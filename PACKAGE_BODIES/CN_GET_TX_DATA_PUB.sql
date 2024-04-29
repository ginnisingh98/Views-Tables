--------------------------------------------------------
--  DDL for Package Body CN_GET_TX_DATA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_GET_TX_DATA_PUB" AS
--$Header: cnpxadjb.pls 120.15.12010000.6 2009/06/03 12:22:15 ppillai ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_get_tx_data_pub
-- Purpose
--   Package Body for Mass Adjustments Package
-- History
-- 08/08/2005 Hithanki R12 Version
--
  --
  -- Nov 14, 2005    vensrini   Commented out call to
  --                            convert_rec_to_gmiss in
  --                            update_api_rec procedure
  --
  -- Nov 22, 2005    vensrini   Bug fix 4202682. Changed order_cur cursor
  --                            in call_split proc to exclude transactions with
  --                            load status as FILTERED
  --
  -- Jan 30, 2006    vensrini   Added org id join to the cursor that checks whether
  --                            transaction processed date is in an open acc period
  --                            in insert_api_record procedure
  --
  -- Mar 27, 2006    vensrini   Bug fix 5116954
  --
  -- Aug 2, 2006     vensrini   Bug fix 5438265


   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_GET_TX_DATA_PUB';
   G_FILE_NAME                 	CONSTANT VARCHAR2(12) := 'cnpxadjb.pls';
   g_space			VARCHAR2(10) := '&'||'nbsp;';
--
FUNCTION g_track_invoice
   RETURN VARCHAR2 IS
   l_track_invoice 	VARCHAR2(1) := 'N';
BEGIN
   l_track_invoice  := NVL(fnd_profile.value('CN_TRACK_INVOICE'),'N');
   RETURN l_track_invoice;
EXCEPTION
   WHEN OTHERS THEN
      RETURN l_track_invoice;
END;
--


PROCEDURE get_api_data(
	p_comm_lines_api_id	IN	NUMBER,
	x_adj_tbl        OUT NOCOPY     adj_tbl_type) IS
--
CURSOR api_cur IS
   SELECT l.*, s.name
     FROM cn_comm_lines_api_all l,
          cn_salesreps s
    WHERE comm_lines_api_id = p_comm_lines_api_id
      AND l.salesrep_id = s.salesrep_id;
--
CURSOR header_cur IS
   SELECT h.*,s.employee_number,s.name
     FROM cn_commission_headers_all h,
          cn_salesreps s
    WHERE comm_lines_api_id = p_comm_lines_api_id
      AND h.direct_salesrep_id = s.salesrep_id;
--
   l_tbl_count		NUMBER := 1;
--
BEGIN
   FOR adj IN api_cur
   LOOP
	 x_adj_tbl(l_tbl_count).direct_salesrep_number	:= adj.employee_number;
	 x_adj_tbl(l_tbl_count).direct_salesrep_name	:= adj.name;
	 x_adj_tbl(l_tbl_count).direct_salesrep_id	:= adj.salesrep_id;
	 x_adj_tbl(l_tbl_count).processed_period_id	:= adj.processed_period_id;
	 x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
	 x_adj_tbl(l_tbl_count).rollup_date		:= adj.rollup_date;
	 x_adj_tbl(l_tbl_count).transaction_amount	:= adj.acctd_transaction_amount;
	 x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount;
         x_adj_tbl(l_tbl_count).trx_type		:= adj.trx_type;
	 x_adj_tbl(l_tbl_count).quantity		:= adj.quantity;
	 x_adj_tbl(l_tbl_count).discount_percentage	:= adj.discount_percentage;
	 x_adj_tbl(l_tbl_count).margin_percentage	:= adj.margin_percentage;
	 x_adj_tbl(l_tbl_count).orig_currency_code	:= adj.transaction_currency_code;
	 x_adj_tbl(l_tbl_count).exchange_rate		:= adj.exchange_rate;
	 x_adj_tbl(l_tbl_count).reason_code		:= adj.reason_code;
	 x_adj_tbl(l_tbl_count).comments		:= NULL;
	 x_adj_tbl(l_tbl_count).attribute_category      := adj.attribute_category;
	 x_adj_tbl(l_tbl_count).attribute1         	:= adj.attribute1;
	 x_adj_tbl(l_tbl_count).attribute2           	:= adj.attribute2;
	 x_adj_tbl(l_tbl_count).attribute3           	:= adj.attribute3;
	 x_adj_tbl(l_tbl_count).attribute4           	:= adj.attribute4;
	 x_adj_tbl(l_tbl_count).attribute5           	:= adj.attribute5;
	 x_adj_tbl(l_tbl_count).attribute6           	:= adj.attribute6;
	 x_adj_tbl(l_tbl_count).attribute7           	:= adj.attribute7;
	 x_adj_tbl(l_tbl_count).attribute8           	:= adj.attribute8;
	 x_adj_tbl(l_tbl_count).attribute9           	:= adj.attribute9;
	 x_adj_tbl(l_tbl_count).attribute10          	:= adj.attribute10;
	 x_adj_tbl(l_tbl_count).attribute11          	:= adj.attribute11;
	 x_adj_tbl(l_tbl_count).attribute12          	:= adj.attribute12;
	 x_adj_tbl(l_tbl_count).attribute13          	:= adj.attribute13;
	 x_adj_tbl(l_tbl_count).attribute14          	:= adj.attribute14;
	 x_adj_tbl(l_tbl_count).attribute15          	:= adj.attribute15;
	 x_adj_tbl(l_tbl_count).attribute16          	:= adj.attribute16;
	 x_adj_tbl(l_tbl_count).attribute17          	:= adj.attribute17;
	 x_adj_tbl(l_tbl_count).attribute18          	:= adj.attribute18;
	 x_adj_tbl(l_tbl_count).attribute19          	:= adj.attribute19;
	 x_adj_tbl(l_tbl_count).attribute20          	:= adj.attribute20;
	 x_adj_tbl(l_tbl_count).attribute21          	:= adj.attribute21;
	 x_adj_tbl(l_tbl_count).attribute22          	:= adj.attribute22;
	 x_adj_tbl(l_tbl_count).attribute23          	:= adj.attribute23;
	 x_adj_tbl(l_tbl_count).attribute24          	:= adj.attribute24;
	 x_adj_tbl(l_tbl_count).attribute25          	:= adj.attribute25;
	 x_adj_tbl(l_tbl_count).attribute26          	:= adj.attribute26;
	 x_adj_tbl(l_tbl_count).attribute27          	:= adj.attribute27;
	 x_adj_tbl(l_tbl_count).attribute28          	:= adj.attribute28;
	 x_adj_tbl(l_tbl_count).attribute29          	:= adj.attribute29;
	 x_adj_tbl(l_tbl_count).attribute30          	:= adj.attribute30;
	 x_adj_tbl(l_tbl_count).attribute31          	:= adj.attribute31;
	 x_adj_tbl(l_tbl_count).attribute32          	:= adj.attribute32;
	 x_adj_tbl(l_tbl_count).attribute33          	:= adj.attribute33;
	 x_adj_tbl(l_tbl_count).attribute34          	:= adj.attribute34;
	 x_adj_tbl(l_tbl_count).attribute35          	:= adj.attribute35;
	 x_adj_tbl(l_tbl_count).attribute36          	:= adj.attribute36;
	 x_adj_tbl(l_tbl_count).attribute37          	:= adj.attribute37;
	 x_adj_tbl(l_tbl_count).attribute38          	:= adj.attribute38;
	 x_adj_tbl(l_tbl_count).attribute39          	:= adj.attribute39;
	 x_adj_tbl(l_tbl_count).attribute40          	:= adj.attribute40;
	 x_adj_tbl(l_tbl_count).attribute41          	:= adj.attribute41;
	 x_adj_tbl(l_tbl_count).attribute42          	:= adj.attribute42;
	 x_adj_tbl(l_tbl_count).attribute43          	:= adj.attribute43;
	 x_adj_tbl(l_tbl_count).attribute44          	:= adj.attribute44;
	 x_adj_tbl(l_tbl_count).attribute45          	:= adj.attribute45;
	 x_adj_tbl(l_tbl_count).attribute46          	:= adj.attribute46;
	 x_adj_tbl(l_tbl_count).attribute47          	:= adj.attribute47;
	 x_adj_tbl(l_tbl_count).attribute48          	:= adj.attribute48;
	 x_adj_tbl(l_tbl_count).attribute49          	:= adj.attribute49;
	 x_adj_tbl(l_tbl_count).attribute50          	:= adj.attribute50;
	 x_adj_tbl(l_tbl_count).attribute51          	:= adj.attribute51;
	 x_adj_tbl(l_tbl_count).attribute52          	:= adj.attribute52;
	 x_adj_tbl(l_tbl_count).attribute53          	:= adj.attribute53;
	 x_adj_tbl(l_tbl_count).attribute54          	:= adj.attribute54;
	 x_adj_tbl(l_tbl_count).attribute55          	:= adj.attribute55;
	 x_adj_tbl(l_tbl_count).attribute56          	:= adj.attribute56;
	 x_adj_tbl(l_tbl_count).attribute57          	:= adj.attribute57;
	 x_adj_tbl(l_tbl_count).attribute58          	:= adj.attribute58;
	 x_adj_tbl(l_tbl_count).attribute59          	:= adj.attribute59;
	 x_adj_tbl(l_tbl_count).attribute60          	:= adj.attribute60;
	 x_adj_tbl(l_tbl_count).attribute61          	:= adj.attribute61;
	 x_adj_tbl(l_tbl_count).attribute62          	:= adj.attribute62;
	 x_adj_tbl(l_tbl_count).attribute63          	:= adj.attribute63;
	 x_adj_tbl(l_tbl_count).attribute64          	:= adj.attribute64;
	 x_adj_tbl(l_tbl_count).attribute65          	:= adj.attribute65;
	 x_adj_tbl(l_tbl_count).attribute66          	:= adj.attribute66;
	 x_adj_tbl(l_tbl_count).attribute67          	:= adj.attribute67;
	 x_adj_tbl(l_tbl_count).attribute68          	:= adj.attribute68;
	 x_adj_tbl(l_tbl_count).attribute69          	:= adj.attribute69;
	 x_adj_tbl(l_tbl_count).attribute70          	:= adj.attribute70;
	 x_adj_tbl(l_tbl_count).attribute71          	:= adj.attribute71;
	 x_adj_tbl(l_tbl_count).attribute72          	:= adj.attribute72;
	 x_adj_tbl(l_tbl_count).attribute73          	:= adj.attribute73;
	 x_adj_tbl(l_tbl_count).attribute74          	:= adj.attribute74;
	 x_adj_tbl(l_tbl_count).attribute75          	:= adj.attribute75;
	 x_adj_tbl(l_tbl_count).attribute76          	:= adj.attribute76;
	 x_adj_tbl(l_tbl_count).attribute77          	:= adj.attribute77;
	 x_adj_tbl(l_tbl_count).attribute78          	:= adj.attribute78;
	 x_adj_tbl(l_tbl_count).attribute79          	:= adj.attribute79;
	 x_adj_tbl(l_tbl_count).attribute80          	:= adj.attribute80;
	 x_adj_tbl(l_tbl_count).attribute81          	:= adj.attribute81;
	 x_adj_tbl(l_tbl_count).attribute82          	:= adj.attribute82;
	 x_adj_tbl(l_tbl_count).attribute83          	:= adj.attribute83;
	 x_adj_tbl(l_tbl_count).attribute84          	:= adj.attribute84;
	 x_adj_tbl(l_tbl_count).attribute85          	:= adj.attribute85;
	 x_adj_tbl(l_tbl_count).attribute86          	:= adj.attribute86;
	 x_adj_tbl(l_tbl_count).attribute87          	:= adj.attribute87;
	 x_adj_tbl(l_tbl_count).attribute88          	:= adj.attribute88;
	 x_adj_tbl(l_tbl_count).attribute89          	:= adj.attribute89;
	 x_adj_tbl(l_tbl_count).attribute90          	:= adj.attribute90;
	 x_adj_tbl(l_tbl_count).attribute91          	:= adj.attribute91;
	 x_adj_tbl(l_tbl_count).attribute92          	:= adj.attribute92;
	 x_adj_tbl(l_tbl_count).attribute93          	:= adj.attribute93;
	 x_adj_tbl(l_tbl_count).attribute94          	:= adj.attribute94;
	 x_adj_tbl(l_tbl_count).attribute95          	:= adj.attribute95;
	 x_adj_tbl(l_tbl_count).attribute96          	:= adj.attribute96;
	 x_adj_tbl(l_tbl_count).attribute97          	:= adj.attribute97;
	 x_adj_tbl(l_tbl_count).attribute98          	:= adj.attribute98;
	 x_adj_tbl(l_tbl_count).attribute99          	:= adj.attribute99;
	 x_adj_tbl(l_tbl_count).attribute100         	:= adj.attribute100;
	 x_adj_tbl(l_tbl_count).comm_lines_api_id 	:= adj.comm_lines_api_id;
	 x_adj_tbl(l_tbl_count).source_doc_type 	:= adj.source_doc_type;
	 x_adj_tbl(l_tbl_count).source_trx_number	:= adj.source_trx_number;
	 x_adj_tbl(l_tbl_count).trx_sales_line_id 	:= adj.trx_sales_line_id;
 	 x_adj_tbl(l_tbl_count).trx_line_id		:= adj.trx_line_id;
 	 x_adj_tbl(l_tbl_count).trx_id			:= adj.trx_id;
	 x_adj_tbl(l_tbl_count).upside_amount 		:= adj.upside_amount;
	 x_adj_tbl(l_tbl_count).upside_quantity 	:= adj.upside_quantity;
	 x_adj_tbl(l_tbl_count).uom_code 		:= adj.uom_code;
	 x_adj_tbl(l_tbl_count).forecast_id 		:= adj.forecast_id;
	 x_adj_tbl(l_tbl_count).invoice_number 		:= adj.invoice_number;
	 x_adj_tbl(l_tbl_count).invoice_date 		:= adj.invoice_date;
	 x_adj_tbl(l_tbl_count).order_number 		:= adj.order_number;
	 x_adj_tbl(l_tbl_count).order_date 		:= adj.booked_date;
	 x_adj_tbl(l_tbl_count).line_number 		:= adj.line_number;
	 x_adj_tbl(l_tbl_count).customer_id 		:= adj.customer_id;
	 x_adj_tbl(l_tbl_count).bill_to_address_id 	:= adj.bill_to_address_id;
	 x_adj_tbl(l_tbl_count).ship_to_address_id 	:= adj.ship_to_address_id;
	 x_adj_tbl(l_tbl_count).bill_to_contact_id 	:= adj.bill_to_contact_id;
	 x_adj_tbl(l_tbl_count).ship_to_contact_id 	:= adj.ship_to_contact_id;
	 x_adj_tbl(l_tbl_count).load_status 		:= adj.load_status;
	 x_adj_tbl(l_tbl_count).revenue_type 		:= adj.revenue_type;
	 x_adj_tbl(l_tbl_count).adjust_rollup_flag 	:= adj.adjust_rollup_flag;
	 x_adj_tbl(l_tbl_count).adjust_date 		:= adj.adjust_date;
	 x_adj_tbl(l_tbl_count).adjusted_by 		:= adj.adjusted_by;
	 x_adj_tbl(l_tbl_count).adjust_status 		:= NVL(adj.adjust_status,'NEW');
	 x_adj_tbl(l_tbl_count).adjust_comments 	:= adj.adjust_comments;
	 x_adj_tbl(l_tbl_count).type 			:= adj.type;
	 x_adj_tbl(l_tbl_count).pre_processed_code 	:= adj.pre_processed_code;
	 x_adj_tbl(l_tbl_count).comp_group_id 		:= adj.comp_group_id;
	 x_adj_tbl(l_tbl_count).srp_plan_assign_id 	:= adj.srp_plan_assign_id;
	 x_adj_tbl(l_tbl_count).role_id 		:= adj.role_id;
	 x_adj_tbl(l_tbl_count).sales_channel 		:= adj.sales_channel;
	 x_adj_tbl(l_tbl_count).split_pct 		:= adj.split_pct;
	 x_adj_tbl(l_tbl_count).split_status 		:= adj.split_status;
         x_adj_tbl(l_tbl_count).source_trx_id           := adj.source_trx_id;
         x_adj_tbl(l_tbl_count).source_trx_line_id      := adj.source_trx_line_id;
         x_adj_tbl(l_tbl_count).source_trx_sales_line_id := adj.source_trx_sales_line_id;
	 x_adj_tbl(l_tbl_count).org_id := adj.org_id;
	 x_adj_tbl(l_tbl_count).inventory_item_id := adj.inventory_item_id; -- Bug fix 5116954
	 /*Fix for Crediting bug*/
	 x_adj_tbl(l_tbl_count).terr_id := adj.terr_id;
	 x_adj_tbl(l_tbl_count).terr_name := adj.terr_name;
	 x_adj_tbl(l_tbl_count).preserve_credit_override_flag := NVL(adj.preserve_credit_override_flag,'N');

	 l_tbl_count := l_tbl_count + 1;
   END LOOP;
   IF (x_adj_tbl.COUNT = 0) THEN
      FOR adj IN header_cur
      LOOP
	 x_adj_tbl(l_tbl_count).direct_salesrep_number	:= adj.employee_number;
	 x_adj_tbl(l_tbl_count).direct_salesrep_name	:= adj.name;
	 x_adj_tbl(l_tbl_count).direct_salesrep_id	:= adj.direct_salesrep_id;
	 x_adj_tbl(l_tbl_count).processed_period_id	:= adj.processed_period_id;
	 x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
	 x_adj_tbl(l_tbl_count).rollup_date		:= adj.rollup_date;
	 x_adj_tbl(l_tbl_count).transaction_amount	:= adj.transaction_amount;
	 x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount_orig;
	 x_adj_tbl(l_tbl_count).trx_type		:= adj.trx_type;
	 x_adj_tbl(l_tbl_count).quantity		:= adj.quantity;
	 x_adj_tbl(l_tbl_count).discount_percentage	:= adj.discount_percentage;
	 x_adj_tbl(l_tbl_count).margin_percentage	:= adj.margin_percentage;
	 x_adj_tbl(l_tbl_count).orig_currency_code	:= adj.orig_currency_code;
	 x_adj_tbl(l_tbl_count).exchange_rate		:= adj.exchange_rate;
	 x_adj_tbl(l_tbl_count).reason_code		:= adj.reason_code;
	 x_adj_tbl(l_tbl_count).comments		:= adj.comments;
	 x_adj_tbl(l_tbl_count).attribute_category      := adj.attribute_category;
	 x_adj_tbl(l_tbl_count).attribute1         	:= adj.attribute1;
	 x_adj_tbl(l_tbl_count).attribute2           	:= adj.attribute2;
	 x_adj_tbl(l_tbl_count).attribute3           	:= adj.attribute3;
	 x_adj_tbl(l_tbl_count).attribute4           	:= adj.attribute4;
	 x_adj_tbl(l_tbl_count).attribute5           	:= adj.attribute5;
	 x_adj_tbl(l_tbl_count).attribute6           	:= adj.attribute6;
	 x_adj_tbl(l_tbl_count).attribute7           	:= adj.attribute7;
	 x_adj_tbl(l_tbl_count).attribute8           	:= adj.attribute8;
	 x_adj_tbl(l_tbl_count).attribute9           	:= adj.attribute9;
	 x_adj_tbl(l_tbl_count).attribute10          	:= adj.attribute10;
	 x_adj_tbl(l_tbl_count).attribute11          	:= adj.attribute11;
	 x_adj_tbl(l_tbl_count).attribute12          	:= adj.attribute12;
	 x_adj_tbl(l_tbl_count).attribute13          	:= adj.attribute13;
	 x_adj_tbl(l_tbl_count).attribute14          	:= adj.attribute14;
	 x_adj_tbl(l_tbl_count).attribute15          	:= adj.attribute15;
	 x_adj_tbl(l_tbl_count).attribute16          	:= adj.attribute16;
	 x_adj_tbl(l_tbl_count).attribute17          	:= adj.attribute17;
	 x_adj_tbl(l_tbl_count).attribute18          	:= adj.attribute18;
	 x_adj_tbl(l_tbl_count).attribute19          	:= adj.attribute19;
	 x_adj_tbl(l_tbl_count).attribute20          	:= adj.attribute20;
	 x_adj_tbl(l_tbl_count).attribute21          	:= adj.attribute21;
	 x_adj_tbl(l_tbl_count).attribute22          	:= adj.attribute22;
	 x_adj_tbl(l_tbl_count).attribute23          	:= adj.attribute23;
	 x_adj_tbl(l_tbl_count).attribute24          	:= adj.attribute24;
	 x_adj_tbl(l_tbl_count).attribute25          	:= adj.attribute25;
	 x_adj_tbl(l_tbl_count).attribute26          	:= adj.attribute26;
	 x_adj_tbl(l_tbl_count).attribute27          	:= adj.attribute27;
	 x_adj_tbl(l_tbl_count).attribute28          	:= adj.attribute28;
	 x_adj_tbl(l_tbl_count).attribute29          	:= adj.attribute29;
	 x_adj_tbl(l_tbl_count).attribute30          	:= adj.attribute30;
	 x_adj_tbl(l_tbl_count).attribute31          	:= adj.attribute31;
	 x_adj_tbl(l_tbl_count).attribute32          	:= adj.attribute32;
	 x_adj_tbl(l_tbl_count).attribute33          	:= adj.attribute33;
	 x_adj_tbl(l_tbl_count).attribute34          	:= adj.attribute34;
	 x_adj_tbl(l_tbl_count).attribute35          	:= adj.attribute35;
	 x_adj_tbl(l_tbl_count).attribute36          	:= adj.attribute36;
	 x_adj_tbl(l_tbl_count).attribute37          	:= adj.attribute37;
	 x_adj_tbl(l_tbl_count).attribute38          	:= adj.attribute38;
	 x_adj_tbl(l_tbl_count).attribute39          	:= adj.attribute39;
	 x_adj_tbl(l_tbl_count).attribute40          	:= adj.attribute40;
	 x_adj_tbl(l_tbl_count).attribute41          	:= adj.attribute41;
	 x_adj_tbl(l_tbl_count).attribute42          	:= adj.attribute42;
	 x_adj_tbl(l_tbl_count).attribute43          	:= adj.attribute43;
	 x_adj_tbl(l_tbl_count).attribute44          	:= adj.attribute44;
	 x_adj_tbl(l_tbl_count).attribute45          	:= adj.attribute45;
	 x_adj_tbl(l_tbl_count).attribute46          	:= adj.attribute46;
	 x_adj_tbl(l_tbl_count).attribute47          	:= adj.attribute47;
	 x_adj_tbl(l_tbl_count).attribute48          	:= adj.attribute48;
	 x_adj_tbl(l_tbl_count).attribute49          	:= adj.attribute49;
	 x_adj_tbl(l_tbl_count).attribute50          	:= adj.attribute50;
	 x_adj_tbl(l_tbl_count).attribute51          	:= adj.attribute51;
	 x_adj_tbl(l_tbl_count).attribute52          	:= adj.attribute52;
	 x_adj_tbl(l_tbl_count).attribute53          	:= adj.attribute53;
	 x_adj_tbl(l_tbl_count).attribute54          	:= adj.attribute54;
	 x_adj_tbl(l_tbl_count).attribute55          	:= adj.attribute55;
	 x_adj_tbl(l_tbl_count).attribute56          	:= adj.attribute56;
	 x_adj_tbl(l_tbl_count).attribute57          	:= adj.attribute57;
	 x_adj_tbl(l_tbl_count).attribute58          	:= adj.attribute58;
	 x_adj_tbl(l_tbl_count).attribute59          	:= adj.attribute59;
	 x_adj_tbl(l_tbl_count).attribute60          	:= adj.attribute60;
	 x_adj_tbl(l_tbl_count).attribute61          	:= adj.attribute61;
	 x_adj_tbl(l_tbl_count).attribute62          	:= adj.attribute62;
	 x_adj_tbl(l_tbl_count).attribute63          	:= adj.attribute63;
	 x_adj_tbl(l_tbl_count).attribute64          	:= adj.attribute64;
	 x_adj_tbl(l_tbl_count).attribute65          	:= adj.attribute65;
	 x_adj_tbl(l_tbl_count).attribute66          	:= adj.attribute66;
	 x_adj_tbl(l_tbl_count).attribute67          	:= adj.attribute67;
	 x_adj_tbl(l_tbl_count).attribute68          	:= adj.attribute68;
	 x_adj_tbl(l_tbl_count).attribute69          	:= adj.attribute69;
	 x_adj_tbl(l_tbl_count).attribute70          	:= adj.attribute70;
	 x_adj_tbl(l_tbl_count).attribute71          	:= adj.attribute71;
	 x_adj_tbl(l_tbl_count).attribute72          	:= adj.attribute72;
	 x_adj_tbl(l_tbl_count).attribute73          	:= adj.attribute73;
	 x_adj_tbl(l_tbl_count).attribute74          	:= adj.attribute74;
	 x_adj_tbl(l_tbl_count).attribute75          	:= adj.attribute75;
	 x_adj_tbl(l_tbl_count).attribute76          	:= adj.attribute76;
	 x_adj_tbl(l_tbl_count).attribute77          	:= adj.attribute77;
	 x_adj_tbl(l_tbl_count).attribute78          	:= adj.attribute78;
	 x_adj_tbl(l_tbl_count).attribute79          	:= adj.attribute79;
	 x_adj_tbl(l_tbl_count).attribute80          	:= adj.attribute80;
	 x_adj_tbl(l_tbl_count).attribute81          	:= adj.attribute81;
	 x_adj_tbl(l_tbl_count).attribute82          	:= adj.attribute82;
	 x_adj_tbl(l_tbl_count).attribute83          	:= adj.attribute83;
	 x_adj_tbl(l_tbl_count).attribute84          	:= adj.attribute84;
	 x_adj_tbl(l_tbl_count).attribute85          	:= adj.attribute85;
	 x_adj_tbl(l_tbl_count).attribute86          	:= adj.attribute86;
	 x_adj_tbl(l_tbl_count).attribute87          	:= adj.attribute87;
	 x_adj_tbl(l_tbl_count).attribute88          	:= adj.attribute88;
	 x_adj_tbl(l_tbl_count).attribute89          	:= adj.attribute89;
	 x_adj_tbl(l_tbl_count).attribute90          	:= adj.attribute90;
	 x_adj_tbl(l_tbl_count).attribute91          	:= adj.attribute91;
	 x_adj_tbl(l_tbl_count).attribute92          	:= adj.attribute92;
	 x_adj_tbl(l_tbl_count).attribute93          	:= adj.attribute93;
	 x_adj_tbl(l_tbl_count).attribute94          	:= adj.attribute94;
	 x_adj_tbl(l_tbl_count).attribute95          	:= adj.attribute95;
	 x_adj_tbl(l_tbl_count).attribute96          	:= adj.attribute96;
	 x_adj_tbl(l_tbl_count).attribute97          	:= adj.attribute97;
	 x_adj_tbl(l_tbl_count).attribute98          	:= adj.attribute98;
	 x_adj_tbl(l_tbl_count).attribute99          	:= adj.attribute99;
	 x_adj_tbl(l_tbl_count).attribute100         	:= adj.attribute100;
	 x_adj_tbl(l_tbl_count).comm_lines_api_id 	:= adj.comm_lines_api_id;
	 x_adj_tbl(l_tbl_count).source_doc_type 	:= adj.source_doc_type;
	 x_adj_tbl(l_tbl_count).source_trx_number	:= adj.source_trx_number;
	 x_adj_tbl(l_tbl_count).upside_amount 		:= adj.upside_amount;
	 x_adj_tbl(l_tbl_count).upside_quantity 	:= adj.upside_quantity;
	 x_adj_tbl(l_tbl_count).uom_code 		:= adj.uom_code;
	 x_adj_tbl(l_tbl_count).forecast_id 		:= adj.forecast_id;
	 x_adj_tbl(l_tbl_count).invoice_number 		:= adj.invoice_number;
	 x_adj_tbl(l_tbl_count).invoice_date 		:= adj.invoice_date;
	 x_adj_tbl(l_tbl_count).order_number 		:= adj.order_number;
	 x_adj_tbl(l_tbl_count).order_date 		:= adj.booked_date;
	 x_adj_tbl(l_tbl_count).line_number 		:= adj.line_number;
	 x_adj_tbl(l_tbl_count).customer_id 		:= adj.customer_id;
	 x_adj_tbl(l_tbl_count).bill_to_address_id 	:= adj.bill_to_address_id;
	 x_adj_tbl(l_tbl_count).ship_to_address_id 	:= adj.ship_to_address_id;
	 x_adj_tbl(l_tbl_count).bill_to_contact_id 	:= adj.bill_to_contact_id;
	 x_adj_tbl(l_tbl_count).ship_to_contact_id 	:= adj.ship_to_contact_id;
	 x_adj_tbl(l_tbl_count).load_status 		:= NULL;
	 x_adj_tbl(l_tbl_count).revenue_type 		:= adj.revenue_type;
	 x_adj_tbl(l_tbl_count).adjust_rollup_flag 	:= adj.adjust_rollup_flag;
	 x_adj_tbl(l_tbl_count).adjust_date 		:= adj.adjust_date;
	 x_adj_tbl(l_tbl_count).adjusted_by 		:= adj.adjusted_by;
	 x_adj_tbl(l_tbl_count).adjust_status 		:= NVL(adj.adjust_status,'NEW');
	 x_adj_tbl(l_tbl_count).adjust_comments 	:= adj.adjust_comments;
	 x_adj_tbl(l_tbl_count).type 			:= adj.type;
	 x_adj_tbl(l_tbl_count).pre_processed_code 	:= adj.pre_processed_code;
	 x_adj_tbl(l_tbl_count).comp_group_id 		:= adj.comp_group_id;
	 x_adj_tbl(l_tbl_count).srp_plan_assign_id 	:= adj.srp_plan_assign_id;
	 x_adj_tbl(l_tbl_count).role_id 		:= adj.role_id;
	 x_adj_tbl(l_tbl_count).sales_channel 		:= adj.sales_channel;
	 x_adj_tbl(l_tbl_count).split_pct 		:= adj.split_pct;
	 x_adj_tbl(l_tbl_count).split_status 		:= adj.split_status;
         x_adj_tbl(l_tbl_count).source_trx_id           := adj.source_trx_id;
         x_adj_tbl(l_tbl_count).source_trx_line_id      := adj.source_trx_line_id;
	 x_adj_tbl(l_tbl_count).source_trx_sales_line_id := adj.source_trx_sales_line_id;
	 x_adj_tbl(l_tbl_count).inventory_item_id := adj.inventory_item_id; -- Bug fix 5116954
         x_adj_tbl(l_tbl_count).org_id := adj.org_id;
	 l_tbl_count := l_tbl_count + 1;
      END LOOP;
   END IF;
