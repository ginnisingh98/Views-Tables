--------------------------------------------------------
--  DDL for Package Body OE_HOLDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_HOLDS_PVT" AS
/* $Header: OEXVHLDB.pls 120.21.12010000.19 2010/04/07 04:42:25 spothula ship $ */

--  Global constant holding the package name

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'OE_Holds_Pvt';


Procedure Release_Hold_Source (
   p_hold_source_rec    IN   OE_HOLDS_PVT.Hold_source_Rec_Type,
   p_hold_release_rec   IN   OE_HOLDS_PVT.hold_release_rec_type,
   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
);


/****************************/
/*    entity_code_value     */
/****************************/
/*
*
*/
function entity_code_value (
      p_hold_entity_code IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE
       )
  return VARCHAR2
IS
 l_hold_entity_code_value    VARCHAR2 (100) := NULL;


 CURSOR hold_entity_code_value IS
   select meaning
     from oe_lookups
    where LOOKUP_TYPE = 'HOLD_ENTITY_DESC'
      and LOOKUP_CODE = p_hold_entity_code
      and rownum = 1;

BEGIN

  OPEN hold_entity_code_value;
  FETCH hold_entity_code_value
   INTO l_hold_entity_code_value;
  CLOSE hold_entity_code_value;

  return l_hold_entity_code_value;

END entity_code_value;
/*********************/
/*8477694*/
function check_system_holds(
 p_hold_id           IN   NUMBER,
 x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                             )
RETURN varchar2
IS
 l_authorized_or_not varchar2(1) := 'Y';
 l_return_status Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

  x_return_status := l_return_status;
  x_msg_count := 0;
  x_msg_data := NULL;


/* 7576948: IR ISO Change Management project Start */

-- In the below IF check for system holds, Hold_id 17 is added
-- for IR ISO change management project. This is a seeded system
-- hold, responsible for applying and release IR ISO hold, which
-- can be applied/released only by the Purchasing product, while
-- internal requisition / requisition line gets changed by the
-- requesting organization user. The judiciously application
-- and releasing of this hold will be done by Purchasing APIs.
-- OM has no APIs for calling the direct Application or Releasing
-- of this seeded system hold for any business flow other than
-- Internal Sales Order flow.
--
-- The application of this seeded hold can be done via OM API
-- OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq, while it can
-- be released via OE_Internal_Requisition_Pvt.Release_Hold_for_IReq
-- The call to both these APIs will be done from Purchasing APIs only.
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc

 IF p_hold_id in (13,14,15,17) THEN

/* ============================= */
/* IR ISO Change Management Ends */

   oe_debug_pub.add('renga: hold not authorized - ');
   l_authorized_or_not := 'N';

 END IF;

 return l_authorized_or_not;

END check_system_holds;
/*8477694*/




/*=======================*/
/* Private procedures    */
/*=======================*/
function get_user_id
  return number
IS
BEGIN
 return NVL(FND_GLOBAL.USER_ID, -1);
END get_user_id;


function entity_id_value (
      p_hold_entity_code IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE,
      p_hold_entity_id   IN OE_HOLD_SOURCES_ALL.HOLD_ENTITY_ID%TYPE )
  return VARCHAR2
IS
 l_hold_entity_id_value    VARCHAR2 (100) := NULL;

 CURSOR order_value_cur IS
   select order_number
     from oe_order_headers
    where header_id = p_hold_entity_id
      and rownum = 1;

 CURSOR item_value_cur IS
   select concatenated_segments
     from mtl_system_items_kfv
    where inventory_item_id = p_hold_entity_id;

/* Following cursor has been changed to use direct TCA tables -Bug 1874065*/
/* CURSOR customer_value_cur IS
   select customer_name
     from ra_customers
    where customer_id = p_hold_entity_id;
*/
 CURSOR customer_value_cur IS
   select substrb(party.party_name,1,50) customer_name
     from hz_parties party, hz_cust_accounts cust_acct
    where party.party_id  = cust_acct.party_id
      AND cust_acct.cust_account_id = p_hold_entity_id;

 CURSOR ship_to_value_cur IS
   select name
     from oe_ship_to_orgs_v
    where ORGANIZATION_ID = p_hold_entity_id;

 CURSOR bill_to_value_cur IS
   select name
     from oe_invoice_to_orgs_v
    where ORGANIZATION_ID = p_hold_entity_id;

 CURSOR ship_from_value_cur IS
   select name
     from oe_ship_from_orgs_v
    where ORGANIZATION_ID = p_hold_entity_id;

--ER#7479609 start
 CURSOR deliver_to_value_cur IS
   select name
     from oe_deliver_to_orgs_v
    where ORGANIZATION_ID = p_hold_entity_id;

 CURSOR payment_type_value_cur IS
   SELECT name
   FROM oe_payment_types_vl
   WHERE payment_type_code = p_hold_entity_id;

 CURSOR payment_term_value_cur IS
   select name
   from ra_terms
   WHERE term_id = p_hold_entity_id;

 CURSOR price_list_value_cur IS
   select name
   from qp_list_headers_vl
   WHERE list_header_id = p_hold_entity_id;

 CURSOR transaction_type_value_cur IS
   select name
   from oe_transaction_types
   WHERE transaction_type_id = p_hold_entity_id;

 CURSOR source_type_value_cur IS
   select meaning
   from oe_lookups
   WHERE lookup_code= p_hold_entity_id
   AND lookup_type = 'SOURCE_TYPE';

 CURSOR shipping_method_value_cur IS
   select meaning
   from oe_ship_methods_v
   WHERE lookup_code= p_hold_entity_id
   AND lookup_type = 'SHIP_METHOD';

 CURSOR currency_value_cur IS
   select name
   from fnd_currencies_vl
   WHERE currency_code = p_hold_entity_id;

 CURSOR salesrep_value_cur IS
   select name
   from ra_salesreps
   WHERE salesrep_id = p_hold_entity_id;

 CURSOR sales_channel_value_cur IS
   select meaning
   from oe_lookups
   WHERE lookup_code= p_hold_entity_id
   AND lookup_type = 'SALES_CHANNEL';

 CURSOR project_value_cur IS
   select PROJECT_NAME
   from PJM_PROJECTS_ORG_OU_SECURE_V
   WHERE PROJECT_ID = p_hold_entity_id;

 CURSOR task_value_cur IS
   select TASK_NAME
   from PJM_TASKS_OU_V
   WHERE TASK_ID = p_hold_entity_id;

 CURSOR user_value_cur IS
   select user_name
   from fnd_user
   WHERE user_id = p_hold_entity_id;

--ER#7479609 end

BEGIN

  if p_hold_entity_code = 'O' THEN
    OPEN order_value_cur;
    FETCH order_value_cur
     INTO l_hold_entity_id_value;
    CLOSE order_value_cur;
  --ER#7479609 elsif p_hold_entity_code = 'I' THEN
  elsif p_hold_entity_code in ('I','OI','TM') THEN  --ER#7479609
    OPEN item_value_cur;
    FETCH item_value_cur
      into l_hold_entity_id_value;
    CLOSE item_value_cur;
  elsif p_hold_entity_code = 'C' THEN
    OPEN customer_value_cur;
    FETCH customer_value_cur
      into l_hold_entity_id_value;
    CLOSE customer_value_cur;
  elsif p_hold_entity_code = 'S' THEN
    OPEN ship_to_value_cur;
    FETCH ship_to_value_cur
      into l_hold_entity_id_value;
    CLOSE ship_to_value_cur;
  elsif p_hold_entity_code = 'B' THEN
    OPEN bill_to_value_cur;
    FETCH bill_to_value_cur
      into l_hold_entity_id_value;
    CLOSE bill_to_value_cur;
  elsif p_hold_entity_code = 'W' THEN
    OPEN ship_from_value_cur;
    FETCH ship_from_value_cur
      into l_hold_entity_id_value;
    CLOSE ship_from_value_cur;
  elsif p_hold_entity_code = 'H' THEN
    l_hold_entity_id_value := p_hold_entity_id;
  elsif p_hold_entity_code = 'L' THEN
    l_hold_entity_id_value := p_hold_entity_id;
--ER#7479609 start
  elsif p_hold_entity_code = 'D' THEN
    OPEN deliver_to_value_cur;
    FETCH deliver_to_value_cur
      into l_hold_entity_id_value;
    CLOSE deliver_to_value_cur;
  elsif p_hold_entity_code = 'P' THEN
    OPEN payment_type_value_cur;
    FETCH payment_type_value_cur
      into l_hold_entity_id_value;
    CLOSE payment_type_value_cur;
 elsif p_hold_entity_code = 'PT' THEN
    OPEN payment_term_value_cur;
    FETCH payment_term_value_cur
      into l_hold_entity_id_value;
    CLOSE payment_term_value_cur;

  elsif p_hold_entity_code = 'PL' THEN
    OPEN price_list_value_cur;
    FETCH price_list_value_cur
      into l_hold_entity_id_value;
    CLOSE price_list_value_cur;

  elsif p_hold_entity_code in ('OT','LT') THEN
    OPEN transaction_type_value_cur;
    FETCH transaction_type_value_cur
      into l_hold_entity_id_value;
    CLOSE transaction_type_value_cur;

  elsif p_hold_entity_code = 'ST' THEN
    OPEN source_type_value_cur;
    FETCH source_type_value_cur
      into l_hold_entity_id_value;
    CLOSE source_type_value_cur;

  elsif p_hold_entity_code = 'SM' THEN
    OPEN shipping_method_value_cur;
    FETCH shipping_method_value_cur
      into l_hold_entity_id_value;
    CLOSE shipping_method_value_cur;

  elsif p_hold_entity_code = 'TC' THEN
    OPEN currency_value_cur;
    FETCH currency_value_cur
      into l_hold_entity_id_value;
    CLOSE currency_value_cur;

  elsif p_hold_entity_code = 'SC' THEN
    OPEN sales_channel_value_cur;
    FETCH sales_channel_value_cur
      into l_hold_entity_id_value;
    CLOSE sales_channel_value_cur;

  elsif p_hold_entity_code = 'PR' THEN
    OPEN project_value_cur;
    FETCH project_value_cur
      into l_hold_entity_id_value;
    CLOSE project_value_cur;

  elsif p_hold_entity_code = 'T' THEN
    OPEN task_value_cur;
    FETCH task_value_cur
      into l_hold_entity_id_value;
    CLOSE task_value_cur;

  elsif p_hold_entity_code = 'CB' THEN
    OPEN user_value_cur;
    FETCH user_value_cur
      into l_hold_entity_id_value;
    CLOSE user_value_cur;

  elsif p_hold_entity_code = 'CD' THEN
    l_hold_entity_id_value := p_hold_entity_id;
--ER#7479609 end
  end if;

  return l_hold_entity_id_value;

END entity_id_value;
--------------------------
function hold_name(
      p_hold_source_id  IN  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE)
  return varchar2
IS
  l_hold_name oe_hold_definitions.name%type := '';
BEGIN
  select hd.name
    into l_hold_name
    from oe_hold_sources     hs,
         oe_hold_definitions hd
   where hs.HOLD_SOURCE_ID = p_hold_source_id
     and hs.hold_id = hd.hold_id;

  return l_hold_name;
END hold_name;

------------------
function user_name (
     p_user_id   IN  FND_USER.USER_ID%TYPE )
   return VARCHAR2
IS
 l_user_name VARCHAR2(100) := '';
BEGIN
  select USER_NAME
    into l_user_name
    from fnd_user
   where USER_ID = p_user_id;
  return l_user_name;
END user_name;
-----------------

/*
NAME :
       progress_order
BRIEF DESCRIPTION  :
       This API is called when a workflow based hold is released to progress
       the workflow of affected lines/orders if eligible.Introduced as a part
       of ER 1373910.
CALLER :
       1. Process_release_holds_lines
       2. Process_release_holds_orders
RELEASE LEVEL :
       12.1.1 and higher.
PARAMETERS :
       p_num_of_records  Number of records affected by the hold release.
                         Determines whether workflow should be progressed
			 or deferred.
       p_order_tbl       Details of affected order/line.
       x_return_status   Return status
*/
PROCEDURE progress_order( p_hold_id            IN NUMBER,
                          p_num_of_records     IN NUMBER,
                          p_order_tbl          OE_HOLDS_PVT.order_tbl_type,
                          x_return_status      OUT NOCOPY VARCHAR2,
			  x_msg_count          OUT NOCOPY NUMBER,
                          x_msg_data           OUT NOCOPY VARCHAR2
                         )
IS

l_rel_threshold    NUMBER;
l_release_children VARCHAR2(10) := 'N';
l_result           VARCHAR2(10);
l_item_type        VARCHAR2(10);
l_activity         VARCHAR2(250);
l_hold_activity    VARCHAR2(250);
l_found            VARCHAR2(2) := 'T';

CURSOR c_child_lines(p_header_id IN NUMBER, p_activity_name IN VARCHAR2)
IS
SELECT wpa_to.process_name || ':' || wpa_to.activity_name full_activity_name,
       wias_to.item_type,
       wias_to.item_key
FROM   wf_item_activity_statuses wias_to,
       wf_process_activities wpa_to,
       wf_activities wa,
       wf_item_activity_statuses wias_from,
       wf_process_activities wpa_from,
       wf_activity_transitions wat,
       wf_items wi
WHERE  wpa_to.instance_id= wias_to.process_activity
AND    wat.to_process_activity = wpa_to.instance_id
AND    wat.result_code = 'ON_HOLD'
AND    wias_from.process_activity = wat.from_process_activity
AND    wpa_from.instance_id = wias_from.process_activity
AND    wpa_from.activity_name = p_activity_name  -- 8284926
AND    wias_from.activity_result_code = 'ON_HOLD'
AND    wias_from.end_date IS NOT NULL
AND    wias_from.item_type = 'OEOL'
AND    wi.parent_item_key = To_Char(p_header_id)
AND    wa.item_type = wias_to.item_type
AND    wa.NAME = wpa_to.activity_name
AND    wa.FUNCTION = 'OE_STANDARD_WF.STANDARD_BLOCK'
AND    wa.end_date IS NULL
AND    wias_to.end_date IS NULL
AND    wias_to.activity_status = 'NOTIFIED'
AND    wias_to.item_type = wias_from.item_type
AND    wias_to.item_key = wias_from.item_key
AND    wi.item_type = wias_to.item_type
AND    wias_to.item_key = wi.item_key;

BEGIN

  l_rel_threshold :=  wf_engine.threshold;
  SAVEPOINT progress_order;

  -- Begin : 8284926
  -- Get the activity name on which the hold is defined
  BEGIN
	SELECT activity_name
	INTO   l_hold_activity
	FROM   oe_hold_definitions
	WHERE  hold_id = p_hold_id;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Oe_debug_pub.ADD('Activity name not found!!');
	WHEN OTHERS THEN
		Oe_debug_pub.ADD(SQLERRM);
  END;

  IF l_hold_activity IS NULL THEN
	RETURN;    -- No further processing is needed.
  ELSE
	Oe_debug_pub.ADD('Hold Activity name : ' || l_hold_activity);
  END IF;
  -- End : 8284926

  /*
     This section will be executed in the following situation :
     1. Hold is defined on a line and is workflow based.
     2. Hold definition has its apply_to_order_and_line_flag
        = 'Y'
     If such an hold is applied on an order, the following code
     takes care that the child lines are also progressed when it
     is released.
  */

  IF p_order_tbl(1).line_id IS NULL THEN
	  BEGIN
	      SELECT 'Y'
	      INTO   l_release_children
	      FROM   oe_order_holds oh,
		     oe_hold_sources hs,
		     oe_hold_definitions hd
	      WHERE  hs.hold_source_id = oh.hold_source_id
	      AND    hs.hold_id = hd.hold_id
	      AND    hd.hold_id = p_hold_id
	      AND    oh.header_id = p_order_tbl(1).header_id
	      AND    oh.line_id IS NULL
	      AND    hs.hold_entity_code = 'O'
	      AND    hs.hold_entity_id = p_order_tbl(1).header_id
	      AND    NVL(hd.item_type, 'INVALID') = 'OEOL'
	      AND    hd.activity_name IS NOT NULL
	      AND    NVL(hd.apply_to_order_and_line_flag,'N') = 'Y';

	  EXCEPTION
	      WHEN NO_DATA_FOUND THEN
		  Oe_debug_pub.ADD('Normal hold release.');
	      WHEN OTHERS THEN
		  Oe_debug_pub.ADD(SQLERRM);
		  -- RAISE;
	  END;

	  IF l_release_children = 'Y' THEN

		Oe_debug_pub.ADD('Handling apply_to_order_and_line_flag..');

	        wf_engine.threshold :=  -1;

		FOR c_rec IN c_child_lines(p_order_tbl(1).header_id, l_hold_activity)
		LOOP
			Oe_debug_pub.ADD('Processing OEOL : ' || c_rec.item_key);
			wf_engine.CompleteActivity('OEOL', c_rec.item_key, c_rec.full_activity_name, l_result);
		END LOOP;

		wf_engine.threshold := l_rel_threshold;
		x_return_status := FND_API.G_RET_STS_SUCCESS;
		Oe_msg_pub.Count_And_Get
			( p_count => x_msg_count
			 ,p_data  => x_msg_data
			);
		RETURN;
	  END IF;
  END IF;

  /* This section will take care of the normal situation */

  IF p_num_of_records > 1 THEN
    wf_engine.threshold :=  -1 ;
  END IF;

  Oe_debug_pub.ADD('p_num_of_records : ' || p_num_of_records);

  FOR i in p_order_tbl.FIRST..p_order_tbl.LAST
  LOOP
	  BEGIN

		/* This select statement will pick up the activity which fulfills
		   the following criteria :
		   1. Activity is based on a OE_STANDARD_WF.STANDARD_BLOCK function
		   2. Activity is in a 'NOTIFIED' status
		   3. Activity has been reached via a transition of 'ON_HOLD'
		   4. For a given item_type and item_key
		*/
		l_found := 'T';

		SELECT wpa_to.process_name || ':' || wpa_to.activity_name,
		       wias_to.item_type
		INTO   l_activity, l_item_type
		FROM   wf_item_activity_statuses wias_to,
		       wf_process_activities wpa_to,
		       wf_activities wa,
		       wf_item_activity_statuses wias_from,
		       wf_process_activities wpa_from,
		       wf_activity_transitions wat
		WHERE  wpa_to.instance_id= wias_to.process_activity
		AND    wat.to_process_activity = wpa_to.instance_id
		AND    wat.result_code = 'ON_HOLD'
		AND    wias_from.process_activity = wat.from_process_activity
		AND    wpa_from.instance_id = wias_from.process_activity
                AND    wpa_from.activity_name = l_hold_activity  -- 8284926
		AND    wias_from.activity_result_code = 'ON_HOLD'
		AND    wias_from.end_date IS NOT NULL
		AND    wias_from.item_type = DECODE(p_order_tbl(i).line_id, NULL, 'OEOH', 'OEOL')
		AND    wias_from.item_key = To_Char(NVL(p_order_tbl(i).line_id,p_order_tbl(i).header_id))
		AND    wa.item_type = wias_to.item_type
		AND    wa.NAME = wpa_to.activity_name
		AND    wa.FUNCTION = 'OE_STANDARD_WF.STANDARD_BLOCK'
		AND    wa.end_date IS NULL
		AND    wias_to.end_date IS NULL
		AND    wias_to.activity_status = 'NOTIFIED'
		AND    wias_to.item_type = wias_from.item_type
		AND    wias_to.item_key = wias_from.item_key;

		Oe_debug_pub.ADD('Processing ' || l_item_type || ':' || NVL(p_order_tbl(i).line_id,p_order_tbl(i).header_id));

	  EXCEPTION
	     WHEN OTHERS THEN
		  Oe_debug_pub.ADD('Could not get activity ID for header/line : ' || To_Char(NVL(p_order_tbl(i).line_id,p_order_tbl(i).header_id)));
		  l_found := 'F';
		  -- Do not raise an exception here as the query might fail because
		  -- entity being processed is not at this workflow stage (not reached
		  -- yet/ crossed already). This is a valid scenario. say, line hasn't
		  -- been booked but scheduling hold is being released. So the
		  -- processing must resume for the other lines.

		  -- RAISE;
	  END;

	  -- Begin : 8284926
          -- For BOOK_ORDER activity, search the history tables also as the ON_HOLD
          -- transition is moved into the history table

          IF l_found = 'F' AND l_hold_activity = 'BOOK_ORDER' THEN
		BEGIN

		  l_found := 'T';

		  SELECT wpa_to.process_name || ':' || wpa_to.activity_name,
		         wias_to.item_type
	          INTO   l_activity, l_item_type
	          FROM   wf_item_activity_statuses wias_to,
			 wf_process_activities wpa_to,
			 wf_activities wa,
			 wf_item_activity_statuses_h wias_from,
			 wf_process_activities wpa_from,
			 wf_activity_transitions wat
		  WHERE  wpa_to.instance_id= wias_to.process_activity
		  AND    wat.to_process_activity = wpa_to.instance_id
		  AND    wat.result_code = 'ON_HOLD'
		  AND    wias_from.process_activity = wat.from_process_activity
		  AND    wpa_from.instance_id = wias_from.process_activity
		  AND    wpa_from.activity_name = l_hold_activity  -- 8284926
		  AND    wias_from.activity_result_code = 'ON_HOLD'
		  AND    wias_from.end_date = wias_to.begin_date
		  AND    wias_from.item_type = DECODE(p_order_tbl(i).line_id, NULL, 'OEOH', 'OEOL')
		  AND    wias_from.item_key = To_Char(NVL(p_order_tbl(i).line_id,p_order_tbl(i).header_id))
		  AND    wa.item_type = wias_to.item_type
		  AND    wa.NAME = wpa_to.activity_name
		  AND    wa.FUNCTION = 'OE_STANDARD_WF.STANDARD_BLOCK'
		  AND    wa.end_date IS NULL
		  AND    wias_to.end_date IS NULL
		  AND    wias_to.activity_status = 'NOTIFIED'
		  AND    wias_to.item_type = wias_from.item_type
		  AND    wias_to.item_key = wias_from.item_key;

		EXCEPTION
		  WHEN OTHERS THEN
			  Oe_debug_pub.ADD('Could not get activity ID for header (history) : ' || To_Char(NVL(p_order_tbl(i).line_id,p_order_tbl(i).header_id)));
			  l_found := 'F';
		END;
	  END IF;

	  -- End : 8284926

	  IF l_found = 'T' THEN
		wf_engine.CompleteActivity(l_item_type, To_Char(NVL(p_order_tbl(1).line_id,p_order_tbl(1).header_id)),l_activity, l_result);
	  END IF;

  END LOOP;

  wf_engine.threshold :=  l_rel_threshold;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Oe_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data  => x_msg_data
        );

EXCEPTION
  WHEN OTHERS THEN
    Oe_debug_pub.ADD('Failed from progress order.');
    wf_engine.threshold :=  l_rel_threshold;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Oe_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data  => x_msg_data
        );
    ROLLBACK TO progress_order;

END progress_order;


/*
NAME :
       progress_order
BRIEF DESCRIPTION  :
       This overloaded version of API is called when a workflow based hold
       SOURCE is released to progress the workflow of affected lines/orders
       if eligible.Introduced as a part of ER 1373910.
CALLER :
       1. Process_release_source
RELEASE LEVEL :
       12.1.1 and higher.
PARAMETERS :
       p_hold_source_id  Released hold source
       x_return_status   Return status
*/

PROCEDURE progress_order( p_hold_source_id      IN NUMBER,
                          x_return_status       OUT NOCOPY VARCHAR2,
			  x_msg_count           OUT NOCOPY NUMBER,
                          x_msg_data            OUT NOCOPY VARCHAR2
                        )
IS

l_rel_threshold    NUMBER;
l_result           VARCHAR2(10);
l_activity         VARCHAR2(250);
l_hold_activity    VARCHAR2(250);
l_found            VARCHAR2(2) := 'T';
l_item_type        VARCHAR2(10);
l_hold_entity_code VARCHAR2(10);

CURSOR released_orders_lines
IS
SELECT NVL(line_id, header_id) entity_id,
       DECODE(line_id , NULL, 'OEOH', 'OEOL') entity_type
FROM   oe_order_holds oh, oe_hold_sources hs
WHERE  hs.hold_source_id = p_hold_source_id
AND    oh.hold_release_id = hs.hold_release_id
AND    oh.released_flag = 'Y';

BEGIN

  Oe_debug_pub.ADD('In overloaded progress_order!!');

  l_rel_threshold :=  wf_engine.threshold;

  -- Begin : 8284926
  -- Get the activity name on which the hold is defined
  BEGIN
	SELECT hd.activity_name
	INTO   l_hold_activity
	FROM   oe_hold_definitions hd, oe_hold_sources hs
	WHERE  hd.hold_id = hs.hold_id
	AND    hs.hold_source_id = p_hold_source_id;
  EXCEPTION
	WHEN NO_DATA_FOUND THEN
		Oe_debug_pub.ADD('Activity name not found!!');
	WHEN OTHERS THEN
		Oe_debug_pub.ADD(SQLERRM);
  END;

  IF l_hold_activity IS NULL THEN
	RETURN;    -- No further processing is needed.
  END IF;
  -- End : 8284926

  BEGIN
      SELECT hold_entity_code
      INTO   l_hold_entity_code
      FROM   oe_hold_sources
      WHERE  hold_source_id = p_hold_source_id;
  EXCEPTION
      WHEN OTHERS THEN
          Oe_debug_pub.ADD('Source not found.!!');
          -- RAISE;
  END;

  IF NVL(l_hold_entity_code,'INVALID') <> 'O' THEN
      wf_engine.threshold :=  -1 ;
  END IF;

  FOR x IN released_orders_lines LOOP

      BEGIN

	/* This select statement will pick up the activity which fulfills
	   the following criteria :
	   1. Activity is based on a OE_STANDARD_WF.STANDARD_BLOCK function
	   2. Activity is in a 'NOTIFIED' status
	   3. Activity has been reached via a transition of 'ON_HOLD'
	   4. For a given item_type and item_key
	*/
	l_found := 'T';

	SELECT wpa_to.process_name || ':' || wpa_to.activity_name,
	       wias_to.item_type
        INTO   l_activity, l_item_type
        FROM   wf_item_activity_statuses wias_to,
               wf_process_activities wpa_to,
               wf_activities wa,
               wf_item_activity_statuses wias_from,
	       wf_process_activities wpa_from,
               wf_activity_transitions wat
        WHERE  wpa_to.instance_id= wias_to.process_activity
        AND    wat.to_process_activity = wpa_to.instance_id
	AND    wat.result_code = 'ON_HOLD'
        AND    wias_from.process_activity = wat.from_process_activity
	AND    wpa_from.instance_id = wias_from.process_activity
        AND    wpa_from.activity_name = l_hold_activity  -- 8284926
        AND    wias_from.activity_result_code = 'ON_HOLD'
        AND    wias_from.end_date IS NOT NULL
        AND    wias_from.item_type = x.entity_type
        AND    wias_from.item_key = To_Char(x.entity_id)
        AND    wa.item_type = wias_to.item_type
        AND    wa.NAME = wpa_to.activity_name
        AND    wa.FUNCTION = 'OE_STANDARD_WF.STANDARD_BLOCK'
        AND    wa.end_date IS NULL
        AND    wias_to.end_date IS NULL
        AND    wias_to.activity_status = 'NOTIFIED'
        AND    wias_to.item_type = wias_from.item_type
        AND    wias_to.item_key = wias_from.item_key;

        Oe_debug_pub.ADD('Processing ' || l_item_type || ':' || x.entity_id);
      EXCEPTION
        WHEN OTHERS THEN
          Oe_debug_pub.ADD('Could not get activity ID for header/line : ' || x.entity_id);
          l_found := 'F';
	  -- Do not raise an exception here as the query might fail because
	  -- entity being processed is not at this workflow stage (not reached
	  -- yet/ crossed already). This is a valid scenario. say, line hasn't
	  -- been booked but scheduling hold is being released. So the
	  -- processing must resume for the other lines.

	  -- RAISE;
       END;

       -- Begin : 8284926
       -- For BOOK_ORDER activity, search the workflow history table also as the ON_HOLD
       -- transition is moved into the history table

       IF l_found = 'F' AND l_hold_activity = 'BOOK_ORDER' THEN
	       BEGIN

		  l_found := 'T';

		  SELECT wpa_to.process_name || ':' || wpa_to.activity_name,
			 wias_to.item_type
		  INTO   l_activity, l_item_type
		  FROM   wf_item_activity_statuses wias_to,
			 wf_process_activities wpa_to,
			 wf_activities wa,
			 wf_item_activity_statuses_h wias_from,
			 wf_process_activities wpa_from,
			 wf_activity_transitions wat
		  WHERE  wpa_to.instance_id= wias_to.process_activity
		  AND    wat.to_process_activity = wpa_to.instance_id
		  AND    wat.result_code = 'ON_HOLD'
		  AND    wias_from.process_activity = wat.from_process_activity
		  AND    wpa_from.instance_id = wias_from.process_activity
                  AND    wpa_from.activity_name = l_hold_activity  -- 8284926
		  AND    wias_from.activity_result_code = 'ON_HOLD'
		  AND    wias_from.end_date = wias_to.begin_date
		  AND    wias_from.item_type = x.entity_type
		  AND    wias_from.item_key = To_Char(x.entity_id)
		  AND    wa.item_type = wias_to.item_type
		  AND    wa.NAME = wpa_to.activity_name
		  AND    wa.FUNCTION = 'OE_STANDARD_WF.STANDARD_BLOCK'
		  AND    wa.end_date IS NULL
		  AND    wias_to.end_date IS NULL
		  AND    wias_to.activity_status = 'NOTIFIED'
		  AND    wias_to.item_type = wias_from.item_type
		  AND    wias_to.item_key = wias_from.item_key;

	      EXCEPTION
		WHEN OTHERS THEN
		  Oe_debug_pub.ADD('Could not get activity ID for header (history) : ' || x.entity_id);
		  l_found := 'F';
	      END;
       END IF;

       -- End : 8284926

       SAVEPOINT progress_order;

       IF l_found = 'T' THEN
           wf_engine.CompleteActivity(l_item_type, To_Char(x.entity_id),l_activity, l_result);
       END IF;

  END LOOP;

  wf_engine.threshold :=  l_rel_threshold;
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  Oe_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data  => x_msg_data
        );

EXCEPTION
  WHEN OTHERS THEN
    OE_debug_pub.ADD('Failed from progress order');
    wf_engine.threshold :=  l_rel_threshold;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    Oe_msg_pub.Count_And_Get
        ( p_count => x_msg_count
         ,p_data  => x_msg_data
        );
    ROLLBACK TO progress_order;
END progress_order;

-------------------------------------
-- CHECK_AUTHORIZATION
-------------------------------------
function check_authorization (
 p_hold_id           IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
 p_authorized_action_code IN OE_HOLD_AUTHORIZATIONS.AUTHORIZED_ACTION_CODE%TYPE,
 p_responsibility_id IN OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE,
 p_application_id    IN OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE,
 x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
 x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
 x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                             )
RETURN varchar2
IS
 l_auth_exists   Varchar2(1) := 'N';
 l_authorized_or_not varchar2(1) := 'Y';
 l_dummy VARCHAR2(1);
BEGIN
 OE_Debug_PUB.Add('Hold Check_Authorization Action' ||
								   p_authorized_action_code,1);
 OE_Debug_PUB.Add('Hold_id' || to_char(p_hold_id),1);
 OE_Debug_PUB.Add('Responsibility_Id' || to_char(p_responsibility_id),1);
 OE_Debug_PUB.Add('Application_Id' || to_char(p_application_id),1);
 begin
      select 'Y'
        Into l_auth_exists
        from oe_hold_authorizations
       where hold_id = p_hold_id
         and authorized_action_code = p_authorized_action_code
         and rownum = 1;
   Exception
        When NO_DATA_FOUND Then
		   OE_Debug_PUB.Add('No Authorization exists, Authorized=Yes',1);
             l_authorized_or_not := 'Y';
             l_auth_exists := 'N';
        when others then
             null;
  End;

  if l_auth_exists = 'Y' then
   begin
    select 'x'
      into l_dummy
      from oe_hold_authorizations
     where sysdate between nvl(start_date_active,sysdate)
                       and nvl(end_date_active,sysdate)
       and authorized_action_code = p_authorized_action_code
       and responsibility_id = p_responsibility_id
       and application_id   = p_application_id
       and hold_id          = p_hold_id
       and rownum = 1;
    exception
       when no_data_found then
	    OE_Debug_PUB.Add('Not Authorized', 1);
         l_authorized_or_not := 'N';
       when others then
         null;
    end;
   end if;
 return l_authorized_or_not;
END check_authorization;



--ER#7479609 start
---------------------------------------------------------------------------------------------------
-- PROCEDURE   : InsertTable_OOH_Header
-- DESCRIPTION : This is a Local Procedure used to insert record into the OE_ORDER_HOLDS_ALL table
--               for header level holds

-- Caller      : Create_Order_Holds Procedure
-- PARAMETERS:
-- p_hold_source_id  : Hold Source Id of the hold
-- p_header_id       : Line Id if the hold is applied using action -> apply hold for a specific Hold
--                     and BLANK if a hold source is created for a header level attribute
-- p_org_id          : Operating Unit ID
-- p_hold_entity_where_clause : Condition for the hold criteria selected
-- p_item_type	     : Workflow item type like 'OEOH' or 'OEOL'
-- p_activity_name   : Workflow activity name
-- p_activity_status : Workflow activity status
-- p_additional_where_clause : Its derived from the p_item_type and p_activity_name
---------------------------------------------------------------------------------------------------
Procedure InsertTable_OOH_Header (p_hold_source_id  OE_HOLD_SOURCES_ALL.hold_source_id%type
			    ,p_header_id       OE_ORDER_HEADERS_ALL.header_id%type
			    ,p_org_id          OE_ORDER_HEADERS_ALL.org_id%type
			    ,p_hold_entity_where_clause VARCHAR2
			    ,p_item_type	      VARCHAR2
			    ,p_activity_name   VARCHAR2
			    ,p_activity_status VARCHAR2
			    ,p_additional_where_clause VARCHAR2
			    ,x_is_hold_applied OUT NOCOPY BOOLEAN)
