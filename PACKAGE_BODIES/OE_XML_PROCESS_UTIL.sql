--------------------------------------------------------
--  DDL for Package Body OE_XML_PROCESS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_XML_PROCESS_UTIL" AS
/* $Header: OEXUPOXB.pls 120.3 2006/02/15 22:42:36 ppnair noship $ */

Procedure Concat_Strings(
          String1       IN      VARCHAR2,
          String2       IN      VARCHAR2,
OUT_String OUT NOCOPY VARCHAR2

          )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

     OUT_String := String1 || String2;

End Concat_Strings;

Procedure Get_Ship_To_Org_Id(
          p_address_id       IN      NUMBER,
x_ship_to_org_id OUT NOCOPY NUMBER

          )
IS
l_site_use_id   Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_SHIP_TO_ORG_ID' ) ;
  END IF;
    SELECT site_use_id
    INTO   l_site_use_id
    FROM   hz_cust_site_uses_all a, hz_cust_acct_sites_all b
    WHERE  a.cust_acct_site_id = b.cust_acct_site_id
    AND    a.cust_acct_site_id = p_address_id
    AND    a.site_use_code     = 'SHIP_TO'
    AND    a.status = 'A'
    AND    b.status ='A'; --bug 2752321

    x_ship_to_org_id := l_site_use_id;
Exception
        When Others Then
           x_ship_to_org_id := NULL;
           fnd_message.set_name ('ONT', 'OE_OI_ORG_NOT_FOUND');
	   fnd_message.set_token ('SITE_USAGE', 'SHIP-TO');
	   fnd_message.set_token ('ADDRESS_ID', p_address_id);
	   oe_msg_pub.add;
End Get_Ship_To_Org_Id;


Procedure Get_Bill_To_Org_Id(
          p_address_id       IN      NUMBER,
x_bill_to_org_id OUT NOCOPY NUMBER

          )
IS
l_site_use_id   Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_BILL_TO_ORG_ID' ) ;
  END IF;

    SELECT site_use_id
    INTO   l_site_use_id
    FROM   hz_cust_site_uses_all a, hz_cust_acct_sites_all b
    WHERE  a.cust_acct_site_id = b.cust_acct_site_id
    AND    a.cust_acct_site_id = p_address_id
    AND    a.site_use_code     = 'BILL_TO'
    AND    a.status = 'A'
    AND    b.status ='A';--bug 2752321

   x_bill_to_org_id := l_site_use_id;
Exception
        When Others Then
           x_bill_to_org_id := NULL;
	   fnd_message.set_name ('ONT', 'OE_OI_ORG_NOT_FOUND');
	   fnd_message.set_token ('SITE_USAGE', 'BILL-TO');
	   fnd_message.set_token ('ADDRESS_ID', p_address_id);
	   oe_msg_pub.add;
End Get_Bill_To_Org_Id;

Procedure Get_Sold_To_Org_Id(
          p_address_id       IN      NUMBER,
x_sold_to_org_id OUT NOCOPY NUMBER

          )
IS
l_sold_to_org_id   Number;
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_SOLD_TO_ORG_ID' ) ;
  END IF;

    SELECT cust_account_id
    INTO   l_sold_to_org_id
    FROM   hz_cust_acct_sites_all
    WHERE  cust_acct_site_id  = p_address_id
    AND    status             = 'A';

   x_sold_to_org_id := l_sold_to_org_id;
Exception
        When Others Then
           x_sold_to_org_id := NULL;
	   fnd_message.set_name ('ONT', 'OE_OI_ORG_NOT_FOUND');
	   fnd_message.set_token ('SITE_USAGE', 'SOLD-TO');
	   fnd_message.set_token ('ADDRESS_ID', p_address_id);
	   oe_msg_pub.add;
End Get_Sold_To_Org_Id;

