--------------------------------------------------------
--  DDL for Package Body CN_INVOICE_CHANGES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_INVOICE_CHANGES_PVT" AS
--$Header: cnvinvb.pls 120.8.12010000.10 2009/10/05 12:31:04 rajukum ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_invoice_changes_pvt
-- Purpose
--   Package Body for Procedures related to cn_invoice_changes table changes.
-- History
--   08/07/01   Rao.Chenna         Created
  --
  -- Nov 22, 2005      vensrini     Bug Fix 4202682. Changed cursor c1 in
  --                                capture_deal_invoice proc to exclude transactions
  --                                with load status FILTERED
  --
  --                                Added org_id join to cursor c2 in capture_deal_invoice
  --                                proc
  --
  -- Jun 26, 2006      vensrini     Bug fix 5220393
  --
  -- Jul 5, 2006       vensrini     Bug fix 5349170


   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_INVOICE_CHANGES_PVT';
   G_FILE_NAME                 	CONSTANT VARCHAR2(12) := 'cnvinvb.pls';
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
PROCEDURE convert_adj_to_api(
	p_adj_rec	IN	cn_get_tx_data_pub.adj_rec_type,
	x_api_rec OUT NOCOPY cn_comm_lines_api_pkg.comm_lines_api_rec_type) IS
BEGIN
   x_api_rec.salesrep_id		:= p_adj_rec.direct_salesrep_id;
   x_api_rec.processed_date		:= p_adj_rec.processed_date;
   x_api_rec.processed_period_id	:= p_adj_rec.processed_period_id;
   x_api_rec.transaction_amount		:= p_adj_rec.transaction_amount_orig;
   x_api_rec.trx_type			:= p_adj_rec.trx_type;
   x_api_rec.revenue_class_id		:= p_adj_rec.revenue_class_id;
   x_api_rec.load_status		:= p_adj_rec.load_status;
   x_api_rec.attribute_category 	:= p_adj_rec.attribute_category;
   x_api_rec.attribute1			:= p_adj_rec.attribute1;
   x_api_rec.attribute2			:= p_adj_rec.attribute2;
   x_api_rec.attribute3			:= p_adj_rec.attribute3;
   x_api_rec.attribute4			:= p_adj_rec.attribute4;
   x_api_rec.attribute5			:= p_adj_rec.attribute5;
   x_api_rec.attribute6			:= p_adj_rec.attribute6;
   x_api_rec.attribute7			:= p_adj_rec.attribute7;
   x_api_rec.attribute8			:= p_adj_rec.attribute8;
   x_api_rec.attribute9			:= p_adj_rec.attribute9;
   x_api_rec.attribute10		:= p_adj_rec.attribute10;
   x_api_rec.attribute11		:= p_adj_rec.attribute11;
   x_api_rec.attribute12		:= p_adj_rec.attribute12;
   x_api_rec.attribute13		:= p_adj_rec.attribute13;
   x_api_rec.attribute14		:= p_adj_rec.attribute14;
   x_api_rec.attribute15		:= p_adj_rec.attribute15;
   x_api_rec.attribute16		:= p_adj_rec.attribute16;
   x_api_rec.attribute17		:= p_adj_rec.attribute17;
   x_api_rec.attribute18		:= p_adj_rec.attribute18;
   x_api_rec.attribute19		:= p_adj_rec.attribute19;
   x_api_rec.attribute20		:= p_adj_rec.attribute20;
   x_api_rec.attribute21		:= p_adj_rec.attribute21;
   x_api_rec.attribute22		:= p_adj_rec.attribute22;
   x_api_rec.attribute23		:= p_adj_rec.attribute23;
   x_api_rec.attribute24		:= p_adj_rec.attribute24;
   x_api_rec.attribute25		:= p_adj_rec.attribute25;
   x_api_rec.attribute26		:= p_adj_rec.attribute26;
   x_api_rec.attribute27		:= p_adj_rec.attribute27;
   x_api_rec.attribute28		:= p_adj_rec.attribute28;
   x_api_rec.attribute29		:= p_adj_rec.attribute29;
   x_api_rec.attribute30		:= p_adj_rec.attribute30;
   x_api_rec.attribute31		:= p_adj_rec.attribute31;
   x_api_rec.attribute32		:= p_adj_rec.attribute32;
   x_api_rec.attribute33		:= p_adj_rec.attribute33;
   x_api_rec.attribute34		:= p_adj_rec.attribute34;
   x_api_rec.attribute35		:= p_adj_rec.attribute35;
   x_api_rec.attribute36		:= p_adj_rec.attribute36;
   x_api_rec.attribute37		:= p_adj_rec.attribute37;
   x_api_rec.attribute38		:= p_adj_rec.attribute38;
   x_api_rec.attribute39		:= p_adj_rec.attribute39;
   x_api_rec.attribute40		:= p_adj_rec.attribute40;
   x_api_rec.attribute41		:= p_adj_rec.attribute41;
   x_api_rec.attribute42		:= p_adj_rec.attribute42;
   x_api_rec.attribute43		:= p_adj_rec.attribute43;
   x_api_rec.attribute44		:= p_adj_rec.attribute44;
   x_api_rec.attribute45		:= p_adj_rec.attribute45;
   x_api_rec.attribute46 		:= p_adj_rec.attribute46;
   x_api_rec.attribute47 		:= p_adj_rec.attribute47;
   x_api_rec.attribute48 		:= p_adj_rec.attribute48;
   x_api_rec.attribute49 		:= p_adj_rec.attribute49;
   x_api_rec.attribute50 		:= p_adj_rec.attribute50;
   x_api_rec.attribute51 		:= p_adj_rec.attribute51;
   x_api_rec.attribute52 		:= p_adj_rec.attribute52;
   x_api_rec.attribute53 		:= p_adj_rec.attribute53;
   x_api_rec.attribute54		:= p_adj_rec.attribute54;
   x_api_rec.attribute55 		:= p_adj_rec.attribute55;
   x_api_rec.attribute56 		:= p_adj_rec.attribute56;
   x_api_rec.attribute57 		:= p_adj_rec.attribute57;
   x_api_rec.attribute58 		:= p_adj_rec.attribute58;
   x_api_rec.attribute59 		:= p_adj_rec.attribute59;
   x_api_rec.attribute60 		:= p_adj_rec.attribute60;
   x_api_rec.attribute61 		:= p_adj_rec.attribute61;
   x_api_rec.attribute62 		:= p_adj_rec.attribute62;
   x_api_rec.attribute63 		:= p_adj_rec.attribute63;
   x_api_rec.attribute64 		:= p_adj_rec.attribute64;
   x_api_rec.attribute65  		:= p_adj_rec.attribute65;
   x_api_rec.attribute66  		:= p_adj_rec.attribute66;
   x_api_rec.attribute67  		:= p_adj_rec.attribute67;
   x_api_rec.attribute68  		:= p_adj_rec.attribute68;
   x_api_rec.attribute69  		:= p_adj_rec.attribute69;
   x_api_rec.attribute70  		:= p_adj_rec.attribute70;
   x_api_rec.attribute71  		:= p_adj_rec.attribute71;
   x_api_rec.attribute72  		:= p_adj_rec.attribute72;
   x_api_rec.attribute73 		:= p_adj_rec.attribute73;
   x_api_rec.attribute74 		:= p_adj_rec.attribute74;
   x_api_rec.attribute75  		:= p_adj_rec.attribute75;
   x_api_rec.attribute76 		:= p_adj_rec.attribute76;
   x_api_rec.attribute77 		:= p_adj_rec.attribute77;
   x_api_rec.attribute78  		:= p_adj_rec.attribute78;
   x_api_rec.attribute79 		:= p_adj_rec.attribute79;
   x_api_rec.attribute80 		:= p_adj_rec.attribute80;
   x_api_rec.attribute81 		:= p_adj_rec.attribute81;
   x_api_rec.attribute82 		:= p_adj_rec.attribute82;
   x_api_rec.attribute83 		:= p_adj_rec.attribute83;
   x_api_rec.attribute84 		:= p_adj_rec.attribute84;
   x_api_rec.attribute85 		:= p_adj_rec.attribute85;
   x_api_rec.attribute86 		:= p_adj_rec.attribute86;
   x_api_rec.attribute87 		:= p_adj_rec.attribute87;
   x_api_rec.attribute88  		:= p_adj_rec.attribute88;
   x_api_rec.attribute89  		:= p_adj_rec.attribute89;
   x_api_rec.attribute90  		:= p_adj_rec.attribute90;
   x_api_rec.attribute91  		:= p_adj_rec.attribute91;
   x_api_rec.attribute92  		:= p_adj_rec.attribute92;
   x_api_rec.attribute93  		:= p_adj_rec.attribute93;
   x_api_rec.attribute94  		:= p_adj_rec.attribute94;
   x_api_rec.attribute95  		:= p_adj_rec.attribute95;
   x_api_rec.attribute96 		:= p_adj_rec.attribute96;
   x_api_rec.attribute97 		:= p_adj_rec.attribute97;
   x_api_rec.attribute98 		:= p_adj_rec.attribute98;
   x_api_rec.attribute99  		:= p_adj_rec.attribute99;
   x_api_rec.attribute100 		:= p_adj_rec.attribute100;
   x_api_rec.employee_number		:= p_adj_rec.direct_salesrep_number;
   x_api_rec.comm_lines_api_id		:= p_adj_rec.comm_lines_api_id;
   x_api_rec.conc_batch_id		:= NULL;
   x_api_rec.process_batch_id		:= NULL;
   x_api_rec.salesrep_number		:= NULL;
   x_api_rec.rollup_date		:= p_adj_rec.rollup_date;
   x_api_rec.source_doc_id 		:= NULL;
   x_api_rec.source_doc_type		:= p_adj_rec.source_doc_type;
   x_api_rec.created_by			:= NULL;
   x_api_rec.creation_date		:= NULL;
   x_api_rec.last_updated_by		:= NULL;
   x_api_rec.last_update_date		:= NULL;
   x_api_rec.last_update_login		:= NULL;
   x_api_rec.transaction_currency_code	:= p_adj_rec.orig_currency_code;
   x_api_rec.exchange_rate		:= p_adj_rec.exchange_rate;
   x_api_rec.acctd_transaction_amount	:= p_adj_rec.transaction_amount;
   x_api_rec.trx_id			:= p_adj_rec.trx_id;
   x_api_rec.trx_line_id		:= p_adj_rec.trx_line_id;
   x_api_rec.trx_sales_line_id		:= p_adj_rec.trx_sales_line_id;
   x_api_rec.org_id			:= NULL;
   x_api_rec.quantity 			:= p_adj_rec.quantity;
   x_api_rec.source_trx_number		:= p_adj_rec.source_trx_number;
   x_api_rec.discount_percentage	:= p_adj_rec.discount_percentage;
   x_api_rec.margin_percentage 		:= p_adj_rec.margin_percentage;
   x_api_rec.pre_defined_rc_flag	:= NULL;
   x_api_rec.rollup_flag   		:= NULL;
   x_api_rec.forecast_id 		:= p_adj_rec.forecast_id;
   x_api_rec.upside_quantity		:= p_adj_rec.upside_quantity;
   x_api_rec.upside_amount		:= p_adj_rec.upside_amount;
   x_api_rec.uom_code  			:= p_adj_rec.uom_code;
   x_api_rec.source_trx_id  		:= p_adj_rec.source_trx_id;
   x_api_rec.source_trx_line_id 	:= p_adj_rec.source_trx_line_id;
   x_api_rec.source_trx_sales_line_id  	:= p_adj_rec.source_trx_sales_line_id;
   x_api_rec.negated_flag		:= NULL;
   x_api_rec.customer_id		:= p_adj_rec.customer_id;
   x_api_rec.inventory_item_id 		:= p_adj_rec.inventory_item_id;
   x_api_rec.order_number		:= p_adj_rec.order_number;
   x_api_rec.booked_date		:= p_adj_rec.order_date;
   x_api_rec.invoice_number		:= p_adj_rec.invoice_number;
   x_api_rec.invoice_date 		:= p_adj_rec.invoice_date;
   x_api_rec.bill_to_address_id		:= p_adj_rec.bill_to_address_id;
   x_api_rec.ship_to_address_id		:= p_adj_rec.ship_to_address_id;
   x_api_rec.bill_to_contact_id 	:= p_adj_rec.bill_to_contact_id;
   x_api_rec.ship_to_contact_id 	:= p_adj_rec.ship_to_contact_id;
   x_api_rec.adj_comm_lines_api_id	:= p_adj_rec.adj_comm_lines_api_id;
   x_api_rec.adjust_date  		:= SYSDATE;
   x_api_rec.adjusted_by 		:= get_adjusted_by;
   x_api_rec.revenue_type 		:= p_adj_rec.revenue_type;
   x_api_rec.adjust_rollup_flag 	:= p_adj_rec.adjust_rollup_flag;
   x_api_rec.adjust_comments   		:= p_adj_rec.adjust_comments;
   x_api_rec.adjust_status   		:= NVL(p_adj_rec.adjust_status,'NEW');
   x_api_rec.line_number    		:= p_adj_rec.line_number;
   x_api_rec.reason_code    		:= p_adj_rec.reason_code;
   x_api_rec.type   			:= p_adj_rec.type;
   x_api_rec.pre_processed_code  	:= p_adj_rec.pre_processed_code;
   x_api_rec.quota_id        		:= p_adj_rec.quota_id;
   x_api_rec.srp_plan_assign_id 	:= p_adj_rec.srp_plan_assign_id; -- NULL
   x_api_rec.role_id          		:= p_adj_rec.role_id; -- NULL
   x_api_rec.comp_group_id    		:= p_adj_rec.comp_group_id; -- NULL
   x_api_rec.commission_amount 		:= p_adj_rec.commission_amount;
   x_api_rec.reversal_flag     		:= NULL;
   x_api_rec.reversal_header_id		:= NULL;
   x_api_rec.sales_channel     		:= p_adj_rec.sales_channel;
   x_api_rec.object_version_number	:= p_adj_rec.object_version_number;
   x_api_rec.split_pct         		:= p_adj_rec.split_pct;
   x_api_rec.split_status      		:= p_adj_rec.split_status;
   x_api_rec.org_id      		:= p_adj_rec.org_id;
/* Added for Crediting Bug */
   x_api_rec.terr_id      		:= p_adj_rec.terr_id;
   x_api_rec.terr_name      		:= p_adj_rec.terr_name;
   x_api_rec.preserve_credit_override_flag := NVL(p_adj_rec.preserve_credit_override_flag,'N');
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;

