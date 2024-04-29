--------------------------------------------------------
--  DDL for Package Body PV_ORDER_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ORDER_MGMT_PVT" as
/* $Header: pvxvpomb.pls 120.37.12010000.3 2009/04/28 21:49:39 hekkiral ship $ */



--Comments
--kvattiku: Aug 05, 05	For R12
--	1. In set_enrq_payment_info, retrieve from pv_lookups as all the payment types
--	are included in it for backporting enhancements.
--	2. Invoice is a payment type and we should pass payment type code as null in set_payment_info.
--	3. As Purchase Order is not a payment type, commented out relevant code in set_payment_info.
--	4. PO number is a new attribute for all pay types, so store the number in set_payment_info.
--kvattiku: Aug 08, 05 For R12 (NOCOPY bug 4445205)
--	1. Declared new output variables (l_header_out_rec and l_line_out_tbl) wherever required and substituted
--	them for the output variables (x_header_rec and x_line_tbl) when calling OE_ORDER_GRP.process_order
--kvattiku: Aug 14, 05 For R12
--	Modified the signatures of set_enrq_payment_info and set_payment_info procedures. p_payment_method_rec and
--	p_enrl_req_id (in set_enrq_payment_info) are only IN and not IN OUT. p_payment_method_rec and
--	p_order_header_id (in set_payment_info) are only IN and not IN OUT.
--ktsao: Oct 05, 05 Fixed for bug 4645137
--ktsao: Oct 05, 05 Added debug message for cancel_order


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_ORDER_MGMT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpomb.pls';
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


-- usage: this function is needed because OM is writing messages into its on
-- stack and is not using the fnd stack. here the exception handlers will not
-- take care of it.

PROCEDURE Retrieve_OE_Messages IS
  l_msg_count NUMBER;
  l_msg_data  VARCHAR2(2000);
  x_msg_data  VARCHAR2(2000);
  l_msg_index                   NUMBER := 0;


  l_len_sqlerrm NUMBER;
  i             NUMBER := 1;


 BEGIN

     OE_MSG_PUB.Count_And_Get
   		( p_count         	=>      l_msg_count,
        	  p_data          	=>      l_msg_data
    		);

   IF l_msg_count > 0 THEN

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('before updating the processing messages table');

     END IF;

     FOR k IN 1 .. l_msg_count LOOP

       i:=1;

       IF (PV_DEBUG_HIGH_ON) THEN



       PVX_UTILITY_PVT.debug_message('before calling oe_msg_pub.get');

       END IF;
       oe_msg_pub.get (
           p_msg_index     => k
          ,p_encoded       => FND_API.G_FALSE
          ,p_data          => l_msg_data
          ,p_msg_index_out => l_msg_index);

       IF oe_msg_pub.g_msg_tbl(l_msg_index).message_text IS NULL THEN
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('In index.message_text is null');
          END IF;
          x_msg_data := oe_msg_pub.get(l_msg_index, 'F');
        END IF;

        x_msg_data := l_msg_data;

        IF (PV_DEBUG_HIGH_ON) THEN



        PVX_UTILITY_PVT.debug_message('x_msg_data ' || x_msg_data);

        END IF;

        l_len_sqlerrm := Length(x_msg_data) ;
        WHILE l_len_sqlerrm >= i LOOP
          FND_MESSAGE.Set_Name('PV', 'PV_OM_ERROR');
          FND_MESSAGE.Set_token('MSG_TXT' , substr(x_msg_data,i,240));
          i := i + 240;
          FND_MSG_PUB.ADD;
        END LOOP;

     END LOOP;

   END IF;

END Retrieve_OE_Messages;


PROCEDURE Order_Debug_On IS

  cursor c_debug_directory IS
  select value value, substr(value,1,instr(value,',')-1) subvalue
  from v$parameter where name = 'utl_file_dir';

  l_debug_dir varchar2(512);
  l_file_val  varchar2(2000);
  l_debug_on  VARCHAR2(240);
  l_debug_level number;


BEGIN

  l_debug_on := FND_PROFILE.Value('SO_DEBUG');

  IF (PV_DEBUG_HIGH_ON) THEN
    PVX_UTILITY_PVT.debug_message('OE Debug on ' || l_debug_on);
  END IF;

  IF (l_debug_on = 'Y' )THEN
  for x in c_debug_directory loop
    IF (x.subvalue IS NULL) THEN
      l_debug_dir := x.value;
    else
      l_debug_dir := x.subvalue;
    END IF;
    exit when l_debug_dir IS NOT NULL;
  end loop;

  l_debug_level := to_number(nvl(FND_PROFILE.Value('OE_DEBUG_LEVEL'), 5));
  oe_Debug_pub.setdebuglevel(l_debug_level);
  oe_debug_pub.debug_on;
  oe_debug_pub.initialize;
  OE_DEBUG_PUB.G_DIR := l_debug_dir;
  l_file_val  := OE_DEBUG_PUB.Set_Debug_Mode('FILE');
  IF (PV_DEBUG_HIGH_ON) THEN
    PVX_UTILITY_PVT.debug_message('Debug File ' || l_file_val);
  END IF;
  END IF;

END Order_Debug_On;




PROCEDURE set_mo_policy_context (p_order_header_id IN number)
IS
   CURSOR c_order_header_id (l_order_header_id number) IS
     select org_id
     from oe_order_headers_all
     where header_id = l_order_header_id;

   curr_org number;
   order_org number;

BEGIN

   IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message(' begin : set_mo_policy_context: ' );
   END IF;

   curr_org := mo_global.get_current_org_id;

   IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message('set_mo_policy_context: p_order_header_id ' || p_order_header_id);
	PVX_UTILITY_PVT.debug_message('set_mo_policy_context: curr_org ' || curr_org);
   END IF;

   OPEN c_order_header_id(p_order_header_id);
     FETCH c_order_header_id into order_org;
   CLOSE c_order_header_id;

   IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('set_mo_policy_context: order_org ' || order_org);
   END IF;

   if ((curr_org is null or curr_org <> order_org) and order_org is not null) then
	mo_global.set_policy_context('S', order_org);
	IF (PV_DEBUG_HIGH_ON) THEN
		PVX_UTILITY_PVT.debug_message('call mo_global.set_policy_context set single org');
	 END IF;
   end if;

   IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message(' end : set_mo_policy_context: ' );
   END IF;