Procedure Get_Sold_To_Edi_Loc(
          p_sold_to_org_id      IN     Number,
x_edi_location_code OUT NOCOPY Varchar2,

x_sold_to_name OUT NOCOPY Varchar2

          )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_SOLD_TO_EDI_LOC' ) ;
  END IF;

  Select /* MOAC_SQL_CHANGE */ a.ece_tp_location_code, c.party_name
  Into   x_edi_location_code, x_sold_to_name
  From   hz_cust_acct_sites a, hz_cust_site_uses_all b,
         hz_parties c, hz_cust_accounts d
  Where  a.cust_acct_site_id = b.cust_acct_site_id
  And    a.cust_account_id   = p_sold_to_org_id
  And    b.site_use_code     = 'SOLD_TO'
  And    b.primary_flag      = 'Y'
  And    b.status            = 'A'
  AND    a.status            = 'A' --bug 2752321
  And    a.cust_account_id   = d.cust_account_id
  And    d.party_id          = c.party_id;

  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'EXITING OE_XML_PROCESS_UTIL.GET_SOLD_TO_EDI_LOC' ) ;
  END IF;
Exception
  When Others Then
    x_edi_location_code := Null;
    fnd_message.set_name ('ONT', 'OE_OI_EDI_LOC_NOT_FOUND');
    fnd_message.set_token ('EDI_LOCATION', 'SOLD-TO');
    fnd_message.set_token ('SITE_USAGE', p_sold_to_org_id);
    oe_msg_pub.add;

End Get_Sold_To_Edi_Loc;

-- API which will return all the address data based on the site_use_id
-- Will be called by both EDI and  XML

Procedure Get_Address_Details
 (p_site_use_id        In         Number,
  p_site_use_code      In         Varchar2,
  x_location           Out NOCOPY Varchar2,
  x_address1           Out NOCOPY Varchar2,
  x_address2           Out NOCOPY Varchar2,
  x_address3           Out NOCOPY Varchar2,
  x_address4           Out NOCOPY Varchar2,
  x_city               Out NOCOPY Varchar2,
  x_state              Out NOCOPY Varchar2,
  x_country            Out NOCOPY Varchar2,
  x_postal_code        Out NOCOPY Varchar2,
  x_edi_location_code  Out NOCOPY Varchar2,
  x_customer_name      Out NOCOPY Varchar2,
  x_return_status      Out NOCOPY Varchar2
 )
Is
  l_debug_level        Constant Number := Oe_Debug_Pub.g_debug_level;
Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Entering get_address_details');
    Oe_Debug_Pub.Add('Site Use Id = '||p_site_use_id);
    Oe_Debug_Pub.Add('Site Use Code = '||p_site_use_code);
  End If;

  If p_site_use_code = 'SHIP_FROM' Then

    Select hl.Location_Code,
           hl.Address_Line_1,
           hl.Address_Line_2,
           hl.Address_Line_3,
           hl.Town_Or_City,
           hl.Country,
           hl.postal_code,
           hl.ece_tp_location_code,
           hu.name
    Into   x_location,
           x_address1,
           x_address2,
           x_address3,
           x_city,
           x_country,
           x_postal_code,
           x_edi_location_code,
           x_customer_name
    From   hr_all_organization_units hu, hr_locations hl
    Where  hl.location_id     = hu.location_id
    And    hu.organization_id = p_site_use_id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  Else

    Select /* MOAC_SQL_CHANGE */ Site.Location,
           Loc.Address1,
           Loc.Address2,
           Loc.Address3,
           Loc.Address4,
           Loc.City,
           Loc.State,
           Loc.Country,
           Loc.Postal_Code,
           Acct_Site.ece_tp_location_code,
           Party.Party_Name
      Into x_location,
           x_address1,
           x_address2,
           x_address3,
           x_address4,
           x_city,
           x_state,
           x_country,
           x_postal_code,
           x_edi_location_code,
           x_customer_name
      From Hz_Cust_Site_Uses       Site,
           Hz_Party_Sites          Party_Site,
           Hz_Locations            Loc,
           Hz_Cust_Acct_Sites_All  Acct_Site,
           Hz_Parties              Party,
           Hz_Cust_Accounts        Cust_Accts
     Where Site.Site_Use_Code         = p_site_use_code
       And Site.Cust_Acct_Site_Id     = Acct_Site.Cust_Acct_Site_Id
       And Acct_Site.Party_Site_Id    = Party_Site.Party_Site_Id
       And Party_Site.Location_Id     = Loc.Location_Id
       And Site.Site_Use_Id           = p_site_use_id
       And Acct_Site.Cust_Account_id  = Cust_Accts.Cust_Account_id
       And Party.Party_Id             = Cust_Accts.Party_Id;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  End If;

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Exiting get_address_details');
  End If;