-- Assumptions:
-- PL/SQL Table contains atleast on record.
PROCEDURE prepare_api_record(
	p_newtx_rec		IN	cn_get_tx_data_pub.adj_rec_type,
	p_old_adj_tbl		IN	cn_get_tx_data_pub.adj_tbl_type,
	x_final_trx_rec	 OUT NOCOPY cn_get_tx_data_pub.adj_rec_type,
	x_return_status	 OUT NOCOPY VARCHAR2) IS
   --
   l_attribute1		VARCHAR2(240);
   l_attribute100	VARCHAR2(240);
   l_exchange_rate  cn_comm_lines_api.exchange_rate%type;
   --
BEGIN

          IF (p_newtx_rec.exchange_rate <> FND_API.G_MISS_NUM) THEN
     		l_exchange_rate := p_newtx_rec.exchange_rate;
   	  ELSE
      		IF ((p_newtx_rec.orig_currency_code = FND_API.G_MISS_CHAR) OR
          	(p_newtx_rec.orig_currency_code = p_old_adj_tbl(1).orig_currency_code))
		THEN
			l_exchange_rate := p_old_adj_tbl(1).exchange_rate;
      		ELSE
        		l_exchange_rate := null;
      		END IF;
   	  END IF;

	SELECT

	  DECODE(p_newtx_rec.direct_salesrep_id,FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).direct_salesrep_id,p_newtx_rec.direct_salesrep_id),
          DECODE(p_newtx_rec.inventory_item_id,FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).inventory_item_id,p_newtx_rec.inventory_item_id),
	  -- Bug fix 5349170
	  DECODE(nvl(p_newtx_rec.source_trx_id,FND_API.G_MISS_num), FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).source_trx_id,p_newtx_rec.source_trx_id),
          DECODE(nvl(p_newtx_rec.source_trx_line_id,FND_API.G_MISS_num), FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).source_trx_line_id,p_newtx_rec.source_trx_line_id),
          DECODE(nvl(p_newtx_rec.source_trx_sales_line_id,FND_API.G_MISS_num), FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).source_trx_sales_line_id,p_newtx_rec.source_trx_sales_line_id),
	  -- Bug fix 5349170
	  DECODE(p_newtx_rec.processed_date,FND_API.G_MISS_DATE,
                 p_old_adj_tbl(1).processed_date,p_newtx_rec.processed_date),
          DECODE(p_newtx_rec.transaction_amount,FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).transaction_amount,p_newtx_rec.transaction_amount),
          DECODE(p_newtx_rec.trx_type,FND_API.G_MISS_CHAR,
                 p_old_adj_tbl(1).trx_type,p_newtx_rec.trx_type),
          DECODE(p_newtx_rec.revenue_class_id,FND_API.G_MISS_NUM,
                 p_old_adj_tbl(1).revenue_class_id,p_newtx_rec.revenue_class_id),
          'UNLOADED',
          DECODE(nvl(p_newtx_rec.attribute_category,FND_API.G_MISS_CHAR),FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute_category,p_newtx_rec.attribute_category),
          DECODE(p_newtx_rec.attribute1,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute1,p_newtx_rec.attribute1),
          DECODE(p_newtx_rec.attribute2,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute2,p_newtx_rec.attribute2),
          DECODE(p_newtx_rec.attribute3,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute3,p_newtx_rec.attribute3),
          DECODE(p_newtx_rec.attribute4,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute4,p_newtx_rec.attribute4),
          DECODE(p_newtx_rec.attribute5,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute5,p_newtx_rec.attribute5),
          DECODE(p_newtx_rec.attribute6,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute6,p_newtx_rec.attribute6),
          DECODE(p_newtx_rec.attribute7,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute7,p_newtx_rec.attribute7),
          DECODE(p_newtx_rec.attribute8,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute8,p_newtx_rec.attribute8),
          DECODE(p_newtx_rec.attribute9,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute9,p_newtx_rec.attribute9),
          DECODE(p_newtx_rec.attribute10,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute10,p_newtx_rec.attribute10),
          DECODE(p_newtx_rec.attribute11,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute11,p_newtx_rec.attribute11),
          DECODE(p_newtx_rec.attribute12,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute12,p_newtx_rec.attribute12),
          DECODE(p_newtx_rec.attribute13,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute13,p_newtx_rec.attribute13),
          DECODE(p_newtx_rec.attribute14,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute14,p_newtx_rec.attribute14),
          DECODE(p_newtx_rec.attribute15,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute15,p_newtx_rec.attribute15),
          DECODE(p_newtx_rec.attribute16,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute16,p_newtx_rec.attribute16),
          DECODE(p_newtx_rec.attribute17,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute17,p_newtx_rec.attribute17),
          DECODE(p_newtx_rec.attribute18,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute18,p_newtx_rec.attribute18),
          DECODE(p_newtx_rec.attribute19,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute19,p_newtx_rec.attribute19),
          DECODE(p_newtx_rec.attribute20,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute20,p_newtx_rec.attribute20),
          DECODE(p_newtx_rec.attribute21,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute21,p_newtx_rec.attribute21),
          DECODE(p_newtx_rec.attribute22,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute22,p_newtx_rec.attribute22),
          DECODE(p_newtx_rec.attribute23,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute23,p_newtx_rec.attribute23),
          DECODE(p_newtx_rec.attribute24,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute24,p_newtx_rec.attribute24),
          DECODE(p_newtx_rec.attribute25,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute25,p_newtx_rec.attribute25),
          DECODE(p_newtx_rec.attribute26,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute26,p_newtx_rec.attribute26),
          DECODE(p_newtx_rec.attribute27,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute27,p_newtx_rec.attribute27),
          DECODE(p_newtx_rec.attribute28,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute28,p_newtx_rec.attribute28),
          DECODE(p_newtx_rec.attribute29,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute29,p_newtx_rec.attribute29),
          DECODE(p_newtx_rec.attribute30,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute30,p_newtx_rec.attribute30),
          DECODE(p_newtx_rec.attribute31,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute31,p_newtx_rec.attribute31),
          DECODE(p_newtx_rec.attribute32,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute32,p_newtx_rec.attribute32),
          DECODE(p_newtx_rec.attribute33,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute33,p_newtx_rec.attribute33),
          DECODE(p_newtx_rec.attribute34,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute34,p_newtx_rec.attribute34),
          DECODE(p_newtx_rec.attribute35,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute35,p_newtx_rec.attribute35),
          DECODE(p_newtx_rec.attribute36,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute36,p_newtx_rec.attribute36),
          DECODE(p_newtx_rec.attribute37,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute37,p_newtx_rec.attribute37),
          DECODE(p_newtx_rec.attribute38,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute38,p_newtx_rec.attribute38),
          DECODE(p_newtx_rec.attribute39,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute39,p_newtx_rec.attribute39),
          DECODE(p_newtx_rec.attribute40,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute40,p_newtx_rec.attribute40),
          DECODE(p_newtx_rec.attribute41,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute41,p_newtx_rec.attribute41),
          DECODE(p_newtx_rec.attribute42,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute42,p_newtx_rec.attribute42),
          DECODE(p_newtx_rec.attribute43,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute43,p_newtx_rec.attribute43),
          DECODE(p_newtx_rec.attribute44,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute44,p_newtx_rec.attribute44),
          DECODE(p_newtx_rec.attribute45,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute45,p_newtx_rec.attribute45),
          DECODE(p_newtx_rec.attribute46,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute46,p_newtx_rec.attribute46),
          DECODE(p_newtx_rec.attribute47,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute47,p_newtx_rec.attribute47),
          DECODE(p_newtx_rec.attribute48,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute48,p_newtx_rec.attribute48),
          DECODE(p_newtx_rec.attribute49,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute49,p_newtx_rec.attribute49),
          DECODE(p_newtx_rec.attribute50,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute50,p_newtx_rec.attribute50),
          DECODE(p_newtx_rec.attribute51,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute51,p_newtx_rec.attribute51),
          DECODE(p_newtx_rec.attribute52,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute52,p_newtx_rec.attribute52),
          DECODE(p_newtx_rec.attribute53,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute53,p_newtx_rec.attribute53),
          DECODE(p_newtx_rec.attribute54,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute54,p_newtx_rec.attribute54),
          DECODE(p_newtx_rec.attribute55,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute55,p_newtx_rec.attribute55),
          DECODE(p_newtx_rec.attribute56,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute56,p_newtx_rec.attribute56),
          DECODE(p_newtx_rec.attribute57,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute57,p_newtx_rec.attribute57),
          DECODE(p_newtx_rec.attribute58,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute58,p_newtx_rec.attribute58),
          DECODE(p_newtx_rec.attribute59,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute59,p_newtx_rec.attribute59),
          DECODE(p_newtx_rec.attribute60,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute60,p_newtx_rec.attribute60),
          DECODE(p_newtx_rec.attribute61,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute61,p_newtx_rec.attribute61),
          DECODE(p_newtx_rec.attribute62,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute62,p_newtx_rec.attribute62),
          DECODE(p_newtx_rec.attribute63,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute63,p_newtx_rec.attribute63),
          DECODE(p_newtx_rec.attribute64,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute64,p_newtx_rec.attribute64),
          DECODE(p_newtx_rec.attribute65,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute65,p_newtx_rec.attribute65),
          DECODE(p_newtx_rec.attribute66,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute66,p_newtx_rec.attribute66),
          DECODE(p_newtx_rec.attribute67,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute67,p_newtx_rec.attribute67),
          DECODE(p_newtx_rec.attribute68,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute68,p_newtx_rec.attribute68),
          DECODE(p_newtx_rec.attribute69,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute69,p_newtx_rec.attribute69),
          DECODE(p_newtx_rec.attribute70,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute70,p_newtx_rec.attribute70),
          DECODE(p_newtx_rec.attribute71,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute71,p_newtx_rec.attribute71),
          DECODE(p_newtx_rec.attribute72,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute72,p_newtx_rec.attribute72),
          DECODE(p_newtx_rec.attribute73,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute73,p_newtx_rec.attribute73),
          DECODE(p_newtx_rec.attribute74,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute74,p_newtx_rec.attribute74),
          DECODE(p_newtx_rec.attribute75,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute75,p_newtx_rec.attribute75),
          DECODE(p_newtx_rec.attribute76,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute76,p_newtx_rec.attribute76),
          DECODE(p_newtx_rec.attribute77,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute77,p_newtx_rec.attribute77),
          DECODE(p_newtx_rec.attribute78,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute78,p_newtx_rec.attribute78),
          DECODE(p_newtx_rec.attribute79,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute79,p_newtx_rec.attribute79),
          DECODE(p_newtx_rec.attribute80,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute80,p_newtx_rec.attribute80),
          DECODE(p_newtx_rec.attribute81,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute81,p_newtx_rec.attribute81),
          DECODE(p_newtx_rec.attribute82,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute82,p_newtx_rec.attribute82),
          DECODE(p_newtx_rec.attribute83,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute83,p_newtx_rec.attribute83),
          DECODE(p_newtx_rec.attribute84,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute84,p_newtx_rec.attribute84),
          DECODE(p_newtx_rec.attribute85,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute85,p_newtx_rec.attribute85),
          DECODE(p_newtx_rec.attribute86,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute86,p_newtx_rec.attribute86),
          DECODE(p_newtx_rec.attribute87,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute87,p_newtx_rec.attribute87),
          DECODE(p_newtx_rec.attribute88,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute88,p_newtx_rec.attribute88),
          DECODE(p_newtx_rec.attribute89,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute89,p_newtx_rec.attribute89),
          DECODE(p_newtx_rec.attribute90,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute90,p_newtx_rec.attribute90),
          DECODE(p_newtx_rec.attribute91,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute91,p_newtx_rec.attribute91),
          DECODE(p_newtx_rec.attribute92,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute92,p_newtx_rec.attribute92),
          DECODE(p_newtx_rec.attribute93,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute93,p_newtx_rec.attribute93),
          DECODE(p_newtx_rec.attribute94,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute94,p_newtx_rec.attribute94),
          DECODE(p_newtx_rec.attribute95,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute95,p_newtx_rec.attribute95),
          DECODE(p_newtx_rec.attribute96,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute96,p_newtx_rec.attribute96),
          DECODE(p_newtx_rec.attribute97,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute97,p_newtx_rec.attribute97),
          DECODE(p_newtx_rec.attribute98,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute98,p_newtx_rec.attribute98),
          DECODE(p_newtx_rec.attribute99,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute99,p_newtx_rec.attribute99),
          DECODE(p_newtx_rec.attribute100,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).attribute100,p_newtx_rec.attribute100),
          DECODE(p_newtx_rec.rollup_date,FND_API.G_MISS_DATE,
	         p_old_adj_tbl(1).rollup_date,p_newtx_rec.rollup_date),
          DECODE(p_newtx_rec.source_doc_type,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).source_doc_type,p_newtx_rec.source_doc_type),
	  DECODE(p_newtx_rec.orig_currency_code,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).orig_currency_code,
		 p_newtx_rec.orig_currency_code),

	  l_exchange_rate,

          DECODE(p_newtx_rec.transaction_amount_orig,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).transaction_amount_orig,
	         p_newtx_rec.transaction_amount_orig),
	  -- Bug fix 5220393. Changed decode statement to just null value check.
	    decode(nvl(p_newtx_rec.trx_id, FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,
	           p_old_adj_tbl(1).trx_id, p_newtx_rec.trx_id),
	    decode(nvl(p_newtx_rec.trx_line_id, FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,
	           p_old_adj_tbl(1).trx_line_id, p_newtx_rec.trx_line_id),
	    decode(nvl(p_newtx_rec.trx_sales_line_id, FND_API.G_MISS_NUM),FND_API.G_MISS_NUM,
	           p_old_adj_tbl(1).trx_sales_line_id, p_newtx_rec.trx_sales_line_id),
	  -- Bug fix 5220393. Changed decode statement to just null value check.
          DECODE(p_newtx_rec.quantity,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).quantity,p_newtx_rec.quantity),
          DECODE(p_newtx_rec.source_trx_number,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).source_trx_number,p_newtx_rec.source_trx_number),
          DECODE(p_newtx_rec.discount_percentage,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).discount_percentage,p_newtx_rec.discount_percentage),
          DECODE(p_newtx_rec.margin_percentage,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).margin_percentage,p_newtx_rec.margin_percentage),
          DECODE(p_newtx_rec.customer_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).customer_id,p_newtx_rec.customer_id),
          DECODE(p_newtx_rec.order_number,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).order_number,p_newtx_rec.order_number),
          p_newtx_rec.order_date,
          DECODE(p_newtx_rec.invoice_number,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).invoice_number,p_newtx_rec.invoice_number),
          p_newtx_rec.invoice_date,
	  SYSDATE,
          DECODE(p_newtx_rec.revenue_type,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).revenue_type,p_newtx_rec.revenue_type),
          DECODE(p_newtx_rec.adjust_comments,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).adjust_comments,p_newtx_rec.adjust_comments),
	  NVL(DECODE(p_newtx_rec.adjust_status,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).adjust_status,p_newtx_rec.adjust_status),'NEW'),
          DECODE(p_newtx_rec.line_number,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).line_number,p_newtx_rec.line_number),
          DECODE(p_newtx_rec.bill_to_address_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).bill_to_address_id,p_newtx_rec.bill_to_address_id),
          DECODE(p_newtx_rec.ship_to_address_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).ship_to_address_id,p_newtx_rec.ship_to_address_id),
          DECODE(p_newtx_rec.bill_to_contact_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).bill_to_contact_id,p_newtx_rec.bill_to_contact_id),
          DECODE(p_newtx_rec.ship_to_contact_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).ship_to_contact_id,p_newtx_rec.ship_to_contact_id),
          DECODE(p_newtx_rec.reason_code,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).reason_code,p_newtx_rec.reason_code),
          DECODE(p_newtx_rec.quota_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).quota_id,p_newtx_rec.quota_id),
          p_newtx_rec.comp_group_id,
          DECODE(p_newtx_rec.direct_salesrep_number,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).direct_salesrep_number,
		 p_newtx_rec.direct_salesrep_number),
          DECODE(p_newtx_rec.sales_channel,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).sales_channel,p_newtx_rec.sales_channel),
          DECODE(p_newtx_rec.split_pct,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).split_pct,p_newtx_rec.split_pct),
          DECODE(p_newtx_rec.split_status,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).split_status,p_newtx_rec.split_status),
	  DECODE(p_newtx_rec.commission_amount,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).commission_amount,p_newtx_rec.commission_amount),
          DECODE(p_newtx_rec.role_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).role_id,p_newtx_rec.role_id),
	  DECODE(p_newtx_rec.pre_processed_code,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).pre_processed_code,p_newtx_rec.pre_processed_code),
	  DECODE(p_newtx_rec.org_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).org_id,p_newtx_rec.org_id),
