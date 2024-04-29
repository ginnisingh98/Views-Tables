--------------------------------------------------------
--  DDL for Package Body ASO_SOURCING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_SOURCING_PVT" as
/* $Header: asovsrcb.pls 120.1 2005/08/05 09:32:23 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_SOURCING_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASO_SOURCING_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asovsrcb.pls';




FUNCTION Get_Cust_Acct (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_cust_account_id NUMBER;
BEGIN

   SELECT cust_account_id
   INTO x_cust_account_id
   FROM aso_quote_headers_all
   WHERE quote_header_id = p_quote_header_id;

   IF (SQL%NOTFOUND) THEN
       null;
       x_cust_account_id := null;
   END IF;


   return  x_cust_account_id;
   EXCEPTION
   WHEN OTHERS THEN
	RETURN NULL;
END Get_Cust_Acct;

-- the following four APIs actually create the site use if needed
-- this should be changed in the party int

FUNCTION Get_Ship_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_ship_to_org_id      NUMBER := NULL;
l_cust_account_id     NUMBER;
l_ship_party_site_id  NUMBER;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            varchar2(2000);
l_ship_to_cust_account_id            NUMBER;

CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT qh.cust_account_id, qs.ship_to_party_site_id,qs.ship_to_cust_account_id
     FROM aso_quote_headers_all qh, aso_shipments qs
     WHERE qh.quote_header_id = qs.quote_header_id
     AND qh.quote_header_id = l_quote_header_id
     AND qs.quote_line_id is NULL;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO l_cust_account_id, l_ship_party_site_id,l_ship_to_cust_account_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_to_org_id;
      END IF;
      CLOSE C_get_quote_info;


      if l_ship_to_cust_account_id is not null OR l_ship_to_cust_account_id <>  fnd_api.G_MISS_NUM then
	 l_cust_account_id := l_ship_to_cust_account_id;
	 end if;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('cust account = ' || l_cust_account_id,1,'N');
        aso_debug_pub.add('ship party site = ' || l_ship_party_site_id,1,'N');
      END IF;
      IF l_cust_account_id is not NULL
         AND l_ship_party_site_id is not NULL THEN


      ASO_MAP_QUOTE_ORDER_INT.GET_ACCT_SITE_USES (

 		P_Cust_Account_Id => l_cust_account_id
 		 ,P_Party_Site_Id   => l_ship_party_site_id
	         ,P_Acct_Site_type  => 'SHIP_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_site_use_id     => x_ship_to_org_id
  	   );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_ship_to_org_id := NULL;
       END IF;

      END IF;  -- not null

      return x_ship_to_org_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;


END Get_Ship_to_Site_Use;



FUNCTION Get_Line_Ship_to_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER
IS
x_ship_to_org_id      NUMBER := NULL;
l_cust_account_id     NUMBER;
l_ship_party_site_id  NUMBER;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            varchar2(2000);
l_ship_to_cust_account_id            NUMBER;
l_quote_header_id number;
CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qh.cust_account_id, qs.ship_to_party_site_id,
   qs.ship_to_cust_account_id,qh.quote_header_id
     FROM aso_quote_headers_all qh, aso_shipments qs, aso_quote_lines_all ql
     WHERE qh.quote_header_id = qs.quote_header_id
     AND ql.quote_header_id = qh.quote_header_id
     AND ql.quote_line_id = l_quote_line_id
     AND ql.quote_line_id = qs.quote_line_id;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO l_cust_account_id, l_ship_party_site_id,
           l_ship_to_cust_account_id, l_quote_header_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_to_org_id;
      END IF;
      CLOSE C_get_quote_info;

	 if l_ship_to_cust_account_id is not null OR l_ship_to_cust_account_id <>  fnd_api.G_MISS_NUM then
	 l_cust_account_id := l_ship_to_cust_account_id;
	 end if;
     IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
       aso_debug_pub.add('cust account = ' || l_cust_account_id,1,'N');
        aso_debug_pub.add('party site = ' || l_ship_party_site_id,1,'N');
     END IF;

      IF l_cust_account_id is not NULL
         AND l_ship_party_site_id is not NULL THEN
          ASO_MAP_QUOTE_ORDER_INT.GET_ACCT_SITE_USES (

 		 P_Cust_Account_Id => l_cust_account_id
 		 ,P_Party_Site_Id   => l_ship_party_site_id
	         ,P_Acct_Site_type  => 'SHIP_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_site_use_id     => x_ship_to_org_id
  	   );


       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_ship_to_org_id := NULL;
       END IF;
     ELSE
       x_ship_to_org_id := get_ship_to_site_use(l_quote_header_id);
    END IF;  -- not null

      return x_ship_to_org_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;


END Get_Line_Ship_to_Site_Use;




FUNCTION Get_Invoice_to_Site_Use (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_invoice_to_org_id NUMBER := NULL;
l_cust_account_id NUMBER;
l_invoice_party_site_id NUMBER;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            varchar2(2000);
l_invoice_to_cust_account_id            NUMBER;


CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT cust_account_id, invoice_to_party_site_id,invoice_to_cust_account_id
     FROM aso_quote_headers_all
     WHERE quote_header_id = l_quote_header_id;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO l_cust_account_id, l_invoice_party_site_id,l_invoice_to_cust_account_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_to_org_id;
      END IF;
      CLOSE C_get_quote_info;

      -- ----------------dbms_output.put_line(l_cust_account_id || l_invoice_party_site_id);

	 if l_invoice_to_cust_account_id is not null OR l_invoice_to_cust_account_id <>  fnd_api.G_MISS_NUM then
	 l_cust_account_id := l_invoice_to_cust_account_id;
	 end if;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('cust account = ' || l_cust_account_id,1,'N');
        aso_debug_pub.add('invoice party site = ' || l_invoice_party_site_id,1,'N');
          END IF;


      IF l_cust_account_id is not NULL
         AND l_invoice_party_site_id is not NULL THEN

       ASO_MAP_QUOTE_ORDER_INT.GET_ACCT_SITE_USES (

 		 P_Cust_Account_Id => l_cust_account_id
 		 ,P_Party_Site_Id   => l_invoice_party_site_id
	         ,P_Acct_Site_type  => 'BILL_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_site_use_id     => x_invoice_to_org_id
  	   );

     --  ----------------dbms_output.put_line(l_return_status || ' '||x_invoice_to_org_id );
       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_invoice_to_org_id := NULL;
       END IF;

      END IF;  -- not null

      return x_invoice_to_org_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;


END Get_Invoice_to_Site_Use;





FUNCTION Get_Line_Invoice_Site_Use (p_quote_line_id NUMBER)
RETURN NUMBER
IS
x_invoice_to_org_id NUMBER := NULL;
l_cust_account_id NUMBER;
l_invoice_party_site_id NUMBER;
l_return_status       VARCHAR2(1);
l_msg_count           NUMBER;
l_msg_data            NUMBER;
l_invoice_to_cust_account_id            NUMBER;
l_quote_header_id number;
CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qh.cust_account_id, ql.invoice_to_party_site_id,
          ql.invoice_to_cust_account_id, qh.quote_header_id
     FROM aso_quote_headers_all qh, aso_quote_lines_all ql
     WHERE ql.quote_line_id = l_quote_line_id
     AND   ql.quote_header_id = qh.quote_header_id;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO l_cust_account_id, l_invoice_party_site_id,
         l_invoice_to_cust_account_id, l_quote_header_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_to_org_id;
      END IF;
      CLOSE C_get_quote_info;

	 if l_invoice_to_cust_account_id is not null OR l_invoice_to_cust_account_id <>  fnd_api.G_MISS_NUM then
	 l_cust_account_id := l_invoice_to_cust_account_id;
	 end if;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('cust account = ' || l_cust_account_id,1,'N');
        aso_debug_pub.add('invoice party site = ' || l_invoice_party_site_id,1,'N');
      END IF;

      IF l_cust_account_id is not NULL
         AND l_invoice_party_site_id is not NULL THEN
       ASO_MAP_QUOTE_ORDER_INT.GET_ACCT_SITE_USES (

 		 P_Cust_Account_Id => l_cust_account_id
 		 ,P_Party_Site_Id   => l_invoice_party_site_id
	         ,P_Acct_Site_type  => 'BILL_TO'
 		 ,x_return_status   => l_return_status
 		 ,x_site_use_id     => x_invoice_to_org_id
  	   );

       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_invoice_to_org_id := NULL;
       END IF;
      ELSE
        x_invoice_to_org_id := get_invoice_to_site_use(l_quote_header_id);
      END IF;  -- not null

      return x_invoice_to_org_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;


END Get_Line_Invoice_Site_Use;


FUNCTION Get_Ship_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT qs.ship_to_party_site_id
     FROM aso_shipments qs
     WHERE qs.quote_header_id = l_quote_header_id
     AND qs.quote_line_id is NULL;

x_ship_party_site_id NUMBER := NULL;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO x_ship_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_ship_party_site_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;

END  Get_Ship_to_Party_Site;



FUNCTION Get_Line_Ship_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qs.ship_to_party_site_id
     FROM aso_shipments qs
     WHERE  qs.quote_line_id = l_quote_line_id;

x_ship_party_site_id NUMBER;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO x_ship_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_ship_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_ship_party_site_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;

END  Get_Line_Ship_Party_Site;


FUNCTION Get_Invoice_to_Party_Site (p_quote_header_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_header_id NUMBER) IS
   SELECT qs.invoice_to_party_site_id
     FROM aso_quote_headers_all qs
     WHERE qs.quote_header_id = l_quote_header_id;

x_invoice_party_site_id NUMBER := NULL;

BEGIN

      OPEN C_get_quote_info(p_quote_header_id);
      FETCH C_get_quote_info INTO x_invoice_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return x_invoice_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return x_invoice_party_site_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;

END  Get_Invoice_to_Party_Site;



FUNCTION Get_Line_Invoice_Party_Site (p_quote_line_id NUMBER)
RETURN NUMBER
IS
 CURSOR C_get_quote_info (l_quote_line_id NUMBER) IS
   SELECT qs.invoice_to_party_site_id
     FROM aso_quote_lines_all qs
     WHERE  qs.quote_line_id = l_quote_line_id;

xl_inv_party_site_id NUMBER;

BEGIN

      OPEN C_get_quote_info(p_quote_line_id);
      FETCH C_get_quote_info INTO xl_inv_party_site_id;
      IF (C_get_quote_info%NOTFOUND) THEN
         return xl_inv_party_site_id;
      END IF;
      CLOSE C_get_quote_info;

      return xl_inv_party_site_id;
	 EXCEPTION
	 WHEN OTHERS THEN
	   RETURN NULL;

END  Get_Line_Invoice_Party_Site;

/*
FUNCTION Get_Party_Id (p_quote_header_id NUMBER)
RETURN NUMBER
IS
x_party_id NUMBER;
BEGIN

   SELECT party_id
   INTO x_party_id
   FROM aso_quote_headers_all
   WHERE quote_header_id = p_quote_header_id;

   IF (SQL%NOTFOUND) THEN
       null;
       x_party_id := null;
   END IF;

   return  x_party_id;

END Get_Party_Id;

*/