END set_mo_policy_context;





 PROCEDURE process_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN  VARCHAR2           := FND_API.G_FALSE
    ,p_party_site_id              IN   NUMBER
    ,p_partner_party_id           IN   NUMBER
    ,p_currency_code              IN   VARCHAR2
    ,p_contact_party_id           IN   NUMBER
    ,p_partner_account_id         IN   NUMBER
    ,P_order_tbl                  IN   Order_Tbl_type
    ,x_order_header_id            OUT  NOCOPY  JTF_NUMBER_TABLE
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
  )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'process_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
   l_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;

   --kvattiku Aug 08, 05 Added new variables to take care of the NOCOPY related changes (bug # 4445205)
   l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
   l_line_out_tbl              OE_ORDER_PUB.Line_Tbl_Type;


   l_transaction_type_id       NUMBER;
   l_bill_to_site_use_id       NUMBER;
   l_ship_to_site_use_id       NUMBER;
   l_cust_account_role_id      NUMBER;
   l_cust_acct_site_id	       NUMBER;
   l_party_id		       NUMBER;
   l_salesrep_id               NUMBER;
   l_price_exists boolean := true;
   l_update_order boolean := false;

   l_msg_count        number;
   l_msg_data         varchar2(200);
   l_return_status    VARCHAR2(1);


   x_header_val_rec          OE_ORDER_PUB.Header_Val_Rec_Type;
   x_Header_Adj_tbl          OE_ORDER_PUB. Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl      OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl    OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl      OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl    OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl      OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl  OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl            OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl            OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl        OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl      OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl        OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl      OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl        OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl    OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl          OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl      OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	     OE_ORDER_PUB.Request_Tbl_Type;

   CURSOR validate_price (cv_order_header_id JTF_NUMBER_TABLE) IS
     select 1 from dual where exists
      (select /*+ CARDINALITY(t 10) */ 1
      from oe_order_lines_all,(SELECT * FROM TABLE (CAST(cv_order_header_id AS JTF_NUMBER_TABLE))) t
      where header_id = t.column_value
	  and  (unit_list_price is null or
	 unit_selling_price is null or price_list_id is  null));


 BEGIN


     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT PV_PROCESS_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------

  -------------Validate IN Parameters -----------------------------

      IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;


     IF (p_party_site_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_PARTY_SITE_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_partner_party_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_PARTNER_PARTY_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_currency_code = FND_API.G_MISS_CHAR) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_CURRENCY');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_contact_party_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_CONTACT_PARTY_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_partner_account_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
	  FND_MESSAGE.Set_Token('ID', 'Account', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (P_order_tbl.count = 0) THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
	  FND_MESSAGE.Set_Token('ID', 'Order Details', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR i in P_order_tbl.FIRST..P_order_tbl.LAST loop
      IF((P_order_tbl(i).order_header_id=FND_API.G_MISS_NUM or P_order_tbl(i).order_header_id IS NULL)
         and (P_order_tbl(i).inventory_item_id=FND_API.G_MISS_NUM or P_order_tbl(i).inventory_item_id IS NULL)) THEN
          FND_MESSAGE.set_name('PV', 'PV_NO_PROGRAM_INVENTORY_ITEM');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
     end loop;


     -------------End of Validate IN Parameters -----------------------------
     ------------- Get Transaction Type ID and Salesperson ID for order creation -----------

    for i in P_order_tbl.FIRST..P_order_tbl.LAST loop
       IF((P_order_tbl(i).order_header_id is not null) and
          (P_order_tbl(i).order_header_id <> FND_API.G_MISS_NUM)) THEN
	  l_update_order := true;
	  exit;
       END IF;
    end loop;

    IF(not(l_update_order)) THEN
      l_transaction_type_id := to_number(FND_PROFILE.Value('PV_ORDER_TRANSACTION_TYPE_ID'));
      IF  l_transaction_type_id is null then
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('PV', 'PV_NO_ORDER_TRANSACTION_TYPE');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- add to fix bug#2792593
      l_salesrep_id := to_number(FND_PROFILE.Value('PV_DEFAULT_SALESPERSON_ID'));
      IF  l_salesrep_id is null then
          x_return_status := FND_API.G_RET_STS_ERROR;
          FND_MESSAGE.Set_Name('PV', 'PV_NO_SALESREP_ID');
          FND_MSG_PUB.ADD;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- end adding
    END IF;

   -------------End of Get Transaction Type ID and Salesperson ID for order creation -----------



     IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Partner Accoutn ID : ' || p_partner_account_id);

     END IF;



     ----------------End of Get Sold to org ID----------------------------------
     /* R12 Changes
      * Calls to PV_PARTNER_ACCNT_MGMT_PVT.get_acct_site_uses will have an extra
      * out parameter x_cust_acct_site_id which will get passed to the procedure
      * PV_PARTNER_ACCNT_MGMT_PVT.get_cust_acct_roles
      * also will pass a generic party_id to get_acct_site_uses and will throw
      * an exception if the party_site_id does not match with the partner_party_id
      * or contact_party_id
      */

     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('-----Get generic party_id based on party_site_id------');
     END IF;

     select party_id
     into   l_party_id
     from   hz_party_sites
     where  party_site_id = p_party_site_id
     and    party_id in (p_partner_party_id, p_contact_party_id)
     and    status = 'A';

     IF (l_party_id IS NULL) THEN
        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('PV', 'PV_INVALID_PARTY_SITE_COMB');
	   FND_MESSAGE.Set_Token('ID1', to_char(p_partner_party_id) || ',' || to_char(p_contact_party_id), FALSE);
	   FND_MESSAGE.Set_Token('ID2', to_char(p_party_site_id), FALSE);
	   FND_MSG_PUB.ADD;
	END IF;
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('-----Get Invoice to Org ID------');
     END IF;
     PV_PARTNER_ACCNT_MGMT_PVT.Get_acct_site_uses(
              p_party_site_id  => p_party_site_id,
              p_acct_site_type => 'BILL_TO',
              p_cust_account_id => p_partner_account_id,
              p_party_id => l_party_id,
              x_return_status => l_return_status,
              x_site_use_id => l_bill_to_site_use_id,
	      x_cust_acct_site_id => l_cust_acct_site_id
     );

      IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('l_bill_to_site_use_id : ' ||l_bill_to_site_use_id);
        PVX_UTILITY_PVT.debug_message('l_return_status : ' || l_return_status);

       END IF;

     IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('PV', 'PV_INVOICE_ORG_ERROR');
           FND_MESSAGE.Set_Token('ID', to_char(p_partner_party_id), FALSE);
           FND_MSG_PUB.ADD;
        END IF;
            raise FND_API.G_EXC_ERROR;
    END IF;

     -----------------End of get Invoice to Org ID--------------------------------
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('---------Get Ship To Org ID-----------');
     END IF;

    PV_PARTNER_ACCNT_MGMT_PVT.Get_acct_site_uses(
              p_party_site_id  => p_party_site_id,
              p_acct_site_type => 'SHIP_TO',
              p_cust_account_id => p_partner_account_id,
              p_party_id => l_party_id,
              x_return_status => l_return_status,
              x_site_use_id => l_ship_to_site_use_id,
	      x_cust_acct_site_id => l_cust_acct_site_id
     );

      IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('l_ship_to_site_use_id : ' ||l_ship_to_site_use_id);
        PVX_UTILITY_PVT.debug_message('l_return_status : ' || l_return_status);

     END IF;
     IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('PV', 'PV_SHIP_TO_ORG_ERROR');
           FND_MESSAGE.Set_Token('ID', to_char(p_partner_party_id), FALSE);
           FND_MSG_PUB.ADD;
        END IF;
            raise FND_API.G_EXC_ERROR;
    END IF;

     ---------------End of Ship Org ID----------------------------------
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('----- Get Contact Role--------');
     END IF;

     PV_PARTNER_ACCNT_MGMT_PVT.Get_cust_acct_roles(
              p_contact_party_id => p_contact_party_id,
              p_cust_account_id  => p_partner_account_id,
	      p_cust_account_site_id => l_cust_acct_site_id,
              x_return_status    => l_return_status,
              x_cust_account_role_id => l_cust_account_role_id
     );

      IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('l_cust_account_role_id : ' ||l_cust_account_role_id);
       PVX_UTILITY_PVT.debug_message('l_return_status : ' || l_return_status);

      END IF;

      IF l_Return_Status <> FND_API.G_RET_STS_SUCCESS THEN
       IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
           FND_MESSAGE.Set_Name('PV', 'PV_ACCOUNT_ROLE_ERROR');
           FND_MESSAGE.Set_Token('ID', to_char(p_contact_party_id), FALSE);
           FND_MSG_PUB.ADD;
        END IF;
            raise FND_API.G_EXC_ERROR;
    END IF;
     --------------End of get Contact role--------------------------------



     IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Before header rec initialization');
     END IF;

    x_order_header_id   := JTF_NUMBER_TABLE();

    FOR i in p_order_tbl.FIRST..p_order_tbl.LAST LOOP

      Order_Debug_On;

    l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_rec.freight_terms_code := NULL;
    l_header_rec.transactional_curr_code := P_currency_code;
    l_header_rec.sold_to_org_id := p_partner_account_id;
    l_header_rec.INVOICE_TO_ORG_ID   := l_bill_to_site_use_id;
    l_header_rec.SHIP_TO_ORG_ID  := l_ship_to_site_use_id;
    l_header_rec.INVOICE_TO_CONTACT_ID  := l_cust_account_role_id;
    l_header_rec.SOLD_TO_CONTACT_ID  := l_cust_account_role_id;
    IF (p_order_tbl(i).enrl_request_id is not null) THEN
       l_header_rec.order_source_id   	     := 23;
       l_header_rec.source_document_type_id  := 23;
       l_header_rec.source_document_id	     := p_order_tbl(i).enrl_request_id;
       l_header_rec.orig_sys_document_ref    := p_order_tbl(i).enrl_request_id;
    ELSIF (p_order_tbl(i).invite_header_id is not null) THEN
       l_header_rec.order_source_id   	     := 31 ;
       l_header_rec.source_document_type_id  := 31;
       l_header_rec.source_document_id	     := p_order_tbl(i).invite_header_id;
       l_header_rec.orig_sys_document_ref    := p_order_tbl(i).invite_header_id;
    END IF;


    l_header_out_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    /*l_header_out_rec.order_type_id := l_transaction_type_id;
    l_header_out_rec.freight_terms_code := NULL;
    l_header_out_rec.transactional_curr_code := P_currency_code;
    l_header_out_rec.sold_to_org_id := p_partner_account_id;
    l_header_out_rec.INVOICE_TO_ORG_ID   := l_bill_to_site_use_id;
    l_header_out_rec.SHIP_TO_ORG_ID  := l_ship_to_site_use_id;
    l_header_out_rec.INVOICE_TO_CONTACT_ID  := l_cust_account_role_id;
    l_header_out_rec.SOLD_TO_CONTACT_ID  := l_cust_account_role_id;
    l_header_out_rec.order_source_id   := 23;
    l_header_out_rec.salesrep_id := l_salesrep_id;*/


    IF(P_order_tbl(i).order_header_id=FND_API.G_MISS_NUM or P_order_tbl(i).order_header_id IS NULL) THEN

      l_header_rec.operation := OE_GLOBALS.G_OPR_CREATE;
      l_header_rec.order_type_id := l_transaction_type_id;
      l_header_rec.salesrep_id := l_salesrep_id;

      l_line_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_tbl(1).ordered_quantity  := 1;
      l_line_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
      l_line_tbl(1).inventory_item_id := P_order_tbl(i).inventory_item_id;


      --kvattiku: Aug 08, 05 NOCOPY bug related change
      /*l_header_out_rec.operation := OE_GLOBALS.G_OPR_CREATE;

      l_line_out_tbl(1) := OE_ORDER_PUB.G_MISS_LINE_REC;
      l_line_out_tbl(1).ordered_quantity  := 1;
      l_line_out_tbl(1).operation := OE_GLOBALS.G_OPR_CREATE;
      l_line_out_tbl(1).inventory_item_id := P_order_tbl(i).inventory_item_id;*/

    else
      l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
      l_header_rec.header_id := P_order_tbl(i).order_header_id;
      l_header_rec.pricing_date  := sysdate;
      l_header_rec.change_reason := 'SYSTEM';

      --kvattiku: Aug 08, 05 NOCOPY bug related change
      /*l_header_out_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
      l_header_out_rec.header_id := P_order_tbl(i).order_header_id;
      l_header_out_rec.pricing_date  := sysdate;
      l_header_out_rec.change_reason := 'SYSTEM';*/

    END IF;





IF (PV_DEBUG_HIGH_ON) THEN



PVX_UTILITY_PVT.debug_message('Just before order call');

END IF;

     --kvattiku: Aug 08, 05 Changed the x_line_tbl initialization to l_line_out_tbl and x_header_rec
     --to l_header_out_rec from l_line_tbl and l_header_rec respectively (NOCOPY bug)

     OE_ORDER_GRP.process_order(
         p_api_version_number => l_api_version_number,
         p_init_msg_list => FND_API.g_false  ,
         p_return_values => FND_API.g_true ,
         p_commit => FND_API.g_false ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_header_rec => l_header_rec,
         p_line_tbl => l_line_tbl,
         x_header_rec => l_header_out_rec,
         x_header_val_rec => x_header_val_rec,
         x_Header_Adj_tbl => x_Header_Adj_tbl  ,
         x_Header_Adj_val_tbl => x_Header_Adj_val_tbl,
         x_Header_price_Att_tbl => x_Header_price_Att_tbl,
         x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl,
         x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl,
         x_Header_Scredit_tbl => x_Header_Scredit_tbl,
         x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl,
         x_line_tbl => l_line_out_tbl,
         x_line_val_tbl => x_line_val_tbl ,
         x_Line_Adj_tbl => x_Line_Adj_tbl,
         x_Line_Adj_val_tbl => x_Line_Adj_val_tbl,
         x_Line_price_Att_tbl => x_Line_price_Att_tbl,
         x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl ,
         x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl,
         x_Line_Scredit_tbl => x_Line_Scredit_tbl,
         x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl,
         x_Lot_Serial_tbl => x_Lot_Serial_tbl ,
         x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl,
         x_action_request_tbl =>x_action_request_tbl
       );

  IF (PV_DEBUG_HIGH_ON) THEN
     PVX_UTILITY_PVT.debug_message('X_return_status ' || x_return_status);
     PVX_UTILITY_PVT.debug_message('X_msg_count ' || x_msg_count);
     PVX_UTILITY_PVT.debug_message('X_msg_data ' || x_msg_data);
   END IF;


   x_order_header_id.extend;

   --kvattiku: Aug 08, 05 NOCOPY bug related change
   --x_order_header_id(x_order_header_id.count) := l_header_rec.header_id;
   x_order_header_id(x_order_header_id.count) := l_header_out_rec.header_id;

   IF (PV_DEBUG_HIGH_ON) THEN

   PVX_UTILITY_PVT.debug_message('x_order_header_id :  '|| i|| ' : ' || x_order_header_id(x_order_header_id.count));
   END IF;
    Retrieve_OE_Messages;

    IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;


    END LOOP;

    FOR x in validate_price( x_order_header_id) LOOP
      fnd_message.SET_NAME  ('PV', 'PV_ERROR_IN_CALC_PRICE');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
    END LOOP;

     FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

      IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;



    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO PV_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO PV_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO PV_PROCESS_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


End process_order;




PROCEDURE process_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_party_site_id              IN   NUMBER
    ,p_partner_party_id           IN   NUMBER
    ,p_currency_code              IN   VARCHAR2
    ,p_contact_party_id           IN   NUMBER
    ,p_partner_account_id         IN   NUMBER
    ,p_enrl_req_id                IN   JTF_NUMBER_TABLE
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
 )
 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Process_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_index number := 0;
   l_order_header_id_tbl  JTF_NUMBER_TABLE;
   l_enrl_req_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_obj_ver_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_order_tbl Order_Tbl_type;
   l_enrl_req_rec   PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;

   -- Cursor to get partner program inventoty item id
   CURSOR c_inventory_item_id IS
     SELECT  /*+ CARDINALITY(erequests 10) */ pvpp.inventory_item_id, pver.enrl_request_id, pver.order_header_id, pver.object_version_number
     FROM PV_PARTNER_PROGRAM_B pvpp, PV_PG_ENRL_REQUESTS pver,
     (Select  column_value from table (CAST(p_enrl_req_id AS JTF_NUMBER_TABLE))) erequests
     WHERE pver.enrl_request_id = erequests.column_value
      and pver.PROGRAM_ID = pvpp.program_id
      and pver.custom_setup_id in (7004, 7005)
      and (pver.order_header_id is null
      OR  (pver.order_header_id is not null and pver.payment_status_code <> 'AUTHORIZED_PAYMENT'));



 BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT ENRQ_PROCESS_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF p_enrl_req_id.count()  = 0 THEN
      FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
      FND_MESSAGE.Set_Token('ID', 'Enrollment Request', FALSE);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;


     FOR x IN c_inventory_item_id LOOP
           -- Debug Message
          IF (x.order_header_id IS NOT NULL) THEN
	     l_order_tbl(l_index).order_header_id   := x.order_header_id;
	  ELSE
	     l_order_tbl(l_index).inventory_item_id := x.inventory_item_id;
	  END IF;
	  l_order_tbl(l_index).enrl_request_id := x.enrl_request_id;
	  l_enrl_req_id_tbl.extend;
	  l_obj_ver_tbl.extend;
	  l_enrl_req_id_tbl(l_enrl_req_id_tbl.count) := x.enrl_request_id;
	  l_obj_ver_tbl(l_obj_ver_tbl.count) := x.object_version_number;
	  l_index := l_index + 1;
     END loop;


     IF(l_order_tbl.count >0) THEN
      process_order(
        p_api_version_number       => p_api_version_number
       ,p_init_msg_list            => FND_API.g_false
       ,p_commit                   =>  FND_API.G_FALSE
       ,p_party_site_id            => p_party_site_id
       ,p_partner_party_id         => p_partner_party_id
       ,p_currency_code            => p_currency_code
       ,p_contact_party_id         => p_contact_party_id
       ,p_partner_account_id       => p_partner_account_id
       ,p_order_tbl                => l_order_tbl
       ,x_order_header_id          => l_order_header_id_tbl
       ,x_return_status            => x_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data
       );


       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;


       FOR i in l_order_header_id_tbl.FIRST ..l_order_header_id_tbl.LAST LOOP


            l_enrl_req_rec.object_version_number := l_obj_ver_tbl(i);
	    l_enrl_req_rec.enrl_request_id  := l_enrl_req_id_tbl(i);
	    l_enrl_req_rec.order_header_id := l_order_header_id_tbl(i);
	    l_enrl_req_rec.payment_status_code  := 'NOT_AUTHORIZED';


            PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests
	    (
               p_api_version_number        =>  p_api_version_number,
               p_init_msg_list             =>  Fnd_Api.G_FALSE,
               p_commit                    =>  Fnd_Api.G_FALSE,
               p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
               x_return_status             =>  x_return_status,
               x_msg_count                 =>  x_msg_count,
               x_msg_data                  =>  x_msg_data,
               p_enrl_request_rec          =>  l_enrl_req_rec
             );

	     IF x_return_status = FND_API.g_ret_sts_error THEN
                    RAISE FND_API.g_exc_error;
             ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                    RAISE FND_API.g_exc_unexpected_error;
             END IF;


       END LOOP;

     END IF;
      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
          p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
        );

       IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;


     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ENRQ_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ENRQ_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO ENRQ_PROCESS_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END process_order;



 PROCEDURE process_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_party_site_id              IN   NUMBER
    ,p_partner_party_id           IN   NUMBER
    ,p_currency_code              IN   VARCHAR2
    ,p_contact_party_id           IN   NUMBER
    ,p_partner_account_id         IN   NUMBER
    ,p_program_id                 IN   NUMBER
    ,p_invite_header_id		  IN   NUMBER
    ,x_order_header_id            OUT  NOCOPY  NUMBER
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
  )
 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Process_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_index number := 0;
   l_order_tbl Order_Tbl_type;
   l_order_header_id_tbl JTF_NUMBER_TABLE;
   l_inventory_item_id         NUMBER;
   l_invite_headers_rec	       PV_PG_INVITE_HEADERS_PVT.invite_headers_rec_type;

   -- Cursor to get partner program inventoty item id
   CURSOR c_inventory_item_id(cv_program_id NUMBER) IS
      SELECT pvpp.inventory_item_id
      FROM PV_PARTNER_PROGRAM_B pvpp
      WHERE program_id = cv_program_id;


 BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT PRGM_PROCESS_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_program_id = FND_API.G_MISS_NUM) THEN
      FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
      FND_MESSAGE.Set_Token('ID', 'Program', FALSE);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;


     OPEN c_inventory_item_id(p_program_id);
     FETCH c_inventory_item_id into l_inventory_item_id;
     IF c_inventory_item_id%FOUND THEN
          l_order_tbl(0).inventory_item_id := l_inventory_item_id;
     END IF;
     CLOSE c_inventory_item_id;

     IF(l_order_tbl.count >0) THEN
      l_order_tbl(0).invite_header_id := p_invite_header_id;
      process_order(
        p_api_version_number       => p_api_version_number
       ,p_init_msg_list            => FND_API.g_false
       ,p_commit                   =>  FND_API.G_FALSE
       ,p_party_site_id            => p_party_site_id
       ,p_partner_party_id         => p_partner_party_id
       ,p_currency_code            => p_currency_code
       ,p_contact_party_id         => p_contact_party_id
       ,p_partner_account_id       => p_partner_account_id
       ,p_order_tbl                => l_order_tbl
       ,x_order_header_id          => l_order_header_id_tbl
       ,x_return_status            => x_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data
       );

       x_order_header_id := l_order_header_id_tbl(l_order_header_id_tbl.FIRST);

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
       END IF;

       l_invite_headers_rec.invite_header_id := p_invite_header_id;
       l_invite_headers_rec.order_header_id  := x_order_header_id;
       l_invite_headers_rec.object_version_number := 1;

       PV_PG_INVITE_HEADERS_PVT.update_invite_headers
       (
               p_api_version_number        =>  p_api_version_number,
               p_init_msg_list             =>  Fnd_Api.G_FALSE,
               p_commit                    =>  Fnd_Api.G_FALSE,
               p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
               x_return_status             =>  x_return_status,
               x_msg_count                 =>  x_msg_count,
               x_msg_data                  =>  x_msg_data,
               p_invite_headers_rec          =>  l_invite_headers_rec
       );

       IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
       ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
       END IF;

     END IF;

      FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
          p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
        );

       IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;


     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO PRGM_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO PRGM_PROCESS_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO PRGM_PROCESS_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END process_order;






