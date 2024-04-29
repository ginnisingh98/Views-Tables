--------------------------------------------------------
--  DDL for Package Body CN_ADJUSTMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_ADJUSTMENTS_PKG" AS
-- $Header: cntradjb.pls 120.10.12010000.5 2009/06/30 07:02:08 gmarwah ship $
-- +======================================================================+
-- |                Copyright (c) 1994 Oracle Corporation                 |
-- |                   Redwood Shores, California, USA                    |
-- |                        All rights reserved.                          |
-- +======================================================================+
--
-- Package Name
--   cn_adjustments_pkg
-- Purpose
--   Package spec for notifying orders
-- History
--   11/17/98   JPENDYAL        Created
--   07/22/04   HITHANKI        Modified For  Bug Fix : 3784174
--				Added Comma In GET_CUST_INFO Queries
--
  -- Jun 26, 2006   vensrini  Bug fix 5349170
  --


   G_PKG_NAME                  	CONSTANT VARCHAR2(30) := 'CN_ADJUSTMENTS_PKG';
   G_FILE_NAME                 	CONSTANT VARCHAR2(12) := 'cntradjb.pls';
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
PROCEDURE mass_adjust_build_query(
	x_where_clause 		VARCHAR2) IS
   --
   select_cursor   		NUMBER(15);
   sql_stmt			VARCHAR2(5000);
   count_rows 			NUMBER;
   l_comm_lines_api_id		NUMBER;
   i				BINARY_INTEGER := 1;
BEGIN
   select_cursor := DBMS_SQL.open_cursor;
   sql_stmt := 'SELECT COMM_LINES_API_ID FROM CN_ADJUSTMENTS_V WHERE ';
   sql_stmt := sql_stmt || x_where_clause;
   dbms_sql.parse(select_cursor,sql_stmt,DBMS_SQL.NATIVE);
   DBMS_SQL.define_column (select_cursor,1,l_comm_lines_api_id);
   count_rows := DBMS_SQL.execute (select_cursor);
   tab_mass_update_comm.delete;
   LOOP
      IF (dbms_sql.fetch_rows(select_cursor) > 0) THEN
         DBMS_SQL.column_value (select_cursor,1,l_comm_lines_api_id);
         tab_mass_update_comm(i) := l_comm_lines_api_id;
         i := i + 1;
      ELSE
         EXIT;
      END IF;
   END LOOP;
   DBMS_SQL.close_cursor(select_cursor);
END mass_adjust_build_query;
--

  --    Negate a transaction (original transaction t1)
  --    If t1 was in API table (not loaded) then
  --      1. adjust_status = 'FROZEN'
  --      2. load_status = 'OBSOLETE'
  --    ELSIF t1 was in HEADER table (loaded) then
  --      1. adjust_status = 'FROZEN'
  --      2. update reversal_header_id, reversal_flag for t1
  --      3. insert REVERSAL trx t1'  into API table

PROCEDURE api_negate_record(
  		x_comm_lines_api_id  	IN	NUMBER,
		x_adjusted_by		IN	VARCHAR2,
                x_adjust_comments    	IN	VARCHAR2,
		x_salesrep_number	IN	VARCHAR2 DEFAULT NULL) IS

  l_comm_lines_api_id         	NUMBER;
  --Added for Crediting issue
  l_terr_id                     NUMBER;
  l_org_id                      NUMBER;
  l_adjusted_by                 VARCHAR2(100);
  l_quantity   		      	NUMBER;
  l_transaction_amount	      	NUMBER;
  l_src_transaction_amount	NUMBER;
  l_acctd_transaction_amount  	NUMBER;
  l_negate_flag               	VARCHAR2(1);
  l_adjust_status             	VARCHAR2(20);
  l_adjust_date               	DATE := SYSDATE;
  l_status		      	VARCHAR2(10);
  l_reversal_header_id        	NUMBER;
  l_reversal_flag             	VARCHAR2(1);
  l_next_step			CHAR(1) := 'Y';
  l_load_status			cn_comm_lines_api.load_status%TYPE;
  l_trx_type			cn_commission_headers.trx_type%TYPE;
  l_transaction_amount_orig	cn_commission_headers.transaction_amount_orig%TYPE;
  -- PL/SQL tables/columns
  l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;
  -- Added for bug 7524578
  l_territory_id                NUMBER;
  l_terr_name                   VARCHAR2(2000);
  l_presrv_credit_override_flag VARCHAR2(1);
  --
CURSOR api_cur IS
   SELECT *
     FROM cn_comm_lines_api
    WHERE comm_lines_api_id = x_comm_lines_api_id;
--
CURSOR header_cur(l_commission_header_id	NUMBER) IS
   SELECT a.*,b.employee_number
     FROM cn_commission_headers a,
          cn_salesreps b
    WHERE a.direct_salesrep_id = b.salesrep_id
      AND commission_header_id = l_commission_header_id;

-- Added for bug 7524578
CURSOR api_cur_terr IS
   SELECT terr_id,terr_name,NVL(preserve_credit_override_flag,'N') preserve_credit_override_flag
     FROM cn_comm_lines_api
    WHERE comm_lines_api_id = x_comm_lines_api_id;

BEGIN
   -- First check whether the record is available in cn_comm_lines_api table.
   BEGIN
      SELECT adjust_status,load_status,quantity,
             acctd_transaction_amount,transaction_amount
	INTO l_adjust_status,l_load_status,l_quantity,
	     l_acctd_transaction_amount,l_transaction_amount
	FROM cn_comm_lines_api
       WHERE comm_lines_api_id = x_comm_lines_api_id
         AND load_status <> 'LOADED'
	 AND (adjust_status NOT IN ('FROZEN','REVERSAL')); -- OR
--	      adjust_status IS NULL);
            --
            UPDATE cn_comm_lines_api api
               SET load_status 		= 'OBSOLETE',
		   adjust_status 	= 'FROZEN',
		   adjust_date   	= l_adjust_date,
		   adjusted_by   	= x_adjusted_by,
		   adjust_comments 	= x_adjust_comments
	     WHERE comm_lines_api_id 	= x_comm_lines_api_id;
	    --
      l_next_step := 'N'; -- It need not check in cn_commission_headers table.
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;
   --

   FOR each_trx IN api_cur_terr
    LOOP
       l_territory_id                := each_trx.terr_id;
       l_terr_name                   := each_trx.terr_name;
       l_presrv_credit_override_flag := NVL(each_trx.preserve_credit_override_flag,'N');

    END LOOP;

   IF (l_next_step = 'Y') THEN
      BEGIN
         SELECT commission_header_id,adjust_status,quantity,trx_type,
                transaction_amount,transaction_amount_orig
	   INTO l_reversal_header_id,l_adjust_status,l_quantity,l_trx_type,
	        l_transaction_amount,l_transaction_amount_orig
	   FROM cn_commission_headers
          WHERE comm_lines_api_id = x_comm_lines_api_id
	    AND (adjust_status NOT IN ('FROZEN','REVERSAL')) -- OR