FUNCTION Get_Customer_Class(p_cust_account_id IN NUMBER)
RETURN VARCHAR2
IS
x_class_code VARCHAR2(240);
BEGIN

    SELECT customer_class_code
    INTO   x_class_code
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_cust_account_id;

    RETURN x_class_code;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;

END Get_Customer_Class;

FUNCTION Get_Account_Type (p_cust_account_id IN NUMBER)
RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

TYPE t_cursor IS REF CURSOR;

x_account_type_ids     QP_Attr_Mapping_PUB.t_MultiRecord;
l_account_type_id      number;
v_count 	       NUMBER := 1;
l_acct_type_cursor     t_cursor;
BEGIN
    OPEN l_acct_type_cursor FOR
    SELECT profile_class_id
    FROM   HZ_CUSTOMER_PROFILES
    WHERE  cust_account_id = p_cust_account_id;

    LOOP

	FETCH l_acct_type_cursor INTO l_account_type_id;
	EXIT WHEN l_acct_type_cursor%NOTFOUND;

	x_account_type_ids(v_count) := l_account_type_id;
	v_count := v_count + 1;

    END LOOP;

    CLOSE l_acct_type_cursor;

    RETURN x_account_type_ids;

END Get_Account_Type;

FUNCTION Get_Sales_Channel (p_cust_account_id IN NUMBER)
RETURN VARCHAR2
IS
x_sales_channel_code VARCHAR2(240);
BEGIN

    SELECT sales_channel_code
    INTO   x_sales_channel_code
    FROM   hz_cust_accounts
    WHERE  cust_account_id = p_cust_account_id;

    RETURN x_sales_channel_code;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;


