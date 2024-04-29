--------------------------------------------------------
--  DDL for Package Body OE_CUSTACCEPTREP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_CUSTACCEPTREP_PVT" AS
/* $Header: OEXVCARB.pls 120.12 2006/09/19 11:08:01 myerrams noship $ */
--Package Name
  G_PKG_NAME CONSTANT VARCHAR2(50) := 'OE_CustAcceptRep_PVT';
--Global Variables that will contain the parameters values
  g_sorted_by               VARCHAR2(30);
  g_customer_name_low       VARCHAR2(100); --myerrams, CustomerName can be more than 30 chars long. Making it to 100
  g_customer_name_high      VARCHAR2(100); --myerrams, CustomerName can be more than 30 chars long. Making it to 100
  g_customer_no_low         VARCHAR2(30);
  g_customer_no_high        VARCHAR2(30);
  g_order_type_low          VARCHAR2(30);
  g_order_type_high         VARCHAR2(30);
  g_order_no_low            NUMBER;
  g_order_no_high           NUMBER;
  g_order_date_low          DATE;
  g_order_date_high         DATE;
  g_fulfill_date_low        DATE;
  g_fulfill_date_high       DATE;
  g_accepted_date_low       DATE;
  g_accepted_date_high      DATE;
  g_acceptance_status       VARCHAR2(30);
  g_item_display            VARCHAR2(30);
  g_currency                VARCHAR2(30);

--myerrams, currency related global variables
  g_func_currency           VARCHAR2(30);
  g_func_currency_desc	    VARCHAR2(30);
  g_ord_currency	    VARCHAR2(30);
--myerrams, end

  g_org_id                  NUMBER;
  g_operating_unit          VARCHAR2(240);
--Get the value of debug level set by the user.
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  g_counter		 NUMBER := 0;	--myerrams, Introduced for no_date_found logic.

--=============================================================================
-- PROCEDURES AND FUNCTIONS
--=============================================================================
--=============================================================================
-- Start of comments
-- PROCEDURE      : gl_conversion_rate_func
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the parameter values in the XML output.
--=============================================================================
function gl_conversion_rate_func (
	P_from_currency			VARCHAR2,
	P_to_currency			VARCHAR2,
	P_ordered_date			DATE,
	P_conversion_type_code		VARCHAR2
	)
return Number is
begin

Declare
    gl_rate number;
BEGIN
	IF p_conversion_type_code is null then
	   gl_rate := gl_currency_api.get_rate (
					P_from_currency,
					P_to_currency,
					P_ordered_date);
	RETURN(gl_rate);
	ELSE
	   gl_rate := gl_currency_api.get_rate (
					P_from_currency,
					P_to_currency,
					P_ordered_date,
					P_conversion_type_code );
	RETURN(gl_rate);
	END IF;
EXCEPTION
WHEN NO_DATA_FOUND THEN
RETURN(-1);
 WHEN OTHERS THEN
RETURN(-1);
end;

RETURN NULL; end;

--=============================================================================
-- PROCEDURE NAME: To_Xsd_Date_String
-- TYPE          : PUBLIC
-- PARAMETERS    :
--   p_date        Oracle Date to be converted to XSD Date Format
-- RETURN        : A String representing the passed in Date in XSD Date Format
-- DESCRIPTION   : Convert an Oracle DB Date Object to a date string represented
--                 in the XSD Date Format.  This is mainly for use by the
--                 XML Publisher Reports.
-- EXCEPTIONS    :
--
-- CHANGE HISTORY: 012-SEP-06    MYERRAMS    Created.
--=============================================================================

FUNCTION To_Xsd_Date_String
( p_date IN DATE
)
RETURN VARCHAR2
IS

l_api_name CONSTANT VARCHAR2(30) := 'To_Xsd_Date_String';
l_xsd_date_string   VARCHAR2(40);

BEGIN

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR:' || l_api_name || '.begin') ;
 END IF;

  SELECT TO_CHAR(p_date, 'YYYY-MM-DD')
  INTO   l_xsd_date_string
  FROM   DUAL;

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR:' || l_api_name || '.end: Returning XSD Date = ' || l_xsd_date_string ) ;
 END IF;

  l_xsd_date_string := TRIM(l_xsd_date_string);

  RETURN l_xsd_date_string;

EXCEPTION

  WHEN OTHERS THEN
  IF l_debug_level  > 0
  THEN
	oe_debug_pub.add(  'OEXCARR:'  || l_api_name || ': ' || sqlerrm ) ;
  END IF;

  RETURN NULL;

END To_Xsd_Date_String;

--=============================================================================

--=============================================================================
-- Start of comments
-- PROCEDURE      : put_parameter_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the parameter values in the XML output.
--=============================================================================
PROCEDURE put_parameter_tags IS
l_acceptance_status	VARCHAR2(100);
l_item_display		VARCHAR2(50);
l_sorted_by		VARCHAR2(30);
l_order_type_low          VARCHAR2(30);
l_order_type_high         VARCHAR2(30);

l_order_date_low	VARCHAR2(50);
l_order_date_high	VARCHAR2(50);
l_fulfill_date_low	VARCHAR2(50);
l_fulfill_date_high	VARCHAR2(50);
l_accepted_date_low	VARCHAR2(50);
l_accepted_date_high	VARCHAR2(50);

BEGIN
  IF l_debug_level  > 0
  THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_parameter_tags') ;
  END IF;

--myerrams, converting the sort by option to an appropriate display name.
--myerrams, Bug: 5480694
IF g_sorted_by IS NOT NULL
THEN
select meaning into l_sorted_by
from oe_lookups
where lookup_type='OECARR_ORDER_BY'
and lookup_code=g_sorted_by;
END IF;
--myerrams, end

--myerrams, Bug: 5480694
 IF g_acceptance_status IS NOT NULL
 THEN
 select meaning into l_acceptance_status
 from oe_lookups
 where lookup_type='OECARR_ACC_STATUS'
 and lookup_code = g_acceptance_status;
 END IF;

--myerrams, Selecting the appropriate Item Display Name from OE Lookups
 IF g_item_display IS NOT NULL
 THEN
  select meaning into l_item_display
	from OE_LOOKUPS
	where lookup_type = 'ITEM_DISPLAY_CODE'
	and LOOKUP_CODE=g_item_display;
 END IF;
--myerrams, end

--myerrams, Selecting the appropriate Order Type Name.	Bug: 5230819
 IF g_order_type_low IS NOT NULL
 THEN
  select name into l_order_type_low
	from OE_ORDER_TYPES_V
	where order_type_id = g_order_type_low ;
 END IF;
 IF g_order_type_high IS NOT NULL
 THEN
  select name into l_order_type_high
	from OE_ORDER_TYPES_V
	where order_type_id = g_order_type_high ;
 END IF;
--myerrams, end;

