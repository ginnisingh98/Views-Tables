--------------------------------------------------------
--  DDL for Package Body CN_MASS_ADJUST_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_MASS_ADJUST_UTIL" AS
-- $Header: cnvmutlb.pls 120.12.12010000.7 2009/06/03 12:20:49 ppillai ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   CN_MASS_ADJUST_UTIL
-- Purpose
--   Package Body for Mass Adjustments Package
-- History
--   10/27/03   Hithanki    R12 Version
--
--   Nov 10, 2005  vensrini  Added org_id join condition
--                           to l_header_sql and l_api_sql dynamic sql
--   Nov 14, 2005  vensrini  Removed commented out portion in
--                           convert_rec_to_gmiss procedure
--   Jun 26, 2006  vensrinin Bug fix 5349170
--
--
--



   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_MASS_ADJUST_UTIL';
   G_FILE_NAME                 	CONSTANT VARCHAR2(12) := 'cnvmutlb.pls';
   g_space						VARCHAR2(10) := '&'||'nbsp;';

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
PROCEDURE  find_functional_amount(
   p_from_currency	IN 	VARCHAR2,
   p_to_currency	IN	VARCHAR2,
   p_conversion_date	IN	DATE,
   p_conversion_type	IN 	VARCHAR2,
   p_from_amount	IN	NUMBER,
   x_to_amount	 OUT NOCOPY NUMBER,
   x_return_status      OUT NOCOPY     VARCHAR2) IS
   -- Local variables
   l_conversion_date		DATE;
   l_check_max			CHAR(1) := 'Y';

--
CURSOR c1 IS
   SELECT conversion_date
     FROM gl_daily_rates
    WHERE from_currency 	= p_from_currency
      AND to_currency		= p_to_currency
      AND conversion_type	= p_conversion_type
      AND conversion_date	= p_conversion_date
      AND rownum		< 2
    ORDER BY conversion_date DESC;
CURSOR c2 IS
   SELECT MAX(conversion_date) conversion_date
     FROM gl_daily_rates
    WHERE from_currency 	= p_from_currency
      AND to_currency		= p_to_currency
      AND conversion_type	= p_conversion_type
      AND conversion_date	< p_conversion_date;
--
BEGIN
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   FOR rec IN c1
   LOOP
      l_conversion_date := rec.conversion_date;
      l_check_max := 'N';
   END LOOP;
   IF (l_check_max = 'Y') THEN
      FOR rec IN c2
      LOOP
         IF (rec.conversion_date IS NOT NULL) THEN
            l_conversion_date := rec.conversion_date;
            l_check_max := 'N';
	 END IF;
      END LOOP;
   END IF;
   IF (l_check_max = 'Y') THEN
      RAISE NO_DATA_FOUND;
   ELSE
      x_to_amount :=
      gl_currency_api.convert_amount(
         x_from_currency 	=> p_from_currency,
         x_to_currency   	=> p_to_currency,
         x_conversion_date 	=> l_conversion_date,
         x_conversion_type 	=> p_conversion_type,
         x_amount        	=> p_from_amount);
      x_return_status := 'SUCCESS';
   END IF;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
      x_to_amount := 0;
      x_return_status := 'NO DATA';
   WHEN OTHERS THEN
      x_to_amount := 0;
      x_return_status := 'ERROR';
END find_functional_amount;
--
PROCEDURE search_result (
   p_salesrep_id    	IN   	NUMBER 	:= FND_API.G_MISS_NUM,
   p_pr_date_to      	IN 	DATE 	:= FND_API.G_MISS_DATE,
   p_pr_date_from    	IN  	DATE	:= FND_API.G_MISS_DATE,
   p_calc_status  	IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   p_adj_status  	IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   p_load_status  	IN 	VARCHAR2:= FND_API.G_MISS_CHAR,
   p_invoice_num     	IN  	VARCHAR2:= FND_API.G_MISS_CHAR,
   p_order_num       	IN 	NUMBER	:= FND_API.G_MISS_NUM,
   p_org_id		IN	NUMBER 	:= FND_API.G_MISS_NUM,
   p_srch_attr_rec      IN      cn_get_tx_data_pub.adj_rec_type,
   x_return_status     OUT NOCOPY  	VARCHAR2,
   x_adj_tbl           OUT NOCOPY  	cn_get_tx_data_pub.adj_tbl_type,
   x_source_counter    OUT NOCOPY 	NUMBER) IS
