--------------------------------------------------------
--  DDL for Package Body CN_IMP_TRXAPI_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CN_IMP_TRXAPI_PVT" AS
-- $Header: cnvimtxb.pls 120.5.12010000.7 2009/06/29 05:47:37 gmarwah ship $

G_PKG_NAME               CONSTANT VARCHAR2(30) := 'CN_IMP_TRXAPI_PVT';
G_FILE_NAME              CONSTANT VARCHAR2(12) := 'cnvimtxb.pls';

-- Start of comments
--    API name        : Trxapi_Import
--    Type            : Private.
--    Function        : programtransfer data from staging table into
--                      cn_comm_lines_api_all
--    Pre-reqs        : None.
--    Parameters      :
--    IN                  p_imp_header_id           IN    NUMBER,
--    OUT              : errbuf         OUT VARCHAR2       Required
--                      retcode        OUTVARCHAR2     Optional
--    Version :         Current version       1.0
--
--
--
--    Notes           : The import process will terminated when error occurs.
--       Cannot partially import data because if error happens and re-run
--       SQL*Loader to stage fixed data,the old one will be deleted first.
--       Because SQL*Loader run in APPEND mode.
-- End of comments

PROCEDURE Trxapi_Import
  (errbuf                    OUT NOCOPY   VARCHAR2,
   retcode                   OUT NOCOPY   VARCHAR2,
   p_imp_header_id           IN    NUMBER,
   p_org_id		     IN NUMBER
   ) IS

      l_status_code cn_imp_lines.status_code%TYPE := 'STAGE';

      CURSOR c_trxapi_imp_csr IS
	 SELECT
	   imp_line_id,
	   imp_header_id,
	   status_code,
	   error_code,
	   trim(resource_name) resource_name,
	   trim(employee_number) employee_number,
	   trim(processed_date) processed_date,
	   trim(transaction_amount) transaction_amount,
	   trim(quantity) quantity,
	   trim(order_number) order_number,
	   trim(order_date) order_date,
	   trim(invoice_number) invoice_number,
	   trim(invoice_date) invoice_date,
	   trim(revenue_type) revenue_type,
	   trim(sales_channel) sales_channel,
	   trim(revenue_class_name) revenue_class_name,
	   trim(attribute_category) attribute_category,
           trim(attribute1) attribute1  ,
           trim(attribute2) attribute2  ,
           trim(attribute3) attribute3  ,
           trim(attribute4) attribute4  ,
           trim(attribute5) attribute5  ,
           trim(attribute6) attribute6  ,
           trim(attribute7) attribute7  ,
           trim(attribute8) attribute8  ,
           trim(attribute9) attribute9  ,
           trim(attribute10) attribute10  ,
           trim(attribute11) attribute11  ,
           trim(attribute12) attribute12  ,
           trim(attribute13) attribute13  ,
           trim(attribute14) attribute14  ,
           trim(attribute15) attribute15  ,
           trim(attribute16) attribute16  ,
           trim(attribute17) attribute17  ,
           trim(attribute18) attribute18  ,
           trim(attribute19) attribute19  ,
           trim(attribute20) attribute20  ,
           trim(attribute21) attribute21  ,
           trim(attribute22) attribute22  ,
           trim(attribute23) attribute23  ,
           trim(attribute24) attribute24  ,
           trim(attribute25) attribute25  ,
           trim(attribute26) attribute26  ,
           trim(attribute27) attribute27  ,
           trim(attribute28) attribute28  ,
           trim(attribute29) attribute29  ,
           trim(attribute30) attribute30  ,
           trim(attribute31) attribute31  ,
           trim(attribute32) attribute32  ,
           trim(attribute33) attribute33  ,
           trim(attribute34) attribute34  ,
           trim(attribute35) attribute35  ,
           trim(attribute36) attribute36  ,
           trim(attribute37) attribute37  ,
           trim(attribute38) attribute38  ,
           trim(attribute39) attribute39  ,
           trim(attribute40) attribute40  ,
           trim(attribute41) attribute41  ,
           trim(attribute42) attribute42  ,
           trim(attribute43) attribute43  ,
           trim(attribute44) attribute44  ,
           trim(attribute45) attribute45  ,
           trim(attribute46) attribute46  ,
           trim(attribute47) attribute47  ,
           trim(attribute48) attribute48  ,
           trim(attribute49) attribute49  ,
           trim(attribute50) attribute50  ,
           trim(attribute51) attribute51  ,
           trim(attribute52) attribute52  ,
           trim(attribute53) attribute53  ,
           trim(attribute54) attribute54  ,
           trim(attribute55) attribute55  ,
           trim(attribute56) attribute56  ,
           trim(attribute57) attribute57  ,
           trim(attribute58) attribute58  ,
           trim(attribute59) attribute59  ,
           trim(attribute60) attribute60  ,
           trim(attribute61) attribute61  ,
           trim(attribute62) attribute62  ,
           trim(attribute63) attribute63  ,
           trim(attribute64) attribute64  ,
           trim(attribute65) attribute65  ,
           trim(attribute66) attribute66  ,
           trim(attribute67) attribute67  ,
           trim(attribute68) attribute68  ,
           trim(attribute69) attribute69  ,
           trim(attribute70) attribute70  ,
           trim(attribute71) attribute71  ,
           trim(attribute72) attribute72  ,
           trim(attribute73) attribute73  ,
           trim(attribute74) attribute74  ,
           trim(attribute75) attribute75  ,
           trim(attribute76) attribute76  ,
           trim(attribute77) attribute77  ,
           trim(attribute78) attribute78  ,
           trim(attribute79) attribute79  ,
           trim(attribute80) attribute80  ,
           trim(attribute81) attribute81  ,
           trim(attribute82) attribute82  ,
           trim(attribute83) attribute83  ,
           trim(attribute84) attribute84  ,
           trim(attribute85) attribute85  ,
           trim(attribute86) attribute86  ,
           trim(attribute87) attribute87  ,
           trim(attribute88) attribute88  ,
           trim(attribute89) attribute89  ,
           trim(attribute90) attribute90  ,
           trim(attribute91) attribute91  ,
           trim(attribute92) attribute92  ,
           trim(attribute93) attribute93  ,
           trim(attribute94) attribute94  ,
           trim(attribute95) attribute95  ,
           trim(attribute96) attribute96  ,
           trim(attribute97) attribute97  ,
           trim(attribute98) attribute98  ,
           trim(attribute99) attribute99  ,
           trim(attribute100) attribute100 ,
	   trim(commission_amount) commission_amount,
	   trim(exchange_rate) exchange_rate,
	   trim(transaction_currency_code) transaction_currency_code ,
	   trim(discount_percentage) discount_percentage,
	   trim(margin_percentage) margin_percentage,
	   trim(reason_code) reason_code ,
	   trim(pre_processed_code) pre_processed_code ,
	   trim(compensation_group_name) compensation_group_name ,
	   trim(plan_element_name) plan_element_name ,
	   trim(role_name) role_name ,
	   trim(rollup_date) rollup_date,
	   trim(line_number) line_number,
	   trim(split_pct) split_pct,
           -- Added new column, bugID 7033617
     NVL(trim(preserve_credit_override_flag),'N') preserve_credit_override_flag,
     trim(adjust_comments) adjust_comments
	   FROM CN_COMMLINE_API_IMP_V
	   WHERE imp_header_id = p_imp_header_id
	   AND status_code = l_status_code
	   ;

      l_api_name     CONSTANT VARCHAR2(30) := 'Trxapi_Import';

      l_trxapi_imp c_trxapi_imp_csr%ROWTYPE;
      l_salesrep_id cn_salesreps.salesrep_id%TYPE;
      l_rev_class_id cn_revenue_classes.revenue_class_id%TYPE;
      l_role_id  cn_roles.role_id%TYPE;
      l_period_id cn_acc_period_statuses_v.period_id%TYPE;
      l_rollup_period_id cn_acc_period_statuses_v.period_id%TYPE;
      l_quota_id  cn_quotas.quota_id%TYPE;
      l_comp_group_id cn_comp_groups.comp_group_id%TYPE;
      l_meaning cn_lookups.meaning%TYPE;

      l_processed_row NUMBER := 0;
      l_failed_row    NUMBER := 0;
      l_message       VARCHAR2(2000);
      l_error_code    VARCHAR2(30);
      l_comm_lines_api_id NUMBER(15);
      l_header_list       VARCHAR2(2000);
      l_sql_stmt          VARCHAR2(2000);
      err_num         NUMBER;
      l_msg_count     NUMBER := 0;
      l_imp_header      cn_imp_headers_pvt.imp_headers_rec_type := cn_imp_headers_pvt.G_MISS_IMP_HEADERS_REC;
      l_process_audit_id cn_process_audits.process_audit_id%TYPE;
	l_temp NUMBER;
        l_err_flag CHAR(1);

