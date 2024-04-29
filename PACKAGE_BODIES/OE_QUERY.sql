--------------------------------------------------------
--  DDL for Package Body OE_QUERY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_QUERY" as
/* $Header: OEXQRYSB.pls 120.1 2006/11/19 18:01:41 ssurapan noship $ */


------------------------------------------------------------------------
-- 1. if LINE_TYPE_CODE is 'PARENT', get the extended_price from the
--    shipment_schedule_line_id = current line_id
-- 2. if not, check the ITEM_TYPE_CODE
-- 2.1 if 'MODEL', get current line's extended_price
--     + parent_line_id = current line_id 's extended_price
--     + service_parent_line_id = current line_id 's extended_price
-- 2.2 if'SERVICE', check serviceable_duration, if 0 then total is 0
--     if not,get current extended_price
-- 2.3 otherwise, check service_flag='Y',
-- 2.3.1 TRUE : get current line's extend_price +
--       service_parent_line_id = current line_id 's extended price
-- 2.3.2 FALSE : get current line's extended_price
------------------------------------------------------------------------
function LINE_TOTAL(
   ORDER_ROWID           IN VARCHAR2
 , ORDER_LINE_ID         IN NUMBER DEFAULT NULL
 , LINE_TYPE_CODE        IN VARCHAR2
 , ITEM_TYPE_CODE        IN VARCHAR2
 , SERVICE_DURATION      IN NUMBER
 , SERVICEABLE_FLAG      IN VARCHAR2
 , ORDERED_QTY           IN NUMBER
 , CANCELLED_QTY         IN NUMBER
 , SELLING_PRICE         IN NUMBER
                      )
  return NUMBER
IS
  order_line_total NUMBER := NULL ;
BEGIN

   if ( LINE_TYPE_CODE = 'PARENT' )
    then
      SELECT NVL(SUM( (NVL( ORDERED_QUANTITY, 0 ) -
                       NVL( CANCELLED_QUANTITY, 0 )) *
                      NVL(SELLING_PRICE, 0 ))
                    , 0)
      INTO   order_line_total
      FROM   SO_LINES
      WHERE  SHIPMENT_SCHEDULE_LINE_ID = ORDER_LINE_ID;
   elsif ( ITEM_TYPE_CODE = 'MODEL' )
   then
      SELECT NVL(SUM((NVL( ORDERED_QUANTITY, 0 ) -
                     NVL( CANCELLED_QUANTITY, 0 )) *
                    NVL(SELLING_PRICE, 0 ))
                 , 0)
      INTO   order_line_total
      FROM   SO_LINES
      WHERE  (ROWID = ORDER_ROWID
      OR     PARENT_LINE_ID = ORDER_LINE_ID
      OR     SERVICE_PARENT_LINE_ID = ORDER_LINE_ID );

   elsif (ITEM_TYPE_CODE = 'SERVICE')
   then
      if (SERVICE_DURATION = 0)
      then
         order_line_total := 0;
      else
         order_line_total := ( ORDERED_QTY - CANCELLED_QTY)
                             * SELLING_PRICE;
      end if;
   elsif (SERVICEABLE_FLAG= 'Y')
   then
      SELECT NVL(SUM((NVL( ORDERED_QUANTITY, 0 ) -
                      NVL( CANCELLED_QUANTITY, 0 )) *
                     NVL(SELLING_PRICE, 0 ))
                 , 0)
      INTO   order_line_total
      FROM   SO_LINES
      WHERE  (ROWID = ORDER_ROWID
      OR     SERVICE_PARENT_LINE_ID = ORDER_LINE_ID );
   else
      order_line_total := ( nvl(ORDERED_QTY,0) - nvl(CANCELLED_QTY,0))
                             * nvl(SELLING_PRICE,0);
   end if ;

   return(order_line_total);

Exception WHEN NO_DATA_FOUND then
  return(NULL);

END;

------------------------------------------------------------------------
-- Service Total for shipments and options
------------------------------------------------------------------------

function SERVICE_TOTAL(
   P_ROWID               IN VARCHAR2
 , P_LINE_ID             IN NUMBER
 , P_LINES_LINE_ID       IN NUMBER
 , P_ITEM_TYPE_CODE      IN VARCHAR2
 , P_SERVICEABLE_FLAG    IN VARCHAR2
                      )
  return NUMBER

IS

  Service_Total   NUMBER;

BEGIN

   if (P_serviceable_Flag <> 'Y') then
      return (NULL);
   end if;

   if (P_Item_Type_Code = 'MODEL') then

	SELECT  NVL( SUM( DECODE( SERVICE_PARENT_LINE_ID, P_LINES_LINE_ID,
                  (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 ) ) *
                         NVL( SELLING_PRICE, 0 )
                  , 0 ) ), 0 )
	INTO Service_Total
	FROM SO_LINES
	WHERE (ROWID = P_ROWID
	OR     PARENT_LINE_ID = P_LINE_ID
	OR     SERVICE_PARENT_LINE_ID = P_LINE_ID );
  else
        SELECT  NVL( SUM( DECODE( SERVICE_PARENT_LINE_ID, P_LINES_LINE_ID,
                  (NVL( ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 ) ) *
                         NVL( SELLING_PRICE, 0 )
                  , 0 ) ), 0 )
        INTO Service_Total
	FROM SO_LINES
        WHERE (ROWID = P_ROWID
        OR     SERVICE_PARENT_LINE_ID = P_LINE_ID );

  end if;

   return(Service_Total);

EXCEPTION WHEN NO_DATA_FOUND then

  return(NULL);

END;


function SCHEDULE_STATUS(
	SCHEDULE_STATUS_CODE IN VARCHAR2
	)
	return VARCHAR2 is

schedule_status VARCHAR2(80) := NULL;

begin

  if (  schedule_status_code is not null )
  then
     select meaning
     into  schedule_status
     from   so_lookups
     where  lookup_code =  schedule_status_code
     and    lookup_type = 'SCHEDULE STATUS';
  end if;

  return( SCHEDULE_STATUS );
Exception

WHEN NO_DATA_FOUND
then
  return(NULL);

end SCHEDULE_STATUS;


------------------------------------------------------------------------
-- The schedule status code priority is 'RESERVED' > 'SUPPLY RESERVED'
-- > 'DEMAND', return the highest priority code to the line. If none
-- of above, the status code is null;
------------------------------------------------------------------------
function SCHEDULE_STATUS(
   ORDER_LINE_ID         IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2
IS
   schedule_status_code VARCHAR2(30) := NULL;
   schedule_status VARCHAR2(80) := NULL;
begin
  SELECT DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                                  'RESERVED', SLD.QUANTITY, 0 ) ), 0),
                0,
                DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                            'SUPPLY RESERVED', SLD.QUANTITY, 0 ) ), 0),
                        0,
                        DECODE( NVL( SUM( DECODE(
                                      SLD.SCHEDULE_STATUS_CODE,
                                      'DEMANDED', SLD.QUANTITY, 0 ) ),0 ),
                                0, NULL,
                                'DEMANDED' ),
                        'SUPPLY RESERVED' ),
                 'RESERVED' )
  INTO schedule_status_code
  FROM SO_LINE_DETAILS SLD
  WHERE SLD.LINE_ID = ORDER_LINE_ID;

  if (  schedule_status_code is not null )
  then
     select meaning
     into  schedule_status
     from   so_lookups
     where  lookup_code =  schedule_status_code
     and    lookup_type = 'SCHEDULE STATUS';
  end if;

  return( SCHEDULE_STATUS );
Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end ;