IS
l_user_id NUMBER := OE_HOLDS_PVT.get_user_id;
l_parent_count NUMBER;
l_user_activity_name     VARCHAR2(80);
l_sql_rowcount NUMBER;
l_sqlmt VARCHAR2(3000);
l_wf_sqlmt VARCHAR2(3000);

BEGIN

   OE_DEBUG_PUB.ADD('Entering InsertTable_OOH_Header');

   IF p_header_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  ''N''
     ,  h.org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id
       and h.header_id = :header_id
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id IS NULL
                           and oh.hold_source_id =:hold_source_id )';
      IF p_item_type is not null and p_activity_name is not null then
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(h.header_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
       END IF;

      IF p_hold_entity_where_clause IS NOT NULL THEN
         l_sqlmt :=l_sqlmt||'  '||p_hold_entity_where_clause;
      END IF;


       IF p_item_type is null and p_activity_name is null then

          EXECUTE IMMEDIATE
          l_sqlmt USING l_user_id,
                        l_user_id,
                        p_hold_source_id,
                        p_org_id  ,
                        p_header_id,
                        p_hold_source_id;
          IF sql%rowcount = 0 THEN
            x_is_hold_applied := FALSE;
          ELSIF sql%rowcount = 1 THEN
            x_is_hold_applied := TRUE;
          END IF;
       ELSE

	  EXECUTE IMMEDIATE
	  l_sqlmt USING l_user_id,
	                l_user_id,
	                p_hold_source_id,
	                p_org_id ,
	                p_header_id,
	                p_hold_source_id,
	                'OEOH',
	                p_activity_name,
	                p_activity_status,
			 'XXX', 'INCOMPLETE','ON_HOLD'; --9538334;

          IF sql%rowcount = 0 THEN
            x_is_hold_applied := FALSE;
          ELSIF sql%rowcount = 1 THEN
            x_is_hold_applied := TRUE;
          END IF;
       END IF;

   ELSE


    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  ''N''
     ,  h.org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	  and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id IS NULL
                           and oh.hold_source_id =:hold_source_id )';
      IF p_item_type is not null and p_activity_name is not null then
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(h.header_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
      END IF;

      IF p_hold_entity_where_clause IS NOT NULL THEN
         l_sqlmt :=l_sqlmt||'  '||p_hold_entity_where_clause;
      END IF;


     IF p_item_type is null and p_activity_name is null then

        EXECUTE IMMEDIATE
        l_sqlmt USING l_user_id,
                      l_user_id,
                      p_hold_source_id,
                      p_org_id,
                      p_hold_source_id;
     ELSE

         EXECUTE IMMEDIATE
         l_sqlmt USING l_user_id,
                       l_user_id,
                       p_hold_source_id,
                       p_org_id,
                       p_hold_source_id,
                       'OEOH',
                       p_activity_name,
                       p_activity_status,
		        'XXX', 'INCOMPLETE','ON_HOLD'; --9538334;


         l_sql_rowcount := sql%rowcount;

         OE_DEBUG_PUB.ADD('l_sql_rowcount - '||l_sql_rowcount);

     IF l_sql_rowcount = 0 THEN

       SELECT meaning
       INTO l_user_activity_name
       FROM   oe_lookups
       WHERE  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
       AND lookup_code = p_activity_name;

      FND_MESSAGE.SET_NAME('ONT', 'OE_NO_HOLD_ALL_LINES');
      FND_MESSAGE.SET_TOKEN('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      OE_DEBUG_PUB.ADD(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;

     ELSIF l_sql_rowcount > 0 THEN

       l_wf_sqlmt := 'SELECT count(*)
       FROM OE_ORDER_HEADERS_ALL h
       WHERE h.OPEN_FLAG = ''Y''
       AND nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
       AND NOT EXISTS ( select ''x''
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.hold_source_id = '||p_hold_source_id||' )';

      IF p_hold_entity_where_clause IS NOT NULL THEN
         l_wf_sqlmt :=l_wf_sqlmt||'  '||p_hold_entity_where_clause;
      END IF;


      EXECUTE IMMEDIATE l_wf_sqlmt INTO l_parent_count;

/* Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables. */

     OE_DEBUG_PUB.ADD('l_parent_count - '||l_parent_count);

     IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        SELECT meaning
        INTO l_user_activity_name
        FROM   oe_lookups
        WHERE  lookup_type = DECODE(p_item_type,
        				OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        				OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        AND    lookup_code = p_activity_name;

        FND_MESSAGE.SET_NAME('ONT', 'OE_NO_HOLD_FEW_LINES');
        FND_MESSAGE.SET_TOKEN('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        OE_DEBUG_PUB.ADD(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
    END IF;
   END IF;
   OE_DEBUG_PUB.ADD('Exiting InsertTable_OOH_Header Successfully');
EXCEPTION
WHEN OTHERS THEN
   OE_DEBUG_PUB.ADD('Exiting InsertTable_OOH_Header with Error:'||SQLCODE);
END InsertTable_OOH_Header;
--ER#7479609 end


--ER#7479609 start
---------------------------------------------------------------------------------------------------
-- PROCEDURE   : InsertTable_OOH_Line
-- DESCRIPTION : This is a Local Procedure used to insert record into the OE_ORDER_HOLDS_ALL table
--               for line level holds

-- Caller      : Create_Order_Holds Procedure
-- PARAMETERS:
-- p_hold_source_id  : Hold Source Id of the hold
-- p_line_id         : Line Id if the hold is applied using action -> apply hold for a specific Hold
--                     and BLANK if a hold source is created for a line level attribute
-- p_org_id          : Operating Unit ID
-- p_hold_entity_where_clause : Condition for the hold criteria selected
-- p_item_type	     : Workflow item type like 'OEOH' or 'OEOL'
-- p_activity_name   : Workflow activity name
-- p_activity_status : Workflow activity status
-- p_additional_where_clause : Its derived from the p_item_type and p_activity_name
---------------------------------------------------------------------------------------------------
Procedure InsertTable_OOH_Line (p_hold_source_id  OE_HOLD_SOURCES_ALL.hold_source_id%type,
			    p_line_id         OE_ORDER_LINES_ALL.line_id%type,
			    p_org_id          OE_ORDER_HEADERS_ALL.org_id%type,
			    p_hold_entity_where_clause VARCHAR2,
			    p_item_type	      VARCHAR2,
			    p_activity_name   VARCHAR2,
			    p_activity_status VARCHAR2,
			    p_additional_where_clause VARCHAR2,
			    x_is_hold_applied OUT NOCOPY BOOLEAN)
IS
l_user_id NUMBER := OE_HOLDS_PVT.get_user_id;
l_parent_count NUMBER;
l_user_activity_name     VARCHAR2(80);
l_sql_rowcount NUMBER;
l_sqlmt VARCHAR2(3000);
l_wf_sqlmt VARCHAR2(3000);
BEGIN

  OE_DEBUG_PUB.ADD('Entering InsertTable_OOH_Line');

  IF p_line_id IS NOT NULL THEN

   l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.header_id = ol.header_id
       and h.org_id = :l_org_id
       and ol.line_id = :line_id
       and ol.OPEN_FLAG = ''Y''
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id = :hold_source_id )';
    IF p_item_type is not null and p_activity_name is not null then
       l_sqlmt :=l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
    END IF;

    IF p_additional_where_clause = 'PICK_TRUE' THEN
       l_sqlmt :=l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                                     where w.source_line_id = ol.line_id
                                                     and   w.source_code = ''OE''
                                                     and   w.released_status in (''Y'', ''C''))';
    ELSIF p_additional_where_clause = 'PACK_TRUE' THEN
       l_sqlmt :=l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                                where  wdd.source_line_id = ol.LINE_ID
                                                and    wdd.source_code = ''OE''
                                                and    wda.delivery_detail_id = wdd.delivery_detail_id
                                                and    wda.parent_delivery_detail_id is not null)';
    END IF;

    IF p_hold_entity_where_clause IS NOT NULL THEN
       l_sqlmt :=l_sqlmt||'  '||p_hold_entity_where_clause;
    END IF;

    IF p_item_type is null and p_activity_name is null then

       EXECUTE IMMEDIATE
       l_sqlmt USING l_user_id,
                     l_user_id,
                     p_hold_source_id,
                     p_org_id,
                     p_line_id,
                     p_hold_source_id;

      IF sql%rowcount = 0 THEN
       x_is_hold_applied := FALSE;
      ELSIF sql%rowcount = 1 THEN
       x_is_hold_applied := TRUE;
      END IF;

    ELSE

       EXECUTE IMMEDIATE
       l_sqlmt using l_user_id,
                     l_user_id,
                     p_hold_source_id,
                     p_org_id ,
                     p_line_id,
                     p_hold_source_id,
                     'OEOL',
                     p_activity_name,
                     p_activity_status,
		     'XXX', 'INCOMPLETE','ON_HOLD'; --9538334;

      IF sql%rowcount = 0 THEN
       x_is_hold_applied := FALSE;
      ELSIF sql%rowcount = 1 THEN
       x_is_hold_applied := TRUE;
      END IF;

    END IF;

 ELSE

  l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.header_id = ol.header_id
       and h.org_id = :l_org_id
       and ol.OPEN_FLAG = ''Y''
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                          where oh.header_id = h.header_id
     					  and oh.line_id   = ol.line_id
                          and oh.hold_source_id =:hold_source_id )';

     IF p_item_type is not null and p_activity_name is not null then
        l_sqlmt :=l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
     END IF;

     IF p_additional_where_clause = 'PICK_TRUE' THEN
        l_sqlmt :=l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                     where w.source_line_id = ol.line_id and   w.source_code = ''OE''
                                     and   w.released_status in (''Y'', ''C''))';
     ELSIF p_additional_where_clause = 'PACK_TRUE' THEN
        l_sqlmt :=l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID and    wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
     END IF;

     IF p_hold_entity_where_clause IS NOT NULL THEN
        l_sqlmt :=l_sqlmt||'  '||p_hold_entity_where_clause;
     END IF;


      OE_DEBUG_PUB.ADD('Before Executing SQL:'||l_sqlmt);
    IF p_item_type is null AND p_activity_name is null THEN

       EXECUTE IMMEDIATE
       l_sqlmt USING l_user_id,
       		     l_user_id,
       		     p_hold_source_id,
       		     p_org_id ,
       		     p_hold_source_id;
      OE_DEBUG_PUB.ADD('After Executing SQL for non-WF Hold');
    ELSE

       EXECUTE IMMEDIATE
       l_sqlmt USING l_user_id,
                     l_user_id,
                     p_hold_source_id,
                     p_org_id ,
                     p_hold_source_id,
                     'OEOL',
                     p_activity_name,
                     p_activity_status,
		      'XXX', 'INCOMPLETE','ON_HOLD'; --9538334;;


      l_sql_rowcount := sql%rowcount;
      IF l_sql_rowcount = 0 THEN

       SELECT meaning
       INTO l_user_activity_name
       FROM   oe_lookups
       WHERE  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
       AND    lookup_code = p_activity_name;

      FND_MESSAGE.SET_NAME('ONT', 'OE_NO_HOLD_ALL_LINES');
      FND_MESSAGE.SET_TOKEN('WF_ACT',l_user_activity_name);
      OE_MSG_PUB.ADD;
      OE_DEBUG_PUB.ADD(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;

     ELSIF l_sql_rowcount > 0 THEN
      l_wf_sqlmt := 'SELECT count(*)
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = ''Y''
      AND h.header_id = ol.header_id
      AND ol.OPEN_FLAG = ''Y''
      AND NVL(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
      AND NOT EXISTS ( SELECT ''x''
                       FROM oe_order_holds_ALL oh
                       WHERE oh.header_id = h.header_id
                       AND oh.line_id   = ol.line_id
                       AND oh.hold_source_id = '||p_hold_source_id||' )';

      IF p_hold_entity_where_clause IS NOT NULL THEN
         l_wf_sqlmt :=l_wf_sqlmt||'  '||p_hold_entity_where_clause;
      END IF;

      EXECUTE IMMEDIATE l_wf_sqlmt INTO l_parent_count;

     OE_DEBUG_PUB.ADD('l_parent_count/sql_count'||l_parent_count||sql%rowcount);
/* Note: The above query is used based on WHERE clause of thel_sqlmt but without any query on Workflow or Shipping product tables. */

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        SELECT meaning
        INTO l_user_activity_name
        FROM   oe_lookups
        WHERE  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        AND    lookup_code = p_activity_name;

        FND_MESSAGE.SET_NAME('ONT', 'OE_NO_HOLD_FEW_LINES');
        FND_MESSAGE.SET_TOKEN('WF_ACT',l_user_activity_name);
        OE_MSG_PUB.ADD;
        OE_DEBUG_PUB.ADD(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
    END IF;
   END IF;

   OE_DEBUG_PUB.ADD('Exiting InsertTable_OOH_Line Successfully');
EXCEPTION
WHEN OTHERS THEN
   OE_DEBUG_PUB.ADD('Exiting InsertTable_OOH_Line with Error:'||SQLCODE);
END InsertTable_OOH_Line;
--ER#7479609 end

--ER#7479609 start
---------------------------------------------------------------------------------------------------
-- PROCEDURE   : PaymentType_Hold
-- DESCRIPTION : This is a Local Procedure used to insert record into the OE_ORDER_HOLDS_ALL table
--               for header level holds

-- Caller      : Create_Order_Holds Procedure
-- PARAMETERS:
-- p_hold_source_id  : Hold Source Id of the hold
-- p_header_id       : Line Id if the hold is applied using action -> apply hold for a specific Hold
---------------------------------------------------------------------------------------------------
Procedure PaymentType_Hold (p_hold_source_rec  OE_HOLDS_PVT.Hold_source_Rec_Type
			    ,p_org_id          OE_ORDER_HEADERS_ALL.org_id%type
			    ,p_item_type       VARCHAR2
			    ,p_activity_name   VARCHAR2
			    ,p_activity_status VARCHAR2
			    ,p_additional_where_clause VARCHAR2
			    ,x_is_hold_applied OUT NOCOPY BOOLEAN)
IS

l_payment_count NUMBER := 0;
l_sqlmt VARCHAR2(3000);
l_sqlmt1 VARCHAR2(3000);

TYPE eligible_record_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
l_eligible_record_tab eligible_record_tab;

BEGIN

  OE_DEBUG_PUB.ADD('Entering PaymentType_Hold');

  OE_DEBUG_PUB.ADD('Header_id :'||p_hold_source_rec.header_id);
  OE_DEBUG_PUB.ADD('Line_id :'||p_hold_source_rec.line_id);
  x_is_hold_applied := FALSE;  --8221671

 IF  p_item_type = 'OEOL' or p_item_type IS NULL THEN
  oe_debug_pub.add('Line Level Processing Starts');
  l_eligible_record_tab.delete;

  IF p_hold_source_rec.hold_entity_code = 'P' and p_hold_source_rec.hold_entity_code2 IS NULL   THEN

   l_sqlmt := 'Select line_id
   FROM OE_PAYMENTS OP
   WHERE line_id IS NOT NULL
   AND PAYMENT_TYPE_CODE =:hold_entity_id';


   IF (p_hold_source_rec.header_id IS NOT NULL AND p_hold_source_rec.line_id IS NOT NULL)
       OR (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NOT NULL) THEN

     l_sqlmt := l_sqlmt||'  AND OP.line_id = '||p_hold_source_rec.line_id;

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id;

   ELSIF (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NULL)  THEN

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id;

   END IF;



  ELSIF p_hold_source_rec.hold_entity_code = 'C' and p_hold_source_rec.hold_entity_code2 ='P'   THEN

   l_sqlmt := 'Select OP.line_id
   FROM OE_PAYMENTS OP,OE_ORDER_LINES_ALL OL
   WHERE OP.line_id IS NOT NULL
   AND OP.line_id= OL.line_id
   AND OL.sold_to_org_id= :hold_entity_id
   AND OP.PAYMENT_TYPE_CODE = :hold_entity_id2';

   IF (p_hold_source_rec.header_id IS NOT NULL AND p_hold_source_rec.line_id IS NOT NULL)
       OR (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NOT NULL) THEN
     l_sqlmt := l_sqlmt||'  AND OP.line_id = '||p_hold_source_rec.line_id;

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2;

   ELSIF (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NULL)  THEN

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2;

    END IF;

   END IF;


  FOR i in 1 .. l_eligible_record_tab.count LOOP

      oe_debug_pub.add('Calling InsertTable_OOH_Line for P for line_id:'||l_eligible_record_tab(i));
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => l_eligible_record_tab(i)
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => NULL
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => p_activity_name
      		           ,p_activity_status => p_activity_status
      		           ,p_additional_where_clause => p_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      oe_debug_pub.add('After Calling InsertTable_OOH_Line for P');

  END LOOP;
END IF;
IF  p_item_type = 'OEOH' or p_item_type IS NULL THEN
  oe_debug_pub.add('Header Level Processing Starts');

   l_eligible_record_tab.delete;

  IF p_hold_source_rec.hold_entity_code = 'P' and p_hold_source_rec.hold_entity_code2 IS NULL   THEN

     l_sqlmt := 'Select header_id
     FROM OE_PAYMENTS OP
     WHERE line_id IS NULL
     AND PAYMENT_TYPE_CODE = :hold_entity_id';

   IF p_hold_source_rec.header_id IS NOT NULL and p_hold_source_rec.line_id IS NULL THEN
     l_sqlmt := l_sqlmt||'  AND OP.header_id = '||p_hold_source_rec.header_id;

     l_sqlmt1 := '   UNION  Select header_id
     FROM OE_ORDER_HEADERS_ALL OH
     WHERE PAYMENT_TYPE_CODE = :hold_entity_id
     AND header_id = :header_id';

     l_sqlmt := l_sqlmt||l_sqlmt1;

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id,p_hold_source_rec.header_id;

   ELSIF (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NULL)  THEN

     l_sqlmt1 := '  UNION  Select header_id
     FROM OE_ORDER_HEADERS_ALL OH
     WHERE PAYMENT_TYPE_CODE = :hold_entity_id';

     l_sqlmt := l_sqlmt||l_sqlmt1;

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id;

   END IF;

  ELSIF p_hold_source_rec.hold_entity_code = 'C' and p_hold_source_rec.hold_entity_code2 ='P'  THEN

     l_sqlmt := 'Select OP.header_id
     FROM OE_PAYMENTS OP,OE_ORDER_HEADERS_ALL OH
     WHERE OP.line_id IS NULL
     AND OP.header_id= OH.header_id
     AND OH.sold_to_org_id= :hold_entity_id
     AND OP.PAYMENT_TYPE_CODE = :hold_entity_id2';

   IF p_hold_source_rec.header_id IS NOT NULL and p_hold_source_rec.line_id IS NULL THEN
     l_sqlmt := l_sqlmt||'  AND OP.header_id = '||p_hold_source_rec.header_id;

     l_sqlmt1 := '  UNION  Select header_id
     FROM OE_ORDER_HEADERS_ALL OH
     WHERE sold_to_org_id= :hold_entity_id
     AND PAYMENT_TYPE_CODE = :hold_entity_id2
     AND header_id = :header_id';

     l_sqlmt := l_sqlmt||l_sqlmt1;
     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2,
           p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2,
           p_hold_source_rec.header_id;

   ELSIF (p_hold_source_rec.header_id IS NULL AND p_hold_source_rec.line_id IS NULL)  THEN

     l_sqlmt1 := '  UNION  Select header_id
     FROM OE_ORDER_HEADERS_ALL OH
     WHERE sold_to_org_id= :hold_entity_id
     AND PAYMENT_TYPE_CODE = :hold_entity_id2';

     l_sqlmt := l_sqlmt||l_sqlmt1;

     EXECUTE IMMEDIATE l_sqlmt
     BULK COLLECT INTO l_eligible_record_tab
     USING p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2,
     	   p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_entity_id2;

   END IF;


  END IF;


   FOR i in 1 .. l_eligible_record_tab.count LOOP

      oe_debug_pub.add('Calling InsertTable_OOH_Header for P for header_id:'||l_eligible_record_tab(i));
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>l_eligible_record_tab(i)
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => NULL
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => p_activity_name
    			       ,p_activity_status => p_activity_status
			       ,p_additional_where_clause => p_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);

      oe_debug_pub.add('After Calling InsertTable_OOH_Header for P');

   END LOOP;
END IF;



oe_debug_pub.add('Exiting PaymentType_Hold Successfully');

EXCEPTION
WHEN OTHERS THEN
   OE_DEBUG_PUB.ADD('Exiting PaymentType_Hold with Error:'||SQLCODE);
END PaymentType_Hold;
--ER#7479609 end


/****************************
|  RELEASE_ORDERS
 ***************************/
Procedure release_orders (
   p_hold_release_rec   IN   OE_HOLDS_PVT.hold_release_rec_type,
   p_order_rec          IN   OE_HOLDS_PVT.order_rec_type,
   p_hold_source_rec    IN   OE_HOLDS_PVT.Hold_source_Rec_Type,
   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

CURSOR hold_source IS
     SELECT  HS.HOLD_SOURCE_ID,
             HS.HOLD_ENTITY_CODE,
             hs.hold_id,
             oh.order_hold_id
     FROM OE_HOLD_SOURCES HS,
          OE_ORDER_HOLDS  oh
     WHERE  HS.HOLD_ID = nvl(p_hold_source_rec.hold_id, HS.HOLD_ID)
	  and  hs.hold_entity_code = nvl(p_hold_source_rec.hold_entity_code, hs.hold_entity_code)
	  and  hs.hold_entity_id   = nvl(p_hold_source_rec.hold_entity_id, hs.hold_entity_id)
       and  hs.HOLD_SOURCE_ID = oh.HOLD_SOURCE_ID
       and  oh.HEADER_ID      = p_order_rec.header_id
       and  nvl(oh.LINE_ID, -99 ) = nvl(p_order_rec.line_id, -99)
       AND  OH.RELEASED_FLAG = 'N';

-- GENESIS --
CURSOR check_hold_type_cur(p_ord_hld_id IN NUMBER) IS
     SELECT 'Y'
     FROM DUAL
     WHERE EXISTS (SELECT NULL
                   FROM   oe_order_holds ooh,
                          oe_hold_sources ohs,
                          oe_hold_definitions ohd,
                          oe_order_headers_all h,
			  oe_order_sources oos
                   WHERE  ooh.header_id = h.header_id
--		   AND    ohd.activity_name IS NULL       Bug 6791587
		   AND    oos.aia_enabled_flag = 'Y'
                   AND    ohd.hold_id = ohs.hold_id
                   AND    ohs.hold_source_id = ooh.hold_source_id
                   AND    ooh.order_hold_id = p_ord_hld_id);

     l_chk_hold   VARCHAR2(1) := 'N';

     -- Bug 8463870
     l_header_id     number;
     l_header_rec    oe_order_pub.header_rec_type;

     l_line_id       number;
     l_line_rec      oe_order_pub.line_rec_type;

    cursor header_line_id_cur(p_ord_hld_id in number) is
      select ohld.header_id,
             ohld.line_id
      from   oe_order_holds ohld,
             oe_order_headers ooh,
             oe_order_sources src
      where  ohld.order_hold_id = p_ord_hld_id
      and    ohld.header_id = ooh.header_id
      and    src.order_source_id = ooh.order_source_id
      and    src.aia_enabled_flag = 'Y';

-- GENESIS --

l_user_id      NUMBER;
x_hold_release_id oe_hold_releases.HOLD_RELEASE_ID%type;
 l_hold_source_id     OE_HOLD_SOURCES.HOLD_SOURCE_ID%TYPE;
 x_hold_source_id     OE_HOLD_SOURCES.HOLD_SOURCE_ID%TYPE;
 l_hold_entity_code   OE_HOLD_SOURCES.HOLD_ENTITY_CODE%TYPE;
 l_order_hold_id      OE_ORDER_HOLDS.ORDER_HOLD_ID%TYPE;
 l_hold_id            OE_HOLD_DEFINITIONS.hold_id%type;

 l_hold_source_rec    OE_HOLDS_PVT.hold_source_rec_type;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_user_id := OE_HOLDS_PVT.get_user_id;
-- XX Also check for release reason code
    OPEN hold_source;
    LOOP

      FETCH hold_source INTO l_hold_source_id,
                            l_hold_entity_code,
                            l_hold_id,
                            l_order_hold_id;
      exit when  hold_source%NOTFOUND;
      -- If the Order was created as an Order Based Hold.
      OE_Debug_PUB.Add('Rleaseing Hold' || l_hold_id);
      if l_hold_entity_code = 'O' THEN
         --x_hold_source_id := l_hold_source_id;
         OE_Debug_PUB.Add('Rlsing Source for:'||to_char(p_order_rec.header_id),1);
	    l_hold_source_rec.hold_source_id    := l_hold_source_id;
         l_hold_source_rec.HOLD_ENTITY_CODE  := 'O';
         l_hold_source_rec.HOLD_ENTITY_ID    := p_order_rec.header_id;
         l_hold_source_rec.HOLD_ID           := l_hold_id;
         oe_holds_pvt.Release_Hold_Source (
                      p_hold_source_rec  => l_hold_source_rec,
                      p_hold_release_rec => p_hold_release_rec,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data );
      ELSE
  	  -- Releasing only orders from hold. Insert a record in the
	  -- OE_HOLD_RELEASES with hold_source_id as null.
	  OE_Debug_PUB.Add('Releasing Orders from Hold',1);
         --x_hold_source_id := '';

      SELECT     OE_HOLD_RELEASES_S.NEXTVAL
      INTO  x_hold_release_id
      FROM  DUAL;
     /*Bug3042838 Added nvl condition for insertion into CREATED_BY column */
    INSERT INTO OE_HOLD_RELEASES
     ( HOLD_RELEASE_ID
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN
     , PROGRAM_APPLICATION_ID
     , PROGRAM_ID
     , PROGRAM_UPDATE_DATE
     , REQUEST_ID
     , HOLD_SOURCE_ID
     , RELEASE_REASON_CODE
     , RELEASE_COMMENT
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
     , ORDER_HOLD_ID
     )
    VALUES
     ( x_hold_release_id
     , sysdate
     , nvl(p_hold_release_rec.CREATED_BY,l_user_id)
     , sysdate
     , l_user_id
     , p_hold_release_rec.LAST_UPDATE_LOGIN
     , p_hold_release_rec.PROGRAM_APPLICATION_ID
     , p_hold_release_rec.PROGRAM_ID
     , p_hold_release_rec.PROGRAM_UPDATE_DATE
     , p_hold_release_rec.REQUEST_ID
     , NULL    -- HOLD_SOURCE_ID
     , p_hold_release_rec.RELEASE_REASON_CODE
     , p_hold_release_rec.RELEASE_COMMENT
     , p_hold_release_rec.CONTEXT
     , p_hold_release_rec.ATTRIBUTE1
     , p_hold_release_rec.ATTRIBUTE2
     , p_hold_release_rec.ATTRIBUTE3
     , p_hold_release_rec.ATTRIBUTE4
     , p_hold_release_rec.ATTRIBUTE5
     , p_hold_release_rec.ATTRIBUTE6
     , p_hold_release_rec.ATTRIBUTE7
     , p_hold_release_rec.ATTRIBUTE8
     , p_hold_release_rec.ATTRIBUTE9
     , p_hold_release_rec.ATTRIBUTE10
     , p_hold_release_rec.ATTRIBUTE11
     , p_hold_release_rec.ATTRIBUTE12
     , p_hold_release_rec.ATTRIBUTE13
     , p_hold_release_rec.ATTRIBUTE14
     , p_hold_release_rec.ATTRIBUTE15
     , l_order_hold_id
     );

--dbms_output.put_line('RlsID:'||to_char(p_hold_release_rec.hold_release_id));
      UPDATE oe_order_holds
         SET hold_release_id = x_hold_release_id,
             LAST_UPDATED_BY = l_user_id,
             LAST_UPDATE_DATE = sysdate,
             RELEASED_FLAG    = 'Y'
       WHERE ORDER_HOLD_ID  = l_order_hold_id;

      END IF;
       -- XX Also check to see if its the last order from a non order based
       -- hold and release the hold source also. NO

-- GENESIS --
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OE_HOLDS_PVT - RELEASE ORDERS- BEFORE GENESIS CALL');
    END IF;

    OPEN check_hold_type_cur(l_order_hold_id);
    FETCH check_hold_type_cur INTO l_chk_hold;
    CLOSE check_hold_type_cur;

    IF NVL(l_chk_hold, 'N') = 'Y' THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_HOLDS_PVT - RELEASE ORDERS- BEFORE SYNC_HEADER_LINE');
    END IF;

    -- Bug 8463870
    for hld_rls_rec in header_line_id_cur(l_order_hold_id)
    loop
      l_header_id := hld_rls_rec.header_id;
      l_line_id   := hld_rls_rec.line_id;
    end loop;

    if l_debug_level > 0 then
      oe_debug_pub.add('....header_id = ' || l_header_id);
      oe_debug_pub.add('....line_id  = ' || l_line_id);
    end if;

    if ( l_header_id is not null ) then
      l_header_rec := oe_header_util.query_row(p_header_id => l_header_id);
      if ( l_debug_level > 0 ) then
        oe_debug_pub.add('.... Queried up header record.');
      end if;
    end if;

    if ( l_line_id is not null ) then
      l_line_rec := oe_line_util.query_row(p_line_id => l_line_id);
      if ( l_debug_level > 0 ) then
        oe_debug_pub.add('.... Queried up line record.');
      end if;
    end if;

    if (l_debug_level > 0 ) then
      oe_debug_pub.add('.... Calling oe_sync_order_pvt.sync_header_line...');
    end if;

     -- XXXX Do we need to generate req_id here
     OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(  p_header_rec       => l_header_rec -- NULL
                                          ,p_line_rec        => l_line_rec  -- NULL
                                          ,p_hold_source_id  => NULL
                                          ,p_order_hold_id   => l_order_hold_id
                                          ,p_change_type     => 'RELEASE');
    END IF;
-- GENESIS --

    END LOOP;
    CLOSE hold_source;

END release_orders;



Procedure Validate_Hold_Source (
    p_hold_source_rec	IN   OE_HOLDS_PVT.Hold_Source_Rec_Type
  , x_return_status     OUT NOCOPY /* file.sql.39 change */     VARCHAR2
  , x_msg_count         OUT NOCOPY /* file.sql.39 change */     NUMBER
  , x_msg_data          OUT NOCOPY /* file.sql.39 change */     VARCHAR2
)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Hold_source';
l_dummy                 VARCHAR2(30);

l_hold_id               NUMBER := p_hold_source_rec.hold_id;
l_item_type             VARCHAR2(8);
l_apply_to_flag         VARCHAR2(1);

cursor hold_info
is
select
  item_type
, nvl(apply_to_order_and_line_flag, 'N')
from oe_hold_definitions
where hold_id = l_hold_id;

BEGIN
OE_Debug_PUB.Add('In OE_holds_PUB.Validate_Hold_source',1);
-- Initialize API return status to success
x_return_status := FND_API.G_RET_STS_SUCCESS;

--XXX Check the Entity Combination
/*
 > Item - Customer
 > Item - Customer Ship to Site
 > Item - Customer Bill to Site
 > Item - Warehouse
 > Warehouse - Customer
 > Warehouse - Customer Ship to Site
 > Warehouse - Customer Bill to Site
 > Bill To Site - Order     (Used by Line level Credit Checking only)

 > Item - Blanket Number
 > Blanket Number
 > Blanket Number - Customer
 > Blanket Number - Customer Ship to Site
 > Blanket Number - Customer Bill to Site
 > Blanket Number - Warehouse
 > Blanket Number - Blanket Line Number
*/
  OE_Debug_PUB.Add('Entity Combination:' || p_hold_source_rec.hold_entity_code
        || '/' || p_hold_source_rec.hold_entity_code2,1);

  /* ER # 2662206 Start */
  IF p_hold_source_rec.hold_entity_code IS NOT NULL THEN
    OPEN hold_info;
    FETCH hold_info into l_item_type, l_apply_to_flag;
    CLOSE hold_info;

    /*ER#7479609
    IF l_item_type = 'OEOH' THEN
      IF p_hold_source_rec.hold_entity_code IN ('B','H','I','W','S','L') OR
        (p_hold_source_rec.hold_entity_code = 'O' AND
         p_hold_source_rec.line_id IS NOT NULL) OR
         p_hold_source_rec.hold_entity_code2 IS NOT NULL THEN
        oe_debug_pub.add('Error: Order WF Hold, being applied at Line Level');
        FND_MESSAGE.SET_NAME('ONT','OE_ORDER_HOLD_INVALID_CRITERIA');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    ELSIF l_item_type = 'OEOL' THEN
      IF p_hold_source_rec.hold_entity_code IN ('C','O') AND
         p_hold_source_rec.line_id IS NULL AND
         l_apply_to_flag = 'N' THEN
        oe_debug_pub.add('Error: Line WF Hold, being applied at Order Level');
        FND_MESSAGE.SET_NAME('ONT','OE_LINE_HOLD_INVALID_CRITERIA');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;
    ER#7479609*/

    --ER#7479609 start
     IF (p_hold_source_rec.hold_entity_code = 'O' and p_hold_source_rec.line_id IS NULL) OR
        (p_hold_source_rec.hold_entity_code = 'C' and
       					(p_hold_source_rec.hold_entity_code2 IS NULL OR
       					 p_hold_source_rec.hold_entity_code2 = 'OT' OR
       					 p_hold_source_rec.hold_entity_code2 = 'P' OR
       					 p_hold_source_rec.hold_entity_code2 = 'TC' OR
       					 p_hold_source_rec.hold_entity_code2 = 'SC')) 	OR
        (p_hold_source_rec.hold_entity_code = 'PL' and
        					(p_hold_source_rec.hold_entity_code2 IS NULL OR
        					 p_hold_source_rec.hold_entity_code2 = 'TC')) OR
        (p_hold_source_rec.hold_entity_code = 'OT' and
        					(p_hold_source_rec.hold_entity_code2 IS NULL OR
        					 p_hold_source_rec.hold_entity_code2 = 'TC')) OR
        (p_hold_source_rec.hold_entity_code = 'SC' and p_hold_source_rec.hold_entity_code2 IS NULL) --ER#7479609 OR
       --ER#7479609 (p_hold_source_rec.hold_entity_code = 'P'  and p_hold_source_rec.hold_entity_code2 IS NULL)
     THEN
      IF l_item_type = 'OEOH' THEN
        NULL;
        oe_debug_pub.add('Order WF HOLD');
      ELSIF l_item_type = 'OEOL' AND l_apply_to_flag = 'N' THEN
        oe_debug_pub.add('Error: Line WF Hold, being applied at Order Level');
        FND_MESSAGE.SET_NAME('ONT','OE_LINE_HOLD_INVALID_CRITERIA');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     ELSE
     IF (p_hold_source_rec.hold_entity_code = 'P'  and p_hold_source_rec.hold_entity_code2 IS NULL) THEN
      NULL;
     ELSE
      IF l_item_type = 'OEOL' AND l_apply_to_flag = 'N' THEN
        NULL;
        oe_debug_pub.add('Line WF HOLD');
      ELSIF l_item_type = 'OEOH' THEN
        oe_debug_pub.add('Error: Order WF Hold, being applied at Line Level');
        FND_MESSAGE.SET_NAME('ONT','OE_ORDER_HOLD_INVALID_CRITERIA');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
     END IF;
     END IF;
    --ER#7479609 end


  END IF;
  /* ER # 2662206 End */

  if (p_hold_source_rec.hold_entity_code2 is not null) then
    if p_hold_source_rec.hold_entity_code = 'I' then
      --ER#7479609 if p_hold_source_rec.hold_entity_code2 not in ('C', 'S', 'B', 'W','H') then
      if p_hold_source_rec.hold_entity_code2 not in ('C', 'S', 'B', 'W','H','SM','D','PL','PR','ST','LT') then  --ER#7479609
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'W' then
      --ER#7479609 if p_hold_source_rec.hold_entity_code2 not in ('C', 'S', 'B') then
      if p_hold_source_rec.hold_entity_code2 not in ('C', 'S', 'B','LT','SM','D','ST') then	--ER#7479609
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'B' then
      if p_hold_source_rec.hold_entity_code2 not in ('O') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'H' then
      --ER#7479609 if p_hold_source_rec.hold_entity_code2 not in ('S', 'B', 'W', 'L') then
      if p_hold_source_rec.hold_entity_code2 not in ('S', 'B', 'W', 'L','PL','PT','SM','D','LT') then	--ER#7479609
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
--ER#7479609 start
    elsif p_hold_source_rec.hold_entity_code = 'TM' then
      if p_hold_source_rec.hold_entity_code2 not in ('OI') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'PR' then
      if p_hold_source_rec.hold_entity_code2 not in ('T') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'C' then
      if p_hold_source_rec.hold_entity_code2 not in ('ST','B','S','D','PL','LT','PT','OT','P','TC','SC') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'PL' then
      if p_hold_source_rec.hold_entity_code2 not in ('TC') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'OT' then
      if p_hold_source_rec.hold_entity_code2 not in ('LT','TC') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
    elsif p_hold_source_rec.hold_entity_code = 'CD' then
      if p_hold_source_rec.hold_entity_code2 not in ('CB') then
        OE_Debug_PUB.Add('Invalid Entity Combination',1);
        FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_ENTITY_CONBINATION');
        OE_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
      end if;
--ER#7479609 end
    else
      null;
    end if;
  end if;

  OE_Debug_PUB.Add('Entity ID Combination->' ||
                    to_char(p_hold_source_rec.hold_entity_id) || '/' ||
                    to_char(p_hold_source_rec.hold_entity_id2),1);
     IF p_hold_source_rec.hold_entity_code = 'O' THEN

                SELECT 'Valid Entity'
                INTO l_dummy
                FROM OE_ORDER_HEADERS
                WHERE  HEADER_ID = p_hold_source_rec.hold_entity_id
                  -- QUOTING change
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';


     ELSIF p_hold_source_rec.hold_entity_code = 'C' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_sold_to_orgs_v
                WHERE ORGANIZATION_ID = p_hold_source_rec.hold_entity_id;

/* Following cursor has been changed to use direct TCA tables -Bug 1874065*/
/*
     ELSIF p_hold_source_rec.hold_entity_code = 'S' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM RA_SITE_USES
                WHERE site_use_id = p_hold_source_rec.hold_entity_id
                  AND site_use_code = 'SHIP_TO'
			   AND STATUS='A';*/

 ELSIF p_hold_source_rec.hold_entity_code = 'S' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses     -- Bug 2138398
                WHERE site_use_id = p_hold_source_rec.hold_entity_id
                  AND site_use_code = 'SHIP_TO'
                           AND STATUS='A';

/* Following cursor has been changed to use direct TCA tables -Bug 1874065*/
  /*   ELSIF p_hold_source_rec.hold_entity_code = 'B' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM RA_SITE_USES
                WHERE site_use_id = p_hold_source_rec.hold_entity_id
                  AND site_use_code = 'BILL_TO'
                  AND STATUS='A';*/

    ELSIF p_hold_source_rec.hold_entity_code = 'B' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses       -- Bug 2138398
                WHERE site_use_id = p_hold_source_rec.hold_entity_id
                  AND site_use_code = 'BILL_TO'
                  AND STATUS='A';
--ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'D' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses
                WHERE site_use_id = p_hold_source_rec.hold_entity_id
                  AND site_use_code = 'DELIVER_TO'
                  AND STATUS='A';
--ER#7479609 end
     ELSIF p_hold_source_rec.hold_entity_code = 'I' THEN
               SELECT 'Valid Entity'
                 INTO l_dummy
                 from mtl_system_items_kfv
                where inventory_item_id = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'W' THEN
               SELECT 'Valid Entity'
                 INTO l_dummy
                 from oe_ship_from_orgs_v
                where ORGANIZATION_id = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'H' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_blanket_headers
                WHERE ORDER_NUMBER = p_hold_source_rec.hold_entity_id
                  AND SALES_DOCUMENT_TYPE_CODE = 'B';
--ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'TM' THEN
               SELECT 'Valid Entity'
               INTO l_dummy
               from mtl_system_items_kfv
               where inventory_item_id = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'PR' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM PJM_PROJECTS_ORG_OU_SECURE_V
                WHERE PROJECT_ID = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'PL' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM qp_list_headers_vl
                WHERE list_header_id = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'OT' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_transaction_types
                WHERE transaction_type_id = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'P' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_payment_types_vl
                WHERE  payment_type_code = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'CD' THEN
                NULL;
     ELSIF p_hold_source_rec.hold_entity_code = 'SC' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_lookups
                WHERE lookup_code = p_hold_source_rec.hold_entity_id
                  AND lookup_type = 'SALES_CHANNEL';
     ELSIF p_hold_source_rec.hold_entity_code = 'PT' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_payment_types_vl
                WHERE payment_type_code = p_hold_source_rec.hold_entity_id;
     ELSIF p_hold_source_rec.hold_entity_code = 'SM' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_ship_methods_v
                WHERE lookup_code= p_hold_source_rec.hold_entity_id
                AND lookup_type = 'SHIP_METHOD';
--ER#7479609 end
     ELSE
                OE_Debug_PUB.Add('Invalid Entity Code');
                FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_CODE');
                OE_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
     END IF;

    /*********************************
    **    Check the Second Entity   **
    *********************************/
    IF p_hold_source_rec.hold_entity_code2 is not null THEN
        OE_Debug_PUB.Add('Second Entity Code->' ||
                        p_hold_source_rec.hold_entity_code2,1);
        OE_Debug_PUB.Add('Second Entity ID' ||
                       to_char(p_hold_source_rec.hold_entity_id2),1);

        IF p_hold_source_rec.hold_entity_code2 = 'O' THEN

                SELECT 'Valid Entity'
                INTO l_dummy
                FROM OE_ORDER_HEADERS
                WHERE  HEADER_ID = p_hold_source_rec.hold_entity_id2
                  -- QUOTING change
                  AND nvl(TRANSACTION_PHASE_CODE,'F') = 'F';

        ELSIF p_hold_source_rec.hold_entity_code2 = 'C' THEN

                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_sold_to_orgs_v
                WHERE ORGANIZATION_ID = p_hold_source_rec.hold_entity_id2;

/* Following cursor has been changed to use direct TCA tables -Bug 1874065*/
/*        ELSIF p_hold_source_rec.hold_entity_code2 = 'S' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM RA_SITE_USES
                WHERE SITE_USE_ID = p_hold_source_rec.hold_entity_id2
                  AND site_use_code = 'SHIP_TO';*/


        ELSIF p_hold_source_rec.hold_entity_code2 = 'S' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses      -- Bug 2138398
                WHERE SITE_USE_ID = p_hold_source_rec.hold_entity_id2
                  AND site_use_code = 'SHIP_TO';


/* Following cursor has been changed to use direct TCA tables -Bug 1874065*/
   /*     ELSIF p_hold_source_rec.hold_entity_code2 = 'B' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM RA_SITE_USES
                WHERE SITE_USE_ID = p_hold_source_rec.hold_entity_id2
                  AND site_use_code = 'BILL_TO';*/

 ELSIF p_hold_source_rec.hold_entity_code2 = 'B' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses     -- Bug 2138398
                WHERE SITE_USE_ID = p_hold_source_rec.hold_entity_id2
                  AND site_use_code = 'BILL_TO';
        ELSIF p_hold_source_rec.hold_entity_code2 = 'H' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_blanket_headers
                WHERE ORDER_NUMBER = p_hold_source_rec.hold_entity_id2
                  AND SALES_DOCUMENT_TYPE_CODE = 'B';
        ELSIF p_hold_source_rec.hold_entity_code2 = 'L' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_blanket_lines_ext
                WHERE  ORDER_NUMBER = p_hold_source_rec.hold_entity_id
                  AND  LINE_NUMBER = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'W' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                from oe_ship_from_orgs_v
                where ORGANIZATION_id = p_hold_source_rec.hold_entity_id2;
--ER#7479609 start
        ELSIF p_hold_source_rec.hold_entity_code2 = 'CB' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM fnd_user
                WHERE user_id = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'D' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM hz_cust_site_uses
                WHERE SITE_USE_ID = p_hold_source_rec.hold_entity_id2
                  AND site_use_code = 'DELIVER_TO';
        ELSIF p_hold_source_rec.hold_entity_code2 in ('LT','OT') THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_transaction_types
                WHERE transaction_type_id = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'OI' THEN
               SELECT 'Valid Entity'
                 INTO l_dummy
                 from mtl_system_items_kfv
                where inventory_item_id = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'PT' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM ra_terms
                WHERE term_id = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'P' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_payment_types_vl
                WHERE  payment_type_code = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'PL' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                from qp_list_headers_vl
                where list_header_id = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'PR' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM PJM_PROJECTS_ORG_OU_SECURE_V
                WHERE PROJECT_ID = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'SC' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_lookups
                WHERE  lookup_code = p_hold_source_rec.hold_entity_id2
                  AND  lookup_type = 'SALES_CHANNEL';
        ELSIF p_hold_source_rec.hold_entity_code2 = 'SM' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                from oe_ship_methods_v
                where lookup_code = p_hold_source_rec.hold_entity_id2
                  AND lookup_type = 'SHIP_METHOD';
        ELSIF p_hold_source_rec.hold_entity_code2 = 'ST' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM oe_lookups
                WHERE lookup_code = p_hold_source_rec.hold_entity_id2
                  AND lookup_type = 'SOURCE_TYPE';
        ELSIF p_hold_source_rec.hold_entity_code2 = 'T' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                FROM PJM_TASKS_OU_V
                WHERE  TASK_ID = p_hold_source_rec.hold_entity_id2;
        ELSIF p_hold_source_rec.hold_entity_code2 = 'TC' THEN
                SELECT 'Valid Entity'
                INTO l_dummy
                from fnd_currencies_vl
                where currency_code = p_hold_source_rec.hold_entity_id2;
--ER#7479609 end
       ELSE
		OE_Debug_PUB.Add('Invalid Second Entity Code');
                FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_CODE');
                OE_MSG_PUB.ADD;
                RAISE FND_API.G_EXC_ERROR;
     END IF;
    END IF;
        ------------------------------

EXCEPTION
    WHEN TOO_MANY_ROWS THEN
       null;
    WHEN NO_DATA_FOUND THEN
       /* XXX Error message here */
       OE_Debug_PUB.Add('Hold Entity ID not found for entity',1);
       FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_ENTITY_ID');
       OE_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    WHEN FND_API.G_EXC_ERROR THEN
       /*
       ** This message is not required.
       FND_MESSAGE.SET_NAME('ONT', 'OE_ENTITY_NOT_ON_ORDER_OR_LINE');
       OE_MSG_PUB.ADD;
       */
        OE_Debug_PUB.Add('Expected error in Validate_Hold_source',1);
        x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF      OE_MSG_PUB.Check_Msg_Level
                (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
                OE_MSG_PUB.Add_Exc_Msg
                        (   G_PKG_NAME
                        ,   l_api_name
                        );
        END IF;

END Validate_Hold_Source;


-----------------------
Procedure Validate_Hold (
     p_hold_id          IN   OE_HOLD_DEFINITIONS.HOLD_id%TYPE,
     x_return_status    OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     x_msg_count        OUT NOCOPY /* file.sql.39 change */  NUMBER,
     x_msg_data         OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
  l_dummy         VARCHAR2(30) DEFAULT NULL;
BEGIN
        x_return_status := FND_API.G_RET_STS_SUCCESS;


     --  Check for Missing Values
     IF p_hold_id IS NULL THEN
         FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_ID');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
     END IF;


         -- Validate Hold ID

         BEGIN
                SELECT  'x'
                  INTO  l_dummy
          FROM  OE_HOLD_DEFINITIONS
                 WHERE  HOLD_ID = p_hold_id
                   AND  SYSDATE
                BETWEEN NVL(START_DATE_ACTIVE, SYSDATE )
                            AND NVL(END_DATE_ACTIVE, SYSDATE );

         EXCEPTION

                WHEN NO_DATA_FOUND THEN
                  OE_Debug_PUB.Add('Invalid Hold ID'||to_char(p_hold_id),1);
                  FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_HOLD_ID');
                  FND_MESSAGE.SET_TOKEN('HOLD_ID',p_hold_id);
                  OE_MSG_PUB.ADD;
                  x_return_status := FND_API.G_RET_STS_ERROR;

         END;  -- Validate Hold ID

END Validate_Hold;

----------------------
---Overload procedure for bug5548778
Procedure Create_Hold_Source (
        p_hold_source_rec	IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
        p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
	   x_hold_source_id      OUT NOCOPY /* file.sql.39 change */  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE,
          x_hold_exists         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
        x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
        x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
        x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_HOLD_SOURCE';
 l_user_id      NUMBER;
 l_org_id       NUMBER;
 l_count        NUMBER;
 --l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_hold_source_rec       OE_HOLDS_PVT.Hold_Source_Rec_Type;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 x_hold_exists := 'N';
 l_user_id := OE_HOLDS_PVT.get_user_id;
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 if (p_hold_source_rec.hold_entity_code = 'O'
       AND p_hold_source_rec.hold_entity_code2 is NULL) then
    /* If Line-level hold */
    IF p_hold_source_rec.line_id is not null THEN
      select count(*)
        into l_count
        --ER#7479609 FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
         AND  HS.HOLD_ENTITY_CODE2 is null
         AND  HS.HOLD_ENTITY_ID2 is null
         AND  HS.RELEASED_FLAG = 'N'
         AND  HS.org_id= p_org_id   --ER#7479609
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
         AND  EXISTS ( select 'x'
                         --ER#7479609 from oe_order_holds OH
                         from oe_order_holds_all OH  --ER#7479609
                        where OH.line_id   = p_hold_source_rec.line_id
                          and OH.org_id= p_org_id   --ER#7479609
                          and OH.hold_source_id = HS.hold_source_id);

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         x_hold_exists := 'Y';
         RETURN;
         --RAISE FND_API.G_EXC_ERROR;
      END IF;
    /* If Order Level Hold */
    ELSE
      select count(*)
        into l_count
        --ER#7479609  FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
         AND  HS.HOLD_ENTITY_CODE2 is null
         AND  HS.HOLD_ENTITY_ID2 is null
         AND  HS.RELEASED_FLAG = 'N'
         AND  HS.org_id= p_org_id   --ER#7479609
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
         AND  EXISTS ( select 'x'
                         --ER#7479609 from oe_order_holds OH
                         from oe_order_holds_all OH  --ER#7479609
                        where OH.line_id is null
                          and OH.org_id= p_org_id   --ER#7479609
                          and OH.hold_source_id = HS.hold_source_id);

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         x_hold_exists := 'Y';
         RETURN;
         --RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF; /*If Order Level Hold */
  else
      select count(*)
        into l_count
        --ER#7479609 FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
         AND  HS.org_id= p_org_id   --ER#7479609
	    AND  nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
              nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
         AND  nvl(HS.HOLD_ENTITY_ID2, -99) =
              nvl(p_hold_source_rec.hold_entity_id2,-99 )
         AND  HS.RELEASED_FLAG = 'N'
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         --RETURN;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
  end if;


-- Inserting a NEW HOLD SOURCE record

    SELECT OE_HOLD_SOURCES_S.NEXTVAL
      INTO x_hold_source_id
      FROM DUAL;

    INSERT INTO OE_HOLD_SOURCES_ALL
    (  HOLD_SOURCE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , PROGRAM_APPLICATION_ID
     , PROGRAM_ID
     , PROGRAM_UPDATE_DATE
     , REQUEST_ID
     , HOLD_ID
     , HOLD_ENTITY_CODE
     , HOLD_ENTITY_ID
     , HOLD_UNTIL_DATE
     , RELEASED_FLAG
     , HOLD_COMMENT
     , ORG_ID
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
     , HOLD_RELEASE_ID
     ,HOLD_ENTITY_CODE2
     ,HOLD_ENTITY_ID2
    )
VALUES
    (  x_hold_source_id
     , sysdate
     , l_user_id
     , sysdate
     , l_user_id
     , p_hold_source_rec.LAST_UPDATE_LOGIN
     , p_hold_source_rec.PROGRAM_APPLICATION_ID
     , p_hold_source_rec.PROGRAM_ID
     , p_hold_source_rec.PROGRAM_UPDATE_DATE
     , p_hold_source_rec.REQUEST_ID
     , p_hold_source_rec.HOLD_ID
     , p_hold_source_rec.HOLD_ENTITY_CODE
     , p_hold_source_rec.HOLD_ENTITY_ID
     , p_hold_source_rec.HOLD_UNTIL_DATE
     , 'N'
     , p_hold_source_rec.HOLD_COMMENT
     , p_org_id  --ER#7479609 l_org_id
     , p_hold_source_rec.CONTEXT
     , p_hold_source_rec.ATTRIBUTE1
     , p_hold_source_rec.ATTRIBUTE2
     , p_hold_source_rec.ATTRIBUTE3
     , p_hold_source_rec.ATTRIBUTE4
     , p_hold_source_rec.ATTRIBUTE5
     , p_hold_source_rec.ATTRIBUTE6
     , p_hold_source_rec.ATTRIBUTE7
     , p_hold_source_rec.ATTRIBUTE8
     , p_hold_source_rec.ATTRIBUTE9
     , p_hold_source_rec.ATTRIBUTE10
     , p_hold_source_rec.ATTRIBUTE11
     , p_hold_source_rec.ATTRIBUTE12
     , p_hold_source_rec.ATTRIBUTE13
     , p_hold_source_rec.ATTRIBUTE14
     , p_hold_source_rec.ATTRIBUTE15
     , p_hold_source_rec.HOLD_RELEASE_ID
     , p_hold_source_rec.HOLD_ENTITY_CODE2
     , p_hold_source_rec.HOLD_ENTITY_ID2
    );

 --l_hold_source_rec := p_hold_source_rec;
 --l_hold_source_rec.hold_source_id := l_hold_source_id;

--dbms_output.put_line ('Caling Create_Order_Holds');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
               ( G_PKG_NAME,
                 l_api_name);
        END IF;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
END Create_Hold_Source;

------
Procedure Create_Hold_Source (
        p_hold_source_rec	IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
        p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
	   x_hold_source_id      OUT NOCOPY /* file.sql.39 change */  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE,
        x_return_status       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
        x_msg_count           OUT NOCOPY /* file.sql.39 change */  NUMBER,
        x_msg_data            OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
 l_api_name     CONSTANT VARCHAR2(30) := 'CREATE_HOLD_SOURCE';
 l_user_id      NUMBER;
 l_org_id       NUMBER;
 l_count        NUMBER;
 --l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_hold_source_rec       OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_comment		OE_HOLD_SOURCES_ALL.HOLD_COMMENT%TYPE;  --ER#7479609
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 l_user_id := OE_HOLDS_PVT.get_user_id;
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

 if (p_hold_source_rec.hold_entity_code = 'O'
       AND p_hold_source_rec.hold_entity_code2 is NULL) then
    /* If Line-level hold */
    IF p_hold_source_rec.line_id is not null THEN
      select count(*)
        into l_count
        --ER#7479609 FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS  --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
         AND  HS.HOLD_ENTITY_CODE2 is null
         AND  HS.HOLD_ENTITY_ID2 is null
         AND  HS.RELEASED_FLAG = 'N'
         AND  HS.ORG_ID = p_org_id  --ER#7479609
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
         AND  EXISTS ( select 'x'
                         --ER#7479609 from oe_order_holds OH
                         from oe_order_holds_all OH  --ER#7479609
                        where OH.line_id   = p_hold_source_rec.line_id
                          and OH.hold_source_id = HS.hold_source_id);

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         --RETURN;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
    /* If Order Level Hold */
    ELSE
      select count(*)
        into l_count
        --ER#7479609 FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS   --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
         AND  HS.HOLD_ENTITY_CODE2 is null
         AND  HS.HOLD_ENTITY_ID2 is null
         AND  HS.RELEASED_FLAG = 'N'
         AND  HS.ORG_ID = p_org_id  --ER#7479609
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
         AND  EXISTS ( select 'x'
                         --ER#7479609 from oe_order_holds OH
                         from oe_order_holds_all OH  --ER#7479609
                        where OH.line_id is null
                          and OH.hold_source_id = HS.hold_source_id);

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         --RETURN;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF; /*If Order Level Hold */
  else
      select count(*)
        into l_count
        --ER#7479609 FROM  OE_HOLD_SOURCES HS
        FROM  OE_HOLD_SOURCES_ALL HS  --ER#7479609
       WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
         AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
         AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
	    AND  nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
              nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
         AND  nvl(HS.HOLD_ENTITY_ID2, -99) =
              nvl(p_hold_source_rec.hold_entity_id2,-99 )
         AND  HS.RELEASED_FLAG = 'N'
         AND  HS.ORG_ID = p_org_id  --ER#7479609
         AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;

  --    AND  EXISTS ( select 'x'
  --                    from oe_order_holds
  --                   where header_id = p_hold_source_rec.hold_entity_id
  --                     and line_id   = nvl(p_hold_source_rec.line_id, -99));

      IF l_count > 0 THEN
         OE_Debug_PUB.Add('Duplicate Hold Source for EntityID'||
                        to_char(p_hold_source_rec.hold_entity_id) ,1);
         --FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD');
         FND_MESSAGE.SET_NAME('ONT', 'OE_DUPLICATE_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         --RETURN;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

  end if;

 -- Check to see if the hold source already exists
 -- and if exists, retrieve hold source ID.

 -- BEGIN
 --   SELECT  HOLD_SOURCE_ID
 --     INTO  l_hold_source_id
 --     FROM  OE_HOLD_SOURCES HS
 --    WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
 --      AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
 --      AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
 --      AND  nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
 --           nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
 --      AND  nvl(HS.HOLD_ENTITY_ID2, -99) =
 --           nvl(p_hold_source_rec.hold_entity_id2,-99 )
 --      AND  HS.RELEASED_FLAG = 'N'
 --      AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE;

 --      oe_debug_pub.add('Using Existing Hold Source for:' ||
 --           to_char(p_hold_source_rec.hold_entity_id) || 'And:' ||
 --           nvl(to_char(p_hold_source_rec.hold_entity_id2), 'No Second Entity'),3);
 -- EXCEPTION
 --      WHEN NO_DATA_FOUND THEN

-- Inserting a NEW HOLD SOURCE record

 --ER#7479609 start
 l_hold_comment := p_hold_source_rec.HOLD_COMMENT;
 IF p_hold_source_rec.hold_id = 1 and p_hold_source_rec.HOLD_COMMENT IS NULL THEN
    l_hold_comment := 'Credit Hold check box has been enabled that has put the hold';
 END IF;

--ER#7479609 end


    SELECT OE_HOLD_SOURCES_S.NEXTVAL
      INTO x_hold_source_id
      FROM DUAL;

    INSERT INTO OE_HOLD_SOURCES_ALL
    (  HOLD_SOURCE_ID
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_LOGIN
     , PROGRAM_APPLICATION_ID
     , PROGRAM_ID
     , PROGRAM_UPDATE_DATE
     , REQUEST_ID
     , HOLD_ID
     , HOLD_ENTITY_CODE
     , HOLD_ENTITY_ID
     , HOLD_UNTIL_DATE
     , RELEASED_FLAG
     , HOLD_COMMENT
     , ORG_ID
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
     , HOLD_RELEASE_ID
     ,HOLD_ENTITY_CODE2
     ,HOLD_ENTITY_ID2
    )
VALUES
    (  x_hold_source_id
     , sysdate
     , l_user_id
     , sysdate
     , l_user_id
     , p_hold_source_rec.LAST_UPDATE_LOGIN
     , p_hold_source_rec.PROGRAM_APPLICATION_ID
     , p_hold_source_rec.PROGRAM_ID
     , p_hold_source_rec.PROGRAM_UPDATE_DATE
     , p_hold_source_rec.REQUEST_ID
     , p_hold_source_rec.HOLD_ID
     , p_hold_source_rec.HOLD_ENTITY_CODE
     , p_hold_source_rec.HOLD_ENTITY_ID
     , p_hold_source_rec.HOLD_UNTIL_DATE
     , 'N'
     , l_hold_comment  --ER#7479609 p_hold_source_rec.HOLD_COMMENT
     , p_org_id  --ER#7479609 l_org_id
     , p_hold_source_rec.CONTEXT
     , p_hold_source_rec.ATTRIBUTE1
     , p_hold_source_rec.ATTRIBUTE2
     , p_hold_source_rec.ATTRIBUTE3
     , p_hold_source_rec.ATTRIBUTE4
     , p_hold_source_rec.ATTRIBUTE5
     , p_hold_source_rec.ATTRIBUTE6
     , p_hold_source_rec.ATTRIBUTE7
     , p_hold_source_rec.ATTRIBUTE8
     , p_hold_source_rec.ATTRIBUTE9
     , p_hold_source_rec.ATTRIBUTE10
     , p_hold_source_rec.ATTRIBUTE11
     , p_hold_source_rec.ATTRIBUTE12
     , p_hold_source_rec.ATTRIBUTE13
     , p_hold_source_rec.ATTRIBUTE14
     , p_hold_source_rec.ATTRIBUTE15
     , p_hold_source_rec.HOLD_RELEASE_ID
     , p_hold_source_rec.HOLD_ENTITY_CODE2
     , p_hold_source_rec.HOLD_ENTITY_ID2
    );

 --l_hold_source_rec := p_hold_source_rec;
 --l_hold_source_rec.hold_source_id := l_hold_source_id;

--dbms_output.put_line ('Caling Create_Order_Holds');

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        --ROLLBACK TO Create_Hold_Source;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
               ( G_PKG_NAME,
                 l_api_name);
        END IF;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
END Create_Hold_Source;


---------------------
Procedure Create_Order_Holds(
  p_hold_source_rec       IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
  x_return_status   OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count       OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data        OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
 l_user_id      NUMBER;
 l_org_id       NUMBER;
 l_api_name     CONSTANT VARCHAR2(30) := 'Create_Order_Holds';
 l_site_use_code     VARCHAR2(30);
 /*Added the three variables for WF_HOLDS bug 6449458*/
 l_is_hold_applied    BOOLEAN DEFAULT NULL;
 l_wf_item_type       OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE := NULL;
 l_wf_activity_name   OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;


/* Moved to Overloaded Procedure under Bug 6801108
-- GENESIS --
 l_check_hold   VARCHAR2(1) := 'N';

 CURSOR check_line_hold_type_cur(p_line_id IN NUMBER) IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT NULL
                  FROM   oe_order_holds ooh,
                         oe_hold_sources ohs,
                         oe_hold_definitions ohd,
                         oe_order_headers_all h,
			 oe_order_sources oos
                  WHERE  ohd.activity_name IS NULL
                  AND    ohd.hold_id = ohs.hold_id
                  AND    ooh.header_id = h.header_id
                  AND    h.order_source_id = oos.order_source_id
		  AND    oos.aia_enabled_flag = 'Y'
                  AND    ohs.hold_source_id = ooh.hold_source_id
                  AND    ooh.line_id = p_line_id);

 CURSOR check_hdr_hold_type_cur(p_hdr_id IN NUMBER) IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT NULL
                  FROM   oe_order_holds ooh,
                         oe_hold_sources ohs,
                         oe_hold_definitions ohd,
                         oe_order_headers_all h,
			 oe_order_sources oos
                  WHERE  ohd.activity_name IS NULL
                  AND    ohd.hold_id = ohs.hold_id
                  AND    h.order_source_id = oos.order_source_id
		  AND    oos.aia_enabled_flag = 'Y'
                  AND    ooh.header_id = h.header_id
                  AND    ohs.hold_source_id = ooh.hold_source_id
                  AND    ooh.header_id = p_hdr_id);

 CURSOR check_src_hold_type_cur(p_hld_src_id IN NUMBER) IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT NULL
                  FROM   oe_hold_sources ohs,
                         oe_hold_definitions ohd
                  WHERE  ohd.activity_name IS NULL
                  AND    ohd.hold_id = ohs.hold_id
                  AND    ohs.hold_source_id = p_hld_src_id);

 l_header_rec        OE_Order_PUB.Header_Rec_Type;
 l_line_rec          OE_Order_PUB.Line_Rec_Type;*/
-- GENESIS --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 l_user_id := OE_HOLDS_PVT.get_user_id;
 l_org_id := MO_GLOBAL.get_current_org_id;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

  Begin
    select item_type, activity_name
    into   l_wf_item_type, l_wf_activity_name
    from   oe_hold_definitions
    where  hold_id = p_hold_source_rec.hold_id;
  Exception
    When NO_DATA_FOUND Then
      NULL; -- OE_Holds_Pvt.Validate has not yet been called.
  End;

  OE_DEBUG_PUB.Add ('Calling Overloaded Create_Order_Holds Based on Workflow from original Create_Order_Holds',1);
  Create_Order_Holds (
          p_hold_source_rec     =>  p_hold_source_rec
         ,p_org_id		=>  p_org_id    --ER#7479609
         ,p_item_type           =>  l_wf_item_type
         ,p_activity_name       =>  l_wf_activity_name
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
         ,x_is_hold_applied     =>  l_is_hold_applied);

  /*oe_debug_pub.add('p_hold_source_rec.hold_source_id:' ||
                 p_hold_source_rec.hold_source_id);
  oe_debug_pub.add('Hold_entity_code/Hold_entity_id/' ||
                   'Hold_entity_code2/Hold_entity_id2:' ||
                    p_hold_source_rec.Hold_entity_code || '/' ||
                    p_hold_source_rec.Hold_entity_id   || '/' ||
                    p_hold_source_rec.Hold_entity_code2 || '/' ||
                    p_hold_source_rec.Hold_entity_id2);
  oe_debug_pub.add('p_hold_source_rec.header_id:' || p_hold_source_rec.header_id);
  oe_debug_pub.add('p_hold_source_rec.line_id:' || p_hold_source_rec.line_id);
-- Insert a hold record for the order header or the order line.

   IF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'C' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and h.header_id = ol.header_id
       and ol.line_id = p_hold_source_rec.line_id
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and h.header_id = ol.header_id
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    END IF;
    Only used by Credit checking
   ELSIF p_hold_source_rec.hold_entity_code = 'B' and
      p_hold_source_rec.hold_entity_code2 = 'O' THEN
     IF p_hold_source_rec.line_id IS NOT NULL THEN
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol,
              ra_terms_b rt
         WHERE h.OPEN_FLAG = 'Y'
           and h.header_id = p_hold_source_rec.hold_entity_id2
           and h.header_id = ol.header_id
           and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
           and ol.line_id = p_hold_source_rec.line_id
           and ol.OPEN_FLAG = 'Y'
           and ol.PAYMENT_TERM_ID = rt.TERM_ID
           and rt.CREDIT_CHECK_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
       ELSE
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol,
              ra_terms_b rt
         WHERE h.OPEN_FLAG = 'Y'
           and h.header_id = p_hold_source_rec.hold_entity_id2
           and h.header_id = ol.header_id
           and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
           and ol.OPEN_FLAG = 'Y'
           and ol.PAYMENT_TERM_ID = rt.TERM_ID
           and rt.CREDIT_CHECK_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
       END IF;

   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'B' THEN
     IF p_hold_source_rec.line_id IS NOT NULL THEN
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
           and h.header_id = ol.header_id
           and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.line_id = p_hold_source_rec.line_id
           and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
       ELSE
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
           and h.header_id = ol.header_id
           and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
       END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'S' THEN
     IF p_hold_source_rec.line_id IS NOT NULL THEN
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
           and h.header_id = ol.header_id
           and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.line_id = p_hold_source_rec.line_id
           and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
        				      and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
       ELSE
        INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  l_user_id
         ,  SYSDATE
         ,  l_user_id
         ,  NULL
         ,  p_hold_source_rec.hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  'N'
         ,  l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
           and h.header_id = ol.header_id
           and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =
                                   p_hold_source_rec.hold_source_id );
    END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'W' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.line_id = p_hold_source_rec.line_id
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    END IF;
    ELSIF p_hold_source_rec.hold_entity_code = 'I' and
        p_hold_source_rec.hold_entity_code2 = 'H' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id2
         and ol.line_id = p_hold_source_rec.line_id
         and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                                          and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id2
         and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;

   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
      p_hold_source_rec.hold_entity_code2 = 'C' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and ol.line_id = p_hold_source_rec.line_id
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
   END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'B' THEN
     IF p_hold_source_rec.line_id IS NOT NULL THEN
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --AND nvl(h.CANCELLED_FLAG, 'N') = 'N'
           AND h.header_id = ol.header_id
           AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
           and ol.line_id = p_hold_source_rec.line_id
           AND ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           AND NOT EXISTS ( SELECT 'x'
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
       ELSE
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --AND nvl(h.CANCELLED_FLAG, 'N') = 'N'
           AND h.header_id = ol.header_id
           AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
           AND ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           AND NOT EXISTS ( SELECT 'x'
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
     END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'S' THEN
     IF p_hold_source_rec.line_id IS NOT NULL THEN
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --AND nvl(h.CANCELLED_FLAG, 'N') = 'N'
           AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
           and ol.line_id = p_hold_source_rec.line_id
           AND h.header_id = ol.header_id
           AND ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           AND NOT EXISTS ( SELECT 'x'
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
       ELSE
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = 'Y'
           --AND nvl(h.CANCELLED_FLAG, 'N') = 'N'
           AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
           AND h.header_id = ol.header_id
           AND ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
           and ol.OPEN_FLAG = 'Y'
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
           AND NOT EXISTS ( SELECT 'x'
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
     END IF;
 ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'B' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
         and ol.line_id = p_hold_source_rec.line_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                                          and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.INVOICE_TO_ORG_ID= p_hold_source_rec.hold_entity_id2
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;

ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'S' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
         and ol.line_id = p_hold_source_rec.line_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.SHIP_TO_ORG_ID= p_hold_source_rec.hold_entity_id2
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'W' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id2
         and ol.line_id = p_hold_source_rec.line_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.SHIP_FROM_ORG_ID= p_hold_source_rec.hold_entity_id2
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;

     ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'L' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.BLANKET_LINE_NUMBER = p_hold_source_rec.hold_entity_id2
         and ol.line_id = p_hold_source_rec.line_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.BLANKET_LINE_NUMBER = p_hold_source_rec.hold_entity_id2
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;

     ELSIF p_hold_source_rec.hold_entity_code = 'H' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.line_id = p_hold_source_rec.line_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
         and h.header_id = ol.header_id
         and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
      END IF;

   ELSIF p_hold_source_rec.hold_entity_code = 'O' THEN
    IF p_hold_source_rec.line_id is NULL THEN
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  NULL
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h
       WHERE h.OPEN_FLAG = 'Y'
         and h.header_id = p_hold_source_rec.hold_entity_id
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
    ELSE
      INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  l_user_id
       ,  SYSDATE
       ,  l_user_id
       ,  NULL
       ,  p_hold_source_rec.hold_source_id
       ,  h.HEADER_ID
       ,  p_hold_source_rec.line_id
       ,  'N'
       ,  l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = 'Y'
         and h.header_id = p_hold_source_rec.hold_entity_id
         and h.header_id = ol.header_id
         and ol.line_id = p_hold_source_rec.line_id
         and ol.open_flag = 'Y'
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
         and not exists ( select 'x'
                              from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id = ol.line_id
                             and oh.hold_source_id =
                                 p_hold_source_rec.hold_source_id );
    END IF;

   ELSIF p_hold_source_rec.hold_entity_code = 'C' THEN
       -- Use header_id for Customer based hold source
    IF p_hold_source_rec.header_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = p_hold_source_rec.header_id
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'B' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = 'Y'
            --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
            and h.header_id = ol.header_id
            and ol.line_id = p_hold_source_rec.line_id
            and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
            and ol.OPEN_FLAG = 'Y'
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
            and not exists ( select 'x'
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
       ELSE
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = 'Y'
            --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
            and h.header_id = ol.header_id
            and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
            and ol.OPEN_FLAG = 'Y'
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
            and not exists ( select 'x'
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
      END IF;
    ELSIF p_hold_source_rec.hold_entity_code = 'S' THEN
      IF p_hold_source_rec.line_id IS NOT NULL THEN
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = 'Y'
            --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
            and h.header_id = ol.header_id
            and ol.line_id = p_hold_source_rec.line_id
            and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id
            and ol.OPEN_FLAG = 'Y'
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
            and not exists ( select 'x'
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
     					  and oh.line_id   = ol.line_id
                                and oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
       ELSE
         INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  l_user_id
          ,  SYSDATE
          ,  l_user_id
          ,  NULL
          ,  p_hold_source_rec.hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  'N'
          ,  l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = 'Y'
            --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
            and h.header_id = ol.header_id
            and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id
            and ol.OPEN_FLAG = 'Y'
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
            and not exists ( select 'x'
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =
                                    p_hold_source_rec.hold_source_id );
     END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'W' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
	  and h.header_id = ol.header_id
       and ol.line_id = p_hold_source_rec.line_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    END IF;
   ELSIF p_hold_source_rec.hold_entity_code = 'I' THEN
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.line_id = p_hold_source_rec.line_id
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    ELSE
    INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  p_hold_source_rec.hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  'N'
     ,  l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = 'Y'
       --and nvl(h.CANCELLED_FLAG, 'N') = 'N'
       and h.header_id = ol.header_id
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
       and not exists ( select 'x'
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =
                               p_hold_source_rec.hold_source_id );
    END IF;
   END IF;
-- Moved to Overloaded procedure under Bug 6801108
-- GENESIS --
    IF p_hold_source_rec.line_id IS NOT NULL THEN

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.line_id IS NOT NULL');
       END IF;

       OPEN check_line_hold_type_cur(p_hold_source_rec.line_id);
       FETCH check_line_hold_type_cur INTO l_check_hold;
       CLOSE check_line_hold_type_cur;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold' || l_check_hold);
       END IF;

    ELSIF p_hold_source_rec.line_id IS NULL AND
       p_hold_source_rec.header_id IS NOT NULL THEN

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.header_id IS NOT NULL');
       END IF;
       OPEN check_hdr_hold_type_cur(p_hold_source_rec.header_id);
       FETCH check_hdr_hold_type_cur INTO l_check_hold;
       CLOSE check_hdr_hold_type_cur;
       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold' || l_check_hold);
       END IF;

   ELSIF p_hold_source_rec.line_id IS NULL AND
       p_hold_source_rec.header_id IS NULL AND
       p_hold_source_rec.hold_source_id IS NOT NULL THEN

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.hold_source_id IS NOT NULL');
       END IF;
       OPEN check_src_hold_type_cur(p_hold_source_rec.hold_source_id);
       FETCH check_src_hold_type_cur INTO l_check_hold;
       CLOSE check_src_hold_type_cur;

       IF l_debug_level  > 0 THEN
          oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold :' || l_check_hold);
       END IF;

   END IF;

   IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OE_HOLDS_PVT - CREATE ORDER HOLDS - BEFORE SYNC_HEADER_LINE');
   END IF;

   IF NVL(l_check_hold, 'N') = 'Y' THEN

      IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_HOLDS_PVT - CREATE ORDER HOLDS - l_check_hold: ' || l_check_hold);
      END IF;

      IF p_hold_source_rec.hold_entity_code = 'O' THEN
        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(' p_hold_source_rec.hold_entity_code ' || p_hold_source_rec.hold_entity_code);
        END IF;
        IF p_hold_source_rec.hold_entity_id is NOT NULL THEN
          IF l_debug_level  > 0 THEN
              oe_debug_pub.add(' p_hold_source_rec.hold_entity_id : ' || p_hold_source_rec.hold_entity_id);
          END IF;
          oe_header_util.query_row ( p_header_id  => p_hold_source_rec.hold_entity_id,
                                     x_header_rec => l_header_rec);
        END IF; -- p_hold_source_rec.hold_entity_id is NOT NULL

        IF p_hold_source_rec.line_id is not NULL THEN
          IF l_debug_level  > 0 THEN
             oe_debug_pub.add(' p_hold_source_rec.line_id : ' || p_hold_source_rec.line_id );
          END IF;
          oe_line_util.query_row(
                                 p_line_id  => p_hold_source_rec.line_id
                                ,x_line_rec => l_line_rec
                                );
        END IF;

        -- XXXX Do we need to generate req_id here
        OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(p_header_rec       => l_header_rec
                                          ,p_line_rec         => l_line_rec
                                          ,p_hold_source_id   => p_hold_source_rec.hold_source_id
                                          ,p_change_type      => 'APPLY');
     ELSE --p_hold_source_rec.hold_entity_code = 'O'

        IF l_debug_level  > 0 THEN
           oe_debug_pub.add(' p_hold_source_rec.hold_entity_code ' || p_hold_source_rec.hold_entity_code);
        END IF;

        IF p_hold_source_rec.header_id is NOT NULL THEN
           oe_header_util.query_row ( p_header_id  => p_hold_source_rec.header_id,
                                      x_header_rec => l_header_rec);
        END IF;
        IF p_hold_source_rec.line_id is not NULL THEN
           oe_line_util.query_row(
                                  p_line_id  => p_hold_source_rec.line_id
                                 ,x_line_rec => l_line_rec
                                 );
        END IF;
--	IF(p_hold_source_rec.header_id IS NOT NULL OR p_hold_source_rec.line_id IS NOT NULL) THEN
        -- XXXX Do we need to generate req_id here
        OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(p_header_rec       => l_header_rec
                                          ,p_line_rec         => l_line_rec
                                          ,p_hold_source_id   => p_hold_source_rec.hold_source_id
                                          ,p_change_type      => 'APPLY');
--      END IF;  Bug 6791576
    END IF; --p_hold_source_rec.hold_entity_code = 'O'
  END IF;*/
-- GENESIS --
EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     OE_MSG_PUB.Check_Msg_Level
          (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Create_Order_Holds;


Procedure Release_Order_holds (
   p_hold_release_rec	IN	OE_HOLDS_PVT.hold_release_rec_type,
   x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
-- GENESIS --
 CURSOR check_hold_typ_cur(p_hld_src_id IN NUMBER) IS
    SELECT 'Y'
    FROM DUAL
    WHERE EXISTS (SELECT NULL
                  FROM   oe_hold_sources ohs,
                         oe_hold_definitions ohd
                  WHERE  ohd.hold_id = ohs.hold_id
--		  AND    ohd.activity_name IS NULL  Bug 6791587
                  AND    ohs.hold_source_id = p_hld_src_id
                  AND    ohs.hold_entity_code <> 'O');

 l_chk_hld   VARCHAR2(1) := 'N';

  -- Bug 8463870
  l_line_id    number;
  l_line_rec   oe_order_pub.line_rec_type;

  l_header_id  number;
  l_header_rec oe_order_pub.header_rec_type;

  cursor header_line_id_cur(p_ord_hld_id in number) is
    select ohld.header_id,
           ohld.line_id
    from   oe_order_holds ohld,
           oe_order_headers ooh,
           oe_order_sources src
    where  ohld.order_hold_id = p_ord_hld_id
    and    ohld.header_id = ooh.header_id
    and    src.order_source_id = ooh.order_source_id
    and    src.aia_enabled_flag = 'Y';

-- GENESIS --

 l_user_id      NUMBER;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_user_id := OE_HOLDS_PVT.get_user_id;
  -- Flag all orders and order line holds for this hold source
  -- as released
    UPDATE oe_order_holds
       SET hold_release_id = p_hold_release_rec.hold_release_id,
           LAST_UPDATED_BY = l_user_id,
           LAST_UPDATE_DATE = sysdate,
           RELEASED_FLAG    = 'Y'
     WHERE hold_source_id = p_hold_release_rec.hold_source_id
       AND hold_release_id IS NULL;
     -- XXX ??
     -- If the entity code is order, then release hold source also, if no
     -- other order hold records exist for this hold source. This would
     -- be the case if selected lines of an order were put on hold.
     -- IF l_entity_code = 'O' THEN
     -- END IF;
-- GENESIS --
  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OE_HOLDS_PVT - RELEASE ORDER HOLDS - BEFORE GENESIS CALL');
  END IF;
  OPEN check_hold_typ_cur(p_hold_release_rec.hold_source_id);
  FETCH check_hold_typ_cur INTO l_chk_hld;
  CLOSE check_hold_typ_cur;

  IF NVL(l_chk_hld, 'N') = 'Y' THEN
    IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OE_HOLDS_PVT - 1 RELEASE ORDER HOLDS - BEFORE SYNC_HEADER_LINE');
       oe_debug_pub.add(  'OE_HOLDS_PVT - hold_source _id '|| p_hold_release_rec.hold_source_id);
       oe_debug_pub.add(  'OE_HOLDS_PVT - hold_release_id' ||p_hold_release_rec.hold_release_id);
    END IF;

    -- Bug 8463870
    for hld_rls_rec in header_line_id_cur(p_hold_release_rec.order_hold_id)
    loop
      l_header_id := hld_rls_rec.header_id;
      l_line_id   := hld_rls_rec.line_id;
    end loop;

    if l_debug_level > 0 then
      oe_debug_pub.add('....header_id = ' || l_header_id);
      oe_debug_pub.add('....line_id  = ' || l_line_id);
    end if;

    if ( l_header_id is not null ) then
      l_header_rec := oe_header_util.query_row(p_header_id => l_header_id);
      if ( l_debug_level > 0 ) then
        oe_debug_pub.add('.... Queried up header record.');
      end if;
    end if;

    if ( l_line_id is not null ) then
      l_line_rec := oe_line_util.query_row(p_line_id => l_line_id);
      if ( l_debug_level > 0 ) then
        oe_debug_pub.add('.... Queried up line record.');
      end if;
    end if;

    if (l_debug_level > 0 ) then
      oe_debug_pub.add('.... Calling oe_sync_order_pvt.sync_header_line...');
    end if;

    OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(p_header_rec       => l_header_rec  -- NULL
                                      ,p_line_rec        => l_line_rec     -- NULL
                                      ,p_hold_source_id  => p_hold_release_rec.hold_source_id
                                      ,p_change_type     => 'RELEASE'
                                      ,p_hold_release_id => p_hold_release_rec.hold_release_id);

    if (l_debug_level > 0 ) then
      oe_debug_pub.add('.... Returned from oe_sync_order_pvt.sync_header_line...');
    end if;
  END IF;
-- GENESIS --
END Release_Order_holds;



PROCEDURE Create_Release_Source (
      p_hold_release_rec   IN   OE_Holds_Pvt.Hold_Release_Rec_type,
	 x_hold_release_id    OUT NOCOPY /* file.sql.39 change */  oe_hold_releases.HOLD_RELEASE_ID%type,
      x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
      x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
      x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
     )
IS
l_dummy     VARCHAR2(30);
l_user_id   NUMBER;
l_hold_release_rec    OE_Holds_Pvt.Hold_Release_Rec_type;
BEGIN

 -- Fix For Bug 1903900
 SAVEPOINT insert_hold_release;
 x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_user_id := OE_HOLDS_PVT.get_user_id;

     -- Validate Reason Code
     BEGIN

          SELECT  'x'
          INTO    l_dummy
               FROM    OE_LOOKUPS
          WHERE   LOOKUP_TYPE = 'RELEASE_REASON'
          AND     LOOKUP_CODE = p_hold_release_rec.release_reason_code;

      EXCEPTION

          WHEN NO_DATA_FOUND THEN
          oe_debug_pub.add('Invalid Reason Code:' ||
                        p_hold_release_rec.release_reason_code ,2);
          FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_REASON_CODE');
          FND_MESSAGE.SET_TOKEN('REASON_CODE',
					    p_hold_release_rec.release_reason_code);
          OE_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;

      END;  -- Validate Reason Code

    SELECT     OE_HOLD_RELEASES_S.NEXTVAL
    INTO  x_hold_release_id
    FROM  DUAL;

    oe_debug_pub.add('Creating OE_HOLD_RELEASES record', 1);
   /*Bug3042838 Added nvl condition for insertion into CREATED_BY column */
    INSERT INTO OE_HOLD_RELEASES
     ( HOLD_RELEASE_ID
     , CREATION_DATE
     , CREATED_BY
     , LAST_UPDATE_DATE
     , LAST_UPDATED_BY
     , LAST_UPDATE_LOGIN
     , PROGRAM_APPLICATION_ID
     , PROGRAM_ID
     , PROGRAM_UPDATE_DATE
     , REQUEST_ID
     , HOLD_SOURCE_ID
     , RELEASE_REASON_CODE
     , RELEASE_COMMENT
     , CONTEXT
     , ATTRIBUTE1
     , ATTRIBUTE2
     , ATTRIBUTE3
     , ATTRIBUTE4
     , ATTRIBUTE5
     , ATTRIBUTE6
     , ATTRIBUTE7
     , ATTRIBUTE8
     , ATTRIBUTE9
     , ATTRIBUTE10
     , ATTRIBUTE11
     , ATTRIBUTE12
     , ATTRIBUTE13
     , ATTRIBUTE14
     , ATTRIBUTE15
     )
   VALUES
     ( x_hold_release_id
     , sysdate
     , nvl(p_hold_release_rec.CREATED_BY,l_user_id)
     , sysdate
     , l_user_id
     , p_hold_release_rec.LAST_UPDATE_LOGIN
     , p_hold_release_rec.PROGRAM_APPLICATION_ID
     , p_hold_release_rec.PROGRAM_ID
     , p_hold_release_rec.PROGRAM_UPDATE_DATE
     , p_hold_release_rec.REQUEST_ID
     , p_hold_release_rec.HOLD_SOURCE_ID
     , p_hold_release_rec.RELEASE_REASON_CODE
     , p_hold_release_rec.RELEASE_COMMENT
     , p_hold_release_rec.CONTEXT
     , p_hold_release_rec.ATTRIBUTE1
     , p_hold_release_rec.ATTRIBUTE2
     , p_hold_release_rec.ATTRIBUTE3
     , p_hold_release_rec.ATTRIBUTE4
     , p_hold_release_rec.ATTRIBUTE5
     , p_hold_release_rec.ATTRIBUTE6
     , p_hold_release_rec.ATTRIBUTE7
     , p_hold_release_rec.ATTRIBUTE8
     , p_hold_release_rec.ATTRIBUTE9
     , p_hold_release_rec.ATTRIBUTE10
     , p_hold_release_rec.ATTRIBUTE11
     , p_hold_release_rec.ATTRIBUTE12
     , p_hold_release_rec.ATTRIBUTE13
     , p_hold_release_rec.ATTRIBUTE14
     , p_hold_release_rec.ATTRIBUTE15
     );

-- Flag the hold source as released

    oe_debug_pub.add('Updating oe_hold_sources for Release', 1);
    --ER#7479609 UPDATE oe_hold_sources
    UPDATE oe_hold_sources_all  --ER#7479609
    SET hold_release_id = x_hold_release_id
    ,     released_flag = 'Y'
    ,     LAST_UPDATED_BY = l_user_id
    ,     LAST_UPDATE_DATE = sysdate
    WHERE hold_source_id = p_hold_release_rec.HOLD_SOURCE_ID;

 -- l_hold_release_rec := p_hold_release_rec;
 --  l_hold_release_rec.hold_release_id := x_hold_release_id;

 EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
       x_return_status := FND_API.G_RET_STS_ERROR;
       ROLLBACK TO insert_hold_release;
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       ROLLBACK TO insert_hold_release;
     WHEN OTHERS THEN
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         OE_MSG_PUB.Add_Exc_Msg
         (G_PKG_NAME
          ,'Insert_Hold_Release');
      END IF;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     ROLLBACK TO insert_hold_release;

END Create_Release_Source;

Procedure Release_Hold_Source (
   p_hold_source_rec	IN   OE_HOLDS_PVT.Hold_source_Rec_Type,
   p_hold_release_rec   IN   OE_HOLDS_PVT.hold_release_rec_type,
   x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
   x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER,
   x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
l_hold_release_rec  OE_HOLDS_PVT.hold_release_rec_type;
l_hold_release_id oe_hold_releases.HOLD_RELEASE_ID%type;
--
CURSOR hold_source IS
     SELECT  HS.HOLD_SOURCE_ID
     FROM OE_HOLD_SOURCES HS
     WHERE   HS.HOLD_ID = p_hold_source_rec.hold_id
     AND  HS.RELEASED_FLAG = 'N'
     --AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
     AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
     AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
     AND  nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
          nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
     AND  nvl(HS.HOLD_ENTITY_ID2, -99) =
          nvl(p_hold_source_rec.hold_entity_id2, -99);

CURSOR order_hold_source IS
     SELECT  HS.HOLD_SOURCE_ID
       FROM  OE_HOLD_SOURCES HS
      WHERE  HS.HOLD_ID = p_hold_source_rec.hold_id
        AND  HS.RELEASED_FLAG = 'N'
      --AND  NVL(HS.HOLD_UNTIL_DATE, SYSDATE + 1) > SYSDATE
        AND  HS.HOLD_ENTITY_CODE = p_hold_source_rec.hold_entity_code
        AND  HS.HOLD_ENTITY_ID = p_hold_source_rec.hold_entity_id
        AND  HS.HOLD_ENTITY_CODE2 is null
        AND  HS.HOLD_ENTITY_ID2 is null
--        AND  nvl(HS.HOLD_ENTITY_CODE2, 'NO_ENTITY_CODE2') =
--             nvl(p_hold_source_rec.hold_entity_code2, 'NO_ENTITY_CODE2')
--        AND  nvl(HS.HOLD_ENTITY_ID2, -99) =
--             nvl(p_hold_source_rec.hold_entity_id2, -99)
        AND  EXISTS (select 1
                       from oe_order_holds oh
                      where oh.hold_source_id = hs.hold_source_id
                        and oh.header_id      =
                            nvl(p_hold_source_rec.header_id, oh.header_id)
                        and nvl(oh.line_id, -99) =
                            nvl(p_hold_source_rec.line_id, -99));
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_hold_release_rec := p_hold_release_rec;

-- Retrieving hold source ID if not passed
  IF p_hold_source_rec.hold_source_id IS NULL THEN
    IF p_hold_source_rec.hold_entity_code = 'O' AND
       p_hold_source_rec.hold_entity_code2 is null THEN
      oe_debug_pub.add('Releasing Order based holds', 1);
      OPEN order_hold_source;
      FETCH order_hold_source INTO l_hold_release_rec.hold_source_id;
      IF (order_hold_source%NOTFOUND) THEN
         /* Note:Fix for bug#2669137 */
         /*
         oe_debug_pub.add('Missing Order Hold Source ID...',1);
         oe_debug_pub.add('Entity Code/ID/Header_id/Line_id' ||
                           p_hold_source_rec.hold_entity_code || '/' ||
                           to_char(p_hold_source_rec.hold_entity_id) || '/' ||
                           p_hold_source_rec.header_id || '/' ||
                           p_hold_source_rec.line_id,1);
         oe_debug_pub.add('Entity Code2/ID2' ||
                           p_hold_source_rec.hold_entity_code2 || '/' ||
                           to_char(p_hold_source_rec.hold_entity_id2) ,1);
         FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
         */
         CLOSE order_hold_source;
         RETURN;
      END IF;  -- order_hold_source%NOTFOUND
      CLOSE order_hold_source;
    ELSE
      OPEN hold_source;
      FETCH hold_source INTO l_hold_release_rec.hold_source_id;
      IF (hold_source%NOTFOUND) THEN
         oe_debug_pub.add('Missing Hold Source ID...',1);
         oe_debug_pub.add('Entity Code/ID' ||
                           p_hold_source_rec.hold_entity_code || '/' ||
                           to_char(p_hold_source_rec.hold_entity_id) ,1);
         oe_debug_pub.add('Entity Code2/ID2' ||
                           p_hold_source_rec.hold_entity_code2 || '/' ||
                           to_char(p_hold_source_rec.hold_entity_id2) ,1);
         FND_MESSAGE.SET_NAME('ONT', 'OE_MISSING_HOLD_SOURCE');
         OE_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
      END IF;  -- hold_source%NOTFOUND
      CLOSE hold_source;
    END IF; -- p_hold_source_rec.hold_entity_code = 'O'
  ELSE
    l_hold_release_rec.hold_source_id := p_hold_source_rec.hold_source_id;
     oe_debug_pub.add('Using Hold Source ID:' ||
                       to_char(l_hold_release_rec.hold_source_id) ,1);
  END IF;

  OE_HOLDS_PVT.Create_Release_Source(p_hold_release_rec => l_hold_release_rec,
							  x_hold_release_id  => l_hold_release_id,
                                     x_return_status    => x_return_status,
                                     x_msg_count        => x_msg_count,
                                     x_msg_data         => x_msg_data);

  IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;
  oe_debug_pub.add('Calling Release_Order_holds using l_hold_release_id' ||
					    to_char(l_hold_release_id) ,1);
  l_hold_release_rec.hold_release_id := l_hold_release_id;

  OE_HOLDS_PVT.Release_Order_holds(
				  p_hold_release_rec => l_hold_release_rec,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
	   x_return_status := FND_API.G_RET_STS_ERROR;
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   WHEN OTHERS THEN
     IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
		 OE_MSG_PUB.Add_Exc_Msg (G_PKG_NAME
		                        ,'Insert_Hold_Release');
     END IF;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

END Release_Hold_Source;




Procedure Validate_Order(p_header_id IN OE_ORDER_HEADERS.header_id%type,
                         p_line_id   IN OE_ORDER_LINES.line_id%type,
                         x_return_status       OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
                         x_msg_count           OUT NOCOPY /* file.sql.39 change */     NUMBER,
                         x_msg_data            OUT NOCOPY /* file.sql.39 change */     VARCHAR2)
IS
l_api_name              CONSTANT VARCHAR2(30) := 'Validate_Order';
l_dummy                 VARCHAR2(30);
l_header_id             OE_ORDER_HEADERS.header_id%type;
BEGIN
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     IF p_line_id IS NULL AND p_header_id IS NULL THEN
            FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
            OE_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
     ELSIF p_header_id IS NULL THEN
          l_dummy := 'LINE'; -- Added for bug 7112725
          SELECT header_id
            INTO l_header_id
            FROM OE_ORDER_LINES
           WHERE LINE_ID = p_line_id;
     ELSE
        l_dummy := 'HEADER'; -- Added for bug 7112725
        SELECT 'Valid Entity'
          INTO l_dummy
          FROM OE_ORDER_HEADERS
         WHERE HEADER_ID = p_header_id;
     END IF;
EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Modified below code for bug 7112725
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF l_dummy = 'HEADER' THEN
             FND_MESSAGE.SET_NAME('ONT', 'OE_INVALID_HEADER_ID');
             FND_MESSAGE.SET_TOKEN('HEADER_ID',p_header_id);
             OE_MSG_PUB.ADD;
          ELSIF l_dummy = 'LINE' THEN
             FND_MESSAGE.SET_NAME('ONT', 'OE_COGS_INVALID_LINE_ID');
             FND_MESSAGE.SET_TOKEN('LINE_ID',p_line_id);
             OE_MSG_PUB.ADD;
          END IF;
          oe_debug_pub.add('Return Status : ' || x_return_status, 5);
          -- RAISE FND_API.G_EXC_ERROR; -- Commented for bug 7112725
END Validate_Order;


Procedure Validate (
  p_hold_source_rec           IN      OE_HOLDS_PVT.Hold_Source_Rec_type,
  x_return_status             OUT NOCOPY /* file.sql.39 change */     VARCHAR2,
  x_msg_count                 OUT NOCOPY /* file.sql.39 change */     NUMBER,
  x_msg_data                  OUT NOCOPY /* file.sql.39 change */     VARCHAR2)
IS
BEGIN
   Validate_Hold_source ( p_hold_source_rec => p_hold_source_rec,
                         x_return_status   => x_return_status,
                         x_msg_count       => x_msg_count,
                         x_msg_data        => x_msg_data
                       );
  /*
  ** Call Validate_Hold() only if Validate_Hold_Source() was successful
  */
  IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

  Validate_Hold ( p_hold_id         => p_hold_source_rec.hold_id,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                );
  ELSE
    RETURN;
  END IF;
END Validate;


----------------------------------------------------------------------------
--  Delete Holds
--  Deletes from OE_ORDER_HOLDS all hold records for an order (p_header_id)
--  or for a line (p_line_id).
--  Also, if there are ORDER hold sources (hold_entity_code = 'O') for this
--  order, deletes hold source records from OE_HOLD_SOURCES.
--  If the hold or hold source was released and the same release record is
--  not used by an existing hold or hold source, then deletes the
--  release record also from OE_HOLD_RELEASES;
----------------------------------------------------------------------------
PROCEDURE Delete_Holds (
   p_order_rec              IN    OE_HOLDS_PVT.order_rec_Type,
   x_return_status		OUT NOCOPY /* file.sql.39 change */	VARCHAR2,
   x_msg_count			OUT NOCOPY /* file.sql.39 change */	NUMBER,
   x_msg_data			OUT NOCOPY /* file.sql.39 change */	VARCHAR2
 )
IS
l_api_name		CONSTANT VARCHAR2(30) := 'DELETE_HOLDS';
l_api_version		CONSTANT NUMBER := 1.0;
l_order_hold_id		NUMBER;
l_hold_source_id	NUMBER;
l_hold_release_id	NUMBER := 0;
CURSOR order_hold IS
	SELECT order_hold_id, NVL(hold_release_id,0)
	FROM OE_ORDER_HOLDS_all
	WHERE HEADER_ID = p_order_rec.header_id;
CURSOR hold_source IS
	SELECT hold_source_id, NVL(hold_release_id,0)
	FROM OE_HOLD_SOURCES_all
	WHERE HOLD_ENTITY_CODE = 'O'
	  AND HOLD_ENTITY_ID = p_order_rec.header_id;
CURSOR line_hold IS
	SELECT order_hold_id, NVL(hold_release_id,0)
	FROM OE_ORDER_HOLDS_all
	WHERE LINE_ID = p_order_rec.line_id;

BEGIN
	-- Standard Start of API savepoint

	SAVEPOINT DELETE_HOLDS_PUB;

	-- Initialize API return status to success
	x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Missing Input arguments

	IF (p_order_rec.header_id = FND_API.G_MISS_NUM
   		AND p_order_rec.line_id = FND_API.G_MISS_NUM) THEN

		FND_MESSAGE.SET_NAME('ONT', 'OE_ENTER_HEADER_OR_LINE_ID');
		OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;

	END IF;

	-- Delete the hold records corr. to this order or line in OE_ORDER_HOLDS

	IF p_order_rec.line_id = FND_API.G_MISS_NUM THEN

   	-- Delete order hold records

        OPEN order_hold;

        LOOP
   	   FETCH order_hold INTO l_order_hold_id, l_hold_release_id;
   	   IF (order_hold%notfound) THEN
   	    	EXIT;
   	   END IF;

     	   OE_Debug_PUB.Add('Deleting order hold record',1);

     	   DELETE FROM OE_ORDER_HOLDS_all
     	    WHERE order_hold_id = l_order_hold_id;

     	 OE_Debug_PUB.Add('Deleting hold release record',1);
     	 DELETE FROM OE_HOLD_RELEASES
     	  WHERE HOLD_RELEASE_ID = l_hold_release_id
     	    AND HOLD_RELEASE_ID NOT IN (SELECT NVL(HOLD_RELEASE_ID,0)
     	                                  FROM OE_ORDER_HOLDS_all
                                         UNION
                                        SELECT NVL(HOLD_RELEASE_ID,0)
                                          FROM OE_HOLD_SOURCES_all
    			                );
       END LOOP;

       CLOSE order_hold;

       -- Delete hold source records
       OPEN hold_source;
       LOOP
          FETCH hold_source INTO l_hold_source_id, l_hold_release_id;
          IF (hold_source%notfound) THEN
       		     EXIT;
          END IF;
     	  OE_Debug_PUB.Add('Deleting hold source record',1);

          DELETE FROM  OE_HOLD_SOURCES_all
           WHERE HOLD_SOURCE_ID = l_hold_source_id;

         OE_Debug_PUB.Add('Deleting hold release record',1);
          DELETE FROM OE_HOLD_RELEASES
           WHERE HOLD_RELEASE_ID = l_hold_release_id
             AND HOLD_RELEASE_ID NOT IN
			  ( SELECT NVL(HOLD_RELEASE_ID,0)
       	  	           FROM OE_ORDER_HOLDS_all
     		          UNION
     	              SELECT NVL(HOLD_RELEASE_ID,0)
     			     FROM OE_HOLD_SOURCES_all
     			 );

     	    END LOOP;

     	    CLOSE hold_source;


	ELSE

        -- Delete line hold records

   	   OPEN line_hold;

   	   LOOP

   	    	FETCH line_hold INTO l_order_hold_id, l_hold_release_id;
   	    	IF (line_hold%notfound) THEN
   	    		EXIT;
   	    	END IF;

     	    OE_Debug_PUB.Add('Deleting order hold record',1);

     	    DELETE FROM OE_ORDER_HOLDS
     	    	WHERE order_hold_id = l_order_hold_id;

     	    DELETE FROM OE_HOLD_RELEASES
     	    	WHERE HOLD_RELEASE_ID = l_hold_release_id
     	    	  AND HOLD_RELEASE_ID NOT IN
				   (SELECT NVL(HOLD_RELEASE_ID,0)
     	    	  		 FROM OE_ORDER_HOLDS_all
     				UNION
     			    SELECT NVL(HOLD_RELEASE_ID,0)
     				 FROM OE_HOLD_SOURCES_all
     			   );

        END LOOP;

        CLOSE line_hold;

	END IF;


EXCEPTION
    	WHEN FND_API.G_EXC_ERROR THEN
    		IF (order_hold%isopen) THEN
    			CLOSE order_hold;
    		END IF;
    		IF (hold_source%isopen) THEN
    			CLOSE hold_source;
    		END IF;
    		IF (line_hold%isopen) THEN
    			CLOSE line_hold;
    		END IF;
        	ROLLBACK TO DELETE_HOLDS_PUB;
        	x_return_status := FND_API.G_RET_STS_ERROR;
        	OE_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
    	WHEN OTHERS THEN
    		IF (order_hold%isopen) THEN
    			CLOSE order_hold;
    		END IF;
    		IF (hold_source%isopen) THEN
    			CLOSE hold_source;
    		END IF;
    		IF (line_hold%isopen) THEN
    			CLOSE line_hold;
    		END IF;
    		ROLLBACK TO DELETE_HOLDS_PUB;
        	x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        	IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        	THEN
        		OE_MSG_PUB.Add_Exc_Msg
        				( G_PKG_NAME
                			, l_api_name
                			);
        	END IF;
        	OE_MSG_PUB.Count_And_Get
		(   p_count 	=>	x_msg_count
		,   p_data	=>	x_msg_data
	  	);
END Delete_Holds;


--------------------
Procedure Apply_Holds (
  p_order_tbl          IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id	       IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
  p_hold_until_date    IN OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE,
  p_hold_comment       IN OE_HOLD_SOURCES.HOLD_COMMENT%TYPE,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', -- bug 8477694
  x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2 )
IS
 j     NUMBER;
 l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_hold_exists      VARCHAR2(1) :='N'; --bug 5548778
 l_msg_token        VARCHAR2(100);  --8477694
 /*Added the Following  Variables for WF_HOLDS ER (bug 6449458)*/
  l_wf_item_type      OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE := NULL;
 l_wf_activity_name  OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;
 l_is_hold_applied BOOLEAN;
 l_count_of_holds_applied NUMBER := 0;
 l_user_activity_name     VARCHAR2(80);

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  OE_DEBUG_PUB.Add('IN Apply Holds..Orders',1);

    -- 8477694

  IF NOT OE_GLOBALS.G_SYS_HOLD THEN
    IF check_system_holds(
       p_hold_id           => p_hold_id,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data) = 'N' THEN

      OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
      l_msg_token := 'APPLY(System Hold)';
      fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
      fnd_message.set_token('ACTION', l_msg_token);
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
      RETURN;
    END IF;
   END IF;
    OE_DEBUG_PUB.Add('After calling Check_System_Holds');

    OE_DEBUG_PUB.Add('Apply Hold before calling Check_Authorization');

    -- 8477694
      IF p_check_authorization_flag = 'Y'  THEN
        OE_DEBUG_PUB.Add('8477694 Manual Auth'||p_check_authorization_flag);
      ELSE
        OE_DEBUG_PUB.Add('8477694 Auto Auth'||p_check_authorization_flag);
      END IF;

  IF p_check_authorization_flag = 'Y'  THEN  --bug 8477694
    IF check_authorization ( p_hold_id                => p_hold_id
                            ,p_authorized_action_code => 'APPLY'
                            ,p_responsibility_id      => l_resp_id
                            ,p_application_id         => l_application_id
                            ,x_return_status          => x_return_status
                            ,x_msg_count              => x_msg_count
                            ,x_msg_data               => x_msg_data
                           ) = 'N'  THEN
      OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
      fnd_message.set_name('ONT','ONT_APPLY');
      l_msg_token := fnd_message.get;
      fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
      fnd_message.set_token('ACTION', l_msg_token);
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
      RETURN;
    END IF;
  END IF; --bug 8477694

    OE_DEBUG_PUB.Add('Apply Hold After calling Check_Authorization');
--8477694


  for j in 1..p_order_tbl.COUNT loop
     OE_DEBUG_PUB.Add('IN Apply Holds Loop',3);
       l_hold_exists := 'N';  --bug 5548778
       x_return_status := FND_API.G_RET_STS_SUCCESS;
       l_hold_source_rec.hold_entity_code := 'O';
       l_hold_source_rec.hold_entity_id := p_order_tbl(j).header_id;
       l_hold_source_rec.line_id := p_order_tbl(j).line_id;

       l_hold_source_rec.hold_id := p_hold_id;
       l_hold_source_rec.hold_until_date := p_hold_until_date;
       l_hold_source_rec.hold_comment := p_hold_comment;

--dbms_output.put_line ('p_order_tbl.header_id'||p_order_tbl(j).header_id);
--dbms_output.put_line ('Hold_id'|| l_hold_source_rec.hold_id);

       OE_DEBUG_PUB.Add('headerID'|| to_char(p_order_tbl(j).header_id),3);
       OE_DEBUG_PUB.Add('HoldID:' || to_char(l_hold_source_rec.hold_id),3 );

     OE_DEBUG_PUB.Add('Validating ORder',1);
       Validate_Order (p_order_tbl(j).header_id,
                       p_order_tbl(j).line_id,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data
                      );
--dbms_output.put_line ('Validate_Order:x_return_status' || x_return_status );
--dbms_output.put_line ('Validate_Order:x_msg_count' || to_char(x_msg_count) );
--dbms_output.put_line ('Validate_Order:x_msg_data' || x_msg_data );

   OE_DEBUG_PUB.Add('After Validate_Order',2);
   OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,1);
   OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),2 );
   OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data,2 );

        -- Added for bug 7112725
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

       /* Don't need this, cos just putting orders on hold
       ** Uncommenting this for ER # 2662206
        */
	Validate ( p_hold_source_rec => l_hold_source_rec,
                   x_return_status   => x_return_status,
                   x_msg_count       => x_msg_count,
                   x_msg_data        => x_msg_data
                  );
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	        RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
--bug 5548778 call overloaded method
	Create_Hold_Source (
                  p_hold_source_rec => l_hold_source_rec,
                  x_hold_source_id  => l_hold_source_id,
                  x_hold_exists  => l_hold_exists,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                           );
     OE_DEBUG_PUB.Add('After Create_Hold_Source, x_return_status:' ||
								x_return_status,1);
     OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),3 );
     OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data ,3);
     OE_DEBUG_PUB.Add('l_hold_exists:' || l_hold_exists ,3);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;

    OE_DEBUG_PUB.Add('l_hold_source_id->' || to_char(l_hold_source_id) ,1);
    l_hold_source_rec.hold_source_id := l_hold_source_id;
  IF l_hold_exists = 'N' THEN   --bug 5548778
   /*Added the Select query and IF Condition below and calling overloaded create_order_holds procedure
     for WF_HOLDS ER (bug 6449458)*/
   IF l_wf_item_type IS NULL AND l_wf_activity_name IS NULL THEN
      select item_type, activity_name
      into   l_wf_item_type, l_wf_activity_name
      from   oe_hold_definitions
      where  hold_id = l_hold_source_rec.hold_id;
    END IF;

    IF l_wf_item_type IS NOT NULL AND l_wf_activity_name IS NOT
                                                        NULL THEN
      OE_DEBUG_PUB.Add ('Calling Overloaded Create_Order_Holds Based on Workflow',1);
      Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,p_item_type           =>  l_wf_item_type
         ,p_activity_name       =>  l_wf_activity_name
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
         ,x_is_hold_applied     =>  l_is_hold_applied);

    ELSE

    OE_DEBUG_PUB.Add ('Calling Create_Order_Holds',1);
    Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
			  );
     OE_DEBUG_PUB.Add('After Create_Order_Holds',1);
    END IF; -- l_item_type and l_activity_name

    IF NVL(l_is_hold_applied,FALSE) THEN
      l_count_of_holds_applied := l_count_of_holds_applied + 1;
     OE_DEBUG_PUB.Add('Hold is applied :',2);
    END IF;
    l_is_hold_applied := FALSE;
   /* OE_DEBUG_PUB.Add ('Calling Create_Order_Holds',1);
    Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
			  );
     OE_DEBUG_PUB.Add('After Create_Order_Holds',1);*/
  END IF;
  end loop;
/*Added the query and IF Condition below for WF_HOLDS ER (bug 6449458)*/
 IF l_wf_item_type is not null and l_wf_activity_name is not null THEN
  select meaning into l_user_activity_name
  from   oe_lookups
  where  lookup_type = DECODE(l_wf_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
  and    lookup_code = l_wf_activity_name;

  IF p_order_tbl.COUNT = 1 AND l_count_of_holds_applied = 0 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FOR_ACTIVITY');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add(' Hold Not applied for the requested line');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_count_of_holds_applied  = 0
    AND p_order_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for ALL requested lines');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_order_tbl.COUNT > l_count_of_holds_applied
    AND p_order_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for FEW requested lines');
  ELSE
    NULL; -- No messages are required to be logged.
  END IF;
 END IF;

EXCEPTION
   WHEN OTHERS THEN
      --dbms_output.put_line ('ApplyHolds-EXCEPTION');
      OE_DEBUG_PUB.Add('Error:Apply Holds',1);
      OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,1);
      OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),1 );
      OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data ,1);
END Apply_Holds;


Procedure Apply_Holds(
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_hold_existing_flg   IN  VARCHAR2,
  p_hold_future_flg     IN  VARCHAR2,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', --bug 8477694
  x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
  x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER,
  x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2 )
IS
 l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_hold_source_rec       OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_exists      VARCHAR2(1) :='N'; --bug 5548778
 l_msg_token        VARCHAR2(100);  --8477694
/* Commented OLD Processing and added the lines below for WF_HOLS ER (bug 6449458)*/
 l_hold_msg_applied   BOOLEAN DEFAULT NULL;
 l_wf_item_type       OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE := NULL;
 l_wf_activity_name   OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;

 BEGIN



  Begin
    select item_type, activity_name
    into   l_wf_item_type, l_wf_activity_name
    from   oe_hold_definitions
    where  hold_id = p_hold_source_rec.hold_id;
  Exception
    When NO_DATA_FOUND Then
      NULL; -- OE_Holds_Pvt.Validate has not yet been called.
  End;

 Apply_Holds(
  p_hold_source_rec     => p_hold_source_rec,
  p_hold_existing_flg   => p_hold_existing_flg,
  p_hold_future_flg     => p_hold_future_flg,
  p_wf_item_type        => l_wf_item_type,
  p_wf_activity_name    => l_wf_activity_name,
  p_check_authorization_flag => p_check_authorization_flag, -- bug 8477694
  x_return_status       => x_return_status,
  x_msg_count           => x_msg_count,
  x_msg_data            => x_msg_data,
  x_is_hold_applied     => l_hold_msg_applied);
/*BEGIN
  OE_DEBUG_PUB.Add('In OE_Holds_pvt.Apply Holds, Creating Hold Source',1);

  x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_hold_source_rec := p_hold_source_rec;
    Validate (p_hold_source_rec  => p_hold_source_rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data );
    OE_DEBUG_PUB.Add('Validate return status:' || x_return_status,1);
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            OE_Debug_PUB.Add('Validate not successful',1);
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
    ELSE
        OE_DEBUG_PUB.Add ('Calling Create_Hold_Source bug 5548778 overload',1);
	  Create_Hold_Source (
                  p_hold_source_rec => p_hold_source_rec,
                  x_hold_source_id  => l_hold_source_id,
    		  x_hold_exists  => l_hold_exists,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                           );
        OE_DEBUG_PUB.Add('x_return_status->' || x_return_status,1);
        OE_DEBUG_PUB.Add('x_msg_count->' || x_msg_count,1);
        OE_DEBUG_PUB.Add('x_msg_data' || x_msg_data,1);
        OE_DEBUG_PUB.Add('l_hold_exists' || l_hold_exists,1);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	        RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;
      OE_DEBUG_PUB.Add('l_hold_source_id->' || to_char(l_hold_source_id) ,1);
      l_hold_source_rec.hold_source_id := l_hold_source_id;
  --bug 5548778
    IF l_hold_exists = 'N' THEN
      OE_DEBUG_PUB.Add ('Calling Create_Order_Holds',1);
      Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
			  );
     OE_DEBUG_PUB.Add('After Create_Order_Holds',1);
     END IF;
    END IF;*/
END Apply_Holds;


---------------------
Procedure Release_Holds (
  p_hold_source_rec       IN   OE_HOLDS_PVT.hold_source_rec_type,
  p_hold_release_rec      IN   OE_HOLDS_PVT.Hold_Release_Rec_Type,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', -- bug 8477694
  x_return_status         OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count             OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data              OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_order_rec          OE_HOLDS_PVT.order_rec_type;
--bug 5051532
l_hold_source_rec    OE_HOLDS_PVT.hold_source_rec_type;
l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;  --8477694
l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;  --8477694
l_msg_token        VARCHAR2(100);  --8477694

BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --8477694
   IF NOT OE_GLOBALS.G_SYS_HOLD THEN
       IF check_system_holds( p_hold_id                => p_hold_source_rec.hold_id
                             ,x_return_status          => x_return_status
                             ,x_msg_count              => x_msg_count
                             ,x_msg_data               => x_msg_data
                              ) = 'N'  THEN
         OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_source_rec.hold_id));
         l_msg_token := 'RELEASE(System Hold)';
         fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
         fnd_message.set_token('ACTION', l_msg_token);
         OE_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
         OE_MSG_PUB.Count_And_Get
              (   p_count     =>      x_msg_count
              ,   p_data      =>      x_msg_data
              );
         RETURN;
       END IF;
   END IF;

     OE_DEBUG_PUB.Add('After calling Check_System_Holds');

     OE_DEBUG_PUB.Add('Release Hold before calling Check_Authorization');

      -- bug 8477694
       IF p_check_authorization_flag = 'Y'  THEN
         OE_DEBUG_PUB.Add('8477694 Manual Auth'||p_check_authorization_flag);
       ELSE
         OE_DEBUG_PUB.Add('8477694 Auto Auth'||p_check_authorization_flag);
       END IF;

   IF p_check_authorization_flag = 'Y' THEN -- Bug 8477694
     IF check_authorization ( p_hold_id                => p_hold_source_rec.hold_id
                             ,p_authorized_action_code => 'REMOVE'
                             ,p_responsibility_id      => l_resp_id
                             ,p_application_id         => l_application_id
                             ,x_return_status          => x_return_status
                             ,x_msg_count              => x_msg_count
                             ,x_msg_data               => x_msg_data
                            ) = 'N'  THEN
       OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_source_rec.hold_id));
       fnd_message.set_name('ONT','ONT_RELEASE');
       l_msg_token := fnd_message.get;
       fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
       fnd_message.set_token('ACTION', l_msg_token);
       OE_MSG_PUB.ADD;
       x_return_status := FND_API.G_RET_STS_ERROR;
       OE_MSG_PUB.Count_And_Get
              (   p_count     =>      x_msg_count
              ,   p_data      =>      x_msg_data
              );
       RETURN;
     END IF;
   END IF; -- BUG 8477694

     OE_DEBUG_PUB.Add('Release Hold  After calling Check_Authorization');
   --8477694


   --bug 5051532
   l_hold_source_rec := p_hold_source_rec;
   -- replaced the occurences of p_hold_source_rec with l_hold_source_rec in theIF part of the IF-ELSE block below, for bug 5051532

   --bug 3977747 start--
    if (l_hold_source_rec.header_id is not null or
              l_hold_source_rec.line_id is not null )
    then
        l_order_rec.line_id   := l_hold_source_rec.line_id;

        --bug 5051532
        If l_hold_source_rec.header_id is null then
                select header_id
                into l_hold_source_rec.header_id
                from oe_order_lines_all
                where line_id = l_hold_source_rec.line_id;
        end if;

        oe_debug_pub.add('l_hold_source_rec.header_id ' || l_hold_source_rec.header_id);
        oe_debug_pub.add('l_hold_source_rec.line_id ' || l_hold_source_rec.line_id);
        l_order_rec.header_id := l_hold_source_rec.header_id;
        -- bug 5051532

	Validate_Order (l_hold_source_rec.header_id,
                       l_hold_source_rec.line_id,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data
                      );
       oe_debug_pub.add('After Validate_Order with x_return_status'||x_return_status,2);

        -- Added for bug 7112725
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

       Release_orders ( p_hold_release_rec  => p_hold_release_rec,
                      p_order_rec         => l_order_rec,
                      p_hold_source_rec   =>  l_hold_source_rec,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data );
      oe_debug_pub.add('After oe_holds_pvt.release_orders with x_return_status' || x_return_status, 1);
       --bug 3977747 ends--
    else

    if (p_hold_source_rec.hold_source_id is null )then
      Validate (p_hold_source_rec  => p_hold_source_rec,
                x_return_status    => x_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data
             );
