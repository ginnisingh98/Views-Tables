--------------------------------------------------------
--  DDL for Package Body CN_TRANSACTION_LOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_TRANSACTION_LOAD_PUB" AS
-- $Header: cnploadb.pls 120.4.12010000.7 2009/06/30 08:17:47 gmarwah ship $
--+
--+ Global Variable
--+
G_PKG_NAME                  CONSTANT VARCHAR2(30) := 'CN_TRANSACTION_LOAD_PUB';
G_FILE_NAME                 CONSTANT VARCHAR2(12) := 'cnploadb.pls';
G_LAST_UPDATE_DATE          DATE    := sysdate;
G_LAST_UPDATED_BY           NUMBER  := FND_GLOBAL.USER_ID;
G_CREATION_DATE             DATE    := sysdate;
G_CREATED_BY                NUMBER  := FND_GLOBAL.USER_ID;
G_LAST_UPDATE_LOGIN         NUMBER  := FND_GLOBAL.LOGIN_ID;
G_ROWID                     VARCHAR2(30);
G_PROGRAM_TYPE              VARCHAR2(30);

g_logical_process    	VARCHAR2(30) := 'LOAD';
g_physical_process      VARCHAR2(30) := 'LOAD';
no_valid_transactions		EXCEPTION;


-- Local Procedure for showing debug msg

PROCEDURE debugmsg(msg VARCHAR2) IS
BEGIN
   cn_message_pkg.debug(substr(msg,1,254));
END debugmsg;


-- Procedure Name
--   get_physical_batch_id
-- Purpose : get the unique physical batch id

FUNCTION get_physical_batch_id RETURN NUMBER IS
   x_physical_batch_id  NUMBER;
BEGIN
   -- sequence s3 is for physical batch id
   SELECT cn_process_batches_s3.nextval
     INTO x_physical_batch_id
     FROM sys.dual;

   RETURN x_physical_batch_id;
EXCEPTION
   WHEN no_data_found THEN raise NO_DATA_FOUND;