/* myerrams, Convert an Oracle DB Date Object to a date string represented in the XSD Date Format */

  IF g_order_date_low IS NOT NULL
  THEN
  l_order_date_low := To_Xsd_Date_String(g_order_date_low);
  END IF;

  IF g_order_date_high IS NOT NULL
  THEN
  l_order_date_high := To_Xsd_Date_String(g_order_date_high);
  END IF;

  IF g_fulfill_date_low IS NOT NULL
  THEN
  l_fulfill_date_low := To_Xsd_Date_String(g_fulfill_date_low);
  END IF;

  IF g_fulfill_date_high IS NOT NULL
  THEN
  l_fulfill_date_high := To_Xsd_Date_String(g_fulfill_date_high);
  END IF;

  IF g_accepted_date_low IS NOT NULL
  THEN
  l_accepted_date_low := To_Xsd_Date_String(g_accepted_date_low);
  END IF;

  IF g_accepted_date_high IS NOT NULL
  THEN
  l_accepted_date_high := To_Xsd_Date_String(g_accepted_date_high);
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<?xml version="1.0" ?>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT, '<OEXCARR>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<OPERATING_UNIT>' ||g_operating_unit|| '</OPERATING_UNIT>');
--myerrams  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CURRENCY>' ||g_currency|| '</CURRENCY>');
--myerrams  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_BY>' || g_sorted_by || '</ORDER_BY>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_BY_PARAM>' || l_sorted_by || '</ORDER_BY_PARAM>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NAME_LOW>' || '<![CDATA['||g_customer_name_low||']]>' || '</CUSTOMER_NAME_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NAME_HIGH>' || '<![CDATA['||g_customer_name_high||']]>' || '</CUSTOMER_NAME_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NO_LOW>' || g_customer_no_low || '</CUSTOMER_NO_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NO_HIGH>' || g_customer_no_high || '</CUSTOMER_NO_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_TYPE_LOW>' || l_order_type_low || '</ORDER_TYPE_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_TYPE_HIGH>' || l_order_type_high || '</ORDER_TYPE_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_NO_LOW>' || g_order_no_low || '</ORDER_NO_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_NO_HIGH>' || g_order_no_high || '</ORDER_NO_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDERED_DATE_LOW>' || l_order_date_low || '</ORDERED_DATE_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDERED_DATE_HIGH>' || l_order_date_high || '</ORDERED_DATE_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<FULFILL_DATE_LOW>' || l_fulfill_date_low || '</FULFILL_DATE_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<FULFILL_DATE_HIGH>' || l_fulfill_date_high || '</FULFILL_DATE_HIGH>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTED_DATE_LOW>' || l_accepted_date_low || '</ACCEPTED_DATE_LOW>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTED_DATE_HIGH>' || l_accepted_date_high || '</ACCEPTED_DATE_HIGH>');
--myerrams  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTANCE_STATUS>' || g_acceptance_status || '</ACCEPTANCE_STATUS>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTANCE_STATUS>' || l_acceptance_status || '</ACCEPTANCE_STATUS>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<FUNC_CURRENCY>' || g_func_currency_desc || '</FUNC_CURRENCY>');
  --myerrams
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ITEM_DISPLAY>' || l_item_display || '</ITEM_DISPLAY>');
  --myerrams, end
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<USERID>' || FND_GLOBAL.USER_NAME || '</USERID>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<REQUESTID>' || FND_GLOBAL.CONC_REQUEST_ID || '</REQUESTID>');
END;
--=============================================================================
-- Start of comments
-- FUNCTION       : create_where_clause
-- PRE-CONDITIONS : None.
-- COMMENTS       : Creates where clause for the queries based on the
--                  input parameters passed by the user.
-- PARAMETERS     : The query String
-- RETURN         : Query string with where clause generated based on the
--                  user parameters.
--=============================================================================

FUNCTION create_where_clause
(p_where_clause VARCHAR2)
RETURN VARCHAR2
IS
  l_query VARCHAR2(15000);
BEGIN

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR: Inside create_where_clause') ;
 END IF;
 l_query := p_where_clause;

 IF g_customer_no_low IS NOT NULL
 THEN
/*myerrams, customer number is varchar, not a number
  l_query := l_query || ' AND hca.account_number BETWEEN '||  g_customer_no_low||
             ' AND ' || nvl(g_customer_no_high,g_customer_no_low);
myerrams, end*/
  l_query := l_query || ' AND hca.account_number BETWEEN '||''''||  g_customer_no_low||''''||
             ' AND ' ||''''|| nvl(g_customer_no_high,g_customer_no_low)||'''';
 END IF;

 IF g_customer_name_low IS NOT NULL
 THEN
  l_query := l_query || ' AND hp.party_name BETWEEN '||''''||  g_customer_name_low ||''''||
             ' AND ' ||''''|| nvl(g_customer_name_high,g_customer_name_low)||'''';
 END IF;

 IF g_order_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.ordered_date BETWEEN '||
             ''''||  g_order_date_low ||''''||' AND ' ||''''|| nvl(g_order_date_high,g_order_date_low)||'''';
 END IF;

 IF g_order_type_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.order_type_id BETWEEN '||
             g_order_type_low ||' AND ' || nvl(g_order_type_high,g_order_type_low);
 END IF;

 IF g_order_no_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.order_number BETWEEN '||
             g_order_no_low ||' AND ' || nvl(g_order_no_high,g_order_no_low);
 END IF;

 IF g_fulfill_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oln.fulfillment_date BETWEEN '||
             ''''||  g_fulfill_date_low ||''''||' AND ' ||
	     ''''|| nvl(g_fulfill_date_high,g_fulfill_date_low)||'''';
 END IF;
 IF g_accepted_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oln.revrec_signature_date BETWEEN '||
             ''''||  g_accepted_date_low ||''''||' AND ' ||
	     ''''|| nvl(g_accepted_date_high,g_accepted_date_low)||'''';
 END IF;

  IF g_acceptance_status = 'PRE-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'POST-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'REJECTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity = 0' ;
  ELSIF g_acceptance_status = 'ACCEPTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity > 0' ;
  ELSE
   l_query := l_query || ' AND (oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''
			   OR oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''
			   OR oln.accepted_quantity >= 0) ';
  END IF;

IF l_debug_level  > 0 THEN
 oe_debug_pub.add(  'OEXCARR: create_where_clause returns : '||l_query);
END IF;
return l_query;

END;

--=============================================================================
-- Start of comments
-- FUNCTION       : create_ord_where_clause
-- PRE-CONDITIONS : None.
-- COMMENTS       : Creates where clause for the queries based on the
--                  input parameters passed by the user.
-- PARAMETERS     : The query String
-- RETURN         : Query string with where clause generated based on the
--                  user parameters.
--=============================================================================

FUNCTION create_ord_where_clause
( p_where_clause VARCHAR2
 ,p_cust_id      NUMBER)
RETURN VARCHAR2
IS
  l_query VARCHAR2(15000);