--	         adjust_status IS NULL)
	    AND trx_type NOT IN ('ITD','GRP','THR');
	    --
            l_quantity           	:= -1 * l_quantity;
	    l_src_transaction_amount 	:= -1 * NVL(l_transaction_amount_orig,0);
	    l_acctd_transaction_amount 	:= -1 * NVL(l_transaction_amount,0);
	    l_negate_flag        	:= 'Y';
	    l_adjust_status      	:= 'REVERSAL';
	    l_reversal_flag      	:= 'Y';
	    --
	    UPDATE cn_commission_headers
	       SET adjust_status 	= 'FROZEN',
		   reversal_header_id 	= l_reversal_header_id,
		   reversal_flag 	= l_reversal_flag,
		   adjust_date   	= l_adjust_date,
		   adjusted_by   	= x_adjusted_by,
		   adjust_comments 	= x_adjust_comments,
           -- clku, update the last updated info
           last_update_date = sysdate,
           last_updated_by = fnd_global.user_id,
           last_update_login = fnd_global.login_id
	     WHERE comm_lines_api_id 	= x_comm_lines_api_id;
	    FOR api_curs_rec IN header_cur(l_reversal_header_id)
	    LOOP
	       --
	       SELECT cn_comm_lines_api_s.NEXTVAL
	         INTO l_comm_lines_api_id
	         FROM dual;
	       --
               l_api_rec.salesrep_id			:= api_curs_rec.direct_salesrep_id;
               l_api_rec.processed_date			:= api_curs_rec.processed_date;
               l_api_rec.processed_period_id		:= api_curs_rec.processed_period_id;
               l_api_rec.transaction_amount		:= l_src_transaction_amount;
               l_api_rec.trx_type			:= api_curs_rec.trx_type;
               l_api_rec.revenue_class_id		:= api_curs_rec.revenue_class_id;
               l_api_rec.load_status			:= 'UNLOADED';
               l_api_rec.attribute1			:= api_curs_rec.attribute1;
               l_api_rec.attribute2			:= api_curs_rec.attribute2;
               l_api_rec.attribute3			:= api_curs_rec.attribute3;
               l_api_rec.attribute4			:= api_curs_rec.attribute4;
               l_api_rec.attribute5			:= api_curs_rec.attribute5;
               l_api_rec.attribute6			:= api_curs_rec.attribute6;
               l_api_rec.attribute7			:= api_curs_rec.attribute7;
               l_api_rec.attribute8			:= api_curs_rec.attribute8;
               l_api_rec.attribute9			:= api_curs_rec.attribute9;
               l_api_rec.attribute10			:= api_curs_rec.attribute10;
               l_api_rec.attribute11			:= api_curs_rec.attribute11;
               l_api_rec.attribute12			:= api_curs_rec.attribute12;
               l_api_rec.attribute13			:= api_curs_rec.attribute13;
               l_api_rec.attribute14			:= api_curs_rec.attribute14;
               l_api_rec.attribute15			:= api_curs_rec.attribute15;
               l_api_rec.attribute16			:= api_curs_rec.attribute16;
               l_api_rec.attribute17			:= api_curs_rec.attribute17;
               l_api_rec.attribute18			:= api_curs_rec.attribute18;
               l_api_rec.attribute19			:= api_curs_rec.attribute19;
               l_api_rec.attribute20			:= api_curs_rec.attribute20;
               l_api_rec.attribute21			:= api_curs_rec.attribute21;
               l_api_rec.attribute22			:= api_curs_rec.attribute22;
               l_api_rec.attribute23			:= api_curs_rec.attribute23;
               l_api_rec.attribute24			:= api_curs_rec.attribute24;
               l_api_rec.attribute25			:= api_curs_rec.attribute25;
               l_api_rec.attribute26			:= api_curs_rec.attribute26;
               l_api_rec.attribute27			:= api_curs_rec.attribute27;
               l_api_rec.attribute28			:= api_curs_rec.attribute28;
               l_api_rec.attribute29			:= api_curs_rec.attribute29;
               l_api_rec.attribute30			:= api_curs_rec.attribute30;
               l_api_rec.attribute31			:= api_curs_rec.attribute31;
               l_api_rec.attribute32			:= api_curs_rec.attribute32;
               l_api_rec.attribute33			:= api_curs_rec.attribute33;
               l_api_rec.attribute34			:= api_curs_rec.attribute34;
               l_api_rec.attribute35			:= api_curs_rec.attribute35;
               l_api_rec.attribute36			:= api_curs_rec.attribute36;
               l_api_rec.attribute37			:= api_curs_rec.attribute37;
               l_api_rec.attribute38			:= api_curs_rec.attribute38;
               l_api_rec.attribute39			:= api_curs_rec.attribute39;
               l_api_rec.attribute40			:= api_curs_rec.attribute40;
               l_api_rec.attribute41			:= api_curs_rec.attribute41;
               l_api_rec.attribute42			:= api_curs_rec.attribute42;
               l_api_rec.attribute43			:= api_curs_rec.attribute43;
               l_api_rec.attribute44			:= api_curs_rec.attribute44;
               l_api_rec.attribute45			:= api_curs_rec.attribute45;
               l_api_rec.attribute46			:= api_curs_rec.attribute46;
               l_api_rec.attribute47			:= api_curs_rec.attribute47;
               l_api_rec.attribute48			:= api_curs_rec.attribute48;
               l_api_rec.attribute49			:= api_curs_rec.attribute49;
               l_api_rec.attribute50			:= api_curs_rec.attribute50;
               l_api_rec.attribute51			:= api_curs_rec.attribute51;
               l_api_rec.attribute52			:= api_curs_rec.attribute52;
               l_api_rec.attribute53			:= api_curs_rec.attribute53;
               l_api_rec.attribute54			:= api_curs_rec.attribute54;
               l_api_rec.attribute55			:= api_curs_rec.attribute55;
               l_api_rec.attribute56			:= api_curs_rec.attribute56;
               l_api_rec.attribute57			:= api_curs_rec.attribute57;
               l_api_rec.attribute58			:= api_curs_rec.attribute58;
               l_api_rec.attribute59			:= api_curs_rec.attribute59;
               l_api_rec.attribute60			:= api_curs_rec.attribute60;
               l_api_rec.attribute61			:= api_curs_rec.attribute61;
               l_api_rec.attribute62			:= api_curs_rec.attribute62;
               l_api_rec.attribute63			:= api_curs_rec.attribute63;
               l_api_rec.attribute64			:= api_curs_rec.attribute64;
               l_api_rec.attribute65			:= api_curs_rec.attribute65;
               l_api_rec.attribute66			:= api_curs_rec.attribute66;
               l_api_rec.attribute67			:= api_curs_rec.attribute67;
               l_api_rec.attribute68			:= api_curs_rec.attribute68;
               l_api_rec.attribute69			:= api_curs_rec.attribute69;
               l_api_rec.attribute70			:= api_curs_rec.attribute70;
               l_api_rec.attribute71			:= api_curs_rec.attribute71;
               l_api_rec.attribute72			:= api_curs_rec.attribute72;
               l_api_rec.attribute73			:= api_curs_rec.attribute73;
               l_api_rec.attribute74			:= api_curs_rec.attribute74;
               l_api_rec.attribute75			:= api_curs_rec.attribute75;
               l_api_rec.attribute76			:= api_curs_rec.attribute76;
               l_api_rec.attribute77			:= api_curs_rec.attribute77;
               l_api_rec.attribute78			:= api_curs_rec.attribute78;
               l_api_rec.attribute79			:= api_curs_rec.attribute79;
               l_api_rec.attribute80			:= api_curs_rec.attribute80;
               l_api_rec.attribute81			:= api_curs_rec.attribute81;
               l_api_rec.attribute82			:= api_curs_rec.attribute82;
               l_api_rec.attribute83			:= api_curs_rec.attribute83;
               l_api_rec.attribute84			:= api_curs_rec.attribute84;
               l_api_rec.attribute85			:= api_curs_rec.attribute85;
               l_api_rec.attribute86			:= api_curs_rec.attribute86;
               l_api_rec.attribute87			:= api_curs_rec.attribute87;
               l_api_rec.attribute88			:= api_curs_rec.attribute88;
               l_api_rec.attribute89			:= api_curs_rec.attribute89;
               l_api_rec.attribute90			:= api_curs_rec.attribute90;
               l_api_rec.attribute91			:= api_curs_rec.attribute91;
               l_api_rec.attribute92			:= api_curs_rec.attribute92;
               l_api_rec.attribute93			:= api_curs_rec.attribute93;
               l_api_rec.attribute94			:= api_curs_rec.attribute94;
               l_api_rec.attribute95			:= api_curs_rec.attribute95;
               l_api_rec.attribute96			:= api_curs_rec.attribute96;
               l_api_rec.attribute97			:= api_curs_rec.attribute97;
               l_api_rec.attribute98			:= api_curs_rec.attribute98;
               l_api_rec.attribute99			:= api_curs_rec.attribute99;
               l_api_rec.attribute100			:= api_curs_rec.attribute100;
               l_api_rec.employee_number		:= api_curs_rec.employee_number;
               l_api_rec.comm_lines_api_id		:= l_comm_lines_api_id;
               l_api_rec.conc_batch_id			:= NULL;
               l_api_rec.process_batch_id		:= NULL;
               -- l_api_rec.salesrep_number
               -- := api_curs_rec.employee_number;
               -- obsoleted column bug2131915
               l_api_rec.salesrep_number        := null;
               l_api_rec.rollup_date			:= api_curs_rec.rollup_date;
               --l_api_rec.rollup_period_id		:= NULL;
               l_api_rec.source_doc_id			:= NULL;
               l_api_rec.source_doc_type		:= api_curs_rec.source_doc_type;
               l_api_rec.transaction_currency_code	:= api_curs_rec.orig_currency_code;
               l_api_rec.exchange_rate			:= api_curs_rec.exchange_rate;
               l_api_rec.acctd_transaction_amount	:= l_acctd_transaction_amount;
               l_api_rec.trx_id				    := NULL;
               l_api_rec.trx_line_id 			:= NULL;
               l_api_rec.trx_sales_line_id		:= NULL;
               l_api_rec.quantity			:= l_quantity;
               l_api_rec.source_trx_number		:= api_curs_rec.source_trx_number;
               l_api_rec.discount_percentage	:= api_curs_rec.discount_percentage;
               l_api_rec.margin_percentage 		:= api_curs_rec.margin_percentage;
               l_api_rec.pre_defined_rc_flag	:= NULL;
               l_api_rec.rollup_flag			:= NULL;
               l_api_rec.forecast_id			:= api_curs_rec.forecast_id;
               l_api_rec.upside_quantity 		:= api_curs_rec.upside_quantity;
               l_api_rec.upside_amount			:= api_curs_rec.upside_amount;
               l_api_rec.uom_code  			    := api_curs_rec.uom_code;
               l_api_rec.source_trx_id 			:= api_curs_rec.source_trx_id;
               l_api_rec.source_trx_line_id		:= api_curs_rec.source_trx_line_id;
               l_api_rec.source_trx_sales_line_id 	:= api_curs_rec.source_trx_sales_line_id;
               l_api_rec.negated_flag			:= l_negate_flag;
               l_api_rec.customer_id			:= api_curs_rec.customer_id;
               l_api_rec.inventory_item_id		:= api_curs_rec.inventory_item_id;
               l_api_rec.order_number			:= api_curs_rec.order_number;
               l_api_rec.booked_date 			:= api_curs_rec.booked_date;
               l_api_rec.invoice_number			:= api_curs_rec.invoice_number;
               l_api_rec.invoice_date			:= api_curs_rec.invoice_date;
               l_api_rec.bill_to_address_id		:= api_curs_rec.bill_to_address_id;
               l_api_rec.ship_to_address_id		:= api_curs_rec.ship_to_address_id;
               l_api_rec.bill_to_contact_id		:= api_curs_rec.bill_to_contact_id;
               l_api_rec.ship_to_contact_id		:= api_curs_rec.ship_to_contact_id;
               l_api_rec.adj_comm_lines_api_id	:= api_curs_rec.comm_lines_api_id;
               l_api_rec.adjust_date			:= l_adjust_date;
               l_api_rec.adjusted_by 			:= x_adjusted_by;
               l_api_rec.revenue_type 			:= api_curs_rec.revenue_type;
               l_api_rec.adjust_rollup_flag 	:= api_curs_rec.adjust_rollup_flag;
               l_api_rec.adjust_comments		:= x_adjust_comments;
               l_api_rec.adjust_status 			:= NVL(l_adjust_status,'NEW');
               l_api_rec.line_number 			:= api_curs_rec.line_number;
	       /* codeCheck: Is it correct? */
               l_api_rec.reason_code			:= api_curs_rec.reason_code;
               l_api_rec.attribute_category 	:= api_curs_rec.attribute_category;
               l_api_rec.type  				    := api_curs_rec.type;
               l_api_rec.pre_processed_code 	:= api_curs_rec.pre_processed_code;
               l_api_rec.quota_id 			    := api_curs_rec.quota_id;
               l_api_rec.srp_plan_assign_id 	:= api_curs_rec.srp_plan_assign_id;
               l_api_rec.role_id  			    := api_curs_rec.role_id;
               l_api_rec.comp_group_id 			:= api_curs_rec.comp_group_id;
	       /* codeCheck: Is it correct? */
               l_api_rec.commission_amount		:= NULL;
               l_api_rec.reversal_flag			:= l_reversal_flag;
               l_api_rec.reversal_header_id		:= l_reversal_header_id;
               l_api_rec.sales_channel 			:= api_curs_rec.sales_channel;
               l_api_rec.split_pct 		       	:= api_curs_rec.split_pct;
	       l_api_rec.split_status 		        := api_curs_rec.split_status;
    	       l_api_rec.org_id                         := api_curs_rec.org_id; -- vensrini.
               l_api_rec.terr_id                        := l_territory_id;
               l_api_rec.terr_name                      := l_terr_name;
               l_api_rec.preserve_credit_override_flag  := NVL(l_presrv_credit_override_flag,'N');
	       --
	       cn_comm_lines_api_pkg.insert_row(l_api_rec);
	       --
         END LOOP;
      EXCEPTION
         WHEN OTHERS THEN
	    NULL;
      END;
   END IF;

  /* Added for Crediting Bug */