/* Added for Crediting Bug */
      DECODE(p_newtx_rec.terr_id,FND_API.G_MISS_NUM,
	         p_old_adj_tbl(1).terr_id,p_newtx_rec.terr_id),
      DECODE(p_newtx_rec.terr_name,FND_API.G_MISS_CHAR,
	         p_old_adj_tbl(1).terr_name,p_newtx_rec.terr_name)       	,
	  DECODE(p_newtx_rec.preserve_credit_override_flag,FND_API.G_MISS_CHAR,
	         NVL(p_old_adj_tbl(1).preserve_credit_override_flag,'N'),NVL(p_newtx_rec.preserve_credit_override_flag,'N'))
     INTO x_final_trx_rec.direct_salesrep_id, x_final_trx_rec.inventory_item_id,
          x_final_trx_rec.source_trx_id, x_final_trx_rec.source_trx_line_id,
          x_final_trx_rec.source_trx_sales_line_id ,
          x_final_trx_rec.processed_date,
          x_final_trx_rec.transaction_amount, x_final_trx_rec.trx_type,
          x_final_trx_rec.revenue_class_id, x_final_trx_rec.load_status,
          x_final_trx_rec.attribute_category,
          x_final_trx_rec.attribute1, x_final_trx_rec.attribute2,
          x_final_trx_rec.attribute3, x_final_trx_rec.attribute4,
          x_final_trx_rec.attribute5, x_final_trx_rec.attribute6,
          x_final_trx_rec.attribute7, x_final_trx_rec.attribute8,
          x_final_trx_rec.attribute9, x_final_trx_rec.attribute10,
          x_final_trx_rec.attribute11, x_final_trx_rec.attribute12,
          x_final_trx_rec.attribute13, x_final_trx_rec.attribute14,
          x_final_trx_rec.attribute15, x_final_trx_rec.attribute16,
          x_final_trx_rec.attribute17, x_final_trx_rec.attribute18,
          x_final_trx_rec.attribute19, x_final_trx_rec.attribute20,
          x_final_trx_rec.attribute21, x_final_trx_rec.attribute22,
          x_final_trx_rec.attribute23, x_final_trx_rec.attribute24,
          x_final_trx_rec.attribute25, x_final_trx_rec.attribute26,
          x_final_trx_rec.attribute27, x_final_trx_rec.attribute28,
          x_final_trx_rec.attribute29, x_final_trx_rec.attribute30,
          x_final_trx_rec.attribute31, x_final_trx_rec.attribute32,
          x_final_trx_rec.attribute33, x_final_trx_rec.attribute34,
          x_final_trx_rec.attribute35, x_final_trx_rec.attribute36,
          x_final_trx_rec.attribute37, x_final_trx_rec.attribute38,
          x_final_trx_rec.attribute39, x_final_trx_rec.attribute40,
          x_final_trx_rec.attribute41, x_final_trx_rec.attribute42,
          x_final_trx_rec.attribute43, x_final_trx_rec.attribute44,
          x_final_trx_rec.attribute45, x_final_trx_rec.attribute46,
          x_final_trx_rec.attribute47, x_final_trx_rec.attribute48,
          x_final_trx_rec.attribute49, x_final_trx_rec.attribute50,
          x_final_trx_rec.attribute51, x_final_trx_rec.attribute52,
          x_final_trx_rec.attribute53, x_final_trx_rec.attribute54,
          x_final_trx_rec.attribute55, x_final_trx_rec.attribute56,
          x_final_trx_rec.attribute57, x_final_trx_rec.attribute58,
          x_final_trx_rec.attribute59, x_final_trx_rec.attribute60,
          x_final_trx_rec.attribute61, x_final_trx_rec.attribute62,
          x_final_trx_rec.attribute63, x_final_trx_rec.attribute64,
          x_final_trx_rec.attribute65, x_final_trx_rec.attribute66,
          x_final_trx_rec.attribute67, x_final_trx_rec.attribute68,
          x_final_trx_rec.attribute69, x_final_trx_rec.attribute70,
          x_final_trx_rec.attribute71, x_final_trx_rec.attribute72,
          x_final_trx_rec.attribute73, x_final_trx_rec.attribute74,
          x_final_trx_rec.attribute75, x_final_trx_rec.attribute76,
          x_final_trx_rec.attribute77, x_final_trx_rec.attribute78,
          x_final_trx_rec.attribute79, x_final_trx_rec.attribute80,
          x_final_trx_rec.attribute81, x_final_trx_rec.attribute82,
          x_final_trx_rec.attribute83, x_final_trx_rec.attribute84,
          x_final_trx_rec.attribute85, x_final_trx_rec.attribute86,
          x_final_trx_rec.attribute87, x_final_trx_rec.attribute88,
          x_final_trx_rec.attribute89, x_final_trx_rec.attribute90,
          x_final_trx_rec.attribute91, x_final_trx_rec.attribute92,
          x_final_trx_rec.attribute93, x_final_trx_rec.attribute94,
          x_final_trx_rec.attribute95, x_final_trx_rec.attribute96,
          x_final_trx_rec.attribute97, x_final_trx_rec.attribute98,
          x_final_trx_rec.attribute99, x_final_trx_rec.attribute100,
          x_final_trx_rec.rollup_date, x_final_trx_rec.source_doc_type,
          x_final_trx_rec.orig_currency_code, x_final_trx_rec.exchange_rate,
          x_final_trx_rec.transaction_amount_orig, x_final_trx_rec.trx_id,
          x_final_trx_rec.trx_line_id, x_final_trx_rec.trx_sales_line_id,
          x_final_trx_rec.quantity, x_final_trx_rec.source_trx_number,
          x_final_trx_rec.discount_percentage, x_final_trx_rec.margin_percentage,
          x_final_trx_rec.customer_id, x_final_trx_rec.order_number,
          x_final_trx_rec.order_date, x_final_trx_rec.invoice_number,
          x_final_trx_rec.invoice_date, x_final_trx_rec.adjust_date,
          x_final_trx_rec.revenue_type, x_final_trx_rec.adjust_comments,
	  x_final_trx_rec.adjust_status,
          x_final_trx_rec.line_number, x_final_trx_rec.bill_to_address_id,
          x_final_trx_rec.ship_to_address_id, x_final_trx_rec.bill_to_contact_id,
          x_final_trx_rec.ship_to_contact_id, x_final_trx_rec.reason_code ,
          x_final_trx_rec.quota_id, x_final_trx_rec.comp_group_id,
          x_final_trx_rec.direct_salesrep_number, x_final_trx_rec.sales_channel,
          x_final_trx_rec.split_pct, x_final_trx_rec.split_status,
	  x_final_trx_rec.commission_amount,x_final_trx_rec.role_id,
	  x_final_trx_rec.pre_processed_code, x_final_trx_rec.org_id,
	  x_final_trx_rec.terr_id, x_final_trx_rec.terr_name,
	  x_final_trx_rec.preserve_credit_override_flag
     FROM dual;
   x_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