BEGIN

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR: Inside create_ord_where_clause') ;
 END IF;
 l_query := p_where_clause;
 IF p_cust_id IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.sold_to_org_id = '||  p_cust_id;
 END IF;

 IF g_order_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.ordered_date BETWEEN '||
             ''''||  g_order_date_low ||''''||' AND ' ||''''|| nvl(g_order_date_high,g_order_date_low)||'''';
 END IF;

 IF g_order_type_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.order_type_id BETWEEN '||
             g_order_type_low ||' AND ' || nvl(g_order_type_high,g_order_type_low);
 END IF;

 IF g_order_no_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.order_number BETWEEN '||
             g_order_no_low ||' AND ' || nvl(g_order_no_high,g_order_no_low);
 END IF;

  IF g_acceptance_status = 'PRE-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'POST-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'REJECTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity = 0' ;
  ELSIF g_acceptance_status = 'ACCEPTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity > 0' ;
  ELSE
   l_query := l_query || ' AND (oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''
			   OR oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''
			   OR oln.accepted_quantity >= 0) ';
  END IF;

IF l_debug_level  > 0 THEN
 oe_debug_pub.add(  'OEXCARR: create_where_clause returns : '||l_query);
END IF;
return l_query;

END;

--myerrams, start
--=============================================================================
-- Start of comments
-- FUNCTION       : create_curr_where_clause
-- PRE-CONDITIONS : None.
-- COMMENTS       : Creates where clause for the queries based on the
--                  input parameters passed by the user.
-- PARAMETERS     : The query String
-- RETURN         : Query string with where clause generated based on the
--                  user parameters.
--=============================================================================

FUNCTION create_curr_where_clause
( p_where_clause VARCHAR2
 ,p_curr_code    VARCHAR2)
RETURN VARCHAR2
IS
  l_query	VARCHAR2(15000);
BEGIN

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR: Inside create_curr_where_clause') ;
 END IF;
 l_query := p_where_clause;
 IF p_curr_code IS NOT NULL
 THEN
  l_query := l_query || ' AND oha.TRANSACTIONAL_CURR_CODE = '|| ''''|| p_curr_code||'''';
 END IF;
return l_query;
END;
--myerrams, end

--=============================================================================
-- Start of comments
-- FUNCTION       : create_lines_where_clause
-- PRE-CONDITIONS : None.
-- COMMENTS       : Creates where clause for the queries based on the
--                  input parameters passed by the user.
-- PARAMETERS     : The query String
-- RETURN         : Query string with where clause generated based on the
--                  user parameters.
--=============================================================================

FUNCTION create_lines_where_clause
         (p_where_clause VARCHAR2
	 ,p_header_id    NUMBER
	 )
RETURN VARCHAR2
IS
  l_query VARCHAR2(15000);
BEGIN

 IF l_debug_level  > 0
 THEN
   oe_debug_pub.add(  'OEXCARR: Inside create_lines_where_clause') ;
 END IF;
 l_query := p_where_clause;
 IF p_header_id IS NOT NULL
 THEN
  l_query := l_query || ' AND oln.header_id = '||  p_header_id;
 END IF;

 IF g_fulfill_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oln.fulfillment_date BETWEEN '||
             ''''||  g_fulfill_date_low ||''''||' AND ' ||
	     ''''|| nvl(g_fulfill_date_high,g_fulfill_date_low)||'''';
 END IF;
 IF g_accepted_date_low IS NOT NULL
 THEN
  l_query := l_query || ' AND oln.revrec_signature_date BETWEEN '||
             ''''||  g_accepted_date_low ||''''||' AND ' ||
	     ''''|| nvl(g_accepted_date_high,g_accepted_date_low)||'''';
 END IF;

  IF g_acceptance_status = 'PRE-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'POST-BILLING_ACCEPTANCE'
  THEN
   l_query := l_query || ' AND oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''' ;
  ELSIF g_acceptance_status = 'REJECTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity = 0' ;
  ELSIF g_acceptance_status = 'ACCEPTED'
  THEN
   l_query := l_query || ' AND oln.accepted_quantity > 0' ;
   ELSE
   l_query := l_query || ' AND (oln.flow_status_code = ''PRE-BILLING_ACCEPTANCE''
			   OR oln.flow_status_code = ''POST-BILLING_ACCEPTANCE''
			   OR oln.accepted_quantity >= 0) ';
  END IF;

IF l_debug_level  > 0 THEN
 oe_debug_pub.add(  'OEXCARR: create_where_clause returns : '||l_query);
END IF;
return l_query;

END;

--=============================================================================
-- Start of comments
-- PROCEDURE      : put_ghead_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the header tags in the generated XML output.
--=============================================================================
PROCEDURE put_ghead_tags
          ( p_party_name          VARCHAR2
	   ,p_account_number      VARCHAR2
	  )
IS
BEGIN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXCARR: Inside put_ghead_tags') ;
    END IF;

    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<LIST_G_CUST>');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NAME>' || '<![CDATA['||p_party_name||']]>' || '</CUSTOMER_NAME>');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NUMBER>'|| p_account_number || '</CUSTOMER_NUMBER>');
END;

--myerrams, start
--=============================================================================
-- Start of comments
-- PROCEDURE      : put_gcurr_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the currency header tags in the generated XML output.
--=============================================================================
PROCEDURE put_gcurr_tags
          ( p_currency          VARCHAR2
	   ,p_order_by          VARCHAR2
	  )
IS

BEGIN
    IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXCARR: Inside put_gcurr_tags') ;
    END IF;
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<LIST_G_CURR>');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CURRENCY>' || p_currency || '</CURRENCY>');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_BY>'|| p_order_by || '</ORDER_BY>');
END;
--myerrams, end

--=============================================================================
-- Start of comments
-- PROCEDURE      : put_ord_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the header tags in the generated XML output.
--=============================================================================
PROCEDURE put_ord_tags
          ( p_order_number          VARCHAR2
	   ,p_order_date            DATE
	   ,p_customer_po           VARCHAR2
	   ,p_order_type            VARCHAR2
	   ,p_sales_rep             VARCHAR2
	   ,p_party_name            VARCHAR2
	   ,p_account_number        VARCHAR2
	   ,p_currency	            VARCHAR2	--myerrams, added the currency to comply with XML Publisher Currency Formatting Standards
	  )
IS
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_ord_tags') ;
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<LIST_G_ORD>');
  IF p_party_name IS NOT NULL
  THEN
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NAME>' || '<![CDATA['||p_party_name||']]>' || '</CUSTOMER_NAME>');
    FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_NUMBER>'|| p_account_number || '</CUSTOMER_NUMBER>');
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_NUMBER>' || p_order_number || '</ORDER_NUMBER>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_DATE>'|| p_order_date || '</ORDER_DATE>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CUSTOMER_PO>'|| p_customer_po || '</CUSTOMER_PO>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ORDER_TYPE>'|| p_order_type || '</ORDER_TYPE>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SALES_PERSON>' || p_sales_rep || '</SALES_PERSON>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CURRENCY_LINE>' || p_currency || '</CURRENCY_LINE>');  --myerrams, Added order level Currency Tag. Bug: 5480694
END;