END;
--
--
FUNCTION get_adjusted_by
   RETURN VARCHAR2 IS
   l_adjusted_by 	VARCHAR2(100) := '0';
BEGIN
   SELECT user_name
     INTO l_adjusted_by
     FROM fnd_user
    WHERE user_id  = fnd_profile.value('USER_ID');
   RETURN l_adjusted_by;
EXCEPTION
   WHEN OTHERS THEN
      RETURN l_adjusted_by;
END;
--




--

PROCEDURE get_adj (
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_org_id		 IN	   NUMBER	:= FND_API.G_MISS_NUM,
   	p_salesrep_id            IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to             IN        DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from           IN        DATE		:= FND_API.G_MISS_DATE,
   	p_calc_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_adj_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_load_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_invoice_num            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_order_num              IN        NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec          IN        adj_rec_type,
	p_first			 IN    	   NUMBER,
   	p_last                   IN        NUMBER,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_adj_tbl                OUT NOCOPY       adj_tbl_type,
   	x_adj_count              OUT NOCOPY       NUMBER,
        x_valid_trx_count        OUT NOCOPY       NUMBER) IS

   l_api_name		CONSTANT VARCHAR2(30) := 'get_adj';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER;
   l_api_sql		VARCHAR2(10000);
   l_header_sql		VARCHAR2(10000);
   l_total_rows		NUMBER := 0;
   l_adjusted_by	VARCHAR2(100) := '0';
   l_api_query_flag	CHAR(1) := 'Y';
   l_source_counter	NUMBER := 0;
   l_valid_trx_counter  NUMBER := 0;
   l_return_status	VARCHAR2(30);
   -- Tables/Records definitions
   l_adj_tbl            adj_tbl_type;
   adj                  adj_rec_type;

   -- Defining REF CURSOR
   TYPE rc IS REF CURSOR;
   query_cur         	rc;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_adj;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   /* This API take the parameters and construct the SQL. Based on the SQL
      get the data from cn_comm_lines_api and cn_commission_headers tables. */
   cn_mass_adjust_util.search_result(
   	p_salesrep_id		=> p_salesrep_id,
   	p_pr_date_to		=> p_pr_date_to,
   	p_pr_date_from		=> p_pr_date_from,
   	p_calc_status 		=> p_calc_status,
        p_adj_status            => p_adj_status,
        p_load_status           => p_load_status,
   	p_invoice_num		=> p_invoice_num,
   	p_order_num		=> p_order_num,
	p_org_id		=> p_org_id,
	p_srch_attr_rec		=> p_srch_attr_rec,
   	x_return_status		=> l_return_status,
   	x_adj_tbl		=> l_adj_tbl,
   	x_source_counter	=> l_source_counter);
   IF (l_source_counter > 0) THEN
      l_tbl_count := 0;
      FOR i IN 1..l_source_counter
      LOOP
         IF ((l_adj_tbl(i).adjust_status NOT IN('FROZEN','REVERSAL','SCA_PENDING')) --OR
	      --l_adj_tbl(i).adjust_status IS null)
              AND
	      l_adj_tbl(i).trx_type NOT IN ('ITD','GRP','THR') AND
              l_adj_tbl(i).load_status NOT IN ('FILTERED')) THEN
         	l_valid_trx_counter := l_valid_trx_counter + 1;
	 END IF;
         l_total_rows := l_total_rows + 1;
	 IF (l_total_rows BETWEEN p_first AND p_last) THEN
	    l_tbl_count := l_tbl_count + 1;
            x_adj_tbl(l_tbl_count).commission_header_id	:= NVL(l_adj_tbl(i).commission_header_id,0);
	    x_adj_tbl(l_tbl_count).direct_salesrep_number:= NVL(l_adj_tbl(i).direct_salesrep_number,g_space);
	    x_adj_tbl(l_tbl_count).direct_salesrep_name	:= NVL(l_adj_tbl(i).direct_salesrep_name,g_space);
	    x_adj_tbl(l_tbl_count).direct_salesrep_id	:= NVL(l_adj_tbl(i).direct_salesrep_id,0);
	    x_adj_tbl(l_tbl_count).processed_period_id	:= NVL(l_adj_tbl(i).processed_period_id,0);
	    x_adj_tbl(l_tbl_count).processed_period	:= NVL(l_adj_tbl(i).processed_period,g_space);
	    x_adj_tbl(l_tbl_count).processed_date	:= l_adj_tbl(i).processed_date;
	    x_adj_tbl(l_tbl_count).rollup_date		:= l_adj_tbl(i).rollup_date;
	    x_adj_tbl(l_tbl_count).transaction_amount	:= NVL(l_adj_tbl(i).transaction_amount,0);
	    x_adj_tbl(l_tbl_count).transaction_amount_orig:= NVL(l_adj_tbl(i).transaction_amount_orig,0);
	    x_adj_tbl(l_tbl_count).quantity		:= NVL(l_adj_tbl(i).quantity,0);
	    x_adj_tbl(l_tbl_count).discount_percentage	:= NVL(l_adj_tbl(i).discount_percentage,0);
	    x_adj_tbl(l_tbl_count).margin_percentage	:= NVL(l_adj_tbl(i).margin_percentage,0);
	    x_adj_tbl(l_tbl_count).orig_currency_code	:= NVL(l_adj_tbl(i).orig_currency_code,g_space);
	    x_adj_tbl(l_tbl_count).exchange_rate	:= NVL(l_adj_tbl(i).exchange_rate,0);
	    x_adj_tbl(l_tbl_count).status_disp		:= NVL(l_adj_tbl(i).status_disp,g_space);
	    x_adj_tbl(l_tbl_count).status		:= NVL(l_adj_tbl(i).status,g_space);
	    x_adj_tbl(l_tbl_count).trx_type_disp	:= NVL(l_adj_tbl(i).trx_type_disp,g_space);
	    x_adj_tbl(l_tbl_count).trx_type		:= NVL(l_adj_tbl(i).trx_type,g_space);
	    x_adj_tbl(l_tbl_count).reason		:= NVL(l_adj_tbl(i).reason,g_space);
	    x_adj_tbl(l_tbl_count).reason_code		:= NVL(l_adj_tbl(i).reason_code,g_space);
	    x_adj_tbl(l_tbl_count).comments		:= NVL(l_adj_tbl(i).comments,g_space);
	    x_adj_tbl(l_tbl_count).trx_batch_id		:= NVL(l_adj_tbl(i).trx_batch_id,0);
	    x_adj_tbl(l_tbl_count).created_by		:= NVL(l_adj_tbl(i).created_by,0);
	    x_adj_tbl(l_tbl_count).creation_date	:= l_adj_tbl(i).creation_date;
	    x_adj_tbl(l_tbl_count).last_updated_by	:= NVL(l_adj_tbl(i).last_updated_by,0);
	    x_adj_tbl(l_tbl_count).last_update_login	:= NVL(l_adj_tbl(i).last_update_login,0);
	    x_adj_tbl(l_tbl_count).last_update_date	:= l_adj_tbl(i).last_update_date;
	    x_adj_tbl(l_tbl_count).attribute_category	:= l_adj_tbl(i).attribute_category;
	    x_adj_tbl(l_tbl_count).attribute1         	:= NVL(l_adj_tbl(i).attribute1,g_space);
	    x_adj_tbl(l_tbl_count).attribute2           	:= NVL(l_adj_tbl(i).attribute2,g_space);
	    x_adj_tbl(l_tbl_count).attribute3           	:= NVL(l_adj_tbl(i).attribute3,g_space);
	    x_adj_tbl(l_tbl_count).attribute4           	:= NVL(l_adj_tbl(i).attribute4,g_space);
	    x_adj_tbl(l_tbl_count).attribute5           	:= NVL(l_adj_tbl(i).attribute5,g_space);
	    x_adj_tbl(l_tbl_count).attribute6           	:= NVL(l_adj_tbl(i).attribute6,g_space);
	    x_adj_tbl(l_tbl_count).attribute7           	:= NVL(l_adj_tbl(i).attribute7,g_space);
	    x_adj_tbl(l_tbl_count).attribute8           	:= NVL(l_adj_tbl(i).attribute8,g_space);
	    x_adj_tbl(l_tbl_count).attribute9           	:= NVL(l_adj_tbl(i).attribute9,g_space);
	    x_adj_tbl(l_tbl_count).attribute10          	:= NVL(l_adj_tbl(i).attribute10,g_space);
	    x_adj_tbl(l_tbl_count).attribute11          	:= NVL(l_adj_tbl(i).attribute11,g_space);
	    x_adj_tbl(l_tbl_count).attribute12          	:= NVL(l_adj_tbl(i).attribute12,g_space);
	    x_adj_tbl(l_tbl_count).attribute13          	:= NVL(l_adj_tbl(i).attribute13,g_space);
	    x_adj_tbl(l_tbl_count).attribute14          	:= NVL(l_adj_tbl(i).attribute14,g_space);
	    x_adj_tbl(l_tbl_count).attribute15          	:= NVL(l_adj_tbl(i).attribute15,g_space);
	    x_adj_tbl(l_tbl_count).attribute16          	:= NVL(l_adj_tbl(i).attribute16,g_space);
	    x_adj_tbl(l_tbl_count).attribute17          	:= NVL(l_adj_tbl(i).attribute17,g_space);
	    x_adj_tbl(l_tbl_count).attribute18          	:= NVL(l_adj_tbl(i).attribute18,g_space);
	    x_adj_tbl(l_tbl_count).attribute19          	:= NVL(l_adj_tbl(i).attribute19,g_space);
	    x_adj_tbl(l_tbl_count).attribute20          	:= NVL(l_adj_tbl(i).attribute20,g_space);
	    x_adj_tbl(l_tbl_count).attribute21          	:= NVL(l_adj_tbl(i).attribute21,g_space);
	    x_adj_tbl(l_tbl_count).attribute22          	:= NVL(l_adj_tbl(i).attribute22,g_space);
	    x_adj_tbl(l_tbl_count).attribute23          	:= NVL(l_adj_tbl(i).attribute23,g_space);
	    x_adj_tbl(l_tbl_count).attribute24          	:= NVL(l_adj_tbl(i).attribute24,g_space);
	    x_adj_tbl(l_tbl_count).attribute25          	:= NVL(l_adj_tbl(i).attribute25,g_space);
	    x_adj_tbl(l_tbl_count).attribute26          	:= NVL(l_adj_tbl(i).attribute26,g_space);
	    x_adj_tbl(l_tbl_count).attribute27          	:= NVL(l_adj_tbl(i).attribute27,g_space);
	    x_adj_tbl(l_tbl_count).attribute28          	:= NVL(l_adj_tbl(i).attribute28,g_space);
	    x_adj_tbl(l_tbl_count).attribute29          	:= NVL(l_adj_tbl(i).attribute29,g_space);
	    x_adj_tbl(l_tbl_count).attribute30          	:= NVL(l_adj_tbl(i).attribute30,g_space);
	    x_adj_tbl(l_tbl_count).attribute31          	:= NVL(l_adj_tbl(i).attribute31,g_space);
	    x_adj_tbl(l_tbl_count).attribute32          	:= NVL(l_adj_tbl(i).attribute32,g_space);
	    x_adj_tbl(l_tbl_count).attribute33          	:= NVL(l_adj_tbl(i).attribute33,g_space);
	    x_adj_tbl(l_tbl_count).attribute34          	:= NVL(l_adj_tbl(i).attribute34,g_space);
	    x_adj_tbl(l_tbl_count).attribute35          	:= NVL(l_adj_tbl(i).attribute35,g_space);
	    x_adj_tbl(l_tbl_count).attribute36          	:= NVL(l_adj_tbl(i).attribute36,g_space);
	    x_adj_tbl(l_tbl_count).attribute37          	:= NVL(l_adj_tbl(i).attribute37,g_space);
	    x_adj_tbl(l_tbl_count).attribute38          	:= NVL(l_adj_tbl(i).attribute38,g_space);
	    x_adj_tbl(l_tbl_count).attribute39          	:= NVL(l_adj_tbl(i).attribute39,g_space);
	    x_adj_tbl(l_tbl_count).attribute40          	:= NVL(l_adj_tbl(i).attribute40,g_space);
	    x_adj_tbl(l_tbl_count).attribute41          	:= NVL(l_adj_tbl(i).attribute41,g_space);
	    x_adj_tbl(l_tbl_count).attribute42          	:= NVL(l_adj_tbl(i).attribute42,g_space);
	    x_adj_tbl(l_tbl_count).attribute43          	:= NVL(l_adj_tbl(i).attribute43,g_space);
	    x_adj_tbl(l_tbl_count).attribute44          	:= NVL(l_adj_tbl(i).attribute44,g_space);
	    x_adj_tbl(l_tbl_count).attribute45          	:= NVL(l_adj_tbl(i).attribute45,g_space);
	    x_adj_tbl(l_tbl_count).attribute46          	:= NVL(l_adj_tbl(i).attribute46,g_space);
	    x_adj_tbl(l_tbl_count).attribute47          	:= NVL(l_adj_tbl(i).attribute47,g_space);
	    x_adj_tbl(l_tbl_count).attribute48          	:= NVL(l_adj_tbl(i).attribute48,g_space);
	    x_adj_tbl(l_tbl_count).attribute49          	:= NVL(l_adj_tbl(i).attribute49,g_space);
	    x_adj_tbl(l_tbl_count).attribute50          	:= NVL(l_adj_tbl(i).attribute50,g_space);
	    x_adj_tbl(l_tbl_count).attribute51          	:= NVL(l_adj_tbl(i).attribute51,g_space);
	    x_adj_tbl(l_tbl_count).attribute52          	:= NVL(l_adj_tbl(i).attribute52,g_space);
	    x_adj_tbl(l_tbl_count).attribute53          	:= NVL(l_adj_tbl(i).attribute53,g_space);
	    x_adj_tbl(l_tbl_count).attribute54          	:= NVL(l_adj_tbl(i).attribute54,g_space);
	    x_adj_tbl(l_tbl_count).attribute55          	:= NVL(l_adj_tbl(i).attribute55,g_space);
	    x_adj_tbl(l_tbl_count).attribute56          	:= NVL(l_adj_tbl(i).attribute56,g_space);
	    x_adj_tbl(l_tbl_count).attribute57          	:= NVL(l_adj_tbl(i).attribute57,g_space);
	    x_adj_tbl(l_tbl_count).attribute58          	:= NVL(l_adj_tbl(i).attribute58,g_space);
	    x_adj_tbl(l_tbl_count).attribute59          	:= NVL(l_adj_tbl(i).attribute59,g_space);
	    x_adj_tbl(l_tbl_count).attribute60          	:= NVL(l_adj_tbl(i).attribute60,g_space);
	    x_adj_tbl(l_tbl_count).attribute61          	:= NVL(l_adj_tbl(i).attribute61,g_space);
	    x_adj_tbl(l_tbl_count).attribute62          	:= NVL(l_adj_tbl(i).attribute62,g_space);
	    x_adj_tbl(l_tbl_count).attribute63          	:= NVL(l_adj_tbl(i).attribute63,g_space);
	    x_adj_tbl(l_tbl_count).attribute64          	:= NVL(l_adj_tbl(i).attribute64,g_space);
	    x_adj_tbl(l_tbl_count).attribute65          	:= NVL(l_adj_tbl(i).attribute65,g_space);
	    x_adj_tbl(l_tbl_count).attribute66          	:= NVL(l_adj_tbl(i).attribute66,g_space);
	    x_adj_tbl(l_tbl_count).attribute67          	:= NVL(l_adj_tbl(i).attribute67,g_space);
	    x_adj_tbl(l_tbl_count).attribute68          	:= NVL(l_adj_tbl(i).attribute68,g_space);
	    x_adj_tbl(l_tbl_count).attribute69          	:= NVL(l_adj_tbl(i).attribute69,g_space);
	    x_adj_tbl(l_tbl_count).attribute70          	:= NVL(l_adj_tbl(i).attribute70,g_space);
	    x_adj_tbl(l_tbl_count).attribute71          	:= NVL(l_adj_tbl(i).attribute71,g_space);
	    x_adj_tbl(l_tbl_count).attribute72          	:= NVL(l_adj_tbl(i).attribute72,g_space);
	    x_adj_tbl(l_tbl_count).attribute73          	:= NVL(l_adj_tbl(i).attribute73,g_space);
	    x_adj_tbl(l_tbl_count).attribute74          	:= NVL(l_adj_tbl(i).attribute74,g_space);
	    x_adj_tbl(l_tbl_count).attribute75          	:= NVL(l_adj_tbl(i).attribute75,g_space);
	    x_adj_tbl(l_tbl_count).attribute76          	:= NVL(l_adj_tbl(i).attribute76,g_space);
	    x_adj_tbl(l_tbl_count).attribute77          	:= NVL(l_adj_tbl(i).attribute77,g_space);
	    x_adj_tbl(l_tbl_count).attribute78          	:= NVL(l_adj_tbl(i).attribute78,g_space);
	    x_adj_tbl(l_tbl_count).attribute79          	:= NVL(l_adj_tbl(i).attribute79,g_space);
	    x_adj_tbl(l_tbl_count).attribute80          	:= NVL(l_adj_tbl(i).attribute80,g_space);
	    x_adj_tbl(l_tbl_count).attribute81          	:= NVL(l_adj_tbl(i).attribute81,g_space);
	    x_adj_tbl(l_tbl_count).attribute82          	:= NVL(l_adj_tbl(i).attribute82,g_space);
	    x_adj_tbl(l_tbl_count).attribute83          	:= NVL(l_adj_tbl(i).attribute83,g_space);
	    x_adj_tbl(l_tbl_count).attribute84          	:= NVL(l_adj_tbl(i).attribute84,g_space);
	    x_adj_tbl(l_tbl_count).attribute85          	:= NVL(l_adj_tbl(i).attribute85,g_space);
	    x_adj_tbl(l_tbl_count).attribute86          	:= NVL(l_adj_tbl(i).attribute86,g_space);
	    x_adj_tbl(l_tbl_count).attribute87          	:= NVL(l_adj_tbl(i).attribute87,g_space);
	    x_adj_tbl(l_tbl_count).attribute88          	:= NVL(l_adj_tbl(i).attribute88,g_space);
	    x_adj_tbl(l_tbl_count).attribute89          	:= NVL(l_adj_tbl(i).attribute89,g_space);
	    x_adj_tbl(l_tbl_count).attribute90          	:= NVL(l_adj_tbl(i).attribute90,g_space);
	    x_adj_tbl(l_tbl_count).attribute91          	:= NVL(l_adj_tbl(i).attribute91,g_space);
	    x_adj_tbl(l_tbl_count).attribute92          	:= NVL(l_adj_tbl(i).attribute92,g_space);
	    x_adj_tbl(l_tbl_count).attribute93          	:= NVL(l_adj_tbl(i).attribute93,g_space);
	    x_adj_tbl(l_tbl_count).attribute94          	:= NVL(l_adj_tbl(i).attribute94,g_space);
	    x_adj_tbl(l_tbl_count).attribute95          	:= NVL(l_adj_tbl(i).attribute95,g_space);
	    x_adj_tbl(l_tbl_count).attribute96          	:= NVL(l_adj_tbl(i).attribute96,g_space);
	    x_adj_tbl(l_tbl_count).attribute97          	:= NVL(l_adj_tbl(i).attribute97,g_space);
	    x_adj_tbl(l_tbl_count).attribute98          	:= NVL(l_adj_tbl(i).attribute98,g_space);
	    x_adj_tbl(l_tbl_count).attribute99          	:= NVL(l_adj_tbl(i).attribute99,g_space);
	    x_adj_tbl(l_tbl_count).attribute100         	:= NVL(l_adj_tbl(i).attribute100,g_space);
	    x_adj_tbl(l_tbl_count).quota_id 		:= NVL(l_adj_tbl(i).quota_id,0);
	    x_adj_tbl(l_tbl_count).quota_name 		:= NVL(l_adj_tbl(i).quota_name,g_space);
	    x_adj_tbl(l_tbl_count).revenue_class_id 	:= NVL(l_adj_tbl(i).revenue_class_id,0);
	    x_adj_tbl(l_tbl_count).revenue_class_name 	:= NVL(l_adj_tbl(i).revenue_class_name,g_space);
	    x_adj_tbl(l_tbl_count).trx_batch_name 	:= NVL(l_adj_tbl(i).trx_batch_name,g_space);
	    x_adj_tbl(l_tbl_count).source_trx_number 	:= NVL(l_adj_tbl(i).source_trx_number,g_space);
	    x_adj_tbl(l_tbl_count).trx_sales_line_id 	:= NVL(l_adj_tbl(i).trx_sales_line_id,0);
	    x_adj_tbl(l_tbl_count).trx_line_id 		:= NVL(l_adj_tbl(i).trx_line_id,0);
	    x_adj_tbl(l_tbl_count).trx_id 		:= NVL(l_adj_tbl(i).trx_id,0);
	    x_adj_tbl(l_tbl_count).comm_lines_api_id 	:= NVL(l_adj_tbl(i).comm_lines_api_id,0);
	    x_adj_tbl(l_tbl_count).source_doc_type 	:= NVL(l_adj_tbl(i).source_doc_type,g_space);
	    x_adj_tbl(l_tbl_count).upside_amount 	:= NVL(l_adj_tbl(i).upside_amount,0);
	    x_adj_tbl(l_tbl_count).upside_quantity 	:= NVL(l_adj_tbl(i).upside_quantity,0);
	    x_adj_tbl(l_tbl_count).uom_code 		:= NVL(l_adj_tbl(i).uom_code,'N/A');
	    x_adj_tbl(l_tbl_count).forecast_id 		:= NVL(l_adj_tbl(i).forecast_id,0);
	    x_adj_tbl(l_tbl_count).program_id 		:= NVL(l_adj_tbl(i).program_id,0);
	    x_adj_tbl(l_tbl_count).request_id 		:= NVL(l_adj_tbl(i).request_id,0);
	    x_adj_tbl(l_tbl_count).program_application_id := NVL(l_adj_tbl(i).program_application_id,0);
	    x_adj_tbl(l_tbl_count).program_update_date 	:= l_adj_tbl(i).program_update_date;
	    x_adj_tbl(l_tbl_count).adj_comm_lines_api_id:= NVL(l_adj_tbl(i).adj_comm_lines_api_id,0);
	    x_adj_tbl(l_tbl_count).invoice_number 	:= NVL(l_adj_tbl(i).invoice_number,g_space);
	    x_adj_tbl(l_tbl_count).invoice_date 	:= l_adj_tbl(i).invoice_date;
	    x_adj_tbl(l_tbl_count).order_number 	:= NVL(l_adj_tbl(i).order_number,0);
	    x_adj_tbl(l_tbl_count).order_date 		:= l_adj_tbl(i).order_date;
	    x_adj_tbl(l_tbl_count).line_number 		:= NVL(l_adj_tbl(i).line_number,0);
	    x_adj_tbl(l_tbl_count).customer_id 		:= NVL(l_adj_tbl(i).customer_id,0);
	    x_adj_tbl(l_tbl_count).bill_to_address_id 	:= l_adj_tbl(i).bill_to_address_id;
	    x_adj_tbl(l_tbl_count).ship_to_address_id 	:= l_adj_tbl(i).ship_to_address_id;
	    x_adj_tbl(l_tbl_count).bill_to_contact_id 	:= l_adj_tbl(i).bill_to_contact_id;
	    x_adj_tbl(l_tbl_count).ship_to_contact_id 	:= l_adj_tbl(i).ship_to_contact_id;
	    x_adj_tbl(l_tbl_count).load_status 		:= NVL(l_adj_tbl(i).load_status,g_space);
	    x_adj_tbl(l_tbl_count).revenue_type_disp 	:= NVL(l_adj_tbl(i).revenue_type_disp,g_space);
	    x_adj_tbl(l_tbl_count).revenue_type 	:= NVL(l_adj_tbl(i).revenue_type,g_space);
	    x_adj_tbl(l_tbl_count).adjust_rollup_flag 	:= l_adj_tbl(i).adjust_rollup_flag;
	    x_adj_tbl(l_tbl_count).adjust_date 		:= l_adj_tbl(i).adjust_date;
	    x_adj_tbl(l_tbl_count).adjusted_by 		:= l_adj_tbl(i).adjusted_by;
	    x_adj_tbl(l_tbl_count).adjust_status_disp 	:= NVL(l_adj_tbl(i).adjust_status_disp,g_space);
	    x_adj_tbl(l_tbl_count).adjust_status 	:= NVL(l_adj_tbl(i).adjust_status,g_space);
	    x_adj_tbl(l_tbl_count).adjust_comments 	:= l_adj_tbl(i).adjust_comments;
	    x_adj_tbl(l_tbl_count).type 		:= l_adj_tbl(i).type;
	    x_adj_tbl(l_tbl_count).pre_processed_code 	:= l_adj_tbl(i).pre_processed_code;
	    x_adj_tbl(l_tbl_count).comp_group_id 	:= l_adj_tbl(i).comp_group_id;
	    x_adj_tbl(l_tbl_count).srp_plan_assign_id 	:= l_adj_tbl(i).srp_plan_assign_id;
	    x_adj_tbl(l_tbl_count).role_id 		:= l_adj_tbl(i).role_id;
	    x_adj_tbl(l_tbl_count).sales_channel 	:= l_adj_tbl(i).sales_channel;
	    x_adj_tbl(l_tbl_count).object_version_number:= l_adj_tbl(i).object_version_number;
	    x_adj_tbl(l_tbl_count).split_pct		:= NVL(l_adj_tbl(i).split_pct,0);
	    x_adj_tbl(l_tbl_count).split_status		:= NVL(l_adj_tbl(i).split_status,g_space);
	 END IF;
      END LOOP;
   END IF;
   x_adj_count := l_total_rows;
   x_valid_trx_count := l_valid_trx_counter;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_adj;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_adj;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO get_adj;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE get_split_data(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
     	p_comm_lines_api_id     IN      NUMBER 		DEFAULT NULL,
	p_load_status		IN	VARCHAR2        DEFAULT NULL,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_adj_tbl               OUT NOCOPY     adj_tbl_type,
     	x_adj_count             OUT NOCOPY     NUMBER) IS
