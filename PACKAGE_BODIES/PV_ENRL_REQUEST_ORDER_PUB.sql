--------------------------------------------------------
--  DDL for Package Body PV_ENRL_REQUEST_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ENRL_REQUEST_ORDER_PUB" AS
/* $Header: pvxperob.pls 120.1 2005/08/10 17:00:25 appldev ship $ */

--Comments
--kvattiku: Aug 05, 05	Commented out for R12 in Get_payment_type. Directly retrieve from pv_lookups.
--			Added prefix ARPS to the AMOUNT_DUE_REMAINING column as it exists in
--			both AR_PAYMENT_SCHEDULES_ALL and RA_CUSTOMER_TRX_LINES_ALL

--  Global constant holding the package name

G_PKG_NAME     CONSTANT VARCHAR2(30) := 'PV_ENRL_REQUEST_ORDER_PUB';


FUNCTION get_Invoice_Balance
( p_order_header_id IN NUMBER
) RETURN NUMBER
IS
   v_balance NUMBER := NULL ;
BEGIN
   RETURN(v_balance);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return(NULL);
END;  -- INVOICE_BALANCE


FUNCTION Get_payment_type
(  p_order_header_id IN NUMBER
) RETURN VARCHAR2
IS
   v_payment_type_code varchar2(80) := NULL ;
   v_po_number varchar2(50) := NULL;
   v_payment_type varchar2(80) := NULL;
BEGIN
   IF ( p_order_header_id IS NOT NULL ) THEN
       select h.payment_type_code , h.cust_po_number
       into v_payment_type_code, v_po_number
       from oe_order_headers_all h
       where h.header_id = p_order_header_id;

       --kvattiku: Aug 05, 05 Directly retrieve from pv_lookups.
	if(v_payment_type_code is null) then
		select meaning
		into v_payment_type
		from pv_lookups
		where lookup_type ='PV_PAYMENT_TYPE'
		and lookup_code = 'INVOICE';
	else
	        select meaning
		into v_payment_type
		from pv_lookups
		where lookup_type ='PV_PAYMENT_TYPE'
		and lookup_code = v_payment_type_code;
	end if;

       /*kvattiku: Aug, 05 Commented out for R12.
       if(v_payment_type_code is null) then
         if(v_po_number is null) then
	   return(NULL);
         else
	   select meaning
	   into v_payment_type
	   from fnd_lookup_values_vl
	   where lookup_type ='PV_PAYMENT_TYPE'
	   and lookup_code = 'PURCHASE_ORDER';
	 end if;
       else
           IF v_payment_type_code='WIRE_TRANSFER' THEN
               select meaning
	       into v_payment_type
	       from fnd_lookup_values_vl
	       where lookup_type ='PV_PAYMENT_TYPE'
	       and lookup_code = 'WIRE_TRANSFER';
           ELSE
              select meaning
	      into v_payment_type
	      from oe_lookups
	      where lookup_type = 'PAYMENT TYPE'
	      and lookup_code = v_payment_type_code;
	   END IF;
       end if;
       */

   END IF;

   RETURN(v_payment_type);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return(NULL);
END;  -- Get_payment_type



PROCEDURE get_invoice_balance(
     p_order_header_id  IN  NUMBER
    ,x_invoice_balance   OUT NOCOPY NUMBER
    ,x_invoice_currency OUT NOCOPY VARCHAR2
)
IS

 BEGIN

  IF (p_order_header_id IS NOT NULL ) THEN

      --kvattiku: Aug 05, 05 Added prefix ARPS to the AMOUNT_DUE_REMAINING column as it exists in
      --both AR_PAYMENT_SCHEDULES_ALL and RA_CUSTOMER_TRX_LINES_ALL
      SELECT NVL(SUM(ARPS.AMOUNT_DUE_REMAINING),0), FCV.NAME
      into x_invoice_balance, x_invoice_currency
      FROM AR_PAYMENT_SCHEDULES_ALL ARPS, RA_CUSTOMER_TRX_LINES_ALL RCTL,
           OE_ORDER_LINES_ALL OOLA, FND_CURRENCIES_VL FCV
      WHERE  OOLA.HEADER_ID = p_order_header_id
      AND RCTL.INTERFACE_LINE_ATTRIBUTE6  = to_char(OOLA.LINE_ID)
      AND RCTL.INTERFACE_LINE_CONTEXT = 'ORDER ENTRY'
      AND  RCTL.CUSTOMER_TRX_ID = ARPS.CUSTOMER_TRX_ID
      AND ARPS.CLASS = 'INV'
      AND  ARPS.INVOICE_CURRENCY_CODE = FCV.CURRENCY_CODE
      group by  RCTL.CUSTOMER_TRX_ID, FCV.NAME ;

  END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_invoice_balance  := NULL;
      x_invoice_currency  := NULL;
END get_invoice_balance;  -- GET_INVOICE_BALANCE


PROCEDURE get_invoice_details(
     p_order_line_id  IN VARCHAR2
    ,x_invoice_balance   OUT NOCOPY NUMBER
    ,x_invoice_currency OUT NOCOPY VARCHAR2
    ,x_invoice_number OUT NOCOPY VARCHAR2
) IS
BEGIN
  --kvattiku: Aug 05, 05 Added prefix ARPS to the AMOUNT_DUE_REMAINING column as it exists in
  --both AR_PAYMENT_SCHEDULES_ALL and RA_CUSTOMER_TRX_LINES_ALL
  IF (p_order_line_id IS NOT NULL ) THEN
    SELECT NVL(SUM(ARPS.AMOUNT_DUE_REMAINING),0), FCV.name, RCT.TRX_NUMBER
      into x_invoice_balance, x_invoice_currency, x_invoice_number
      FROM AR_PAYMENT_SCHEDULES_ALL ARPS, RA_CUSTOMER_TRX_LINES_ALL RCTL,
      FND_CURRENCIES_VL FCV, RA_CUSTOMER_TRX_ALL RCT
      WHERE  RCTL.INTERFACE_LINE_ATTRIBUTE6  = p_order_line_id
      AND RCTL.INTERFACE_LINE_CONTEXT = 'ORDER ENTRY'
      AND  RCTL.CUSTOMER_TRX_ID = ARPS.CUSTOMER_TRX_ID
      AND  ARPS.CLASS = 'INV'
      AND  ARPS.INVOICE_CURRENCY_CODE = FCV.CURRENCY_CODE
      AND RCT.CUSTOMER_TRX_ID = RCTL.CUSTOMER_TRX_ID
      group by  RCTL.CUSTOMER_TRX_ID, FCV.name, RCT.TRX_NUMBER;

  END IF;


EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_invoice_balance  := NULL;
      x_invoice_currency  := NULL;
      x_invoice_number    := NULL;
END get_invoice_details;  -- GET_INVOICE_BALANCE

END PV_ENRL_REQUEST_ORDER_PUB;

/