END Get_Sales_Channel;


FUNCTION Get_GSA (p_cust_account_id NUMBER)
RETURN VARCHAR2
IS
x_gsa VARCHAR2(1);
BEGIN

	SELECT gsa_indicator_flag
	INTO   x_gsa
	FROM   hz_cust_accounts accts ,hz_parties party
	WHERE  accts.party_id=party.party_id
	AND    cust_account_id =  p_cust_account_id;

	RETURN x_gsa;
EXCEPTION
WHEN OTHERS THEN
  RETURN NULL;

END get_gsa;

/*
FUNCTION Get_Site_Use (p_contact_id IN VARCHAR2)
RETURN VARCHAR2
IS

x_site_use_id VARCHAR2(240);

BEGIN

    SELECT site_use_id
    INTO   x_site_use_id
    FROM  HZ_CUST_SITE_USES_ALL
    WHERE  contact_id = p_contact_id;

    RETURN x_site_use_id;

END Get_Site_Use;
*/


FUNCTION Get_quote_Qty (p_qte_header_id IN NUMBER)
RETURN VARCHAR2
IS

x_quote_qty	  varchar2(30);
l_quote_qty	  NUMBER;

BEGIN

  SELECT SUM(nvl(quantity,0))
  INTO	l_quote_qty
  FROM aso_quote_lines_all
  WHERE quote_header_id=p_qte_header_id
  AND (line_category_code<>'RETURN' OR line_category_code IS NULL)
  GROUP BY quote_header_id;


   IF (SQL%NOTFOUND) THEN
 		l_quote_qty :=0;
   end if;

  x_quote_qty := FND_NUMBER.NUMBER_TO_CANONICAL(nvl(l_quote_qty, 0));
  RETURN x_quote_qty;
 EXCEPTION
 WHEN OTHERS THEN
   RETURN NULL;