Exception

  When Others Then
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('Unable to derive address values for Ack');
    End If;
    x_return_status := FND_API.G_RET_STS_ERROR;

End Get_Address_Details;

Procedure Get_Contact_Details
 (p_contact_id            In         Number,
  p_cust_acct_id          In         Number,
  x_first_name            Out NOCOPY Varchar2,
  x_last_name             Out NOCOPY Varchar2,
  x_return_status         Out NOCOPY Varchar2)
Is

  l_debug_level        Constant Number := Oe_Debug_Pub.g_debug_level;

Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Entering Get_Contact_Details');
    Oe_Debug_Pub.Add('Contact Id   = '||p_contact_id);
    Oe_Debug_Pub.Add('Cust Acct Id = '||p_cust_acct_id);
  End If;

  Select a.person_first_name, a.person_last_name
    Into x_first_name, x_last_name
    From hz_parties a, hz_relationships b,
         hz_cust_account_roles c
   Where c.cust_account_role_id     = p_contact_id
     And c.party_id                 = b.party_id
     And b.subject_id               = a.party_id
     And b.subject_table_name       = 'HZ_PARTIES'
     And b.object_table_name        = 'HZ_PARTIES'
     And c.cust_account_id          = p_cust_acct_id
     And b.directional_flag         = 'F';

  x_return_status := FND_API.G_RET_STS_SUCCESS;

Exception

  When Others Then
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('Unable to derive Contact info for Ack '||sqlerrm);
    End If;
    x_return_status := FND_API.G_RET_STS_ERROR;

End Get_Contact_Details;


Procedure Get_Ship_From_Edi_Loc(
          p_ship_from_org_id   IN    Number,
x_edi_location_code OUT NOCOPY Varchar2

          )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_SHIP_FROM_EDI_LOC' ) ;
  END IF;

  Select hl.ece_tp_location_code
  Into   x_edi_location_code
  From   hr_all_organization_units hu, hr_locations hl
  Where  hl.location_id     = hu.location_id
  And    hu.organization_id = p_ship_from_org_id;

Exception
  When Others Then
    x_edi_location_code := Null;
    fnd_message.set_name ('ONT', 'OE_OI_EDI_LOC_NOT_FOUND');
    fnd_message.set_token ('EDI_LOCATION', 'SHIP-FROM');
    fnd_message.set_token ('SITE_USAGE', p_ship_from_org_id);
    oe_msg_pub.add;
End Get_Ship_From_Edi_Loc;

-- {
-- This function will get the Total of the Order or specific Line
Procedure Get_Order_Total(
          p_header_id        IN      NUMBER,
          p_line_id          IN      NUMBER,
          p_total_type       IN      VARCHAR2,
x_order_line_total OUT NOCOPY NUMBER

          )
IS
    l_order_line_total               NUMBER := 0;
    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --
BEGIN
    l_order_line_total := oe_totals_grp.get_order_total
                          ( p_header_id     =>   p_header_id,
                            p_line_id       =>   p_line_id,
                            p_total_type    =>   p_total_type);

    x_order_line_total := l_order_line_total;
Exception
    When Others Then
       x_order_line_total := 0;
       IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       	  OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_order_total');
       End if;


End Get_Order_Total;
-- } End of procedure