BEGIN
    SELECT COMM_LINES_API_ID, TERR_ID, ORG_ID
    INTO l_comm_lines_api_id, l_terr_id, l_org_id
    FROM CN_COMM_LINES_API
    WHERE COMM_LINES_API_ID = x_comm_lines_api_id;

    update_credit_credentials(
    l_comm_lines_api_id,
    l_terr_id,
    l_org_id,
    x_adjusted_by
    );
EXCEPTION
WHEN OTHERS THEN
NULL;
END;

END api_negate_record;

--
PROCEDURE mass_update_values(
        x_adj_data                     	cn_get_tx_data_pub.adj_tbl_type,
	x_adj_rec			cn_get_tx_data_pub.adj_rec_type,
        x_mass_adj_type			VARCHAR2,
        x_proc_comp		OUT NOCOPY    VARCHAR2) IS

   l_api_name			CONSTANT VARCHAR2(30) := 'mass_update_values';
   l_api_version      		CONSTANT NUMBER := 1.0;
   l_validation_level		VARCHAR2(100)	:= FND_API.G_VALID_LEVEL_FULL;
   l_return_status         	VARCHAR2(2000);
   l_msg_count             	NUMBER;
   l_msg_data              	VARCHAR2(2000);
   l_loading_status        	VARCHAR2(2000);
   l_max_val			NUMBER;
   l_adjust_status              VARCHAR2(20);
   l_adjust_date                DATE := SYSDATE;
   l_comm_lines_api_id          NUMBER;
   l_counter			NUMBER := 0;
   -- PL/SQL tables/columns
   l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;
   l_existing_data		cn_invoice_changes_pvt.invoice_tbl;
   l_new_data			cn_invoice_changes_pvt.invoice_tbl;
   --