--dbms_output.put_line ('After ValidateRS->' || x_return_status);
    end if;

    Release_Hold_Source (p_hold_source_rec  => p_hold_source_rec,
                         p_hold_release_rec => p_hold_release_rec,
                         x_return_status    => x_return_status,
                         x_msg_count        => x_msg_count,
                         x_msg_data         => x_msg_data );
--dbms_output.put_line ('After ReleaseRS->' || x_return_status);

    end if;

END Release_Holds;


---------------------
Procedure Release_Holds (
  p_order_tbl              IN   OE_HOLDS_PVT.order_tbl_type,
  p_hold_id                IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE,
  p_release_reason_code    IN   OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE,
  p_release_comment        IN   OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', -- bug 8477694
  x_return_status          OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count              OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data               OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
j                    NUMBER;
l_hold_source_rec    OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_order_rec          OE_HOLDS_PVT.order_rec_type;
l_hold_release_rec   OE_HOLDS_PVT.hold_release_rec_type;
l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;  --8477694
l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;  --8477694
l_msg_token        VARCHAR2(100);  --8477694

BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  oe_debug_pub.add('In Release Holds..Orders',1);

  --8477694
  IF NOT OE_GLOBALS.G_SYS_HOLD THEN
      IF check_system_holds( p_hold_id                => p_hold_id
                            ,x_return_status          => x_return_status
                            ,x_msg_count              => x_msg_count
                            ,x_msg_data               => x_msg_data
                             ) = 'N'  THEN
        OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_id));
        l_msg_token := 'RELEASE(System Hold)';
        fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
        fnd_message.set_token('ACTION', l_msg_token);
        OE_MSG_PUB.ADD;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
        RETURN;
      END IF;
  END IF;

    OE_DEBUG_PUB.Add('After calling Check_System_Holds');

    OE_DEBUG_PUB.Add('Release Hold overloaded before calling Check_Authorization');
    -- bug 8477694
       IF p_check_authorization_flag = 'Y'  THEN
         OE_DEBUG_PUB.Add('8477694 Manual Auth'||p_check_authorization_flag);
       ELSE
         OE_DEBUG_PUB.Add('8477694 Auto Auth'||p_check_authorization_flag);
       END IF;

  IF p_check_authorization_flag= 'Y' THEN -- 8477694
    IF check_authorization ( p_hold_id                => p_hold_id
                            ,p_authorized_action_code => 'REMOVE'
                            ,p_responsibility_id      => l_resp_id
                            ,p_application_id         => l_application_id
                            ,x_return_status          => x_return_status
                            ,x_msg_count              => x_msg_count
                            ,x_msg_data               => x_msg_data
                           ) = 'N'  THEN
      OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_id));
      fnd_message.set_name('ONT','ONT_RELEASE');
      l_msg_token := fnd_message.get;
      fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
      fnd_message.set_token('ACTION', l_msg_token);
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
      RETURN;
    END IF;
  END IF; -- 8477694
    OE_DEBUG_PUB.Add('Release Hold overloaded  After calling Check_Authorization');
    --8477694


  for j in 1..p_order_tbl.COUNT loop
       -- IF p_order_tbl(j).header_id  IS NULL AND
       --    p_order_tbl(j).line_id NULL THEN ERROR
       l_order_rec.header_id := p_order_tbl(j).header_id;
       l_order_rec.line_id   := p_order_tbl(j).line_id;
       l_hold_release_rec.release_reason_code := p_release_reason_code;
       l_hold_release_rec.release_comment     := p_release_comment;
       l_hold_source_rec.hold_id              := p_hold_id;
       oe_debug_pub.add('HeaderID:' || l_order_rec.header_id );
       oe_debug_pub.add('LineID:' || l_order_rec.Line_id );