-- { Start Get_Processing_Msgs
PROCEDURE Get_Processing_Msgs
( p_request_id             in     varchar2,
  p_order_source_id        in     number      := 20,
  p_orig_sys_document_ref  in     varchar2    := NULL,
  p_orig_sys_line_ref      in     varchar2    := NULL,
  p_ack_code               in     varchar2    := '0',
  p_org_id                 in     number      := null,
x_error_text out nocopy varchar2,

x_result out nocopy varchar2

)
IS
    CURSOR l_msg_cursor_hdr IS
    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
           USE_NL (a b) */
           a.order_source_id
         , a.original_sys_document_ref
         , b.message_text
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
     WHERE a.request_id                = p_request_id
       AND a.order_source_id           = p_order_source_id
       AND a.original_sys_document_ref = p_orig_sys_document_ref
       AND (a.org_id is null or a.org_id = p_org_id)
       AND a.original_sys_document_line_ref is null
       AND a.transaction_id            = b.transaction_id
       AND b.language                  = oe_globals.g_lang;

    CURSOR l_msg_cursor_line IS
    SELECT /*+ INDEX (a,OE_PROCESSING_MSGS_N2)
           USE_NL (a b) */
           a.order_source_id
         , a.original_sys_document_ref
         , a.original_sys_document_line_ref
         , b.message_text
      FROM oe_processing_msgs a, oe_processing_msgs_tl b
     WHERE a.request_id                         = p_request_id
       AND a.order_source_id                    = p_order_source_id
       AND a.original_sys_document_ref          = p_orig_sys_document_ref
       AND a.original_sys_document_line_ref     = p_orig_sys_line_ref
       AND (a.org_id is null or a.org_id = p_org_id)
       AND a.transaction_id                     = b.transaction_id
       AND b.language                           = oe_globals.g_lang;

  l_message_text            Varchar2(2000);
  l_error_text              Varchar2(4000);
  l_order_source_id         Number;
  l_orig_sys_document_ref   Varchar2(50);
  l_orig_sys_line_ref       Varchar2(50);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'ENTERING GET_PROCESSING_MSGS' ) ;
   END IF;

   -- { Start If p_ack_code
/*   If p_ack_code = '0' Then
      x_error_text := 'Accepted';
      x_result := FND_API.G_RET_STS_SUCCESS;
      IF l_debug_level  > 0 THEN
          oe_debug_pub.add(  'EXITING GET_PROCESSING_MSGS WITH ACCEPTED' ) ;
      END IF;
      Return;
   End If;*/
   -- End If p_ack_code }

   -- { Start of if p_orig_sys_line_ref
   If p_orig_sys_line_ref is NULL Then
     OPEN l_msg_cursor_hdr;
     LOOP
       FETCH l_msg_cursor_hdr
        INTO l_order_source_id
           , l_orig_sys_document_ref
           , l_message_text;
        EXIT WHEN l_msg_cursor_hdr%NOTFOUND;

        l_error_text := substr(l_error_text
                        ||','||to_char(l_order_source_id)
                        ||'/'||l_orig_sys_document_ref
                        ||' '||l_message_text, 1, 4000);
     END LOOP;
     CLOSE l_msg_cursor_hdr;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_PROCESSING_MSGS WITH REJECTED HEADER' ) ;
         oe_debug_pub.add(  L_ERROR_TEXT ) ;
     END IF;
   Else
     OPEN l_msg_cursor_line;
     LOOP
       FETCH l_msg_cursor_line
        INTO l_order_source_id
           , l_orig_sys_document_ref
           , l_orig_sys_line_ref
           , l_message_text;
        EXIT WHEN l_msg_cursor_line%NOTFOUND;

        l_error_text := substr(l_error_text
                        ||','||to_char(l_order_source_id)
                        ||'/'||l_orig_sys_document_ref
                        ||'/'||l_orig_sys_line_ref
                        ||' '||l_message_text, 1, 4000);
     END LOOP;
     CLOSE l_msg_cursor_line;
     IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'EXITING GET_PROCESSING_MSGS WITH REJECTED LINE' ) ;
         oe_debug_pub.add(  L_ERROR_TEXT ) ;
     END IF;
   End If;
   -- End of if p_orig_sys_line_ref }

   If l_error_text IS NULL then
      If p_ack_code = '0' Then
         l_error_text := 'Accepted';
      Elsif p_ack_code = '2' Then
      -- If Failed without logging any error, at least Rejected code should go.
         l_error_text := 'Rejected';
      Elsif p_ack_code = '3' Then
         l_error_text := 'Pending';
      End If;
   End If;
   x_error_text := l_error_text;
   x_result := FND_API.G_RET_STS_SUCCESS;
   IF l_debug_level  > 0 THEN
       oe_debug_pub.add(  'EXITING GET_PROCESSING_MSGS' ) ;
   END IF;
