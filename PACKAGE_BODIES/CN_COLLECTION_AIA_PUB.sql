--------------------------------------------------------
--  DDL for Package Body CN_COLLECTION_AIA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_COLLECTION_AIA_PUB" AS
  /* $Header: CNPCLTRB.pls 120.1.12010000.15 2009/09/02 12:22:45 rajukum noship $*/
  G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CN_COLLECTION_AIA_PUB';
  G_FILE_NAME CONSTANT VARCHAR2(12) := 'CNPCLTRB.pls';
  g_cn_debug  VARCHAR2(1)           := fnd_profile.value('CN_DEBUG');
  g_error_msg VARCHAR2(100)         := ' is a required field. Please enter the value for it.';


PROCEDURE debugmsg
  (
    msg VARCHAR2)
IS
BEGIN
  IF g_cn_debug = 'Y' THEN
    cn_message_pkg.debug(SUBSTR(msg,1,254));
    fnd_file.put_line(fnd_file.Log, msg); -- Bug fix 5125980
  END IF;
  -- comment out dbms_output before checking in file
  -- dbms_output.put_line(substr(msg,1,254));
END debugmsg;

-- API name  : loadrow_om
-- Type : public.
-- Pre-reqs :
-- Usage : This particular api will be called by above load row api for collection of siebel order management records.

PROCEDURE loadrow_om
  (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2:= FND_API.G_FALSE,
    p_commit                    IN VARCHAR2:= FND_API.G_FALSE,
    p_aia_rec_tbl               IN CN_COLLECTION_AIA_PUB.aia_rec_tbl_type,
    p_org_id                    IN NUMBER,
    x_msg_count OUT nocopy     NUMBER,
    x_msg_data OUT nocopy      VARCHAR2,
    x_return_status OUT nocopy VARCHAR2 )
                                   IS
  l_api_name        CONSTANT VARCHAR2(30) := 'loadrow';
  l_api_version     CONSTANT NUMBER       :=1.0;
  l_error_msg       VARCHAR(240);
  --x_org_id          NUMBER;
  l_update_flag     VARCHAR2(10) := 'N';
  l_salesrep_number VARCHAR2(30) := '_';
  l_employee_number VARCHAR2(30) := '_';
  l_salesrep_id     NUMBER       := -1;
  l_trans_seq_num   NUMBER       := 0;
  l_update_check    NUMBER       := -1;
  l_counter         NUMBER;
  l_invoice_date DATE            := sysdate;


  CURSOR get_res_num_from_src_num(p_employee_number varchar2)
  IS
      SELECT employee_number
       FROM cn_salesreps
      WHERE resource_id IN
      (SELECT resource_id
         FROM jtf_rs_resource_extns
        WHERE source_number = p_employee_number
      );

  CURSOR get_salesrep_from_res_num(p_employee_number varchar2)
  IS
     SELECT salesrep_id
       FROM cn_salesreps
      WHERE resource_id IN
      (SELECT resource_id
         FROM jtf_rs_resource_extns
        WHERE source_number = p_employee_number
      );

  CURSOR get_res_num_from_salesrep(p_salesrep_id number)
  IS
     SELECT employee_number FROM cn_salesreps WHERE salesrep_id = p_salesrep_id;

  CURSOR get_src_num_from_salesrep(p_salesrep_id number)
  IS
     SELECT source_number
       FROM jtf_rs_resource_extns
      WHERE resource_id IN
      ( SELECT resource_id FROM cn_salesreps WHERE salesrep_id = p_salesrep_id
      ) ;

  CURSOR check_order_number(p_order_number varchar2)
  IS
     SELECT 'Y' FLAG,
      TRANS_SEQ_ID
       FROM CN_COLLECTION_AIA
      WHERE ORDER_NUMBER = p_order_number
    AND rownum             = 1;

  CURSOR check_not_trx(l_trans_seq_num number,p_org_id number)
  IS
     SELECT 1 FLAG
       FROM cn_not_trx
      WHERE source_trx_line_id = l_trans_seq_num --*** Line.Primary_Key
    AND event_id               = -1020
    AND org_id                 = p_org_id;

  l_resnum_srcnum_cr get_res_num_from_src_num%ROWTYPE;
  l_salesrep_resnum_cr get_salesrep_from_res_num%ROWTYPE;
  l_resnum_salesrep_cr get_res_num_from_salesrep%ROWTYPE;
  l_srcnum_salesrep_cr get_src_num_from_salesrep%ROWTYPE;
  l_order_num_cr check_order_number%ROWTYPE;
  l_not_trx_cr check_not_trx%ROWTYPE;