BEGIN
   x_proc_comp := 'N';

   IF (x_adj_data.COUNT>0) THEN

      FOR i in x_adj_data.first .. x_adj_data.last
      LOOP
         IF ((x_adj_data(i).adjust_status NOT IN('FROZEN','REVERSAL','SCA_PENDING'))-- OR
	      --x_adj_data(i).adjust_status IS null)
              AND
	      x_adj_data(i).trx_type NOT IN ('ITD','GRP','THR') AND
              x_adj_data(i).load_status NOT IN ('FILTERED')) THEN
	    IF (x_mass_adj_type = 'M') THEN
	       l_adjust_status := 'MASSADJ';
	    ELSE
	       l_adjust_status := 'MASSASGN';
	    END IF;
	    --
            SELECT cn_comm_lines_api_s.NEXTVAL
              INTO l_comm_lines_api_id
              FROM DUAL;
	    --


        SELECT DECODE(x_adj_rec.direct_salesrep_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).direct_salesrep_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).direct_salesrep_id),
			  x_adj_rec.direct_salesrep_id),
	    	     DECODE(x_adj_rec.processed_date,fnd_api.g_miss_date,
	                  DECODE(x_adj_data(i).processed_date,fnd_api.g_miss_date,NULL,
			         x_adj_data(i).processed_date),
			  x_adj_rec.processed_date),
	    	   DECODE(x_adj_rec.processed_period_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).processed_period_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).processed_period_id),
			  x_adj_rec.processed_period_id),
	    	   DECODE(x_adj_rec.transaction_amount,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).transaction_amount,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).transaction_amount),
			  x_adj_rec.transaction_amount),
	    	   DECODE(x_adj_rec.trx_type,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).trx_type,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).trx_type),x_adj_rec.trx_type),
	    	   DECODE(x_adj_rec.revenue_class_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).revenue_class_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).revenue_class_id),
			  x_adj_rec.revenue_class_id),
		   'UNLOADED',
	    	   DECODE(x_adj_rec.attribute1,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute1,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute1),x_adj_rec.attribute1),
	    	   DECODE(x_adj_rec.attribute2,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute2,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute2),x_adj_rec.attribute2),
	    	   DECODE(x_adj_rec.attribute3,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute3,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute3),x_adj_rec.attribute3),
	    	   DECODE(x_adj_rec.attribute4,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute4,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute4),x_adj_rec.attribute4),
	    	   DECODE(x_adj_rec.attribute5,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute5,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute5),x_adj_rec.attribute5),
	    	   DECODE(x_adj_rec.attribute6,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute6,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute6),x_adj_rec.attribute6),
	    	   DECODE(x_adj_rec.attribute7,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute7,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute7),x_adj_rec.attribute7),
	    	   DECODE(x_adj_rec.attribute8,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute8,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute8),x_adj_rec.attribute8),
	    	   DECODE(x_adj_rec.attribute9,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute9,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute9),x_adj_rec.attribute9),
	    	   DECODE(x_adj_rec.attribute10,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute10,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute10),x_adj_rec.attribute10),
	    	   DECODE(x_adj_rec.attribute11,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute11,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute11),x_adj_rec.attribute11),
	    	   DECODE(x_adj_rec.attribute12,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute12,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute12),x_adj_rec.attribute12),
	    	   DECODE(x_adj_rec.attribute13,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute13,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute13),x_adj_rec.attribute13),
	    	   DECODE(x_adj_rec.attribute14,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute14,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute14),x_adj_rec.attribute14),
	    	   DECODE(x_adj_rec.attribute15,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute15,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute15),x_adj_rec.attribute15),
	    	   DECODE(x_adj_rec.attribute16,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute16,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute16),x_adj_rec.attribute16),
	    	   DECODE(x_adj_rec.attribute17,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute17,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute17),x_adj_rec.attribute17),
	    	   DECODE(x_adj_rec.attribute18,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute18,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute18),x_adj_rec.attribute18),
	    	   DECODE(x_adj_rec.attribute19,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute19,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute19),x_adj_rec.attribute19),
	    	   DECODE(x_adj_rec.attribute20,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute20,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute20),x_adj_rec.attribute20),
	    	   DECODE(x_adj_rec.attribute21,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute21,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute21),x_adj_rec.attribute21),
	    	   DECODE(x_adj_rec.attribute22,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute22,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute22),x_adj_rec.attribute22),
	    	   DECODE(x_adj_rec.attribute23,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute23,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute23),x_adj_rec.attribute23),
	    	   DECODE(x_adj_rec.attribute24,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute24,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute24),x_adj_rec.attribute24),
	    	   DECODE(x_adj_rec.attribute25,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute25,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute25),x_adj_rec.attribute25),
	    	   DECODE(x_adj_rec.attribute26,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute26,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute26),x_adj_rec.attribute26),
	    	   DECODE(x_adj_rec.attribute27,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute27,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute27),x_adj_rec.attribute27),
	    	   DECODE(x_adj_rec.attribute28,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute28,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute28),x_adj_rec.attribute28),
	    	   DECODE(x_adj_rec.attribute29,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute29,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute29),x_adj_rec.attribute29),
	    	   DECODE(x_adj_rec.attribute30,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute30,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute30),x_adj_rec.attribute30),
	    	   DECODE(x_adj_rec.attribute31,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute31,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute31),x_adj_rec.attribute31),
	    	   DECODE(x_adj_rec.attribute32,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute32,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute32),x_adj_rec.attribute32),
	    	   DECODE(x_adj_rec.attribute33,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute33,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute33),x_adj_rec.attribute33),
	    	   DECODE(x_adj_rec.attribute34,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute34,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute34),x_adj_rec.attribute34),
	    	   DECODE(x_adj_rec.attribute35,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute35,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute35),x_adj_rec.attribute35),
	    	   DECODE(x_adj_rec.attribute36,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute36,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute36),x_adj_rec.attribute36),
	    	   DECODE(x_adj_rec.attribute37,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute37,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute37),x_adj_rec.attribute37),
	    	   DECODE(x_adj_rec.attribute38,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute38,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute38),x_adj_rec.attribute38),
	    	   DECODE(x_adj_rec.attribute39,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute39,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute39),x_adj_rec.attribute39),
	    	   DECODE(x_adj_rec.attribute40,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute40,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute40),x_adj_rec.attribute40),
	    	   DECODE(x_adj_rec.attribute41,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute41,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute41),x_adj_rec.attribute41),
	    	   DECODE(x_adj_rec.attribute42,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute42,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute42),x_adj_rec.attribute42),
	    	   DECODE(x_adj_rec.attribute43,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute43,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute43),x_adj_rec.attribute43),
	    	   DECODE(x_adj_rec.attribute44,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute44,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute44),x_adj_rec.attribute44),
	    	   DECODE(x_adj_rec.attribute45,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute45,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute45),x_adj_rec.attribute45),
	    	   DECODE(x_adj_rec.attribute46,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute46,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute46),x_adj_rec.attribute46),
	    	   DECODE(x_adj_rec.attribute47,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute47,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute47),x_adj_rec.attribute47),
	    	   DECODE(x_adj_rec.attribute48,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute48,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute48),x_adj_rec.attribute48),
	    	   DECODE(x_adj_rec.attribute49,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute49,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute49),x_adj_rec.attribute49),
	    	   DECODE(x_adj_rec.attribute50,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute50,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute50),x_adj_rec.attribute50),
	    	   DECODE(x_adj_rec.attribute51,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute51,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute51),x_adj_rec.attribute51),
	    	   DECODE(x_adj_rec.attribute52,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute52,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute52),x_adj_rec.attribute52),
	    	   DECODE(x_adj_rec.attribute53,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute53,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute53),x_adj_rec.attribute53),
	    	   DECODE(x_adj_rec.attribute54,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute54,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute54),x_adj_rec.attribute54),
	    	   DECODE(x_adj_rec.attribute55,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute55,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute55),x_adj_rec.attribute55),
	    	   DECODE(x_adj_rec.attribute56,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute56,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute56),x_adj_rec.attribute56),
	    	   DECODE(x_adj_rec.attribute57,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute57,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute57),x_adj_rec.attribute57),
	    	   DECODE(x_adj_rec.attribute58,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute58,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute58),x_adj_rec.attribute58),
	    	   DECODE(x_adj_rec.attribute59,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute59,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute59),x_adj_rec.attribute59),
	    	   DECODE(x_adj_rec.attribute60,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute60,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute60),x_adj_rec.attribute60),
	    	   DECODE(x_adj_rec.attribute61,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute61,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute61),x_adj_rec.attribute61),
	    	   DECODE(x_adj_rec.attribute62,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute62,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute62),x_adj_rec.attribute62),
	    	   DECODE(x_adj_rec.attribute63,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute63,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute63),x_adj_rec.attribute63),
	    	   DECODE(x_adj_rec.attribute64,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute64,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute64),x_adj_rec.attribute64),
	    	   DECODE(x_adj_rec.attribute65,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute65,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute65),x_adj_rec.attribute65),
	    	   DECODE(x_adj_rec.attribute66,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute66,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute66),x_adj_rec.attribute66),
	    	   DECODE(x_adj_rec.attribute67,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute67,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute67),x_adj_rec.attribute67),
	    	   DECODE(x_adj_rec.attribute68,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute68,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute68),x_adj_rec.attribute68),
	    	   DECODE(x_adj_rec.attribute69,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute69,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute69),x_adj_rec.attribute69),
	    	   DECODE(x_adj_rec.attribute70,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute70,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute70),x_adj_rec.attribute70),
	    	   DECODE(x_adj_rec.attribute71,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute71,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute71),x_adj_rec.attribute71),
	    	   DECODE(x_adj_rec.attribute72,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute72,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute72),x_adj_rec.attribute72),
	    	   DECODE(x_adj_rec.attribute73,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute73,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute73),x_adj_rec.attribute73),
	    	   DECODE(x_adj_rec.attribute74,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute74,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute74),x_adj_rec.attribute74),
	    	   DECODE(x_adj_rec.attribute75,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute75,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute75),x_adj_rec.attribute75),
	    	   DECODE(x_adj_rec.attribute76,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute76,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute76),x_adj_rec.attribute76),
	    	   DECODE(x_adj_rec.attribute77,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute77,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute77),x_adj_rec.attribute77),
	    	   DECODE(x_adj_rec.attribute78,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute78,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute78),x_adj_rec.attribute78),
	    	   DECODE(x_adj_rec.attribute79,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute79,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute79),x_adj_rec.attribute79),
	    	   DECODE(x_adj_rec.attribute80,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute80,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute80),x_adj_rec.attribute80),
	    	   DECODE(x_adj_rec.attribute81,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute81,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute81),x_adj_rec.attribute81),
	    	   DECODE(x_adj_rec.attribute82,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute82,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute82),x_adj_rec.attribute82),
	    	   DECODE(x_adj_rec.attribute83,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute83,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute83),x_adj_rec.attribute83),
	    	   DECODE(x_adj_rec.attribute84,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute84,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute84),x_adj_rec.attribute84),
	    	   DECODE(x_adj_rec.attribute85,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute85,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute85),x_adj_rec.attribute85),
	    	   DECODE(x_adj_rec.attribute86,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute86,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute86),x_adj_rec.attribute86),
	    	   DECODE(x_adj_rec.attribute87,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute87,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute87),x_adj_rec.attribute87),
	    	   DECODE(x_adj_rec.attribute88,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute88,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute88),x_adj_rec.attribute88),
	    	   DECODE(x_adj_rec.attribute89,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute89,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute89),x_adj_rec.attribute89),
	    	   DECODE(x_adj_rec.attribute90,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute90,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute90),x_adj_rec.attribute90),
	    	   DECODE(x_adj_rec.attribute91,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute91,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute91),x_adj_rec.attribute91),
	    	   DECODE(x_adj_rec.attribute92,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute92,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute92),x_adj_rec.attribute92),
	    	   DECODE(x_adj_rec.attribute93,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute93,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute93),x_adj_rec.attribute93),
	    	   DECODE(x_adj_rec.attribute94,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute94,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute94),x_adj_rec.attribute94),
	    	   DECODE(x_adj_rec.attribute95,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute95,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute95),x_adj_rec.attribute95),
	    	   DECODE(x_adj_rec.attribute96,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute96,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute96),x_adj_rec.attribute96),
	    	   DECODE(x_adj_rec.attribute97,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute97,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute97),x_adj_rec.attribute97),
	    	   DECODE(x_adj_rec.attribute98,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute98,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute98),x_adj_rec.attribute98),
	    	   DECODE(x_adj_rec.attribute99,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute99,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute99),x_adj_rec.attribute99),
	    	   DECODE(x_adj_rec.attribute100,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).attribute100,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).attribute100),x_adj_rec.attribute100),
		   DECODE(x_adj_rec.direct_salesrep_number,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).direct_salesrep_number,fnd_api.g_miss_char,NULL,
			         x_adj_data(i).direct_salesrep_number),
			  x_adj_rec.direct_salesrep_number),
		   l_comm_lines_api_id,
		   NULL,NULL,NULL,
		   DECODE(x_adj_data(i).rollup_date,fnd_api.g_miss_date,NULL,
		          x_adj_data(i).rollup_date),
		   NULL,
		   DECODE(x_adj_data(i).source_doc_type,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).source_doc_type),
		   DECODE(x_adj_data(i).orig_currency_code,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).orig_currency_code),
		   DECODE(x_adj_data(i).exchange_rate,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).exchange_rate),
		   DECODE(x_adj_data(i).transaction_amount_orig,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).transaction_amount_orig),
		   DECODE(x_adj_data(i).trx_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).trx_id),
		   DECODE(x_adj_data(i).trx_line_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).trx_line_id),
		   DECODE(x_adj_data(i).trx_sales_line_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).trx_sales_line_id),
		   DECODE(x_adj_data(i).quantity,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).quantity),
		   DECODE(x_adj_data(i).source_trx_number,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).source_trx_number),
		   DECODE(x_adj_data(i).discount_percentage,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).discount_percentage),
		   DECODE(x_adj_data(i).margin_percentage,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).margin_percentage),
		   NULL,NULL,
		   DECODE(x_adj_data(i).forecast_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).forecast_id),
		   DECODE(x_adj_data(i).upside_quantity,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).upside_quantity),
		   DECODE(x_adj_data(i).upside_amount,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).upside_amount),
		   DECODE(x_adj_data(i).uom_code,fnd_api.g_miss_char,NULL,
	                  x_adj_data(i).uom_code),
	           -- Bug fix 5349170
		   DECODE(x_adj_data(i).source_trx_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).source_trx_id),
		   DECODE(x_adj_data(i).source_trx_line_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).source_trx_line_id),
		   DECODE(x_adj_data(i).source_trx_sales_line_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).source_trx_sales_line_id),
	           -- Bug fix 5349170
	           NULL,
		   DECODE(x_adj_rec.customer_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).customer_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).customer_id),x_adj_rec.customer_id),
                   DECODE(x_adj_rec.inventory_item_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).inventory_item_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).inventory_item_id),x_adj_rec.inventory_item_id),
		   DECODE(x_adj_data(i).order_number,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).order_number),
		   DECODE(x_adj_data(i).order_date,fnd_api.g_miss_date,NULL,
		          x_adj_data(i).order_date),
		   DECODE(x_adj_data(i).invoice_number,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).invoice_number),
		   DECODE(x_adj_data(i).invoice_date,fnd_api.g_miss_date,NULL,
		          x_adj_data(i).invoice_date),
		   DECODE(x_adj_data(i).bill_to_address_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).bill_to_address_id),
		   DECODE(x_adj_data(i).ship_to_address_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).ship_to_address_id),
		   DECODE(x_adj_data(i).bill_to_contact_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).bill_to_contact_id),
		   DECODE(x_adj_data(i).ship_to_contact_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).ship_to_contact_id),
		   DECODE(x_adj_data(i).comm_lines_api_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).comm_lines_api_id),
		   l_adjust_date,x_adj_rec.adjusted_by,
		   DECODE(x_adj_data(i).revenue_type,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).revenue_type),
		   NULL,
		   x_adj_rec.adjust_comments,NVL(l_adjust_status,'NEW'),
		   DECODE(x_adj_data(i).line_number,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).line_number),
		   DECODE(x_adj_data(i).reason_code,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).reason_code),
		   DECODE(x_adj_data(i).attribute_category,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).attribute_category),
		   DECODE(x_adj_data(i).type,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).type),
		   DECODE(x_adj_data(i).pre_processed_code,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).pre_processed_code),
		   DECODE(x_adj_data(i).quota_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).quota_id),
		   DECODE(x_adj_data(i).srp_plan_assign_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).srp_plan_assign_id),
		   DECODE(x_adj_data(i).role_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).role_id),
		   DECODE(x_adj_data(i).comp_group_id,fnd_api.g_miss_num,NULL,
		          x_adj_data(i).comp_group_id),
		   NULL,NULL,NULL,
		   DECODE(x_adj_data(i).sales_channel,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).sales_channel),
		   DECODE(x_adj_data(i).split_pct,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).split_pct),
		   DECODE(x_adj_data(i).split_status,fnd_api.g_miss_char,NULL,
		          x_adj_data(i).split_status),
           DECODE(x_adj_rec.org_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).org_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).org_id),
			  x_adj_rec.org_id),
           DECODE(x_adj_rec.terr_id,fnd_api.g_miss_num,
	                  DECODE(x_adj_data(i).terr_id,fnd_api.g_miss_num,NULL,
			         x_adj_data(i).terr_id),
			  x_adj_rec.terr_id),
           DECODE(x_adj_rec.preserve_credit_override_flag,fnd_api.g_miss_char,
	                  DECODE(x_adj_data(i).preserve_credit_override_flag,fnd_api.g_miss_char,'N',
			         NVL(x_adj_data(i).preserve_credit_override_flag,'N')),
			  NVL(x_adj_rec.preserve_credit_override_flag,'N'))
	      INTO l_api_rec.salesrep_id,l_api_rec.processed_date,
                   l_api_rec.processed_period_id,l_api_rec.acctd_transaction_amount,
                   l_api_rec.trx_type,l_api_rec.revenue_class_id,
                   l_api_rec.load_status,
	           l_api_rec.attribute1,l_api_rec.attribute2,
	           l_api_rec.attribute3,l_api_rec.attribute4,
	           l_api_rec.attribute5,l_api_rec.attribute6,
	           l_api_rec.attribute7,l_api_rec.attribute8,
	           l_api_rec.attribute9,l_api_rec.attribute10,
	           l_api_rec.attribute11,l_api_rec.attribute12,
	           l_api_rec.attribute13,l_api_rec.attribute14,
	           l_api_rec.attribute15,l_api_rec.attribute16,
	           l_api_rec.attribute17,l_api_rec.attribute18,
	           l_api_rec.attribute19,l_api_rec.attribute20,
	           l_api_rec.attribute21,l_api_rec.attribute22,
	           l_api_rec.attribute23,l_api_rec.attribute24,
	           l_api_rec.attribute25,l_api_rec.attribute26,
	           l_api_rec.attribute27,l_api_rec.attribute28,
	           l_api_rec.attribute29,l_api_rec.attribute30,
	           l_api_rec.attribute31,l_api_rec.attribute32,
	           l_api_rec.attribute33,l_api_rec.attribute34,
	           l_api_rec.attribute35,l_api_rec.attribute36,
	           l_api_rec.attribute37,l_api_rec.attribute38,
	           l_api_rec.attribute39,l_api_rec.attribute40,
	           l_api_rec.attribute41,l_api_rec.attribute42,
	           l_api_rec.attribute43,l_api_rec.attribute44,
	           l_api_rec.attribute45,l_api_rec.attribute46,
	           l_api_rec.attribute47,l_api_rec.attribute48,
	           l_api_rec.attribute49,l_api_rec.attribute50,
	           l_api_rec.attribute51,l_api_rec.attribute52,
	           l_api_rec.attribute53,l_api_rec.attribute54,
	           l_api_rec.attribute55,l_api_rec.attribute56,
	           l_api_rec.attribute57,l_api_rec.attribute58,
	           l_api_rec.attribute59,l_api_rec.attribute60,
	           l_api_rec.attribute61,l_api_rec.attribute62,
	           l_api_rec.attribute63,l_api_rec.attribute64,
	           l_api_rec.attribute65,l_api_rec.attribute66,
	           l_api_rec.attribute67,l_api_rec.attribute68,
	           l_api_rec.attribute69,l_api_rec.attribute70,
	           l_api_rec.attribute71,l_api_rec.attribute72,
	           l_api_rec.attribute73,l_api_rec.attribute74,
	           l_api_rec.attribute75,l_api_rec.attribute76,
	           l_api_rec.attribute77,l_api_rec.attribute78,
	           l_api_rec.attribute79,l_api_rec.attribute80,
	           l_api_rec.attribute81,l_api_rec.attribute82,
	           l_api_rec.attribute83,l_api_rec.attribute84,
	           l_api_rec.attribute85,l_api_rec.attribute86,
	           l_api_rec.attribute87,l_api_rec.attribute88,
	           l_api_rec.attribute89,l_api_rec.attribute90,
	           l_api_rec.attribute91,l_api_rec.attribute92,
	           l_api_rec.attribute93,l_api_rec.attribute94,
	           l_api_rec.attribute95,l_api_rec.attribute96,
	           l_api_rec.attribute97,l_api_rec.attribute98,
	           l_api_rec.attribute99,l_api_rec.attribute100,
                   l_api_rec.employee_number,l_api_rec.comm_lines_api_id,
                   l_api_rec.conc_batch_id,l_api_rec.process_batch_id,
                   l_api_rec.salesrep_number,l_api_rec.rollup_date,
                   l_api_rec.source_doc_id,l_api_rec.source_doc_type,
                   l_api_rec.transaction_currency_code,
                   l_api_rec.exchange_rate,
		   l_api_rec.transaction_amount,
                   l_api_rec.trx_id,l_api_rec.trx_line_id,
                   l_api_rec.trx_sales_line_id,l_api_rec.quantity,
                   l_api_rec.source_trx_number,
                   l_api_rec.discount_percentage,
                   l_api_rec.margin_percentage,
                   l_api_rec.pre_defined_rc_flag,l_api_rec.rollup_flag,
            	   l_api_rec.forecast_id,
                   l_api_rec.upside_quantity,l_api_rec.upside_amount,
                   l_api_rec.uom_code,l_api_rec.source_trx_id,
                   l_api_rec.source_trx_line_id,
                   l_api_rec.source_trx_sales_line_id,
                   l_api_rec.negated_flag,l_api_rec.customer_id,
                   l_api_rec.inventory_item_id,l_api_rec.order_number,
                   l_api_rec.booked_date,l_api_rec.invoice_number,
                   l_api_rec.invoice_date,l_api_rec.bill_to_address_id,
                   l_api_rec.ship_to_address_id,l_api_rec.bill_to_contact_id,
                   l_api_rec.ship_to_contact_id,l_api_rec.adj_comm_lines_api_id,
                   l_api_rec.adjust_date,l_api_rec.adjusted_by,
                   l_api_rec.revenue_type,l_api_rec.adjust_rollup_flag,
                   l_api_rec.adjust_comments,l_api_rec.adjust_status,
                   l_api_rec.line_number,l_api_rec.reason_code,
                   l_api_rec.attribute_category,l_api_rec.type,
                   l_api_rec.pre_processed_code,l_api_rec.quota_id,
                   l_api_rec.srp_plan_assign_id,l_api_rec.role_id,
                   l_api_rec.comp_group_id,l_api_rec.commission_amount,
                   l_api_rec.reversal_flag,l_api_rec.reversal_header_id,
                   l_api_rec.sales_channel,l_api_rec.split_pct,
                   l_api_rec.split_status,
                   l_api_rec.org_id,
                   l_api_rec.terr_id,
                   l_api_rec.preserve_credit_override_flag
	      FROM DUAL;

        --Added for Crediting
        IF(x_adj_data(i).terr_id IS NOT NULL)
        THEN
            l_api_rec.terr_id := -999;
            l_api_rec.preserve_credit_override_flag := 'Y';
        END IF;

        l_api_rec.adj_comm_lines_api_id := x_adj_data(i).comm_lines_api_id;
	    cn_comm_lines_api_pkg.insert_row(l_api_rec);

	    --
	    IF ((g_track_invoice = 'Y') AND (l_api_rec.trx_type = 'INV')) THEN
	       l_counter := l_counter + 1;
	       --
               l_new_data(l_counter).salesrep_id	:= l_api_rec.salesrep_id;
               l_new_data(l_counter).direct_salesrep_number
      							:= l_api_rec.employee_number;
               l_new_data(l_counter).invoice_number	:= l_api_rec.invoice_number;
               l_new_data(l_counter).line_number	:= l_api_rec.line_number;
               l_new_data(l_counter).revenue_type	:= l_api_rec.revenue_type;
               l_new_data(l_counter).split_pct		:= l_api_rec.split_pct;
               l_new_data(l_counter).comm_lines_api_id	:= l_comm_lines_api_id;
               --
	    END IF;
            X_proc_comp := 'Y';
         END IF;
	 IF (x_mass_adj_type = 'M') AND
	    (x_adj_data(i).adjust_status NOT IN('FROZEN','REVERSAL','SCA_PENDING')) --OR
	     --x_adj_data(i).adjust_status IS null)
             AND
             x_adj_data(i).load_status NOT IN ('FILTERED') THEN

	    cn_adjustments_pkg.api_negate_record(
	    		x_adj_data(i).comm_lines_api_id,
			x_adj_rec.adjusted_by,
			x_adj_rec.adjust_comments,
			x_adj_data(i).direct_salesrep_number);

			--Added for Crediting
            /*CN_GET_TX_DATA_PUB.update_credit_credentials(
            x_adj_data(i).comm_lines_api_id,
            x_adj_data(i).terr_id,
            x_adj_data(i).org_id,
            x_adj_rec.adjusted_by
            );*/

         END IF;
      END LOOP;
   END IF; -- IF (x_adj_data.COUNT>0)
   IF ((g_track_invoice = 'Y') AND (l_new_data.COUNT > 0)) THEN
      --
      l_existing_data(1).salesrep_id 		:= NULL;
      l_existing_data(1).direct_salesrep_number := NULL;
      l_existing_data(1).invoice_number 	:= NULL;
      l_existing_data(1).line_number		:= NULL;
      l_existing_data(1).revenue_type		:= NULL;
      l_existing_data(1).split_pct		:= NULL;
      l_existing_data(1).comm_lines_api_id	:= NULL;
      --
      cn_invoice_changes_pvt.update_invoice_changes(
   	p_api_version 		=> l_api_version,
	p_validation_level	=> l_validation_level,
   	p_existing_data		=> l_existing_data,
	p_new_data		=> l_new_data,
	p_exist_data_check	=> 'N',
	p_new_data_check	=> 'Y',
	x_return_status		=> l_return_status,
	x_msg_count		=> l_msg_count,
	x_msg_data		=> l_msg_data,
	x_loading_status	=> l_loading_status);
      --
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         IF (FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
            FND_MESSAGE.Set_Name('CN', 'CN_UPDATE_INV_ERROR');
 	    FND_MSG_PUB.Add;
         END IF;
         l_loading_status := 'CN_UPDATE_INV_ERROR';
	 x_proc_comp := 'E';
      END IF;
      --
   END IF;
EXCEPTION
   WHEN OTHERS THEN
      x_proc_comp := 'E';
END mass_update_values;
--
PROCEDURE deal_split(
	x_source_salesrep_id   	NUMBER,
	x_salesrep_id		NUMBER,
	x_split_percent   	NUMBER,
        x_revenue_type		VARCHAR2,
	x_invoice_number	VARCHAR2,
	x_order_number		NUMBER,
	x_adjusted_by		VARCHAR2,
        x_adjust_comments	VARCHAR2) IS
   --
   deal_select_cursor   	NUMBER(15);
   sql_stmt			VARCHAR2(5000);
   count_rows 			NUMBER;
   l_comm_lines_api_id		NUMBER;
   l_ins_comm_lines_api_id    	NUMBER;
   l_transaction_amount		NUMBER;
   l_acctd_transaction_amount   NUMBER;
   l_salesrep_number          	VARCHAR2(30);
   l_revenue_type		VARCHAR2(15);
   l_revenue                    VARCHAR2(12) := 'REVENUE';
   l_adj_tbl			cn_get_tx_data_pub.adj_tbl_type;
   -- PL/SQL tables/records
   l_newtx_rec           	cn_get_tx_data_pub.adj_rec_type;
   o_newtx_rec			cn_get_tx_data_pub.adj_rec_type;
   l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;
   -- To mask this non-standard API
   x_return_status		VARCHAR2(1000);
BEGIN
   deal_select_cursor := DBMS_SQL.open_cursor;
   sql_stmt := 'SELECT COMM_LINES_API_ID FROM CN_ADJUSTMENTS_V WHERE
   direct_salesrep_id = :X_source_salesrep_id  AND revenue_type = :l_revenue';
   --
   IF (x_invoice_number IS NOT NULL) THEN
      sql_stmt := sql_stmt || ' and invoice_number = :X_invoice_number';
   ELSIF(x_order_number  IS NOT NULL) THEN
      sql_stmt := sql_stmt || ' and order_number = :X_order_number';
   END IF;
   --
   dbms_sql.parse(deal_select_cursor,sql_stmt,DBMS_SQL.NATIVE);
   DBMS_SQL.bind_variable(
            deal_select_cursor,'x_source_salesrep_id',x_source_salesrep_id);
   DBMS_SQL.bind_variable(
            deal_select_cursor,'l_revenue',l_revenue);
   --
   IF (x_invoice_number  IS NOT NULL) THEN
      DBMS_SQL.bind_variable(
      	       deal_select_cursor,'x_invoice_number',x_invoice_number);
   END IF;
   --
   IF (x_order_number  IS NOT NULL) THEN
      DBMS_SQL.bind_variable(
      	       deal_select_cursor,'x_order_number',x_order_number);
   END IF;
   --
   DBMS_SQL.define_column (deal_select_cursor,1,l_comm_lines_api_id);
   count_rows := DBMS_SQL.execute (deal_select_cursor);
   LOOP
      IF (dbms_sql.fetch_rows(deal_select_cursor) > 0) THEN
         DBMS_SQL.column_value (deal_select_cursor,1,l_comm_lines_api_id);
	 --
	 --cn_adjustments_pkg.get_api_data(l_comm_lines_api_id,l_adj_tbl);
	 cn_get_tx_data_pub.get_api_data(l_comm_lines_api_id,l_adj_tbl);
	 --
	 IF (l_adj_tbl.COUNT > 0) THEN
            l_transaction_amount	:= ((NVL(l_adj_tbl(1).transaction_amount,0) *
                                             x_split_percent)/100);
	    l_acctd_transaction_amount	:= ((NVL(l_adj_tbl(1).transaction_amount,0) *
				             x_split_percent)/100);
            --
               SELECT employee_number
                 INTO l_salesrep_number
                 FROM cn_salesreps
                WHERE salesrep_id = x_salesrep_id;
            --
               SELECT cn_comm_lines_api_s.NEXTVAL
                 INTO l_ins_comm_lines_api_id
                 FROM dual;
	    --
            l_newtx_rec.direct_salesrep_id	:= x_salesrep_id;
	    l_newtx_rec.transaction_amount	:= l_transaction_amount;
	    l_newtx_rec.load_status		:= 'UNLOADED';
            l_newtx_rec.comm_lines_api_id	:= l_ins_comm_lines_api_id;
	    l_newtx_rec.transaction_amount_orig	:= l_acctd_transaction_amount;
	    l_newtx_rec.adjust_date		:= SYSDATE;
	    l_newtx_rec.adjusted_by		:= x_adjusted_by;
	    l_newtx_rec.revenue_type		:= x_revenue_type;
	    l_newtx_rec.adjust_comments		:= x_adjust_comments;
	    l_newtx_rec.adjust_status		:= 'DEALSPLIT';
	    l_newtx_rec.adj_comm_lines_api_id	:= l_adj_tbl(1).comm_lines_api_id;
	    l_newtx_rec.direct_salesrep_number	:= l_salesrep_number;
	    --
	    cn_invoice_changes_pvt.prepare_api_record(
		p_newtx_rec			=> l_newtx_rec,
		p_old_adj_tbl			=> l_adj_tbl,
		x_final_trx_rec			=> o_newtx_rec,
		x_return_status 		=> x_return_status);
            -- codeCheck: I will explain later about this conversion.
            cn_invoice_changes_pvt.convert_adj_to_api(
		p_adj_rec			=> o_newtx_rec,
		x_api_rec			=> l_api_rec);
	    --
   	    cn_comm_lines_api_pkg.insert_row(l_api_rec);
   	    --
         END IF;
      ELSE
         EXIT;
      END IF;
   END LOOP;
   DBMS_SQL.close_cursor(deal_select_cursor);
END deal_split;
--
PROCEDURE deal_assign(
	x_from_salesrep_id	NUMBER,
	x_to_salesrep_id   	NUMBER,
	x_invoice_number	VARCHAR2,
	x_order_number		NUMBER,
	x_adjusted_by		VARCHAR2,
        x_adjust_comments	VARCHAR2) IS
--
CURSOR api_cur(l_comm_lines_api_id 	NUMBER) IS
   SELECT l.comm_lines_api_id,NVL(l.adjust_status,'NEW') adjust_status
     FROM cn_comm_lines_api l
    WHERE adj_comm_lines_api_id = l_comm_lines_api_id;
--
CURSOR header_cur(l_comm_lines_api_id 	NUMBER) IS
   SELECT h.comm_lines_api_id,NVL(h.adjust_status,'NEW') adjust_status
     FROM cn_commission_headers h
    WHERE adj_comm_lines_api_id = l_comm_lines_api_id;
   --
   assign_select_cursor   	NUMBER(15);
   sql_stmt			VARCHAR2(5000);
   count_rows 			NUMBER;
   l_comm_lines_api_id		NUMBER;
   l_ins_comm_lines_api_id    	NUMBER;
   l_transaction_amount		NUMBER;
   l_acctd_transaction_amount   NUMBER;
   l_salesrep_number          	VARCHAR2(30);
   l_revenue                    VARCHAR2(12) := 'REVENUE';
   l_load_status		VARCHAR2(30);
   -- PL/SQL tables/records
   l_adj_tbl			cn_get_tx_data_pub.adj_tbl_type;
   l_newtx_rec           	cn_get_tx_data_pub.adj_rec_type;
   o_newtx_rec			cn_get_tx_data_pub.adj_rec_type;
   l_api_rec			cn_comm_lines_api_pkg.comm_lines_api_rec_type;
   -- To mask this non-standard API
   x_return_status		VARCHAR2(1000);
   --
BEGIN
   assign_select_cursor := DBMS_SQL.open_cursor;
   sql_stmt := 'SELECT comm_lines_api_id,load_status FROM cn_adjustments_v WHERE';
   sql_stmt := sql_stmt || ' direct_salesrep_id = :x_from_salesrep_id AND revenue_type = :l_revenue';
   --
   IF (x_invoice_number  IS NOT NULL) THEN
      sql_stmt := sql_stmt || ' AND invoice_number = :x_invoice_number';
   ELSIF(x_order_number  IS NOT NULL) THEN
      sql_stmt := sql_stmt || ' AND order_number = :x_order_number';
   END IF;
   --
   dbms_sql.parse(assign_select_cursor,sql_stmt,DBMS_SQL.NATIVE);
   DBMS_SQL.bind_variable(
            assign_select_cursor,'x_from_salesrep_id',x_from_salesrep_id);
   DBMS_SQL.bind_variable(
   	    assign_select_cursor,'l_revenue',l_revenue);
   --
   IF (x_invoice_number  IS NOT NULL) THEN
      DBMS_SQL.bind_variable(
      	       assign_select_cursor,'x_invoice_number',x_invoice_number);
   END IF;
   --
   IF (x_order_number  IS NOT NULL) THEN
      DBMS_SQL.bind_variable(
      	       assign_select_cursor,'x_order_number',x_order_number);
   END IF;
   --
   DBMS_SQL.define_column (assign_select_cursor,1,l_comm_lines_api_id);
   DBMS_SQL.define_column (assign_select_cursor,2,l_load_status,30);
   count_rows := DBMS_SQL.execute (assign_select_cursor);
   LOOP
      IF (dbms_sql.fetch_rows(assign_select_cursor) > 0) THEN
         DBMS_SQL.column_value (assign_select_cursor,1,l_comm_lines_api_id);
	 DBMS_SQL.column_value (assign_select_cursor,2,l_load_status);
	 IF (l_load_status = 'LOADED') THEN
	    FOR rec IN header_cur(l_comm_lines_api_id)
	    LOOP
	       IF(nvl(rec.adjust_status,'X') <> 'FROZEN') THEN
	          cn_adjustments_pkg.api_negate_record(
		  		rec.comm_lines_api_id,
				x_adjusted_by,
				x_adjust_comments);
	       END IF;
	    END LOOP;
	 ELSIF (l_load_status = 'UNLOADED') THEN
	    FOR rec IN api_cur(l_comm_lines_api_id)
	    LOOP
	       IF(nvl(rec.adjust_status,'X') <> 'FROZEN') THEN
	          cn_adjustments_pkg.api_negate_record(
		  		rec.comm_lines_api_id,
				x_adjusted_by,
				x_adjust_comments);
	       END IF;
	    END LOOP;
	 END IF;
	 --
	 --cn_adjustments_pkg.get_api_data(l_comm_lines_api_id,l_adj_tbl);
	 cn_get_tx_data_pub.get_api_data(l_comm_lines_api_id,l_adj_tbl);
	 --
	 IF (l_adj_tbl.COUNT > 0) THEN
	    /* codeCheck: I need to revisit this code */
            l_transaction_amount := NVL(l_adj_tbl(1).transaction_amount,0);
            l_acctd_transaction_amount
	    			 := NVL(l_adj_tbl(1).transaction_amount,0);
            --
	    /*
            IF(nvl(l_adj_tbl(1).adjust_status,'X') <> 'FROZEN') THEN
               cn_adjustments_pkg.api_negate_record(
               		l_adj_tbl(1).comm_lines_api_id,
			l_adjusted_by,
                        l_adjust_comments);
            END IF; */
	    --
            SELECT employee_number
              INTO l_salesrep_number
              FROM cn_salesreps
             WHERE salesrep_id = x_to_salesrep_id;
	    --
            SELECT cn_comm_lines_api_s.NEXTVAL
              INTO l_ins_comm_lines_api_id
              FROM dual;
	    --
            l_newtx_rec.direct_salesrep_id	:= x_to_salesrep_id;
	    l_newtx_rec.transaction_amount	:= l_transaction_amount;
	    l_newtx_rec.load_status		:= 'UNLOADED';
            l_newtx_rec.comm_lines_api_id	:= l_ins_comm_lines_api_id;
	    l_newtx_rec.transaction_amount_orig	:= l_acctd_transaction_amount;
	    l_newtx_rec.adjust_date		:= SYSDATE;
	    l_newtx_rec.adjusted_by		:= x_adjusted_by;
	    l_newtx_rec.revenue_type		:= 'REVENUE';
	    l_newtx_rec.adjust_comments		:= x_adjust_comments;
	    l_newtx_rec.adjust_status		:= 'DEALASGN';
	    l_newtx_rec.adj_comm_lines_api_id	:= l_adj_tbl(1).comm_lines_api_id;
	    l_newtx_rec.direct_salesrep_number	:= l_salesrep_number;
	    --
	    cn_invoice_changes_pvt.prepare_api_record(
		p_newtx_rec			=> l_newtx_rec,
		p_old_adj_tbl			=> l_adj_tbl,
		x_final_trx_rec			=> o_newtx_rec,
		x_return_status 		=> x_return_status);
            -- codeCheck: I will explain later about this conversion.
            cn_invoice_changes_pvt.convert_adj_to_api(
		p_adj_rec			=> o_newtx_rec,
		x_api_rec			=> l_api_rec);
	    --
   	    cn_comm_lines_api_pkg.insert_row(l_api_rec);
   	    --
         END IF;
      ELSE
         exit;
      END IF;
   END LOOP;
   DBMS_SQL.close_cursor(assign_select_cursor);
END deal_assign;
--
PROCEDURE get_cust_info(
   	p_comm_lines_api_id	IN	NUMBER,
	p_load_status		IN	VARCHAR2,
	x_cust_info_rec		OUT NOCOPY     cust_info_rec) IS
BEGIN
   -- First check in header table.
   BEGIN
      SELECT CCH.customer_id,RAC.customer_number,RAC.customer_name,
             CCH.bill_to_address_id,RABA.address1,RABA.address2,
             RABA.address3,RABA.address4,RABA.city,RABA.postal_code,
             RABA.state,CCH.ship_to_address_id,RASA.address1,
             RASA.address2,RASA.address3,RASA.address4,RASA.city,
             RASA.postal_code,RASA.state,CCH.bill_to_contact_id,
             RABC.person_last_name||', ' ||RABC.person_first_name,
             CCH.ship_to_contact_id,
             RASC.person_last_name||', '||RASC.person_first_name

        INTO x_cust_info_rec.customer_id,
      	  x_cust_info_rec.customer_number,
      	  x_cust_info_rec.customer_name,
      	  x_cust_info_rec.bill_to_address_id,
      	  x_cust_info_rec.bill_to_address1,
      	  x_cust_info_rec.bill_to_address2,
      	  x_cust_info_rec.bill_to_address3,
      	  x_cust_info_rec.bill_to_address4,
      	  x_cust_info_rec.bill_to_city,
      	  x_cust_info_rec.bill_to_postal_code,
      	  x_cust_info_rec.bill_to_state,
      	  x_cust_info_rec.ship_to_address_id,
      	  x_cust_info_rec.ship_to_address1,
      	  x_cust_info_rec.ship_to_address2,
      	  x_cust_info_rec.ship_to_address3,
      	  x_cust_info_rec.ship_to_address4,
      	  x_cust_info_rec.ship_to_city,
      	  x_cust_info_rec.ship_to_postal_code,
      	  x_cust_info_rec.ship_to_state,
      	  x_cust_info_rec.bill_to_contact_id,
      	  x_cust_info_rec.bill_to_contact,
      	  x_cust_info_rec.ship_to_contact_id,
      	  x_cust_info_rec.ship_to_contact

        FROM cn_commission_headers cch,
             (SELECT CUST_ACCT.CUST_ACCOUNT_ID CUSTOMER_ID, substrb(PARTY.PARTY_NAME,1,50) CUSTOMER_NAME,
               CUST_ACCT.ACCOUNT_NUMBER CUSTOMER_NUMBER
               FROM HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
               WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID) rac,
             (SELECT  ACCT_SITE.CUST_ACCT_SITE_ID /* ADDRESS_ID */ ,
               LOC.ADDRESS1 , LOC.ADDRESS2 , LOC.ADDRESS3 , LOC.ADDRESS4 , LOC.CITY , LOC.POSTAL_CODE ,
               LOC.STATE FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
               HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
               WHERE ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
               AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
               AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
               AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)) raba,
             (SELECT  ACCT_SITE.CUST_ACCT_SITE_ID /* ADDRESS_ID */ ,
               LOC.ADDRESS1 , LOC.ADDRESS2 , LOC.ADDRESS3 , LOC.ADDRESS4 , LOC.CITY , LOC.POSTAL_CODE ,
               LOC.STATE FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
               HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
               WHERE ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
               AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
               AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
               AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)) rasa,
             (SELECT ACCT_ROLE.CUST_ACCOUNT_ROLE_ID /* CONTACT_ID */ ,
              	substrb(PARTY.PERSON_LAST_NAME,1,50) PERSON_LAST_NAME,
              	substrb(PARTY.PERSON_FIRST_NAME,1,40) PERSON_FIRST_NAME
               FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, HZ_PARTIES PARTY, HZ_RELATIONSHIPS REL,
              	HZ_ORG_CONTACTS ORG_CONT, HZ_PARTIES REL_PARTY, HZ_CUST_ACCOUNTS ROLE_ACCT
               WHERE 	ACCT_ROLE.PARTY_ID = REL.PARTY_ID
               AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
               AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
               AND REL.SUBJECT_ID = PARTY.PARTY_ID
               AND REL.PARTY_ID = REL_PARTY.PARTY_ID
               AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
               AND ROLE_ACCT.PARTY_ID = REL.OBJECT_ID /* AND REL.DIRECTIONAL_FLAG = 'F' */
               ) rabc,
           (SELECT ACCT_ROLE.CUST_ACCOUNT_ROLE_ID /* CONTACT_ID */ ,
          	    substrb(PARTY.PERSON_LAST_NAME,1,50) PERSON_LAST_NAME,
              	substrb(PARTY.PERSON_FIRST_NAME,1,40) PERSON_FIRST_NAME
             FROM 	HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, HZ_PARTIES PARTY, HZ_RELATIONSHIPS REL,
              	HZ_ORG_CONTACTS ORG_CONT, HZ_PARTIES REL_PARTY, HZ_CUST_ACCOUNTS ROLE_ACCT
            WHERE 	ACCT_ROLE.PARTY_ID = REL.PARTY_ID
             AND 	ACCT_ROLE.ROLE_TYPE = 'CONTACT'
             AND 	ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
             AND 	REL.SUBJECT_ID = PARTY.PARTY_ID
             AND 	REL.PARTY_ID = REL_PARTY.PARTY_ID
             AND 	REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
             AND 	REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
             AND 	ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
             AND 	ROLE_ACCT.PARTY_ID = REL.OBJECT_ID /* AND REL.DIRECTIONAL_FLAG = 'F' */
           )  rasc
       WHERE CCH.comm_lines_api_id = p_comm_lines_api_id
         AND CCH.customer_id = RAC.customer_id (+)
         AND CCH.bill_to_address_id = RABA.CUST_ACCT_SITE_ID (+)
         AND CCH.ship_to_address_id = RASA.CUST_ACCT_SITE_ID (+)
         AND CCH.bill_to_contact_id = RABC.CUST_ACCOUNT_ROLE_ID (+)
         AND CCH.ship_to_contact_id = RASC.CUST_ACCOUNT_ROLE_ID (+)
         AND ROWNUM < 2;
   EXCEPTION
      WHEN OTHERS THEN
         BEGIN
	    SELECT CCLA.customer_id,RAC.customer_number,RAC.customer_name,
          	   CCLA.bill_to_address_id,RABA.address1,RABA.address2,
          	   RABA.address3,RABA.address4,RABA.city,RABA.postal_code,
          	   RABA.state,CCLA.ship_to_address_id,RASA.address1,
          	   RASA.address2,RASA.address3,RASA.address4,RASA.city,
          	   RASA.postal_code,RASA.state,CCLA.bill_to_contact_id,
          	   RABC.person_last_name||', ' ||RABC.person_first_name,
          	   CCLA.ship_to_contact_id,
          	   RASC.person_last_name||', '||RASC.person_first_name

     	      INTO x_cust_info_rec.customer_id,
   	           x_cust_info_rec.customer_number,
   	           x_cust_info_rec.customer_name,
   	           x_cust_info_rec.bill_to_address_id,
   	           x_cust_info_rec.bill_to_address1,
   	           x_cust_info_rec.bill_to_address2,
   	           x_cust_info_rec.bill_to_address3,
   	           x_cust_info_rec.bill_to_address4,
   	           x_cust_info_rec.bill_to_city,
   	           x_cust_info_rec.bill_to_postal_code,
   	           x_cust_info_rec.bill_to_state,
   	           x_cust_info_rec.ship_to_address_id,
   	           x_cust_info_rec.ship_to_address1,
   	           x_cust_info_rec.ship_to_address2,
   	           x_cust_info_rec.ship_to_address3,
   	           x_cust_info_rec.ship_to_address4,
   	           x_cust_info_rec.ship_to_city,
   	           x_cust_info_rec.ship_to_postal_code,
   	           x_cust_info_rec.ship_to_state,
   	           x_cust_info_rec.bill_to_contact_id,
   	           x_cust_info_rec.bill_to_contact,
   	           x_cust_info_rec.ship_to_contact_id,
   	           x_cust_info_rec.ship_to_contact

             FROM  cn_comm_lines_api ccla,
             (SELECT CUST_ACCT.CUST_ACCOUNT_ID CUSTOMER_ID, substrb(PARTY.PARTY_NAME,1,50) CUSTOMER_NAME,
               CUST_ACCT.ACCOUNT_NUMBER CUSTOMER_NUMBER
               FROM HZ_PARTIES PARTY, HZ_CUST_ACCOUNTS CUST_ACCT
               WHERE CUST_ACCT.PARTY_ID = PARTY.PARTY_ID) rac,
             (SELECT  ACCT_SITE.CUST_ACCT_SITE_ID /* ADDRESS_ID */ ,
               LOC.ADDRESS1 , LOC.ADDRESS2 , LOC.ADDRESS3 , LOC.ADDRESS4 , LOC.CITY , LOC.POSTAL_CODE ,
               LOC.STATE FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
               HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
               WHERE ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
               AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
               AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
               AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)) raba,
             (SELECT  ACCT_SITE.CUST_ACCT_SITE_ID /* ADDRESS_ID */ ,
               LOC.ADDRESS1 , LOC.ADDRESS2 , LOC.ADDRESS3 , LOC.ADDRESS4 , LOC.CITY , LOC.POSTAL_CODE ,
               LOC.STATE FROM HZ_PARTY_SITES PARTY_SITE, HZ_LOC_ASSIGNMENTS LOC_ASSIGN,
               HZ_LOCATIONS LOC, HZ_CUST_ACCT_SITES_ALL ACCT_SITE
               WHERE ACCT_SITE.PARTY_SITE_ID = PARTY_SITE.PARTY_SITE_ID
               AND LOC.LOCATION_ID = PARTY_SITE.LOCATION_ID
               AND LOC.LOCATION_ID = LOC_ASSIGN.LOCATION_ID
               AND NVL(ACCT_SITE.ORG_ID, -99) = NVL(LOC_ASSIGN.ORG_ID, -99)) rasa,
             (SELECT ACCT_ROLE.CUST_ACCOUNT_ROLE_ID /* CONTACT_ID */ ,
              	substrb(PARTY.PERSON_LAST_NAME,1,50) PERSON_LAST_NAME,
              	substrb(PARTY.PERSON_FIRST_NAME,1,40) PERSON_FIRST_NAME
               FROM HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, HZ_PARTIES PARTY, HZ_RELATIONSHIPS REL,
              	HZ_ORG_CONTACTS ORG_CONT, HZ_PARTIES REL_PARTY, HZ_CUST_ACCOUNTS ROLE_ACCT
               WHERE 	ACCT_ROLE.PARTY_ID = REL.PARTY_ID
               AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
               AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
               AND REL.SUBJECT_ID = PARTY.PARTY_ID
               AND REL.PARTY_ID = REL_PARTY.PARTY_ID
               AND REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
               AND ROLE_ACCT.PARTY_ID = REL.OBJECT_ID /* AND REL.DIRECTIONAL_FLAG = 'F' */
               ) rabc,
             (SELECT ACCT_ROLE.CUST_ACCOUNT_ROLE_ID,
          	    substrb(PARTY.PERSON_LAST_NAME,1,50) PERSON_LAST_NAME,
              	substrb(PARTY.PERSON_FIRST_NAME,1,40) PERSON_FIRST_NAME
               FROM 	HZ_CUST_ACCOUNT_ROLES ACCT_ROLE, HZ_PARTIES PARTY, HZ_RELATIONSHIPS REL,
              	HZ_ORG_CONTACTS ORG_CONT, HZ_PARTIES REL_PARTY, HZ_CUST_ACCOUNTS ROLE_ACCT
               WHERE 	ACCT_ROLE.PARTY_ID = REL.PARTY_ID
               AND 	ACCT_ROLE.ROLE_TYPE = 'CONTACT'
               AND 	ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
               AND 	REL.SUBJECT_ID = PARTY.PARTY_ID
               AND 	REL.PARTY_ID = REL_PARTY.PARTY_ID
               AND 	REL.SUBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND 	REL.OBJECT_TABLE_NAME = 'HZ_PARTIES'
               AND 	ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
               AND 	ROLE_ACCT.PARTY_ID = REL.OBJECT_ID /* AND REL.DIRECTIONAL_FLAG = 'F' */
               ) rasc
             WHERE ccla.comm_lines_api_id = p_comm_lines_api_id
               AND ccla.customer_id 	   = RAC.customer_id (+)
               AND ccla.bill_to_address_id = RABA.CUST_ACCT_SITE_ID (+)
               AND ccla.ship_to_address_id = RASA.CUST_ACCT_SITE_ID (+)
               AND ccla.bill_to_contact_id = RABC.CUST_ACCOUNT_ROLE_ID (+)
               AND ccla.ship_to_contact_id = RASC.CUST_ACCOUNT_ROLE_ID (+)
	       AND ROWNUM < 2;
	 EXCEPTION
	    WHEN OTHERS THEN
	       NULL;
	 END;
   END;