Exception
   When Others Then
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'OTHERS ERROR IN GETTING ERROR MESSAGE. SQLERR: ' || SQLERRM ) ;
    END IF;
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    IF l_debug_level  > 0 THEN
        oe_debug_pub.add(  'EXITING GET_PROCESSING_MSGS' ) ;
    END IF;
    IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_processing_msgs');
    End if;
END Get_Processing_Msgs;
-- End Get_Processing_Msgs}

Procedure Get_Sales_Person(
          p_salesrep_id        IN    Number,
x_salesrep OUT NOCOPY Varchar2

          )
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_SALES_PERSON' ) ;
  END IF;
  x_salesrep := Oe_Id_To_Value.Salesrep(p_salesrep_id => p_salesrep_id);

Exception
  When Others Then
    x_salesrep := Null;
    IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_sales_person');
    End if;

End Get_Sales_Person;

Procedure Get_Line_Ordered_Quantity
(
	 p_orig_sys_document_ref	IN	VARCHAR2,
	 p_orig_sys_line_ref		IN	VARCHAR2,
	 p_orig_sys_shipment_ref	IN	VARCHAR2,
	 p_order_source_id		IN 	NUMBER,
         p_sold_to_org_id               IN      NUMBER,
x_ordered_quantity OUT NOCOPY NUMBER

	 )
IS

l_customer_key_profile VARCHAR2(1)  :=  'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_LINE_ORDERED_QUANTITY' ) ;
  END IF;

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

 select ordered_quantity
  into x_ordered_quantity
  from oe_order_lines_all
  where orig_sys_document_ref = p_orig_sys_document_ref
  and orig_sys_line_ref = p_orig_sys_line_ref
  and orig_sys_shipment_ref = p_orig_sys_shipment_ref
  and order_source_id = p_order_source_id
  and decode(l_customer_key_profile, 'Y',
      nvl(sold_to_org_id,                -999), 1)
    = decode(l_customer_key_profile, 'Y',
      nvl(p_sold_to_org_id,                -999), 1);



Exception
  When Others Then
    x_ordered_quantity := NULL;
   IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_line_ordered_quantity');
    End if;


End Get_Line_Ordered_Quantity;

Procedure Get_Line_Ordered_Quantity_UOM
(
	 p_orig_sys_document_ref	IN	VARCHAR2,
	 p_orig_sys_line_ref		IN	VARCHAR2,
	 p_orig_sys_shipment_ref	IN	VARCHAR2,
	 p_order_source_id		IN 	NUMBER,
         p_sold_to_org_id               IN      NUMBER,
x_ordered_quantity_uom OUT NOCOPY VARCHAR2

	 )
IS

l_customer_key_profile VARCHAR2(1)  :=  'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.GET_LINE_ORDERED_QUANTITY_UOM' ) ;
  END IF;


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;


 select order_quantity_uom
  into x_ordered_quantity_uom
  from oe_order_lines_all
  where orig_sys_document_ref = p_orig_sys_document_ref
  and orig_sys_line_ref = p_orig_sys_line_ref
  and orig_sys_shipment_ref = p_orig_sys_shipment_ref
  and order_source_id = p_order_source_id
  and decode(l_customer_key_profile, 'Y',
      nvl(sold_to_org_id,                -999), 1)
    = decode(l_customer_key_profile, 'Y',
      nvl(p_sold_to_org_id,                -999), 1);



Exception
  When Others Then
    x_ordered_quantity_uom := NULL;
    IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'get_line_ordered_quantity_uom');
    End if;


End Get_Line_Ordered_Quantity_UOM;

PROCEDURE Set_Cancelled_Flag
(p_orig_sys_document_ref 	in varchar2,
 p_transaction_type             in varchar2,
 p_order_source_id              in number,
 p_sold_to_org_id               in number,
 p_change_sequence              in varchar2,
 p_org_id                       in number,
 p_xml_message_id               in number
)
is

