--------------------------------------------------------
--  DDL for Package Body CS_CHARGE_CORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_CHARGE_CORE_PVT" AS
/*$Header: csxchcrb.pls 120.1.12010000.2 2008/09/02 05:44:24 sshilpam ship $*/

/*********** Global  Variables  ********************************/
G_PKG_NAME     CONSTANT  VARCHAR2(30)  := 'CS_Charge_Details_PUB' ;


PROCEDURE Get_Source_Id(
                p_source_code       IN   VARCHAR2,
                p_source_number     IN   VARCHAR2,
                p_org_id            IN   NUMBER,
                x_source_id        OUT NOCOPY   NUMBER,
                p_return_status    OUT NOCOPY   VARCHAR2)  IS

BEGIN
-- Initialize API return status to success

  p_return_status := 'S' ;


  IF p_source_code = 'SR'  THEN

      IF p_source_number  IS NOT NULL THEN
              SELECT  incident_id INTO  x_source_id
              FROM    CS_INCIDENTS_ALL_B
              WHERE   incident_number = p_source_number;
      ELSE
             p_return_status := 'F' ;

      END IF ;

  ELSIF p_source_code = 'DR' THEN

      IF p_source_number  IS NOT NULL THEN
           SELECT  repair_line_id INTO x_source_id
           FROM    CSD_REPAIRS
           WHERE   repair_number = p_source_number ;
      ELSE
             p_return_status := 'F' ;
      END IF ;

  ELSIF p_source_code = 'SD' THEN

      IF p_source_number  IS NOT NULL THEN
           SELECT  debrief_header_id INTO x_source_id
           FROM    csf_debrief_headers
           WHERE   debrief_number = p_source_number ;
      ELSE
          p_return_status := 'F' ;
      END IF ;

  ELSE
         p_return_status := 'F' ;
  END IF ;

  EXCEPTION
  WHEN NO_DATA_FOUND  THEN
         p_return_status := 'F' ;

END  Get_Source_Id ;


-- Stubs for removed code
-- Stubs for removed code
-- Stubs for removed code

Procedure default_attributes(p_org OUT NOCOPY number,
                             x_return_status OUT NOCOPY varchar2) is
BEGIN null; END;


PROCEDURE Get_Invoice_details(
                p_order_header_id   IN   NUMBER,
                p_order_line_id     IN   NUMBER,
                x_invoice_number   OUT NOCOPY   VARCHAR2,
                x_invoice_date     OUT NOCOPY   DATE) is


/* Fix bug 2901318
CURSOR Inv_Det(p_order_header_id number) IS
       SELECT min(TRX.TRX_NUMBER), to_char(TRX.TRX_DATE)
         FROM OE_ORDER_HEADERS_ALL HD,
              RA_CUSTOMER_TRX_ALL TRX,
              OE_ORDER_LINES_ALL L,
              RA_CUSTOMER_TRX_LINES_ALL TRXL
         WHERE HD.HEADER_ID = L.HEADER_ID
	      AND  trxl.INTERFACE_LINE_CONTEXT    = 'ORDER ENTRY'
	      AND  trxl.INTERFACE_LINE_ATTRIBUTE1 = to_char(hd.ORDER_NUMBER)
	      -- AND  trxl.INTERFACE_LINE_ATTRIBUTE2 = to_char(hd.ORDER_TYPE_ID) -- bug:2463968
              AND  trxl.INTERFACE_LINE_ATTRIBUTE6 = to_char(l.LINE_ID)
              AND TRX.CUSTOMER_TRX_ID = TRXL.CUSTOMER_TRX_ID
              AND HD.HEADER_ID    = p_order_header_id
         group by trx.trx_number,trx.trx_date; */