-- XXX Need some analysis
-- When release holds for orders, check to see if this order was put on
-- hold as an
-- Order based hold. If yes, then release the Hold_Source from hold and
-- also order
-- from hold in oe_order_holds and insert record in oe_hold_releases with
-- order_hold_id(No with Hold Source ID).
-- IF the order being releasesed is part of a different hold source (e.g. 'C')
-- then don't release the hold source(what if its the last order)
--  and only release the order from hold in
-- OE_ORDER_HOLDS and create a record in OE_HOLD_RELEASES with the
-- Order_Hold_ID.
       Validate_Order (p_order_tbl(j).header_id,
                       p_order_tbl(j).line_id,
                       x_return_status   => x_return_status,
                       x_msg_count       => x_msg_count,
                       x_msg_data        => x_msg_data
                      );
       oe_debug_pub.add('After Validate_Order with x_return_status'|| x_return_status);

        -- Added for bug 7112725
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

       oe_debug_pub.add('l_order_rec.header_id'||l_order_rec.header_id);
       oe_debug_pub.add('lhldrlsrec.rel_reas_code' || l_hold_release_rec.release_reason_code);
     oe_holds_pvt.release_orders (
				  p_hold_release_rec  => l_hold_release_rec,
                      p_order_rec         => l_order_rec,
                      p_hold_source_rec   => l_hold_source_rec,
                      x_return_status     => x_return_status,
                      x_msg_count         => x_msg_count,
                      x_msg_data          => x_msg_data );
    oe_debug_pub.add('After oe_holds_pvt.release_orders:' ||
                        x_return_status);
     -- If the entity code is order, then release hold source also, if no
     -- other order hold records exist for this hold source. This would
     -- be the case if selected lines of an order were put on hold.
     -- Decided not to release source XX
    /*
     IF entity_code = 'O' THEN
        BEGIN
          SELECT 'NO HOLDS'
          INTO l_dummy
          FROM OE_ORDER_HOLDS
          WHERE HOLD_SOURCE_ID = l_hold_source_id
            AND HOLD_RELEASE_ID IS NULL
            AND ROWNUM = 1;

        EXCEPTION
          WHEN NO_DATA_FOUND THEN
            OE_Debug_PUB.Add('Setting hold source status to released');
               UPDATE OE_HOLD_SOURCES
               SET  RELEASED_FLAG = 'Y'
               ,    HOLD_RELEASE_ID = l_hold_release_id
               ,    LAST_UPDATED_BY = l_user_id
               ,    LAST_UPDATE_DATE = SYSDATE
                    WHERE HOLD_SOURCE_ID = l_hold_source_id;

        END;
     END IF;
    */

   end loop;
