--------------------------------------------------------
--  DDL for Package Body OKL_INTERNAL_TO_EXTERNAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_INTERNAL_TO_EXTERNAL" AS
/* $Header: OKLRIEXB.pls 120.24.12010000.3 2009/06/03 04:19:20 racheruv ship $ */

   -- Start of wraper code generated automatically by Debug code generator
  l_module VARCHAR2(40) := 'LEASE.RECEIVABLES.INVOICE';
  l_debug_enabled CONSTANT VARCHAR2(10) := Okl_Debug_Pub.check_log_enabled;
  l_level_procedure NUMBER;
  is_debug_procedure_on BOOLEAN;
  -- End of wraper code generated automatically by Debug code generator

  --fmiao 5209209 change
  ----------------------------------------------
  -- Global variables for bulk processing
  ----------------------------------------------

  l_xsi_cnt     NUMBER := 0;
  l_xls_cnt     NUMBER := 0;
  l_esd_cnt     NUMBER := 0;

  TYPE xsi_tbl_type IS TABLE OF OKL_EXT_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xls_tbl_type IS TABLE OF OKL_XTL_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE esd_tbl_type IS TABLE OF OKL_XTD_SELL_INVS_B%ROWTYPE INDEX BY BINARY_INTEGER;

  xsi_tbl       xsi_tbl_type;
  xls_tbl       xls_tbl_type;
  esd_tbl       esd_tbl_type;

  l_xsitl_cnt     NUMBER := 0;
  l_xlstl_cnt     NUMBER := 0;
  l_esdtl_cnt     NUMBER := 0;

  TYPE xsitl_tbl_type IS TABLE OF OKL_EXT_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE xlstl_tbl_type IS TABLE OF OKL_XTL_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;
  TYPE esdtl_tbl_type IS TABLE OF OKL_XTD_SELL_INVS_TL%ROWTYPE INDEX BY BINARY_INTEGER;

  xsitl_tbl       xsitl_tbl_type;
  xlstl_tbl       xlstl_tbl_type;
  esdtl_tbl       esdtl_tbl_type;

  TYPE error_rec_type IS RECORD (id NUMBER);
  TYPE error_tbl_type IS TABLE OF error_rec_type INDEX BY BINARY_INTEGER;

  error_tbl        error_tbl_type;
  total_error_tbl  error_tbl_type;

  --for bulk update
  l_tai_id_cnt NUMBER := 0;
  TYPE tai_id_tbl_type IS TABLE OF okl_trx_ar_invoices_b.id%TYPE
	      INDEX  BY BINARY_INTEGER;
  --TYPE num_tbl IS TABLE OF NUMBER INDEX  BY BINARY_INTEGER;
  tai_id_tbl tai_id_tbl_type;

  l_commit_cnt                 NUMBER := 0;
  l_commit_cnt2                NUMBER := 0;
  l_khr_id	okl_trx_ar_invoices_v.khr_id%TYPE := -1;
  l_max_commit_cnt             NUMBER := 500;

  --fmiao 5209209 change end

  -- -------------------------------------------------
  -- To print log messages
  -- -------------------------------------------------
  PROCEDURE print_to_log(p_message IN VARCHAR2) IS
  BEGIN

    Fnd_File.PUT_LINE(Fnd_File.LOG,   p_message);

    IF(Fnd_Log.level_statement >= Fnd_Log.g_current_runtime_level) THEN
      Fnd_Log.string(Fnd_Log.level_statement,   'okl_internal_to_external',   p_message);
    END IF;

    Okl_Debug_Pub.logmessage(p_message);
    --dbms_output.put_line(p_message);
  END print_to_log;

  --fmiao 5209209 change
  /*
  -- -------------------------------------------------
  -- To print log messages for xsi_rec
  -- -------------------------------------------------
  PROCEDURE print_xsi_rec(i_xsiv_rec IN okl_xsi_pvt.xsiv_rec_type) IS
  BEGIN
    print_to_log('Start XSI Record (+)');
    print_to_log('i_xsiv_rec.trx_date ' || i_xsiv_rec.trx_date);
    print_to_log('i_xsiv_rec.customer_id ' || i_xsiv_rec.customer_id);
    print_to_log('i_xsiv_rec.receipt_method_id ' || i_xsiv_rec.receipt_method_id);
    print_to_log('i_xsiv_rec.term_id ' || i_xsiv_rec.term_id);
    print_to_log('i_xsiv_rec.currency_code ' || i_xsiv_rec.currency_code);
    print_to_log('i_xsiv_rec.currency_conversion_type ' || i_xsiv_rec.currency_conversion_type);
    print_to_log('i_xsiv_rec.currency_conversion_rate ' || i_xsiv_rec.currency_conversion_rate);
    print_to_log('i_xsiv_rec.currency_conversion_date ' || i_xsiv_rec.currency_conversion_date);
    print_to_log('i_xsiv_rec.customer_address_id ' || i_xsiv_rec.customer_address_id);
    print_to_log('i_xsiv_rec.set_of_books_id ' || i_xsiv_rec.set_of_books_id);
    print_to_log('i_xsiv_rec.cust_trx_type_id ' || i_xsiv_rec.cust_trx_type_id);
    print_to_log('i_xsiv_rec.description ' || i_xsiv_rec.description);
    print_to_log('i_xsiv_rec.CUSTOMER_BANK_ACCOUNT_ID ' || i_xsiv_rec.customer_bank_account_id);
    print_to_log('i_xsiv_rec.org_id ' || i_xsiv_rec.org_id);
    print_to_log('i_xsiv_rec.trx_status_code ' || i_xsiv_rec.trx_status_code);
    print_to_log('i_xsiv_rec.tax_exempt_flag ' || i_xsiv_rec.tax_exempt_flag);
    print_to_log('i_xsiv_rec.tax_exempt_reason_code ' || i_xsiv_rec.tax_exempt_reason_code);
    print_to_log('End XSI Record (-)');
  END print_xsi_rec;

  -- -------------------------------------------------
  -- To print log messages for xls_rec
  -- -------------------------------------------------
  PROCEDURE print_xls_rec(i_xlsv_rec IN okl_xls_pvt.xlsv_rec_type) IS
  BEGIN

    print_to_log('Start XLS Record (+)');

    print_to_log('i_xlsv_rec.TLD_ID ' || i_xlsv_rec.tld_id);
    print_to_log('i_xlsv_rec.XSI_ID_DETAILS ' || i_xlsv_rec.xsi_id_details);
    print_to_log('i_xlsv_rec.LINE_TYPE ' || i_xlsv_rec.line_type);
    print_to_log('i_xlsv_rec.DESCRIPTION ' || i_xlsv_rec.description);
    print_to_log('i_xlsv_rec.AMOUNT ' || i_xlsv_rec.amount);
    print_to_log('i_xlsv_rec.ORG_ID ' || i_xlsv_rec.org_id);
    print_to_log('i_xlsv_rec.SEL_ID ' || i_xlsv_rec.sel_id);

    print_to_log('End XLS Record (-)');
  END print_xls_rec;

  -- -------------------------------------------------
  -- To print log messages for esd_rec
  -- -------------------------------------------------
  PROCEDURE print_esd_rec(i_esdv_rec IN okl_esd_pvt.esdv_rec_type) IS
  BEGIN

    print_to_log('Start ESD Record (+)');
    print_to_log('i_esdv_rec.code_combination_id ' || i_esdv_rec.code_combination_id);
    print_to_log('i_esdv_rec.xls_id ' || i_esdv_rec.xls_id);
    print_to_log('i_esdv_rec.amount ' || i_esdv_rec.amount);
    print_to_log('i_esdv_rec.percent ' || i_esdv_rec.percent);
    print_to_log('i_esdv_rec.account_class ' || i_esdv_rec.account_class);
    print_to_log('End ESD Record (-)');

  END print_esd_rec;
  */


  PROCEDURE bulk_process
  (  p_api_version		IN  NUMBER
    ,p_init_msg_list	IN  VARCHAR2
    ,x_return_status	OUT NOCOPY VARCHAR2
    ,x_msg_count		OUT NOCOPY NUMBER
    ,x_msg_data		    OUT NOCOPY VARCHAR2
    ,p_commit           IN  VARCHAR2
  ) IS

    l_api_name	    CONSTANT VARCHAR2(30)  := 'BULK_PROCESS';
    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_api_version	CONSTANT NUMBER := 1;

    i NUMBER := 0;
    j NUMBER := 0;

    CURSOR del_error_csr(p_xsi_id NUMBER) IS
  		 SELECT xls.id  xls_id
		 FROM okl_ext_sell_invs_v xsi,
 	  	 	  okl_xtl_sell_invs_v xls
		 WHERE xls.xsi_id_details = xsi.id 	  AND
			   xsi.id = p_xsi_id;

    CURSOR del_xtd_csr( p_xls_id  NUMBER ) IS
  		 SELECT id  esd_id
		 FROM 	okl_xtd_sell_invs_v
		 WHERE 	xls_id = p_xls_id;

	--d_xlsv_rec      Okl_Xls_Pvt.xlsv_rec_type;
	--d_esdv_rec      Okl_Esd_Pvt.esdv_rec_type;

  BEGIN

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_internal_to_external'
									,'Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    PRINT_TO_LOG('BULK p_commit '||p_commit);

    l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

	--Starting process
    error_tbl.DELETE;

  	-----------------------------------------
    -- Transfer Xsi records to the Xsi table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XSI records to XSI table...');
    PRINT_TO_LOG('BULK xsi_tbl.COUNT : ' || xsi_tbl.COUNT);

    IF xsi_tbl.COUNT > 0 THEN
       FORALL indx IN xsi_tbl.first..xsi_tbl.LAST
              SAVE EXCEPTIONS
              INSERT INTO OKL_EXT_SELL_INVS_B
              VALUES xsi_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
          FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
              PRINT_TO_LOG('BULK For inserting external header, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
              PRINT_TO_LOG('BULK Oracle error is ' ||
              SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

              error_tbl(error_tbl.COUNT + 1).id := TO_NUMBER(xsi_tbl(i).id);
		      total_error_tbl(total_error_tbl.COUNT + 1).id := TO_NUMBER(xsi_tbl(i).id);
           END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_ext_sell_invs_b');

    -- --------------------------------------
    -- Transfer XsiTl records to the XsiTl table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XSI_TL records to XSI_TL table...');
    PRINT_TO_LOG('BULK xsitl_tbl.COUNT : ' || xsitl_tbl.COUNT);

    IF xsitl_tbl.COUNT > 0 THEN
       FORALL indx IN xsitl_tbl.first..xsitl_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO OKL_EXT_SELL_INVS_TL
                VALUES xsitl_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                PRINT_TO_LOG('BULK For inserting external header tl, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                PRINT_TO_LOG('BULK Oracle error is ' ||
                    SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                --error_tbl(error_tbl.count + 1).id := to_number(xsitl_tbl(i).id);
            END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_ext_sell_invs_tl');

    -- --------------------------------------
    -- Transfer Xls records to the Xls table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XLS records to XLS table...');
    PRINT_TO_LOG('BULK xls_tbl.COUNT : ' || xls_tbl.COUNT);

    IF xls_tbl.COUNT > 0 THEN
       FORALL indx IN xls_tbl.first..xls_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO OKL_XTL_SELL_INVS_B
                VALUES xls_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                PRINT_TO_LOG('BULK For inserting external lines, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                PRINT_TO_LOG('BULK Oracle error is ' ||
                    SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                --error_tbl(error_tbl.count + 1).xls_id := to_number(xls_tbl(i).id);
            END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_xtl_sell_invs_b');

    -- --------------------------------------
    -- Transfer XlsTl records to the XlsTl table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XLS_TL records to XLS_TL table...');
    PRINT_TO_LOG('BULK xlstl_tbl.COUNT : ' || xlstl_tbl.COUNT);

    IF xlstl_tbl.COUNT > 0 THEN
              FORALL indx IN xlstl_tbl.first..xlstl_tbl.LAST
			    SAVE EXCEPTIONS
                INSERT INTO OKL_XTL_SELL_INVS_TL
                VALUES xlstl_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                PRINT_TO_LOG('BULK For inserting external lines tl, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                PRINT_TO_LOG('BULK Oracle error is ' ||
                    SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                --error_tbl(error_tbl.count + 1).id := to_number(xlstl_tbl(i).id);
            END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_xtl_sell_invs_tl');

    -- --------------------------------------
    -- Transfer Xtd records to the Xtd table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XTD records to XTD table...');
    PRINT_TO_LOG('BULK xtd_tbl.COUNT : ' || esd_tbl.COUNT);

    IF esd_tbl.COUNT > 0 THEN
       FORALL indx IN esd_tbl.first..esd_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO OKL_XTD_SELL_INVS_B
                VALUES esd_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                PRINT_TO_LOG('BULK For inserting external details, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                PRINT_TO_LOG('BULK Oracle error is ' ||
                    SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                --error_tbl(error_tbl.count + 1).esd_id := to_number(esd_tbl(i).id);
            END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_xtd_sell_invs_b');

    -- --------------------------------------
    -- Transfer XtdTl records to the XtdTl table
    -- --------------------------------------
    PRINT_TO_LOG('BULK Transfering XTD_TL records to XTD_TL table...');
    PRINT_TO_LOG('BULK xtdtl_tbl.COUNT : ' || esdtl_tbl.COUNT);

    IF esdtl_tbl.COUNT > 0 THEN
       FORALL indx IN esdtl_tbl.first..esdtl_tbl.LAST
                SAVE EXCEPTIONS
                INSERT INTO OKL_XTD_SELL_INVS_TL
                VALUES esdtl_tbl(indx);
    END IF;

    IF SQL%BULK_EXCEPTIONS.COUNT > 0 THEN
    --Fnd_File.PUT_LINE (Fnd_File.LOG, 'esdtl_tbl insert');
            FOR i IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
                PRINT_TO_LOG('BULK For inserting external details tl, error ' || i || ' occurred during '||
                    'iteration ' || SQL%BULK_EXCEPTIONS(i).ERROR_INDEX);
                PRINT_TO_LOG('BULK Oracle error is ' ||
                    SQLERRM(SQL%BULK_EXCEPTIONS(i).ERROR_CODE));

                --error_tbl(error_tbl.count + 1).id := to_number(esdtl_tbl(i).id);
            END LOOP;
    END IF;
    PRINT_TO_LOG('BULK Done Inserting into okl_xtd_sell_invs_tl');

    -- update the status
    PRINT_TO_LOG('BULK tai_id_tbl.COUNT: '||tai_id_tbl.COUNT);
    IF (tai_id_tbl.COUNT > 0) THEN
        FORALL indx IN tai_id_tbl.FIRST..tai_id_tbl.LAST
       	   UPDATE okl_trx_ar_invoices_b
       	   SET trx_status_code = 'PROCESSED',
               last_update_date = SYSDATE,
               last_updated_by = Fnd_Global.USER_ID,
               last_update_login = Fnd_Global.LOGIN_ID
           WHERE ID = tai_id_tbl(indx);

           COMMIT;
           Fnd_File.PUT_LINE (Fnd_File.LOG, 'BULK Status updated!');
    END IF;


    --Fnd_File.PUT_LINE (Fnd_File.LOG, 'BULK commit commented 1Y');
    l_commit_cnt := 0;
    PRINT_TO_LOG('BULK error_tbl.count = '||error_tbl.COUNT);
    --Fnd_File.PUT_LINE (Fnd_File.LOG, 'before the error_tbl print');

	IF (error_tbl.COUNT > 0) THEN
	   PRINT_TO_LOG('BULK Processing error ...');
           FOR i IN error_tbl.first..error_tbl.last LOOP
                l_commit_cnt := l_commit_cnt + 1;

		PRINT_TO_LOG('BULK Error XSI ID = ' || error_tbl(i).id);
		FOR del_error_rec IN del_error_csr(error_tbl(i).id) LOOP

                    FOR del_xtd_rec IN  del_xtd_csr( del_error_rec.xls_id ) LOOP
                        PRINT_TO_LOG('BULK Deleting xtd when error ...');

                        DELETE FROM Okl_Xtd_Sell_Invs_B
                        WHERE id =  del_xtd_rec.esd_id;

                        DELETE FROM Okl_Xtd_Sell_Invs_TL
                        WHERE id =  del_xtd_rec.esd_id;

                     END LOOP;

                     PRINT_TO_LOG('BULK Deleting xls when error ...');
                     DELETE FROM Okl_Xtl_Sell_Invs_B
                     WHERE id = del_error_rec.xls_id;

                     DELETE FROM Okl_Xtl_Sell_Invs_TL
                     WHERE id = del_error_rec.xls_id;

		     PRINT_TO_LOG('BULK Finally deleting xsi when error ...');
                     DELETE FROM Okl_Ext_Sell_Invs_B
                     WHERE id = error_tbl(i).id;

                     DELETE FROM Okl_Ext_Sell_Invs_TL
                     WHERE id = error_tbl(i).id;
           END LOOP;

	   -- Performance Improvement
	   IF Fnd_Api.To_Boolean( p_commit )THEN
              COMMIT;
	   END IF;

       END LOOP; --error_tbl

       PRINT_TO_LOG('BULK End Processing error ...');
       END IF; --error_tbl.count > 0


	-----------------------
	-- Commit
	-----------------------
	PRINT_TO_LOG('BULK  p_commit in bulk process' ||p_commit);
	IF Fnd_Api.To_Boolean( p_commit ) THEN
          COMMIT;
	PRINT_TO_LOG('BULK after commit in bulk process');
    END IF;

	------------------------------------------
	-- Clean up the tables after processing
	------------------------------------------
    error_tbl.DELETE;
    tai_id_tbl.DELETE;

    xsi_tbl.DELETE;
    xls_tbl.DELETE;
    esd_tbl.DELETE;

    xsitl_tbl.DELETE;
    xlstl_tbl.DELETE;
    esdtl_tbl.DELETE;

    l_xsi_cnt  := 0;
    l_xls_cnt  := 0;
    l_esd_cnt  := 0;

    l_xsitl_cnt   := 0;
    l_xlstl_cnt   := 0;
    l_esdtl_cnt   := 0;
    l_tai_id_cnt  := 0;

    IF (Fnd_Log.LEVEL_PROCEDURE >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
       Fnd_Log.STRING(Fnd_Log.LEVEL_PROCEDURE,'okl_internal_to_external','End(-)');
    END IF;

    Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

  EXCEPTION

	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------

	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'bulk_process',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
        END IF;

        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'bulk_process',
               'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;

        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 1) => '||SQLERRM);

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'bulk_process',
               'EXCEPTION :'||'OTHERS');
        END IF;

        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');



  END bulk_process;

  -- populate the tbl structures
  PROCEDURE process_ie_tbl
  (     p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
        ,p_commit               IN  VARCHAR2
	,p_contract_number	IN  VARCHAR2	DEFAULT NULL
	,p_ie_tbl1              IN  ie_tbl_type1
	,p_ie_tbl2              IN  ie_tbl_type2
        ,p_end_of_records       IN  VARCHAR2    DEFAULT NULL
  )
  IS
        l_api_name	        CONSTANT VARCHAR2(30)  := 'PROCESS_IE_TBL';
	l_xsi_id                OKL_EXT_SELL_INVS_B.id%TYPE;
	l_xls_id 		OKL_XTL_SELL_INVS_B.id%TYPE;
	l_esd_id 		OKL_XTD_SELL_INVS_B.id%TYPE;
	l_legal_entity_id       OKL_EXT_SELL_INVS_B.legal_entity_id%TYPE; -- for LE Uptake project 08-11-2006

        -- Selects all distributions created by the accounting Engine
        CURSOR acc_dstrs_csr(p_source_id IN NUMBER,   p_source_table IN VARCHAR2) IS
        SELECT cr_dr_flag,
               code_combination_id,
               source_id,
               amount,
               percentage,
        --Start code changes for rev rec by fmiao on 10/05/2004
               NVL(comments,   '-99') comments --End code changes for rev rec by fmiao on 10/05/2004
        FROM okl_trns_acc_dstrs
        WHERE source_id = p_source_id
        AND source_table = p_source_table;

        -- Local Variables Used in this API
        l_api_version NUMBER := 1;
        l_init_msg_list VARCHAR2(1);
        l_return_status VARCHAR2(1);
        l_msg_count NUMBER;
        l_msg_data VARCHAR2(2000);
/*
  -- In and Out records for the Internal AR transaction tables
  l_taiv_rec okl_tai_pvt.taiv_rec_type;
  x_taiv_rec okl_tai_pvt.taiv_rec_type;
  n_taiv_rec okl_tai_pvt.taiv_rec_type;
  null_taiv_rec okl_tai_pvt.taiv_rec_type;

  l_tilv_rec okl_til_pvt.tilv_rec_type;
  x_tilv_rec okl_til_pvt.tilv_rec_type;
  null_tilv_rec okl_til_pvt.tilv_rec_type;

  l_tldv_rec okl_tld_pvt.tldv_rec_type;
  x_tldv_rec okl_tld_pvt.tldv_rec_type;
  null_tldv_rec okl_tld_pvt.tldv_rec_type;

  -- In and Out records for the external sell invoice tables
  l_xsiv_rec okl_xsi_pvt.xsiv_rec_type;
  x_xsiv_rec okl_xsi_pvt.xsiv_rec_type;
  d_xsiv_rec okl_xsi_pvt.xsiv_rec_type;
  null_xsiv_rec okl_xsi_pvt.xsiv_rec_type;

  l_xlsv_rec okl_xls_pvt.xlsv_rec_type;
  x_xlsv_rec okl_xls_pvt.xlsv_rec_type;
  d_xlsv_rec okl_xls_pvt.xlsv_rec_type;
  null_xlsv_rec okl_xls_pvt.xlsv_rec_type;

  l_esdv_rec okl_esd_pvt.esdv_rec_type;
  x_esdv_rec okl_esd_pvt.esdv_rec_type;
  d_esdv_rec okl_esd_pvt.esdv_rec_type;
  null_esdv_rec okl_esd_pvt.esdv_rec_type;

  i NUMBER;
  l_recv_inv_id NUMBER;
  tab_cntr NUMBER;

  type int_hdr_rec_type IS record(tai_id NUMBER := okl_api.g_miss_num,   return_status VARCHAR2(1));

  type int_hdr_tbl_type IS TABLE OF int_hdr_rec_type INDEX BY binary_integer;

  int_hdr_status int_hdr_tbl_type;

  CURSOR del_xsi_3csr(p_tai_id NUMBER) IS
  SELECT xsi.id xsi_id,
    xls.id xls_id
  FROM okl_ext_sell_invs_v xsi,
    okl_xtl_sell_invs_v xls,
    okl_trx_ar_invoices_v tai,
    okl_txl_ar_inv_lns_v til,
    okl_txd_ar_ln_dtls_v tld
  WHERE til.tai_id = tai.id
   AND tld.til_id_details = til.id
   AND xls.xsi_id_details = xsi.id
   AND xls.tld_id = tld.id
   AND tai.id = p_tai_id;

  CURSOR del_xsi_2csr(p_tai_id NUMBER) IS
  SELECT xsi.id xsi_id,
    xls.id xls_id
  FROM okl_ext_sell_invs_v xsi,
    okl_xtl_sell_invs_v xls,
    okl_trx_ar_invoices_v tai,
    okl_txl_ar_inv_lns_v til
  WHERE til.tai_id = tai.id
   AND xls.xsi_id_details = xsi.id
   AND xls.til_id = til.id
   AND tai.id = p_tai_id;

  CURSOR del_xtd_csr(p_xls_id NUMBER) IS
  SELECT id esd_id
  FROM okl_xtd_sell_invs_v
  WHERE xls_id = p_xls_id;
*/
        i NUMBER;
        l_recv_inv_id NUMBER;
        CURSOR reverse_csr1(p_tld_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txd_ar_ln_dtls_v
        WHERE id = p_tld_id;

        CURSOR reverse_csr2(p_til_id NUMBER) IS
        SELECT receivables_invoice_id
        FROM okl_txl_ar_inv_lns_v
        WHERE id = p_til_id;

        -- Cursors to fetch Rule based data
        CURSOR customer_id_csr(p_khr_id NUMBER) IS
        SELECT object1_id1
        FROM okc_k_party_roles_b
        WHERE jtot_object1_code = 'OKX_PARTY'
        AND rle_code = 'CUSTOMER'
        AND chr_id = p_khr_id
	and dnz_chr_id = chr_id ;

        l_jtot_object1_code okc_rules_b.jtot_object1_code%TYPE;
        l_jtot_object2_code okc_rules_b.jtot_object2_code%TYPE;
        l_object1_id1 okc_rules_b.object1_id1%TYPE;
        l_object1_id2 okc_rules_b.object1_id2%TYPE;

        CURSOR rule_code_csr(p_khr_id NUMBER,   p_rule_category VARCHAR2) IS
        SELECT jtot_object1_code,
               object1_id1,
               object1_id2
        FROM okc_rules_b
        WHERE rgp_id =
        (SELECT id
        FROM okc_rule_groups_b
        WHERE dnz_chr_id = p_khr_id
        AND cle_id IS NULL
        AND rgd_code = 'LABILL')
        AND rule_information_category = p_rule_category;

        --commented out for rules migration

        /*CURSOR bto_csr( p_khr_id NUMBER, p_rule_category VARCHAR2 ) IS
	   SELECT  Jtot_object1_code, Jtot_object2_code, object1_id1
	   FROM    OKC_RULES_B
	   WHERE   Rgp_id = (SELECT id
	   		   		  	 FROM Okc_rule_groups_B
						 WHERE dnz_chr_id = p_khr_id AND cle_id IS NULL
	   					 AND rgd_code = 'LABILL') AND
			   rule_information_category = p_rule_category;*/

        CURSOR cust_acct_id_csr(p_id1 NUMBER) IS
        SELECT cust_acct_site_id,
               payment_term_id
        FROM okx_cust_site_uses_v
        WHERE id1 = p_id1;

        l_cust_acct_site_id okx_cust_site_uses_v.cust_acct_site_id%TYPE;
        l_cust_bank_acct okx_rcpt_method_accounts_v.bank_account_id%TYPE;
        l_payment_term_id okx_cust_site_uses_v.payment_term_id%TYPE;

        l_rulv_rec Okl_Rule_Apis_Pvt.rulv_rec_type;
        null_rulv_rec Okl_Rule_Apis_Pvt.rulv_rec_type;

        CURSOR cust_trx_type_csr(p_sob_id NUMBER,   p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Invoice-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;

        CURSOR cm_trx_type_csr(p_sob_id NUMBER,   p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Credit Memo-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;

        /*commented out for rules migration on 21-Aug-2003
        CURSOR cust_id_csr(p_khr_id NUMBER) IS
	   SELECT object1_id1
  	   FROM okc_rules_b rul
        WHERE  rul.rule_information_category = 'CAN'
	   AND EXISTS (SELECT '1' FROM okc_rule_groups_b rgp
			   	   WHERE rgp.id = rul.rgp_id
        	  	   AND   rgp.rgd_code = 'LACAN'
        	  	   AND   rgp.chr_id   = rul.dnz_chr_id
        	  	   AND   rgp.chr_id = p_khr_id);
               */

        CURSOR org_id_csr(p_khr_id NUMBER) IS
        SELECT authoring_org_id
        FROM okc_k_headers_b
        WHERE id = p_khr_id;

        /*CURSOR Cur_address_billto(p_id IN VARCHAR2,Code VARCHAR2) IS
        SELECT  A.cust_account_id,
            A.cust_acct_site_id,
			A.payment_term_id
        FROM    Okx_cust_site_uses_v A, okx_customer_accounts_v  C
        WHERE   A.id1 = p_id
        AND     C.id1 = A.cust_account_id
        AND     A.site_use_code = Code;*/
       --added for rules migration
       CURSOR cur_address_billto(p_contract_id IN VARCHAR2) IS
       SELECT a.cust_acct_id cust_account_id,
              b.cust_acct_site_id,
              c.standard_terms payment_term_id
       FROM okc_k_headers_v a,
            okx_cust_site_uses_v b,
            hz_customer_profiles c
       WHERE a.id = p_contract_id
       AND a.bill_to_site_use_id = b.id1
       AND a.bill_to_site_use_id = c.site_use_id(+);

       billto_rec cur_address_billto % ROWTYPE;

       CURSOR rcpt_mthd_csr(p_cust_rct_mthd NUMBER) IS
       SELECT c.receipt_method_id
       FROM ra_cust_receipt_methods c
       WHERE c.cust_receipt_method_id = p_cust_rct_mthd;

       -- For bank accounts
       CURSOR bank_acct_csr(p_id NUMBER) IS
       SELECT bank_account_id
       FROM okx_rcpt_method_accounts_v
       WHERE id1 = p_id;

       -- Default term Id
       cursor std_terms_csr IS
       SELECT B.TERM_ID
       FROM RA_TERMS_TL T, RA_TERMS_B B
       where T.name = 'IMMEDIATE' and T.LANGUAGE = userenv('LANG')
       and B.TERM_ID = T.TERM_ID;

       CURSOR cntrct_csr(p_khr_id NUMBER) IS
       SELECT contract_number
       FROM okc_k_headers_b
       WHERE id = p_khr_id;

  CURSOR sty_id_csr(p_sty_id NUMBER) IS
  SELECT name
  FROM okl_strm_type_v
  WHERE id = p_sty_id;

  CURSOR rcpt_method_csr(p_rct_method_id NUMBER) IS
  SELECT c.creation_method_code
  FROM ar_receipt_methods m,
    ar_receipt_classes c
  WHERE m.receipt_class_id = c.receipt_class_id
   AND m.receipt_method_id = p_rct_method_id;

  l_contract_number okc_k_headers_b.contract_number%TYPE;
  l_stream_name okl_strm_type_v.name%TYPE;
  l_rct_method_code ar_receipt_classes.creation_method_code%TYPE;

  -- Get currency attributes
  CURSOR l_curr_csr(cp_currency_code VARCHAR2) IS
  SELECT c.minimum_accountable_unit,
    c.PRECISION
  FROM fnd_currencies c
  WHERE c.currency_code = cp_currency_code;

  l_min_acct_unit fnd_currencies.minimum_accountable_unit%TYPE;
  l_precision fnd_currencies.PRECISION %TYPE;

  l_rounded_amount okl_txl_ar_inv_lns_v.amount%TYPE;

  --Start code added by pgomes on 20-NOV-2002
  SUBTYPE khr_id_type IS okl_k_headers_v.khr_id%TYPE;
  l_khr_id khr_id_type;
  l_currency_code okl_ext_sell_invs_b.currency_code%TYPE;
  l_currency_conversion_type okl_ext_sell_invs_b.currency_conversion_type%TYPE;
  l_currency_conversion_rate okl_ext_sell_invs_b.currency_conversion_rate%TYPE;
  l_currency_conversion_date okl_ext_sell_invs_b.currency_conversion_date%TYPE;

  --Get currency conversion attributes for a contract
  CURSOR l_curr_conv_csr(cp_khr_id IN khr_id_type) IS
  SELECT currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date
  FROM okl_k_headers_full_v
  WHERE id = cp_khr_id;

  --End code added by pgomes on 20-NOV-2002

  /* 5162232 Start
   -- Tax Cursor for Exempt Or Standard
   CURSOR astx_csr ( p_khr_id NUMBER ) IS
        SELECT  rule_information1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LAASTX'                AND
              rgp.dnz_chr_id = rgp.chr_id              AND
              rul.rule_information_category = 'LAASTX' AND
              rgp.dnz_chr_id = p_khr_id;

   -- Tax Cursor for Exempt Or Standard at Line level
   CURSOR astx_line_csr ( p_khr_id NUMBER, p_cle_id NUMBER ) IS
        SELECT  rule_information1
        FROM OKC_RULES_B       rul,
             Okc_rule_groups_B rgp
        WHERE rul.rgp_id     = rgp.id                  AND
              rgp.rgd_code   = 'LAASTX'                AND
              rgp.cle_id     = p_cle_id              AND
              rul.rule_information_category = 'LAASTX' AND
              rgp.dnz_chr_id = p_khr_id;

    l_asst_tax                OKC_RULES_B.rule_information1%TYPE;
    l_asst_line_tax           OKC_RULES_B.rule_information1%TYPE;

    5162232 End */ -- Performance Improvement
    l_max_commit NUMBER := 500;
    --l_commit_cnt NUMBER;

    -- ----------------------
    -- Std requests columns
    -- ----------------------
    l_request_id                NUMBER(15);
    l_program_application_id    NUMBER(15);
    l_program_id                NUMBER(15);
    l_program_update_date       DATE;

/*
  -- ------------------------------------------------
  -- Printing and debug log
  -- ------------------------------------------------
  l_request_id NUMBER;

  CURSOR req_id_csr IS
  SELECT decode(fnd_global.conc_request_id,   -1,   NULL,   fnd_global.conc_request_id)
  FROM dual;

  ------------------------------------------------------------
  -- Operating Unit
  ------------------------------------------------------------
  CURSOR op_unit_csr IS
  SELECT name
  FROM hr_operating_units
  WHERE organization_id = nvl(to_number(substrb(userenv('CLIENT_INFO'),   1,   10)),   -99);

  CURSOR xsi_cnt_succ_csr(p_req_id NUMBER,   p_sts VARCHAR2) IS
  SELECT COUNT(*)
  FROM okl_ext_sell_invs_v
  WHERE trx_status_code = p_sts
   AND request_id = p_req_id;

  CURSOR xsi_cnt_err_csr(p_req_id NUMBER,   p_sts VARCHAR2) IS
  SELECT COUNT(*)
  FROM okl_ext_sell_invs_v
  WHERE trx_status_code = p_sts
   AND request_id = p_req_id;

  l_succ_cnt NUMBER;
  l_err_cnt NUMBER;
  l_op_unit_name hr_operating_units.name%TYPE;
  lx_msg_data VARCHAR2(450);
  l_msg_index_out NUMBER := 0;

  -- ------------------------------------------------
  -- Bind variables to address issues in bug 3761940
  -- ------------------------------------------------
  submitted_sts okl_ext_sell_invs_v.trx_status_code%TYPE;
  error_sts okl_ext_sell_invs_v.trx_status_code%TYPE;
*/
  -- -------------------------------------------
  -- To support new fields in XSI and XLS
  -- Added on 21-MAR-2005
  -- -------------------------------------------
  -- rseela BUG# 4733028 Start: fetching review invoice flag
  CURSOR inv_frmt_csr(cp_khr_id IN NUMBER) IS
  SELECT inf.id,
    rul.rule_information4 review_invoice_yn
  FROM okc_rule_groups_v rgp,
    okc_rules_v rul,
    okl_invoice_formats_v inf
  WHERE rgp.dnz_chr_id = cp_khr_id
   AND rgp.chr_id = rgp.dnz_chr_id
   AND rgp.id = rul.rgp_id
   AND rgp.cle_id IS NULL
   AND rgp.rgd_code = 'LABILL'
   AND rul.rule_information_category = 'LAINVD'
   AND rul.rule_information1 = inf.name;

  l_inf_id okl_invoice_formats_v.id%TYPE;

  -- -------------------------------------------
  -- To support private label transfers to
  -- AR. Bug 4525643
  -- -------------------------------------------
  CURSOR pvt_label_csr(cp_khr_id IN NUMBER) IS
  SELECT rule_information1 private_label
  FROM okc_rule_groups_b a,
       okc_rules_b b
  WHERE a.dnz_chr_id = cp_khr_id
   AND a.rgd_code = 'LALABL'
   AND a.id = b.rgp_id
   AND b.rule_information_category = 'LALOGO';

  l_private_label okc_rules_b.rule_information1%TYPE;

  -- to get inventory_org_id  bug 4890024 begin
  CURSOR inv_org_id_csr(p_contract_id NUMBER) IS
  SELECT NVL(inv_organization_id,   -99)
  FROM okc_k_headers_b
  WHERE id = p_contract_id;
  -- bug 4890024 end
  --bug 5160519
  lx_remrkt_sty_id NUMBER;
  l_populate_pmnt_method VARCHAR2(1) := 'Y';
  l_populate_bank_acct VARCHAR2(1) := 'Y';
  --bug 5160519: end

    CURSOR get_languages IS
        SELECT *
        FROM FND_LANGUAGES
        WHERE INSTALLED_FLAG IN ('I', 'B');

   -- Start : Bug#5964007 : PRASJAIN
     -- Cursor to check if 3 level credit memo is on-account
     CURSOR c_3level_cm(p_tld_id OKL_TXD_AR_LN_DTLS_B.ID%TYPE) IS
       SELECT 'X' FROM
           OKL_TXD_AR_LN_DTLS_B
       WHERE ID = p_tld_id
         AND TLD_ID_REVERSES IS NULL;

     -- Cursor to check if 2 level credit memo is on-account
     CURSOR c_2level_cm(p_til_id OKL_TXL_AR_INV_LNS_B.ID%TYPE) IS
       SELECT 'X' FROM
           OKL_TXL_AR_INV_LNS_B
       WHERE ID = p_til_id
         AND TIL_ID_REVERSES IS NULL;

     l_on_acc_cm BOOLEAN;
     l_chk VARCHAR2(1);
     -- End : Bug#5964007 : PRASJAIN

  BEGIN

    l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF(Fnd_Log.level_procedure >= Fnd_Log.g_current_runtime_level) THEN
      Fnd_Log.string(Fnd_Log.level_procedure,   'process_ie_tbl',   'Begin(+)');
    END IF;

    -- ------------------------
    -- Print Input variables
    -- ------------------------
    print_to_log('TBL p_commit ' || p_commit);
    print_to_log('TBL p_contract_number ' || p_contract_number);

    --  This cursor processes all records with 3-level of
    -- detail in the internal transaction table

/*
    i := 0;

    tab_cntr := 0;
    int_hdr_status(tab_cntr).tai_id := 0;

    -- Initialize commit counter
    l_commit_cnt := 0;

    FOR ln_dtls_rec IN int_lns_csr1
    LOOP
      l_commit_cnt := l_commit_cnt + 1;

      -- Initialize Records
      l_xsiv_rec := null_xsiv_rec;
      x_xsiv_rec := null_xsiv_rec;

      l_xlsv_rec := null_xlsv_rec;
      x_xlsv_rec := null_xlsv_rec;

      l_esdv_rec := null_esdv_rec;
      x_esdv_rec := null_esdv_rec;
*/
    IF p_end_of_records = 'Y' THEN
       PRINT_TO_LOG('TBL Done building XSI, XLS and XTD records ...');

       -- caling Bulk insert
       bulk_process
            (p_api_version
            ,p_init_msg_list
            ,x_return_status
            ,x_msg_count
            ,x_msg_data
            ,p_commit);


     ELSE -- p_end_of_records = 'N'
         BEGIN
      	      SELECT
  	  	    	   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.PROG_APPL_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID),
      	  		   DECODE(Fnd_Global.CONC_PROGRAM_ID,-1,NULL,Fnd_Global.CONC_PROGRAM_ID),
      	  		   DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,SYSDATE)
                INTO
  	  	           l_request_id,
          	  	   l_program_application_id,
          	  	   l_program_id,
          	  	   l_program_update_date
                FROM dual;
          EXCEPTION
                WHEN OTHERS THEN
                      Fnd_File.PUT_LINE (Fnd_File.LOG,'(Exception): When resolving request_id'||SQLERRM );
          END;


    	-- Build table records for bulk processing

    	PRINT_TO_LOG('Building XSI, XLS and XTD records ...');


    	IF (p_ie_tbl1.COUNT > 0) THEN
           PRINT_TO_LOG('TBL p_ie_tbl1.COUNT=  '||p_ie_tbl1.COUNT);
		   i := 0;

	   	   l_commit_cnt := 0;

	  	   l_xsi_cnt := 0;
	   	   l_xls_cnt := 0;
	   	   l_esd_cnt := 0;
	   	   l_xsitl_cnt := 0;
	   	   l_xlstl_cnt := 0;
	   	   l_esdtl_cnt := 0;
	   	   l_tai_id_cnt := 0;

	   	   xsi_tbl.DELETE;
	   	   xls_tbl.DELETE;
	   	   esd_tbl.DELETE;
	   	   xsitl_tbl.DELETE;
	   	   xlstl_tbl.DELETE;
	   	   esdtl_tbl.DELETE;

	   	   tai_id_tbl.DELETE;

            FOR k IN p_ie_tbl1.FIRST..p_ie_tbl1.LAST LOOP

			l_commit_cnt := l_commit_cnt + 1;
			l_xsi_cnt := l_xsi_cnt + 1;
			l_tai_id_cnt := l_tai_id_cnt + 1;

        	IF l_commit_cnt > l_max_commit_cnt THEN

           	   PRINT_TO_LOG(' TBL Done building XSI, XLS and XTD records ...');


			   -- caling Bulk insert
                   bulk_process
	           (p_api_version
                   ,p_init_msg_list
                   ,x_return_status
                   ,x_msg_count
                   ,x_msg_data
                   ,p_commit);

                   l_commit_cnt := 0;

                END IF;

      -- Initialize variable for updating xsi trx_status_code
      tai_id_tbl(l_tai_id_cnt) := p_ie_tbl1(k).tai_id;
      PRINT_TO_LOG('TBL tai_id_tbl(l_tai_id_cnt): '||tai_id_tbl(l_tai_id_cnt));
      PRINT_TO_LOG('TBL p_ie_tbl1(k).tld_id : '||p_ie_tbl1(k).tld_id);

      --added by pgomes 11/20/2002 (multi-currency er)
      l_khr_id := p_ie_tbl1(k).contract_id;

      --Start code added by pgomes on 11/21/2002
      l_currency_code := NULL;
      l_currency_conversion_type := NULL;
      l_currency_conversion_rate := NULL;
      l_currency_conversion_date := NULL;

      print_to_log('TBL l_khr_id: ' || l_khr_id);
      FOR cur IN l_curr_conv_csr(l_khr_id)
      LOOP
        l_currency_code := cur.currency_code;
        l_currency_conversion_type := cur.currency_conversion_type;
        l_currency_conversion_rate := cur.currency_conversion_rate;
        l_currency_conversion_date := cur.currency_conversion_date;
      END LOOP;

      --End code added by pgomes on 11/21/2002

      l_contract_number := NULL;

      OPEN cntrct_csr(l_khr_id);
      FETCH cntrct_csr
      INTO l_contract_number;
      CLOSE cntrct_csr;

      -- Initialize variable
      l_stream_name := NULL;

      OPEN sty_id_csr(p_ie_tbl1(k).sty_id);
      FETCH sty_id_csr
      INTO l_stream_name;
      CLOSE sty_id_csr;

      -- Start; Bug 4525643; stmathew
      -- Private Label
      l_private_label := NULL;

      OPEN pvt_label_csr(p_ie_tbl1(k).contract_id);
      FETCH pvt_label_csr
      INTO l_private_label;
      CLOSE pvt_label_csr;
      -- End; Bug 4525643; stmathew

      print_to_log('TBL Processing: Contract #: ' || l_contract_number || ' ,Stream: ' || l_stream_name || ' ,Amount: ' || p_ie_tbl1(k).amount);

      l_jtot_object1_code := NULL;
      l_object1_id1 := NULL;
      l_object1_id2 := NULL;
      l_jtot_object2_code := NULL;

      i := i + 1;
      -- for LE Uptake project 08-11-2006
      IF (p_ie_tbl1(k).legal_entity_id IS NULL OR (p_ie_tbl1(k).legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
        l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_ie_tbl1(k).contract_id);
      ELSE l_legal_entity_id  := p_ie_tbl1(k).legal_entity_id;
      END IF;
      xsi_tbl(l_xsi_cnt).legal_entity_id := l_legal_entity_id;
      -- for LE Uptake project 08-11-2006
      xsi_tbl(l_xsi_cnt).trx_status_code := p_ie_tbl1(k).trx_status_code;
      --TAI
      xsi_tbl(l_xsi_cnt).isi_id := NULL;
      --Populated later during fetch

      --l_xsiv_rec.TRX_NUMBER             := ln_dtls_rec.trx_number; -- Not populated in OKS
      xsi_tbl(l_xsi_cnt).trx_number := NULL;

      xsi_tbl(l_xsi_cnt).trx_date := p_ie_tbl1(k).date_invoiced;

      xsi_tbl(l_xsi_cnt).receipt_method_id := NULL;

      IF p_ie_tbl1(k).contract_id IS NOT NULL THEN
        -- Changed if condition for bug 4155476

        IF(p_ie_tbl1(k).irm_id IS NULL) THEN
          --AND ln_dtls_rec.IXX_ID IS NULL )THEN

          OPEN rule_code_csr(p_ie_tbl1(k).contract_id,   'LAPMTH');
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          IF l_object1_id2 <> '#' THEN
            xsi_tbl(l_xsi_cnt).receipt_method_id := l_object1_id2;
          ELSE
            -- This cursor needs to be removed when the view changes to
            -- include id2

            OPEN rcpt_mthd_csr(l_object1_id1);
            FETCH rcpt_mthd_csr
            INTO xsi_tbl(l_xsi_cnt).receipt_method_id;
            CLOSE rcpt_mthd_csr;
          END IF;

        ELSE
          xsi_tbl(l_xsi_cnt).receipt_method_id := p_ie_tbl1(k).irm_id;
        END IF;

        print_to_log('TBL....Receipt Method ID: ' || xsi_tbl(l_xsi_cnt).receipt_method_id);

        -- Null out local variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_jtot_object2_code := NULL;

        --commented out for rules migration

        /*
		   	  OPEN bto_csr( ln_dtls_rec.contract_id, 'BTO');
			  FETCH bto_csr INTO l_jtot_object1_code,
			  					 l_jtot_object2_code,
			  				 	 l_object1_id1;
 		   	  CLOSE bto_csr;
              */

        billto_rec.cust_account_id := NULL;
        billto_rec.cust_acct_site_id := NULL;
        billto_rec.payment_term_id := NULL;

        OPEN cur_address_billto(p_ie_tbl1(k).contract_id);
        FETCH cur_address_billto
        INTO billto_rec;
        CLOSE cur_address_billto;

        xsi_tbl(l_xsi_cnt).customer_id := NVL(p_ie_tbl1(k).ixx_id,   billto_rec.cust_account_id);

        print_to_log('TBL....Customer ID: ' || xsi_tbl(l_xsi_cnt).customer_id);
        -- FOR Term ID

        OPEN std_terms_csr;
        FETCH std_terms_csr
        INTO xsi_tbl(l_xsi_cnt).term_id;
        CLOSE std_terms_csr;

        print_to_log('TBL....Term ID: ' || xsi_tbl(l_xsi_cnt).term_id);

        xsi_tbl(l_xsi_cnt).customer_address_id := NVL(p_ie_tbl1(k).ibt_id,   billto_rec.cust_acct_site_id);

        print_to_log('TBL....Customer Address ID: ' || xsi_tbl(l_xsi_cnt).customer_address_id);

        print_to_log('TBL p_ie_tbl1(k).org_id: ' || p_ie_tbl1(k).org_id);
        print_to_log('TBL p_ie_tbl1(k).contract_id: ' || p_ie_tbl1(k).contract_id);
        IF p_ie_tbl1(k).org_id IS NULL THEN

          OPEN org_id_csr(p_ie_tbl1(k).contract_id);
          FETCH org_id_csr
          INTO xsi_tbl(l_xsi_cnt).org_id;
          CLOSE org_id_csr;
        ELSE
          xsi_tbl(l_xsi_cnt).org_id := p_ie_tbl1(k).org_id;
          --TAI
        END IF;

        print_to_log('TBL....Org ID: ' || xsi_tbl(l_xsi_cnt).org_id);


        -- To resolve the bank account for the customer
        -- If receipt method is manual do not supply customer bank account
        -- Id. This is required for Auto Invoice Validation

        -- Null out variable
        l_rct_method_code := NULL;

        OPEN rcpt_method_csr(xsi_tbl(l_xsi_cnt).receipt_method_id);
        FETCH rcpt_method_csr
        INTO l_rct_method_code;
        CLOSE rcpt_method_csr;

        --Null out variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        l_cust_bank_acct := NULL;

        IF(l_rct_method_code <> 'MANUAL') THEN

          OPEN rule_code_csr(p_ie_tbl1(k).contract_id,   'LABACC');
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          OPEN bank_acct_csr(l_object1_id1);
          FETCH bank_acct_csr
          INTO l_cust_bank_acct;
          CLOSE bank_acct_csr;

          xsi_tbl(l_xsi_cnt).customer_bank_account_id := l_cust_bank_acct;
        END IF;

        --pgomes 11/22/2002 changed below line to output l_cust_bank_acct instead of l_xsiv_rec.customer_bank_account_id
        print_to_log('TBL....Bank Acct ID: ' || l_cust_bank_acct);
      ELSE
        -- Else for contract_id

        IF p_ie_tbl1(k).ixx_id IS NULL THEN
          --d*bms_output.put_line ('IXX_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IXX_ID must be populated WHEN the contract header IS NULL!');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_id := p_ie_tbl1(k).ixx_id;
        END IF;

        IF p_ie_tbl1(k).irm_id IS NULL THEN
          -- d*bms_output.put_line ('IRM_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRM_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).receipt_method_id := p_ie_tbl1(k).irm_id;
        END IF;

        IF p_ie_tbl1(k).irt_id IS NULL THEN
          -- d*bms_output.put_line ('IRT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).term_id := p_ie_tbl1(k).irt_id;
        END IF;

        IF p_ie_tbl1(k).ibt_id IS NULL THEN
          --d*bms_output.put_line ('IBT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IBT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_address_id := p_ie_tbl1(k).ibt_id;
        END IF;

        IF p_ie_tbl1(k).org_id IS NULL THEN
          --d*bms_output.put_line ('ORG_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'ORG_ID must be populated WHEN the contract header IS NULL');
        ELSE
          --l_xsiv_rec.ORG_ID     := ln_dtls_rec.ORG_ID; --TAI
          xsi_tbl(l_xsi_cnt).org_id := NULL;
        END IF;
        -- for LE Uptake project 08-11-2006
	IF ( p_ie_tbl1(k).legal_entity_id IS NULL OR (p_ie_tbl1(k).legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
          --d*bms_output.put_line ('LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).legal_entity_id := p_ie_tbl1(k).legal_entity_id;
        END IF;
        -- for LE Uptake project 08-11-2006
      END IF;

      --How to get the set_of_books_id ?

      IF p_ie_tbl1(k).set_of_books_id IS NULL THEN
        xsi_tbl(l_xsi_cnt).set_of_books_id := Okl_Accounting_Util.get_set_of_books_id;
      ELSE
        xsi_tbl(l_xsi_cnt).set_of_books_id := p_ie_tbl1(k).set_of_books_id;
        --TAI
      END IF;

      print_to_log('TBL ....SET OF Books ID: ' || xsi_tbl(l_xsi_cnt).set_of_books_id);

      -- How to get from set_of_books_id
      -- This field is varchar2 on the XSI table. Change to number

      --Start code added by pgomes on 20-NOV-2002
      --Check for currency code

      IF p_ie_tbl1(k).currency_code IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_code := l_currency_code;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_code := p_ie_tbl1(k).currency_code;
      END IF;
      print_to_log('TBL ....currency_code: ' || xsi_tbl(l_xsi_cnt).currency_code);
      --Check for currency conversion type

      IF p_ie_tbl1(k).currency_conversion_type IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_type := l_currency_conversion_type;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_type := p_ie_tbl1(k).currency_conversion_type;
      END IF;

      --Check for currency conversion rate

      IF(xsi_tbl(l_xsi_cnt).currency_conversion_type = 'User') THEN

        IF(xsi_tbl(l_xsi_cnt).currency_code = Okl_Accounting_Util.get_func_curr_code) THEN
          xsi_tbl(l_xsi_cnt).currency_conversion_rate := 1;
        ELSE

          IF p_ie_tbl1(k).currency_conversion_rate IS NULL THEN
            xsi_tbl(l_xsi_cnt).currency_conversion_rate := l_currency_conversion_rate;
          ELSE
            xsi_tbl(l_xsi_cnt).currency_conversion_rate := p_ie_tbl1(k).currency_conversion_rate;
          END IF;

        END IF;

      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_rate := NULL;
      END IF;

      --Check for currency conversion date

      IF p_ie_tbl1(k).currency_conversion_date IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_date := l_currency_conversion_date;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_date := p_ie_tbl1(k).currency_conversion_date;
      END IF;

      --End code added by pgomes on 20-NOV-2002

      --Start code added by pgomes on 06-JAN-2003

      IF(xsi_tbl(l_xsi_cnt).currency_conversion_type IS NULL) THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_type := 'User';
        xsi_tbl(l_xsi_cnt).currency_conversion_rate := 1;
        xsi_tbl(l_xsi_cnt).currency_conversion_date := SYSDATE;
      END IF;

      --End code added by pgomes on 06-JAN-2003

      print_to_log('TBL....Currency Code: ' || xsi_tbl(l_xsi_cnt).currency_code);
      --For Credit Memo Processing

      IF p_ie_tbl1(k).tld_id_reverses IS NOT NULL THEN
        -- Null out variables
        l_recv_inv_id := NULL;

        OPEN reverse_csr1(p_ie_tbl1(k).tld_id_reverses);
        FETCH reverse_csr1
        INTO l_recv_inv_id;
        CLOSE reverse_csr1;
        xsi_tbl(l_xsi_cnt).reference_line_id := l_recv_inv_id;
      ELSE
        xsi_tbl(l_xsi_cnt).reference_line_id := NULL;
      END IF;

      xsi_tbl(l_xsi_cnt).receivables_invoice_id := NULL;
      -- Populated later by fetch

      -- Populate Customer TRX-TYPE ID From AR setup

      IF p_ie_tbl1(k).amount < 0 THEN
        xsi_tbl(l_xsi_cnt).term_id := NULL;

        --OPEN cm_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
        --xsi_tbl(l_xsi_cnt).org_id was null out, so use p_ie_tbl1(k).org_id
        OPEN cm_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id, p_ie_tbl1(k).org_id);
        FETCH cm_trx_type_csr
        INTO xsi_tbl(l_xsi_cnt).cust_trx_type_id;
        CLOSE cm_trx_type_csr;
      ELSE

        --OPEN cust_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
        OPEN cust_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id, p_ie_tbl1(k).org_id);
        FETCH cust_trx_type_csr
        INTO xsi_tbl(l_xsi_cnt).cust_trx_type_id;
        CLOSE cust_trx_type_csr;
      END IF;
      print_to_log('TBL xsi_tbl(l_xsi_cnt).cust_trx_type_id: ' || xsi_tbl(l_xsi_cnt).cust_trx_type_id);

      --l_xsiv_rec.CUST_TRX_TYPE_ID         := NULL;

      --Updated during consolidation fron INV_MSGS
      -- Use messaging API to
     -- xsi_tbl(l_xsi_cnt).invoice_message := NULL;
      --xsi_tbl(l_xsi_cnt).description := p_ie_tbl1(k).tai_description;
      --TAI

      /*
        -- Null Rule records
        l_rulv_rec := null_rulv_rec;
		--Tax exempt Y_N from the rules
		Okl_Bp_Rules.EXTRACT_RULES(
       								 l_api_version,
   	   								 l_init_msg_list,
	   	 						     ln_dtls_rec.contract_id,
									 NULL,
									 'LAASTX',
									 'LAASTX',
									 l_return_status,
									 l_msg_count,
									 l_msg_data,
									 l_rulv_rec);
		l_xsiv_rec.TAX_EXEMPT_FLAG := l_rulv_rec.rule_information1;
		--l_xsiv_rec.TAX_EXEMPT_FLAG            := NULL;
		l_xsiv_rec.TAX_EXEMPT_REASON_CODE     := NULL;
		*/

       /* 5162232 Start
         -- Start Tax Code addition
         -- Null Out tax details
         l_asst_tax      := NULL;
         l_asst_line_tax := NULL;

         -- Compute Tax Info
         OPEN  astx_csr( ln_dtls_rec.contract_id );
         FETCH astx_csr INTO l_asst_tax;
         CLOSE astx_csr;

         -- Compute Tax Info at asset line
         OPEN  astx_line_csr( ln_dtls_rec.contract_id, ln_dtls_rec.kle_id );
         FETCH astx_line_csr INTO l_asst_line_tax;
         CLOSE astx_line_csr;

        -- Set Tax exempt flag to Standard
        l_xsiv_rec.tax_exempt_flag        := 'S';
        l_xsiv_rec.tax_exempt_reason_code := NULL;

        IF l_asst_tax IS NOT NULL THEN
           -- Check header code to test and set
           IF l_asst_tax IN ( 'E','N' ) THEN
                l_xsiv_rec.tax_exempt_flag        := 'E';
                l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
           ELSE
                l_xsiv_rec.tax_exempt_flag        := 'S';
                l_xsiv_rec.tax_exempt_reason_code := NULL;
           END IF;

           -- Line level rule instance
           IF l_asst_line_tax IS NOT NULL THEN
              -- Check line code to test and set
              IF l_asst_line_tax IN ( 'E','N' ) THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              ELSE
                 l_xsiv_rec.tax_exempt_flag        := 'S';
                 l_xsiv_rec.tax_exempt_reason_code := NULL;
              END IF;

              -- if stream is not taxable, override
              IF ln_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           ELSE
              -- if stream is not taxable, override
              IF ln_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           END IF;
        ELSE
           -- Line level rule instance
           IF l_asst_line_tax IS NOT NULL THEN
              -- Check line code to test and set
              IF l_asst_line_tax IN ( 'E','N' ) THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              ELSE
                 l_xsiv_rec.tax_exempt_flag        := 'S';
                 l_xsiv_rec.tax_exempt_reason_code := NULL;
              END IF;

              -- if stream is not taxable, override
              IF ln_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           ELSE
              -- if stream is not taxable, override
              IF ln_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           END IF;
        END IF;
        -- End Tax Code addition
*/ -- Set Tax exempt flag to Standard
      xsi_tbl(l_xsi_cnt).tax_exempt_flag := 'S';
      xsi_tbl(l_xsi_cnt).tax_exempt_reason_code := NULL;
      -- 5162232 End
      -- Updated after consolidation
      --xsi_tbl(l_xsi_cnt).xtrx_cons_invoice_number := NULL;
      --xsi_tbl(l_xsi_cnt).xtrx_format_type := NULL;
      xsi_tbl(l_xsi_cnt).xtrx_invoice_pull_yn := NULL;

      -- Start; Bug 4525643; stmathew
      --xsi_tbl(l_xsi_cnt).xtrx_private_label := l_private_label;
      -- End; Bug 4525643; stmathew

      -- New fields added on 21-MAR-2005
      l_inf_id := NULL;
      -- rseela BUG# 4733028 Start: populating review invoice flag

      OPEN inv_frmt_csr(p_ie_tbl1(k).contract_id);
      FETCH inv_frmt_csr
      INTO xsi_tbl(l_xsi_cnt).inf_id,
           xsi_tbl(l_xsi_cnt).xtrx_invoice_pull_yn;
      CLOSE inv_frmt_csr;

      -- copied from G

	    -- Populate id and other columns
        l_xsi_id                                     := Okc_P_Util.raw_to_number(sys_guid());
        xsi_tbl(l_xsi_cnt).ID                        := l_xsi_id;
        xsi_tbl(l_xsi_cnt).OBJECT_VERSION_NUMBER     := 1;
        xsi_tbl(l_xsi_cnt).CREATION_DATE     := SYSDATE;
        xsi_tbl(l_xsi_cnt).CREATED_BY        := Fnd_Global.USER_ID;
        xsi_tbl(l_xsi_cnt).LAST_UPDATE_DATE  := SYSDATE;
        xsi_tbl(l_xsi_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
        xsi_tbl(l_xsi_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

        xsi_tbl(l_xsi_cnt).request_id             := l_request_id;
        xsi_tbl(l_xsi_cnt).program_application_id := l_program_application_id;
        xsi_tbl(l_xsi_cnt).program_id             := l_program_id;
        xsi_tbl(l_xsi_cnt).program_update_date    := l_program_update_date;


        FOR l_lang_rec IN get_languages LOOP

            l_xsitl_cnt     := l_xsitl_cnt + 1;

            xsitl_tbl(l_xsitl_cnt).ID  := l_xsi_id;
            xsitl_tbl(l_xsitl_cnt).xtrx_private_label    := l_private_label;
            --Original code for the view tbl structure
	    xsitl_tbl(l_xsitl_cnt).INVOICE_MESSAGE           := NULL;
	    xsitl_tbl(l_xsitl_cnt).DESCRIPTION := p_ie_tbl1(k).tai_description; --TAI
	    -- Updated after consolidation
	    xsitl_tbl(l_xsitl_cnt).XTRX_CONS_INVOICE_NUMBER   := NULL;
	    xsitl_tbl(l_xsitl_cnt).XTRX_FORMAT_TYPE           := NULL;
	    --xsitl_tbl(l_xsitl_cnt).XTRX_PRIVATE_LABEL         := l_private_label;
	    xsitl_tbl(l_xsitl_cnt).LANGUAGE          := l_lang_rec.language_code;
	    xsitl_tbl(l_xsitl_cnt).SOURCE_LANG       := USERENV('LANG');
	    xsitl_tbl(l_xsitl_cnt).SFWT_FLAG         := 'N';
	    --xsitl_tbl(l_xsitl_cnt).DESCRIPTION       := l_def_desc;

            xsitl_tbl(l_xsitl_cnt).CREATION_DATE     := SYSDATE;
            xsitl_tbl(l_xsitl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            xsitl_tbl(l_xsitl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            xsitl_tbl(l_xsitl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            xsitl_tbl(l_xsitl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

        END LOOP;

      -- end copy from g

      -- Start of wraper code generated automatically by Debug code generator for Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS
      /*
      IF(l_debug_enabled = 'Y') THEN
        l_level_procedure := fnd_log.level_procedure;
        is_debug_procedure_on := okl_debug_pub.check_log_on(l_module,   l_level_procedure);
      END IF;

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS ');
        END;
      END IF;

      print_xsi_rec(l_xsiv_rec);
      okl_ext_sell_invs_pub.insert_ext_sell_invs(l_api_version,   l_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_xsiv_rec,   x_xsiv_rec);

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS

      IF(x_return_status = 'S') THEN
        print_to_log('====>External Header Created.');
      END IF;
     */
      l_xls_cnt := l_xls_cnt + 1;

      -- One of TLD or TIL
      xls_tbl(l_xls_cnt).tld_id := p_ie_tbl1(k).tld_id;
      -- Updated after Consolidation
      xls_tbl(l_xls_cnt).lsm_id := NULL;
      xls_tbl(l_xls_cnt).isl_id := 1;
      --One of TLD or TIL
      xls_tbl(l_xls_cnt).til_id := NULL;

      -- To be updated by fetch program
      xls_tbl(l_xls_cnt).ill_id := NULL;
      xls_tbl(l_xls_cnt).xsi_id_details := l_xsi_id;
      xls_tbl(l_xls_cnt).line_type := p_ie_tbl1(k).inv_receiv_line_code;
      --??
      --xls_tbl(l_xls_cnt).description := p_ie_tbl1(k).til_description;
      --TIL
      -- Start changes on remarketing by fmiao on 10/18/04 --
      xls_tbl(l_xls_cnt).inventory_item_id := p_ie_tbl1(k).inventory_item_id;
      -- End changes on remarketing by fmiao on 10/18/04 --
      -- Bug 4890024 begin

      IF(p_ie_tbl1(k).inventory_org_id IS NULL) THEN

        OPEN inv_org_id_csr(p_ie_tbl1(k).contract_id);
        FETCH inv_org_id_csr
        INTO xls_tbl(l_xls_cnt).inventory_org_id;
        CLOSE inv_org_id_csr;
      ELSE
        xls_tbl(l_xls_cnt).inventory_org_id := p_ie_tbl1(k).inventory_org_id;
      END IF;
      print_to_log('TBL xls_tbl(l_xls_cnt).inventory_org_id: ' || xls_tbl(l_xls_cnt).inventory_org_id);

      -- Bug 4890024 end

      -------- Rounded Amount --------------
      l_rounded_amount := NULL;
      l_min_acct_unit := NULL;
      l_precision := NULL;

      print_to_log('TBL xsi_tbl(l_xsi_cnt).currency_code: ' || xsi_tbl(l_xsi_cnt).currency_code);
      OPEN l_curr_csr(xsi_tbl(l_xsi_cnt).currency_code);
      FETCH l_curr_csr
      INTO l_min_acct_unit,
        l_precision;
      CLOSE l_curr_csr;

      IF(NVL(l_min_acct_unit,   0) <> 0) THEN
        -- Round the amount to the nearest Min Accountable Unit
        l_rounded_amount := ROUND(p_ie_tbl1(k).amount / l_min_acct_unit) * l_min_acct_unit;
      ELSE
        -- Round the amount to the nearest precision
        l_rounded_amount := ROUND(p_ie_tbl1(k).amount,   l_precision);
      END IF;
      print_to_log('TBL l_rounded_amount: ' || l_rounded_amount);
      print_to_log('TBL l_min_acct_unit: ' || l_min_acct_unit);
      print_to_log('TBL p_ie_tbl1(k).amount: ' || p_ie_tbl1(k).amount);

      -------- Rounded Amount --------------
      xls_tbl(l_xls_cnt).amount := l_rounded_amount;
      --TIL

      xls_tbl(l_xls_cnt).quantity := p_ie_tbl1(k).quantity;

      --copy from g
      xls_tbl(l_xls_cnt).sel_id                := p_ie_tbl1(k).sel_id; --TIL

      -- Updated after Consolidation
      xls_tbl(l_xls_cnt).XTRX_CONS_LINE_NUMBER := NULL;
      --xls_tbl(l_xls_cnt).XTRX_CONTRACT         := NULL;
		--xls_tbl(l_xls_cnt).XTRX_ASSET            := NULL;
		--xls_tbl(l_xls_cnt).XTRX_STREAM_GROUP     := NULL;
		--xls_tbl(l_xls_cnt).XTRX_STREAM_TYPE      := NULL;
       xls_tbl(l_xls_cnt).XTRX_CONS_STREAM_ID   := NULL;

       l_xls_id                               := Okc_P_Util.raw_to_number(sys_guid());
       xls_tbl(l_xls_cnt).ID                    := l_xls_id;
       xls_tbl(l_xls_cnt).OBJECT_VERSION_NUMBER := 1;
       xls_tbl(l_xls_cnt).CREATION_DATE         := SYSDATE;
       xls_tbl(l_xls_cnt).CREATED_BY            := Fnd_Global.USER_ID;
       xls_tbl(l_xls_cnt).LAST_UPDATE_DATE      := SYSDATE;
       xls_tbl(l_xls_cnt).LAST_UPDATED_BY       := Fnd_Global.USER_ID;
       xls_tbl(l_xls_cnt).LAST_UPDATE_LOGIN     := Fnd_Global.LOGIN_ID;

        xls_tbl(l_xls_cnt).request_id             := l_request_id;
        xls_tbl(l_xls_cnt).program_application_id := l_program_application_id;
       	xls_tbl(l_xls_cnt).program_id             := l_program_id;
       	xls_tbl(l_xls_cnt).program_update_date    := l_program_update_date;

        FOR l_lang_rec IN get_languages LOOP

            l_xlstl_cnt     := l_xlstl_cnt + 1;

            xlstl_tbl(l_xlstl_cnt).ID                := l_xls_id;
            xlstl_tbl(l_xlstl_cnt).LANGUAGE          := l_lang_rec.language_code;
            xlstl_tbl(l_xlstl_cnt).SOURCE_LANG       := USERENV('LANG');
            xlstl_tbl(l_xlstl_cnt).SFWT_FLAG         := 'N';
            --xlstl_tbl(l_xlstl_cnt).DESCRIPTION     := p_bill_tbl(k).sty_name;
            xlstl_tbl(l_xlstl_cnt).DESCRIPTION       := p_ie_tbl1(k).til_description; --TIL

            -- Updated after Consolidation
            xlstl_tbl(l_xlstl_cnt).XTRX_CONTRACT         := NULL;
            xlstl_tbl(l_xlstl_cnt).XTRX_ASSET            := NULL;
            xlstl_tbl(l_xlstl_cnt).XTRX_STREAM_GROUP     := NULL;
            xlstl_tbl(l_xlstl_cnt).XTRX_STREAM_TYPE      := NULL;

            xlstl_tbl(l_xlstl_cnt).CREATION_DATE     := SYSDATE;
            xlstl_tbl(l_xlstl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            xlstl_tbl(l_xlstl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            xlstl_tbl(l_xlstl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            xlstl_tbl(l_xlstl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

        END LOOP;

      --end copy from g

      --TIL
      /*
      l_xlsv_rec.sel_id := ln_dtls_rec.sel_id;
      --TIL

      -- Updated after Consolidation
      l_xlsv_rec.xtrx_cons_line_number := NULL;
      l_xlsv_rec.xtrx_contract := NULL;
      l_xlsv_rec.xtrx_asset := NULL;
      l_xlsv_rec.xtrx_stream_group := NULL;
      l_xlsv_rec.xtrx_stream_type := NULL;
      l_xlsv_rec.xtrx_cons_stream_id := NULL;

      -- Start of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS ');
        END;
      END IF;

      print_xls_rec(l_xlsv_rec);
      okl_xtl_sell_invs_pub.insert_xtl_sell_invs(p_api_version,   p_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_xlsv_rec,   x_xlsv_rec);

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS

      IF(x_return_status = 'S') THEN
        print_to_log('====>External Line Created.');
      END IF;
     */
      -- Create External Distribution Lines from AR
      --print_to_log('TBL p_ie_tbl1(k).tld_id: ' || p_ie_tbl1(k).tld_id);
      FOR acc_dtls_rec IN acc_dstrs_csr(p_ie_tbl1(k).tld_id,   'OKL_TXD_AR_LN_DTLS_B')
      LOOP
        l_esd_cnt     := l_esd_cnt + 1;

        esd_tbl(l_esd_cnt).xls_id := l_xls_id;
        esd_tbl(l_esd_cnt).code_combination_id := acc_dtls_rec.code_combination_id;
        esd_tbl(l_esd_cnt).amount := acc_dtls_rec.amount;
        esd_tbl(l_esd_cnt).percent := acc_dtls_rec.percentage;
        --esd_tbl(l_esd_cnt).sfwt_flag := 'Y';
        esd_tbl(l_esd_cnt).ild_id := 99;

                -- Start : Bug#5964007 : PRASJAIN
                -- Re-intialize every time the loop come over
                l_on_acc_cm := FALSE;
                -- Start : Bug#5964007 : PRASJAIN

        IF p_ie_tbl1(k).amount > 0 THEN

          IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            esd_tbl(l_esd_cnt).account_class := 'REV';
          ELSE
            esd_tbl(l_esd_cnt).account_class := 'REC';
          END IF;
        ELSE
          IF(acc_dtls_rec.cr_dr_flag = 'C') THEN
            esd_tbl(l_esd_cnt).account_class := 'REC';
          ELSE
            esd_tbl(l_esd_cnt).account_class := 'REV';
          END IF;

          -- Start : Bug#5964007 : PRASJAIN
          -- Adding logic to determine if credit memo is On-account
          OPEN c_3level_cm(p_ie_tbl1(k).tld_id);
            FETCH c_3level_cm INTO l_chk ;
            IF c_3level_cm%FOUND THEN
              l_on_acc_cm := TRUE;
            END IF;
          CLOSE c_3level_cm;
          -- End : Bug#5964007 : PRASJAIN
        END IF;

        -- Start of wraper code generated automatically by Debug code generator for Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs
        IF(is_debug_procedure_on) THEN
          BEGIN
            Okl_Debug_Pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs ');
          END;
        END IF;

        --Start code changes for rev rec by fmiao on 10/05/2004
        IF(acc_dtls_rec.comments = 'CASH_RECEIPT'
           AND esd_tbl(l_esd_cnt).account_class <> 'REC' AND NOT l_on_acc_cm) -- added AND NOT l_on_acc_cm by prasjian for bug 5964007
           OR(acc_dtls_rec.comments <> 'CASH_RECEIPT') THEN

          IF(acc_dtls_rec.comments = 'CASH_RECEIPT') THEN
            esd_tbl(l_esd_cnt).account_class := 'UNEARN';
          END IF;
          /*
          print_esd_rec(l_esdv_rec);
          okl_xtd_sell_invs_pub.insert_xtd_sell_invs(p_api_version,   p_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_esdv_rec,   x_esdv_rec);
        END IF;

        --End code changes for rev rec by fmiao on 10/05/2004

        IF(is_debug_procedure_on) THEN
          BEGIN
            okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs ');
          END;
        END IF;

        -- End of wraper code generated automatically by Debug code generator for Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs

        IF(x_return_status = 'S') THEN
          print_to_log('====>External Distributions Created FOR ' || l_esdv_rec.account_class);
        END IF;

      END LOOP;

      -- Done Creating External distribution lines from AR

      IF(int_hdr_status(tab_cntr).tai_id <> ln_dtls_rec.tai_id) THEN
        tab_cntr := tab_cntr + 1;
        int_hdr_status(tab_cntr).tai_id := ln_dtls_rec.tai_id;
        int_hdr_status(tab_cntr).return_status := x_return_status;
      ELSE

        IF(x_return_status <> 'S') THEN
          int_hdr_status(tab_cntr).return_status := x_return_status;
        END IF;

      END IF;

      -- Performance Improvement

      IF l_commit_cnt > l_max_commit THEN
        l_commit_cnt := 0;
        --

        IF fnd_api.to_boolean(p_commit) THEN
          -- Commit and restart
          COMMIT;
        END IF;

        --
      END IF;

    END LOOP;

    print_to_log(' NUMBER OF 3 LEVEL RECORD processed =  ' || i);

    --d*bms_output.put_line(' NUMBER OF 3 LEVEL RECORD processed =  '||i);
    --fnd_file.PUT_LINE('OUT',' NUMBER OF 3 LEVEL RECORD processed =  '||TO_CHAR(i));

    l_commit_cnt := 0;

    FOR i IN 1 .. tab_cntr
    LOOP
      l_commit_cnt := l_commit_cnt + 1;

      n_taiv_rec.id := int_hdr_status(i).tai_id;

      IF(int_hdr_status(i).return_status = 'S') THEN
        n_taiv_rec.trx_status_code := 'PROCESSED';
      ELSE
        n_taiv_rec.trx_status_code := 'ERROR';

        FOR del3level IN del_xsi_3csr(n_taiv_rec.id)
        LOOP

          FOR delrec IN del_xtd_csr(del3level.xls_id)
          LOOP
            d_esdv_rec.id := delrec.esd_id;

            DELETE FROM okl_xtd_sell_invs_b
            WHERE id = d_esdv_rec.id;

            DELETE FROM okl_xtd_sell_invs_tl
            WHERE id = d_esdv_rec.id;

          END LOOP;

          d_xlsv_rec.id := del3level.xls_id;

          DELETE FROM okl_xtl_sell_invs_b
          WHERE id = d_xlsv_rec.id;

          DELETE FROM okl_xtl_sell_invs_tl
          WHERE id = d_xlsv_rec.id;

          d_xsiv_rec.id := del3level.xsi_id;

          DELETE FROM okl_ext_sell_invs_b
          WHERE id = d_xsiv_rec.id;

          DELETE FROM okl_ext_sell_invs_tl
          WHERE id = d_xsiv_rec.id;

        END LOOP;
      END IF;

      UPDATE okl_trx_ar_invoices_b
      SET trx_status_code = n_taiv_rec.trx_status_code
      WHERE id = n_taiv_rec.id;

      -- Performance Improvement

      IF l_commit_cnt > l_max_commit THEN
        l_commit_cnt := 0;

        IF fnd_api.to_boolean(p_commit) THEN
          COMMIT;
        END IF;

      END IF;

    END LOOP;

    i := 0;

    tab_cntr := 0;
    int_hdr_status(tab_cntr).tai_id := 0;

    l_commit_cnt := 0;

    FOR ln_no_dtls_rec IN int_lns_csr2
    LOOP

      l_commit_cnt := l_commit_cnt + 1;

      -- Initialize Records
*/
--copy from g
                l_esd_id                                 := Okc_P_Util.raw_to_number(sys_guid());
       		esd_tbl(l_esd_cnt).ID                    := l_esd_id;
       		esd_tbl(l_esd_cnt).OBJECT_VERSION_NUMBER := 1;

       		esd_tbl(l_esd_cnt).ORG_ID                := NULL;
       		esd_tbl(l_esd_cnt).CREATION_DATE         := SYSDATE;
       		esd_tbl(l_esd_cnt).CREATED_BY            := Fnd_Global.USER_ID;
       		esd_tbl(l_esd_cnt).LAST_UPDATE_DATE      := SYSDATE;
       		esd_tbl(l_esd_cnt).LAST_UPDATED_BY       := Fnd_Global.USER_ID;
       		esd_tbl(l_esd_cnt).LAST_UPDATE_LOGIN     := Fnd_Global.LOGIN_ID;

        	esd_tbl(l_esd_cnt).request_id             := l_request_id;
        	esd_tbl(l_esd_cnt).program_application_id := l_program_application_id;
       		esd_tbl(l_esd_cnt).program_id             := l_program_id;
       		esd_tbl(l_esd_cnt).program_update_date    := l_program_update_date;


          FOR l_lang_rec IN get_languages LOOP

            	l_esdtl_cnt     := l_esdtl_cnt + 1;

                esdtl_tbl(l_esdtl_cnt).ID                := l_esd_id;
                esdtl_tbl(l_esdtl_cnt).LANGUAGE          := l_lang_rec.language_code;
                esdtl_tbl(l_esdtl_cnt).SOURCE_LANG       := USERENV('LANG');
                esdtl_tbl(l_esdtl_cnt).SFWT_FLAG         := 'N';

            	esdtl_tbl(l_esdtl_cnt).CREATION_DATE     := SYSDATE;
            	esdtl_tbl(l_esdtl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            	esdtl_tbl(l_esdtl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            	esdtl_tbl(l_esdtl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            	esdtl_tbl(l_esdtl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

          END LOOP;
        END IF;
     END LOOP; --loop through acc_dtls_rec

    END LOOP; -- loop through p_ie_tbl1
    PRINT_TO_LOG('TBL NUMBER OF 3 LEVEL RECORD processed =  '||i);
    END IF; -- p_ie_tbl1 >0

    IF (p_ie_tbl2.COUNT > 0) THEN
        PRINT_TO_LOG('TBL2 p_ie_tbl2.COUNT=  '||p_ie_tbl2.COUNT);
        -- construct level 2 tbl structure
        i := 0;

	   --tab_cntr := 0;
	   --int_hdr_status(tab_cntr).tai_id := 0;

	   -- clear out the tbl for 2 level insert --
	   l_commit_cnt2 := 0;

	   l_xsi_cnt := 0;
	   l_xls_cnt := 0;
	   l_esd_cnt := 0;
	   l_xsitl_cnt := 0;
	   l_xlstl_cnt := 0;
	   l_esdtl_cnt := 0;
           l_tai_id_cnt := 0;

	   xsi_tbl.DELETE;
	   xls_tbl.DELETE;
	   esd_tbl.DELETE;
	   xsitl_tbl.DELETE;
	   xlstl_tbl.DELETE;
	   esdtl_tbl.DELETE;

	   tai_id_tbl.DELETE;

	   FOR h IN p_ie_tbl2.FIRST.. p_ie_tbl2.LAST LOOP


       	           l_commit_cnt2 := l_commit_cnt2 + 1;
		   l_xsi_cnt := l_xsi_cnt + 1;
		   l_tai_id_cnt := l_tai_id_cnt + 1;

               IF l_commit_cnt2 > l_max_commit_cnt THEN

                    PRINT_TO_LOG('TBL2  Done building XSI ,XLS and XTD records ...');

			       -- Bulk insert/update records, Commit and restart
			   bulk_process
	                    (p_api_version
                	    ,p_init_msg_list
                	    ,x_return_status
                	    ,x_msg_count
                	    ,x_msg_data
                            ,p_commit);

                    l_commit_cnt2 := 0;
               --PRINT_TO_LOG('TBL2 l_commit_cnt2: '||l_commit_cnt2);
               END IF;

				--populate tai table for update
              tai_id_tbl(l_tai_id_cnt) := p_ie_tbl2(h).tai_id;
              PRINT_TO_LOG('TBL2 tai_id_tbl(l_tai_id_cnt): '||tai_id_tbl(l_tai_id_cnt));

		   --added by pgomes 11/20/2002 (multi-currency er)

--end copy from g
      --added by pgomes 11/20/2002 (multi-currency er)
      l_khr_id := p_ie_tbl2(h).contract_id;
      PRINT_TO_LOG('TBL2 l_khr_id: '||l_khr_id);

      --Start code added by pgomes on 11/21/2002
      l_currency_code := NULL;
      l_currency_conversion_type := NULL;
      l_currency_conversion_rate := NULL;
      l_currency_conversion_date := NULL;

      FOR cur IN l_curr_conv_csr(l_khr_id)
      LOOP
        l_currency_code := cur.currency_code;
        l_currency_conversion_type := cur.currency_conversion_type;
        l_currency_conversion_rate := cur.currency_conversion_rate;
        l_currency_conversion_date := cur.currency_conversion_date;
      END LOOP;
      PRINT_TO_LOG('TBL2 l_currency_code: '||l_currency_code);

      --End code added by pgomes on 11/21/2002
      /*
      l_xsiv_rec := null_xsiv_rec;
      x_xsiv_rec := null_xsiv_rec;

      l_xlsv_rec := null_xlsv_rec;
      x_xlsv_rec := null_xlsv_rec;

      l_esdv_rec := null_esdv_rec;
      x_esdv_rec := null_esdv_rec;
      */
      -- Null out variable
      l_contract_number := NULL;

      OPEN cntrct_csr(p_ie_tbl2(h).contract_id);
      FETCH cntrct_csr
      INTO l_contract_number;
      CLOSE cntrct_csr;

      -- Null out variable
      l_stream_name := NULL;

      OPEN sty_id_csr(p_ie_tbl2(h).sty_id);
      FETCH sty_id_csr
      INTO l_stream_name;
      CLOSE sty_id_csr;

      -- Start; Bug 4525643; stmathew
      -- Private Label
      l_private_label := NULL;

      OPEN pvt_label_csr(p_ie_tbl2(h).contract_id);
      FETCH pvt_label_csr
      INTO l_private_label;
      CLOSE pvt_label_csr;
      -- End; Bug 4525643; stmathew

      print_to_log('TBL2 Processing: Contract #: ' || l_contract_number || ' ,Stream: ' || l_stream_name || ' ,Amount: ' || p_ie_tbl2(h).amount);

      l_jtot_object1_code := NULL;
      l_object1_id1 := NULL;
      l_object1_id2 := NULL;
      l_jtot_object2_code := NULL;

      i := i + 1;

      xsi_tbl(l_xsi_cnt).trx_status_code := p_ie_tbl2(h).trx_status_code;
      xsi_tbl(l_xsi_cnt).isi_id := NULL;

      -- Cannot Import into AR
      -- l_xsiv_rec.TRX_NUMBER       := ln_no_dtls_rec.trx_number;
      xsi_tbl(l_xsi_cnt).trx_number := NULL;

      xsi_tbl(l_xsi_cnt).trx_date := p_ie_tbl2(h).date_invoiced;

      IF p_ie_tbl2(h).contract_id IS NOT NULL THEN
        --bug 5160519 : Sales Order Billing
        -- Order Management sales for remarketing, these billing details are
        --purely from the Order, so if payment method,Bank Account is not passed,
        --then pass as NULL.

        l_populate_bank_acct := 'Y';
        l_populate_pmnt_method := 'Y';
        --get primary stream type for remarketing stream
        Okl_Streams_Util.get_primary_stream_type(p_ie_tbl2(h).contract_id,   'ASSET_SALE_RECEIVABLE',   l_return_status,   lx_remrkt_sty_id);

        IF l_return_status = Okl_Api.g_ret_sts_success THEN

          IF(lx_remrkt_sty_id = p_ie_tbl2(h).sty_id) THEN

            IF p_ie_tbl2(h).bank_acct_id IS NULL THEN
              xsi_tbl(l_xsi_cnt).customer_bank_account_id := NULL;
              --l_remrkt_flag:='Y';
              l_populate_bank_acct := 'N';
            END IF;

            IF p_ie_tbl2(h).irm_id IS NULL THEN
              xsi_tbl(l_xsi_cnt).receipt_method_id := NULL;

              l_populate_pmnt_method := 'N';
            END IF;

          END IF;

        END IF;

        --bug 5160519 : end

        --bug 5160519 : Lease Vendor Billing
        --  For termination quote to  Lease Vendor AND repurchase quote to Lease Vendor
        -- on VPA...the payment method should be taken from the Vendor Billing Details,
        -- if NULL, then as per above, pass nothing to AR and let AR default to Primary
        -- payment method

        IF p_ie_tbl2(h).qte_id IS NOT NULL THEN
          -- if termination record

          IF(p_ie_tbl2(h).ixx_id IS NOT NULL)
             AND(p_ie_tbl2(h).ibt_id IS NOT NULL)
             AND(p_ie_tbl2(h).irt_id IS NOT NULL) THEN
            -- it means the transaction is for the additional recipant
            -- if payment method is passed as NULL then we will keep
            --  it as null

            IF(p_ie_tbl2(h).irm_id IS NULL) THEN
              xsi_tbl(l_xsi_cnt).receipt_method_id := NULL;
              l_populate_pmnt_method := 'N';
            END IF;

            IF(p_ie_tbl2(h).bank_acct_id IS NULL) THEN
              xsi_tbl(l_xsi_cnt).customer_bank_account_id := NULL;
              l_populate_bank_acct := 'N';
            END IF;

          END IF;

        END IF;

        --bug 5160519:end

        --bug 5160519
        --if not remarketing invoice

        IF(l_populate_pmnt_method = 'Y') THEN
          --bug 5160519:end
          -- Changed if condition for bug 4155476

          IF(p_ie_tbl2(h).irm_id IS NULL) THEN
            -- AND ln_no_dtls_rec.IXX_ID IS NULL) THEN

            -- Null out variables
            l_jtot_object1_code := NULL;
            l_object1_id1 := NULL;
            l_object1_id2 := NULL;

            OPEN rule_code_csr(p_ie_tbl2(h).contract_id,   'LAPMTH');
            FETCH rule_code_csr
            INTO l_jtot_object1_code,
              l_object1_id1,
              l_object1_id2;
            CLOSE rule_code_csr;

            IF l_object1_id2 <> '#' THEN
              xsi_tbl(l_xsi_cnt).receipt_method_id := l_object1_id2;
            ELSE
              -- This cursor needs to be removed when the view changes to
              -- include id2

              OPEN rcpt_mthd_csr(l_object1_id1);
              FETCH rcpt_mthd_csr
              INTO xsi_tbl(l_xsi_cnt).receipt_method_id;
              CLOSE rcpt_mthd_csr;
            END IF;

          ELSE
            xsi_tbl(l_xsi_cnt).receipt_method_id := p_ie_tbl2(h).irm_id;
          END IF;

          --bug 5160519
        END IF;

        --bug 5160519:end
        print_to_log('TBL2....Receipt Method ID: ' || xsi_tbl(l_xsi_cnt).receipt_method_id);

        -- Null out variables
        l_jtot_object1_code := NULL;
        l_jtot_object2_code := NULL;
        l_object1_id1 := NULL;
        --commented out for rules migration

        /*OPEN bto_csr( ln_no_dtls_rec.contract_id, 'BTO');
			  FETCH bto_csr INTO l_jtot_object1_code,
			  					 l_jtot_object2_code,
			  				 	 l_object1_id1;

 		   	  CLOSE bto_csr;
              */

        billto_rec.cust_account_id := NULL;
        billto_rec.cust_acct_site_id := NULL;
        billto_rec.payment_term_id := NULL;

        OPEN cur_address_billto(p_ie_tbl2(h).contract_id);
        FETCH cur_address_billto
        INTO billto_rec;
        CLOSE cur_address_billto;

        xsi_tbl(l_xsi_cnt).customer_id := NVL(p_ie_tbl2(h).ixx_id,   billto_rec.cust_account_id);
        print_to_log('TBL2....Customer ID: ' || xsi_tbl(l_xsi_cnt).customer_id);

        -- FOR Term ID

        OPEN std_terms_csr;
        FETCH std_terms_csr
        INTO xsi_tbl(l_xsi_cnt).term_id;
        CLOSE std_terms_csr;

        print_to_log('TBL2....Term ID: ' || xsi_tbl(l_xsi_cnt).term_id);
        xsi_tbl(l_xsi_cnt).customer_address_id := NVL(p_ie_tbl2(h).ibt_id,   billto_rec.cust_acct_site_id);

        print_to_log('TBL2....Customer Address ID: ' || xsi_tbl(l_xsi_cnt).customer_address_id);

        print_to_log('TBL2 p_ie_tbl2(h).org_id: ' || p_ie_tbl2(h).org_id);
        print_to_log('TBL2 p_ie_tbl2(h).contract_id: ' || p_ie_tbl2(h).contract_id);
        IF p_ie_tbl2(h).org_id IS NULL THEN

          OPEN org_id_csr(p_ie_tbl2(h).contract_id);
          FETCH org_id_csr
          INTO xsi_tbl(l_xsi_cnt).org_id;
          CLOSE org_id_csr;
        ELSE
          xsi_tbl(l_xsi_cnt).org_id := p_ie_tbl2(h).org_id;
          --TAI
        END IF;

        print_to_log('TBL2....Org ID: ' || xsi_tbl(l_xsi_cnt).org_id);

        -- To resolve the bank account for the customer
        -- If receipt method is manual do not supply customer bank account
        -- Id. This is required for Auto Invoice Validation
        l_rct_method_code := NULL;
        --bug 5160519

        IF(l_populate_bank_acct = 'Y') THEN
          --bug 5160519:end

          OPEN rcpt_method_csr(xsi_tbl(l_xsi_cnt).receipt_method_id);
          FETCH rcpt_method_csr
          INTO l_rct_method_code;
          CLOSE rcpt_method_csr;

          -- Null out variables
          l_jtot_object1_code := NULL;
          l_object1_id1 := NULL;
          l_object1_id2 := NULL;
          l_cust_bank_acct := NULL;

          IF(l_rct_method_code <> 'MANUAL') THEN

            -- Start Bug 4673593

            IF p_ie_tbl2(h).bank_acct_id IS NULL THEN

              OPEN rule_code_csr(p_ie_tbl2(h).contract_id,   'LABACC');
              FETCH rule_code_csr
              INTO l_jtot_object1_code,
                l_object1_id1,
                l_object1_id2;
              CLOSE rule_code_csr;

              OPEN bank_acct_csr(l_object1_id1);
              FETCH bank_acct_csr
              INTO l_cust_bank_acct;
              CLOSE bank_acct_csr;
            ELSE
              l_cust_bank_acct := p_ie_tbl2(h).bank_acct_id;
            END IF;

            -- End Bug 4673593

            xsi_tbl(l_xsi_cnt).customer_bank_account_id := l_cust_bank_acct;
          END IF;

          --bug 5160519
        END IF;

        --bug 5160519:end

        print_to_log('TBL2....Bank Acct ID: ' || xsi_tbl(l_xsi_cnt).customer_bank_account_id);

      ELSE
        -- Else for contract_id

        IF p_ie_tbl2(h).ixx_id IS NULL THEN
          --d*bms_output.put_line ('IXX_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IXX_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_id := p_ie_tbl2(h).ixx_id;
        END IF;

        IF p_ie_tbl2(h).irm_id IS NULL THEN
          --d*bms_output.put_line ('IRM_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRM_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).receipt_method_id := p_ie_tbl2(h).irm_id;
        END IF;

        IF p_ie_tbl2(h).irt_id IS NULL THEN
          --d*bms_output.put_line ('IRT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IRT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).term_id := p_ie_tbl2(h).irt_id;
        END IF;

        IF p_ie_tbl2(h).ibt_id IS NULL THEN
          --d*bms_output.put_line ('IBT_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'IBT_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).customer_address_id := p_ie_tbl2(h).ibt_id;
        END IF;

        IF p_ie_tbl2(h).org_id IS NULL THEN
          --d*bms_output.put_line ('ORG_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'ORG_ID must be populated WHEN the contract header IS NULL');
        ELSE
          --l_xsiv_rec.ORG_ID     := ln_no_dtls_rec.ORG_ID; --TAI
          xsi_tbl(l_xsi_cnt).org_id := NULL;
        END IF;
	-- for LE Uptake project 08-11-2006
	IF (p_ie_tbl2(h).legal_entity_id IS NULL OR (p_ie_tbl2(h).legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
          --d*bms_output.put_line ('LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL!');
          Fnd_File.PUT_LINE(Fnd_File.OUTPUT,   'LEGAL_ENTITY_ID must be populated WHEN the contract header IS NULL');
        ELSE
          xsi_tbl(l_xsi_cnt).legal_entity_id := p_ie_tbl2(h).legal_entity_id;
        END IF;
	-- for LE Uptake project 08-11-2006

      END IF;

      IF p_ie_tbl2(h).set_of_books_id IS NULL THEN
        xsi_tbl(l_xsi_cnt).set_of_books_id := Okl_Accounting_Util.get_set_of_books_id;
      ELSE
        xsi_tbl(l_xsi_cnt).set_of_books_id := p_ie_tbl2(h).set_of_books_id;
        --TAI
      END IF;

      print_to_log('TBL2....xsi_tbl(l_xsi_cnt).set_of_books_id: ' || xsi_tbl(l_xsi_cnt).set_of_books_id);
      --Start code added by pgomes on 20-NOV-2002
      --Check for currency code

      IF p_ie_tbl2(h).currency_code IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_code := l_currency_code;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_code := p_ie_tbl2(h).currency_code;
      END IF;

      --Check for currency conversion type

      IF p_ie_tbl2(h).currency_conversion_type IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_type := l_currency_conversion_type;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_type := p_ie_tbl2(h).currency_conversion_type;
      END IF;

      --Check for currency conversion rate

      IF(xsi_tbl(l_xsi_cnt).currency_conversion_type = 'User') THEN

        IF(xsi_tbl(l_xsi_cnt).currency_code = Okl_Accounting_Util.get_func_curr_code) THEN
          xsi_tbl(l_xsi_cnt).currency_conversion_rate := 1;
        ELSE

          IF p_ie_tbl2(h).currency_conversion_rate IS NULL THEN
            xsi_tbl(l_xsi_cnt).currency_conversion_rate := l_currency_conversion_rate;
          ELSE
            xsi_tbl(l_xsi_cnt).currency_conversion_rate := p_ie_tbl2(h).currency_conversion_rate;
          END IF;

        END IF;

      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_rate := NULL;
      END IF;

      --Check for currency conversion date

      IF p_ie_tbl2(h).currency_conversion_date IS NULL THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_date := l_currency_conversion_date;
      ELSE
        xsi_tbl(l_xsi_cnt).currency_conversion_date := p_ie_tbl2(h).currency_conversion_date;
      END IF;

      --End code added by pgomes on 20-NOV-2002

      --Start code added by pgomes on 06-JAN-2003

      IF(xsi_tbl(l_xsi_cnt).currency_conversion_type IS NULL) THEN
        xsi_tbl(l_xsi_cnt).currency_conversion_type := 'User';
        xsi_tbl(l_xsi_cnt).currency_conversion_rate := 1;
        xsi_tbl(l_xsi_cnt).currency_conversion_date := SYSDATE;
      END IF;

      --End code added by pgomes on 06-JAN-2003

      --For Credit Memo Processing

      IF p_ie_tbl2(h).til_id_reverses IS NOT NULL THEN

        -- Null out variables
        l_recv_inv_id := NULL;

        OPEN reverse_csr2(p_ie_tbl2(h).til_id_reverses);
        FETCH reverse_csr2
        INTO l_recv_inv_id;
        CLOSE reverse_csr2;
        xsi_tbl(l_xsi_cnt).reference_line_id := l_recv_inv_id;
      ELSE
        xsi_tbl(l_xsi_cnt).reference_line_id := NULL;
      END IF;

      xsi_tbl(l_xsi_cnt).receivables_invoice_id := NULL;
      -- Populated later by fetch

      -- Populate Customer TRX-TYPE ID From AR setup

      IF p_ie_tbl2(h).amount < 0 THEN
        xsi_tbl(l_xsi_cnt).term_id := NULL;

        --OPEN cm_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
        OPEN cm_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id, p_ie_tbl2(h).org_id );
        FETCH cm_trx_type_csr
        INTO xsi_tbl(l_xsi_cnt).cust_trx_type_id;
        CLOSE cm_trx_type_csr;
      ELSE

        --OPEN cust_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id,   xsi_tbl(l_xsi_cnt).org_id);
        OPEN cust_trx_type_csr(xsi_tbl(l_xsi_cnt).set_of_books_id, p_ie_tbl2(h).org_id);
        FETCH cust_trx_type_csr
        INTO xsi_tbl(l_xsi_cnt).cust_trx_type_id;
        CLOSE cust_trx_type_csr;
      END IF;

      --xsi_tbl(l_xsi_cnt).invoice_message := NULL;
      --xsi_tbl(l_xsi_cnt).description := p_ie_tbl2(h).tai_description;

      /*
        -- Null Rule records
        l_rulv_rec := null_rulv_rec;
		--Tax exempt Y_N from the rules
		Okl_Bp_Rules.EXTRACT_RULES(
       								 l_api_version,
   	   								 l_init_msg_list,
	   	 						     ln_no_dtls_rec.contract_id,
									 NULL,
									 'LAASTX',
									 'LAASTX',
									 l_return_status,
									 l_msg_count,
									 l_msg_data,
									 l_rulv_rec);

		l_xsiv_rec.TAX_EXEMPT_FLAG := l_rulv_rec.rule_information1;

		--l_xsiv_rec.TAX_EXEMPT_FLAG          := NULL;
		l_xsiv_rec.TAX_EXEMPT_REASON_CODE     := NULL;
        */

       /* 5162232	Start
         -- Start Tax Code addition
         -- Null Out tax details
         l_asst_tax      := NULL;
         l_asst_line_tax := NULL;

         -- Compute Tax Info
         OPEN  astx_csr( ln_no_dtls_rec.contract_id );
         FETCH astx_csr INTO l_asst_tax;
         CLOSE astx_csr;

         -- Compute Tax Info at asset line
         OPEN  astx_line_csr( ln_no_dtls_rec.contract_id, ln_no_dtls_rec.kle_id );
         FETCH astx_line_csr INTO l_asst_line_tax;
         CLOSE astx_line_csr;

        -- Set Tax exempt flag to Standard
        l_xsiv_rec.tax_exempt_flag        := 'S';
        l_xsiv_rec.tax_exempt_reason_code := NULL;

        IF l_asst_tax IS NOT NULL THEN
           -- Check header code to test and set
           IF l_asst_tax IN ( 'E','N' ) THEN
                l_xsiv_rec.tax_exempt_flag        := 'E';
                l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
           ELSE
                l_xsiv_rec.tax_exempt_flag        := 'S';
                l_xsiv_rec.tax_exempt_reason_code := NULL;
           END IF;

           -- Line level rule instance
           IF l_asst_line_tax IS NOT NULL THEN
              -- Check line code to test and set
              IF l_asst_line_tax IN ( 'E','N' ) THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              ELSE
                 l_xsiv_rec.tax_exempt_flag        := 'S';
                 l_xsiv_rec.tax_exempt_reason_code := NULL;
              END IF;

              -- if stream is not taxable, override
              IF ln_no_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           ELSE
              -- if stream is not taxable, override
              IF ln_no_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           END IF;
        ELSE
           -- Line level rule instance
           IF l_asst_line_tax IS NOT NULL THEN
              -- Check line code to test and set
              IF l_asst_line_tax IN ( 'E','N' ) THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              ELSE
                 l_xsiv_rec.tax_exempt_flag        := 'S';
                 l_xsiv_rec.tax_exempt_reason_code := NULL;
              END IF;

              -- if stream is not taxable, override
              IF ln_no_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           ELSE
              -- if stream is not taxable, override
              IF ln_no_dtls_rec.taxable_default_yn = 'N' THEN
                 l_xsiv_rec.tax_exempt_flag        := 'E';
                 l_xsiv_rec.tax_exempt_reason_code := 'MANUFACTURER';
              END IF;
           END IF;
        END IF;
        -- End Tax Code addition
5162232 End*/ -- Set Tax exempt flag to Standard
      xsi_tbl(l_xsi_cnt).tax_exempt_flag := 'S';
      xsi_tbl(l_xsi_cnt).tax_exempt_reason_code := NULL;
      -- 5162232 End
      -- Updated after consolidation
      --xsi_tbl(l_xsi_cnt).xtrx_cons_invoice_number := NULL;
      --xsi_tbl(l_xsi_cnt).xtrx_format_type := NULL;
      xsi_tbl(l_xsi_cnt).xtrx_invoice_pull_yn := NULL;

      -- Start; Bug 4525643; stmathew
      --xsi_tbl(l_xsi_cnt).xtrx_private_label := l_private_label;
      -- End; Bug 4525643; stmathew

      -- New fields added on 21-MAR-2005
      l_inf_id := NULL;
      -- rseela BUG# 4733028 Start: populating review invoice flag

      print_to_log('TBL2 p_ie_tbl2(h).contract_id: ' || p_ie_tbl2(h).contract_id);
      OPEN inv_frmt_csr(p_ie_tbl2(h).contract_id);
      FETCH inv_frmt_csr
      INTO xsi_tbl(l_xsi_cnt).inf_id,
        xsi_tbl(l_xsi_cnt).xtrx_invoice_pull_yn;
      CLOSE inv_frmt_csr;

           PRINT_TO_LOG('TBL2  XTRX_INVOICE_PULL_YN  = '|| xsi_tbl(l_xsi_cnt).XTRX_INVOICE_PULL_YN);

           l_xsi_id                                     := Okc_P_Util.raw_to_number(sys_guid());
           xsi_tbl(l_xsi_cnt).ID                        := l_xsi_id;
           xsi_tbl(l_xsi_cnt).OBJECT_VERSION_NUMBER     := 1;
           xsi_tbl(l_xsi_cnt).CREATION_DATE     := SYSDATE;
           xsi_tbl(l_xsi_cnt).CREATED_BY        := Fnd_Global.USER_ID;
           xsi_tbl(l_xsi_cnt).LAST_UPDATE_DATE  := SYSDATE;
           xsi_tbl(l_xsi_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
           xsi_tbl(l_xsi_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

       	   xsi_tbl(l_xsi_cnt).request_id             := l_request_id;
           xsi_tbl(l_xsi_cnt).program_application_id := l_program_application_id;
       	   xsi_tbl(l_xsi_cnt).program_id             := l_program_id;
       	   xsi_tbl(l_xsi_cnt).program_update_date    := l_program_update_date;


           FOR l_lang_rec IN get_languages LOOP

              l_xsitl_cnt     := l_xsitl_cnt + 1;

              xsitl_tbl(l_xsitl_cnt).ID                    := l_xsi_id;
              -- Start; Bug 4525643; stmathew
              xsitl_tbl(l_xsitl_cnt).xtrx_private_label    := l_private_label;
              -- End; Bug 4525643; stmathew

              --Original code for the view tbl structure
              xsitl_tbl(l_xsitl_cnt).INVOICE_MESSAGE           := NULL;
              xsitl_tbl(l_xsitl_cnt).DESCRIPTION := p_ie_tbl2(h).tai_description; --TAI
              -- Updated after consolidation
              xsitl_tbl(l_xsitl_cnt).XTRX_CONS_INVOICE_NUMBER   := NULL;
              xsitl_tbl(l_xsitl_cnt).XTRX_FORMAT_TYPE           := NULL;
              --xsitl_tbl(l_xsitl_cnt).XTRX_PRIVATE_LABEL         := l_private_label;

              xsitl_tbl(l_xsitl_cnt).LANGUAGE          := l_lang_rec.language_code;
              xsitl_tbl(l_xsitl_cnt).SOURCE_LANG       := USERENV('LANG');
              xsitl_tbl(l_xsitl_cnt).SFWT_FLAG         := 'N';
              --xsitl_tbl(l_xsitl_cnt).DESCRIPTION       := l_def_desc;

              xsitl_tbl(l_xsitl_cnt).CREATION_DATE     := SYSDATE;
              xsitl_tbl(l_xsitl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
              xsitl_tbl(l_xsitl_cnt).LAST_UPDATE_DATE  := SYSDATE;
              xsitl_tbl(l_xsitl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
              xsitl_tbl(l_xsitl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

           END LOOP;
           --PRINT_TO_LOG('TBL2  after populateing xsi tbl ');

      -- Start of wraper code generated automatically by Debug code generator for Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS
      /*
      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS ');
        END;
      END IF;

      print_xsi_rec(l_xsiv_rec);
      okl_ext_sell_invs_pub.insert_ext_sell_invs(l_api_version,   l_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_xsiv_rec,   x_xsiv_rec);

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Ext_Sell_Invs_Pub.INSERT_EXT_SELL_INVS

      IF(x_return_status = 'S') THEN
        print_to_log('====>External Header Created.');
      END IF;
*/
      l_xls_cnt := l_xls_cnt + 1;

      xls_tbl(l_xls_cnt).tld_id := NULL;
      xls_tbl(l_xls_cnt).lsm_id := NULL;
      xls_tbl(l_xls_cnt).isl_id := 1;
      xls_tbl(l_xls_cnt).til_id := p_ie_tbl2(h).til_id;
      --xls_tbl(l_xls_cnt).til_id := ln_no_dtls_rec.til_id;

      -- To be updated by fetch program
      xls_tbl(l_xls_cnt).ill_id := NULL;
      xls_tbl(l_xls_cnt).xsi_id_details := l_xsi_id;
      xls_tbl(l_xls_cnt).line_type := p_ie_tbl2(h).inv_receiv_line_code;
      --xls_tbl(l_xls_cnt).description := p_ie_tbl2(h).til_description;
      -- Start changes on remarketing by fmiao on 10/18/04 --
      xls_tbl(l_xls_cnt).inventory_item_id := p_ie_tbl2(h).inventory_item_id;
      -- End changes on remarketing by fmiao on 10/18/04 --
      -- Bug 4890024 begin

      IF(p_ie_tbl2(h).inventory_org_id IS NULL) THEN

        OPEN inv_org_id_csr(p_ie_tbl2(h).contract_id);
        FETCH inv_org_id_csr
        INTO xls_tbl(l_xls_cnt).inventory_org_id;
        CLOSE inv_org_id_csr;
      ELSE
        xls_tbl(l_xls_cnt).inventory_org_id := p_ie_tbl2(h).inventory_org_id;
      END IF;
      print_to_log('TBL2 xls_tbl(l_xls_cnt).inventory_org_id: ' || xls_tbl(l_xls_cnt).inventory_org_id);

      -- Bug 4890024 end

      -------- Rounded Amount --------------
      l_rounded_amount := NULL;

      -- Null out variables
      l_min_acct_unit := NULL;
      l_precision := NULL;

      OPEN l_curr_csr(xsi_tbl(l_xsi_cnt).currency_code);
      FETCH l_curr_csr
      INTO l_min_acct_unit,
           l_precision;
      CLOSE l_curr_csr;

      print_to_log('TBL2 l_min_acct_unit: ' || l_min_acct_unit);
      print_to_log('TBL2 l_precision: ' || l_precision);
      print_to_log('TBL2 xsi_tbl(l_xsi_cnt).currency_code: ' || xsi_tbl(l_xsi_cnt).currency_code);
      IF(NVL(l_min_acct_unit,   0) <> 0) THEN
        -- Round the amount to the nearest Min Accountable Unit
        l_rounded_amount := ROUND(p_ie_tbl2(h).amount / l_min_acct_unit) * l_min_acct_unit;
      ELSE
        -- Round the amount to the nearest precision
        l_rounded_amount := ROUND(p_ie_tbl2(h).amount,   l_precision);
      END IF;

      ------ Rounded Amount --------------

      xls_tbl(l_xls_cnt).amount := l_rounded_amount;
      xls_tbl(l_xls_cnt).quantity := p_ie_tbl2(h).quantity;
      print_to_log('TBL2 l_rounded_amount: '||l_rounded_amount);
      print_to_log('TBL2 xls_tbl(l_xls_cnt).amount: ' || xls_tbl(l_xls_cnt).amount);

      --copy from g PRINT_TO_LOG('TBL2  AMOUNT = '||xls_tbl(l_xls_cnt).AMOUNT);

		   -- Updated after Consolidation
           xls_tbl(l_xls_cnt).XTRX_CONS_LINE_NUMBER := NULL;
		   --xls_tbl(l_xls_cnt).XTRX_CONTRACT         := NULL;
		   --xls_tbl(l_xls_cnt).XTRX_ASSET            := NULL;
		   --xls_tbl(l_xls_cnt).XTRX_STREAM_GROUP     := NULL;
		   --xls_tbl(l_xls_cnt).XTRX_STREAM_TYPE      := NULL;
           xls_tbl(l_xls_cnt).XTRX_CONS_STREAM_ID   := NULL;

           l_xls_id                                 := Okc_P_Util.raw_to_number(sys_guid());
           xls_tbl(l_xls_cnt).ID                    := l_xls_id;
           xls_tbl(l_xls_cnt).OBJECT_VERSION_NUMBER := 1;
           xls_tbl(l_xls_cnt).CREATION_DATE         := SYSDATE;
           xls_tbl(l_xls_cnt).CREATED_BY            := Fnd_Global.USER_ID;
           xls_tbl(l_xls_cnt).LAST_UPDATE_DATE      := SYSDATE;
           xls_tbl(l_xls_cnt).LAST_UPDATED_BY       := Fnd_Global.USER_ID;
           xls_tbl(l_xls_cnt).LAST_UPDATE_LOGIN     := Fnd_Global.LOGIN_ID;

           xls_tbl(l_xls_cnt).request_id             := l_request_id;
           xls_tbl(l_xls_cnt).program_application_id := l_program_application_id;
       	   xls_tbl(l_xls_cnt).program_id             := l_program_id;
       	   xls_tbl(l_xls_cnt).program_update_date    := l_program_update_date;


           FOR l_lang_rec IN get_languages LOOP

              l_xlstl_cnt     := l_xlstl_cnt + 1;

              xlstl_tbl(l_xlstl_cnt).ID                := l_xls_id;
              xlstl_tbl(l_xlstl_cnt).LANGUAGE          := l_lang_rec.language_code;
              xlstl_tbl(l_xlstl_cnt).SOURCE_LANG       := USERENV('LANG');
              xlstl_tbl(l_xlstl_cnt).SFWT_FLAG         := 'N';
              --xlstl_tbl(l_xlstl_cnt).DESCRIPTION     := p_bill_tbl(k).sty_name;
              xlstl_tbl(l_xlstl_cnt).DESCRIPTION       := p_ie_tbl2(h).til_description; --TIL

              -- Updated after Consolidation
              xlstl_tbl(l_xlstl_cnt).XTRX_CONTRACT         := NULL;
              xlstl_tbl(l_xlstl_cnt).XTRX_ASSET            := NULL;
              xlstl_tbl(l_xlstl_cnt).XTRX_STREAM_GROUP     := NULL;
              xlstl_tbl(l_xlstl_cnt).XTRX_STREAM_TYPE      := NULL;

              xlstl_tbl(l_xlstl_cnt).CREATION_DATE     := SYSDATE;
              xlstl_tbl(l_xlstl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
              xlstl_tbl(l_xlstl_cnt).LAST_UPDATE_DATE  := SYSDATE;
              xlstl_tbl(l_xlstl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
              xlstl_tbl(l_xlstl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

           END LOOP;
           --PRINT_TO_LOG('TBL2  after populateing xls tbl ');

      /*
      -- Updated after Consolidation
      l_xlsv_rec.xtrx_cons_line_number := NULL;
      l_xlsv_rec.xtrx_contract := NULL;
      l_xlsv_rec.xtrx_asset := NULL;
      l_xlsv_rec.xtrx_stream_group := NULL;
      l_xlsv_rec.xtrx_stream_type := NULL;
      l_xlsv_rec.xtrx_cons_stream_id := NULL;

      -- Start of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS ');
        END;
      END IF;

      print_xls_rec(l_xlsv_rec);
      okl_xtl_sell_invs_pub.insert_xtl_sell_invs(p_api_version,   p_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_xlsv_rec,   x_xlsv_rec);

      IF(is_debug_procedure_on) THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Xtl_Sell_Invs_Pub.INSERT_XTL_SELL_INVS

      IF(x_return_status = 'S') THEN
        print_to_log('====>External Line Created.');
      END IF;
      */
      -- Create Accounting Distributions in the External Table
      FOR acc_no_dtls_rec IN acc_dstrs_csr(p_ie_tbl2(h).til_id,   'OKL_TXL_AR_INV_LNS_B')
      LOOP
        l_esd_cnt     := l_esd_cnt + 1;

        esd_tbl(l_esd_cnt).xls_id := l_xls_id;
        esd_tbl(l_esd_cnt).code_combination_id := acc_no_dtls_rec.code_combination_id;
        esd_tbl(l_esd_cnt).amount := acc_no_dtls_rec.amount;
        esd_tbl(l_esd_cnt).percent := acc_no_dtls_rec.percentage;
        --esd_tbl(l_esd_cnt).sfwt_flag := 'Y';
        esd_tbl(l_esd_cnt).ild_id := 99;

               -- Start : prasjain : bug 5964007
                -- Re-intialize every time the loop come over
                l_on_acc_cm := FALSE;
                -- End : prasjain : bug 5964007

        print_to_log('TBL2 p_ie_tbl2(h).amount: ' || p_ie_tbl2(h).amount);
        IF p_ie_tbl2(h).amount > 0 THEN

          IF(acc_no_dtls_rec.cr_dr_flag = 'C') THEN
            esd_tbl(l_esd_cnt).account_class := 'REV';
          ELSE
            esd_tbl(l_esd_cnt).account_class := 'REC';
          END IF;

        ELSE

          IF(acc_no_dtls_rec.cr_dr_flag = 'C') THEN
            esd_tbl(l_esd_cnt).account_class := 'REC';
          ELSE
            esd_tbl(l_esd_cnt).account_class := 'REV';
          END IF;

                   -- Start : bug 5964007 : prasjain
                     -- Adding logic to determine if credit memo is On-account
                     OPEN c_2level_cm (p_ie_tbl2(h).til_id);
                       FETCH c_2level_cm INTO l_chk ;
                       IF c_2level_cm%FOUND THEN
                         l_on_acc_cm := TRUE;
                       END IF;
                     CLOSE c_2level_cm;
                     -- End : bug 5964007 : prasjain

        END IF;

        -- Start of wraper code generated automatically by Debug code generator for Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs

        IF(is_debug_procedure_on) THEN
          BEGIN
            Okl_Debug_Pub.log_debug(l_level_procedure,   l_module,   'Begin Debug OKLRIEXB.pls call Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs ');
          END;
        END IF;

        --Start code changes for rev rec by fmiao on 10/05/2004

        IF(acc_no_dtls_rec.comments = 'CASH_RECEIPT'
           AND esd_tbl(l_esd_cnt).account_class <> 'REC' AND NOT l_on_acc_cm) -- bug 5964007 : prasjain
            OR(acc_no_dtls_rec.comments <> 'CASH_RECEIPT') THEN

          IF(acc_no_dtls_rec.comments = 'CASH_RECEIPT') THEN
            esd_tbl(l_esd_cnt).account_class := 'UNEARN';
          END IF;

               l_esd_id                                 := Okc_P_Util.raw_to_number(sys_guid());
               esd_tbl(l_esd_cnt).ID                    := l_esd_id;
               esd_tbl(l_esd_cnt).OBJECT_VERSION_NUMBER := 1;

               esd_tbl(l_esd_cnt).ORG_ID                := NULL;
               esd_tbl(l_esd_cnt).CREATION_DATE         := SYSDATE;
               esd_tbl(l_esd_cnt).CREATED_BY            := Fnd_Global.USER_ID;
               esd_tbl(l_esd_cnt).LAST_UPDATE_DATE      := SYSDATE;
               esd_tbl(l_esd_cnt).LAST_UPDATED_BY       := Fnd_Global.USER_ID;
               esd_tbl(l_esd_cnt).LAST_UPDATE_LOGIN     := Fnd_Global.LOGIN_ID;

               esd_tbl(l_esd_cnt).request_id             := l_request_id;
               esd_tbl(l_esd_cnt).program_application_id := l_program_application_id;
               esd_tbl(l_esd_cnt).program_id             := l_program_id;
               esd_tbl(l_esd_cnt).program_update_date    := l_program_update_date;

               FOR l_lang_rec IN get_languages LOOP

                  l_esdtl_cnt     := l_esdtl_cnt + 1;

                  esdtl_tbl(l_esdtl_cnt).ID                := l_esd_id;
                  esdtl_tbl(l_esdtl_cnt).LANGUAGE          := l_lang_rec.language_code;
                  esdtl_tbl(l_esdtl_cnt).SOURCE_LANG       := USERENV('LANG');
                  esdtl_tbl(l_esdtl_cnt).SFWT_FLAG         := 'N';

            	  esdtl_tbl(l_esdtl_cnt).CREATION_DATE     := SYSDATE;
            	  esdtl_tbl(l_esdtl_cnt).CREATED_BY        := Fnd_Global.USER_ID;
            	  esdtl_tbl(l_esdtl_cnt).LAST_UPDATE_DATE  := SYSDATE;
            	  esdtl_tbl(l_esdtl_cnt).LAST_UPDATED_BY   := Fnd_Global.USER_ID;
            	  esdtl_tbl(l_esdtl_cnt).LAST_UPDATE_LOGIN := Fnd_Global.LOGIN_ID;

               END LOOP;
			   --PRINT_TO_LOG('TBL2 after populateing l_esd_tbl');
              END IF;
            END LOOP; -- acct distr tbl

 		    -- End creating Acctng Distributions in the External Table
	     END LOOP; -- loop throught p_ie_tbl2
	  END IF; --p_ie_tbl2.count > 0

    END IF;--p_end_of_records = 'N''

      --Insert when level 3 or 2 is populated
    PRINT_TO_LOG('TBL insert for < 500 records ...commented out');

                          -- Bulk insert/update records, Commit and restart
			   bulk_process
	                    (p_api_version
                	    ,p_init_msg_list
                	    ,x_return_status
                	    ,x_msg_count
                	    ,x_msg_data
                            ,p_commit);

	--tai_id_tbl.DELETE;
    PRINT_TO_LOG('TBL End time process_id_tbl : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));

    PRINT_TO_LOG('TBL End process_id_tbl (-)');

    Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);

    /*
          print_esd_rec(l_esdv_rec);
          okl_xtd_sell_invs_pub.insert_xtd_sell_invs(p_api_version,   p_init_msg_list,   x_return_status,   x_msg_count,   x_msg_data,   l_esdv_rec,   x_esdv_rec);
        END IF;

        --End code changes for rev rec by fmiao on 10/05/2004

        IF(is_debug_procedure_on) THEN
          BEGIN
            okl_debug_pub.log_debug(l_level_procedure,   l_module,   'End Debug OKLRIEXB.pls call Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs ');
          END;
        END IF;

        -- End of wraper code generated automatically by Debug code generator for Okl_Xtd_Sell_Invs_Pub.insert_xtd_sell_invs

        IF(x_return_status = 'S') THEN
          print_to_log('====>External Distributions Created FOR ' || l_esdv_rec.account_class);
        END IF;

      END LOOP;

      -- End creating Acctng Distributions in the External Table

      IF(int_hdr_status(tab_cntr).tai_id <> ln_no_dtls_rec.tai_id) THEN
        tab_cntr := tab_cntr + 1;
        int_hdr_status(tab_cntr).tai_id := ln_no_dtls_rec.tai_id;
        int_hdr_status(tab_cntr).return_status := x_return_status;
      ELSE

        IF(x_return_status <> 'S') THEN
          int_hdr_status(tab_cntr).return_status := x_return_status;
        END IF;

      END IF;

      -- Performance Improvement

      IF l_commit_cnt > l_max_commit THEN
        l_commit_cnt := 0;

        IF fnd_api.to_boolean(p_commit) THEN
          -- Commit and restart
          COMMIT;
        END IF;

      END IF;

    END LOOP;

    print_to_log(' NUMBER OF 2 LEVEL RECORD processed =  ' || i);

    l_commit_cnt := 0;

    FOR i IN 1 .. tab_cntr
    LOOP
      l_commit_cnt := l_commit_cnt + 1;

      n_taiv_rec.id := int_hdr_status(i).tai_id;

      IF(int_hdr_status(i).return_status = 'S') THEN
        n_taiv_rec.trx_status_code := 'PROCESSED';
      ELSE
        n_taiv_rec.trx_status_code := 'ERROR';

        FOR del2level IN del_xsi_2csr(n_taiv_rec.id)
        LOOP

          FOR delrec IN del_xtd_csr(del2level.xls_id)
          LOOP
            d_esdv_rec.id := delrec.esd_id;

            DELETE FROM okl_xtd_sell_invs_b
            WHERE id = d_esdv_rec.id;

            DELETE FROM okl_xtd_sell_invs_tl
            WHERE id = d_esdv_rec.id;

          END LOOP;

          d_xlsv_rec.id := del2level.xls_id;

          DELETE FROM okl_xtl_sell_invs_b
          WHERE id = d_xlsv_rec.id;

          DELETE FROM okl_xtl_sell_invs_tl
          WHERE id = d_xlsv_rec.id;

          d_xsiv_rec.id := del2level.xsi_id;

          DELETE FROM okl_ext_sell_invs_b
          WHERE id = d_xsiv_rec.id;

          DELETE FROM okl_ext_sell_invs_tl
          WHERE id = d_xsiv_rec.id;
        END LOOP;
      END IF;

      UPDATE okl_trx_ar_invoices_b
      SET trx_status_code = n_taiv_rec.trx_status_code
      WHERE id = n_taiv_rec.id;

      -- Performance Improvement

      IF l_commit_cnt > l_max_commit THEN
        l_commit_cnt := 0;

        IF fnd_api.to_boolean(p_commit) THEN
          -- Commit and restart
          COMMIT;
        END IF;

      END IF;

    END LOOP;

    ------------------------------------------------------------
    -- Print log and output messages
    ------------------------------------------------------------

    -- Get the request Id
    l_request_id := NULL;

    OPEN req_id_csr;
    FETCH req_id_csr
    INTO l_request_id;
    CLOSE req_id_csr;

    submitted_sts := 'SUBMITTED';
    error_sts := 'ERROR';

    l_succ_cnt := 0;
    l_err_cnt := 0;

    -- Success Count

    OPEN xsi_cnt_succ_csr(l_request_id,   submitted_sts);
    FETCH xsi_cnt_succ_csr
    INTO l_succ_cnt;
    CLOSE xsi_cnt_succ_csr;

    -- Error Count

    OPEN xsi_cnt_err_csr(l_request_id,   error_sts);
    FETCH xsi_cnt_err_csr
    INTO l_err_cnt;
    CLOSE xsi_cnt_err_csr;

    ----------------------------------------
    -- Get Operating unit name
    ----------------------------------------
    l_op_unit_name := NULL;

    OPEN op_unit_csr;
    FETCH op_unit_csr
    INTO l_op_unit_name;
    CLOSE op_unit_csr;

    -- Start New Out File stmathew 15-OCT-2004
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   54,   ' ') || 'Oracle Lease and Finance Management' || lpad(' ',   55,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   53,   ' ') || 'Prepare Receivables Bills' || lpad(' ',   54,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   53,   ' ') || '-------------------------' || lpad(' ',   54,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   'Operating Unit: ' || l_op_unit_name);
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   'Request Id: ' || l_request_id || lpad(' ',   74,   ' ') || 'Run Date: ' || to_char(sysdate));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   'Currency: ' || okl_accounting_util.get_func_curr_code);
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad('-',   132,   '-'));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));

    fnd_file.PUT_LINE(fnd_file.OUTPUT,   'Processing Details:' || lpad(' ',   113,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   '                Number of Successful Records: ' || l_succ_cnt);
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   '                Number of Errored Records: ' || l_err_cnt);
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   '                Total: ' ||(l_succ_cnt + l_err_cnt));
    fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));

    IF x_msg_count > 0 THEN
      FOR i IN 1 .. x_msg_count
      LOOP

        IF i = 1 THEN
          fnd_file.PUT_LINE(fnd_file.OUTPUT,   'Details of Errored Records:' || lpad(' ',   97,   ' '));
          fnd_file.PUT_LINE(fnd_file.OUTPUT,   rpad(' ',   132,   ' '));
        END IF;

        fnd_msg_pub.GET(p_msg_index => i,   p_encoded => 'F',   p_data => lx_msg_data,   p_msg_index_out => l_msg_index_out);

        fnd_file.PUT_LINE(fnd_file.OUTPUT,   to_char(i) || ': ' || lx_msg_data);

        IF(fnd_log.level_exception >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string(fnd_log.level_exception,   'okl_internal_to_external',   to_char(i) || ': ' || lx_msg_data);
        END IF;

      END LOOP;
    END IF;

    IF(fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string(fnd_log.level_procedure,   'okl_internal_to_external',   'End(-)');
    END IF;

    ------------------------------------------------------------
    -- End processing
    ------------------------------------------------------------

    okl_api.end_activity(x_msg_count => x_msg_count,   x_msg_data => x_msg_data);*/

  EXCEPTION
  WHEN OTHERS THEN

    IF(Fnd_Log.level_exception >= Fnd_Log.g_current_runtime_level) THEN
      Fnd_Log.string(Fnd_Log.level_exception,   'okl_internal_to_external',   'EXCEPTION :' || 'OTHERS');
    END IF;

    print_to_log('*=> Error Message(O1): ' || SQLERRM);

  END process_ie_tbl;

  PROCEDURE internal_to_external
	(p_api_version		IN  NUMBER
	,p_init_msg_list	IN  VARCHAR2
	,x_return_status	OUT NOCOPY VARCHAR2
	,x_msg_count		OUT NOCOPY NUMBER
	,x_msg_data		OUT NOCOPY VARCHAR2
        ,p_commit               IN  VARCHAR2
	,p_contract_number	IN  VARCHAR2
	,p_assigned_process IN  VARCHAR2
  ) IS

	l_api_name	    CONSTANT VARCHAR2(30)  := 'INTERNAL_TO_EXTERNAL';
	l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	l_api_version	CONSTANT NUMBER := 1;


	-- Cursor picks lines with detail records
        CURSOR int_lns_csr1 IS
        SELECT t1.id tai_id,
               t1.khr_id contract_id,
               t1.trx_status_code trx_status_code,
               t1.date_invoiced date_invoiced,
               t1.ixx_id ixx_id,
               t1.irm_id irm_id,
               t1.irt_id irt_id,
               t1.ibt_id ibt_id,
               t1.set_of_books_id set_of_books_id,
               t1.description tai_description,
               t1.currency_code currency_code,
    --Start code added by pgomes on 20-NOV-2002
               t1.currency_conversion_type currency_conversion_type,
               t1.currency_conversion_rate currency_conversion_rate,
               t1.currency_conversion_date currency_conversion_date,
    --End code added by pgomes on 20-NOV-2002
               t1.org_id org_id,
               t1.trx_number trx_number,
	       t1.legal_entity_id,     -- for LE Uptake project 08-11-2006
               t2.inv_receiv_line_code inv_receiv_line_code,
               NVL(t3.description,   t2.description) til_description,
               t2.quantity quantity,
               t2.kle_id kle_id,
               t3.id tld_id,
               t3.amount amount,
               t3.tld_id_reverses tld_id_reverses,
               t3.sty_id sty_id,
               t4.taxable_default_yn taxable_default_yn,
               t3.sel_id sel_id,
    -- Start changes on remarketing by fmiao on 10/18/04 --
               t3.inventory_item_id inventory_item_id,
    -- End changes on remarketing by fmiao on 10/18/04 --
               NVL(t3.inventory_org_id,   t2.inventory_org_id) inventory_org_id
        FROM  okl_trx_ar_invoices_v t1,
              okl_txl_ar_inv_lns_v t2,
              okl_txd_ar_ln_dtls_v t3,
              okl_strm_type_v t4,
              okc_k_headers_b CHR
        WHERE t1.trx_status_code = 'SUBMITTED'
        AND t1.khr_id = CHR.id
        AND CHR.contract_number = NVL(p_contract_number,   CHR.contract_number)
        AND t2.tai_id = t1.id
        AND t3.til_id_details = t2.id
        AND t4.id = t3.sty_id
        ORDER BY tai_id;

        -- Pick lines with no detail records
        CURSOR int_lns_csr2 IS
        SELECT t1.id tai_id,
               t1.khr_id contract_id,
               t1.trx_status_code trx_status_code,
               t1.date_invoiced date_invoiced,
               t1.ixx_id ixx_id,
               t1.irm_id irm_id,
               t1.irt_id irt_id,
               t1.ibt_id ibt_id,
               t1.set_of_books_id set_of_books_id,
               t1.description tai_description,
               t1.currency_code currency_code,
    --Start code added by pgomes on 20-NOV-2002
               t1.currency_conversion_type currency_conversion_type,
               t1.currency_conversion_rate currency_conversion_rate,
               t1.currency_conversion_date currency_conversion_date,
    --End code added by pgomes on 20-NOV-2002
               t1.org_id org_id,
               t1.trx_number trx_number,
	       t1.legal_entity_id, -- for LE Uptake project 08-11-2006
               t2.id til_id,
               t2.kle_id kle_id,
               t2.inv_receiv_line_code inv_receiv_line_code,
               t2.description til_description,
               t2.quantity quantity,
               t2.amount amount,
               t2.til_id_reverses til_id_reverses,
               t2.sty_id sty_id,
               t4.taxable_default_yn taxable_default_yn,
    -- Start changes on remarketing by fmiao on 10/18/04 --
               t2.inventory_item_id inventory_item_id,
    -- End changes on remarketing by fmiao on 10/18/04 --
               t2.inventory_org_id inventory_org_id,
    -- Start Bug 4673593
               t2.bank_acct_id bank_acct_id, -- End Bug 4673593 --bug 5160519,
               t1.qte_id qte_id --Termination Quote id --bug 5160519:end
        FROM okl_trx_ar_invoices_v t1,
             okl_txl_ar_inv_lns_v t2,
             okl_strm_type_v t4,
             okc_k_headers_b CHR
        WHERE t1.trx_status_code = 'SUBMITTED'
        AND t1.khr_id = CHR.id
        AND CHR.contract_number = NVL(p_contract_number,   CHR.contract_number)
        AND t2.tai_id = t1.id
        AND t4.id = t2.sty_id
        AND NOT EXISTS
        (SELECT *
        FROM okl_txd_ar_ln_dtls_b t3
        WHERE t3.til_id_details = t2.id)
        ORDER BY tai_id;

  	-- Cursor picks lines with detail records
        CURSOR int_lns_csr3 IS
        SELECT t1.id tai_id,
               t1.khr_id contract_id,
               t1.trx_status_code trx_status_code,
               t1.date_invoiced date_invoiced,
               t1.ixx_id ixx_id,
               t1.irm_id irm_id,
               t1.irt_id irt_id,
               t1.ibt_id ibt_id,
               t1.set_of_books_id set_of_books_id,
               t1.description tai_description,
               t1.currency_code currency_code,
    --Start code added by pgomes on 20-NOV-2002
               t1.currency_conversion_type currency_conversion_type,
               t1.currency_conversion_rate currency_conversion_rate,
               t1.currency_conversion_date currency_conversion_date,
    --End code added by pgomes on 20-NOV-2002
               t1.org_id org_id,
               t1.trx_number trx_number,
	       t1.legal_entity_id, -- for LE Uptake project 08-11-2006
               t2.inv_receiv_line_code inv_receiv_line_code,
               NVL(t3.description,   t2.description) til_description,
               t2.quantity quantity,
               t2.kle_id kle_id,
               t3.id tld_id,
               t3.amount amount,
               t3.tld_id_reverses tld_id_reverses,
               t3.sty_id sty_id,
               t4.taxable_default_yn taxable_default_yn,
               t3.sel_id sel_id,
    -- Start changes on remarketing by fmiao on 10/18/04 --
               t3.inventory_item_id inventory_item_id,
    -- End changes on remarketing by fmiao on 10/18/04 --
               NVL(t3.inventory_org_id,   t2.inventory_org_id) inventory_org_id
        FROM okl_trx_ar_invoices_v t1,
             okl_txl_ar_inv_lns_v t2,
             okl_txd_ar_ln_dtls_v t3,
             okl_strm_type_v t4,
             okc_k_headers_b CHR,
             OKL_PARALLEL_PROCESSES  pws
        WHERE t1.trx_status_code = 'SUBMITTED'
        AND t1.khr_id = CHR.id
        AND CHR.contract_number = NVL(p_contract_number,   CHR.contract_number)
        AND t2.tai_id = t1.id
        AND t3.til_id_details = t2.id
        AND t4.id = t3.sty_id
        -- parallel process
        AND pws.object_type = 'PREP_CONTRACT'
    	AND pws.object_value = CHR.contract_number
    	AND pws.assigned_process = p_assigned_process
        ORDER BY tai_id;

        -- Pick lines with no detail records
        CURSOR int_lns_csr4 IS
        SELECT t1.id tai_id,
               t1.khr_id contract_id,
               t1.trx_status_code trx_status_code,
               t1.date_invoiced date_invoiced,
               t1.ixx_id ixx_id,
               t1.irm_id irm_id,
               t1.irt_id irt_id,
               t1.ibt_id ibt_id,
               t1.set_of_books_id set_of_books_id,
               t1.description tai_description,
               t1.currency_code currency_code,
    --Start code added by pgomes on 20-NOV-2002
               t1.currency_conversion_type currency_conversion_type,
               t1.currency_conversion_rate currency_conversion_rate,
               t1.currency_conversion_date currency_conversion_date,
    --End code added by pgomes on 20-NOV-2002
               t1.org_id org_id,
               t1.trx_number trx_number,
	       t1.legal_entity_id, -- for LE Uptake project 08-11-2006
               t2.id til_id,
               t2.kle_id kle_id,
               t2.inv_receiv_line_code inv_receiv_line_code,
               t2.description til_description,
               t2.quantity quantity,
               t2.amount amount,
               t2.til_id_reverses til_id_reverses,
               t2.sty_id sty_id,
               t4.taxable_default_yn taxable_default_yn,
    -- Start changes on remarketing by fmiao on 10/18/04 --
               t2.inventory_item_id inventory_item_id,
    -- End changes on remarketing by fmiao on 10/18/04 --
               t2.inventory_org_id inventory_org_id,
    -- Start Bug 4673593
               t2.bank_acct_id bank_acct_id, -- End Bug 4673593 --bug 5160519,
               t1.qte_id qte_id --Termination Quote id
  --bug 5160519:end
         FROM okl_trx_ar_invoices_v t1,
              okl_txl_ar_inv_lns_v t2,
              okl_strm_type_v t4,
              okc_k_headers_b CHR,
	      OKL_PARALLEL_PROCESSES  pws
        WHERE t1.trx_status_code = 'SUBMITTED'
        AND t1.khr_id = CHR.id
        AND CHR.contract_number = NVL(p_contract_number,   CHR.contract_number)
        AND t2.tai_id = t1.id
        AND t4.id = t2.sty_id
        AND NOT EXISTS
        (SELECT *
        FROM okl_txd_ar_ln_dtls_v t3
        WHERE t3.til_id_details = t2.id)
	-- parallel process
        AND pws.object_type = 'PREP_CONTRACT'
    	AND pws.object_value = CHR.contract_number
    	AND pws.assigned_process = p_assigned_process
        ORDER BY tai_id;


	ie_tbl1         ie_tbl_type1;
	ie_tbl2         ie_tbl_type2;

        l_fetch_size    NUMBER := 5000;

    -- --------------------------------------------------------
    -- To Print log messages
    -- --------------------------------------------------------

        l_request_id      NUMBER;

        CURSOR req_id_csr IS
	   SELECT
           DECODE(Fnd_Global.CONC_REQUEST_ID,-1,NULL,Fnd_Global.CONC_REQUEST_ID)
	   FROM dual;


        CURSOR xsi_cnt_succ_csr( p_req_id NUMBER, p_sts VARCHAR2 ) IS
          SELECT COUNT(*)
          FROM okl_ext_sell_invs_v
          WHERE trx_status_code = p_sts AND
                request_id = p_req_id ;

 	 ------------------------------------------------------------
	 -- Operating Unit
	 ------------------------------------------------------------
         CURSOR op_unit_csr IS
            SELECT NAME
            FROM hr_operating_units
            WHERE ORGANIZATION_ID=MO_GLOBAL.GET_CURRENT_ORG_ID; -- MOAC fix - Bug#5378114 --varangan- 29-9-06


         l_succ_cnt          NUMBER;
         l_op_unit_name      hr_operating_units.name%TYPE;
         lx_msg_data         VARCHAR2(450);
         l_msg_index_out     NUMBER :=0;
         submitted_sts       okl_trx_ar_invoices_v.trx_status_code%TYPE;
         l_end_of_records    VARCHAR2(1);

  BEGIN
	 l_return_status := Okl_Api.START_ACTIVITY(
		p_api_name	=> l_api_name,
		p_pkg_name	=> G_PKG_NAME,
		p_init_msg_list	=> p_init_msg_list,
		l_api_version	=> l_api_version,
		p_api_version	=> p_api_version,
		p_api_type	=> '_PVT',
		x_return_status	=> l_return_status);

         --L_DEBUG_ENABLED := Okl_Debug_Pub.CHECK_LOG_ENABLED;

	 l_end_of_records := 'N';


    	 PRINT_TO_LOG('=========================================================================================');
    	 PRINT_TO_LOG('              ** Start Processing. Please See Error Log for any errored transactions **   ');
    	 PRINT_TO_LOG('=========================================================================================');

         PRINT_TO_LOG('IE p_assigned_process: '||p_assigned_process);
         PRINT_TO_LOG('IE Start time internal_to_external : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));

         IF p_assigned_process IS NOT NULL THEN
            -- Cursors 3,4 with parallel process
            ie_tbl1.DELETE;
            ie_tbl2.DELETE;

            OPEN int_lns_csr3;
            LOOP
            -- ----------------------------
            -- Clear table contents
            -- ----------------------------

               FETCH int_lns_csr3 BULK COLLECT INTO ie_tbl1 LIMIT l_fetch_size;
               PRINT_TO_LOG('IE int_lns_csr3 ie_tbl1 count is: '||ie_tbl1.COUNT);

               IF ie_tbl1.COUNT > 0 THEN

                  process_ie_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                        ,p_commit
			,p_contract_number
			,ie_tbl1
			,ie_tbl2
    			,l_end_of_records
                	);

               END IF;
            EXIT WHEN int_lns_csr3%NOTFOUND;
            END LOOP;
            CLOSE int_lns_csr3;

            ie_tbl1.DELETE;
            ie_tbl2.DELETE;

            OPEN int_lns_csr4;
            LOOP
            -- ----------------------------
            -- Clear table contents
            -- ----------------------------

            FETCH int_lns_csr4 BULK COLLECT INTO ie_tbl2 LIMIT l_fetch_size;
            PRINT_TO_LOG('IE int_lns_csr4 ie_tbl2 count is: '||ie_tbl2.COUNT);

				/*
				FOR i IN ie_tbl2.first..ie_tbl2.last LOOP
				   Fnd_File.PUT_LINE (Fnd_File.LOG, 'IE4 ie_tbl2(i).tai_id: '||ie_tbl2(i).tai_id);
				   Fnd_File.PUT_LINE (Fnd_File.LOG, 'IE4 ie_tbl2(i).kle_id: '||ie_tbl2(i).kle_id);
				   Fnd_File.PUT_LINE (Fnd_File.LOG, 'IE4 ie_tbl2(i).contract_id: '||ie_tbl2(i).contract_id);
				   Fnd_File.PUT_LINE (Fnd_File.LOG, 'IE4 ie_tbl2(i).amount: '||ie_tbl2(i).amount);
				END LOOP;
                 */
                IF ie_tbl2.COUNT > 0 THEN
                   process_ie_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                        ,p_commit
			,p_contract_number
			,ie_tbl1
			,ie_tbl2
    			,l_end_of_records
                	);
                END IF;
             EXIT WHEN int_lns_csr4%NOTFOUND;
             END LOOP;
             CLOSE int_lns_csr4;
          ELSE -- p_assigned_process is null
             -- Cursors 1,2  without parallel processes
             ie_tbl1.DELETE;
	     ie_tbl2.DELETE;

             OPEN int_lns_csr1;
             LOOP
             -- ----------------------------
             -- Clear table contents
             -- ----------------------------

             FETCH int_lns_csr1 BULK COLLECT INTO ie_tbl1 LIMIT l_fetch_size;
             PRINT_TO_LOG('IE int_lns_csr1 ie_tbl1 count is: '||ie_tbl1.COUNT);
                IF ie_tbl1.COUNT > 0 THEN
                   process_ie_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                        ,p_commit
			,p_contract_number
			,ie_tbl1
			,ie_tbl2
    			,l_end_of_records
                	);
                END IF;
             EXIT WHEN int_lns_csr1%NOTFOUND;
             END LOOP;
             CLOSE int_lns_csr1;

             ie_tbl1.DELETE;
             ie_tbl2.DELETE;

	     OPEN int_lns_csr2;
             LOOP
             -- ----------------------------
             -- Clear table contents
             -- ----------------------------

             FETCH int_lns_csr2 BULK COLLECT INTO ie_tbl2 LIMIT l_fetch_size;
             PRINT_TO_LOG('IE int_lns_csr2 ie_tbl2 count is: '||ie_tbl2.COUNT);
                IF ie_tbl2.COUNT > 0 THEN
                   process_ie_tbl
                	(p_api_version
                	,p_init_msg_list
                	,x_return_status
                	,x_msg_count
                	,x_msg_data
                        ,p_commit
			,p_contract_number
			,ie_tbl1
			,ie_tbl2
    		        ,l_end_of_records
                	);
                END IF;
             EXIT WHEN int_lns_csr2%NOTFOUND;
             END LOOP;
             CLOSE int_lns_csr2;
         END IF; -- p_assigned_process is null


        ------------------------------------------------
        -- Call bulk_process to mark end of process
        ------------------------------------------------
        l_end_of_records := 'Y';
        IF (ie_tbl1.COUNT > 0 OR ie_tbl2.COUNT > 0) THEN
            process_ie_tbl
                  (p_api_version
                  ,p_init_msg_list
                  ,x_return_status
                  ,x_msg_count
                  ,x_msg_data
                  ,p_commit
		  ,p_contract_number
		  ,ie_tbl1
		  ,ie_tbl2
    		  ,l_end_of_records
                  );
         END IF;
         -----------------------------------------------------------
	 -- Print log and output messages
	 ------------------------------------------------------------

         -- Get the request Id
         l_request_id := NULL;
         OPEN  req_id_csr;
         FETCH req_id_csr INTO l_request_id;
         CLOSE req_id_csr;

         submitted_sts       := 'SUBMITTED';
         l_succ_cnt          := 0;
         -- Success Count
         OPEN   xsi_cnt_succ_csr( l_request_id, submitted_sts );
         FETCH  xsi_cnt_succ_csr INTO l_succ_cnt;
         CLOSE  xsi_cnt_succ_csr;

         -- --------------------------------------
         -- Get Operating unit name
         -- --------------------------------------
         l_op_unit_name := NULL;
         OPEN  op_unit_csr;
         FETCH op_unit_csr INTO l_op_unit_name;
         CLOSE op_unit_csr;

    -- Start New Out File stmathew 15-OCT-2004
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 54, ' ')||'Oracle Lease and Finance Management'||LPAD(' ', 55, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 53, ' ')||'Prepare Receivables Bills'||LPAD(' ', 54, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 53, ' ')||'-------------------------'||LPAD(' ', 54, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Operating Unit: '||l_op_unit_name);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Request Id: '||l_request_id||LPAD(' ',74,' ') ||'Run Date: '||TO_CHAR(SYSDATE));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Currency: '||Okl_Accounting_Util.get_func_curr_code);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD('-', 132, '-'));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Processing Details:'||LPAD(' ', 113, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Successful Records: '||l_succ_cnt);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Number of Errored Records: '||total_error_tbl.COUNT);
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT, '                Total: '||(l_succ_cnt+total_error_tbl.COUNT));
    Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));

    total_error_tbl.DELETE;

    -- End New Out File stmathew 15-OCT-2004
    IF x_msg_count > 0 THEN
       FOR i IN 1..x_msg_count LOOP
            IF i = 1 THEN
                Fnd_File.PUT_LINE (Fnd_File.OUTPUT,'Details of Errored Records:'||LPAD(' ', 97, ' '));
                Fnd_File.PUT_LINE (Fnd_File.OUTPUT,RPAD(' ', 132, ' '));
            END IF;
            Fnd_Msg_Pub.get (p_msg_index => i,
                       p_encoded => 'F',
                       p_data => lx_msg_data,
                       p_msg_index_out => l_msg_index_out);

            Fnd_File.PUT_LINE (Fnd_File.OUTPUT,TO_CHAR(i) || ': ' || lx_msg_data);

            IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_internal_to_external',
                  TO_CHAR(i) || ': ' || lx_msg_data);
            END IF;

      END LOOP;
    END IF;

    ie_tbl1.DELETE;
    ie_tbl2.DELETE;

    -- -------------------------------------------
    -- Purge data from the Parallel process Table
    -- -------------------------------------------

    IF p_assigned_process IS NOT NULL THEN

        DELETE OKL_PARALLEL_PROCESSES
        WHERE assigned_process = p_assigned_process;

        COMMIT;

    END IF;

    Okl_Api.END_ACTIVITY (
		x_msg_count	=> x_msg_count,
		x_msg_data	=> x_msg_data);
    PRINT_TO_LOG('IE End time internal_to_external : '||TO_CHAR(SYSDATE, 'HH:MI:SS'));

    PRINT_TO_LOG('=========================================================================================');
    PRINT_TO_LOG('            ** End Processing. Please See Error Log for any errored transactions **   ');
    PRINT_TO_LOG('=========================================================================================');


  EXCEPTION
	------------------------------------------------------------
	-- Exception handling
	------------------------------------------------------------
	WHEN Okl_Api.G_EXCEPTION_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (EXCP) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
                Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_internal_to_external',
                  'EXCEPTION :'||'OKL_API.G_EXCEPTION_ERROR');
        END IF;

        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (UNEXP) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_internal_to_external',
               'EXCEPTION :'||'OKL_API.G_EXCEPTION_UNEXPECTED_ERROR');
        END IF;
        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'Okl_Api.G_RET_STS_UNEXP_ERROR',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');

	WHEN OTHERS THEN
        Fnd_File.PUT_LINE (Fnd_File.OUTPUT, 'Error (OTHERS 2) => '||SQLERRM);

        IF p_assigned_process IS NOT NULL THEN
            DELETE OKL_PARALLEL_PROCESSES
            WHERE assigned_process = p_assigned_process;
            COMMIT;
        END IF;

        IF (Fnd_Log.LEVEL_EXCEPTION >= Fnd_Log.G_CURRENT_RUNTIME_LEVEL) THEN
            Fnd_Log.STRING(Fnd_Log.LEVEL_EXCEPTION,'okl_internal_to_external',
               'EXCEPTION :'||'OTHERS');
        END IF;
        x_return_status := Okl_Api.HANDLE_EXCEPTIONS (
					p_api_name	=> l_api_name,
					p_pkg_name	=> G_PKG_NAME,
					p_exc_name	=> 'OTHERS',
					x_msg_count	=> x_msg_count,
					x_msg_data	=> x_msg_data,
					p_api_type	=> '_PVT');


  END internal_to_external;


END Okl_Internal_To_External;

/