l_customer_key_profile VARCHAR2(1)  :=  'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin
 IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'ENTERING OE_XML_PROCESS_UTIL.SET_CANCELLED_FLAG' ) ;
 END IF;



 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;



  update oe_headers_iface_all
  set cancelled_flag='Y'
  where orig_sys_document_ref = p_orig_sys_document_ref
  and order_source_id         = p_order_source_id
  and decode(l_customer_key_profile, 'Y',
      nvl(sold_to_org_id,                -999), 1)
    = decode(l_customer_key_profile, 'Y',
      nvl(p_sold_to_org_id,                -999), 1)
  and nvl(change_sequence,                  ' ')
    = nvl(p_change_sequence,                ' ')
  and xml_transaction_type_code = p_transaction_type
  and org_id                  = p_org_id
  and xml_message_id          = p_xml_message_id;

Exception
  When Others Then
null;
  IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'set_cancelled_flag');
  End if;
end set_cancelled_flag;

PROCEDURE Clear_Oe_Header_And_Line_Acks
(p_orig_sys_document_ref        in varchar2,
 p_ack_type                     in varchar2,
 p_sold_to_org_id               in number,
 p_change_sequence              in varchar2,
 p_request_id                   in number
)
is

l_customer_key_profile VARCHAR2(1)  :=  'N';

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
begin

 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;

      Delete from OE_HEADER_ACKS
      Where  orig_sys_document_ref           =  p_orig_sys_document_ref
      And    acknowledgment_type =  p_ack_type
      And decode(l_customer_key_profile, 'Y',
	  nvl(sold_to_org_id,                -999), 1)
        = decode(l_customer_key_profile, 'Y',
	  nvl(p_sold_to_org_id,                -999), 1)
      And nvl(change_sequence,                ' ')
        = nvl(p_change_sequence,                ' ')
      And    request_id          =  p_request_id;
      IF l_debug_level  > 0 THEN
         oe_debug_pub.add(  'DELETED OE_HEADER_ACKS ENTRIES FOR ORIG_SYS_DOCUMENT_REF => ' || P_ORIG_SYS_DOCUMENT_REF ||
                            ' AND ACKNOWLEDGMENT_TYPE => ' || P_ACK_TYPE || ' AND REQUEST_ID => ' || P_REQUEST_ID ||
                         ' AND SOLD_TO_ORG_ID => ' || P_SOLD_TO_ORG_ID ||
                         ' AND CHANGE_SEQUENCE => ' || P_CHANGE_SEQUENCE);
      END IF;


      Delete from OE_LINE_ACKS
      Where  orig_sys_document_ref           =  p_orig_sys_document_ref
      And    acknowledgment_type =  p_ack_type
      And    decode(l_customer_key_profile, 'Y',
	     nvl(sold_to_org_id,                -999), 1)
        =    decode(l_customer_key_profile, 'Y',
	     nvl(p_sold_to_org_id,                -999), 1)
      And    nvl(change_sequence,                ' ')
        =    nvl(p_change_sequence,                ' ')
      And    request_id          =  p_request_id;
      IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'DELETED OE_LINE_ACKS ENTRIES FOR ORIG_SYS_DOCUMENT_REF => ' || P_ORIG_SYS_DOCUMENT_REF ||
                            ' AND ACKNOWLEDGMENT_TYPE => ' || P_ACK_TYPE || ' AND REQUEST_ID => ' || P_REQUEST_ID ||
                         ' AND SOLD_TO_ORG_ID => ' || P_SOLD_TO_ORG_ID ||
                         ' AND CHANGE_SEQUENCE => ' || P_CHANGE_SEQUENCE);
END IF;


Exception
  When Others Then
null;
  IF OE_MSG_PUB.Check_Msg_level (OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
     OE_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, 'clear_oe_header_and_line_acks');
  End if;
end Clear_Oe_Header_And_Line_Acks;

Procedure Derive_Line_Operation_Code
( p_orig_sys_document_ref in varchar2,
  p_orig_sys_line_ref     in varchar2,
  p_orig_sys_shipment_ref in varchar2,
  p_order_source_id       in number,
  p_sold_to_org_id        in number,
  p_org_id                in number,
  x_operation_code        OUT NOCOPY varchar2
)
Is
--    l_dummy number := NULL;
      l_dummy varchar2 (50) := NULL;
      l_customer_key_profile VARCHAR2(1)  :=  'N';


    --
    l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
    --

