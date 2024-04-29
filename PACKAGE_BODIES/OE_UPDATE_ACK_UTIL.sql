--------------------------------------------------------
--  DDL for Package Body OE_UPDATE_ACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_UPDATE_ACK_UTIL" AS
/* $Header: OEXUACKB.pls 120.8 2005/12/15 03:04:32 akyadav ship $ */

PROCEDURE Update_Header_Ack_First(
   p_header_id		IN  NUMBER
  ,p_ack_code		IN  VARCHAR2
) is

  l_api_name            CONSTANT VARCHAR2(30) := 'Update_Header_Ack_First';
  l_ack_code VARCHAR2(30);
  l_order_source_id       Number;
  l_orig_sys_document_ref Varchar2(50);
  l_orig_sys_line_ref     Varchar2(50);
  l_request_id            Number;
  l_em_message_id         Number;
  l_header_id             NUMBER;
BEGIN
    l_ack_code := 'AT';
  Begin

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
      -- bug 3392678
      SELECT OE_XML_MESSAGE_SEQ_S.NEXTVAL
        INTO l_em_message_id
        FROM DUAL;
    END IF;

    Select order_source_id, orig_sys_document_ref, request_id
    into   l_order_source_id, l_orig_sys_document_ref, l_request_id
    From   oe_header_acks
    Where  header_id = p_header_id
      And  first_ack_date is null
      And  rownum    = 1;

    Delete oe_lines_interface
    Where  order_source_id       = l_order_source_id
    And    orig_sys_document_ref = l_orig_sys_document_ref
    And    request_id            = l_request_id
    And    rejected_flag         = 'Y';

    if sql%rowcount > 0 Then
       Delete oe_headers_interface
       Where  order_source_id       = l_order_source_id
       And    orig_sys_document_ref = l_orig_sys_document_ref
       And    request_id            = l_request_id;
    end if;

  Exception
    When Others then
      oe_debug_pub.add('When Others excep=> ' || sqlerrm);
  End;
 -- Lock the Header Table before Updating for bug 4505695
   SELECT header_id
   INTO l_header_id
   FROM oe_order_headers
   WHERE  header_id = p_header_id
   FOR UPDATE nowait;

    UPDATE oe_order_headers
       SET first_ack_code = l_ack_code
         , first_ack_date = sysdate
         , lock_control   = lock_control + 1
         , xml_message_id = l_em_message_id
     WHERE header_id = p_header_id;

    UPDATE oe_header_acks
       SET acknowledgment_flag = 'Y'
         , first_ack_date = sysdate
     WHERE header_id = p_header_id
       AND first_ack_date is null;

EXCEPTION
  WHEN OTHERS THEN NULL;

END Update_Header_Ack_first;


PROCEDURE Update_Header_Ack_Last(
   p_header_id		IN  NUMBER
  ,p_ack_code		IN  VARCHAR2
) is

  l_api_name            CONSTANT VARCHAR2(30) := 'Update_Header_Ack_Last';
  l_ack_code VARCHAR2(30);
  l_em_message_id         Number;
  l_header_id             NUMBER;
BEGIN
  begin

    IF OE_CODE_CONTROL.GET_CODE_RELEASE_LEVEL >= '110510' THEN
       -- bug 3392678
      SELECT OE_XML_MESSAGE_SEQ_S.NEXTVAL
        INTO l_em_message_id
        FROM DUAL;
    END IF;

    select last_ack_code
    into   l_ack_code
    from   oe_header_acks
    where  header_id = p_header_id
      and  first_ack_date is not null
      and  last_ack_code is null
      and  rownum    = 1;
  exception
    when others then
      l_ack_code := 'AT';
  end;

   --Lock the header table before Updating bug4505695

   SELECT header_id
   INTO l_header_id
    FROM oe_order_headers
   WHERE  header_id = p_header_id
   FOR UPDATE nowait;
    UPDATE oe_order_headers
       SET last_ack_code = l_ack_code
         , last_ack_date = sysdate
         , lock_control   = lock_control + 1
         , xml_message_id = l_em_message_id
     WHERE header_id = p_header_id;

    UPDATE oe_header_acks
       SET acknowledgment_flag = 'Y'
         , last_ack_date = sysdate
     WHERE header_id = p_header_id
       AND first_ack_date is not null
       AND last_ack_date is null;

EXCEPTION
  WHEN OTHERS THEN NULL;

END Update_Header_Ack_last;


PROCEDURE Update_Line_Ack_First(
   p_header_id          IN  NUMBER
  ,p_line_id		IN  NUMBER
  ,p_ack_code		IN  VARCHAR2
) is

  l_api_name            CONSTANT VARCHAR2(30) := 'Update_Line_Ack_First';
  l_first_ack_date DATE := fnd_api.g_miss_date;
  l_ack_code VARCHAR2(30);
  l_header_id             NUMBER;
BEGIN
  begin
    select first_ack_code
    into   l_ack_code
    from   oe_line_acks
    where  header_id = p_header_id
      and  line_id   = p_line_id
      and  (first_ack_date is null
        or  first_ack_date = l_first_ack_date)
      and  rownum    = 1;
  exception
    when others then
      l_ack_code := 'IA'; --Changed AT to IA for bug4137350
  end;

  -- Lock the lines table before UPDATE for bug4505695

   SELECT header_id
   INTO l_header_id
   FROM oe_order_lines
   WHERE  line_id = p_line_id
   FOR UPDATE nowait;

    UPDATE oe_order_lines
       SET first_ack_code = l_ack_code
         , first_ack_date = sysdate
         , lock_control   = lock_control + 1
     WHERE line_id = p_line_id;

    UPDATE oe_line_acks
       SET acknowledgment_flag = 'Y'
         , first_ack_date =  sysdate
     WHERE  header_id = p_header_id
       AND  line_id   = p_line_id
       AND  (first_ack_date is null
         OR  first_ack_date = l_first_ack_date);
    UPDATE oe_line_acks
       SET acknowledgment_flag = 'Y'
         , first_ack_date =  sysdate
     WHERE  header_id = p_header_id
       AND  line_id   is null
       AND  (first_ack_date is null
         OR  first_ack_date = l_first_ack_date);

EXCEPTION
  WHEN OTHERS THEN NULL;

END Update_Line_Ack_first;


PROCEDURE Update_Line_Ack_Last(
   p_header_id          IN  NUMBER
  ,p_line_id		IN  NUMBER
  ,p_ack_code		IN  VARCHAR2
) is

  l_api_name            CONSTANT VARCHAR2(30) := 'Update_Line_Ack_Last';
  l_ack_code VARCHAR2(30);
   l_header_id             NUMBER;

BEGIN
  begin
    select last_ack_code
    into   l_ack_code
    from   oe_line_acks
    where  header_id = p_header_id
      and  line_id   = p_line_id
      and  first_ack_date is not null
      and  last_ack_date  is null
      and  rownum    = 1;
  exception
    when others then
       l_ack_code := 'IA'; --Changed AT to IA for bug4137350
  end;
   -- Lock the lines table before UPDATE for bug 4505695

   SELECT header_id
   INTO l_header_id
   FROM oe_order_lines
   WHERE  line_id = p_line_id
   FOR UPDATE nowait;

    UPDATE oe_order_lines
       SET last_ack_code = l_ack_code
         , last_ack_date = sysdate
         , lock_control   = lock_control + 1
         , first_ack_code = nvl(first_ack_code, l_ack_code)
         , first_ack_date = nvl(first_ack_date,sysdate)
     WHERE line_id = p_line_id;

    UPDATE oe_line_acks
       SET acknowledgment_flag = 'Y'
         , last_ack_date = sysdate
     WHERE header_id = p_header_id
       AND line_id   = p_line_id
       AND first_ack_date is not null
       AND last_ack_date is null;