END;
--
PROCEDURE update_invoice_changes(
      	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2 := FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
   	p_existing_data		IN	invoice_tbl,
	p_new_data		IN	invoice_tbl,
	p_exist_data_check	IN	VARCHAR2	DEFAULT NULL,
	p_new_data_check	IN	VARCHAR2	DEFAULT NULL,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name			CONSTANT VARCHAR2(30) := 'update_invoice_changes';
   l_api_version      		CONSTANT NUMBER := 1.0;
   --
   l_invoice_change_id		NUMBER;
   -- PL/SQL tables and records
   l_insert_rec			cn_invoice_changes_pkg.invoice_changes_all_rec_type;
   --
   CURSOR c1(
   	l_comm_lines_api_id	NUMBER) IS
      SELECT invoice_change_id
        FROM cn_invoice_changes
       WHERE comm_lines_api_id = l_comm_lines_api_id;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_invoice_changes;
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
   -- Delete the existing records in cn_invoice_changes table.
   -- apiId: I need to change here. update_api is OK with api_id.
   -- apiId: trx split uses this and it is OK with api_id.
   -- apiId: Move credits also uses and it is OK with api_id.
   IF (NVL(p_exist_data_check,'Y') = 'Y') THEN
      FOR i IN p_existing_data.FIRST..p_existing_data.LAST
      LOOP
         FOR c1_rec IN c1(p_existing_data(i).comm_lines_api_id)  LOOP
            cn_invoice_changes_pkg.delete_row(c1_rec.invoice_change_id);
         END LOOP;
      END LOOP;
   END IF;
   -- Create new records in the same table.
   IF (NVL(p_new_data_check,'Y') = 'Y') THEN
   FOR i IN p_new_data.FIRST..p_new_data.LAST
   LOOP
      --
      SELECT cn_invoice_change_s.NEXTVAL
        INTO l_invoice_change_id
	FROM dual;
      --
      l_insert_rec.invoice_change_id	:= l_invoice_change_id;
      l_insert_rec.salesrep_id		:= p_new_data(i).salesrep_id;
      l_insert_rec.invoice_number	:= p_new_data(i).invoice_number;
      l_insert_rec.line_number		:= p_new_data(i).line_number;
      l_insert_rec.revenue_type		:= p_new_data(i).revenue_type;
      l_insert_rec.split_pct		:= p_new_data(i).split_pct;
      l_insert_rec.comm_lines_api_id	:= p_new_data(i).comm_lines_api_id;
      --
      cn_invoice_changes_pkg.insert_row(
	 p_invoice_changes_all_rec 	=> l_insert_rec);
      --
   END LOOP;
   END IF;
   --
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_invoice_changes;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_invoice_changes;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_invoice_changes;
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
/*-----------------------------------------------------------------------------
  update_credit_memo logic:
  Step 1: Create a cursor api_cur based on old split % data.
  Step 2: Create a cursor header_cur based on old split % data.
  Step 3: Open existing old split % PL/SQL table.
  Step 4: For each record in the Step 3, open api_cur.
  Step 5: Get the comm_lines_api from Step 4 and negate the record.
  Step 6: Take the record info from api_cur and construct a adj_rec record type
  Step 7: Open new split % PL/SQL.
  Step 8: Complete constructing adj_rec type based on Step 6 and 7.
  Step 9: Call cn_get_tx_data_pub.insert_api_record to create a new record.
-----------------------------------------------------------------------------*/
PROCEDURE update_credit_memo(
      	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
   	p_existing_data		IN	invoice_tbl,
	p_new_data		IN	invoice_tbl,
	p_to_salesrep_id	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
	p_to_salesrep_number	IN   	VARCHAR2:= FND_API.G_MISS_CHAR,
	p_called_from		IN	VARCHAR2,
	p_adjust_status		IN	VARCHAR2,
   	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
   --
   l_api_name			CONSTANT VARCHAR2(30) := 'update_credit_memo';
   l_api_version      		CONSTANT NUMBER := 1.0;
   --
   l_last_update_date          	DATE    := sysdate;
   l_last_updated_by           	NUMBER  := fnd_global.user_id;
   l_creation_date             	DATE    := sysdate;
   l_created_by                	NUMBER  := fnd_global.user_id;
   l_last_update_login        	NUMBER  := fnd_global.login_id;
   l_comm_lines_api_id		NUMBER;
   --
   l_invoice_change_id		NUMBER;
   --
   l_newtx_rec			cn_get_tx_data_pub.adj_rec_type;
   --
   CURSOR api_cur(
   	l_salesrep_id		NUMBER,
	l_invoice_number	VARCHAR2,
	l_line_number		NUMBER,
	l_revenue_type		VARCHAR2,
	l_split_pct		NUMBER) IS
      SELECT l.*
        FROM cn_comm_lines_api l
       WHERE l.salesrep_id 	= l_salesrep_id
         AND l.invoice_number 	= l_invoice_number
	 AND l.line_number	= l_line_number
	 AND l.revenue_type 	= l_revenue_type
	 AND l.split_pct 	= l_split_pct
	 AND l.trx_type	IN ('CM','PMT')
	 AND l.load_status       <> 'LOADED'
	 AND ((l.adjust_status NOT IN ('FROZEN','REVERSAL','SCA_PENDING')) )--OR
--              (l.adjust_status IS NULL))
	 AND ((l.split_status    <> 'DELINKED') OR
	      (l.split_status IS NULL));
   --
   CURSOR header_cur(
   	l_salesrep_id		NUMBER,
	l_invoice_number	VARCHAR2,
	l_line_number		NUMBER,
	l_revenue_type		VARCHAR2,
	l_split_pct		NUMBER) IS
      SELECT h.*, api.terr_id, api.terr_name, NVL(api.preserve_credit_override_flag,'N') preserve_credit_override_flag
        FROM cn_commission_headers h,
        cn_comm_lines_api api
       WHERE h.direct_salesrep_id 	= l_salesrep_id
         AND h.invoice_number 		= l_invoice_number
	 AND h.line_number		= l_line_number
	 AND h.revenue_type 		= l_revenue_type
	 AND h.split_pct 		= l_split_pct
	 AND h.trx_type	IN ('CM','PMT')
	 AND ((h.adjust_status NOT IN ('FROZEN','REVERSAL')))-- OR
--              (h.adjust_status IS NULL))
	 AND ((h.split_status    <> 'DELINKED') OR
	      (h.split_status IS NULL))
     AND api.comm_lines_api_id = h.comm_lines_api_id
     AND api.org_id = h.org_id;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_credit_memo;
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
   -- Based on the input criteria get all the records
   FOR i IN p_existing_data.FIRST..p_existing_data.LAST
   LOOP
      FOR rec IN api_cur(p_existing_data(i).salesrep_id,
      		         p_existing_data(i).invoice_number,
		         p_existing_data(i).line_number,
		         p_existing_data(i).revenue_type,
		         p_existing_data(i).split_pct)
      LOOP
         /* codeCheck: I should be able to pass original invoice transaction
	               adjust_comments */
	 -- Then negate the transaction
         cn_adjustments_pkg.api_negate_record(
   	    x_comm_lines_api_id	=> rec.comm_lines_api_id,
	    x_adjusted_by	=> get_adjusted_by,
	    x_adjust_comments	=> rec.adjust_comments);
         -- Then create a transaction based on new split information.
	 l_newtx_rec.processed_period_id	:= rec.processed_period_id;
	 l_newtx_rec.processed_date		:= rec.processed_date;
	 l_newtx_rec.rollup_date		:= rec.rollup_date;
	 l_newtx_rec.transaction_amount		:= NULL;
	 l_newtx_rec.transaction_amount_orig	:= rec.transaction_amount;
         l_newtx_rec.trx_type			:= rec.trx_type;
	 l_newtx_rec.quantity			:= rec.quantity;
	 l_newtx_rec.discount_percentage	:= rec.discount_percentage;
	 l_newtx_rec.margin_percentage		:= rec.margin_percentage;
	 l_newtx_rec.orig_currency_code		:= rec.transaction_currency_code;
	 l_newtx_rec.exchange_rate		:= rec.exchange_rate;
	 l_newtx_rec.reason_code		:= rec.reason_code;
	 l_newtx_rec.comments			:= NULL;
	 l_newtx_rec.attribute_category         := rec.attribute_category;
	 l_newtx_rec.attribute1         	:= rec.attribute1;
	 l_newtx_rec.attribute2           	:= rec.attribute2;
	 l_newtx_rec.attribute3           	:= rec.attribute3;
	 l_newtx_rec.attribute4           	:= rec.attribute4;
	 l_newtx_rec.attribute5           	:= rec.attribute5;
	 l_newtx_rec.attribute6           	:= rec.attribute6;
	 l_newtx_rec.attribute7           	:= rec.attribute7;
	 l_newtx_rec.attribute8           	:= rec.attribute8;
	 l_newtx_rec.attribute9           	:= rec.attribute9;
	 l_newtx_rec.attribute10          	:= rec.attribute10;
	 l_newtx_rec.attribute11          	:= rec.attribute11;
	 l_newtx_rec.attribute12          	:= rec.attribute12;
	 l_newtx_rec.attribute13          	:= rec.attribute13;
	 l_newtx_rec.attribute14          	:= rec.attribute14;
	 l_newtx_rec.attribute15          	:= rec.attribute15;
	 l_newtx_rec.attribute16          	:= rec.attribute16;
	 l_newtx_rec.attribute17          	:= rec.attribute17;
	 l_newtx_rec.attribute18          	:= rec.attribute18;
	 l_newtx_rec.attribute19          	:= rec.attribute19;
	 l_newtx_rec.attribute20          	:= rec.attribute20;
	 l_newtx_rec.attribute21          	:= rec.attribute21;
	 l_newtx_rec.attribute22          	:= rec.attribute22;
	 l_newtx_rec.attribute23          	:= rec.attribute23;
	 l_newtx_rec.attribute24          	:= rec.attribute24;
	 l_newtx_rec.attribute25          	:= rec.attribute25;
	 l_newtx_rec.attribute26          	:= rec.attribute26;
	 l_newtx_rec.attribute27          	:= rec.attribute27;
	 l_newtx_rec.attribute28          	:= rec.attribute28;
	 l_newtx_rec.attribute29          	:= rec.attribute29;
	 l_newtx_rec.attribute30          	:= rec.attribute30;
	 l_newtx_rec.attribute31          	:= rec.attribute31;
	 l_newtx_rec.attribute32          	:= rec.attribute32;
	 l_newtx_rec.attribute33          	:= rec.attribute33;
	 l_newtx_rec.attribute34          	:= rec.attribute34;
	 l_newtx_rec.attribute35          	:= rec.attribute35;
	 l_newtx_rec.attribute36          	:= rec.attribute36;
	 l_newtx_rec.attribute37          	:= rec.attribute37;
	 l_newtx_rec.attribute38          	:= rec.attribute38;
	 l_newtx_rec.attribute39          	:= rec.attribute39;
	 l_newtx_rec.attribute40          	:= rec.attribute40;
	 l_newtx_rec.attribute41          	:= rec.attribute41;
	 l_newtx_rec.attribute42          	:= rec.attribute42;
	 l_newtx_rec.attribute43          	:= rec.attribute43;
	 l_newtx_rec.attribute44          	:= rec.attribute44;
	 l_newtx_rec.attribute45          	:= rec.attribute45;
	 l_newtx_rec.attribute46          	:= rec.attribute46;
	 l_newtx_rec.attribute47          	:= rec.attribute47;
	 l_newtx_rec.attribute48          	:= rec.attribute48;
	 l_newtx_rec.attribute49          	:= rec.attribute49;
	 l_newtx_rec.attribute50          	:= rec.attribute50;
	 l_newtx_rec.attribute51          	:= rec.attribute51;
	 l_newtx_rec.attribute52          	:= rec.attribute52;
	 l_newtx_rec.attribute53          	:= rec.attribute53;
	 l_newtx_rec.attribute54          	:= rec.attribute54;
	 l_newtx_rec.attribute55          	:= rec.attribute55;
	 l_newtx_rec.attribute56          	:= rec.attribute56;
	 l_newtx_rec.attribute57          	:= rec.attribute57;
	 l_newtx_rec.attribute58          	:= rec.attribute58;
	 l_newtx_rec.attribute59          	:= rec.attribute59;
	 l_newtx_rec.attribute60          	:= rec.attribute60;
	 l_newtx_rec.attribute61          	:= rec.attribute61;
	 l_newtx_rec.attribute62          	:= rec.attribute62;
	 l_newtx_rec.attribute63          	:= rec.attribute63;
	 l_newtx_rec.attribute64          	:= rec.attribute64;
	 l_newtx_rec.attribute65          	:= rec.attribute65;
	 l_newtx_rec.attribute66          	:= rec.attribute66;
	 l_newtx_rec.attribute67          	:= rec.attribute67;
	 l_newtx_rec.attribute68          	:= rec.attribute68;
	 l_newtx_rec.attribute69          	:= rec.attribute69;
	 l_newtx_rec.attribute70          	:= rec.attribute70;
	 l_newtx_rec.attribute71          	:= rec.attribute71;
	 l_newtx_rec.attribute72          	:= rec.attribute72;
	 l_newtx_rec.attribute73          	:= rec.attribute73;
	 l_newtx_rec.attribute74          	:= rec.attribute74;
	 l_newtx_rec.attribute75          	:= rec.attribute75;
	 l_newtx_rec.attribute76          	:= rec.attribute76;
	 l_newtx_rec.attribute77          	:= rec.attribute77;
	 l_newtx_rec.attribute78          	:= rec.attribute78;
	 l_newtx_rec.attribute79          	:= rec.attribute79;
	 l_newtx_rec.attribute80          	:= rec.attribute80;
	 l_newtx_rec.attribute81          	:= rec.attribute81;
	 l_newtx_rec.attribute82          	:= rec.attribute82;
	 l_newtx_rec.attribute83          	:= rec.attribute83;
	 l_newtx_rec.attribute84          	:= rec.attribute84;
	 l_newtx_rec.attribute85          	:= rec.attribute85;
	 l_newtx_rec.attribute86          	:= rec.attribute86;
	 l_newtx_rec.attribute87          	:= rec.attribute87;
	 l_newtx_rec.attribute88          	:= rec.attribute88;
	 l_newtx_rec.attribute89          	:= rec.attribute89;
	 l_newtx_rec.attribute90          	:= rec.attribute90;
	 l_newtx_rec.attribute91          	:= rec.attribute91;
	 l_newtx_rec.attribute92          	:= rec.attribute92;
	 l_newtx_rec.attribute93          	:= rec.attribute93;
	 l_newtx_rec.attribute94          	:= rec.attribute94;
	 l_newtx_rec.attribute95          	:= rec.attribute95;
	 l_newtx_rec.attribute96          	:= rec.attribute96;
	 l_newtx_rec.attribute97          	:= rec.attribute97;
	 l_newtx_rec.attribute98          	:= rec.attribute98;
	 l_newtx_rec.attribute99          	:= rec.attribute99;
	 l_newtx_rec.attribute100         	:= rec.attribute100;
	 l_newtx_rec.source_doc_type 		:= rec.source_doc_type;
	 l_newtx_rec.source_trx_number		:= rec.source_trx_number;
	 l_newtx_rec.trx_sales_line_id 		:= rec.trx_sales_line_id;
 	 l_newtx_rec.trx_line_id		:= rec.trx_line_id;
 	 l_newtx_rec.trx_id			:= rec.trx_id;
	 l_newtx_rec.upside_amount 		:= rec.upside_amount;
	 l_newtx_rec.upside_quantity 		:= rec.upside_quantity;
	 l_newtx_rec.uom_code 			:= rec.uom_code;
	 l_newtx_rec.forecast_id 		:= rec.forecast_id;
	 l_newtx_rec.adj_comm_lines_api_id	:= rec.comm_lines_api_id;
	 l_newtx_rec.invoice_number 		:= rec.invoice_number;
	 l_newtx_rec.invoice_date 		:= rec.invoice_date;
	 l_newtx_rec.order_number 		:= rec.order_number;
	 l_newtx_rec.order_date 		:= rec.booked_date;
	 l_newtx_rec.line_number 		:= rec.line_number;
	 l_newtx_rec.customer_id 		:= rec.customer_id;
	 l_newtx_rec.bill_to_address_id 	:= rec.bill_to_address_id;
	 l_newtx_rec.ship_to_address_id 	:= rec.ship_to_address_id;
	 l_newtx_rec.bill_to_contact_id 	:= rec.bill_to_contact_id;
	 l_newtx_rec.ship_to_contact_id 	:= rec.ship_to_contact_id;
	 l_newtx_rec.load_status 		:= 'UNLOADED';
	 l_newtx_rec.revenue_type 		:= rec.revenue_type;
	 l_newtx_rec.adjust_rollup_flag 	:= rec.adjust_rollup_flag;
	 l_newtx_rec.adjust_date 		:= rec.adjust_date;
	 l_newtx_rec.adjusted_by 		:= rec.adjusted_by;
	 l_newtx_rec.adjust_status 		:= NVL(p_adjust_status,'NEW');
	 l_newtx_rec.adjust_comments 		:= rec.adjust_comments;
	 l_newtx_rec.type 			:= rec.type;
	 l_newtx_rec.pre_processed_code 	:= rec.pre_processed_code;
	 l_newtx_rec.comp_group_id 		:= rec.comp_group_id;
	 l_newtx_rec.srp_plan_assign_id 	:= rec.srp_plan_assign_id;
	 l_newtx_rec.role_id 			:= rec.role_id;
	 l_newtx_rec.sales_channel 		:= rec.sales_channel;
	 l_newtx_rec.split_pct 			:= rec.split_pct;
	 l_newtx_rec.split_status 		:= 'LINKED';
	 l_newtx_rec.commission_amount 		:= rec.commission_amount;

	 /* Added for crediting bug*/
	 l_newtx_rec.terr_id 		:= rec.terr_id;
	 l_newtx_rec.terr_name 		:= rec.terr_name;
	 l_newtx_rec.preserve_credit_override_flag 		:= NVL(rec.preserve_credit_override_flag,'N');

     --Added for Crediting bug
     IF(rec.terr_id IS NOT NULL)
     THEN
     l_newtx_rec.preserve_credit_override_flag 	:= 'Y';
     l_newtx_rec.terr_id := -999;
     END IF;


         --
	 -- Update this record with new split information.
	 IF (p_called_from = 'MASS') THEN
	    l_newtx_rec.direct_salesrep_number	:= p_to_salesrep_number;
	    l_newtx_rec.direct_salesrep_id	:= p_to_salesrep_id;
	    l_newtx_rec.invoice_number 		:= rec.invoice_number;
	    l_newtx_rec.line_number 		:= rec.line_number;
	    l_newtx_rec.revenue_type		:= rec.revenue_type;
	    l_newtx_rec.split_pct 		:= rec.split_pct;
	    --
	    cn_get_tx_data_pub.insert_api_record(
   	       p_api_version		=> p_api_version,
	       p_init_msg_list		=> p_init_msg_list,
     	       p_validation_level	=> p_validation_level,
	       p_action			=> 'UPDATE',
	       p_newtx_rec		=> l_newtx_rec,
	       x_api_id			=> l_comm_lines_api_id,
	       x_return_status		=> x_return_status,
     	       x_msg_count		=> x_msg_count,
     	       x_msg_data		=> x_msg_data,
     	       x_loading_status		=> x_loading_status);
	    -- codeCheck: I need to handle the return_status
	 ELSE
	 FOR i IN p_new_data.FIRST..p_new_data.LAST
	 LOOP
	    l_newtx_rec.direct_salesrep_number	:= p_new_data(i).direct_salesrep_number;
	    l_newtx_rec.direct_salesrep_id	:= p_new_data(i).salesrep_id;
	    l_newtx_rec.invoice_number 		:= p_new_data(i).invoice_number;
	    l_newtx_rec.line_number 		:= p_new_data(i).line_number;
	    l_newtx_rec.revenue_type		:= p_new_data(i).revenue_type;
	    l_newtx_rec.split_pct 		:= p_new_data(i).split_pct;
	    IF (p_called_from = 'SPLIT') THEN
               l_newtx_rec.transaction_amount_orig
	       					:= ROUND((rec.transaction_amount*
	       					          p_new_data(i).split_pct)/100,2);
	    END IF;
 	    -- Create a record in the cn_comm_lines_api table using this record.
	    cn_get_tx_data_pub.insert_api_record(
   	       p_api_version		=> p_api_version,
	       p_init_msg_list		=> p_init_msg_list,
     	       p_validation_level	=> p_validation_level,
	       p_action			=> 'UPDATE',
	       p_newtx_rec		=> l_newtx_rec,
	       x_api_id			=> l_comm_lines_api_id,
	       x_return_status		=> x_return_status,
     	       x_msg_count		=> x_msg_count,
     	       x_msg_data		=> x_msg_data,
     	       x_loading_status		=> x_loading_status);
	    --
         END LOOP;
	 END IF;
	 --

            /* Added for Crediting Bug */

            /*cn_get_tx_data_pub.update_credit_credentials(
            rec.comm_lines_api_id,
            rec.terr_id,
            rec.org_id,
            rec.adjusted_by
            );*/

      END LOOP;
      --
      FOR rec IN header_cur(
      		p_existing_data(i).salesrep_id,
      		p_existing_data(i).invoice_number,
		p_existing_data(i).line_number,
		p_existing_data(i).revenue_type,
		p_existing_data(i).split_pct)
      LOOP
         /* codeCheck: I should be able to pass original invoice transaction
	               adjust_comments */
	 -- Then negate the transaction
         cn_adjustments_pkg.api_negate_record(
   	    x_comm_lines_api_id	=> rec.comm_lines_api_id,
	    x_adjusted_by	=> get_adjusted_by,
	    x_adjust_comments	=> rec.adjust_comments);
         -- Then create a transaction based on new split information.
	 l_newtx_rec.processed_period_id	:= rec.processed_period_id;
	 l_newtx_rec.processed_date		:= rec.processed_date;
	 l_newtx_rec.rollup_date		:= rec.rollup_date;
	 l_newtx_rec.transaction_amount		:= rec.transaction_amount;
	 l_newtx_rec.transaction_amount_orig	:= NULL;
	 l_newtx_rec.trx_type			:= rec.trx_type;
	 l_newtx_rec.quantity			:= rec.quantity;
	 l_newtx_rec.discount_percentage	:= rec.discount_percentage;
	 l_newtx_rec.margin_percentage		:= rec.margin_percentage;
	 l_newtx_rec.orig_currency_code		:= rec.orig_currency_code;
	 l_newtx_rec.exchange_rate		:= rec.exchange_rate;
	 l_newtx_rec.reason_code		:= rec.reason_code;
	 l_newtx_rec.comments			:= rec.comments;
	 l_newtx_rec.attribute_category         := rec.attribute_category;
	 l_newtx_rec.attribute1         	:= rec.attribute1;
	 l_newtx_rec.attribute2           	:= rec.attribute2;
	 l_newtx_rec.attribute3           	:= rec.attribute3;
	 l_newtx_rec.attribute4           	:= rec.attribute4;
	 l_newtx_rec.attribute5           	:= rec.attribute5;
	 l_newtx_rec.attribute6           	:= rec.attribute6;
	 l_newtx_rec.attribute7           	:= rec.attribute7;
	 l_newtx_rec.attribute8           	:= rec.attribute8;
	 l_newtx_rec.attribute9           	:= rec.attribute9;
	 l_newtx_rec.attribute10          	:= rec.attribute10;
	 l_newtx_rec.attribute11          	:= rec.attribute11;
	 l_newtx_rec.attribute12          	:= rec.attribute12;
	 l_newtx_rec.attribute13          	:= rec.attribute13;
	 l_newtx_rec.attribute14          	:= rec.attribute14;
	 l_newtx_rec.attribute15          	:= rec.attribute15;
	 l_newtx_rec.attribute16          	:= rec.attribute16;
	 l_newtx_rec.attribute17          	:= rec.attribute17;
	 l_newtx_rec.attribute18          	:= rec.attribute18;
	 l_newtx_rec.attribute19          	:= rec.attribute19;
	 l_newtx_rec.attribute20          	:= rec.attribute20;
	 l_newtx_rec.attribute21          	:= rec.attribute21;
	 l_newtx_rec.attribute22          	:= rec.attribute22;
	 l_newtx_rec.attribute23          	:= rec.attribute23;
	 l_newtx_rec.attribute24          	:= rec.attribute24;
	 l_newtx_rec.attribute25          	:= rec.attribute25;
	 l_newtx_rec.attribute26          	:= rec.attribute26;
	 l_newtx_rec.attribute27          	:= rec.attribute27;
	 l_newtx_rec.attribute28          	:= rec.attribute28;
	 l_newtx_rec.attribute29          	:= rec.attribute29;
	 l_newtx_rec.attribute30          	:= rec.attribute30;
	 l_newtx_rec.attribute31          	:= rec.attribute31;
	 l_newtx_rec.attribute32          	:= rec.attribute32;
	 l_newtx_rec.attribute33          	:= rec.attribute33;
	 l_newtx_rec.attribute34          	:= rec.attribute34;
	 l_newtx_rec.attribute35          	:= rec.attribute35;
	 l_newtx_rec.attribute36          	:= rec.attribute36;
	 l_newtx_rec.attribute37          	:= rec.attribute37;
	 l_newtx_rec.attribute38          	:= rec.attribute38;
	 l_newtx_rec.attribute39          	:= rec.attribute39;
	 l_newtx_rec.attribute40          	:= rec.attribute40;
	 l_newtx_rec.attribute41          	:= rec.attribute41;
	 l_newtx_rec.attribute42          	:= rec.attribute42;
	 l_newtx_rec.attribute43          	:= rec.attribute43;
	 l_newtx_rec.attribute44          	:= rec.attribute44;
	 l_newtx_rec.attribute45          	:= rec.attribute45;
	 l_newtx_rec.attribute46          	:= rec.attribute46;
	 l_newtx_rec.attribute47          	:= rec.attribute47;
	 l_newtx_rec.attribute48          	:= rec.attribute48;
	 l_newtx_rec.attribute49          	:= rec.attribute49;
	 l_newtx_rec.attribute50          	:= rec.attribute50;
	 l_newtx_rec.attribute51          	:= rec.attribute51;
	 l_newtx_rec.attribute52          	:= rec.attribute52;
	 l_newtx_rec.attribute53          	:= rec.attribute53;
	 l_newtx_rec.attribute54          	:= rec.attribute54;
	 l_newtx_rec.attribute55          	:= rec.attribute55;
	 l_newtx_rec.attribute56          	:= rec.attribute56;
	 l_newtx_rec.attribute57          	:= rec.attribute57;
	 l_newtx_rec.attribute58          	:= rec.attribute58;
	 l_newtx_rec.attribute59          	:= rec.attribute59;
	 l_newtx_rec.attribute60          	:= rec.attribute60;
	 l_newtx_rec.attribute61          	:= rec.attribute61;
	 l_newtx_rec.attribute62          	:= rec.attribute62;
	 l_newtx_rec.attribute63          	:= rec.attribute63;
	 l_newtx_rec.attribute64          	:= rec.attribute64;
	 l_newtx_rec.attribute65          	:= rec.attribute65;
	 l_newtx_rec.attribute66          	:= rec.attribute66;
	 l_newtx_rec.attribute67          	:= rec.attribute67;
	 l_newtx_rec.attribute68          	:= rec.attribute68;
	 l_newtx_rec.attribute69          	:= rec.attribute69;
	 l_newtx_rec.attribute70          	:= rec.attribute70;
	 l_newtx_rec.attribute71          	:= rec.attribute71;
	 l_newtx_rec.attribute72          	:= rec.attribute72;
	 l_newtx_rec.attribute73          	:= rec.attribute73;
	 l_newtx_rec.attribute74          	:= rec.attribute74;
	 l_newtx_rec.attribute75          	:= rec.attribute75;
	 l_newtx_rec.attribute76          	:= rec.attribute76;
	 l_newtx_rec.attribute77          	:= rec.attribute77;
	 l_newtx_rec.attribute78          	:= rec.attribute78;
	 l_newtx_rec.attribute79          	:= rec.attribute79;
	 l_newtx_rec.attribute80          	:= rec.attribute80;
	 l_newtx_rec.attribute81          	:= rec.attribute81;
	 l_newtx_rec.attribute82          	:= rec.attribute82;
	 l_newtx_rec.attribute83          	:= rec.attribute83;
	 l_newtx_rec.attribute84          	:= rec.attribute84;
	 l_newtx_rec.attribute85          	:= rec.attribute85;
	 l_newtx_rec.attribute86          	:= rec.attribute86;
	 l_newtx_rec.attribute87          	:= rec.attribute87;
	 l_newtx_rec.attribute88          	:= rec.attribute88;
	 l_newtx_rec.attribute89          	:= rec.attribute89;
	 l_newtx_rec.attribute90          	:= rec.attribute90;
	 l_newtx_rec.attribute91          	:= rec.attribute91;
	 l_newtx_rec.attribute92          	:= rec.attribute92;
	 l_newtx_rec.attribute93          	:= rec.attribute93;
	 l_newtx_rec.attribute94          	:= rec.attribute94;
	 l_newtx_rec.attribute95          	:= rec.attribute95;
	 l_newtx_rec.attribute96          	:= rec.attribute96;
	 l_newtx_rec.attribute97          	:= rec.attribute97;
	 l_newtx_rec.attribute98          	:= rec.attribute98;
	 l_newtx_rec.attribute99          	:= rec.attribute99;
	 l_newtx_rec.attribute100         	:= rec.attribute100;
	 l_newtx_rec.source_doc_type 		:= rec.source_doc_type;
	 l_newtx_rec.source_trx_number		:= rec.source_trx_number;
	 l_newtx_rec.upside_amount 		:= rec.upside_amount;
	 l_newtx_rec.upside_quantity 		:= rec.upside_quantity;
	 l_newtx_rec.uom_code 			:= rec.uom_code;
	 l_newtx_rec.forecast_id 		:= rec.forecast_id;
	 l_newtx_rec.adj_comm_lines_api_id	:= rec.comm_lines_api_id;
	 l_newtx_rec.invoice_number 		:= rec.invoice_number;
	 l_newtx_rec.invoice_date 		:= rec.invoice_date;
	 l_newtx_rec.order_number 		:= rec.order_number;
	 l_newtx_rec.order_date 		:= rec.booked_date;
	 l_newtx_rec.line_number 		:= rec.line_number;
	 l_newtx_rec.customer_id 		:= rec.customer_id;
	 l_newtx_rec.bill_to_address_id 	:= rec.bill_to_address_id;
	 l_newtx_rec.ship_to_address_id 	:= rec.ship_to_address_id;
	 l_newtx_rec.bill_to_contact_id 	:= rec.bill_to_contact_id;
	 l_newtx_rec.ship_to_contact_id 	:= rec.ship_to_contact_id;
	 l_newtx_rec.load_status 		:= 'UNLOADED';
	 l_newtx_rec.revenue_type 		:= rec.revenue_type;
	 l_newtx_rec.adjust_rollup_flag 	:= rec.adjust_rollup_flag;
	 l_newtx_rec.adjust_date 		:= rec.adjust_date;
	 l_newtx_rec.adjusted_by 		:= rec.adjusted_by;
	 l_newtx_rec.adjust_status 		:= NVL(p_adjust_status,'NEW');
	 l_newtx_rec.adjust_comments 		:= rec.adjust_comments;
	 l_newtx_rec.type 			:= rec.type;
	 l_newtx_rec.pre_processed_code 	:= rec.pre_processed_code;
	 l_newtx_rec.comp_group_id 		:= rec.comp_group_id;
	 l_newtx_rec.srp_plan_assign_id 	:= rec.srp_plan_assign_id;
	 l_newtx_rec.role_id 			:= rec.role_id;
	 l_newtx_rec.sales_channel 		:= rec.sales_channel;
	 l_newtx_rec.split_pct 			:= rec.split_pct;
	 l_newtx_rec.split_status 		:= rec.split_status;
	 l_newtx_rec.commission_amount 		:= rec.commission_amount;
         --

	 /* Added for crediting bug*/
	 l_newtx_rec.terr_id 		:= rec.terr_id;
	 l_newtx_rec.terr_name 		:= rec.terr_name;
	 l_newtx_rec.preserve_credit_override_flag 		:= NVL(rec.preserve_credit_override_flag,'N');

     --Added for Crediting bug
     IF(rec.terr_id IS NOT NULL)
     THEN
     l_newtx_rec.preserve_credit_override_flag 	:= 'Y';
     l_newtx_rec.terr_id := -999;
     END IF;


	 -- Update this record with new split information.
	 IF (p_called_from = 'MASS') THEN
	    l_newtx_rec.direct_salesrep_number	:= p_to_salesrep_number;
	    l_newtx_rec.direct_salesrep_id	:= p_to_salesrep_id;
	    l_newtx_rec.invoice_number 		:= rec.invoice_number;
	    l_newtx_rec.line_number 		:= rec.line_number;
	    l_newtx_rec.revenue_type		:= rec.revenue_type;
	    l_newtx_rec.split_pct 		:= rec.split_pct;
	    --
	    cn_get_tx_data_pub.insert_api_record(
   	       p_api_version		=> p_api_version,
	       p_init_msg_list		=> p_init_msg_list,
     	       p_validation_level	=> p_validation_level,
	       p_action			=> 'UPDATE',
	       p_newtx_rec		=> l_newtx_rec,
	       x_api_id			=> l_comm_lines_api_id,
	       x_return_status		=> x_return_status,
     	       x_msg_count		=> x_msg_count,
     	       x_msg_data		=> x_msg_data,
     	       x_loading_status		=> x_loading_status);
	    -- codeCheck: I need to handle the return_status
	 ELSE
	 FOR i IN p_new_data.FIRST..p_new_data.LAST
	 LOOP
	    l_newtx_rec.direct_salesrep_number	:= p_new_data(i).direct_salesrep_number;
	    l_newtx_rec.direct_salesrep_id	:= p_new_data(i).salesrep_id;
	    l_newtx_rec.invoice_number 		:= p_new_data(i).invoice_number;
	    l_newtx_rec.line_number 		:= p_new_data(i).line_number;
	    l_newtx_rec.revenue_type		:= p_new_data(i).revenue_type;
	    l_newtx_rec.split_pct 		:= p_new_data(i).split_pct;
	    -- Create a record in the cn_comm_lines_api table using this record.
	    IF (p_called_from = 'SPLIT') THEN
               l_newtx_rec.transaction_amount	:= ROUND((rec.transaction_amount*
	       					          p_new_data(i).split_pct)/100,2);
	    END IF;
	    cn_get_tx_data_pub.insert_api_record(
   	       p_api_version		=> p_api_version,
	       p_init_msg_list		=> p_init_msg_list,
     	       p_validation_level	=> p_validation_level,
	       p_action			=> 'UPDATE',
	       p_newtx_rec		=> l_newtx_rec,
	       x_api_id			=> l_comm_lines_api_id,
	       x_return_status		=> x_return_status,
     	       x_msg_count		=> x_msg_count,
     	       x_msg_data		=> x_msg_data,
     	       x_loading_status		=> x_loading_status);
	    --
         END LOOP;
	 END IF;

            /* Added for Crediting Bug */

            /*cn_get_tx_data_pub.update_credit_credentials(
            rec.comm_lines_api_id,
            rec.terr_id,
            rec.org_id,
            rec.adjusted_by
            );*/

	 --
      END LOOP;
      --
   END LOOP;
   -- Create new records in the same table.
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_credit_memo;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_credit_memo;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_credit_memo;
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
PROCEDURE update_mass_invoices (
	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
   	p_salesrep_id    	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
   	p_pr_date_to      	IN 	DATE 	:= FND_API.G_MISS_DATE,
   	p_pr_date_from    	IN  	DATE	:= FND_API.G_MISS_DATE,
   	p_calc_status  		IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_invoice_num     	IN  	VARCHAR2:= FND_API.G_MISS_CHAR,
   	p_order_num       	IN 	NUMBER	:= FND_API.G_MISS_NUM,
	p_srch_attr_rec		IN      cn_get_tx_data_pub.adj_rec_type,
   	p_to_salesrep_id	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
	p_to_salesrep_number	IN   	VARCHAR2:= FND_API.G_MISS_CHAR,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2,
	x_existing_data	 OUT NOCOPY invoice_tbl) IS
   --
   -- Local variables
   --
   l_api_name		CONSTANT VARCHAR2(30) := 'update_mass_invoices';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_api_query_flag	CHAR(1) := 'Y';
   l_sql		VARCHAR2(10000);
   l_handle		INTEGER;
   l_return		INTEGER;
   l_counter		NUMBER	:= 0;
   l_direct_salesrep_id	NUMBER;
   l_invoice_number	VARCHAR2(20);
   l_line_number	NUMBER;
   l_revenue_type	VARCHAR2(15);
   l_split_pct		NUMBER;
   l_salesrep_number	VARCHAR2(30);
   l_comm_lines_api_id	NUMBER;

   --Added for Crediting
   l_terr_id NUMBER;
   l_keep_flag VARCHAR2(1);
   -- PL/SQL tables and records
   l_existing_data	invoice_tbl;
   l_new_data		invoice_tbl;
   --l_invoice_tbl	invoice_tbl;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_mass_invoices;
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
   l_handle := DBMS_SQL.open_cursor;
   l_sql :=
      'SELECT '||
      'CCH.direct_salesrep_id,CCH.invoice_number,CCH.line_number, '||
      'CCH.revenue_type,CCH.split_pct,RSD.employee_number, CCH.comm_lines_api_id, '||
      --Modified for Crediting Bug
      'API.terr_id, NVL(API.preserve_credit_override_flag,''N'') '||
      'FROM cn_period_statuses CPSP, cn_salesreps RSD, cn_commission_headers CCH, '||
      'cn_lookups CLT, cn_lookups CLR, cn_lookups CLS, cn_lookups CLRV, '||
      'cn_lookups CLAD, cn_revenue_classes CNR, cn_quotas CQ, cn_trx_batches CTB, '||
      -- Modified for Crediting Bug
      'cn_comm_lines_api API '||
      'WHERE CCH.direct_salesrep_id = RSD.salesrep_id '||
      --Modified for Crediting Bug
      'AND CCH.comm_lines_api_id = API.comm_lines_api_id(+)'||
      'AND CCH.org_id = API.org_id(+)'||
      'AND CCH.processed_period_id = CPSP.period_id '||
      'AND CCH.status = CLS.lookup_code(+) '||
      'AND CLS.lookup_type (+)= ''TRX_STATUS'' '||
      'AND CCH.reason_code = CLR.lookup_code(+) '||
      'AND CLR.lookup_type (+)= ''ADJUSTMENT_REASON'' '||
      'AND CCH.trx_type = CLT.lookup_code(+) '||
      'AND CLT.lookup_type (+)= ''TRX TYPES'' '||
      'AND CCH.revenue_type = CLRV.lookup_code (+) '||
      'AND CLRV.lookup_type (+) = ''REVENUE_TYPE'' '||
      'AND CCH.adjust_status = CLAD.lookup_code (+) '||
      'AND CLAD.lookup_type (+) = ''ADJUST_STATUS'' '||
      'AND CCH.quota_id = CQ.quota_id(+) '||
      'AND CCH.revenue_class_id = CNR.revenue_class_id(+) '||
      'AND CCH.trx_batch_id = CTB.trx_batch_id(+) '||
      'AND CCH.trx_type = ''INV'' '||
      'AND ((CCH.adjust_status NOT IN (''REVERSAL'',''FROZEN'')) )';--||