--
   TYPE api_rec IS RECORD(
      salesrep_id		cn_comm_lines_api.salesrep_id%TYPE,
      processed_date		cn_comm_lines_api.processed_date%TYPE,
      processed_period_id	cn_comm_lines_api.processed_period_id%TYPE,
      transaction_amount	cn_comm_lines_api.transaction_amount%TYPE,
      trx_type			cn_comm_lines_api.trx_type%TYPE,
      revenue_class_id		cn_comm_lines_api.revenue_class_id%TYPE,
      load_status		cn_comm_lines_api.load_status%TYPE,
      attribute_category	cn_comm_lines_api.attribute_category%TYPE,
      attribute1		cn_comm_lines_api.attribute1%TYPE,
      attribute2		cn_comm_lines_api.attribute2%TYPE,
      attribute3		cn_comm_lines_api.attribute3%TYPE,
      attribute4		cn_comm_lines_api.attribute4%TYPE,
      attribute5		cn_comm_lines_api.attribute5%TYPE,
      attribute6		cn_comm_lines_api.attribute6%TYPE,
      attribute7		cn_comm_lines_api.attribute7%TYPE,
      attribute8		cn_comm_lines_api.attribute8%TYPE,
      attribute9		cn_comm_lines_api.attribute9%TYPE,
      attribute10		cn_comm_lines_api.attribute10%TYPE,
      attribute11		cn_comm_lines_api.attribute11%TYPE,
      attribute12		cn_comm_lines_api.attribute12%TYPE,
      attribute13		cn_comm_lines_api.attribute13%TYPE,
      attribute14		cn_comm_lines_api.attribute14%TYPE,
      attribute15		cn_comm_lines_api.attribute15%TYPE,
      attribute16		cn_comm_lines_api.attribute16%TYPE,
      attribute17		cn_comm_lines_api.attribute17%TYPE,
      attribute18		cn_comm_lines_api.attribute18%TYPE,
      attribute19		cn_comm_lines_api.attribute19%TYPE,
      attribute20		cn_comm_lines_api.attribute20%TYPE,
      attribute21		cn_comm_lines_api.attribute21%TYPE,
      attribute22		cn_comm_lines_api.attribute22%TYPE,
      attribute23		cn_comm_lines_api.attribute23%TYPE,
      attribute24		cn_comm_lines_api.attribute24%TYPE,
      attribute25		cn_comm_lines_api.attribute25%TYPE,
      attribute26		cn_comm_lines_api.attribute26%TYPE,
      attribute27		cn_comm_lines_api.attribute27%TYPE,
      attribute28		cn_comm_lines_api.attribute28%TYPE,
      attribute29		cn_comm_lines_api.attribute29%TYPE,
      attribute30		cn_comm_lines_api.attribute30%TYPE,
      attribute31		cn_comm_lines_api.attribute31%TYPE,
      attribute32		cn_comm_lines_api.attribute32%TYPE,
      attribute33		cn_comm_lines_api.attribute33%TYPE,
      attribute34		cn_comm_lines_api.attribute34%TYPE,
      attribute35		cn_comm_lines_api.attribute35%TYPE,
      attribute36		cn_comm_lines_api.attribute36%TYPE,
      attribute37		cn_comm_lines_api.attribute37%TYPE,
      attribute38		cn_comm_lines_api.attribute38%TYPE,
      attribute39		cn_comm_lines_api.attribute39%TYPE,
      attribute40		cn_comm_lines_api.attribute40%TYPE,
      attribute41		cn_comm_lines_api.attribute41%TYPE,
      attribute42		cn_comm_lines_api.attribute42%TYPE,
      attribute43		cn_comm_lines_api.attribute43%TYPE,
      attribute44		cn_comm_lines_api.attribute44%TYPE,
      attribute45		cn_comm_lines_api.attribute45%TYPE,
      attribute46		cn_comm_lines_api.attribute46%TYPE,
      attribute47		cn_comm_lines_api.attribute47%TYPE,
      attribute48		cn_comm_lines_api.attribute48%TYPE,
      attribute49		cn_comm_lines_api.attribute49%TYPE,
      attribute50		cn_comm_lines_api.attribute50%TYPE,
      attribute51		cn_comm_lines_api.attribute51%TYPE,
      attribute52		cn_comm_lines_api.attribute52%TYPE,
      attribute53		cn_comm_lines_api.attribute53%TYPE,
      attribute54		cn_comm_lines_api.attribute54%TYPE,
      attribute55		cn_comm_lines_api.attribute55%TYPE,
      attribute56		cn_comm_lines_api.attribute56%TYPE,
      attribute57		cn_comm_lines_api.attribute57%TYPE,
      attribute58		cn_comm_lines_api.attribute58%TYPE,
      attribute59		cn_comm_lines_api.attribute59%TYPE,
      attribute60		cn_comm_lines_api.attribute60%TYPE,
      attribute61		cn_comm_lines_api.attribute61%TYPE,
      attribute62		cn_comm_lines_api.attribute62%TYPE,
      attribute63		cn_comm_lines_api.attribute63%TYPE,
      attribute64		cn_comm_lines_api.attribute64%TYPE,
      attribute65		cn_comm_lines_api.attribute65%TYPE,
      attribute66		cn_comm_lines_api.attribute66%TYPE,
      attribute67		cn_comm_lines_api.attribute67%TYPE,
      attribute68		cn_comm_lines_api.attribute68%TYPE,
      attribute69		cn_comm_lines_api.attribute69%TYPE,
      attribute70		cn_comm_lines_api.attribute70%TYPE,
      attribute71		cn_comm_lines_api.attribute71%TYPE,
      attribute72		cn_comm_lines_api.attribute72%TYPE,
      attribute73		cn_comm_lines_api.attribute73%TYPE,
      attribute74		cn_comm_lines_api.attribute74%TYPE,
      attribute75		cn_comm_lines_api.attribute75%TYPE,
      attribute76		cn_comm_lines_api.attribute76%TYPE,
      attribute77		cn_comm_lines_api.attribute77%TYPE,
      attribute78		cn_comm_lines_api.attribute78%TYPE,
      attribute79		cn_comm_lines_api.attribute79%TYPE,
      attribute80		cn_comm_lines_api.attribute80%TYPE,
      attribute81		cn_comm_lines_api.attribute81%TYPE,
      attribute82		cn_comm_lines_api.attribute82%TYPE,
      attribute83		cn_comm_lines_api.attribute83%TYPE,
      attribute84		cn_comm_lines_api.attribute84%TYPE,
      attribute85		cn_comm_lines_api.attribute85%TYPE,
      attribute86		cn_comm_lines_api.attribute86%TYPE,
      attribute87		cn_comm_lines_api.attribute87%TYPE,
      attribute88		cn_comm_lines_api.attribute88%TYPE,
      attribute89		cn_comm_lines_api.attribute89%TYPE,
      attribute90		cn_comm_lines_api.attribute90%TYPE,
      attribute91		cn_comm_lines_api.attribute91%TYPE,
      attribute92		cn_comm_lines_api.attribute92%TYPE,
      attribute93		cn_comm_lines_api.attribute93%TYPE,
      attribute94		cn_comm_lines_api.attribute94%TYPE,
      attribute95		cn_comm_lines_api.attribute95%TYPE,
      attribute96		cn_comm_lines_api.attribute96%TYPE,
      attribute97		cn_comm_lines_api.attribute97%TYPE,
      attribute98		cn_comm_lines_api.attribute98%TYPE,
      attribute99		cn_comm_lines_api.attribute99%TYPE,
      attribute100		cn_comm_lines_api.attribute100%TYPE,
      comm_lines_api_id		cn_comm_lines_api.comm_lines_api_id%TYPE,
      conc_batch_id		cn_comm_lines_api.conc_batch_id%TYPE,
      process_batch_id		cn_comm_lines_api.process_batch_id%TYPE,
      salesrep_number		cn_comm_lines_api.salesrep_number%TYPE,
      rollup_date 		cn_comm_lines_api.rollup_date%TYPE,
      source_doc_id		cn_comm_lines_api.source_doc_id%TYPE,
      source_doc_type		cn_comm_lines_api.source_doc_type%TYPE,
      created_by 		cn_comm_lines_api.created_by%TYPE,
      creation_date		cn_comm_lines_api.creation_date%TYPE,
      last_updated_by		cn_comm_lines_api.last_updated_by%TYPE,
      last_update_date		cn_comm_lines_api.last_update_date%TYPE,
      last_update_login		cn_comm_lines_api.last_update_login%TYPE,
      transaction_currency_code	cn_comm_lines_api.transaction_currency_code%TYPE,
      exchange_rate		cn_comm_lines_api.exchange_rate%TYPE,
      acctd_transaction_amount	cn_comm_lines_api.acctd_transaction_amount%TYPE,
      trx_id   			cn_comm_lines_api.trx_id%TYPE,
      trx_line_id		cn_comm_lines_api.trx_line_id%TYPE,
      trx_sales_line_id 	cn_comm_lines_api.trx_sales_line_id%TYPE,
      org_id          		cn_comm_lines_api.org_id%TYPE,
      quantity         		cn_comm_lines_api.quantity%TYPE,
      source_trx_number 	cn_comm_lines_api.source_trx_number%TYPE,
      discount_percentage	cn_comm_lines_api.discount_percentage%TYPE,
      margin_percentage    	cn_comm_lines_api.margin_percentage%TYPE,
      source_trx_id    		cn_comm_lines_api.source_trx_id%TYPE,
      source_trx_line_id  	cn_comm_lines_api.source_trx_line_id%TYPE,
      source_trx_sales_line_id  cn_comm_lines_api.source_trx_sales_line_id%TYPE,
      negated_flag    		cn_comm_lines_api.negated_flag%TYPE,
      customer_id     		cn_comm_lines_api.customer_id%TYPE,
      inventory_item_id 	cn_comm_lines_api.inventory_item_id%TYPE,
      order_number    		cn_comm_lines_api.order_number%TYPE,
      booked_date     		cn_comm_lines_api.booked_date%TYPE,
      invoice_number  		cn_comm_lines_api.invoice_number%TYPE,
      invoice_date    		cn_comm_lines_api.invoice_date%TYPE,
      adjust_date    		cn_comm_lines_api.adjust_date%TYPE,
      adjusted_by    		cn_comm_lines_api.adjusted_by%TYPE,
      revenue_type   		cn_comm_lines_api.revenue_type%TYPE,
      adjust_rollup_flag 	cn_comm_lines_api.adjust_rollup_flag%TYPE,
      adjust_comments    	cn_comm_lines_api.adjust_comments%TYPE,
      adjust_status     	cn_comm_lines_api.adjust_status%TYPE,
      line_number       	cn_comm_lines_api.line_number%TYPE,
      bill_to_address_id 	cn_comm_lines_api.bill_to_address_id%TYPE,
      ship_to_address_id 	cn_comm_lines_api.ship_to_address_id%TYPE,
      bill_to_contact_id  	cn_comm_lines_api.bill_to_contact_id%TYPE,
      ship_to_contact_id 	cn_comm_lines_api.ship_to_contact_id%TYPE,
      adj_comm_lines_api_id  	cn_comm_lines_api.adj_comm_lines_api_id%TYPE,
      pre_defined_rc_flag	cn_comm_lines_api.pre_defined_rc_flag%TYPE,
      rollup_flag     		cn_comm_lines_api.rollup_flag%TYPE,
      forecast_id      		cn_comm_lines_api.forecast_id%TYPE,
      upside_quantity   	cn_comm_lines_api.upside_quantity%TYPE,
      upside_amount     	cn_comm_lines_api.upside_amount%TYPE,
      uom_code          	cn_comm_lines_api.uom_code%TYPE,
      reason_code        	cn_comm_lines_api.reason_code%TYPE,
      type               	cn_comm_lines_api.type%TYPE,
      pre_processed_code  	cn_comm_lines_api.pre_processed_code%TYPE,
      quota_id            	cn_comm_lines_api.quota_id%TYPE,
      srp_plan_assign_id  	cn_comm_lines_api.srp_plan_assign_id%TYPE,
      role_id            	cn_comm_lines_api.role_id%TYPE,
      comp_group_id      	cn_comm_lines_api.comp_group_id%TYPE,
      commission_amount   	cn_comm_lines_api.commission_amount%TYPE,
      employee_number     	cn_comm_lines_api.employee_number%TYPE,
      reversal_flag       	cn_comm_lines_api.reversal_flag%TYPE,
      reversal_header_id 	cn_comm_lines_api.reversal_header_id%TYPE,
      sales_channel       	cn_comm_lines_api.sales_channel%TYPE,
      object_version_number 	cn_comm_lines_api.object_version_number%TYPE,
      split_pct			cn_comm_lines_api.split_pct%TYPE,
      split_status		cn_comm_lines_api.split_status%TYPE,
      direct_salesrep_number	cn_salesreps.employee_number%TYPE,
      direct_salesrep_name	cn_salesreps.name%TYPE,
      period_name		cn_period_statuses.period_name%TYPE,
      trx_type_disp		cn_lookups.meaning%TYPE,
      reason			cn_lookups.meaning%TYPE,
      revenue_class_name       	cn_revenue_classes.name%TYPE,
      revenue_type_disp		cn_lookups.meaning%TYPE,
      adjust_status_disp	cn_lookups.meaning%TYPE,
      terr_id               cn_comm_lines_api.terr_id%TYPE,
      preserve_credit_override_flag    cn_comm_lines_api.preserve_credit_override_flag%TYPE);
   l_api_rec		api_rec;

   TYPE header_rec IS RECORD(
      commission_header_id	cn_commission_headers.commission_header_id%TYPE,
      direct_salesrep_id	cn_commission_headers.direct_salesrep_id%TYPE,
      processed_date		cn_commission_headers.processed_date%TYPE,
      processed_period_id	cn_commission_headers.processed_period_id%TYPE,
      rollup_date		cn_commission_headers.rollup_date%TYPE,
      transaction_amount	cn_commission_headers.transaction_amount%TYPE,
      quantity			cn_commission_headers.quantity%TYPE,
      discount_percentage	cn_commission_headers.discount_percentage%TYPE,
      margin_percentage    	cn_commission_headers.margin_percentage%TYPE,
      orig_currency_code	cn_commission_headers.orig_currency_code%TYPE,
      transaction_amount_orig	cn_commission_headers.transaction_amount_orig%TYPE,
      trx_type			cn_commission_headers.trx_type%TYPE,
      status			cn_commission_headers.status%TYPE,
      pre_processed_code	cn_commission_headers.pre_processed_code%TYPE,
      comm_lines_api_id		cn_commission_headers.comm_lines_api_id%TYPE,
      source_doc_type		cn_commission_headers.source_doc_type%TYPE,
      source_trx_number		cn_commission_headers.source_trx_number%TYPE,
      quota_id            	cn_commission_headers.quota_id%TYPE,
      srp_plan_assign_id  	cn_commission_headers.srp_plan_assign_id%TYPE,
      revenue_class_id		cn_commission_headers.revenue_class_id%TYPE,
      role_id			cn_commission_headers.role_id%TYPE,
      comp_group_id		cn_commission_headers.comp_group_id%TYPE,
      commission_amount		cn_commission_headers.commission_amount%TYPE,
      trx_batch_id		cn_commission_headers.trx_batch_id%TYPE,
      reversal_flag		cn_commission_headers.reversal_flag%TYPE,
      reversal_header_id	cn_commission_headers.reversal_header_id%TYPE,
      reason_code		cn_commission_headers.reason_code%TYPE,
      comments			cn_commission_headers.comments%TYPE,
      attribute_category	cn_commission_headers.attribute_category%TYPE,
      attribute1		cn_commission_headers.attribute1%TYPE,
      attribute2		cn_commission_headers.attribute2%TYPE,
      attribute3		cn_commission_headers.attribute3%TYPE,
      attribute4		cn_commission_headers.attribute4%TYPE,
      attribute5		cn_commission_headers.attribute5%TYPE,
      attribute6		cn_commission_headers.attribute6%TYPE,
      attribute7		cn_commission_headers.attribute7%TYPE,
      attribute8		cn_commission_headers.attribute8%TYPE,
      attribute9		cn_commission_headers.attribute9%TYPE,
      attribute10		cn_commission_headers.attribute10%TYPE,
      attribute11		cn_commission_headers.attribute11%TYPE,
      attribute12		cn_commission_headers.attribute12%TYPE,
      attribute13		cn_commission_headers.attribute13%TYPE,
      attribute14		cn_commission_headers.attribute14%TYPE,
      attribute15		cn_commission_headers.attribute15%TYPE,
      attribute16		cn_commission_headers.attribute16%TYPE,
      attribute17		cn_commission_headers.attribute17%TYPE,
      attribute18		cn_commission_headers.attribute18%TYPE,
      attribute19		cn_commission_headers.attribute19%TYPE,
      attribute20		cn_commission_headers.attribute20%TYPE,
      attribute21		cn_commission_headers.attribute21%TYPE,
      attribute22		cn_commission_headers.attribute22%TYPE,
      attribute23		cn_commission_headers.attribute23%TYPE,
      attribute24		cn_commission_headers.attribute24%TYPE,
      attribute25		cn_commission_headers.attribute25%TYPE,
      attribute26		cn_commission_headers.attribute26%TYPE,
      attribute27		cn_commission_headers.attribute27%TYPE,
      attribute28		cn_commission_headers.attribute28%TYPE,
      attribute29		cn_commission_headers.attribute29%TYPE,
      attribute30		cn_commission_headers.attribute30%TYPE,
      attribute31		cn_commission_headers.attribute31%TYPE,
      attribute32		cn_commission_headers.attribute32%TYPE,
      attribute33		cn_commission_headers.attribute33%TYPE,
      attribute34		cn_commission_headers.attribute34%TYPE,
      attribute35		cn_commission_headers.attribute35%TYPE,
      attribute36		cn_commission_headers.attribute36%TYPE,
      attribute37		cn_commission_headers.attribute37%TYPE,
      attribute38		cn_commission_headers.attribute38%TYPE,
      attribute39		cn_commission_headers.attribute39%TYPE,
      attribute40		cn_commission_headers.attribute40%TYPE,
      attribute41		cn_commission_headers.attribute41%TYPE,
      attribute42		cn_commission_headers.attribute42%TYPE,
      attribute43		cn_commission_headers.attribute43%TYPE,
      attribute44		cn_commission_headers.attribute44%TYPE,
      attribute45		cn_commission_headers.attribute45%TYPE,
      attribute46		cn_commission_headers.attribute46%TYPE,
      attribute47		cn_commission_headers.attribute47%TYPE,
      attribute48		cn_commission_headers.attribute48%TYPE,
      attribute49		cn_commission_headers.attribute49%TYPE,
      attribute50		cn_commission_headers.attribute50%TYPE,
      attribute51		cn_commission_headers.attribute51%TYPE,
      attribute52		cn_commission_headers.attribute52%TYPE,
      attribute53		cn_commission_headers.attribute53%TYPE,
      attribute54		cn_commission_headers.attribute54%TYPE,
      attribute55		cn_commission_headers.attribute55%TYPE,
      attribute56		cn_commission_headers.attribute56%TYPE,
      attribute57		cn_commission_headers.attribute57%TYPE,
      attribute58		cn_commission_headers.attribute58%TYPE,
      attribute59		cn_commission_headers.attribute59%TYPE,
      attribute60		cn_commission_headers.attribute60%TYPE,
      attribute61		cn_commission_headers.attribute61%TYPE,
      attribute62		cn_commission_headers.attribute62%TYPE,
      attribute63		cn_commission_headers.attribute63%TYPE,
      attribute64		cn_commission_headers.attribute64%TYPE,
      attribute65		cn_commission_headers.attribute65%TYPE,
      attribute66		cn_commission_headers.attribute66%TYPE,
      attribute67		cn_commission_headers.attribute67%TYPE,
      attribute68		cn_commission_headers.attribute68%TYPE,
      attribute69		cn_commission_headers.attribute69%TYPE,
      attribute70		cn_commission_headers.attribute70%TYPE,
      attribute71		cn_commission_headers.attribute71%TYPE,
      attribute72		cn_commission_headers.attribute72%TYPE,
      attribute73		cn_commission_headers.attribute73%TYPE,
      attribute74		cn_commission_headers.attribute74%TYPE,
      attribute75		cn_commission_headers.attribute75%TYPE,
      attribute76		cn_commission_headers.attribute76%TYPE,
      attribute77		cn_commission_headers.attribute77%TYPE,
      attribute78		cn_commission_headers.attribute78%TYPE,
      attribute79		cn_commission_headers.attribute79%TYPE,
      attribute80		cn_commission_headers.attribute80%TYPE,
      attribute81		cn_commission_headers.attribute81%TYPE,
      attribute82		cn_commission_headers.attribute82%TYPE,
      attribute83		cn_commission_headers.attribute83%TYPE,
      attribute84		cn_commission_headers.attribute84%TYPE,
      attribute85		cn_commission_headers.attribute85%TYPE,
      attribute86		cn_commission_headers.attribute86%TYPE,
      attribute87		cn_commission_headers.attribute87%TYPE,
      attribute88		cn_commission_headers.attribute88%TYPE,
      attribute89		cn_commission_headers.attribute89%TYPE,
      attribute90		cn_commission_headers.attribute90%TYPE,
      attribute91		cn_commission_headers.attribute91%TYPE,
      attribute92		cn_commission_headers.attribute92%TYPE,
      attribute93		cn_commission_headers.attribute93%TYPE,
      attribute94		cn_commission_headers.attribute94%TYPE,
      attribute95		cn_commission_headers.attribute95%TYPE,
      attribute96		cn_commission_headers.attribute96%TYPE,
      attribute97		cn_commission_headers.attribute97%TYPE,
      attribute98		cn_commission_headers.attribute98%TYPE,
      attribute99		cn_commission_headers.attribute99%TYPE,
      attribute100		cn_commission_headers.attribute100%TYPE,
      last_update_date		cn_commission_headers.last_update_date%TYPE,
      last_updated_by		cn_commission_headers.last_updated_by%TYPE,
      last_update_login		cn_commission_headers.last_update_login%TYPE,
      creation_date		cn_commission_headers.creation_date%TYPE,
      created_by		cn_commission_headers.created_by%TYPE,
      org_id          		cn_commission_headers.org_id%TYPE,
      exchange_rate		cn_commission_headers.exchange_rate%TYPE,
      forecast_id		cn_commission_headers.forecast_id%TYPE,
      upside_quantity   	cn_commission_headers.upside_quantity%TYPE,
      upside_amount     	cn_commission_headers.upside_amount%TYPE,
      uom_code          	cn_commission_headers.uom_code%TYPE,
      source_trx_id    		cn_commission_headers.source_trx_id%TYPE,
      source_trx_line_id  	cn_commission_headers.source_trx_line_id%TYPE,
      source_trx_sales_line_id  cn_commission_headers.source_trx_sales_line_id%TYPE,
      negated_flag    		cn_commission_headers.negated_flag%TYPE,
      customer_id     		cn_commission_headers.customer_id%TYPE,
      inventory_item_id 	cn_commission_headers.inventory_item_id%TYPE,
      order_number    		cn_commission_headers.order_number%TYPE,
      booked_date     		cn_commission_headers.booked_date%TYPE,
      invoice_number  		cn_commission_headers.invoice_number%TYPE,
      invoice_date    		cn_commission_headers.invoice_date%TYPE,
      bill_to_address_id 	cn_commission_headers.bill_to_address_id%TYPE,
      ship_to_address_id 	cn_commission_headers.ship_to_address_id%TYPE,
      bill_to_contact_id  	cn_commission_headers.bill_to_contact_id%TYPE,
      ship_to_contact_id 	cn_commission_headers.ship_to_contact_id%TYPE,
      adj_comm_lines_api_id  	cn_commission_headers.adj_comm_lines_api_id%TYPE,
      adjust_date    		cn_commission_headers.adjust_date%TYPE,
      adjusted_by    		cn_commission_headers.adjusted_by%TYPE,
      revenue_type   		cn_commission_headers.revenue_type%TYPE,
      adjust_rollup_flag 	cn_commission_headers.adjust_rollup_flag%TYPE,
      adjust_comments    	cn_commission_headers.adjust_comments%TYPE,
      adjust_status     	cn_commission_headers.adjust_status%TYPE,
      line_number       	cn_commission_headers.line_number%TYPE,
      request_id		cn_commission_headers.request_id%TYPE,
      program_id		cn_commission_headers.program_id%TYPE,
      program_application_id	cn_commission_headers.program_application_id%TYPE,
      program_update_date	cn_commission_headers.program_update_date%TYPE,
      type               	cn_commission_headers.type%TYPE,
      sales_channel       	cn_commission_headers.sales_channel%TYPE,
      object_version_number 	cn_commission_headers.object_version_number%TYPE,
      split_pct			cn_commission_headers.split_pct%TYPE,
      split_status		cn_commission_headers.split_status%TYPE,
      direct_salesrep_number	cn_salesreps.employee_number%TYPE,
      direct_salesrep_name	cn_salesreps.name%TYPE,
      period_name		cn_period_statuses.period_name%TYPE,
      status_disp		cn_lookups.meaning%TYPE,
      trx_type_disp		cn_lookups.meaning%TYPE,
      reason			cn_lookups.meaning%TYPE,
      revenue_class_name       	cn_revenue_classes.name%TYPE,
      revenue_type_disp		cn_lookups.meaning%TYPE,
      adjust_status_disp	cn_lookups.meaning%TYPE,
      trx_batch_name		cn_trx_batches.trx_batch_name%TYPE,
      terr_id               cn_comm_lines_api.terr_id%TYPE,
      preserve_credit_override_flag    cn_comm_lines_api.preserve_credit_override_flag%TYPE
      );
   l_header_rec		header_rec;
   -- Local Variables
   l_api_sql		VARCHAR2(10000);
   l_header_sql		VARCHAR2(10000);
   l_api_query_flag	CHAR(1) := 'Y';
   l_header_query_flag  CHAR(1) := 'Y';
   l_source_counter	NUMBER := 0;
   l_salesrep_id    NUMBER;
   l_pr_date_from 	DATE;
   l_pr_date_to		DATE;
   l_invoice_num	VARCHAR2(20);
   l_order_num		NUMBER;

   --Added for Crediting
   l_terr_id NUMBER;
   l_keep_flag VARCHAR2(1);

   -- Tables/Records definitions
   l_adj_tbl            cn_get_tx_data_pub.adj_tbl_type;
   adj                  cn_get_tx_data_pub.adj_rec_type;
   l_attribute_tbl	cn_get_tx_data_pub.attribute_tbl;
   -- Defining REF CURSOR
   TYPE rc IS REF CURSOR;
   query_cur         	rc;

   cursor get_inv_details(p_comm_lines_api_id NUMBER)
   is
     select trx_id, trx_line_id, trx_sales_line_id
     from cn_comm_lines_api
     where comm_lines_api_id = p_comm_lines_api_id;