END Get_quote_Qty;


FUNCTION Get_quote_Amount(p_qte_header_id IN NUMBER) RETURN VARCHAR2
IS
x_quote_amount	  VARCHAR2(30);
l_quote_amount	  NUMBER;

BEGIN

  SELECT SUM((nvl(quantity,0))*(LINE_LIST_PRICE-LINE_ADJUSTED_AMOUNT))
  INTO	l_quote_amount
  FROM aso_quote_lines_all
  WHERE quote_header_id=p_qte_header_id
  AND (line_category_code<>'RETURN' OR line_category_code IS NULL)
  GROUP BY quote_header_id;


  IF (SQL%NOTFOUND) THEN
	 l_quote_amount :=0;
  END IF;

  x_quote_amount:=FND_NUMBER.NUMBER_TO_CANONICAL(NVL(l_quote_amount,0));

  RETURN x_quote_amount;

END Get_quote_Amount;

-- order context

FUNCTION Get_shippable_flag(p_qte_line_id NUMBER)
RETURN VARCHAR2
IS
x_shippable_item_flag VARCHAR2(1);
BEGIN

	SELECT shippable_item_flag
	INTO   x_shippable_item_flag
	FROM  aso_i_items_v i, aso_quote_lines_all l
	WHERE  l.quote_line_id = p_qte_line_id
	and l.inventory_item_id = i.inventory_item_id
	and l.organization_id = i.organization_id;

	RETURN x_shippable_item_flag;
	EXCEPTION
	WHEN OTHERS THEN
	  RETURN NULL;

END get_shippable_flag;

FUNCTION Get_Cust_Po(
	p_qte_header_id     number
		) RETURN  VARCHAR2
		IS
		Cursor get_po is SELECT payment_ref_number from aso_payments
		WHERE
	payment_type_code ='PO' and quote_header_id = p_qte_header_id and quote_line_id is NULL;
		Customer_PO VARCHAR2(240);

		BEGIN
		OPEN get_po;
		fetch get_po into Customer_Po;
		CLOSE get_po;
		RETURN Customer_Po;
		EXCEPTION
		WHEN OTHERS THEN
		  RETURN NULL;

		END Get_Cust_Po;