--=============================================================================
-- Start of comments
-- PROCEDURE      : put_line_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the line tags in the generated XML output.
--=============================================================================
PROCEDURE put_line_tags
          ( p_line_number            NUMBER
	   ,p_ordered_item           VARCHAR2
	   ,p_fulfilled_quantity     NUMBER
	   ,p_shipping_quantity_uom  VARCHAR2
	   ,p_accepted_quantity      NUMBER
	   ,p_rejected_quantity      NUMBER
	   ,p_pending_quantity       NUMBER
	   ,p_accepted_quantity_value NUMBER
	   ,p_rejected_quantity_value NUMBER
	   ,p_pending_quantity_value NUMBER
	   ,p_currency		     VARCHAR2	--myerrams, added the currency to comply with XML Publisher Number Formatting Standards
	  ) IS
BEGIN
     IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXCARR: Inside put_line_tags') ;
     END IF;
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<LIST_G_LINES>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<CURRENCY_LINE>' || p_currency || '</CURRENCY_LINE>');  --myerrams, Added order level Currency Tag for formatting the number columns in the RTF template. Bug: 5460837
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_LINE_NUMBER>' || p_line_number || '</SO_LINE_NUMBER>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_ITEM>' || p_ordered_item || '</SO_ITEM>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_FULFILLED_QTY>' || nvl(p_fulfilled_quantity,0) || '</SO_FULFILLED_QTY>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_UOM>' || p_shipping_quantity_uom || '</SO_UOM>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_ACCEPTED_QTY>'|| nvl(p_accepted_quantity,0) || '</SO_ACCEPTED_QTY>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_ACCEPTED_VALUE>'|| nvl(p_accepted_quantity_value,0) || '</SO_ACCEPTED_VALUE>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_REJECTED_QTY>'||nvl(p_rejected_quantity,0) || '</SO_REJECTED_QTY>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_REJECTED_VALUE>'|| nvl(p_rejected_quantity_value,0) || '</SO_REJECTED_VALUE>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_PENDING_ACC_QTY>'|| nvl(p_pending_quantity,0)|| '</SO_PENDING_ACC_QTY>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<SO_PENDING_ACC_VALUE>'|| nvl(p_pending_quantity_value,0)|| '</SO_PENDING_ACC_VALUE>');
     FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</LIST_G_LINES>');
END;
--=============================================================================
-- Start of comments
-- PROCEDURE      : put_order_total_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the order level totals in the generated XML output.
--=============================================================================
PROCEDURE put_order_total_tags
          ( p_accepted_value     NUMBER
	   ,p_rejected_value     NUMBER
	   ,p_pending_value      NUMBER
	  )
IS
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_order_total_tags') ;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTED_ORD_TOTAL>'|| p_accepted_value || '</ACCEPTED_ORD_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<REJECTED_ORD_TOTAL>'|| p_rejected_value || '</REJECTED_ORD_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<PENDING_ORD_TOTAL>'|| p_pending_value || '</PENDING_ORD_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</LIST_G_ORD>');
END;
--=============================================================================
-- Start of comments
-- PROCEDURE      : put_cust_total_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the customer level totals in the generated XML output.
--=============================================================================
PROCEDURE put_cust_total_tags
          ( p_accepted_value     NUMBER
	   ,p_rejected_value     NUMBER
	   ,p_pending_value      NUMBER
	  )
IS
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_cust_total_tags') ;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTED_CUST_TOTAL>'|| p_accepted_value || '</ACCEPTED_CUST_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<REJECTED_CUST_TOTAL>'|| p_rejected_value || '</REJECTED_CUST_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<PENDING_CUST_TOTAL>'|| p_pending_value || '</PENDING_CUST_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</LIST_G_CUST>');
END;
--=============================================================================
-- Start of comments
-- PROCEDURE      : put_rep_total_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the report level totals in the generated XML output.
--=============================================================================
PROCEDURE put_rep_total_tags
          ( p_accepted_value     NUMBER
	   ,p_rejected_value     NUMBER
	   ,p_pending_value      NUMBER
	  )
IS
BEGIN
  IF l_debug_level  > 0 THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_rep_total_tags') ;
  END IF;
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<ACCEPTED_REP_TOTAL>'|| p_accepted_value || '</ACCEPTED_REP_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<REJECTED_REP_TOTAL>'|| p_rejected_value || '</REJECTED_REP_TOTAL>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<PENDING_REP_TOTAL>'|| p_pending_value || '</PENDING_REP_TOTAL>');
--myerrams, start
--  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</OEXCARR>');
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</LIST_G_CURR>');
--myerrams, end

END;

--=============================================================================
-- Start of comments
-- PROCEDURE      : put_remaining_tags
-- PRE-CONDITIONS : None.
-- COMMENTS       : Puts the customer, order and line values in the XML output.
--=============================================================================
PROCEDURE put_remaining_tags
(
	  p_sorted_by	VARCHAR2
	, p_func_currency VARCHAR2
	, p_errbuf	OUT NOCOPY  VARCHAR2
	, p_retcode	OUT NOCOPY  VARCHAR2
)
IS
l_cust_cursor_query VARCHAR2(15000) := 'SELECT DISTINCT hp.party_name, '||
                                         '       hca.account_number, '||
                                         '       hca.cust_account_id '||
					 'FROM   hz_parties hp, '||
					 '       hz_cust_accounts_all hca, '||
					 '       oe_order_headers_all oha, '||
					 '       oe_order_lines_all   oln, '||
					 '       oe_transaction_types_all ota '||
					 'WHERE  hp.party_id = hca.party_id '||
					 'AND    hca.cust_account_id = oha.sold_to_org_id '||
					 'AND    oha.header_id = oln.header_id '||
					 'AND    oha.order_type_id = ota.transaction_type_id ';

--myerrams, Modified the following query to add oe_order_lines_all
--myerrams, Bug: 5259257. Added Distinct keyword to remove the duplicates.
l_ord_cursor_query VARCHAR2(15000) := 'SELECT distinct oha.order_number,'||
                                        '       oha.header_id,'||
					'       oha.ordered_date,'||
					'	oha.cust_po_number,'||
					'	ota.order_category_code,'||
					'       rsa.name, '||
					'       oha.TRANSACTIONAL_CURR_CODE, '||
					'	oha.conversion_type_code, '||
					'	oha.conversion_rate '||
					'FROM   oe_order_headers_all oha, '||
					'       oe_order_lines_all oln, '||
					'       oe_transaction_types_all ota, '||
					'	ra_salesreps_all rsa '||
					'WHERE  oha.order_type_id = ota.transaction_type_id '||
					'AND    oha.header_id = oln.header_id ' ||
					'AND    oha.salesrep_id = rsa.salesrep_id ';