EXCEPTION
  WHEN OTHERS THEN NULL;

END Update_Line_Ack_Last;


-- Procedure to get values for Acknowledgments
-- This procedure will be called by a workflow which receives the write ack data event.
-- It will fetch all the values required to be sent on the Ack and then write the
-- data to the Ack tables.
-- To be delivered with Pack J

Procedure write_ack_data_values
           (p_header_id           In   Number,
            p_transaction_type    In   Varchar2,
            x_return_status       Out Nocopy Varchar2)
Is
  --added end customer fields for bug 4034441
  Cursor Header_Acks_Cur IS
    Select Header_Id,
           Org_Id,
           Sold_To_Org_Id,
           Ship_To_Org_Id,
           Invoice_To_Org_Id,
           Sold_To_Contact_Id,
           Ship_To_Contact_Id,
           Ship_From_Org_Id,
           Order_Type_Id,
           Price_List_Id,
           Payment_Term_Id,
           Salesrep_Id,
           Fob_Point_Code,
           Freight_Terms_Code,
           Agreement_Id,
           Conversion_Type_Code,
           Tax_Exempt_Reason_Code,
           Tax_Point_Code,
           Invoicing_Rule_Id,
           End_Customer_Id,
           End_Customer_Contact_Id,
           End_Customer_Site_Use_Id

    From   Oe_Header_Acks
    Where  Header_Id = p_header_id
    And    Acknowledgment_Flag Is Null
    For Update;
  --Added end customer fields for bug 4034441
  Cursor Line_Acks_Cur Is
    Select line_id,
           ship_to_org_id,
           invoice_to_org_id,
           invoice_to_contact_id,
           ship_from_org_id,
           agreement_id,
           price_list_id,
           arrival_set_id,
           accounting_rule_id,
           fob_point_code,
           freight_terms_code,
           fulfillment_set_id,
           inventory_item_id,
           invoice_set_id,
           invoicing_rule_id,
           line_type_id,
           order_source_id,
           payment_term_id,
           project_id,
           salesrep_id,
           ship_set_id,
           ship_to_contact_id,
           shipping_method_code,
           task_id,
           tax_code,
           tax_exempt_reason_code,
           tax_point_code,
           line_type,
           ship_to_address1,
           ship_to_address2,
           ship_to_address3,
           ship_to_address4,
           ship_to_country,
           ship_to_state,
           ship_to_postal_code,
           ship_to_city,
           ship_to_address_code,
           ship_to_edi_location_code,
           ship_to_org,
           ship_from_address_1,
           ship_from_address_2,
           ship_from_address_3,
           ship_from_city,
           ship_from_postal_code,
           ship_from_country,
           ship_from_org,
           ship_from_edi_location_code,
           invoice_to_org,
           invoice_city,
           invoice_address_code,
           agreement,
           price_list,
           arrival_set_name,
           accounting_rule,
           fob_point,
           freight_terms,
           fulfillment_set_name,
           inventory_item,
           invoice_set_name,
           invoicing_rule,
           payment_term,
           project,
           salesrep,
           ship_set_name,
           ship_to_contact,
           ship_to_contact_first_name,
           ship_to_contact_last_name,
           shipping_method,
           fob_point_code,
           freight_terms_code,
           shipping_method_code,
           tax_code,
           tax_point_code,
           tax_exempt_reason_code,
           task,
           error_flag,
           End_Customer_Id,
           End_Customer_Contact_Id,
           End_Customer_Site_Use_Id,
           End_Customer_Name,
           End_Customer_Number,
           End_Customer_Contact,
           End_Customer_Address1,
           End_Customer_Address2,
           End_Customer_Address3,
           End_Customer_Address4,
           End_Customer_City,
           End_Customer_State,
           End_Customer_Postal_Code,
           End_Customer_Country
    From   Oe_Line_Acks
    Where  Header_id = p_header_id
    And    Acknowledgment_Flag Is Null
    For Update;

  l_debug_level              Constant Number := Oe_Debug_Pub.g_debug_level;
  l_return_status            Varchar2(1)     := FND_API.g_ret_sts_success;

  l_sold_to_site_use_id      Number;
  l_sold_to_location         Varchar2(40);
  l_invoice_to_location      Varchar2(40);
  l_ship_from_location       Varchar2(20);
  l_ship_from_address_4      Varchar2(20);
  l_ship_from_state          Varchar2(20);
  l_ship_from_org_id         Number;

  l_header_acks_rec          Oe_Header_Acks%ROWTYPE;
  l_line_acks_rec            OE_Update_Ack_Util.Line_Rec_Type;
  l_sold_to_org_id           Number;
  l_header_end_customer_location Varchar2(40);
  l_line_end_customer_location Varchar2(40);

Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Entering OE_Update_Ack_Util.write_ack_data_values');
    Oe_Debug_Pub.Add('Header_id: ||p_header_id');
  End If;

  Open Header_Acks_Cur;
    Fetch Header_Acks_Cur
    Into  l_header_acks_rec.header_id,
          l_header_acks_rec.org_id,
          l_header_acks_rec.sold_to_org_id,
          l_header_acks_rec.ship_to_org_id,
          l_header_acks_rec.invoice_to_org_id,
          l_header_acks_rec.sold_to_contact_id,
          l_header_acks_rec.ship_to_contact_id,
          l_header_acks_rec.ship_from_org_id,
          l_header_acks_rec.order_type_id,
          l_header_acks_rec.price_list_id,
          l_header_acks_rec.payment_term_id,
          l_header_acks_rec.salesrep_id,
          l_header_acks_rec.fob_point_code,
          l_header_acks_rec.freight_terms_code,
          l_header_acks_rec.agreement_id,
          l_header_acks_rec.conversion_type_code,
          l_header_acks_rec.tax_exempt_reason_code,
          l_header_acks_rec.tax_point_code,
          l_header_acks_rec.invoicing_rule_id,
          l_header_acks_rec.End_Customer_Id,
          l_header_acks_rec.End_Customer_Contact_Id,
          l_header_acks_rec.End_Customer_Site_Use_Id;

    If Header_Acks_Cur%NOTFOUND Then
      Close Header_Acks_Cur;
      x_return_status := FND_API.G_RET_STS_ERROR;
      Return;
    End If;

    -- Set the Org
    --dbms_application_info.set_client_info(l_header_acks_rec.org_id);
    mo_global.set_policy_context('S',l_header_acks_rec.org_id); --MOAC changes
    l_sold_to_org_id := l_header_acks_rec.sold_to_org_id;
    -- Start updating values in the rec structure

    -- Get Sold To Information
    Begin
      Select /* MOAC_SQL_CHANGE*/ b.site_use_id
        Into l_sold_to_site_use_id
        From hz_cust_acct_sites a, hz_cust_site_uses_all b
       Where a.cust_acct_site_id = b.cust_acct_site_id
         And a.cust_account_id   = l_header_acks_rec.sold_to_org_id
	 And b.org_id            = a.org_id
         And b.site_use_code     = 'SOLD_TO'
         And b.primary_flag      = 'Y'
         And b.status            = 'A';

      Oe_Xml_Process_Util.Get_Address_details
       (p_site_use_id       => l_sold_to_site_use_id,
        p_site_use_code     => 'SOLD_TO',
        x_location          => l_sold_to_location,
        x_address1          => l_header_acks_rec.sold_to_address1,
        x_address2          => l_header_acks_rec.sold_to_address2,
        x_address3          => l_header_acks_rec.sold_to_address3,
        x_address4          => l_header_acks_rec.sold_to_address4,
        x_city              => l_header_acks_rec.sold_to_city,
        x_state             => l_header_acks_rec.sold_to_state,
        x_country           => l_header_acks_rec.sold_to_country,
        x_postal_code       => l_header_acks_rec.sold_to_postal_code,
        x_edi_location_code => l_header_acks_rec.sold_to_edi_location_code,
        x_customer_name     => l_header_acks_rec.sold_to_org,
        x_return_status     => l_return_status);

      If l_header_acks_rec.sold_to_contact_id Is Not Null Then
       Oe_Xml_Process_Util.Get_Contact_Details
       (p_contact_id        => l_header_acks_rec.sold_to_contact_id,
        p_cust_acct_id      => l_header_acks_rec.sold_to_org_id,
        x_first_name        => l_header_acks_rec.sold_to_contact_first_name,
        x_last_name         => l_header_acks_rec.sold_to_contact_last_name,
        x_return_status     => l_return_status);
      End If;

    Exception
      When Others Then
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting sold to info '||sqlerrm);
        End If;
    End;

    -- Get Ship To info
    Begin
     If l_header_acks_rec.ship_to_org_id Is Not Null Then
      Oe_Xml_Process_Util.Get_Address_details
       (p_site_use_id       => l_header_acks_rec.ship_to_org_id,
        p_site_use_code     => 'SHIP_TO',
        x_location          => l_header_acks_rec.ship_to_address_code,
        x_address1          => l_header_acks_rec.ship_to_address_1,
        x_address2          => l_header_acks_rec.ship_to_address_2,
        x_address3          => l_header_acks_rec.ship_to_address_3,
        x_address4          => l_header_acks_rec.ship_to_address_4,
        x_city              => l_header_acks_rec.ship_to_city,
        x_state             => l_header_acks_rec.ship_to_state,
        x_country           => l_header_acks_rec.ship_to_country,
        x_postal_code       => l_header_acks_rec.ship_to_postal_code,
        x_edi_location_code => l_header_acks_rec.ship_to_edi_location_code,
        x_customer_name     => l_header_acks_rec.ship_to_org,
        x_return_status     => l_return_status);
     End If;
     If l_header_acks_rec.ship_to_contact_id Is Not Null Then
      Oe_Xml_Process_Util.Get_Contact_Details
       (p_contact_id        => l_header_acks_rec.ship_to_contact_id,
        p_cust_acct_id      => l_header_acks_rec.sold_to_org_id,
        x_first_name        => l_header_acks_rec.ship_to_contact_first_name,
        x_last_name         => l_header_acks_rec.ship_to_contact_last_name,
        x_return_status     => l_return_status);
     End If;

    Exception
      When Others Then
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting ship to info '||sqlerrm);
        End If;
    End;

     -- Get Invoice To info
    Begin
     If l_header_acks_rec.invoice_to_org_id Is Not Null Then
      Oe_Xml_Process_Util.Get_Address_details
       (p_site_use_id       => l_header_acks_rec.invoice_to_org_id,
        p_site_use_code     => 'BILL_TO',
        x_location          => l_invoice_to_location,
        x_address1          => l_header_acks_rec.invoice_address_1,
        x_address2          => l_header_acks_rec.invoice_address_2,
        x_address3          => l_header_acks_rec.invoice_address_3,
        x_address4          => l_header_acks_rec.invoice_address_4,
        x_city              => l_header_acks_rec.invoice_city,
        x_state             => l_header_acks_rec.invoice_state,
        x_country           => l_header_acks_rec.invoice_country,
        x_postal_code       => l_header_acks_rec.invoice_postal_code,
        x_edi_location_code => l_header_acks_rec.bill_to_edi_location_code,
        x_customer_name     => l_header_acks_rec.invoice_to_org,
        x_return_status     => l_return_status);
     End If;
     If l_header_acks_rec.invoice_to_contact_id Is Not Null Then
      Oe_Xml_Process_Util.Get_Contact_Details
       (p_contact_id        => l_header_acks_rec.invoice_to_contact_id,
        p_cust_acct_id      => l_header_acks_rec.sold_to_org_id,
        x_first_name        => l_header_acks_rec.invoice_to_contact_first_name,
        x_last_name         => l_header_acks_rec.invoice_to_contact_last_name,
        x_return_status     => l_return_status);
     End If;
    Exception
      When Others Then
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting invoice to info '||sqlerrm);
        End If;
    End;

    -- Get Ship From info
    Begin
     If l_header_acks_rec.ship_from_org_id Is Not Null Then
      Oe_Xml_Process_Util.Get_Address_details
       (p_site_use_id       => l_header_acks_rec.ship_from_org_id,
        p_site_use_code     => 'SHIP_FROM',
        x_location          => l_ship_from_location,
        x_address1          => l_header_acks_rec.ship_from_address_1,
        x_address2          => l_header_acks_rec.ship_from_address_2,
        x_address3          => l_header_acks_rec.ship_from_address_3,
        x_address4          => l_ship_from_address_4,
        x_city              => l_header_acks_rec.ship_from_city,
        x_state             => l_ship_from_state,
        x_country           => l_header_acks_rec.ship_from_country,
        x_postal_code       => l_header_acks_rec.ship_from_postal_code,
        x_edi_location_code => l_header_acks_rec.ship_from_edi_location_code,
        x_customer_name     => l_header_acks_rec.ship_from_org,
        x_return_status     => l_return_status);
     End If;
    Exception
      When Others Then
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting Ship From info '||sqlerrm);
        End If;
    End;

    -- Get Order Type, Price List, Salesrep, FOB, tax
    -- agreement, freight terms
    Begin

     If l_header_acks_rec.order_type_id Is Not Null Then
      l_header_acks_rec.order_type := Oe_Id_To_Value.Order_Type
                                       (p_order_type_id => l_header_acks_rec.order_type_id);
     End If;
     If l_header_acks_rec.price_list_id Is Not Null Then
      l_header_acks_rec.price_list := Oe_Id_To_Value.Price_List
                                       (p_price_list_id => l_header_acks_rec.price_list_id);
     End If;
     If l_header_acks_rec.payment_term_id Is Not Null Then
      l_header_acks_rec.payment_term := Oe_Id_To_Value.Payment_Term
                                         (p_payment_term_id => l_header_acks_rec.payment_term_id);
     End If;
     If l_header_acks_rec.salesrep_id Is Not Null Then
      l_header_acks_rec.salesrep := Oe_Id_To_Value.Salesrep
                                     (p_salesrep_id => l_header_acks_rec.salesrep_id);
     End If;
     If l_header_acks_rec.fob_point_code Is Not Null Then
      l_header_acks_rec.fob_point := Oe_Id_To_Value.Fob_Point
                                      (p_fob_point_code => l_header_acks_rec.fob_point_code);
     End If;
     If l_header_acks_rec.freight_terms_code Is Not Null Then
      l_header_acks_rec.freight_terms := Oe_Id_To_Value.Freight_Terms
                                          (p_freight_terms_code => l_header_acks_rec.freight_terms_code);
     End If;
     If l_header_acks_rec.agreement_id Is Not Null Then
      l_header_acks_rec.agreement := Oe_Id_To_Value.Agreement
                                      (p_agreement_id => l_header_acks_rec.agreement_id);
     End If;
     If l_header_acks_rec.conversion_type_code Is Not Null Then
      l_header_acks_rec.conversion_type := Oe_Id_To_Value.Conversion_Type
                                            (p_conversion_type_code => l_header_acks_rec.conversion_type_code);
     End If;
     If l_header_acks_rec.Tax_Exempt_Reason_code Is Not Null Then
      l_header_acks_rec.tax_exempt_reason := Oe_Id_To_Value.Tax_Exempt_Reason
                                              (p_tax_exempt_reason_code => l_header_acks_rec.tax_exempt_reason_code);
     End If;
     If l_header_acks_rec.tax_point_code Is Not Null Then
      l_header_acks_rec.tax_point := Oe_Id_To_Value.Tax_Point
                                      (p_tax_point_code => l_header_acks_rec.tax_point_code);
     End If;
     If l_header_acks_rec.invoicing_rule_id Is Not Null Then
      l_header_acks_rec.invoicing_rule := Oe_Id_To_Value.Invoicing_Rule
                                           (p_invoicing_rule_id => l_header_acks_rec.invoicing_rule_id);
     End If;
        --added for bug 40344441 start
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for header1');
        End If;

     If l_header_acks_rec.end_customer_id Is Not Null Then
      Oe_Id_To_Value.End_Customer(  p_end_customer_id => l_header_acks_rec.end_customer_id
,   x_end_customer_name => l_header_acks_rec.end_customer_name
,   x_end_customer_number => l_header_acks_rec.end_customer_number
);
     End If;




        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for header2');
        End If;

     If l_header_acks_rec.end_customer_contact_id Is Not Null Then
       l_header_acks_rec.end_customer_contact := Oe_Id_To_Value.End_Customer_Contact(p_end_customer_contact_id => l_header_acks_rec.end_customer_contact_id);
     End If;




        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for header3');
        End If;



     If l_header_acks_rec.end_customer_site_use_id Is Not Null Then
      OE_ID_TO_VALUE.End_Customer_Site_Use(  p_end_customer_site_use_id => l_header_acks_rec.end_customer_site_use_id
,   x_end_customer_address1 => l_header_acks_rec.end_customer_address1
,   x_end_customer_address2 => l_header_acks_rec.end_customer_address2
,   x_end_customer_address3 => l_header_acks_rec.end_customer_address3
,   x_end_customer_address4 => l_header_acks_rec.end_customer_address4
,   x_end_customer_location => l_header_end_customer_location
,   x_end_customer_city => l_header_acks_rec.end_customer_city
,   x_end_customer_state => l_header_acks_rec.end_customer_state
,   x_end_customer_postal_code => l_header_acks_rec.end_customer_postal_code
,   x_end_customer_country => l_header_acks_rec.end_customer_country
);
     End If;

        --added for bug 40344441 end
   -- start of changes for bug 4489065

      If l_debug_level > 0 Then
        Oe_Debug_Pub.Add('Before ship to customer name derviation for header');
      End If;

     If l_header_acks_rec.ship_to_org_id Is Not Null Then
       OE_ID_TO_VALUE.Ship_To_Customer_Name(p_ship_to_org_id => l_header_acks_rec.ship_to_org_id,
                                            x_ship_to_customer_name => l_header_acks_rec.ship_to_customer);
     End If;

     If l_debug_level > 0 Then
        Oe_Debug_Pub.Add('Before invoice to customer name derviation for header');
     End If;

     If l_header_acks_rec.invoice_to_org_id Is Not Null Then
       OE_ID_TO_VALUE.Invoice_To_Customer_Name(p_invoice_to_org_id => l_header_acks_rec.invoice_to_org_id,
                                               x_invoice_to_customer_name => l_header_acks_rec.invoice_customer);

     End If;
   -- end of changes for bug 4489065



    Exception

      When Others Then
      If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting other ids '||sqlerrm);
        End If;

    End;

  Close Header_Acks_Cur;


    -- Derive Ack Line Data
    Open Line_Acks_Cur;
    Fetch Line_Acks_Cur Bulk Collect
    Into  l_line_acks_rec.line_id,
          l_line_acks_rec.ship_to_org_id,
          l_line_acks_rec.invoice_to_org_id,
          l_line_acks_rec.invoice_to_contact_id,
          l_line_acks_rec.ship_from_org_id,
          l_line_acks_rec.agreement_id,
          l_line_acks_rec.price_list_id,
          l_line_acks_rec.arrival_set_id,
          l_line_acks_rec.accounting_rule_id,
          l_line_acks_rec.fob_point_code,
          l_line_acks_rec.freight_terms_code,
          l_line_acks_rec.fulfillment_set_id,
          l_line_acks_rec.inventory_item_id,
          l_line_acks_rec.invoice_set_id,
          l_line_acks_rec.invoicing_rule_id,
          l_line_acks_rec.line_type_id,
          l_line_acks_rec.order_source_id,
          l_line_acks_rec.payment_term_id,
          l_line_acks_rec.project_id,
          l_line_acks_rec.salesrep_id,
          l_line_acks_rec.ship_set_id,
          l_line_acks_rec.ship_to_contact_id,
          l_line_acks_rec.shipping_method_code,
          l_line_acks_rec.task_id,
          l_line_acks_rec.tax_code,
          l_line_acks_rec.tax_exempt_reason_code,
          l_line_acks_rec.tax_point_code,
          l_line_acks_rec.line_type,
          l_line_acks_rec.ship_to_address1,
          l_line_acks_rec.ship_to_address2,
          l_line_acks_rec.ship_to_address3,
          l_line_acks_rec.ship_to_address4,
          l_line_acks_rec.ship_to_country,
          l_line_acks_rec.ship_to_state,
          l_line_acks_rec.ship_to_postal_code,
          l_line_acks_rec.ship_to_city,
          l_line_acks_rec.ship_to_address_code,
          l_line_acks_rec.ship_to_edi_location_code,
          l_line_acks_rec.ship_to_org,
          l_line_acks_rec.ship_from_address_1,
          l_line_acks_rec.ship_from_address_2,
          l_line_acks_rec.ship_from_address_3,
          l_line_acks_rec.ship_from_city,
          l_line_acks_rec.ship_from_postal_code,
          l_line_acks_rec.ship_from_country,
          l_line_acks_rec.ship_from_org,
	  l_line_acks_rec.ship_from_edi_location_code,
          l_line_acks_rec.invoice_to_org,
          l_line_acks_rec.invoice_city,
          l_line_acks_rec.invoice_address_code,
          l_line_acks_rec.agreement,
          l_line_acks_rec.price_list,
          l_line_acks_rec.arrival_set_name,
          l_line_acks_rec.accounting_rule,
          l_line_acks_rec.fob_point,
          l_line_acks_rec.freight_terms,
          l_line_acks_rec.fulfillment_set_name,
          l_line_acks_rec.inventory_item,
          l_line_acks_rec.invoice_set_name,
          l_line_acks_rec.invoicing_rule,
          l_line_acks_rec.payment_term,
          l_line_acks_rec.project,
          l_line_acks_rec.salesrep,
          l_line_acks_rec.ship_set_name,
          l_line_acks_rec.ship_to_contact,
          l_line_acks_rec.ship_to_contact_first_name,
          l_line_acks_rec.ship_to_contact_last_name,
          l_line_acks_rec.shipping_method,
          l_line_acks_rec.fob_point_code,
          l_line_acks_rec.freight_terms_code,
          l_line_acks_rec.shipping_method_code,
          l_line_acks_rec.tax_code,
          l_line_acks_rec.tax_point_code,
          l_line_acks_rec.tax_exempt_reason_code,
          l_line_acks_rec.task,
          l_line_acks_rec.error_flag,
          l_line_acks_rec.End_Customer_Id,
          l_line_acks_rec.End_Customer_Contact_Id,
          l_line_acks_rec.End_Customer_Site_Use_Id,
          l_line_acks_rec.End_Customer_Name,
          l_line_acks_rec.End_Customer_Number,
          l_line_acks_rec.End_Customer_Contact,
          l_line_acks_rec.End_Customer_Address1,
          l_line_acks_rec.End_Customer_Address2,
          l_line_acks_rec.End_Customer_Address3,
          l_line_acks_rec.End_Customer_Address4,
          l_line_acks_rec.End_Customer_City,
          l_line_acks_rec.End_Customer_State,
          l_line_acks_rec.End_Customer_Postal_Code,
          l_line_acks_rec.End_Customer_Country;


    Close Line_Acks_Cur;

   If l_line_acks_rec.line_id.count > 0 Then

    For i In l_line_acks_rec.line_id.First..l_line_acks_rec.line_id.Last Loop
     If nvl(l_line_acks_rec.error_flag(i),'N') = 'N' Then
        l_line_acks_rec.line_type(i) := OE_Id_To_Value.Line_Type
         (p_line_type_id => l_line_acks_rec.line_type_id(i));

        l_line_acks_rec.price_list(i) := OE_Id_To_Value.price_list
         (p_price_list_id => l_line_acks_rec.price_list_id(i));

        l_line_acks_rec.salesrep(i) := OE_Id_To_Value.salesrep
         (p_salesrep_id => l_line_acks_rec.salesrep_id(i));

        l_line_acks_rec.fob_point(i) := OE_Id_To_Value.Fob_Point
         (p_Fob_Point_code => l_line_acks_rec.fob_point_code(i));

        l_line_acks_rec.freight_terms(i) := OE_Id_To_Value.freight_terms
         (p_freight_terms_code => l_line_acks_rec.freight_terms_code(i));

        l_line_acks_rec.Agreement(i) := OE_Id_To_Value.Agreement
         (p_agreement_id => l_line_acks_rec.agreement_id(i));

        l_line_acks_rec.payment_term(i) := OE_Id_To_Value.payment_term
         (p_payment_term_id => l_line_acks_rec.payment_term_id(i));

 If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for lines1');
        End If;


        Oe_Id_To_Value.End_Customer(  p_end_customer_id => l_line_acks_rec.end_customer_id(i)
,   x_end_customer_name => l_line_acks_rec.end_customer_name(i)
,   x_end_customer_number => l_line_acks_rec.end_customer_number(i)
);


        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for lines2');
        End If;


       l_line_acks_rec.end_customer_contact(i) := Oe_Id_To_Value.End_Customer_Contact(p_end_customer_contact_id => l_line_acks_rec.end_customer_contact_id(i));


        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Before end customer derivation for lines3');
        End If;

      OE_ID_TO_VALUE.End_Customer_Site_Use(  p_end_customer_site_use_id => l_line_acks_rec.end_customer_site_use_id(i)
,   x_end_customer_address1 => l_line_acks_rec.end_customer_address1(i)
,   x_end_customer_address2 => l_line_acks_rec.end_customer_address2(i)
,   x_end_customer_address3 => l_line_acks_rec.end_customer_address3(i)
,   x_end_customer_address4 => l_line_acks_rec.end_customer_address4(i)
,   x_end_customer_location => l_line_end_customer_location
,   x_end_customer_city => l_line_acks_rec.end_customer_city(i)
,   x_end_customer_state => l_line_acks_rec.end_customer_state(i)
,   x_end_customer_postal_code => l_line_acks_rec.end_customer_postal_code(i)
,   x_end_customer_country => l_line_acks_rec.end_customer_country(i)
);

        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('after end customer derivation for lines');
        End If;


      -- Get address info for lines here

      -- Get Ship To info
      Begin
       If l_line_acks_rec.ship_to_org_id(i) Is Not Null Then
        Oe_Xml_Process_Util.Get_Address_details
         (p_site_use_id       => l_line_acks_rec.ship_to_org_id(i),
          p_site_use_code     => 'SHIP_TO',
          x_location          => l_line_acks_rec.ship_to_address_code(i),
          x_address1          => l_line_acks_rec.ship_to_address1(i),
          x_address2          => l_line_acks_rec.ship_to_address2(i),
          x_address3          => l_line_acks_rec.ship_to_address3(i),
          x_address4          => l_line_acks_rec.ship_to_address4(i),
          x_city              => l_line_acks_rec.ship_to_city(i),
          x_state             => l_line_acks_rec.ship_to_state(i),
          x_country           => l_line_acks_rec.ship_to_country(i),
          x_postal_code       => l_line_acks_rec.ship_to_postal_code(i),
          x_edi_location_code => l_line_acks_rec.ship_to_edi_location_code(i),
          x_customer_name     => l_line_acks_rec.ship_to_org(i),
          x_return_status     => l_return_status);
       End If;
       If l_line_acks_rec.ship_to_contact_id(I) Is Not Null Then
        Oe_Xml_Process_Util.Get_Contact_Details
         (p_contact_id        => l_line_acks_rec.ship_to_contact_id(i),
          p_cust_acct_id      => l_sold_to_org_id,
          x_first_name        => l_line_acks_rec.ship_to_contact_first_name(i),
          x_last_name         => l_line_acks_rec.ship_to_contact_last_name(i),
          x_return_status     => l_return_status);
       End If;

      Exception
        When Others Then
          If l_debug_level > 0 Then
            Oe_Debug_Pub.Add('Error in getting ship to info line'||sqlerrm);
          End If;
      End;

    /*
     -- Get Invoice To info
     Begin
       If l_line_acks_rec.invoice_to_org_id(i) Is Not Null Then
         Oe_Xml_Process_Util.Get_Address_details
         (p_site_use_id       => l_line_acks_rec.invoice_to_org_id(i),
          p_site_use_code     => 'BILL_TO',
          x_location          => l_line_acks_rec.invoice_address_code(i),
          x_address1          => l_line_acks_rec.invoice_to_address1(i),
          x_address2          => l_line_acks_rec.invoice_to_address2(i),
          x_address3          => l_line_acks_rec.invoice_to_address3(i),
          x_address4          => l_line_acks_rec.invoice_to_address4(i),
          x_city              => l_line_acks_rec.invoice_city(i),
          x_state             => l_line_acks_rec.invoice_to_state(i),
          x_country           => l_line_acks_rec.invoice_to_country(i),
          x_postal_code       => l_line_acks_rec.invoice_to_postal_code(i),
          x_edi_location_code => l_line_acks_rec.bill_to_edi_location_code(i),
          x_customer_name     => l_line_acks_rec.invoice_to_org(i),
          x_return_status     => l_return_status);
        End If;

      Exception
        When Others Then
          If l_debug_level > 0 Then
            Oe_Debug_Pub.Add('Error in getting invoice to info line'||sqlerrm);
          End If;

      End;
      */

      -- Get Ship From info
      Begin
        If l_line_acks_rec.ship_from_org_id Is Not Null Then
          Oe_Xml_Process_Util.Get_Address_details
           (p_site_use_id       => l_line_acks_rec.ship_from_org_id(i),
            p_site_use_code     => 'SHIP_FROM',
            x_location          => l_ship_from_location,
            x_address1          => l_line_acks_rec.ship_from_address_1(i),
            x_address2          => l_line_acks_rec.ship_from_address_2(i),
            x_address3          => l_line_acks_rec.ship_from_address_3(i),
            x_address4          => l_ship_from_address_4,
            x_city              => l_line_acks_rec.ship_from_city(i),
            x_state             => l_ship_from_state,
            x_country           => l_line_acks_rec.ship_from_country(i),
            x_postal_code       => l_line_acks_rec.ship_from_postal_code(i),
            x_edi_location_code => l_line_acks_rec.ship_from_edi_location_code(i),
            x_customer_name     => l_line_acks_rec.ship_from_org(i),
            x_return_status     => l_return_status);
        End If;
      Exception
        When Others Then
        If l_debug_level > 0 Then
          Oe_Debug_Pub.Add('Error in getting Ship From info line'||sqlerrm);
        End If;
      End;

     End If;
    End Loop;

  -- Insert Line Ack Records
  FORALL i In l_line_acks_rec.line_id.First..l_line_acks_rec.line_id.last
    Update Oe_Line_Acks
    Set    line_type                     = l_line_acks_rec.line_type(i),
           price_list                    = l_line_acks_rec.price_list(i),
           salesrep                      = l_line_acks_rec.salesrep(i),
           fob_point                     = l_line_acks_rec.fob_point(i),
           freight_terms                 = l_line_acks_rec.freight_terms(i),
           Agreement                     = l_line_acks_rec.Agreement(i),
           payment_term                  = l_line_acks_rec.payment_term(i),
           ship_to_address1              = l_line_acks_rec.ship_to_address1(i),
           ship_to_address2              = l_line_acks_rec.ship_to_address2(i),
           ship_to_address3              = l_line_acks_rec.ship_to_address3(i),
           ship_to_address4              = l_line_acks_rec.ship_to_address4(i),
           ship_to_city                  = l_line_acks_rec.ship_to_city(i),
           ship_to_state                 = l_line_acks_rec.ship_to_state(i),
           ship_to_country               = l_line_acks_rec.ship_to_country(i),
           ship_to_postal_code           = l_line_acks_rec.ship_to_postal_code(i),
           ship_to_edi_location_code     = l_line_acks_rec.ship_to_edi_location_code(i),
           ship_to_address_code          = l_line_acks_rec.ship_to_address_code(i),
           ship_to_contact_first_name    = l_line_acks_rec.ship_to_contact_first_name(i),
           ship_to_contact_last_name     = l_line_acks_rec.ship_to_contact_last_name(i),
           invoice_to_org                = l_line_acks_rec.invoice_to_org(i),
           invoice_city                  = l_line_acks_rec.invoice_city(i) ,
           end_customer_name             = l_line_acks_rec.end_customer_name(i),
           end_customer_number           = l_line_acks_rec.end_customer_number(i),
           end_customer_contact          = l_line_acks_rec.end_customer_contact(i),
           end_customer_address1         = l_line_acks_rec.end_customer_address1(i),
           end_customer_address2         = l_line_acks_rec.end_customer_address2(i),
           end_customer_address3         = l_line_acks_rec.end_customer_address3(i),
           end_customer_address4         = l_line_acks_rec.end_customer_address4(i),
           end_customer_city             = l_line_acks_rec.end_customer_city(i),
           end_customer_state            = l_line_acks_rec.end_customer_state(i),
           end_customer_postal_code      = l_line_acks_rec.end_customer_postal_code(i),
           end_customer_country          = l_line_acks_rec.end_customer_country(i)

    Where  Header_Id           = p_header_id
    And    Acknowledgment_flag Is Null;

  End If;

  -- Update data in Acks table
  Update Oe_Header_Acks
  Set    sold_to_address1                = l_header_acks_rec.sold_to_address1,
         sold_to_address2                = l_header_acks_rec.sold_to_address2,
         sold_to_address3                = l_header_acks_rec.sold_to_address3,
         sold_to_address4                = l_header_acks_rec.sold_to_address4,
         sold_to_city                    = l_header_acks_rec.sold_to_city,
         sold_to_state                   = l_header_acks_rec.sold_to_state,
         sold_to_country                 = l_header_acks_rec.sold_to_country,
         sold_to_postal_code             = l_header_acks_rec.sold_to_postal_code,
         sold_to_edi_location_code       = l_header_acks_rec.sold_to_edi_location_code,
         sold_to_org                     = l_header_acks_rec.sold_to_org,
         sold_to_contact_first_name      = l_header_acks_rec.sold_to_contact_first_name,
         sold_to_contact_last_name       = l_header_acks_rec.sold_to_contact_last_name,
         ship_to_address_code            = l_header_acks_rec.ship_to_address_code,
         ship_to_address_1               = l_header_acks_rec.ship_to_address_1,
         ship_to_address_2               = l_header_acks_rec.ship_to_address_2,
         ship_to_address_3               = l_header_acks_rec.ship_to_address_3,
         ship_to_address_4               = l_header_acks_rec.ship_to_address_4,
         ship_to_city                    = l_header_acks_rec.ship_to_city,
         ship_to_state                   = l_header_acks_rec.ship_to_state,
         ship_to_country                 = l_header_acks_rec.ship_to_country,
         ship_to_postal_code             = l_header_acks_rec.ship_to_postal_code,
         ship_to_edi_location_code       = l_header_acks_rec.ship_to_edi_location_code,
         ship_to_org                     = l_header_acks_rec.ship_to_org,
         ship_to_contact_first_name      = l_header_acks_rec.ship_to_contact_first_name,
         ship_to_contact_last_name       = l_header_acks_rec.ship_to_contact_last_name,
         invoice_address_1               = l_header_acks_rec.invoice_address_1,
         invoice_address_2               = l_header_acks_rec.invoice_address_2,
         invoice_address_3               = l_header_acks_rec.invoice_address_3,
         invoice_address_4               = l_header_acks_rec.invoice_address_4,
         invoice_city                    = l_header_acks_rec.invoice_city,
         invoice_state                   = l_header_acks_rec.invoice_state,
         invoice_country                 = l_header_acks_rec.invoice_country,
         invoice_postal_code             = l_header_acks_rec.invoice_postal_code,
         bill_to_edi_location_code       = l_header_acks_rec.bill_to_edi_location_code,
         invoice_to_org                  = l_header_acks_rec.invoice_to_org,
         invoice_to_contact_first_name   = l_header_acks_rec.invoice_to_contact_first_name,
         invoice_to_contact_last_name    = l_header_acks_rec.invoice_to_contact_last_name,
         ship_from_address_1             = l_header_acks_rec.ship_from_address_1,
         ship_from_address_2             = l_header_acks_rec.ship_from_address_2,
         ship_from_address_3             = l_header_acks_rec.ship_from_address_3,
         ship_from_city                  = l_header_acks_rec.ship_from_city,
         ship_from_country               = l_header_acks_rec.ship_from_country,
         ship_from_postal_code           = l_header_acks_rec.ship_from_postal_code,
         ship_from_edi_location_code     = l_header_acks_rec.ship_from_edi_location_code,
         ship_from_org                   = l_header_acks_rec.ship_from_org,
         order_type                      = l_header_acks_rec.order_type,
         price_list                      = l_header_acks_rec.price_list,
         payment_term                    = l_header_acks_rec.payment_term,
         salesrep                        = l_header_acks_rec.salesrep,
         fob_point                       = l_header_acks_rec.fob_point,
         freight_terms                   = l_header_acks_rec.freight_terms,
         agreement                       = l_header_acks_rec.agreement,
         conversion_type                 = l_header_acks_rec.conversion_type,
         tax_exempt_reason               = l_header_acks_rec.tax_exempt_reason,
         tax_point                       = l_header_acks_rec.tax_point,
         invoicing_rule                  = l_header_acks_rec.invoicing_rule ,
         end_customer_name               = l_header_acks_rec.end_customer_name,
         end_customer_number             = l_header_acks_rec.end_customer_number,
         end_customer_contact            = l_header_acks_rec.end_customer_contact,
         end_customer_address1           = l_header_acks_rec.end_customer_address1,
         end_customer_address2           = l_header_acks_rec.end_customer_address2,
         end_customer_address3           = l_header_acks_rec.end_customer_address3,
         end_customer_address4           = l_header_acks_rec.end_customer_address4,
         end_customer_city               = l_header_acks_rec.end_customer_city,
         end_customer_state              = l_header_acks_rec.end_customer_state,
         end_customer_postal_code        = l_header_acks_rec.end_customer_postal_code,
         end_customer_country            = l_header_acks_rec.end_customer_country,
	 ship_to_customer                = l_header_acks_rec.ship_to_customer,
         invoice_customer                = l_header_acks_rec.invoice_customer

  Where  Header_Id           = p_header_id
  And    Acknowledgment_flag Is Null;


  x_return_status := FND_API.G_RET_STS_SUCCESS;

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Exiting OE_Update_Ack_Util.write_ack_data_values');
  End If;