PROCEDURE book_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_order_header_id            IN   NUMBER
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Book_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_action_request_tbl        OE_ORDER_PUB.Request_Tbl_Type;


   x_header_rec                      OE_ORDER_PUB.Header_Rec_Type;
   x_header_val_rec                     OE_ORDER_PUB.Header_Val_Rec_Type;
   x_Header_Adj_tbl                  OE_ORDER_PUB. Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl              OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl            OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl              OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl            OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl              OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl          OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                       OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl                    OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl                   OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl               OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl             OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl                OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl             OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl               OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl           OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl                 OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl             OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	            OE_ORDER_PUB.Request_Tbl_Type;


 BEGIN


     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT BOOK_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------

     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     IF p_order_header_id IS NULL or p_order_header_id = FND_API.g_miss_num then
         FND_MESSAGE.set_name('PV', 'PV_API_NO_ORDER_HEADER_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      Order_Debug_On;

   set_mo_policy_context (p_order_header_id);

   l_action_request_tbl(1) := oe_order_pub.G_MISS_REQUEST_REC;
   l_action_request_tbl(1).Entity_code :=  OE_GLOBALS.G_ENTITY_HEADER;
   l_action_request_tbl(1).Entity_id   :=  p_order_header_id;
   l_action_request_tbl(1).request_type := OE_GLOBALS.G_BOOK_ORDER;

   OE_ORDER_GRP.process_order(
         p_api_version_number => l_api_version_number,
         p_init_msg_list => FND_API.g_false  ,
         p_return_values => FND_API.g_true ,
         p_commit => FND_API.g_false ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_action_request_tbl => l_action_request_tbl,
         x_header_rec => x_header_rec,
         x_header_val_rec => x_header_val_rec,
         x_Header_Adj_tbl => x_Header_Adj_tbl  ,
         x_Header_Adj_val_tbl => x_Header_Adj_val_tbl,
         x_Header_price_Att_tbl => x_Header_price_Att_tbl,
         x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl,
         x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl,
         x_Header_Scredit_tbl => x_Header_Scredit_tbl,
         x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl,
         x_line_tbl => x_line_tbl,
         x_line_val_tbl => x_line_val_tbl ,
         x_Line_Adj_tbl => x_Line_Adj_tbl,
         x_Line_Adj_val_tbl => x_Line_Adj_val_tbl,
         x_Line_price_Att_tbl => x_Line_price_Att_tbl,
         x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl ,
         x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl,
         x_Line_Scredit_tbl => x_Line_Scredit_tbl,
         x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl,
         x_Lot_Serial_tbl => x_Lot_Serial_tbl ,
         x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl,
         x_action_request_tbl =>x_action_request_tbl
       );

     IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message('process_order :: x_return_status : ' || x_return_status);
        PVX_UTILITY_PVT.debug_message('process_order :: x_msg_data : ' || x_msg_data);
        PVX_UTILITY_PVT.debug_message('process_order :: x_msg_count : ' || x_msg_count);
        PVX_UTILITY_PVT.debug_message('process_order :: x_action_request_tbl.COUNT : ' || x_action_request_tbl.COUNT);
     END IF;

     Retrieve_OE_Messages;

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
        FOR i in 1..x_action_request_tbl.COUNT LOOP
           PVX_UTILITY_PVT.debug_message('process_order :: x_action_request_tbl(i).return_status : ' || x_action_request_tbl(i).return_status);
           IF x_action_request_tbl(i).return_status = FND_API.G_RET_STS_ERROR THEN
               PVX_UTILITY_PVT.debug_message('x_action_request_tbl.return_status is ' || x_action_request_tbl(i).return_status);
               RAISE FND_API.g_exc_error;
           ELSIF x_action_request_tbl(i).return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               PVX_UTILITY_PVT.debug_message('x_action_request_tbl.return_status is ' || x_action_request_tbl(i).return_status);
               RAISE FND_API.g_exc_error;
           END IF;
        END LOOP;
     END IF;

     FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE ,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO BOOK_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO BOOK_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO BOOK_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

 End book_order;


 PROCEDURE cancel_order(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_order_header_id            IN   NUMBER
    ,p_set_moac_context           IN   VARCHAR2 := 'Y'
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
    )
  IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Cancel_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_header_rec                OE_ORDER_PUB.Header_Rec_Type;
   --kvattiku: Aug 08, 05 NOCOPY bug related change
   l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
   l_change_reason             VARCHAR2(30);

   x_header_val_rec                  OE_ORDER_PUB.Header_Val_Rec_Type;
   x_Header_Adj_tbl                  OE_ORDER_PUB. Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl              OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl            OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl              OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl            OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl              OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl          OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                       OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl                    OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl                   OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl               OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl             OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl                OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl             OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Scredit_tbl               OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl           OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl                 OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl             OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	            OE_ORDER_PUB.Request_Tbl_Type;



 BEGIN


     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT cancel_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------

     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     IF p_order_header_id IS NULL or p_order_header_id = FND_API.g_miss_num then
         FND_MESSAGE.set_name('PV', 'PV_API_NO_ORDER_HEADER_ID');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

    l_change_reason := FND_PROFILE.Value('PV_ORDER_CANCEL_REASON');
    IF  l_change_reason is null then
        x_return_status := FND_API.G_RET_STS_ERROR;
           FND_MESSAGE.Set_Name('PV', 'PV_NO_ORDER_CANCEL_REASON');
           FND_MSG_PUB.ADD;
       RAISE FND_API.G_EXC_ERROR;
    END IF;


    Order_Debug_On;

    set_mo_policy_context (p_order_header_id);

    l_header_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    l_header_rec.header_id := p_order_header_id;
    l_header_rec.cancelled_flag := 'Y';
    l_header_rec.change_reason  := l_change_reason;

    --kvattiku: Aug 08, 05 NOCOPY bug related change
    /*l_header_out_rec := OE_ORDER_PUB.G_MISS_HEADER_REC;
    l_header_out_rec.operation := OE_GLOBALS.G_OPR_UPDATE;
    l_header_out_rec.header_id := p_order_header_id;
    l_header_out_rec.cancelled_flag := 'Y';
    l_header_out_rec.change_reason  := l_change_reason;*/

     --kvattiku: Aug 08, 05 NOCOPY bug related change
     OE_ORDER_GRP.process_order(
         p_api_version_number => l_api_version_number,
         p_init_msg_list => FND_API.g_false  ,
         p_return_values => FND_API.g_true ,
         p_commit => FND_API.g_false ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_header_rec => l_header_rec,
         x_header_rec => l_header_out_rec,
         x_header_val_rec => x_header_Val_Rec,
         x_Header_Adj_tbl => x_Header_Adj_tbl  ,
         x_Header_Adj_val_tbl => x_Header_Adj_val_tbl,
         x_Header_price_Att_tbl => x_Header_price_Att_tbl,
         x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl,
         x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl,
         x_Header_Scredit_tbl => x_Header_Scredit_tbl,
         x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl,
         x_line_tbl => x_line_tbl,
         x_line_val_tbl => x_line_val_tbl ,
         x_Line_Adj_tbl => x_Line_Adj_tbl,
         x_Line_Adj_val_tbl => x_Line_Adj_val_tbl,
         x_Line_price_Att_tbl => x_Line_price_Att_tbl,
         x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl ,
         x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl,
         x_Line_Scredit_tbl => x_Line_Scredit_tbl,
         x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl,
         x_Lot_Serial_tbl => x_Lot_Serial_tbl ,
         x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl,
         x_action_request_tbl =>x_action_request_tbl
       );

     IF (PV_DEBUG_HIGH_ON) THEN
        PVX_UTILITY_PVT.debug_message('process_order :: x_return_status : ' || x_return_status);
        PVX_UTILITY_PVT.debug_message('process_order :: x_msg_data : ' || x_msg_data);
        PVX_UTILITY_PVT.debug_message('process_order ::  x_msg_count : ' || x_msg_count);
     END IF;

    	Retrieve_OE_Messages;

   IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
    ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;


     FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO cancel_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO cancel_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO cancel_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );
 End cancel_order;



 PROCEDURE cancel_order(
    p_api_version_number          IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_enrl_req_id                IN   JTF_NUMBER_TABLE
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
  )
  IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Cancel_order';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   -- Cursor to get order_header_id
   CURSOR c_order_header_id IS
      SELECT /*+ CARDINALITY(t 10) */ pver.order_header_id
      FROM  PV_PG_ENRL_REQUESTS pver,
	    (Select  * from table (CAST(p_enrl_req_id AS JTF_NUMBER_TABLE))) t
      WHERE pver.enrl_request_id = t.column_value
      and pver.order_header_id is not null
      and pver.payment_status_code <> 'AUTHORIZED_PAYMENT';


 BEGIN


     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT ENRQ_cancel_ORDER;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------
     FOR x in c_order_header_id loop
      cancel_order
      ( p_api_version_number         => p_api_version_number
       ,p_init_msg_list              => FND_API.g_false
       ,p_commit                     => p_commit
       ,p_order_header_id            => x.order_header_id
       ,p_set_moac_context           => 'N'
       ,x_return_status              => x_return_status
       ,x_msg_count                  => x_msg_count
       ,x_msg_data                   => x_msg_data
      );

      IF x_return_status = FND_API.g_ret_sts_error THEN
       RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
       RAISE FND_API.g_exc_unexpected_error;
      END IF;

     END LOOP;

     FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO ENRQ_cancel_ORDER;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO ENRQ_cancel_ORDER;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO ENRQ_cancel_ORDER;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );
 End cancel_order;