/*
-- Fix bug 2901318
CURSOR Inv_Det(p_order_header_id number) IS
       SELECT min(TRX.TRX_NUMBER), to_char(TRX.TRX_DATE)
         FROM OE_ORDER_HEADERS_ALL HD,
              RA_CUSTOMER_TRX_ALL TRX,
              RA_CUSTOMER_TRX_LINES_ALL TRXL,
              oe_transaction_types_tl ottt
         WHERE HD.HEADER_ID = p_order_header_id
           and ottt.transaction_type_id = hd.ORDER_TYPE_ID
           and trxl.sales_order = to_char(hd.ORDER_NUMBER)
	       AND  trxl.INTERFACE_LINE_ATTRIBUTE2 = ottt.name
           AND TRX.CUSTOMER_TRX_ID = TRXL.CUSTOMER_TRX_ID
         group by trx.trx_number, trx.trx_date;
*/

 -- Added to resolve Bug # 3816254

  Cursor get_order_details(p_order_header_id number) IS
    SELECT order_number
     FROM  oe_order_headers_all
    WHERE  header_id = p_order_header_id;

  Cursor get_invoice_details(p_order_header_number NUMBER,
                             p_line_id NUMBER)IS
    SELECT TRX.TRX_NUMBER,
           TRX.TRX_DATE
    FROM   RA_CUSTOMER_TRX_ALL TRX
    WHERE  TRX.CUSTOMER_TRX_ID IN (SELECT TRXL.CUSTOMER_TRX_ID  -- Bug 7117570 Changed = to IN
                                  FROM   RA_CUSTOMER_TRX_LINES_ALL TRXL
                                  WHERE  TRXL.INTERFACE_LINE_CONTEXT    = 'ORDER ENTRY'
                                  AND    TRXL.INTERFACE_LINE_ATTRIBUTE1 = to_char(p_order_header_number)
                                  AND    TRXL.INTERFACE_LINE_ATTRIBUTE6 = to_char(p_line_id)
  			          AND    TRXL.SALES_ORDER = to_char(p_order_header_number));
   -- Fixed bug:5104595
   /* SELECT TRX.TRX_NUMBER,
           TRX.TRX_DATE
    FROM   RA_CUSTOMER_TRX_LINES_ALL TRXL,
           RA_CUSTOMER_TRX_ALL TRX
    WHERE  TRXL.INTERFACE_LINE_CONTEXT    = 'ORDER ENTRY'
    AND    TRXL.INTERFACE_LINE_ATTRIBUTE1 = to_char(p_order_header_number)
    AND    TRXL.INTERFACE_LINE_ATTRIBUTE6 = to_char(p_line_id)
    AND    TRX.CUSTOMER_TRX_ID = TRXL.CUSTOMER_TRX_ID; */

    l_order_number NUMBER;

BEGIN

      OPEN get_order_details(p_order_header_id);
      FETCH get_order_details
      INTO l_order_number;
      CLOSE get_order_details;

      IF l_order_number IS NOT NULL AND
         p_order_line_id IS NOT NULL THEN

        FOR v_cur in get_invoice_details(l_order_number,
                                       p_order_line_id) LOOP
          x_invoice_number := v_cur.TRX_NUMBER;
          x_invoice_date :=  v_cur.TRX_DATE;
          exit;

        END LOOP;

      ELSE
         x_invoice_number := null;
         x_invoice_date := null;
      END IF;

      /*
      OPEN Inv_Det(p_order_header_id);
      FETCH Inv_Det
      INTO x_invoice_number,
	   x_invoice_date;
      CLOSE Inv_Det;
      */

  EXCEPTION
  When NO_DATA_FOUND THEN
     BEGIN
         x_invoice_number := null;
         x_invoice_date   := null;
     END;
END;