oe_debug_pub.add('After release_orders with x_return_status'|| x_return_status,3);
END Release_Holds;

/*8477694
function check_system_holds(
 p_hold_id           IN   NUMBER,
 x_return_status     OUT NOCOPY  file.sql.39 change   VARCHAR2,
 x_msg_count         OUT NOCOPY  file.sql.39 change   NUMBER,
 x_msg_data          OUT NOCOPY  file.sql.39 change   VARCHAR2
                             )
RETURN varchar2
IS
 l_authorized_or_not varchar2(1) := 'Y';
 l_return_status Varchar2(1) := FND_API.G_RET_STS_SUCCESS;
BEGIN

  x_return_status := l_return_status;
  x_msg_count := 0;
  x_msg_data := NULL;


/* 7576948: IR ISO Change Management project Start

-- In the below IF check for system holds, Hold_id 17 is added
-- for IR ISO change management project. This is a seeded system
-- hold, responsible for applying and release IR ISO hold, which
-- can be applied/released only by the Purchasing product, while
-- internal requisition / requisition line gets changed by the
-- requesting organization user. The judiciously application
-- and releasing of this hold will be done by Purchasing APIs.
-- OM has no APIs for calling the direct Application or Releasing
-- of this seeded system hold for any business flow other than
-- Internal Sales Order flow.
--
-- The application of this seeded hold can be done via OM API
-- OE_Internal_Requisition_Pvt.Apply_Hold_for_IReq, while it can
-- be released via OE_Internal_Requisition_Pvt.Release_Hold_for_IReq
-- The call to both these APIs will be done from Purchasing APIs only.
--
-- For details on IR ISO CMS project, please refer to FOL >
-- OM Development > OM GM > 12.1.1 > TDD > IR_ISO_CMS_TDD.doc

 IF p_hold_id in (13,14,15,17) THEN

 =============================
 IR ISO Change Management Ends
   oe_debug_pub.add('renga: hold not authorized - ');
   l_authorized_or_not := 'N';
 END IF;
 return l_authorized_or_not;
END check_system_holds;
8477694 */

procedure process_apply_holds_lines (
  p_num_of_records     IN NUMBER
, p_sel_rec_tbl        IN OE_GLOBALS.Selected_Record_Tbl
, p_hold_id            IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_hold_until_date    IN OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE
, p_hold_comment       IN OE_HOLD_SOURCES.HOLD_COMMENT%TYPE
, x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

l_header_rec       OE_ORDER_PUB.Header_Rec_Type;
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'process_apply_holds_lines';
l_line_id          NUMBER;
l_return_status    VARCHAR2(30);
l_order_tbl        OE_HOLDS_PVT.order_tbl_type;
l_error_count      NUMBER :=0;
l_ordered_quantity NUMBER ;
j                  INTEGER;
initial            INTEGER;
nextpos            INTEGER;

l_prev_org_id      number;
l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_application_id   OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
l_resp_id          OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
l_msg_token        VARCHAR2(100);
/*Added the following variables for WF_HOLDS ER (bug 6449458)*/
 l_item_type       OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE := NULL;
 l_activity_name   OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;
 l_is_hold_applied BOOLEAN;
 l_count_of_holds_applied NUMBER := 0;
 l_user_activity_name     VARCHAR2(80);


BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_apply_holds_lines',1);

  IF check_system_holds(
     p_hold_id           => p_hold_id,
     x_return_status     => x_return_status,
     x_msg_count         => x_msg_count,
     x_msg_data          => x_msg_data) = 'N' THEN

    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;
  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                          ,p_authorized_action_code => 'APPLY'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));

    fnd_message.set_name('ONT','ONT_APPLY');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_apply_holds_lines;

  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99)
    THEN
       OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
       Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                     p_org_id      => p_sel_rec_tbl(j).Org_Id);
       l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;

    l_line_id := p_sel_rec_tbl(j).id1;
    OE_LINE_UTIL.Query_Row
    ( p_line_id  => l_line_id,
      x_line_rec => l_line_rec
    );

    OE_DEBUG_PUB.Add('Header_id: '||l_line_rec.header_id);
    OE_DEBUG_PUB.Add('Line_id: '||to_char(l_line_rec.line_id));

    l_hold_source_rec.hold_entity_code := 'O';
    l_hold_source_rec.hold_entity_id := l_line_rec.header_id;
    l_hold_source_rec.LINE_ID := l_line_rec.line_id;
    l_hold_source_rec.hold_id := p_hold_id;
    l_hold_source_rec.hold_until_date := p_hold_until_date;
    l_hold_source_rec.hold_comment := p_hold_comment;
 /*Added the IF condition for WF_HOLDS ER (bug 6449458)*/
   IF l_item_type IS NULL AND l_activity_name IS NULL THEN
      select item_type, activity_name
      into   l_item_type, l_activity_name
      from   oe_hold_definitions
      where  hold_id = l_hold_source_rec.hold_id;
    END IF;

    OE_DEBUG_PUB.Add('Before calling oe_holds_pvt.apply_holds');
   /*Calling overloaded procedure apply_holds, modified for WF_HOLDS ER (bug 6449458)*/
    /*oe_holds_pvt.apply_Holds(
        p_hold_source_rec     =>  l_hold_source_rec
       ,p_hold_existing_flg   =>  'Y'
       ,p_hold_future_flg     =>  'Y'
       ,x_return_status       =>  x_return_status
       ,x_msg_count           =>  x_msg_count
       ,x_msg_data            =>  x_msg_data);*/
     oe_holds_pvt.apply_Holds(
       p_hold_source_rec     =>  l_hold_source_rec
      ,p_hold_existing_flg   =>  'Y'
      ,p_hold_future_flg     =>  'Y'
      ,p_org_id		     =>p_sel_rec_tbl(j).org_id    --ER#7479609
      ,p_wf_item_type        =>  l_item_type
      ,p_wf_activity_name    =>  l_activity_name
      ,p_check_authorization_flag => 'N'    -- bug 8477694
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data
      ,x_is_hold_applied     => l_is_hold_applied);

      IF NVL(l_is_hold_applied,FALSE) THEN
        l_count_of_holds_applied := l_count_of_holds_applied + 1;
       OE_DEBUG_PUB.Add('Hold is applied : TRUE',2);
      END IF;
      l_is_hold_applied := FALSE;


     OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,2);
     OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),2);
     OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data,2);

    /*OE_DEBUG_PUB.Add('Before calling OE_Holds_PVT.Apply_Holds');
    oe_holds_pvt.apply_Holds(
       p_hold_source_rec     =>  l_hold_source_rec
      ,p_hold_existing_flg   =>  'Y'
      ,p_hold_future_flg     =>  'Y'
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data);*/

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add('process_apply_holds_lines unexpected failure',1);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add('process_apply_holds_lines expected failure',1);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;
    /*Added the Select query and IF Condition below for WF_HOLDS ER (bug 6449458)*/
 IF l_item_type IS NOT NULL AND l_activity_name IS NOT NULL THEN
    select meaning into l_user_activity_name
    from   oe_lookups
    where  lookup_type = DECODE(l_item_type,
                                OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
                                OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES',
                                '-XX')
    and    lookup_code = l_activity_name;

  IF p_sel_rec_tbl.COUNT = 1 AND l_count_of_holds_applied = 0
                                                             THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FOR_ACTIVITY');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add(' Hold Not applied for the requested line');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_count_of_holds_applied  = 0
    AND p_sel_rec_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for ALL requested lines');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_sel_rec_tbl.COUNT > l_count_of_holds_applied
    AND p_sel_rec_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for FEW requested lines');
  ELSE
    NULL; -- No messages are required to be logged.
  END IF;
 END IF; -- End of WF_HOLDS ER (bug 6449458) IF Condition

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Get message count and data
  OE_MSG_PUB.Count_And_Get
    ( p_count  => x_msg_count
    , p_data   => x_msg_data
    );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_apply_holds_lines',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_apply_holds_lines;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_apply_holds_lines;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_apply_holds_lines;

end process_apply_holds_lines;

/*=================================*/
procedure process_apply_holds_orders (
  p_num_of_records     IN   NUMBER
, p_sel_rec_tbl        IN   OE_GLOBALS.Selected_Record_Tbl
, p_hold_id            IN   OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_hold_until_date    IN   OE_HOLD_SOURCES.HOLD_UNTIL_DATE%TYPE
, p_hold_comment       IN   OE_HOLD_SOURCES.HOLD_COMMENT%TYPE
, x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS
 --l_header_rec      OE_ORDER_PUB.Header_Rec_Type;
 l_line_rec          OE_ORDER_PUB.line_rec_type;
 --l_old_header_rec  OE_ORDER_PUB.Header_Rec_Type;
 l_api_name          CONSTANT VARCHAR2(30) := 'process_apply_holds_orders';
 l_header_id         NUMBER;
 l_return_status     VARCHAR2(30);
 l_order_tbl         OE_HOLDS_PVT.order_tbl_type;
 l_error_count       NUMBER :=0;
 j                   INTEGER;

 L_prev_org_id number;
 l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_application_id    OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id           OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_msg_token        VARCHAR2(100);
 /*Added the following variables for WF_HOLDS ER (bug 6449458)*/
 l_item_type       OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE := NULL;
 l_activity_name   OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;
 l_is_hold_applied BOOLEAN;
 l_count_of_holds_applied NUMBER := 0;
 l_user_activity_name     VARCHAR2(80);

 BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_apply_holds_orders',1);

  IF check_system_holds( p_hold_id                => p_hold_id
                       , x_return_status          => x_return_status
                       , x_msg_count              => x_msg_count
                       , x_msg_data               => x_msg_data
                       ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                         , p_authorized_action_code => 'APPLY'
                         , p_responsibility_id      => l_resp_id
                         , p_application_id         => l_application_id
                         , x_return_status          => x_return_status
                         , x_msg_count              => x_msg_count
                         , x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));

    fnd_message.set_name('ONT','ONT_APPLY');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --   RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_apply_holds_orders;
  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    OE_DEBUG_PUB.Add('p_sel_rec_tbl orgID:' || p_sel_rec_tbl(j).org_id ||
                     ', l_prev_org_id:' || l_prev_org_id);

    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99)
    THEN
      OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
      Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                    p_org_id      => p_sel_rec_tbl(j).Org_Id);
      OE_DEBUG_PUB.Add('After the ORG is :' || MO_GLOBAL.get_current_org_id);
      l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;

    l_hold_source_rec.hold_entity_code := 'O';
    l_hold_source_rec.hold_entity_id := p_sel_rec_tbl(j).id1;
    l_hold_source_rec.hold_id := p_hold_id;
    l_hold_source_rec.hold_until_date := p_hold_until_date;
    l_hold_source_rec.hold_comment := p_hold_comment;