------------------------------------------------------------------------
-- The schedule status code priority is 'RESERVED' > 'SUPPLY RESERVED'
-- > 'DEMAND', return the highest priority code to the line. If none
-- of above, the status code is null;
------------------------------------------------------------------------
function SCHEDULE_STATUS_CODE (
   ORDER_LINE_ID         IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2
IS
   schedule_status_code VARCHAR2(30) := NULL;
begin
  SELECT DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                                  'RESERVED', SLD.QUANTITY, 0 ) ), 0),
                0,
                DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                            'SUPPLY RESERVED', SLD.QUANTITY, 0 ) ), 0),
                        0,
                        DECODE( NVL( SUM( DECODE(
                                      SLD.SCHEDULE_STATUS_CODE,
                                      'DEMANDED', SLD.QUANTITY, 0 ) ),0 ),
                                0, NULL,
                                'DEMANDED' ),
                        'SUPPLY RESERVED' ),
                 'RESERVED' )
  INTO schedule_status_code
  FROM SO_LINE_DETAILS SLD
  WHERE SLD.LINE_ID = ORDER_LINE_ID;

  return( SCHEDULE_STATUS_CODE );

Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end ;

------------------------------------------------------------------------
-- To get the ato_indicator for model
------------------------------------------------------------------------

function ATO_Indicator( P_Line_Id IN NUMBER,
			P_Item_Type_Code IN VARCHAR2)
   return VARCHAR2
IS
   ATO_Ind    VARCHAR2(1);
begin

  if (P_Item_Type_Code <> 'MODEL') then
     ATO_Ind := 'N';
  else
	SELECT  DECODE( COUNT(*), 0, 'N', 'Y' )
       		INTO   ATO_Ind
        FROM    SO_LINES
        WHERE   PARENT_LINE_ID = P_Line_Id
        	AND    SERVICE_PARENT_LINE_ID IS NULL
        	AND    ATO_FLAG = 'Y'
        	AND    ROWNUM = 1;
  end if;

  return(ATO_Ind);

Exception
WHEN OTHERS
then
  return(NULL);
end ;

------------------------------------------------------------------------
-- To get the ato_indicator for model
------------------------------------------------------------------------

function Get_ATO_Indicator( P_Line_Id IN NUMBER,
                        P_Item_Type_Code IN VARCHAR2)
   return VARCHAR2
IS
   ATO_Ind    VARCHAR2(1);
begin

  if (P_Item_Type_Code <> 'MODEL') then
     ATO_Ind := 'N';
  else
        SELECT  DECODE( COUNT(*), 0, 'N', 'Y' )
                INTO   ATO_Ind
        FROM    SO_LINES
        WHERE   PARENT_LINE_ID = P_Line_Id
                AND    SERVICE_PARENT_LINE_ID IS NULL
                AND    ATO_FLAG = 'Y'
                AND    ROWNUM = 1;
  end if;

  return(ATO_Ind);

Exception
WHEN OTHERS
then
  return(NULL);
end ;



------------------------------------------------------------------------
-- from So_Line_DETAILS table to get released quantity for a line.
------------------------------------------------------------------------
FUNCTION Released_Quantity(P_Line_Id IN NUMBER) RETURN NUMBER IS
	Config_Item_Flag VARCHAR2(1) := NULL;
	rel_qty NUMBER := 0;
	total_rel_qty NUMBER := 0;
	CURSOR C_Get_Released_Quantity (X_Line_Id IN NUMBER) IS
	SELECT sum(nvl(quantity, 0)),  configuration_item_flag
	FROM so_line_details
	WHERE line_id = X_Line_Id
	AND   nvl(included_item_flag, 'N') = 'N'
	AND   nvl(released_flag, 'Y') = 'Y'
	GROUP BY configuration_item_flag;
BEGIN

	OPEN C_Get_Released_Quantity (P_Line_Id);

	LOOP

	  FETCH C_Get_Released_Quantity
	  INTO  rel_qty, config_item_flag;

	  EXIT WHEN C_Get_Released_Quantity%NOTFOUND;

	  IF (config_item_flag = 'Y') THEN
	    RETURN (rel_qty);
	  END IF;

	  total_rel_qty := total_rel_qty + rel_qty;

	END LOOP;

	RETURN (total_rel_qty);

EXCEPTION

	WHEN OTHERS THEN
		RAISE;

END Released_Quantity;

FUNCTION P_Line_Released_Quantity(P_Line_Id IN NUMBER) RETURN NUMBER IS
        rel_qty NUMBER := 0;
BEGIN

	SELECT SUM(NVL(REQUESTED_QUANTITY,0))
	INTO   rel_qty
	FROM   SO_PICKING_LINE_DETAILS
   	WHERE  PICKING_LINE_ID = P_LINE_ID
	AND    NVL(RELEASED_FLAG,'N')='Y';
        RETURN (rel_qty);

EXCEPTION

        WHEN OTHERS THEN
                RAISE;

END P_LINE_Released_Quantity;




------------------------------------------------------------------------
-- from So_Line_DETAILS table to get all reserved details quantity
------------------------------------------------------------------------
function RESERVED_QUANTITY(
   ORDER_LINE_ID        IN NUMBER DEFAULT NULL
                              )
   return NUMBER
IS
   RESERVED_QTY NUMBER := NULL ;
BEGIN

  select sum( decode( SCHEDULE_STATUS_CODE,
                      'RESERVED', QUANTITY,
                      0))
  into RESERVED_QTY
  from SO_LINE_DETAILS
  where line_id = ORDER_LINE_ID
  and NVL(INCLUDED_ITEM_FLAG, 'N')='N';

  return( RESERVED_QTY);

EXCEPTION
when NO_DATA_FOUND
then
  return(NULL);
END ;


------------------------------------------------------------------------
-- from So_Line_DETAILS table to get all reserved details quantity
-- for the included item.
------------------------------------------------------------------------
function II_RESERVED_QUANTITY(
   P_LINE_ID             IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return NUMBER
IS
   RESERVED_QTY NUMBER := NULL ;
BEGIN

/* Modified the following where clause to fix bug# 925562, propagated from
   Rel 11 - 896589. Replaced ltrim(...  by  p_component_code
*/
  select sum(nvl(det.quantity, 0))
  into   reserved_qty
  from   so_lines   l,
	 so_line_details det
  where
	 l.line_id = p_line_id
  and    det.line_id = l.line_id
  and	 det.included_item_flag = 'Y'
  and    det.schedule_status_code = 'RESERVED'
--  and    det.component_code = l.component_code ||
--			      ltrim(p_component_code, '0123456789');
  and    det.component_code = p_component_code;

  return( RESERVED_QTY);

EXCEPTION
when NO_DATA_FOUND
then
  return(NULL);
END ;



------------------------------------------------------------------------
-- from So_Line_DETAILS table to get all reserved details quantity
-- for the included item.
------------------------------------------------------------------------

function II_RELEASED_QUANTITY(
   P_LINE_ID             IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return NUMBER
IS
   RELEASED_QTY NUMBER := NULL ;
BEGIN

/* Modified the following where clause to fix bug# 925562, propagated from
   Rel 11 - 896589. Replaced ltrim(...  by  p_component_code
*/
  select sum(nvl(det.quantity, 0))
  into   released_qty
  from   so_lines   l,
	 so_line_details det
  where
	 l.line_id = p_line_id
  and    det.line_id = l.line_id
  and    det.released_flag = 'Y'
  and	det.included_item_flag = 'Y'
--  and    det.component_code = l.component_code ||
--			      ltrim(p_component_code, '0123456789');
  and    det.component_code = p_component_code;

  return( RELEASED_QTY);

EXCEPTION
when NO_DATA_FOUND
then
  return(NULL);
END ;



------------------------------------------------------------------------
-- The schedule status code priority is 'RESERVED' > 'SUPPLY RESERVED'
-- > 'DEMAND', return the highest priority code to the line. If none
-- of above, the status code is null;
------------------------------------------------------------------------
function II_SCHEDULE_STATUS_CODE (
   P_LINE_ID         IN NUMBER,
   P_COMPONENT_CODE	 IN VARCHAR2
                              )
   return VARCHAR2
IS
   schedule_status_code VARCHAR2(30) := NULL;
begin
/* Modified the following where clause to fix bug# 925562, propagated from
   Rel 11 - 896589. Replaced ltrim(...  by  p_component_code
*/
  SELECT DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                                  'RESERVED', SLD.QUANTITY, 0 ) ), 0),
                0,
                DECODE( NVL( SUM( DECODE( SLD.SCHEDULE_STATUS_CODE,
                            'SUPPLY RESERVED', SLD.QUANTITY, 0 ) ), 0),
                        0,
                        DECODE( NVL( SUM( DECODE(
                                      SLD.SCHEDULE_STATUS_CODE,
                                      'DEMANDED', SLD.QUANTITY, 0 ) ),0 ),
                                0, NULL,
                                'DEMANDED' ),
                        'SUPPLY RESERVED' ),
                 'RESERVED' )
  INTO schedule_status_code
  FROM
	SO_LINES	SL,
	SO_LINE_DETAILS SLD
  WHERE
	SL.line_id = P_Line_Id