FUNCTION Get_line_Cust_Po(
    p_qte_line_id       number
    ) RETURN  VARCHAR2
    IS
    Cursor get_po is SELECT payment_ref_number from aso_payments
    WHERE
    payment_type_code ='PO' and  quote_line_id = p_qte_line_id;
    Customer_PO VARCHAR2(240);

    BEGIN
    OPEN get_po;
    fetch get_po into Customer_Po;
    CLOSE get_po;
    RETURN Customer_Po;
    EXCEPTION
   WHEN OTHERS THEN
 RETURN NULL;

    END Get_line_Cust_Po;





FUNCTION Get_Request_date(
	p_qte_header_id 	number
	) RETURN  DATE
IS

Cursor get_req_date is SELECT request_date from aso_shipments
WHERE
quote_header_id = p_qte_header_id and quote_line_id is NULL;
l_request_date DATE;
x_request_date DATE;
BEGIN
OPEN get_req_date;
fetch get_req_date into l_request_date;
CLOSE get_req_date;

x_request_date := FND_DATE.DATE_TO_CANONICAL(l_request_date);
RETURN x_request_date;
END Get_Request_date;

FUNCTION Get_Line_Request_date(
     p_qte_line_id       number
) RETURN  DATE
IS

Cursor get_req_date is SELECT request_date from aso_shipments
WHERE quote_line_id = p_qte_line_id ;
l_request_date DATE;
x_request_date DATE;
BEGIN
OPEN get_req_date;
fetch get_req_date into l_request_date;
CLOSE get_req_date;

x_request_date := FND_DATE.DATE_TO_CANONICAL(l_request_date);
RETURN x_request_date;
END Get_line_Request_date;


FUNCTION Get_Freight_term(
	p_qte_header_id 	number
	) RETURN  DATE
IS

Cursor get_frieght is SELECT FREIGHT_TERMS_CODE from aso_shipments
WHERE
quote_header_id = p_qte_header_id and quote_line_id is NULL;
l_freight_terms_code VARCHAR2(30);
BEGIN
OPEN get_frieght;
fetch get_frieght into l_freight_terms_code;
CLOSE get_frieght;
RETURN l_freight_terms_code;
END Get_Freight_term;

FUNCTION Get_line_Freight_term(
	 p_qte_line_id    number
	) RETURN  VARCHAR2
IS

Cursor get_frieght is SELECT FREIGHT_TERMS_CODE from aso_shipments
WHERE
quote_line_id = p_qte_line_id;
l_freight_terms_code VARCHAR2(30);
BEGIN
OPEN get_frieght;
fetch get_frieght into l_freight_terms_code;
CLOSE get_frieght;
RETURN l_freight_terms_code;
END Get_line_Freight_term;

FUNCTION Get_Payment_term(
	p_qte_header_id 	number
	) RETURN  NUMBER
IS

Cursor get_pmnt_term is SELECT payment_term_id from aso_payments
WHERE
quote_header_id = p_qte_header_id and quote_line_id IS null;
l_pmnt_term_id NUMBER;
BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_line_Payment_term',1,'N');
	   aso_debug_pub.add('p_qte_header_id: '||nvl(to_char(p_qte_header_id),'null'),1,'N');
      END IF;
OPEN get_pmnt_term;
fetch get_pmnt_term into l_pmnt_term_id;
CLOSE get_pmnt_term;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_line_Payment_term'||l_pmnt_term_id,1,'N');
      END IF;
RETURN l_pmnt_term_id;
END Get_Payment_term;


FUNCTION Get_line_Payment_term(
	   p_qte_line_id    number,p_qte_header_id number
	) RETURN  NUMBER
IS
Cursor get_hdr_pmnt_term is SELECT payment_term_id from aso_payments
WHERE
quote_header_id = p_qte_header_id and quote_line_id IS null;

Cursor get_pmnt_term is SELECT payment_term_id from aso_payments
WHERE
quote_line_id = p_qte_line_id;
l_pmnt_term_id NUMBER;
BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_line_Payment_term',1,'N');
	   aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_qte_line_id),'null'),1,'N');
	   aso_debug_pub.add('p_qte_header_id: '||nvl(to_char(p_qte_header_id),'null'),1,'N');
      END IF;
OPEN get_pmnt_term;
fetch get_pmnt_term into l_pmnt_term_id;
CLOSE get_pmnt_term;