Begin


 If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
  fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
  l_customer_key_profile := nvl(l_customer_key_profile, 'N');
  IF l_debug_level  > 0 THEN
      oe_debug_pub.add(  'CUSTOMER KEY PROFILE SETTING = '||l_customer_key_profile ) ;
  END IF;
 End If;


  Begin
    Select orig_sys_document_ref
    Into l_dummy
    From oe_order_lines_all
    Where orig_sys_document_ref = p_orig_sys_document_ref
    And orig_sys_line_ref = p_orig_sys_line_ref
    And orig_sys_shipment_ref = p_orig_sys_shipment_ref
    And order_source_id = p_order_source_id
    And decode(l_customer_key_profile, 'Y',
	nvl(sold_to_org_id,                -999), 1)
      = decode(l_customer_key_profile, 'Y',
        nvl(p_sold_to_org_id,                -999), 1)
    And org_id = p_org_id;

    x_operation_code := 'UPDATE';
  Exception
    When NO_DATA_FOUND Then
         x_operation_code := NULL;
    When OTHERS Then
         x_operation_code := NULL;
  End;

  IF l_debug_level  > 0 THEN
     oe_debug_pub.add(  'operation code is '|| x_operation_code ||' for orig_sys_document_ref ' ||  p_orig_sys_document_ref ||
                                                     ' orig_sys_line_ref  ' ||  p_orig_sys_line_ref ||
                                                     ' orig_sys_shipment_ref  ' ||  p_orig_sys_shipment_ref);
  END IF;

End Derive_Line_Operation_Code;

Procedure Check_Rejected_Level
 (p_header_ack_code       In         Varchar2,
  p_line_ack_code         In         Varchar2,
  p_shipment_ack_code     In         Varchar2,
  p_response_profile      In         Varchar2,
  p_ordered_quantity      In         Number,
  p_response_flag         In         Varchar2,
  p_level_code            In         Varchar2,
  x_insert_flag           Out Nocopy Varchar2)
IS
BEGIN
 x_insert_flag := 'Y';
 IF nvl(p_response_flag,'N') = 'N' OR nvl(p_response_profile,'N') = 'N' THEN
    RETURN;
 END IF;

 IF p_level_code = 'H' THEN
    IF nvl(p_header_ack_code,'0') = '2' THEN
       x_insert_flag := 'N';
    END IF;
 ELSIF p_level_code = 'L' THEN
    IF nvl(p_header_ack_code,'0') = '2' THEN
       x_insert_flag := 'N';
    ELSIF (nvl(p_line_ack_code,'0')= '2' OR nvl(p_shipment_ack_code,'0') = '2')
       --AND nvl(p_response_profile,'N') = 'Y'
       --AND nvl(p_response_flag,'N') = 'Y'
       --AND nvl(p_ordered_quantity, FND_API.G_MISS_NUM) <> 0
    THEN
       x_insert_flag := 'N';
    END IF;
 END IF;
END Check_Rejected_Level;

Procedure Process_Response_Reject
  (p_header_ack_code         In           Varchar2,
   p_line_ack_code           In           Varchar2,
   p_shipment_ack_code       In           Varchar2,
   p_ordered_quantity        In           Number,
   p_response_flag           In           Varchar2,
   p_event_raised_flag       In           Varchar2,
   p_level_code              In           Varchar2,
   p_orig_sys_document_ref   In           Varchar2,
   p_change_sequence         In           Varchar2,
   p_org_id                  In           Varchar2,
   p_sold_to_org_id          In           Number,
   p_xml_message_id          In           Number,
   p_confirmation_flag       In           Varchar2,
   p_confirmation_message    In           Varchar2,
   x_insert_level            Out Nocopy   Varchar2,
   x_raised_event            Out Nocopy   Varchar2)
IS
  l_response_profile varchar2(10) := nvl(FND_PROFILE.VALUE('ONT_3A7_RESPONSE_REQUIRED'),'N');
  l_insert_level     varchar2(1) := 'Y';
  l_raise_event      varchar2(1) := 'N';
  l_message_text     varchar2(2000);
  l_status           varchar2(10);
  l_return_status    varchar2(10);
  l_order_number     number := NULL;
  l_order_type_id    number := NULL;
  l_header_id        number := NULL;
  l_customer_key_profile VARCHAR2(1)  :=  'N';