/*Added the IF condition for WF_HOLDS ER (bug 6449458)*/
   IF l_item_type IS NULL AND l_activity_name IS NULL THEN
      select item_type, activity_name
      into   l_item_type, l_activity_name
      from   oe_hold_definitions
      where  hold_id = l_hold_source_rec.hold_id;
    END IF;

    OE_DEBUG_PUB.Add('Before calling oe_holds_pvt.apply_holds');
    /*oe_holds_pvt.apply_Holds(
        p_hold_source_rec     =>  l_hold_source_rec
       ,p_hold_existing_flg   =>  'Y'
       ,p_hold_future_flg     =>  'Y'
       ,x_return_status       =>  x_return_status
       ,x_msg_count           =>  x_msg_count
       ,x_msg_data            =>  x_msg_data);*/

     oe_holds_pvt.apply_Holds(
       p_hold_source_rec     =>  l_hold_source_rec
      ,p_hold_existing_flg   =>  'Y'
      ,p_hold_future_flg     =>  'Y'
      ,p_org_id =>p_sel_rec_tbl(j).org_id    --ER#7479609
      ,p_wf_item_type        =>  l_item_type
      ,p_wf_activity_name    =>  l_activity_name
      ,p_check_authorization_flag => 'N'    -- bug 8477694
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data
      ,x_is_hold_applied     => l_is_hold_applied);

      IF NVL(l_is_hold_applied,FALSE) THEN
        l_count_of_holds_applied := l_count_of_holds_applied + 1;
       OE_DEBUG_PUB.Add('Hold is applied : TRUE',2);
      END IF;
      l_is_hold_applied := FALSE;

     OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,2);
     OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),2);
     OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data,2);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
       Oe_debug_pub.add('process_apply_holds_orders unexpected failure',3);
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       oe_debug_pub.add('process_apply_holds_orders expected failure',3);
       RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;
  /*Added the Select query and IF Condition below for WF_HOLDS ER (bug 6449458)*/
   IF l_item_type IS NOT NULL AND l_activity_name IS NOT NULL THEN
    select meaning into l_user_activity_name
    from   oe_lookups
    where  lookup_type = DECODE(l_item_type,
                                OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
                                OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES',
                                '-XX')
    and    lookup_code = l_activity_name;

  IF p_sel_rec_tbl.COUNT = 1 AND l_count_of_holds_applied = 0
                                                             THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FOR_ACTIVITY');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add(' Hold Not applied for the requested line');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF l_count_of_holds_applied  = 0
    AND p_sel_rec_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for ALL requested lines');
    RAISE FND_API.G_EXC_ERROR;
  ELSIF p_sel_rec_tbl.COUNT > l_count_of_holds_applied
    AND p_sel_rec_tbl.COUNT > 1 THEN
    fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
    fnd_message.set_token('WF_ACT',l_user_activity_name);
    OE_MSG_PUB.ADD;
    oe_debug_pub.add('Hold Not applied for FEW requested lines');
  ELSE
    NULL; -- No messages are required to be logged.
   END IF;
  END IF; -- End of WF_HOLDS ER (bug 6449458) IF Condition

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Get message count and data
  OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_apply_holds_orders',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_apply_holds_orders;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_apply_holds_orders;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_apply_holds_orders;

end process_apply_holds_orders;

/***********************************************/
/* Releasing Orders from Sales Order Form - Old*/
/***********************************************/

-- Kept for backward compatibility with third party applications
-- using the holds framework. The new overloaded version will be
-- called after ER 1373910

procedure process_release_holds_lines (
  p_num_of_records      IN NUMBER
, p_sel_rec_tbl         IN OE_GLOBALS.Selected_Record_Tbl
, p_hold_id             IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_release_reason_code IN OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
, p_release_comment     IN OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
, x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

--l_header_rec     OE_ORDER_PUB.Header_Rec_Type;
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'process_release_holds_lines';
l_line_id          NUMBER;
l_return_status    VARCHAR2(30);
l_order_tbl        OE_HOLDS_PVT.order_tbl_type;
l_error_count      NUMBER :=0;
l_ordered_quantity NUMBER ;
j                  INTEGER;
initial            INTEGER;
nextpos            INTEGER;

l_prev_org_id number;
 l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_application_id   OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
l_resp_id          OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_msg_token        VARCHAR2(100);
BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_release_holds_lines',1);

  IF check_system_holds( p_hold_id                => p_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'||to_char(p_hold_id));
    fnd_message.set_name('ONT','ONT_RELEASE');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --   RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_release_holds_lines;

  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99)
    THEN
       OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
       Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                     p_org_id      => p_sel_rec_tbl(j).Org_Id);
       l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;


    L_line_id := p_sel_rec_tbl(j).id1;
    OE_LINE_UTIL.Query_Row
       ( p_line_id  => l_line_id,
         x_line_rec => l_line_rec
        );
    OE_DEBUG_PUB.Add('header_id: '||l_line_rec.header_id);
    OE_DEBUG_PUB.Add('Line_id: '||to_char(l_line_rec.line_id));
    l_order_tbl(1).header_id := l_line_rec.header_id;
    l_order_tbl(1).line_id := l_line_rec.line_id;


  OE_DEBUG_PUB.Add('B4 Calling oe_holds_pvt.release_holds:HeaderID'
                 || l_order_tbl(1).header_id || ', LineID:' || l_order_tbl(1).line_id);
  oe_holds_pvt.release_holds(
          p_order_tbl        =>  l_order_tbl,
          p_hold_id          =>  p_hold_id,
          p_release_reason_code  =>  p_release_reason_code,
          p_release_comment      =>  p_release_comment,
          p_check_authorization_flag => 'N' ,   -- bug 8477694
          x_return_status    =>  x_return_status,
          x_msg_count        =>  x_msg_count,
          x_msg_data         =>  x_msg_data
                           );

     OE_DEBUG_PUB.Add('After oe_holds_pvt.release_holds:' || x_return_status,3);


    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add('process_release_holds_lines unexpected failure',3);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add('process_release_holds_lines failure',3);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
  OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_release_holds_lines',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

end process_release_holds_lines;

/*
    PROCESS_RELEASE_HOLDS_ORDERS
*/
procedure process_release_holds_orders (
  p_num_of_records      IN NUMBER
, p_sel_rec_tbl         IN OE_GLOBALS.Selected_Record_Tbl
, p_hold_id             IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_release_reason_code IN OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
, p_release_comment     IN OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
, x_return_status      OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count          OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data           OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'process_release_holds_orders';
l_header_id        NUMBER;
l_return_status    VARCHAR2(30);
l_order_tbl        OE_HOLDS_PVT.order_tbl_type;
l_error_count      NUMBER :=0;
j                  INTEGER;
initial            INTEGER;
nextpos            INTEGER;
L_prev_org_id number; -- MOAC
 l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
  l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
--l_record_ids     varchar2(2000) := p_record_ids || ',';
--l_num_of_records number;

l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_msg_token        VARCHAR2(100);
BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_release_holds_orders',1);

  IF check_system_holds( p_hold_id                => p_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_id),1);
    fnd_message.set_name('ONT','ONT_RELEASE');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --   RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;

    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );

    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_release_holds_orders;

  OE_DEBUG_PUB.Add('Release_Reason_Code: '||p_release_reason_code);

  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99)
    THEN
      OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
      Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                    p_org_id      => p_sel_rec_tbl(j).Org_Id);
      l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;
    l_order_tbl(1).header_id := p_sel_rec_tbl(j).Id1;

  OE_DEBUG_PUB.Add('B4 Calling oe_holds_pvt.release_holds 4 HeaderID' || l_order_tbl(1).header_id);
  oe_holds_pvt.release_holds(
          p_order_tbl        =>  l_order_tbl,
          p_hold_id          =>  p_hold_id,
          p_release_reason_code  =>  p_release_reason_code,
          p_release_comment      =>  p_release_comment,
          p_check_authorization_flag => 'N' ,   -- bug 8477694
          x_return_status    =>  x_return_status,
          x_msg_count        =>  x_msg_count,
          x_msg_data         =>  x_msg_data
                           );

    OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,2);
    OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),2);
    OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data,2);

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add('process_release_holds_orders unexpected failure',3);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add('process_release_holds_orders failure',3);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  END LOOP;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_release_holds_orders',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_orders;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_orders;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_release_holds_orders;


end process_release_holds_orders;

/*******************************/
/* process_create_source       */
/*******************************/
/* This procedure gets called when Create Holds Source is selected
   from the special menu.
*/
procedure process_create_source(
		p_hold_source_rec    IN OE_HOLDS_PVT.Hold_Source_Rec_Type
         ,p_hold_existing_flg  IN varchar2
         ,p_hold_future_flg    IN varchar2
         ,p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id  --ER#7479609
         ,x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2
         ,x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER
         ,x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                                        )
IS
 l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_hold_release_rec   OE_HOLDS_PVT.hold_release_rec_type;
 l_hold_release_id oe_hold_releases.HOLD_RELEASE_ID%type;
 l_api_name         CONSTANT VARCHAR2(30) := 'process_create_holds';
 l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 l_msg_token        VARCHAR2(100);
 /*Added the following variables for WF_HOLDS ER (bug 6449458)*/
 l_item_type       OE_HOLD_DEFINITIONS.ITEM_TYPE%TYPE  := NULL;
 l_activity_name   OE_HOLD_DEFINITIONS.ACTIVITY_NAME%TYPE := NULL;
 l_is_hold_applied BOOLEAN;
 l_count_of_holds_applied NUMBER := 0;

--
BEGIN
  oe_debug_pub.add('In process_create_holds', 1);
  oe_msg_pub.initialize;  --bug 5548778
  l_hold_source_rec := p_hold_source_rec;

if check_system_holds( p_hold_id                => l_hold_source_rec.hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
   OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(l_hold_source_rec.hold_id));
     fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
     OE_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;

  if check_authorization ( p_hold_id                => l_hold_source_rec.hold_id
                          ,p_authorized_action_code => 'APPLY'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
     OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'||
					    to_char(l_hold_source_rec.hold_id));

     fnd_message.set_name('ONT','ONT_APPLY');
     l_msg_token := fnd_message.get;

     fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
     fnd_message.set_token('ACTION', l_msg_token);

     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;


  oe_debug_pub.add('p_hold_existing_flg->' || p_hold_existing_flg,3);
  oe_debug_pub.add('p_hold_future_flg->' || p_hold_future_flg,3);
/*added the select statement for WF_HOLDS ER (bug 6449458)*/
        select item_type, activity_name
        into   l_item_type, l_activity_name
        from   oe_hold_definitions
        where  hold_id = l_hold_source_rec.hold_id;

  if (p_hold_existing_flg = 'Y' AND p_hold_future_flg = 'Y') then
    oe_debug_pub.add('Calling oe_holds_pvt.apply_Holds',3);
    /*oe_holds_pvt.apply_Holds(
       p_hold_source_rec     =>  l_hold_source_rec
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data
                  );*/
    /*Calling Overloaded Apply_hold Procedure for WF_HOLDS ER (bug 6449458)*/
     oe_holds_pvt.apply_Holds(
       p_hold_source_rec     =>  l_hold_source_rec
      ,p_hold_existing_flg   =>  'Y'
      ,p_hold_future_flg     =>  'Y'
      ,p_org_id => p_org_id  --ER#7479609
      ,p_wf_item_type        =>  l_item_type
      ,p_wf_activity_name    =>  l_activity_name
      ,x_return_status       =>  x_return_status
      ,x_msg_count           =>  x_msg_count
      ,x_msg_data            =>  x_msg_data
      ,x_is_hold_applied     => l_is_hold_applied
                              );

    OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,2);
    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         oe_debug_pub.add('process_create_holds unexpected failure',1);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         oe_debug_pub.add('process_create_holds expected failure',1);
         RAISE FND_API.G_EXC_ERROR;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;
  elsif (p_hold_existing_flg = 'Y' AND p_hold_future_flg = 'N') then
    -- Create_Hold_Source (Create the Hold Source)
    -- Create_Order_Holds (Put the existing Orders on Hold)
    -- Create_Release_Source (Release the source.Do not release orders from hold)
    oe_debug_pub.add('Calling Create_Hold_Source',3);
    Create_Hold_Source (
       p_hold_source_rec => l_hold_source_rec,
       p_org_id =>p_org_id,    --ER#7479609
       x_hold_source_id  => l_hold_source_id,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data
                   );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
    OE_DEBUG_PUB.Add('l_hold_source_id->' || to_char(l_hold_source_id) ,3);
    l_hold_source_rec.hold_source_id := l_hold_source_id;
    OE_DEBUG_PUB.Add ('Calling Create_Order_Holds',3);
    Create_Order_Holds (
         p_hold_source_rec     =>  l_hold_source_rec
        ,p_org_id =>p_org_id    --ER#7479609
        ,x_return_status       =>  x_return_status
        ,x_msg_count           =>  x_msg_count
        ,x_msg_data            =>  x_msg_data
                       );
    OE_DEBUG_PUB.Add('After Create_Order_Holds',3);
    -- XX Should be a new reason code
    l_hold_release_rec.hold_source_id      := l_hold_source_id;
    l_hold_release_rec.release_reason_code := 'EXPIRE';
    l_hold_release_rec.release_comment     := 'Released automatically by System';
    oe_debug_pub.add('Calling Create_Release_Source',3);
    OE_HOLDS_PVT.Create_Release_Source(p_hold_release_rec => l_hold_release_rec,
                                       x_hold_release_id  => l_hold_release_id,
                                       x_return_status    => x_return_status,
                                       x_msg_count        => x_msg_count,
                                       x_msg_data         => x_msg_data);
    OE_DEBUG_PUB.Add('Create_Order_Holds Status' || x_return_status,3);

  elsif (p_hold_existing_flg = 'N' AND p_hold_future_flg = 'Y') then
    -- call create_hold_source for only future holds to go on hold.
    OE_DEBUG_PUB.Add('Calling Create_Hold_Source',3);
    Create_Hold_Source (
        p_hold_source_rec => l_hold_source_rec,
        p_org_id =>p_org_id,    --ER#7479609
        x_hold_source_id  => l_hold_source_id,
        x_return_status   => x_return_status,
        x_msg_count       => x_msg_count,
        x_msg_data        => x_msg_data
                       );
    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	    RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
    END IF;
  else
     -- Should not get here
	oe_debug_pub.add ('Both of Hold Future and Existing Flag are unset',3);
	oe_debug_pub.add ('Do nothing',3);
  end if; -- (p_hold_existing_flg = 'Y' AND p_hold_future_flg 'Y')
   --  Get message count and data

   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);


end process_create_source;


/*******************************/
/* process_release_source       */
/*******************************/
/* This procedure gets called when Release Source button is pressed
   from the Release Source window.
*/
procedure process_release_source(
        p_hold_source_id       IN OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE
	  ,p_hold_release_rec     IN OE_HOLDS_PVT.Hold_Release_Rec_Type
       ,x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
       ,x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
       ,x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                                        )
IS
  l_hold_source_rec  OE_HOLDS_PVT.Hold_Source_Rec_Type;
  l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;
  l_api_name         CONSTANT VARCHAR2(30) := 'process_release_source';
  l_hold_id        OE_HOLD_DEFINITIONS.HOLD_ID%TYPE;
 l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 --ER#7479609 l_hold_entity_code varchar2(1); /* Added for Bug 1946783 */
 l_hold_entity_code  OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE;  --ER#7479609
 l_msg_token        VARCHAR2(100);
BEGIN

  BEGIN
    select hold_id, hold_entity_code
      into l_hold_id, l_hold_entity_code
      from OE_HOLD_SOURCES_all
     where hold_source_id = p_hold_source_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         null;
  END;


/* Bug 1946783 - Added Check for credit hold created from AR */

  If l_hold_id = 1 AND (l_hold_entity_code ='C' OR l_hold_entity_code = 'B') then
    OE_DEBUG_PUB.Add('Bug 1946783 Credit Hold should be released from AR',1);

     fnd_message.set_name('ONT', 'OE_CC_AR_HOLD_NOT_RELEASED');
     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
  return;
 end if;

/* End of code added for Bug 1946783 */


if check_system_holds( p_hold_id                => l_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
   OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(l_hold_id));
     fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
     fnd_message.set_token('ACTION', 'Release');
     OE_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;

  if check_authorization ( p_hold_id                => l_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
     OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(l_hold_id));

     fnd_message.set_name('ONT','ONT_RELEASE');
     l_msg_token := fnd_message.get;

     fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
     fnd_message.set_token('ACTION', l_msg_token);

     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;

  l_hold_source_rec.hold_source_id    := p_hold_source_id;
  l_hold_release_rec                  := p_hold_release_rec;
  --l_hold_release_rec.RELEASE_REASON_CODE := p_release_reason_code;
  --l_hold_release_rec.RELEASE_COMMENT     := p_release_comment;

  oe_holds_pvt.Release_Holds(
     p_hold_source_rec     =>  l_hold_source_rec
    ,p_hold_release_rec    =>  l_hold_release_rec
    ,p_check_authorization_flag => 'N'    -- bug 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );
   OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,1);

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         oe_debug_pub.add('process_release_source unexpected failure',3);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         oe_debug_pub.add('process_release_source expected failure',3);
         RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);

end process_release_source;

/* ========================================== */
/* Overloaded procedures for ER 1373910 begin */
/* ========================================== */

/*
NAME :
       process_release_holds_lines
BRIEF DESCRIPTION  :
       This API is called when workflow based hold on lines is released from
       the sales order form.
CALLER :
       1. Oe_holds_release_window.action_release
RELEASE LEVEL :
       12.1.1 and higher.
PARAMETERS :
       p_num_of_records       Number of records affected by the hold release.
       p_sel_rec_tbl          Table of lines affected by hold release.
       p_hold_id              Hold being released
       p_release_reason_code  Hold release reason code
       p_release_comment      Hold release comments
       p_wf_release_action    Decides if workflow is to be progressed if hold
                              being released is workflow based.
       x_return_status        Return status
*/

procedure process_release_holds_lines (
  p_num_of_records      IN NUMBER
, p_sel_rec_tbl         IN OE_GLOBALS.Selected_Record_Tbl
, p_hold_id             IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_release_reason_code IN OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
, p_release_comment     IN OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
, p_wf_release_action   IN VARCHAR2
, x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS

--l_header_rec     OE_ORDER_PUB.Header_Rec_Type;
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'process_release_holds_lines';
l_line_id          NUMBER;
l_return_status    VARCHAR2(30);
l_order_tbl        OE_HOLDS_PVT.order_tbl_type;
l_error_count      NUMBER :=0;
l_ordered_quantity NUMBER ;
j                  INTEGER;
initial            INTEGER;
nextpos            INTEGER;

l_prev_org_id number;
l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
l_application_id   OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
l_resp_id          OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
l_msg_token        VARCHAR2(100);
BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_release_holds_lines',1);

  IF check_system_holds( p_hold_id                => p_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'||to_char(p_hold_id));
    fnd_message.set_name('ONT','ONT_RELEASE');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --   RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_release_holds_lines;

  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99)
    THEN
       OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
       Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                     p_org_id      => p_sel_rec_tbl(j).Org_Id);
       l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;

    L_line_id := p_sel_rec_tbl(j).id1;
    OE_LINE_UTIL.Query_Row
       ( p_line_id  => l_line_id,
         x_line_rec => l_line_rec
        );
    OE_DEBUG_PUB.Add('header_id: '||l_line_rec.header_id);
    OE_DEBUG_PUB.Add('Line_id: '||to_char(l_line_rec.line_id));
    l_order_tbl(1).header_id := l_line_rec.header_id;
    l_order_tbl(1).line_id := l_line_rec.line_id;


    OE_DEBUG_PUB.Add('B4 Calling oe_holds_pvt.release_holds:HeaderID'
                     || l_order_tbl(1).header_id || ', LineID:' || l_order_tbl(1).line_id);
    oe_holds_pvt.release_holds(
          p_order_tbl        =>  l_order_tbl,
          p_hold_id          =>  p_hold_id,
          p_release_reason_code  =>  p_release_reason_code,
          p_release_comment      =>  p_release_comment,
          p_check_authorization_flag => 'N' ,   -- bug 8477694
          x_return_status    =>  x_return_status,
          x_msg_count        =>  x_msg_count,
          x_msg_data         =>  x_msg_data
                           );

    OE_DEBUG_PUB.Add('After oe_holds_pvt.release_holds:' || x_return_status,3);

    -- Changes begin : ER 1373910
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN

        IF p_wf_release_action = 'Y' THEN
              OE_DEBUG_PUB.Add('Before calling Oe_holds_pvt.progress_order');
              progress_order( p_hold_id,
	                      p_num_of_records,
                              l_order_tbl,
                              x_return_status,
			      x_msg_count,
                              x_msg_data );
              OE_DEBUG_PUB.Add('After Oe_holds_pvt.progress_order : ' || x_return_status,3);
        END IF;
    END IF;
    -- Changes End : ER 1373910

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add('process_release_holds_lines unexpected failure',3);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add('process_release_holds_lines failure',3);
      RAISE FND_API.G_EXC_ERROR;
    END IF;

  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
  OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_release_holds_lines',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_release_holds_lines;

end process_release_holds_lines;

/*
NAME :
       process_release_holds_orders
BRIEF DESCRIPTION  :
       This API is called when workflow based hold on orders is released from
       the sales order form.
CALLER :
       1. Oe_holds_release_window.action_release
RELEASE LEVEL :
       12.1.1 and higher.
PARAMETERS :
       p_num_of_records       Number of records affected by the hold release.
       p_sel_rec_tbl          Table of orders affected by hold release.
       p_hold_id              Hold being released
       p_release_reason_code  Hold release reason code
       p_release_comment      Hold release comments
       p_wf_release_action    Decides if workflow is to be progressed if hold
                              being released is workflow based.
       x_return_status        Return status
*/

procedure process_release_holds_orders (
  p_num_of_records      IN NUMBER
, p_sel_rec_tbl         IN OE_GLOBALS.Selected_Record_Tbl
, p_hold_id             IN OE_HOLD_DEFINITIONS.HOLD_ID%TYPE
, p_release_reason_code IN OE_HOLD_RELEASES.RELEASE_REASON_CODE%TYPE
, p_release_comment     IN OE_HOLD_RELEASES.RELEASE_COMMENT%TYPE
, p_wf_release_action   IN VARCHAR2
, x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2
, x_msg_count           OUT NOCOPY /* file.sql.39 change */ NUMBER
, x_msg_data            OUT NOCOPY /* file.sql.39 change */ VARCHAR2
)
IS
l_line_rec         OE_ORDER_PUB.line_rec_type;
l_api_name         CONSTANT VARCHAR2(30) := 'process_release_holds_orders';
l_header_id        NUMBER;
l_return_status    VARCHAR2(30);
l_order_tbl        OE_HOLDS_PVT.order_tbl_type;
l_error_count      NUMBER :=0;
j                  INTEGER;
initial            INTEGER;
nextpos            INTEGER;
l_prev_org_id number; -- MOAC
l_hold_source_rec OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_release_rec  OE_HOLDS_PVT.Hold_Release_Rec_Type;
--l_record_ids     varchar2(2000) := p_record_ids || ',';
--l_num_of_records number;

l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
l_msg_token        VARCHAR2(100);
BEGIN
  oe_msg_pub.initialize;

  OE_DEBUG_PUB.Add('Entering OE_Holds_PVT.process_release_holds_orders',1);

  IF check_system_holds( p_hold_id                => p_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_id));
    fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
    OE_MSG_PUB.ADD;
    x_return_status := FND_API.G_RET_STS_ERROR;
    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_System_Holds');

  IF check_authorization ( p_hold_id                => p_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
    OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(p_hold_id),1);
    fnd_message.set_name('ONT','ONT_RELEASE');
    l_msg_token := fnd_message.get;

    fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
    fnd_message.set_token('ACTION', l_msg_token);

    OE_MSG_PUB.ADD;
    --   RAISE FND_API.G_EXC_ERROR;
    x_return_status := FND_API.G_RET_STS_ERROR;

    OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );

    RETURN;
  END IF;

  OE_DEBUG_PUB.Add('After calling Check_Authorization');

  SAVEPOINT process_release_holds_orders;

  OE_DEBUG_PUB.Add('Release_Reason_Code: '||p_release_reason_code);

  l_prev_org_id := null;
  FOR j in 1.. p_sel_rec_tbl.COUNT LOOP
    IF p_sel_rec_tbl(j).org_id <> nvl(l_prev_org_id, -99) THEN
      OE_DEBUG_PUB.Add('Mo_Global.Set_Policy_Context to:' || p_sel_rec_tbl(j).Org_Id );
      Mo_Global.Set_Policy_Context (p_access_mode => 'S',
                                    p_org_id      => p_sel_rec_tbl(j).Org_Id);
      l_prev_org_id := p_sel_rec_tbl(j).org_id;
    END IF;
    l_order_tbl(1).header_id := p_sel_rec_tbl(j).Id1;

    OE_DEBUG_PUB.Add('B4 Calling oe_holds_pvt.release_holds 4 HeaderID' || l_order_tbl(1).header_id);
    oe_holds_pvt.release_holds(
          p_order_tbl        =>  l_order_tbl,
          p_hold_id          =>  p_hold_id,
          p_release_reason_code  =>  p_release_reason_code,
          p_release_comment      =>  p_release_comment,
          p_check_authorization_flag => 'N' ,   -- bug 8477694
          x_return_status    =>  x_return_status,
          x_msg_count        =>  x_msg_count,
          x_msg_data         =>  x_msg_data
                           );

    OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,2);
    OE_DEBUG_PUB.Add('x_msg_count:' || to_char(x_msg_count),2);
    OE_DEBUG_PUB.Add('x_msg_data:' || x_msg_data,2);

    -- Changes begin : ER 1373910
    IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF p_wf_release_action = 'Y' THEN
              OE_DEBUG_PUB.Add('Before calling Oe_holds_pvt.progress_order');
              progress_order( p_hold_id,
	                      p_num_of_records,
                              l_order_tbl,
                              x_return_status,
			      x_msg_count,
			      x_msg_data);
              OE_DEBUG_PUB.Add('After Oe_holds_pvt.progress_order : ' || x_return_status,3);
        END IF;
    END IF;
    -- Changes end : ER 1373910

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      oe_debug_pub.add('process_release_holds_orders unexpected failure',3);
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      oe_debug_pub.add('process_release_holds_orders failure',3);
      RAISE FND_API.G_EXC_ERROR;
    END IF;


  END LOOP;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  --  Get message count and data
  OE_MSG_PUB.Count_And_Get
   (   p_count                       => x_msg_count
   ,   p_data                        => x_msg_data
   );

  OE_DEBUG_PUB.Add('Exiting OE_Holds_PVT.process_release_holds_orders',1);

EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_orders;

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );
        ROLLBACK TO SAVEPOINT process_release_holds_orders;

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);
        ROLLBACK TO SAVEPOINT process_release_holds_orders;


end process_release_holds_orders;

/*
NAME :
       process_release_source
BRIEF DESCRIPTION  :
       This API is called when Release Source button is pressed
       from the Release Source window.
CALLER :
       1. Oe_holds_release_window.create_release_source
RELEASE LEVEL :
       12.1.1 and higher.
PARAMETERS :
       p_hold_source_id       Hold source being released.
       p_hold_release_rec     Hold source release record.
       p_wf_release_action    Decides if workflow is to be progressed if hold
                              source being released is defined on a workflow
			      based hold.
       x_return_status        Return status
*/

procedure process_release_source(
 p_hold_source_id       IN OE_Hold_Sources_ALL.HOLD_SOURCE_ID%TYPE
,p_hold_release_rec     IN OE_HOLDS_PVT.Hold_Release_Rec_Type
,p_wf_release_action    IN VARCHAR2
,x_return_status        OUT NOCOPY /* file.sql.39 change */  VARCHAR2
,x_msg_count            OUT NOCOPY /* file.sql.39 change */  NUMBER
,x_msg_data             OUT NOCOPY /* file.sql.39 change */  VARCHAR2
                                        )
IS
 l_hold_source_rec  OE_HOLDS_PVT.Hold_Source_Rec_Type;
 l_hold_release_rec OE_HOLDS_PVT.Hold_Release_Rec_Type;
 l_api_name         CONSTANT VARCHAR2(30) := 'process_release_source';
 l_hold_id          OE_HOLD_DEFINITIONS.HOLD_ID%TYPE;
 l_application_id   OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE := FND_GLOBAL.RESP_APPL_ID;
 l_resp_id          OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE := FND_GLOBAL.RESP_ID;
 --ER#7479609 l_hold_entity_code VARCHAR2(1); /* Added for Bug 1946783 */
 l_hold_entity_code  OE_HOLD_SOURCES_ALL.HOLD_ENTITY_CODE%TYPE;  --ER#7479609
 l_msg_token        VARCHAR2(100);
BEGIN


  BEGIN
    select hold_id, hold_entity_code
    into l_hold_id, l_hold_entity_code
    from OE_HOLD_SOURCES_all
    where hold_source_id = p_hold_source_id;
  EXCEPTION
     WHEN NO_DATA_FOUND THEN
         null;
  END;

/* Bug 1946783 - Added Check for credit hold created from AR */

  If l_hold_id = 1 AND (l_hold_entity_code ='C' OR l_hold_entity_code = 'B') then
    OE_DEBUG_PUB.Add('Bug 1946783 Credit Hold should be released from AR',1);

     fnd_message.set_name('ONT', 'OE_CC_AR_HOLD_NOT_RELEASED');
     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
  return;
 end if;

/* End of code added for Bug 1946783 */


if check_system_holds( p_hold_id                => l_hold_id
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
   OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(l_hold_id));
     fnd_message.set_name('ONT', 'ONT_HOLDS_SYSTEM_CHECK');
     fnd_message.set_token('ACTION', 'Release');
     OE_MSG_PUB.ADD;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;


  if check_authorization ( p_hold_id                => l_hold_id
                          ,p_authorized_action_code => 'REMOVE'
                          ,p_responsibility_id      => l_resp_id
                          ,p_application_id         => l_application_id
                          ,x_return_status          => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data
                         ) = 'N'  THEN
     OE_DEBUG_PUB.Add('Not authorize to Release this Hold:'|| to_char(l_hold_id));

     fnd_message.set_name('ONT','ONT_RELEASE');
     l_msg_token := fnd_message.get;

     fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
     fnd_message.set_token('ACTION', l_msg_token);

     OE_MSG_PUB.ADD;
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     OE_MSG_PUB.Count_And_Get
           (   p_count     =>      x_msg_count
           ,   p_data      =>      x_msg_data
           );
     return;
  END IF;

  l_hold_source_rec.hold_source_id    := p_hold_source_id;
  l_hold_release_rec                  := p_hold_release_rec;
  --l_hold_release_rec.RELEASE_REASON_CODE := p_release_reason_code;
  --l_hold_release_rec.RELEASE_COMMENT     := p_release_comment;

  oe_holds_pvt.Release_Holds(
     p_hold_source_rec     =>  l_hold_source_rec
    ,p_hold_release_rec    =>  l_hold_release_rec
    ,p_check_authorization_flag => 'N'    -- bug 8477694
    ,x_return_status       =>  x_return_status
    ,x_msg_count           =>  x_msg_count
    ,x_msg_data            =>  x_msg_data
                  );


   OE_DEBUG_PUB.Add('x_return_status:' || x_return_status,1);

   -- Changes begin : ER 1373910
   IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        IF p_wf_release_action = 'Y' THEN
            Oe_debug_pub.Add('Before calling Oe_holds_pvt.progress_order');
            progress_order( p_hold_source_id,
                            x_return_status,
			    x_msg_count,
			    x_msg_data);
            Oe_debug_pub.ADD('Oe_holds_pvt.progress order returned with : ' || x_return_status);
        END IF;
   END IF;
   -- Changes end : ER 1373910

   IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         oe_debug_pub.add('process_release_source unexpected failure',3);
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
         oe_debug_pub.add('process_release_source expected failure',3);
         RAISE FND_API.G_EXC_ERROR;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   --  Get message count and data
   OE_MSG_PUB.Count_And_Get
    (   p_count                       => x_msg_count
    ,   p_data                        => x_msg_data
    );


EXCEPTION  /* Procedure exception handler */

 WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data
            );

 WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
             OE_MSG_PUB.Add_Exc_Msg
                    (G_PKG_NAME,
                     l_api_name
                );
        END IF;
        OE_MSG_PUB.Count_And_Get
            ( p_count => x_msg_count,
              p_data  => x_msg_data);

end process_release_source;

/* ========================================== */
/* Overloaded procedures for ER 1373910 end */
/* ========================================== */


------------------------------------
-- SPLIT_HOLDS                    --
------------------------------------
procedure split_hold (
     p_line_id            IN   NUMBER,
     p_split_from_line_id IN   NUMBER,
     x_return_status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
     x_msg_count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
     x_msg_data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2
   )