EXCEPTION
   WHEN OTHERS THEN
      NULL;
END;

PROCEDURE update_credit_credentials (
    p_comm_lines_api_id IN NUMBER,
    p_terr_id IN NUMBER,
    p_org_id IN NUMBER,
    p_adjusted_by IN VARCHAR2
)
IS
   /* Added to fix Crediting bug */
   CURSOR l_csr_credited_trx(l_nbr_comm_lines_api_id NUMBER, l_nbr_org_id NUMBER) IS
        SELECT COMM_LINES_API_ID, ORG_ID
        FROM CN_COMM_LINES_API
        WHERE ORG_ID = l_nbr_org_id
        AND TERR_ID IS NOT NULL
        AND (adjust_status NOT IN ('FROZEN','REVERSAL','SCA PENDING'))-- OR
--	    adjust_status IS NULL)
	    START WITH COMM_LINES_API_ID = l_nbr_comm_lines_api_id
        CONNECT BY PRIOR COMM_LINES_API_ID = ADJ_COMM_LINES_API_ID;


   CURSOR l_csr_parent_trx(l_nbr_comm_lines_api_id NUMBER, l_nbr_org_id NUMBER) IS
        SELECT COMM_LINES_API_ID, ORG_ID FROM CN_COMM_LINES_API
        WHERE ORG_ID = l_nbr_org_id
        AND TERR_ID IS NULL
        AND (adjust_status NOT IN ('FROZEN','REVERSAL','SCA PENDING'))-- OR