and	SLD.Line_id = SL.Line_Id
and	SLD.Included_Item_Flag = 'Y'
--and     SLD.Component_Code = SL.Component_Code ||
--			     ltrim(P_Component_Code, '0123456789');
and     SLD.Component_Code = P_Component_Code;

  return( SCHEDULE_STATUS_CODE );

Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end ;



------------------------------------------------------------------------
-- Return 'Y' if there are supply reserved details for this line.
-- Otherwise, return 'N'
-----------------------------------------------------------------------

function SUPPLY_RES_DETAILS(
   P_Line_Id        IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2
IS
   Supply_Reserved_Details VARCHAR2(1):= 'N';

BEGIN

  select 'Y'
  into Supply_Reserved_Details
  from so_line_details
  where
	line_id = P_Line_Id
  and	schedule_status_code = 'SUPPLY RESERVED'
  and   rownum = 1;

  return(Supply_Reserved_Details);

EXCEPTION
when NO_DATA_FOUND
then
  return('N');
END ;



------------------------------------------------------------------------
-- Check any hold from line or header in the table SO_ORDER_HOLDS_ALL.
-----------------------------------------------------------------------
function HOLD(
   ORDER_LINE_ID           IN NUMBER DEFAULT NULL
,  ORDER_HEADER_ID         IN NUMBER DEFAULT NULL
              )
   return VARCHAR2
IS
  HOLD_FLAG VARCHAR2(1);
BEGIN
   SELECT DECODE( NVL(SUM(DECODE( HOLD_RELEASE_ID, NULL, 1, 0)),0),
           0,'N', 'Y')
   INTO   HOLD_FLAG
   FROM   SO_ORDER_HOLDS_ALL
   WHERE  LINE_ID = ORDER_LINE_ID
   OR    (LINE_ID IS NULL AND HEADER_ID = ORDER_HEADER_ID);

   RETURN( HOLD_FLAG );

EXCEPTION
WHEN NO_DATA_FOUND
THEN
   RETURN('N');
END; -- HOLD

----------------------------------------------------------------------
-- SHIPMENT_SCHEDULE_NUMBER is a better function to figure out
-- shipment_number because it takes service lines into consideration.
-- Should use SHIPMENT_SCHEDULE_NUMBER whenever possible.
----------------------------------------------------------------------
function SHIPMENT_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   SHIP_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  ORDER_SHIP_SCHEDULE_LINE_ID IS NOT NULL ) -- if null, return null
   THEN
      IF( ORDER_PARENT_LINE_ID IS NULL )
      THEN
          SHIP_NUMBER := ORDER_LINE_NUMBER;
      ELSE
         SELECT LINE_NUMBER
         INTO   SHIP_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = ORDER_PARENT_LINE_ID;
      END IF;
   END IF;

   RETURN( SHIP_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- SHIPMENT_NUMBER


----------------------------------------------------------------------
-- BASE_LINE_NUMBER is a better function to figure out line_number
-- because it takes service lines into consideration.
-- Should use BASE_LINE_NUMBER whenever possible.
----------------------------------------------------------------------
function LINE_NUMBER(
   ORDER_LINE_ID                       IN NUMBER DEFAULT NULL
,  ORDER_SHIP_SCHEDULE_LINE_ID         IN NUMBER DEFAULT NULL
,  ORDER_PARENT_LINE_ID                IN NUMBER DEFAULT NULL
,  ORDER_LINE_NUMBER                   IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   LINES_NUMBER NUMBER := NULL;
BEGIN

   IF (  ORDER_SHIP_SCHEDULE_LINE_ID IS NULL)
   THEN
      IF (  ORDER_PARENT_LINE_ID IS NULL)
      THEN
          LINES_NUMBER :=  ORDER_LINE_NUMBER ;
      ELSE
         SELECT LINE_NUMBER
         INTO   LINES_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = ORDER_PARENT_LINE_ID;
      END IF;
   ELSE
      SELECT LINE_NUMBER
      INTO   LINES_NUMBER
      FROM   SO_LINES
      WHERE  LINE_ID = ORDER_SHIP_SCHEDULE_LINE_ID;
   END IF;

   RETURN( LINES_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ;


------------------------------------------------------------------------
function ITEM_CONC_SEG(
   ITEM_ID        IN NUMBER DEFAULT NULL
,  ORG_ID         IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2
IS
  ITEM_NAME VARCHAR2(81);
BEGIN
  SELECT CONCATENATED_SEGMENTS
  INTO   ITEM_NAME
  FROM   MTL_SYSTEM_ITEMS_KFV
  WHERE  INVENTORY_ITEM_ID = ITEM_ID
  AND    ORGANIZATION_ID = ORG_ID;

  RETURN(ITEM_NAME);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- ITEM


------------------------------------------------------------------------
-- Input a Order_Type_Id, search for so_headers to get the Order_Type
-- of that line.
------------------------------------------------------------------------
function ORDER_TYPE(
  ID         IN NUMBER DEFAULT NULL
                          )
   return VARCHAR2
IS
  ORDER_TYPE   VARCHAR2(80);
BEGIN
  SELECT NAME
  INTO   ORDER_TYPE
  FROM   SO_ORDER_TYPES
  WHERE  ORDER_TYPE_ID = ID;

  RETURN(ORDER_TYPE);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ;

  --
  -- NAME
  --  Order_Total
  --
  --
  FUNCTION Order_Total(Header_Id IN NUMBER) Return NUMBER IS

    CURSOR C_Ord_Total(X_Header_Id NUMBER) IS
      SELECT NVL(SUM( (NVL( l.ordered_quantity, 0) -
		       NVL( l.cancelled_quantity, 0)) *
		       NVL( l.selling_price, 0)), 0)  ORDER_TOTAL
      FROM   so_lines l
      WHERE  l.header_id = X_Header_Id
      AND    l.line_type_code IN ('REGULAR', 'DETAIL','RETURN');

    Ord_Total NUMBER;
  begin
    -- For bug# 610993. This was changing the record status to INSERT in case
    -- of NEW records eventhough nothing is changed.(since the above select
    -- returns value '0' if header_id is null)
    IF Header_Id is NULL then
       return NULL;
    END IF;
    OPEN C_Ord_Total(Header_Id);
    FETCH C_Ord_Total INTO Ord_Total;
    CLOSE C_Ord_Total;
    return(Ord_Total);
  end Order_Total;

function Shipment_Total(P_Line_Id IN NUMBER) return NUMBER
IS
  line_total NUMBER := NULL ;
BEGIN

      SELECT NVL(SUM( (NVL( ORDERED_QUANTITY, 0 ) -
                       NVL( CANCELLED_QUANTITY, 0 )) *
                      NVL(SELLING_PRICE, 0 ))
                    , 0)
      INTO   line_total
      FROM   SO_LINES
      WHERE  SHIPMENT_SCHEDULE_LINE_ID = P_Line_Id;

   return(line_total);

Exception WHEN NO_DATA_FOUND then
  return(NULL);

END;


FUNCTION  Configuration_Total
(
        Config_Parent_Line_Id               IN NUMBER
) RETURN NUMBER

is

        L_Configuration_Total NUMBER;

begin


SELECT NVL(SUM((NVL(ORDERED_QUANTITY, 0 ) -
                         NVL( CANCELLED_QUANTITY, 0 )) *
                         NVL(SELLING_PRICE, 0 )),0)
       INTO   L_Configuration_Total
       FROM   SO_LINES
       WHERE (LINE_ID = Config_Parent_Line_Id
       OR     PARENT_LINE_ID = Config_Parent_Line_Id
       OR     SERVICE_PARENT_LINE_ID =
              Config_Parent_Line_Id );

 return(L_Configuration_Total);

end Configuration_Total;


----------------------------------------------------------------
-- Returns Order Number if Copied Order
----------------------------------------------------------------
Function Source_Order_number
       ( P_ORIGINAL_SYSTEM_SOURCE_CODE VARCHAR2,
         P_ORIGINAL_SYSTEM_REFERENCE VARCHAR2
       ) return VARCHAR2 is
rtn_value varchar2(50);
begin
  if P_ORIGINAL_SYSTEM_SOURCE_CODE = '2' then
     begin
        select to_char(ord.order_number)
        into rtn_value
        from so_headers ord
        where ord.header_id = decode(rtrim(p_original_system_reference,
                                        '0123456789'),
                                null,to_number(p_original_system_reference),
                                    null);
     exception when others then
               rtn_value := p_original_system_reference;
     end;
  else
     rtn_value := p_original_system_reference;
  end if;
  return(rtn_value);
end Source_Order_number;
----------------------------------------------------------------
-- Returns Order Type of the source Order
----------------------------------------------------------------
Function Source_Order_Type
       ( P_ORIGINAL_SYSTEM_SOURCE_CODE VARCHAR2,
         P_ORIGINAL_SYSTEM_REFERENCE VARCHAR2
       ) return VARCHAR2 is
rtn_value varchar2(50);
begin
  if P_ORIGINAL_SYSTEM_SOURCE_CODE = '2' then
     begin
        select typ.name
        into rtn_value
        from so_headers ord,
             so_order_types typ
        where typ.order_type_id = ord.order_type_id
        and ord.header_id = decode(rtrim(p_original_system_reference,
                                        '0123456789'),
                                null,to_number(p_original_system_reference),
                                    null);
     exception when others then
               rtn_value := NULL;
     end;
  else
     rtn_value := NULL;
  end if;
  return(rtn_value);
end Source_Order_Type;



-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Returns total received quantity of the given line_id
-- from the MTL_SO_RMA_INTERFACE table
--
-----------------------------------------------------------
function Received_qty( p_line_id NUMBER)
         RETURN NUMBER  IS

        L_Qty_Ordered NUMBER;
	l_qty_received number;
	l_interface_id number;
	l_cancel_qty so_lines.cancelled_quantity%TYPE;
	l_link_to_line_id so_lines.link_to_line_id%TYPE;
	l_item_type so_lines.item_type_code%TYPE;
	l_ato_flag so_lines.ato_flag%TYPE;
	l_included_item_count number;
        L_S29 NUMBER;
        L_Shipped_Quantity NUMBER;

BEGIN

select 	Ordered_Quantity,
        nvl(cancelled_quantity, 0),
	link_to_line_id,
	item_type_code,
	Ato_Flag,
        S29,
        Shipped_quantity
into	L_Qty_Ordered,
        l_cancel_qty,
	l_link_to_line_id,
	l_item_type,
        L_Ato_Flag,
        L_S29,
        L_Shipped_quantity
from 	so_lines
where 	line_id = p_line_id;


IF (l_qty_ordered > l_cancel_qty) THEN
	select 	floor(
	  	 nvl( min( mtlint.received_quantity *
	    	  (lin.Ordered_Quantity - nvl(lin.cancelled_quantity,0)) /
	           mtlint.interfaced_quantity),0))
        into 	l_qty_received
	from	so_rma_mtl_int_v mtlint,
		so_lines lin
	where   mtlint.rma_line_id = p_line_id
	and     lin.line_id = p_line_id
	group by lin.line_id,
		 lin.ordered_quantity,
		 lin.cancelled_quantity;
ELSE /* Case where there are no items to receive for this line  */
     /* All RMA'ed items were cancelled.  This causes divide by */
     /* zero error in the above statement                       */

    /* Original order reference exists for this line */
    IF (l_link_to_line_id is not NULL) THEN

	/* For PTO Models, we need get the included item ratios  */
    	IF ((l_ato_flag = 'N') AND
	    ((l_item_type = 'CLASS') OR
	     (l_item_type = 'MODEL') OR
	     (l_item_type = 'KIT'))) THEN

	    SELECT 	count (line_detail_id)
	    INTO	l_included_item_count
	    FROM 	so_line_details
	    WHERE	line_id = l_link_to_line_id
	    AND 	included_item_flag = 'Y';

	    /* Components are frozen so ratios exist */
	    IF (l_included_item_count > 0) THEN
		SELECT floor(nvl(min(MTLINT.Received_Quantity),0))
		INTO l_qty_received
		FROM   SO_RMA_MTL_INT_DETAIL_V MTLINT
		WHERE  MTLINT.Detail_line_id = l_link_to_line_id
		AND    MTLINT.RMA_LINE_ID = P_Line_Id;

	    /* Components were not frozen at the time return was created.  */
 	    /* No ratios exist, so null out the field.			   */
	    ELSE
		l_qty_received := NULL;

	    END IF;

	/* Not a PTO model.  No BOM explosion occurred, so received  */
    	/* calcuation is straight forward, not requiring any ratios. */
    	ELSE
	    SELECT sum(nvl(MTLSRR.received_quantity,0))
	    INTO   l_qty_received
	    FROM   MTL_SO_RMA_RECEIPTS MTLSRR
	    ,      MTL_SO_RMA_INTERFACE MTLSRI
	    WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
	    AND    MTLSRI.RMA_LINE_ID = p_line_id;
      	END IF;

    /* No original reference exists.  No BOM explosion occurred   */
    /* so received calcuation is straight forward, not requiring  */
    /* any ratios.						  */
    ELSE
	SELECT sum(nvl(MTLSRR.received_quantity,0))
	INTO   l_qty_received
        FROM   MTL_SO_RMA_RECEIPTS MTLSRR
	,      MTL_SO_RMA_INTERFACE MTLSRI
	WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
	AND    MTLSRI.RMA_LINE_ID = p_line_id;
    END IF;
END IF;

IF (l_s29 = 17 and l_qty_received = 0 ) then
   	select min(rma_interface_id)
     	    into l_interface_id
       	    from mtl_so_rma_interface
     	    where rma_line_id = p_line_id;
ELSE
   	RETURN(l_qty_received);
END IF;

RETURN(l_qty_received);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   l_qty_received := nvl(l_shipped_quantity,0);
   RETURN(l_qty_received);

END;



-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Returns the total accepted quantity of the given line_id
-- from the MTL_SO_RMA_INTERFACE table
--
-----------------------------------------------------------
function Accepted_qty( p_line_id NUMBER)
         RETURN NUMBER  IS

        L_Qty_Ordered NUMBER;
	l_qty_received number;
	l_interface_id number;
	l_cancel_qty so_lines.cancelled_quantity%TYPE;
	l_link_to_line_id so_lines.link_to_line_id%TYPE;
	l_item_type so_lines.item_type_code%TYPE;
	l_ato_flag so_lines.ato_flag%TYPE;
	l_included_item_count number;
        L_S29 NUMBER;
        L_Shipped_Quantity NUMBER;

BEGIN

select 	Ordered_Quantity,
        nvl(cancelled_quantity, 0),
	link_to_line_id,
	item_type_code,
	Ato_Flag,
        S29,
        Shipped_quantity
into	L_Qty_Ordered,
        l_cancel_qty,
	l_link_to_line_id,
	l_item_type,
        L_Ato_Flag,
        L_S29,
        L_Shipped_quantity
from 	so_lines
where 	line_id = p_line_id;


IF (l_qty_ordered > l_cancel_qty) THEN
	select 	floor(
	  	 nvl( min( mtlint.accepted_quantity *
	    	  (lin.Ordered_Quantity - nvl(lin.cancelled_quantity,0)) /
	           mtlint.interfaced_quantity),0))
        into 	l_qty_received
	from	so_rma_mtl_int_v mtlint,
		so_lines lin
	where   mtlint.rma_line_id = p_line_id
	and     lin.line_id = p_line_id
	group by lin.line_id,
		 lin.ordered_quantity,
		 lin.cancelled_quantity;
ELSE /* Case where there are no items to receive for this line  */
     /* All RMA'ed items were cancelled.  This causes divide by */
     /* zero error in the above statement                       */

    /* Original order reference exists for this line */
    IF (l_link_to_line_id is not NULL) THEN

	/* For PTO Models, we need get the included item ratios  */
    	IF ((l_ato_flag = 'N') AND
	    ((l_item_type = 'CLASS') OR
	     (l_item_type = 'MODEL') OR
	     (l_item_type = 'KIT'))) THEN

	    SELECT 	count (line_detail_id)
	    INTO	l_included_item_count
	    FROM 	so_line_details
	    WHERE	line_id = l_link_to_line_id
	    AND 	included_item_flag = 'Y';

	    /* Components are frozen so ratios exist */
	    IF (l_included_item_count > 0) THEN
		SELECT floor(nvl(min(MTLINT.Accepted_Quantity),0))
		INTO l_qty_received
		FROM   SO_RMA_MTL_INT_DETAIL_V MTLINT
		WHERE  MTLINT.Detail_line_id = l_link_to_line_id
		AND    MTLINT.RMA_LINE_ID = P_Line_Id;

	    /* Components were not frozen at the time return was created.  */
 	    /* No ratios exist, so null out the field.			   */
	    ELSE
		l_qty_received := NULL;

	    END IF;

	/* Not a PTO model.  No BOM explosion occurred, so received  */
    	/* calcuation is straight forward, not requiring any ratios. */
    	ELSE
	    SELECT sum(nvl(MTLSRR.accepted_quantity,0))
	    INTO   l_qty_received
	    FROM   MTL_SO_RMA_RECEIPTS MTLSRR
	    ,      MTL_SO_RMA_INTERFACE MTLSRI
	    WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
	    AND    MTLSRI.RMA_LINE_ID = p_line_id;
      	END IF;

    /* No original reference exists.  No BOM explosion occurred   */
    /* so received calcuation is straight forward, not requiring  */
    /* any ratios.						  */
    ELSE
	SELECT sum(nvl(MTLSRR.accepted_quantity,0))
	INTO   l_qty_received
        FROM   MTL_SO_RMA_RECEIPTS MTLSRR
	,      MTL_SO_RMA_INTERFACE MTLSRI
	WHERE  MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
	AND    MTLSRI.RMA_LINE_ID = p_line_id;
    END IF;
END IF;

IF (l_s29 = 17 and l_qty_received = 0 ) then
   	select min(rma_interface_id)
     	    into l_interface_id
       	    from mtl_so_rma_interface
     	    where rma_line_id = p_line_id;
ELSE
   	RETURN(l_qty_received);
END IF;

RETURN(l_qty_received);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   l_qty_received := nvl(l_shipped_quantity,0);
   RETURN(l_qty_received);

END;



-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Returns the latest received date for the given line_id
-- from the MTL_SO_RMA_INTERFACE table
--
-----------------------------------------------------------
function Received_Date( p_line_id NUMBER,
			P_S29_DATE DATE)
         RETURN DATE  IS

   L_Received_Date DATE;

BEGIN

SELECT	MAX( MTLSRR.RECEIPT_DATE )
INTO	L_Received_Date
FROM	MTL_SO_RMA_RECEIPTS MTLSRR
,      	MTL_SO_RMA_INTERFACE MTLSRI
WHERE  	MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
AND    	MTLSRI.RMA_LINE_ID = p_line_id
AND	MTLSRR.RECEIVED_QUANTITY > 0;

RETURN (L_RECEIVED_DATE);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN (P_S29_DATE);
END;





-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Returns the latest accetped date for the given line_id
-- from the MTL_SO_RMA_INTERFACE table
--
-----------------------------------------------------------
function Accepted_Date( p_line_id NUMBER,
			P_S29_DATE DATE)
         RETURN DATE  IS

   L_Accepted_Date DATE;

BEGIN

SELECT	MAX( MTLSRR.RECEIPT_DATE )
INTO	L_Accepted_Date
FROM	MTL_SO_RMA_RECEIPTS MTLSRR
,      	MTL_SO_RMA_INTERFACE MTLSRI
WHERE  	MTLSRR.RMA_INTERFACE_ID = MTLSRI.RMA_INTERFACE_ID
AND    	MTLSRI.RMA_LINE_ID = p_line_id
AND	MTLSRR.ACCEPTED_QUANTITY > 0;

RETURN (L_ACCEPTED_DATE);

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN (P_S29_DATE);
END;



-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Given the reference code, select tax exemption flag from
-- the proper source ( reference invoice, reference order,
-- or return order ) and return the tax exemption flag
-- display value.
--
-----------------------------------------------------------
FUNCTION  GET_TAX_EXEMPT_FLAG(
			      P_Reference_Code VARCHAR2,
			      P_Invoice_Flag VARCHAR2,
			      P_Order_Flag VARCHAR2,
			      P_No_Ref_Flag VARCHAR2,
			      P_Open_Flag VARCHAR2
			     )
			      RETURN VARCHAR2 IS

L_FLAG VARCHAR2(5);
L_FLAG_DISPLAY VARCHAR2(80);

BEGIN

IF (P_Reference_Code = 'INVOICE') THEN
  IF (P_OPEN_FLAG = 'Y') THEN
    L_Flag := P_Invoice_Flag;
  ELSE
    L_FLag := NULL;
  END IF;
ELSIF (P_Reference_Code IN ('ORDER','PO')) THEN
  L_Flag := P_Order_Flag;
ELSE
  L_Flag := P_No_Ref_Flag;
END IF;

SELECT MEANING
INTO   L_Flag_Display
FROM   AR_LOOKUPS
WHERE  LOOKUP_TYPE = 'TAX_CONTROL_FLAG'
AND    LOOKUP_CODE = L_Flag;


RETURN L_FLAG_DISPLAY;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN NULL;

END;


-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Given the reference code, select tax exemption reason
-- from theproper source ( reference invoice, reference
-- order, or returnorder ) and return the tax exemption
-- reason display value.
--
-----------------------------------------------------------
FUNCTION  GET_TAX_EXEMPT_REASON(
				P_Reference_Code VARCHAR2,
				P_Invoice_reason VARCHAR2,
				P_Order_reason VARCHAR2,
				P_No_Ref_reason VARCHAR2,
				P_Open_Flag VARCHAR2
			       )
				RETURN VARCHAR2 IS

L_REASON VARCHAR2(30);
L_REASON_DISPLAY VARCHAR2(80);

BEGIN

IF (P_Reference_Code = 'INVOICE') THEN
  IF (P_OPEN_FLAG = 'Y') THEN
    L_REASON := P_Invoice_Reason;
  ELSE
    L_REASON := NULL;
  END IF;
ELSIF (P_Reference_Code IN ('ORDER','PO')) THEN
  L_REASON := P_Order_Reason;
ELSE
  L_REASON := P_No_Ref_Reason;
END IF;

SELECT MEANING
INTO  L_REASON_DISPLAY
FROM  AR_LOOKUPS
WHERE LOOKUP_CODE = L_REASON
AND   LOOKUP_TYPE = 'TAX_REASON';

RETURN L_REASON_DISPLAY;

EXCEPTION
 WHEN NO_DATA_FOUND THEN
   RETURN NULL;

END;


-----------------------------------------------------------
--
-- RETURN LINES VIEW
--
-- Return the price adjustment total for the given line.
-- This isthe sum of the line and header price adjustments
-- for the given line.
--
-----------------------------------------------------------
FUNCTION  GET_PRICE_ADJ_TOTAL(
			      P_HEADER_ID NUMBER,
			      P_LINE_ID NUMBER
			      )
			      RETURN NUMBER IS

L_Total NUMBER;

BEGIN

SELECT NVL( SUM( PERCENT ), 0 )
INTO   L_TOTAL
FROM   SO_PRICE_ADJUSTMENTS
WHERE  HEADER_ID = P_HEADER_ID
  AND  (LINE_ID IS NULL
   OR   LINE_ID = P_LINE_ID);

RETURN L_TOTAL;

END;

  --
  -- NAME
  --   Std_Tax_Exemption
  --
  PROCEDURE Get_Std_Tax_Exemption(Ship_To_Site_Use_Id    IN NUMBER,
				  Invoice_To_customer_id IN NUMBER,
				  Date_Ordered		 IN DATE,
				  Tax_Exempt_Number	 OUT NOCOPY VARCHAR2,
				  Tax_Exempt_Reason	 OUT NOCOPY VARCHAR2) is

    CURSOR C_Std_Tax_Exemption(X_Ship_To_Site_Use_Id    NUMBER,
			       X_Invoice_To_customer_id NUMBER,
			       X_Date_Ordered		DATE) is
      SELECT tax.tax_exempt_number,
      	     tax.tax_exempt_reason_meaning
      FROM tax_exemptions_qp_v tax
      WHERE  tax.ship_to_site_use_id = X_Ship_To_Site_Use_Id
      AND    tax.bill_to_customer_id = X_Invoice_To_customer_id
      AND    trunc(NVL(X_Date_Ordered, SYSDATE))
       	     between trunc(tax.start_date) and
                     trunc(NVL(tax.end_date, NVL(X_Date_Ordered, SYSDATE)))
      AND    tax.status_code = 'PRIMARY';

  begin
    OPEN C_Std_Tax_Exemption(Ship_To_Site_Use_Id,
			     Invoice_To_customer_id,
			     Date_Ordered);
    FETCH C_Std_Tax_Exemption INTO Tax_Exempt_Number, Tax_Exempt_Reason;
    CLOSE C_Std_Tax_Exemption;

  end;


  --
  -- Std_Tax_Exempt_Number
  --
  FUNCTION Std_Tax_Exempt_Number(Ship_To_Site_Use_Id    IN NUMBER,
				 Invoice_To_customer_id IN NUMBER,
				 Date_Ordered	        IN DATE)
    Return VARCHAR2 is
     Tax_Exempt_Number VARCHAR2(80);
     Tax_Exempt_Reason VARCHAR2(80);
  begin

    Get_Std_Tax_Exemption(Ship_To_Site_Use_Id,
			  Invoice_To_customer_id,
			  Date_Ordered,
			  Tax_Exempt_Number,
			  Tax_Exempt_Reason);

    Return(Tax_Exempt_Number);
  end;

  --
  -- Std_Tax_Exempt_Reason
  --
  FUNCTION Std_Tax_Exempt_Reason(Ship_To_Site_Use_Id    IN NUMBER,
				 Invoice_To_customer_id IN NUMBER,
				 Date_Ordered	        IN DATE)
    Return VARCHAR2 is
     Tax_Exempt_Number VARCHAR2(80);
     Tax_Exempt_Reason VARCHAR2(80);
  begin

    Get_Std_Tax_Exemption(Ship_To_Site_Use_Id,
			  Invoice_To_customer_id,
			  Date_Ordered,
			  Tax_Exempt_Number,
			  Tax_Exempt_Reason);

    Return(Tax_Exempt_Reason);

  end;

FUNCTION line_config_item_exists(X_line_id IN NUMBER) RETURN VARCHAR2 IS
 l_flag VARCHAR2(1) := 'N';
BEGIN

  SELECT 'Y'
    INTO l_flag
    FROM sys.dual
   WHERE EXISTS (SELECT 1
	           FROM so_line_details
		   WHERE line_id = X_line_id
		     AND configuration_item_flag = 'Y');

  IF (l_flag = 'Y') THEN
	RETURN('Y');
  ELSE
	RETURN('N');
  END IF;

 EXCEPTION
	WHEN NO_DATA_FOUND THEN RETURN('N');



END line_config_item_exists;

FUNCTION line_released_qty(X_line_id IN NUMBER) RETURN NUMBER IS
  l_qty NUMBER := 0;
BEGIN

  SELECT SUM(NVL(quantity,0))
    INTO l_qty
    FROM so_line_Details
   WHERE line_id = X_line_id
     AND NVL(included_item_flag, 'N') = 'N'
     AND NVL(released_flag, 'Y') = 'Y'
     AND NVL(configuration_item_flag, 'N') =
	OE_QUERY.line_config_item_exists(X_line_id);

   RETURN(l_qty);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN(NULL);

END line_released_qty;


FUNCTION lot_expiration(X_inventory_item_id IN NUMBER,
                            X_organization_id IN NUMBER,
                            X_lot_number IN VARCHAR2) RETURN DATE IS
  l_expiration_date DATE;
BEGIN

  SELECT expiration_date
    INTO l_expiration_date
    FROM mtl_lot_numbers
   WHERE inventory_item_id = X_inventory_item_id
     AND organization_id = X_organization_id
     AND lot_number = X_lot_number;

  RETURN(l_expiration_date);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RETURN(NULL);

END lot_expiration;


FUNCTION picking_line_reserved_qty(X_picking_line_id IN NUMBER)
RETURN NUMBER IS
	l_num NUMBER := 0;
BEGIN

  SELECT NVL( SUM( NVL(requested_quantity,0)), 0)
    INTO l_num
    FROM so_picking_line_details
   WHERE schedule_status_code = 'RESERVED'
     AND picking_line_id = X_picking_line_id;

  RETURN(l_num);

END picking_line_reserved_qty;


--
-- Open_Backordered_Quantity:   This function returns the unreleased quantity
-- from the backordered picking lines for a given line.  It sums up the
-- quantity in the SO_PICKING_LINE_DETAILS table for unreleased details.
-- This function ignores picking lines for included items.
-- For ATO Model lines, this quantity will be the backorered amount of the
-- config item
-- For Option Lines for ATO Models, it will return 0, as the options for ATO
-- models never get backordered.
--
-- Input Argument:  X_Line_Id is the line_id from the SO_LINES tables
-- corresponding to the Order Line that you are interested in.
--
-- Return Value:  Returns the total backordered amount for this order line,
-- barring any included items.
--

FUNCTION Open_Backordered_Quantity(X_line_id NUMBER) RETURN NUMBER IS
   l_backordered_quantity NUMBER := 0;
BEGIN

   SELECT Nvl(SUM(pld.requested_quantity),0)
   INTO   l_backordered_quantity
   FROM
          so_picking_lines pl,
          so_picking_line_details pld
   WHERE
          Nvl(pld.released_flag, 'Y') = 'N'
     AND  pld.picking_line_id = pl.picking_line_id
     AND  pl.picking_header_id = 0
     AND  Nvl(pl.included_item_flag, 'N') = 'N'
     AND  pl.order_line_id = x_line_id;

   RETURN l_backordered_quantity;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      RETURN 0;
END Open_Backordered_Quantity;


FUNCTION picking_line_item_id(X_picking_line_id IN NUMBER) return NUMBER is
    item_id NUMBER;
begin

    select inventory_item_id
    into item_id
    from so_picking_lines
    where picking_line_id = X_picking_line_id;

    return (item_id);

end picking_line_item_id;

function ATP_Date_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2,
   P_Inventory_Item_Id In Number)
    return Date
Is
    L_ATP_Date   Date;
Begin
   Select NVL(Min(Group_Available_Date), Min(Request_ATP_Date))
   Into L_ATP_Date
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Line = P_Line_Id
   And   Inventory_Item_Id = P_Inventory_Item_Id
   And   N_Column4 is Null
   Having Count(Distinct Group_Available_Date) = 1
     Or  (Count(Distinct Group_Available_Date) = 0
      And Count(Distinct Request_ATP_Date) = 1);

   return L_ATP_Date;

Exception WHEN Others Then
        return (NULL);

End ATP_Date_Line_Id;

function Available_Quantity_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2,
   P_Inventory_Item_Id In Number)
    return Number
Is
    L_Available_Qty   Number;
Begin
   Select Min(Request_Date_ATP_Quantity)
   Into L_Available_Qty
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Line = P_Line_Id
   And   Inventory_Item_Id = P_Inventory_Item_Id
   And   Line_Item_Quantity > 0
   And   N_Column4 is Null
   Having Count(Demand_Source_Delivery) = 1;

   return L_Available_Qty;

Exception WHEN Others Then
        return (NULL);
End Available_Quantity_Line_Id;

function Demand_Interface_RowId_Line_Id(
   P_Session_id In Number,
   P_Line_Id    In Varchar2)
   return Varchar2
Is
   L_Demand_Interface_RowId   Varchar2(30);
Begin
   Select Min(RowIdtoChar(RowId))
   Into L_Demand_Interface_RowId
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Line = P_Line_Id
   And   N_Column4 is Null
   And   Line_Item_Quantity <> 0
   And   Action_Code = 100
   Having Count(Distinct ATP_Group_Id) = 1;

   return L_Demand_Interface_RowId;
Exception
   When Others Then
    return (NULL);
End Demand_Interface_RowId_Line_Id;

function ATP_Date_Delivery(
   P_Session_id In Number,
   P_Delivery    In Varchar2)
    return Date
Is
    L_ATP_Date   Date;
Begin
   Select NVL(Min(Group_Available_Date), Min(Request_ATP_Date))
   Into L_ATP_Date
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Delivery = P_Delivery
   And   N_Column4 is Null
   Having Count(Distinct Group_Available_Date) = 1
     Or  (Count(Distinct Group_Available_Date) = 0
      And Count(Distinct Request_ATP_Date) = 1);

   return L_ATP_Date;

Exception WHEN Others Then
        return (NULL);

End ATP_Date_Delivery;

function Available_Quantity_Delivery(
   P_Session_id In Number,
   P_Delivery   In Varchar2)
    return Number
Is
    L_Available_Qty   Number;
Begin
   Select Min(Request_Date_ATP_Quantity)
   Into L_Available_Qty
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Delivery = P_Delivery
   And   Line_Item_Quantity > 0
   And   N_Column4 is Null
   Having Count(Demand_Source_Delivery) = 1;

   return L_Available_Qty;

Exception WHEN Others Then
        return (NULL);
End Available_Quantity_Delivery;

function Demand_Interface_RowId_Del(
   P_Session_id In Number,
   P_Delivery    In Varchar2)
   return Varchar2
Is
   L_Demand_Interface_RowId   Varchar2(30);
Begin
   Select Min(RowIdtoChar(RowId))
   Into L_Demand_Interface_RowId
   From MTL_Demand_Interface
   Where Session_Id = P_Session_Id
   And   Demand_Source_Line = P_Delivery
   And   N_Column4 is Null
   And   Line_Item_Quantity <> 0
   And   Action_Code = 100
   Having Count(Distinct ATP_Group_Id) = 1;

   return L_Demand_Interface_RowId;
Exception
   When Others Then
    return (NULL);
End Demand_Interface_RowId_Del;

function picking_line_schedule_status(
   P_LINE_ID         IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2
IS
   schedule_status_code VARCHAR2(30) := NULL;
   schedule_status VARCHAR2(80) := NULL;
begin
  SELECT DECODE( NVL( SUM( DECODE( SPLD.SCHEDULE_STATUS_CODE,
                                  'RESERVED', SPLD.REQUESTED_QUANTITY, 0 ) ), 0),
                0,
                DECODE( NVL( SUM( DECODE( SPLD.SCHEDULE_STATUS_CODE,
                            'SUPPLY RESERVED', SPLD.REQUESTED_QUANTITY, 0 ) ), 0),
                        0,
                        DECODE( NVL( SUM( DECODE(
                                      SPLD.SCHEDULE_STATUS_CODE,
                                      'DEMANDED', SPLD.REQUESTED_QUANTITY, 0 ) ),0 ),
                                0, NULL,
                                'DEMANDED' ),
                        'SUPPLY RESERVED' ),
                 'RESERVED' )
  INTO schedule_status_code
  FROM SO_PICKING_LINE_DETAILS SPLD
  WHERE SPLD.PICKING_LINE_ID = P_LINE_ID;

  if (  schedule_status_code is not null )
  then
     select meaning
     into  schedule_status
     from   so_lookups
     where  lookup_code =  schedule_status_code
     and    lookup_type = 'SCHEDULE STATUS';
  end if;

  return( SCHEDULE_STATUS );
Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end picking_line_schedule_status;

function p_line_schedule_status_code(
   P_LINE_ID         IN NUMBER DEFAULT NULL
                              )
   return VARCHAR2
IS
   schedule_status_code VARCHAR2(30) := NULL;
begin
  SELECT DECODE( NVL( SUM( DECODE( SPLD.SCHEDULE_STATUS_CODE,
                                  'RESERVED', SPLD.REQUESTED_QUANTITY, 0 ) ), 0),
                0,
                DECODE( NVL( SUM( DECODE( SPLD.SCHEDULE_STATUS_CODE,
                            'SUPPLY RESERVED', SPLD.REQUESTED_QUANTITY, 0 ) ), 0),
                        0,
                        DECODE( NVL( SUM( DECODE(
                                      SPLD.SCHEDULE_STATUS_CODE,
                                      'DEMANDED', SPLD.REQUESTED_QUANTITY, 0 ) ),0 ),
                                0, NULL,
                                'DEMANDED' ),
                        'SUPPLY RESERVED' ),
                 'RESERVED' )
  INTO schedule_status_code
  FROM SO_PICKING_LINE_DETAILS SPLD
  WHERE SPLD.PICKING_LINE_ID = P_LINE_ID;

  return( SCHEDULE_STATUS_CODE );

Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end p_line_schedule_status_code;

Function get_organization_name
  return VARCHAR2
IS
 org_name VARCHAR2(60) := NULL;
 org_id NUMBER := NULL;
Begin
  SELECT org_id
  INTO org_id
  from so_headers
  where rownum = 1;

  if org_id IS NULL Then
     return(NULL);
  else
    Select name
    into org_name
    from hr_operating_units
    where organization_id = org_id
    and rownum = 1;
    return(org_name);
  end if;
Exception
WHEN NO_DATA_FOUND
then
  return(NULL);
end get_organization_name;

/* The order status is displayed as cancelled or Closed if the order
       is in the state of Cancelld or Closed and the entry status field
       will be set to non updatable. For other headers the entry status
       will display the result for the value in the column s1
*/
function get_entry_status_name(p_open_flag in varchar2,
                               p_cancelled_flag in varchar2,
                               p_s1_id  in number)
  return VARCHAR2 is
  p_entry_status_name varchar2(30);
  cursor c_entry_status(p_id number) is
         select name from so_results
         where result_id = p_id;
begin
  if p_cancelled_flag = 'Y' then
     p_entry_status_name :=
             nvl(substr(fnd_message.get_string('OE','OE_MSG_CANCELLED'),1,30),
                  'OE_MSG_CANCELLED');
  elsif nvl(p_open_flag,'N') = 'N' then
     p_entry_status_name :=
             nvl(substr(fnd_message.get_string('OE','OE_MSG_CLOSED'),1,30),
                  'OE_MSG_CLOSED');
  else
    open c_entry_status(p_s1_id);
    fetch c_entry_status into p_entry_status_name;
    close c_entry_status;
  end if;
  return(p_entry_status_name);
end;

function OPTION_LINE_NUMBER(
   P_PARENT_LINE_ID                       IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID               IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID            IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                          IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   OPTION_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
                PARENT_LINE_ID,
                LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
                V_PARENT_LINE_ID,
                V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NULL) THEN
        IF (V_PARENT_LINE_ID IS NOT NULL) THEN
                OPTION_LINE_NUMBER := V_LINE_NUMBER;
        END IF;
   ELSE
        IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NOT NULL) THEN
           IF (V_PARENT_LINE_ID IS NOT NULL) THEN
                OPTION_LINE_NUMBER := V_LINE_NUMBER;
           END IF;
        END IF;
   END IF;

   RETURN(OPTION_LINE_NUMBER);


EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- OPTION_LINE_NUMBER

function INVOICE_BALANCE(
P_CUSTOMER_TRX_ID        IN NUMBER
                )
  return NUMBER
IS
  v_balance NUMBER := NULL ;
BEGIN

   IF ( P_CUSTOMER_TRX_ID IS NOT NULL )
   THEN
        SELECT NVL(SUM(AMOUNT_DUE_REMAINING),0)
        INTO v_balance
        FROM AR_PAYMENT_SCHEDULES
        WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
   END IF;
  RETURN(v_balance);
 EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    return(NULL);
END;  -- INVOICE_BALANCE

function INVOICE_AMOUNT(
P_CUSTOMER_TRX_ID        IN NUMBER
                )
  return NUMBER
IS
  v_invoice NUMBER := NULL ;
BEGIN

   IF ( P_CUSTOMER_TRX_ID IS NOT NULL )
   THEN
        SELECT NVL(SUM(EXTENDED_AMOUNT),0)
        INTO v_invoice
        FROM RA_CUSTOMER_TRX_LINES
        WHERE CUSTOMER_TRX_ID = P_CUSTOMER_TRX_ID;
   END IF;
  RETURN(v_invoice);
 EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    return(NULL);
END;  -- INVOICE_AMOUNT

function CYCLE_REQUEST return number is
request_id      number  := NULL;
Begin
Savepoint A;
request_id := FND_REQUEST.SUBMIT_REQUEST (
           'OE',
           'OECMWC','',
           to_char(sysdate,'YYYY/MM/DD HH24:MI'),FALSE,
           chr(0),
           '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '',
           '', '', '', '', '', '', '', '', '', '');
if request_id <> 0 Then
  Commit;
Else
  Rollback to A;
End If;
  Return Request_id;
End;

 function BASE_LINE_NUMBER(
   P_PARENT_LINE_ID                      IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID              IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID           IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                         IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   BASE_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
                PARENT_LINE_ID,
                LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
                V_PARENT_LINE_ID,
                V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NULL) THEN
        IF (V_PARENT_LINE_ID IS NULL) THEN
                BASE_LINE_NUMBER := V_LINE_NUMBER;
	ELSE
		SELECT  LINE_NUMBER
	        INTO    BASE_LINE_NUMBER
		FROM    SO_LINES
		WHERE   LINE_ID = V_PARENT_LINE_ID;
        END IF;
   ELSE
	SELECT	LINE_NUMBER
	INTO	BASE_LINE_NUMBER
	FROM	SO_LINES
	WHERE	LINE_ID = V_SHIPMENT_SCHEDULE_LINE_ID;
   END IF;

   RETURN(BASE_LINE_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- BASE_LINE_NUMBER

function SHIPMENT_SCHEDULE_NUMBER(
   P_PARENT_LINE_ID                       IN NUMBER DEFAULT NULL
,  P_SERVICE_PARENT_LINE_ID               IN NUMBER DEFAULT NULL
,  P_SHIPMENT_SCHEDULE_LINE_ID            IN NUMBER DEFAULT NULL
,  P_LINE_NUMBER                          IN NUMBER DEFAULT NULL
                          )
   return NUMBER
IS
   V_SHIPMENT_SCHEDULE_LINE_ID NUMBER := NULL;  -- default is NULL
   V_PARENT_LINE_ID NUMBER := NULL;  -- default is NULL
   V_LINE_NUMBER NUMBER := NULL;  -- default is NULL
   SCHEDULE_LINE_NUMBER NUMBER := NULL;  -- default is NULL
BEGIN
   IF (  P_SERVICE_PARENT_LINE_ID IS NULL )
    THEN
       V_SHIPMENT_SCHEDULE_LINE_ID := P_SHIPMENT_SCHEDULE_LINE_ID;
       V_PARENT_LINE_ID := P_PARENT_LINE_ID;
       V_LINE_NUMBER := P_LINE_NUMBER;
    ELSE
         SELECT SHIPMENT_SCHEDULE_LINE_ID,
		PARENT_LINE_ID,
		LINE_NUMBER
         INTO   V_SHIPMENT_SCHEDULE_LINE_ID,
		V_PARENT_LINE_ID,
		V_LINE_NUMBER
         FROM   SO_LINES
         WHERE  LINE_ID = P_SERVICE_PARENT_LINE_ID;
   END IF;
   IF (V_SHIPMENT_SCHEDULE_LINE_ID IS NOT NULL) THEN
	IF (V_PARENT_LINE_ID IS NULL) THEN
		SCHEDULE_LINE_NUMBER := V_LINE_NUMBER;
        ELSE
        	SELECT	LINE_NUMBER
        	INTO	SCHEDULE_LINE_NUMBER
		FROM	SO_LINES
		WHERE	LINE_ID = V_PARENT_LINE_ID;
        END IF;
   END IF;

   RETURN(SCHEDULE_LINE_NUMBER);

EXCEPTION
WHEN NO_DATA_FOUND
THEN
  RETURN( NULL );
END ; -- SHIPMENT_LINE_NUMBER

END OE_QUERY;

/