BEGIN
   IF (p_salesrep_id <> FND_API.G_MISS_NUM) THEN
      l_salesrep_id := p_salesrep_id;
   ELSE
      l_salesrep_id := null;
   END IF;
   IF (p_pr_date_from <> FND_API.G_MISS_DATE) THEN
      l_pr_date_from := p_pr_date_from;
   ELSE
      l_pr_date_from := null;
   END IF;
   IF (p_pr_date_to <> FND_API.G_MISS_DATE) THEN
      l_pr_date_to := p_pr_date_to;
   ELSE
      l_pr_date_to := null;
   END IF;
   IF (p_invoice_num <> FND_API.G_MISS_CHAR) THEN
      l_invoice_num := p_invoice_num;
   ELSE
      l_invoice_num := null;
   END IF;
   IF (p_order_num <> FND_API.G_MISS_NUM) THEN
      l_order_num := p_order_num;
   ELSE
      l_order_num := null;
   END IF;

   l_header_sql :=
      'SELECT '||
      'CCH.commission_header_id,CCH.direct_salesrep_id,CCH.processed_date, '||
      'CCH.processed_period_id,CCH.rollup_date,CCH.transaction_amount, '||
      'CCH.quantity,CCH.discount_percentage,CCH.margin_percentage, '||
      'CCH.orig_currency_code,CCH.transaction_amount_orig, '||
      'CCH.trx_type,CCH.status,CCH.pre_processed_code,CCH.comm_lines_api_id, '||
      'CCH.source_doc_type,CCH.source_trx_number,CCH.quota_id, '||
      'CCH.srp_plan_assign_id,CCH.revenue_class_id,CCH.role_id, '||
      'CCH.comp_group_id,CCH.commission_amount,CCH.trx_batch_id, '||
      'CCH.reversal_flag,CCH.reversal_header_id,CCH.reason_code, '||
      'CCH.comments,CCH.attribute_category, '||
      'CCH.attribute1,CCH.attribute2,CCH.attribute3,CCH.attribute4,CCH.attribute5, '||
      'CCH.attribute6,CCH.attribute7,CCH.attribute8,CCH.attribute9,CCH.attribute10, '||
      'CCH.attribute11,CCH.attribute12,CCH.attribute13,CCH.attribute14,CCH.attribute15, '||
      'CCH.attribute16,CCH.attribute17,CCH.attribute18,CCH.attribute19,CCH.attribute20, '||
      'CCH.attribute21,CCH.attribute22,CCH.attribute23,CCH.attribute24,CCH.attribute25, '||
      'CCH.attribute26,CCH.attribute27,CCH.attribute28,CCH.attribute29,CCH.attribute30, '||
      'CCH.attribute31,CCH.attribute32,CCH.attribute33,CCH.attribute34,CCH.attribute35, '||
      'CCH.attribute36,CCH.attribute37,CCH.attribute38,CCH.attribute39,CCH.attribute40, '||
      'CCH.attribute41,CCH.attribute42,CCH.attribute43,CCH.attribute44,CCH.attribute45, '||
      'CCH.attribute46,CCH.attribute47,CCH.attribute48,CCH.attribute49,CCH.attribute50, '||
      'CCH.attribute51,CCH.attribute52,CCH.attribute53,CCH.attribute54,CCH.attribute55, '||
      'CCH.attribute56,CCH.attribute57,CCH.attribute58,CCH.attribute59,CCH.attribute60, '||
      'CCH.attribute61,CCH.attribute62,CCH.attribute63,CCH.attribute64,CCH.attribute65, '||
      'CCH.attribute66,CCH.attribute67,CCH.attribute68,CCH.attribute69,CCH.attribute70, '||
      'CCH.attribute71,CCH.attribute72,CCH.attribute73,CCH.attribute74,CCH.attribute75, '||
      'CCH.attribute76,CCH.attribute77,CCH.attribute78,CCH.attribute79,CCH.attribute80, '||
      'CCH.attribute81,CCH.attribute82,CCH.attribute83,CCH.attribute84,CCH.attribute85, '||
      'CCH.attribute86,CCH.attribute87,CCH.attribute88,CCH.attribute89,CCH.attribute90, '||
      'CCH.attribute91,CCH.attribute92,CCH.attribute93,CCH.attribute94,CCH.attribute95, '||
      'CCH.attribute96,CCH.attribute97,CCH.attribute98,CCH.attribute99,CCH.attribute100, '||
      'CCH.last_update_date,CCH.last_updated_by,CCH.last_update_login, '||
      'CCH.creation_date,CCH.created_by,CCH.org_id,CCH.exchange_rate, '||
      'CCH.forecast_id,CCH.upside_quantity,CCH.upside_amount, '||
      'CCH.uom_code,CCH.source_trx_id,CCH.source_trx_line_id, '||
      'CCH.source_trx_sales_line_id,CCH.negated_flag,CCH.customer_id, '||
      'CCH.inventory_item_id,CCH.order_number,CCH.booked_date, '||
      'CCH.invoice_number,CCH.invoice_date,CCH.bill_to_address_id, '||
      'CCH.ship_to_address_id,CCH.bill_to_contact_id,CCH.ship_to_contact_id, '||
      'CCH.adj_comm_lines_api_id,CCH.adjust_date,CCH.adjusted_by, '||
      'CCH.revenue_type,CCH.adjust_rollup_flag,CCH.adjust_comments, '||
      'NVL(CCH.adjust_status,''NEW''),CCH.line_number,CCH.request_id,CCH.program_id, '||
      'CCH.program_application_id,CCH.program_update_date,CCH.type, '||
      'CCH.sales_channel,CCH.object_version_number,CCH.split_pct, CCH.split_status, '||
      'RSD.employee_number direct_salesrep_number, '||
      'RSD.name direct_salesrep_name, CPSP.period_name, '||
      'CLS.meaning status_disp ,CLT.meaning trx_type_disp, '||
      'CLR.meaning reason, CNR.name revenue_class_name, '||
      'CLRV.meaning revenue_type_disp, CLAD.meaning adjust_status_disp, '||
      'CTB.trx_batch_name, '||
      --Added for Crediting bug
      'API.terr_id, NVL(API.preserve_credit_override_flag,''N'') '||
      'FROM cn_period_statuses CPSP, cn_salesreps RSD, cn_commission_headers_all CCH, '||
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
      'AND CPSP.ORG_ID = CCH.ORG_ID '||
      'AND RSD.ORG_ID = CCH.ORG_id '||
      'AND CNR.ORG_ID(+) = CCH.ORG_id '||
      'AND CQ.ORG_ID(+) = CCH.ORG_id '||
      'AND CTB.ORG_ID(+) = CCH.ORG_id ';
   -- Column Mappings
   -- RSD.employee_number	-> direct_salesrep_number
   -- RSD.name			-> direct_salesrep_name
   -- CPSP.period_name		-> processed_period
   -- CLT.meaning 		-> trx_type_disp
   -- CLT.lookup_code 		-> trx_type
   -- CLR.meaning 		-> reason
   -- CLR.lookup_code 		-> reason_code
   -- CNR.name 			-> revenue_class_name
   -- CLRV.meaning 		-> revenue_type_disp
   -- CLAD.meaning 		-> adjust_status_disp
   l_api_sql :=
      'SELECT '||
      'CCLA.salesrep_id,CCLA.processed_date,CCLA.processed_period_id,CCLA.transaction_amount, '||
      'CCLA.trx_type,CCLA.revenue_class_id,CCLA.load_status,CCLA.attribute_category, '||
      'CCLA.attribute1,CCLA.attribute2,CCLA.attribute3,CCLA.attribute4,CCLA.attribute5, '||
      'CCLA.attribute6,CCLA.attribute7,CCLA.attribute8,CCLA.attribute9,CCLA.attribute10, '||
      'CCLA.attribute11,CCLA.attribute12,CCLA.attribute13,CCLA.attribute14,CCLA.attribute15, '||
      'CCLA.attribute16,CCLA.attribute17,CCLA.attribute18,CCLA.attribute19,CCLA.attribute20, '||
      'CCLA.attribute21,CCLA.attribute22,CCLA.attribute23,CCLA.attribute24,CCLA.attribute25, '||
      'CCLA.attribute26,CCLA.attribute27,CCLA.attribute28,CCLA.attribute29,CCLA.attribute30, '||
      'CCLA.attribute31,CCLA.attribute32,CCLA.attribute33,CCLA.attribute34,CCLA.attribute35, '||
      'CCLA.attribute36,CCLA.attribute37,CCLA.attribute38,CCLA.attribute39,CCLA.attribute40, '||
      'CCLA.attribute41,CCLA.attribute42,CCLA.attribute43,CCLA.attribute44,CCLA.attribute45, '||
      'CCLA.attribute46,CCLA.attribute47,CCLA.attribute48,CCLA.attribute49,CCLA.attribute50, '||
      'CCLA.attribute51,CCLA.attribute52,CCLA.attribute53,CCLA.attribute54,CCLA.attribute55, '||
      'CCLA.attribute56,CCLA.attribute57,CCLA.attribute58,CCLA.attribute59,CCLA.attribute60, '||
      'CCLA.attribute61,CCLA.attribute62,CCLA.attribute63,CCLA.attribute64,CCLA.attribute65, '||
      'CCLA.attribute66,CCLA.attribute67,CCLA.attribute68,CCLA.attribute69,CCLA.attribute70, '||
      'CCLA.attribute71,CCLA.attribute72,CCLA.attribute73,CCLA.attribute74,CCLA.attribute75, '||
      'CCLA.attribute76,CCLA.attribute77,CCLA.attribute78,CCLA.attribute79,CCLA.attribute80, '||
      'CCLA.attribute81,CCLA.attribute82,CCLA.attribute83,CCLA.attribute84,CCLA.attribute85, '||
      'CCLA.attribute86,CCLA.attribute87,CCLA.attribute88,CCLA.attribute89,CCLA.attribute90, '||
      'CCLA.attribute91,CCLA.attribute92,CCLA.attribute93,CCLA.attribute94,CCLA.attribute95, '||
      'CCLA.attribute96,CCLA.attribute97,CCLA.attribute98,CCLA.attribute99,CCLA.attribute100, '||
      'CCLA.comm_lines_api_id,CCLA.conc_batch_id,CCLA.process_batch_id,CCLA.salesrep_number, '||
      'CCLA.rollup_date,CCLA.source_doc_id,CCLA.source_doc_type,CCLA.created_by, '||
      'CCLA.creation_date,CCLA.last_updated_by,CCLA.last_update_date,CCLA.last_update_login, '||
      'CCLA.transaction_currency_code,CCLA.exchange_rate,CCLA.acctd_transaction_amount, '||
      'CCLA.trx_id,CCLA.trx_line_id,CCLA.trx_sales_line_id,CCLA.org_id,CCLA.quantity, '||
      'CCLA.source_trx_number, CCLA.discount_percentage,CCLA.margin_percentage, '||
      'CCLA.source_trx_id,CCLA.source_trx_line_id, '||
      'CCLA.source_trx_sales_line_id,CCLA.negated_flag,CCLA.customer_id,CCLA.inventory_item_id, '||
      'CCLA.order_number,CCLA.booked_date,CCLA.invoice_number,CCLA.invoice_date,CCLA.adjust_date, '||
      'CCLA.adjusted_by,CCLA.revenue_type,CCLA.adjust_rollup_flag,CCLA.adjust_comments, '||
      'NVL(CCLA.adjust_status,''NEW''),CCLA.line_number,CCLA.bill_to_address_id,CCLA.ship_to_address_id, '||
      'CCLA.bill_to_contact_id,CCLA.ship_to_contact_id,CCLA.adj_comm_lines_api_id, '||
      'CCLA.pre_defined_rc_flag,CCLA.rollup_flag,CCLA.forecast_id,CCLA.upside_quantity, '||
      'CCLA.upside_amount,CCLA.uom_code,CCLA.reason_code,CCLA.type,CCLA.pre_processed_code, '||
      'CCLA.quota_id,CCLA.srp_plan_assign_id,CCLA.role_id,CCLA.comp_group_id, '||
      'CCLA.commission_amount,CCLA.employee_number,CCLA.reversal_flag,CCLA.reversal_header_id, '||
      'CCLA.sales_channel,CCLA.object_version_number,CCLA.split_pct,CCLA.split_status, '||
      'RSD.employee_number, '||
      'RSD.name, CPSP.period_name, CLT.meaning trx_type_disp, '||
      'CLR.meaning reason, CNR.name revenue_class_name, '||
      'CLRV.meaning revenue_type_disp, CLAD.meaning adjust_status_disp, '||
      --Modified for Crediting Bug
      'CCLA.terr_id, NVL(CCLA.preserve_credit_override_flag,''N'') '||
      'FROM cn_comm_lines_api_all CCLA, '||
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
      'AND CPSP.ORG_ID = CCLA.ORG_ID '||
      'AND RSD.ORG_ID = CCLA.ORG_ID '||
      'AND CNR.ORG_ID(+) = CCLA.ORG_id ';

   IF (p_salesrep_id <> FND_API.G_MISS_NUM) THEN
      l_header_sql := l_header_sql|| ' AND CCH.direct_salesrep_id = :p_salesrep_id';
      l_api_sql := l_api_sql || ' AND CCLA.salesrep_id = :p_salesrep_id';
   ELSE
      --l_header_sql := l_header_sql|| ' AND :p_salesrep_id = '||FND_API.G_MISS_NUM;
      --l_api_sql := l_api_sql|| ' AND :p_salesrep_id = '||FND_API.G_MISS_NUM;
      l_header_sql := l_header_sql|| ' AND :p_salesrep_id IS NULL ';
      l_api_sql := l_api_sql|| ' AND :p_salesrep_id IS NULL ';
   END IF;

   IF (p_org_id <> FND_API.G_MISS_NUM) THEN
      l_header_sql := l_header_sql|| ' AND CCH.org_id = :p_org_id';
      l_api_sql := l_api_sql || ' AND CCLA.org_id = :p_org_id';
   ELSE
      l_header_sql := l_header_sql|| ' AND :p_org_id = '||FND_API.G_MISS_NUM;
      l_api_sql := l_api_sql|| ' AND :p_org_id = '||FND_API.G_MISS_NUM;
   END IF;

   --

   --Added for Crediting
   l_terr_id := p_srch_attr_rec.terr_id;
   IF (l_terr_id = 0) THEN
      l_header_sql := l_header_sql|| ' AND API.terr_id is not null';
      l_api_sql := l_api_sql || ' AND CCLA.terr_id is not null';
   END IF;
   IF (l_terr_id = 1) THEN
      l_header_sql := l_header_sql|| ' AND API.terr_id is null';
      l_api_sql := l_api_sql || ' AND CCLA.terr_id is null';
   END IF;

   l_keep_flag := p_srch_attr_rec.preserve_credit_override_flag;
   IF (l_keep_flag <> FND_API.G_MISS_CHAR AND l_keep_flag IS NOT NULL) THEN
      IF (l_keep_flag = 'Y')
      THEN
      l_header_sql := l_header_sql|| ' AND API.preserve_credit_override_flag = :l_keep_flag';
      l_api_sql := l_api_sql || ' AND CCLA.preserve_credit_override_flag = :l_keep_flag';
      END IF;
      IF (l_keep_flag = 'N')
      THEN
      l_header_sql := l_header_sql|| ' AND API.preserve_credit_override_flag = :l_keep_flag';
      l_api_sql := l_api_sql || ' AND CCLA.preserve_credit_override_flag = :l_keep_flag';
      END IF;
   ELSE
      l_header_sql := l_header_sql|| ' AND :l_keep_flag IS NULL';
      l_api_sql := l_api_sql || ' AND :l_keep_flag IS NULL';
   END IF;


   IF (p_pr_date_from <> FND_API.G_MISS_DATE) THEN
      l_header_sql := l_header_sql|| ' AND trunc(CCH.processed_date) >= :l_pr_date_from';
      l_api_sql := l_api_sql || ' AND trunc(CCLA.processed_date) >= :l_pr_date_from';
   ELSE
      l_header_sql := l_header_sql|| ' AND :l_pr_date_from IS NULL';
      l_api_sql := l_api_sql|| ' AND :l_pr_date_from IS NULL';
   END IF;
   --
   IF (p_pr_date_to <> FND_API.G_MISS_DATE) THEN
      l_header_sql := l_header_sql|| ' AND trunc(CCH.processed_date) <= :l_pr_date_to';
      l_api_sql := l_api_sql || ' AND trunc(CCLA.processed_date) <= :l_pr_date_to';
   ELSE
      l_header_sql := l_header_sql|| ' AND :l_pr_date_to IS NULL';
      l_api_sql := l_api_sql|| ' AND :l_pr_date_to IS NULL';
   END IF;
   --
   IF (p_invoice_num <> FND_API.G_MISS_CHAR) THEN
      l_header_sql := l_header_sql|| ' AND CCH.invoice_number LIKE :l_invoice_num';
      l_api_sql := l_api_sql || ' AND CCLA.invoice_number LIKE :l_invoice_num';
   ELSE
      l_header_sql := l_header_sql|| ' AND :l_invoice_num IS NULL';
      l_api_sql := l_api_sql|| ' AND :l_invoice_num IS NULL';
   END IF;
   --
   IF (p_order_num <> FND_API.G_MISS_NUM) THEN
      l_header_sql := l_header_sql|| ' AND CCH.order_number = :p_order_num';
      l_api_sql := l_api_sql || ' AND CCLA.order_number = :p_order_num';
   ELSE
      l_header_sql := l_header_sql|| ' AND :p_order_num IS NULL';
      l_api_sql := l_api_sql|| ' AND :p_order_num IS NULL';
   END IF;
   --
   convert_rec_to_tbl(
   	p_srch_attr_rec	=> p_srch_attr_rec,
	x_attribute_tbl	=> l_attribute_tbl);
   --
   IF (l_attribute_tbl.COUNT > 0) THEN
      FOR i IN l_attribute_tbl.FIRST..l_attribute_tbl.LAST
      LOOP
         IF (l_attribute_tbl(i).attribute_name IS NOT NULL) THEN
            l_header_sql := l_header_sql||' AND CCH.'||
                            l_attribute_tbl(i).attribute_name||' LIKE '''||
			    l_attribute_tbl(i).attribute_value||'''';
            l_api_sql    := l_api_sql||' AND CCLA.'||
                            l_attribute_tbl(i).attribute_name||' LIKE '''||
			    l_attribute_tbl(i).attribute_value||'''';
         END IF;
      END LOOP;
   END IF;
   --

   IF (p_calc_status <> 'ALL') THEN
      l_header_sql := l_header_sql|| ' AND CCH.status = :p_calc_status';
      l_api_query_flag := 'N';
   ELSE
      l_header_sql := l_header_sql|| ' and :p_calc_status = ''ALL''';
      l_api_query_flag := 'Y';
   END IF;
   IF (p_adj_status <> 'ALL') THEN
      l_header_sql := l_header_sql|| ' AND CCH.adjust_status = :p_adj_status';
      l_api_sql := l_api_sql || ' AND CCLA.adjust_status = :p_adj_status';
   ELSE
      l_header_sql := l_header_sql|| ' and :p_adj_status = ''ALL''';
      l_api_sql := l_api_sql || ' and :p_adj_status = ''ALL''';
   END IF;
   IF ((p_load_status <> 'ALL') AND (p_load_status <> 'LOADED')) THEN
      l_header_query_flag := 'N';
      l_api_sql := l_api_sql || ' AND CCLA.load_status = :p_load_status';
   ELSIF ((p_load_status <> 'ALL') AND (p_load_status = 'LOADED')) THEN
      l_header_query_flag := 'Y';
      l_api_query_flag := 'N';
   ELSE
      l_header_query_flag := 'Y';
      l_api_sql := l_api_sql || ' and :p_load_status = ''ALL''';
   END IF;
   -- Processing Attribute Columns
   --CN_mydebug.ADD('Header SQL  : '||substr(l_header_sql,1,3500));
   --CN_mydebug.ADD('Header SQL  : '||substr(l_header_sql,3500,7000));
   --CN_mydebug.ADD('Header SQL  : '||substr(l_header_sql,7000,1000));

   --CN_mydebug.ADD('API SQL  : '||substr(l_api_sql,1,3500));
   --CN_mydebug.ADD('API SQL  : '||substr(l_api_sql,3500,7000));
   --CN_mydebug.ADD('API SQL  : '||substr(l_api_sql,7000,1000));

   IF (l_header_query_flag = 'Y') THEN
   OPEN query_cur FOR l_header_sql
        USING
        l_salesrep_id,
	      p_org_id,
	      l_keep_flag,
	      l_pr_date_from,
	      l_pr_date_to,
	      l_invoice_num,
	      l_order_num,
	      p_calc_status,
          p_adj_status;
   LOOP
      FETCH query_cur INTO l_header_rec;
      EXIT WHEN query_cur%NOTFOUND;
         l_source_counter := l_source_counter + 1;
         l_adj_tbl(l_source_counter).commission_header_id	:= l_header_rec.commission_header_id;
	 l_adj_tbl(l_source_counter).direct_salesrep_number	:= l_header_rec.direct_salesrep_number;
	 l_adj_tbl(l_source_counter).direct_salesrep_name	:= l_header_rec.direct_salesrep_name;
	 l_adj_tbl(l_source_counter).direct_salesrep_id		:= l_header_rec.direct_salesrep_id;
	 l_adj_tbl(l_source_counter).processed_period_id	:= l_header_rec.processed_period_id;
	 l_adj_tbl(l_source_counter).processed_period		:= l_header_rec.period_name;
	 l_adj_tbl(l_source_counter).processed_date		:= l_header_rec.processed_date;
	 l_adj_tbl(l_source_counter).rollup_date		:= l_header_rec.rollup_date;
	 /* In this record type transaction_amount corresponds to functional amount
	    and transaction_amount_orig corresponds to foreign amount. In the header table
	    functional amount is stored in the transaction_amount and foreign amount is
	    stored in the transaction_amount_orig column. check the API record for
	    more information */
	 l_adj_tbl(l_source_counter).transaction_amount		:= l_header_rec.transaction_amount;
	 l_adj_tbl(l_source_counter).transaction_amount_orig	:= l_header_rec.transaction_amount_orig;
	 l_adj_tbl(l_source_counter).quantity			:= l_header_rec.quantity;
	 l_adj_tbl(l_source_counter).discount_percentage	:= l_header_rec.discount_percentage;
	 l_adj_tbl(l_source_counter).margin_percentage		:= l_header_rec.margin_percentage;
	 l_adj_tbl(l_source_counter).orig_currency_code		:= l_header_rec.orig_currency_code;
	 l_adj_tbl(l_source_counter).exchange_rate		:= l_header_rec.exchange_rate;
	 l_adj_tbl(l_source_counter).status_disp		:= l_header_rec.status_disp;
	 l_adj_tbl(l_source_counter).status			:= l_header_rec.status;
	 l_adj_tbl(l_source_counter).trx_type_disp		:= l_header_rec.trx_type_disp;
	 l_adj_tbl(l_source_counter).trx_type			:= l_header_rec.trx_type;
	 l_adj_tbl(l_source_counter).reason			:= l_header_rec.reason;
	 l_adj_tbl(l_source_counter).reason_code		:= l_header_rec.reason_code;
	 l_adj_tbl(l_source_counter).comments			:= l_header_rec.comments;
	 l_adj_tbl(l_source_counter).trx_batch_id		:= l_header_rec.trx_batch_id;
	 l_adj_tbl(l_source_counter).created_by			:= l_header_rec.created_by;
	 l_adj_tbl(l_source_counter).creation_date		:= l_header_rec.creation_date;
	 l_adj_tbl(l_source_counter).last_updated_by		:= l_header_rec.last_updated_by;
	 l_adj_tbl(l_source_counter).last_update_login		:= l_header_rec.last_update_login;
	 l_adj_tbl(l_source_counter).last_update_date		:= l_header_rec.last_update_date;
	 l_adj_tbl(l_source_counter).attribute_category		:= l_header_rec.attribute_category;
	 l_adj_tbl(l_source_counter).attribute1         	:= l_header_rec.attribute1;
	 l_adj_tbl(l_source_counter).attribute2           	:= l_header_rec.attribute2;
	 l_adj_tbl(l_source_counter).attribute3           	:= l_header_rec.attribute3;
	 l_adj_tbl(l_source_counter).attribute4           	:= l_header_rec.attribute4;
	 l_adj_tbl(l_source_counter).attribute5           	:= l_header_rec.attribute5;
	 l_adj_tbl(l_source_counter).attribute6           	:= l_header_rec.attribute6;
	 l_adj_tbl(l_source_counter).attribute7           	:= l_header_rec.attribute7;
	 l_adj_tbl(l_source_counter).attribute8           	:= l_header_rec.attribute8;
	 l_adj_tbl(l_source_counter).attribute9           	:= l_header_rec.attribute9;
	 l_adj_tbl(l_source_counter).attribute10          	:= l_header_rec.attribute10;
	 l_adj_tbl(l_source_counter).attribute11          	:= l_header_rec.attribute11;
	 l_adj_tbl(l_source_counter).attribute12          	:= l_header_rec.attribute12;
	 l_adj_tbl(l_source_counter).attribute13          	:= l_header_rec.attribute13;
	 l_adj_tbl(l_source_counter).attribute14          	:= l_header_rec.attribute14;
	 l_adj_tbl(l_source_counter).attribute15          	:= l_header_rec.attribute15;
	 l_adj_tbl(l_source_counter).attribute16          	:= l_header_rec.attribute16;
	 l_adj_tbl(l_source_counter).attribute17          	:= l_header_rec.attribute17;
	 l_adj_tbl(l_source_counter).attribute18          	:= l_header_rec.attribute18;
	 l_adj_tbl(l_source_counter).attribute19          	:= l_header_rec.attribute19;
	 l_adj_tbl(l_source_counter).attribute20          	:= l_header_rec.attribute20;
	 l_adj_tbl(l_source_counter).attribute21          	:= l_header_rec.attribute21;
	 l_adj_tbl(l_source_counter).attribute22          	:= l_header_rec.attribute22;
	 l_adj_tbl(l_source_counter).attribute23          	:= l_header_rec.attribute23;
	 l_adj_tbl(l_source_counter).attribute24          	:= l_header_rec.attribute24;
	 l_adj_tbl(l_source_counter).attribute25          	:= l_header_rec.attribute25;
	 l_adj_tbl(l_source_counter).attribute26          	:= l_header_rec.attribute26;
	 l_adj_tbl(l_source_counter).attribute27          	:= l_header_rec.attribute27;
	 l_adj_tbl(l_source_counter).attribute28          	:= l_header_rec.attribute28;
	 l_adj_tbl(l_source_counter).attribute29          	:= l_header_rec.attribute29;
	 l_adj_tbl(l_source_counter).attribute30          	:= l_header_rec.attribute30;
	 l_adj_tbl(l_source_counter).attribute31          	:= l_header_rec.attribute31;
	 l_adj_tbl(l_source_counter).attribute32          	:= l_header_rec.attribute32;
	 l_adj_tbl(l_source_counter).attribute33          	:= l_header_rec.attribute33;
	 l_adj_tbl(l_source_counter).attribute34          	:= l_header_rec.attribute34;
	 l_adj_tbl(l_source_counter).attribute35          	:= l_header_rec.attribute35;
	 l_adj_tbl(l_source_counter).attribute36          	:= l_header_rec.attribute36;
	 l_adj_tbl(l_source_counter).attribute37          	:= l_header_rec.attribute37;
	 l_adj_tbl(l_source_counter).attribute38          	:= l_header_rec.attribute38;
	 l_adj_tbl(l_source_counter).attribute39          	:= l_header_rec.attribute39;
	 l_adj_tbl(l_source_counter).attribute40          	:= l_header_rec.attribute40;
	 l_adj_tbl(l_source_counter).attribute41          	:= l_header_rec.attribute41;
	 l_adj_tbl(l_source_counter).attribute42          	:= l_header_rec.attribute42;
	 l_adj_tbl(l_source_counter).attribute43          	:= l_header_rec.attribute43;
	 l_adj_tbl(l_source_counter).attribute44          	:= l_header_rec.attribute44;
	 l_adj_tbl(l_source_counter).attribute45          	:= l_header_rec.attribute45;
	 l_adj_tbl(l_source_counter).attribute46          	:= l_header_rec.attribute46;
	 l_adj_tbl(l_source_counter).attribute47          	:= l_header_rec.attribute47;
	 l_adj_tbl(l_source_counter).attribute48          	:= l_header_rec.attribute48;
	 l_adj_tbl(l_source_counter).attribute49          	:= l_header_rec.attribute49;
	 l_adj_tbl(l_source_counter).attribute50          	:= l_header_rec.attribute50;
	 l_adj_tbl(l_source_counter).attribute51          	:= l_header_rec.attribute51;
	 l_adj_tbl(l_source_counter).attribute52          	:= l_header_rec.attribute52;
	 l_adj_tbl(l_source_counter).attribute53          	:= l_header_rec.attribute53;
	 l_adj_tbl(l_source_counter).attribute54          	:= l_header_rec.attribute54;
	 l_adj_tbl(l_source_counter).attribute55          	:= l_header_rec.attribute55;
	 l_adj_tbl(l_source_counter).attribute56          	:= l_header_rec.attribute56;
	 l_adj_tbl(l_source_counter).attribute57          	:= l_header_rec.attribute57;
	 l_adj_tbl(l_source_counter).attribute58          	:= l_header_rec.attribute58;
	 l_adj_tbl(l_source_counter).attribute59          	:= l_header_rec.attribute59;
	 l_adj_tbl(l_source_counter).attribute60          	:= l_header_rec.attribute60;
	 l_adj_tbl(l_source_counter).attribute61          	:= l_header_rec.attribute61;
	 l_adj_tbl(l_source_counter).attribute62          	:= l_header_rec.attribute62;
	 l_adj_tbl(l_source_counter).attribute63          	:= l_header_rec.attribute63;
	 l_adj_tbl(l_source_counter).attribute64          	:= l_header_rec.attribute64;
	 l_adj_tbl(l_source_counter).attribute65          	:= l_header_rec.attribute65;
	 l_adj_tbl(l_source_counter).attribute66          	:= l_header_rec.attribute66;
	 l_adj_tbl(l_source_counter).attribute67          	:= l_header_rec.attribute67;
	 l_adj_tbl(l_source_counter).attribute68          	:= l_header_rec.attribute68;
	 l_adj_tbl(l_source_counter).attribute69          	:= l_header_rec.attribute69;
	 l_adj_tbl(l_source_counter).attribute70          	:= l_header_rec.attribute70;
	 l_adj_tbl(l_source_counter).attribute71          	:= l_header_rec.attribute71;
	 l_adj_tbl(l_source_counter).attribute72          	:= l_header_rec.attribute72;
	 l_adj_tbl(l_source_counter).attribute73          	:= l_header_rec.attribute73;
	 l_adj_tbl(l_source_counter).attribute74          	:= l_header_rec.attribute74;
	 l_adj_tbl(l_source_counter).attribute75          	:= l_header_rec.attribute75;
	 l_adj_tbl(l_source_counter).attribute76          	:= l_header_rec.attribute76;
	 l_adj_tbl(l_source_counter).attribute77          	:= l_header_rec.attribute77;
	 l_adj_tbl(l_source_counter).attribute78          	:= l_header_rec.attribute78;
	 l_adj_tbl(l_source_counter).attribute79          	:= l_header_rec.attribute79;
	 l_adj_tbl(l_source_counter).attribute80          	:= l_header_rec.attribute80;
	 l_adj_tbl(l_source_counter).attribute81          	:= l_header_rec.attribute81;
	 l_adj_tbl(l_source_counter).attribute82          	:= l_header_rec.attribute82;
	 l_adj_tbl(l_source_counter).attribute83          	:= l_header_rec.attribute83;
	 l_adj_tbl(l_source_counter).attribute84          	:= l_header_rec.attribute84;
	 l_adj_tbl(l_source_counter).attribute85          	:= l_header_rec.attribute85;
	 l_adj_tbl(l_source_counter).attribute86          	:= l_header_rec.attribute86;
	 l_adj_tbl(l_source_counter).attribute87          	:= l_header_rec.attribute87;
	 l_adj_tbl(l_source_counter).attribute88          	:= l_header_rec.attribute88;
	 l_adj_tbl(l_source_counter).attribute89          	:= l_header_rec.attribute89;
	 l_adj_tbl(l_source_counter).attribute90          	:= l_header_rec.attribute90;
	 l_adj_tbl(l_source_counter).attribute91          	:= l_header_rec.attribute91;
	 l_adj_tbl(l_source_counter).attribute92          	:= l_header_rec.attribute92;
	 l_adj_tbl(l_source_counter).attribute93          	:= l_header_rec.attribute93;
	 l_adj_tbl(l_source_counter).attribute94          	:= l_header_rec.attribute94;
	 l_adj_tbl(l_source_counter).attribute95          	:= l_header_rec.attribute95;
	 l_adj_tbl(l_source_counter).attribute96          	:= l_header_rec.attribute96;
	 l_adj_tbl(l_source_counter).attribute97          	:= l_header_rec.attribute97;
	 l_adj_tbl(l_source_counter).attribute98          	:= l_header_rec.attribute98;
	 l_adj_tbl(l_source_counter).attribute99          	:= l_header_rec.attribute99;
	 l_adj_tbl(l_source_counter).attribute100         	:= l_header_rec.attribute100;
	 l_adj_tbl(l_source_counter).quota_id 			:= l_header_rec.quota_id;
	 l_adj_tbl(l_source_counter).revenue_class_id 		:= l_header_rec.revenue_class_id;
	 l_adj_tbl(l_source_counter).revenue_class_name 	:= l_header_rec.revenue_class_name;
	 l_adj_tbl(l_source_counter).trx_batch_name 		:= l_header_rec.trx_batch_name;
	 l_adj_tbl(l_source_counter).source_trx_number 		:= l_header_rec.source_trx_number;
	 l_adj_tbl(l_source_counter).comm_lines_api_id 		:= l_header_rec.comm_lines_api_id;
	 l_adj_tbl(l_source_counter).source_doc_type 		:= l_header_rec.source_doc_type;
	 l_adj_tbl(l_source_counter).upside_amount 		:= l_header_rec.upside_amount;
	 l_adj_tbl(l_source_counter).upside_quantity 		:= l_header_rec.upside_quantity;
	 l_adj_tbl(l_source_counter).uom_code 			:= l_header_rec.uom_code;
	 l_adj_tbl(l_source_counter).forecast_id 		:= l_header_rec.forecast_id;
	 l_adj_tbl(l_source_counter).program_id 		:= l_header_rec.program_id;
	 l_adj_tbl(l_source_counter).request_id 		:= l_header_rec.request_id;
	 l_adj_tbl(l_source_counter).program_application_id 	:= l_header_rec.program_application_id;
	 l_adj_tbl(l_source_counter).program_update_date 	:= l_header_rec.program_update_date;
	 l_adj_tbl(l_source_counter).adj_comm_lines_api_id 	:= l_header_rec.adj_comm_lines_api_id;
	 l_adj_tbl(l_source_counter).invoice_number 		:= l_header_rec.invoice_number;
	 l_adj_tbl(l_source_counter).invoice_date 		:= l_header_rec.invoice_date;
	 l_adj_tbl(l_source_counter).order_number 		:= l_header_rec.order_number;
	 l_adj_tbl(l_source_counter).order_date 		:= l_header_rec.booked_date;
	 l_adj_tbl(l_source_counter).line_number 		:= l_header_rec.line_number;
	 l_adj_tbl(l_source_counter).customer_id 		:= l_header_rec.customer_id;
	 l_adj_tbl(l_source_counter).bill_to_address_id 	:= l_header_rec.bill_to_address_id;
	 l_adj_tbl(l_source_counter).ship_to_address_id 	:= l_header_rec.ship_to_address_id;
	 l_adj_tbl(l_source_counter).bill_to_contact_id 	:= l_header_rec.bill_to_contact_id;
	 l_adj_tbl(l_source_counter).ship_to_contact_id 	:= l_header_rec.ship_to_contact_id;
	 l_adj_tbl(l_source_counter).load_status 		:= 'LOADED';
	 l_adj_tbl(l_source_counter).revenue_type_disp 		:= l_header_rec.revenue_type_disp;
	 l_adj_tbl(l_source_counter).revenue_type 		:= l_header_rec.revenue_type;
	 l_adj_tbl(l_source_counter).adjust_rollup_flag 	:= l_header_rec.adjust_rollup_flag;
	 l_adj_tbl(l_source_counter).adjust_date 		:= l_header_rec.adjust_date;
	 l_adj_tbl(l_source_counter).adjusted_by 		:= l_header_rec.adjusted_by;
	 l_adj_tbl(l_source_counter).adjust_status_disp 	:= l_header_rec.adjust_status_disp;
	 l_adj_tbl(l_source_counter).adjust_status 		:= NVL(l_header_rec.adjust_status,'NEW');
	 l_adj_tbl(l_source_counter).adjust_comments 		:= l_header_rec.adjust_comments;
	 l_adj_tbl(l_source_counter).type 			:= l_header_rec.type;
	 l_adj_tbl(l_source_counter).pre_processed_code 	:= l_header_rec.pre_processed_code;
	 l_adj_tbl(l_source_counter).comp_group_id 		:= l_header_rec.comp_group_id;
	 l_adj_tbl(l_source_counter).srp_plan_assign_id 	:= l_header_rec.srp_plan_assign_id;
	 l_adj_tbl(l_source_counter).role_id 			:= l_header_rec.role_id;
	 l_adj_tbl(l_source_counter).sales_channel 		:= l_header_rec.sales_channel;
	 l_adj_tbl(l_source_counter).object_version_number	:= l_header_rec.object_version_number;
	 l_adj_tbl(l_source_counter).split_pct			:= l_header_rec.split_pct;
	 l_adj_tbl(l_source_counter).split_status		:= l_header_rec.split_status;
	 l_adj_tbl(l_source_counter).inventory_item_id		:= l_header_rec.inventory_item_id;
	 l_adj_tbl(l_source_counter).org_id			:= l_header_rec.org_id;
	 -- Bug fix 5349170
	 l_adj_tbl(l_source_counter).source_trx_id		:= l_header_rec.source_trx_id;
	 l_adj_tbl(l_source_counter).source_trx_line_id		:= l_header_rec.source_trx_line_id;
	 l_adj_tbl(l_source_counter).source_trx_sales_line_id	:= l_header_rec.source_trx_sales_line_id;
	 -- Bug fix 5349170
        -- Added for Crediting
	   l_adj_tbl(l_source_counter).terr_id	:= l_header_rec.terr_id;
	   l_adj_tbl(l_source_counter).preserve_credit_override_flag	:= NVL(l_header_rec.preserve_credit_override_flag,'N');


	 -- fix to get trx_id, trx_line_id, trx_sales_line_id when using header query
         -- an extra cursor is required as these columns are not available in
         -- cn_commission_headers table
         FOR inv_rec IN get_inv_details(l_header_rec.comm_lines_api_id) LOOP
           l_adj_tbl(l_source_counter).trx_id			:= inv_rec.trx_id;
	   l_adj_tbl(l_source_counter).trx_line_id		:= inv_rec.trx_line_id;
	   l_adj_tbl(l_source_counter).trx_sales_line_id	:= inv_rec.trx_sales_line_id;

	 END LOOP;

   END LOOP;
   END IF;

    IF (l_api_query_flag = 'Y') THEN


   --CN_mydebug.ADD('API SQL  : '||l_api_sql);


      OPEN query_cur FOR l_api_sql
           USING
           l_salesrep_id,
		 p_org_id,
		 l_keep_flag,
	         l_pr_date_from,
	      	 l_pr_date_to,
	      	 l_invoice_num,
	      	 l_order_num,
                 p_adj_status,
                 p_load_status;

      LOOP
         FETCH query_cur INTO l_api_rec;
         EXIT WHEN query_cur%NOTFOUND;

	    l_source_counter := l_source_counter + 1;
	    l_adj_tbl(l_source_counter).direct_salesrep_number	:= l_api_rec.direct_salesrep_number;
	    l_adj_tbl(l_source_counter).direct_salesrep_name	:= l_api_rec.direct_salesrep_name;
	    l_adj_tbl(l_source_counter).direct_salesrep_id	:= l_api_rec.salesrep_id;
	    l_adj_tbl(l_source_counter).processed_period_id	:= l_api_rec.processed_period_id;
	    l_adj_tbl(l_source_counter).processed_period	:= l_api_rec.period_name;
	    l_adj_tbl(l_source_counter).processed_date		:= l_api_rec.processed_date;
	    l_adj_tbl(l_source_counter).rollup_date		:= l_api_rec.rollup_date;
	    /* In this API table transaction_amount corresponds to foreign amount
	    and acctd_transaction_amount corresponds to functional amount.*/
	    l_adj_tbl(l_source_counter).transaction_amount	:= l_api_rec.acctd_transaction_amount;
	    l_adj_tbl(l_source_counter).transaction_amount_orig	:= l_api_rec.transaction_amount;
	    l_adj_tbl(l_source_counter).quantity		:= l_api_rec.quantity;
	    l_adj_tbl(l_source_counter).discount_percentage	:= l_api_rec.discount_percentage;
	    l_adj_tbl(l_source_counter).margin_percentage	:= l_api_rec.margin_percentage;
	    l_adj_tbl(l_source_counter).orig_currency_code	:= l_api_rec.transaction_currency_code;
	    l_adj_tbl(l_source_counter).exchange_rate		:= l_api_rec.exchange_rate;
	    l_adj_tbl(l_source_counter).status_disp		:= g_space;
	    l_adj_tbl(l_source_counter).status			:= g_space;
	    l_adj_tbl(l_source_counter).trx_type_disp		:= l_api_rec.trx_type_disp;
	    l_adj_tbl(l_source_counter).trx_type		:= l_api_rec.trx_type;
	    l_adj_tbl(l_source_counter).reason			:= l_api_rec.reason;
	    l_adj_tbl(l_source_counter).reason_code		:= l_api_rec.reason_code;
	    l_adj_tbl(l_source_counter).created_by		:= l_api_rec.created_by;
	    l_adj_tbl(l_source_counter).creation_date		:= l_api_rec.creation_date;
	    l_adj_tbl(l_source_counter).last_updated_by		:= l_api_rec.last_updated_by;
	    l_adj_tbl(l_source_counter).last_update_login	:= l_api_rec.last_update_login;
	    l_adj_tbl(l_source_counter).last_update_date	:= l_api_rec.last_update_date;
	    l_adj_tbl(l_source_counter).attribute_category	:= l_api_rec.attribute_category;
	    l_adj_tbl(l_source_counter).attribute1         	:= l_api_rec.attribute1;
	    l_adj_tbl(l_source_counter).attribute2           	:= l_api_rec.attribute2;
	    l_adj_tbl(l_source_counter).attribute3           	:= l_api_rec.attribute3;
	    l_adj_tbl(l_source_counter).attribute4           	:= l_api_rec.attribute4;
	    l_adj_tbl(l_source_counter).attribute5           	:= l_api_rec.attribute5;
	    l_adj_tbl(l_source_counter).attribute6           	:= l_api_rec.attribute6;
	    l_adj_tbl(l_source_counter).attribute7           	:= l_api_rec.attribute7;
	    l_adj_tbl(l_source_counter).attribute8           	:= l_api_rec.attribute8;
	    l_adj_tbl(l_source_counter).attribute9           	:= l_api_rec.attribute9;
	    l_adj_tbl(l_source_counter).attribute10          	:= l_api_rec.attribute10;
	    l_adj_tbl(l_source_counter).attribute11          	:= l_api_rec.attribute11;
	    l_adj_tbl(l_source_counter).attribute12          	:= l_api_rec.attribute12;
	    l_adj_tbl(l_source_counter).attribute13          	:= l_api_rec.attribute13;
	    l_adj_tbl(l_source_counter).attribute14          	:= l_api_rec.attribute14;
	    l_adj_tbl(l_source_counter).attribute15          	:= l_api_rec.attribute15;
	    l_adj_tbl(l_source_counter).attribute16          	:= l_api_rec.attribute16;
	    l_adj_tbl(l_source_counter).attribute17          	:= l_api_rec.attribute17;
	    l_adj_tbl(l_source_counter).attribute18          	:= l_api_rec.attribute18;
	    l_adj_tbl(l_source_counter).attribute19          	:= l_api_rec.attribute19;
	    l_adj_tbl(l_source_counter).attribute20          	:= l_api_rec.attribute20;
	    l_adj_tbl(l_source_counter).attribute21          	:= l_api_rec.attribute21;
	    l_adj_tbl(l_source_counter).attribute22          	:= l_api_rec.attribute22;
	    l_adj_tbl(l_source_counter).attribute23          	:= l_api_rec.attribute23;
	    l_adj_tbl(l_source_counter).attribute24          	:= l_api_rec.attribute24;
	    l_adj_tbl(l_source_counter).attribute25          	:= l_api_rec.attribute25;
	    l_adj_tbl(l_source_counter).attribute26          	:= l_api_rec.attribute26;
	    l_adj_tbl(l_source_counter).attribute27          	:= l_api_rec.attribute27;
	    l_adj_tbl(l_source_counter).attribute28          	:= l_api_rec.attribute28;
	    l_adj_tbl(l_source_counter).attribute29          	:= l_api_rec.attribute29;
	    l_adj_tbl(l_source_counter).attribute30          	:= l_api_rec.attribute30;
	    l_adj_tbl(l_source_counter).attribute31          	:= l_api_rec.attribute31;
	    l_adj_tbl(l_source_counter).attribute32          	:= l_api_rec.attribute32;
	    l_adj_tbl(l_source_counter).attribute33          	:= l_api_rec.attribute33;
	    l_adj_tbl(l_source_counter).attribute34          	:= l_api_rec.attribute34;
	    l_adj_tbl(l_source_counter).attribute35          	:= l_api_rec.attribute35;
	    l_adj_tbl(l_source_counter).attribute36          	:= l_api_rec.attribute36;
	    l_adj_tbl(l_source_counter).attribute37          	:= l_api_rec.attribute37;
	    l_adj_tbl(l_source_counter).attribute38          	:= l_api_rec.attribute38;
	    l_adj_tbl(l_source_counter).attribute39          	:= l_api_rec.attribute39;
	    l_adj_tbl(l_source_counter).attribute40          	:= l_api_rec.attribute40;
	    l_adj_tbl(l_source_counter).attribute41          	:= l_api_rec.attribute41;
	    l_adj_tbl(l_source_counter).attribute42          	:= l_api_rec.attribute42;
	    l_adj_tbl(l_source_counter).attribute43          	:= l_api_rec.attribute43;
	    l_adj_tbl(l_source_counter).attribute44          	:= l_api_rec.attribute44;
	    l_adj_tbl(l_source_counter).attribute45          	:= l_api_rec.attribute45;
	    l_adj_tbl(l_source_counter).attribute46          	:= l_api_rec.attribute46;
	    l_adj_tbl(l_source_counter).attribute47          	:= l_api_rec.attribute47;
	    l_adj_tbl(l_source_counter).attribute48          	:= l_api_rec.attribute48;
	    l_adj_tbl(l_source_counter).attribute49          	:= l_api_rec.attribute49;
	    l_adj_tbl(l_source_counter).attribute50          	:= l_api_rec.attribute50;
	    l_adj_tbl(l_source_counter).attribute51          	:= l_api_rec.attribute51;
	    l_adj_tbl(l_source_counter).attribute52          	:= l_api_rec.attribute52;
	    l_adj_tbl(l_source_counter).attribute53          	:= l_api_rec.attribute53;
	    l_adj_tbl(l_source_counter).attribute54          	:= l_api_rec.attribute54;
	    l_adj_tbl(l_source_counter).attribute55          	:= l_api_rec.attribute55;
	    l_adj_tbl(l_source_counter).attribute56          	:= l_api_rec.attribute56;
	    l_adj_tbl(l_source_counter).attribute57          	:= l_api_rec.attribute57;
	    l_adj_tbl(l_source_counter).attribute58          	:= l_api_rec.attribute58;
	    l_adj_tbl(l_source_counter).attribute59          	:= l_api_rec.attribute59;
	    l_adj_tbl(l_source_counter).attribute60          	:= l_api_rec.attribute60;
	    l_adj_tbl(l_source_counter).attribute61          	:= l_api_rec.attribute61;
	    l_adj_tbl(l_source_counter).attribute62          	:= l_api_rec.attribute62;
	    l_adj_tbl(l_source_counter).attribute63          	:= l_api_rec.attribute63;
	    l_adj_tbl(l_source_counter).attribute64          	:= l_api_rec.attribute64;
	    l_adj_tbl(l_source_counter).attribute65          	:= l_api_rec.attribute65;
	    l_adj_tbl(l_source_counter).attribute66          	:= l_api_rec.attribute66;
	    l_adj_tbl(l_source_counter).attribute67          	:= l_api_rec.attribute67;
	    l_adj_tbl(l_source_counter).attribute68          	:= l_api_rec.attribute68;
	    l_adj_tbl(l_source_counter).attribute69          	:= l_api_rec.attribute69;
	    l_adj_tbl(l_source_counter).attribute70          	:= l_api_rec.attribute70;
	    l_adj_tbl(l_source_counter).attribute71          	:= l_api_rec.attribute71;
	    l_adj_tbl(l_source_counter).attribute72          	:= l_api_rec.attribute72;
	    l_adj_tbl(l_source_counter).attribute73          	:= l_api_rec.attribute73;
	    l_adj_tbl(l_source_counter).attribute74          	:= l_api_rec.attribute74;
	    l_adj_tbl(l_source_counter).attribute75          	:= l_api_rec.attribute75;
	    l_adj_tbl(l_source_counter).attribute76          	:= l_api_rec.attribute76;
	    l_adj_tbl(l_source_counter).attribute77          	:= l_api_rec.attribute77;
	    l_adj_tbl(l_source_counter).attribute78          	:= l_api_rec.attribute78;
	    l_adj_tbl(l_source_counter).attribute79          	:= l_api_rec.attribute79;
	    l_adj_tbl(l_source_counter).attribute80          	:= l_api_rec.attribute80;
	    l_adj_tbl(l_source_counter).attribute81          	:= l_api_rec.attribute81;
	    l_adj_tbl(l_source_counter).attribute82          	:= l_api_rec.attribute82;
	    l_adj_tbl(l_source_counter).attribute83          	:= l_api_rec.attribute83;
	    l_adj_tbl(l_source_counter).attribute84          	:= l_api_rec.attribute84;
	    l_adj_tbl(l_source_counter).attribute85          	:= l_api_rec.attribute85;
	    l_adj_tbl(l_source_counter).attribute86          	:= l_api_rec.attribute86;
	    l_adj_tbl(l_source_counter).attribute87          	:= l_api_rec.attribute87;
	    l_adj_tbl(l_source_counter).attribute88          	:= l_api_rec.attribute88;
	    l_adj_tbl(l_source_counter).attribute89          	:= l_api_rec.attribute89;
	    l_adj_tbl(l_source_counter).attribute90          	:= l_api_rec.attribute90;
	    l_adj_tbl(l_source_counter).attribute91          	:= l_api_rec.attribute91;
	    l_adj_tbl(l_source_counter).attribute92          	:= l_api_rec.attribute92;
	    l_adj_tbl(l_source_counter).attribute93          	:= l_api_rec.attribute93;
	    l_adj_tbl(l_source_counter).attribute94          	:= l_api_rec.attribute94;
	    l_adj_tbl(l_source_counter).attribute95          	:= l_api_rec.attribute95;
	    l_adj_tbl(l_source_counter).attribute96          	:= l_api_rec.attribute96;
	    l_adj_tbl(l_source_counter).attribute97          	:= l_api_rec.attribute97;
	    l_adj_tbl(l_source_counter).attribute98          	:= l_api_rec.attribute98;
	    l_adj_tbl(l_source_counter).attribute99          	:= l_api_rec.attribute99;
	    l_adj_tbl(l_source_counter).attribute100         	:= l_api_rec.attribute100;
	    l_adj_tbl(l_source_counter).quota_id 		:= l_api_rec.quota_id;
	    l_adj_tbl(l_source_counter).revenue_class_id 	:= l_api_rec.revenue_class_id;
	    l_adj_tbl(l_source_counter).revenue_class_name 	:= l_api_rec.revenue_class_name;
	    l_adj_tbl(l_source_counter).source_trx_number 	:= l_api_rec.source_trx_number;
	    l_adj_tbl(l_source_counter).comm_lines_api_id 	:= l_api_rec.comm_lines_api_id;
	    l_adj_tbl(l_source_counter).source_doc_type 	:= l_api_rec.source_doc_type;
	    l_adj_tbl(l_source_counter).upside_amount 		:= l_api_rec.upside_amount;
	    l_adj_tbl(l_source_counter).upside_quantity 	:= l_api_rec.upside_quantity;
	    l_adj_tbl(l_source_counter).uom_code 		:= l_api_rec.uom_code;
	    l_adj_tbl(l_source_counter).forecast_id 		:= l_api_rec.forecast_id;
	    l_adj_tbl(l_source_counter).adj_comm_lines_api_id 	:= l_api_rec.adj_comm_lines_api_id;
	    l_adj_tbl(l_source_counter).invoice_number 		:= l_api_rec.invoice_number;
	    l_adj_tbl(l_source_counter).invoice_date 		:= l_api_rec.invoice_date;
	    l_adj_tbl(l_source_counter).order_number 		:= l_api_rec.order_number;
	    l_adj_tbl(l_source_counter).order_date 		:= l_api_rec.booked_date;
	    l_adj_tbl(l_source_counter).line_number 		:= l_api_rec.line_number;
	    l_adj_tbl(l_source_counter).customer_id 		:= l_api_rec.customer_id;
	    l_adj_tbl(l_source_counter).bill_to_address_id 	:= l_api_rec.bill_to_address_id;
	    l_adj_tbl(l_source_counter).ship_to_address_id 	:= l_api_rec.ship_to_address_id;
	    l_adj_tbl(l_source_counter).bill_to_contact_id 	:= l_api_rec.bill_to_contact_id;
	    l_adj_tbl(l_source_counter).ship_to_contact_id 	:= l_api_rec.ship_to_contact_id;
	    l_adj_tbl(l_source_counter).load_status 		:= l_api_rec.load_status;
	    l_adj_tbl(l_source_counter).revenue_type_disp 	:= l_api_rec.revenue_type_disp;
	    l_adj_tbl(l_source_counter).revenue_type 		:= l_api_rec.revenue_type;
	    l_adj_tbl(l_source_counter).adjust_rollup_flag 	:= l_api_rec.adjust_rollup_flag;
	    l_adj_tbl(l_source_counter).adjust_date 		:= l_api_rec.adjust_date;
	    l_adj_tbl(l_source_counter).adjusted_by 		:= l_api_rec.adjusted_by;
	    l_adj_tbl(l_source_counter).adjust_status_disp 	:= l_api_rec.adjust_status_disp;
	    l_adj_tbl(l_source_counter).adjust_status 		:= NVL(l_api_rec.adjust_status,'NEW');
	    l_adj_tbl(l_source_counter).adjust_comments 	:= l_api_rec.adjust_comments;
	    l_adj_tbl(l_source_counter).type 			:= l_api_rec.type;
	    l_adj_tbl(l_source_counter).pre_processed_code 	:= l_api_rec.pre_processed_code;
	    l_adj_tbl(l_source_counter).comp_group_id 		:= l_api_rec.comp_group_id;
	    l_adj_tbl(l_source_counter).srp_plan_assign_id 	:= l_api_rec.srp_plan_assign_id;
	    l_adj_tbl(l_source_counter).role_id 		:= l_api_rec.role_id;
	    l_adj_tbl(l_source_counter).sales_channel 		:= l_api_rec.sales_channel;
	    l_adj_tbl(l_source_counter).object_version_number	:= l_api_rec.object_version_number;
	    l_adj_tbl(l_source_counter).split_pct	  	:= l_api_rec.split_pct;
	    l_adj_tbl(l_source_counter).split_status		:= l_api_rec.split_status;
        l_adj_tbl(l_source_counter).inventory_item_id	:= l_api_rec.inventory_item_id;
	l_adj_tbl(l_source_counter).org_id			:= l_api_rec.org_id;
	-- Bug fix 5349170
	l_adj_tbl(l_source_counter).trx_id			:= l_api_rec.trx_id;
	l_adj_tbl(l_source_counter).trx_line_id			:= l_api_rec.trx_line_id;
	l_adj_tbl(l_source_counter).trx_sales_line_id		:= l_api_rec.trx_sales_line_id;

	l_adj_tbl(l_source_counter).source_trx_id		:= l_api_rec.source_trx_id;
	l_adj_tbl(l_source_counter).source_trx_line_id		:= l_api_rec.source_trx_line_id;
	l_adj_tbl(l_source_counter).source_trx_sales_line_id	:= l_api_rec.source_trx_sales_line_id;
	-- Bug fix 5349170

	   l_adj_tbl(l_source_counter).terr_id	:= l_api_rec.terr_id;
	   l_adj_tbl(l_source_counter).preserve_credit_override_flag	:= NVL(l_api_rec.preserve_credit_override_flag,'N');


      END LOOP;
   END IF;

   IF (l_source_counter = 0) THEN
      x_return_status	:= 'NO DATA';
      x_source_counter	:= l_source_counter;
   ELSE
      x_adj_tbl		:= l_adj_tbl;
      x_source_counter	:= l_source_counter;
      x_return_status	:= 'SUCCESS';
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_return_status	:= 'ERROR';
      --cn_mass_adjust_util.my_debug(SQLERRM);
      x_source_counter	:= l_source_counter;
