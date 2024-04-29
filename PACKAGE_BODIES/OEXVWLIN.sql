--------------------------------------------------------
--  DDL for Package Body OEXVWLIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OEXVWLIN" AS
/* $Header: OEXVWLNB.pls 115.1 99/07/16 08:17:13 porting shi $ */

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
      order_line_total := ( ORDERED_QTY - CANCELLED_QTY)
                             * SELLING_PRICE;
   end if ;

return(order_line_total);

Exception WHEN NO_DATA_FOUND then
  return(NULL);

END;


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


------------------------------------------------------------------------
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


------------------------------------------------------------------------
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


END OEXVWLIN;

/