--      'OR  (CCH.adjust_status IS NULL)) ';
   IF (p_salesrep_id <> FND_API.G_MISS_NUM) THEN
      l_sql := l_sql|| ' AND CCH.direct_salesrep_id = :p_salesrep_id';
   END IF;
   IF (p_pr_date_from <> FND_API.G_MISS_DATE) THEN
      l_sql := l_sql|| ' AND CCH.processed_date >= :p_pr_date_from';
   END IF;
   IF (p_pr_date_to <> FND_API.G_MISS_DATE) THEN
      l_sql := l_sql|| ' AND CCH.processed_date <= :p_pr_date_to';
   END IF;
   IF (p_invoice_num <> FND_API.G_MISS_CHAR) THEN
         l_sql := l_sql|| ' AND CCH.invoice_number LIKE :p_invoice_num';
   END IF;
   IF (p_order_num <> FND_API.G_MISS_NUM AND p_order_num <> 0) THEN
      l_sql := l_sql|| ' AND CCH.order_number = :p_order_num';
   END IF;
   IF (p_calc_status <> 'ALL') THEN
      l_sql := l_sql|| ' AND CCH.status = :p_calc_status';
      l_api_query_flag := 'N';
   END IF;

   --Added for Crediting
   l_terr_id := p_srch_attr_rec.terr_id;
   IF (l_terr_id = 0) THEN
      l_sql := l_sql|| ' AND API.terr_id IS NOT NULL';
   END IF;
   IF (l_terr_id = 1) THEN
      l_sql := l_sql|| ' AND API.terr_id IS NULL';
   END IF;

   l_keep_flag := NVL(p_srch_attr_rec.preserve_credit_override_flag,'N');
   IF (l_keep_flag <> FND_API.G_MISS_CHAR AND l_keep_flag IS NOT NULL) THEN
      l_sql := l_sql|| ' AND API.preserve_credit_override_flag = :l_keep_flag';
   END IF;

   l_sql := l_sql||' GROUP BY CCH.direct_salesrep_id, '||
                   'CCH.invoice_number,CCH.line_number, '||
                   'CCH.revenue_type,CCH.split_pct,RSD.employee_number, '||
		   'CCH.comm_lines_api_id ';
   IF (l_api_query_flag = 'Y') THEN
      l_sql := l_sql||' UNION ALL '||
      'SELECT CCLA.salesrep_id,CCLA.invoice_number,CCLA.line_number, '||
      'CCLA.revenue_type,CCLA.split_pct,RSD.employee_number, CCLA.comm_lines_api_id, '||
      --Modified for Crediting Bug
      'CCLA.terr_id, CCLA.preserve_credit_override_flag '||
      'FROM cn_comm_lines_api CCLA, '||
      'cn_period_statuses CPSP, cn_salesreps RSD, '||
      'cn_revenue_classes CNR, cn_lookups CLT, '||
      'cn_lookups CLRV, cn_lookups CLAD,cn_lookups CLR '||
      'WHERE RSD.salesrep_id = CCLA.salesrep_id '||
      'AND CCLA.processed_period_id = CPSP.period_id '||
      'AND CCLA.revenue_class_id = CNR.revenue_class_id(+) '||
      'AND CCLA.reason_code = CLR.lookup_code(+) '||
      'AND CLR.lookup_type (+)= ''ADJUSTMENT_REASON'' '||
      'AND CCLA.trx_type = CLT.lookup_code '||
      'AND CLT.lookup_type = ''TRX TYPES'' '||
      'AND CCLA.revenue_type = CLRV.lookup_code(+) '||
      'AND CLRV.lookup_type (+)= ''REVENUE_TYPE'' '||
      'AND CCLA.adjust_status = CLAD.lookup_code(+) '||
      'AND CLAD.lookup_type (+)= ''ADJUST_STATUS'' '||
      'AND nvl(CCLA.load_status,''X'') <> ''LOADED'' '||
      'AND CCLA.trx_type = ''INV'' '||
      'AND ((CCLA.adjust_status NOT IN (''REVERSAL'',''FROZEN'',''SCA_PENDING'')) )';--||
     -- 'OR  (CCLA.adjust_status IS NULL)) ';
      IF (p_salesrep_id <> FND_API.G_MISS_NUM) THEN
         l_sql := l_sql|| ' AND CCLA.salesrep_id = :p_salesrep_id';
      END IF;
      IF (p_pr_date_from <> FND_API.G_MISS_DATE) THEN
         l_sql := l_sql|| ' AND CCLA.processed_date >= :p_pr_date_from';
      END IF;
      IF (p_pr_date_to <> FND_API.G_MISS_DATE) THEN
         l_sql := l_sql|| ' AND CCLA.processed_date <= :p_pr_date_to';
      END IF;
      IF (p_invoice_num <> FND_API.G_MISS_CHAR) THEN
         l_sql := l_sql|| ' AND CCLA.invoice_number LIKE :p_invoice_num';
      END IF;
      IF (p_order_num <> FND_API.G_MISS_NUM AND p_order_num <> 0) THEN
         l_sql := l_sql|| ' AND CCLA.order_number = :p_order_num';
      END IF;

   --Added for Crediting
   l_terr_id := p_srch_attr_rec.terr_id;
   IF (l_terr_id = 0) THEN
      l_sql := l_sql|| ' AND CCLA.terr_id IS NOT NULL';
   END IF;
   IF (l_terr_id = 1) THEN
      l_sql := l_sql|| ' AND CCLA.terr_id IS NULL';
   END IF;

   l_keep_flag := NVL(p_srch_attr_rec.preserve_credit_override_flag,'N');
   IF (l_keep_flag <> FND_API.G_MISS_CHAR AND l_keep_flag IS NOT NULL) THEN
      l_sql := l_sql|| ' AND CCLA.preserve_credit_override_flag = :l_keep_flag';
   END IF;

      l_sql := l_sql||' GROUP BY CCLA.salesrep_id, '||
                      'CCLA.invoice_number,CCLA.line_number, '||
                      'CCLA.revenue_type,CCLA.split_pct,RSD.employee_number, '||
		      'CCLA.comm_lines_api_id ';
   END IF;
   --insert into rao_debug values(l_sql);
   --commit;
   DBMS_SQL.PARSE(l_handle,l_sql,DBMS_SQL.NATIVE);
   IF (p_salesrep_id <> FND_API.G_MISS_NUM) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_salesrep_id',p_salesrep_id);
   END IF;
   IF (p_pr_date_from <> FND_API.G_MISS_DATE) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_pr_date_from',p_pr_date_from);
   END IF;
   IF (p_pr_date_to <> FND_API.G_MISS_DATE) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_pr_date_to',p_pr_date_to);
   END IF;
   IF (p_invoice_num <> FND_API.G_MISS_CHAR) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_invoice_num',p_invoice_num);
   END IF;
   IF (p_order_num <> FND_API.G_MISS_NUM AND p_order_num <> 0) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_order_num',p_order_num);
   END IF;
   IF (p_calc_status <> 'ALL') THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'p_calc_status',p_calc_status);
   END IF;