/*
--  tkochend - commented out because not used
--  tkochend - commented out because not used
--  tkochend - commented out because not used
Procedure default_attributes(p_org    OUT NOCOPY number,
				         x_return_status OUT NOCOPY varchar2) is
p_resp_appl_id NUMBER;
p_user_id NUMBER;
p_resp_id NUMBER;
p_login_id NUMBER;
p_org_id NUMBER;

BEGIN

 -- ----------------------------------------------------------------------
 -- FND_GLOBAL.RESP_APPL_ID, FND_GLOBAL.RESP_ID, and FND_GLOBAL.LOGIN_ID
 -- returns -1 by default, which is an invalid value. FND_GLOBAL.USER_ID
 -- is okay, because user ID -1 corresponds to user 'ANONYMOUS.'  If
 -- FND_GLOBAL returns -1, the variables are set to NULL instead.
 -- ----------------------------------------------------------------------

   IF ((p_resp_appl_id IS NULL) AND (FND_GLOBAL.RESP_APPL_ID <> -1)) THEN
	  -- ID is not passed in, return the default.
	 p_resp_appl_id := FND_GLOBAL.RESP_APPL_ID;
   END IF;

   IF ((p_resp_id IS NULL) AND (FND_GLOBAL.RESP_ID <> -1)) THEN
	    p_resp_id := FND_GLOBAL.RESP_ID;
   END IF;

   IF (p_user_id IS NULL) THEN
	  p_user_id := FND_GLOBAL.USER_ID;
   END IF;

   IF ((p_login_id = FND_API.G_MISS_NUM) AND
	   (FND_GLOBAL.LOGIN_ID NOT IN (-1,0))) THEN
	  p_login_id := FND_GLOBAL.LOGIN_ID;
    ELSE
	   p_login_id := NULL;
   END IF;

   IF (p_org_id IS NULL) THEN
	 SELECT TO_NUMBER(DECODE(SUBSTRB(USERENV('CLIENT_INFO'),1,1), ' ', NULL,
				   SUBSTRB(USERENV('CLIENT_INFO'),1,10)))
	 INTO   p_org_id
      FROM   dual;

   IF (p_org_id IS NULL) THEN
	p_org_id := TO_NUMBER(FND_PROFILE.Value_Specific('ORG_ID', p_user_id,
						    p_resp_id, p_resp_appl_id));
   END IF;

  IF p_org_id IS NOT NULL THEN

  p_org := p_org_id;

  x_return_status := 'Y';

  ELSE
  x_return_status := 'N';
  END IF;

 END IF;
END Default_attributes;

--End of removed code
--End of removed code
--End of removed code
*/


FUNCTION Get_Ship_To_site_Id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER) RETURN NUMBER
IS
    CURSOR c_ship_site1 IS
	SELECT ship_to_org_id
	FROM   CS_ESTIMATE_DETAILS
	WHERE  incident_id = p_qte_header_id
	AND    estimate_detail_id = p_qte_line_id;

    CURSOR c_ship_site2 IS
	SELECT ship_to_org_id
	FROM   CS_ESTIMATE_DETAILS
	WHERE  incident_id = p_qte_header_id
	AND    estimate_detail_id IS NULL ;

    l_ship_site_id		NUMBER;
    l_ship_site_use_id   NUMBER;

    CURSOR c_cust_id IS
    SELECT account_id
    FROM   CS_INCIDENTS_ALL_B
    WHERE  incident_id = p_qte_header_id;

    CURSOR C_site_use(l_cust_id NUMBER, l_ship_site_id NUMBER) IS
         SELECT site_use_id
         FROM   hz_cust_site_uses b,
			 hz_cust_acct_sites a
         WHERE b.cust_acct_site_id = a.cust_acct_site_id
         AND   b.site_use_code = 'SHIP_TO' --and b.primary_flag = 'Y'
         AND   a.party_site_id = l_ship_site_id
         AND   a.cust_account_id = l_cust_id;

    l_cust_id NUMBER;
    l_return_status VARCHAR2(1);
    l_msg_count number;
    l_msg_data VARCHAR2(2000);

BEGIN
    OPEN c_ship_site1;
    FETCH c_ship_site1 INTO l_ship_site_id;
    IF c_ship_site1%FOUND THEN
	CLOSE c_ship_site1;
    -- Get the Customer Account from the header
    OPEN c_cust_id;
    FETCH c_cust_id INTO l_cust_id;
    CLOSE c_cust_id;

    -- Get the site use id from the HZ_cust_site_uses

    OPEN C_site_use(l_cust_id , l_ship_site_id);
    FETCH C_site_use into l_ship_site_use_id;
    CLOSE C_site_use;

  	return l_ship_site_use_id;
    END IF;
    CLOSE c_ship_site1;
    OPEN c_ship_site2;
    FETCH c_ship_site2 INTO l_ship_site_id;
    IF c_ship_site2%FOUND THEN
	CLOSE c_ship_site2;

      -- Get the Customer Account from the header
    OPEN c_cust_id;
    FETCH c_cust_id INTO l_cust_id;
    CLOSE c_cust_id;

       -- Get the site use id from the HZ_cust_site_uses

    OPEN C_site_use(l_cust_id , l_ship_site_id);
    FETCH C_site_use into l_ship_site_use_id;
    CLOSE C_site_use;

  	return l_ship_site_use_id;

	END IF;
    CLOSE c_ship_site2;
    return l_ship_site_use_id;
END Get_Ship_To_site_Id;

