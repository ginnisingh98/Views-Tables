--------------------------------------------------------
--  DDL for Package Body PO_PRICE_BREAK_S
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_PRICE_BREAK_S" as
/* $Header: POXPRBKB.pls 115.6.1158.2 2002/09/30 23:18:43 dreddy ship $ */
Procedure Get_Price_Break (
	SOURCE_DOCUMENT_HEADER_ID IN NUMBER,
        SOURCE_DOCUMENT_LINE_NUM  IN NUMBER,
	IN_QUANTITY IN NUMBER,
	UNIT_OF_MEASURE IN VARCHAR2,
        DELIVER_TO_LOCATION_ID IN NUMBER,
	REQUIRED_CURRENCY  IN VARCHAR2,
	REQUIRED_RATE_TYPE IN VARCHAR2,
	BASE_PRICE OUT NUMBER,
	CURRENCY_PRICE OUT NUMBER,
	DISCOUNT OUT NUMBER,
	CURRENCY_CODE OUT VARCHAR2,
	RATE_TYPE OUT VARCHAR2,
	RATE_DATE OUT DATE,
	RATE OUT NUMBER) is
v_ship_to_location_id number;
v_temp number;
v_return_unit_of_measure varchar2(26);

--------------------------------------------------------------
-- Bug 2401468 (anhuang)				6/6/02
--------------------------------------------------------------
-- The following fixes were taken from the original USER_EXIT:
-- 1) Truncated all sysdates. (Bug 1655381)
-- 2) Added decode statement for QUOTATIONs in unit_price cursor
--    so it is equivalent to PRICE BREAK case. (Bug 1934869)

CURSOR loc_unit_price  IS
        SELECT  poll.price_override
        ,       round(poll.price_override * decode(poh.rate, 0, 1, null, 1, poh.rate), 5 )
        ,       poh.rate_date
        ,       poh.rate
        ,       poh.currency_code
        ,       poh.rate_type
        ,       poll.price_discount
        ,       poll.price_override
        ,       decode(	poll.line_location_id,
			null, pol.unit_meas_lookup_code,
                       	poll.unit_meas_lookup_code)
        FROM    po_headers poh
        ,       po_lines pol
        ,       po_line_locations poll
        WHERE   poh.po_header_id = source_document_header_id
        and     poh.po_header_id = pol.po_header_id
        and     pol.line_num = source_document_line_num
        and     pol.po_line_id = poll.po_line_id (+)
        and     (   required_currency is null
                 or poh.currency_code = required_currency )
        and     (   required_rate_type is null
                 or poh.rate_type = required_rate_type )
        and     nvl(poll.unit_meas_lookup_code, nvl(unit_of_measure,
                                                pol.unit_meas_lookup_code))
                = nvl(unit_of_measure, pol.unit_meas_lookup_code)
        and     trunc(sysdate) between nvl(poll.start_date, trunc(sysdate))
                         and     nvl(poll.end_date, trunc(sysdate))
        and     poll.quantity <= in_quantity
        and     poll.ship_to_location_id = v_ship_to_location_id
        and     poll.shipment_type in ('PRICE BREAK', 'QUOTATION')
        order by 1 asc;