IS
 l_user_id      NUMBER;
 l_org_id       NUMBER;
 l_api_name     CONSTANT VARCHAR2(30) := 'SPLIT_HOLD';

 l_line_number  NUMBER;
 l_hold_source_id OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
 l_hold_source_rec       OE_HOLDS_PVT.Hold_Source_Rec_Type;

 CURSOR c_order_holds IS
   SELECT oh.HOLD_SOURCE_ID
      ,   oh.HEADER_ID
      ,   hs.hold_entity_code
      ,   hs.hold_id
      ,   hs.hold_until_date
      ,   hs.hold_comment
        , hs.CONTEXT
        , hs.ATTRIBUTE1
        , hs.ATTRIBUTE2
        , hs.ATTRIBUTE3
        , hs.ATTRIBUTE4
        , hs.ATTRIBUTE5
        , hs.ATTRIBUTE6
        , hs.ATTRIBUTE7
        , hs.ATTRIBUTE8
        , hs.ATTRIBUTE9
        , hs.ATTRIBUTE10
        , hs.ATTRIBUTE11
        , hs.ATTRIBUTE12
        , hs.ATTRIBUTE13
        , hs.ATTRIBUTE14
        , hs.ATTRIBUTE15
        , oh.org_id
    FROM OE_ORDER_HOLDS_all oh,
         OE_HOLD_SOURCES_all hs
   WHERE oh.line_id = p_split_from_line_id
    AND  oh.RELEASED_FLAG = 'N'
    AND  OH.HOLD_SOURCE_ID = HS.HOLD_SOURCE_ID;


BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 l_user_id := OE_HOLDS_PVT.get_user_id;
 l_org_id := OE_GLOBALS.G_ORG_ID;
 if l_org_id IS NULL THEN
   OE_GLOBALS.Set_Context;
   l_org_id := OE_GLOBALS.G_ORG_ID;
 end if;

  for c_rec IN c_order_holds
  loop
    IF c_rec.HOLD_ENTITY_CODE = 'O' THEN
       l_hold_source_rec.hold_entity_code := c_rec.HOLD_ENTITY_CODE;
       l_hold_source_rec.hold_entity_id := c_rec.header_id;
       l_hold_source_rec.line_id := p_line_id;
       l_hold_source_rec.hold_id := c_rec.hold_id;
       l_hold_source_rec.hold_until_date := c_rec.hold_until_date;
       l_hold_source_rec.hold_comment := c_rec.hold_comment;
       l_hold_source_rec.CONTEXT := c_rec.CONTEXT;
       l_hold_source_rec.ATTRIBUTE1 := c_rec.ATTRIBUTE1;
       l_hold_source_rec.ATTRIBUTE2 := c_rec.ATTRIBUTE2;
       l_hold_source_rec.ATTRIBUTE3 := c_rec.ATTRIBUTE3;
       l_hold_source_rec.ATTRIBUTE4 := c_rec.ATTRIBUTE4;
       l_hold_source_rec.ATTRIBUTE5 := c_rec.ATTRIBUTE5;
       l_hold_source_rec.ATTRIBUTE6 := c_rec.ATTRIBUTE6;
       l_hold_source_rec.ATTRIBUTE7 := c_rec.ATTRIBUTE7;
       l_hold_source_rec.ATTRIBUTE8 := c_rec.ATTRIBUTE8;
       l_hold_source_rec.ATTRIBUTE9 := c_rec.ATTRIBUTE9;
       l_hold_source_rec.ATTRIBUTE10 := c_rec.ATTRIBUTE10;
       l_hold_source_rec.ATTRIBUTE11 := c_rec.ATTRIBUTE11;
       l_hold_source_rec.ATTRIBUTE12 := c_rec.ATTRIBUTE12;
       l_hold_source_rec.ATTRIBUTE13 := c_rec.ATTRIBUTE13;
       l_hold_source_rec.ATTRIBUTE14 := c_rec.ATTRIBUTE14;
       l_hold_source_rec.ATTRIBUTE15 := c_rec.ATTRIBUTE15;
       l_hold_source_rec.org_id      := c_rec.org_id;

     oe_holds_pvt.Create_Hold_Source (
                  p_hold_source_rec => l_hold_source_rec,
                  p_org_id =>l_org_id,    --ER#7479609
                  x_hold_source_id  => l_hold_source_id,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data
                           );
       --l_hold_source_rec.hold_source_id := l_hold_source_id;
    ELSE
      l_hold_source_id := c_rec.hold_source_id;
      --l_hold_source_rec.hold_source_id := c_rec.hold_source_id;
    END IF;

    INSERT INTO OE_ORDER_HOLDS_all
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    VALUES (
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  l_user_id
     ,  SYSDATE
     ,  l_user_id
     ,  NULL
     ,  l_HOLD_SOURCE_ID
     ,  c_rec.HEADER_ID
     ,  p_line_id
     ,  'N'
     ,  c_rec.org_id);

  end loop;

 exception
    WHEN NO_DATA_FOUND then
      null; -- its ok if there is not holds on the orignal line
    WHEN FND_API.G_EXC_ERROR THEN
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF OE_MSG_PUB.Check_Msg_Level
            (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
               ( G_PKG_NAME,
                 l_api_name);
        END IF;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END split_hold;

/*Added Overloaded procedure apply_holds for WF_HOLDS ER (bug 6449458)*/
Procedure Apply_Holds(
  p_hold_source_rec     IN  OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_hold_existing_flg   IN  VARCHAR2,
  p_hold_future_flg     IN  VARCHAR2,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
  p_wf_item_type IN  VARCHAR2 DEFAULT NULL,
  p_wf_activity_name IN  VARCHAR2 DEFAULT NULL,
  p_check_authorization_flag IN VARCHAR2 DEFAULT 'N', --bug 8477694
  x_return_status       OUT NOCOPY VARCHAR2,
  x_msg_count           OUT NOCOPY NUMBER,
  x_msg_data            OUT NOCOPY VARCHAR2,
  x_is_hold_applied     OUT NOCOPY BOOLEAN )

IS

l_application_id  OE_HOLD_AUTHORIZATIONS.APPLICATION_ID%TYPE :=
                                         FND_GLOBAL.RESP_APPL_ID;
l_resp_id         OE_HOLD_AUTHORIZATIONS.RESPONSIBILITY_ID%TYPE
                                           := FND_GLOBAL.RESP_ID;
l_hold_source_id  OE_HOLD_SOURCES_ALL.HOLD_SOURCE_ID%TYPE;
l_hold_source_rec       OE_HOLDS_PVT.Hold_Source_Rec_Type;
l_hold_exists      VARCHAR2(1) :='N'; --bug 5548778
l_msg_token        VARCHAR2(100);  --8477694

l_is_hold_applied BOOLEAN;

BEGIN

  OE_DEBUG_PUB.Add('In OE_Holds_pvt.Apply Holds, Creating Hold Source',1);

  x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- 8477694

  IF NOT OE_GLOBALS.G_SYS_HOLD THEN
    IF check_system_holds(
       p_hold_id           => p_hold_source_rec.hold_id,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data) = 'N' THEN

      OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_source_rec.hold_id));
      l_msg_token := 'APPLY(System Hold)';
      fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
      fnd_message.set_token('ACTION', l_msg_token);
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
      RETURN;
    END IF;
   END IF;
    OE_DEBUG_PUB.Add('After calling Check_System_Holds');

    OE_DEBUG_PUB.Add('Apply Hold overloaded before calling Check_Authorization');

    --bug 8477694
    IF p_check_authorization_flag = 'Y'  THEN
          OE_DEBUG_PUB.Add('8477694 Manual Auth'||p_check_authorization_flag);
    ELSE
          OE_DEBUG_PUB.Add('8477694 Auto Auth'||p_check_authorization_flag);
    END IF;

   IF p_check_authorization_flag = 'Y'  THEN -- bug 8477694
    IF check_authorization ( p_hold_id                => p_hold_source_rec.hold_id
                            ,p_authorized_action_code => 'APPLY'
                            ,p_responsibility_id      => l_resp_id
                            ,p_application_id         => l_application_id
                            ,x_return_status          => x_return_status
                            ,x_msg_count              => x_msg_count
                            ,x_msg_data               => x_msg_data
                           ) = 'N'  THEN
      OE_DEBUG_PUB.Add('Not authorize to Apply this Hold:'|| to_char(p_hold_source_rec.hold_id));
      fnd_message.set_name('ONT','ONT_APPLY');
      l_msg_token := fnd_message.get;
      fnd_message.set_name('ONT', 'OE_HOLDS_AUTHORIZATION_FAILED');
      fnd_message.set_token('ACTION', l_msg_token);
      OE_MSG_PUB.ADD;
      x_return_status := FND_API.G_RET_STS_ERROR;
      OE_MSG_PUB.Count_And_Get
             (   p_count     =>      x_msg_count
             ,   p_data      =>      x_msg_data
             );
      RETURN;
    END IF;
   END IF; --bug 8477694
    OE_DEBUG_PUB.Add('Apply Hold overloaded  After calling Check_Authorization');
  --8477694


  l_hold_source_rec := p_hold_source_rec;

  Validate (p_hold_source_rec  => p_hold_source_rec,
              x_return_status    => x_return_status,
              x_msg_count        => x_msg_count,
              x_msg_data         => x_msg_data );
 OE_DEBUG_PUB.Add('Validate return status:' || x_return_status,1);

 IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
   OE_Debug_PUB.Add('Validate not successful',1);
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
 ELSE
   OE_DEBUG_PUB.Add ('Calling Create_Hold_Source bug 5548778 overload',1);
   Create_Hold_Source (
                  p_hold_source_rec => p_hold_source_rec,
                  p_org_id =>  p_org_id,  --ER#7479609
		  x_hold_source_id  => l_hold_source_id,
    		  x_hold_exists  => l_hold_exists,
                  x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data);

   OE_DEBUG_PUB.Add('x_return_status->' || x_return_status,1);
        OE_DEBUG_PUB.Add('x_msg_count->' || x_msg_count,1);
        OE_DEBUG_PUB.Add('x_msg_data' || x_msg_data,1);
        OE_DEBUG_PUB.Add('l_hold_exists' || l_hold_exists,1);
        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
	        RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
        END IF;

   OE_DEBUG_PUB.Add('l_hold_source_id->' ||
                                   to_char(l_hold_source_id) ,1);
   l_hold_source_rec.hold_source_id := l_hold_source_id;
   --bug 5548778

   IF l_hold_exists = 'N' THEN
     IF p_wf_item_type IS NOT NULL AND p_wf_activity_name IS NOT
                                                        NULL THEN
       OE_DEBUG_PUB.Add ('Calling Overloaded Create_Order_Holds Based on Workflow',1);
       Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,p_org_id =>  p_org_id  --ER#7479609
         ,p_item_type           =>  p_wf_item_type
         ,p_activity_name       =>  p_wf_activity_name
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
         ,x_is_hold_applied     =>  l_is_hold_applied);

     ELSE
       OE_DEBUG_PUB.Add ('Calling Create_Order_Holds',1);
       Create_Order_Holds (
          p_hold_source_rec     =>  l_hold_source_rec
         ,p_org_id =>p_org_id    --ER#7479609
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data);

     END IF; -- l_item_type and l_activity_name

     x_is_hold_applied := l_is_hold_applied;

     OE_DEBUG_PUB.Add('After Create_Order_Holds',1);
   END IF;
 END IF;

END Apply_Holds;

/*Added New Overloaded Procedure Create_Order_hols for WF_HOLDS ER (bug 6449458)*/
Procedure Create_Order_Holds(
  p_hold_source_rec       IN   OE_HOLDS_PVT.Hold_Source_Rec_Type,
  p_org_id IN NUMBER  DEFAULT  MO_GLOBAL.get_current_org_id,  --ER#7479609
  p_item_type      IN VARCHAR2,
  p_activity_name  IN VARCHAR2,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2,
  x_is_hold_applied OUT NOCOPY BOOLEAN)

IS
 l_user_id      NUMBER;
 l_org_id       NUMBER;
 l_api_name     CONSTANT VARCHAR2(30) := 'Create_Order_Holds';
 l_site_use_code     VARCHAR2(30);
 l_act_status VARCHAR2(30):= 'COMPLETE';
 l_additional_where_clause VARCHAR2(30) := 'XXX';
 l_hold_entity_where_clause VARCHAR2(1000);  --ER#7479609
 l_sqlmt VARCHAR2(3000);
 l_parent_count NUMBER;
 l_user_activity_name     VARCHAR2(80);
 l_activity_name  VARCHAR2(80);
 l_sql_rowcount NUMBER;
 -- GENESIS --
 l_check_hold   VARCHAR2(1) := 'N';

 --ER#7479609 start
 TYPE line_id_tab is TABLE OF NUMBER INDEX BY binary_integer;
 l_line_id_tab	line_id_tab;
 --ER#7479609 end

 /*ER#7479609
 CURSOR check_line_hold_type_cur(p_line_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_order_holds ooh,
                       oe_hold_sources ohs,
                       oe_hold_definitions ohd,
                       oe_order_headers_all h,
                       oe_order_sources oos
                WHERE  ohd.hold_id = ohs.hold_id
--		AND    ohd.activity_name IS NULL    Bug 6791587
                AND    ooh.header_id = h.header_id
                AND    h.order_source_id = oos.order_source_id
                AND    oos.aia_enabled_flag = 'Y'
                AND    ohs.hold_source_id = ooh.hold_source_id
                AND    ooh.line_id = p_line_id);

 CURSOR check_hdr_hold_type_cur(p_hdr_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_order_holds ooh,
                       oe_hold_sources ohs,
                       oe_hold_definitions ohd,
                       oe_order_headers_all h,
                       oe_order_sources oos
                 WHERE  ohd.hold_id = ohs.hold_id
--		 AND    ohd.activity_name IS NULL Bug 6791587
                 AND    h.order_source_id = oos.order_source_id
                 AND    oos.aia_enabled_flag = 'Y'
                 AND    ooh.header_id = h.header_id
                 AND    ohs.hold_source_id = ooh.hold_source_id
                 AND    ooh.header_id = p_hdr_id);

 CURSOR check_src_hold_type_cur(p_hld_src_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_hold_sources ohs,
                       oe_hold_definitions ohd
  WHERE  ohd.hold_id = ohs.hold_id
--AND    ohd.activity_name IS NULL  Bug 6791587
  AND    ohs.hold_source_id = p_hld_src_id);
ER#7479609*/

--ER#7479609 start
 CURSOR check_line_hold_type_cur(p_line_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_order_holds_all ooh,
                       oe_hold_sources_all ohs,
                       oe_hold_definitions ohd,
                       oe_order_headers_all h,
                       oe_order_sources oos
                WHERE  ohd.hold_id = ohs.hold_id
                AND    ooh.header_id = h.header_id
                AND    ooh.org_id = p_org_id
                AND    ooh.org_id = ohs.org_id
                AND    ooh.org_id = h.org_id
                AND    h.order_source_id = oos.order_source_id
                AND    oos.aia_enabled_flag = 'Y'
                AND    ohs.hold_source_id = ooh.hold_source_id
                AND    ooh.line_id = p_line_id);

 CURSOR check_hdr_hold_type_cur(p_hdr_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_order_holds_all ooh,
                       oe_hold_sources_all ohs,
                       oe_hold_definitions ohd,
                       oe_order_headers_all h,
                       oe_order_sources oos
                 WHERE  ohd.hold_id = ohs.hold_id
                 AND    ooh.org_id = p_org_id
                 AND    ooh.org_id = ohs.org_id
                 AND    ooh.org_id = h.org_id
                 AND    h.order_source_id = oos.order_source_id
                 AND    oos.aia_enabled_flag = 'Y'
                 AND    ooh.header_id = h.header_id
                 AND    ohs.hold_source_id = ooh.hold_source_id
                 AND    ooh.header_id = p_hdr_id);

 CURSOR check_src_hold_type_cur(p_hld_src_id IN NUMBER) IS
  SELECT 'Y'
  FROM DUAL
  WHERE EXISTS (SELECT NULL
                FROM   oe_hold_sources_all ohs,
                       oe_hold_definitions ohd
  WHERE  ohd.hold_id = ohs.hold_id
  AND    ohs.org_id = p_org_id
  AND    ohs.hold_source_id = p_hld_src_id);
--ER#7479609 end

 l_header_rec        OE_Order_PUB.Header_Rec_Type;
 l_line_rec          OE_Order_PUB.Line_Rec_Type;
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
-- GENESIS --
BEGIN
 x_return_status := FND_API.G_RET_STS_SUCCESS;
 l_user_id := OE_HOLDS_PVT.get_user_id;
 l_org_id := MO_GLOBAL.get_current_org_id;
 x_is_hold_applied := NULL;
 IF l_org_id IS NULL THEN
         -- org_id is null, raise an error.
         oe_debug_pub.add('Org_Id is NULL',1);
         x_return_status := FND_API.G_RET_STS_ERROR;
         FND_MESSAGE.SET_NAME('FND','MO_ORG_REQUIRED');
         FND_MSG_PUB.ADD;
         RAISE FND_API.G_EXC_ERROR;
 END IF;

  oe_debug_pub.add('p_hold_source_rec.hold_source_id:' ||
                 p_hold_source_rec.hold_source_id);
  oe_debug_pub.add('Hold_entity_code/Hold_entity_id/' ||
                   'Hold_entity_code2/Hold_entity_id2:' ||
                    p_hold_source_rec.Hold_entity_code || '/' ||
                    p_hold_source_rec.Hold_entity_id   || '/' ||
                    p_hold_source_rec.Hold_entity_code2 || '/' ||
                    p_hold_source_rec.Hold_entity_id2);
  oe_debug_pub.add('p_hold_source_rec.header_id:' || p_hold_source_rec.header_id);
  oe_debug_pub.add('p_hold_source_rec.line_id:' || p_hold_source_rec.line_id);
  oe_debug_pub.add('Org Id:' || p_org_id);
-- Insert a hold record for the order header or the order line.
  IF p_item_type = 'OEOH' and p_activity_name = 'CLOSE_ORDER' THEN
  l_activity_name := 'CLOSE_HEADER';
  ELSIF p_item_type = 'OEOL' and p_activity_name = 'PICK_LINE' THEN
  l_activity_name := 'SHIP_LINE';
  l_additional_where_clause := 'PICK_TRUE';
  ELSIF p_item_type = 'OEOL' and p_activity_name = 'PACK_LINE' THEN
  l_activity_name := 'SHIP_LINE';
  l_additional_where_clause := 'PACK_TRUE';
  ELSE
  l_activity_name := p_activity_name;
  END IF;

  /*********************************************************
    HOLD CRITERIA 1 : ITEM
   *********************************************************/
   IF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'C' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      oe_debug_pub.add('Calling InsertTable_OOH_Line for I and C');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      oe_debug_pub.add('After Calling InsertTable_OOH_Line for I and C');
      --ER#7479609 end


 /*ER#7479609 start
 IF p_hold_source_rec.line_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       --and nvl(h.CANCELLED_FLAG, ''N'') = ''N''
       and h.SOLD_TO_ORG_ID = :hold_entity_id2
       and h.header_id = ol.header_id
       and h.header_id = :l_org_id  --ER#7479609
       and ol.line_id = :line_id
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id = :hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

          IF l_additional_where_clause = 'PICK_TRUE' THEN
               l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                                     where w.source_line_id = ol.line_id
                                                     and   w.source_code = ''OE''
                                                     and   w.released_status in (''Y'', ''C''))';
          ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
          l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                                where  wdd.source_line_id = ol.LINE_ID
                                                and    wdd.source_code = ''OE''
                                                and    wda.delivery_detail_id = wdd.delivery_detail_id
                                                and    wda.parent_delivery_detail_id is not null)';
          END IF;
    IF p_item_type is null and p_activity_name is null then
    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id,  p_hold_source_rec.hold_entity_id2,p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	 ELSE
    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_hold_source_rec.hold_entity_id2,p_org_id , p_hold_source_rec.line_id,
p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;

      IF sql%rowcount = 0 THEN
       x_is_hold_applied := FALSE;
      ELSIF sql%rowcount = 1 THEN
       x_is_hold_applied := TRUE;
      END IF;
	END IF;

    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id   --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       --and nvl(h.CANCELLED_FLAG, ''N'') = ''N''
       and h.SOLD_TO_ORG_ID = :hold_entity_id2
       and h.header_id = ol.header_id
       and h.org_ud = :l_org_id  --ER#7479609
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                          where oh.header_id = h.header_id
     					  and oh.line_id   = ol.line_id
                          and oh.hold_source_id =:hold_source_id )';

	   IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

          IF l_additional_where_clause = 'PICK_TRUE' THEN
               l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                     where w.source_line_id = ol.line_id and   w.source_code = ''OE''
                                     and   w.released_status in (''Y'', ''C''))';
          ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
           l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID and    wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
          END IF;
    IF p_item_type is null and p_activity_name is null then
    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id,p_hold_source_rec.hold_entity_id2,p_org_id ,  p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	ELSE
    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id,
     p_hold_source_rec.hold_entity_id2,p_org_id ,
    p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
    l_sql_rowcount := sql%rowcount;
    IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
    ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
      and h.header_id = ol.header_id
      and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );
   oe_debug_pub.add('l_parent_count/sql_count'||l_parent_count||sql%rowcount);
-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
    END IF;
   END IF;
ER#7479609 end */
   /* Only used by Credit checking */
  --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'SM' THEN

      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIPPING_METHOD_CODE = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and SM');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and SM');
    --ER#7479609 end


  --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'D' THEN

      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.DELIVER_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and D');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and D');
    --ER#7479609 end

  --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'PL' THEN

      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.PRICE_LIST_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and PL');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and PL');
    --ER#7479609 end

  --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'LT' THEN

      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.LINE_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and LT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and LT');
    --ER#7479609 end

  --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'PR' THEN

      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.PROJECT_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and PR');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and PR');
  --ER#7479609 end

   ELSIF p_hold_source_rec.hold_entity_code = 'B' and
      p_hold_source_rec.hold_entity_code2 = 'O' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVOICE_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.HEADER_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      oe_debug_pub.add('Calling InsertTable_OOH_Line for B and O');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      oe_debug_pub.add('After Calling InsertTable_OOH_Line for B and O');
      --ER#7479609 end

/*ER#7479609 start
     IF p_hold_source_rec.line_id IS NOT NULL THEN
     l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol,
              ra_terms_b rt
         WHERE h.OPEN_FLAG = ''Y''
           and h.header_id = :hold_entity_id2
           and h.header_id = ol.header_id
           and h.org_id =:l_org_id  --ER#7479609
           and ol.INVOICE_TO_ORG_ID = :hold_entity_id
           and ol.line_id = :line_id
           and ol.OPEN_FLAG = ''Y''
           and ol.PAYMENT_TERM_ID = rt.TERM_ID
           and rt.CREDIT_CHECK_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =:hold_source_id )';
     IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
     END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w where w.source_line_id = ol.line_id and   w.source_code = ''OE'' and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                             where  wdd.source_line_id = ol.LINE_ID and wdd.source_code = ''OE''
                                             and    wda.delivery_detail_id = wdd.delivery_detail_id
                                             and    wda.parent_delivery_detail_id is not null)';
        END IF;
       IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id,  p_hold_source_rec.hold_entity_id2,p_org_id , p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id,
           p_hold_source_rec.hold_entity_id2,p_org_id , p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;

       ELSE
        l_sqlmt :='INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id  --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol,
              ra_terms_b rt
         WHERE h.OPEN_FLAG = ''Y''
           and h.header_id = :hold_entity_id2
           and h.header_id = ol.header_id
           and h.org_id = :l_org_id   --ER#7479609
           and ol.INVOICE_TO_ORG_ID = :hold_entity_id
           and ol.OPEN_FLAG = ''Y''
           and ol.PAYMENT_TERM_ID = rt.TERM_ID
           and rt.CREDIT_CHECK_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                              where w.source_line_id = ol.line_id
                                              and   w.source_code = ''OE''
                                              and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, l_org_id, p_hold_source_rec.hold_entity_id2,  p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, l_org_id, p_hold_source_rec.hold_entity_id2,
          p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol , ra_terms_b rt
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = p_hold_source_rec.hold_entity_id2
      and h.header_id = ol.header_id
      and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and ol.PAYMENT_TERM_ID = rt.TERM_ID
      and rt.CREDIT_CHECK_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
	  END IF;
     END IF;
   END IF;
ER#7479609 end*/
   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'B' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.INVOICE_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and B');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and B');
      --ER#7479609 end

/*ER#7479609 start
     IF p_hold_source_rec.line_id IS NOT NULL THEN
        l_sqlmt :='INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id  --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           and h.header_id = ol.header_id
           and h.org_id = :l_org_id  --ER#7479609
           and ol.INVOICE_TO_ORG_ID = :hold_entity_id2
           and ol.line_id = :line_id
           and ol.INVENTORY_ITEM_ID = :hold_entity_id
           and ol.OPEN_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id = :hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
       ELSE
        l_sqlmt := 'Insert into oe_order_holds_all
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id  --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           and h.header_id = ol.header_id
           and h.org_id = :l_org_id  --ER#7479609
           and ol.INVOICE_TO_ORG_ID = :hold_entity_id2
           and ol.INVENTORY_ITEM_ID = :hold_entity_id
           and ol.OPEN_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id = :hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

         IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                                where w.source_line_id = ol.line_id
                                                and   w.source_code = ''OE''
                                                and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
      ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
      and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
	  END IF;
     END IF;
   END IF;

   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'S' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and S');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and S');
      --ER#7479609 end

/*ER#7479609 start
     IF p_hold_source_rec.line_id IS NOT NULL THEN
        l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id  --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           and h.header_id = ol.header_id
           and h.org_id = :l_org_id   --ER#7479609
           and ol.SHIP_TO_ORG_ID = :hold_entity_id2
           and ol.line_id = :line_id
           and ol.INVENTORY_ITEM_ID = :hold_entity_id
           and ol.OPEN_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
        				      and oh.line_id   = ol.line_id
                               and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_source_id;
      ELSE
	    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id,p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
       ELSE
        l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
        (   ORDER_HOLD_ID
        ,   LAST_UPDATE_DATE
        ,   LAST_UPDATED_BY
        ,   CREATION_DATE
        ,   CREATED_BY
        ,   LAST_UPDATE_LOGIN
        ,   HOLD_SOURCE_ID
        ,   HEADER_ID
        ,   LINE_ID
        ,   RELEASED_FLAG
        ,   ORG_ID
        )
        SELECT
            OE_ORDER_HOLDS_S.NEXTVAL
         ,  SYSDATE
         ,  :l_user_id
         ,  SYSDATE
         ,  :l_user_id
         ,  NULL
         ,  :hold_source_id
         ,  h.HEADER_ID
         ,  ol.line_id
         ,  ''N''
         ,  h.org_id   --ER#7479609 :l_org_id
         FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           and h.header_id = ol.header_id
           and h.org_id = :l_org_id   --ER#7479609
           and ol.SHIP_TO_ORG_ID = :hold_entity_id2
           and ol.INVENTORY_ITEM_ID = :hold_entity_id
           and ol.OPEN_FLAG = ''Y''
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                             where oh.header_id = h.header_id
                               and oh.line_id   = ol.line_id
                               and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id,  p_hold_source_rec.hold_source_id;
	   ELSE
	    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
      and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
   END IF;
   END IF;
ER#7479609 end*/

   ELSIF p_hold_source_rec.hold_entity_code = 'I' and
      p_hold_source_rec.hold_entity_code2 = 'W' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_FROM_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and W');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and W');
      --ER#7479609 end

/*ER#7479609 start
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id    --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''

       and h.header_id = ol.header_id
       and h.org_id = :l_org_id   --ER#7479609
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id2
       and ol.line_id = :line_id
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id,  p_hold_source_rec.hold_source_id;
       ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;

        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id  --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''

       and h.header_id = ol.header_id
       and h.org_id = :l_org_id   --ER#7479609
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id2
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

    ELSIF p_hold_source_rec.hold_entity_code = 'I' and
        p_hold_source_rec.hold_entity_code2 = 'H' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.BLANKET_NUMBER  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I and H');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I and H');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id   --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''

         and h.header_id = ol.header_id
         and h.org_id = :l_org_id  --ER#7479609
         and ol.BLANKET_NUMBER = :hold_entity_id2
         and ol.line_id = :line_id
         and ol.INVENTORY_ITEM_ID = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                                          and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
      ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id   --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''

         and h.header_id = ol.header_id
         and h.org_id = :l_org_id  --ER#7479609
         and ol.BLANKET_NUMBER  = :hold_entity_id2
         and ol.INVENTORY_ITEM_ID = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id,  p_hold_source_rec.hold_source_id;
	   ELSE
	    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
 	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
        and h.header_id = ol.header_id
        and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id2
        and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
        and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

  /*********************************************************
    HOLD CRITERIA 1 : WAREHOUSE
   *********************************************************/
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
      p_hold_source_rec.hold_entity_code2 = 'C' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SOLD_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and C');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and C');
      --ER#7479609 end

/*ER#7479609 start
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id   --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''

       and h.header_id = ol.header_id
       and h.org_id = :l_org_id
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id
       and ol.line_id = :line_id
       and h.SOLD_TO_ORG_ID = :hold_entity_id2
       and ol.OPEN_FLAG = ''Y''
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_source_id;
      ELSE
	  execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  p_org_id  --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''

       and h.header_id = ol.header_id
       and h.org_id = :l_org_id   --ER#7479609
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id
       and h.SOLD_TO_ORG_ID = :hold_entity_id2
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_source_id;
      ELSE
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id,
       p_hold_source_rec.hold_entity_id2 , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
	 l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'SM' THEN


      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIPPING_METHOD_CODE = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and SM');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and SM');
  --ER#7479609 end

   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'ST' THEN


      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SOURCE_TYPE_CODE = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and ST');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and ST');
  --ER#7479609 end


   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'LT' THEN


      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.LINE_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and LT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and LT');
     --ER#7479609 end

   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'D' THEN

      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.DELIVER_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and D');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and D');
   --ER#7479609 end


   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'B' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.INVOICE_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and B');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and B');
      --ER#7479609 end

/*ER#7479609 start
     IF p_hold_source_rec.line_id IS NOT NULL THEN
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           AND h.header_id = ol.header_id
           and h.org_id = :l_org_id   --ER#7479609
           AND ol.SHIP_FROM_ORG_ID = :hold_entity_id
           and ol.line_id = :line_id
           AND ol.INVOICE_TO_ORG_ID = :hold_entity_id2
           and ol.OPEN_FLAG = ''Y''
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   AND NOT EXISTS ( select ''x''
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2,  p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2 , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
       ELSE
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  p_org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''

           AND h.header_id = ol.header_id
           and h.org_id = :l_org_id  --ER#7479609
           AND ol.SHIP_FROM_ORG_ID = :hold_entity_id
           AND ol.INVOICE_TO_ORG_ID = :hold_entity_id2
           and ol.OPEN_FLAG = ''Y''
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   AND NOT EXISTS ( select ''x''
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
       IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_source_id;
	  ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id,
p_hold_source_rec.hold_entity_id2 , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       AND h.header_id = ol.header_id
       AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       AND ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

   ELSIF p_hold_source_rec.hold_entity_code = 'W' and
         p_hold_source_rec.hold_entity_code2 = 'S' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W and S');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W and S');
      --ER#7479609 end

/*ER#7479609 start
     IF p_hold_source_rec.line_id IS NOT NULL THEN
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''
           AND h.org_id = :l_org_id  --ER#7479609
           AND ol.SHIP_FROM_ORG_ID = :hold_entity_id
           and ol.line_id = :line_id
           AND h.header_id = ol.header_id
           AND ol.SHIP_TO_ORG_ID = :hold_entity_id2
           and ol.OPEN_FLAG = ''Y''
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   AND NOT EXISTS ( select ''x''
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2,  p_hold_source_rec.hold_source_id;
      ELSE
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id,
 p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id2 , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
          IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
      END IF;
       ELSE
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
         WHERE h.OPEN_FLAG = ''Y''
           AND h.org_id = :l_org_id   --ER#7479609
           AND ol.SHIP_FROM_ORG_ID = :hold_entity_id
           AND h.header_id = ol.header_id
           AND ol.SHIP_TO_ORG_ID = :hold_entity_id2
           and ol.OPEN_FLAG = ''Y''
           -- QUOTING change
           and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		   AND NOT EXISTS ( select ''x''
                              FROM oe_order_holds_ALL oh
                             WHERE oh.header_id = h.header_id
                               AND oh.line_id   = ol.line_id
                               AND oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
         IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_entity_id2,  p_hold_source_rec.hold_source_id;
      ELSE
	  execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id,
 p_hold_source_rec.hold_entity_id2 , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
   	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      AND ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
      AND h.header_id = ol.header_id
      AND ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id2
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/
  /*********************************************************
    HOLD CRITERIA 1 : SALES AGREEMENT
   *********************************************************/

 ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'B' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.INVOICE_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and B');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and B');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id   --ER#7479609
         and h.header_id = ol.header_id
         and ol.INVOICE_TO_ORG_ID = :hold_entity_id2
         and ol.line_id = :line_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                                          and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
      ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
         IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
	  ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.INVOICE_TO_ORG_ID= :hold_entity_id2
         and ol.BLANKET_NUMBER  = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id,  p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
         and h.header_id = ol.header_id
         and ol.INVOICE_TO_ORG_ID= p_hold_source_rec.hold_entity_id2
         and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
         and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/


   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'H' and
         p_hold_source_rec.hold_entity_code2 = 'PT' THEN

      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.PAYMENT_TERM_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and PT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and PT');
   --ER#7479609 end


    --ER#7479609 start
    ELSIF p_hold_source_rec.hold_entity_code = 'H' and
          p_hold_source_rec.hold_entity_code2 = 'PL' THEN

       l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                      ||'  and ol.PRICE_LIST_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


       OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and PL');
       InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
       		           ,p_line_id         => p_hold_source_rec.line_id
       		           ,p_org_id          => p_org_id
       		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
       		           ,p_item_type	=> p_item_type
       		           ,p_activity_name   => l_activity_name
       		           ,p_activity_status => l_act_status
       		           ,p_additional_where_clause => l_additional_where_clause
       		           ,x_is_hold_applied => x_is_hold_applied);
       OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and PL');
    --ER#7479609 end


    --ER#7479609 start
    ELSIF p_hold_source_rec.hold_entity_code = 'H' and
          p_hold_source_rec.hold_entity_code2 = 'D' THEN

       l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                      ||'  and ol.DELIVER_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


       OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and D');
       InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
       		           ,p_line_id         => p_hold_source_rec.line_id
       		           ,p_org_id          => p_org_id
       		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
       		           ,p_item_type	=> p_item_type
       		           ,p_activity_name   => l_activity_name
       		           ,p_activity_status => l_act_status
       		           ,p_additional_where_clause => l_additional_where_clause
       		           ,x_is_hold_applied => x_is_hold_applied);
       OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and D');
    --ER#7479609 end


   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'H' and
         p_hold_source_rec.hold_entity_code2 = 'LT' THEN

      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.LINE_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and LT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and LT');
   --ER#7479609 end

   --ER#7479609 start
   ELSIF p_hold_source_rec.hold_entity_code = 'H' and
         p_hold_source_rec.hold_entity_code2 = 'SM' THEN

      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIPPING_METHOD_CODE = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and SM');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and SM');
   --ER#7479609 end


ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'S' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_TO_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and S');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and S');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id   --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id   --ER#7479609
         and h.header_id = ol.header_id
         and ol.SHIP_TO_ORG_ID = :hold_entity_id2
         and ol.line_id = :line_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
      ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id   --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.SHIP_TO_ORG_ID= :hold_entity_id2
         and ol.BLANKET_NUMBER  = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
      ELSE
	  execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
     l_sql_rowcount := sql%rowcount;

 	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.SHIP_TO_ORG_ID= p_hold_source_rec.hold_entity_id2
      and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

   ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'W' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_FROM_ORG_ID  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and W');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and W');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.SHIP_FROM_ORG_ID = :hold_entity_id2
         and ol.line_id = :line_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id,  p_hold_source_rec.hold_source_id;
	   ELSE
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
      ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.SHIP_FROM_ORG_ID= :hold_entity_id2
         and ol.BLANKET_NUMBER  = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID= p_hold_source_rec.hold_entity_id2
       and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

     ELSIF p_hold_source_rec.hold_entity_code = 'H' and
        p_hold_source_rec.hold_entity_code2 = 'L' THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.BLANKET_LINE_NUMBER  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H and L');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H and L');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.BLANKET_LINE_NUMBER = :hold_entity_id2
         and ol.line_id = :line_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,
 p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
      ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id   --ER#7479609
         and h.header_id = ol.header_id
         and ol.BLANKET_LINE_NUMBER = :hold_entity_id2
         and ol.BLANKET_NUMBER  = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id2,	 p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id2,
