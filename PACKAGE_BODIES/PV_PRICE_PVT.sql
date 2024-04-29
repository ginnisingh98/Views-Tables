--------------------------------------------------------
--  DDL for Package Body PV_PRICE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PRICE_PVT" as
/* $Header: pvxvprib.pls 120.5 2006/05/04 15:37:47 dgottlie ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_PRICE_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpomb.pls';
PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

FUNCTION  check_billing_address_exists(
		p_partner_party_id IN NUMBER
	       ,p_contact_party_id IN NUMBER
) RETURN BOOLEAN IS

  l_return number;

BEGIN

  select 1
  into   l_return
  from   dual
  where exists
  (
   select hzu.party_site_use_id
   from   hz_party_sites     hzs,
	  hz_party_site_uses hzu
   where  hzs.party_id in (p_partner_party_id, p_contact_party_id)
   and    hzu.party_site_id = hzs.party_site_id
   and    hzu.site_use_type = 'BILL_TO'
   and    hzs.status = 'A'
   and    hzu.status = 'A'
  );

  IF (l_return = 1) THEN
    return true;
  ELSE
    return false;
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    return false;

END check_billing_address_exists;

PROCEDURE Price_Request(
            p_api_version_number         IN  NUMBER
           ,p_init_msg_list              IN  VARCHAR2           := FND_API.G_FALSE
           ,p_commit                     IN  VARCHAR2           := FND_API.G_FALSE
	   ,p_partner_account_id         IN  NUMBER
	   ,p_partner_party_id           IN  NUMBER
	   ,p_contact_party_id		 IN  NUMBER
	   ,p_transaction_currency       IN  VARCHAR2
	   ,p_enrl_req_id                IN  JTF_NUMBER_TABLE
	   ,x_return_status		 OUT NOCOPY	VARCHAR2
  	   ,x_msg_count                  OUT NOCOPY  NUMBER
           ,x_msg_data                   OUT NOCOPY  VARCHAR2
)
IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Price_Request';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_inventory_item_id  NUMBER;
   l_enrl_req_id NUMBER;
   l_inventory_item_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_enrl_req_id_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_obj_ver_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();


   l_control_rec                 QP_PREQ_GRP.CONTROL_RECORD_TYPE;
   G_LiNE_iNDEX_TBL              QP_PREQ_GRP.PLS_iNTEGER_TYPE;
   G_LiNE_TYPE_CODE_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCiNG_EFFECTiVE_DATE_TBL  QP_PREQ_GRP.DATE_TYPE   ;
   G_ACTiVE_DATE_FiRST_TBL       QP_PREQ_GRP.DATE_TYPE   ;
   G_ACTiVE_DATE_FiRST_TYPE_TBL  QP_PREQ_GRP.VARCHAR_TYPE;
   G_ACTiVE_DATE_SECOND_TBL      QP_PREQ_GRP.DATE_TYPE   ;
   G_ACTiVE_DATE_SECOND_TYPE_TBL QP_PREQ_GRP.VARCHAR_TYPE ;
   --G_LiNE_QUANTiTY_TBL         QP_PREQ_GRP.NUMBER_TYPE ;
   --G_LiNE_UOM_CODE_TBL         QP_PREQ_GRP.VARCHAR_TYPE;
   G_REQUEST_TYPE_CODE_TBL     	 QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCED_QUANTiTY_TBL       	 QP_PREQ_GRP.NUMBER_TYPE;
   G_UOM_QUANTiTY_TBL          	 QP_PREQ_GRP.NUMBER_TYPE;
   G_PRiCED_UOM_CODE_TBL       	 QP_PREQ_GRP.VARCHAR_TYPE;
   G_CURRENCY_CODE_TBL         	 QP_PREQ_GRP.VARCHAR_TYPE;
   G_UNiT_PRiCE_TBL            	 QP_PREQ_GRP.NUMBER_TYPE;
   G_PERCENT_PRiCE_TBL         	 QP_PREQ_GRP.NUMBER_TYPE;
   G_ADJUSTED_UNiT_PRiCE_TBL   	 QP_PREQ_GRP.NUMBER_TYPE;
   G_UPD_ADJUSTED_UNiT_PRiCE_TBL QP_PREQ_GRP.NUMBER_TYPE;
   G_PROCESSED_FLAG_TBL          QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCE_FLAG_TBL              QP_PREQ_GRP.VARCHAR_TYPE;
   G_LiNE_iD_TBL                 QP_PREQ_GRP.NUMBER_TYPE;
   G_PROCESSiNG_ORDER_TBL        QP_PREQ_GRP.PLS_iNTEGER_TYPE;
   G_ROUNDiNG_FACTOR_TBL         QP_PREQ_GRP.PLS_iNTEGER_TYPE;
   G_ROUNDiNG_FLAG_TBL           QP_PREQ_GRP.FLAG_TYPE;
   G_QUALiFiERS_EXiST_FLAG_TBL   QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCiNG_ATTRS_EXiST_FLAG_TBL QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCE_LiST_iD_TBL           QP_PREQ_GRP.NUMBER_TYPE;
   G_PL_VALiDATED_FLAG_TBL       QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCE_REQUEST_CODE_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
   G_USAGE_PRiCiNG_TYPE_TBL      QP_PREQ_GRP.VARCHAR_TYPE;
   G_LiNE_CATEGORY_TBL           QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCiNG_STATUS_CODE_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
   G_PRiCiNG_STATUS_TEXT_tbl     QP_PREQ_GRP.VARCHAR_TYPE;
   G_RELATiONSHiP_TYPE_CODE	 QP_PREQ_GRP.VARCHAR_TYPE;
   G_LiNE_DETAiL_iNDEX_tbl       QP_PREQ_GRP.NUMBER_TYPE;
   G_RLTD_LiNE_DETAiL_iNDEX_tbl  QP_PREQ_GRP.NUMBER_TYPE;
   G_LiNE_QUANTiTY_TBL         	 QP_PREQ_GRP.NUMBER_TYPE ;
   G_LiNE_UOM_CODE_TBL           QP_PREQ_GRP.VARCHAR_TYPE;

   line_index number := 0;
   l_line_index number;
   l_line_id number;
   l_adjusted_unit_price NUMBER;
   l_unit_price number;
   L_LINE_UNIT_PRICE number;
   l_ORDER_UOM_SELLiNG_PRiCE number;
   l_LINE_AMOUNT number;
   l_EXTENDED_PRICE number;
   l_LiNE_UOM_CODE  VARCHAR2(30);
   l_PRICED_QUANTITY number;
   l_PRICED_UOM_CODE  VARCHAR2(30);
   l_UOM_QUANTITY  number;
   l_LINE_TYPE_CODE  VARCHAR2(30);
   l_LiNE_QUANTiTY number;
   l_PRiCiNG_STATUS_CODE  VARCHAR2(30);
   l_PRiCiNG_STATUS_TEXT  VARCHAR2(2000);
   l_price_list_header_id number;
   l_currency_code  VARCHAR2(30);
   l_return_status_text VARCHAR2(2000);
   l_billing_address_exists boolean := false;
   l_line_has_price_error boolean := false;
   l_has_price_error boolean := false;
   l_program_name varchar2(60);
    l_enrl_req_rec   PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_uom_code VARCHAR2(10);



   -- Cursor to get partner program inventoty item id
   CURSOR c_inventory_item_id IS
      SELECT  /*+ CARDINALITY(erequests 10) */ pvpp.inventory_item_id, pver.enrl_request_id, pver.object_version_number
      FROM PV_PARTNER_PROGRAM_B pvpp, PV_PG_ENRL_REQUESTS pver,
      (Select  column_value from table (CAST(p_enrl_req_id AS JTF_NUMBER_TABLE))) erequests
      WHERE pver.enrl_request_id = erequests.column_value
      and pver.PROGRAM_ID = pvpp.program_id
      and pver.custom_setup_id in (7004, 7005)
      and (pver.order_header_id is null
      OR  (pver.order_header_id is not null and pver.payment_status_code <> 'AUTHORIZED_PAYMENT'));



   -- Cursor to get price
   CURSOR c_price IS
     SELECT  LiNE_INDEX, LINE_ID, adjusted_unit_price, UNIT_PRICE, LINE_UNIT_PRICE, ORDER_UOM_SELLING_PRICE, LINE_AMOUNT, EXTENDED_PRICE
            ,LiNE_UOM_CODE, PRICED_QUANTITY, PRICED_UOM_CODE, UOM_QUANTITY
	    , LINE_TYPE_CODE, LiNE_QUANTiTY, PRiCiNG_STATUS_CODE, PRICING_STATUS_TEXT, price_list_header_id, currency_code
     FROM QP_PREQ_LiNES_TMP
     ORDER BY LiNE_INDEX;

   CURSOR c_program_name (cv_enrl_request_id NUMBER) IS
      select pvppv.program_name
      from pv_partner_program_vl pvppv, PV_PG_ENRL_REQUESTS pver
      where pver.enrl_request_id = cv_enrl_request_id
      and pver.program_id = pvppv.program_id;



 BEGIN


     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT PRICE_REQUEST;

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

       IF (p_partner_party_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
	  FND_MESSAGE.Set_Token('ID', 'Partner Party', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF (p_transaction_currency  = FND_API.G_MISS_CHAR) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
	  FND_MESSAGE.Set_Token('ID', 'Currency', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;



     IF (p_partner_account_id = FND_API.G_MISS_NUM) THEN
          FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
	  FND_MESSAGE.Set_Token('ID', 'Account', FALSE);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_enrl_req_id.count < 1) THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_ID');
         FND_MESSAGE.Set_Token('ID', 'Enrollment Request', FALSE);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
     END IF;

       FOR x in c_inventory_item_id LOOP
  	  l_inventory_item_id_tbl.extend();
	  l_enrl_req_id_tbl.extend;
	  l_obj_ver_tbl.extend;
	  l_inventory_item_id_tbl(l_inventory_item_id_tbl.count) := x.inventory_item_id;
	  l_enrl_req_id_tbl(l_enrl_req_id_tbl.count) := x.enrl_request_id;
	  l_obj_ver_tbl(l_obj_ver_tbl.count) := x.object_version_number;
	END loop;

       IF (l_inventory_item_id_tbl.count > 0 )  THEN
	IF (check_billing_address_exists(p_partner_party_id => p_partner_party_id,
	 			        p_contact_party_id => p_contact_party_id)) THEN
	  l_billing_address_exists := true;
	END IF;

	if(not l_billing_address_exists) then
	  FND_MESSAGE.set_name('PV', 'PV_NO_BILLING_ADDRESS');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
	else
	   IF (PV_DEBUG_HIGH_ON) THEN
             PVX_UTiLiTY_PVT.debug_message('Billing Address Validated succesfully');
           END IF;
	end if;

       PV_ORDER_MGMT_PVT.Order_Debug_On;

                 -- Debug Message
        IF (PV_DEBUG_HIGH_ON) THEN
           PVX_UTiLiTY_PVT.debug_message('QP Version'||QP_PREQ_GRP.GET_VERSiON);
         END IF;

        QP_PRiCE_REQUEST_CONTEXT.SET_REQUEST_iD();

        IF (PV_DEBUG_HIGH_ON) THEN
       	  PVX_UTiLiTY_PVT.debug_message('request id was set');
        END IF;


       l_control_rec.pricing_event := 'BATCH';
       l_control_rec.calculate_flag := 'Y';
       l_control_rec.simulation_flag := 'N';
       l_control_rec.temp_table_insert_flag := 'N';
       l_control_rec.request_type_code := 'ONT';


      FOR  line_index in l_enrl_req_id_tbl.FIRST..l_enrl_req_id_tbl.LAST LOOP

        IF (PV_DEBUG_HIGH_ON) THEN
       	  PVX_UTiLiTY_PVT.debug_message('building contex for line :' || line_index);
          PVX_UTiLiTY_PVT.debug_message('Getting UOM code for item id:' || l_inventory_item_id_tbl(line_index));
        END IF;

	 select msi.primary_uom_code
         into   l_uom_code
         from   mtl_system_items_b msi
         where  msi.inventory_item_id = l_inventory_item_id_tbl(line_index)
         and    rownum = 1;

        IF (PV_DEBUG_HIGH_ON) THEN
       	  PVX_UTiLiTY_PVT.debug_message('UOM Code is:' || l_uom_code);
        END IF;

         G_line_index_tbl(line_index) := line_index;
 	 G_line_type_code_tbl(line_index) := 'LINE';
 	 G_pricing_effective_date_tbl(line_index) := sysdate;
 	 G_active_date_first_tbl(line_index) := sysdate;
 	 G_active_date_first_type_tbl(line_index) := 'NO TYPE';
 	 G_active_date_second_tbl(line_index) := sysdate;
 	 G_active_date_second_type_tbl(line_index) :='NO TYPE';

 	 G_line_quantity_tbl(line_index) := 1;
 	 G_LiNE_UOM_CODE_TBL(line_index) := l_uom_code;

	 G_REQUEST_TYPE_CODE_TBL(line_index) := 'ONT';
	 G_PRiCED_QUANTiTY_TBL(line_index) := null;
	 G_PRiCED_UOM_CODE_TBL(line_index) := null;
 	 G_CURRENCY_CODE_TBL(line_index) := p_transaction_currency;
	 G_UNiT_PRiCE_TBL(line_index) := null;
	 G_PERCENT_PRiCE_TBL(line_index) := null;
	 G_UOM_QUANTiTY_TBL(line_index) := null;
	 G_ADJUSTED_UNiT_PRiCE_TBL(line_index) := null;
	 G_UPD_ADJUSTED_UNiT_PRiCE_TBL(line_index) := null;
	 G_PROCESSED_FLAG_TBL(line_index) := null;
 	 G_PRiCE_FLAG_TBL(line_index) := 'Y';
 	 G_LiNE_iD_TBL(line_index) := line_index;
	 G_PROCESSiNG_ORDER_TBL(line_index) := null;
	 G_PRiCiNG_STATUS_CODE_tbl(line_index) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
	 G_PRiCiNG_STATUS_TEXT_tbl(line_index) := null;
	 G_ROUNDiNG_FLAG_TBL(line_index) := null;
	 G_ROUNDiNG_FACTOR_TBL(line_index) := null;
	 G_QUALiFiERS_EXiST_FLAG_TBL(line_index) := 'N';
	 G_PRiCiNG_ATTRS_EXiST_FLAG_TBL(line_index) := 'N';
	 G_PRiCE_LiST_iD_TBL(line_index) := null;
	 G_PL_VALiDATED_FLAG_TBL(line_index) := 'N';
         G_PRiCE_REQUEST_CODE_TBL(line_index) := null;
 	 G_usage_pricing_type_tbl(line_index) := QP_PREQ_GRP.G_REGULAR_USAGE_TYPE;
	 G_LiNE_CATEGORY_tbl(line_index) := null;


	 OE_ORDER_PUB.G_line.inventory_item_id := l_inventory_item_id_tbl(line_index);
 	 OE_ORDER_PUB.G_line.order_quantity_uom:= l_uom_code;
 	 OE_ORDER_PUB.G_line.ordered_quantity:= 1;
	 OE_ORDER_PUB.G_line.sold_to_org_id  := p_partner_account_id;
	 OE_ORDER_PUB.G_line.order_source_id := 23;

	 QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS('ONT', line_index, 'L');

      END LOOP;


        line_index := l_enrl_req_id_tbl.LAST;
        line_index := line_index + 1;

        IF (PV_DEBUG_HIGH_ON) THEN
       	  PVX_UTiLiTY_PVT.debug_message('line_index '|| line_index);
        END IF;

        G_LiNE_iNDEX_TBL(line_index) :=line_index;
        G_LiNE_TYPE_CODE_TBL(line_index) := 'ORDER';
 	G_pricing_effective_date_tbl(line_index) := sysdate;
 	G_active_date_first_tbl(line_index) := sysdate;
 	G_active_date_first_type_tbl(line_index) := 'NO TYPE';
 	G_active_date_second_tbl(line_index) := sysdate;
 	G_active_date_second_type_tbl(line_index) :='NO TYPE';

 	G_LiNE_QUANTiTY_TBL(line_index) := 1;
 	G_LiNE_UOM_CODE_TBL(line_index) := NULL;
 	g_request_type_code_tbl(line_index) := 'ONT';
	G_PRiCED_QUANTiTY_TBL(line_index) := null;
	G_PRiCED_UOM_CODE_TBL(line_index) := null;
 	G_currency_code_tbl(line_index) := p_transaction_currency;
	G_UNiT_PRiCE_TBL(line_index) := null;
	G_PERCENT_PRiCE_TBL(line_index) := null;
	G_UOM_QUANTiTY_TBL(line_index) := null;
	G_ADJUSTED_UNiT_PRiCE_TBL(line_index) := null;
	G_UPD_ADJUSTED_UNiT_PRiCE_TBL(line_index) := null;
	G_PROCESSED_FLAG_TBL(line_index) := null;
 	G_PRiCE_FLAG_TBL(line_index) := 'Y';
 	G_LiNE_iD_TBL(line_index) := line_index;
	G_PROCESSiNG_ORDER_TBL(line_index) := null;
	G_PRiCiNG_STATUS_CODE_tbl(line_index) := QP_PREQ_GRP.G_STATUS_UNCHANGED;
	G_PRiCiNG_STATUS_TEXT_tbl(line_index) := null;
	G_ROUNDiNG_FLAG_TBL(line_index) := null;
	G_ROUNDiNG_FACTOR_TBL(line_index) := null;
	G_QUALiFiERS_EXiST_FLAG_TBL(line_index) := 'N';
	G_PRiCiNG_ATTRS_EXiST_FLAG_TBL(line_index) := 'N';
	G_PRiCE_LiST_iD_TBL(line_index) := null;
	G_PL_VALiDATED_FLAG_TBL(line_index) := 'N';
	G_PRiCE_REQUEST_CODE_TBL(line_index) := null;
 	G_usage_pricing_type_tbl(line_index) := QP_PREQ_GRP.G_REGULAR_USAGE_TYPE;
	--G_LiNE_CATEGORY_tbl(line_index) := null;

	oe_order_pub.g_hdr.transactional_curr_code := p_transaction_currency;
        oe_order_pub.g_hdr.sold_to_org_id := p_partner_account_id;
        oe_order_pub.g_hdr.order_source_id   := 23;
        oe_order_pub.g_hdr.freight_terms_code := NULL;
        oe_order_pub.g_hdr.order_type_id := to_number(FND_PROFILE.Value('PV_ORDER_TRANSACTION_TYPE_ID'));

	-- populate header attibutes/qualifiers
	QP_ATTR_MAPPING_PUB.BUILD_CONTEXTS
	    	(p_request_type_code => 'ONT',
	    	 p_line_index        => line_index,
	    	 p_pricing_type_code => 'H');


        IF (PV_DEBUG_HIGH_ON) THEN
       	  PVX_UTiLiTY_PVT.debug_message('Before inserting into temporary tables');
        END IF;


        QP_PREQ_GRP.iNSERT_LiNES2
           (p_LiNE_iNDEX               => G_LiNE_iNDEX_TBL,
            p_LiNE_TYPE_CODE           => G_LiNE_TYPE_CODE_TBL,
            p_PRiCiNG_EFFECTiVE_DATE   => G_PRiCiNG_EFFECTiVE_DATE_TBL,
            p_ACTiVE_DATE_FiRST        => G_ACTiVE_DATE_FiRST_TBL,
            p_ACTiVE_DATE_FiRST_TYPE   => G_ACTiVE_DATE_FiRST_TYPE_TBL,
            p_ACTiVE_DATE_SECOND       => G_ACTiVE_DATE_SECOND_TBL,
            p_ACTiVE_DATE_SECOND_TYPE  => G_ACTiVE_DATE_SECOND_TYPE_TBL,
            p_LiNE_QUANTiTY            => G_LiNE_QUANTiTY_TBL,
            p_LiNE_UOM_CODE            => G_line_UOM_CODE_TBL,
            p_REQUEST_TYPE_CODE        => G_REQUEST_TYPE_CODE_TBL,
            p_PRiCED_QUANTiTY          => G_PRiCED_QUANTiTY_TBL,
            p_PRiCED_UOM_CODE          => G_line_UOM_CODE_TBL,
            p_CURRENCY_CODE            => G_CURRENCY_CODE_TBL,
            p_UNiT_PRiCE               => G_UNiT_PRiCE_TBL,
            p_PERCENT_PRiCE            => G_PERCENT_PRiCE_TBL,
            p_UOM_QUANTiTY             => G_UOM_QUANTiTY_TBL,
            p_ADJUSTED_UNiT_PRiCE      => G_ADJUSTED_UNiT_PRiCE_TBL,
            p_UPD_ADJUSTED_UNiT_PRiCE  => G_UPD_ADJUSTED_UNiT_PRiCE_TBL,
            p_PROCESSED_FLAG           => G_PROCESSED_FLAG_TBL,
            p_PRiCE_FLAG               => G_PRiCE_FLAG_TBL,
            p_LiNE_iD                  => G_LiNE_iD_TBL,
            p_PROCESSiNG_ORDER         => G_PROCESSiNG_ORDER_TBL,
            p_PRiCiNG_STATUS_CODE      => G_PRiCiNG_STATUS_CODE_TBL,
            p_PRiCiNG_STATUS_TEXT      => G_PRiCiNG_STATUS_TEXT_TBL,
            p_ROUNDiNG_FLAG            => G_ROUNDiNG_FLAG_TBL,
            p_ROUNDiNG_FACTOR          => G_ROUNDiNG_FACTOR_TBL,
            p_QUALiFiERS_EXiST_FLAG    => G_QUALiFiERS_EXiST_FLAG_TBL,
            p_PRiCiNG_ATTRS_EXiST_FLAG => G_PRiCiNG_ATTRS_EXiST_FLAG_TBL,
            p_PRiCE_LiST_iD            => G_PRiCE_LiST_iD_TBL,
            p_VALiDATED_FLAG           => G_PL_VALiDATED_FLAG_TBL,
            p_PRiCE_REQUEST_CODE       => G_PRiCE_REQUEST_CODE_TBL,
            p_USAGE_PRiCiNG_TYPE       => G_USAGE_PRiCiNG_TYPE_TBL,
            --p_line_category            => G_LiNE_CATEGORY_TBL,
            x_status_code              => x_return_status,
            x_status_text              => l_return_status_text);



           IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTiLiTY_PVT.debug_message('Return Status ater inserting : '|| x_return_status);
           END IF;

           IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTiLiTY_PVT.debug_message('Return Status text after inserting : '|| l_return_status_text);
           END IF;

             IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 FND_MESSAGE.SET_NAME('PV','PV_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 FND_MESSAGE.SET_NAME('PV','PV_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
	         RAISE FND_API.G_EXC_ERROR;
   	      END IF;


            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTiLiTY_PVT.debug_message('Before pricing engine call');
            END IF;



	    QP_PREQ_PUB.PRICE_REQUEST
		(p_control_rec => l_control_rec,
		 x_return_status => x_return_status,
		 x_return_status_text => l_return_status_text);


	    IF (PV_DEBUG_HIGH_ON) THEN
              PVX_UTiLiTY_PVT.debug_message('Return Status ater pricing call : '|| x_return_status);
            END IF;


            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTiLiTY_PVT.debug_message('Return Status text after pricing call : '|| l_return_status_text);
            END IF;


	     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 FND_MESSAGE.SET_NAME('PV','PV_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
		 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 FND_MESSAGE.SET_NAME('PV','PV_PRICING_ERROR');
                 FND_MESSAGE.SET_TOKEN('ERR_TEXT',l_return_status_text);
                 OE_MSG_PUB.Add;
	         RAISE FND_API.G_EXC_ERROR;
   	      END IF;



          IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTiLiTY_PVT.debug_message('Before retrieving the price from temp table ');
            END IF;



	  open c_price;
	  loop



	     fetch c_price into  l_line_index , l_line_id, l_adjusted_unit_price, l_unit_price, l_LINE_UNIT_PRICE, l_ORDER_UOM_SELLiNG_PRiCE,
	                           l_LINE_AMOUNT, l_EXTENDED_PRICE, l_LiNE_UOM_CODE, l_PRICED_QUANTITY,
				   l_PRICED_UOM_CODE, l_UOM_QUANTITY, l_LINE_TYPE_CODE, l_LiNE_QUANTiTY, l_PRiCiNG_STATUS_CODE,
				   l_PRiCiNG_STATUS_TEXT, l_price_list_header_id, l_currency_code;
  	     exit when c_price%notfound;

	    l_line_has_price_error := l_pricing_status_code <> QP_PREQ_PUB.G_STATUS_NEW AND
                                 l_pricing_status_code <> QP_PREQ_PUB.G_STATUS_UNCHANGED AND
		                 l_pricing_status_code <> QP_PREQ_PUB.G_STATUS_UPDATED;

	    IF(l_line_has_price_error) THEN
	        l_has_price_error := true;
	        IF (l_line_type_code = 'LINE') THEN
	             open c_program_name(l_enrl_req_id_tbl(l_line_index));
		     fetch c_program_name into l_program_name;
                     close c_program_name;

                     IF (PV_DEBUG_HIGH_ON) THEN
                       PVX_UTiLiTY_PVT.debug_message('Pricing Error  for program : ' || l_program_name || ' : ' ||
                                             'Pricing_status_code' || ' : ' || l_pricing_status_code || ' : ' ||
					     ' pricing status text :' || l_PRiCiNG_STATUS_TEXT );
                     END IF;

		     FND_MESSAGE.set_name('PV', 'PV_ERROR_IN_CALC_PRICE');
		     FND_MESSAGE.Set_Token('PROGRAM_NAME', l_program_name);
                     FND_MSG_PUB.add;



		ELSIF (l_line_type_code = 'ORDER') THEN
		     IF (PV_DEBUG_HIGH_ON) THEN
                        PVX_UTiLiTY_PVT.debug_message('Pricing Error  for ORDER LINE : Pricing_status_code' || ' : ' || l_pricing_status_code  || ' : ' ||
					     ' pricing status text :' || l_PRiCiNG_STATUS_TEXT );
                     END IF;

		     FND_MESSAGE.set_name('PV', 'PV_ERROR_IN_CALC_PRICE');
	             FND_MSG_PUB.add;

	       END IF;
	       exit;


            ELSE
	       IF (l_line_type_code = 'LINE') THEN
	        IF (PV_DEBUG_HIGH_ON) THEN
                    PVX_UTiLiTY_PVT.debug_message('Updating : ' || l_line_index || ' : ' || 'Enrl_req_id' || ' : ' ||
                                             l_enrl_req_id_tbl(l_line_index) || ' : ' || 'Price' || ' : '
                                             ||  l_adjusted_unit_price || ' : ' || 'currency' || ' : ' || l_currency_code ||
					     'Price_list' || l_price_list_header_id);
                END IF;

		l_enrl_req_rec.object_version_number :=  l_obj_ver_tbl(l_line_index);
		l_enrl_req_rec.enrl_request_id  := l_enrl_req_id_tbl(l_line_index);
		l_enrl_req_rec.membership_fee := l_adjusted_unit_price;
		l_enrl_req_rec.trans_curr_code  := l_currency_code;


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


	        update pv_pg_enrl_requests
	        set MEMBERSHIP_FEE  = l_adjusted_unit_price , TRANS_CURR_CODE = l_currency_code
	        where enrl_request_id = l_enrl_req_id_tbl(l_line_index);

	       ELSIF (l_line_type_code = 'ORDER') THEN
                  IF (PV_DEBUG_HIGH_ON) THEN
                    PVX_UTiLiTY_PVT.debug_message('ORDER LINE : ' || l_line_index || ' : ' || 'Price' || ' : '
                                             ||  l_adjusted_unit_price || ' : ' || 'currency' || ' : ' || l_currency_code);
                  END IF;

               END IF;
	  END IF;

         END LOOP;

	 IF (l_has_price_error) THEN
            RAISE FND_API.G_EXC_ERROR;
	 END IF;

	 Close c_price;

         IF (PV_DEBUG_HIGH_ON) THEN
           PVX_UTiLiTY_PVT.debug_message('After retrieving the price and updating price information ');
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
          ROLLBACK TO PRICE_REQUEST;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO PRICE_REQUEST;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO PRICE_REQUEST;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

END price_request;

END PV_PRICE_PVT;

/