l_line_cursor_query VARCHAR2(15000) := 'SELECT oln.line_number,'||
                                         '       oln.ordered_item,'||
					 '	 oln.user_item_description,'||
					 '       msi.concatenated_segments,'||
					 '       msi.description,'||
					 '	 oln.ordered_quantity, '||
					 '	 oln.ordered_quantity * oln.unit_selling_price ordered_value, '||
					 '       oln.fulfilled_quantity,'||
					 '       oln.fulfilled_quantity * oln.unit_selling_price fulfilled_value,'||
					 '	 oln.shipped_quantity,'||
					 '       oln.shipped_quantity * oln.unit_selling_price shipped_value, '||
					 '       oln.order_quantity_uom,'||
					 '	 oln.accepted_quantity,'||
					 '       oln.accepted_quantity * oln.unit_selling_price acceptance_value '||
					 'FROM   oe_order_lines_all oln, '||
					 '       mtl_system_items_b_kfv msi '||
					 'WHERE  msi.inventory_item_id = oln.inventory_item_id '||
					 'AND    msi.organization_id = oln.ship_from_org_id ';

  TYPE c_cust_from_param_type IS REF CURSOR;
  c_cust_from_param c_cust_from_param_type;

  TYPE c_ord_from_param_type IS REF CURSOR;
  c_ord_from_param c_ord_from_param_type;

  TYPE c_line_from_param_type IS REF CURSOR;
  c_line_from_param c_line_from_param_type;


  l_cust_query              VARCHAR2(15000);
  l_ord_query              VARCHAR2(15000);
  l_lines_query              VARCHAR2(15000);

  l_party_name              VARCHAR2(360);
  l_account_number          VARCHAR2(30);
  l_order_number            NUMBER;
  l_ordered_date            DATE;
--myerrams, added the following Conversion related variables
  l_conversion_type_code    VARCHAR2(30);
  l_ord_conversion_rate	    NUMBER;
  l_conversion_rate	    NUMBER;
--myerrams, end
  l_order_type              VARCHAR2(30);
  l_header_id               NUMBER;
  l_cust_acc_id             NUMBER;
  l_line_number             NUMBER;
  l_ordered_item            VARCHAR2(2000);
  l_ordered_item_desc       VARCHAR2(1000);
  l_internal_item           VARCHAR2(2000);
  l_internal_item_desc      VARCHAR2(1000);
  l_fulfilled_quantity      NUMBER;
  l_shipping_quantity_uom   VARCHAR2(3);
  l_shipped_quantity        NUMBER := 0;
  l_shipped_quantity_value  NUMBER := 0;

  l_ordered_quantity        NUMBER := 0;	--myerrams, Added for finding the pending quantity
  l_ordered_quantity_value  NUMBER := 0;	--myerrams, Added for finding the pending quantity value

  l_accepted_quantity       NUMBER := 0;
  l_accepted_quantity_value NUMBER := 0;
  l_acceptance_value        NUMBER := 0;
  l_pending_quantity        NUMBER := 0;
  l_pending_quantity_value  NUMBER := 0;
  l_rejected_quantity       NUMBER := 0;
  l_rejected_quantity_value NUMBER := 0;
  l_fulfilled_value         NUMBER := 0;
  l_flow_status_code        VARCHAR2(30);
  l_total_shipped_value     NUMBER := 0;
  l_total_line_value        NUMBER := 0;
  l_total_line_qty          NUMBER := 0;
  l_item_value              VARCHAR2(5000);
  l_cust_po_number          VARCHAR2(50);
  l_sales_rep_name          VARCHAR2(360);

  l_line_accepted_total     NUMBER := 0;
  l_line_rejected_total     NUMBER := 0;
  l_line_pending_total      NUMBER := 0;
  l_cust_accepted_total     NUMBER := 0;
  l_cust_rejected_total     NUMBER := 0;
  l_cust_pending_total      NUMBER := 0;
  l_rep_accepted_total      NUMBER := 0;
  l_rep_rejected_total      NUMBER := 0;
  l_rep_pending_total       NUMBER := 0;
  l_first_time_flag	    BOOLEAN; --myerrams, Bug: 5231338
  l_orders_flag             BOOLEAN; --myerrams, Bug: 5231338
  l_line_counter	    NUMBER;  --myerrams, line counter;
  l_currency		    VARCHAR2(30); --myerrams, added for populating the line currency

BEGIN
  IF l_debug_level  > 0
  THEN
    oe_debug_pub.add(  'OEXCARR: Inside put_remaining_tags') ;
  END IF;

  -- Get the query string by calling function create_where_clause, This
  -- function creates the where clause for the query based on the user input parameters.
    l_cust_query := l_cust_cursor_query;
    l_cust_query := create_where_clause (l_cust_query);
    IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OEXCARR: Query to be executed: '||l_cust_query ) ;
    END IF;
    OPEN c_cust_from_param FOR l_cust_query;
    LOOP
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCARR: Inside the LOOP for Customer');
      END IF;

      FETCH c_cust_from_param
      INTO  l_party_name,
            l_account_number,
	    l_cust_acc_id;
      EXIT WHEN c_cust_from_param%NOTFOUND;
      g_counter := g_counter + 1;		--myerrams, increase the counter by 1
-- Call the procedure put_ghead_tags to populate the output XML with the header tags
--myerrams, Bug: 5231338.
     l_first_time_flag	    := TRUE;
     l_orders_flag          := FALSE;

     l_ord_query := l_ord_cursor_query;
--myerrams, constraining to the passed Operating unit
 IF g_org_id IS NOT NULL
 THEN
    l_ord_query := l_ord_query || ' AND oha.org_id =' || g_org_id;
 END IF;
--myerrams, end

      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCARR: Value of l_cust_acc_id : '||l_cust_acc_id) ;
      END IF;
      l_ord_query := create_ord_where_clause(l_ord_query,l_cust_acc_id);

--myerrams, start
IF p_func_currency <> 'Y' THEN
	l_ord_query := create_curr_where_clause(l_ord_query,g_ord_currency);
END IF;
--myerrams, end

--myerrams, to Order the records by Sales Order Number
l_ord_query := l_ord_query || ' ORDER BY oha.order_number ';
--myerrams, end


      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCARR: Query to be executed for Order: '||l_ord_query ) ;
      END IF;

      OPEN c_ord_from_param FOR l_ord_query;
      LOOP
        FETCH c_ord_from_param
	INTO  l_order_number,
	      l_header_id,
	      l_ordered_date,
	      l_cust_po_number,
	      l_order_type,
	      l_sales_rep_name,
	      g_currency,
	      l_conversion_type_code,
	      l_ord_conversion_rate;
        EXIT WHEN c_ord_from_param%NOTFOUND;
--myerrams, Bug: 5231338. This flag is used to decide whether to place customer total tags or not.
	l_orders_flag := TRUE;

	--myerrams, added for populating the order and line currency
	IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
		l_currency := g_func_currency;
	ELSE
		l_currency := g_currency;
	END IF;

     IF (p_sorted_by = 'CUSTOMER')
     THEN