END;
--
PROCEDURE convert_rec_to_tbl(
   p_srch_attr_rec      IN      cn_get_tx_data_pub.adj_rec_type,
   x_attribute_tbl OUT NOCOPY cn_get_tx_data_pub.attribute_tbl) IS
   --
   l_counter		NUMBER := 1;
   --
BEGIN
   x_attribute_tbl(1).attribute_name 	:= NULL;
   x_attribute_tbl(1).attribute_value	:= NULL;
   l_counter := l_counter + 1;
   IF (p_srch_attr_rec.attribute1 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE1';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute1;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute2 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE2';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute2;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute3 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE3';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute3;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute4 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE4';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute4;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute5 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE5';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute5;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute6 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE6';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute6;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute7 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE7';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute7;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute8 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE8';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute8;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute9 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE9';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute9;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute10 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE10';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute10;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute11 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE11';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute11;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute12 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE12';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute12;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute13 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE13';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute13;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute14 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE14';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute14;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute15 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE15';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute15;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute16 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE16';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute16;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute17 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE17';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute17;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute18 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE18';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute18;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute19 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE19';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute19;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute20 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE20';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute20;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute21 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE21';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute21;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute22 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE22';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute22;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute23 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE23';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute23;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute24 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE24';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute24;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute25 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE25';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute25;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute26 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE26';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute26;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute27 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE27';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute27;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute28 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE28';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute28;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute29 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE29';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute29;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute30 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE30';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute30;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute31 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE31';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute31;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute32 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE32';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute32;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute33 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE33';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute33;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute34 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE34';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute34;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute35 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE35';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute35;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute36 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE36';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute36;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute37 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE37';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute37;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute38 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE38';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute38;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute39 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE39';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute39;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute40 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE40';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute40;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute41 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE41';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute41;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute42 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE42';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute42;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute43 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE43';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute43;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute44 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE44';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute44;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute45 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE45';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute45;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute46 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE46';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute46;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute47 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE47';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute47;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute48 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE48';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute48;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute49 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE49';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute49;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute50 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE50';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute50;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute51 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE51';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute51;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute52 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE52';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute52;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute53 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE53';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute53;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute54 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE54';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute54;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute55 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE55';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute55;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute56 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE56';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute56;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute57 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE57';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute57;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute58 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE58';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute58;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute59 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE59';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute59;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute60 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE60';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute60;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute61 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE61';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute61;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute62 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE62';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute62;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute63 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE63';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute63;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute64 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE64';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute64;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute65 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE65';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute65;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute66 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE66';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute66;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute67 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE67';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute67;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute68 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE68';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute68;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute69 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE69';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute69;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute70 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE70';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute70;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute71 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE71';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute71;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute72 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE72';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute72;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute73 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE73';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute73;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute74 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE74';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute74;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute75 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE75';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute75;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute76 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE76';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute76;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute77 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE77';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute77;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute78 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE78';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute78;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute79 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE79';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute79;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute80 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE80';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute80;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute81 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE81';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute81;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute82 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE82';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute82;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute83 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE83';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute83;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute84 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE84';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute84;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute85 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE85';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute85;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute86 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE86';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute86;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute87 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE87';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute87;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute88 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE88';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute88;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute89 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE89';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute89;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute90 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE90';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute90;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute91 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE91';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute91;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute92 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE92';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute92;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute93 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE93';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute93;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute94 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE94';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute94;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute95 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE95';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute95;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute96 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE96';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute96;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute97 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE97';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute97;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute98 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE98';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute98;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute99 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE99';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute99;
      l_counter := l_counter + 1;
   END IF;
   IF (p_srch_attr_rec.attribute100 <> FND_API.G_MISS_CHAR) THEN
      x_attribute_tbl(l_counter).attribute_name := 'ATTRIBUTE100';
      x_attribute_tbl(l_counter).attribute_value := p_srch_attr_rec.attribute100;
      l_counter := l_counter + 1;
   END IF;
END;

PROCEDURE convert_rec_to_gmiss(
	p_rec      	IN      cn_get_tx_data_pub.adj_rec_type,
   	x_api_rec	    OUT NOCOPY cn_get_tx_data_pub.adj_rec_type) IS

BEGIN

     SELECT  DECODE(p_rec.direct_salesrep_id, null, fnd_api.g_miss_num, p_rec.direct_salesrep_id),
	           DECODE(p_rec.processed_date, null, fnd_api.g_miss_date, p_rec.processed_date),
	    	   DECODE(p_rec.processed_period_id, null, fnd_api.g_miss_num, p_rec.processed_period_id),
	    	   DECODE(p_rec.transaction_amount, null, fnd_api.g_miss_num, p_rec.transaction_amount),
	    	   DECODE(p_rec.trx_type, null, fnd_api.g_miss_char,p_rec.trx_type),
	    	   DECODE(p_rec.revenue_class_id, null, fnd_api.g_miss_num, p_rec.revenue_class_id),
		   DECODE(p_rec.load_status, null, fnd_api.g_miss_char, p_rec.load_status),
	    	   DECODE(p_rec.attribute1,null, fnd_api.g_miss_char, p_rec.attribute1),
	    	   DECODE(p_rec.attribute2,null, fnd_api.g_miss_char, p_rec.attribute2),
	    	   DECODE(p_rec.attribute3,null, fnd_api.g_miss_char, p_rec.attribute3),
	    	   DECODE(p_rec.attribute4,null, fnd_api.g_miss_char, p_rec.attribute4),
	    	   DECODE(p_rec.attribute5,null, fnd_api.g_miss_char, p_rec.attribute5),
	    	   DECODE(p_rec.attribute6,null, fnd_api.g_miss_char, p_rec.attribute6),
	    	   DECODE(p_rec.attribute7,null, fnd_api.g_miss_char, p_rec.attribute7),
               DECODE(p_rec.attribute8,null, fnd_api.g_miss_char, p_rec.attribute8),
               DECODE(p_rec.attribute9,null, fnd_api.g_miss_char, p_rec.attribute9),
               DECODE(p_rec.attribute10,null, fnd_api.g_miss_char, p_rec.attribute10),
               DECODE(p_rec.attribute11,null, fnd_api.g_miss_char, p_rec.attribute11),
	    	   DECODE(p_rec.attribute12,null, fnd_api.g_miss_char, p_rec.attribute12),
	    	   DECODE(p_rec.attribute13,null, fnd_api.g_miss_char, p_rec.attribute13),
	    	   DECODE(p_rec.attribute14,null, fnd_api.g_miss_char, p_rec.attribute14),
	    	   DECODE(p_rec.attribute15,null, fnd_api.g_miss_char, p_rec.attribute15),
	    	   DECODE(p_rec.attribute16,null, fnd_api.g_miss_char, p_rec.attribute16),
	    	   DECODE(p_rec.attribute17,null, fnd_api.g_miss_char, p_rec.attribute17),
               DECODE(p_rec.attribute18,null, fnd_api.g_miss_char, p_rec.attribute18),
               DECODE(p_rec.attribute19,null, fnd_api.g_miss_char, p_rec.attribute19),
               DECODE(p_rec.attribute20,null, fnd_api.g_miss_char, p_rec.attribute20),
               DECODE(p_rec.attribute21,null, fnd_api.g_miss_char, p_rec.attribute21),
	    	   DECODE(p_rec.attribute22,null, fnd_api.g_miss_char, p_rec.attribute22),
	    	   DECODE(p_rec.attribute23,null, fnd_api.g_miss_char, p_rec.attribute23),
	    	   DECODE(p_rec.attribute24,null, fnd_api.g_miss_char, p_rec.attribute24),
	    	   DECODE(p_rec.attribute25,null, fnd_api.g_miss_char, p_rec.attribute25),
	    	   DECODE(p_rec.attribute26,null, fnd_api.g_miss_char, p_rec.attribute26),
	    	   DECODE(p_rec.attribute27,null, fnd_api.g_miss_char, p_rec.attribute27),
               DECODE(p_rec.attribute28,null, fnd_api.g_miss_char, p_rec.attribute28),
               DECODE(p_rec.attribute29,null, fnd_api.g_miss_char, p_rec.attribute29),
               DECODE(p_rec.attribute30,null, fnd_api.g_miss_char, p_rec.attribute30),
               DECODE(p_rec.attribute31,null, fnd_api.g_miss_char, p_rec.attribute31),
	    	   DECODE(p_rec.attribute32,null, fnd_api.g_miss_char, p_rec.attribute32),
	    	   DECODE(p_rec.attribute33,null, fnd_api.g_miss_char, p_rec.attribute33),
	    	   DECODE(p_rec.attribute34,null, fnd_api.g_miss_char, p_rec.attribute34),
	    	   DECODE(p_rec.attribute35,null, fnd_api.g_miss_char, p_rec.attribute35),
	    	   DECODE(p_rec.attribute36,null, fnd_api.g_miss_char, p_rec.attribute36),
	    	   DECODE(p_rec.attribute37,null, fnd_api.g_miss_char, p_rec.attribute37),
               DECODE(p_rec.attribute38,null, fnd_api.g_miss_char, p_rec.attribute38),
               DECODE(p_rec.attribute39,null, fnd_api.g_miss_char, p_rec.attribute39),
               DECODE(p_rec.attribute40,null, fnd_api.g_miss_char, p_rec.attribute40),
               DECODE(p_rec.attribute41,null, fnd_api.g_miss_char, p_rec.attribute41),
	    	   DECODE(p_rec.attribute42,null, fnd_api.g_miss_char, p_rec.attribute42),
	    	   DECODE(p_rec.attribute43,null, fnd_api.g_miss_char, p_rec.attribute43),
	    	   DECODE(p_rec.attribute44,null, fnd_api.g_miss_char, p_rec.attribute44),
	    	   DECODE(p_rec.attribute45,null, fnd_api.g_miss_char, p_rec.attribute45),
	    	   DECODE(p_rec.attribute46,null, fnd_api.g_miss_char, p_rec.attribute46),
	    	   DECODE(p_rec.attribute47,null, fnd_api.g_miss_char, p_rec.attribute47),
               DECODE(p_rec.attribute48,null, fnd_api.g_miss_char, p_rec.attribute48),
               DECODE(p_rec.attribute49,null, fnd_api.g_miss_char, p_rec.attribute49),
               DECODE(p_rec.attribute50,null, fnd_api.g_miss_char, p_rec.attribute50),
               DECODE(p_rec.attribute51,null, fnd_api.g_miss_char, p_rec.attribute51),
	    	   DECODE(p_rec.attribute52,null, fnd_api.g_miss_char, p_rec.attribute52),
	    	   DECODE(p_rec.attribute53,null, fnd_api.g_miss_char, p_rec.attribute53),
	    	   DECODE(p_rec.attribute54,null, fnd_api.g_miss_char, p_rec.attribute54),
	    	   DECODE(p_rec.attribute55,null, fnd_api.g_miss_char, p_rec.attribute55),
	    	   DECODE(p_rec.attribute56,null, fnd_api.g_miss_char, p_rec.attribute56),
	    	   DECODE(p_rec.attribute57,null, fnd_api.g_miss_char, p_rec.attribute57),
               DECODE(p_rec.attribute58,null, fnd_api.g_miss_char, p_rec.attribute58),
               DECODE(p_rec.attribute59,null, fnd_api.g_miss_char, p_rec.attribute59),
               DECODE(p_rec.attribute60,null, fnd_api.g_miss_char, p_rec.attribute60),
               DECODE(p_rec.attribute61,null, fnd_api.g_miss_char, p_rec.attribute61),
	    	   DECODE(p_rec.attribute62,null, fnd_api.g_miss_char, p_rec.attribute62),
	    	   DECODE(p_rec.attribute63,null, fnd_api.g_miss_char, p_rec.attribute63),
	    	   DECODE(p_rec.attribute64,null, fnd_api.g_miss_char, p_rec.attribute64),
	    	   DECODE(p_rec.attribute65,null, fnd_api.g_miss_char, p_rec.attribute65),
	    	   DECODE(p_rec.attribute66,null, fnd_api.g_miss_char, p_rec.attribute66),
	    	   DECODE(p_rec.attribute67,null, fnd_api.g_miss_char, p_rec.attribute67),
               DECODE(p_rec.attribute68,null, fnd_api.g_miss_char, p_rec.attribute68),
               DECODE(p_rec.attribute69,null, fnd_api.g_miss_char, p_rec.attribute69),
               DECODE(p_rec.attribute70,null, fnd_api.g_miss_char, p_rec.attribute70),
               DECODE(p_rec.attribute71,null, fnd_api.g_miss_char, p_rec.attribute71),
	    	   DECODE(p_rec.attribute72,null, fnd_api.g_miss_char, p_rec.attribute72),
	    	   DECODE(p_rec.attribute73,null, fnd_api.g_miss_char, p_rec.attribute73),
	    	   DECODE(p_rec.attribute74,null, fnd_api.g_miss_char, p_rec.attribute74),
	    	   DECODE(p_rec.attribute75,null, fnd_api.g_miss_char, p_rec.attribute75),
	    	   DECODE(p_rec.attribute76,null, fnd_api.g_miss_char, p_rec.attribute76),
	    	   DECODE(p_rec.attribute77,null, fnd_api.g_miss_char, p_rec.attribute77),
               DECODE(p_rec.attribute78,null, fnd_api.g_miss_char, p_rec.attribute78),
               DECODE(p_rec.attribute79,null, fnd_api.g_miss_char, p_rec.attribute79),
               DECODE(p_rec.attribute80,null, fnd_api.g_miss_char, p_rec.attribute80),
               DECODE(p_rec.attribute81,null, fnd_api.g_miss_char, p_rec.attribute81),
	    	   DECODE(p_rec.attribute82,null, fnd_api.g_miss_char, p_rec.attribute82),
	    	   DECODE(p_rec.attribute83,null, fnd_api.g_miss_char, p_rec.attribute83),
	    	   DECODE(p_rec.attribute84,null, fnd_api.g_miss_char, p_rec.attribute84),
	    	   DECODE(p_rec.attribute85,null, fnd_api.g_miss_char, p_rec.attribute85),
	    	   DECODE(p_rec.attribute86,null, fnd_api.g_miss_char, p_rec.attribute86),
	    	   DECODE(p_rec.attribute87,null, fnd_api.g_miss_char, p_rec.attribute87),
               DECODE(p_rec.attribute88,null, fnd_api.g_miss_char, p_rec.attribute88),
               DECODE(p_rec.attribute89,null, fnd_api.g_miss_char, p_rec.attribute89),
               DECODE(p_rec.attribute90,null, fnd_api.g_miss_char, p_rec.attribute90),
               DECODE(p_rec.attribute91,null, fnd_api.g_miss_char, p_rec.attribute91),
	    	   DECODE(p_rec.attribute92,null, fnd_api.g_miss_char, p_rec.attribute92),
	    	   DECODE(p_rec.attribute93,null, fnd_api.g_miss_char, p_rec.attribute93),
	    	   DECODE(p_rec.attribute94,null, fnd_api.g_miss_char, p_rec.attribute94),
	    	   DECODE(p_rec.attribute95,null, fnd_api.g_miss_char, p_rec.attribute95),
	    	   DECODE(p_rec.attribute96,null, fnd_api.g_miss_char, p_rec.attribute96),
	    	   DECODE(p_rec.attribute97,null, fnd_api.g_miss_char, p_rec.attribute97),
               DECODE(p_rec.attribute98,null, fnd_api.g_miss_char, p_rec.attribute98),
               DECODE(p_rec.attribute99,null, fnd_api.g_miss_char, p_rec.attribute99),
               DECODE(p_rec.attribute100,null, fnd_api.g_miss_char, p_rec.attribute100),
		   DECODE(p_rec.direct_salesrep_number,null,fnd_api.g_miss_char, p_rec.direct_salesrep_number),
		DECODE(p_rec.comm_lines_api_id,null,fnd_api.g_miss_num, p_rec.comm_lines_api_id),
		   DECODE(p_rec.rollup_date,NULL, fnd_api.g_miss_date,
		          p_rec.rollup_date),
		   DECODE(p_rec.source_doc_type,NULL, fnd_api.g_miss_char,
		          p_rec.source_doc_type),
		   DECODE(p_rec.orig_currency_code,NULL, fnd_api.g_miss_char,
		          p_rec.orig_currency_code),
		   DECODE(p_rec.exchange_rate,NULL, fnd_api.g_miss_num,
		          p_rec.exchange_rate),
		   DECODE(p_rec.transaction_amount_orig,NULL, fnd_api.g_miss_num,
		          p_rec.transaction_amount_orig),
		   DECODE(p_rec.trx_id,NULL, fnd_api.g_miss_num,
		          p_rec.trx_id),
		   DECODE(p_rec.trx_line_id,NULL, fnd_api.g_miss_num,
		          p_rec.trx_line_id),
		   DECODE(p_rec.trx_sales_line_id,NULL, fnd_api.g_miss_num,
		          p_rec.trx_sales_line_id),
		   DECODE(p_rec.quantity,NULL, fnd_api.g_miss_num,
		          p_rec.quantity),
		   DECODE(p_rec.source_trx_number,NULL, fnd_api.g_miss_char,
		          p_rec.source_trx_number),
		   DECODE(p_rec.discount_percentage,NULL, fnd_api.g_miss_num,
		          p_rec.discount_percentage),
		   DECODE(p_rec.margin_percentage,NULL, fnd_api.g_miss_num,
		          p_rec.margin_percentage),
		   DECODE(p_rec.forecast_id,NULL, fnd_api.g_miss_num,
		          p_rec.forecast_id),
		   DECODE(p_rec.upside_quantity,NULL, fnd_api.g_miss_num,
		          p_rec.upside_quantity),
		   DECODE(p_rec.upside_amount,NULL, fnd_api.g_miss_num,
		          p_rec.upside_amount),
		   DECODE(p_rec.uom_code,NULL, fnd_api.g_miss_char,
		          p_rec.uom_code),
		DECODE(p_rec.source_trx_id,NULL, fnd_api.g_miss_num,
		          p_rec.source_trx_id),
		DECODE(p_rec.source_trx_line_id,NULL, fnd_api.g_miss_num,
		          p_rec.source_trx_line_id),
		DECODE(p_rec.source_trx_sales_line_id,NULL, fnd_api.g_miss_num,
		          p_rec.source_trx_sales_line_id),
		   DECODE(p_rec.customer_id, NULL, fnd_api.g_miss_num, p_rec.customer_id),
                   DECODE(p_rec.inventory_item_id, NULL, fnd_api.g_miss_num,p_rec.inventory_item_id),
		   DECODE(p_rec.order_number,NULL, fnd_api.g_miss_num,
		          p_rec.order_number),
		   DECODE(p_rec.order_date,NULL, fnd_api.g_miss_date,
		          p_rec.order_date),
		   DECODE(p_rec.invoice_number,NULL, fnd_api.g_miss_char,
		          p_rec.invoice_number),
		   DECODE(p_rec.invoice_date,NULL, fnd_api.g_miss_date,
		          p_rec.invoice_date),
		   DECODE(p_rec.bill_to_address_id,NULL, fnd_api.g_miss_num,
		          p_rec.bill_to_address_id),
		   DECODE(p_rec.ship_to_address_id,NULL, fnd_api.g_miss_num,
		          p_rec.ship_to_address_id),
		   DECODE(p_rec.bill_to_contact_id,NULL, fnd_api.g_miss_num,
		          p_rec.bill_to_contact_id),
		   DECODE(p_rec.ship_to_contact_id,NULL, fnd_api.g_miss_num,
		          p_rec.ship_to_contact_id),
		   DECODE(p_rec.adj_comm_lines_api_id,NULL, fnd_api.g_miss_num,
		          p_rec.adj_comm_lines_api_id),
		   DECODE(p_rec.adjust_date,NULL, fnd_api.g_miss_date,
		          p_rec.adjust_date),
		   DECODE(p_rec.adjusted_by,NULL, fnd_api.g_miss_char,
		          p_rec.adjusted_by),
		   DECODE(p_rec.revenue_type,NULL, fnd_api.g_miss_char,
		          p_rec.revenue_type),
		   DECODE(p_rec.adjust_rollup_flag,NULL, fnd_api.g_miss_char,
		          p_rec.adjust_rollup_flag),
		   DECODE(p_rec.adjust_comments,NULL, fnd_api.g_miss_char,
		          p_rec.adjust_comments),
		   NVL(DECODE(p_rec.adjust_status,NULL, fnd_api.g_miss_char,
		          p_rec.adjust_status),'NEW'),
		   DECODE(p_rec.line_number,NULL, fnd_api.g_miss_num,
		          p_rec.line_number),
		   DECODE(p_rec.reason_code,NULL, fnd_api.g_miss_char,
		          p_rec.reason_code),
		   DECODE(p_rec.attribute_category,NULL, fnd_api.g_miss_char,
		          p_rec.attribute_category),
		   DECODE(p_rec.type,NULL, fnd_api.g_miss_char,
		          p_rec.type),
		   DECODE(p_rec.pre_processed_code,NULL, fnd_api.g_miss_char,
		          p_rec.pre_processed_code),
		   DECODE(p_rec.quota_id,NULL, fnd_api.g_miss_num,
		          p_rec.quota_id),
		   DECODE(p_rec.srp_plan_assign_id,NULL, fnd_api.g_miss_num,
		          p_rec.srp_plan_assign_id),
		   DECODE(p_rec.role_id,NULL, fnd_api.g_miss_num,
		          p_rec.role_id),
		   DECODE(p_rec.comp_group_id,NULL, fnd_api.g_miss_num,
		          p_rec.comp_group_id),
		   DECODE(p_rec.commission_amount,NULL, fnd_api.g_miss_num,
		          p_rec.commission_amount),
		   DECODE(p_rec.sales_channel,NULL, fnd_api.g_miss_char,
		          p_rec.sales_channel),
		   DECODE(p_rec.split_pct,NULL, fnd_api.g_miss_num,
		          p_rec.split_pct),
		   DECODE(p_rec.split_status,NULL, fnd_api.g_miss_char,
		          p_rec.split_status),
           DECODE(p_rec.org_id,NULL, fnd_api.g_miss_num,
			  p_rec.org_id),
           DECODE(p_rec.terr_id,NULL, fnd_api.g_miss_num,
			  p_rec.terr_id),
           NVL(DECODE(p_rec.preserve_credit_override_flag,NULL, fnd_api.g_miss_char,
			  p_rec.preserve_credit_override_flag),'N')
	      INTO x_api_rec.direct_salesrep_id,x_api_rec.processed_date,
                   x_api_rec.processed_period_id,x_api_rec.transaction_amount,
                   x_api_rec.trx_type,x_api_rec.revenue_class_id,
                   x_api_rec.load_status,
	           x_api_rec.attribute1,x_api_rec.attribute2,
	           x_api_rec.attribute3,x_api_rec.attribute4,
	           x_api_rec.attribute5,x_api_rec.attribute6,
	           x_api_rec.attribute7,x_api_rec.attribute8,
	           x_api_rec.attribute9,x_api_rec.attribute10,
	           x_api_rec.attribute11,x_api_rec.attribute12,
	           x_api_rec.attribute13,x_api_rec.attribute14,
	           x_api_rec.attribute15,x_api_rec.attribute16,
	           x_api_rec.attribute17,x_api_rec.attribute18,
	           x_api_rec.attribute19,x_api_rec.attribute20,
	           x_api_rec.attribute21,x_api_rec.attribute22,
	           x_api_rec.attribute23,x_api_rec.attribute24,
	           x_api_rec.attribute25,x_api_rec.attribute26,
	           x_api_rec.attribute27,x_api_rec.attribute28,
	           x_api_rec.attribute29,x_api_rec.attribute30,
	           x_api_rec.attribute31,x_api_rec.attribute32,
	           x_api_rec.attribute33,x_api_rec.attribute34,
	           x_api_rec.attribute35,x_api_rec.attribute36,
	           x_api_rec.attribute37,x_api_rec.attribute38,
	           x_api_rec.attribute39,x_api_rec.attribute40,
	           x_api_rec.attribute41,x_api_rec.attribute42,
	           x_api_rec.attribute43,x_api_rec.attribute44,
	           x_api_rec.attribute45,x_api_rec.attribute46,
	           x_api_rec.attribute47,x_api_rec.attribute48,
	           x_api_rec.attribute49,x_api_rec.attribute50,
	           x_api_rec.attribute51,x_api_rec.attribute52,
	           x_api_rec.attribute53,x_api_rec.attribute54,
	           x_api_rec.attribute55,x_api_rec.attribute56,
	           x_api_rec.attribute57,x_api_rec.attribute58,
	           x_api_rec.attribute59,x_api_rec.attribute60,
	           x_api_rec.attribute61,x_api_rec.attribute62,
	           x_api_rec.attribute63,x_api_rec.attribute64,
	           x_api_rec.attribute65,x_api_rec.attribute66,
	           x_api_rec.attribute67,x_api_rec.attribute68,
	           x_api_rec.attribute69,x_api_rec.attribute70,
	           x_api_rec.attribute71,x_api_rec.attribute72,
	           x_api_rec.attribute73,x_api_rec.attribute74,
	           x_api_rec.attribute75,x_api_rec.attribute76,
	           x_api_rec.attribute77,x_api_rec.attribute78,
	           x_api_rec.attribute79,x_api_rec.attribute80,
	           x_api_rec.attribute81,x_api_rec.attribute82,
	           x_api_rec.attribute83,x_api_rec.attribute84,
	           x_api_rec.attribute85,x_api_rec.attribute86,
	           x_api_rec.attribute87,x_api_rec.attribute88,
	           x_api_rec.attribute89,x_api_rec.attribute90,
	           x_api_rec.attribute91,x_api_rec.attribute92,
	           x_api_rec.attribute93,x_api_rec.attribute94,
	           x_api_rec.attribute95,x_api_rec.attribute96,
	           x_api_rec.attribute97,x_api_rec.attribute98,
	           x_api_rec.attribute99,x_api_rec.attribute100,
                   x_api_rec.direct_salesrep_number,x_api_rec.comm_lines_api_id,
                   x_api_rec.rollup_date,
                   x_api_rec.source_doc_type,
                   x_api_rec.orig_currency_code,
                   x_api_rec.exchange_rate,
		   x_api_rec.transaction_amount_orig,
                   x_api_rec.trx_id,x_api_rec.trx_line_id,
                   x_api_rec.trx_sales_line_id,x_api_rec.quantity,
                   x_api_rec.source_trx_number,
                   x_api_rec.discount_percentage,
                   x_api_rec.margin_percentage,
            	   x_api_rec.forecast_id,
                   x_api_rec.upside_quantity,x_api_rec.upside_amount,
                   x_api_rec.uom_code,x_api_rec.source_trx_id,
                   x_api_rec.source_trx_line_id,
                   x_api_rec.source_trx_sales_line_id,
		   x_api_rec.customer_id,
                   x_api_rec.inventory_item_id,x_api_rec.order_number,
                   x_api_rec.order_date,x_api_rec.invoice_number,
                   x_api_rec.invoice_date,x_api_rec.bill_to_address_id,
                   x_api_rec.ship_to_address_id,x_api_rec.bill_to_contact_id,
                   x_api_rec.ship_to_contact_id,x_api_rec.adj_comm_lines_api_id,
                   x_api_rec.adjust_date,x_api_rec.adjusted_by,
                   x_api_rec.revenue_type,x_api_rec.adjust_rollup_flag,
                   x_api_rec.adjust_comments,x_api_rec.adjust_status,
                   x_api_rec.line_number,x_api_rec.reason_code,
                   x_api_rec.attribute_category,x_api_rec.type,
                   x_api_rec.pre_processed_code,x_api_rec.quota_id,
                   x_api_rec.srp_plan_assign_id,x_api_rec.role_id,
                   x_api_rec.comp_group_id,x_api_rec.commission_amount,
                   x_api_rec.sales_channel,x_api_rec.split_pct,
                   x_api_rec.split_status,
                   x_api_rec.org_id,
                   x_api_rec.terr_id,
                   x_api_rec.preserve_credit_override_flag
	      FROM DUAL;
END;
--
END;



/