Exception

  When Too_Many_Rows Then
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('More than 1 ack header in Ack tables which is not acknowledged');
    End If;

  When Others Then
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('Others Exception in write_ack_data_values '||sqlerrm);
    End If;

  x_return_status := FND_API.G_RET_STS_ERROR;

End write_ack_data_values;


Procedure Derive_Ack_Values
 (p_itemtype      In      Varchar2,
  p_itemkey       In      Varchar2,
  p_actid         In      Number,
  p_funcmode      In      Varchar2,
  p_x_result      In Out Nocopy  Varchar2
 )
Is

  l_header_id                Number;
  l_transaction_type         Varchar2(4);
  l_transaction_subtype      Varchar2(4);
  l_return_status            Varchar2(1);

  l_debug_level              CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  l_user_key                 Varchar2(240);
  l_orig_sys_document_ref    Varchar2(50);
  l_change_sequence          Varchar2(50);
  l_sold_to_org_id           Number;
  l_order_number             Number;
  l_order_source_id          Number;
  l_org_id                   Number;
  l_xml_msg_id               Number;
  l_order_type_id            Number;
  l_message_text             Varchar2(500);

Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('In Derive_Ack_Values');
  End If;

  Oe_Standard_Wf.Set_Msg_Context(p_actid);

  l_header_id := wf_engine.GetItemAttrNumber
                  (p_itemtype,
                   p_itemkey,
                   'HEADER_ID');

  l_transaction_type := wf_engine.GetItemAttrText
                         (p_itemtype,
                          p_itemkey,
                          'TRANSACTION_TYPE');

  l_transaction_subtype := wf_engine.GetItemAttrText
                         (p_itemtype,
                          p_itemkey,
                          'TRANSACTION_SUBTYPE');

  l_orig_sys_document_ref := wf_engine.GetItemAttrText
                         (p_itemtype,
                          p_itemkey,
                          'ORIG_SYS_DOCUMENT_REF');

  l_change_sequence := wf_engine.GetItemAttrText
                         (p_itemtype,
                          p_itemkey,
                          'CHANGE_SEQUENCE');

  l_order_number := wf_engine.GetItemAttrNumber
                         (p_itemtype,
                          p_itemkey,
                          'ORDER_NUMBER');

  l_sold_to_org_id := wf_engine.GetItemAttrNumber
                       (p_itemtype,
                        p_itemkey,
                        'SOLD_TO_ORG_ID');

  l_xml_msg_id := wf_engine.GetItemAttrNumber
                       (p_itemtype,
                        p_itemkey,
                        'XML_MESSAGE_ID');

  l_order_type_id := wf_engine.GetItemAttrNumber
                       (p_itemtype,
                        p_itemkey,
                        'ORDER_TYPE_ID');

  l_org_id := wf_engine.GetItemAttrNumber
                       (p_itemtype,
                        p_itemkey,
                        'ORG_ID');

  l_order_source_id := wf_engine.GetItemAttrNumber
                       (p_itemtype,
                        p_itemkey,
                        'ORDER_SOURCE_ID');

  l_user_key       := l_orig_sys_document_ref || ',' ||to_char(l_sold_to_org_id)||','||
                      l_change_sequence||','||l_transaction_type;

   -- start exception management
   OE_MSG_PUB.set_msg_context(
           p_entity_code                => 'ELECMSG_'||p_itemtype
          ,p_entity_id                  => p_itemkey
          ,p_header_id                  => l_header_id
          ,p_line_id                    => null
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => null
          ,p_orig_sys_shipment_ref      => null
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => null
          ,p_source_document_id         => null
          ,p_source_document_line_id    => null );
   -- end exception management

  wf_engine.SetItemUserKey(itemtype     => 'OEXWFEDI',
                           itemkey      => p_itemkey,
                           userkey      => l_user_key);

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('Header Id = '||l_header_id);
  End If;

  write_ack_data_values
   (p_header_id        => l_header_id,
    p_transaction_type => l_transaction_type,
    x_return_status    => l_return_status);

  If l_return_status = FND_API.G_RET_STS_SUCCESS Then
    p_x_result := 'SUCCESS';
    fnd_message.set_name('ONT', 'OE_OI_OUTBOUND_TRIGGERED');
    fnd_message.set_token ('TRANSACTION', l_transaction_subtype);
    l_message_text := fnd_message.get;
    OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  l_order_source_id,
             p_partner_document_num   =>  l_orig_sys_document_ref,
             p_sold_to_org_id         =>  l_sold_to_org_id,
             p_transaction_type       =>  l_transaction_type,
             p_transaction_subtype    =>  l_transaction_subtype,
             p_itemtype               =>  'OEXWFEDI',
             p_itemkey                =>  p_itemkey,
             p_message_text           =>  l_message_text,
             p_document_num           =>  l_order_number,
             p_change_sequence        =>  l_change_sequence,
             p_org_id                 =>  l_org_id,
             p_xmlg_document_id       => l_xml_msg_id,
             p_order_type_id          => l_order_type_id,
             p_doc_status             => 'ACTIVE',
             p_header_id              => l_header_id,
             p_processing_stage       => 'OUTBOUND_SETUP',
             x_return_status          =>  l_return_status);
  Else
    p_x_result := 'FAILURE';
  End If;

  --OE_STANDARD_WF.Save_Messages;
  --OE_STANDARD_WF.Clear_Msg_Context;

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('End Derive_Ack_Values');
  End If;