-- Added for Crediting
   IF (l_keep_flag <> FND_API.G_MISS_CHAR AND l_keep_flag <> NULL) THEN
      DBMS_SQL.BIND_VARIABLE(l_handle,'l_keep_flag',l_keep_flag);
   END IF;


   DBMS_SQL.DEFINE_COLUMN (l_handle,1,l_direct_salesrep_id);
   DBMS_SQL.DEFINE_COLUMN (l_handle,2,l_invoice_number,20);
   DBMS_SQL.DEFINE_COLUMN (l_handle,3,l_line_number);
   DBMS_SQL.DEFINE_COLUMN (l_handle,4,l_revenue_type,15);
   DBMS_SQL.DEFINE_COLUMN (l_handle,5,l_split_pct);
   DBMS_SQL.DEFINE_COLUMN (l_handle,6,l_salesrep_number,30);
   DBMS_SQL.DEFINE_COLUMN (l_handle,7,l_comm_lines_api_id);
   l_return := DBMS_SQL.execute (l_handle);
   LOOP
      IF (dbms_sql.fetch_rows(l_handle) > 0) THEN
         l_counter := l_counter + 1;
         DBMS_SQL.COLUMN_VALUE (l_handle,1,l_direct_salesrep_id);
	 DBMS_SQL.COLUMN_VALUE (l_handle,2,l_invoice_number);
	 DBMS_SQL.COLUMN_VALUE (l_handle,3,l_line_number);
	 DBMS_SQL.COLUMN_VALUE (l_handle,4,l_revenue_type);
	 DBMS_SQL.COLUMN_VALUE (l_handle,5,l_split_pct);
	 DBMS_SQL.COLUMN_VALUE (l_handle,6,l_salesrep_number);
	 DBMS_SQL.COLUMN_VALUE (l_handle,7,l_comm_lines_api_id);
	 -- Creating a table of to-be-deleted records.
	 l_existing_data(l_counter).salesrep_id		:= l_direct_salesrep_id;
         l_existing_data(l_counter).invoice_number	:= l_invoice_number;
         l_existing_data(l_counter).line_number		:= l_line_number;
         l_existing_data(l_counter).revenue_type	:= l_revenue_type;
         l_existing_data(l_counter).split_pct		:= l_split_pct;
	 l_existing_data(l_counter).direct_salesrep_number
	 						:= l_salesrep_number;
	 l_existing_data(l_counter).comm_lines_api_id	:= l_comm_lines_api_id;
      ELSE
         EXIT;
      END IF;
   END LOOP;
   DBMS_SQL.close_cursor(l_handle);
   -- A dummy PL/SQL table need to be created with NULL values to make a
   -- call to update_invoice_changes procedure.
	 l_new_data(1).salesrep_id		:= NULL;
         l_new_data(1).invoice_number		:= NULL;
         l_new_data(1).line_number		:= NULL;
         l_new_data(1).revenue_type		:= NULL;
         l_new_data(1).split_pct		:= NULL;
	 l_new_data(1).direct_salesrep_number	:= NULL;
   IF ((l_existing_data.COUNT <> 0) AND (l_new_data.COUNT <> 0)) THEN
   cn_invoice_changes_pvt.update_invoice_changes(
   	p_api_version 		=> l_api_version,
	p_validation_level	=> p_validation_level,
   	p_existing_data		=> l_existing_data,
	p_new_data		=> l_new_data,
	p_exist_data_check	=> 'Y',
	p_new_data_check	=> 'N',
	x_return_status		=> x_return_status,
	x_msg_count		=> x_msg_count,
	x_msg_data		=> x_msg_data,
	x_loading_status	=> x_loading_status);
   END IF;
   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      FND_MESSAGE.Set_Name('CN', 'CN_UPD_INV_CHANGES');
      FND_MSG_PUB.Add;
      x_loading_status := 'CN_UPD_INV_CHANGES';
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   x_existing_data	:= l_existing_data;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO update_mass_invoices;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO update_mass_invoices;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO update_mass_invoices;
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
PROCEDURE capture_deal_invoice(
	p_api_version  		IN 	NUMBER,
   	p_init_msg_list         IN      VARCHAR2:= FND_API.G_TRUE,
   	p_validation_level      IN      VARCHAR2:= FND_API.G_VALID_LEVEL_FULL,
	p_trx_type		IN	VARCHAR2,
        p_split_nonrevenue_line IN	VARCHAR2,
	p_invoice_number	IN	VARCHAR2,
        p_org_id		IN	NUMBER,
        p_split_data_tbl	IN	cn_get_tx_data_pub.split_data_tbl,
	x_deal_data_tbl	 OUT NOCOPY cn_invoice_changes_pvt.deal_data_tbl,
	x_return_status         OUT NOCOPY     VARCHAR2,
   	x_msg_count             OUT NOCOPY     NUMBER,
   	x_msg_data              OUT NOCOPY     VARCHAR2,
   	x_loading_status        OUT NOCOPY     VARCHAR2) IS