p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
      l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.BLANKET_LINE_NUMBER = p_hold_source_rec.hold_entity_id2
      and ol.BLANKET_NUMBER  = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

     ELSIF p_hold_source_rec.hold_entity_code = 'H'
       AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.BLANKET_NUMBER = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for H');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for H');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.line_id = :line_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
  					  and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
      ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.line_id,
p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
      ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  ol.line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = ol.header_id
         and ol.BLANKET_NUMBER = :hold_entity_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		and not exists ( select ''x''
                            from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id   = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
   	   IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id , p_hold_source_rec.hold_entity_id ,
 p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
        and h.header_id = ol.header_id
        and ol.BLANKET_NUMBER = p_hold_source_rec.hold_entity_id
        and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/
  /******************************************************************************************************
    HOLD CRITERIA 1 : ORDER (EVEN FOR HOLD FOR A SPECIFIC ORDER LIKE ACTION->APPLY HOLDS OR ONLINE HOLDS)
   ******************************************************************************************************/

   ELSIF p_hold_source_rec.hold_entity_code = 'O' THEN
    IF p_hold_source_rec.line_id is NULL THEN
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  NULL
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = :hold_entity_id
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.hold_source_id =:hold_source_id2 )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(h.header_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(was.activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
         END IF;

      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  /*ER#7479609 start l_org_id*/, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  /*ER#7479609 start l_org_id*/, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOH', l_activity_name,
	         l_act_status,'XXX', 'INCOMPLETE','ON_HOLD'; --9538334
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
    ELSE
      l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
      (   ORDER_HOLD_ID
      ,   LAST_UPDATE_DATE
      ,   LAST_UPDATED_BY
      ,   CREATION_DATE
      ,   CREATED_BY
      ,   LAST_UPDATE_LOGIN
      ,   HOLD_SOURCE_ID
      ,   HEADER_ID
      ,   LINE_ID
      ,   RELEASED_FLAG
      ,   ORG_ID
      )
      SELECT
          OE_ORDER_HOLDS_S.NEXTVAL
       ,  SYSDATE
       ,  :l_user_id
       ,  SYSDATE
       ,  :l_user_id
       ,  NULL
       ,  :hold_source_id
       ,  h.HEADER_ID
       ,  :line_id
       ,  ''N''
       ,  h.org_id  --ER#7479609 :l_org_id
       FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
       WHERE h.OPEN_FLAG = ''Y''
         and h.org_id = :l_org_id  --ER#7479609
         and h.header_id = :hold_entity_id
         and h.header_id = ol.header_id
         and ol.line_id = :line_id
         and ol.OPEN_FLAG = ''Y''
         -- QUOTING change
         and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
		 and not exists ( select ''x''
                              from oe_order_holds_ALL oh
                           where oh.header_id = h.header_id
                             and oh.line_id = ol.line_id
                             and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status
						  and nvl(activity_result_code, :l_activity_result)
						      NOT IN (:l_result_1, :l_result_2))'; --9538334
         END IF;
      IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_hold_source_rec.line_id,
                                                           p_org_id  /*ER#7479609 start l_org_id*/,  p_hold_source_rec.hold_entity_id,
                                                                  p_hold_source_rec.line_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_hold_source_rec.line_id, p_org_id  /*ER#7479609 start l_org_id*/,
 p_hold_source_rec.hold_entity_id, p_hold_source_rec.line_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status,
 'XXX', 'INCOMPLETE','ON_HOLD'; --9538334;
       l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
     x_is_hold_applied := TRUE;
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
         and h.header_id = p_hold_source_rec.hold_entity_id
         and h.header_id = ol.header_id
         and ol.line_id = p_hold_source_rec.line_id
         and ol.open_flag = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

/* Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables. */

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;

  /*********************************************************
    HOLD CRITERIA 1 : CUSTOMER
   *********************************************************/

   ELSIF p_hold_source_rec.hold_entity_code = 'C'
     AND p_hold_source_rec.hold_entity_code2 IS NULL THEN
       -- Use header_id for Customer based hold source

    --ER#7479609 start
      l_hold_entity_where_clause := 'and h.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';

      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for C');

    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for C');
    --ER#7479609 end


    /*ER#7479609 start
    IF p_hold_source_rec.header_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  ''N''
     ,  h.org_id   --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id  --ER#7479609
       and h.header_id = :header_id
       and h.SOLD_TO_ORG_ID = :hold_entity_id
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(h.header_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

        IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.header_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id  , p_hold_source_rec.header_id,
 p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOH', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  NULL
     ,  ''N''
     ,  h.org_id --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h
     WHERE h.OPEN_FLAG = ''Y''

       and h.SOLD_TO_ORG_ID = :hold_entity_id
       and h.org_id = :l_org_id  --ER#7479609
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	  and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(h.header_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;

      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_hold_source_rec.hold_entity_id,p_org_id, p_hold_source_rec.hold_source_id;
      ELSE

       	    execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_hold_source_rec.hold_entity_id,p_org_id, p_hold_source_rec.hold_source_id, 'OEOH', l_activity_name, l_act_status;

  	  l_sql_rowcount := sql%rowcount;
oe_debug_pub.add('l_sql_rowcount - '||l_sql_rowcount);
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
       FROM OE_ORDER_HEADERS_ALL h
        WHERE h.OPEN_FLAG = 'Y'

        and h.SOLD_TO_ORG_ID = p_hold_source_rec.hold_entity_id
	    and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
        and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow -- or Shipping product tables.
  oe_debug_pub.add('l_parent_count - '||l_parent_count);
      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
   ER#7479609 end*/

    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'B' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.INVOICE_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and B');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and B');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'S' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SHIP_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and S');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and S');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'D' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.DELIVER_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and D');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and D');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'PL' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.PRICE_LIST_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and PL');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and PL');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'LT' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.LINE_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and LT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and LT');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'PT' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.PAYMENT_TERM_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and PT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and PT');
    --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'OT' THEN


      l_hold_entity_where_clause := 'and h.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.ORDER_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';

      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for C and OT');
      InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    	        	     ,p_header_id =>p_hold_source_rec.header_id
    			     ,p_org_id => p_org_id
    			     ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			     ,p_item_type => p_item_type
    			     ,p_activity_name => l_activity_name
    			     ,p_activity_status => l_act_status
			     ,p_additional_where_clause => l_additional_where_clause
			     ,x_is_hold_applied => x_is_hold_applied);

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for C and OT');
    --ER#7479609 end

    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'P' THEN


      OE_DEBUG_PUB.ADD('Calling PaymentType_Hold for C and P');
           PaymentType_Hold (p_hold_source_rec  => p_hold_source_rec
                            ,p_org_id          => p_org_id
			    ,p_item_type       => p_item_type
			    ,p_activity_name   => l_activity_name
			    ,p_activity_status => l_act_status
			    ,p_additional_where_clause =>  l_additional_where_clause
			    ,x_is_hold_applied => x_is_hold_applied);

      --ER#7479609 start
      IF NOT x_is_hold_applied THEN
        x_return_status := '0';
      END IF;
      --ER#7479609 end

      OE_DEBUG_PUB.ADD('After Calling InsePaymentType_Hold for C and P');
    --ER#7479609 end

    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'TC' THEN


      l_hold_entity_where_clause := 'and h.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.TRANSACTIONAL_CURR_CODE  = '||''''||p_hold_source_rec.hold_entity_id2||'''';

      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for C and TC');
      InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    	        	     ,p_header_id =>p_hold_source_rec.header_id
    			     ,p_org_id => p_org_id
    			     ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			     ,p_item_type => p_item_type
    			     ,p_activity_name => l_activity_name
    			     ,p_activity_status => l_act_status
			     ,p_additional_where_clause => l_additional_where_clause
			     ,x_is_hold_applied => x_is_hold_applied);

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for C and TC');
    --ER#7479609 end

  --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'ST' THEN


      l_hold_entity_where_clause := 'and ol.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.SOURCE_TYPE_CODE = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for C and ST');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for C and ST');
  --ER#7479609 end


    --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'C' and
           p_hold_source_rec.hold_entity_code2 = 'SC' THEN


      l_hold_entity_where_clause := 'and h.SOLD_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.SALES_CHANNEL_CODE  = '||''''||p_hold_source_rec.hold_entity_id2||'''';

      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for C and SC');
      InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    	        	     ,p_header_id =>p_hold_source_rec.header_id
    			     ,p_org_id => p_org_id
    			     ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			     ,p_item_type => p_item_type
    			     ,p_activity_name => l_activity_name
    			     ,p_activity_status => l_act_status
			     ,p_additional_where_clause => l_additional_where_clause
			     ,x_is_hold_applied => x_is_hold_applied);

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for C and SC');
    --ER#7479609 end


  /*********************************************************
    HOLD CRITERIA 1 : BILL TO SITE
   *********************************************************/

   ELSIF p_hold_source_rec.hold_entity_code = 'B'
     AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVOICE_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for B');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for B');
      --ER#7479609 end

/*ER#7479609 start
    IF p_hold_source_rec.line_id IS NOT NULL THEN
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = ''Y''
            and h.org_id = :l_org_id
            and h.header_id = ol.header_id
            and ol.line_id = :line_id
            and ol.INVOICE_TO_ORG_ID = :hold_entity_id
            and ol.OPEN_FLAG = ''Y''
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
			and not exists ( select ''x''
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id,  p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id,  p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
	   END IF;

       ELSE
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = ''Y''
            and h.org_id = :l_org_id  --ER#7479609
            and h.header_id = ol.header_id
            and ol.INVOICE_TO_ORG_ID = :hold_entity_id
            and ol.OPEN_FLAG = ''Y''
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
			and not exists ( select ''x''
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
 	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.INVOICE_TO_ORG_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/

  /*********************************************************
    HOLD CRITERIA 1 : SHIP TO SITE
   *********************************************************/

    ELSIF p_hold_source_rec.hold_entity_code = 'S'
      AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.SHIP_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for S');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for S');
      --ER#7479609 end

/*ER#7479609 start
      IF p_hold_source_rec.line_id IS NOT NULL THEN
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = ''Y''
            and h.org_id = :l_org_id   --ER#7479609
            and h.header_id = ol.header_id
            and ol.line_id = :line_id
            and ol.SHIP_TO_ORG_ID = :hold_entity_id
            and ol.OPEN_FLAG = ''Y''
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
			and not exists ( select ''x''
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
     					  and oh.line_id   = ol.line_id
                                and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
       ELSE
         l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
         (   ORDER_HOLD_ID
         ,   LAST_UPDATE_DATE
         ,   LAST_UPDATED_BY
         ,   CREATION_DATE
         ,   CREATED_BY
         ,   LAST_UPDATE_LOGIN
         ,   HOLD_SOURCE_ID
         ,   HEADER_ID
         ,   LINE_ID
         ,   RELEASED_FLAG
         ,   ORG_ID
         )
         SELECT
             OE_ORDER_HOLDS_S.NEXTVAL
          ,  SYSDATE
          ,  :l_user_id
          ,  SYSDATE
          ,  :l_user_id
          ,  NULL
          ,  :hold_source_id
          ,  h.HEADER_ID
          ,  ol.line_id
          ,  ''N''
          ,  h.org_id  --ER#7479609 :l_org_id
          FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
          WHERE h.OPEN_FLAG = ''Y''
            and h.org_id = :l_org_id  --ER#7479609
            and h.header_id = ol.header_id
            and ol.SHIP_TO_ORG_ID = :hold_entity_id
            and ol.OPEN_FLAG = ''Y''
            -- QUOTING change
            and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
			and not exists ( select ''x''
                               from oe_order_holds_ALL oh
                              where oh.header_id = h.header_id
                                and oh.line_id   = ol.line_id
                                and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	  ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       and h.header_id = ol.header_id
       and ol.SHIP_TO_ORG_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/
  /*********************************************************
    HOLD CRITERIA 1 : WAREHOUSE
   *********************************************************/

   ELSIF p_hold_source_rec.hold_entity_code = 'W'
     AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.SHIP_FROM_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for W');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for W');
      --ER#7479609 end

/*ER#7479609 start
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id  --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id   --ER#7479609
       and h.header_id = ol.header_id
       and ol.line_id = :line_id
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	  and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	  ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;
    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id  --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id  --ER#7479609
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
  	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      oe_debug_pub.add(' Hold Not applied for All requested records');
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
       and h.header_id = ol.header_id
       and ol.SHIP_FROM_ORG_ID = p_hold_source_rec.hold_entity_id
       and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;
        oe_debug_pub.add(' Hold Not applied for FEW of the requested records');
      END IF;
     END IF;
	 END IF;
   END IF;
ER#7479609 end*/
  /*********************************************************
    HOLD CRITERIA 1 : ITEM
   *********************************************************/

   ELSIF p_hold_source_rec.hold_entity_code = 'I'
     AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.INVENTORY_ITEM_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for I');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
		      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for I');
      --ER#7479609 end

/*ER#7479609 start
    IF p_hold_source_rec.line_id IS NOT NULL THEN
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id  --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id  --ER#7479609
       and h.header_id = ol.header_id
       and ol.line_id = :line_id
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
					  and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
         IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
	   execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.line_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
        IF sql%rowcount = 0 THEN
          x_is_hold_applied := FALSE;
        ELSIF sql%rowcount = 1 THEN
          x_is_hold_applied := TRUE;
        END IF;
       END IF;

    ELSE
    l_sqlmt := 'INSERT INTO OE_ORDER_HOLDS_ALL
    (   ORDER_HOLD_ID
    ,   LAST_UPDATE_DATE
    ,   LAST_UPDATED_BY
    ,   CREATION_DATE
    ,   CREATED_BY
    ,   LAST_UPDATE_LOGIN
    ,   HOLD_SOURCE_ID
    ,   HEADER_ID
    ,   LINE_ID
    ,   RELEASED_FLAG
    ,   ORG_ID
    )
    SELECT
        OE_ORDER_HOLDS_S.NEXTVAL
     ,  SYSDATE
     ,  :l_user_id
     ,  SYSDATE
     ,  :l_user_id
     ,  NULL
     ,  :hold_source_id
     ,  h.HEADER_ID
     ,  ol.line_id
     ,  ''N''
     ,  h.org_id --ER#7479609 :l_org_id
     FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
     WHERE h.OPEN_FLAG = ''Y''
       and h.org_id = :l_org_id  --ER#7479609
       and h.header_id = ol.header_id
       and ol.INVENTORY_ITEM_ID = :hold_entity_id
       and ol.OPEN_FLAG = ''Y''
       -- QUOTING change
       and nvl(h.TRANSACTION_PHASE_CODE,''F'') = ''F''
	   and not exists ( select ''x''
                          from oe_order_holds_ALL oh
                         where oh.header_id = h.header_id
                           and oh.line_id   = ol.line_id
                           and oh.hold_source_id =:hold_source_id )';
         IF p_item_type is not null and p_activity_name is not null then
             l_sqlmt := l_sqlmt||' and not exists (select 1 from wf_item_activity_statuses was
                                                        , wf_process_activities wpa
                                                  where  was.process_activity = wpa.instance_id
                                                  and    item_type = :p_item_type
                                                  and    item_key  = to_char(ol.line_id)
                                                  and    activity_name = :l_activity_name
                                                  and    activity_status = :l_activity_status)';
         END IF;
        IF l_additional_where_clause = 'PICK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details w
                                               where w.source_line_id = ol.line_id
                                               and   w.source_code = ''OE''
                                               and   w.released_status in (''Y'', ''C''))';
        ELSIF l_additional_where_clause = 'PACK_TRUE' THEN
         l_sqlmt := l_sqlmt||' and not exists (select 1 from wsh_delivery_details wdd, wsh_delivery_assignments wda
                                               where  wdd.source_line_id = ol.LINE_ID
                                               and wdd.source_code = ''OE''
                                               and    wda.delivery_detail_id = wdd.delivery_detail_id
                                               and    wda.parent_delivery_detail_id is not null)';
        END IF;
      IF p_item_type is null and p_activity_name is null then
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id, p_hold_source_rec.hold_source_id;
	   ELSE
       execute immediate l_sqlmt using l_user_id, l_user_id, p_hold_source_rec.hold_source_id, p_org_id, p_hold_source_rec.hold_entity_id , p_hold_source_rec.hold_source_id, 'OEOL', l_activity_name, l_act_status;
   	  l_sql_rowcount := sql%rowcount;
	  IF l_sql_rowcount = 0 THEN

      select meaning into l_user_activity_name
      from   oe_lookups
      where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
      and    lookup_code = p_activity_name;

      fnd_message.set_name('ONT', 'OE_NO_HOLD_ALL_LINES');
      fnd_message.set_token('WF_ACT', l_user_activity_name);
      OE_MSG_PUB.ADD;
      RAISE FND_API.G_EXC_ERROR;
     ELSIF l_sql_rowcount > 0 THEN
      SELECT count(*)
      into   l_parent_count
      FROM OE_ORDER_HEADERS_ALL h, OE_ORDER_LINES_ALL ol
      WHERE h.OPEN_FLAG = 'Y'
      and h.header_id = ol.header_id
      and ol.INVENTORY_ITEM_ID = p_hold_source_rec.hold_entity_id
      and ol.OPEN_FLAG = 'Y'
      and nvl(h.TRANSACTION_PHASE_CODE,'F') = 'F'
      and not exists ( select 'x'
                       from oe_order_holds_ALL oh
                       where oh.header_id = h.header_id
                       and oh.line_id   = ol.line_id
                       and oh.hold_source_id =
                              p_hold_source_rec.hold_source_id );

-- Note: The above query is used based on WHERE clause of the l_sqlmt but without any query on Workflow or Shipping product tables.

      IF l_sql_rowcount < (l_parent_count+l_sql_rowcount) THEN

        select meaning into l_user_activity_name
        from   oe_lookups
        where  lookup_type = DECODE(p_item_type,
        OE_GLOBALS.G_WFI_HDR, 'HOLDABLE_HEADER_ACTIVITIES',
        OE_GLOBALS.G_WFI_LIN, 'HOLDABLE_LINE_ACTIVITIES', '-XX')
        and    lookup_code = p_activity_name;

        fnd_message.set_name('ONT', 'OE_NO_HOLD_FEW_LINES');
        fnd_message.set_token('WF_ACT', l_user_activity_name);
        OE_MSG_PUB.ADD;

      END IF;
     END IF;
   END IF;
   END IF;
ER#7479609 end*/

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'PR' and
        p_hold_source_rec.hold_entity_code2 = 'T' THEN

      l_hold_entity_where_clause := 'and ol.PROJECT_ID  = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.TASK_ID   = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for PR and T');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for PR and T');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'PR' and
        p_hold_source_rec.hold_entity_code2 IS NULL  THEN

      l_hold_entity_where_clause := 'and ol.PROJECT_ID  = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for PR and T');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for PR and T');
    --ER#7479609 end


     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'PL' and
        p_hold_source_rec.hold_entity_code2 = 'TC' THEN

      l_hold_entity_where_clause := 'and h.PRICE_LIST_ID   = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.TRANSACTIONAL_CURR_CODE  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for PL and TC');
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for PR and T');
    --ER#7479609 end


     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'PL' and
        p_hold_source_rec.hold_entity_code2 IS NULL THEN

      l_hold_entity_where_clause := 'and h.PRICE_LIST_ID   = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for PL and TC');
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for PR and T');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'OT' and
        p_hold_source_rec.hold_entity_code2 = 'LT' THEN

      l_hold_entity_where_clause := 'and h.ORDER_TYPE_ID  = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.LINE_TYPE_ID = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for OT and LT');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for OT and LT');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'OT' and
        p_hold_source_rec.hold_entity_code2 = 'TC' THEN

      l_hold_entity_where_clause := 'and h.ORDER_TYPE_ID  = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and h.TRANSACTIONAL_CURR_CODE  = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for OT and TC');
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for OT and TC');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'OT' and
        p_hold_source_rec.hold_entity_code2 IS NULL THEN

      l_hold_entity_where_clause := 'and h.ORDER_TYPE_ID  = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Header for OT and TC');
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Header for OT and TC');
    --ER#7479609 end


     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'CD' and
        p_hold_source_rec.hold_entity_code2 = 'CB' THEN

      l_hold_entity_where_clause := 'and to_char(ol.CREATION_DATE,''DD-MON-RRRR'')  = '||''''||p_hold_source_rec.hold_entity_id||''''
                                     ||'  and ol.CREATED_BY = '||''''||p_hold_source_rec.hold_entity_id2||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for CD and CB');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for CD and CB');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'CD' and
        p_hold_source_rec.hold_entity_code2 IS NULL THEN

      l_hold_entity_where_clause := 'and to_char(ol.CREATION_DATE,''DD-MON-RRRR'')  = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for CD');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for CD');
    --ER#7479609 end


     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'SC'
       AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      l_hold_entity_where_clause := 'and h.SALES_CHANNEL_CODE  = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for SC');
    	InsertTable_OOH_Header (p_hold_source_id => p_hold_source_rec.hold_source_id
    			       ,p_header_id =>p_hold_source_rec.header_id
    			       ,p_org_id => p_org_id
    			       ,p_hold_entity_where_clause => l_hold_entity_where_clause
    			       ,p_item_type => p_item_type
    			       ,p_activity_name => l_activity_name
    			       ,p_activity_status => l_act_status
			       ,p_additional_where_clause => l_additional_where_clause
			       ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for SC');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'P'
       AND p_hold_source_rec.hold_entity_code2 IS NULL THEN


      OE_DEBUG_PUB.ADD('Calling PaymentType_Hold for P');
           PaymentType_Hold (p_hold_source_rec  => p_hold_source_rec
           		    ,p_org_id          => p_org_id
			    ,p_item_type       => p_item_type
			    ,p_activity_name   => l_activity_name
			    ,p_activity_status => l_act_status
			    ,p_additional_where_clause =>  l_additional_where_clause
			    ,x_is_hold_applied => x_is_hold_applied);

      --ER#7479609 start
      IF NOT x_is_hold_applied THEN
        x_return_status := '0';
      END IF;
      --ER#7479609 end

      OE_DEBUG_PUB.ADD('After Calling PaymentType_Hold for P');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'SM'
       AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      l_hold_entity_where_clause := 'and ol.SHIPPING_METHOD_CODE  = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for SM');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for SM');
    --ER#7479609 end

     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'D'
     AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

      --ER#7479609 start
      l_hold_entity_where_clause := 'and ol.DELIVER_TO_ORG_ID = '||''''||p_hold_source_rec.hold_entity_id||'''';


      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for D');
      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => p_hold_source_rec.line_id
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for D');
      --ER#7479609 end


     --ER#7479609 start
     ELSIF p_hold_source_rec.hold_entity_code = 'TM'
       AND p_hold_source_rec.hold_entity_code2 IS NULL THEN

       BEGIN
       l_line_id_tab.delete;

       IF p_hold_source_rec.line_id IS NULL THEN

       	select line_id
       	BULK COLLECT INTO l_line_id_tab
       	from oe_order_lines_all
       	where inventory_item_id=p_hold_source_rec.hold_entity_id
       	and line_id=top_model_line_id
       	and top_model_line_id IS NOT NULL;

       ELSE

       	select line_id
       	BULK COLLECT INTO l_line_id_tab
       	from oe_order_lines_all
       	where inventory_item_id=p_hold_source_rec.hold_entity_id
       	and line_id=top_model_line_id
       	and line_id=p_hold_source_rec.line_id
       	and top_model_line_id IS NOT NULL;

        END IF;

       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;



      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for TM:'||l_line_id_tab.count);

      FOR i in 1 .. l_line_id_tab.count LOOP

      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => l_line_id_tab(i)
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      END LOOP;

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for TM');

     ELSIF p_hold_source_rec.hold_entity_code = 'TM'
       AND p_hold_source_rec.hold_entity_code2 = 'OI' THEN

       BEGIN
        l_line_id_tab.delete;

	IF p_hold_source_rec.line_id IS NULL THEN

	  select top_model_line_id
  	  BULK COLLECT INTO l_line_id_tab
	  from oe_order_lines_all line_opt
	  where line_opt.inventory_item_id=p_hold_source_rec.hold_entity_id2
	  and line_opt.item_type_code in ('OPTION','CLASS','INCLUDED')
	  and EXISTS (select 1 from oe_order_lines_all line_mod
	              where line_mod.inventory_item_id=p_hold_source_rec.hold_entity_id
	               and  line_mod.line_id=line_opt.top_model_line_id);
	ELSE

	  select top_model_line_id
  	  BULK COLLECT INTO l_line_id_tab
	  from oe_order_lines_all line_opt
	  where line_opt.inventory_item_id=p_hold_source_rec.hold_entity_id2
	  and line_opt.line_id=p_hold_source_rec.line_id
	  and line_opt.item_type_code in ('OPTION','CLASS','INCLUDED')
	  and EXISTS (select 1 from oe_order_lines_all line_mod
	              where line_mod.inventory_item_id=p_hold_source_rec.hold_entity_id
	               and  line_mod.line_id=line_opt.top_model_line_id);
	END IF;

       EXCEPTION
        WHEN OTHERS THEN
         NULL;
       END;



      OE_DEBUG_PUB.ADD('Calling InsertTable_OOH_Line for TM and OI:'||l_line_id_tab.count);

      FOR i in 1 .. l_line_id_tab.count LOOP

      InsertTable_OOH_Line (p_hold_source_id => p_hold_source_rec.hold_source_id
      		           ,p_line_id         => l_line_id_tab(i)
      		           ,p_org_id          => p_org_id
      		           ,p_hold_entity_where_clause => l_hold_entity_where_clause
      		           ,p_item_type	=> p_item_type
      		           ,p_activity_name   => l_activity_name
      		           ,p_activity_status => l_act_status
      		           ,p_additional_where_clause => l_additional_where_clause
      		           ,x_is_hold_applied => x_is_hold_applied);
      END LOOP;

      OE_DEBUG_PUB.ADD('After Calling InsertTable_OOH_Line for TM and OI');
    --ER#7479609 end


END IF;


-- GENESIS --
  IF p_hold_source_rec.line_id IS NOT NULL THEN

     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.line_id IS NOT NULL');
     END IF;

     OPEN check_line_hold_type_cur(p_hold_source_rec.line_id);
     FETCH check_line_hold_type_cur INTO l_check_hold;
     CLOSE check_line_hold_type_cur;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold' || l_check_hold);
     END IF;

  ELSIF p_hold_source_rec.line_id IS NULL AND
        p_hold_source_rec.header_id IS NOT NULL THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.header_id IS NOT NULL');
     END IF;
     OPEN check_hdr_hold_type_cur(p_hold_source_rec.header_id);
     FETCH check_hdr_hold_type_cur INTO l_check_hold;
     CLOSE check_hdr_hold_type_cur;
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold' || l_check_hold);
     END IF;

  ELSIF p_hold_source_rec.line_id IS NULL AND
        p_hold_source_rec.header_id IS NULL AND
        p_hold_source_rec.hold_source_id IS NOT NULL THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - p_hold_source_rec.hold_source_id IS NOT NULL');
     END IF;
     OPEN check_src_hold_type_cur(p_hold_source_rec.hold_source_id);
     FETCH check_src_hold_type_cur INTO l_check_hold;
     CLOSE check_src_hold_type_cur;

     IF l_debug_level  > 0 THEN
	oe_debug_pub.add('OE_HOLDS_PVT-CREATE ORDER HOLDS - l_check_hold :' || l_check_hold);
     END IF;

  END IF;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OE_HOLDS_PVT - CREATE ORDER HOLDS - BEFORE SYNC_HEADER_LINE');
  END IF;

  IF NVL(l_check_hold, 'N') = 'Y' THEN
     IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OE_HOLDS_PVT - CREATE ORDER HOLDS - l_check_hold: ' || l_check_hold);
     END IF;

  IF p_hold_source_rec.hold_entity_code = 'O' THEN
     IF l_debug_level  > 0 THEN
  	oe_debug_pub.add(' p_hold_source_rec.hold_entity_code ' || p_hold_source_rec.hold_entity_code);
     END IF;
     IF p_hold_source_rec.hold_entity_id is NOT NULL THEN
        IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(' p_hold_source_rec.hold_entity_id : ' || p_hold_source_rec.hold_entity_id);
	END IF;
	oe_header_util.query_row ( p_header_id  => p_hold_source_rec.hold_entity_id,
				   x_header_rec => l_header_rec);
     END IF; -- p_hold_source_rec.hold_entity_id is NOT NULL

     IF p_hold_source_rec.line_id is not NULL THEN
	IF l_debug_level  > 0 THEN
	   oe_debug_pub.add(' p_hold_source_rec.line_id : ' || p_hold_source_rec.line_id );
	END IF;
	oe_line_util.query_row(
				p_line_id  => p_hold_source_rec.line_id
			       ,x_line_rec => l_line_rec
		              );
     END IF;

  -- XXXX Do we need to generate req_id here
     OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(p_header_rec       => l_header_rec
					,p_line_rec         => l_line_rec
					,p_hold_source_id   => p_hold_source_rec.hold_source_id
					,p_change_type      => 'APPLY');

  ELSE --p_hold_source_rec.hold_entity_code = 'O'

     IF l_debug_level  > 0 THEN
	oe_debug_pub.add(' p_hold_source_rec.hold_entity_code ' || p_hold_source_rec.hold_entity_code);
     END IF;

     IF p_hold_source_rec.header_id is NOT NULL THEN
	oe_header_util.query_row ( p_header_id  => p_hold_source_rec.header_id,
				   x_header_rec => l_header_rec);
     END IF;
     IF p_hold_source_rec.line_id is not NULL THEN
	oe_line_util.query_row(
				p_line_id  => p_hold_source_rec.line_id
				,x_line_rec => l_line_rec
				);
     END IF;

  -- XXXX Do we need to generate req_id here
    OE_SYNC_ORDER_PVT.SYNC_HEADER_LINE(p_header_rec       => l_header_rec
				       ,p_line_rec         => l_line_rec
				       ,p_hold_source_id   => p_hold_source_rec.hold_source_id
				       ,p_change_type      => 'APPLY');
  END IF; --p_hold_source_rec.hold_entity_code = 'O'
END IF;
-- GENESIS --

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );
    WHEN OTHERS THEN
        --ROLLBACK TO APPLY_HOLDS_PUB;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF     OE_MSG_PUB.Check_Msg_Level
          (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
          OE_MSG_PUB.Add_Exc_Msg
               (   G_PKG_NAME
                    ,   l_api_name
                    );
        END IF;
        OE_MSG_PUB.Count_And_Get
          (   p_count    =>   x_msg_count
          ,   p_data     =>   x_msg_data
          );

END Create_Order_Holds;


END OE_HOLDS_PVT;


/