BEGIN
  IF nvl(p_response_flag,'N') = 'N' OR l_response_profile = 'N' THEN
     x_insert_level := 'Y';
     x_raised_event := 'N';
     RETURN;
  END IF;

  Check_Rejected_Level
    (p_header_ack_code       => p_header_ack_code,
     p_line_ack_code         => p_line_ack_code,
     p_shipment_ack_code     => p_shipment_ack_code,
     p_response_profile      => l_response_profile,
     p_ordered_quantity      => p_ordered_quantity,
     p_response_flag         => p_response_flag,
     p_level_code            => p_level_code,
     x_insert_flag           => l_insert_level);

  IF p_level_code = 'H' THEN
     IF l_insert_level = 'N' THEN
        l_raise_event := 'Y';
        l_status := 'ERROR';  -- bug 3578502, CLN needs this recorded as an error
        FND_MESSAGE.SET_NAME('ONT','OE_OI_CSO_REJECTED_HEADER');
        l_message_text := FND_MESSAGE.GET;
     END IF;
  ELSIF p_level_code = 'L' THEN
     IF l_insert_level = 'N'
        AND p_event_raised_flag = 'N' THEN
          l_raise_event := 'Y';
          l_status := 'ACTIVE';
          FND_MESSAGE.SET_NAME('ONT','OE_OI_CSO_REJECTED_LINE');
          l_message_text := FND_MESSAGE.GET;
     END IF;
  END IF;

  IF l_raise_event = 'Y' THEN
     -- bug 3578502
     -- CLN needs the order number, hence we fetch it here
     IF p_level_code = 'H' THEN
        Begin
	   If OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' Then
              fnd_profile.get('ONT_INCLUDE_CUST_IN_OI_KEY', l_customer_key_profile);
              l_customer_key_profile := nvl(l_customer_key_profile, 'N');
           End If;

           Select order_number, order_type_id, header_id
           Into l_order_number, l_order_type_id, l_header_id
           From oe_order_headers_all
           Where orig_sys_document_ref = p_orig_sys_document_ref
           And order_source_id = 20
           And decode(l_customer_key_profile, 'Y',
	       nvl(sold_to_org_id,                -999), 1)
               = decode(l_customer_key_profile, 'Y',
               nvl(p_sold_to_org_id,                -999), 1)
           And org_id = p_org_id;
        Exception
           When Others Then
              l_order_number := NULL;
              l_order_type_id := NULL;
              l_header_id := NULL;
        End;

        OE_Acknowledgment_Pub.Raise_CBOD_Out_Event
                   (p_orig_sys_document_ref => p_orig_sys_document_ref,
                    p_sold_to_org_id => p_sold_to_org_id,
                    p_change_sequence => p_change_sequence,
                    p_icn => p_xml_message_id,
                    p_transaction_type => 'CHO',
                    p_org_id => p_org_id,
                    p_confirmation_flag => p_confirmation_flag,
                    p_cbod_message_text => p_confirmation_message,
                    x_return_status => l_return_status);

     END IF;
     -- end bug 3578502

     OE_Acknowledgment_Pub.Raise_Event_Xmlint
             (p_order_source_id => 20,
              p_partner_document_num => p_orig_sys_document_ref,
              p_document_num => l_order_number,
              p_order_type_id => l_order_type_id,
              p_message_text => l_message_text,
              p_change_sequence => p_change_sequence,
              p_header_id => l_header_id,
              p_itemkey => NULL, p_itemtype => NULL,
              p_transaction_type => 'ONT',
              p_transaction_subtype => 'CHO',
              p_doc_status => l_status,
              p_org_id => p_org_id,
              p_sold_to_org_id => p_sold_to_org_id,
              p_xmlg_icn     => p_xml_message_id,
              p_processing_stage => 'INBOUND_GATEWAY',
              p_response_flag  => p_response_flag,
              x_return_status  => l_return_status);



  END IF;

  x_insert_level := l_insert_level;
  IF p_event_raised_flag = 'N' THEN
     x_raised_event := l_raise_event;
  ELSE
     x_raised_event := 'Y'; -- it shd already be Y, so just make sure you don't set it to N
  END IF;

END Process_Response_Reject;

END OE_XML_PROCESS_UTIL;

/