/* myerrams, Bug: 5231338. Place the header tags if there are any orders for this customer.
l_first_time_flag is used to place header tags only once.*/
IF l_first_time_flag THEN
       put_ghead_tags(l_party_name
                     ,l_account_number
		     );
l_first_time_flag := FALSE;
END IF;
/* myerrams,Bug: 5231338; end */
       put_ord_tags(l_order_number
	           ,l_ordered_date
	           ,l_cust_po_number
		   ,l_order_type
		   ,l_sales_rep_name
		   ,NULL
		   ,NULL
		   ,l_currency
		   );
     ELSE
       put_ord_tags(l_order_number
	           ,l_ordered_date
	           ,l_cust_po_number
		   ,l_order_type
		   ,l_sales_rep_name
		   ,l_party_name
		   ,l_account_number
		   ,l_currency
		   );
     END IF;

--myerrams, currency conversion
IF l_debug_level  > 0 THEN
oe_debug_pub.add(  'OEXCARR: Value of l_ord_conversion_rate:'||l_ord_conversion_rate);
END IF;
IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
IF l_debug_level  > 0 THEN
oe_debug_pub.add(  'OEXCARR: before calculating the conversion_rate');
oe_debug_pub.add(  'OEXCARR: Value of g_currency:'||g_currency);
oe_debug_pub.add(  'OEXCARR: Value of g_func_currency:'||g_func_currency);
oe_debug_pub.add(  'OEXCARR: Value of l_ordered_date:'||l_ordered_date);
oe_debug_pub.add(  'OEXCARR: Value of l_conversion_type_code:'||l_conversion_type_code);
END IF;

if(l_ord_conversion_rate is null) then
l_conversion_rate := gl_conversion_rate_func
			(g_currency,
			g_func_currency,
			l_ordered_date,
			l_conversion_type_code
			);
else
l_conversion_rate := l_ord_conversion_rate;
end if;

IF l_debug_level  > 0 THEN
oe_debug_pub.add(  'OEXCARR: Value of l_conversion_rate:'||l_conversion_rate);
END IF;
END IF;
--myerrams, currency conversion, end
	l_lines_query := l_line_cursor_query;

	l_lines_query := create_lines_where_clause(l_lines_query,l_header_id);
--myerrams, added the order by clause
	l_lines_query := l_lines_query || ' Order by oln.line_number, oln.line_id ';
--myerrams, end

	IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXCARR: Query to be executed for Lines: '||l_lines_query ) ;
        END IF;

	l_line_counter := 0; --myerrams, Initialize the Line counter.

        OPEN c_line_from_param FOR l_lines_query;
        LOOP
          FETCH c_line_from_param
          INTO  l_line_number,
                l_ordered_item,
  	        l_ordered_item_desc,
	        l_internal_item,
	        l_internal_item_desc,
		l_ordered_quantity,
		l_ordered_quantity_value,
                l_fulfilled_quantity,
	        l_fulfilled_value,
	        l_shipped_quantity,
	        l_shipped_quantity_value,
                l_shipping_quantity_uom,
	        l_accepted_quantity,
	        l_acceptance_value;
           EXIT WHEN c_line_from_param%NOTFOUND;
	   l_line_counter := l_line_counter + 1; --myerrams, Increase the counter by 1.

   	   IF g_item_display = 'D'
	   THEN
	    l_item_value := l_internal_item_desc;
	   ELSIF g_item_display = 'F'
	   THEN
	    l_item_value := l_internal_item;
	   ELSIF g_item_display = 'I'
	   THEN
	    l_item_value := l_internal_item ||' - '||l_internal_item_desc;
           ELSIF g_item_display = 'P'
	   THEN
	    l_item_value := l_ordered_item_desc;
           ELSIF g_item_display = 'O'
	   THEN
	    l_item_value := l_ordered_item;
           ELSIF g_item_display = 'C'
	   THEN
	    l_item_value := l_ordered_item ||' - '||l_ordered_item_desc;
	   END IF;
           IF l_accepted_quantity IS NOT NULL
	   THEN
             l_pending_quantity := 0;
             l_pending_quantity_value := 0;
  	     IF l_accepted_quantity = 0
	     THEN
	       l_rejected_quantity := l_fulfilled_quantity;
	       l_accepted_quantity := 0;
               l_accepted_quantity_value := 0;
               l_rejected_quantity_value := l_fulfilled_value;
	     ELSE
	       l_rejected_quantity := 0;
	       l_accepted_quantity := l_accepted_quantity;
               l_accepted_quantity_value := l_acceptance_value;
               l_rejected_quantity_value := 0;
	     END IF;
	   ELSE
             l_accepted_quantity := 0;
             l_accepted_quantity_value := 0;
             l_rejected_quantity := 0;
             l_rejected_quantity_value := 0;
--myerrams, Pending quantity has to be taken from either Fulfilled Quantity or Shipped Quantity or Ordered Quantity in the same order
	     l_pending_quantity := NVL(l_fulfilled_quantity,NVL(l_shipped_quantity, NVL (l_ordered_quantity, 0)));
	     l_pending_quantity_value := NVL(l_fulfilled_value,NVL(l_shipped_quantity_value, NVL (l_ordered_quantity_value, 0)));

           END IF;
           l_line_accepted_total := l_line_accepted_total + nvl(l_accepted_quantity_value,0);
     	   l_line_rejected_total := l_line_rejected_total + nvl(l_rejected_quantity_value,0);
	   l_line_pending_total  := l_line_pending_total + nvl(l_pending_quantity_value,0);
--myerrams, currency conversion
	IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
	--do a null and zero check
		l_accepted_quantity_value := l_accepted_quantity_value * l_conversion_rate;
		l_rejected_quantity_value := l_rejected_quantity_value * l_conversion_rate;
		l_pending_quantity_value  := l_pending_quantity_value  * l_conversion_rate;
	END IF;
--myerrams, currency conversion, end
           put_line_tags(l_line_number
		        ,l_item_value
		        ,l_fulfilled_quantity
		        ,l_shipping_quantity_uom
		        ,l_accepted_quantity
		        ,l_rejected_quantity
		        ,l_pending_quantity
		        ,l_accepted_quantity_value
		        ,l_rejected_quantity_value
		        ,l_pending_quantity_value
			,l_currency
		        );
        END LOOP; -- LOOP END for c_line_from_param
        close c_line_from_param;
	l_lines_query := NULL;
        IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'OEXCARR: Value of l_line_accepted_total 2: '||l_line_accepted_total ) ;
         oe_debug_pub.add(  'OEXCARR: Value of l_line_rejected_total 2: '||l_line_rejected_total ) ;
         oe_debug_pub.add(  'OEXCARR: Value of l_line_pending_total 2: '||l_line_pending_total ) ;
        END IF;
	IF l_line_counter > 0 THEN	--myerrams, put the order total tags only when there are lines present.