CURSOR api_cur IS
   SELECT l.*,s.employee_number srp_employee_number,s.name,
          clad.meaning adjust_status_disp,
	  clt.meaning trx_type_disp
     FROM cn_comm_lines_api l,
          cn_salesreps s,
	  cn_lookups clad,
	  cn_lookups clt
    WHERE l.trx_type = clt.lookup_code(+)
      AND clt.lookup_type (+)= 'TRX TYPES'
      AND l.adjust_status = clad.lookup_code(+)
      AND clad.lookup_type (+)= 'ADJUST_STATUS'
      AND l.comm_lines_api_id = p_comm_lines_api_id
      AND l.salesrep_id = s.salesrep_id
      AND (adjust_status NOT IN ('FROZEN','REVERSAL') )--OR
--	   adjust_status IS NULL)
      AND trx_type NOT IN ('ITD','GRP','THR');
--
CURSOR header_cur IS
   SELECT h.*,s.employee_number,s.name,
          clad.meaning adjust_status_disp,
	  clt.meaning trx_type_disp
     FROM cn_commission_headers h,
          cn_salesreps s,
	  cn_lookups clad,
	  cn_lookups clt
    WHERE h.trx_type = clt.lookup_code(+)
      AND clt.lookup_type (+)= 'TRX TYPES'
      AND h.adjust_status = clad.lookup_code(+)
      AND clad.lookup_type (+)= 'ADJUST_STATUS'
      AND h.comm_lines_api_id = p_comm_lines_api_id
      AND h.direct_salesrep_id = s.salesrep_id
      AND (adjust_status NOT IN ('FROZEN','REVERSAL') )--OR
--	   adjust_status IS NULL)
      AND trx_type NOT IN ('ITD','GRP','THR');
--
   l_api_name		CONSTANT VARCHAR2(30) := 'get_split_data';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER 	:= 1;
   l_cg_flag		CHAR(1)	:= 'N';
   l_rc_flag  		CHAR(1)	:= 'N';
   l_quota_flag		CHAR(1)	:= 'N';
   l_role_flag 		CHAR(1)	:= 'N';
   l_cust_flag 		CHAR(1)	:= 'N';
   l_cg_id 		NUMBER;
   l_rc_id 		NUMBER;
   l_quota_id 		NUMBER;
   l_role_id 		NUMBER;
   l_cust_id 		NUMBER;
   l_space		VARCHAR2(10) := '&'||'nbsp;';