--	    adjust_status IS NULL)
        START WITH COMM_LINES_API_ID = l_nbr_comm_lines_api_id
        CONNECT BY PRIOR ADJ_COMM_LINES_API_ID = COMM_LINES_API_ID;

   l_adj_comm_lines_api_id  NUMBER;
BEGIN
   /* Code added for Crediting, to obsolete any child records that have gone through
   the crediting cycle */
   IF p_terr_id IS NULL
   THEN
       FOR each_trx IN l_csr_credited_trx(p_comm_lines_api_id, p_org_id)
       LOOP

            cn_adjustments_pkg.api_negate_record(
   	        x_comm_lines_api_id	=> each_trx.comm_lines_api_id,
            x_adjusted_by		=> p_adjusted_by,
   	        x_adjust_comments	=> 'Parent transaction modified');
       END LOOP;
    ELSE IF p_terr_id IS NOT NULL
         THEN
                FOR parent_trx IN l_csr_parent_trx(p_comm_lines_api_id, p_org_id)
                LOOP
                    UPDATE CN_COMM_LINES_API
                    SET PRESERVE_CREDIT_OVERRIDE_FLAG = 'Y',
                    ADJUSTED_BY = p_adjusted_by
                    WHERE COMM_LINES_API_ID = parent_trx.comm_lines_api_id
                    AND ORG_ID = parent_trx.org_id;
                END LOOP;
         END IF;
   END IF;

--
END update_credit_credentials;

--
END cn_adjustments_pkg;




/