/* R12 Changes
 * New function that will return 'Y' or 'N' for whether
 * certain credit card attributes are required
 * If p_attribute = CVV2, then it will look at CVV2 code
 * if p_attribute = STMT, then it will look at card statement address
 */
 FUNCTION get_cc_requirements(
    p_attribute 	          IN  VARCHAR2
    ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(100);
    l_msg_count		NUMBER;
    l_msg_data		VARCHAR2(200);
    l_payment_attribs   IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
    l_response		IBY_FNDCPT_COMMON_PUB.Result_rec_type;
 BEGIN

    IF ((p_attribute <> 'CVV2') and (p_attribute <> 'STMT')) THEN
      RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IBY_FNDCPT_SETUP_PUB.get_payment_channel_attribs
    (
	p_api_version		=> 1.0,
	p_init_msg_list		=> FND_API.G_FALSE,
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	p_channel_code		=> 'CREDIT_CARD',
	x_channel_attrib_uses	=> l_payment_attribs,
	x_response		=> l_response
    );
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       IF (l_response.result_code = 'INVALID_PMT_CHANNEL') THEN
          RAISE FND_API.G_EXC_ERROR;
       ELSE
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;
    END IF;

    IF (p_attribute = 'CVV2') THEN
       IF (l_payment_attribs.Instr_SecCode_Use = 'REQUIRED') THEN
          RETURN 'Y';
       ELSE
	  RETURN 'N';
       END IF;
    ELSIF (p_attribute = 'STMT') THEN
       IF (l_payment_attribs.Instr_Billing_Address = 'REQUIRED') THEN
          RETURN 'Y';
       ELSE
	  RETURN 'N';
       END IF;
    END IF;
  END get_cc_requirements;

  FUNCTION get_party_site_id(
      			     p_contact_party_id IN   NUMBER
     			    ,p_location_id      IN   NUMBER
                            ) RETURN NUMBER
  IS

    x_party_site_id NUMBER;

  BEGIN

    select party_site_id
    into   x_party_site_id
    from   hz_party_sites
    where  party_id = p_contact_party_id
    and    location_id = p_location_id
    and    status = 'A';

    return x_party_site_id;

    EXCEPTION
       WHEN NO_DATA_FOUND THEN
          return null;

  END get_party_site_id;


  PROCEDURE set_payment_info(
     p_api_version_number         IN  NUMBER
    ,p_init_msg_list              IN  VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN  VARCHAR2           := FND_API.G_FALSE
    ,p_contact_party_id		  IN  NUMBER
    ,p_payment_method_rec         IN  Payment_method_Rec_type
    ,p_order_header_id            IN  Payment_info_Tbl_type
    ,p_enrollment_flow	          IN  VARCHAR2
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,x_is_authorized              OUT NOCOPY  VARCHAR2
    ,x_enrl_info		  OUT NOCOPY  Payment_info_Tbl_type
   )
    IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'set_payment_info';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   --dgottlie: Process new credit card and create transaction extension variables
   l_party_type		       VARCHAR2(30);
   l_location_id	       NUMBER;
   l_party_site_rec            HZ_PARTY_SITE_V2PUB.Party_Site_Rec_Type;
   l_party_site_use_rec        HZ_PARTY_SITE_V2PUB.Party_Site_Use_Rec_Type;
   l_party_site_id	       NUMBER;
   l_party_site_number	       NUMBER;
   l_count		       NUMBER;
   l_cc_exp_date	       DATE;
   l_skip_auth		       VARCHAR2(1);
    lx_response		       IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_payer		       IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type;
   l_payee		       IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
   l_trxn_attribs	       IBY_FNDCPT_TRXN_PUB.trxnExtension_rec_type;
   l_amount		       IBY_FNDCPT_TRXN_PUB.amount_rec_type;
   l_auth_attribs	       IBY_FNDCPT_TRXN_PUB.authattribs_rec_type;
   l_auth_result	       IBY_FNDCPT_TRXN_PUB.authresult_rec_type;
   l_payment_attribs	       IBY_FNDCPT_SETUP_PUB.PmtChannel_AttribUses_rec_type;
   l_card_instrument	       IBY_FNDCPT_SETUP_PUB.CreditCard_Rec_type;
   l_PmtInstrument	       IBY_FNDCPT_SETUP_PUB.PmtInstrument_rec_type;
   l_assignment_attr	       IBY_FNDCPT_SETUP_PUB.PmtInstrAssignment_rec_type;
   lx_instr_assign_id	       NUMBER;
   lx_trxn_extension_id	       NUMBER;
   l_is_authorized	       VARCHAR2(1);

   l_order_header_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   cursor c_get_payment_amount(cv_order_header_id_tbl JTF_NUMBER_TABLE) IS
    SELECT /*+ cardinality( T 10 ) */ ((oeol.unit_selling_price*oeol.ordered_quantity)+nvl(oeol.tax_value,0)) payment_amount, oeoh.transactional_curr_code currency,
           oeoh.header_id
    FROM  oe_order_headers_all oeoh, oe_order_Lines_all oeol,
    (SELECT * FROM TABLE (CAST(cv_order_header_id_tbl AS JTF_NUMBER_TABLE))) T
    WHERE oeoh.header_id = T.column_value
    AND oeoh.header_id = oeol.header_id;

 BEGIN


     ---------------Initialize --------------------
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      -- Initialize local authorization to successful as well as authorization and skip to No
      l_is_authorized := 'Y';
      x_is_authorized := 'N';
      l_skip_auth     := 'N';
  -------------End Of Initialize -------------------------------



     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     IF p_order_header_id.count()  = 0 THEN
      FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
      FND_MESSAGE.Set_Token('ID', 'Order Details', FALSE);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     for i in p_order_header_id.FIRST..p_order_header_id.LAST loop
      IF (p_order_header_id(i).order_header_id IS NULL or p_order_header_id(i).order_header_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
          FND_MESSAGE.Set_Token('ID', 'Order Details', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
       l_order_header_id_tbl.extend;
       l_order_header_id_tbl(l_order_header_id_tbl.count) := p_order_header_id(i).order_header_id;
       --dgottlie: set local collection of enrollment info to deal with trxn extension ids
       --          the loop variable i is really the order header id used to populate the record
       x_enrl_info(i).order_header_id       := p_order_header_id(i).order_header_id;
       IF (p_enrollment_flow = 'Y') THEN
          x_enrl_info(i).enrl_req_id        := p_order_header_id(i).enrl_req_id;
       ELSE
          x_enrl_info(i).invite_header_id   := p_order_header_id(i).invite_header_id;
       END IF;
       x_enrl_info(i).trxn_extension_id     := p_order_header_id(i).trxn_extension_id;
       x_enrl_info(i).object_version_number := p_order_header_id(i).object_version_number;
     END LOOP;


     IF (p_payment_method_rec.payment_type_code = FND_API.G_MISS_CHAR or p_payment_method_rec.payment_type_code IS NULL) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_PAYMENT_TYPE');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Payment Type : ' || p_payment_method_rec.payment_type_code );
       END IF;




     IF (p_payment_method_rec.payment_type_code = 'CHECK') THEN
       IF (p_payment_method_rec.check_number = FND_API.G_MISS_CHAR or p_payment_method_rec.check_number IS NULL) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_NO_CHECK_NUMBER');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

     ELSIF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN
      /* R12 Changes
       * Adding check to see if statement address and security code are supplied if they are required
       * Only running validations for everything except security code if the inst_assignment_id is null
       * meaning we're dealing with a new credit card
       * Adding code to process new credit cards
       */
       IBY_FNDCPT_SETUP_PUB.get_payment_channel_attribs
       (
	p_api_version		=> p_api_version_number,
	p_init_msg_list		=> FND_API.G_FALSE,
	x_return_status		=> x_return_status,
	x_msg_count		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	p_channel_code		=> 'CREDIT_CARD',
	x_channel_attrib_uses	=> l_payment_attribs,
	x_response		=> lx_response
       );

       IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          IF (lx_response.result_code = 'INVALID_PMT_CHANNEL') THEN
	     FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
             FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
	     FND_MSG_PUB.add;
	     RAISE FND_API.G_EXC_ERROR;
          ELSE
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
       END IF;


       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after call to get_payment_channel_attribs');
       END IF;

        -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' CVV2 : ' || l_payment_attribs.Instr_SecCode_Use);
       END IF;




       IF (l_payment_attribs.Instr_SecCode_Use = 'REQUIRED') THEN
          IF (p_payment_method_rec.instrument_security_code = FND_API.G_MISS_NUM or p_payment_method_rec.instrument_security_code IS NULL) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_CVV2_CODE');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

       IF (p_enrollment_flow IS NULL or (p_enrollment_flow not in ('Y' , 'N'))) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
          FND_MESSAGE.Set_Token('ID', 'Authorization', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
       END IF;

       IF (p_payment_method_rec.instr_assignment_id IS NULL) THEN

	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Entered the instr_assignment_id is NULL block');
	  END IF;


          IF (p_payment_method_rec.credit_card_holder_name = FND_API.G_MISS_CHAR or p_payment_method_rec.credit_card_holder_name IS NULL) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_HOLDER_NAME');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_payment_method_rec.credit_card_number = FND_API.G_MISS_CHAR or p_payment_method_rec.credit_card_number IS NULL) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_NUMBER');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_payment_method_rec.credit_card_code = FND_API.G_MISS_CHAR or p_payment_method_rec.credit_card_code is null) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_TYPE');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          /* No Expiration Date in R12, instead it is passed as month and year and the date is then derived */
          IF (p_payment_method_rec.credit_card_exp_month = FND_API.G_MISS_NUM or p_payment_method_rec.credit_card_exp_month IS NULL) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_EXP_DATE');
             FND_MESSAGE.set_token('DPART', 'month');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF (p_payment_method_rec.credit_card_exp_year = FND_API.G_MISS_NUM or p_payment_method_rec.credit_card_exp_year IS NULL) THEN
             FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_EXP_DATE');
             FND_MESSAGE.set_token('DPART', 'year');
             FND_MSG_PUB.add;
             RAISE FND_API.G_EXC_ERROR;
          END IF;

	  --kvattiku Aug 14, 05
	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Billing Address : ' || l_payment_attribs.Instr_Billing_Address);
	  END IF;

	  IF (l_payment_attribs.Instr_Billing_Address = 'REQUIRED') THEN
	     IF (p_payment_method_rec.cc_stmt_party_site_id = FND_API.G_MISS_NUM or p_payment_method_rec.cc_stmt_party_site_id IS NULL) THEN
                FND_MESSAGE.set_name('PV', 'PV_API_NO_CC_STMT_ADDR');
                FND_MSG_PUB.add;
		RAISE FND_API.G_EXC_ERROR;
	     END IF;

	     IF (PV_DEBUG_HIGH_ON) THEN
	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' party site id = ' || p_payment_method_rec.cc_stmt_party_site_id);
	     END IF;

	     select hzp.party_type,
		    hzs.location_id
	     into   l_party_type,
                    l_location_id
             from   hz_parties         hzp,
	            hz_party_sites     hzs
	     where  hzs.party_site_id = p_payment_method_rec.cc_stmt_party_site_id
             and    hzp.party_id = hzs.party_id;

	     IF (PV_DEBUG_HIGH_ON) THEN
		PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' contact party id = ' || p_contact_party_id);
		PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' party type = ' || l_party_type);
		PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' location id = ' || l_location_id);
	     END IF;

	     IF (l_party_type = 'ORGANIZATION') THEN

		l_party_site_id := get_party_site_id(
						     p_contact_party_id => p_contact_party_id,
						     p_location_id      => l_location_id
						    );

  	        IF (PV_DEBUG_HIGH_ON) THEN
		   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Contact''s party site id = ' || l_party_site_id);
 		END IF;

		IF (l_party_site_id IS NULL) THEN
		   l_party_site_rec.party_id    := p_contact_party_id;
                   l_party_site_rec.location_id := l_location_id;
                   l_party_site_rec.identifying_address_flag := 'N';
		   l_party_site_rec.created_by_module := 'PV';

  	           IF (PV_DEBUG_HIGH_ON) THEN
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Before HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_rec.party_id =  ' ||
						    p_contact_party_id);
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Before HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_rec.location_id =  ' ||
						    l_location_id);
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Before HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_rec.identifying_address_flag =  ' ||
						    'N');
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Before HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_rec.created_by_module = ' ||
						    'PV');
 		   END IF;

                   HZ_PARTY_SITE_V2PUB.create_party_site (
                      p_init_msg_list                 => FND_API.G_FALSE,
       		      p_party_site_rec                => l_party_site_rec,
	              x_party_site_id                 => l_party_site_id,
       	 	      x_party_site_number             => l_party_site_number,
                      x_return_status                 => x_return_status,
                      x_msg_count                     => x_msg_count,
                      x_msg_data                      => x_msg_data );
		   IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;

		   IF (PV_DEBUG_HIGH_ON) THEN
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' After HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_id = ' || l_party_site_id);
		      PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' After HZ_PARTY_SITE_V2PUB.create_party_site l_party_site_number = ' || l_party_site_number);
		   END IF;

	        END IF;
             ELSE
                l_party_site_id := p_payment_method_rec.cc_stmt_party_site_id;
             END IF;
          ELSE
             l_party_site_id := null;
	  END IF;


          	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || '  l_party_site_id :  ' ||  l_party_site_id);
	  END IF;


	  /* Create Card and get Intrument Assignment ID*/
	  IF (p_payment_method_rec.credit_card_exp_month = 12) THEN
	     l_cc_exp_date := to_date('01/'||(p_payment_method_rec.credit_card_exp_year+1),'MM/YYYY') - 1;
	  ELSE
             l_cc_exp_date := to_date((p_payment_method_rec.credit_card_exp_month + 1)||'/'||p_payment_method_rec.credit_card_exp_year,'MM/YYYY') - 1;
	  END IF;
	  l_card_instrument.card_id		:= NULL;
	  l_card_instrument.owner_id		:= p_contact_party_id;
	  l_card_instrument.billing_address_id  := l_party_site_id;
	  l_card_instrument.card_number		:= p_payment_method_rec.credit_card_number;
	  l_card_instrument.expiration_date	:= l_cc_exp_date;
	  l_card_instrument.instrument_type	:= 'CREDITCARD';
 	  l_card_instrument.card_issuer		:= p_payment_method_rec.credit_card_code;
	  l_card_instrument.card_holder_name	:= p_payment_method_rec.credit_card_holder_name;
	  l_payer.Payment_Function		:= 'CUSTOMER_PAYMENT';
	  l_payer.Party_Id			:= p_contact_party_id;
	  l_PmtInstrument.Instrument_Type	:= 'CREDITCARD';
	  l_PmtInstrument.Instrument_Id		:= NULL;
	  l_assignment_attr.Assignment_Id	:= NULL;
	  l_assignment_attr.Instrument		:= l_PmtInstrument;
	  l_assignment_attr.Start_Date		:= sysdate;



	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the IBY_FNDCPT_SETUP_PUB.process_credit_card call');
	  END IF;


	  IBY_FNDCPT_SETUP_PUB.process_credit_card
 	  (
	   p_api_version => 1.0,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_commit => FND_API.G_FALSE,
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data,
	   p_payer => l_payer,
	   p_credit_card => l_card_instrument,
	   p_assignment_attribs => l_assignment_attr,
	   x_assign_id => lx_instr_assign_id,
	   x_response => lx_response
 	  );

	 -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_return_status from IBY_FNDCPT_SETUP_PUB.process_credit_card call: ' || x_return_status);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_count from IBY_FNDCPT_SETUP_PUB.process_credit_card call: ' || x_msg_count);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_data from IBY_FNDCPT_SETUP_PUB.process_credit_card call: ' || x_msg_data);
	  END IF;



	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
	     IF (lx_response.Result_Category = 'INVALID PARAM') THEN
	        FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
                FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
	        FND_MSG_PUB.add;
	        RAISE FND_API.G_EXC_ERROR;
	     ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
	  END IF;

	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
   	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after the IBY_FNDCPT_SETUP_PUB.process_credit_card call');
	  END IF;

       ELSE
          lx_instr_assign_id := p_payment_method_rec.instr_assignment_id;
       END IF; --inst_assignment_id is null
     END IF; -- p_payment_method_rec.payment_type_code = 'CHECK' or 'CREDIT_CARD'

     IF (PV_DEBUG_HIGH_ON) THEN
   	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' lx_instr_assign_id ' || lx_instr_assign_id);
     END IF;


     FOR x in c_get_payment_amount(l_order_header_id_tbl) loop

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' Entered the c_get_payment_amount for loop');
     END IF;

     x_enrl_info(x.header_id).payment_amount := x.payment_amount;
     x_enrl_info(x.header_id).currency       := x.currency;

     --dgottlie: If the payment is anything but credit card and the transaction extension id exists, then delete the extension
     IF ((p_payment_method_rec.payment_type_code <> 'CREDIT_CARD') and (x_enrl_info(x.header_id).trxn_extension_id IS NOT NULL) and
         (p_enrollment_flow = 'Y')) THEN
        -- Debug Message
        IF (PV_DEBUG_HIGH_ON) THEN
    	   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension call');
	   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' p_contact_party_id ' || p_contact_party_id);
	   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).trxn_extension_id ' || x_enrl_info(x.header_id).trxn_extension_id);
        END IF;

        l_payer.party_id := p_contact_party_id;

	IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension
        (
           p_api_version => 1.0,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_commit => FND_API.G_FALSE,
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data,
	   p_payer => l_payer,
	   p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
           p_entity_id => x_enrl_info(x.header_id).trxn_extension_id,
           x_response => lx_response
        );

	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_return_status from IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension : ' || x_return_status);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_count from IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension : ' || x_msg_count);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_data from IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension : ' || x_msg_data);
	  END IF;

 	IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
           IF ((lx_response.Result_Category = 'INVALID_PARAM') or (lx_response.Result_Category = 'INCORRECT_FLOW')) THEN
	      FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
              FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
	      FND_MSG_PUB.add;
	      RAISE FND_API.G_EXC_ERROR;
           ELSE
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
           END IF;
        END IF;

	x_enrl_info(x.header_id).trxn_extension_id := null;

        -- Debug Message
        IF (PV_DEBUG_HIGH_ON) THEN
    	   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after the IBY_FNDCPT_TRXN_PUB.Delete_Transaction_Extension call');
	   PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).trxn_extension_id ' || x_enrl_info(x.header_id).trxn_extension_id);
        END IF;

     ELSIF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN

       /* R12 Changes
	* Creating or Updating transaction extension id
        * First step is to test if the transaction extension id exists
	* If not, go ahead and create one, otherwise just update it
        */

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
	  PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the IF (x_enrl_info(x.header_id).trxn_extension_id IS NULL)');
	  PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id.trxn_extension_id ' || x_enrl_info(x.header_id).trxn_extension_id);
	  PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).order_header_id ' || x_enrl_info(x.header_id).order_header_id);
          IF (p_enrollment_flow = 'Y') THEN
  	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).enrl_req_id ' || x_enrl_info(x.header_id).enrl_req_id);
          ELSE
             PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).invite_header_id ' || x_enrl_info(x.header_id).invite_header_id);
	  END IF;
       END IF;

       l_trxn_attribs.instrument_security_code := p_payment_method_rec.instrument_security_code;
       l_trxn_attribs.originating_application_id := 691;
       IF (p_enrollment_flow = 'Y') THEN
          l_trxn_attribs.order_id := x_enrl_info(x.header_id).enrl_req_id; --wait for geetha
       ELSE
          l_trxn_attribs.order_id := x_enrl_info(x.header_id).invite_header_id; --wait for geetha
       END IF;
       l_trxn_attribs.trxn_ref_number1 := null; --wait for geetha

       l_payer.Payment_Function := 'CUSTOMER_PAYMENT';
       l_payer.Party_Id := p_contact_party_id;


       IF (x_enrl_info(x.header_id).trxn_extension_id IS NULL) THEN
	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
    	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension call');
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' p_payment_method_rec.instrument_security_code ' || p_payment_method_rec.instrument_security_code);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' p_contact_party_id ' || p_contact_party_id);
             IF (p_enrollment_flow = 'Y') THEN
  	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).enrl_req_id ' || x_enrl_info(x.header_id).enrl_req_id);
             ELSE
                PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_enrl_info(x.header_id).invite_header_id ' || x_enrl_info(x.header_id).invite_header_id);
	     END IF;
	  END IF;

	  IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension
 	  (
	   p_api_version => 1.0,
	   p_init_msg_list => FND_API.G_FALSE,
	   p_commit => FND_API.G_FALSE,
	   x_return_status => x_return_status,
	   x_msg_count => x_msg_count,
	   x_msg_data => x_msg_data,
	   p_payer => l_payer,
	   p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
           p_pmt_channel => 'CREDIT_CARD',
           p_instr_assignment => lx_instr_assign_id,
	   p_trxn_attribs => l_trxn_attribs,
           x_entity_id => lx_trxn_extension_id,
           x_response => lx_response
          );

	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_return_status from IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension : ' || x_return_status);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_count from IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension : ' || x_msg_count);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_data from IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension : ' || x_msg_data);
	  END IF;

	  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             IF (lx_response.Result_Category = 'INVALID_PARAM') THEN
	        FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
                FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
	        FND_MSG_PUB.add;
                RAISE FND_API.G_EXC_ERROR;
             ELSE
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             END IF;
          END IF;

	  x_enrl_info(x.header_id).trxn_extension_id := lx_trxn_extension_id;

	  -- Debug Message
 	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after the IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension call');
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' lx_trxn_extension_id ' || lx_trxn_extension_id);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' lx_instr_assign_id ' || lx_instr_assign_id);
	  END IF;

       ELSE
	  lx_trxn_extension_id := x_enrl_info(x.header_id).trxn_extension_id;

          -- Debug Message
          IF (PV_DEBUG_HIGH_ON) THEN
             PVX_UTILITY_PVT.debug_message('Checking if credit card is the same and has already been authorized');
          END IF;

          IF (l_skip_auth = 'N') THEN
             select nvl(authorized_flag,'N')
             into   l_skip_auth
             from   iby_trxn_extensions_v
             where  trxn_extension_id = lx_trxn_extension_id;
          END IF;

	  -- Debug Message
	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension call');
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' instrument assignment id = ' || lx_instr_assign_id);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' skip authorization flag = ' || l_skip_auth);
	  END IF;


	  -- Only update transaction extension if successful authorization hasn't already happened (online or offline)
	  IF (l_skip_auth = 'N') THEN

             IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension
             (
              p_api_version => 1.0,
	      p_init_msg_list => FND_API.G_FALSE,
	      p_commit => FND_API.G_FALSE,
	      x_return_status => x_return_status,
	      x_msg_count => x_msg_count,
	      x_msg_data => x_msg_data,
	      p_payer => l_payer,
	      p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
              p_pmt_channel => 'CREDIT_CARD',
              p_instr_assignment => lx_instr_assign_id,
	      p_trxn_attribs => l_trxn_attribs,
              p_entity_id => lx_trxn_extension_id,
              x_response => lx_response
             );

	     IF (PV_DEBUG_HIGH_ON) THEN
	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_return_status from IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension : ' || x_return_status);
	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_count from IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension : ' || x_msg_count);
	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_data from IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension : ' || x_msg_data);
	     END IF;

             IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
 	        IF ((lx_response.Result_Category = 'INVALID_PARAM') or (lx_response.Result_Category = 'INCORRECT_FLOW')) THEN
	           FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
                   FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
	           FND_MSG_PUB.add;
                   RAISE FND_API.G_EXC_ERROR;
                ELSE
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;
             END IF;

	     -- Debug Message
	     IF (PV_DEBUG_HIGH_ON) THEN
	        PVX_UTILITY_PVT.debug_message('In ' || l_api_name ||  ' after the IBY_FNDCPT_TRXN_PUB.Update_Transaction_Extension call');
  	     END IF;
	  END IF;

       END IF; -- x_enrl_info(x.header_id).trxn_extension_id IS NULL

       /* R12 Changes
	* Removing call to authorize payment procedure and instead
        * just call the Oracle Payments procedure directly
	* Also, we will commit all our work right before the call to create_authorization
        */
       commit;

       IF ((p_enrollment_flow = 'Y') and (l_is_authorized = 'Y') and (l_skip_auth = 'N'))  THEN
          l_payer.payment_function := 'CUSTOMER_PAYMENT';
          l_payer.party_id := p_contact_party_id;
	  l_payee.Org_Type := 'OPERATING_UNIT';
          l_payee.Org_Id   := MO_GLOBAL.get_current_org_id;
          l_amount.value := x.payment_amount;
          l_amount.currency_code := x.currency;
	  l_auth_attribs.RiskEval_Enable_Flag := 'N';

          -- Debug Message
          IF (PV_DEBUG_HIGH_ON) THEN
             PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before IBY_FNDCPT_TRXN_PUB.Create_Authorization');
             PVX_UTILITY_PVT.debug_message('Payee ID (Org ID): ' || l_payee.Org_id);
          END IF;

	  IBY_FNDCPT_TRXN_PUB.CREATE_AUTHORIZATION
          (
           p_api_version => 1.0,
           x_return_status => x_return_status,
           x_msg_count => x_msg_count,
           x_msg_data => x_msg_data,
           p_payer => l_payer,
           p_payee => l_payee,
           p_payer_equivalency => IBY_FNDCPT_COMMON_PUB.G_PAYER_EQUIV_UPWARD,
           p_trxn_entity_id => lx_trxn_extension_id,
	   p_auth_attribs => l_auth_attribs,
           p_amount => l_amount,
           x_auth_result => l_auth_result,
           x_response => lx_response
          );

	  IF (PV_DEBUG_HIGH_ON) THEN
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_return_status from IBY_FNDCPT_TRXN_PUB.CREATE_AUTHORIZATION : ' || x_return_status);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_count from IBY_FNDCPT_TRXN_PUB.CREATE_AUTHORIZATION : ' || x_msg_count);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_msg_data from IBY_FNDCPT_TRXN_PUB.CREATE_AUTHORIZATION : ' || x_msg_data);
	     PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_response Code: ' || lx_response.Result_Code);
             PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_response Category: ' || lx_response.Result_Category);
             PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' x_response Message: ' || lx_response.Result_Message);
          END IF;

	  /* R12 Changes
	   * Even if Authorization is unsuccessful, we do not throw an expection.
           * We still need to update the enrollment with the transaction extension
	   */

          IF ((x_Return_Status <> FND_API.G_RET_STS_SUCCESS) OR (lx_response.Result_Code <> 'AUTH_SUCCESS')) THEN
             l_is_authorized := 'N';
             l_skip_auth     := 'Y'; -- already failure, don't need to do anything relating to authorization
          END IF;

          FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
          FND_MESSAGE.set_token('TEXT', lx_response.Result_Message);
          FND_MSG_PUB.add;

       END IF;

       /* It is possible that we have skipped authorization for just a single request, but that subsequent
          requests need authorization (i.e. updating a transaction that failed once but was manually authorized)
          In that case, we need to allow authorization to continue on the next pass through */
       IF ((l_skip_auth = 'Y') and (l_is_authorized = 'Y')) THEN
          l_skip_auth := 'N';
       END IF;

    END IF;

   END LOOP;

     /* Need to set the authorized output flag to match the internal flag.  The internal flag will only get
        set to 'N' if the authorization has failed for any one of the enrollment requrests;
     */
     IF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN
        x_is_authorized := l_is_authorized;
     END IF;

     FND_MSG_PUB.Count_And_Get
     (   p_encoded => FND_API.G_FALSE,
         p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
     );

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;


    EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

 End set_payment_info;

 PROCEDURE set_enrq_payment_info(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_contact_party_id		  IN   NUMBER
    ,p_payment_method_rec         IN	Payment_method_Rec_type
    ,P_enrl_req_id                IN    Payment_info_Tbl_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
    ,x_is_authorized              OUT NOCOPY  VARCHAR2
 )
 IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'set_enrq_payment_info';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   lx_enrl_info Payment_info_Tbl_type;
   l_enrl_req_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_order_header_id_tbl Payment_info_Tbl_type;
   l_enrl_req_rec   PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_log_params_tbl  pvx_utility_pvt.log_params_tbl_type;
   l_partner_id number;
   l_trans_currency varchar2(15);
   l_payment_amount number;
   l_pmnt_mode_mean varchar2(80);

   /*Moving process_order to here instead of set_payment_info*/
   l_header_payment_tbl        OE_ORDER_PUB.Header_Payment_Tbl_Type;
   l_header_payment_out_tbl    OE_ORDER_PUB.Header_Payment_Tbl_Type;
   l_header_rec		       OE_ORDER_PUB.Header_Rec_Type;
   l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
   x_header_val_rec            OE_ORDER_PUB.Header_Val_Rec_Type;
   x_header_payment_val_tbl    OE_ORDER_PUB.Header_Payment_Val_Tbl_Type;
   x_Header_Adj_tbl            OE_ORDER_PUB.Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl        OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl      OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl        OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl      OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl        OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl    OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl              OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl              OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl          OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl        OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl          OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl        OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Payment_tbl	       OE_ORDER_PUB.Line_Payment_Tbl_Type;
   x_Line_Payment_val_tbl      OE_ORDER_PUB.Line_Payment_Val_Tbl_Type;
   x_Line_Scredit_tbl          OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl      OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl            OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl        OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	       OE_ORDER_PUB.Request_Tbl_Type;


    /* R12 Change
     * cursor c_get_order_id will return the transaction extension id
     */
    CURSOR c_get_order_id(cv_enrl_req_id JTF_NUMBER_TABLE) IS
      SELECT /*+ CARDINALITY(t 10) */ pver.order_header_id, pver.enrl_request_id,
	     pver.object_version_number, pver.partner_id, pver.trxn_extension_id
      FROM  PV_PG_ENRL_REQUESTS pver,
	    (Select  * from table (CAST(cv_enrl_req_id AS JTF_NUMBER_TABLE))) t
      WHERE pver.enrl_request_id = t.column_value
      and pver.custom_setup_id in (7004, 7005)
      and pver.order_header_id is not null
      and pver.payment_status_code <> 'AUTHORIZED_PAYMENT';



 BEGIN

     ---------------Initialize --------------------
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF p_enrl_req_id.count()  = 0 THEN
      FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
      FND_MESSAGE.Set_Token('ID', 'Enrollment Request', FALSE);
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;



     for i in p_enrl_req_id.FIRST..p_enrl_req_id.LAST loop
      IF (p_enrl_req_id(i).enrl_req_id IS NULL or p_enrl_req_id(i).enrl_req_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
          FND_MESSAGE.Set_Token('ID', 'Enrollment Request', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
      END IF;
       l_enrl_req_id_tbl.extend;
       l_enrl_req_id_tbl(l_enrl_req_id_tbl.count) := p_enrl_req_id(i).enrl_req_id;
      END LOOP;


     FOR x IN c_get_order_id(l_enrl_req_id_tbl) LOOP
      	 l_order_header_id_tbl(x.order_header_id).order_header_id := x.order_header_id;
         l_order_header_id_tbl(x.order_header_id).enrl_req_id := x.enrl_request_id;
	 l_order_header_id_tbl(x.order_header_id).trxn_extension_id := x.trxn_extension_id; 		-- dgottlie: new in R12
         l_order_header_id_tbl(x.order_header_id).object_version_number := x.object_version_number; 	-- dgottlie: new in R12
	 l_partner_id := x.partner_id;
     END loop;


     IF (l_order_header_id_tbl.count >0) THEN
        IF (PV_DEBUG_HIGH_ON) THEN
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' Before calling set_payment_info ');
        END IF;

        set_payment_info(
          p_api_version_number       => p_api_version_number
         ,p_init_msg_list            => FND_API.g_false
         ,p_commit                   => FND_API.G_FALSE
         ,p_contact_party_id	     => p_contact_party_id
         ,p_payment_method_rec       => p_payment_method_rec
         ,p_order_header_id          => l_order_header_id_tbl
         ,p_enrollment_flow          => 'Y'
         ,x_return_status            => x_return_status
         ,x_msg_count                => x_msg_count
         ,x_msg_data                 => x_msg_data
         ,x_is_authorized            => x_is_authorized
         ,x_enrl_info		     => lx_enrl_info
        );

        IF (PV_DEBUG_HIGH_ON) THEN
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' After calling set_payment_info');
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' x_return_status ' || x_return_status);
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' x_msg_count ' || x_msg_count);
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' x_msg_data ' || x_msg_data);
           PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' x_is_authorized ' || x_is_authorized);
        END IF;

     END IF;

     /* R12 Changes
      * For credit cards only, we will be updated the transaction extension id
      * in the enrollment requests table regardless of whether the credit card
      * authorization is sucessful
      */
     for i in lx_enrl_info.FIRST..lx_enrl_info.LAST loop

       l_enrl_req_rec.object_version_number := lx_enrl_info(i).object_version_number;
       l_enrl_req_rec.enrl_request_id  := lx_enrl_info(i).enrl_req_id;
       l_enrl_req_rec.trxn_extension_id := lx_enrl_info(i).trxn_extension_id;


       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' Before update pv_pg_enrl_request');
       END IF;

       PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests
       (
           p_api_version_number        =>  p_api_version_number,
           p_init_msg_list             =>  Fnd_Api.G_FALSE,
           p_commit                    =>  Fnd_Api.G_TRUE, -- we will always commit the new trxn extensions generated
           p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
           x_return_status             =>  x_return_status,
           x_msg_count                 =>  x_msg_count,
           x_msg_data                  =>  x_msg_data,
           p_enrl_request_rec          =>  l_enrl_req_rec
        );

        IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| 'After populating trxn_extension_id in pv_pg_enrl_request x_return_status ' || x_return_status);
        END IF;

	IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
        END IF;

      END LOOP;




     -- dgottlie: If one of the authorization failed, print error message and throw exception
     --           This needed to be done after enrollment requests table updated but before OM order processed
     IF ((p_payment_method_rec.payment_type_code = 'CREDIT_CARD') and (x_is_authorized = 'N')) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;




     -- dgottlie:If we reach here, all the enrollment requests have been authorized and we can update OM with the orders.
     l_header_payment_tbl     	:= OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_TBL;
     l_header_payment_out_tbl 	:= OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_TBL;
     l_header_rec		:= OE_ORDER_PUB.G_MISS_HEADER_REC;
     l_header_out_rec		:= OE_ORDER_PUB.G_MISS_HEADER_REC;


     FOR i IN lx_enrl_info.FIRST..lx_enrl_info.LAST LOOP

       l_header_rec.operation		:= OE_GLOBALS.g_OPR_UPDATE;
       l_header_rec.header_id		:= lx_enrl_info(i).order_header_id;
       l_header_rec.change_reason	:= 'SYSTEM';
       l_header_rec.payment_amount	:= lx_enrl_info(i).payment_amount;
       l_header_rec.cust_po_number	:= p_payment_method_rec.cust_po_number;
       l_header_rec.creation_date	:= SYSDATE;
       l_header_rec.created_by		:= FND_GLOBAL.USER_ID;
       l_header_rec.last_update_date	:= SYSDATE;
       l_header_rec.last_updated_by	:= FND_GLOBAL.USER_ID;

       IF (p_payment_method_rec.payment_type_code <> 'CREDIT_CARD') THEN
          l_header_rec.payment_type_code   := p_payment_method_rec.payment_type_code;
       END IF;

       IF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN
	  l_header_payment_tbl(1).operation  			:= OE_GLOBALS.g_OPR_CREATE;
  	  l_header_payment_tbl(1).header_id			:= lx_enrl_info(i).order_header_id;
	  l_header_payment_tbl(1).payment_collection_event	:= 'INVOICE';
	  l_header_payment_tbl(1).payment_type_code		:= p_payment_method_rec.payment_type_code;
	  l_header_payment_tbl(1).trxn_extension_id     	:= lx_enrl_info(i).trxn_extension_id;
       ELSIF (p_payment_method_rec.payment_type_code = 'CHECK') THEN
	  l_header_rec.check_number 				:= p_payment_method_rec.check_number;
       ELSIF (p_payment_method_rec.payment_type_code = 'INVOICE') THEN
	  l_header_rec.payment_type_code 			:= null;
       END IF;

       Order_Debug_On;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the OE_ORDER_GRP.process_order call ');
       END IF;

       OE_ORDER_GRP.process_order(
         p_api_version_number => l_api_version_number,
         p_init_msg_list => FND_API.g_false  ,
         p_return_values => FND_API.g_true ,
         p_commit => FND_API.g_false ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_header_rec => l_header_rec,
         x_header_rec => l_header_out_rec,
         p_header_payment_tbl => l_header_payment_tbl,
         x_header_payment_tbl => l_header_payment_out_tbl,
         x_header_val_rec => x_header_Val_Rec,
	 x_header_payment_val_tbl => x_header_payment_val_tbl,
         x_Header_Adj_tbl => x_Header_Adj_tbl  ,
         x_Header_Adj_val_tbl => x_Header_Adj_val_tbl,
         x_Header_price_Att_tbl => x_Header_price_Att_tbl,
         x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl,
         x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl,
         x_Header_Scredit_tbl => x_Header_Scredit_tbl,
         x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl,
         x_line_tbl => x_line_tbl,
         x_line_val_tbl => x_line_val_tbl ,
         x_Line_Adj_tbl => x_Line_Adj_tbl,
         x_Line_Adj_val_tbl => x_Line_Adj_val_tbl,
         x_Line_price_Att_tbl => x_Line_price_Att_tbl,
         x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl ,
         x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl,
         x_Line_Payment_tbl => x_line_payment_tbl,
         x_Line_Payment_val_tbl => x_line_payment_val_tbl,
         x_Line_Scredit_tbl => x_Line_Scredit_tbl,
         x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl,
         x_Lot_Serial_tbl => x_Lot_Serial_tbl ,
         x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl,
         x_action_request_tbl =>x_action_request_tbl
       );

        IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| 'After process_order API call :  x_return_status ' || x_return_status);
        END IF;

       Retrieve_OE_Messages;

       IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
       ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
       ELSIF (x_return_status = FND_API.g_ret_sts_success) THEN
	  for i in 1..l_header_payment_out_tbl.count loop
             IF (l_header_payment_out_tbl(i).return_status = FND_API.g_ret_sts_error) THEN
		RAISE FND_API.g_exc_error;
	     ELSIF (l_header_payment_out_tbl(i).return_status = FND_API.g_ret_sts_unexp_error) THEN
		RAISE FND_API.g_exc_unexpected_error;
	     END IF;
          end loop;
       END IF;


     END LOOP;

            -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after the OE_ORDER_GRP.process_order call');
       END IF;


      for i in lx_enrl_info.FIRST..lx_enrl_info.LAST loop

       l_enrl_req_rec.object_version_number := lx_enrl_info(i).object_version_number+1;
       l_enrl_req_rec.enrl_request_id  := lx_enrl_info(i).enrl_req_id;
       IF ((p_payment_method_rec.payment_type_code <> 'CREDIT_CARD') or (x_is_authorized = 'Y')) THEN
          l_enrl_req_rec.payment_status_code := 'AUTHORIZED_PAYMENT';
       END IF;


       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' Before update pv_pg_enrl_request');
       END IF;

       PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests
       (
           p_api_version_number        =>  p_api_version_number,
           p_init_msg_list             =>  Fnd_Api.G_FALSE,
           p_commit                    =>  Fnd_Api.G_FALSE,
           p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
           x_return_status             =>  x_return_status,
           x_msg_count                 =>  x_msg_count,
           x_msg_data                  =>  x_msg_data,
           p_enrl_request_rec          =>  l_enrl_req_rec
        );

        IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| 'After updating payment status to AUTHORIZED in pv_pg_enrl_request x_return_status ' || x_return_status);
        END IF;

	IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
        END IF;


	IF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN
           IF (x_is_authorized = 'Y') THEN

	      pvx_utility_pvt.create_history_log
	      (
               p_arc_history_for_entity_code  =>  'ENRQ',
               p_history_for_entity_id        =>  lx_enrl_info(i).enrl_req_id,
               p_history_category_code	      =>  'PAYMENT',
               p_message_code		      =>  'PV_CREDIT_CARD_AUTH_SUCCESS',
               p_partner_id                   =>  l_partner_id,
               p_access_level_flag            =>  'V',
	       p_log_params_tbl		      =>   l_log_params_tbl,
               x_return_status    	      =>   x_return_status,
               x_msg_count                    =>   x_msg_count,
               x_msg_data                     =>   x_msg_data
              );

              IF (PV_DEBUG_HIGH_ON) THEN
                   PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' After create history log : x_return_status ' || x_return_status);
              END IF;

              IF (x_return_status = FND_API.g_ret_sts_error) THEN
                 RAISE FND_API.g_exc_error;
              ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
                 RAISE FND_API.g_exc_unexpected_error;
              END IF;
           END IF;
       END IF;

       IF (p_payment_method_rec.payment_type_code <> 'CREDIT_CARD') and (x_is_authorized = 'Y') THEN
          select payment_amount,
                 transactional_curr_code
          into   l_payment_amount,
                 l_trans_currency
          from   oe_order_headers_all
          where  header_id = lx_enrl_info(i).order_header_id;

          select meaning
          into   l_pmnt_mode_mean
          from   PV_LOOKUPS
          where  lookup_type = 'PV_PAYMENT_TYPE'
          and    lookup_code = p_payment_method_rec.payment_type_code;

          l_log_params_tbl(1).param_name := 'AMOUNT';
	  l_log_params_tbl(1).param_value :=  l_payment_amount;

          l_log_params_tbl(2).param_name := 'CURRENCY';
	  l_log_params_tbl(2).param_value := l_trans_currency;

          l_log_params_tbl(3).param_name := 'MODE';
	  l_log_params_tbl(3).param_value := l_pmnt_mode_mean;

  	  pvx_utility_pvt.create_history_log
	  (
            p_arc_history_for_entity_code  =>  'ENRQ',
            p_history_for_entity_id  	 =>  lx_enrl_info(i).enrl_req_id,
            p_history_category_code	 =>  'PAYMENT',
            p_message_code		 =>  'PV_PAYMENT_AUTHORIZED',
            p_partner_id                   =>  l_partner_id,
            p_access_level_flag            =>  'V',
            p_log_params_tbl		 =>   l_log_params_tbl,
            x_return_status    	         =>   x_return_status,
            x_msg_count                    =>   x_msg_count,
            x_msg_data                     =>   x_msg_data
          );

          IF (PV_DEBUG_HIGH_ON) THEN
                PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' After create history log : x_return_status ' || x_return_status);
          END IF;

	  IF (x_return_status = FND_API.g_ret_sts_error) THEN
             RAISE FND_API.g_exc_error;
          ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
             RAISE FND_API.g_exc_unexpected_error;
          END IF;
       END IF;

      END LOOP;

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('API: ' || l_api_name|| ' Processing done');
      END IF;


     FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
          p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
        );

       IF FND_API.to_Boolean( p_commit ) THEN
         COMMIT WORK;
       END IF;


     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
             FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
          END IF;
	  FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
           );

 END set_enrq_payment_info;

 PROCEDURE set_vad_payment_info(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_contact_party_id		  IN   NUMBER
    ,p_payment_method_rec         IN	Payment_method_Rec_type
    ,P_order_header_id            IN    Payment_info_Tbl_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'set_vad_payment_info';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_order_header_id_tbl	Payment_info_Tbl_type;
   l_partner_id			NUMBER;
   lx_enrl_info 		Payment_info_Tbl_type;
   l_is_authorized 		VARCHAR2(1);
   l_invite_header_rec		Pv_Pg_Invite_headers_PVT.invite_headers_rec_type;

   /*Moving process_order to here instead of set_payment_info*/
   l_header_payment_tbl        OE_ORDER_PUB.Header_Payment_Tbl_Type;
   l_header_payment_out_tbl    OE_ORDER_PUB.Header_Payment_Tbl_Type;
   l_header_rec		       OE_ORDER_PUB.Header_Rec_Type;
   l_header_out_rec            OE_ORDER_PUB.Header_Rec_Type;
   x_header_val_rec            OE_ORDER_PUB.Header_Val_Rec_Type;
   x_header_payment_val_tbl    OE_ORDER_PUB.Header_Payment_Val_Tbl_Type;
   x_Header_Adj_tbl            OE_ORDER_PUB.Header_Adj_Tbl_Type;
   x_Header_Adj_val_tbl        OE_ORDER_PUB.Header_Adj_Val_Tbl_Type;
   x_Header_price_Att_tbl      OE_ORDER_PUB.Header_Price_Att_Tbl_Type;
   x_Header_Adj_Att_tbl        OE_ORDER_PUB.Header_Adj_Att_Tbl_Type;
   x_Header_Adj_Assoc_tbl      OE_ORDER_PUB.Header_Adj_Assoc_Tbl_Type;
   x_Header_Scredit_tbl        OE_ORDER_PUB.Header_Scredit_Tbl_Type;
   x_Header_Scredit_val_tbl    OE_ORDER_PUB.Header_Scredit_Val_Tbl_Type;
   x_line_tbl                  OE_ORDER_PUB.Line_Tbl_Type;
   x_line_val_tbl              OE_ORDER_PUB.Line_Val_Tbl_Type;
   x_Line_Adj_tbl              OE_ORDER_PUB.Line_Adj_Tbl_Type;
   x_Line_Adj_val_tbl          OE_ORDER_PUB.Line_Adj_Val_Tbl_Type;
   x_Line_price_Att_tbl        OE_ORDER_PUB.Line_Price_Att_Tbl_Type;
   x_Line_Adj_Att_tbl          OE_ORDER_PUB.Line_Adj_Att_Tbl_Type;
   x_Line_Adj_Assoc_tbl        OE_ORDER_PUB.Line_Adj_Assoc_Tbl_Type;
   x_Line_Payment_tbl	       OE_ORDER_PUB.Line_Payment_Tbl_Type;
   x_Line_Payment_val_tbl      OE_ORDER_PUB.Line_Payment_Val_Tbl_Type;
   x_Line_Scredit_tbl          OE_ORDER_PUB.Line_Scredit_Tbl_Type;
   x_Line_Scredit_val_tbl      OE_ORDER_PUB.Line_Scredit_Val_Tbl_Type;
   x_Lot_Serial_tbl            OE_ORDER_PUB.Lot_Serial_Tbl_Type;
   x_Lot_Serial_val_tbl        OE_ORDER_PUB.Lot_Serial_Val_Tbl_Type;
   x_action_request_tbl	       OE_ORDER_PUB.Request_Tbl_Type;

   /* R12 Change
    * cursor c_get_order_id will return the transaction extension id
    */
   CURSOR c_get_order_id(cv_invite_header_id NUMBER) IS
     SELECT pvih.order_header_id, pvih.invite_header_id, pvih.object_version_number,
            pvih.partner_id, pvih.trxn_extension_id
     FROM   PV_PG_INVITE_HEADERS_B pvih
     WHERE  pvih.invite_header_id = cv_invite_header_id
     and    pvih.order_header_id is not null;

 BEGIN

     ---------------Initialize --------------------
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF p_order_header_id.count() = 0 THEN
        FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
        FND_MESSAGE.Set_Token('ID', 'Order Header', FALSE);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF ((p_order_header_id(p_order_header_id.FIRST).invite_header_id IS NULL) or
         (p_order_header_id(p_order_header_id.FIRST).invite_header_id = FND_API.G_MISS_NUM)) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
          FND_MESSAGE.Set_Token('ID', 'Invite Header', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     FOR x IN c_get_order_id(p_order_header_id(p_order_header_id.FIRST).invite_header_id) LOOP
      	 l_order_header_id_tbl(x.order_header_id).order_header_id := x.order_header_id;
         l_order_header_id_tbl(x.order_header_id).invite_header_id := x.invite_header_id;
	 l_order_header_id_tbl(x.order_header_id).trxn_extension_id := x.trxn_extension_id; 		-- dgottlie: new in R12
         l_order_header_id_tbl(x.order_header_id).object_version_number := x.object_version_number; 	-- dgottlie: new in R12
	 l_partner_id := x.partner_id;
     END loop;

     IF(l_order_header_id_tbl.count >0) THEN
      set_payment_info(
        p_api_version_number       => p_api_version_number
       ,p_init_msg_list            => FND_API.g_false
       ,p_commit                   => FND_API.G_FALSE
       ,p_contact_party_id	   => p_contact_party_id
       ,p_payment_method_rec       => p_payment_method_rec
       ,p_order_header_id          => l_order_header_id_tbl
       ,p_enrollment_flow          => 'N'
       ,x_return_status            => x_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data
       ,x_is_authorized            => l_is_authorized
       ,x_enrl_info		   => lx_enrl_info
       );
     END IF;

     IF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     for i in lx_enrl_info.FIRST..lx_enrl_info.LAST loop

       l_invite_header_rec.object_version_number := lx_enrl_info(i).object_version_number;
       l_invite_header_rec.invite_header_id  := lx_enrl_info(i).invite_header_id;
       l_invite_header_rec.trxn_extension_id := lx_enrl_info(i).trxn_extension_id;

       PV_Pg_Invite_Headers_PVT.Update_Invite_Headers
       (
           p_api_version_number        =>  p_api_version_number,
           p_init_msg_list             =>  Fnd_Api.G_FALSE,
           p_commit                    =>  Fnd_Api.G_FALSE,
           p_validation_level          =>  Fnd_Api.G_VALID_LEVEL_FULL,
           x_return_status             =>  x_return_status,
           x_msg_count                 =>  x_msg_count,
           x_msg_data                  =>  x_msg_data,
           p_invite_headers_rec        =>  l_invite_header_rec
        );

	IF x_return_status = FND_API.g_ret_sts_error THEN
             RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
             RAISE FND_API.g_exc_unexpected_error;
        END IF;

     END LOOP;

     -- dgottlie:If we reach here, all the enrollment requests have been authorized and we can update OM with the orders.
     l_header_payment_tbl     	:= OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_TBL;
     l_header_payment_out_tbl 	:= OE_ORDER_PUB.G_MISS_HEADER_PAYMENT_TBL;
     l_header_rec		:= OE_ORDER_PUB.G_MISS_HEADER_REC;
     l_header_out_rec		:= OE_ORDER_PUB.G_MISS_HEADER_REC;
     FOR i IN lx_enrl_info.FIRST..lx_enrl_info.LAST LOOP
       l_header_rec.operation		:= OE_GLOBALS.g_OPR_UPDATE;
       l_header_rec.header_id		:= lx_enrl_info(i).order_header_id;
       l_header_rec.change_reason	:= 'SYSTEM';
       l_header_rec.payment_amount	:= lx_enrl_info(i).payment_amount;
       l_header_rec.cust_po_number	:= p_payment_method_rec.cust_po_number;
       l_header_rec.creation_date	:= SYSDATE;
       l_header_rec.created_by		:= FND_GLOBAL.USER_ID;
       l_header_rec.last_update_date	:= SYSDATE;
       l_header_rec.last_updated_by	:= FND_GLOBAL.USER_ID;

       IF (p_payment_method_rec.payment_type_code <> 'CREDIT_CARD') THEN
          l_header_rec.payment_type_code   := p_payment_method_rec.payment_type_code;
       END IF;

       IF (p_payment_method_rec.payment_type_code = 'CREDIT_CARD') THEN
	  l_header_payment_tbl(1).operation  			:= OE_GLOBALS.g_OPR_CREATE;
  	  l_header_payment_tbl(1).header_id			:= lx_enrl_info(i).order_header_id;
	  l_header_payment_tbl(1).payment_collection_event	:= 'INVOICE';
	  l_header_payment_tbl(1).payment_type_code		:= p_payment_method_rec.payment_type_code;
	  l_header_payment_tbl(1).trxn_extension_id     	:= lx_enrl_info(i).trxn_extension_id;
       ELSIF (p_payment_method_rec.payment_type_code = 'CHECK') THEN
	  l_header_rec.check_number 				:= p_payment_method_rec.check_number;
       ELSIF (p_payment_method_rec.payment_type_code = 'INVOICE') THEN
	  l_header_rec.payment_type_code 			:= null;
       END IF;

       Order_Debug_On;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' before the OE_ORDER_GRP.process_order call');
       END IF;

       OE_ORDER_GRP.process_order(
         p_api_version_number => l_api_version_number,
         p_init_msg_list => FND_API.g_false  ,
         p_return_values => FND_API.g_true ,
         p_commit => FND_API.g_false ,
         x_return_status => x_return_status,
         x_msg_count => x_msg_count,
         x_msg_data  => x_msg_data,
         p_header_rec => l_header_rec,
         x_header_rec => l_header_out_rec,
         p_header_payment_tbl => l_header_payment_tbl,
         x_header_payment_tbl => l_header_payment_out_tbl,
         x_header_val_rec => x_header_Val_Rec,
	 x_header_payment_val_tbl => x_header_payment_val_tbl,
         x_Header_Adj_tbl => x_Header_Adj_tbl  ,
         x_Header_Adj_val_tbl => x_Header_Adj_val_tbl,
         x_Header_price_Att_tbl => x_Header_price_Att_tbl,
         x_Header_Adj_Att_tbl => x_Header_Adj_Att_tbl,
         x_Header_Adj_Assoc_tbl => x_Header_Adj_Assoc_tbl,
         x_Header_Scredit_tbl => x_Header_Scredit_tbl,
         x_Header_Scredit_val_tbl => x_Header_Scredit_val_tbl,
         x_line_tbl => x_line_tbl,
         x_line_val_tbl => x_line_val_tbl ,
         x_Line_Adj_tbl => x_Line_Adj_tbl,
         x_Line_Adj_val_tbl => x_Line_Adj_val_tbl,
         x_Line_price_Att_tbl => x_Line_price_Att_tbl,
         x_Line_Adj_Att_tbl => x_Line_Adj_Att_tbl ,
         x_Line_Adj_Assoc_tbl => x_Line_Adj_Assoc_tbl,
         x_Line_Payment_tbl => x_line_payment_tbl,
         x_Line_Payment_val_tbl => x_line_payment_val_tbl,
         x_Line_Scredit_tbl => x_Line_Scredit_tbl,
         x_Line_Scredit_val_tbl => x_Line_Scredit_val_tbl,
         x_Lot_Serial_tbl => x_Lot_Serial_tbl ,
         x_Lot_Serial_val_tbl => x_Lot_Serial_val_tbl,
         x_action_request_tbl =>x_action_request_tbl
       );

       Retrieve_OE_Messages;

       IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
       ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
       ELSIF (x_return_status = FND_API.g_ret_sts_success) THEN
	  for i in 1..l_header_payment_out_tbl.count loop
             IF (l_header_payment_out_tbl(i).return_status = FND_API.g_ret_sts_error) THEN
		RAISE FND_API.g_exc_error;
	     ELSIF (l_header_payment_out_tbl(i).return_status = FND_API.g_ret_sts_unexp_error) THEN
		RAISE FND_API.g_exc_unexpected_error;
	     END IF;
          end loop;
       END IF;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('In ' || l_api_name || ' after the OE_ORDER_GRP.process_order call');
       END IF;

     END LOOP;

     FND_MSG_PUB.Count_And_Get
        ( p_encoded => FND_API.G_FALSE,
          p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
        );

     IF FND_API.to_Boolean( p_commit ) THEN
        COMMIT WORK;
     END IF;

     EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END set_vad_payment_info;

END PV_ORDER_MGMT_PVT;

/