--
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_split_data;
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';

   -- API Body Begin
   IF (p_load_status <> 'LOADED') THEN
      FOR adj IN api_cur
      LOOP
	 x_adj_tbl(l_tbl_count).direct_salesrep_number	:= NVL(adj.srp_employee_number,l_space);
	 x_adj_tbl(l_tbl_count).direct_salesrep_name	:= NVL(adj.name,l_space);
	 x_adj_tbl(l_tbl_count).direct_salesrep_id	:= NVL(adj.salesrep_id,0);
	 x_adj_tbl(l_tbl_count).processed_period_id	:= NVL(adj.processed_period_id,0);
	 x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
	 x_adj_tbl(l_tbl_count).rollup_date		:= adj.rollup_date;
	 x_adj_tbl(l_tbl_count).transaction_amount	:= adj.acctd_transaction_amount;
	 x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount;
	 x_adj_tbl(l_tbl_count).quantity		:= adj.quantity;
	 x_adj_tbl(l_tbl_count).discount_percentage	:= adj.discount_percentage;
	 x_adj_tbl(l_tbl_count).margin_percentage	:= adj.margin_percentage;
	 x_adj_tbl(l_tbl_count).orig_currency_code	:= adj.transaction_currency_code;
	 x_adj_tbl(l_tbl_count).exchange_rate		:= adj.exchange_rate;
	 x_adj_tbl(l_tbl_count).reason_code		:= NVL(adj.reason_code,l_space);
	 x_adj_tbl(l_tbl_count).comments		:= l_space;
	 x_adj_tbl(l_tbl_count).attribute_category      := NVL(adj.attribute_category,l_space);
	 x_adj_tbl(l_tbl_count).attribute1         	:= NVL(adj.attribute1,l_space);
	 x_adj_tbl(l_tbl_count).attribute2           	:= NVL(adj.attribute2,l_space);
	 x_adj_tbl(l_tbl_count).attribute3           	:= NVL(adj.attribute3,l_space);
	 x_adj_tbl(l_tbl_count).attribute4           	:= NVL(adj.attribute4,l_space);
	 x_adj_tbl(l_tbl_count).attribute5           	:= NVL(adj.attribute5,l_space);
	 x_adj_tbl(l_tbl_count).attribute6           	:= NVL(adj.attribute6,l_space);
	 x_adj_tbl(l_tbl_count).attribute7           	:= NVL(adj.attribute7,l_space);
	 x_adj_tbl(l_tbl_count).attribute8           	:= NVL(adj.attribute8,l_space);
	 x_adj_tbl(l_tbl_count).attribute9           	:= NVL(adj.attribute9,l_space);
	 x_adj_tbl(l_tbl_count).attribute10          	:= NVL(adj.attribute10,l_space);
	 x_adj_tbl(l_tbl_count).attribute11          	:= NVL(adj.attribute11,l_space);
	 x_adj_tbl(l_tbl_count).attribute12          	:= NVL(adj.attribute12,l_space);
	 x_adj_tbl(l_tbl_count).attribute13          	:= NVL(adj.attribute13,l_space);
	 x_adj_tbl(l_tbl_count).attribute14          	:= NVL(adj.attribute14,l_space);
	 x_adj_tbl(l_tbl_count).attribute15          	:= NVL(adj.attribute15,l_space);
	 x_adj_tbl(l_tbl_count).attribute16          	:= NVL(adj.attribute16,l_space);
	 x_adj_tbl(l_tbl_count).attribute17          	:= NVL(adj.attribute17,l_space);
	 x_adj_tbl(l_tbl_count).attribute18          	:= NVL(adj.attribute18,l_space);
	 x_adj_tbl(l_tbl_count).attribute19          	:= NVL(adj.attribute19,l_space);
	 x_adj_tbl(l_tbl_count).attribute20          	:= NVL(adj.attribute20,l_space);
	 x_adj_tbl(l_tbl_count).attribute21          	:= NVL(adj.attribute21,l_space);
	 x_adj_tbl(l_tbl_count).attribute22          	:= NVL(adj.attribute22,l_space);
	 x_adj_tbl(l_tbl_count).attribute23          	:= NVL(adj.attribute23,l_space);
	 x_adj_tbl(l_tbl_count).attribute24          	:= NVL(adj.attribute24,l_space);
	 x_adj_tbl(l_tbl_count).attribute25          	:= NVL(adj.attribute25,l_space);
	 x_adj_tbl(l_tbl_count).attribute26          	:= NVL(adj.attribute26,l_space);
	 x_adj_tbl(l_tbl_count).attribute27          	:= NVL(adj.attribute27,l_space);
	 x_adj_tbl(l_tbl_count).attribute28          	:= NVL(adj.attribute28,l_space);
	 x_adj_tbl(l_tbl_count).attribute29          	:= NVL(adj.attribute29,l_space);
	 x_adj_tbl(l_tbl_count).attribute30          	:= NVL(adj.attribute30,l_space);
	 x_adj_tbl(l_tbl_count).attribute31          	:= NVL(adj.attribute31,l_space);
	 x_adj_tbl(l_tbl_count).attribute32          	:= NVL(adj.attribute32,l_space);
	 x_adj_tbl(l_tbl_count).attribute33          	:= NVL(adj.attribute33,l_space);
	 x_adj_tbl(l_tbl_count).attribute34          	:= NVL(adj.attribute34,l_space);
	 x_adj_tbl(l_tbl_count).attribute35          	:= NVL(adj.attribute35,l_space);
	 x_adj_tbl(l_tbl_count).attribute36          	:= NVL(adj.attribute36,l_space);
	 x_adj_tbl(l_tbl_count).attribute37          	:= NVL(adj.attribute37,l_space);
	 x_adj_tbl(l_tbl_count).attribute38          	:= NVL(adj.attribute38,l_space);
	 x_adj_tbl(l_tbl_count).attribute39          	:= NVL(adj.attribute39,l_space);
	 x_adj_tbl(l_tbl_count).attribute40          	:= NVL(adj.attribute40,l_space);
	 x_adj_tbl(l_tbl_count).attribute41          	:= NVL(adj.attribute41,l_space);
	 x_adj_tbl(l_tbl_count).attribute42          	:= NVL(adj.attribute42,l_space);
	 x_adj_tbl(l_tbl_count).attribute43          	:= NVL(adj.attribute43,l_space);
	 x_adj_tbl(l_tbl_count).attribute44          	:= NVL(adj.attribute44,l_space);
	 x_adj_tbl(l_tbl_count).attribute45          	:= NVL(adj.attribute45,l_space);
	 x_adj_tbl(l_tbl_count).attribute46          	:= NVL(adj.attribute46,l_space);
	 x_adj_tbl(l_tbl_count).attribute47          	:= NVL(adj.attribute47,l_space);
	 x_adj_tbl(l_tbl_count).attribute48          	:= NVL(adj.attribute48,l_space);
	 x_adj_tbl(l_tbl_count).attribute49          	:= NVL(adj.attribute49,l_space);
	 x_adj_tbl(l_tbl_count).attribute50          	:= NVL(adj.attribute50,l_space);
	 x_adj_tbl(l_tbl_count).attribute51          	:= NVL(adj.attribute51,l_space);
	 x_adj_tbl(l_tbl_count).attribute52          	:= NVL(adj.attribute52,l_space);
	 x_adj_tbl(l_tbl_count).attribute53          	:= NVL(adj.attribute53,l_space);
	 x_adj_tbl(l_tbl_count).attribute54          	:= NVL(adj.attribute54,l_space);
	 x_adj_tbl(l_tbl_count).attribute55          	:= NVL(adj.attribute55,l_space);
	 x_adj_tbl(l_tbl_count).attribute56          	:= NVL(adj.attribute56,l_space);
	 x_adj_tbl(l_tbl_count).attribute57          	:= NVL(adj.attribute57,l_space);
	 x_adj_tbl(l_tbl_count).attribute58          	:= NVL(adj.attribute58,l_space);
	 x_adj_tbl(l_tbl_count).attribute59          	:= NVL(adj.attribute59,l_space);
	 x_adj_tbl(l_tbl_count).attribute60          	:= NVL(adj.attribute60,l_space);
	 x_adj_tbl(l_tbl_count).attribute61          	:= NVL(adj.attribute61,l_space);
	 x_adj_tbl(l_tbl_count).attribute62          	:= NVL(adj.attribute62,l_space);
	 x_adj_tbl(l_tbl_count).attribute63          	:= NVL(adj.attribute63,l_space);
	 x_adj_tbl(l_tbl_count).attribute64          	:= NVL(adj.attribute64,l_space);
	 x_adj_tbl(l_tbl_count).attribute65          	:= NVL(adj.attribute65,l_space);
	 x_adj_tbl(l_tbl_count).attribute66          	:= NVL(adj.attribute66,l_space);
	 x_adj_tbl(l_tbl_count).attribute67          	:= NVL(adj.attribute67,l_space);
	 x_adj_tbl(l_tbl_count).attribute68          	:= NVL(adj.attribute68,l_space);
	 x_adj_tbl(l_tbl_count).attribute69          	:= NVL(adj.attribute69,l_space);
	 x_adj_tbl(l_tbl_count).attribute70          	:= NVL(adj.attribute70,l_space);
	 x_adj_tbl(l_tbl_count).attribute71          	:= NVL(adj.attribute71,l_space);
	 x_adj_tbl(l_tbl_count).attribute72          	:= NVL(adj.attribute72,l_space);
	 x_adj_tbl(l_tbl_count).attribute73          	:= NVL(adj.attribute73,l_space);
	 x_adj_tbl(l_tbl_count).attribute74          	:= NVL(adj.attribute74,l_space);
	 x_adj_tbl(l_tbl_count).attribute75          	:= NVL(adj.attribute75,l_space);
	 x_adj_tbl(l_tbl_count).attribute76          	:= NVL(adj.attribute76,l_space);
	 x_adj_tbl(l_tbl_count).attribute77          	:= NVL(adj.attribute77,l_space);
	 x_adj_tbl(l_tbl_count).attribute78          	:= NVL(adj.attribute78,l_space);
	 x_adj_tbl(l_tbl_count).attribute79          	:= NVL(adj.attribute79,l_space);
	 x_adj_tbl(l_tbl_count).attribute80          	:= NVL(adj.attribute80,l_space);
	 x_adj_tbl(l_tbl_count).attribute81          	:= NVL(adj.attribute81,l_space);
	 x_adj_tbl(l_tbl_count).attribute82          	:= NVL(adj.attribute82,l_space);
	 x_adj_tbl(l_tbl_count).attribute83          	:= NVL(adj.attribute83,l_space);
	 x_adj_tbl(l_tbl_count).attribute84          	:= NVL(adj.attribute84,l_space);
	 x_adj_tbl(l_tbl_count).attribute85          	:= NVL(adj.attribute85,l_space);
	 x_adj_tbl(l_tbl_count).attribute86          	:= NVL(adj.attribute86,l_space);
	 x_adj_tbl(l_tbl_count).attribute87          	:= NVL(adj.attribute87,l_space);
	 x_adj_tbl(l_tbl_count).attribute88          	:= NVL(adj.attribute88,l_space);
	 x_adj_tbl(l_tbl_count).attribute89          	:= NVL(adj.attribute89,l_space);
	 x_adj_tbl(l_tbl_count).attribute90          	:= NVL(adj.attribute90,l_space);
	 x_adj_tbl(l_tbl_count).attribute91          	:= NVL(adj.attribute91,l_space);
	 x_adj_tbl(l_tbl_count).attribute92          	:= NVL(adj.attribute92,l_space);
	 x_adj_tbl(l_tbl_count).attribute93          	:= NVL(adj.attribute93,l_space);
	 x_adj_tbl(l_tbl_count).attribute94          	:= NVL(adj.attribute94,l_space);
	 x_adj_tbl(l_tbl_count).attribute95          	:= NVL(adj.attribute95,l_space);
	 x_adj_tbl(l_tbl_count).attribute96          	:= NVL(adj.attribute96,l_space);
	 x_adj_tbl(l_tbl_count).attribute97          	:= NVL(adj.attribute97,l_space);
	 x_adj_tbl(l_tbl_count).attribute98          	:= NVL(adj.attribute98,l_space);
	 x_adj_tbl(l_tbl_count).attribute99          	:= NVL(adj.attribute99,l_space);
	 x_adj_tbl(l_tbl_count).attribute100         	:= NVL(adj.attribute100,l_space);
	 x_adj_tbl(l_tbl_count).quota_id	        := NVL(adj.quota_id,0);
	 x_adj_tbl(l_tbl_count).comm_lines_api_id 	:= NVL(adj.comm_lines_api_id,0);
	 x_adj_tbl(l_tbl_count).source_doc_type 	:= adj.source_doc_type;
	 x_adj_tbl(l_tbl_count).upside_amount 		:= NVL(adj.upside_amount,0);
	 x_adj_tbl(l_tbl_count).upside_quantity 	:= NVL(adj.upside_quantity,0);
	 x_adj_tbl(l_tbl_count).uom_code 		:= NVL(adj.uom_code,'N/A');
	 x_adj_tbl(l_tbl_count).forecast_id 		:= NVL(adj.forecast_id,0);
	 x_adj_tbl(l_tbl_count).invoice_number 		:= adj.invoice_number;
	 x_adj_tbl(l_tbl_count).invoice_date 		:= adj.invoice_date;
	 x_adj_tbl(l_tbl_count).order_number 		:= adj.order_number;
	 x_adj_tbl(l_tbl_count).order_date 		:= adj.booked_date;
	 x_adj_tbl(l_tbl_count).line_number 		:= adj.line_number;
	 x_adj_tbl(l_tbl_count).load_status 		:= NVL(adj.load_status,l_space);
	 x_adj_tbl(l_tbl_count).revenue_type 		:= NVL(adj.revenue_type,l_space);
	 x_adj_tbl(l_tbl_count).adjust_rollup_flag 	:= adj.adjust_rollup_flag;
	 x_adj_tbl(l_tbl_count).adjust_date 		:= adj.adjust_date;
	 x_adj_tbl(l_tbl_count).adjusted_by 		:= adj.adjusted_by;
	 x_adj_tbl(l_tbl_count).adjust_status 		:= NVL(adj.adjust_status,l_space);
	 x_adj_tbl(l_tbl_count).adjust_status_disp	:= NVL(adj.adjust_status_disp,l_space);
	 x_adj_tbl(l_tbl_count).adjust_comments 	:= adj.adjust_comments;
	 x_adj_tbl(l_tbl_count).type 			:= adj.type;
	 x_adj_tbl(l_tbl_count).pre_processed_code 	:= adj.pre_processed_code;
	 x_adj_tbl(l_tbl_count).comp_group_id 		:= adj.comp_group_id;
	 x_adj_tbl(l_tbl_count).srp_plan_assign_id 	:= adj.srp_plan_assign_id;
	 x_adj_tbl(l_tbl_count).role_id 		:= adj.role_id;
	 x_adj_tbl(l_tbl_count).sales_channel 		:= adj.sales_channel;
	 x_adj_tbl(l_tbl_count).object_version_number	:= adj.object_version_number;
	 x_adj_tbl(l_tbl_count).split_pct		:= adj.split_pct;
	 x_adj_tbl(l_tbl_count).split_status		:= adj.split_status;
	 x_adj_tbl(l_tbl_count).commission_amount	:= adj.commission_amount;
	 x_adj_tbl(l_tbl_count).revenue_class_id	:= adj.revenue_class_id;
	 x_adj_tbl(l_tbl_count).trx_type_disp		:= adj.trx_type_disp;
         x_adj_tbl(l_tbl_count).inventory_item_id	:= adj.inventory_item_id;
         x_adj_tbl(l_tbl_count).source_trx_id           := adj.source_trx_id;
         x_adj_tbl(l_tbl_count).source_trx_line_id      := adj.source_trx_line_id;
         x_adj_tbl(l_tbl_count).source_trx_sales_line_id := adj.source_trx_sales_line_id;

	 IF (adj.comp_group_id IS NOT NULL) THEN
	    l_cg_flag 		:= 'Y';
	    l_cg_id 		:= adj.comp_group_id;
	 END IF;
	 IF (adj.revenue_class_id IS NOT NULL) THEN
	    l_rc_flag 		:= 'Y';
	    l_rc_id 		:= adj.revenue_class_id;
	 END IF;
	 IF (adj.quota_id IS NOT NULL) THEN
	    l_quota_flag 	:= 'Y';
	    l_quota_id		:= adj.quota_id;
	 END IF;
	 IF (adj.role_id IS NOT NULL) THEN
	    l_role_flag 	:= 'Y';
	    l_role_id		:= adj.role_id;
	 END IF;
	 IF (adj.customer_id IS NOT NULL) THEN
	    l_cust_flag 	:= 'Y';
	    l_cust_id		:= adj.customer_id;
	 END IF;
      END LOOP;
   ELSIF (p_load_status = 'LOADED') THEN
      FOR adj IN header_cur
      LOOP
	 x_adj_tbl(l_tbl_count).direct_salesrep_number	:= NVL(adj.employee_number,l_space);
	 x_adj_tbl(l_tbl_count).direct_salesrep_name	:= NVL(adj.name,l_space);
	 x_adj_tbl(l_tbl_count).direct_salesrep_id	:= NVL(adj.direct_salesrep_id,0);
	 x_adj_tbl(l_tbl_count).processed_period_id	:= NVL(adj.processed_period_id,0);
	 x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
	 x_adj_tbl(l_tbl_count).rollup_date		:= adj.rollup_date;
	 x_adj_tbl(l_tbl_count).transaction_amount	:= adj.transaction_amount;
	 x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount_orig;
	 x_adj_tbl(l_tbl_count).quantity		:= adj.quantity;
	 x_adj_tbl(l_tbl_count).discount_percentage	:= adj.discount_percentage;
	 x_adj_tbl(l_tbl_count).margin_percentage	:= adj.margin_percentage;
	 x_adj_tbl(l_tbl_count).orig_currency_code	:= adj.orig_currency_code;
	 x_adj_tbl(l_tbl_count).exchange_rate		:= adj.exchange_rate;
	 x_adj_tbl(l_tbl_count).reason_code		:= NVL(adj.reason_code,l_space);
	 x_adj_tbl(l_tbl_count).comments		:= NVL(adj.comments,l_space);
	 x_adj_tbl(l_tbl_count).attribute_category      := NVL(adj.attribute_category,l_space);
	 x_adj_tbl(l_tbl_count).attribute1         	:= NVL(adj.attribute1,l_space);
	 x_adj_tbl(l_tbl_count).attribute2           	:= NVL(adj.attribute2,l_space);
	 x_adj_tbl(l_tbl_count).attribute3           	:= NVL(adj.attribute3,l_space);
	 x_adj_tbl(l_tbl_count).attribute4           	:= NVL(adj.attribute4,l_space);
	 x_adj_tbl(l_tbl_count).attribute5           	:= NVL(adj.attribute5,l_space);
	 x_adj_tbl(l_tbl_count).attribute6           	:= NVL(adj.attribute6,l_space);
	 x_adj_tbl(l_tbl_count).attribute7           	:= NVL(adj.attribute7,l_space);
	 x_adj_tbl(l_tbl_count).attribute8           	:= NVL(adj.attribute8,l_space);
	 x_adj_tbl(l_tbl_count).attribute9           	:= NVL(adj.attribute9,l_space);
	 x_adj_tbl(l_tbl_count).attribute10          	:= NVL(adj.attribute10,l_space);
	 x_adj_tbl(l_tbl_count).attribute11          	:= NVL(adj.attribute11,l_space);
	 x_adj_tbl(l_tbl_count).attribute12          	:= NVL(adj.attribute12,l_space);
	 x_adj_tbl(l_tbl_count).attribute13          	:= NVL(adj.attribute13,l_space);
	 x_adj_tbl(l_tbl_count).attribute14          	:= NVL(adj.attribute14,l_space);
	 x_adj_tbl(l_tbl_count).attribute15          	:= NVL(adj.attribute15,l_space);
	 x_adj_tbl(l_tbl_count).attribute16          	:= NVL(adj.attribute16,l_space);
	 x_adj_tbl(l_tbl_count).attribute17          	:= NVL(adj.attribute17,l_space);
	 x_adj_tbl(l_tbl_count).attribute18          	:= NVL(adj.attribute18,l_space);
	 x_adj_tbl(l_tbl_count).attribute19          	:= NVL(adj.attribute19,l_space);
	 x_adj_tbl(l_tbl_count).attribute20          	:= NVL(adj.attribute20,l_space);
	 x_adj_tbl(l_tbl_count).attribute21          	:= NVL(adj.attribute21,l_space);
	 x_adj_tbl(l_tbl_count).attribute22          	:= NVL(adj.attribute22,l_space);
	 x_adj_tbl(l_tbl_count).attribute23          	:= NVL(adj.attribute23,l_space);
	 x_adj_tbl(l_tbl_count).attribute24          	:= NVL(adj.attribute24,l_space);
	 x_adj_tbl(l_tbl_count).attribute25          	:= NVL(adj.attribute25,l_space);
	 x_adj_tbl(l_tbl_count).attribute26          	:= NVL(adj.attribute26,l_space);
	 x_adj_tbl(l_tbl_count).attribute27          	:= NVL(adj.attribute27,l_space);
	 x_adj_tbl(l_tbl_count).attribute28          	:= NVL(adj.attribute28,l_space);
	 x_adj_tbl(l_tbl_count).attribute29          	:= NVL(adj.attribute29,l_space);
	 x_adj_tbl(l_tbl_count).attribute30          	:= NVL(adj.attribute30,l_space);
	 x_adj_tbl(l_tbl_count).attribute31          	:= NVL(adj.attribute31,l_space);
	 x_adj_tbl(l_tbl_count).attribute32          	:= NVL(adj.attribute32,l_space);
	 x_adj_tbl(l_tbl_count).attribute33          	:= NVL(adj.attribute33,l_space);
	 x_adj_tbl(l_tbl_count).attribute34          	:= NVL(adj.attribute34,l_space);
	 x_adj_tbl(l_tbl_count).attribute35          	:= NVL(adj.attribute35,l_space);
	 x_adj_tbl(l_tbl_count).attribute36          	:= NVL(adj.attribute36,l_space);
	 x_adj_tbl(l_tbl_count).attribute37          	:= NVL(adj.attribute37,l_space);
	 x_adj_tbl(l_tbl_count).attribute38          	:= NVL(adj.attribute38,l_space);
	 x_adj_tbl(l_tbl_count).attribute39          	:= NVL(adj.attribute39,l_space);
	 x_adj_tbl(l_tbl_count).attribute40          	:= NVL(adj.attribute40,l_space);
	 x_adj_tbl(l_tbl_count).attribute41          	:= NVL(adj.attribute41,l_space);
	 x_adj_tbl(l_tbl_count).attribute42          	:= NVL(adj.attribute42,l_space);
	 x_adj_tbl(l_tbl_count).attribute43          	:= NVL(adj.attribute43,l_space);
	 x_adj_tbl(l_tbl_count).attribute44          	:= NVL(adj.attribute44,l_space);
	 x_adj_tbl(l_tbl_count).attribute45          	:= NVL(adj.attribute45,l_space);
	 x_adj_tbl(l_tbl_count).attribute46          	:= NVL(adj.attribute46,l_space);
	 x_adj_tbl(l_tbl_count).attribute47          	:= NVL(adj.attribute47,l_space);
	 x_adj_tbl(l_tbl_count).attribute48          	:= NVL(adj.attribute48,l_space);
	 x_adj_tbl(l_tbl_count).attribute49          	:= NVL(adj.attribute49,l_space);
	 x_adj_tbl(l_tbl_count).attribute50          	:= NVL(adj.attribute50,l_space);
	 x_adj_tbl(l_tbl_count).attribute51          	:= NVL(adj.attribute51,l_space);
	 x_adj_tbl(l_tbl_count).attribute52          	:= NVL(adj.attribute52,l_space);
	 x_adj_tbl(l_tbl_count).attribute53          	:= NVL(adj.attribute53,l_space);
	 x_adj_tbl(l_tbl_count).attribute54          	:= NVL(adj.attribute54,l_space);
	 x_adj_tbl(l_tbl_count).attribute55          	:= NVL(adj.attribute55,l_space);
	 x_adj_tbl(l_tbl_count).attribute56          	:= NVL(adj.attribute56,l_space);
	 x_adj_tbl(l_tbl_count).attribute57          	:= NVL(adj.attribute57,l_space);
	 x_adj_tbl(l_tbl_count).attribute58          	:= NVL(adj.attribute58,l_space);
	 x_adj_tbl(l_tbl_count).attribute59          	:= NVL(adj.attribute59,l_space);
	 x_adj_tbl(l_tbl_count).attribute60          	:= NVL(adj.attribute60,l_space);
	 x_adj_tbl(l_tbl_count).attribute61          	:= NVL(adj.attribute61,l_space);
	 x_adj_tbl(l_tbl_count).attribute62          	:= NVL(adj.attribute62,l_space);
	 x_adj_tbl(l_tbl_count).attribute63          	:= NVL(adj.attribute63,l_space);
	 x_adj_tbl(l_tbl_count).attribute64          	:= NVL(adj.attribute64,l_space);
	 x_adj_tbl(l_tbl_count).attribute65          	:= NVL(adj.attribute65,l_space);
	 x_adj_tbl(l_tbl_count).attribute66          	:= NVL(adj.attribute66,l_space);
	 x_adj_tbl(l_tbl_count).attribute67          	:= NVL(adj.attribute67,l_space);
	 x_adj_tbl(l_tbl_count).attribute68          	:= NVL(adj.attribute68,l_space);
	 x_adj_tbl(l_tbl_count).attribute69          	:= NVL(adj.attribute69,l_space);
	 x_adj_tbl(l_tbl_count).attribute70          	:= NVL(adj.attribute70,l_space);
	 x_adj_tbl(l_tbl_count).attribute71          	:= NVL(adj.attribute71,l_space);
	 x_adj_tbl(l_tbl_count).attribute72          	:= NVL(adj.attribute72,l_space);
	 x_adj_tbl(l_tbl_count).attribute73          	:= NVL(adj.attribute73,l_space);
	 x_adj_tbl(l_tbl_count).attribute74          	:= NVL(adj.attribute74,l_space);
	 x_adj_tbl(l_tbl_count).attribute75          	:= NVL(adj.attribute75,l_space);
	 x_adj_tbl(l_tbl_count).attribute76          	:= NVL(adj.attribute76,l_space);
	 x_adj_tbl(l_tbl_count).attribute77          	:= NVL(adj.attribute77,l_space);
	 x_adj_tbl(l_tbl_count).attribute78          	:= NVL(adj.attribute78,l_space);
	 x_adj_tbl(l_tbl_count).attribute79          	:= NVL(adj.attribute79,l_space);
	 x_adj_tbl(l_tbl_count).attribute80          	:= NVL(adj.attribute80,l_space);
	 x_adj_tbl(l_tbl_count).attribute81          	:= NVL(adj.attribute81,l_space);
	 x_adj_tbl(l_tbl_count).attribute82          	:= NVL(adj.attribute82,l_space);
	 x_adj_tbl(l_tbl_count).attribute83          	:= NVL(adj.attribute83,l_space);
	 x_adj_tbl(l_tbl_count).attribute84          	:= NVL(adj.attribute84,l_space);
	 x_adj_tbl(l_tbl_count).attribute85          	:= NVL(adj.attribute85,l_space);
	 x_adj_tbl(l_tbl_count).attribute86          	:= NVL(adj.attribute86,l_space);
	 x_adj_tbl(l_tbl_count).attribute87          	:= NVL(adj.attribute87,l_space);
	 x_adj_tbl(l_tbl_count).attribute88          	:= NVL(adj.attribute88,l_space);
	 x_adj_tbl(l_tbl_count).attribute89          	:= NVL(adj.attribute89,l_space);
	 x_adj_tbl(l_tbl_count).attribute90          	:= NVL(adj.attribute90,l_space);
	 x_adj_tbl(l_tbl_count).attribute91          	:= NVL(adj.attribute91,l_space);
	 x_adj_tbl(l_tbl_count).attribute92          	:= NVL(adj.attribute92,l_space);
	 x_adj_tbl(l_tbl_count).attribute93          	:= NVL(adj.attribute93,l_space);
	 x_adj_tbl(l_tbl_count).attribute94          	:= NVL(adj.attribute94,l_space);
	 x_adj_tbl(l_tbl_count).attribute95          	:= NVL(adj.attribute95,l_space);
	 x_adj_tbl(l_tbl_count).attribute96          	:= NVL(adj.attribute96,l_space);
	 x_adj_tbl(l_tbl_count).attribute97          	:= NVL(adj.attribute97,l_space);
	 x_adj_tbl(l_tbl_count).attribute98          	:= NVL(adj.attribute98,l_space);
	 x_adj_tbl(l_tbl_count).attribute99          	:= NVL(adj.attribute99,l_space);
	 x_adj_tbl(l_tbl_count).attribute100         	:= NVL(adj.attribute100,l_space);
	 x_adj_tbl(l_tbl_count).quota_id	        := NVL(adj.quota_id,0);
	 x_adj_tbl(l_tbl_count).comm_lines_api_id 	:= NVL(adj.comm_lines_api_id,0);
	 x_adj_tbl(l_tbl_count).source_doc_type 	:= adj.source_doc_type;
	 x_adj_tbl(l_tbl_count).upside_amount 		:= NVL(adj.upside_amount,0);
	 x_adj_tbl(l_tbl_count).upside_quantity 	:= NVL(adj.upside_quantity,0);
	 x_adj_tbl(l_tbl_count).uom_code 		:= NVL(adj.uom_code,'N/A');
	 x_adj_tbl(l_tbl_count).forecast_id 		:= NVL(adj.forecast_id,0);
	 x_adj_tbl(l_tbl_count).invoice_number 		:= adj.invoice_number;
	 x_adj_tbl(l_tbl_count).invoice_date 		:= adj.invoice_date;
	 x_adj_tbl(l_tbl_count).order_number 		:= adj.order_number;
	 x_adj_tbl(l_tbl_count).order_date 		:= adj.booked_date;
	 x_adj_tbl(l_tbl_count).line_number 		:= adj.line_number;
	 x_adj_tbl(l_tbl_count).load_status 		:= 'LOADED';
	 x_adj_tbl(l_tbl_count).revenue_type 		:= adj.revenue_type;
	 x_adj_tbl(l_tbl_count).adjust_rollup_flag 	:= adj.adjust_rollup_flag;
	 x_adj_tbl(l_tbl_count).adjust_date 		:= adj.adjust_date;
	 x_adj_tbl(l_tbl_count).adjusted_by 		:= adj.adjusted_by;
	 x_adj_tbl(l_tbl_count).adjust_status 		:= NVL(adj.adjust_status,l_space);
	 x_adj_tbl(l_tbl_count).adjust_status_disp	:= NVL(adj.adjust_status_disp,l_space);
	 x_adj_tbl(l_tbl_count).adjust_comments 	:= adj.adjust_comments;
	 x_adj_tbl(l_tbl_count).type 			:= adj.type;
	 x_adj_tbl(l_tbl_count).pre_processed_code 	:= adj.pre_processed_code;
	 x_adj_tbl(l_tbl_count).comp_group_id 		:= adj.comp_group_id;
	 x_adj_tbl(l_tbl_count).srp_plan_assign_id 	:= adj.srp_plan_assign_id;
	 x_adj_tbl(l_tbl_count).role_id 		:= adj.role_id;
	 x_adj_tbl(l_tbl_count).sales_channel 		:= adj.sales_channel;
	 x_adj_tbl(l_tbl_count).object_version_number	:= adj.object_version_number;
	 x_adj_tbl(l_tbl_count).split_pct		:= adj.split_pct;
	 x_adj_tbl(l_tbl_count).split_status		:= adj.split_status;
	 x_adj_tbl(l_tbl_count).commission_amount	:= adj.commission_amount;
	 x_adj_tbl(l_tbl_count).revenue_class_id	:= adj.revenue_class_id;
	 x_adj_tbl(l_tbl_count).trx_type_disp		:= adj.trx_type_disp;
         x_adj_tbl(l_tbl_count).inventory_item_id	:= adj.inventory_item_id;
         x_adj_tbl(l_tbl_count).source_trx_id           := adj.source_trx_id;
         x_adj_tbl(l_tbl_count).source_trx_line_id      := adj.source_trx_line_id;
         x_adj_tbl(l_tbl_count).source_trx_sales_line_id := adj.source_trx_sales_line_id;

	 IF (adj.comp_group_id IS NOT NULL) THEN
	    l_cg_flag 		:= 'Y';
	    l_cg_id 		:= adj.comp_group_id;
	 END IF;
	 IF (adj.revenue_class_id IS NOT NULL) THEN
	    l_rc_flag 		:= 'Y';
	    l_rc_id 		:= adj.revenue_class_id;
	 END IF;
	 IF (adj.quota_id IS NOT NULL) THEN
	    l_quota_flag 	:= 'Y';
	    l_quota_id		:= adj.quota_id;
	 END IF;
	 IF (adj.role_id IS NOT NULL) THEN
	    l_role_flag 	:= 'Y';
	    l_role_id		:= adj.role_id;
	 END IF;
	 IF (adj.customer_id IS NOT NULL) THEN
	    l_cust_flag 	:= 'Y';
	    l_cust_id		:= adj.customer_id;
	 END IF;
      END LOOP;
   END IF;
   --
   x_adj_count := x_adj_tbl.COUNT;
   --
   /* To improve the performance, these tables are not added into the main query */
   IF (l_cg_flag = 'Y') THEN
      BEGIN
         SELECT name
	   INTO x_adj_tbl(1).comp_group_name
	   FROM cn_comp_groups
	  WHERE comp_group_id = l_cg_id
	    AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   --
   IF (l_rc_flag = 'Y') THEN
      BEGIN
         SELECT name
	   INTO x_adj_tbl(1).revenue_class_name
	   FROM cn_revenue_classes
	  WHERE revenue_class_id = l_rc_id
	    AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   --
   IF (l_quota_flag = 'Y') THEN
      BEGIN
         SELECT name
	   INTO x_adj_tbl(1).quota_name
	   FROM cn_quotas
	  WHERE quota_id = l_quota_id
	    AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   --
   IF (l_role_flag = 'Y') THEN
      BEGIN
         SELECT name
	   INTO x_adj_tbl(1).role_name
	   FROM cn_roles
	  WHERE role_id = l_role_id
	    AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   --
   IF (l_cust_flag = 'Y') THEN
      BEGIN
        SELECT substrb(PARTY.PARTY_NAME,1,50),
	 	CUST_ACCT.ACCOUNT_NUMBER
	   INTO x_adj_tbl(1).customer_name,
	        x_adj_tbl(1).customer_number
	   FROM HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
	   WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID
	    AND  CUST_ACCT.CUST_ACCOUNT_ID = l_cust_id
	    AND rownum < 2;
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_split_data;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_split_data;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO get_split_data;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE insert_api_record(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_action             	IN	VARCHAR2	DEFAULT NULL,
	p_newtx_rec           	IN     	adj_rec_type,
	x_api_id	 OUT NOCOPY NUMBER,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name			CONSTANT VARCHAR2(30) := 'insert_api_record';
   l_api_version      		CONSTANT NUMBER := 1.0;
   l_comm_lines_api_id         	NUMBER;
   l_functional_amt		NUMBER;
   l_period_count		NUMBER;
   l_processed_period_id	NUMBER(15);
   l_return_status		VARCHAR2(30);
   -- Who columns
   l_last_update_date          	DATE    := sysdate;
   l_last_updated_by           	NUMBER  := fnd_global.user_id;
   l_creation_date             	DATE    := sysdate;
   l_created_by                	NUMBER  := fnd_global.user_id;
   l_last_update_login        	NUMBER  := fnd_global.login_id;
   -- PL/SQL tables/records
   l_newtx_rec           	adj_rec_type;
   l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;

   ------+
   -- Bug#2969534 Start
   ------+

      l_comp_group_id		cn_comp_groups.comp_group_id%TYPE;
      l_comp_group_name		cn_comp_groups.name%TYPE;

      l_rev_class_name		cn_revenue_classes.name%TYPE;
      l_rev_class_id		cn_revenue_classes.revenue_class_id%TYPE;

      l_cust_id			HZ_CUST_ACCOUNTS.CUST_ACCOUNT_ID%TYPE;
      l_cust_name		HZ_PARTIES.PARTY_NAME%TYPE;
      l_cust_num		HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE;

      l_role_name		cn_roles.name%TYPE;
      l_role_id			cn_roles.role_id%TYPE;

      l_pe_id			cn_quotas.quota_id%TYPE;
      l_pe_name			cn_quotas.name%TYPE;

   ------+
   -- Bug#2969534 End
   ------+

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT insert_api_record;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status 	:= FND_API.G_RET_STS_SUCCESS;
   x_loading_status 	:= 'CN_INSERTED';
   x_api_id		:= fnd_api.g_miss_num;
   -- API Body Begin
   -- Check for the open periods
   SELECT count(1)
     INTO l_period_count
     FROM cn_acc_period_statuses_v
    WHERE trunc(p_newtx_rec.processed_date)
  BETWEEN start_date AND end_date
     AND period_status IN ('O','F')
     AND org_id = p_newtx_rec.org_id;
   --
   IF (l_period_count = 0) THEN
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
         FND_MESSAGE.Set_Name('CN', 'NOT_WITHIN_OPEN_PERIODS');
 	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'NOT_WITHIN_OPEN_PERIODS';
      RAISE FND_API.G_EXC_ERROR ;
   ELSE
   --
      BEGIN
         SELECT period_id
           INTO l_processed_period_id
           FROM cn_acc_period_statuses_v
          WHERE trunc(p_newtx_rec.processed_date)
        BETWEEN start_date AND end_date
	   AND period_status IN ('O','F')
	   AND org_id = p_newtx_rec.org_id;
      EXCEPTION
         WHEN OTHERS THEN
	    NULL; -- I need to check once again to avoid NULL.
      END;
   --
   SELECT cn_comm_lines_api_s.NEXTVAL
     INTO l_comm_lines_api_id
     FROM SYS.DUAL;
   --
   l_newtx_rec	:= p_newtx_rec;
   l_newtx_rec.processed_period_id	:= l_processed_period_id;
   l_newtx_rec.comm_lines_api_id	:= l_comm_lines_api_id;
   /*---------------------------------------------------------------
      Functional/Foreign amount Logic
      Rule: Irrespective of API data or Header data foreign amount
            is always stored in adj_rec_type.transaction_amount_orig
	    column and functional amount is stored in
	    adj_rec_type.transaction_amount
   -----------------------------------------------------------------*/
   IF (l_newtx_rec.orig_currency_code IS NULL) THEN
      l_newtx_rec.orig_currency_code 	:= cn_global_var.get_currency_code(p_newtx_rec.org_id);
      l_newtx_rec.exchange_rate 	:= 1;
      IF (l_newtx_rec.transaction_amount_orig IS NOT NULL) THEN
         l_newtx_rec.transaction_amount := l_newtx_rec.transaction_amount_orig;
      ELSE
         l_newtx_rec.transaction_amount_orig
	 				:= l_newtx_rec.transaction_amount;
      END IF;
   ELSE
      -- Foreign Amount to Functional Amount
      IF (l_newtx_rec.transaction_amount_orig IS NOT NULL) THEN
         IF ((l_newtx_rec.orig_currency_code = cn_global_var.get_currency_code(p_newtx_rec.org_id)) OR
	     (l_newtx_rec.orig_currency_code = 'FUNC_CURR')) THEN
	    l_newtx_rec.transaction_amount
	    				:= l_newtx_rec.transaction_amount_orig;
	    l_newtx_rec.exchange_rate 	:= 1;
	 ELSE
	    IF (l_newtx_rec.exchange_rate IS NOT NULL) THEN
	       l_newtx_rec.transaction_amount
	       				:= (l_newtx_rec.transaction_amount_orig)*
	                                   (l_newtx_rec.exchange_rate);
	    ELSE

	       cn_mass_adjust_util.find_functional_amount(
   	   	   p_from_currency	=> l_newtx_rec.orig_currency_code,
		   p_to_currency	=> cn_global_var.get_currency_code(p_newtx_rec.org_id),
   		   p_conversion_date	=> l_newtx_rec.processed_date,
   		   p_from_amount	=> l_newtx_rec.transaction_amount_orig,
   		   x_to_amount		=> l_newtx_rec.transaction_amount,
   		   x_return_status	=> l_return_status,
   		   p_conversion_type	=> CN_SYSTEM_PARAMETERS.VALUE('CN_CONVERSION_TYPE', p_newtx_rec.org_id));
	       IF (l_return_status = 'NO DATA') THEN
                  FND_MESSAGE.SET_NAME('CN','CN_ADJ_NO_CONVERSION');
                  FND_MSG_PUB.Add;
                  x_loading_status := 'CN_ADJ_NO_CONVERSION';
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               ELSIF (l_return_status = 'ERROR') THEN
                  FND_MESSAGE.SET_NAME('CN','CN_ADJ_CONV_ERROR');
                  FND_MSG_PUB.Add;
                  x_loading_status := 'CN_ADJ_NO_CONVERSION';
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
	    END IF;
	 END IF;
      ELSE
         -- Functional Amount to Foreign Amount
         IF ((l_newtx_rec.orig_currency_code = cn_global_var.get_currency_code(p_newtx_rec.org_id)) OR
	     (l_newtx_rec.orig_currency_code = 'FUNC_CURR')) THEN
	    l_newtx_rec.transaction_amount_orig
	    				:= l_newtx_rec.transaction_amount;
	    l_newtx_rec.exchange_rate 	:= 1;
	 ELSE
	    -- In this case some times exchange rate will remain NULL only.
	    cn_mass_adjust_util.find_functional_amount(
   	  	p_from_currency		=> cn_global_var.get_currency_code(p_newtx_rec.org_id),
		p_to_currency		=> l_newtx_rec.orig_currency_code,
   		p_conversion_date	=> l_newtx_rec.processed_date,
   		p_from_amount		=> l_newtx_rec.transaction_amount,
   		x_to_amount		=> l_newtx_rec.transaction_amount_orig,
   		x_return_status		=> l_return_status,
   		p_conversion_type	=> CN_SYSTEM_PARAMETERS.VALUE('CN_CONVERSION_TYPE', p_newtx_rec.org_id));
	    IF (l_return_status = 'NO DATA') THEN
               FND_MESSAGE.SET_NAME('CN','CN_ADJ_NO_CONVERSION');
               FND_MSG_PUB.Add;
               x_loading_status := 'CN_ADJ_NO_CONVERSION';
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            ELSIF (l_return_status = 'ERROR') THEN
               FND_MESSAGE.SET_NAME('CN','CN_ADJ_CONV_ERROR');
               FND_MSG_PUB.Add;
               x_loading_status := 'CN_ADJ_NO_CONVERSION';
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
	 END IF;
      END IF;
   END IF;

    /* most of the code for this module is based on cn_adjustment_v view
      and adj_rec_type is a record corresponding to this view. So
      we have to convert this record type to table handler record type
      before we call the table handler.                                */
   cn_invoice_changes_pvt.convert_adj_to_api(
	p_adj_rec		=> l_newtx_rec,
	x_api_rec		=> l_api_rec);
   --
   cn_comm_lines_api_pkg.insert_row(l_api_rec);
   --
   x_api_id := l_comm_lines_api_id;
   --

   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO insert_api_record;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO insert_api_record;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO insert_api_record;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE call_mass_update (
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_org_id		 IN	   NUMBER	:= FND_API.G_MISS_NUM,
   	p_salesrep_id            IN        NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to             IN        DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from           IN        DATE		:= FND_API.G_MISS_DATE,
   	p_calc_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_adj_status             IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_load_status            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_invoice_num            IN        VARCHAR2	:= FND_API.G_MISS_CHAR,
   	p_order_num              IN        NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec		 IN        adj_rec_type,
	p_mass_adj_type          IN	   VARCHAR2	DEFAULT NULL,
	p_adj_rec           	 IN        adj_rec_type,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2) IS
   -- Local Variables
   l_api_name		CONSTANT VARCHAR2(30) := 'call_mass_update';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER := 0;
   l_adj_tbl		adj_tbl_type;
   l_proc_comp		VARCHAR2(10);
   l_api_query_flag	CHAR(1) := 'Y';
   l_source_counter	NUMBER := 0;
   l_return_status	VARCHAR2(30);
   -- PL/SQL Tables and Records
   l_existing_data	cn_invoice_changes_pvt.invoice_tbl;
   l_new_data		cn_invoice_changes_pvt.invoice_tbl;
   l_adj_rec		adj_rec_type;
   --
BEGIN
    --cn_mydebug.delete;
   -- Standard Start of API savepoint
   SAVEPOINT call_mass_update;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   IF (g_track_invoice = 'Y') THEN
   /* First identify the unique invoices based on the search criteria
      and delete the records from cn_invoice_changes table based on
      these invoices */
   cn_invoice_changes_pvt.update_mass_invoices(
        p_api_version		=> l_api_version,
   	p_salesrep_id		=> p_salesrep_id,
   	p_pr_date_to		=> p_pr_date_to,
   	p_pr_date_from		=> p_pr_date_from,
   	p_calc_status 		=> p_calc_status,
   	p_invoice_num		=> p_invoice_num,
   	p_order_num		=> p_order_num,
	p_srch_attr_rec		=> p_srch_attr_rec,
   	p_to_salesrep_id	=> p_adj_rec.direct_salesrep_id,
	p_to_salesrep_number	=> p_adj_rec.direct_salesrep_number,
	x_return_status         => x_return_status,
   	x_msg_count		=> x_msg_count,
   	x_msg_data		=> x_msg_data,
   	x_loading_status	=> x_loading_status,
	x_existing_data		=> l_existing_data);
   --
   END IF;

   --CN_mydebug.ADD('Counter value before Search  : '||l_source_counter);
   --CN_mydebug.ADD('Adjusted table length before search : '||l_adj_tbl.count);


   /* This API take the parameters and construct the SQL. Based on the SQL
      get the data from cn_comm_lines_api and cn_commission_headers tables. */
   cn_mass_adjust_util.search_result(
   	p_salesrep_id		=> p_salesrep_id,
   	p_pr_date_to		=> p_pr_date_to,
   	p_pr_date_from		=> p_pr_date_from,
   	p_calc_status 		=> p_calc_status,
        p_adj_status 		=> p_adj_status,
        p_load_status 		=> p_load_status,
   	p_invoice_num		=> p_invoice_num,
   	p_order_num		=> p_order_num,
	p_org_id		=> p_org_id,
	p_srch_attr_rec		=> p_srch_attr_rec,
   	x_return_status		=> l_return_status,
   	x_adj_tbl		=> l_adj_tbl,
   	x_source_counter	=> l_source_counter);
   --

   --CN_mydebug.ADD('Counter value after Search Result : '||l_source_counter);
   --CN_mydebug.ADD('Adjusted table length : '||l_adj_tbl.count);

   cn_mass_adjust_util.convert_rec_to_gmiss(
	p_rec      	=> 	p_adj_rec,
   	x_api_rec	=>	l_adj_rec);

   l_adj_rec.adjusted_by	:= get_adjusted_by;
   /* This API negate the original transctions and create new
      transactions based on the l_adj_tbl we got from the above API */
   cn_adjustments_pkg.mass_update_values(
         x_adj_data                     => l_adj_tbl,
	 x_adj_rec			=> l_adj_rec,
         X_mass_adj_type		=> p_mass_adj_type,
	 X_proc_comp			=> l_proc_comp);
   --
   IF (l_proc_comp = 'E') THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   IF (g_track_invoice = 'Y') THEN
   IF (l_existing_data.COUNT > 0) THEN
   -- Update the corresponding credit memos.
   cn_invoice_changes_pvt.update_credit_memo(
      	p_api_version  		=> l_api_version,
   	p_existing_data		=> l_existing_data,
	p_new_data		=> l_new_data,
	p_to_salesrep_id	=> p_adj_rec.direct_salesrep_id,
	p_to_salesrep_number	=> p_adj_rec.direct_salesrep_number,
	p_called_from		=> 'MASS',
	p_adjust_status		=> 'MASSADJ',
        x_return_status         => x_return_status,
   	x_msg_count		=> x_msg_count,
   	x_msg_data		=> x_msg_data,
   	x_loading_status	=> x_loading_status);
   END IF;
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO call_mass_update;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO call_mass_update;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO call_mass_update;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
-- This functionality is obsoleted.
PROCEDURE call_deal_assign(
	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_from_salesrep_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_to_salesrep_id   	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_invoice_number	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	p_order_number		IN	NUMBER  	:= FND_API.G_MISS_NUM,
	p_adjusted_by		IN	VARCHAR2	:= FND_GLOBAL.USER_NAME,
        p_adjust_comments	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'call_deal_assign';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_invoice_number	cn_comm_lines_api.invoice_number%TYPE;
   l_order_number	cn_comm_lines_api.order_number%TYPE;
   l_adjusted_by	cn_comm_lines_api.adjusted_by%TYPE;
   l_adjust_comments	cn_comm_lines_api.adjust_comments%TYPE;
   --

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT call_deal_assign;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   IF (p_invoice_number = FND_API.G_MISS_CHAR) THEN
      l_invoice_number := NULL;
   END IF;
   IF (p_order_number = FND_API.G_MISS_NUM) THEN
      l_order_number := NULL;
   END IF;
   IF (p_adjust_comments = FND_API.G_MISS_CHAR) THEN
      l_adjust_comments := NULL;
   END IF;
   --
   cn_adjustments_pkg.deal_assign(
   		x_from_salesrep_id	=> p_from_salesrep_id,
		x_to_salesrep_id	=> p_to_salesrep_id,
		x_invoice_number	=> l_invoice_number,
		x_order_number          => l_order_number,
		x_adjusted_by           => get_adjusted_by,  -- Function
        	x_adjust_comments       => l_adjust_comments);
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO call_deal_assign;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO call_deal_assign;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO call_deal_assign;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE call_split(
	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
	p_split_type		IN	VARCHAR2,
	p_from_salesrep_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
        p_split_data_tbl	IN	split_data_tbl,
	p_comm_lines_api_id	IN	NUMBER		:= FND_API.G_MISS_NUM,
	p_invoice_number	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
	p_order_number		IN	NUMBER  	:= FND_API.G_MISS_NUM,
	p_transaction_amount	IN	NUMBER,
	p_adjusted_by		IN	VARCHAR2	:= FND_GLOBAL.USER_NAME,
        p_adjust_comments	IN	VARCHAR2	:= FND_API.G_MISS_CHAR,
        p_org_id 		IN	NUMBER 		:= FND_API.G_MISS_NUM,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name		CONSTANT VARCHAR2(30) 	:= 'call_split';
   l_api_version      	CONSTANT NUMBER 	:= 1.0;
   l_split_percent	NUMBER 			:= 0;
   l_split_amount	NUMBER 			:= 0;
   l_comm_lines_api_id	NUMBER;
   l_order_number	NUMBER;
   l_org_id		NUMBER;
   l_counter		NUMBER			:= 0;
   l_id_counter		NUMBER			:= 0;
   l_deal_count 	NUMBER			:= 0;
   l_deal_type		VARCHAR2(30);
   l_split_to_all_nonrevenue_type
                        VARCHAR2(1);
   l_split_nonrevenue_line
                        VARCHAR2(1);
   l_trx_type		VARCHAR2(30);
   l_data_exist         VARCHAR2(1) := 'N';
   --
   --Added for Crediting Bug
   l_terr_id NUMBER;
   l_terr_name VARCHAR2(2000);

   -- PL/SQL tables/records
   l_newtx_rec		adj_rec_type;
   l_adj_tbl		adj_tbl_type;
   l_existing_data	cn_invoice_changes_pvt.invoice_tbl;
   l_new_data		cn_invoice_changes_pvt.invoice_tbl;
   l_api_rec		cn_comm_lines_api_pkg.comm_lines_api_rec_type;
   o_newtx_rec		adj_rec_type;
   l_deal_data_tbl	cn_invoice_changes_pvt.deal_data_tbl;
CURSOR order_cur IS
   SELECT comm_lines_api_id
     FROM cn_comm_lines_api_all api
    WHERE api.order_number = l_order_number
      AND api.org_id = l_org_id
      AND api.trx_type = 'ORD'
      AND api.load_status  NOT IN ('LOADED', 'FILTERED')  -- vensrini Bug fix 4202682
      AND (api.adjust_status NOT IN ('FROZEN','REVERSAL','SCA_PENDING') )--OR
--           api.adjust_status IS NULL)
   UNION ALL
   SELECT comm_lines_api_id
     FROM cn_commission_headers_all ch
    WHERE ch.order_number = l_order_number
      AND ch.org_id = l_org_id
      AND ch.trx_type = 'ORD'
      AND (ch.adjust_status NOT IN ('FROZEN','REVERSAL') );--OR
--         ch.adjust_status IS NULL);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT call_split;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';



   -- API body
   /* Check whether a resource name is available or not to split the trx. */
   FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
   LOOP
      IF (p_split_data_tbl(i).salesrep_id IS NOT NULL) THEN
         l_id_counter := l_id_counter + 1;
      END IF;
   END LOOP;
   IF (l_id_counter = 0) THEN
      IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
         FND_MESSAGE.Set_Name('CN', 'CN_NO_SPLIT_RESOURCE');
 	 FND_MSG_PUB.Add;
      END IF;
      x_loading_status := 'CN_NO_SPLIT_RESOURCE';
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   --
   /* Get the original data for the comm_lines_api_id  */
   get_api_data(
   	p_comm_lines_api_id	=> p_comm_lines_api_id,
	x_adj_tbl		=> l_adj_tbl);
   --
   IF (p_split_type = 'TRX') THEN     -- 1
      -- Check for split amount/percentages
      FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
      LOOP
         IF (p_split_data_tbl(i).revenue_type = 'REVENUE') THEN
            l_split_percent := l_split_percent + NVL(p_split_data_tbl(i).split_pct,0);
            l_split_amount  := l_split_amount + NVL(p_split_data_tbl(i).split_amount,0);
    	 END IF;
      END LOOP;
      IF ((l_adj_tbl(1).revenue_type = 'REVENUE') AND
          (l_adj_tbl(1).split_pct <> 0)) THEN         -- 2

-- bug 2118574
--         IF (l_split_amount <> p_transaction_amount) THEN
--            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
--               FND_MESSAGE.Set_Name('CN', 'CN_ADJ_SPLIT_AMOUNT');
-- 	       FND_MSG_PUB.Add;
--            END IF;
--            x_loading_status := 'CN_ADJ_SPLIT_AMOUNT';
--            RAISE FND_API.G_EXC_ERROR;
--	   END IF;


         IF (l_split_percent <> l_adj_tbl(1).split_pct) THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
               FND_MESSAGE.Set_Name('CN', 'CN_ADJ_SPLIT_PERCENT');
 	       FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_ADJ_SPLIT_PERCENT';
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; --2 end
      --
      IF (l_adj_tbl.COUNT > 0)THEN                -- 3
         IF ((g_track_invoice = 'Y')  AND
	     (l_adj_tbl(1).trx_type = 'INV')) THEN    -- 4
            --
            l_existing_data(1).salesrep_id 	:= l_adj_tbl(1).direct_salesrep_id;
            l_existing_data(1).direct_salesrep_number
      					        := l_adj_tbl(1).direct_salesrep_number;
            l_existing_data(1).invoice_number	:= l_adj_tbl(1).invoice_number;
            l_existing_data(1).line_number	:= l_adj_tbl(1).line_number;
            l_existing_data(1).revenue_type	:= l_adj_tbl(1).revenue_type;
            l_existing_data(1).split_pct	:= l_adj_tbl(1).split_pct;
	    l_existing_data(1).comm_lines_api_id:= l_adj_tbl(1).comm_lines_api_id;
            --
            l_new_data(1).salesrep_id		:= NULL;
            l_new_data(1).direct_salesrep_number:= NULL;
      	    l_new_data(1).invoice_number	:= NULL;
      	    l_new_data(1).line_number		:= NULL;
      	    l_new_data(1).revenue_type		:= NULL;
      	    l_new_data(1).split_pct		:= NULL;
	    l_new_data(1).comm_lines_api_id	:= NULL;
	    --
            cn_invoice_changes_pvt.update_invoice_changes(
            	p_api_version 		=> l_api_version,
	    	p_init_msg_list		=> p_init_msg_list,
     	    	p_validation_level	=> p_validation_level,
            	p_existing_data		=> l_existing_data,
	    	p_new_data		=> l_new_data,
		p_exist_data_check	=> 'Y',
		p_new_data_check	=> 'N',
	    	x_return_status		=> x_return_status,
	 	x_msg_count		=> x_msg_count,
	 	x_msg_data		=> x_msg_data,
	 	x_loading_status	=> x_loading_status);
            --
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                  FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	          FND_MSG_PUB.Add;
               END IF;
               x_loading_status := 'CN_UPDATE_INV_ERROR';
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            --
         END IF;    -- 4 end
      END IF;    -- 3 end
      --
            cn_adjustments_pkg.api_negate_record(
      		x_comm_lines_api_id 	=> p_comm_lines_api_id,
	       	x_adjusted_by	    	=> p_adjusted_by,
            x_adjust_comments	=> p_adjust_comments);

            /* Added for Crediting Bug */

            /*update_credit_credentials(
            p_comm_lines_api_id,
            l_terr_id,
            p_org_id,
            p_adjusted_by
            );*/


            /* Added for Crediting Bug */
            l_terr_id := NULL;
            l_terr_name := NULL;
            BEGIN
    		    SELECT TERR_ID, TERR_NAME INTO l_terr_id, l_terr_name
	       	    FROM CN_COMM_LINES_API
		       WHERE
    		    COMM_LINES_API_ID = p_comm_lines_api_id
	       	    AND ORG_ID = p_org_id;
            EXCEPTION
                WHEN OTHERS THEN
                NULL;
            END;

      IF (l_adj_tbl.COUNT = 1) THEN           -- 5
         FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
	 LOOP
    	    BEGIN
	       IF (l_adj_tbl(1).load_status = 'LOADED') THEN
	          l_newtx_rec.transaction_amount := p_split_data_tbl(i).split_amount;
		  l_newtx_rec.transaction_amount_orig := NULL;
	       ELSE
	          l_newtx_rec.transaction_amount_orig := p_split_data_tbl(i).split_amount;
		  l_newtx_rec.transaction_amount := NULL;
	       END IF;
	       --
	       IF ((l_adj_tbl(1).trx_type IN ('CM','PMT'))  AND
                   (g_track_invoice = 'Y'))THEN
	          l_newtx_rec.split_status	:= 'DELINKED';
	       END IF;
	       --
	       l_newtx_rec.direct_salesrep_id 		:= p_split_data_tbl(i).salesrep_id;
	       l_newtx_rec.revenue_type			:= p_split_data_tbl(i).revenue_type;
	       l_newtx_rec.adjust_comments		:= p_adjust_comments;
	       l_newtx_rec.adjust_status		:= 'SPLIT';
	       l_newtx_rec.load_status			:= 'UNLOADED';
	       l_newtx_rec.adj_comm_lines_api_id	:= p_comm_lines_api_id;
	       l_newtx_rec.direct_salesrep_number	:= p_split_data_tbl(i).salesrep_number;
	       l_newtx_rec.split_pct			:= NVL(p_split_data_tbl(i).split_pct,0);
               l_newtx_rec.invoice_date                 := l_adj_tbl(1).invoice_date;
	       l_newtx_rec.order_date                   := l_adj_tbl(1).order_date;
	       l_newtx_rec.org_id			:= l_adj_tbl(1).org_id;
	       l_newtx_rec.inventory_item_id            := l_adj_tbl(1).inventory_item_id;
	       l_newtx_rec.terr_id := l_terr_id;
	       l_newtx_rec.terr_name := l_terr_name;

            /* Added for Crediting Bug */
    		    IF(l_terr_id IS NOT NULL)
	       	    THEN
		      	  l_newtx_rec.preserve_credit_override_flag := 'Y';
		      	  l_newtx_rec.terr_id := -999;
    		    END IF;

	       --
               cn_invoice_changes_pvt.prepare_api_record(
	       		p_newtx_rec		=> l_newtx_rec,
			p_old_adj_tbl		=> l_adj_tbl,
			x_final_trx_rec		=> o_newtx_rec,
			x_return_status 	=> x_return_status);
   	       --
   	       o_newtx_rec.adj_comm_lines_api_id := p_comm_lines_api_id;
   	       --
	       cn_get_tx_data_pub.insert_api_record(
   			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
     			p_validation_level	=> p_validation_level,
			p_action		=> 'UPDATE',
			p_newtx_rec		=> o_newtx_rec,
			x_api_id		=> l_comm_lines_api_id,
			x_return_status		=> x_return_status,
     			x_msg_count		=> x_msg_count,
     			x_msg_data		=> x_msg_data,
     			x_loading_status	=> x_loading_status);
	       --
	       IF ((g_track_invoice = 'Y') AND (l_adj_tbl(1).trx_type = 'INV'))THEN
	          l_counter := l_counter + 1;
                  l_new_data(l_counter).salesrep_id	:= o_newtx_rec.direct_salesrep_id;
                  l_new_data(l_counter).direct_salesrep_number
      							:= o_newtx_rec.direct_salesrep_number;
                  l_new_data(l_counter).invoice_number	:= o_newtx_rec.invoice_number;
                  l_new_data(l_counter).line_number	:= o_newtx_rec.line_number;
                  l_new_data(l_counter).revenue_type	:= o_newtx_rec.revenue_type;
                  l_new_data(l_counter).split_pct	:= o_newtx_rec.split_pct;
                  l_new_data(l_counter).comm_lines_api_id
		  					:= l_comm_lines_api_id;
	       END IF;

	       --
	    EXCEPTION
	       WHEN OTHERS THEN
                  IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                     FND_MESSAGE.Set_Name('CN', 'CN_SPLIT_TRX_ERROR');
 	             FND_MSG_PUB.Add;
                  END IF;
                  x_loading_status := 'CN_SPLIT_TRX_ERROR';
                  RAISE FND_API.G_EXC_ERROR;
            END;
         END LOOP;

      END IF;        -- 5 end
      --
      IF ((l_adj_tbl(1).trx_type = 'INV') AND
          (g_track_invoice = 'Y') AND
	  (l_new_data.COUNT > 0)) THEN       -- 6
         --
         cn_invoice_changes_pvt.update_invoice_changes(
   	   p_api_version 	=> p_api_version,
   	   p_existing_data	=> l_existing_data,
	   p_new_data		=> l_new_data,
	   p_exist_data_check	=> 'N',
	   p_new_data_check	=> 'Y',
	   x_return_status	=> x_return_status,
	   x_msg_count		=> x_msg_count,
	   x_msg_data		=> x_msg_data,
	   x_loading_status	=> x_loading_status);
         --
         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
               FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	       FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_UPDATE_INV_ERROR';
	    RAISE FND_API.G_EXC_ERROR;
         END IF;
         --
      END IF;     -- 6 end
      --
      IF (g_track_invoice = 'Y') THEN         -- 7
         IF (l_adj_tbl(1).trx_type = 'INV') THEN
      	    cn_invoice_changes_pvt.update_credit_memo(
      		p_api_version		=> p_api_version,
		p_existing_data		=> l_existing_data,
		p_new_data		=> l_new_data,
		p_called_from		=> 'SPLIT',
		p_adjust_status		=> 'SPLIT',
		x_return_status		=> x_return_status,
     		x_msg_count		=> x_msg_count,
     		x_msg_data		=> x_msg_data,
     		x_loading_status	=> x_loading_status);
   	 END IF;
	 --
	 IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
               FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_CM_ERROR');
 	       FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_UPDATE_CM_ERROR';
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;    -- 7 end
      --
   ELSIF (p_split_type = 'DEAL') THEN           -- 1 elsif
      -- Currently order_number is coming as G_MISS_NUM.
      -- Convert that into NULL
      IF (p_order_number = FND_API.G_MISS_NUM) THEN
         l_order_number := NULL;
      ELSE
         l_order_number := p_order_number;
      END IF;

      l_org_id := p_org_id;

      -- Check whether deal is a rev or nonrev deal (based on origial deal)
      IF (l_order_number IS NOT NULL) THEN      -- 8
         BEGIN
            SELECT count(order_number)
	      INTO l_deal_count
	      FROM cn_commission_headers_all
	     WHERE order_number = l_order_number
	       AND revenue_type = 'REVENUE'
	       AND org_id = l_org_id;
	    IF (l_deal_count > 0) THEN
	       l_deal_type := 'REVENUE';
	    ELSE
	       SELECT count(order_number)
	         INTO l_deal_count
	         FROM cn_comm_lines_api_all
	        WHERE order_number = l_order_number
	          AND revenue_type = 'REVENUE'
		  AND org_id = l_org_id;
	       IF (l_deal_count > 0) THEN
	          l_deal_type := 'REVENUE';
	       ELSE
	          l_deal_type := 'NONREVENUE';
	       END IF;
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                  FND_MESSAGE.Set_Name('CN', 'CN_DEAL_REV_ERROR');
 	          FND_MSG_PUB.Add;
               END IF;
               x_loading_status := 'CN_DEAL_REV_ERROR';
               RAISE FND_API.G_EXC_ERROR;
         END;
      ELSIF (p_invoice_number IS NOT NULL) THEN
         BEGIN
            SELECT count(invoice_number)
	      INTO l_deal_count
	      FROM cn_commission_headers_all
	     WHERE invoice_number = p_invoice_number
	       AND revenue_type = 'REVENUE'
	       AND org_id = l_org_id;
	    IF (l_deal_count > 0) THEN
	       l_deal_type := 'REVENUE';
	    ELSE
	       SELECT count(invoice_number)
	         INTO l_deal_count
	         FROM cn_comm_lines_api_all
	        WHERE invoice_number = p_invoice_number
	          AND revenue_type = 'REVENUE'
		  AND org_id = l_org_id;
	       IF (l_deal_count > 0) THEN
	          l_deal_type := 'REVENUE';
	       ELSE
	          l_deal_type := 'NONREVENUE';
	       END IF;
	    END IF;
	 EXCEPTION
	    WHEN OTHERS THEN
	       IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                  FND_MESSAGE.Set_Name('CN', 'CN_DEAL_REV_ERROR');
 	          FND_MSG_PUB.Add;
               END IF;
               x_loading_status := 'CN_DEAL_REV_ERROR';
               RAISE FND_API.G_EXC_ERROR;
         END;
      END IF;                 -- 8 end
      -- Check for split amount/percentages
      FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
      LOOP
         IF (p_split_data_tbl(i).revenue_type = 'REVENUE') THEN
            l_split_percent := l_split_percent + NVL(p_split_data_tbl(i).split_pct,0);
	 END IF;
      END LOOP;
      IF ((l_split_percent <> 100) AND (l_deal_type = 'REVENUE')) THEN
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
            FND_MESSAGE.Set_Name('CN', 'CN_ADJ_SPLIT_PERCENT');
 	    FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_ADJ_SPLIT_PERCENT';
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Check if split to all nonrevenue type or not / bug 2130062
      l_split_to_all_nonrevenue_type := 'Y';
      FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.last  -- 8.5
	LOOP
	   IF (p_split_data_tbl(i).revenue_type = 'REVENUE') THEN
	      l_split_to_all_nonrevenue_type := 'N';
	   END IF;
	END LOOP;

      IF ((l_deal_type = 'NONREVENUE') AND (l_split_to_all_nonrevenue_type = 'Y')) THEN
	 -- we need to split nonrevenue line
	 l_split_nonrevenue_line := 'Y';
       ELSE
	 -- we do not split nonrevenue line
	 l_split_nonrevenue_line := 'N';
      END IF; -- end of 8.5

      --
      -- Processing DEAL SPLIT for order number
      IF (l_order_number IS NOT NULL) THEN     -- 9

	 l_data_exist := 'N';

         FOR order_rec IN order_cur
	  LOOP

	  l_data_exist := 'Y';

          get_api_data(
   		p_comm_lines_api_id	=> order_rec.comm_lines_api_id,
		x_adj_tbl		=> l_adj_tbl);

            l_terr_id := NULL;
            l_terr_name := NULL;
            /* Added for Crediting Bug */
            BEGIN
    		    SELECT TERR_ID, TERR_NAME INTO l_terr_id, l_terr_name
	       	    FROM CN_COMM_LINES_API
		       WHERE
    		    COMM_LINES_API_ID = order_rec.comm_lines_api_id
	       	    AND ORG_ID = p_org_id;

            EXCEPTION
                WHEN OTHERS THEN
                NULL;
            END;

	  --
	  -- bug 2130062 do not split NONREVENUE line
	  --
	  IF ((l_adj_tbl(1).revenue_type = 'NONREVENUE') AND
	      (l_split_nonrevenue_line = 'N'))THEN
	       NULL;
	  ELSE
    	    cn_adjustments_pkg.api_negate_record(
      		x_comm_lines_api_id 	=> order_rec.comm_lines_api_id,
	       	x_adjusted_by	 	=> p_adjusted_by,
    		x_adjust_comments	=> p_adjust_comments);

            /* Added for Crediting Bug */

            /*update_credit_credentials(
            order_rec.comm_lines_api_id,
            l_terr_id,
            p_org_id,
            p_adjusted_by
            );*/


            FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
	      LOOP


	       IF (l_adj_tbl(1).load_status = 'LOADED') THEN
	          l_newtx_rec.transaction_amount 	:= l_adj_tbl(1).transaction_amount*
	                                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
		  l_newtx_rec.transaction_amount_orig	:= NULL;
	       ELSE
	          l_newtx_rec.transaction_amount 	:= NULL;
		  l_newtx_rec.transaction_amount_orig	:= l_adj_tbl(1).transaction_amount_orig*
	                                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
	       END IF;
	       l_newtx_rec.direct_salesrep_id 		:= p_split_data_tbl(i).salesrep_id;
	       l_newtx_rec.revenue_type			:= p_split_data_tbl(i).revenue_type;
	       l_newtx_rec.adjust_comments		:= p_adjust_comments;
	       l_newtx_rec.adjust_status		:= 'DEALSPLIT';
	       l_newtx_rec.load_status			:= 'UNLOADED';
	       l_newtx_rec.adj_comm_lines_api_id	:= order_rec.comm_lines_api_id;
	       l_newtx_rec.direct_salesrep_number	:= p_split_data_tbl(i).salesrep_number;
	       l_newtx_rec.split_pct			:= NVL(p_split_data_tbl(i).split_pct,0);
               l_newtx_rec.invoice_date                 := l_adj_tbl(1).invoice_date;
	       l_newtx_rec.order_date                   := l_adj_tbl(1).order_date;
	       l_newtx_rec.org_id                       := l_adj_tbl(1).org_id;
	       l_newtx_rec.inventory_item_id            := l_adj_tbl(1).inventory_item_id;
	       l_newtx_rec.terr_id := l_terr_id;
	       l_newtx_rec.terr_name := l_terr_name;


            /* Added for Crediting Bug */

    		    IF(l_terr_id IS NOT NULL)
	       	    THEN
		      	  l_newtx_rec.preserve_credit_override_flag := 'Y';
		      	  l_newtx_rec.terr_id := -999;
    		    END IF;

	       --
               cn_invoice_changes_pvt.prepare_api_record(
	       		p_newtx_rec		=> l_newtx_rec,
			p_old_adj_tbl		=> l_adj_tbl,
			x_final_trx_rec		=> o_newtx_rec,
			x_return_status 	=> x_return_status);
   	       --
   	       o_newtx_rec.adj_comm_lines_api_id := order_rec.comm_lines_api_id;
   	       --
               cn_get_tx_data_pub.insert_api_record(
   			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
     			p_validation_level	=> p_validation_level,
			p_action		=> 'UPDATE',
			p_newtx_rec		=> o_newtx_rec,
			x_api_id		=> l_comm_lines_api_id,
			x_return_status		=> x_return_status,
     			x_msg_count		=> x_msg_count,
     			x_msg_data		=> x_msg_data,
     			x_loading_status	=> x_loading_status);
               --
	    END LOOP;

	   END IF; -- 2130062 if l_adj_tbl(1).revenue_type = 'NONREVENUE' THEN
	  END LOOP;

	  --
	  IF (l_data_exist = 'N') THEN
	     IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
		FND_MESSAGE.Set_Name('CN', 'CN_NO_REC_DEAL');
		FND_MSG_PUB.Add;
	     END IF;
	     x_loading_status := 'CN_NO_REC_DEAL';
	     RAISE FND_API.G_EXC_ERROR;
	  END IF;

      END IF;       -- 9 end

      IF (p_invoice_number <> FND_API.G_MISS_CHAR) THEN    -- 10
         cn_invoice_changes_pvt.capture_deal_invoice(
      		p_api_version		=> p_api_version,
		p_trx_type		=> 'INV',
		p_split_nonrevenue_line => l_split_nonrevenue_line,
		p_invoice_number	=> p_invoice_number,
                p_org_id                => l_org_id,
		p_split_data_tbl	=> p_split_data_tbl,
		x_deal_data_tbl		=> l_deal_data_tbl,
		x_return_status		=> x_return_status,
     		x_msg_count		=> x_msg_count,
     		x_msg_data		=> x_msg_data,
     		x_loading_status	=> x_loading_status);
         IF (l_deal_data_tbl.COUNT > 0) THEN                  -- 11
            --
            FOR i IN l_deal_data_tbl.FIRST..l_deal_data_tbl.LAST
    	    LOOP
	       cn_adjustments_pkg.api_negate_record(
      		   x_comm_lines_api_id 	=> l_deal_data_tbl(i).comm_lines_api_id,
		   x_adjusted_by	=> p_adjusted_by,
		   x_adjust_comments	=> p_adjust_comments);
            /* Added for Crediting Bug */

            /*update_credit_credentials(
            l_deal_data_tbl(i).comm_lines_api_id,
            l_terr_id,
            p_org_id,
            p_adjusted_by
            );*/

            END LOOP;
	    --
            FOR j IN l_deal_data_tbl.FIRST..l_deal_data_tbl.LAST
	    LOOP
	    --
	    get_api_data(
   		p_comm_lines_api_id	=> l_deal_data_tbl(j).comm_lines_api_id,
		x_adj_tbl		=> l_adj_tbl);
	    --

            /* Added for Crediting Bug */
            l_terr_id := NULL;
            l_terr_name := NULL;
            BEGIN
    		    SELECT TERR_ID, TERR_NAME INTO l_terr_id, l_terr_name
	       	    FROM CN_COMM_LINES_API
		       WHERE
    		    COMM_LINES_API_ID = l_deal_data_tbl(j).comm_lines_api_id
	       	    AND ORG_ID = p_org_id;

            EXCEPTION
                WHEN OTHERS THEN
                NULL;
            END;

               FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
	       LOOP
	          IF (l_adj_tbl(1).load_status = 'LOADED') THEN
	             l_newtx_rec.transaction_amount 	:= l_adj_tbl(1).transaction_amount*
	                                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
		     l_newtx_rec.transaction_amount_orig:= NULL;
	          ELSE
	             l_newtx_rec.transaction_amount 	:= NULL;
		     l_newtx_rec.transaction_amount_orig:= l_adj_tbl(1).transaction_amount_orig*
	                                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
	          END IF;
	          l_newtx_rec.direct_salesrep_id 	:= p_split_data_tbl(i).salesrep_id;
	          l_newtx_rec.revenue_type		:= p_split_data_tbl(i).revenue_type;
	          l_newtx_rec.adjust_comments		:= p_adjust_comments;
	          l_newtx_rec.adjust_status		:= 'DEALSPLIT';
	          l_newtx_rec.load_status		:= 'UNLOADED';
	          l_newtx_rec.adj_comm_lines_api_id	:= l_deal_data_tbl(j).comm_lines_api_id;
	          l_newtx_rec.direct_salesrep_number	:= p_split_data_tbl(i).salesrep_number;
	          l_newtx_rec.split_pct			:= NVL(p_split_data_tbl(i).split_pct,0);
	          l_newtx_rec.invoice_number		:= l_deal_data_tbl(j).invoice_number;
	          l_newtx_rec.line_number		:= l_deal_data_tbl(j).line_number;
                  l_newtx_rec.invoice_date                 := l_adj_tbl(1).invoice_date;
	          l_newtx_rec.order_date                   := l_adj_tbl(1).order_date;
		  l_newtx_rec.org_id                       := l_adj_tbl(1).org_id;
		  l_newtx_rec.inventory_item_id            := l_adj_tbl(1).inventory_item_id;
		      l_newtx_rec.terr_id := l_terr_id;
		      l_newtx_rec.terr_name := l_terr_name;
	          --

            /* Added for Crediting Bug */

    		    IF(l_terr_id IS NOT NULL)
	       	    THEN
		      	  l_newtx_rec.preserve_credit_override_flag := 'Y';
		      	  l_newtx_rec.terr_id := -999;
    		    END IF;


            cn_invoice_changes_pvt.prepare_api_record(
	       	p_newtx_rec		=> l_newtx_rec,
			p_old_adj_tbl		=> l_adj_tbl,
			x_final_trx_rec		=> o_newtx_rec,
			x_return_status 	=> x_return_status);
   	          --
   	          o_newtx_rec.adj_comm_lines_api_id := l_deal_data_tbl(j).comm_lines_api_id;
   	          --
                  cn_get_tx_data_pub.insert_api_record(
   			p_api_version		=> p_api_version,
			p_init_msg_list		=> p_init_msg_list,
     			p_validation_level	=> p_validation_level,
			p_action		=> 'UPDATE',
			p_newtx_rec		=> o_newtx_rec,
			x_api_id		=> l_comm_lines_api_id,
			x_return_status		=> x_return_status,
     			x_msg_count		=> x_msg_count,
     			x_msg_data		=> x_msg_data,
     			x_loading_status	=> x_loading_status);
	          --
	          IF (g_track_invoice = 'Y') THEN
	             l_counter := l_counter + 1;
	             --
                     l_new_data(l_counter).salesrep_id	:= o_newtx_rec.direct_salesrep_id;
                     l_new_data(l_counter).direct_salesrep_number
      							:= o_newtx_rec.direct_salesrep_number;
                     l_new_data(l_counter).invoice_number
		     					:= o_newtx_rec.invoice_number;
                     l_new_data(l_counter).line_number	:= o_newtx_rec.line_number;
                     l_new_data(l_counter).revenue_type	:= o_newtx_rec.revenue_type;
                     l_new_data(l_counter).split_pct	:= o_newtx_rec.split_pct;
                     l_new_data(l_counter).comm_lines_api_id
		  					:= l_comm_lines_api_id;
                  --
	          END IF;
               END LOOP;
	    END LOOP;
         ELSE
            IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
               FND_MESSAGE.Set_Name('CN', 'CN_NO_REC_DEAL');
 	       FND_MSG_PUB.Add;
            END IF;
            x_loading_status := 'CN_NO_REC_DEAL';
            RAISE FND_API.G_EXC_ERROR;
         END IF;   -- 11 end
         --
         IF ((g_track_invoice = 'Y') AND (l_new_data.COUNT > 0)) THEN     -- 12
            --
            l_existing_data(1).salesrep_id 	:= NULL;
            l_existing_data(1).direct_salesrep_number
	 					:= NULL;
            l_existing_data(1).invoice_number 	:= NULL;
            l_existing_data(1).line_number	:= NULL;
            l_existing_data(1).revenue_type	:= NULL;
            l_existing_data(1).split_pct	:= NULL;
            l_existing_data(1).comm_lines_api_id:= NULL;
            --
            cn_invoice_changes_pvt.update_invoice_changes(
   	      p_api_version 		=> p_api_version,
   	      p_existing_data		=> l_existing_data,
	      p_new_data		=> l_new_data,
	      p_exist_data_check	=> 'N',
	      p_new_data_check		=> 'Y',
	      x_return_status		=> x_return_status,
	      x_msg_count		=> x_msg_count,
	      x_msg_data		=> x_msg_data,
	      x_loading_status		=> x_loading_status);
            --
            IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
               IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
                  FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	          FND_MSG_PUB.Add;
               END IF;
               x_loading_status := 'CN_UPDATE_INV_ERROR';
	       RAISE FND_API.G_EXC_ERROR;
            END IF;
	 END IF;    -- 12 end
         --
	 IF ((g_track_invoice = 'Y') AND (l_deal_data_tbl.COUNT > 0)) THEN  -- 13
	    FOR l_cm_pmt_count IN 1..2
	    LOOP
	       IF (l_cm_pmt_count = 1) THEN
	          l_trx_type := 'CM';
	       ELSE
	          l_trx_type := 'PMT';
	       END IF;
	       --
	       l_deal_data_tbl.DELETE;
	       --
               cn_invoice_changes_pvt.capture_deal_invoice
		 (
		  p_api_version		  => p_api_version,
		  p_trx_type		  => l_trx_type,
		  p_split_nonrevenue_line => l_split_nonrevenue_line,
		  p_invoice_number	  => p_invoice_number,
                  p_org_id                => l_org_id,
		  p_split_data_tbl	  => p_split_data_tbl,
		  x_deal_data_tbl	  => l_deal_data_tbl,
		  x_return_status	  => x_return_status,
		  x_msg_count		  => x_msg_count,
		  x_msg_data		  => x_msg_data,
		  x_loading_status		=> x_loading_status);
	       --
               IF (l_deal_data_tbl.COUNT > 0) THEN       -- 14
               --
                  FOR i IN l_deal_data_tbl.FIRST..l_deal_data_tbl.LAST
	          LOOP
	             cn_adjustments_pkg.api_negate_record(
      		      x_comm_lines_api_id 	=> l_deal_data_tbl(i).comm_lines_api_id,
		      x_adjusted_by	    	=> p_adjusted_by,
		      x_adjust_comments		=> p_adjust_comments);
                  END LOOP;
	          --
                  FOR j IN l_deal_data_tbl.FIRST..l_deal_data_tbl.LAST
	          LOOP


                /* Added for Crediting Bug */
                l_terr_id := NULL;
                l_terr_name := NULL;
                BEGIN
    	       	    SELECT TERR_ID, TERR_NAME INTO l_terr_id, l_terr_name
	       	        FROM CN_COMM_LINES_API
    		       WHERE
        		    COMM_LINES_API_ID = l_deal_data_tbl(j).comm_lines_api_id
	          	    AND ORG_ID = p_org_id;

                EXCEPTION
                    WHEN OTHERS THEN
                    NULL;
                END;


                     FOR i IN p_split_data_tbl.FIRST..p_split_data_tbl.LAST
	             LOOP
	                --
	                get_api_data(
   			   p_comm_lines_api_id	=> l_deal_data_tbl(j).comm_lines_api_id,
			   x_adj_tbl		=> l_adj_tbl);
	                --
	                IF (l_adj_tbl(1).load_status = 'LOADED') THEN
	                   l_newtx_rec.transaction_amount
			   		:= l_adj_tbl(1).transaction_amount*
	                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
		           l_newtx_rec.transaction_amount_orig 	:= NULL;
	                ELSE
	                   l_newtx_rec.transaction_amount	:= NULL;
		           l_newtx_rec.transaction_amount_orig
					:= l_adj_tbl(1).transaction_amount_orig*
	                                   NVL(p_split_data_tbl(i).split_pct,0)/100;
	                END IF;
	                l_newtx_rec.direct_salesrep_id
					:= p_split_data_tbl(i).salesrep_id;
	                l_newtx_rec.revenue_type
					:= p_split_data_tbl(i).revenue_type;
	                l_newtx_rec.adjust_comments
					:= p_adjust_comments;
	                l_newtx_rec.adjust_status := 'DEALSPLIT';
	                l_newtx_rec.load_status   := 'UNLOADED';
	                l_newtx_rec.split_status  := 'LINKED';
	                l_newtx_rec.adj_comm_lines_api_id
					:= l_deal_data_tbl(j).comm_lines_api_id;
	                l_newtx_rec.direct_salesrep_number
					:= p_split_data_tbl(i).salesrep_number;
	                l_newtx_rec.split_pct
					:= NVL(p_split_data_tbl(i).split_pct,0);
	                l_newtx_rec.invoice_number
					:= l_deal_data_tbl(j).invoice_number;
	                l_newtx_rec.line_number
					:= l_deal_data_tbl(j).line_number;

                        l_newtx_rec.invoice_date                 := l_adj_tbl(1).invoice_date;
	                l_newtx_rec.order_date                   := l_adj_tbl(1).order_date;
			l_newtx_rec.org_id                       := l_adj_tbl(1).org_id;
			l_newtx_rec.inventory_item_id            := l_adj_tbl(1).inventory_item_id;
			         l_newtx_rec.terr_id := l_terr_id;
			         l_newtx_rec.terr_name := l_terr_name;

    		    IF(l_terr_id IS NOT NULL)
	       	    THEN
		      	  l_newtx_rec.preserve_credit_override_flag := 'Y';
		      	  l_newtx_rec.terr_id := -999;
    		    END IF;


	                --
                        cn_invoice_changes_pvt.prepare_api_record(
	       		   p_newtx_rec		=> l_newtx_rec,
			   p_old_adj_tbl	=> l_adj_tbl,
			   x_final_trx_rec	=> o_newtx_rec,
			   x_return_status 	=> x_return_status);
   	                --
   	                o_newtx_rec.adj_comm_lines_api_id := l_deal_data_tbl(j).comm_lines_api_id;
   	                --
                        cn_get_tx_data_pub.insert_api_record(
   			   p_api_version	=> p_api_version,
			   p_init_msg_list	=> p_init_msg_list,
     			   p_validation_level	=> p_validation_level,
			   p_action		=> 'UPDATE',
			   p_newtx_rec		=> o_newtx_rec,
			   x_api_id		=> l_comm_lines_api_id,
			   x_return_status	=> x_return_status,
     			   x_msg_count		=> x_msg_count,
     			   x_msg_data		=> x_msg_data,
     			   x_loading_status	=> x_loading_status);
                     END LOOP;

            /* Added for Crediting Bug */

            /*update_credit_credentials(
            l_deal_data_tbl(j).comm_lines_api_id,
            l_terr_id,
            p_org_id,
            p_adjusted_by
            );*/

	          END LOOP;
	       END IF;    -- 14 end
	    END LOOP;
         END IF;    -- 13 end
      END IF;       -- 10 end
   END IF;          -- 1 end



EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO call_split;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO call_split;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO call_split;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE get_trx_lines(
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_header_id              IN        NUMBER	:= FND_API.G_MISS_NUM,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_trx_line_tbl           OUT NOCOPY       trx_line_tbl,
   	x_tbl_count              OUT NOCOPY       NUMBER) IS
CURSOR line_cur IS
   SELECT *
     FROM cn_adj_detail_lines_v
    WHERE commission_header_id = p_header_id;
--
   l_api_name		CONSTANT VARCHAR2(30) := 'get_trx_lines';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER := 0;
--
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_trx_lines;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   FOR line_rec IN line_cur
   LOOP
      l_tbl_count := l_tbl_count + 1;
      x_trx_line_tbl(l_tbl_count).commission_line_id		:= line_rec.commission_line_id;
      x_trx_line_tbl(l_tbl_count).commission_header_id		:= line_rec.commission_header_id;
      x_trx_line_tbl(l_tbl_count).credited_salesrep_id		:= line_rec.credited_salesrep_id;
      x_trx_line_tbl(l_tbl_count).credited_salesrep_name	:= line_rec.credited_salesrep_name;
      x_trx_line_tbl(l_tbl_count).credited_salesrep_number	:= line_rec.credited_salesrep_number;
      x_trx_line_tbl(l_tbl_count).processed_period_id		:= line_rec.processed_period_id;
      x_trx_line_tbl(l_tbl_count).processed_date		:= line_rec.processed_date;
      x_trx_line_tbl(l_tbl_count).plan_element			:= line_rec.plan_element;
      x_trx_line_tbl(l_tbl_count).payment_uplift		:= line_rec.payment_uplift;
      x_trx_line_tbl(l_tbl_count).quota_uplift			:= line_rec.quota_uplift;
      x_trx_line_tbl(l_tbl_count).commission_amount		:= line_rec.commission_amount;
      x_trx_line_tbl(l_tbl_count).commission_rate		:= line_rec.commission_rate;
      x_trx_line_tbl(l_tbl_count).created_during		:= line_rec.created_during;
      x_trx_line_tbl(l_tbl_count).pay_period			:= line_rec.pay_period;
      x_trx_line_tbl(l_tbl_count).accumulation_period		:= line_rec.accumulation_period;
      x_trx_line_tbl(l_tbl_count).perf_achieved			:= line_rec.perf_achieved;
      x_trx_line_tbl(l_tbl_count).posting_status		:= line_rec.posting_status;
      x_trx_line_tbl(l_tbl_count).pending_status		:= line_rec.pending_status;
      x_trx_line_tbl(l_tbl_count).trx_status			:= line_rec.trx_status;
      x_trx_line_tbl(l_tbl_count).payee				:= line_rec.payee;
   END LOOP;
   x_tbl_count := x_trx_line_tbl.COUNT;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_trx_lines;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO get_trx_lines;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO get_trx_lines;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE get_trx_history(
   	p_api_version            IN        NUMBER,
   	p_init_msg_list          IN        VARCHAR2 	:= FND_API.G_TRUE,
   	p_validation_level       IN        VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_adj_comm_lines_api_id  IN        NUMBER	:= FND_API.G_MISS_NUM,
   	x_return_status          OUT NOCOPY       VARCHAR2,
   	x_msg_count              OUT NOCOPY       NUMBER,
   	x_msg_data               OUT NOCOPY       VARCHAR2,
   	x_loading_status         OUT NOCOPY       VARCHAR2,
   	x_adj_tbl                OUT NOCOPY       adj_tbl_type,
   	x_adj_count              OUT NOCOPY       NUMBER) IS
--
CURSOR header_hist_cur IS
   SELECT cch.adj_comm_lines_api_id,re.resource_name name,
          s.salesrep_number employee_number,
          cch.processed_date,clt.meaning,cch.order_number,cch.booked_date,
          cch.invoice_number,cch.invoice_date,cch.quantity,
	  cch.transaction_amount,cch.transaction_amount_orig
     FROM cn_commission_headers cch,
          jtf_rs_resource_extns_vl re,
          jtf_rs_salesreps s,
          cn_lookups clt,
          cn_period_statuses  cpsp
    WHERE cch.direct_salesrep_id 	= s.salesrep_id
      AND s.resource_id                 = re.resource_id
      AND cch.processed_period_id 	= cpsp.period_id
      AND cch.trx_type 			= clt.lookup_code(+)
      AND clt.lookup_type  	     (+)= 'TRX TYPES'
      AND cch.comm_lines_api_id	= p_adj_comm_lines_api_id;
--
CURSOR api_hist_cur IS
   SELECT ccla.adj_comm_lines_api_id,re.resource_name name,
          s.salesrep_number employee_number,
          ccla.processed_date,clt.meaning,ccla.order_number,ccla.booked_date,
          ccla.invoice_number,ccla.invoice_date,ccla.quantity,
	  ccla.acctd_transaction_amount,ccla.transaction_amount
     FROM cn_comm_lines_api ccla,
          jtf_rs_resource_extns_vl re,
          jtf_rs_salesreps s,
          cn_lookups clt,
          cn_period_statuses  cpsp
    WHERE ccla.salesrep_id 		= s.salesrep_id
      AND s.resource_id                 = re.resource_id
      AND ccla.processed_period_id 	= cpsp.period_id
      AND ccla.trx_type 		= clt.lookup_code(+)
      AND clt.lookup_type  	     (+)= 'TRX TYPES'
      AND nvl(CCLA.load_status,'X')    <> 'LOADED'
      AND ccla.comm_lines_api_id	= p_adj_comm_lines_api_id;
--
   l_api_name		CONSTANT VARCHAR2(30) := 'get_trx_history';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER := 1;
--
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_trx_history;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   FOR adj IN header_hist_cur
   LOOP
      x_adj_tbl(l_tbl_count).direct_salesrep_name 	:= adj.name;
      x_adj_tbl(l_tbl_count).direct_salesrep_number 	:= adj.employee_number;
      x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
      x_adj_tbl(l_tbl_count).trx_type_disp		:= adj.meaning;
      x_adj_tbl(l_tbl_count).order_number		:= adj.order_number;
      x_adj_tbl(l_tbl_count).order_date			:= adj.booked_date;
      x_adj_tbl(l_tbl_count).invoice_number		:= adj.invoice_number;
      x_adj_tbl(l_tbl_count).invoice_date		:= adj.invoice_date;
      x_adj_tbl(l_tbl_count).quantity			:= adj.quantity;
      x_adj_tbl(l_tbl_count).transaction_amount		:= adj.transaction_amount;
      x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount_orig;
      l_tbl_count := l_tbl_count + 1;
   END LOOP;
   FOR adj IN api_hist_cur
   LOOP
      x_adj_tbl(l_tbl_count).direct_salesrep_name 	:= adj.name;
      x_adj_tbl(l_tbl_count).direct_salesrep_number 	:= adj.employee_number;
      x_adj_tbl(l_tbl_count).processed_date		:= adj.processed_date;
      x_adj_tbl(l_tbl_count).trx_type_disp		:= adj.meaning;
      x_adj_tbl(l_tbl_count).order_number		:= adj.order_number;
      x_adj_tbl(l_tbl_count).order_date			:= adj.booked_date;
      x_adj_tbl(l_tbl_count).invoice_number		:= adj.invoice_number;
      x_adj_tbl(l_tbl_count).invoice_date		:= adj.invoice_date;
      x_adj_tbl(l_tbl_count).quantity			:= adj.quantity;
      x_adj_tbl(l_tbl_count).transaction_amount		:= adj.acctd_transaction_amount;
      x_adj_tbl(l_tbl_count).transaction_amount_orig	:= adj.transaction_amount;
      l_tbl_count := l_tbl_count + 1;
   END LOOP;
   x_adj_count := x_adj_tbl.COUNT;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE get_cust_info(
   	p_api_version           IN      NUMBER,
   	p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   	p_comm_lines_api_id	IN	NUMBER,
	p_load_status		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_cust_info_rec	 OUT NOCOPY     cust_info_rec) IS
--
   l_api_name		CONSTANT VARCHAR2(30) := 'get_cust_info';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_tbl_count		NUMBER := 1;
   l_cust_info_rec	cn_adjustments_pkg.cust_info_rec;
--
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT get_cust_info;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   -- API body
   cn_adjustments_pkg.get_cust_info(
   	p_comm_lines_api_id	=> p_comm_lines_api_id,
	p_load_status		=> p_load_status,
	x_cust_info_rec		=> l_cust_info_rec);
   x_cust_info_rec.customer_id 		:= l_cust_info_rec.customer_id;
   x_cust_info_rec.customer_number	:= l_cust_info_rec.customer_number;
   x_cust_info_rec.customer_name	:= l_cust_info_rec.customer_name;
   x_cust_info_rec.bill_to_address_id	:= l_cust_info_rec.bill_to_address_id;
   x_cust_info_rec.bill_to_address1	:= l_cust_info_rec.bill_to_address1;
   x_cust_info_rec.bill_to_address2	:= l_cust_info_rec.bill_to_address2;
   x_cust_info_rec.bill_to_address3	:= l_cust_info_rec.bill_to_address3;
   x_cust_info_rec.bill_to_address4	:= l_cust_info_rec.bill_to_address4;
   x_cust_info_rec.bill_to_city		:= l_cust_info_rec.bill_to_city;
   x_cust_info_rec.bill_to_postal_code	:= l_cust_info_rec.bill_to_postal_code;
   x_cust_info_rec.bill_to_state	:= l_cust_info_rec.bill_to_state;
   x_cust_info_rec.ship_to_address_id	:= l_cust_info_rec.ship_to_address_id;
   x_cust_info_rec.ship_to_address1	:= l_cust_info_rec.ship_to_address1;
   x_cust_info_rec.ship_to_address2	:= l_cust_info_rec.ship_to_address2;
   x_cust_info_rec.ship_to_address3	:= l_cust_info_rec.ship_to_address3;
   x_cust_info_rec.ship_to_address4	:= l_cust_info_rec.ship_to_address4;
   x_cust_info_rec.ship_to_city 	:= l_cust_info_rec.ship_to_city;
   x_cust_info_rec.ship_to_postal_code	:= l_cust_info_rec.ship_to_postal_code;
   x_cust_info_rec.ship_to_state	:= l_cust_info_rec.ship_to_state;
   x_cust_info_rec.bill_to_contact_id	:= l_cust_info_rec.bill_to_contact_id;
   x_cust_info_rec.bill_to_contact	:= l_cust_info_rec.bill_to_contact;
   x_cust_info_rec.ship_to_contact_id	:= l_cust_info_rec.ship_to_contact_id;
   x_cust_info_rec.ship_to_contact	:= l_cust_info_rec.ship_to_contact;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE update_api_record(
		p_api_version   		IN	NUMBER,
		p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
		p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
		p_newtx_rec           	IN     	adj_rec_type,
		x_api_id	 			OUT NOCOPY NUMBER,
		x_return_status         OUT NOCOPY     VARCHAR2,
		x_msg_count             OUT NOCOPY     NUMBER,
		x_msg_data              OUT NOCOPY     VARCHAR2,
		x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name			CONSTANT VARCHAR2(30) := 'update_api_record';
   l_api_version      		CONSTANT NUMBER := 1.0;
   l_comm_lines_api_id		NUMBER;
   -- PL/SQL tables/records
   l_old_adj_tbl		adj_tbl_type;
   l_existing_data		cn_invoice_changes_pvt.invoice_tbl;
   l_new_data			cn_invoice_changes_pvt.invoice_tbl;
   l_newtx_rec			adj_rec_type;
   o_newtx_rec			adj_rec_type;
   --


BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_api_record;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status 	:= FND_API.G_RET_STS_SUCCESS;
   x_loading_status 	:= 'CN_INSERTED';
   x_api_id		:= fnd_api.g_miss_num;
   -- Get the existing data for the 'to be updated' comm_lines_api_id
   get_api_data(
	p_comm_lines_api_id	=> p_newtx_rec.comm_lines_api_id,
	x_adj_tbl       	=> l_old_adj_tbl);
   --
   IF ((g_track_invoice = 'Y') AND
       (l_old_adj_tbl.COUNT > 0) AND
       (l_old_adj_tbl(1).trx_type = 'INV')) THEN
      --
      l_existing_data(1).salesrep_id 	:= l_old_adj_tbl(1).direct_salesrep_id;
      l_existing_data(1).direct_salesrep_number
      					:= l_old_adj_tbl(1).direct_salesrep_number;
      l_existing_data(1).invoice_number := l_old_adj_tbl(1).invoice_number;
      l_existing_data(1).line_number	:= l_old_adj_tbl(1).line_number;
      l_existing_data(1).revenue_type	:= l_old_adj_tbl(1).revenue_type;
      l_existing_data(1).split_pct	:= l_old_adj_tbl(1).split_pct;
      l_existing_data(1).comm_lines_api_id
      					:= l_old_adj_tbl(1).comm_lines_api_id;
      --
      l_new_data(1).salesrep_id			:= NULL;
      l_new_data(1).direct_salesrep_number	:= NULL;
      l_new_data(1).invoice_number		:= NULL;
      l_new_data(1).line_number			:= NULL;
      l_new_data(1).revenue_type		:= NULL;
      l_new_data(1).split_pct			:= NULL;
      l_new_data(1).comm_lines_api_id		:= NULL;
      --
      cn_invoice_changes_pvt.update_invoice_changes(
         p_api_version 		=> l_api_version,
	 p_init_msg_list	=> p_init_msg_list,
     	 p_validation_level	=> p_validation_level,
         p_existing_data	=> l_existing_data,
	 p_new_data		=> l_new_data,
	 p_exist_data_check	=> 'Y',
	 p_new_data_check	=> 'N',
	 x_return_status	=> x_return_status,
	 x_msg_count		=> x_msg_count,
	 x_msg_data		=> x_msg_data,
	 x_loading_status	=> x_loading_status);
      --
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
            FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	    FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_UPDATE_INV_ERROR';
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
   END IF;
   --
   cn_adjustments_pkg.api_negate_record(
   	x_comm_lines_api_id	=> p_newtx_rec.comm_lines_api_id,
	x_adjusted_by		=> get_adjusted_by,
	x_adjust_comments	=> p_newtx_rec.adjust_comments);
   --

    /* Added for the Crediting Bug */
    /*update_credit_credentials(
    p_newtx_rec.comm_lines_api_id,
    p_newtx_rec.terr_id,
    p_newtx_rec.org_id,
    get_adjusted_by
    );*/


-- vensrini Nov 14, 2005
--   cn_mass_adjust_util.convert_rec_to_gmiss(
--	p_rec => p_newtx_rec,
--	x_api_rec => l_newtx_rec);
   -- vensrini Nov 14, 2005

   l_newtx_rec := p_newtx_rec;

   --
   IF ((l_old_adj_tbl(1).trx_type IN ('CM','PMT')) AND
       (g_track_invoice = 'Y')) THEN
      l_newtx_rec.split_status	:= 'DELINKED';
   END IF;
   --
   cn_invoice_changes_pvt.prepare_api_record(
	p_newtx_rec		=> l_newtx_rec,
	p_old_adj_tbl		=> l_old_adj_tbl,
	x_final_trx_rec		=> o_newtx_rec,
	x_return_status 	=> x_return_status);
   --

   o_newtx_rec.adj_comm_lines_api_id := l_old_adj_tbl(1).comm_lines_api_id;

   cn_get_tx_data_pub.insert_api_record(
   	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
     	p_validation_level	=> p_validation_level,
	p_action		=> 'UPDATE',
	p_newtx_rec		=> o_newtx_rec,
	x_api_id		=> x_api_id,
	x_return_status		=> x_return_status,
     	x_msg_count		=> x_msg_count,
     	x_msg_data		=> x_msg_data,
     	x_loading_status	=> x_loading_status);
   --
   IF ((g_track_invoice = 'Y') AND
       (l_old_adj_tbl.COUNT > 0) AND
       (l_old_adj_tbl(1).trx_type = 'INV')) THEN
      -- A dummy PL/SQL table need to be created with NULL values to make a
      -- call to update_invoice_changes procedure.
      l_new_data(1).salesrep_id		:= o_newtx_rec.direct_salesrep_id;
      l_new_data(1).invoice_number	:= o_newtx_rec.invoice_number;
      l_new_data(1).line_number		:= o_newtx_rec.line_number;
      l_new_data(1).revenue_type	:= o_newtx_rec.revenue_type;
      l_new_data(1).split_pct		:= o_newtx_rec.split_pct;
      l_new_data(1).direct_salesrep_number
      					:= o_newtx_rec.direct_salesrep_number;
      l_new_data(1).comm_lines_api_id	:= x_api_id;
      --
      cn_invoice_changes_pvt.update_invoice_changes(
   	p_api_version 		=> p_api_version,
	p_validation_level	=> p_validation_level,
   	p_existing_data		=> l_existing_data,
	p_new_data		=> l_new_data,
	p_exist_data_check	=> 'N',
	p_new_data_check	=> 'Y',
	x_return_status		=> x_return_status,
	x_msg_count		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	x_loading_status	=> x_loading_status);
      --
      IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
            FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	    FND_MSG_PUB.Add;
         END IF;
         x_loading_status := 'CN_UPDATE_INV_ERROR';
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      --
   END IF;
   --
   IF ((g_track_invoice = 'Y') AND
       (l_old_adj_tbl.COUNT > 0) AND
       (l_old_adj_tbl(1).trx_type = 'INV')) THEN
      cn_invoice_changes_pvt.update_credit_memo(
      	p_api_version		=> p_api_version,
	p_init_msg_list		=> p_init_msg_list,
     	p_validation_level	=> p_validation_level,
	p_existing_data		=> l_existing_data,
	p_new_data		=> l_new_data,
	p_called_from		=> 'UPDATE',
	p_adjust_status		=> 'MANUAL',
	x_return_status		=> x_return_status,
     	x_msg_count		=> x_msg_count,
     	x_msg_data		=> x_msg_data,
     	x_loading_status	=> x_loading_status);
   END IF;
   --

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
PROCEDURE call_load(
   	p_api_version   	IN	NUMBER,
     	p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_TRUE,
	p_commit	        IN      VARCHAR2 	:= FND_API.G_FALSE,
     	p_validation_level      IN      VARCHAR2 	:= FND_API.G_VALID_LEVEL_FULL,
   	p_salesrep_id           IN      NUMBER 		:= FND_API.G_MISS_NUM,
	p_pr_date_from          IN      DATE,
   	p_pr_date_to            IN      DATE,
	p_cls_rol_flag		IN	CHAR,
	p_load_method		IN	VARCHAR2,
 	p_org_id 		IN 	NUMBER,
	x_return_status         OUT NOCOPY     VARCHAR2,
     	x_msg_count             OUT NOCOPY     NUMBER,
     	x_msg_data              OUT NOCOPY     VARCHAR2,
     	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_process_audit_id      OUT NOCOPY     NUMBER) IS
   --
   l_api_name			CONSTANT VARCHAR2(30) := 'call_load';
   l_api_version      		CONSTANT NUMBER := 1.0;
   l_salesrep_id		NUMBER;
   l_cls_rol_flag 		CHAR(1)	:= 'Y';
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT call_load;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call ( l_api_version ,
                                        p_api_version ,
                                        l_api_name,
                                        G_PKG_NAME ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      FND_MSG_PUB.initialize;
   END IF;
   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   x_loading_status := 'CN_INSERTED';
   IF (p_salesrep_id = FND_API.G_MISS_NUM) THEN
      l_salesrep_id := NULL;
   ELSE
      l_salesrep_id := p_salesrep_id;
   END IF;
   IF (p_cls_rol_flag <> 'Y') THEN
      l_cls_rol_flag := 'N';
   END IF;
   IF (p_load_method = 'CONC') THEN

      x_process_audit_id :=
         FND_REQUEST.SUBMIT_REQUEST(
            application   => 'CN',
            program       => 'CN_TRX_INTERFACE',
            argument1     => TO_CHAR(l_salesrep_id),
            argument2     => TO_CHAR(p_pr_date_from,'YYYY/MM/DD HH24:MI:SS'),
	    argument3     => TO_CHAR(p_pr_date_to,'YYYY/MM/DD HH24:MI:SS'),
	    argument4     => l_cls_rol_flag);
   ELSE
      cn_transaction_load_pub.Load
            (p_api_version       => p_api_version,
             p_init_msg_list     => p_init_msg_list,
             p_commit            => p_commit,
             p_validation_level  => p_validation_level,
             p_salesrep_id       => l_salesrep_id,
             p_start_date        => p_pr_date_from,
             p_end_date          => p_pr_date_to,
             p_cls_rol_flag      => p_cls_rol_flag,
             p_org_id  		 => p_org_id,
             x_return_status     => x_return_status,
             x_msg_count         => x_msg_count,
             x_msg_data          => x_msg_data,
             x_loading_status    => x_loading_status,
             x_process_audit_id  => x_process_audit_id);
   END IF;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level(
         FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
      END IF;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
END;
--
END cn_get_tx_data_pub;



/