END get_physical_batch_id;


 PROCEDURE update_error (x_physical_batch_id NUMBER) IS
   l_user_id  		NUMBER(15) := fnd_global.user_id;
   l_resp_id  		NUMBER(15) := fnd_global.resp_id;
   l_login_id 		NUMBER(15) := fnd_global.login_id;
   l_conc_prog_id 	NUMBER(15) := fnd_global.conc_program_id;
   l_conc_request_id 	NUMBER(15) := fnd_global.conc_request_id;
   l_prog_appl_id 	NUMBER(15) := fnd_global.prog_appl_id;

 BEGIN
       -- Giving the batch an 'ERROR' status prevents subsequent
       -- physical processes picking it up.
        UPDATE cn_process_batches
      	   SET status_code 	      = 'ERROR'
   	      ,last_update_date       = sysdate
	      ,last_update_login      = l_login_id
	      ,last_updated_by        = l_user_id
	      ,request_id             = l_conc_request_id
	      ,program_application_id = l_prog_appl_id
	      ,program_id             = l_conc_prog_id
	      ,program_update_date    = sysdate
         WHERE physical_batch_id      = x_physical_batch_id;
 END update_error;

   -- Procedure: load_worker
   PROCEDURE load_worker
     (
      x_return_status          OUT NOCOPY VARCHAR2,
      x_msg_count              OUT NOCOPY NUMBER,
      x_msg_data               OUT NOCOPY VARCHAR2,
      p_physical_batch_id      IN  NUMBER,
      p_salesrep_id            IN  NUMBER,
      p_start_date             IN  DATE,
      p_end_date               IN  DATE,
      p_cls_rol_flag           IN  VARCHAR2,
      p_loading_status         IN  VARCHAR2,
      p_org_id		       IN  NUMBER,
      x_loading_status         OUT NOCOPY VARCHAR2
      ) IS

      l_api_name        CONSTANT VARCHAR2(30) := 'load_worker';

      CURSOR batches IS
	 SELECT
	   salesrep_id,
	   period_id,
	   start_date,
	   end_date,
	   sales_lines_total trx_count
	   FROM
	   cn_process_batches
	   WHERE
	   physical_batch_id = p_physical_batch_id AND
	   status_code = 'IN_USE';


      Counter NUMBER;

      l_counter       NUMBER;
      l_init_commission_header_id  NUMBER;

      l_skip_credit_flag    VARCHAR2(1);

   BEGIN

      --  Initialize API return status to success
      x_return_status := FND_API.G_RET_STS_SUCCESS;
      x_loading_status := p_loading_status;

      -- Start of API body

      Counter := 0;

      /* Get the value of the profile "OIC: Skip Credit Allocation" */
      l_skip_credit_flag := 'Y';
      IF (Fnd_Profile.DEFINED('CN_SKIP_CREDIT_ALLOCATION')) THEN
        l_skip_credit_flag := NVL(Fnd_Profile.VALUE('CN_SKIP_CREDIT_ALLOCATION'), 'Y');
      END IF;

      -- this is used to make it more restrict for handling reversal trx later on
      SELECT cn_commission_headers_s.NEXTVAL
	INTO l_init_commission_header_id FROM dual;

      FOR batch IN batches LOOP

	debugmsg('Loader : Load_Worker : Load ' ||
		 to_char(batch.trx_count) ||
		 ' lines for physical batch = ' ||
		 p_physical_batch_id ||
		 ' salesrep id = ' || batch.salesrep_id ||
		 ' period_id = ' || batch.period_id ||
		 ' p_salesrep_id = ' || p_salesrep_id ||
		 ' p_start_date = ' || p_start_date ||
		 ' p_end_date = ' || p_end_date ||
		 ' p_cls_rol_flag = ' || p_cls_rol_flag);

	Counter := Counter + batch.trx_count;

   IF (l_skip_credit_flag = 'Y') THEN
	INSERT INTO cn_commission_headers_all
	  (commission_header_id,
	   direct_salesrep_id,
	   processed_date,
	   processed_period_id,
	   rollup_date,
	   transaction_amount,
	   quantity,
	   discount_percentage,
	   margin_percentage,
	   orig_currency_code,
	   TRANSACTION_AMOUNT_ORIG,
	   trx_type,
	   status,
	   pre_processed_code,
	   COMM_LINES_API_ID,
	   SOURCE_DOC_TYPE,
	   SOURCE_TRX_NUMBER,
	   quota_id,
	   srp_plan_assign_id,
	   revenue_class_id,
	   role_id,
	   comp_group_id,
	   commission_amount,
	   reversal_flag,
	   reversal_header_id,
	   reason_code,
           attribute_category,
	   attribute1,
	   attribute2,
	   attribute3,
	   attribute4,
	   attribute5,
	   attribute6,
	   attribute7,
	   attribute8,
	   attribute9,
	   attribute10,
	   attribute11,
	   attribute12,
	   attribute13,
	   attribute14,
	   attribute15,
	   attribute16,
	   attribute17,
	   attribute18,
	   attribute19,
	   attribute20,
	   attribute21,
	   attribute22,
	   attribute23,
	   attribute24,
	   attribute25,
	   attribute26,
	  attribute27,
	  attribute28,
	  attribute29,
	  attribute30,
	  attribute31,
	  attribute32,
	  attribute33,
	  attribute34,
	  attribute35,
	  attribute36,
	  attribute37,
	  attribute38,
	  attribute39,
	  attribute40,
	  attribute41,
	  attribute42,
	  attribute43,
	  attribute44,
	  attribute45,
	  attribute46,
	  attribute47,
	  attribute48,
	  attribute49,
	  attribute50,
	  attribute51,
	  attribute52,
	  attribute53,
	  attribute54,
	  attribute55,
	  attribute56,
	  attribute57,
	  attribute58,
	  attribute59,
	  attribute60,
	  attribute61,
	  attribute62,
	  attribute63,
	  attribute64,
	  attribute65,
	  attribute66,
	  attribute67,
	  attribute68,
	  attribute69,
	  attribute70,
	  attribute71,
	  attribute72,
	  attribute73,
	  attribute74,
	  attribute75,
	  attribute76,
	  attribute77,
	  attribute78,
	  attribute79,
	  attribute80,
	  attribute81,
	  attribute82,
	  attribute83,
	  attribute84,
	  attribute85,
	  attribute86,
	  attribute87,
	  attribute88,
	  attribute89,
	  attribute90,
	  attribute91,
	  attribute92,
	  attribute93,
	  attribute94,
	  attribute95,
	  attribute96,
	  attribute97,
	  attribute98,
	  attribute99,
	  attribute100,
	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  creation_date,
	  created_by,
	  EXCHANGE_RATE,
	  FORECAST_ID,
	  UPSIDE_QUANTITY,
	  UPSIDE_AMOUNT,
	  UOM_CODE,
	  SOURCE_TRX_ID,
	  SOURCE_TRX_LINE_ID,
	  SOURCE_TRX_SALES_LINE_ID,
	  NEGATED_FLAG,
	  CUSTOMER_ID,
	  INVENTORY_ITEM_ID,
	  ORDER_NUMBER,
	  BOOKED_DATE,
	  INVOICE_NUMBER,
	  INVOICE_DATE,
	  BILL_TO_ADDRESS_ID,
	  SHIP_TO_ADDRESS_ID,
	  BILL_TO_CONTACT_ID,
	  SHIP_TO_CONTACT_ID,
	  ADJ_COMM_LINES_API_ID,
	  ADJUST_DATE,
	  ADJUSTED_BY,
	  REVENUE_TYPE,
	  ADJUST_ROLLUP_FLAG,
	  ADJUST_COMMENTS,
	  ADJUST_STATUS,
	  line_number,
	  type,
	  sales_channel,
	  split_pct,
          split_status,
          org_id)
	  (SELECT
	   cn_commission_headers_s.nextval,
	   batch.salesrep_id,
	   Trunc(api.processed_date),
	   batch.period_id,
	   Trunc(api.rollup_date),
	   api.acctd_transaction_amount,
	   api.quantity,
	   api.discount_percentage,
	   api.margin_percentage,
	   api.transaction_currency_code,
	   api.transaction_amount,
	   api.trx_type,
	   'COL',
	   Nvl(api.pre_processed_code,'CRPC'),
	   api.comm_lines_api_id,
	   api.source_doc_type,
	   api.source_trx_number,
	   api.quota_id,
	   api.srp_plan_assign_id,
	   api.revenue_class_id,
	   api.role_id,
	   api.comp_group_id,
	   api.commission_amount,
	   api.reversal_flag,
	   api.reversal_header_id,
	   api.reason_code,
           api.attribute_category,
	   api.attribute1,
	   api.attribute2,
	   api.attribute3,
	   api.attribute4,
	   api.attribute5,
	   api.attribute6,
	   api.attribute7,
	   api.attribute8,
	   api.attribute9,
	   api.attribute10,
	   api.attribute11,
	   api.attribute12,
	   api.attribute13,
	   api.attribute14,
	   api.attribute15,
	   api.attribute16,
	  api.attribute17,
	  api.attribute18,
	  api.attribute19,
	  api.attribute20,
	  api.attribute21,
	  api.attribute22,
	  api.attribute23,
	  api.attribute24,
	  api.attribute25,
	  api.attribute26,
	  api.attribute27,
	  api.attribute28,
	  api.attribute29,
	  api.attribute30,
	  api.attribute31,
	  api.attribute32,
	  api.attribute33,
	  api.attribute34,
	  api.attribute35,
	  api.attribute36,
	  api.attribute37,
	  api.attribute38,
	  api.attribute39,
	  api.attribute40,
	  api.attribute41,
	  api.attribute42,
	  api.attribute43,
	  api.attribute44,
	  api.attribute45,
	  api.attribute46,
	  api.attribute47,
	  api.attribute48,
	  api.attribute49,
	  api.attribute50,
	  api.attribute51,
	  api.attribute52,
	  api.attribute53,
	  api.attribute54,
	  api.attribute55,
	  api.attribute56,
	  api.attribute57,
	  api.attribute58,
	  api.attribute59,
	  api.attribute60,
	  api.attribute61,
	  api.attribute62,
	  api.attribute63,
	  api.attribute64,
	  api.attribute65,
	  api.attribute66,
	  api.attribute67,
	  api.attribute68,
	  api.attribute69,
	  api.attribute70,
	  api.attribute71,
	  api.attribute72,
	  api.attribute73,
	  api.attribute74,
	  api.attribute75,
	  api.attribute76,
	  api.attribute77,
	  api.attribute78,
	  api.attribute79,
	  api.attribute80,
	  api.attribute81,
	  api.attribute82,
	  api.attribute83,
	  api.attribute84,
	  api.attribute85,
	  api.attribute86,
	  api.attribute87,
	  api.attribute88,
	  api.attribute89,
	  api.attribute90,
	  api.attribute91,
	  api.attribute92,
	  api.attribute93,
	  api.attribute94,
	  api.attribute95,
	  api.attribute96,
	  api.attribute97,
	  api.attribute98,
	  api.attribute99,
	  api.attribute100,
	  sysdate,
	  api.last_updated_by,
	  api.last_update_login,
	  sysdate,
	  api.created_by,
	  api.exchange_rate,
	  api.FORECAST_ID,
	  api.UPSIDE_QUANTITY,
	  api.UPSIDE_AMOUNT,
	  api.UOM_CODE,
	  api.SOURCE_TRX_ID,
	  api.SOURCE_TRX_LINE_ID,
	  api.SOURCE_TRX_SALES_LINE_ID,
	  api.NEGATED_FLAG,
	  api.CUSTOMER_ID,
	  api.INVENTORY_ITEM_ID,
	  api.ORDER_NUMBER,
	  api.BOOKED_DATE,
	  api.INVOICE_NUMBER,
	  api.INVOICE_DATE,
	  api.BILL_TO_ADDRESS_ID,
	  api.SHIP_TO_ADDRESS_ID,
	  api.BILL_TO_CONTACT_ID,
	  api.SHIP_TO_CONTACT_ID,
	  api.ADJ_COMM_LINES_API_ID,
	  api.ADJUST_DATE,
	  api.ADJUSTED_BY,
	  api.REVENUE_TYPE,
	  api.ADJUST_ROLLUP_FLAG,
	  api.ADJUST_COMMENTS,
	  NVL(api.ADJUST_STATUS,'NEW'),
	  api.line_number,
	  api.type,
	  api.sales_channel,
          api.split_pct,
          api.split_status,
	  api.org_id
	  FROM
	  cn_comm_lines_api_all api
	  WHERE
	  api.load_status = 'UNLOADED' AND
	  api.processed_date >= TRUNC(p_start_date) AND
	  api.processed_date < (TRUNC(p_end_date) + 1) AND
	  ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	  api.trx_type <> 'FORECAST' AND
	  (api.adjust_status <> 'SCA_PENDING') AND --OR api.adjust_status IS NULL) AND
	  api.salesrep_id = batch.salesrep_id AND
	  api.processed_date >= Trunc(batch.start_date) AND
	  api.processed_date < (Trunc(batch.end_date) + 1) AND
      api.org_id = p_org_id);
  ELSE
	INSERT INTO cn_commission_headers_all
	  (commission_header_id,
	   direct_salesrep_id,
	   processed_date,
	   processed_period_id,
	   rollup_date,
	   transaction_amount,
	   quantity,
	   discount_percentage,
	   margin_percentage,
	   orig_currency_code,
	   TRANSACTION_AMOUNT_ORIG,
	   trx_type,
	   status,
	   pre_processed_code,
	   COMM_LINES_API_ID,
	   SOURCE_DOC_TYPE,
	   SOURCE_TRX_NUMBER,
	   quota_id,
	   srp_plan_assign_id,
	   revenue_class_id,
	   role_id,
	   comp_group_id,
	   commission_amount,
	   reversal_flag,
	   reversal_header_id,
	   reason_code,
           attribute_category,
	   attribute1,
	   attribute2,
	   attribute3,
	   attribute4,
	   attribute5,
	   attribute6,
	   attribute7,
	   attribute8,
	   attribute9,
	   attribute10,
	   attribute11,
	   attribute12,
	   attribute13,
	   attribute14,
	   attribute15,
	   attribute16,
	   attribute17,
	   attribute18,
	   attribute19,
	   attribute20,
	   attribute21,
	   attribute22,
	   attribute23,
	   attribute24,
	   attribute25,
	   attribute26,
	  attribute27,
	  attribute28,
	  attribute29,
	  attribute30,
	  attribute31,
	  attribute32,
	  attribute33,
	  attribute34,
	  attribute35,
	  attribute36,
	  attribute37,
	  attribute38,
	  attribute39,
	  attribute40,
	  attribute41,
	  attribute42,
	  attribute43,
	  attribute44,
	  attribute45,
	  attribute46,
	  attribute47,
	  attribute48,
	  attribute49,
	  attribute50,
	  attribute51,
	  attribute52,
	  attribute53,
	  attribute54,
	  attribute55,
	  attribute56,
	  attribute57,
	  attribute58,
	  attribute59,
	  attribute60,
	  attribute61,
	  attribute62,
	  attribute63,
	  attribute64,
	  attribute65,
	  attribute66,
	  attribute67,
	  attribute68,
	  attribute69,
	  attribute70,
	  attribute71,
	  attribute72,
	  attribute73,
	  attribute74,
	  attribute75,
	  attribute76,
	  attribute77,
	  attribute78,
	  attribute79,
	  attribute80,
	  attribute81,
	  attribute82,
	  attribute83,
	  attribute84,
	  attribute85,
	  attribute86,
	  attribute87,
	  attribute88,
	  attribute89,
	  attribute90,
	  attribute91,
	  attribute92,
	  attribute93,
	  attribute94,
	  attribute95,
	  attribute96,
	  attribute97,
	  attribute98,
	  attribute99,
	  attribute100,
	  last_update_date,
	  last_updated_by,
	  last_update_login,
	  creation_date,
	  created_by,
	  EXCHANGE_RATE,
	  FORECAST_ID,
	  UPSIDE_QUANTITY,
	  UPSIDE_AMOUNT,
	  UOM_CODE,
	  SOURCE_TRX_ID,
	  SOURCE_TRX_LINE_ID,
	  SOURCE_TRX_SALES_LINE_ID,
	  NEGATED_FLAG,
	  CUSTOMER_ID,
	  INVENTORY_ITEM_ID,
	  ORDER_NUMBER,
	  BOOKED_DATE,
	  INVOICE_NUMBER,
	  INVOICE_DATE,
	  BILL_TO_ADDRESS_ID,
	  SHIP_TO_ADDRESS_ID,
	  BILL_TO_CONTACT_ID,
	  SHIP_TO_CONTACT_ID,
	  ADJ_COMM_LINES_API_ID,
	  ADJUST_DATE,
	  ADJUSTED_BY,
	  REVENUE_TYPE,
	  ADJUST_ROLLUP_FLAG,
	  ADJUST_COMMENTS,
	  ADJUST_STATUS,
	  line_number,
	  type,
	  sales_channel,
	  split_pct,
          split_status,
          org_id)
	  (SELECT
	   cn_commission_headers_s.nextval,
	   batch.salesrep_id,
	   Trunc(api.processed_date),
	   batch.period_id,
	   Trunc(api.rollup_date),
	   api.acctd_transaction_amount,
	   api.quantity,
	   api.discount_percentage,
	   api.margin_percentage,
	   api.transaction_currency_code,
	   api.transaction_amount,
	   api.trx_type,
	   'COL',
	   Nvl(api.pre_processed_code,'CRPC'),
	   api.comm_lines_api_id,
	   api.source_doc_type,
	   api.source_trx_number,
	   api.quota_id,
	   api.srp_plan_assign_id,
	   api.revenue_class_id,
	   api.role_id,
	   api.comp_group_id,
	   api.commission_amount,
	   api.reversal_flag,
	   api.reversal_header_id,
	   api.reason_code,
           api.attribute_category,
	   api.attribute1,
	   api.attribute2,
	   api.attribute3,
	   api.attribute4,
	   api.attribute5,
	   api.attribute6,
	   api.attribute7,
	   api.attribute8,
	   api.attribute9,
	   api.attribute10,
	   api.attribute11,
	   api.attribute12,
	   api.attribute13,
	   api.attribute14,
	   api.attribute15,
	   api.attribute16,
	  api.attribute17,
	  api.attribute18,
	  api.attribute19,
	  api.attribute20,
	  api.attribute21,
	  api.attribute22,
	  api.attribute23,
	  api.attribute24,
	  api.attribute25,
	  api.attribute26,
	  api.attribute27,
	  api.attribute28,
	  api.attribute29,
	  api.attribute30,
	  api.attribute31,
	  api.attribute32,
	  api.attribute33,
	  api.attribute34,
	  api.attribute35,
	  api.attribute36,
	  api.attribute37,
	  api.attribute38,
	  api.attribute39,
	  api.attribute40,
	  api.attribute41,
	  api.attribute42,
	  api.attribute43,
	  api.attribute44,
	  api.attribute45,
	  api.attribute46,
	  api.attribute47,
	  api.attribute48,
	  api.attribute49,
	  api.attribute50,
	  api.attribute51,
	  api.attribute52,
	  api.attribute53,
	  api.attribute54,
	  api.attribute55,
	  api.attribute56,
	  api.attribute57,
	  api.attribute58,
	  api.attribute59,
	  api.attribute60,
	  api.attribute61,
	  api.attribute62,
	  api.attribute63,
	  api.attribute64,
	  api.attribute65,
	  api.attribute66,
	  api.attribute67,
	  api.attribute68,
	  api.attribute69,
	  api.attribute70,
	  api.attribute71,
	  api.attribute72,
	  api.attribute73,
	  api.attribute74,
	  api.attribute75,
	  api.attribute76,
	  api.attribute77,
	  api.attribute78,
	  api.attribute79,
	  api.attribute80,
	  api.attribute81,
	  api.attribute82,
	  api.attribute83,
	  api.attribute84,
	  api.attribute85,
	  api.attribute86,
	  api.attribute87,
	  api.attribute88,
	  api.attribute89,
	  api.attribute90,
	  api.attribute91,
	  api.attribute92,
	  api.attribute93,
	  api.attribute94,
	  api.attribute95,
	  api.attribute96,
	  api.attribute97,
	  api.attribute98,
	  api.attribute99,
	  api.attribute100,
	  sysdate,
	  api.last_updated_by,
	  api.last_update_login,
	  sysdate,
	  api.created_by,
	  api.exchange_rate,
	  api.FORECAST_ID,
	  api.UPSIDE_QUANTITY,
	  api.UPSIDE_AMOUNT,
	  api.UOM_CODE,
	  api.SOURCE_TRX_ID,
	  api.SOURCE_TRX_LINE_ID,
	  api.SOURCE_TRX_SALES_LINE_ID,
	  api.NEGATED_FLAG,
	  api.CUSTOMER_ID,
	  api.INVENTORY_ITEM_ID,
	  api.ORDER_NUMBER,
	  api.BOOKED_DATE,
	  api.INVOICE_NUMBER,
	  api.INVOICE_DATE,
	  api.BILL_TO_ADDRESS_ID,
	  api.SHIP_TO_ADDRESS_ID,
	  api.BILL_TO_CONTACT_ID,
	  api.SHIP_TO_CONTACT_ID,
	  api.ADJ_COMM_LINES_API_ID,
	  api.ADJUST_DATE,
	  api.ADJUSTED_BY,
	  api.REVENUE_TYPE,
	  api.ADJUST_ROLLUP_FLAG,
	  api.ADJUST_COMMENTS,
	  NVL(api.ADJUST_STATUS,'NEW'),
	  api.line_number,
	  api.type,
	  api.sales_channel,
          api.split_pct,
          api.split_status,
	  api.org_id
	  FROM
	  cn_comm_lines_api_all api
	  WHERE
	  api.load_status = 'UNLOADED' AND
	  api.processed_date >= TRUNC(p_start_date) AND
	  api.processed_date < (TRUNC(p_end_date) + 1) AND
	  ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	  api.trx_type <> 'FORECAST' AND
	  (api.adjust_status <> 'SCA_PENDING') AND -- OR api.adjust_status IS NULL) AND
	  api.salesrep_id = batch.salesrep_id AND
	  api.processed_date >= Trunc(batch.start_date) AND
	  api.processed_date < (Trunc(batch.end_date) + 1) AND
      (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y') AND
          api.org_id = p_org_id);
  END IF;

	debugmsg('Loader : number of loaded trx = ' ||to_char(SQL%ROWCOUNT));

  IF (l_skip_credit_flag = 'Y') THEN
	UPDATE cn_comm_lines_api_all api
	  SET load_Status = 'LOADED'
	  WHERE
	  api.load_status  = 'UNLOADED' AND
	  api.processed_date >= TRUNC(p_start_date) AND
	  api.processed_date < (TRUNC(p_end_date) + 1) AND
	  ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	  api.trx_type <> 'FORECAST' AND
	  (api.adjust_status <> 'SCA_PENDING' ) AND -- OR api.adjust_status IS NULL) AND
	  api.salesrep_id = batch.salesrep_id AND
	  api.processed_date >= Trunc(batch.start_date) AND
	  api.processed_date < (Trunc(batch.end_date) + 1) AND
          api.org_id = p_org_id;
  ELSE
	UPDATE cn_comm_lines_api_all api
	  SET load_Status = 'LOADED'
	  WHERE
	  api.load_status  = 'UNLOADED' AND
	  api.processed_date >= TRUNC(p_start_date) AND
	  api.processed_date < (TRUNC(p_end_date) + 1) AND
	  ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	  api.trx_type <> 'FORECAST' AND
	  (api.adjust_status <> 'SCA_PENDING' ) AND -- OR api.adjust_status IS NULL) AND
	  api.salesrep_id = batch.salesrep_id AND
	  api.processed_date >= Trunc(batch.start_date) AND
	  api.processed_date < (Trunc(batch.end_date) + 1) AND
      (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y') AND
          api.org_id = p_org_id;
  END IF;

     END LOOP;

     -- Handle reversal transaction add on 10/15/99
     DECLARE
	CURSOR l_headers IS
	   SELECT cch.commission_header_id, cch.reversal_flag, cch.reversal_header_id
	     FROM cn_commission_headers cch,
	     (SELECT DISTINCT salesrep_id
	      FROM cn_process_batches
	      WHERE physical_batch_id = p_physical_batch_id
	      AND status_code = 'IN_USE') pb
	     WHERE cch.direct_salesrep_id = pb.salesrep_id
	     AND cch.commission_header_id > l_init_commission_header_id;
     BEGIN
	FOR l_header IN l_headers LOOP
	   -- Only pass in the "reversal" trx into handle_reversal_trx
	   -- Do not pass in the original trx eventhough its reversal_flag = 'Y'
	   IF (l_header.reversal_flag = 'Y') AND
	     (l_header.commission_header_id <> l_header.reversal_header_id) THEN
	      cn_formula_common_pkg.handle_reversal_trx(l_header.commission_header_id);
	  END IF;
	END LOOP;
     END;

     IF (p_cls_rol_flag = 'Y') THEN

	debugmsg('Loader : Load_Worker : Classify : p_physical_batch_id = '
		 || p_physical_batch_id);
	debugmsg('Loader : Load_Worker : Classify : calling cn_calc_classify_pvt.classify_batch');


	cn_calc_classify_pvt.classify_batch
	  ( p_api_version       => 1.0,
	    p_init_msg_list     => fnd_api.g_true,
	    p_commit            => fnd_api.g_true ,
	    x_return_status     => x_return_status,
	    x_msg_count         => x_msg_count,
	    x_msg_data          => x_msg_data,
	    p_physical_batch_id => p_physical_batch_id,
	    p_mode              => 'NEW');

     debugmsg('Loader : Load_Workder : Classify : return status is '
	      || x_return_status );
     debugmsg('Loader : Load_Workder : Classify : l_msg_count is '
	      || x_msg_count );
     debugmsg('Loader : Load_Workder : Classify : l_msg_data is '
	      || x_msg_data );

     FOR l_counter IN 1..x_msg_count LOOP
	debugmsg( FND_MSG_PUB.get(p_msg_index => l_counter,
				  p_encoded   => FND_API.G_FALSE));
     END LOOP;

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        debugmsg('Loader : load_worker : Classification Failed.');
	x_loading_status := 'CN_FAIL_CLASSIFICATION';
	RAISE FND_API.G_EXC_ERROR;
     END IF;

     debugmsg('Loader : Load_Worker : Rollup : p_physical_batch_id = '
	      || p_physical_batch_id);
     debugmsg('Loader : Load_Worker : Rollup : calling cn_calc_classify_pvt.classify_batch');

     cn_calc_rollup_pvt.rollup_batch
       ( p_api_version       => 1.0,
	 p_init_msg_list     => fnd_api.g_true,
	 p_commit            => fnd_api.g_true ,
	 x_return_status     => x_return_status,
	 x_msg_count         => x_msg_count,
	 x_msg_data          => x_msg_data,
	 p_physical_batch_id => p_physical_batch_id,
	 p_mode              => 'NEW');

     debugmsg('Loader : Load_Workder : Rollup : return status is '
	      || x_return_status );
     debugmsg('Loader : Load_Workder : Rollup : l_msg_count is '
	      || x_msg_count );
     debugmsg('Loader : Load_Workder : Rollup : l_msg_data is '
	      || x_msg_data );


     FOR l_counter IN 1..x_msg_count LOOP
	debugmsg( FND_MSG_PUB.get(p_msg_index => l_counter,
				  p_encoded   => FND_API.G_FALSE));
     END LOOP;

     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
	debugmsg('Loader : load_worker : Rollup Failed.');
	x_loading_status := 'CN_FAIL_ROLLUP';
	RAISE FND_API.G_EXC_ERROR;
     END IF;

    ELSE

	debugmsg('Loader : Load_Worker : classification/rollup flag is NO. Skip Classification and Rollup.');

    END IF;
     -- End of API body.

     -- Standard call to get message count and if count is 1, get message info.

    FND_MSG_PUB.Count_And_Get
      (
       p_count   =>  x_msg_count ,
       p_data    =>  x_msg_data  ,
       p_encoded => FND_API.G_FALSE
       );

   EXCEPTION
      WHEN FND_API.G_EXC_ERROR THEN
	 x_return_status := FND_API.G_RET_STS_ERROR ;
	 debugmsg('Loader : load_worker : Exception : Error msg : ' || x_msg_data);
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   =>  x_msg_count ,
	    p_data    =>  x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 x_loading_status := 'UNEXPECTED_ERR';
	 debugmsg('Loader : load_worker : Exception : Unexpected Error : Error message : ' || x_msg_data);
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   =>  x_msg_count ,
	    p_data    =>  x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
      WHEN OTHERS THEN
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 x_loading_status := 'UNEXPECTED_ERR';
	 debugmsg('Loader : load_worker : Exception Others : Error : Error message : ' || x_msg_data);
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   =>  x_msg_count ,
	    p_data    =>  x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
   END Load_worker;


-- Start of Comments
-- API name 	: Load
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to load transactions from API table (CN_COMM_LINES_API)
--                to HEADER table (CN_COMMISSION_HEADERS)
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		:  p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		:  p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		:  p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		:  x_msg_count	       OUT	      NUMBER
-- 		:  x_msg_data	       OUT	      VARCHAR2(2000)
--              :  x_loading_status         OUT            VARCHAR2
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes
-- Description : This procedure loads trx from CN_COMM_LINES_API to
--               CN_COMMISSION_HEADERS, update cn_process_batches,
--               and perform trx classification, and trx rollup.
--
-- Special Notes : This public API will load trx sequentially instead
--                 of submitting concurrent process to load trx in parallel
--                 as the regular loader does.
-- End of comments


-- Call begin_batch to get process_audit_id
-- Insert into cn_process_batches, populate logical_batch_id
-- Call Assign : populate physical_batch_id
-- Call Conc_dispatch : For each physical_batch_id call load_worker.
-- Note that this public API will load trx sequentially instead of submitting
-- concurrent process to load trx in parallel as the regular loader does
-- Load_worker :
-- 1.load trx into HEADER
-- 2.perform trx classification
-- 3.perform trx rollup


  PROCEDURE load
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_salesrep_id        IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_cls_rol_flag       IN    VARCHAR2,
   p_org_id 		IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   x_loading_status     OUT NOCOPY   VARCHAR2,
   x_process_audit_id   OUT NOCOPY   NUMBER
   ) IS


      l_api_name        CONSTANT VARCHAR2(30) := 'Load';
      l_api_version     CONSTANT NUMBER  := 1.0;

      TYPE l_emp_no_tbl_type IS TABLE OF cn_comm_lines_api.employee_number%TYPE;
      TYPE l_srp_id_tbl_type IS TABLE OF cn_comm_lines_api.salesrep_id%TYPE;
      TYPE l_period_id_tbl_type IS TABLE OF cn_acc_period_statuses_v.period_id%TYPE;
      TYPE l_start_date_tbl_type IS TABLE OF cn_acc_period_statuses_v.start_date%TYPE;
      TYPE l_end_date_tbl_type IS TABLE OF cn_acc_period_statuses_v.end_date%TYPE;
      TYPE l_count_tbl_type IS TABLE OF NUMBER;

      l_emp_no_tbl l_emp_no_tbl_type;
      l_srp_id_tbl l_srp_id_tbl_type;
      l_period_id_tbl l_period_id_tbl_type;
      l_start_date_tbl l_start_date_tbl_type;
      l_end_date_tbl l_end_date_tbl_type;
      l_count_tbl l_count_tbl_type;


      l_user_id  	NUMBER(15) := fnd_global.user_id;
      l_resp_id  	NUMBER(15) := fnd_global.resp_id;
      l_login_id 	NUMBER(15) := fnd_global.login_id;
      l_conc_prog_id 	NUMBER(15) := fnd_global.conc_program_id;
      l_conc_request_id NUMBER(15) := fnd_global.conc_request_id;
      l_prog_appl_id 	NUMBER(15) := fnd_global.prog_appl_id;

      l_logical_batch_id   NUMBER;
      l_process_batch_id   NUMBER;

      --+
      --+ Added Counter Variable : Hithanki 03/06/2003 For Bug Fix : 2781346
      --+
      l_process_rec_cnt	   NUMBER := 0;

      l_skip_credit_flag    VARCHAR2(1);
      l_logical_batch_count NUMBER;
      l_return_status      VARCHAR2(1);
      l_msg_count	   NUMBER;
      l_msg_data	   VARCHAR2(2000);
      l_loading_status     VARCHAR2(200);

      -- Declaration for user hooks
      l_OAI_array    JTF_USR_HKS.oai_data_array_type;
      l_bind_data_id NUMBER;

      -- get the number of valid transactions to load
      CURSOR valid_transactions (p_logical_batch_id NUMBER) IS
      SELECT  salesrep_id, SUM(sales_lines_total) srp_trx_count
	FROM cn_process_batches
	WHERE logical_batch_id = p_logical_batch_id
	AND status_code = 'IN_USE'
	GROUP BY salesrep_id;

      valid_rec valid_transactions%ROWTYPE;

      -- get the trx count for each srp-period
      CURSOR logical_batches(p_salesrep_id NUMBER,
			     p_start_date  DATE,
			     p_end_date    DATE,
             		     p_org_id 	   NUMBER) IS
	 SELECT
	   api.employee_number employee_number,
	   api.salesrep_id salesrep_id,
	   acc.period_id period_id,
	   acc.start_date start_date,
	   acc.end_date end_date,
	   count(*) trx_count
	   FROM
	   cn_comm_lines_api_all api,
	   cn_acc_period_statuses_v acc
	   WHERE
	   api.load_status = 'UNLOADED' AND
	   api.trx_type <> 'FORECAST' AND
  	   (api.adjust_status <> 'SCA_PENDING' ) AND -- OR api.adjust_status IS NULL) AND
	   api.processed_date >= TRUNC(p_start_date) AND
	   api.processed_date < (TRUNC(p_end_date) + 1) AND
	   ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	   api.processed_date >= acc.start_date AND
	   api.processed_date < (acc.end_date + 1) AND
	   api.org_id = p_org_id AND
	   acc.org_id = p_org_id  --added for the bug 7494675
	   GROUP BY
	   api.employee_number,
	   api.salesrep_id,
	   acc.period_id,
	   acc.start_date,
	   acc.end_date;

      CURSOR logical_batches2(p_salesrep_id NUMBER,
			     p_start_date  DATE,
			     p_end_date    DATE,
                 p_org_id      NUMBER) IS
	 SELECT
	   api.employee_number employee_number,
	   api.salesrep_id salesrep_id,
	   acc.period_id period_id,
	   acc.start_date start_date,
	   acc.end_date end_date,
	   count(*) trx_count
	   FROM
	   cn_comm_lines_api_all api,
	   cn_acc_period_statuses_v acc
	   WHERE
	   api.load_status = 'UNLOADED' AND
	   api.trx_type <> 'FORECAST' AND
       (adjust_status <> 'SCA_PENDING' ) AND -- OR adjust_status IS NULL) AND
	   api.processed_date >= TRUNC(p_start_date) AND
	   api.processed_date < (TRUNC(p_end_date) + 1) AND
	   ((p_salesrep_id IS NULL) OR (api.salesrep_id = p_salesrep_id)) AND
	   api.processed_date >= acc.start_date AND
	   api.processed_date < (acc.end_date + 1) AND
       api.org_id = p_org_id AND
       acc.org_id = p_org_id AND --added for the bug 7494675
       (api.terr_id IS NOT NULL OR api.preserve_credit_override_flag = 'Y')
	   GROUP BY
	   api.employee_number,
	   api.salesrep_id,
	   acc.period_id,
	   acc.start_date,
	   acc.end_date;

      -- Get individual physical batch id
      CURSOR physical_batches(l_logical_batch_id NUMBER) IS
	 SELECT DISTINCT physical_batch_id
	   FROM cn_process_batches
	   WHERE logical_batch_id = l_logical_batch_id
	   AND status_code = 'IN_USE';

      physical_rec physical_batches%ROWTYPE;
      l_count  NUMBER;

   BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT	load_savepoint;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.compatible_api_call
	( l_api_version ,p_api_version ,l_api_name ,G_PKG_NAME )
	THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list ) THEN
	 FND_MSG_PUB.initialize;
      END IF;

      --  Initialize API return status to success
      x_return_status  := FND_API.G_RET_STS_SUCCESS;
      x_loading_status := 'CN_LOADED';


      -- User hooks
      --  Customer pre-processing section

      IF JTF_USR_HKS.Ok_to_Execute('CN_TRANSACTION_LOAD_PUB',
				'LOAD',
				'B',
				'C')
	THEN

	 cn_transaction_load_pub_cuhk.load_pre
	   (p_api_version       => p_api_version,
	    p_init_msg_list	=> p_init_msg_list,
	    p_commit	    	=> p_commit,
	    p_validation_level	=> p_validation_level,
	    x_return_status     => x_return_status,
	    x_msg_count         => x_msg_count,
	    x_msg_data          => x_msg_data,
	    x_loading_status    => x_loading_status
	    );

	 IF (x_return_status = FND_API.G_RET_STS_ERROR )
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;


      -- Vertical industry pre-processing section

      IF JTF_USR_HKS.Ok_to_Execute('CN_TRANSACTION_LOAD_PUB',
				   'LOAD',
				   'B',
				   'V')
	THEN

	 cn_transaction_load_pub_vuhk.load_pre
	   (p_api_version          => p_api_version,
	    p_init_msg_list	   => p_init_msg_list,
	    p_commit	    	   => p_commit,
	    p_validation_level	   => p_validation_level,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	    x_loading_status       => x_loading_status
	    );

	 IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;


      -- API body starts here

      -- Call begin_batch to get process_audit_id for debug log file

      debugmsg('Loader : Call begin_batch');

      cn_message_pkg.begin_batch
	(x_process_type	         => 'LOADER',
	 x_parent_proc_audit_id  => null,
	 x_process_audit_id	 => x_process_audit_id,
	 x_request_id		 => null,
	 p_org_id 		 => p_org_id);

      debugmsg('Loader : Start of Loader');
      debugmsg('Loader : process_audit_id is ' ||
	       x_process_audit_id );

      /* verify that parameter start date is within an open acc period */
      l_count := 0;
	  select count(*)
      into   l_count
	  from   cn_period_statuses_all
	  where  period_status = 'O'
	  and    org_id = p_org_id
	  and    (period_set_id, period_type_id) =
               (select period_set_id, period_type_id
	            from   cn_repositories_all
	            where  org_id = p_org_id)
	  and p_start_date between start_date and end_date;
      IF (l_count = 0) THEN
	    debugmsg('Loader : Parameter Start Date is not within an open acc period');

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	      FND_MESSAGE.SET_TOKEN('DATE', p_start_date);
	      FND_MSG_PUB.Add;
        END IF;

        x_loading_status := 'CN_CALC_SUB_OPEN_DATE';
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      /* verify that parameter end date is within an open acc period */
      l_count := 0;
	  select count(*)
      into   l_count
	  from   cn_period_statuses_all
	  where  period_status = 'O'
	  and    org_id = p_org_id
	  and    (period_set_id, period_type_id) =
               (select period_set_id, period_type_id
	            from   cn_repositories_all
	            where  org_id = p_org_id)
	  and p_end_date between start_date and end_date;
      IF (l_count = 0) THEN
	    debugmsg('Loader : Parameter End Date is not within an open acc period');

        IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR) THEN
          FND_MESSAGE.SET_NAME ('CN' , 'CN_CALC_SUB_OPEN_DATE');
	      FND_MESSAGE.SET_TOKEN('DATE', p_end_date);
	      FND_MSG_PUB.Add;
        END IF;

        x_loading_status := 'CN_CALC_SUB_OPEN_DATE';
        RAISE FND_API.G_EXC_ERROR ;
      END IF;

      /* Get the value of the profile "OIC: Skip Credit Allocation" */
      l_skip_credit_flag := 'Y';
      IF (Fnd_Profile.DEFINED('CN_SKIP_CREDIT_ALLOCATION')) THEN
        l_skip_credit_flag := NVL(Fnd_Profile.VALUE('CN_SKIP_CREDIT_ALLOCATION'), 'Y');
      END IF;

      -- Check Data in API table
      cn_transaction_load_pkg.check_api_data(p_start_date  => p_start_date,
					     p_end_date    => p_end_date,
 					     p_org_id 	   => p_org_id);


      -- Validate ruleset status if the classification and
      -- rollup option is checked.
      IF (p_cls_rol_flag = 'Y') THEN
	 debugmsg('Loader : validate ruleset status : load_start_date = '
		  || p_start_date);
	 debugmsg('Loader : validate ruleset status : load_end_date = '
		  || p_end_date);

	 IF NOT cn_proc_batches_pkg.validate_ruleset_status
	   (p_start_date, p_end_date, p_org_id) THEN
	    debugmsg('Loader : validate ruleset fails.');
	    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	      THEN
	       FND_MESSAGE.SET_NAME ('CN' , 'CN_LOAD_INVALID_RULESET');
	       FND_MSG_PUB.Add;
	    END IF;
	    x_loading_status := 'CN_LOAD_INVALID_RULESET';
	    RAISE FND_API.G_EXC_ERROR ;
	 END IF;
      END IF;


      -- Insert into cn_process_batches for each srp-period
      -- Populate logical_batch_id. One logical_batch_id for one load
      -- Physical_batch_id is still empty, will be populated in Assign


      -- sequence s2 is for logical batch id
      SELECT cn_process_batches_s2.NEXTVAL
	INTO l_logical_batch_id
	FROM sys.dual;


   debugmsg('Loader : Logical batch id = '||l_logical_batch_id);

   IF (l_skip_credit_flag = 'Y') THEN
      OPEN logical_batches(p_salesrep_id, p_start_date, p_end_date, p_org_id);
      FETCH logical_batches BULK COLLECT INTO
        l_emp_no_tbl,
        l_srp_id_tbl,
        l_period_id_tbl,
        l_start_date_tbl,
        l_end_date_tbl,
        l_count_tbl;
      CLOSE logical_batches;
   ELSE
      OPEN logical_batches2(p_salesrep_id, p_start_date, p_end_date, p_org_id);
      FETCH logical_batches2 BULK COLLECT INTO
        l_emp_no_tbl,
        l_srp_id_tbl,
        l_period_id_tbl,
        l_start_date_tbl,
        l_end_date_tbl,
        l_count_tbl;
      CLOSE logical_batches2;
   END IF;

   l_logical_batch_count := l_srp_id_tbl.COUNT;

   IF (l_logical_batch_count <= 0) THEN
	 debugmsg('Loader : No transactions to load.');

	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
	   THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOAD_NO_TRX_TO_LOAD');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_LOAD_NO_TRX_TO_LOAD';
	 RAISE FND_API.G_EXC_ERROR ;
   ELSE
     FOR i IN l_srp_id_tbl.FIRST .. l_srp_id_tbl.LAST LOOP

	 -- sequence s1 is for process batch id
	 SELECT cn_process_batches_s1.NEXTVAL
	   INTO l_process_batch_id
	   FROM sys.dual;
	 debugmsg('Loader : insert into cn_process_batches....');
	 debugmsg('l_process_batch_id = ' || l_process_batch_id);
	 debugmsg('l_logical_batch_id = '||l_logical_batch_id);
	 debugmsg('period_id  = '||l_period_id_tbl(i) );
	 debugmsg('start_date = '||l_start_date_tbl(i));
	 debugmsg('end_date '|| l_end_date_tbl(i));
	 debugmsg('salesrep_id  '|| l_srp_id_tbl(i) );
	 debugmsg('employee_number '|| l_emp_no_tbl(i));
	 debugmsg('trx_count '|| l_count_tbl(i));

     IF (l_srp_id_tbl(i) IS NOT NULL) THEN

	 --+
	 --+ Added Counter Variable : Hithanki 03/06/2003 For Bug Fix : 2781346
      	 --+

         l_process_rec_cnt := l_process_rec_cnt + 1;

	 INSERT INTO cn_process_batches_all
	   ( process_batch_id
	     ,logical_batch_id
	     ,srp_period_id
	     ,period_id
	     ,end_period_id
	     ,start_date
	     ,end_date
	     ,salesrep_id
	     ,sales_lines_total
	     ,status_code
	     ,process_batch_type
	     ,creation_date
	     ,created_by
	     ,last_update_date
	     ,last_updated_by
	     ,last_update_login
	     ,request_id
	     ,program_application_id
	     ,program_id
	     ,program_update_date
	     ,org_id)
	   VALUES
	   (
	    l_process_batch_id
	    ,l_logical_batch_id
	    ,l_process_batch_id        -- a dummy value for a not null column
	    ,l_period_id_tbl(i)        -- start_period_id
	    ,l_period_id_tbl(i)        -- end_period_id
	    ,l_start_date_tbl(i)       -- start_date
	    ,l_end_date_tbl(i)         -- end_date
	    ,l_srp_id_tbl(i)           -- salesrep_id
	    ,l_count_tbl(i)            -- sales_lines_total
	    ,'IN_USE'                  -- status_code
	    ,'CREATED_BY_LOADER'       -- process_batch_type
	    ,sysdate
	    ,l_user_id
	    ,sysdate
	    ,l_user_id
	    ,l_login_id
	    ,l_conc_request_id
	    ,l_prog_appl_id
	    ,l_conc_prog_id
        ,sysdate
 	    ,p_org_id);

	 END IF;

      END LOOP;
  END IF;

      OPEN valid_transactions(l_logical_batch_id);
      FETCH valid_transactions INTO valid_rec;

      IF (valid_transactions%NOTFOUND) THEN

  	 debugmsg('Loader : All transactions to load have invalid salesrep id.');

	 IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)
         THEN
	    FND_MESSAGE.SET_NAME ('CN' , 'CN_LOAD_SALESREP_ERROR');
	    FND_MSG_PUB.Add;
	 END IF;
	 x_loading_status := 'CN_LOAD_SALESREP_ERROR';

	 RAISE no_valid_transactions;

      END IF;

      CLOSE valid_transactions;

      --+
      --+ Added If Check : Hithanki 03/06/2003 For Bug Fix : 2781346
      --+
      IF l_process_rec_cnt > 0 THEN

      -- Split the logical batch into smaller physical batches
      -- populate the physical_batch_id in cn_process_batches



      cn_transaction_load_pkg.assign(p_logical_batch_id => l_logical_batch_id, p_org_id => p_org_id);

      -- Call load worker for each physical batch
      -- for regular loader, we call conc_dispatch to submit concurrent procedure.
      -- But for this public API the loader will do the job sequentially.

        commit;

      cn_transaction_load_pkg.pre_conc_dispatch(p_salesrep_id => p_salesrep_id,
						p_start_date  => p_start_date,
						p_end_date    => p_end_date,
						p_org_id      => p_org_id);

        commit;

      FOR physical_rec IN physical_batches(l_logical_batch_id)
	LOOP

	   debugmsg('Loader : call load_worker'
		    ||'physical_rec.physical_batch_id = '
		    || physical_rec.physical_batch_id );

        commit;


	   load_worker(
		       x_return_status     => l_return_status,
		       x_msg_count         => l_msg_count,
		       x_msg_data          => l_msg_data,
		       p_physical_batch_id => physical_rec.physical_batch_id,
		       p_salesrep_id       => p_salesrep_id,
		       p_start_date        => p_start_date,
		       p_end_date          => p_end_date,
		       p_cls_rol_flag      => p_cls_rol_flag,
		       p_loading_status    => x_loading_status,
                       p_org_id 	   => p_org_id,
		       x_loading_status    => l_loading_status
		       );

        commit;

	END LOOP;
	END IF;

        commit;

	cn_transaction_load_pkg.post_conc_dispatch
	  (p_salesrep_id => p_salesrep_id,
	   p_start_date  => p_start_date,
	   p_end_date    => p_end_date,
           p_org_id	 => p_org_id);
      --+
      --+ Added If Check : Hithanki 03/06/2003 For Bug Fix : 2781346
      --+
      IF l_process_rec_cnt > 0
      THEN

      -- Mark the processed batches for deletion
	cn_transaction_load_pkg.void_batches
	  (p_physical_batch_id => null,
	   p_logical_batch_id  => l_logical_batch_id);
      END IF;

      -- Call end_batch to end debug log file
      debugmsg('Loader : Call end_batch');
      cn_message_pkg.end_batch(x_process_audit_id);
      debugmsg('Loader : End of Loader');

      -- End of API body.


      -- Post processing hooks

      -- User hooks

      --  Customer post-processing section

      IF JTF_USR_HKS.Ok_to_Execute('CN_TRANSACTION_LOAD_PUB',
				   'LOAD',
				   'A',
				   'V')
	THEN

	 cn_transaction_load_pub_cuhk.load_post
	   (p_api_version          => p_api_version,
	    p_init_msg_list	   => p_init_msg_list,
	    p_commit	    	   => p_commit,
	    p_validation_level	   => p_validation_level,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	    x_loading_status       => x_loading_status
	    );

	 IF (x_return_status = FND_API.G_RET_STS_ERROR )
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;


      -- Vertical industry post-processing section

      IF JTF_USR_HKS.Ok_to_Execute('CN_TRANSACTION_LOAD_PUB',
				   'LOAD',
				   'A',
				   'C')
	THEN

	 cn_transaction_load_pub_vuhk.load_post
	   (p_api_version          => p_api_version,
	    p_init_msg_list	   => p_init_msg_list,
	    p_commit	    	   => p_commit,
	    p_validation_level	   => p_validation_level,
	    x_return_status        => x_return_status,
	    x_msg_count            => x_msg_count,
	    x_msg_data             => x_msg_data,
	    x_loading_status       => x_loading_status
	    );

	 IF ( x_return_status = FND_API.G_RET_STS_ERROR )
	   THEN
	    RAISE FND_API.G_EXC_ERROR;
	  ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	    THEN
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
      END IF;


      -- Message enable hook

      IF JTF_USR_HKS.Ok_to_execute('CN_TRANSACTION_LOAD_PUB',
				   'LOAD',
				   'M',
				   'M')
	THEN
	 IF  cn_transaction_load_pub_cuhk.ok_to_generate_msg
	   THEN
	    -- Clear bind variables
	    --	 XMLGEN.clearBindValues;

	    -- Set values for bind variables,
	    -- call this for all bind variables in the business object
	    --	 XMLGEN.setBindValue('SRP_PMT_PLAN_ID', x_srp_pmt_plan_id);

	    -- Get a ID for workflow/ business object instance
	    l_bind_data_id := JTF_USR_HKS.get_bind_data_id;

	    --  Do this for all the bind variables in the Business Object
	    JTF_USR_HKS.load_bind_data
	      (l_bind_data_id, 'PROCESS_AUDIT_ID', x_process_audit_id, 'S', 'S');

	    -- Message generation API
	    JTF_USR_HKS.generate_message
	      (p_prod_code    => 'CN',
	       p_bus_obj_code => 'TRXLOAD',
	       p_bus_obj_name => 'TRX_LOAD',
	       p_action_code  => 'I',
	       p_bind_data_id => l_bind_data_id,
	       p_oai_param    => null,
	       p_oai_array    => l_oai_array,
	       x_return_code  => x_return_status) ;

	    IF (x_return_status = FND_API.G_RET_STS_ERROR)
	      THEN
	       RAISE FND_API.G_EXC_ERROR;
	     ELSIF (x_return_status = FND_API.G_RET_STS_UNEXP_ERROR )
	       THEN
	       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	    END IF;
	 END IF;
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
	(p_count   =>  x_msg_count ,
	 p_data    =>  x_msg_data  ,
	 p_encoded => FND_API.G_FALSE
	 );

   EXCEPTION
      WHEN no_valid_transactions THEN
         OPEN logical_batches(p_salesrep_id, p_start_date, p_end_date, p_org_id);
	 ROLLBACK TO load_savepoint;

         UPDATE cn_comm_lines_api_all
         SET load_status = 'SALESREP_ERROR'
	 WHERE
	   load_status = 'UNLOADED' AND
	   trx_type <> 'FORECAST' AND
       (adjust_status <> 'SCA_PENDING' ) AND -- OR adjust_status IS NULL) AND
	   processed_date >= TRUNC(p_start_date) AND
	   processed_date < (TRUNC(p_end_date) + 1) AND
	   ((p_salesrep_id IS NULL) OR (salesrep_id = p_salesrep_id)) AND
           org_id = p_org_id;
         commit;

         debugmsg('Loader : exception : exc_error : End of Loader');
	 cn_message_pkg.end_batch(x_process_audit_id);
	 x_loading_status := 'EXC_ERR';
	 x_return_status := FND_API.G_RET_STS_ERROR ;

	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   => x_msg_count ,
	    p_data    => x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
      WHEN FND_API.G_EXC_ERROR THEN
	 ROLLBACK TO load_savepoint;
	 debugmsg('Loader : exception : exc_error : End of Loader');
	 cn_message_pkg.end_batch(x_process_audit_id);
	 x_loading_status := 'EXC_ERR';
	 x_return_status := FND_API.G_RET_STS_ERROR ;
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   => x_msg_count ,
	    p_data    => x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
	 ROLLBACK TO load_savepoint;
	 debugmsg('Loader : exception : unexc_error : End of Loader');
	 cn_message_pkg.end_batch(x_process_audit_id);
	 x_loading_status := 'UNEXPECTED_ERR';
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   => x_msg_count ,
	    p_data    => x_msg_data   ,
	    p_encoded => FND_API.G_FALSE
	    );
      WHEN OTHERS THEN
	 ROLLBACK TO load_savepoint;
	 debugmsg('Loader : exception : others : End of Loader');
	 cn_message_pkg.end_batch(x_process_audit_id);
	 x_loading_status := 'UNEXPECTED_ERR';
	 x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
	   THEN
	    FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.Count_And_Get
	   (
	    p_count   => x_msg_count ,
	    p_data    => x_msg_data  ,
	    p_encoded => FND_API.G_FALSE
	    );
  END load;

END cn_transaction_load_pub;

/