If l_pmnt_term_id is NULL or l_pmnt_term_id = fnd_api.g_miss_num then
OPEN get_hdr_pmnt_term;
fetch get_hdr_pmnt_term into l_pmnt_term_id;
CLOSE get_hdr_pmnt_term;
end if;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_line_Payment_term'||l_pmnt_term_id,1,'N');
      END IF;
RETURN l_pmnt_term_id;
END Get_line_Payment_term;

FUNCTION Get_freight_terms_code(p_qte_line_id NUMBER)
RETURN VARCHAR2
IS
     CURSOR C_line_freight_terms_code IS
     SELECT qs.freight_terms_code
     FROM aso_shipments qs
     WHERE  qs.quote_line_id = p_qte_line_id
     and qs.freight_terms_code is not null;

     CURSOR C_hdr_freight_terms_code IS
     SELECT qs.freight_terms_code
     FROM aso_shipments qs, aso_quote_lines_all ql
     WHERE qs.quote_header_id = ql.quote_header_id
     and ql.quote_line_id = p_qte_line_id
     and qs.quote_line_id IS NULL;

x_freight_terms_code VARCHAR2(30);

BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Get_freight_terms_code -  Begin  ',1,'Y');
        aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_qte_line_id),'null'),1,'N');
      END IF;

      OPEN C_line_freight_terms_code;
      FETCH C_line_freight_terms_code INTO x_freight_terms_code;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Line Level x_freight_terms_code: '||nvl(x_freight_terms_code,'null'),1,'N');
      END IF;

      IF (C_line_freight_terms_code%NOTFOUND) THEN

	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	      aso_debug_pub.add('Inside first IF statement ',1,'N');
	    END IF;

	    CLOSE C_line_freight_terms_code;

         OPEN C_hdr_freight_terms_code;
         FETCH C_hdr_freight_terms_code INTO x_freight_terms_code;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('Header Level x_freight_terms_code: '||nvl(x_freight_terms_code,'null'),1,'N');
         END IF;

	       IF (C_hdr_freight_terms_code%FOUND AND (x_freight_terms_code <> FND_API.G_MISS_CHAR)) THEN
             CLOSE C_hdr_freight_terms_code;
		      return x_freight_terms_code;
         ELSE
		      CLOSE C_hdr_freight_terms_code;
		      return null;
         END IF;

      ELSIF x_freight_terms_code = FND_API.G_MISS_CHAR THEN
         CLOSE C_line_freight_terms_code;
	    return null;
      END IF;

      CLOSE C_line_freight_terms_code;
      return x_freight_terms_code;

END Get_freight_terms_code ;


FUNCTION Get_shipping_method_code(p_qte_line_id NUMBER)
RETURN VARCHAR2
IS
     CURSOR C_line_ship_method_code IS
     SELECT qs.ship_method_code
     FROM aso_shipments qs
     WHERE  qs.quote_line_id = p_qte_line_id
     and qs.ship_method_code is not null;

     CURSOR C_hdr_ship_method_code IS
     SELECT qs.ship_method_code
     FROM aso_shipments qs, aso_quote_lines_all ql
     WHERE qs.quote_header_id = ql.quote_header_id
     and ql.quote_line_id = p_qte_line_id
     and qs.quote_line_id IS NULL;

x_ship_method_code VARCHAR2(30);

BEGIN

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Get_shipping_method_code -  Begin  ',1,'Y');
	   aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_qte_line_id),'null'),1,'N');
      END IF;

      OPEN C_line_ship_method_code;
      FETCH C_line_ship_method_code INTO x_ship_method_code;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Line Level x_ship_method_code: '||nvl(x_ship_method_code,'null'),1,'N');
      END IF;

      IF (C_line_ship_method_code%NOTFOUND) THEN

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('Inside first IF statement ',1,'N');
         END IF;

	    CLOSE C_line_ship_method_code;
         OPEN C_hdr_ship_method_code;
         FETCH C_hdr_ship_method_code INTO x_ship_method_code;

         IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
           aso_debug_pub.add('Header Level x_ship_method_code: '||nvl(x_ship_method_code,'null'),1,'N');
         END IF;

	    IF (C_hdr_ship_method_code%FOUND AND (x_ship_method_code <> FND_API.G_MISS_CHAR)) THEN
             CLOSE C_hdr_ship_method_code;
		   return x_ship_method_code;
         ELSE
		   CLOSE C_hdr_ship_method_code;
		   return null;
         END IF;
      ELSIF x_ship_method_code = FND_API.G_MISS_CHAR THEN
         CLOSE C_line_ship_method_code;
	    return null;
      END IF;
      CLOSE C_line_ship_method_code;
      return x_ship_method_code;
	 EXCEPTION
			 WHEN OTHERS THEN
					   RETURN NULL;