Exception

  When Others Then
    p_x_result := '#EXCEPTION';
    WF_CORE.Context('OE_UPDATE_ACK_UTIL', 'DERIVE_ACK_VALUES',
                    p_itemtype, p_itemkey, p_actid, p_funcmode);
    OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => p_actid,
                                          p_itemtype => p_itemtype,
                                          p_itemkey => p_itemkey);
    OE_STANDARD_WF.Save_Messages;
    OE_STANDARD_WF.Clear_Msg_Context;
    RAISE;

End Derive_Ack_Values;

Procedure Raise_Derive_Ack_Data_event
 (p_transaction_type          In  Varchar2,
  p_header_id                 In  Number,
  p_org_id                    In  Number,
  p_orig_sys_document_ref     In  Varchar2,
  p_change_sequence           In  Varchar2,
  p_sold_to_org_id            In  Number,
  p_order_number              In  Number,
  p_xml_msg_id                In  Number,
  p_order_type_id             In  Number,
  p_order_source_id           In  Number,
  p_transaction_subtype       In  Varchar2,
  x_return_status             Out Nocopy Varchar2
 )
Is

  l_parameter_list      wf_parameter_list_t := wf_parameter_list_t();
  l_event_name          Varchar2(50);
  l_itemkey             Number;

  l_debug_level         CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --Pragma                AUTONOMOUS_TRANSACTION;
  l_return_status       Varchar2(1);