--myerrams, currency conversion
	IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
		l_line_accepted_total := l_line_accepted_total * l_conversion_rate;
		l_line_rejected_total := l_line_rejected_total * l_conversion_rate;
		l_line_pending_total  := l_line_pending_total  * l_conversion_rate;
	END IF;
--myerrams, currency conversion, end
        put_order_total_tags (l_line_accepted_total
 	                     ,l_line_rejected_total
	    		     ,l_line_pending_total);
	l_line_counter := 0;
	END IF;
        l_cust_accepted_total := l_cust_accepted_total + nvl(l_line_accepted_total,0);
	l_cust_rejected_total := l_cust_rejected_total + nvl(l_line_rejected_total,0);
	l_cust_pending_total  := l_cust_pending_total + nvl(l_line_pending_total,0);

        l_line_accepted_total := 0;
        l_line_rejected_total := 0;
        l_line_pending_total  := 0;
      END LOOP;-- LOOP END for c_ord_from_param
      close c_ord_from_param;
      l_ord_query := NULL;

      IF (p_sorted_by = 'CUSTOMER')
      THEN
--myerrams, currency conversion
	IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
		l_cust_accepted_total := l_cust_accepted_total * l_conversion_rate;
		l_cust_rejected_total := l_cust_rejected_total * l_conversion_rate;
		l_cust_pending_total  := l_cust_pending_total  * l_conversion_rate;
	END IF;
--myerrams, currency conversion, end
/*myerrams, Bug: 5231338. Place the customer total tags if there are any orders for this customer.
l_orders_flag is used to decide if there are any orders for this customer */
IF l_orders_flag THEN
        put_cust_total_tags(l_cust_accepted_total
                         ,l_cust_rejected_total
		         ,l_cust_pending_total);
END IF;
/*myerrams, Bug: 5231338*/
      END IF;
      l_rep_accepted_total := l_rep_accepted_total + nvl(l_cust_accepted_total,0);
      l_rep_rejected_total := l_rep_rejected_total + nvl(l_cust_rejected_total,0);
      l_rep_pending_total  := l_rep_pending_total + nvl(l_cust_pending_total,0);
      l_cust_accepted_total := 0;
      l_cust_rejected_total := 0;
      l_cust_pending_total  := 0;
    END LOOP;-- LOOP END for c_cust_from_param
    close c_cust_from_param;
    l_cust_query := NULL;
--myerrams, currency conversion
	IF(p_func_currency = 'Y' and g_currency <> g_func_currency) THEN
		l_rep_accepted_total := l_rep_accepted_total * l_conversion_rate;
		l_rep_rejected_total := l_rep_rejected_total * l_conversion_rate;
		l_rep_pending_total  := l_rep_pending_total  * l_conversion_rate;
	END IF;
--myerrams, currency conversion, end
    put_rep_total_tags(l_rep_accepted_total
                      ,l_rep_rejected_total
		      ,l_rep_pending_total);

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(FND_FILE.LOG, 'NO_DATA_FOUND exception in the program '||sqlerrm);
      p_ERRBUF := 'NO_DATA_FOUND exception in the program '||sqlerrm;
      p_RETCODE := 2;
   WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'OTHERS exception in the program '||sqlerrm);
      p_ERRBUF := 'OTHERS exception in the program '||sqlerrm;
      p_RETCODE := 2;
END;
--=============================================================================

--=============================================================================
-- Start of comments
-- PROCEDURE      : Generate_ReportData
-- PRE-CONDITIONS : None.
-- COMMENTS       : Generates XML data for Customer Acceptance Report.
-- PARAMETERS     :
--   IN           :
--		   p_sorted_by           IN  VARCHAR2  Required
--		   p_from_customer_name  IN  VARCHAR2  Optional
--				             Default = NULL
--		   p_to_customer_name    IN  VARCHAR2  Optional
--		                             Default = NULL
--		   p_from_customer_no    IN  VARCHAR2  Optional
--				             Default = NULL
--                 p_to_customer_no      IN  VARCHAR2  Optional
--				             Default = NULL
--		   p_from_order_date     IN  DATE      Optional
--				             Default = NULL
--		   p_to_order_date       IN  DATE      Optional
--				             Default = NULL
--                 p_from_fulfill_date   IN  DATE      Optional
--				             Default = NULL
--                 p_to_fulfill_date     IN  DATE      Optional
--				             Default = NULL
--		   p_from_accepted_date  IN  DATE      Optional
--				             Default = NULL
--		   p_to_accepted_date    IN  DATE      Optional
--				             Default = NULL
--                 p_acceptance_status   IN  VARCHAR2  Optional
--				             Default = NULL
--		   p_item_display	 IN  VARCHAR2  Required
--		   p_func_currency	 IN  VARCHAR2  Required
--  OUT	         :
--		   errbuf                  OUT NOCOPY VARCHAR2
--                 retcode                 OUT NOCOPY VARCHAR2
--
-- EXCEPTIONS    : None.
-- NOTES         : This Procedure is called from the concurrent program
--                 which generates the XML data for the customer acceptance
--                 rejection report.
-- End of comments
--=============================================================================

PROCEDURE Generate_ReportData
( ERRBUF                  OUT NOCOPY  VARCHAR2,
  RETCODE                 OUT NOCOPY  VARCHAR2,
  p_sorted_by             IN VARCHAR2,
  p_customer_name_low     IN VARCHAR2,
  p_customer_name_high    IN VARCHAR2,
  p_customer_no_low       IN VARCHAR2,
  p_customer_no_high      IN VARCHAR2,
  p_order_type_low        IN VARCHAR2,
  p_order_type_high       IN VARCHAR2,
  p_order_number_low      IN NUMBER,
  p_order_number_high     IN NUMBER,
--myerrams, Bug: 5214119. Modified the types of all date vars to VARCHAR2 as conc prog passes VARCHAR2.
  p_order_date_low        IN VARCHAR2,
  p_order_date_high       IN VARCHAR2,
  p_fulfill_date_low      IN VARCHAR2,
  p_fulfill_date_high     IN VARCHAR2,
  p_accepted_date_low     IN VARCHAR2,
  p_accepted_date_high    IN VARCHAR2,
--myerrams, Bug: 5214119. end.
  p_acceptance_status     IN VARCHAR2,
  p_item_display          IN VARCHAR2,
  p_func_currency         IN VARCHAR2
)
IS
--myerrams, new variables
l_cust_query_to_append    VARCHAR2(15000);
l_curr_query		    VARCHAR2(15000);

--myerrams, Modified the following query to add oe_order_lines_all
l_curr_cursor_query  VARCHAR2(15000)  := 'SELECT distinct oha.TRANSACTIONAL_CURR_CODE   '||
					 'FROM   oe_order_headers_all oha,		'||
					 '	 oe_order_lines_all  oln,		'||
					 '	 oe_transaction_types_all ota,		'||
					 '	 ra_salesreps_all rsa			'||
					 'WHERE  oha.order_type_id = ota.transaction_type_id	'||
					 'AND    oha.header_id = oln.header_id '||
					 'AND    oha.salesrep_id = rsa.salesrep_id ';