END Get_shipping_method_code ;


FUNCTION Get_top_model_item_id(p_qte_line_id NUMBER)
RETURN NUMBER
IS


     x_top_model_line_id NUMBER;
     lv_quote_line_id NUMBER;
     x_inventory_item_id NUMBER;

     CURSOR C_top_model_line_id(l_quote_line_id NUMBER) IS
     select  quote_line_id
     from aso_line_relationships  aso_rel
     where aso_rel.related_quote_line_id = l_quote_line_id;

     CURSOR C_item_id IS
     select inventory_item_id
     from aso_quote_lines_all
     where quote_line_id = x_top_model_line_id;


BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Get_top_model_item_id -  Begin  ',1,'Y');
	   aso_debug_pub.add('Get_top_model_item_id G_LINE_REC.MODEL_ID  '||ASO_PRICING_INT.G_LINE_REC.MODEL_ID,1,'Y');
      END IF;
	 /* iStore Cataloge is directly setting G_LINE_REC.model_id,Hence we need to return the same value*/
	 IF ASO_PRICING_INT.G_LINE_REC.MODEL_ID IS NOT NULL AND ASO_PRICING_INT.G_LINE_REC.MODEL_ID <> FND_API.G_MISS_NUM THEN
	    Return ASO_PRICING_INT.G_LINE_REC.MODEL_ID;
      END IF;
	 IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	   aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_qte_line_id),'null'),1,'N');
	 END IF;

	 x_top_model_line_id := p_qte_line_id;

      OPEN C_top_model_line_id(x_top_model_line_id);
      FETCH C_top_model_line_id INTO lv_quote_line_id;

      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Before loop - lv_quote_line_id: '||nvl(to_char(lv_quote_line_id),'null'),1,'N');
      END IF;

      IF (C_top_model_line_id%NOTFOUND) THEN
          CLOSE C_top_model_line_id;
		return null;
      END IF;
	 x_top_model_line_id := lv_quote_line_id;
      CLOSE C_top_model_line_id;

      Loop
          OPEN C_top_model_line_id(x_top_model_line_id);
          FETCH C_top_model_line_id INTO lv_quote_line_id;

          IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
            aso_debug_pub.add('Inside Loop - lv_quote_line_id: '||nvl(to_char(lv_quote_line_id),'null'),1,'N');
          END IF;

          IF (C_top_model_line_id%NOTFOUND) THEN
             CLOSE C_top_model_line_id;
             EXIT;
          END IF;

          CLOSE C_top_model_line_id;
          x_top_model_line_id := lv_quote_line_id;
      End Loop;

      open C_item_id;
      fetch C_item_id INTO x_inventory_item_id;
	 IF C_item_id%FOUND AND x_inventory_item_id <> FND_API.G_MISS_NUM THEN
          return x_inventory_item_id;
      ELSE
		return null;
      END IF;

       EXCEPTION
			  WHEN OTHERS THEN
					    RETURN NULL;

END Get_top_model_item_id ;

FUNCTION Get_header_ship_flag(p_qte_header_id NUMBER)
RETURN VARCHAR2
IS
x_shippable_item_flag VARCHAR2(1);
--x_count number;
x_count varchar2(1);

CURSOR C_Is_Item_Shippable IS
SELECT 'x'
FROM  aso_quote_lines_all l
WHERE l.quote_header_id = p_qte_header_id
AND EXISTS ( SELECT null
             FROM mtl_system_items_b i
             WHERE l.inventory_item_id = i.inventory_item_id
             AND l.organization_id = i.organization_id
             AND i.shippable_item_flag = 'Y' );

BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_header_ship_flag',1,'N');
	   aso_debug_pub.add('p_qte_header_id: '||nvl(to_char(p_qte_header_id),'null'),1,'N');
      END IF;

--SELECT count(*)
-- INTO   x_count
--FROM  aso_i_items_v i, aso_quote_lines_all l,
--aso_quote_headers_all h
--WHERE l.quote_header_id=h.quote_header_id
--and  h.quote_header_id = p_qte_header_id
--and l.inventory_item_id = i.inventory_item_id
--and l.organization_id = i.organization_id
--and i.shippable_item_flag = 'Y';