Begin

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('In Raise_Derive_Ack_Data_event');
  End If;

  l_event_name     := 'oracle.apps.ont.oi.edi_ack_values.create';

  Select Oe_Xml_Message_Seq_S.nextval
  Into   l_itemkey
  From   dual;

  wf_event.AddParameterToList(p_name=>          'TRANSACTION_TYPE',
                              p_value=>         p_transaction_type,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'TRANSACTION_SUBTYPE',
                              p_value=>         p_transaction_subtype,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'HEADER_ID',
                              p_value=>         p_header_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORG_ID',
                              p_value=>         p_org_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORIG_SYS_DOCUMENT_REF',
                              p_value=>         p_orig_sys_document_ref,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'CHANGE_SEQUENCE',
                              p_value=>         p_change_sequence,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'SOLD_TO_ORG_ID',
                              p_value=>         p_sold_to_org_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORDER_NUMBER',
                              p_value=>         p_order_number,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'XML_MESSAGE_ID',
                               p_value=>        p_xml_msg_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORDER_TYPE_ID',
                               p_value=>        p_order_type_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.AddParameterToList(p_name=>          'ORDER_SOURCE_ID',
                               p_value=>        p_order_source_id,
                              p_parameterlist=> l_parameter_list);

  wf_event.raise( p_event_name => l_event_name,
                  p_event_key  =>  l_itemkey,
                  p_parameters => l_parameter_list);


  l_parameter_list.DELETE;
  --Commit;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  /*
  OE_Acknowledgment_Pub.Raise_Event_XMLInt (
             p_order_source_id        =>  p_order_source_id,
             p_partner_document_num   =>  p_orig_sys_document_ref,
             p_sold_to_org_id         =>  p_sold_to_org_id,
             p_transaction_type       =>  p_transaction_type,
             p_transaction_subtype    =>  p_transaction_subtype,
             p_itemtype               =>  'OEXWFEDI',
             p_itemkey                =>  l_itemkey,
             p_message_text           =>  'Event to derive EDI Acknowledgment values raised successfully',
             p_document_num           =>  p_order_number,
             p_change_sequence        =>  p_change_sequence,
             p_org_id                 =>  p_org_id,
             p_xmlg_document_id       =>  p_xml_msg_id,
             p_order_type_id          =>  p_order_type_id,
             p_header_id              => p_header_id,
             p_doc_status             => 'ACTIVE',
             p_processing_stage       => 'OUTBOUND_TRIGGERED',
             x_return_status          =>  l_return_status);
  */

  If l_debug_level > 0 Then
    Oe_Debug_Pub.Add('End Raise_Derive_Ack_Data_event');
  End If;

Exception

  When Others Then
    x_return_status := FND_API.G_RET_STS_ERROR;
    If l_debug_level > 0 Then
      Oe_Debug_Pub.Add('Others exception in Raise_Derive_Ack_Data_event');
      Oe_Debug_Pub.Add('Error: '||sqlerrm);
    End If;

End Raise_Derive_Ack_Data_event;


Procedure Oe_Edi_Selector
( p_itemtype   in     varchar2,
  p_itemkey    in     varchar2,
  p_actid      in     number,
  p_funcmode   in     varchar2,
  p_x_result   in out Nocopy varchar2
)
Is

  l_debug_level          Constant Number := oe_debug_pub.g_debug_level;
  l_user_id              Number ;
  l_resp_appl_id         Number ;
  l_resp_id              Number ;
  l_org_id               Number;
  l_current_org_id       Number;
  l_client_org_id        Number;

Begin

  --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);

  If (p_funcmode = 'RUN') Then
    p_x_result := 'COMPLETE';

  Elsif (p_funcmode = 'SET_CTX') Then

    l_org_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                             , p_itemkey
                                             , 'ORG_ID'
                                            );
    If l_debug_level  > 0 Then
       oe_debug_pub.add('l_org_id =>' || l_org_id);
    End If;

    mo_global.set_policy_context(p_access_mode => 'S', p_org_id=>l_Org_Id);
    p_x_result := 'COMPLETE';

  Elsif (p_funcmode = 'TEST_CTX') Then
    --FND_GLOBAL.Apps_Initialize(l_user_id, l_resp_id, l_resp_appl_id);
    l_org_id :=  wf_engine.GetItemAttrNumber( p_itemtype
                                            , p_itemkey
                                            , 'ORG_ID'
                                            );
    IF (NVL(mo_global.get_current_org_id,-99) <> l_Org_Id)
    THEN
      p_x_result := 'FALSE';
    ELSE
      p_x_result := 'TRUE';
    END IF;

  End If;

Exception
  When Others Then
    Raise;

End Oe_Edi_Selector;


END OE_Update_Ack_Util;

/