BEGIN
   retcode := 0 ;

   -- Get imp_header info
   SELECT name, status_code,server_flag,imp_map_id, source_column_num,
     import_type_code
     INTO l_imp_header.name ,l_imp_header.status_code ,
     l_imp_header.server_flag, l_imp_header.imp_map_id,
     l_imp_header.source_column_num,l_imp_header.import_type_code
     FROM cn_imp_headers
     WHERE imp_header_id = p_imp_header_id;

   -- open process audit batch
   cn_message_pkg.begin_batch
     ( x_process_type	=> l_imp_header.import_type_code,
       x_parent_proc_audit_id  => p_imp_header_id ,
       x_process_audit_id	=>  l_process_audit_id,
       x_request_id		=> null,
       p_org_id			=> p_org_id);

   cn_message_pkg.write
     (p_message_text    => 'TRXAPI: Start Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- Get source column name list and target column dynamic sql statement
   CN_IMPORT_PVT.build_error_rec
     (p_imp_header_id => p_imp_header_id,
      x_header_list => l_header_list,
      x_sql_stmt => l_sql_stmt);

   OPEN c_trxapi_imp_csr;
   LOOP
      FETCH c_trxapi_imp_csr INTO l_trxapi_imp;
      EXIT WHEN c_trxapi_imp_csr%notfound;

   BEGIN

      l_processed_row := l_processed_row + 1;
      l_rev_class_id := NULL;
      l_salesrep_id := NULL;

      cn_message_pkg.write
	(p_message_text    => 'TRXAPI:Record ' || To_char(l_processed_row) || ' imp_line_id = ' || To_char(l_trxapi_imp.imp_line_id),
	 p_message_type    => 'DEBUG');

      -- -------- Checking for all required fields ----------------- --
      -- Check required field
      IF l_trxapi_imp.processed_date IS NULL
	OR l_trxapi_imp.transaction_amount IS NULL
	  OR l_trxapi_imp.employee_number IS NULL
	   OR l_trxapi_imp.revenue_type IS NULL THEN
	 l_failed_row := l_failed_row + 1;
	 l_error_code := 'CN_IMP_MISS_REQUIRED';
	 l_message := fnd_message.get_string('CN','CN_IMP_MISS_REQUIRED');
	 CN_IMPORT_PVT.update_imp_lines
	   (p_imp_line_id => l_trxapi_imp.imp_line_id,
	    p_status_code => 'FAIL',
	    p_error_code  => l_error_code,
	    p_error_msg   => l_message);
	 CN_IMPORT_PVT.update_imp_headers
	   (p_imp_header_id => p_imp_header_id,
	    p_status_code => 'IMPORT_FAIL',
	    p_failed_row => l_failed_row);
	 cn_message_pkg.write
	   (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	    p_message_type    => 'ERROR');
	 CN_IMPORT_PVT.write_error_rec
	   (p_imp_header_id => p_imp_header_id,
	    p_imp_line_id => l_trxapi_imp.imp_line_id,
	    p_header_list => l_header_list,
	    p_sql_stmt => l_sql_stmt);

	 retcode := 2;
	 errbuf := l_message;
	 GOTO end_loop;
      END IF;

      -- Get salesrep_id
      BEGIN
	 SELECT salesrep_id
	   INTO l_salesrep_id
	   FROM cn_salesreps
	   WHERE employee_number = l_trxapi_imp.employee_number and org_id = p_org_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_RSRC_ID';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_RSRC_ID');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);

	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
      END;

      -- get process_period_id
      BEGIN
	 SELECT period_id
	   INTO l_period_id
	   FROM cn_acc_period_statuses_v
	   WHERE l_trxapi_imp.processed_date BETWEEN start_date AND end_date
	   AND period_status IN ('O','F') and org_id = p_org_id;
      EXCEPTION
	 WHEN no_data_found THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'NOT_WITHIN_OPEN_PERIODS';
	    l_message := fnd_message.get_string('CN','NOT_WITHIN_OPEN_PERIODS');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);

	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
      END;

      -- -------- Checking for all optional fields ----------------- --

      -- Get revenue_class_id when revenue_class_name exists
      IF l_trxapi_imp.revenue_class_name IS NOT NULL THEN
	 l_rev_class_id := cn_api.get_rev_class_id
	   (p_rev_class_name => l_trxapi_imp.revenue_class_name,
	    p_org_id	     => p_org_id);
	 IF l_rev_class_id IS NULL THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_REVCLS_ID';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_REVCLS_ID');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
	 END IF;
      END IF;

      -- Get quota_id from plan_element_name
      IF l_trxapi_imp.plan_element_name IS NOT NULL THEN
	 BEGIN
	    SELECT quota_id
	      INTO l_quota_id
	      FROM cn_quotas_v
	      WHERE name = l_trxapi_imp.plan_element_name and org_id = p_org_id
	      ;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_failed_row := l_failed_row + 1;
	       l_error_code := 'CN_IMP_NF_QUOTA';
	       l_message :=
		 fnd_message.get_string('CN','CN_IMP_NF_QUOTA');
	       CN_IMPORT_PVT.update_imp_lines
		 (p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_status_code => 'FAIL',
		  p_error_code  => l_error_code,
		  p_error_msg   => l_message);
	       CN_IMPORT_PVT.update_imp_headers
		 (p_imp_header_id => p_imp_header_id,
		  p_status_code => 'IMPORT_FAIL',
		  p_failed_row => l_failed_row);
	       cn_message_pkg.write
		 (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
		  p_message_type    => 'ERROR');
	       CN_IMPORT_PVT.write_error_rec
		 (p_imp_header_id => p_imp_header_id,
		  p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_header_list => l_header_list,
		  p_sql_stmt => l_sql_stmt);

	       retcode := 2;
	       errbuf := l_message;
	       GOTO end_loop;
	 END;
      END IF;

      -- Get comp_group_id from compensation_group_name
      IF l_trxapi_imp.compensation_group_name IS NOT NULL THEN
	 BEGIN
	    SELECT comp_group_id
	      INTO l_comp_group_id
	      FROM cn_comp_groups
	      WHERE name = l_trxapi_imp.compensation_group_name
	      ;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_failed_row := l_failed_row + 1;
	       l_error_code := 'CN_IMP_NF_CG';
	       l_message :=
		 fnd_message.get_string('CN','CN_IMP_NF_CG');
	       CN_IMPORT_PVT.update_imp_lines
		 (p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_status_code => 'FAIL',
		  p_error_code  => l_error_code,
		  p_error_msg   => l_message);
	       CN_IMPORT_PVT.update_imp_headers
		 (p_imp_header_id => p_imp_header_id,
		  p_status_code => 'IMPORT_FAIL',
		  p_failed_row => l_failed_row);
	       cn_message_pkg.write
		 (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
		  p_message_type    => 'ERROR');
	       CN_IMPORT_PVT.write_error_rec
		 (p_imp_header_id => p_imp_header_id,
		  p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_header_list => l_header_list,
		  p_sql_stmt => l_sql_stmt);

	       retcode := 2;
	       errbuf := l_message;
	       GOTO end_loop;
	 END;
      END IF;

      -- Get role_id when role_name exists
      IF l_trxapi_imp.role_name IS NOT NULL THEN
	 l_role_id := cn_api.get_role_id
	   (p_role_name => l_trxapi_imp.role_name);
	 IF l_role_id IS NULL THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_ROLE';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_ROLE');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
	 END IF;
      END IF;

      -- get rollup_period_id
      IF l_trxapi_imp.rollup_date IS NOT NULL THEN
	 BEGIN
	    SELECT period_id
	      INTO l_rollup_period_id
	      FROM cn_acc_period_statuses_v
	      WHERE l_trxapi_imp.rollup_date BETWEEN start_date AND end_date
	      AND period_status IN ('O','F') and org_id = p_org_id;
	 EXCEPTION
	    WHEN no_data_found THEN
	       l_failed_row := l_failed_row + 1;
	       l_error_code := 'CN_IMP_NF_ROLLUP_DATE';
	       l_message :=
		 fnd_message.get_string('CN','CN_IMP_NF_ROLLUP_DATE');
	       CN_IMPORT_PVT.update_imp_lines
		 (p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_status_code => 'FAIL',
		  p_error_code  => l_error_code,
		  p_error_msg   => l_message);
	       CN_IMPORT_PVT.update_imp_headers
		 (p_imp_header_id => p_imp_header_id,
		  p_status_code => 'IMPORT_FAIL',
		  p_failed_row => l_failed_row);
	       cn_message_pkg.write
		 (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
		  p_message_type    => 'ERROR');
	       CN_IMPORT_PVT.write_error_rec
		 (p_imp_header_id => p_imp_header_id,
		  p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_header_list => l_header_list,
		  p_sql_stmt => l_sql_stmt);

	       retcode := 2;
	       errbuf := l_message;
	       GOTO end_loop;
	 END;
      END IF;

      -- Check revenue_type exist
      IF l_trxapi_imp.revenue_type IS NOT NULL THEN
	 l_meaning := NULL;
	 l_meaning := cn_api.get_lkup_meaning
	   ( p_lkup_code => l_trxapi_imp.revenue_type,
	     p_lkup_type => 'REVENUE_TYPE' );
	 IF l_meaning IS NULL THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_REV_TYPE';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_REV_TYPE');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
	 END IF;
      END IF;

      -- Check reason_code exist
      IF l_trxapi_imp.reason_code IS NOT NULL THEN
	 l_meaning := NULL;
	 l_meaning := cn_api.get_lkup_meaning
	   ( p_lkup_code => l_trxapi_imp.reason_code,
	     p_lkup_type => 'ADJUSTMENT_REASON' );
	 IF l_meaning IS NULL THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_REASON_CODE';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_REASON_CODE');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
	 END IF;
      END IF;

      -- Check pre_processed_code exist
      IF l_trxapi_imp.pre_processed_code IS NOT NULL THEN
	 l_meaning := NULL;
	 l_meaning := cn_api.get_lkup_meaning
	   ( p_lkup_code => l_trxapi_imp.pre_processed_code,
	     p_lkup_type => 'PRE_PROCESSED_CODE' );
	 IF l_meaning IS NULL THEN
	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NF_PRE_PROC_CODE';
	    l_message := fnd_message.get_string('CN','CN_IMP_NF_PRE_PRO_CODE');
	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);
	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);
	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');
	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);
	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
	 END IF;
      END IF;

      -- Check transaction_currency_code exist
      IF l_trxapi_imp.transaction_currency_code IS NOT NULL THEN
	 l_meaning := NULL;
	 BEGIN
	    SELECT currency_code
	      INTO l_meaning FROM fnd_currencies_vl
	      WHERE currency_code = l_trxapi_imp.transaction_currency_code;

	 EXCEPTION
	    WHEN no_data_found THEN
	       l_failed_row := l_failed_row + 1;
	       l_error_code := 'CN_IMP_NF_TRX_CURR_CODE';
	       l_message :=
		 fnd_message.get_string('CN','CN_IMP_NF_TRX_CURR_CODE');
	       CN_IMPORT_PVT.update_imp_lines
		 (p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_status_code => 'FAIL',
		  p_error_code  => l_error_code,
		  p_error_msg   => l_message);
	       CN_IMPORT_PVT.update_imp_headers
		 (p_imp_header_id => p_imp_header_id,
		  p_status_code => 'IMPORT_FAIL',
		  p_failed_row => l_failed_row);
	       cn_message_pkg.write
		 (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
		  p_message_type    => 'ERROR');
	       CN_IMPORT_PVT.write_error_rec
		 (p_imp_header_id => p_imp_header_id,
		  p_imp_line_id => l_trxapi_imp.imp_line_id,
		  p_header_list => l_header_list,
		  p_sql_stmt => l_sql_stmt);
	       retcode := 2;
	       errbuf := l_message;
	       GOTO end_loop;
	 END;
       ELSE
               -- set transaction_currency_code to functional curr code
               l_trxapi_imp.transaction_currency_code := CN_GLOBAL_VAR.get_currency_code(p_org_id);
      END IF;


   if l_trxapi_imp.split_pct is null and upper(l_trxapi_imp.revenue_type) = 'REVENUE' THEN
	l_trxapi_imp.split_pct := 100;
   END IF;


    -- Checking split pct value is number or not
     BEGIN
     if l_trxapi_imp.split_pct is not null then
    	 SELECT to_number(l_trxapi_imp.split_pct) into l_temp from dual;
      end if;

      EXCEPTION

	 WHEN others THEN

	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NOT_VALID_NUMBER';
	    l_message := fnd_message.get_string('CN','CN_IMP_NOT_VALID_NUMBER');

	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);

	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);

	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');

	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);

	    retcode := 2;
	    errbuf := l_message;
	    GOTO end_loop;
      END;

    -- checking Split Pct -ve condition
      IF l_trxapi_imp.split_pct is not null AND l_trxapi_imp.split_pct <= 0 THEN

	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_IMP_NOT_ZERO_NEG';
	    l_message := fnd_message.get_string('CN','CN_IMP_NOT_ZERO_NEG');

	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);

	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);

	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');

	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);

	    retcode := 2;
	    errbuf := l_message;

	    GOTO end_loop;

      END IF;


      IF upper(l_trxapi_imp.revenue_type) = 'REVENUE' AND l_trxapi_imp.split_pct > 100 THEN

	    l_failed_row := l_failed_row + 1;
	    l_error_code := 'CN_REVENUE_TYPE_SPLIT_PCT_100';
	    l_message := fnd_message.get_string('CN','CN_REVENUE_TYPE_SPLIT_PCT_100');

	    CN_IMPORT_PVT.update_imp_lines
	      (p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_status_code => 'FAIL',
	       p_error_code  => l_error_code,
	       p_error_msg   => l_message);

	    CN_IMPORT_PVT.update_imp_headers
	      (p_imp_header_id => p_imp_header_id,
	       p_status_code => 'IMPORT_FAIL',
	       p_failed_row => l_failed_row);

	    cn_message_pkg.write
	      (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	       p_message_type    => 'ERROR');

	    CN_IMPORT_PVT.write_error_rec
	      (p_imp_header_id => p_imp_header_id,
	       p_imp_line_id => l_trxapi_imp.imp_line_id,
	       p_header_list => l_header_list,
	       p_sql_stmt => l_sql_stmt);

	    retcode := 2;
	    errbuf := l_message;

	    GOTO end_loop;

      END IF;