/****IF x_count > 0 THEN x_shippable_item_flag:='Y';
END IF;
IF x_count = 0 THEN x_shippable_item_flag:='N';
END IF;
*******/

For C_Is_Item_Shippable_Rec in C_Is_Item_Shippable loop
    If C_Is_Item_Shippable%found then
       x_shippable_item_flag:='Y';
	  exit;
    else
       x_shippable_item_flag:='N';
    end if;
end loop;
IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('x_shippable_item_flag: '||x_shippable_item_flag,1,'N');
END IF;

   RETURN x_shippable_item_flag;
   EXCEPTION
		   WHEN OTHERS THEN
					RETURN NULL;

--						EXCEPTION
--  WHEN no_data_found THEN
 -- x_shippable_item_flag := null;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_header_ship_flag '||x_shippable_item_flag,1,'N');
      END IF;

END get_header_ship_flag;

FUNCTION Get_Parent_List_price (p_quote_line_id NUMBER)
RETURN NUMBER
IS
x_list_price  NUMBER :=NULL;
l_SERVICE_REF_TYPE_CODE varchar2(20);
l_service_ref_line_id NUMBER;

Cursor c_get (l_quote_line_id NUMBER) IS
SELECT SERVICE_REF_TYPE_CODE,service_ref_line_id
FROM    aso_quote_line_details qld
WHERE   qld.quote_line_id = l_quote_line_id ;

BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_Parent_List_price',1,'N');
	   aso_debug_pub.add('p_qte_line_id: '||nvl(to_char(p_quote_line_id),'null'),1,'N');
      END IF;
 OPEN c_get(p_quote_line_id );
 FETCH c_get INTO l_SERVICE_REF_TYPE_CODE,l_service_ref_line_id;

	  IF l_SERVICE_REF_TYPE_CODE = 'QUOTE' Then
			 select line_list_price
			   INTO    x_list_price
			   from   aso_quote_lines_all ql
			  where  ql.quote_line_id = l_service_ref_line_id;
	   Elsif l_SERVICE_REF_TYPE_CODE = 'ORDER' then
		    select unit_list_price
			INTO    x_list_price
     	    from   oe_order_lines_All
		    where  line_id = l_service_ref_line_id;
     END IF;
Close c_get;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Inside Get_Parent_List_price'||x_list_price,1,'N');
      END IF;
return x_list_price;
EXCEPTION
		WHEN OTHERS THEN
				  RETURN NULL;

END Get_Parent_List_price;


FUNCTION Get_Minisite_Id RETURN NUMBER
IS
x_minisite_id NUMBER := NULL;
BEGIN
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('Start of Get_Minisite_Id...',1,'N');
	aso_debug_pub.add('G_HEADER_REC.minisite_id: '||nvl(to_char(ASO_PRICING_INT.G_HEADER_REC.minisite_id),'null'),1,'N');
	aso_debug_pub.add('G_LINE_REC.minisite_id: '||nvl(to_char(ASO_PRICING_INT.G_LINE_REC.minisite_id),'null'),1,'N');
      END IF;
	   IF ASO_PRICING_INT.G_LINE_REC.MINISITE_ID IS NOT NULL AND
	      ASO_PRICING_INT.G_LINE_REC.MINISITE_ID <> FND_API.G_MISS_NUM
           THEN
 		x_minisite_id := ASO_PRICING_INT.G_LINE_REC.MINISITE_ID;
	   ELSIF ASO_PRICING_INT.G_HEADER_REC.MINISITE_ID IS NOT NULL AND
		 ASO_PRICING_INT.G_HEADER_REC.MINISITE_ID <> FND_API.G_MISS_NUM
           THEN
		x_minisite_id := ASO_PRICING_INT.G_HEADER_REC.MINISITE_ID;
	   END IF;
      IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
        aso_debug_pub.add('After Get_Minisite_Id...x_minisite_id :'||x_minisite_id,1,'N');
      END IF;
 RETURN x_minisite_id;
EXCEPTION
	WHEN OTHERS THEN
            RETURN NULL;
END Get_Minisite_Id;

End ASO_SOURCING_PVT;

/