CURSOR unit_price IS
        SELECT 	decode(	poll.shipment_type,
			'PRICE BREAK', 	decode(	poll.ship_to_location_id,
						null, poll.price_override,
						pol.unit_price) ,
			'QUOTATION', 	decode(	poll.ship_to_location_id,
						null, poll.price_override,
						pol.unit_price) ,
			pol.unit_price)
        ,       round( decode(	poll.shipment_type,
				'PRICE BREAK', 	decode(	poll.ship_to_location_id,
							null, poll.price_override,
							pol.unit_price) ,
				'QUOTATION', 	decode(	poll.ship_to_location_id,
							null, poll.price_override,
							pol.unit_price) ,
				pol.unit_price)
                	* decode(poh.rate, 0, 1, null, 1, poh.rate), 5 )
        ,       poh.rate_date
        ,       poh.rate
        ,       poh.currency_code
        ,       poh.rate_type
        ,       poll.price_discount
        ,       decode(	poll.shipment_type,
			'PRICE BREAK', 	decode(	poll.ship_to_location_id,
						null, poll.price_override ,
						pol.unit_price) ,
			'QUOTATION', 	decode(	poll.ship_to_location_id,
						null, poll.price_override ,
						pol.unit_price) ,
			pol.unit_price)
        ,       decode(	poll.line_location_id,
			null, pol.unit_meas_lookup_code,
                       	poll.unit_meas_lookup_code)
        FROM    po_headers poh
        ,       po_lines pol
        ,       po_line_locations poll
        WHERE   poh.po_header_id = source_document_header_id
        and     poh.po_header_id = pol.po_header_id
        and     pol.line_num = source_document_line_num
        and     pol.po_line_id = poll.po_line_id (+)
        and     (   required_currency is null
                 or poh.currency_code = required_currency )
        and     (   required_rate_type is null
                 or poh.rate_type = required_rate_type )
        and     nvl(poll.unit_meas_lookup_code, nvl(	unit_of_measure,
                                                	pol.unit_meas_lookup_code))
                	 = nvl(unit_of_measure, pol.unit_meas_lookup_code)
        and 	trunc(sysdate) BETWEEN nvl(poll.start_date,trunc(sysdate) )   AND nvl(poll.end_date,trunc(sysdate))
        and     poll.quantity (+) <= in_quantity
        order by 1 asc ;

BEGIN

    BEGIN
        SELECT ship_to_location_id
        INTO   v_ship_to_location_id
        FROM   hr_locations
        WHERE  location_id = deliver_to_location_id ;
    EXCEPTION

        WHEN NO_DATA_FOUND THEN
             begin
               	select 	location_id
               	into 	v_ship_to_location_id
               	from 	hz_locations
               	where 	location_id = deliver_to_location_id;

              exception

                 when no_data_found then

                      null;
              end;

        WHEN OTHERS THEN
        null;
    END;

   /* Bug 2596651 */
   /* Get the unit price and the currency price from the blanket line */
   /* This price will be used if the below cursors do not return anything*/

   BEGIN
        SELECT pol.unit_price,
               round(pol.unit_price * decode(poh.rate, 0, 1, null, 1, poh.rate), 5 )
        INTO   base_price,
               currency_price
        FROM   po_lines pol,
               po_headers poh
        WHERE pol.po_header_id = poh.po_header_id
        AND   pol.po_header_id =  source_document_header_id
        AND   pol.line_num = source_document_line_num;

    EXCEPTION
        WHEN OTHERS THEN
        null;
    END;

    OPEN loc_unit_price;

    FETCH loc_unit_price INTO
                v_temp
        ,       base_price
        ,       rate_date
        ,       rate
        ,       currency_code
        ,       rate_type
        ,       discount
        ,       currency_price
        ,       v_return_unit_of_measure;

    /*
    ** If no row returned from the SQL statement, find the price
    ** without using location.
    */
    IF (loc_unit_price%ROWCOUNT = 0) THEN

         OPEN unit_price;

         FETCH unit_price INTO
                v_temp
        ,       base_price
        ,       rate_date
        ,       rate
        ,       currency_code
        ,       rate_type
        ,       discount
        ,       currency_price
        ,       v_return_unit_of_measure;

        /*
        ** If no row returned from the SQL statement, return an error to
        ** the calling form.
        */
        /* Bug 2596651 - do not set price to 0 if no rows returned
           we need to return the line price from above */

        IF (unit_price%ROWCOUNT= 0) THEN
            rate := 0;
         -- currency_price := 0;
            discount := 0;
         -- base_price := 0;
        END IF;

    END IF;
    IF ( v_return_unit_of_measure <> unit_of_measure) THEN
        rate := 0;
     -- currency_price := 0;
        discount := 0;
     -- base_price := 0;
    END IF;
end;
end;

/