CURSOR c1 IS
   SELECT comm_lines_api_id,
          invoice_number,
          line_number,
          revenue_type
     FROM cn_comm_lines_api_all api
    WHERE api.invoice_number = p_invoice_number
      AND api.trx_type = p_trx_type
      AND api.org_id = p_org_id
      AND api.load_status NOT IN ( 'LOADED', 'FILTERED') -- vensrini Buf fix 4202682
      AND (api.adjust_status NOT IN ('FROZEN','REVERSAL','SCA_PENDING'))-- OR
--           api.adjust_status IS NULL)
   UNION ALL
   SELECT comm_lines_api_id,
          invoice_number,
	  line_number,
	  revenue_type
     FROM cn_commission_headers_all ch
    WHERE ch.invoice_number = p_invoice_number
      AND ch.trx_type = p_trx_type
      AND ch.org_id = p_org_id
      AND (ch.adjust_status NOT IN ('FROZEN','REVERSAL')); -- OR
          -- ch.adjust_status IS NULL);
CURSOR c2 IS
   SELECT invoice_change_id, revenue_type
     FROM cn_invoice_changes
     WHERE invoice_number = p_invoice_number
     AND   org_id = p_org_id;  -- vensrini

--
   -- Local variables
   l_api_name		CONSTANT VARCHAR2(30) := 'capture_deal_invoice';
   l_api_version      	CONSTANT NUMBER := 1.0;
   l_invoice_change_id	NUMBER;
   l_counter		NUMBER	:= 0;
   -- PL/SQL tables and records
   l_insert_rec		cn_invoice_changes_pkg.invoice_changes_all_rec_type;
   --
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT capture_deal_invoice;
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
   IF ((g_track_invoice = 'Y') AND (p_trx_type = 'INV'))THEN
      FOR c2_rec IN c2
	LOOP
	   IF ((c2_rec.revenue_type = 'NONREVENUE') AND
	       (p_split_nonrevenue_line = 'N'))THEN
	      NULL;
	    ELSE
	      cn_invoice_changes_pkg.delete_row(c2_rec.invoice_change_id);
	   END IF;
	END LOOP;
   END IF;
   FOR c1_rec IN c1
   LOOP
      IF ((c1_rec.revenue_type = 'NONREVENUE') AND
	  (p_split_nonrevenue_line = 'N'))THEN
	 NULL;
       ELSE
	 l_counter := l_counter + 1;
	 x_deal_data_tbl(l_counter).comm_lines_api_id := c1_rec.comm_lines_api_id;
	 x_deal_data_tbl(l_counter).invoice_number := c1_rec.invoice_number;
	 x_deal_data_tbl(l_counter).line_number := c1_rec.line_number;
      END IF;

   END LOOP;
EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO capture_deal_invoice;
      x_return_status := FND_API.G_RET_STS_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data  ,
           p_encoded => FND_API.G_FALSE);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO capture_deal_invoice;
      x_loading_status := 'UNEXPECTED_ERR';
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      FND_MSG_PUB.Count_And_Get(
           p_count   =>  x_msg_count ,
           p_data    =>  x_msg_data   ,
           p_encoded => FND_API.G_FALSE);
   WHEN OTHERS THEN
      ROLLBACK TO capture_deal_invoice;
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
/*-----------------------------------------------------------------------------
   Batch Program Logic:
   o Collect the new invoices split information after collections get the data
     into cn_comm_lines_api table using cursor c1
   o Collect the new CMs matching with the stored invoice split data based on
     invoice/line/revenue type(group by) using cursor c2
   o Based on c2, collect the individual transactions from cn_comm_lines_api
     table (using api_cur) and NEGATE them.
   o Based on c2, collect the invoice split data from cn_invoice_changes table
     and recreate the new records in the cn_comm_lines_api table.
-----------------------------------------------------------------------------*/
PROCEDURE invoice_split_batch(
	x_errbuf 	 OUT NOCOPY 	VARCHAR2,
        x_retcode 	 OUT NOCOPY 	NUMBER) IS
--
CURSOR c1 IS
   SELECT api.comm_lines_api_id,
          api.salesrep_id,
   	  api.invoice_number,
	  api.line_number,
	  api.revenue_type,
	  api.split_pct
     FROM cn_comm_lines_api api
    WHERE trx_type = 'INV'
      AND load_status = 'UNLOADED'
      AND adjust_status ='NEW'; --IS NULL;
--      AND api.processed_date between SYSDATE-1 AND SYSDATE;
--
CURSOR c2(
	l_trx_type	VARCHAR2) IS
   SELECT api.invoice_number,
   	  api.line_number,
	  api.revenue_type,
	  sum(api.transaction_amount) transaction_amount
     FROM cn_comm_lines_api api
    WHERE EXISTS (
          SELECT 1
	    FROM cn_invoice_changes inv
           WHERE api.invoice_number 	= inv.invoice_number
             AND api.line_number	= inv.line_number
             AND api.revenue_type	= inv.revenue_type)
      AND (api.split_status NOT IN ('LINKED','DELINKED') OR
           api.split_status IS NULL)
      AND trx_type = l_trx_type
      AND adjust_status ='NEW' -- IS NULL
    GROUP BY api.invoice_number,
   	  api.line_number,
	  api.revenue_type;
--
CURSOR api_cur(
	l_invoice_number	VARCHAR2,
	l_line_number		NUMBER,
	l_revenue_type		VARCHAR2,
	l_trx_type		VARCHAR2) IS
   SELECT api.*
     FROM cn_comm_lines_api api
    WHERE api.invoice_number 	= l_invoice_number
      AND api.line_number	= l_line_number
      AND api.revenue_type	= l_revenue_type
      AND (api.split_status NOT IN ('LINKED','DELINKED') OR
           api.split_status IS NULL)
      AND trx_type = l_trx_type;
--
CURSOR inv_cur(
	l_invoice_number	VARCHAR2,
	l_line_number		NUMBER,
	l_revenue_type		VARCHAR2) IS
   SELECT inv.*,rep.employee_number
     FROM cn_invoice_changes inv,
          cn_salesreps rep
    WHERE inv.salesrep_id	= rep.salesrep_id
      AND inv.invoice_number 	= l_invoice_number
      AND inv.line_number	= l_line_number
      AND inv.revenue_type	= l_revenue_type;
--
   -- Local variables.
   l_invoice_change_id		NUMBER;
   l_counter			NUMBER		:= 0;
   l_negate_counter		NUMBER		:= 0;
   l_transaction_amount		NUMBER;
   l_create			VARCHAR(1)	:= 'N';
   l_comm_lines_api_id		NUMBER;
   l_adjust_comments		VARCHAR2(300);
   l_process_audit_id		cn_process_audits.process_audit_id%TYPE;
   l_trx_type			VARCHAR2(30);
   -- PL/SQL tables and records
   l_insert_rec			cn_invoice_changes_pkg.invoice_changes_all_rec_type;
   l_invoice_tbl		invoice_tbl;
   l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;
   l_adj_tbl			cn_get_tx_data_pub.adj_tbl_type;
   --