--Added for bug 5559459

       IF l_trxapi_imp.order_number IS NOT NULL THEN

         l_err_flag := 'N';
       DECLARE

         l_order_num NUMBER ;

       BEGIN

         SELECT to_number(l_trxapi_imp.order_number)
         INTO l_order_num
         FROM dual;

       EXCEPTION
       WHEN OTHERS
       THEN
          l_err_flag := 'Y';
       END;

         IF l_err_flag = 'Y'
         THEN
             l_failed_row := l_failed_row + 1;
             l_error_code := 'CN_ORDER_NUMBER_ALPHANUM';
             l_message := fnd_message.get_string('CN','CN_ORDER_NUMBER_ALPHANUM');

             CN_IMPORT_PVT.update_imp_lines
               (p_imp_line_id => l_trxapi_imp.imp_line_id,
                p_status_code => 'FAIL',
                p_error_code  => l_error_code,
                p_error_msg   => l_message);

             CN_IMPORT_PVT.update_imp_headers
               (p_imp_header_id => p_imp_header_id,
                p_status_code => 'IMPORT_FAIL',
                p_failed_row => l_failed_row);

             cn_message_pkg.write
               (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
                p_message_type    => 'ERROR');

             CN_IMPORT_PVT.write_error_rec
               (p_imp_header_id => p_imp_header_id,
                p_imp_line_id => l_trxapi_imp.imp_line_id,
                p_header_list => l_header_list,
                p_sql_stmt => l_sql_stmt);

             retcode := 2;
             errbuf := l_message;

             GOTO end_loop;
         END IF;
       END IF;


 -- End of addition

      -- insert into cn_comm_lines_api
      SELECT cn_comm_lines_api_s.NEXTVAL INTO l_comm_lines_api_id FROM dual;

      INSERT INTO cn_comm_lines_api
	(ORG_ID,
	 comm_lines_api_id,
	 salesrep_id,
	 processed_date,
	 processed_period_id,
	 transaction_amount,
	 trx_type,
	 employee_number,
	 revenue_class_id,
	 quantity,
	 order_number,
	 booked_date,
	 invoice_number,
	 invoice_date,
	 revenue_type,
	 sales_channel,
	 imp_header_id,
	 load_status,
	 created_by,
	 creation_date,
	 last_updated_by,
	 last_update_date,
	 last_update_login,
	 object_version_number,
	 attribute_category,
	 attribute1  ,
	 attribute2  ,
	 attribute3  ,
	 attribute4  ,
	 attribute5  ,
	 attribute6  ,
	 attribute7  ,
	 attribute8  ,
	 attribute9  ,
	 attribute10  ,
	 attribute11  ,
	 attribute12  ,
	 attribute13  ,
	 attribute14  ,
	 attribute15  ,
	 attribute16  ,
	 attribute17  ,
	 attribute18  ,
	 attribute19  ,
	 attribute20  ,
	 attribute21  ,
	 attribute22  ,
	 attribute23  ,
	 attribute24  ,
	 attribute25  ,
	 attribute26  ,
	 attribute27  ,
	 attribute28  ,
	 attribute29  ,
	 attribute30  ,
	 attribute31  ,
	 attribute32  ,
	 attribute33  ,
	 attribute34  ,
	 attribute35  ,
	 attribute36  ,
	 attribute37  ,
	 attribute38  ,
	 attribute39  ,
	 attribute40  ,
	 attribute41  ,
	 attribute42  ,
	 attribute43  ,
	 attribute44  ,
	 attribute45  ,
	 attribute46  ,
	 attribute47  ,
	 attribute48  ,
	 attribute49  ,
	 attribute50  ,
	 attribute51  ,
	 attribute52  ,
	 attribute53  ,
	 attribute54  ,
	 attribute55  ,
	 attribute56  ,
	 attribute57  ,
	 attribute58  ,
	 attribute59  ,
	 attribute60  ,
	 attribute61  ,
	 attribute62  ,
	 attribute63  ,
	 attribute64  ,
	 attribute65  ,
	 attribute66  ,
	 attribute67  ,
	 attribute68  ,
	 attribute69  ,
	 attribute70  ,
	 attribute71  ,
	 attribute72  ,
	 attribute73  ,
	 attribute74  ,
	 attribute75  ,
	 attribute76  ,
	 attribute77  ,
	 attribute78  ,
	 attribute79  ,
	 attribute80  ,
	 attribute81  ,
	 attribute82  ,
	 attribute83  ,
	 attribute84  ,
	 attribute85  ,
	 attribute86  ,
	 attribute87  ,
	 attribute88  ,
	 attribute89  ,
	 attribute90  ,
	 attribute91  ,
	 attribute92  ,
	 attribute93  ,
	 attribute94  ,
	 attribute95  ,
	 attribute96  ,
	 attribute97  ,
	 attribute98  ,
	 attribute99  ,
	attribute100 ,
	commission_amount ,
	exchange_rate ,
	transaction_currency_code ,
	discount_percentage ,
	margin_percentage ,
	reason_code ,
	pre_processed_code ,
	comp_group_id ,
	quota_id ,
	role_id ,
	rollup_date ,
	rollup_period_id,
	line_number,
	split_pct,
  -- Added new column, bugID 7033617
  preserve_credit_override_flag,
  adjust_comments
	 ) VALUES
	(p_org_id,
	 l_comm_lines_api_id,
	 l_salesrep_id,
	 To_date(l_trxapi_imp.processed_date,'DD/MM/YYYY'),
	 l_period_id,
	 To_number(l_trxapi_imp.transaction_amount),
	 'MAN',
	 l_trxapi_imp.employee_number,
	 l_rev_class_id,
	 To_number(l_trxapi_imp.quantity),
	 To_number(l_trxapi_imp.order_number),
	 To_date(l_trxapi_imp.order_date,'DD/MM/YYYY'),
	 l_trxapi_imp.invoice_number,
	 To_date(l_trxapi_imp.invoice_date,'DD/MM/YYYY'),
	 l_trxapi_imp.revenue_type,
	 l_trxapi_imp.sales_channel,
	 l_trxapi_imp.imp_header_id,
	 'UNLOADED',
	 fnd_global.user_id,
	 sysdate,
	 fnd_global.user_id,
	 sysdate,
	 fnd_global.login_id,
	 1,
	 l_trxapi_imp.attribute_category,
	 l_trxapi_imp.attribute1  ,
	 l_trxapi_imp.attribute2  ,
	 l_trxapi_imp.attribute3  ,
	 l_trxapi_imp.attribute4  ,
	 l_trxapi_imp.attribute5  ,
	 l_trxapi_imp.attribute6  ,
	 l_trxapi_imp.attribute7  ,
	 l_trxapi_imp.attribute8  ,
	 l_trxapi_imp.attribute9  ,
	 l_trxapi_imp.attribute10  ,
	 l_trxapi_imp.attribute11  ,
	 l_trxapi_imp.attribute12  ,
	 l_trxapi_imp.attribute13  ,
	 l_trxapi_imp.attribute14  ,
	 l_trxapi_imp.attribute15  ,
	 l_trxapi_imp.attribute16  ,
	 l_trxapi_imp.attribute17  ,
	 l_trxapi_imp.attribute18  ,
	 l_trxapi_imp.attribute19  ,
	 l_trxapi_imp.attribute20  ,
	 l_trxapi_imp.attribute21  ,
	 l_trxapi_imp.attribute22  ,
	 l_trxapi_imp.attribute23  ,
	 l_trxapi_imp.attribute24  ,
	 l_trxapi_imp.attribute25  ,
	 l_trxapi_imp.attribute26  ,
	 l_trxapi_imp.attribute27  ,
	 l_trxapi_imp.attribute28  ,
	 l_trxapi_imp.attribute29  ,
	 l_trxapi_imp.attribute30  ,
	 l_trxapi_imp.attribute31  ,
	 l_trxapi_imp.attribute32  ,
	 l_trxapi_imp.attribute33  ,
	 l_trxapi_imp.attribute34  ,
	 l_trxapi_imp.attribute35  ,
	 l_trxapi_imp.attribute36  ,
	 l_trxapi_imp.attribute37  ,
	 l_trxapi_imp.attribute38  ,
	 l_trxapi_imp.attribute39  ,
	 l_trxapi_imp.attribute40  ,
	 l_trxapi_imp.attribute41  ,
	 l_trxapi_imp.attribute42  ,
	 l_trxapi_imp.attribute43  ,
	 l_trxapi_imp.attribute44  ,
	 l_trxapi_imp.attribute45  ,
	 l_trxapi_imp.attribute46  ,
	 l_trxapi_imp.attribute47  ,
	 l_trxapi_imp.attribute48  ,
	 l_trxapi_imp.attribute49  ,
	 l_trxapi_imp.attribute50  ,
	 l_trxapi_imp.attribute51  ,
	 l_trxapi_imp.attribute52  ,
	 l_trxapi_imp.attribute53  ,
	 l_trxapi_imp.attribute54  ,
	 l_trxapi_imp.attribute55  ,
	 l_trxapi_imp.attribute56  ,
	 l_trxapi_imp.attribute57  ,
	 l_trxapi_imp.attribute58  ,
	 l_trxapi_imp.attribute59  ,
	 l_trxapi_imp.attribute60  ,
	 l_trxapi_imp.attribute61  ,
	 l_trxapi_imp.attribute62  ,
	 l_trxapi_imp.attribute63  ,
	 l_trxapi_imp.attribute64  ,
	 l_trxapi_imp.attribute65  ,
	 l_trxapi_imp.attribute66  ,
	 l_trxapi_imp.attribute67  ,
	 l_trxapi_imp.attribute68  ,
	 l_trxapi_imp.attribute69  ,
	 l_trxapi_imp.attribute70  ,
	 l_trxapi_imp.attribute71  ,
	 l_trxapi_imp.attribute72  ,
	 l_trxapi_imp.attribute73  ,
	 l_trxapi_imp.attribute74  ,
	 l_trxapi_imp.attribute75  ,
	 l_trxapi_imp.attribute76  ,
	 l_trxapi_imp.attribute77  ,
	 l_trxapi_imp.attribute78  ,
	 l_trxapi_imp.attribute79  ,
	 l_trxapi_imp.attribute80  ,
	 l_trxapi_imp.attribute81  ,
	 l_trxapi_imp.attribute82  ,
	 l_trxapi_imp.attribute83  ,
	 l_trxapi_imp.attribute84  ,
	 l_trxapi_imp.attribute85  ,
	 l_trxapi_imp.attribute86  ,
	 l_trxapi_imp.attribute87  ,
	 l_trxapi_imp.attribute88  ,
	 l_trxapi_imp.attribute89  ,
	 l_trxapi_imp.attribute90  ,
	 l_trxapi_imp.attribute91  ,
	 l_trxapi_imp.attribute92  ,
	 l_trxapi_imp.attribute93  ,
	 l_trxapi_imp.attribute94  ,
	 l_trxapi_imp.attribute95  ,
	 l_trxapi_imp.attribute96  ,
	 l_trxapi_imp.attribute97  ,
	 l_trxapi_imp.attribute98  ,
	 l_trxapi_imp.attribute99  ,
	l_trxapi_imp.attribute100 ,
	To_number(l_trxapi_imp.commission_amount) ,
	To_number(l_trxapi_imp.exchange_rate) ,
	l_trxapi_imp.transaction_currency_code ,
	To_number(l_trxapi_imp.discount_percentage),
	To_number(l_trxapi_imp.margin_percentage),
	l_trxapi_imp.reason_code ,
	l_trxapi_imp.pre_processed_code ,
	l_comp_group_id ,
	l_quota_id ,
	l_role_id ,
	To_date(l_trxapi_imp.rollup_date,'DD/MM/YYYY') ,
	l_rollup_period_id,
	To_number(l_trxapi_imp.line_number),
	To_number(l_trxapi_imp.split_pct),
 -- Added new column, bugID 7033617
  NVL(l_trxapi_imp.preserve_credit_override_flag,'N'),
  l_trxapi_imp.adjust_comments
	 );

      l_error_code := '';
      CN_IMPORT_PVT.update_imp_lines
	(p_imp_line_id => l_trxapi_imp.imp_line_id,
	 p_status_code => 'COMPLETE',
	 p_error_code  => l_error_code);

      cn_message_pkg.write
	(p_message_text    => 'TRXAPI:Import completed. comm_lines_api_id = ' || To_char(l_comm_lines_api_id),
	 p_message_type    => 'DEBUG');

      << end_loop>>
	NULL;

      -- update update_imp_headers:process_row
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => NULL,
	 p_processed_row => l_processed_row);

   EXCEPTION
      WHEN OTHERS THEN
	 l_failed_row := l_failed_row + 1;
	 l_error_code := SQLCODE;
	 l_message := SUBSTR (SQLERRM , 1 , 2000);
	 CN_IMPORT_PVT.update_imp_lines
	   (p_imp_line_id => l_trxapi_imp.imp_line_id,
	    p_status_code => 'FAIL',
	    p_error_code  => l_error_code,
	    p_error_msg   => l_message);
	 CN_IMPORT_PVT.update_imp_headers
	   (p_imp_header_id => p_imp_header_id,
	    p_status_code => 'IMPORT_FAIL',
	    p_processed_row => l_processed_row,
	    p_failed_row => l_failed_row);
	 cn_message_pkg.write
	   (p_message_text    => 'Record ' || To_char(l_processed_row) || ':' || l_message,
	    p_message_type    => 'ERROR');
	 CN_IMPORT_PVT.write_error_rec
	   (p_imp_header_id => p_imp_header_id,
	    p_imp_line_id => l_trxapi_imp.imp_line_id,
	    p_header_list => l_header_list,
	    p_sql_stmt => l_sql_stmt);
	 retcode := 2;
	 errbuf := l_message;
   END;

   END LOOP; -- c_trxapi_imp_csr
   IF c_trxapi_imp_csr%ROWCOUNT = 0 THEN
      l_processed_row := 0;
   END IF;
   CLOSE c_trxapi_imp_csr;
   IF l_failed_row = 0 AND retcode = 0 THEN
      -- update update_imp_headers
      CN_IMPORT_PVT.update_imp_headers
	(p_imp_header_id => p_imp_header_id,
	 p_status_code => 'COMPLETE',
	 p_processed_row => l_processed_row,
	 p_failed_row => l_failed_row);
   END IF;

   cn_message_pkg.write
     (p_message_text    => 'TRXAPI: End Transfer Data. imp_header_id = ' || To_char(p_imp_header_id),
      p_message_type    => 'MILESTONE');

   -- close process batch
   cn_message_pkg.end_batch(l_process_audit_id);

  -- Commit all imports
   COMMIT;

EXCEPTION
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      retcode := 2 ;
      cn_message_pkg.end_batch(l_process_audit_id);
      FND_MSG_PUB.count_and_get
	(p_count   =>  l_msg_count ,
	 p_data    =>  errbuf   ,
	 p_encoded => FND_API.G_FALSE
	 );

   WHEN OTHERS THEN
      err_num :=  SQLCODE;
      IF err_num = -6501 THEN
	 retcode := 2 ;
	 errbuf := fnd_program.message;
       ELSE
	 retcode := 2 ;
	 IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
           THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME ,l_api_name );
	 END IF;
	 FND_MSG_PUB.count_and_get
	   (p_count   =>  l_msg_count ,
	    p_data    =>  errbuf   ,
	    p_encoded => FND_API.G_FALSE
	    );
      END IF;
      cn_message_pkg.set_error(l_api_name,errbuf);
      cn_message_pkg.end_batch(l_process_audit_id);

END Trxapi_Import;

END CN_IMP_TRXAPI_PVT;

/