FUNCTION Get_invoice_to_party_site_id (
		p_qte_header_id		NUMBER,
		p_qte_line_id		NUMBER
		) RETURN NUMBER
IS
    CURSOR c_inv_site1 IS
	SELECT invoice_to_org_id
	FROM   CS_ESTIMATE_DETAILS
	WHERE  estimate_detail_id = p_qte_line_id
     AND    incident_id = p_qte_header_id;

    CURSOR c_inv_site2 IS
	SELECT invoice_to_org_id
	FROM   CS_ESTIMATE_DETAILS
	WHERE  incident_id = p_qte_header_id;


    l_inv_site_id		NUMBER;


    l_ship_site_id		NUMBER;
    l_bill_site_use_id  NUMBER;

    CURSOR c_cust_id IS
    SELECT customer_id
    FROM   CS_INCIDENTS_ALL_B
    WHERE  incident_id = p_qte_header_id;

  CURSOR C_site_use(l_cust_id NUMBER, l_inv_site_id NUMBER) IS
         SELECT site_use_id
         FROM hz_cust_site_uses b,hz_cust_acct_sites a
         WHERE b.cust_acct_site_id = a.cust_acct_site_id
         AND b.site_use_code = 'BILL_TO'
         AND a.party_site_id = l_inv_site_id
         AND a.cust_account_id = l_cust_id;

    l_cust_id NUMBER;

BEGIN

    OPEN c_inv_site1;
    FETCH c_inv_site1 INTO l_inv_site_id;
    IF c_inv_site1%FOUND THEN
	CLOSE c_inv_site1;

    -- Get the Customer Account from the header
    OPEN c_cust_id;
    FETCH c_cust_id INTO l_cust_id;
    CLOSE c_cust_id;

    -- Get the site use id from the HZ_cust_site_uses

    OPEN C_site_use(l_cust_id , l_inv_site_id);
    FETCH C_site_use into l_bill_site_use_id;
    CLOSE C_site_use;
    return l_bill_site_use_id;

    END IF;
    CLOSE c_inv_site1;
    OPEN c_inv_site2;
    FETCH c_inv_site2 INTO l_inv_site_id;
    IF c_inv_site2%FOUND THEN
	CLOSE c_inv_site2;

    -- Get the Customer Account from the header
    OPEN c_cust_id;
    FETCH c_cust_id INTO l_cust_id;
    CLOSE c_cust_id;

    -- Get the site use id from the HZ_cust_site_uses

    OPEN C_site_use(l_cust_id , l_inv_site_id);
    FETCH C_site_use into l_bill_site_use_id;
    CLOSE C_site_use;
    return l_bill_site_use_id;
    END IF;
    CLOSE c_inv_site2;
    return l_bill_site_use_id;
END Get_invoice_to_party_site_id;

Function Number_Format(p_value_amount IN NUMBER) return VARCHAR2

IS

l_format VARCHAR2(2000);
l_value_amount VARCHAR2(100);

BEGIN

  IF p_value_amount IS NOT NULL THEN
    fnd_currency.build_format_mask(l_format,30,2,1);
    l_value_amount := to_char(p_value_amount, l_format);

  ELSE
    --p_value_amount is null
    l_value_amount := null;

  END IF;


  return l_value_amount;

END;


Function Get_Value_Name(p_restriction_type    IN VARCHAR2,
                        p_value_object_id     IN NUMBER) return VARCHAR2
IS

Cursor c_party_name IS
select party_name||'-'||party_number party_name
  from hz_parties
 where party_id = p_value_object_id
   and nvl(status, 'A') = 'A';

Cursor c_incident_type IS
select name
  from cs_incident_types_vl
 where incident_type_id = p_value_object_id;

l_value_name VARCHAR2(4000) := null;

BEGIN

 IF p_restriction_type = 'BILL_TO_CUSTOMER' THEN
    OPEN c_party_name;
    FETCH c_party_name INTO l_value_name;
    CLOSE c_party_name;

  ELSE
    IF p_restriction_type = 'SERVICE_REQUEST_TYPE' THEN
      OPEN c_incident_type;
      FETCH c_incident_type INTO l_value_name;
      CLOSE c_incident_type;
    END IF;
  END IF;

  return l_value_name;

END Get_Value_Name;


END CS_Charge_Core_PVT ;


/