BEGIN
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: start ');
  x_msg_data  := '_';
  x_msg_count := 0;
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_api_version: ' || l_api_version);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_api_name: ' || l_api_name);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: G_PKG_NAME: ' || G_PKG_NAME);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_org_id: ' || p_org_id);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_api_version: ' || p_api_version);

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
  IF NOT FND_API.Compatible_API_Call ( l_api_version , p_api_version , l_api_name , G_PKG_NAME ) THEN
    x_return_status := 'F';
    x_msg_count := 1;
    l_error_msg           := 'p_api_version' || g_error_msg;
    debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
    RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
  END IF;

  IF(p_org_id IS NULL) THEN
    x_return_status := 'F';
    x_msg_count := 1;
    l_error_msg           := 'p_org_id' || g_error_msg;
    debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
    RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
  END IF;

  -- Codes start here
  --x_org_id := mo_global.get_current_org_id;
  --DBMS_OUTPUT.put_line('p_org_id ' || p_org_id);
  mo_global.set_policy_context('S',p_org_id);

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_aia_rec_tbl.COUNT = 0
   THEN
     x_return_status := 'F';
     x_msg_count := 1;
     l_error_msg           := 'p_aia_rec_tbl' || g_error_msg;
     debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
     RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
     RETURN;
   END IF;

   FOR l_counter IN 1 .. p_aia_rec_tbl.COUNT
   LOOP
     begin
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_salesrep_id: ' || p_aia_rec_tbl(l_counter).SALESREP_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_employee_number: ' || p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_processed_date: ' || p_aia_rec_tbl(l_counter).PROCESSED_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_invoice_number: ' || p_aia_rec_tbl(l_counter).INVOICE_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_invoice_date: ' || p_aia_rec_tbl(l_counter).INVOICE_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_transaction_amount: ' || p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_transaction_currency_code: ' || p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_trx_type: ' || p_aia_rec_tbl(l_counter).TRX_TYPE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_revenue_type: ' || p_aia_rec_tbl(l_counter).REVENUE_TYPE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_adjust_comments: ' || p_aia_rec_tbl(l_counter).ADJUST_COMMENTS);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: p_source_doc_id: ' || p_aia_rec_tbl(l_counter).SOURCE_DOC_ID);


      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: SALES_CHANNEL: ' || p_aia_rec_tbl(l_counter).SALES_CHANNEL);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: LINE_NUMBER: ' || p_aia_rec_tbl(l_counter).LINE_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: REASON_CODE: ' || p_aia_rec_tbl(l_counter).REASON_CODE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: ATTRIBUTE_CATEGORY: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE_CATEGORY);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: ADJUST_DATE: ' || p_aia_rec_tbl(l_counter).ADJUST_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: ADJUSTED_BY: ' || p_aia_rec_tbl(l_counter).ADJUSTED_BY);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: BILL_TO_ADDRESS_ID: ' || p_aia_rec_tbl(l_counter).BILL_TO_ADDRESS_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: SHIP_TO_ADDRESS_ID: ' || p_aia_rec_tbl(l_counter).SHIP_TO_ADDRESS_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: BILL_TO_CONTACT_ID: ' || p_aia_rec_tbl(l_counter).BILL_TO_CONTACT_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: SHIP_TO_CONTACT_ID: ' || p_aia_rec_tbl(l_counter).SHIP_TO_CONTACT_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: CUSTOMER_ID: ' || p_aia_rec_tbl(l_counter).CUSTOMER_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: INVENTORY_ITEM_ID: ' || p_aia_rec_tbl(l_counter).INVENTORY_ITEM_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: ORDER_NUMBER: ' || p_aia_rec_tbl(l_counter).ORDER_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: BOOKED_DATE: ' || p_aia_rec_tbl(l_counter).BOOKED_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: SOURCE_TRX_NUMBER: ' || p_aia_rec_tbl(l_counter).SOURCE_TRX_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: DISCOUNT_PERCENTAGE: ' || p_aia_rec_tbl(l_counter).DISCOUNT_PERCENTAGE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: MARGIN_PERCENTAGE: ' || p_aia_rec_tbl(l_counter).MARGIN_PERCENTAGE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: EXCHANGE_RATE: ' || p_aia_rec_tbl(l_counter).EXCHANGE_RATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: TYPE: ' || p_aia_rec_tbl(l_counter).TYPE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: SOURCE_TRX_SALES_LINE_ID: ' || p_aia_rec_tbl(l_counter).SOURCE_TRX_SALES_LINE_ID);


      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute1 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE1 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute2 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE2 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute3 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE3 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute4 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE4 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute5 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE5 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute6 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE6 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute7 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE7 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute8 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE8 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute9 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE9 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute10: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE10 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute11: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE11 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute12: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE12 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute13: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE13 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute14: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE14 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute15: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE15 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute16: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE16 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute17: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE17 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute18: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE18 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute19: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE19 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute20: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE20 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute21: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE21 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute22: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE22 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute23: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE23 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute24: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE24 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute25: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE25 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute26: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE26 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute27: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE27 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute28: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE28 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute29: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE29 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute30: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE30 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute31: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE31 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute32: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE32 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute33: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE33 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute34: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE34 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute35: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE35 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute36: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE36 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute37: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE37 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute38: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE38 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute39: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE39 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute40: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE40 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute41: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE41 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute42: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE42 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute43: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE43 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute44: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE44 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute45: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE45 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute46: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE46 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute47: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE47 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute48: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE48 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute49: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE49 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute50: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE50 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute51: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE51 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute52: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE52 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute53: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE53 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute54: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE54 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute55: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE55 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute56: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE56 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute57: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE57 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute58: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE58 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute59: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE59 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute60: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE60 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute61: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE61 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute62: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE62 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute63: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE63 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute64: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE64 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute65: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE65 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute66: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE66 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute67: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE67 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute68: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE68 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute69: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE69 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute70: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE70 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute71: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE71 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute72: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE72 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute73: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE73 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute74: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE74 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute75: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE75 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute76: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE76 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute77: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE77 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute78: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE78 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute79: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE79 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute80: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE80 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute81: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE81 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute82: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE82 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute83: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE83 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute84: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE84 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute85: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE85 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute86: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE86 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute87: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE87 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute88: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE88 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute89: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE89 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute90: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE90 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute91: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE91 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute92: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE92 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute93: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE93 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute94: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE94 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute95: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE95 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute96: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE96 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute97: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE97 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute98: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE98 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute99: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE99 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:p_attribute100: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE100);
      EXCEPTION
        WHEN OTHERS THEN
        --x_return_status := 'F';
        --DBMS_OUTPUT.put_line('CN_COLLECTION_AIA_PUB.loadrow_om:exception in debug messages others: ' || '[ ' || SQLERRM(SQLCODE()) || ' ]');
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om:exception in debug messages others: ' || SQLERRM(SQLCODE()) );
      end;

      x_msg_data  :=  p_aia_rec_tbl(l_counter).ORDER_NUMBER ;
      l_update_check    := -1;
      l_update_flag     := 'N';
      l_salesrep_number := '_';
      l_employee_number := '_';
      l_salesrep_id     := -1;
      l_trans_seq_num   := 0;


      --Mandatory fields validation starts here
      IF(p_aia_rec_tbl(l_counter).PROCESSED_DATE IS NULL or
          p_aia_rec_tbl(l_counter).PROCESSED_DATE = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg       := 'p_processed_date' || g_error_msg;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;

      IF(p_aia_rec_tbl(l_counter).ORDER_NUMBER IS NULL or
          p_aia_rec_tbl(l_counter).ORDER_NUMBER = G_LOC_MISS_NUM) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg       := 'p_order_number' || g_error_msg;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;

      IF(p_aia_rec_tbl(l_counter).BOOKED_DATE IS NULL or
          p_aia_rec_tbl(l_counter).BOOKED_DATE = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg     := 'p_booked_date' || g_error_msg;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;

      IF(p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT IS NULL or
          p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT = G_LOC_MISS_NUM) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg           := 'p_transaction_amount' || g_error_msg;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;

      IF(p_aia_rec_tbl(l_counter).SALESREP_ID IS NULL AND p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER IS NULL
      AND p_aia_rec_tbl(l_counter).SALESREP_ID = G_LOC_MISS_NUM AND p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg    := 'Any one of p_salesrep_id or p_employee_number' || g_error_msg;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;



      IF(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER     IS NOT NULL and p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER <> FND_API.G_MISS_CHAR) THEN
        FOR l_resnum_srcnum_cr IN get_res_num_from_src_num(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER)
        LOOP
          l_salesrep_number := l_resnum_srcnum_cr.employee_number;
        END LOOP;
        --DBMS_OUTPUT.put_line('l_salesrep_number ' || l_salesrep_number);
        FOR l_salesrep_resnum_cr IN get_salesrep_from_res_num(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER)
        LOOP
          l_salesrep_id := l_salesrep_resnum_cr.salesrep_id;
        END LOOP;
        --DBMS_OUTPUT.put_line('l_salesrep_id ' || l_salesrep_id);
        l_employee_number          := p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER;
        IF(l_salesrep_id            = -1) THEN
          l_salesrep_number        := '_';
          l_employee_number        := '_';
          FOR l_resnum_salesrep_cr IN get_res_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
          LOOP
            l_salesrep_number := l_resnum_salesrep_cr.employee_number;
          END LOOP;
          FOR l_srcnum_salesrep_cr IN get_src_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
          LOOP
            l_employee_number := l_srcnum_salesrep_cr.source_number;
          END LOOP;
          IF(l_employee_number <> '_') THEN
            l_salesrep_id      := p_aia_rec_tbl(l_counter).SALESREP_ID;
          END IF;
        END IF;
      ELSE
        FOR l_resnum_salesrep_cr IN get_res_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
        LOOP
          l_salesrep_number := l_resnum_salesrep_cr.employee_number;
        END LOOP;
        FOR l_srcnum_salesrep_cr IN get_src_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
        LOOP
          l_employee_number := l_srcnum_salesrep_cr.source_number;
        END LOOP;
        IF(l_employee_number <> '_') THEN
          l_salesrep_id      := p_aia_rec_tbl(l_counter).SALESREP_ID;
        END IF;
      END IF;

      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_salesrep_number: ' || l_salesrep_number);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_salesrep_id: ' || l_salesrep_id);
      IF(l_salesrep_id = -1) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_error_msg   := 'Please enter valid value for either of p_salesrep_id or p_employee_number ';
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
      END IF;

      FOR l_order_num_cr IN check_order_number(p_aia_rec_tbl(l_counter).ORDER_NUMBER)
      LOOP
        l_update_flag   := l_order_num_cr.FLAG;
        l_trans_seq_num := l_order_num_cr.TRANS_SEQ_ID;
      END LOOP;
    --DBMS_OUTPUT.put_line('CN_COLLECTION_AIA_PUB.loadrow_om api: l_update_flag: ' || l_update_flag);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_update_flag: ' || l_update_flag);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_trans_seq_num: ' || l_trans_seq_num);

      IF(l_update_flag = 'N') THEN
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: insert start ');
         INSERT
           INTO CN_COLLECTION_AIA
          (
            TRANS_SEQ_ID             ,
            SALESREP_ID              ,
            EMPLOYEE_NUMBER          ,
            PROCESSED_DATE           ,
            INVOICE_NUMBER           ,
            INVOICE_DATE             ,
            TRANSACTION_AMOUNT       ,
            TRANSACTION_CURRENCY_CODE,
            TRX_TYPE                 ,
            REVENUE_TYPE             ,
            SALESREP_NUMBER          ,
            ADJUST_COMMENTS          ,
            ADJUST_STATUS            ,
            SOURCE_DOC_ID            ,
            UPDATE_FLAG              ,
            SALES_CHANNEL            ,
            LINE_NUMBER              ,
            REASON_CODE              ,
            ATTRIBUTE_CATEGORY       ,
            ADJUST_DATE              ,
            ADJUSTED_BY              ,
            BILL_TO_ADDRESS_ID       ,
            SHIP_TO_ADDRESS_ID       ,
            BILL_TO_CONTACT_ID       ,
            SHIP_TO_CONTACT_ID       ,
            CUSTOMER_ID              ,
            INVENTORY_ITEM_ID        ,
            ORDER_NUMBER             ,
            BOOKED_DATE              ,
            SOURCE_TRX_NUMBER        ,
            DISCOUNT_PERCENTAGE      ,
            MARGIN_PERCENTAGE        ,
            EXCHANGE_RATE            ,
            TYPE                     ,
            SOURCE_TRX_SALES_LINE_ID ,
            ORG_ID                   ,
            ATTRIBUTE1               ,
            ATTRIBUTE2               ,
            ATTRIBUTE3               ,
            ATTRIBUTE4               ,
            ATTRIBUTE5               ,
            ATTRIBUTE6               ,
            ATTRIBUTE7               ,
            ATTRIBUTE8               ,
            ATTRIBUTE9               ,
            ATTRIBUTE10              ,
            ATTRIBUTE11              ,
            ATTRIBUTE12              ,
            ATTRIBUTE13              ,
            ATTRIBUTE14              ,
            ATTRIBUTE15              ,
            ATTRIBUTE16              ,
            ATTRIBUTE17              ,
            ATTRIBUTE18              ,
            ATTRIBUTE19              ,
            ATTRIBUTE20              ,
            ATTRIBUTE21              ,
            ATTRIBUTE22              ,
            ATTRIBUTE23              ,
            ATTRIBUTE24              ,
            ATTRIBUTE25              ,
            ATTRIBUTE26              ,
            ATTRIBUTE27              ,
            ATTRIBUTE28              ,
            ATTRIBUTE29              ,
            ATTRIBUTE30              ,
            ATTRIBUTE31              ,
            ATTRIBUTE32              ,
            ATTRIBUTE33              ,
            ATTRIBUTE34              ,
            ATTRIBUTE35              ,
            ATTRIBUTE36              ,
            ATTRIBUTE37              ,
            ATTRIBUTE38              ,
            ATTRIBUTE39              ,
            ATTRIBUTE40              ,
            ATTRIBUTE41              ,
            ATTRIBUTE42              ,
            ATTRIBUTE43              ,
            ATTRIBUTE44              ,
            ATTRIBUTE45              ,
            ATTRIBUTE46              ,
            ATTRIBUTE47              ,
            ATTRIBUTE48              ,
            ATTRIBUTE49              ,
            ATTRIBUTE50              ,
            ATTRIBUTE51              ,
            ATTRIBUTE52              ,
            ATTRIBUTE53              ,
            ATTRIBUTE54              ,
            ATTRIBUTE55              ,
            ATTRIBUTE56              ,
            ATTRIBUTE57              ,
            ATTRIBUTE58              ,
            ATTRIBUTE59              ,
            ATTRIBUTE60              ,
            ATTRIBUTE61              ,
            ATTRIBUTE62              ,
            ATTRIBUTE63              ,
            ATTRIBUTE64              ,
            ATTRIBUTE65              ,
            ATTRIBUTE66              ,
            ATTRIBUTE67              ,
            ATTRIBUTE68              ,
            ATTRIBUTE69              ,
            ATTRIBUTE70              ,
            ATTRIBUTE71              ,
            ATTRIBUTE72              ,
            ATTRIBUTE73              ,
            ATTRIBUTE74              ,
            ATTRIBUTE75              ,
            ATTRIBUTE76              ,
            ATTRIBUTE77              ,
            ATTRIBUTE78              ,
            ATTRIBUTE79              ,
            ATTRIBUTE80              ,
            ATTRIBUTE81              ,
            ATTRIBUTE82              ,
            ATTRIBUTE83              ,
            ATTRIBUTE84              ,
            ATTRIBUTE85              ,
            ATTRIBUTE86              ,
            ATTRIBUTE87              ,
            ATTRIBUTE88              ,
            ATTRIBUTE89              ,
            ATTRIBUTE90              ,
            ATTRIBUTE91              ,
            ATTRIBUTE92              ,
            ATTRIBUTE93              ,
            ATTRIBUTE94              ,
            ATTRIBUTE95              ,
            ATTRIBUTE96              ,
            ATTRIBUTE97              ,
            ATTRIBUTE98              ,
            ATTRIBUTE99              ,
            ATTRIBUTE100
          )
                VALUES
          (
            CN_COLLECTION_AIA_S.NextVal                        ,
            l_salesrep_id                                      ,
            l_employee_number                                  ,
            to_date(p_aia_rec_tbl(l_counter).PROCESSED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
            p_aia_rec_tbl(l_counter).INVOICE_NUMBER            ,
            decode(p_aia_rec_tbl(l_counter).INVOICE_DATE, FND_API.G_MISS_CHAR, null, to_date(p_aia_rec_tbl(l_counter).INVOICE_DATE, 'dd/mm/yyyy hh24:mi:ss')),
            p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT        ,
            p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE ,
            'AIA_OM'                  ,
            decode(p_aia_rec_tbl(l_counter).REVENUE_TYPE, FND_API.G_MISS_CHAR, 'REVENUE', p_aia_rec_tbl(l_counter).REVENUE_TYPE),
            l_salesrep_number                                  ,
            p_aia_rec_tbl(l_counter).ADJUST_COMMENTS           ,
            'MANUAL'                                           ,
            p_aia_rec_tbl(l_counter).SOURCE_DOC_ID             ,
            l_update_flag                                      ,
            p_aia_rec_tbl(l_counter).SALES_CHANNEL             ,
            p_aia_rec_tbl(l_counter).LINE_NUMBER               ,
            p_aia_rec_tbl(l_counter).REASON_CODE               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE_CATEGORY        ,
            decode(p_aia_rec_tbl(l_counter).ADJUST_DATE, FND_API.G_MISS_CHAR, null, to_date(p_aia_rec_tbl(l_counter).ADJUST_DATE, 'dd/mm/yyyy hh24:mi:ss')),
            p_aia_rec_tbl(l_counter).ADJUSTED_BY               ,
            p_aia_rec_tbl(l_counter).BILL_TO_ADDRESS_ID        ,
            p_aia_rec_tbl(l_counter).SHIP_TO_ADDRESS_ID        ,
            p_aia_rec_tbl(l_counter).BILL_TO_CONTACT_ID        ,
            p_aia_rec_tbl(l_counter).SHIP_TO_CONTACT_ID        ,
            p_aia_rec_tbl(l_counter).CUSTOMER_ID               ,
            p_aia_rec_tbl(l_counter).INVENTORY_ITEM_ID         ,
            p_aia_rec_tbl(l_counter).ORDER_NUMBER              ,
            to_date(p_aia_rec_tbl(l_counter).BOOKED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
            p_aia_rec_tbl(l_counter).SOURCE_TRX_NUMBER         ,
            p_aia_rec_tbl(l_counter).DISCOUNT_PERCENTAGE       ,
            p_aia_rec_tbl(l_counter).MARGIN_PERCENTAGE         ,
            p_aia_rec_tbl(l_counter).EXCHANGE_RATE             ,
            p_aia_rec_tbl(l_counter).TYPE                      ,
            p_aia_rec_tbl(l_counter).SOURCE_TRX_SALES_LINE_ID  ,
            p_org_id                                           ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE1                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE2                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE3                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE4                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE5                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE6                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE7                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE8                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE9                ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE10               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE11               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE12               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE13               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE14               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE15               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE16               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE17               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE18               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE19               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE20               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE21               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE22               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE23               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE24               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE25               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE26               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE27               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE28               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE29               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE30               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE31               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE32               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE33               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE34               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE35               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE36               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE37               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE38               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE39               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE40               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE41               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE42               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE43               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE44               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE45               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE46               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE47               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE48               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE49               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE50               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE51               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE52               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE53               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE54               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE55               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE56               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE57               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE58               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE59               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE60               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE61               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE62               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE63               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE64               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE65               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE66               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE67               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE68               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE69               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE70               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE71               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE72               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE73               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE74               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE75               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE76               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE77               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE78               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE79               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE80               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE81               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE82               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE83               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE84               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE85               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE86               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE87               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE88               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE89               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE90               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE91               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE92               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE93               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE94               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE95               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE96               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE97               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE98               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE99               ,
            p_aia_rec_tbl(l_counter).ATTRIBUTE100
          );

        IF fnd_api.to_boolean
          (
            p_commit
          )
          THEN
          COMMIT;
        END IF;

        x_msg_count := 1;

        debugmsg
        (
          'CN_COLLECTION_AIA_PUB.loadrow_om api:  ' || 'INSERTED ORDER NUMBER' || ' '
          || p_aia_rec_tbl(l_counter).ORDER_NUMBER
        )
        ;
      ELSE
        -- This step will check that if this transaction has already been collected then update flag should be 'Y'
        -- else it should be 'N'. Here l_update_check is initialized to -1. If order number exists then it will go
        -- to this else part and here it will check wether this has been collected. If yes then l_update_check = 'Y'
        FOR l_not_trx_cr IN check_not_trx(l_trans_seq_num, p_org_id)
        LOOP
          l_update_check := l_order_num_cr.FLAG;
        END LOOP;

        debugmsg
        (
          'CN_COLLECTION_AIA_PUB.loadrow_om api: l_update_check(in table cn_not_trx): ' || l_update_check
        )
        ;
        -- Since this order number has not been collected. so l_update_check = 'Y'
        IF
          (
            l_update_check = -1
          )
          THEN
          l_update_flag := 'N';
        END IF;
        debugmsg
        (
          'CN_COLLECTION_AIA_PUB.loadrow_om api: l_update_flag: ' || l_update_flag
        )
        ;
        debugmsg
        (
          'CN_COLLECTION_AIA_PUB.loadrow_om api: update process start '
        )
        ;
         UPDATE CN_COLLECTION_AIA
        SET SALESREP_ID             =l_salesrep_id               ,
          EMPLOYEE_NUMBER           =l_employee_number           ,
          PROCESSED_DATE            =to_date(p_aia_rec_tbl(l_counter).PROCESSED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
          INVOICE_DATE              =decode(p_aia_rec_tbl(l_counter).INVOICE_DATE, FND_API.G_MISS_CHAR, null, to_date(p_aia_rec_tbl(l_counter).INVOICE_DATE, 'dd/mm/yyyy hh24:mi:ss')),
          TRANSACTION_AMOUNT        =p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT        ,
          TRANSACTION_CURRENCY_CODE =p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE ,
          TRX_TYPE                  ='AIA_OM'                  ,
          REVENUE_TYPE              =decode(p_aia_rec_tbl(l_counter).REVENUE_TYPE, FND_API.G_MISS_CHAR, 'REVENUE',
                                        p_aia_rec_tbl(l_counter).REVENUE_TYPE)          ,
          SALESREP_NUMBER           =l_salesrep_number                                  ,
          ADJUST_COMMENTS           =p_aia_rec_tbl(l_counter).ADJUST_COMMENTS           ,
          ADJUST_STATUS             ='MANUAL'                                           ,
          SOURCE_DOC_ID             =p_aia_rec_tbl(l_counter).SOURCE_DOC_ID             ,
          UPDATE_FLAG               =l_update_flag                                      ,
          SALES_CHANNEL             =p_aia_rec_tbl(l_counter).SALES_CHANNEL             ,
          LINE_NUMBER               =p_aia_rec_tbl(l_counter).LINE_NUMBER               ,
          REASON_CODE               =p_aia_rec_tbl(l_counter).REASON_CODE               ,
          ATTRIBUTE_CATEGORY        =p_aia_rec_tbl(l_counter).ATTRIBUTE_CATEGORY        ,
          ADJUST_DATE               =decode(p_aia_rec_tbl(l_counter).ADJUST_DATE, FND_API.G_MISS_CHAR, null, to_date(p_aia_rec_tbl(l_counter).ADJUST_DATE, 'dd/mm/yyyy hh24:mi:ss')),
          ADJUSTED_BY               =p_aia_rec_tbl(l_counter).ADJUSTED_BY               ,
          BILL_TO_ADDRESS_ID        =p_aia_rec_tbl(l_counter).BILL_TO_ADDRESS_ID        ,
          SHIP_TO_ADDRESS_ID        =p_aia_rec_tbl(l_counter).SHIP_TO_ADDRESS_ID        ,
          BILL_TO_CONTACT_ID        =p_aia_rec_tbl(l_counter).BILL_TO_CONTACT_ID        ,
          SHIP_TO_CONTACT_ID        =p_aia_rec_tbl(l_counter).SHIP_TO_CONTACT_ID        ,
          CUSTOMER_ID               =p_aia_rec_tbl(l_counter).CUSTOMER_ID               ,
          INVENTORY_ITEM_ID         =p_aia_rec_tbl(l_counter).INVENTORY_ITEM_ID         ,
          ORDER_NUMBER              =p_aia_rec_tbl(l_counter).ORDER_NUMBER              ,
          BOOKED_DATE               =to_date(p_aia_rec_tbl(l_counter).BOOKED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
          SOURCE_TRX_NUMBER         =p_aia_rec_tbl(l_counter).SOURCE_TRX_NUMBER         ,
          DISCOUNT_PERCENTAGE       =p_aia_rec_tbl(l_counter).DISCOUNT_PERCENTAGE       ,
          MARGIN_PERCENTAGE         =p_aia_rec_tbl(l_counter).MARGIN_PERCENTAGE         ,
          EXCHANGE_RATE             =p_aia_rec_tbl(l_counter).EXCHANGE_RATE             ,
          TYPE                      =p_aia_rec_tbl(l_counter).TYPE                      ,
          SOURCE_TRX_SALES_LINE_ID  =p_aia_rec_tbl(l_counter).SOURCE_TRX_SALES_LINE_ID  ,
          ORG_ID                    =p_org_id                                           ,
          ATTRIBUTE1                =p_aia_rec_tbl(l_counter).ATTRIBUTE1                ,
          ATTRIBUTE2                =p_aia_rec_tbl(l_counter).ATTRIBUTE2                ,
          ATTRIBUTE3                =p_aia_rec_tbl(l_counter).ATTRIBUTE3                ,
          ATTRIBUTE4                =p_aia_rec_tbl(l_counter).ATTRIBUTE4                ,
          ATTRIBUTE5                =p_aia_rec_tbl(l_counter).ATTRIBUTE5                ,
          ATTRIBUTE6                =p_aia_rec_tbl(l_counter).ATTRIBUTE6                ,
          ATTRIBUTE7                =p_aia_rec_tbl(l_counter).ATTRIBUTE7                ,
          ATTRIBUTE8                =p_aia_rec_tbl(l_counter).ATTRIBUTE8                ,
          ATTRIBUTE9                =p_aia_rec_tbl(l_counter).ATTRIBUTE9                ,
          ATTRIBUTE10               =p_aia_rec_tbl(l_counter).ATTRIBUTE10               ,
          ATTRIBUTE11               =p_aia_rec_tbl(l_counter).ATTRIBUTE11               ,
          ATTRIBUTE12               =p_aia_rec_tbl(l_counter).ATTRIBUTE12               ,
          ATTRIBUTE13               =p_aia_rec_tbl(l_counter).ATTRIBUTE13               ,
          ATTRIBUTE14               =p_aia_rec_tbl(l_counter).ATTRIBUTE14               ,
          ATTRIBUTE15               =p_aia_rec_tbl(l_counter).ATTRIBUTE15               ,
          ATTRIBUTE16               =p_aia_rec_tbl(l_counter).ATTRIBUTE16               ,
          ATTRIBUTE17               =p_aia_rec_tbl(l_counter).ATTRIBUTE17               ,
          ATTRIBUTE18               =p_aia_rec_tbl(l_counter).ATTRIBUTE18               ,
          ATTRIBUTE19               =p_aia_rec_tbl(l_counter).ATTRIBUTE19               ,
          ATTRIBUTE20               =p_aia_rec_tbl(l_counter).ATTRIBUTE20               ,
          ATTRIBUTE21               =p_aia_rec_tbl(l_counter).ATTRIBUTE21               ,
          ATTRIBUTE22               =p_aia_rec_tbl(l_counter).ATTRIBUTE22               ,
          ATTRIBUTE23               =p_aia_rec_tbl(l_counter).ATTRIBUTE23               ,
          ATTRIBUTE24               =p_aia_rec_tbl(l_counter).ATTRIBUTE24               ,
          ATTRIBUTE25               =p_aia_rec_tbl(l_counter).ATTRIBUTE25               ,
          ATTRIBUTE26               =p_aia_rec_tbl(l_counter).ATTRIBUTE26               ,
          ATTRIBUTE27               =p_aia_rec_tbl(l_counter).ATTRIBUTE27               ,
          ATTRIBUTE28               =p_aia_rec_tbl(l_counter).ATTRIBUTE28               ,
          ATTRIBUTE29               =p_aia_rec_tbl(l_counter).ATTRIBUTE29               ,
          ATTRIBUTE30               =p_aia_rec_tbl(l_counter).ATTRIBUTE30               ,
          ATTRIBUTE31               =p_aia_rec_tbl(l_counter).ATTRIBUTE31               ,
          ATTRIBUTE32               =p_aia_rec_tbl(l_counter).ATTRIBUTE32               ,
          ATTRIBUTE33               =p_aia_rec_tbl(l_counter).ATTRIBUTE33               ,
          ATTRIBUTE34               =p_aia_rec_tbl(l_counter).ATTRIBUTE34               ,
          ATTRIBUTE35               =p_aia_rec_tbl(l_counter).ATTRIBUTE35               ,
          ATTRIBUTE36               =p_aia_rec_tbl(l_counter).ATTRIBUTE36               ,
          ATTRIBUTE37               =p_aia_rec_tbl(l_counter).ATTRIBUTE37               ,
          ATTRIBUTE38               =p_aia_rec_tbl(l_counter).ATTRIBUTE38               ,
          ATTRIBUTE39               =p_aia_rec_tbl(l_counter).ATTRIBUTE39               ,
          ATTRIBUTE40               =p_aia_rec_tbl(l_counter).ATTRIBUTE40               ,
          ATTRIBUTE41               =p_aia_rec_tbl(l_counter).ATTRIBUTE41               ,
          ATTRIBUTE42               =p_aia_rec_tbl(l_counter).ATTRIBUTE42               ,
          ATTRIBUTE43               =p_aia_rec_tbl(l_counter).ATTRIBUTE43               ,
          ATTRIBUTE44               =p_aia_rec_tbl(l_counter).ATTRIBUTE44               ,
          ATTRIBUTE45               =p_aia_rec_tbl(l_counter).ATTRIBUTE45               ,
          ATTRIBUTE46               =p_aia_rec_tbl(l_counter).ATTRIBUTE46               ,
          ATTRIBUTE47               =p_aia_rec_tbl(l_counter).ATTRIBUTE47               ,
          ATTRIBUTE48               =p_aia_rec_tbl(l_counter).ATTRIBUTE48               ,
          ATTRIBUTE49               =p_aia_rec_tbl(l_counter).ATTRIBUTE49               ,
          ATTRIBUTE50               =p_aia_rec_tbl(l_counter).ATTRIBUTE50               ,
          ATTRIBUTE51               =p_aia_rec_tbl(l_counter).ATTRIBUTE51               ,
          ATTRIBUTE52               =p_aia_rec_tbl(l_counter).ATTRIBUTE52               ,
          ATTRIBUTE53               =p_aia_rec_tbl(l_counter).ATTRIBUTE53               ,
          ATTRIBUTE54               =p_aia_rec_tbl(l_counter).ATTRIBUTE54               ,
          ATTRIBUTE55               =p_aia_rec_tbl(l_counter).ATTRIBUTE55               ,
          ATTRIBUTE56               =p_aia_rec_tbl(l_counter).ATTRIBUTE56               ,
          ATTRIBUTE57               =p_aia_rec_tbl(l_counter).ATTRIBUTE57               ,
          ATTRIBUTE58               =p_aia_rec_tbl(l_counter).ATTRIBUTE58               ,
          ATTRIBUTE59               =p_aia_rec_tbl(l_counter).ATTRIBUTE59               ,
          ATTRIBUTE60               =p_aia_rec_tbl(l_counter).ATTRIBUTE60               ,
          ATTRIBUTE61               =p_aia_rec_tbl(l_counter).ATTRIBUTE61               ,
          ATTRIBUTE62               =p_aia_rec_tbl(l_counter).ATTRIBUTE62               ,
          ATTRIBUTE63               =p_aia_rec_tbl(l_counter).ATTRIBUTE63               ,
          ATTRIBUTE64               =p_aia_rec_tbl(l_counter).ATTRIBUTE64               ,
          ATTRIBUTE65               =p_aia_rec_tbl(l_counter).ATTRIBUTE65               ,
          ATTRIBUTE66               =p_aia_rec_tbl(l_counter).ATTRIBUTE66               ,
          ATTRIBUTE67               =p_aia_rec_tbl(l_counter).ATTRIBUTE67               ,
          ATTRIBUTE68               =p_aia_rec_tbl(l_counter).ATTRIBUTE68               ,
          ATTRIBUTE69               =p_aia_rec_tbl(l_counter).ATTRIBUTE69               ,
          ATTRIBUTE70               =p_aia_rec_tbl(l_counter).ATTRIBUTE70               ,
          ATTRIBUTE71               =p_aia_rec_tbl(l_counter).ATTRIBUTE71               ,
          ATTRIBUTE72               =p_aia_rec_tbl(l_counter).ATTRIBUTE72               ,
          ATTRIBUTE73               =p_aia_rec_tbl(l_counter).ATTRIBUTE73               ,
          ATTRIBUTE74               =p_aia_rec_tbl(l_counter).ATTRIBUTE74               ,
          ATTRIBUTE75               =p_aia_rec_tbl(l_counter).ATTRIBUTE75               ,
          ATTRIBUTE76               =p_aia_rec_tbl(l_counter).ATTRIBUTE76               ,
          ATTRIBUTE77               =p_aia_rec_tbl(l_counter).ATTRIBUTE77               ,
          ATTRIBUTE78               =p_aia_rec_tbl(l_counter).ATTRIBUTE78               ,
          ATTRIBUTE79               =p_aia_rec_tbl(l_counter).ATTRIBUTE79               ,
          ATTRIBUTE80               =p_aia_rec_tbl(l_counter).ATTRIBUTE80               ,
          ATTRIBUTE81               =p_aia_rec_tbl(l_counter).ATTRIBUTE81               ,
          ATTRIBUTE82               =p_aia_rec_tbl(l_counter).ATTRIBUTE82               ,
          ATTRIBUTE83               =p_aia_rec_tbl(l_counter).ATTRIBUTE83               ,
          ATTRIBUTE84               =p_aia_rec_tbl(l_counter).ATTRIBUTE84               ,
          ATTRIBUTE85               =p_aia_rec_tbl(l_counter).ATTRIBUTE85               ,
          ATTRIBUTE86               =p_aia_rec_tbl(l_counter).ATTRIBUTE86               ,
          ATTRIBUTE87               =p_aia_rec_tbl(l_counter).ATTRIBUTE87               ,
          ATTRIBUTE88               =p_aia_rec_tbl(l_counter).ATTRIBUTE88               ,
          ATTRIBUTE89               =p_aia_rec_tbl(l_counter).ATTRIBUTE89               ,
          ATTRIBUTE90               =p_aia_rec_tbl(l_counter).ATTRIBUTE90               ,
          ATTRIBUTE91               =p_aia_rec_tbl(l_counter).ATTRIBUTE91               ,
          ATTRIBUTE92               =p_aia_rec_tbl(l_counter).ATTRIBUTE92               ,
          ATTRIBUTE93               =p_aia_rec_tbl(l_counter).ATTRIBUTE93               ,
          ATTRIBUTE94               =p_aia_rec_tbl(l_counter).ATTRIBUTE94               ,
          ATTRIBUTE95               =p_aia_rec_tbl(l_counter).ATTRIBUTE95               ,
          ATTRIBUTE96               =p_aia_rec_tbl(l_counter).ATTRIBUTE96               ,
          ATTRIBUTE97               =p_aia_rec_tbl(l_counter).ATTRIBUTE97               ,
          ATTRIBUTE98               =p_aia_rec_tbl(l_counter).ATTRIBUTE98               ,
          ATTRIBUTE99               =p_aia_rec_tbl(l_counter).ATTRIBUTE99               ,
          ATTRIBUTE100              =p_aia_rec_tbl(l_counter).ATTRIBUTE100
          WHERE ORDER_NUMBER      = p_aia_rec_tbl(l_counter).ORDER_NUMBER;

        IF fnd_api.to_boolean(p_commit) THEN
          COMMIT;
        END IF;

        x_msg_count := 1;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: ' || 'UPDATED ORDER NUMBER' || ' '
        || p_aia_rec_tbl(l_counter).ORDER_NUMBER );
      END IF;
  END LOOP;

  IF(x_msg_data      = '_') THEN
    x_return_status := 'F';
  END IF;

  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: x_return_status: ' || x_return_status);
EXCEPTION
WHEN CN_AIA_REQ_FIELD_NOT_SET_ERROR THEN
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:exception: CN_AIA_REQ_FIELD_NOT_SET_ERROR: ');
  raise_application_error (-20001,l_error_msg);
WHEN OTHERS THEN
  x_return_status := 'F';
  x_msg_count := 1;
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:exception others: ' || SQLERRM(SQLCODE()) );
  raise_application_error (-20002,SQLERRM(SQLCODE()));
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
END loadrow_om;


-- API name  : loadrow
-- Type : Public.
-- Pre-reqs :
-- Usage :
--+
-- Desc  :
--
--
--+
-- Parameters :
--  IN :  p_api_version       NUMBER      Require
--      p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
--      p_commit        VARCHAR2    Optional (FND_API.G_FALSE)
--
--  OUT :  x_return_status     VARCHAR2(1)
--      x_msg_count        NUMBER
--      x_msg_data        VARCHAR2(2000)
--
--
--
--  +
--+
-- Version : Current version 1.0
--    Initial version  1.0
--+
-- Notes :
--+
-- End of comments
PROCEDURE loadrow
  (
    p_api_version               IN NUMBER,
    p_init_msg_list             IN VARCHAR2:= FND_API.G_FALSE,
    p_commit                    IN VARCHAR2:= FND_API.G_FALSE,
    p_aia_rec_tbl               IN CN_COLLECTION_AIA_PUB.aia_rec_tbl_type,
    p_org_id                    IN NUMBER,
    p_aia_error_rec_tbl OUT nocopy CN_COLLECTION_AIA_PUB.aia_error_rec_tbl_type,
    x_msg_count OUT nocopy     NUMBER,
    x_msg_data OUT nocopy      VARCHAR2,
    x_return_status OUT nocopy VARCHAR2 )
                                   IS
  l_api_name        CONSTANT VARCHAR2(30) := 'loadrow';
  l_api_version     CONSTANT NUMBER       :=1.0;
  l_error_msg       VARCHAR(240);
  --x_org_id          NUMBER;
  l_update_flag     VARCHAR2(10) := 'N';
  l_salesrep_number VARCHAR2(30) := '_';
  l_employee_number VARCHAR2(30) := '_';
  l_salesrep_id     NUMBER       := -1;
  l_trans_seq_num   NUMBER       := 0;
  l_update_check    NUMBER       := -1;
  l_counter         NUMBER;
  l_invoice_date DATE            := sysdate;
  l_trx_type VARCHAR2(30)        := '_';
  l_error_count      NUMBER       := 1;
  l_tot_error_count  NUMBER       := 0;


  CURSOR get_res_num_from_src_num(p_employee_number varchar2)
  IS
      SELECT employee_number
       FROM cn_salesreps
      WHERE resource_id IN
      (SELECT resource_id
         FROM jtf_rs_resource_extns
        WHERE source_number = p_employee_number
      );

  CURSOR get_salesrep_from_res_num(p_employee_number varchar2)
  IS
     SELECT salesrep_id
       FROM cn_salesreps
      WHERE resource_id IN
      (SELECT resource_id
         FROM jtf_rs_resource_extns
        WHERE source_number = p_employee_number
      );

  CURSOR get_res_num_from_salesrep(p_salesrep_id number)
  IS
     SELECT employee_number FROM cn_salesreps WHERE salesrep_id = p_salesrep_id;

  CURSOR get_src_num_from_salesrep(p_salesrep_id number)
  IS
     SELECT source_number
       FROM jtf_rs_resource_extns
      WHERE resource_id IN
      ( SELECT resource_id FROM cn_salesreps WHERE salesrep_id = p_salesrep_id
      ) ;

  CURSOR check_invoice_number(p_invoice_number varchar2)
  IS
     SELECT 'Y' FLAG,
      TRANS_SEQ_ID
       FROM CN_COLLECTION_AIA
      WHERE INVOICE_NUMBER = p_invoice_number
    AND rownum             = 1;

  CURSOR check_not_trx(l_trans_seq_num number,p_org_id number)
  IS
     SELECT 1 FLAG
       FROM cn_not_trx
      WHERE source_trx_line_id = l_trans_seq_num --*** Line.Primary_Key
    AND event_id               = -1020
    AND org_id                 = p_org_id;

  l_resnum_srcnum_cr get_res_num_from_src_num%ROWTYPE;
  l_salesrep_resnum_cr get_salesrep_from_res_num%ROWTYPE;
  l_resnum_salesrep_cr get_res_num_from_salesrep%ROWTYPE;
  l_srcnum_salesrep_cr get_src_num_from_salesrep%ROWTYPE;
  l_invoice_num_cr check_invoice_number%ROWTYPE;
  l_not_trx_cr check_not_trx%ROWTYPE;

BEGIN
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: start ');
  x_msg_data  := '_';
  x_msg_count := 0;
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_api_version: ' || l_api_version);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_api_name: ' || l_api_name);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: G_PKG_NAME: ' || G_PKG_NAME);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_org_id: ' || p_org_id);
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_api_version: ' || p_api_version);

    --  Initialize API return status to success
  x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Standard call to check for call compatibility.
  /*IF NOT FND_API.Compatible_API_Call ( l_api_version , p_api_version , l_api_name , G_PKG_NAME ) THEN
    x_return_status := 'F';
    x_msg_count := 1;
    l_error_msg           := 'p_api_version' || g_error_msg;
    debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_error_msg: ' || l_error_msg);
  END IF; */

  IF(p_org_id IS NULL) THEN
    x_return_status := 'F';
    x_msg_count := 1;
    --l_error_msg           := 'p_org_id' || g_error_msg;
    fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
    fnd_message.set_token('FIELD','p_org_id');
    l_error_msg :=  fnd_message.get;
    debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_error_msg: ' || l_error_msg);
    RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
  END IF;

  -- Codes start here
  --x_org_id := mo_global.get_current_org_id;
  --DBMS_OUTPUT.put_line('p_org_id ' || p_org_id);
  mo_global.set_policy_context('S',p_org_id);

  -- Initialize message list if p_init_msg_list is set to TRUE.
  IF FND_API.to_Boolean( p_init_msg_list ) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF p_aia_rec_tbl.COUNT = 0
   THEN
     x_return_status := 'F';
     x_msg_count := 1;
     --l_error_msg           := 'p_aia_rec_tbl' || g_error_msg;
     fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
     fnd_message.set_token('FIELD','p_aia_rec_tbl');
     l_error_msg :=  fnd_message.get;
     debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_error_msg: ' || l_error_msg);
     --RAISE CN_AIA_REQ_FIELD_NOT_SET_ERROR;
     RETURN;
   END IF;

   l_trx_type :=   p_aia_rec_tbl(1).TRX_TYPE;
   debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api:l_trx_type: ' || l_trx_type);

   IF(l_trx_type = 'AIA_OM') THEN
      loadrow_om
          (
            p_api_version     => p_api_version ,
            p_init_msg_list   => p_init_msg_list,
            p_commit          => p_commit,
            p_aia_rec_tbl     => p_aia_rec_tbl,
            p_org_id          => p_org_id,
            x_msg_count       => x_msg_count,
            x_msg_data        => x_msg_data,
            x_return_status   => x_return_status
          );
   ELSE
   FOR l_counter IN 1 .. p_aia_rec_tbl.COUNT
   LOOP
     begin
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_salesrep_id: ' || p_aia_rec_tbl(l_counter).SALESREP_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_employee_number: ' || p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_processed_date: ' || p_aia_rec_tbl(l_counter).PROCESSED_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_invoice_number: ' || p_aia_rec_tbl(l_counter).INVOICE_NUMBER);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_invoice_date: ' || p_aia_rec_tbl(l_counter).INVOICE_DATE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_transaction_amount: ' || p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_transaction_currency_code: ' || p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_trx_type: ' || p_aia_rec_tbl(l_counter).TRX_TYPE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_revenue_type: ' || p_aia_rec_tbl(l_counter).REVENUE_TYPE);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_adjust_comments: ' || p_aia_rec_tbl(l_counter).ADJUST_COMMENTS);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: p_source_doc_id: ' || p_aia_rec_tbl(l_counter).SOURCE_DOC_ID);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute1 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE1 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute2 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE2 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute3 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE3 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute4 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE4 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute5 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE5 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute6 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE6 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute7 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE7 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute8 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE8 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute9 : ' || p_aia_rec_tbl(l_counter).ATTRIBUTE9 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute10: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE10 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute11: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE11 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute12: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE12 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute13: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE13 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute14: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE14 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute15: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE15 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute16: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE16 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute17: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE17 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute18: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE18 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute19: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE19 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute20: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE20 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute21: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE21 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute22: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE22 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute23: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE23 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute24: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE24 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute25: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE25 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute26: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE26 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute27: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE27 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute28: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE28 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute29: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE29 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute30: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE30 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute31: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE31 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute32: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE32 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute33: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE33 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute34: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE34 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute35: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE35 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute36: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE36 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute37: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE37 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute38: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE38 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute39: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE39 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute40: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE40 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute41: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE41 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute42: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE42 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute43: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE43 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute44: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE44 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute45: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE45 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute46: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE46 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute47: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE47 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute48: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE48 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute49: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE49 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute50: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE50 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute51: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE51 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute52: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE52 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute53: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE53 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute54: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE54 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute55: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE55 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute56: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE56 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute57: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE57 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute58: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE58 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute59: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE59 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute60: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE60 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute61: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE61 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute62: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE62 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute63: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE63 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute64: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE64 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute65: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE65 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute66: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE66 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute67: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE67 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute68: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE68 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute69: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE69 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute70: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE70 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute71: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE71 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute72: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE72 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute73: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE73 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute74: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE74 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute75: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE75 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute76: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE76 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute77: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE77 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute78: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE78 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute79: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE79 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute80: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE80 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute81: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE81 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute82: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE82 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute83: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE83 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute84: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE84 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute85: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE85 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute86: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE86 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute87: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE87 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute88: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE88 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute89: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE89 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute90: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE90 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute91: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE91 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute92: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE92 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute93: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE93 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute94: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE94 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute95: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE95 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute96: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE96 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute97: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE97 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute98: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE98 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute99: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE99 );
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:p_attribute100: ' || p_aia_rec_tbl(l_counter).ATTRIBUTE100);
      EXCEPTION
        WHEN OTHERS THEN
        --x_return_status := 'F';
        --DBMS_OUTPUT.put_line('CN_COLLECTION_AIA_PUB.loadrow:exception in debug messages others: ' || '[ ' || SQLERRM(SQLCODE()) || ' ]');
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow:exception in debug messages others: ' || SQLERRM(SQLCODE()) );
      end;

      x_msg_data  :=  p_aia_rec_tbl(l_counter).INVOICE_NUMBER ;
      l_update_check    := -1;
      l_update_flag     := 'N';
      l_salesrep_number := '_';
      l_employee_number := '_';
      l_salesrep_id     := -1;
      l_trans_seq_num   := 0;
      l_error_count     := 1;


  --Mandatory fields validation starts here
      IF(p_aia_rec_tbl(l_counter).PROCESSED_DATE IS NULL or
          p_aia_rec_tbl(l_counter).PROCESSED_DATE = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg       := 'p_processed_date' || g_error_msg;
        fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
        fnd_message.set_token('FIELD','p_processed_date');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count + 1;
      END IF;

      IF(p_aia_rec_tbl(l_counter).INVOICE_NUMBER IS NULL or
          p_aia_rec_tbl(l_counter).INVOICE_NUMBER = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg       := 'p_invoice_number' || g_error_msg;
        fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
        fnd_message.set_token('FIELD','p_invoice_number');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count +1;
      END IF;

      IF(p_aia_rec_tbl(l_counter).INVOICE_DATE IS NULL or
          p_aia_rec_tbl(l_counter).INVOICE_DATE = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg     := 'p_invoice_date' || g_error_msg;
        fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
        fnd_message.set_token('FIELD','p_invoice_date');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count +1;
      END IF;

      IF(p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT IS NULL or
          p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT = G_LOC_MISS_NUM) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg           := 'p_transaction_amount' || g_error_msg;
        fnd_message.set_name('CN', 'CN_AIA_REQ_FIELD_ERROR_MSG');
        fnd_message.set_token('FIELD','p_transaction_amount');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count +1;
      END IF;

      IF(p_aia_rec_tbl(l_counter).SALESREP_ID IS NULL AND p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER IS NULL
      AND p_aia_rec_tbl(l_counter).SALESREP_ID = G_LOC_MISS_NUM AND p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER = FND_API.G_MISS_CHAR) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg    := 'Any one of p_salesrep_id or p_employee_number' || g_error_msg;
        fnd_message.set_name('CN', 'CN_AIA_SR_EMP_FIELD_ERROR_MSG');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow_om api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count +1;
      END IF;



      IF(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER IS NOT NULL and p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER <> FND_API.G_MISS_CHAR) THEN
        FOR l_resnum_srcnum_cr IN get_res_num_from_src_num(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER)
        LOOP
          l_salesrep_number := l_resnum_srcnum_cr.employee_number;
        END LOOP;
        --DBMS_OUTPUT.put_line('l_salesrep_number ' || l_salesrep_number);
        FOR l_salesrep_resnum_cr IN get_salesrep_from_res_num(p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER)
        LOOP
          l_salesrep_id := l_salesrep_resnum_cr.salesrep_id;
        END LOOP;
        --DBMS_OUTPUT.put_line('l_salesrep_id ' || l_salesrep_id);
        l_employee_number          := p_aia_rec_tbl(l_counter).EMPLOYEE_NUMBER;
        IF(l_salesrep_id            = -1) THEN
          l_salesrep_number        := '_';
          l_employee_number        := '_';
          FOR l_resnum_salesrep_cr IN get_res_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
          LOOP
            l_salesrep_number := l_resnum_salesrep_cr.employee_number;
          END LOOP;
          FOR l_srcnum_salesrep_cr IN get_src_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
          LOOP
            l_employee_number := l_srcnum_salesrep_cr.source_number;
          END LOOP;
          IF(l_employee_number <> '_') THEN
            l_salesrep_id      := p_aia_rec_tbl(l_counter).SALESREP_ID;
          END IF;
        END IF;
      ELSE
        FOR l_resnum_salesrep_cr IN get_res_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
        LOOP
          l_salesrep_number := l_resnum_salesrep_cr.employee_number;
        END LOOP;
        FOR l_srcnum_salesrep_cr IN get_src_num_from_salesrep(p_aia_rec_tbl(l_counter).SALESREP_ID)
        LOOP
          l_employee_number := l_srcnum_salesrep_cr.source_number;
        END LOOP;
        IF(l_employee_number <> '_') THEN
          l_salesrep_id      := p_aia_rec_tbl(l_counter).SALESREP_ID;
        END IF;
      END IF;

      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_salesrep_number: ' || l_salesrep_number);
      debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_salesrep_id: ' || l_salesrep_id);
      IF(l_salesrep_id = -1) THEN
        x_return_status := 'F';
        x_msg_count := 1;
        l_tot_error_count :=  l_tot_error_count + 1;
        --l_error_msg   := 'Please enter valid value for either of p_salesrep_id or p_employee_number. ';
        fnd_message.set_name('CN', 'CN_AIA_SR_EMP_FIELD_ERROR_MSG');
        l_error_msg :=  fnd_message.get;
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_error_msg: ' || l_error_msg);
        p_aia_error_rec_tbl(l_tot_error_count).invoice_number :=  x_msg_data;
        p_aia_error_rec_tbl(l_tot_error_count).error_desc :=  l_error_msg;
        l_error_count :=  l_error_count +1;
      END IF;

       if(l_error_count <= 1) Then
         --CONTINUE;
       --End If;

        FOR l_invoice_num_cr IN check_invoice_number(p_aia_rec_tbl(l_counter).INVOICE_NUMBER)
        LOOP
          l_update_flag   := l_invoice_num_cr.FLAG;
          l_trans_seq_num := l_invoice_num_cr.TRANS_SEQ_ID;
        END LOOP;
      --DBMS_OUTPUT.put_line('CN_COLLECTION_AIA_PUB.loadrow api: l_update_flag: ' || l_update_flag);
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_update_flag: ' || l_update_flag);
        debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: l_trans_seq_num: ' || l_trans_seq_num);

        IF(l_update_flag = 'N') THEN
          debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: insert start ');
           INSERT
             INTO CN_COLLECTION_AIA
            (
              TRANS_SEQ_ID             ,
              SALESREP_ID              ,
              EMPLOYEE_NUMBER          ,
              PROCESSED_DATE           ,
              INVOICE_NUMBER           ,
              INVOICE_DATE             ,
              TRANSACTION_AMOUNT       ,
              TRANSACTION_CURRENCY_CODE,
              TRX_TYPE                 ,
              REVENUE_TYPE             ,
              SALESREP_NUMBER          ,
              ADJUST_COMMENTS          ,
              ADJUST_STATUS            ,
              SOURCE_DOC_ID            ,
              UPDATE_FLAG              ,
              ORG_ID                   ,
              ATTRIBUTE1               ,
              ATTRIBUTE2               ,
              ATTRIBUTE3               ,
              ATTRIBUTE4               ,
              ATTRIBUTE5               ,
              ATTRIBUTE6               ,
              ATTRIBUTE7               ,
              ATTRIBUTE8               ,
              ATTRIBUTE9               ,
              ATTRIBUTE10              ,
              ATTRIBUTE11              ,
              ATTRIBUTE12              ,
              ATTRIBUTE13              ,
              ATTRIBUTE14              ,
              ATTRIBUTE15              ,
              ATTRIBUTE16              ,
              ATTRIBUTE17              ,
              ATTRIBUTE18              ,
              ATTRIBUTE19              ,
              ATTRIBUTE20              ,
              ATTRIBUTE21              ,
              ATTRIBUTE22              ,
              ATTRIBUTE23              ,
              ATTRIBUTE24              ,
              ATTRIBUTE25              ,
              ATTRIBUTE26              ,
              ATTRIBUTE27              ,
              ATTRIBUTE28              ,
              ATTRIBUTE29              ,
              ATTRIBUTE30              ,
              ATTRIBUTE31              ,
              ATTRIBUTE32              ,
              ATTRIBUTE33              ,
              ATTRIBUTE34              ,
              ATTRIBUTE35              ,
              ATTRIBUTE36              ,
              ATTRIBUTE37              ,
              ATTRIBUTE38              ,
              ATTRIBUTE39              ,
              ATTRIBUTE40              ,
              ATTRIBUTE41              ,
              ATTRIBUTE42              ,
              ATTRIBUTE43              ,
              ATTRIBUTE44              ,
              ATTRIBUTE45              ,
              ATTRIBUTE46              ,
              ATTRIBUTE47              ,
              ATTRIBUTE48              ,
              ATTRIBUTE49              ,
              ATTRIBUTE50              ,
              ATTRIBUTE51              ,
              ATTRIBUTE52              ,
              ATTRIBUTE53              ,
              ATTRIBUTE54              ,
              ATTRIBUTE55              ,
              ATTRIBUTE56              ,
              ATTRIBUTE57              ,
              ATTRIBUTE58              ,
              ATTRIBUTE59              ,
              ATTRIBUTE60              ,
              ATTRIBUTE61              ,
              ATTRIBUTE62              ,
              ATTRIBUTE63              ,
              ATTRIBUTE64              ,
              ATTRIBUTE65              ,
              ATTRIBUTE66              ,
              ATTRIBUTE67              ,
              ATTRIBUTE68              ,
              ATTRIBUTE69              ,
              ATTRIBUTE70              ,
              ATTRIBUTE71              ,
              ATTRIBUTE72              ,
              ATTRIBUTE73              ,
              ATTRIBUTE74              ,
              ATTRIBUTE75              ,
              ATTRIBUTE76              ,
              ATTRIBUTE77              ,
              ATTRIBUTE78              ,
              ATTRIBUTE79              ,
              ATTRIBUTE80              ,
              ATTRIBUTE81              ,
              ATTRIBUTE82              ,
              ATTRIBUTE83              ,
              ATTRIBUTE84              ,
              ATTRIBUTE85              ,
              ATTRIBUTE86              ,
              ATTRIBUTE87              ,
              ATTRIBUTE88              ,
              ATTRIBUTE89              ,
              ATTRIBUTE90              ,
              ATTRIBUTE91              ,
              ATTRIBUTE92              ,
              ATTRIBUTE93              ,
              ATTRIBUTE94              ,
              ATTRIBUTE95              ,
              ATTRIBUTE96              ,
              ATTRIBUTE97              ,
              ATTRIBUTE98              ,
              ATTRIBUTE99              ,
              ATTRIBUTE100
            )
                  VALUES
            (
              CN_COLLECTION_AIA_S.NextVal                        ,
              l_salesrep_id                                      ,
              l_employee_number                                  ,
              to_date(p_aia_rec_tbl(l_counter).PROCESSED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
              p_aia_rec_tbl(l_counter).INVOICE_NUMBER            ,
              to_date(p_aia_rec_tbl(l_counter).INVOICE_DATE, 'dd/mm/yyyy hh24:mi:ss'),
              p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT        ,
              p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE ,
              'AIA'                  ,
              decode(p_aia_rec_tbl(l_counter).REVENUE_TYPE, FND_API.G_MISS_CHAR, 'REVENUE', p_aia_rec_tbl(l_counter).REVENUE_TYPE),
              l_salesrep_number                                  ,
              p_aia_rec_tbl(l_counter).ADJUST_COMMENTS           ,
              'MANUAL'                                           ,
              p_aia_rec_tbl(l_counter).SOURCE_DOC_ID             ,
              l_update_flag                                      ,
              p_org_id                                           ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE1                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE2                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE3                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE4                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE5                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE6                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE7                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE8                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE9                ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE10               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE11               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE12               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE13               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE14               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE15               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE16               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE17               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE18               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE19               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE20               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE21               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE22               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE23               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE24               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE25               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE26               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE27               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE28               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE29               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE30               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE31               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE32               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE33               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE34               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE35               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE36               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE37               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE38               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE39               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE40               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE41               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE42               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE43               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE44               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE45               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE46               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE47               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE48               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE49               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE50               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE51               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE52               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE53               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE54               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE55               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE56               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE57               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE58               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE59               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE60               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE61               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE62               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE63               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE64               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE65               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE66               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE67               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE68               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE69               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE70               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE71               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE72               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE73               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE74               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE75               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE76               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE77               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE78               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE79               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE80               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE81               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE82               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE83               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE84               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE85               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE86               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE87               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE88               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE89               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE90               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE91               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE92               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE93               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE94               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE95               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE96               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE97               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE98               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE99               ,
              p_aia_rec_tbl(l_counter).ATTRIBUTE100
            );

          IF fnd_api.to_boolean
            (
              p_commit
            )
            THEN
            COMMIT;
          END IF;

          x_msg_count := 1;

          debugmsg
          (
            'CN_COLLECTION_AIA_PUB.loadrow api:  ' || 'INSERTED INVOICE NUMBER' || ' '
            || p_aia_rec_tbl(l_counter).INVOICE_NUMBER
          )
          ;
        ELSE
          -- This step will check that if this transaction has already been collected then update flag should be 'Y'
          -- else it should be 'N'. Here l_update_check is initialized to -1. If invoice number exists then it will go
          -- to this else part and here it will check wether this has been collected. If yes then l_update_check = 'Y'
          FOR l_not_trx_cr IN check_not_trx(l_trans_seq_num, p_org_id)
          LOOP
            l_update_check := l_invoice_num_cr.FLAG;
          END LOOP;

          debugmsg
          (
            'CN_COLLECTION_AIA_PUB.loadrow api: l_update_check(in table cn_not_trx): ' || l_update_check
          )
          ;
          -- Since this invoice number has not been collected. so l_update_check = 'Y'
          IF
            (
              l_update_check = -1
            )
            THEN
            l_update_flag := 'N';
          END IF;
          debugmsg
          (
            'CN_COLLECTION_AIA_PUB.loadrow api: l_update_flag: ' || l_update_flag
          )
          ;
          debugmsg
          (
            'CN_COLLECTION_AIA_PUB.loadrow api: update process start '
          )
          ;
           UPDATE CN_COLLECTION_AIA
          SET SALESREP_ID             =l_salesrep_id               ,
            EMPLOYEE_NUMBER           =l_employee_number           ,
            PROCESSED_DATE            =to_date(p_aia_rec_tbl(l_counter).PROCESSED_DATE, 'dd/mm/yyyy hh24:mi:ss'),
            INVOICE_DATE              =to_date(p_aia_rec_tbl(l_counter).INVOICE_DATE, 'dd/mm/yyyy hh24:mi:ss'),
            TRANSACTION_AMOUNT        =p_aia_rec_tbl(l_counter).TRANSACTION_AMOUNT        ,
            TRANSACTION_CURRENCY_CODE =p_aia_rec_tbl(l_counter).TRANSACTION_CURRENCY_CODE ,
            TRX_TYPE                  ='AIA'                  ,
            REVENUE_TYPE              =decode(p_aia_rec_tbl(l_counter).REVENUE_TYPE, FND_API.G_MISS_CHAR, 'REVENUE',
                                          p_aia_rec_tbl(l_counter).REVENUE_TYPE)          ,
            SALESREP_NUMBER           =l_salesrep_number                                  ,
            ADJUST_COMMENTS           =p_aia_rec_tbl(l_counter).ADJUST_COMMENTS           ,
            ADJUST_STATUS             ='MANUAL'                                           ,
            SOURCE_DOC_ID             =p_aia_rec_tbl(l_counter).SOURCE_DOC_ID             ,
            UPDATE_FLAG               =l_update_flag                                      ,
            ORG_ID                    =p_org_id                                           ,
            ATTRIBUTE1                =p_aia_rec_tbl(l_counter).ATTRIBUTE1                ,
            ATTRIBUTE2                =p_aia_rec_tbl(l_counter).ATTRIBUTE2                ,
            ATTRIBUTE3                =p_aia_rec_tbl(l_counter).ATTRIBUTE3                ,
            ATTRIBUTE4                =p_aia_rec_tbl(l_counter).ATTRIBUTE4                ,
            ATTRIBUTE5                =p_aia_rec_tbl(l_counter).ATTRIBUTE5                ,
            ATTRIBUTE6                =p_aia_rec_tbl(l_counter).ATTRIBUTE6                ,
            ATTRIBUTE7                =p_aia_rec_tbl(l_counter).ATTRIBUTE7                ,
            ATTRIBUTE8                =p_aia_rec_tbl(l_counter).ATTRIBUTE8                ,
            ATTRIBUTE9                =p_aia_rec_tbl(l_counter).ATTRIBUTE9                ,
            ATTRIBUTE10               =p_aia_rec_tbl(l_counter).ATTRIBUTE10               ,
            ATTRIBUTE11               =p_aia_rec_tbl(l_counter).ATTRIBUTE11               ,
            ATTRIBUTE12               =p_aia_rec_tbl(l_counter).ATTRIBUTE12               ,
            ATTRIBUTE13               =p_aia_rec_tbl(l_counter).ATTRIBUTE13               ,
            ATTRIBUTE14               =p_aia_rec_tbl(l_counter).ATTRIBUTE14               ,
            ATTRIBUTE15               =p_aia_rec_tbl(l_counter).ATTRIBUTE15               ,
            ATTRIBUTE16               =p_aia_rec_tbl(l_counter).ATTRIBUTE16               ,
            ATTRIBUTE17               =p_aia_rec_tbl(l_counter).ATTRIBUTE17               ,
            ATTRIBUTE18               =p_aia_rec_tbl(l_counter).ATTRIBUTE18               ,
            ATTRIBUTE19               =p_aia_rec_tbl(l_counter).ATTRIBUTE19               ,
            ATTRIBUTE20               =p_aia_rec_tbl(l_counter).ATTRIBUTE20               ,
            ATTRIBUTE21               =p_aia_rec_tbl(l_counter).ATTRIBUTE21               ,
            ATTRIBUTE22               =p_aia_rec_tbl(l_counter).ATTRIBUTE22               ,
            ATTRIBUTE23               =p_aia_rec_tbl(l_counter).ATTRIBUTE23               ,
            ATTRIBUTE24               =p_aia_rec_tbl(l_counter).ATTRIBUTE24               ,
            ATTRIBUTE25               =p_aia_rec_tbl(l_counter).ATTRIBUTE25               ,
            ATTRIBUTE26               =p_aia_rec_tbl(l_counter).ATTRIBUTE26               ,
            ATTRIBUTE27               =p_aia_rec_tbl(l_counter).ATTRIBUTE27               ,
            ATTRIBUTE28               =p_aia_rec_tbl(l_counter).ATTRIBUTE28               ,
            ATTRIBUTE29               =p_aia_rec_tbl(l_counter).ATTRIBUTE29               ,
            ATTRIBUTE30               =p_aia_rec_tbl(l_counter).ATTRIBUTE30               ,
            ATTRIBUTE31               =p_aia_rec_tbl(l_counter).ATTRIBUTE31               ,
            ATTRIBUTE32               =p_aia_rec_tbl(l_counter).ATTRIBUTE32               ,
            ATTRIBUTE33               =p_aia_rec_tbl(l_counter).ATTRIBUTE33               ,
            ATTRIBUTE34               =p_aia_rec_tbl(l_counter).ATTRIBUTE34               ,
            ATTRIBUTE35               =p_aia_rec_tbl(l_counter).ATTRIBUTE35               ,
            ATTRIBUTE36               =p_aia_rec_tbl(l_counter).ATTRIBUTE36               ,
            ATTRIBUTE37               =p_aia_rec_tbl(l_counter).ATTRIBUTE37               ,
            ATTRIBUTE38               =p_aia_rec_tbl(l_counter).ATTRIBUTE38               ,
            ATTRIBUTE39               =p_aia_rec_tbl(l_counter).ATTRIBUTE39               ,
            ATTRIBUTE40               =p_aia_rec_tbl(l_counter).ATTRIBUTE40               ,
            ATTRIBUTE41               =p_aia_rec_tbl(l_counter).ATTRIBUTE41               ,
            ATTRIBUTE42               =p_aia_rec_tbl(l_counter).ATTRIBUTE42               ,
            ATTRIBUTE43               =p_aia_rec_tbl(l_counter).ATTRIBUTE43               ,
            ATTRIBUTE44               =p_aia_rec_tbl(l_counter).ATTRIBUTE44               ,
            ATTRIBUTE45               =p_aia_rec_tbl(l_counter).ATTRIBUTE45               ,
            ATTRIBUTE46               =p_aia_rec_tbl(l_counter).ATTRIBUTE46               ,
            ATTRIBUTE47               =p_aia_rec_tbl(l_counter).ATTRIBUTE47               ,
            ATTRIBUTE48               =p_aia_rec_tbl(l_counter).ATTRIBUTE48               ,
            ATTRIBUTE49               =p_aia_rec_tbl(l_counter).ATTRIBUTE49               ,
            ATTRIBUTE50               =p_aia_rec_tbl(l_counter).ATTRIBUTE50               ,
            ATTRIBUTE51               =p_aia_rec_tbl(l_counter).ATTRIBUTE51               ,
            ATTRIBUTE52               =p_aia_rec_tbl(l_counter).ATTRIBUTE52               ,
            ATTRIBUTE53               =p_aia_rec_tbl(l_counter).ATTRIBUTE53               ,
            ATTRIBUTE54               =p_aia_rec_tbl(l_counter).ATTRIBUTE54               ,
            ATTRIBUTE55               =p_aia_rec_tbl(l_counter).ATTRIBUTE55               ,
            ATTRIBUTE56               =p_aia_rec_tbl(l_counter).ATTRIBUTE56               ,
            ATTRIBUTE57               =p_aia_rec_tbl(l_counter).ATTRIBUTE57               ,
            ATTRIBUTE58               =p_aia_rec_tbl(l_counter).ATTRIBUTE58               ,
            ATTRIBUTE59               =p_aia_rec_tbl(l_counter).ATTRIBUTE59               ,
            ATTRIBUTE60               =p_aia_rec_tbl(l_counter).ATTRIBUTE60               ,
            ATTRIBUTE61               =p_aia_rec_tbl(l_counter).ATTRIBUTE61               ,
            ATTRIBUTE62               =p_aia_rec_tbl(l_counter).ATTRIBUTE62               ,
            ATTRIBUTE63               =p_aia_rec_tbl(l_counter).ATTRIBUTE63               ,
            ATTRIBUTE64               =p_aia_rec_tbl(l_counter).ATTRIBUTE64               ,
            ATTRIBUTE65               =p_aia_rec_tbl(l_counter).ATTRIBUTE65               ,
            ATTRIBUTE66               =p_aia_rec_tbl(l_counter).ATTRIBUTE66               ,
            ATTRIBUTE67               =p_aia_rec_tbl(l_counter).ATTRIBUTE67               ,
            ATTRIBUTE68               =p_aia_rec_tbl(l_counter).ATTRIBUTE68               ,
            ATTRIBUTE69               =p_aia_rec_tbl(l_counter).ATTRIBUTE69               ,
            ATTRIBUTE70               =p_aia_rec_tbl(l_counter).ATTRIBUTE70               ,
            ATTRIBUTE71               =p_aia_rec_tbl(l_counter).ATTRIBUTE71               ,
            ATTRIBUTE72               =p_aia_rec_tbl(l_counter).ATTRIBUTE72               ,
            ATTRIBUTE73               =p_aia_rec_tbl(l_counter).ATTRIBUTE73               ,
            ATTRIBUTE74               =p_aia_rec_tbl(l_counter).ATTRIBUTE74               ,
            ATTRIBUTE75               =p_aia_rec_tbl(l_counter).ATTRIBUTE75               ,
            ATTRIBUTE76               =p_aia_rec_tbl(l_counter).ATTRIBUTE76               ,
            ATTRIBUTE77               =p_aia_rec_tbl(l_counter).ATTRIBUTE77               ,
            ATTRIBUTE78               =p_aia_rec_tbl(l_counter).ATTRIBUTE78               ,
            ATTRIBUTE79               =p_aia_rec_tbl(l_counter).ATTRIBUTE79               ,
            ATTRIBUTE80               =p_aia_rec_tbl(l_counter).ATTRIBUTE80               ,
            ATTRIBUTE81               =p_aia_rec_tbl(l_counter).ATTRIBUTE81               ,
            ATTRIBUTE82               =p_aia_rec_tbl(l_counter).ATTRIBUTE82               ,
            ATTRIBUTE83               =p_aia_rec_tbl(l_counter).ATTRIBUTE83               ,
            ATTRIBUTE84               =p_aia_rec_tbl(l_counter).ATTRIBUTE84               ,
            ATTRIBUTE85               =p_aia_rec_tbl(l_counter).ATTRIBUTE85               ,
            ATTRIBUTE86               =p_aia_rec_tbl(l_counter).ATTRIBUTE86               ,
            ATTRIBUTE87               =p_aia_rec_tbl(l_counter).ATTRIBUTE87               ,
            ATTRIBUTE88               =p_aia_rec_tbl(l_counter).ATTRIBUTE88               ,
            ATTRIBUTE89               =p_aia_rec_tbl(l_counter).ATTRIBUTE89               ,
            ATTRIBUTE90               =p_aia_rec_tbl(l_counter).ATTRIBUTE90               ,
            ATTRIBUTE91               =p_aia_rec_tbl(l_counter).ATTRIBUTE91               ,
            ATTRIBUTE92               =p_aia_rec_tbl(l_counter).ATTRIBUTE92               ,
            ATTRIBUTE93               =p_aia_rec_tbl(l_counter).ATTRIBUTE93               ,
            ATTRIBUTE94               =p_aia_rec_tbl(l_counter).ATTRIBUTE94               ,
            ATTRIBUTE95               =p_aia_rec_tbl(l_counter).ATTRIBUTE95               ,
            ATTRIBUTE96               =p_aia_rec_tbl(l_counter).ATTRIBUTE96               ,
            ATTRIBUTE97               =p_aia_rec_tbl(l_counter).ATTRIBUTE97               ,
            ATTRIBUTE98               =p_aia_rec_tbl(l_counter).ATTRIBUTE98               ,
            ATTRIBUTE99               =p_aia_rec_tbl(l_counter).ATTRIBUTE99               ,
            ATTRIBUTE100              =p_aia_rec_tbl(l_counter).ATTRIBUTE100
            WHERE INVOICE_NUMBER      = p_aia_rec_tbl(l_counter).INVOICE_NUMBER;

          IF fnd_api.to_boolean(p_commit) THEN
            COMMIT;
          END IF;

          x_msg_count := 1;
          debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: ' || 'UPDATED INVOICE NUMBER' || ' '
          || p_aia_rec_tbl(l_counter).INVOICE_NUMBER );
        END IF;
      End If;
  END LOOP;
  END IF;

  IF(x_msg_data      = '_') THEN
    x_return_status := 'F';
  END IF;

  x_msg_data  :=  'p_aia_error_rec_tbl_count = ' ||  p_aia_error_rec_tbl.count;

  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api: x_return_status: ' || x_return_status);
EXCEPTION
WHEN CN_AIA_REQ_FIELD_NOT_SET_ERROR THEN
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:exception: CN_AIA_REQ_FIELD_NOT_SET_ERROR: ');
  raise_application_error (-20001,l_error_msg);
WHEN OTHERS THEN
  x_return_status := 'F';
  x_msg_count := 1;
  debugmsg('CN_COLLECTION_AIA_PUB.loadrow api:exception others: ' || SQLERRM(SQLCODE()) );
  raise_application_error (-20002,SQLERRM(SQLCODE()));
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
END loadrow;


-- API name  : updaterow_comm_api
-- Type : public.
-- Pre-reqs :
-- Usage : This particular api will be called via trigger when we submit collect aia program and their are transactions in
-- cn_collection_aia table whose update_flag status is 'Y' (this means that these transactions has been
-- updated after collection). Once these have been updated in cn_comm_line_api table, update_flag will again be set
-- to 'N' in cn_collection_aia table, so that re-submission of program does not call the update api again based on flag.
--+
-- Desc  :
--
--
--+
-- Parameters :
--  IN
--
--  OUT :  x_return_status     VARCHAR2(1)
--
--
--
--
--  +
--+
-- Version : Current version 1.0
--    Initial version  1.0
--+
-- Notes :
--+
-- End of comments
PROCEDURE updaterow_comm_api
  (
    x_return_status OUT nocopy VARCHAR2,
    x_start_period_name IN VARCHAR2,
    x_end_period_name   IN VARCHAR2 )
                        IS
  CURSOR c_update_records(l_start_date DATE,l_end_date DATE)
  IS
     SELECT *
       FROM CN_COLLECTION_AIA
      WHERE update_flag = 'Y'
    AND TRUNC(processed_date) BETWEEN to_date(l_start_date, 'dd-mm-rr') AND to_date(l_end_date, 'dd-mm-rr');

    TYPE collect_aia_tbl_type IS TABLE OF c_update_records%ROWTYPE
        INDEX BY PLS_INTEGER;

    l_collect_aia_tbl collect_aia_tbl_type;


  CURSOR get_start_period_id(l_org_id NUMBER)
  IS
     SELECT period_id
       FROM cn_periods
      WHERE period_name = x_start_period_name
    AND org_id          = l_org_id ;

  CURSOR get_end_period_id(l_org_id NUMBER)
  IS
     SELECT period_id
       FROM cn_periods
      WHERE period_name = x_end_period_name
    AND org_id          = l_org_id ;


  l_comm_lines_id NUMBER;
  l_adj_rec_type cn_get_tx_data_pub.adj_rec_type;
  l_api_id          NUMBER;
  l_return_status   VARCHAR2(100);
  l_msg_count       NUMBER;
  l_msg_data        VARCHAR2(2000);
  l_loading_status  VARCHAR2(100);
  l_salesrep_id     NUMBER;
  x_org_id          NUMBER;
  l_start_period_id NUMBER;
  l_end_period_id   NUMBER;
  l_collect_aia_tbl_count NUMBER;
  x_start_date DATE;
  x_end_date DATE;

FUNCTION get_comm_line_id
  (
    p_invoice_number VARCHAR2,
    l_invoice_date DATE,
    l_employee_number VARCHAR2)
  RETURN NUMBER
IS
  CURSOR c_get_comm_line_id
  IS
     SELECT comm_lines_api_id
       FROM cn_comm_lines_api_all
      WHERE invoice_number      = p_invoice_number
    AND employee_number         = l_employee_number
    AND NVL(adjust_status,'N') <> 'FROZEN';

  l_comm_line_id NUMBER;
BEGIN
  OPEN c_get_comm_line_id;
  FETCH c_get_comm_line_id INTO l_comm_line_id;

  CLOSE c_get_comm_line_id;
  RETURN l_comm_line_id;
END;

FUNCTION get_comm_line_id_for_om
  (
    p_order_number NUMBER,
    l_booked_date DATE,
    l_employee_number VARCHAR2)
  RETURN NUMBER
IS
  CURSOR c_get_comm_line_id
  IS
     SELECT comm_lines_api_id
       FROM cn_comm_lines_api_all
      WHERE order_number      = p_order_number
    AND employee_number         = l_employee_number
    AND NVL(adjust_status,'N') <> 'FROZEN';

  l_comm_line_id NUMBER;
BEGIN
  OPEN c_get_comm_line_id;
  FETCH c_get_comm_line_id INTO l_comm_line_id;

  CLOSE c_get_comm_line_id;
  RETURN l_comm_line_id;
END;
BEGIN
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: start: ');

  -- DBMS_OUTPUT.put_line('Start update');
  x_org_id := mo_global.get_current_org_id;

  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_org_id: ' || x_org_id);
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_start_period_name: ' || x_start_period_name);
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_end_period_name: ' || x_end_period_name);
  --DBMS_OUTPUT.put_line('x_org_id ' || x_org_id);
  --DBMS_OUTPUT.put_line('x_start_period_name ' || x_start_period_name);
  --DBMS_OUTPUT.put_line('x_end_period_name ' || x_end_period_name);

  mo_global.set_policy_context('S',x_org_id);

  OPEN get_start_period_id(x_org_id);               -- open the cursor
  FETCH get_start_period_id INTO l_start_period_id; -- fetch data into local variables
  CLOSE get_start_period_id;

  OPEN get_end_period_id(x_org_id);             -- open the cursor
  FETCH get_end_period_id INTO l_end_period_id; -- fetch data into local variables
  CLOSE get_end_period_id;

  cn_periods_api.set_dates(l_start_period_id, l_end_period_id, x_org_id, x_start_date, x_end_date);

  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_start_date: ' || x_start_date);
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_end_date: ' || x_end_date);
  --DBMS_OUTPUT.put_line('x_start_date ' || x_start_date);
  --DBMS_OUTPUT.put_line('x_end_date ' || x_end_date);

  OPEN c_update_records(x_start_date,x_end_date);
      FETCH c_update_records
            BULK COLLECT INTO l_collect_aia_tbl;
  CLOSE c_update_records;

  l_collect_aia_tbl_count :=l_collect_aia_tbl.COUNT;
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: No. of records to be updated : ' || l_collect_aia_tbl_count);

   IF (l_collect_aia_tbl_count <= 0) THEN
	 debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api : No transactions to Update.');
   ELSE
     FOR i IN l_collect_aia_tbl.FIRST .. l_collect_aia_tbl.LAST LOOP
      debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).trx_type: ' || l_collect_aia_tbl(i).trx_type);
        IF(l_collect_aia_tbl(i).trx_type = 'AIA_OM') THEN
         l_comm_lines_id := get_comm_line_id_for_om(l_collect_aia_tbl(i).order_number, l_collect_aia_tbl(i).booked_date, l_collect_aia_tbl(i).salesrep_number);
        ELSE
         l_comm_lines_id := get_comm_line_id(l_collect_aia_tbl(i).invoice_number, l_collect_aia_tbl(i).invoice_date, l_collect_aia_tbl(i).salesrep_number);
        END IF;
        --debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_comm_lines_id: ' || l_comm_lines_id);
        --DBMS_OUTPUT.put_line('l_comm_lines_id ' || l_comm_lines_id);
        l_adj_rec_type.comm_lines_api_id       := l_comm_lines_id;
        l_adj_rec_type.invoice_number          := l_collect_aia_tbl(i).invoice_number;
        l_adj_rec_type.invoice_date            := l_collect_aia_tbl(i).invoice_date;
        l_adj_rec_type.direct_salesrep_number  := l_collect_aia_tbl(i).salesrep_number;
        l_adj_rec_type.transaction_amount      := l_collect_aia_tbl(i).transaction_amount;
        l_adj_rec_type.transaction_amount_orig := l_collect_aia_tbl(i).transaction_amount;
        l_adj_rec_type.attribute1              := l_collect_aia_tbl(i).attribute1;
        l_adj_rec_type.revenue_type            := l_collect_aia_tbl(i).revenue_type;
        l_adj_rec_type.processed_date          := l_collect_aia_tbl(i).processed_date;
        l_adj_rec_type.trx_type                := l_collect_aia_tbl(i).trx_type;
        l_adj_rec_type.orig_currency_code      := l_collect_aia_tbl(i).transaction_currency_code;
        l_adj_rec_type.direct_salesrep_id      := l_collect_aia_tbl(i).salesrep_id;
        l_adj_rec_type.adjust_comments         := l_collect_aia_tbl(i).adjust_comments;
        l_adj_rec_type.attribute2              := l_collect_aia_tbl(i).attribute2 ;
        l_adj_rec_type.attribute3              := l_collect_aia_tbl(i).attribute3 ;
        l_adj_rec_type.attribute4              := l_collect_aia_tbl(i).attribute4 ;
        l_adj_rec_type.attribute5              := l_collect_aia_tbl(i).attribute5 ;
        l_adj_rec_type.attribute6              := l_collect_aia_tbl(i).attribute6 ;
        l_adj_rec_type.attribute7              := l_collect_aia_tbl(i).attribute7 ;
        l_adj_rec_type.attribute8              := l_collect_aia_tbl(i).attribute8 ;
        l_adj_rec_type.attribute9              := l_collect_aia_tbl(i).attribute9 ;
        l_adj_rec_type.attribute10             := l_collect_aia_tbl(i).attribute10 ;
        l_adj_rec_type.attribute11             := l_collect_aia_tbl(i).attribute11 ;
        l_adj_rec_type.attribute12             := l_collect_aia_tbl(i).attribute12 ;
        l_adj_rec_type.attribute13             := l_collect_aia_tbl(i).attribute13 ;
        l_adj_rec_type.attribute14             := l_collect_aia_tbl(i).attribute14 ;
        l_adj_rec_type.attribute15             := l_collect_aia_tbl(i).attribute15 ;
        l_adj_rec_type.attribute16             := l_collect_aia_tbl(i).attribute16 ;
        l_adj_rec_type.attribute17             := l_collect_aia_tbl(i).attribute17 ;
        l_adj_rec_type.attribute18             := l_collect_aia_tbl(i).attribute18 ;
        l_adj_rec_type.attribute19             := l_collect_aia_tbl(i).attribute19 ;
        l_adj_rec_type.attribute20             := l_collect_aia_tbl(i).attribute20 ;
        l_adj_rec_type.attribute21             := l_collect_aia_tbl(i).attribute21 ;
        l_adj_rec_type.attribute22             := l_collect_aia_tbl(i).attribute22 ;
        l_adj_rec_type.attribute23             := l_collect_aia_tbl(i).attribute23 ;
        l_adj_rec_type.attribute24             := l_collect_aia_tbl(i).attribute24 ;
        l_adj_rec_type.attribute25             := l_collect_aia_tbl(i).attribute25 ;
        l_adj_rec_type.attribute26             := l_collect_aia_tbl(i).attribute26 ;
        l_adj_rec_type.attribute27             := l_collect_aia_tbl(i).attribute27 ;
        l_adj_rec_type.attribute28             := l_collect_aia_tbl(i).attribute28 ;
        l_adj_rec_type.attribute29             := l_collect_aia_tbl(i).attribute29 ;
        l_adj_rec_type.attribute30             := l_collect_aia_tbl(i).attribute30 ;
        l_adj_rec_type.attribute31             := l_collect_aia_tbl(i).attribute31 ;
        l_adj_rec_type.attribute32             := l_collect_aia_tbl(i).attribute32 ;
        l_adj_rec_type.attribute33             := l_collect_aia_tbl(i).attribute33 ;
        l_adj_rec_type.attribute34             := l_collect_aia_tbl(i).attribute34 ;
        l_adj_rec_type.attribute35             := l_collect_aia_tbl(i).attribute35 ;
        l_adj_rec_type.attribute36             := l_collect_aia_tbl(i).attribute36 ;
        l_adj_rec_type.attribute37             := l_collect_aia_tbl(i).attribute37 ;
        l_adj_rec_type.attribute38             := l_collect_aia_tbl(i).attribute38 ;
        l_adj_rec_type.attribute39             := l_collect_aia_tbl(i).attribute39 ;
        l_adj_rec_type.attribute40             := l_collect_aia_tbl(i).attribute40 ;
        l_adj_rec_type.attribute41             := l_collect_aia_tbl(i).attribute41 ;
        l_adj_rec_type.attribute42             := l_collect_aia_tbl(i).attribute42 ;
        l_adj_rec_type.attribute43             := l_collect_aia_tbl(i).attribute43 ;
        l_adj_rec_type.attribute44             := l_collect_aia_tbl(i).attribute44 ;
        l_adj_rec_type.attribute45             := l_collect_aia_tbl(i).attribute45 ;
        l_adj_rec_type.attribute46             := l_collect_aia_tbl(i).attribute46 ;
        l_adj_rec_type.attribute47             := l_collect_aia_tbl(i).attribute47 ;
        l_adj_rec_type.attribute48             := l_collect_aia_tbl(i).attribute48 ;
        l_adj_rec_type.attribute49             := l_collect_aia_tbl(i).attribute49 ;
        l_adj_rec_type.attribute50             := l_collect_aia_tbl(i).attribute50 ;
        l_adj_rec_type.attribute51             := l_collect_aia_tbl(i).attribute51 ;
        l_adj_rec_type.attribute52             := l_collect_aia_tbl(i).attribute52 ;
        l_adj_rec_type.attribute53             := l_collect_aia_tbl(i).attribute53 ;
        l_adj_rec_type.attribute54             := l_collect_aia_tbl(i).attribute54 ;
        l_adj_rec_type.attribute55             := l_collect_aia_tbl(i).attribute55 ;
        l_adj_rec_type.attribute56             := l_collect_aia_tbl(i).attribute56 ;
        l_adj_rec_type.attribute57             := l_collect_aia_tbl(i).attribute57 ;
        l_adj_rec_type.attribute58             := l_collect_aia_tbl(i).attribute58 ;
        l_adj_rec_type.attribute59             := l_collect_aia_tbl(i).attribute59 ;
        l_adj_rec_type.attribute60             := l_collect_aia_tbl(i).attribute60 ;
        l_adj_rec_type.attribute61             := l_collect_aia_tbl(i).attribute61 ;
        l_adj_rec_type.attribute62             := l_collect_aia_tbl(i).attribute62 ;
        l_adj_rec_type.attribute63             := l_collect_aia_tbl(i).attribute63 ;
        l_adj_rec_type.attribute64             := l_collect_aia_tbl(i).attribute64 ;
        l_adj_rec_type.attribute65             := l_collect_aia_tbl(i).attribute65 ;
        l_adj_rec_type.attribute66             := l_collect_aia_tbl(i).attribute66 ;
        l_adj_rec_type.attribute67             := l_collect_aia_tbl(i).attribute67 ;
        l_adj_rec_type.attribute68             := l_collect_aia_tbl(i).attribute68 ;
        l_adj_rec_type.attribute69             := l_collect_aia_tbl(i).attribute69 ;
        l_adj_rec_type.attribute70             := l_collect_aia_tbl(i).attribute70 ;
        l_adj_rec_type.attribute71             := l_collect_aia_tbl(i).attribute71 ;
        l_adj_rec_type.attribute72             := l_collect_aia_tbl(i).attribute72 ;
        l_adj_rec_type.attribute73             := l_collect_aia_tbl(i).attribute73 ;
        l_adj_rec_type.attribute74             := l_collect_aia_tbl(i).attribute74 ;
        l_adj_rec_type.attribute75             := l_collect_aia_tbl(i).attribute75 ;
        l_adj_rec_type.attribute76             := l_collect_aia_tbl(i).attribute76 ;
        l_adj_rec_type.attribute77             := l_collect_aia_tbl(i).attribute77 ;
        l_adj_rec_type.attribute78             := l_collect_aia_tbl(i).attribute78 ;
        l_adj_rec_type.attribute79             := l_collect_aia_tbl(i).attribute79 ;
        l_adj_rec_type.attribute80             := l_collect_aia_tbl(i).attribute80 ;
        l_adj_rec_type.attribute81             := l_collect_aia_tbl(i).attribute81 ;
        l_adj_rec_type.attribute82             := l_collect_aia_tbl(i).attribute82 ;
        l_adj_rec_type.attribute83             := l_collect_aia_tbl(i).attribute83 ;
        l_adj_rec_type.attribute84             := l_collect_aia_tbl(i).attribute84 ;
        l_adj_rec_type.attribute85             := l_collect_aia_tbl(i).attribute85 ;
        l_adj_rec_type.attribute86             := l_collect_aia_tbl(i).attribute86 ;
        l_adj_rec_type.attribute87             := l_collect_aia_tbl(i).attribute87 ;
        l_adj_rec_type.attribute88             := l_collect_aia_tbl(i).attribute88 ;
        l_adj_rec_type.attribute89             := l_collect_aia_tbl(i).attribute89 ;
        l_adj_rec_type.attribute90             := l_collect_aia_tbl(i).attribute90 ;
        l_adj_rec_type.attribute91             := l_collect_aia_tbl(i).attribute91 ;
        l_adj_rec_type.attribute92             := l_collect_aia_tbl(i).attribute92 ;
        l_adj_rec_type.attribute93             := l_collect_aia_tbl(i).attribute93 ;
        l_adj_rec_type.attribute94             := l_collect_aia_tbl(i).attribute94 ;
        l_adj_rec_type.attribute95             := l_collect_aia_tbl(i).attribute95 ;
        l_adj_rec_type.attribute96             := l_collect_aia_tbl(i).attribute96 ;
        l_adj_rec_type.attribute97             := l_collect_aia_tbl(i).attribute97 ;
        l_adj_rec_type.attribute98             := l_collect_aia_tbl(i).attribute98 ;
        l_adj_rec_type.attribute99             := l_collect_aia_tbl(i).attribute99 ;
        l_adj_rec_type.attribute100            := l_collect_aia_tbl(i).attribute100;
      begin
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_comm_lines_id: ' || l_comm_lines_id);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).invoice_number: ' || l_adj_rec_type.invoice_number);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).invoice_date: ' || l_adj_rec_type.invoice_date);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).transaction_amount: ' || l_adj_rec_type.transaction_amount);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).revenue_type: ' || l_adj_rec_type.revenue_type);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).processed_date: ' || l_adj_rec_type.processed_date);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).trx_type: ' || l_adj_rec_type.trx_type);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).transaction_currency_code: ' || l_adj_rec_type.orig_currency_code);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).salesrep_id: '     || l_adj_rec_type.direct_salesrep_id);
        /*debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute1: ' || l_adj_rec_type.attribute1 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).adjust_comments: ' || l_adj_rec_type.adjust_comments);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute2  : ' || l_adj_rec_type.attribute2 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute3  : ' || l_adj_rec_type.attribute3 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl.attribute4  : '    || l_adj_rec_type.attribute4 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute5  : ' || l_adj_rec_type.attribute5 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute6  : ' || l_adj_rec_type.attribute6 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute7  : ' || l_adj_rec_type.attribute7 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute8  : ' || l_adj_rec_type.attribute8 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute9  : ' || l_adj_rec_type.attribute9  );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute10 : ' || l_adj_rec_type.attribute10 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute11 : ' || l_adj_rec_type.attribute11 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute12 : ' || l_adj_rec_type.attribute12 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute13 : ' || l_adj_rec_type.attribute13 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute14 : ' || l_adj_rec_type.attribute14 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute15 : ' || l_adj_rec_type.attribute15 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute16 : ' || l_adj_rec_type.attribute16 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute17 : ' || l_adj_rec_type.attribute17 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute18 : ' || l_adj_rec_type.attribute18 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute19 : ' || l_adj_rec_type.attribute19 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute20 : ' || l_adj_rec_type.attribute20 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute21 : ' || l_adj_rec_type.attribute21 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute22 : ' || l_adj_rec_type.attribute22 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute23 : ' || l_adj_rec_type.attribute23 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute24 : ' || l_adj_rec_type.attribute24 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute25 : ' || l_adj_rec_type.attribute25 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute26 : ' || l_adj_rec_type.attribute26 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute27 : ' || l_adj_rec_type.attribute27 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute28 : ' || l_adj_rec_type.attribute28 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute29 : ' || l_adj_rec_type.attribute29 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute30 : ' || l_adj_rec_type.attribute30 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute31 : ' || l_adj_rec_type.attribute31 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute32 : ' || l_adj_rec_type.attribute32 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute33 : ' || l_adj_rec_type.attribute33 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute34 : ' || l_adj_rec_type.attribute34 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute35 : ' || l_adj_rec_type.attribute35 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute36 : ' || l_adj_rec_type.attribute36 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute37 : ' || l_adj_rec_type.attribute37 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute38 : ' || l_adj_rec_type.attribute38 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute39 : ' || l_adj_rec_type.attribute39 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute40 : ' || l_adj_rec_type.attribute40 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute41 : ' || l_adj_rec_type.attribute41 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute42 : ' || l_adj_rec_type.attribute42 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute43 : ' || l_adj_rec_type.attribute43 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute44 : ' || l_adj_rec_type.attribute44 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute45 : ' || l_adj_rec_type.attribute45 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute46 : ' || l_adj_rec_type.attribute46 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute47 : ' || l_adj_rec_type.attribute47 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute48 : ' || l_adj_rec_type.attribute48 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute49 : ' || l_adj_rec_type.attribute49 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute50 : ' || l_adj_rec_type.attribute50 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute51 : ' || l_adj_rec_type.attribute51 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute52 : ' || l_adj_rec_type.attribute52 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute53 : ' || l_adj_rec_type.attribute53 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute54 : ' || l_adj_rec_type.attribute54 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute55 : ' || l_adj_rec_type.attribute55 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute56 : ' || l_adj_rec_type.attribute56 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute57 : ' || l_adj_rec_type.attribute57 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute58 : ' || l_adj_rec_type.attribute58 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute59 : ' || l_adj_rec_type.attribute59 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute60 : ' || l_adj_rec_type.attribute60 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute61 : ' || l_adj_rec_type.attribute61 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute62 : ' || l_adj_rec_type.attribute62 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute63 : ' || l_adj_rec_type.attribute63 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute64 : ' || l_adj_rec_type.attribute64 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute65 : ' || l_adj_rec_type.attribute65 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute66 : ' || l_adj_rec_type.attribute66 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute67 : ' || l_adj_rec_type.attribute67 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute68 : ' || l_adj_rec_type.attribute68 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute69 : ' || l_adj_rec_type.attribute69 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute70 : ' || l_adj_rec_type.attribute70 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute71 : ' || l_adj_rec_type.attribute71 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute72 : ' || l_adj_rec_type.attribute72 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute73 : ' || l_adj_rec_type.attribute73 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute74 : ' || l_adj_rec_type.attribute74 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute75 : ' || l_adj_rec_type.attribute75 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute76 : ' || l_adj_rec_type.attribute76 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute77 : ' || l_adj_rec_type.attribute77 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute78 : ' || l_adj_rec_type.attribute78 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute79 : ' || l_adj_rec_type.attribute79 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute80 : ' || l_adj_rec_type.attribute80 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute81 : ' || l_adj_rec_type.attribute81 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute82 : ' || l_adj_rec_type.attribute82 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute83 : ' || l_adj_rec_type.attribute83 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute84 : ' || l_adj_rec_type.attribute84 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute85 : ' || l_adj_rec_type.attribute85 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute86 : ' || l_adj_rec_type.attribute86 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute87 : ' || l_adj_rec_type.attribute87 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute88 : ' || l_adj_rec_type.attribute88 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute89 : ' || l_adj_rec_type.attribute89 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute90 : ' || l_adj_rec_type.attribute90 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute91 : ' || l_adj_rec_type.attribute91 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute92 : ' || l_adj_rec_type.attribute92 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute93 : ' || l_adj_rec_type.attribute93 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute94 : ' || l_adj_rec_type.attribute94 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute95 : ' || l_adj_rec_type.attribute95 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute96 : ' || l_adj_rec_type.attribute96 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute97 : ' || l_adj_rec_type.attribute97 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute98 : ' || l_adj_rec_type.attribute98 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute99 : ' || l_adj_rec_type.attribute99 );
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: l_collect_aia_tbl(i).attribute100: ' || l_adj_rec_type.attribute100);*/
       EXCEPTION
        WHEN OTHERS THEN
        --x_return_status := 'F';
        --DBMS_OUTPUT.put_line('CN_COLLECTION_AIA_PUB.updaterow_comm_api:exception in debug messages others: ' || '[ ' || SQLERRM(SQLCODE()) || ' ]');
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api:exception in debug messages others: ' || SQLERRM(SQLCODE()) );
      end;
        cn_get_tx_data_pub.update_api_record ( p_api_version => 1.0, p_newtx_rec => l_adj_rec_type, x_api_id => l_api_id, x_return_status => l_return_status , x_msg_count => l_msg_count , x_msg_data => l_msg_data, x_loading_status => l_loading_status);
        -- DBMS_OUTPUT.put_line('Start update' || l_collect_aia_tbl(i).invoice_number);
        -- DBMS_OUTPUT.put_line('Start update' || l_comm_lines_id);
        debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: updating update_flag to N of CN_COLLECTION_AIA : ' );
         UPDATE CN_COLLECTION_AIA
        SET update_flag        = 'N'
          WHERE invoice_number = l_collect_aia_tbl(i).invoice_number;

        x_return_status := 'S';
    END LOOP;
    END IF;


  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api: x_return_status: ' || x_return_status);
EXCEPTION
WHEN OTHERS THEN
  x_return_status := 'F';
  debugmsg('CN_COLLECTION_AIA_PUB.updaterow_comm_api:exception others: ' || SQLERRM(SQLCODE()) );
  -- DBMS_OUTPUT.put_line('[ ' || SQLERRM(SQLCODE()) || ' ]');
END updaterow_comm_api;
END CN_COLLECTION_AIA_PUB;

/