l_cust_soldto_cursor_query VARCHAR2(15000) := 'SELECT DISTINCT hca.cust_account_id '||
					 'FROM   hz_parties hp, '||
					 '       hz_cust_accounts_all hca, '||
					 '       oe_order_headers_all oha, '||
					 '       oe_order_lines_all   oln, '||
					 '       oe_transaction_types_all ota '||
					 'WHERE  hp.party_id = hca.party_id '||
					 'AND    hca.cust_account_id = oha.sold_to_org_id '||
					 'AND    oha.header_id = oln.header_id '||
					 'AND    oha.order_type_id = ota.transaction_type_id ';
  TYPE c_curr_from_param_type IS REF CURSOR;
  c_curr_from_param c_curr_from_param_type;
--myerrams, new variables, end

BEGIN

  IF l_debug_level  > 0
  THEN
    oe_debug_pub.add(  'OEXCARR: Starting Generate_ReportData procedure') ;
  END IF;

--myerrams, Bug: 5214119. Converting the VARCHAR2 variables to DATE variables.
g_order_date_low := fnd_date.canonical_to_date(p_order_date_low);
g_order_date_high := fnd_date.canonical_to_date(p_order_date_high);
g_fulfill_date_low := fnd_date.canonical_to_date(p_fulfill_date_low);
g_fulfill_date_high := fnd_date.canonical_to_date(p_fulfill_date_high);
g_accepted_date_low := fnd_date.canonical_to_date(p_accepted_date_low);
g_accepted_date_high := fnd_date.canonical_to_date(p_accepted_date_high);
--myerrams, Bug: 5214119. end.
  g_org_id := MO_GLOBAL.get_current_org_id;
  BEGIN
    SELECT name
    INTO   g_operating_unit
    FROM   hr_organization_units
    WHERE  organization_id = g_org_id;
  EXCEPTION
    WHEN OTHERS
    THEN
      IF l_debug_level  > 0
      THEN
        oe_debug_pub.add(  'OEXCARR: Error in MO Query, Value of g_org_id '||g_org_id) ;
      END IF;
  END;

  g_sorted_by          := p_sorted_by;
  g_customer_name_low  := p_customer_name_low;
  g_customer_name_high := p_customer_name_high;
  g_customer_no_low    := p_customer_no_low;
  g_customer_no_high   := p_customer_no_high;
  g_order_type_low     := p_order_type_low;
  g_order_type_high    := p_order_type_high;
  g_order_no_low       := p_order_number_low;
  g_order_no_high      := p_order_number_high;
  g_acceptance_status  := p_acceptance_status;	--myerrams, Bug:4749985
  g_item_display       := p_item_display;
  IF l_debug_level  > 0
  THEN
    oe_debug_pub.add('OEXCARR: Before call to put_parameter_tags procedure, p_func_currency:'||p_func_currency);
  END IF;
--myerrams, Bug: 5484771
  IF p_func_currency IS NOT NULL
  THEN
	SELECT meaning into g_func_currency_desc
	FROM FND_LOOKUPS
	WHERE lookup_type = 'YES_NO'
	AND lookup_code = p_func_currency;
  END IF;

--myerrams
--Call the procedure to place the parameter values in the XML output.
  put_parameter_tags;
  IF l_debug_level  > 0
  THEN
    oe_debug_pub.add(  'OEXCARR: After call to put_parameter_tags procedure') ;
  END IF;

  IF p_func_currency = 'Y'
  THEN
   SELECT curr.currency_code
   INTO   g_func_currency
   FROM   fnd_currencies curr,
          gl_sets_of_books sob
   WHERE  curr.enabled_flag ='Y'
   AND    sob.set_of_books_id = (select FND_PROFILE.VALUE('GL_SET_OF_BKS_ID')
                                 from dual)
   AND    curr.currency_code = sob.currency_code;

--myerrams, start
  put_gcurr_tags(g_func_currency,g_sorted_by);
  put_remaining_tags(p_sorted_by,P_FUNC_CURRENCY,ERRBUF,RETCODE);
--myerrams, end

--myerrams, start
  ELSE
    --get the cust query to append to curr query
    l_cust_query_to_append := l_cust_soldto_cursor_query;
    l_cust_query_to_append := create_where_clause (l_cust_query_to_append);

    --get the curr query
    l_curr_query := l_curr_cursor_query;
--myerrams, constraining to the passed Operating unit
 IF g_org_id IS NOT NULL
 THEN
    l_curr_query := l_curr_query || ' AND oha.org_id =' || g_org_id;
 END IF;
--myerrams, end
--myerrams, Bug: 5218214. There is a white space char missing before AND. Added that white space char.
    l_curr_query := l_curr_query  || ' AND oha.sold_to_org_id in (' || l_cust_query_to_append || ') ';
    l_curr_query := create_ord_where_clause(l_curr_query,NULL);

    IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'OEXCARR: Query to be executed: '||l_curr_query ) ;
    END IF;
    OPEN c_curr_from_param FOR l_curr_query;
    LOOP
      IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'OEXCARR: Inside the LOOP for Currency');
      END IF;

      FETCH c_curr_from_param
      INTO
      g_ord_currency;
      EXIT WHEN c_curr_from_param%NOTFOUND;
      IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'OEXCARR: Value of g_ord_currency:'||g_ord_currency);
      END IF;
      put_gcurr_tags(g_ord_currency,g_sorted_by);
      put_remaining_tags(p_sorted_by,P_FUNC_CURRENCY,ERRBUF,RETCODE);
    END LOOP; --c_curr_from_param loop
--myerrams, end
  END IF;

--myerrams, put the value for no_data_found tag.
  IF g_counter = 0 THEN
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<NO_DATA_FOUND>'|| 'Y' || '</NO_DATA_FOUND>');
  ELSE
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '<NO_DATA_FOUND>'|| 'N' || '</NO_DATA_FOUND>');
  END IF;

--myerrams, start
  FND_FILE.PUT_LINE(FND_FILE.OUTPUT,  '</OEXCARR>');
--myerrams, end

  EXCEPTION
   WHEN NO_DATA_FOUND THEN
      fnd_file.put_line(FND_FILE.LOG, 'NO_DATA_FOUND exception in the program '||sqlerrm);
      ERRBUF := 'NO_DATA_FOUND exception in the program '||sqlerrm;
      RETCODE := 2;
   WHEN OTHERS THEN
      fnd_file.put_line(FND_FILE.LOG, 'OTHERS exception in the program '||sqlerrm);
      ERRBUF := 'OTHERS exception in the program '||sqlerrm;
      RETCODE := 2;

END Generate_ReportData;

END OE_CustAcceptRep_PVT;

/