BEGIN
   --
   cn_message_pkg.begin_batch(
   	x_parent_proc_audit_id	=> NULL,
	x_process_audit_id	=> l_process_audit_id,
	x_request_id		=> fnd_global.conc_request_id,
	x_process_type		=> 'INVLOAD',
        p_org_id                => 204
        );
   --
   cn_message_pkg.write(
   	p_message_text	=> 'Starting Invoice Capture Batch Program',
	p_message_type	=> 'MILESTONE');
   --
   l_adjust_comments := 'Negated during Invoice Split Batch Program Execution';
   x_errbuf	:= '';
   x_retcode	:= 0;
   --
   cn_message_pkg.write(
   	p_message_text	=> 'Capturing New Invoices Cursor Start',
	p_message_type	=> 'MILESTONE');
   --
   IF (g_track_invoice = 'Y') THEN
   FOR c1_rec in c1
   LOOP
      --
      l_counter := l_counter + 1;
      --
      cn_message_pkg.write(
   	p_message_text	=> 'Record-'||l_counter||' '||
	                   'api_id:'||c1_rec.comm_lines_api_id||'; '||
	                   'rep:'||c1_rec.salesrep_id||'; '||
			   'invoice:'||c1_rec.invoice_number||'; '||
			   'line:'||c1_rec.line_number,
	p_message_type	=> 'MILESTONE');
      --
      SELECT cn_invoice_change_s.NEXTVAL
        INTO l_invoice_change_id
	FROM dual;
      --
      l_insert_rec.invoice_change_id	:= l_invoice_change_id;
      l_insert_rec.salesrep_id		:= c1_rec.salesrep_id;
      l_insert_rec.invoice_number	:= c1_rec.invoice_number;
      l_insert_rec.line_number		:= c1_rec.line_number;
      l_insert_rec.revenue_type		:= c1_rec.revenue_type;
      l_insert_rec.split_pct		:= c1_rec.split_pct;
      l_insert_rec.comm_lines_api_id	:= c1_rec.comm_lines_api_id;
      --
      cn_invoice_changes_pkg.insert_row(
	 p_invoice_changes_all_rec 	=> l_insert_rec);
      --
      UPDATE cn_comm_lines_api
         SET adjust_status = 'INVLOAD'
       WHERE comm_lines_api_id = c1_rec.comm_lines_api_id;
      --
   END LOOP;
   --
   cn_message_pkg.write(
   	p_message_text	=> 'Total Number Of New Invoices Captured: '||l_counter,
	p_message_type	=> 'MILESTONE');
   --
   FOR l_cm_pmt_count IN 1..2
   LOOP
      IF (l_cm_pmt_count = 1) THEN
         l_trx_type := 'CM';
      ELSE
         l_trx_type := 'PMT';
      END IF;
      l_counter 	:= 0;
      l_negate_counter	:= 0;
      --
      cn_message_pkg.write(
   	p_message_text	=> 'Capturing '||l_trx_type||' Cursor Start',
	p_message_type	=> 'MILESTONE');
      --
      FOR c2_rec IN c2(l_trx_type)
      LOOP
         FOR api_rec IN api_cur(c2_rec.invoice_number,
		       	        c2_rec.line_number,
			        c2_rec.revenue_type,
			        l_trx_type)
         LOOP
	    --
	    l_negate_counter := l_negate_counter + 1;
            --
      	    cn_message_pkg.write(
   		p_message_text	=>
		           'NEGATING '||l_trx_type||' : Record-'||l_negate_counter||' '||
	                   'api_id:'||api_rec.comm_lines_api_id||'; '||
	                   'rep:'||api_rec.salesrep_id||'; '||
			   'invoice:'||api_rec.invoice_number||'; '||
			   'line:'||api_rec.line_number,
		p_message_type	=> 'MILESTONE');
            --
            cn_adjustments_pkg.api_negate_record(
      		x_comm_lines_api_id 	=> api_rec.comm_lines_api_id,
		x_adjusted_by	    	=> get_adjusted_by,
		x_adjust_comments	=> l_adjust_comments);
         END LOOP;
         FOR inv_rec IN inv_cur(c2_rec.invoice_number,
		       	        c2_rec.line_number,
			        c2_rec.revenue_type)
         LOOP
         --
         l_counter := l_counter + 1;
         --
         cn_get_tx_data_pub.get_api_data(
   	 	p_comm_lines_api_id	=> inv_rec.comm_lines_api_id,
		x_adj_tbl		=> l_adj_tbl);
	 --
	 IF (l_adj_tbl.COUNT > 0) THEN
	    --
	    SELECT cn_comm_lines_api_s.NEXTVAL
     	      INTO l_comm_lines_api_id
              FROM sys.dual;
            --
	 l_api_rec.comm_lines_api_id 		:= l_comm_lines_api_id;
	 l_api_rec.salesrep_id			:= inv_rec.salesrep_id;
         l_api_rec.invoice_number		:= inv_rec.invoice_number;
         l_api_rec.line_number			:= inv_rec.line_number;
         l_api_rec.revenue_type			:= inv_rec.revenue_type;
	 l_api_rec.split_pct         		:= inv_rec.split_pct;
	 l_api_rec.employee_number   		:= inv_rec.employee_number;
	 l_api_rec.split_status      		:= 'LINKED';
	 l_api_rec.transaction_amount		:= c2_rec.transaction_amount*
	     				   	   (NVL(inv_rec.split_pct,0)/100);
         l_api_rec.adjust_status		:= 'SPLIT';
	 l_api_rec.load_status			:= 'UNLOADED';
	 l_api_rec.adj_comm_lines_api_id	:= NULL;
         l_api_rec.processed_date               := l_adj_tbl(1).processed_date;
         l_api_rec.processed_period_id          := l_adj_tbl(1).processed_period_id;
         l_api_rec.trx_type                	:= l_trx_type;
         l_api_rec.revenue_class_id             := l_adj_tbl(1).revenue_class_id;
         l_api_rec.attribute_category           := l_adj_tbl(1).attribute_category;
         l_api_rec.attribute1			:= l_adj_tbl(1).attribute1;
         l_api_rec.attribute2			:= l_adj_tbl(1).attribute2;
         l_api_rec.attribute3			:= l_adj_tbl(1).attribute3;
         l_api_rec.attribute4			:= l_adj_tbl(1).attribute4;
         l_api_rec.attribute5			:= l_adj_tbl(1).attribute5;
         l_api_rec.attribute6			:= l_adj_tbl(1).attribute6;
         l_api_rec.attribute7			:= l_adj_tbl(1).attribute7;
         l_api_rec.attribute8			:= l_adj_tbl(1).attribute8;
         l_api_rec.attribute9			:= l_adj_tbl(1).attribute9;
         l_api_rec.attribute10			:= l_adj_tbl(1).attribute10;
         l_api_rec.attribute11			:= l_adj_tbl(1).attribute11;
         l_api_rec.attribute12			:= l_adj_tbl(1).attribute12;
         l_api_rec.attribute13			:= l_adj_tbl(1).attribute13;
         l_api_rec.attribute14			:= l_adj_tbl(1).attribute14;
         l_api_rec.attribute15			:= l_adj_tbl(1).attribute15;
         l_api_rec.attribute16			:= l_adj_tbl(1).attribute16;
         l_api_rec.attribute17			:= l_adj_tbl(1).attribute17;
         l_api_rec.attribute18			:= l_adj_tbl(1).attribute18;
         l_api_rec.attribute19			:= l_adj_tbl(1).attribute19;
         l_api_rec.attribute20			:= l_adj_tbl(1).attribute20;
         l_api_rec.attribute21			:= l_adj_tbl(1).attribute21;
         l_api_rec.attribute22			:= l_adj_tbl(1).attribute22;
         l_api_rec.attribute23			:= l_adj_tbl(1).attribute23;
         l_api_rec.attribute24			:= l_adj_tbl(1).attribute24;
         l_api_rec.attribute25			:= l_adj_tbl(1).attribute25;
         l_api_rec.attribute26			:= l_adj_tbl(1).attribute26;
         l_api_rec.attribute27			:= l_adj_tbl(1).attribute27;
         l_api_rec.attribute28			:= l_adj_tbl(1).attribute28;
         l_api_rec.attribute29			:= l_adj_tbl(1).attribute29;
         l_api_rec.attribute30			:= l_adj_tbl(1).attribute30;
         l_api_rec.attribute31			:= l_adj_tbl(1).attribute31;
         l_api_rec.attribute32			:= l_adj_tbl(1).attribute32;
         l_api_rec.attribute33			:= l_adj_tbl(1).attribute33;
         l_api_rec.attribute34			:= l_adj_tbl(1).attribute34;
         l_api_rec.attribute35			:= l_adj_tbl(1).attribute35;
         l_api_rec.attribute36			:= l_adj_tbl(1).attribute36;
         l_api_rec.attribute37			:= l_adj_tbl(1).attribute37;
         l_api_rec.attribute38			:= l_adj_tbl(1).attribute38;
         l_api_rec.attribute39			:= l_adj_tbl(1).attribute39;
         l_api_rec.attribute40			:= l_adj_tbl(1).attribute40;
         l_api_rec.attribute41			:= l_adj_tbl(1).attribute41;
         l_api_rec.attribute42			:= l_adj_tbl(1).attribute42;
         l_api_rec.attribute43			:= l_adj_tbl(1).attribute43;
         l_api_rec.attribute44			:= l_adj_tbl(1).attribute44;
         l_api_rec.attribute45			:= l_adj_tbl(1).attribute45;
         l_api_rec.attribute46 			:= l_adj_tbl(1).attribute46;
         l_api_rec.attribute47 			:= l_adj_tbl(1).attribute47;
         l_api_rec.attribute48 			:= l_adj_tbl(1).attribute48;
         l_api_rec.attribute49 			:= l_adj_tbl(1).attribute49;
         l_api_rec.attribute50 			:= l_adj_tbl(1).attribute50;
         l_api_rec.attribute51 			:= l_adj_tbl(1).attribute51;
         l_api_rec.attribute52 			:= l_adj_tbl(1).attribute52;
         l_api_rec.attribute53 			:= l_adj_tbl(1).attribute53;
         l_api_rec.attribute54			:= l_adj_tbl(1).attribute54;
         l_api_rec.attribute55 			:= l_adj_tbl(1).attribute55;
         l_api_rec.attribute56 			:= l_adj_tbl(1).attribute56;
         l_api_rec.attribute57 			:= l_adj_tbl(1).attribute57;
         l_api_rec.attribute58 			:= l_adj_tbl(1).attribute58;
         l_api_rec.attribute59 			:= l_adj_tbl(1).attribute59;
         l_api_rec.attribute60 			:= l_adj_tbl(1).attribute60;
         l_api_rec.attribute61 			:= l_adj_tbl(1).attribute61;
         l_api_rec.attribute62 			:= l_adj_tbl(1).attribute62;
         l_api_rec.attribute63 			:= l_adj_tbl(1).attribute63;
         l_api_rec.attribute64 			:= l_adj_tbl(1).attribute64;
         l_api_rec.attribute65  		:= l_adj_tbl(1).attribute65;
         l_api_rec.attribute66  		:= l_adj_tbl(1).attribute66;
         l_api_rec.attribute67  		:= l_adj_tbl(1).attribute67;
         l_api_rec.attribute68  		:= l_adj_tbl(1).attribute68;
         l_api_rec.attribute69  		:= l_adj_tbl(1).attribute69;
         l_api_rec.attribute70  		:= l_adj_tbl(1).attribute70;
         l_api_rec.attribute71  		:= l_adj_tbl(1).attribute71;
         l_api_rec.attribute72  		:= l_adj_tbl(1).attribute72;
         l_api_rec.attribute73 			:= l_adj_tbl(1).attribute73;
         l_api_rec.attribute74 			:= l_adj_tbl(1).attribute74;
         l_api_rec.attribute75  		:= l_adj_tbl(1).attribute75;
         l_api_rec.attribute76 			:= l_adj_tbl(1).attribute76;
         l_api_rec.attribute77 			:= l_adj_tbl(1).attribute77;
         l_api_rec.attribute78  		:= l_adj_tbl(1).attribute78;
         l_api_rec.attribute79 			:= l_adj_tbl(1).attribute79;
         l_api_rec.attribute80 			:= l_adj_tbl(1).attribute80;
         l_api_rec.attribute81 			:= l_adj_tbl(1).attribute81;
         l_api_rec.attribute82 			:= l_adj_tbl(1).attribute82;
         l_api_rec.attribute83 			:= l_adj_tbl(1).attribute83;
         l_api_rec.attribute84 			:= l_adj_tbl(1).attribute84;
         l_api_rec.attribute85 			:= l_adj_tbl(1).attribute85;
         l_api_rec.attribute86 			:= l_adj_tbl(1).attribute86;
         l_api_rec.attribute87 			:= l_adj_tbl(1).attribute87;
         l_api_rec.attribute88  		:= l_adj_tbl(1).attribute88;
         l_api_rec.attribute89  		:= l_adj_tbl(1).attribute89;
         l_api_rec.attribute90  		:= l_adj_tbl(1).attribute90;
         l_api_rec.attribute91  		:= l_adj_tbl(1).attribute91;
         l_api_rec.attribute92  		:= l_adj_tbl(1).attribute92;
         l_api_rec.attribute93  		:= l_adj_tbl(1).attribute93;
         l_api_rec.attribute94  		:= l_adj_tbl(1).attribute94;
         l_api_rec.attribute95  		:= l_adj_tbl(1).attribute95;
         l_api_rec.attribute96 			:= l_adj_tbl(1).attribute96;
         l_api_rec.attribute97 			:= l_adj_tbl(1).attribute97;
         l_api_rec.attribute98 			:= l_adj_tbl(1).attribute98;
         l_api_rec.attribute99  		:= l_adj_tbl(1).attribute99;
         l_api_rec.attribute100 		:= l_adj_tbl(1).attribute100;
         l_api_rec.rollup_date                  := l_adj_tbl(1).rollup_date;
         l_api_rec.source_doc_type              := l_adj_tbl(1).source_doc_type;
         l_api_rec.transaction_currency_code    := l_adj_tbl(1).orig_currency_code;
         l_api_rec.exchange_rate                := l_adj_tbl(1).exchange_rate;
         l_api_rec.trx_id                	:= l_adj_tbl(1).trx_id;
         l_api_rec.trx_line_id                	:= l_adj_tbl(1).trx_line_id;
         l_api_rec.trx_sales_line_id            := l_adj_tbl(1).trx_sales_line_id;
         l_api_rec.quantity                	:= l_adj_tbl(1).quantity;
         l_api_rec.source_trx_number            := l_adj_tbl(1).source_trx_number;
         l_api_rec.discount_percentage          := l_adj_tbl(1).discount_percentage;
         l_api_rec.margin_percentage            := l_adj_tbl(1).margin_percentage;
         l_api_rec.customer_id                	:= l_adj_tbl(1).customer_id;
         l_api_rec.order_number                 := l_adj_tbl(1).order_number;
         l_api_rec.booked_date                 	:= l_adj_tbl(1).order_date;
         l_api_rec.invoice_date                	:= l_adj_tbl(1).invoice_date;
         l_api_rec.adjust_date                	:= SYSDATE;
         l_api_rec.adjusted_by                	:= get_adjusted_by;
         l_api_rec.adjust_rollup_flag       	:= l_adj_tbl(1).adjust_rollup_flag;
         l_api_rec.adjust_comments          	:= l_adj_tbl(1).adjust_comments;
         l_api_rec.bill_to_address_id       	:= l_adj_tbl(1).bill_to_address_id;
         l_api_rec.ship_to_address_id        	:= l_adj_tbl(1).ship_to_address_id;
         l_api_rec.bill_to_contact_id         	:= l_adj_tbl(1).bill_to_contact_id;
         l_api_rec.ship_to_contact_id       	:= l_adj_tbl(1).ship_to_contact_id;
         l_api_rec.forecast_id                	:= l_adj_tbl(1).forecast_id;
         l_api_rec.upside_quantity           	:= l_adj_tbl(1).upside_quantity;
         l_api_rec.upside_amount                := l_adj_tbl(1).upside_amount;
         l_api_rec.uom_code                	:= l_adj_tbl(1).uom_code;
         l_api_rec.reason_code                	:= l_adj_tbl(1).reason_code;
         l_api_rec.type                		:= l_adj_tbl(1).type;
         l_api_rec.pre_processed_code      	:= l_adj_tbl(1).pre_processed_code;
         l_api_rec.quota_id                	:= l_adj_tbl(1).quota_id;
         l_api_rec.srp_plan_assign_id          	:= l_adj_tbl(1).srp_plan_assign_id;
         l_api_rec.role_id                	:= l_adj_tbl(1).role_id;
         l_api_rec.comp_group_id                := l_adj_tbl(1).comp_group_id;
         l_api_rec.commission_amount       	:= l_adj_tbl(1).commission_amount;
         l_api_rec.sales_channel                := l_adj_tbl(1).sales_channel;
	 --
	 cn_comm_lines_api_pkg.insert_row(l_api_rec);
	 --
      	 cn_message_pkg.write(
   	    p_message_text =>
		'Creating '||l_trx_type||' : Record-'||l_counter||' '||
	        'api_id:'||l_comm_lines_api_id,
	    p_message_type => 'MILESTONE');
	 END IF;
         END LOOP;
      END LOOP;
      --
      cn_message_pkg.write(
   	p_message_text	=> 'Total Records Negated for '||
	                    l_trx_type ||':'||l_negate_counter,
	p_message_type	=> 'MILESTONE');
      --
      cn_message_pkg.write(
   	p_message_text	=> 'Total Number Of New '||l_trx_type||
			   ' Created:'||l_counter,
	p_message_type	=> 'MILESTONE');
      --
   END LOOP;
   END IF;
   --
   cn_message_pkg.write(
   	p_message_text	=> 'Ending Invoice Capture Batch Program',
	p_message_type	=> 'MILESTONE');
   --
   cn_message_pkg.end_batch(
	x_process_audit_id	=> l_process_audit_id);
   --
EXCEPTION
   WHEN OTHERS THEN
      --
      ROLLBACK;
      --
      cn_message_pkg.write(
   	p_message_text	=> 'Error Occured In The Batch Process',
	p_message_type	=> 'ERROR');
      --
      cn_message_pkg.write(
   	p_message_text	=> SQLERRM,
	p_message_type	=> 'ERROR');
      --
      x_errbuf	:= 'ERROR';
      x_retcode	:= 1;
      --
      cn_message_pkg.end_batch(
	x_process_audit_id	=> l_process_audit_id);
      --
END;
--
END;


/
