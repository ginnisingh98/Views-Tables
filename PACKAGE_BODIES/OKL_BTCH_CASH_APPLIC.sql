--------------------------------------------------------
--  DDL for Package Body OKL_BTCH_CASH_APPLIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BTCH_CASH_APPLIC" AS
  /* $Header: OKLRBAPB.pls 120.12 2008/01/14 14:26:45 akrangan noship $ */
  -- Start of wraper code generated automatically by Debug code generator
  l_module VARCHAR2(40) := 'LEASE.RECEIVABLES.SETUP';
  l_debug_enabled CONSTANT VARCHAR2(10) := okl_debug_pub.check_log_enabled;
  l_level_procedure     NUMBER;
  is_debug_procedure_on BOOLEAN;

  -- End of wraper code generated automatically by Debug code generator

  -- Start of comments
  --
  -- Function Name   : validate_batch_lines
  -- Description    : validate_batch_lines
  -- Business Rules  :
  -- Parameters       :
  -- Version      : 1.0
  -- History        : AKRANGAN created.
  --
  -- End of comments

  PROCEDURE validate_batch_lines(p_api_version   IN NUMBER,
                                 p_init_msg_list IN VARCHAR2,
                                 p_batch_tbl     IN okl_btch_dtls_tbl_type,
                                 p_batch_exists  IN VARCHAR2,
                                 x_return_status OUT NOCOPY VARCHAR2,
                                 x_msg_count     OUT NOCOPY NUMBER,
                                 x_msg_data      OUT NOCOPY VARCHAR2) IS
    --local variables declaration
    l_api_name    CONSTANT VARCHAR2(30) := 'validate_batch_lines';
    l_api_version CONSTANT NUMBER := p_api_version;
    l_return_status         VARCHAR2(1);
    l_init_msg_list         VARCHAR2(1) := p_init_msg_list;
    l_msg_count             NUMBER;
    l_msg_data              VARCHAR2(2000);
    l_batch_tbl             okl_btch_dtls_tbl_type := p_batch_tbl;
    l_batch_exists          VARCHAR2(1) := p_batch_exists;
    l_counter               NUMBER;
    i                       NUMBER;
    l_no_stor_rcpts         VARCHAR2(1) := 'Y';
    l_submitted_batch_total NUMBER := 0;
    l_check_exists          VARCHAR2(90) DEFAULT NULL;

    --local cursors declaration
    -- get batch irm_id
    CURSOR c_get_btc_irm_id(cp_btc_id IN VARCHAR2) IS
      SELECT irm_id,
             batch_total,
             date_gl_requested
      FROM   okl_trx_csh_batch_v a
      WHERE  a.id = cp_btc_id;

    -- get org_id for contract
    CURSOR c_get_org_id(cp_contract_num IN VARCHAR2) IS
      SELECT authoring_org_id
      FROM   okc_k_headers_b
      WHERE  contract_number = cp_contract_num;

    -- get new batch details
    CURSOR c_get_btc_dtls(cp_btc_id IN VARCHAR2) IS
      SELECT date_gl_requested,
             a.irm_id,
             'x',
             trx_status_code
      FROM   okl_trx_csh_batch_v   a,
             okl_trx_csh_receipt_v b
      WHERE  a.id = cp_btc_id
      AND    a.id = b.btc_id
      AND    rownum = 1;

    -- check for unique check number
    CURSOR c_unique_check(cp_check_number IN VARCHAR2, cp_amount IN NUMBER, cp_customer_id IN NUMBER, cp_receipt_date IN DATE) IS
      SELECT check_number
      FROM   okl_trx_csh_receipt_v a
      WHERE  a.check_number = cp_check_number
      AND    a.amount = cp_amount
      AND    a.ile_id = cp_customer_id
      AND    a.date_effective = trunc(cp_receipt_date);

    --start code by pgomes on 03/05/2003
    CURSOR l_khr_curr_csr(cp_khr_id IN NUMBER) IS
      SELECT currency_code FROM okl_k_headers_full_v WHERE id = cp_khr_id;

    CURSOR l_inv_curr_csr(cp_consolidated_invoice_id IN NUMBER) IS
      SELECT currency_code
      FROM   okl_cnsld_ar_hdrs_b
      WHERE  id = cp_consolidated_invoice_id;

    l_temp_currency_code okl_k_headers_full_v.currency_code%TYPE;

    --end code by pgomes on 03/05/2003
    CURSOR l_ar_inv_curr_csr(cp_invoice_id IN NUMBER) IS
      SELECT invoice_currency_code
      FROM   ra_customer_trx_all
      WHERE  customer_trx_id = cp_invoice_id;
  BEGIN
    l_msg_count := 0;
    --  Initialize API return status to success
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    l_counter := 0;
    i         := l_batch_tbl.FIRST;

    LOOP
      -- check for missing columns
      IF l_batch_tbl(i).customer_number IS NULL AND
         l_batch_tbl(i).check_number IS NULL AND
         l_batch_tbl(i).amount IS NULL AND
         l_batch_tbl.COUNT = 1
      THEN
        l_return_status := okl_api.g_ret_sts_error;
        EXIT;
      ELSIF l_batch_tbl(i).customer_number IS NULL AND
            l_batch_tbl(i).check_number IS NULL AND
            l_batch_tbl(i).amount IS NULL AND
            l_batch_tbl.COUNT > 1
      THEN
        NULL; -- means we have empty lines in a table
      ELSIF l_batch_tbl(i).customer_number IS NULL OR
            l_batch_tbl(i).check_number IS NULL OR
            l_batch_tbl(i).amount IS NULL
      THEN
        -- Message Text: Please enter all mandatory fields
        x_return_status := okl_api.g_ret_sts_error;
        okl_api.set_message(p_app_name => 'OKL',
                            p_msg_name => 'OKL_BPD_MISSING_FIELDS');
        RAISE okl_api.g_exception_error;
      END IF;

        --akrangan cross currency feature modification begin
	/*
	--commenting the following code
      --start code by pgomes on 03/05/2003
      IF (nvl(l_batch_tbl(i).khr_id, okl_api.g_miss_num) <>
         okl_api.g_miss_num)
      THEN
        OPEN l_khr_curr_csr(l_batch_tbl(i).khr_id);

        FETCH l_khr_curr_csr
          INTO l_temp_currency_code;

        CLOSE l_khr_curr_csr;


        IF (l_temp_currency_code <> l_batch_tbl(i).currency_code)
        THEN
          okc_api.set_message(p_app_name => g_app_name,
                              p_msg_name => 'OKL_BPD_BTCH_RCPT_KHR_CURR_ERR');
          RAISE okl_api.g_exception_error;
        END IF;
      ELSIF (nvl(l_batch_tbl(i).consolidated_invoice_id, okl_api.g_miss_num) <>
            okl_api.g_miss_num)
      THEN
        OPEN l_inv_curr_csr(l_batch_tbl(i).consolidated_invoice_id);

        FETCH l_inv_curr_csr
          INTO l_temp_currency_code;

        CLOSE l_inv_curr_csr;

        IF (l_temp_currency_code <> l_batch_tbl(i).currency_code)
        THEN
          okc_api.set_message(p_app_name => g_app_name,
                              p_msg_name => 'OKL_BPD_BTCH_RCPT_INV_CURR_ERR');
          RAISE okl_api.g_exception_error;
        END IF;
      ELSIF (nvl(l_batch_tbl(i).ar_invoice_id, okl_api.g_miss_num) <>
            okl_api.g_miss_num)
      THEN
        OPEN l_ar_inv_curr_csr(l_batch_tbl(i).ar_invoice_id);

        FETCH l_ar_inv_curr_csr
          INTO l_temp_currency_code;

        CLOSE l_ar_inv_curr_csr;

        IF (l_temp_currency_code <> l_batch_tbl(i).currency_code)
        THEN
          okc_api.set_message(p_app_name => g_app_name,
                              p_msg_name => 'OKL_BPD_BTCH_RCPT_INV_CURR_ERR');
          RAISE g_exception_halt_validation;
        END IF;
      END IF;
    */
      --akrangan cross currency feature modification end
      --end code by pgomes on 03/05/2003
      IF l_batch_tbl(i).amount <= 0
      THEN
        -- Message Text: The receipt must not have a value of zero
        x_return_status := okl_api.g_ret_sts_error;
        okl_api.set_message(p_app_name => g_app_name,
                            p_msg_name => 'OKL_OP_BTCH_RCT_AMT_POS');
        RAISE okl_api.g_exception_error;
      END IF;

      IF l_batch_exists <> 'x'
      THEN
        -- creating new batch of receipts
        OPEN c_unique_check(l_batch_tbl(i).check_number,
                            l_batch_tbl(i).amount,
                            l_batch_tbl(i).ile_id,
                            trunc(l_batch_tbl(i).receipt_date));

        FETCH c_unique_check
          INTO l_check_exists;

        CLOSE c_unique_check;

        IF l_check_exists IS NOT NULL
        THEN
          -- Message Text: Check number already exists for customer.
          x_return_status := okl_api.g_ret_sts_error;
          okc_api.set_message(p_app_name     => g_app_name,
                              p_msg_name     => 'OKL_BPD_CHECK_EXISTS',
                              p_token1       => 'CHECK_NUMBER',
                              p_token1_value => l_check_exists);
          RAISE okl_api.g_exception_error;
        END IF;
      END IF;

      -- count batch lines and add receipts
      IF l_batch_tbl(i).consolidated_invoice_id IS NOT NULL OR
         l_batch_tbl(i).khr_id IS NOT NULL OR
         l_batch_tbl(i).ar_invoice_id IS NOT NULL
      THEN
        l_counter               := l_counter + 1;
        l_submitted_batch_total := l_submitted_batch_total + l_batch_tbl(i)
                                  .amount;
      END IF;

      EXIT WHEN(i = l_batch_tbl.LAST);
      i := i + 1;
    END LOOP;

    --set output variables
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_DB_ERROR',
                          p_token1       => 'PROG_NAME',
                          p_token1_value => 'validate_batch_lines',
                          p_token2       => 'SQLCODE',
                          p_token2_value => SQLCODE,
                          p_token3       => 'SQLERRM',
                          p_token3_value => SQLERRM);
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END validate_batch_lines;

  -- Start of comments
  --
  -- Function Name   : update_batch_lines
  -- Description    : update_batch_lines  procedure processes
  -- existing batch lines and updates
  -- Business Rules  :
  -- Parameters       :
  -- Version      : 1.0
  -- History        : AKRANGAN created.
  --
  -- End of comments

  PROCEDURE update_batch_lines(p_api_version   IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               p_batch_exists  IN VARCHAR2,
                               p_batch_tbl     IN okl_btch_dtls_tbl_type,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2) IS
    --local variables declaration
    l_api_name    CONSTANT VARCHAR2(30) := 'update_batch_lines';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status               VARCHAR2(1);
    l_init_msg_list               VARCHAR2(1) := p_init_msg_list;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_batch_tbl                   okl_btch_dtls_tbl_type := p_batch_tbl;
    lx_batch_tbl                  okl_btch_dtls_tbl_type;
    l_rctv_rec                    okl_rct_pvt.rctv_rec_type;
    l_rcav_tbl                    okl_rca_pvt.rcav_tbl_type;
    lx_rctv_rec                   okl_rct_pvt.rctv_rec_type;
    lx_rcav_tbl                   okl_rca_pvt.rcav_tbl_type;
    l_date_gl_requested           DATE DEFAULT NULL;
    l_irm_id                      NUMBER DEFAULT NULL;
    l_consolidated_invoice_number VARCHAR2(90) DEFAULT NULL;
    l_contract_number             VARCHAR2(120) DEFAULT NULL;
    l_customer_number             VARCHAR2(90) DEFAULT NULL;
    l_org_id                      NUMBER := mo_global.get_current_org_id();

    --local cursors defined here
    --cursor to get batch level details from db
    CURSOR c_get_btc_dtls(cp_btc_id IN VARCHAR2) IS
      SELECT date_gl_requested,
             a.irm_id
      FROM   okl_trx_csh_batch_v   a,
             okl_trx_csh_receipt_v b
      WHERE  a.id = cp_btc_id
      AND    a.id = b.btc_id
      AND    rownum = 1;
    --cursor to get receipt application id
    CURSOR c_get_receipt_appln_id(p_receipt_id IN NUMBER) IS
    SELECT id
    FROM OKL_TXL_RCPT_APPS_B
    WHERE rct_id_details = p_receipt_id;

  BEGIN
    l_msg_count := 0;
    --  Initialize API return status to success
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Step 1
    --Validate the Batch Line
    --call validate_batch_lines API
    validate_batch_lines(p_api_version   => l_api_version,
                         p_init_msg_list => l_init_msg_list,
                         p_batch_exists   => p_batch_exists,
                         p_batch_tbl     => l_batch_tbl,
                         x_return_status => l_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      => l_msg_data);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Step 2
    --Prepare Receipt Rec and Table
    OPEN c_get_btc_dtls(l_batch_tbl(1).btc_id);

    FETCH c_get_btc_dtls
      INTO l_date_gl_requested, l_irm_id;

    CLOSE c_get_btc_dtls;

    -- i := l_batch_tbl.FIRST;
    FOR i IN l_batch_tbl.FIRST .. l_batch_tbl.LAST
    LOOP
      l_consolidated_invoice_number := l_batch_tbl(i)
                                      .consolidated_invoice_number;
      l_contract_number             := l_batch_tbl(i).contract_number;
      l_customer_number             := l_batch_tbl(i).customer_number;
      -- Update Record in Internal Transaction Table.

      -- Prepare HEADER REC AND ONE LINE RECORD
      l_rctv_rec.id               := l_batch_tbl(i).id;
      l_rctv_rec.btc_id           := l_batch_tbl(i).btc_id;
      l_rctv_rec.irm_id           := l_irm_id;
      l_rctv_rec.ile_id           := l_batch_tbl(i).ile_id;
      l_rctv_rec.check_number     := l_batch_tbl(i).check_number;
      l_rctv_rec.amount           := l_batch_tbl(i).amount;
      l_rctv_rec.currency_code    := l_batch_tbl(i).currency_code;
      l_rctv_rec.gl_date          := l_date_gl_requested;
      l_rctv_rec.date_effective   := l_batch_tbl(i).receipt_date;
      l_rctv_rec.org_id           := l_org_id;
      l_rctv_rec.rcpt_status_code := 'SUBMITTED';
      -- passing DFF attributes to receipt record
      l_rctv_rec.attribute_category := l_batch_tbl(i).dff_attribute_category;
      l_rctv_rec.attribute1 := l_batch_tbl(i).dff_attribute1;
      l_rctv_rec.attribute2 := l_batch_tbl(i).dff_attribute2;
      l_rctv_rec.attribute3 := l_batch_tbl(i).dff_attribute3;
      l_rctv_rec.attribute4 := l_batch_tbl(i).dff_attribute4;
      l_rctv_rec.attribute5 := l_batch_tbl(i).dff_attribute5;
      l_rctv_rec.attribute6 := l_batch_tbl(i).dff_attribute6;
      l_rctv_rec.attribute7 := l_batch_tbl(i).dff_attribute7;
      l_rctv_rec.attribute8 := l_batch_tbl(i).dff_attribute8;
      l_rctv_rec.attribute9 := l_batch_tbl(i).dff_attribute9;
      l_rctv_rec.attribute10 := l_batch_tbl(i).dff_attribute10;
      l_rctv_rec.attribute11 := l_batch_tbl(i).dff_attribute11;
      l_rctv_rec.attribute12 := l_batch_tbl(i).dff_attribute12;
      l_rctv_rec.attribute13 := l_batch_tbl(i).dff_attribute13;
      l_rctv_rec.attribute14 := l_batch_tbl(i).dff_attribute14;
      l_rctv_rec.attribute15 := l_batch_tbl(i).dff_attribute15;
      OPEN c_get_receipt_appln_id(l_batch_tbl(i).id);
      FETCH  c_get_receipt_appln_id INTO l_rcav_tbl(1).ID;
      CLOSE c_get_receipt_appln_id;
      l_rcav_tbl(1).rct_id_details := l_batch_tbl(i).id;
      l_rcav_tbl(1).cnr_id := l_batch_tbl(i).consolidated_invoice_id;
      l_rcav_tbl(1).ar_invoice_id := l_batch_tbl(i).ar_invoice_id;
      l_rcav_tbl(1).khr_id := l_batch_tbl(i).khr_id;
      l_rcav_tbl(1).ile_id := l_batch_tbl(i).ile_id;
      l_rcav_tbl(1).amount := l_batch_tbl(i).amount;
      l_rcav_tbl(1).line_number := 1;
      l_rcav_tbl(1).org_id := l_org_id;

      -- Start of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans
      IF (is_debug_procedure_on)
      THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,
                                  l_module,
                                  'Begin Debug OKLRBAPB.pls call Okl_Rct_Pub.update_internal_trans ');
        END;
      END IF;

      --Step 3
      --Update the Receipt and Receipt Appln Line
      --Call the Update API
      okl_rct_pub.update_internal_trans(l_api_version,
                                        l_init_msg_list,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_rctv_rec,
                                        l_rcav_tbl,
                                        lx_rctv_rec,
                                        lx_rcav_tbl);

      IF (is_debug_procedure_on)
      THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,
                                  l_module,
                                  'End Debug OKLRBAPB.pls call Okl_Rct_Pub.create_internal_trans ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

    -- EXIT WHEN (i = l_batch_tbl.LAST);
    --i := i + 1;
    END LOOP;

    --set output variables
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_DB_ERROR',
                          p_token1       => 'PROG_NAME',
                          p_token1_value => 'update_batch_lines',
                          p_token2       => 'SQLCODE',
                          p_token2_value => SQLCODE,
                          p_token3       => 'SQLERRM',
                          p_token3_value => SQLERRM);
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END update_batch_lines;

  -- Start of comments
  --
  -- Function Name   : insert_batch_lines
  -- Description    : insert_batch_lines  procedure inserts
  -- new  batch lines
  -- Business Rules  :
  -- Parameters       :
  -- Version      : 1.0
  -- History        : AKRANGAN created.
  --
  -- End of comments

  PROCEDURE insert_batch_lines(p_api_version   IN NUMBER,
                               p_init_msg_list IN VARCHAR2,
                               p_batch_exists  IN VARCHAR2,
                               p_batch_tbl     IN okl_btch_dtls_tbl_type,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count     OUT NOCOPY NUMBER,
                               x_msg_data      OUT NOCOPY VARCHAR2) IS
    --local variables declaration
    l_api_name    CONSTANT VARCHAR2(30) := 'insert_batch_lines';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status               VARCHAR2(1);
    l_init_msg_list               VARCHAR2(1) := p_init_msg_list;
    l_msg_count                   NUMBER;
    l_msg_data                    VARCHAR2(2000);
    l_batch_tbl                   okl_btch_dtls_tbl_type := p_batch_tbl;
    lx_batch_tbl                  okl_btch_dtls_tbl_type;
    l_rctv_rec                    okl_rct_pvt.rctv_rec_type;
    l_rcav_tbl                    okl_rca_pvt.rcav_tbl_type;
    lx_rctv_rec                   okl_rct_pvt.rctv_rec_type;
    lx_rcav_tbl                   okl_rca_pvt.rcav_tbl_type;
    l_date_gl_requested           DATE DEFAULT NULL;
    l_irm_id                      NUMBER DEFAULT NULL;
    l_consolidated_invoice_number VARCHAR2(90) DEFAULT NULL;
    l_contract_number             VARCHAR2(120) DEFAULT NULL;
    l_customer_number             VARCHAR2(90) DEFAULT NULL;
    l_org_id                      NUMBER := mo_global.get_current_org_id
                                                                          ();

    --local cursors defined here
    --cursor to get batch level details from db
    CURSOR c_get_btc_dtls(cp_btc_id IN VARCHAR2) IS
      SELECT date_gl_requested,
             a.irm_id
      FROM   okl_trx_csh_batch_v   a,
             okl_trx_csh_receipt_v b
      WHERE  a.id = cp_btc_id
      AND    a.id = b.btc_id
      AND    rownum = 1;
  BEGIN
    l_msg_count := 0;
    --  Initialize API return status to success
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Step 1
    --Validate the Batch Line
    --call validate_batch_lines API
    validate_batch_lines(p_api_version   => l_api_version,
                         p_init_msg_list => l_init_msg_list,
                         p_batch_exists   => p_batch_exists,
                         p_batch_tbl     => l_batch_tbl,
                         x_return_status => l_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      => l_msg_data);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Step 2
    --Prepare Receipt Rec and Table
    OPEN c_get_btc_dtls(l_batch_tbl(1).btc_id);

    FETCH c_get_btc_dtls
      INTO l_date_gl_requested, l_irm_id;

    CLOSE c_get_btc_dtls;

    --i := l_batch_tbl.FIRST;
    FOR i IN l_batch_tbl.FIRST .. l_batch_tbl.LAST
    LOOP
      l_consolidated_invoice_number := l_batch_tbl(i)
                                      .consolidated_invoice_number;
      l_contract_number             := l_batch_tbl(i).contract_number;
      l_customer_number             := l_batch_tbl(i).customer_number;
      -- Update Record in Internal Transaction Table.

      -- Prepare HEADER REC AND ONE LINE RECORD
      l_rctv_rec.id               := l_batch_tbl(i).id;
      l_rctv_rec.btc_id           := l_batch_tbl(i).btc_id;
      l_rctv_rec.irm_id           := l_irm_id;
      l_rctv_rec.ile_id           := l_batch_tbl(i).ile_id;
      l_rctv_rec.check_number     := l_batch_tbl(i).check_number;
      l_rctv_rec.amount           := l_batch_tbl(i).amount;
      l_rctv_rec.currency_code    := l_batch_tbl(i).currency_code;
      l_rctv_rec.gl_date          := l_date_gl_requested;
      l_rctv_rec.date_effective   := l_batch_tbl(i).receipt_date;
      l_rctv_rec.org_id           := l_org_id;
      l_rctv_rec.rcpt_status_code := 'SUBMITTED';
      -- passing DFF attributes to receipt record
      l_rctv_rec.attribute_category := l_batch_tbl(i).dff_attribute_category;
      l_rctv_rec.attribute1 := l_batch_tbl(i).dff_attribute1;
      l_rctv_rec.attribute2 := l_batch_tbl(i).dff_attribute2;
      l_rctv_rec.attribute3 := l_batch_tbl(i).dff_attribute3;
      l_rctv_rec.attribute4 := l_batch_tbl(i).dff_attribute4;
      l_rctv_rec.attribute5 := l_batch_tbl(i).dff_attribute5;
      l_rctv_rec.attribute6 := l_batch_tbl(i).dff_attribute6;
      l_rctv_rec.attribute7 := l_batch_tbl(i).dff_attribute7;
      l_rctv_rec.attribute8 := l_batch_tbl(i).dff_attribute8;
      l_rctv_rec.attribute9 := l_batch_tbl(i).dff_attribute9;
      l_rctv_rec.attribute10 := l_batch_tbl(i).dff_attribute10;
      l_rctv_rec.attribute11 := l_batch_tbl(i).dff_attribute11;
      l_rctv_rec.attribute12 := l_batch_tbl(i).dff_attribute12;
      l_rctv_rec.attribute13 := l_batch_tbl(i).dff_attribute13;
      l_rctv_rec.attribute14 := l_batch_tbl(i).dff_attribute14;
      l_rctv_rec.attribute15 := l_batch_tbl(i).dff_attribute15;
      l_rcav_tbl(1).rct_id_details := l_batch_tbl(i).id;
      l_rcav_tbl(1).cnr_id := l_batch_tbl(i).consolidated_invoice_id;
      l_rcav_tbl(1).ar_invoice_id := l_batch_tbl(i).ar_invoice_id;
      l_rcav_tbl(1).khr_id := l_batch_tbl(i).khr_id;
      l_rcav_tbl(1).ile_id := l_batch_tbl(i).ile_id;
      l_rcav_tbl(1).amount := l_batch_tbl(i).amount;
      l_rcav_tbl(1).line_number := 1;
      l_rcav_tbl(1).org_id := l_org_id;

      -- Start of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans
      IF (is_debug_procedure_on)
      THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,
                                  l_module,
                                  'Begin Debug OKLRBAPB.pls call Okl_Rct_Pub.update_internal_trans ');
        END;
      END IF;

      --Step 3
      --Insert the Receipt and Receipt Appln Line
      --Call the Insert  API
      okl_rct_pub.create_internal_trans(l_api_version,
                                        l_init_msg_list,
                                        l_return_status,
                                        l_msg_count,
                                        l_msg_data,
                                        l_rctv_rec,
                                        l_rcav_tbl,
                                        lx_rctv_rec,
                                        lx_rcav_tbl);

      IF (is_debug_procedure_on)
      THEN
        BEGIN
          okl_debug_pub.log_debug(l_level_procedure,
                                  l_module,
                                  'End Debug OKLRBAPB.pls call Okl_Rct_Pub.create_internal_trans ');
        END;
      END IF;

      -- End of wraper code generated automatically by Debug code generator for Okl_Rct_Pub.create_internal_trans
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;

    --EXIT WHEN (i = l_batch_tbl.LAST);
    --i := i + 1;
    END LOOP;

    --set output variables
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_DB_ERROR',
                          p_token1       => 'PROG_NAME',
                          p_token1_value => 'insert_batch_lines',
                          p_token2       => 'SQLCODE',
                          p_token2_value => SQLCODE,
                          p_token3       => 'SQLERRM',
                          p_token3_value => SQLERRM);
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END insert_batch_lines;

  -- Start of comments
  --
  -- Function Name   : process_batch_lines
  -- Description    : process_batch_lines  procedure processes
  -- existing and new  batch lines and updates ,inserts  or
  -- Business Rules  :
  -- Parameters       :
  -- Version      : 1.0
  -- History        : AKRANGAN created.
  --
  -- End of comments

  PROCEDURE process_batch_lines(p_api_version   IN NUMBER,
                                p_init_msg_list IN VARCHAR2,
                                p_batch_exists  IN VARCHAR2,
                                p_batch_tbl     IN okl_btch_dtls_tbl_type,
                                x_return_status OUT NOCOPY VARCHAR2,
                                x_msg_count     OUT NOCOPY NUMBER,
                                x_msg_data      OUT NOCOPY VARCHAR2) IS
    --declare local  cursors here
    --cursor for existing receipts in the batch,
    CURSOR get_rct_id(cp_btc_id IN NUMBER, cp_receipt_id IN NUMBER) IS
      SELECT rct.id
      FROM   okl_trx_csh_receipt_b rct
      WHERE  rct.btc_id = cp_btc_id
      AND    rct.id = cp_receipt_id;

    --cursor for existing receipt applications
    CURSOR get_rca_id(cp_rct_id IN NUMBER) IS
      SELECT rca.id
      FROM   okl_txl_rcpt_apps_b rca
      WHERE  rca.rct_id_details = cp_rct_id;

    --local variables declaration
    get_rct_id_rec get_rct_id%ROWTYPE;
    get_rca_id_rec get_rca_id%ROWTYPE;
    l_batch_exists VARCHAR2(1) := p_batch_exists  ;
    l_api_name    CONSTANT VARCHAR2(30) := 'process_batch_lines';
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status VARCHAR2(1);
    l_init_msg_list VARCHAR2(1) := p_init_msg_list;
    l_msg_count     NUMBER;
    l_msg_data      VARCHAR2(2000);
    l_receipt_id    NUMBER;
    l_batch_tbl     okl_btch_dtls_tbl_type := p_batch_tbl;
    i               NUMBER;
    j               NUMBER;
    k               NUMBER;
    m               NUMBER := 0;
    n               NUMBER := 0;
    l_del_batch_tbl okl_btch_dtls_tbl_type;
    l_ins_batch_tbl okl_btch_dtls_tbl_type;
    l_upd_batch_tbl okl_btch_dtls_tbl_type;
  BEGIN
    l_msg_count := 0;
    --  Initialize API return status to success
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              l_init_msg_list,
                                              l_api_version,
                                              l_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Step 1
    --process the existing receipt rows in the batch
    --prepare batch tables to be updated and deleted
    --open the source batch tbl
    IF l_batch_tbl.COUNT > 0
    THEN
      i := l_batch_tbl.FIRST;

      LOOP
        --open receipt source cursor
        OPEN get_rct_id(l_batch_tbl(i).btc_id, l_batch_tbl(i).id);

        FETCH get_rct_id
          INTO l_receipt_id;

        IF get_rct_id%NOTFOUND
        THEN
          l_receipt_id := NULL;
        END IF;

        CLOSE get_rct_id;

        --check validity of receipt
        IF l_receipt_id IS NULL
        THEN
          m := m + 1;
          --populate the receipt batch to be inserted.
          l_ins_batch_tbl(m) := l_batch_tbl(i);
        ELSE
          --populate the receipt batch to be inserted
          n := n + 1;
          l_upd_batch_tbl(n) := l_batch_tbl(i);
        END IF;

        EXIT WHEN(i = l_batch_tbl.LAST);
        i := l_batch_tbl.NEXT(i);
      END LOOP;
    END IF;

    --Step 2
    --Update the Batch Lines which already existing and
    --and is not removed from the UI
    --Call the Update API
    IF l_upd_batch_tbl.COUNT > 0
    THEN
      update_batch_lines(p_api_version   => l_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_batch_exists   => p_batch_exists,
                         p_batch_tbl     => l_upd_batch_tbl,
                         x_return_status => l_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      => l_msg_data);

      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    --Step 3
    --Validate new lines
    --and insert them
    --call the new batch api
    IF l_ins_batch_tbl.COUNT > 0
    THEN
      insert_batch_lines(p_api_version   => l_api_version,
                         p_init_msg_list => p_init_msg_list,
                         p_batch_exists   => p_batch_exists,
                         p_batch_tbl     => l_ins_batch_tbl,
                         x_return_status => l_return_status,
                         x_msg_count     => l_msg_count,
                         x_msg_data      => l_msg_data);

      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

    --set output variables
    x_return_status := l_return_status;
    x_msg_count     := l_msg_count;
    x_msg_data      := l_msg_data;
  EXCEPTION
    WHEN okl_api.g_exception_error THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_msg_count     := l_msg_count;
      x_msg_data      := l_msg_data;
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_DB_ERROR',
                          p_token1       => 'PROG_NAME',
                          p_token1_value => 'process_batch_lines',
                          p_token2       => 'SQLCODE',
                          p_token2_value => SQLCODE,
                          p_token3       => 'SQLERRM',
                          p_token3_value => SQLERRM);
      x_msg_count := l_msg_count;
      x_msg_data  := l_msg_data;
  END process_batch_lines;

  ---------------------------------------------------------------------------
  -- PROCEDURE handle_manual_pay
  ---------------------------------------------------------------------------
  PROCEDURE handle_batch_pay(p_api_version   IN NUMBER,
                             p_init_msg_list IN VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_btch_tbl      IN okl_btch_dtls_tbl_type,
                             x_btch_tbl      OUT NOCOPY okl_btch_dtls_tbl_type) IS
    ---------------------------
    -- DECLARE Local Variables
    ---------------------------
    l_api_version                 NUMBER := 1;
    l_init_msg_list               VARCHAR2(1);
    l_return_status               VARCHAR2(1);
    l_msg_count                   NUMBER := 0;
    l_msg_data                    VARCHAR2(2000);
    l_rct_id                      NUMBER DEFAULT NULL;
    l_rca_id                      NUMBER DEFAULT NULL;
    l_btc_id                      NUMBER DEFAULT NULL;
    l_irm_id                      NUMBER DEFAULT NULL;
    l_consolidated_invoice_number VARCHAR2(90) DEFAULT NULL;
    l_ar_invoice_id               NUMBER DEFAULT NULL;
    l_currency_code               VARCHAR2(15) DEFAULT NULL;
    l_check_number                VARCHAR2(90) DEFAULT NULL;
    l_receipt_date                DATE DEFAULT NULL;
    l_date_gl_requested           DATE DEFAULT NULL;
    l_amount                      NUMBER(14, 3) DEFAULT NULL;
    l_ile_id                      NUMBER DEFAULT NULL;
    l_consolidated_invoice_id     NUMBER DEFAULT NULL;
    l_khr_id                      NUMBER DEFAULT NULL;
    l_contract_number             VARCHAR2(120) DEFAULT NULL;
    l_customer_number             VARCHAR2(90) DEFAULT NULL;
    --l_batch_qty                          NUMBER(15)    DEFAULT NULL;
    l_batch_total           NUMBER(14, 3) DEFAULT NULL;
    l_batch_exists          VARCHAR2(2) DEFAULT NULL;
    l_check_exists          VARCHAR2(90) DEFAULT NULL;
    l_no_stor_rcpts         VARCHAR2(2) DEFAULT 'Y';
    l_batch_status          VARCHAR2(30) DEFAULT NULL;
    i                       NUMBER DEFAULT NULL;
    j                       NUMBER DEFAULT NULL;
    k                       NUMBER DEFAULT NULL;
    counter                 NUMBER DEFAULT NULL;
    l_submitted_batch_total NUMBER DEFAULT NULL;
    l_api_name CONSTANT VARCHAR2(30) := 'handle_batch_pay';
    ------------------------------
    -- DECLARE Record/Table Types
    ------------------------------

    -- Internal Trans
    l_btch_tbl okl_btch_dtls_tbl_type;
    l_org_id   NUMBER DEFAULT mo_global.get_current_org_id();
    -- Internal Trans
    l_btcv_rec okl_btc_pvt.btcv_rec_type;
    x_btcv_rec okl_btc_pvt.btcv_rec_type;
    l_rctv_rec okl_rct_pvt.rctv_rec_type;
    l_rctv_tbl okl_rct_pvt.rctv_tbl_type;
    l_rcav_tbl okl_rca_pvt.rcav_tbl_type;
    -- abindal start bug# 4695618 --
    lv_rcav_tbl okl_rca_pvt.rcav_tbl_type;
    -- abindal end bug# 4695618 --
    x_rctv_rec okl_rct_pvt.rctv_rec_type;
    x_rcav_tbl okl_rca_pvt.rcav_tbl_type;
    --added by akrangan
    l_trx_status_code VARCHAR2(50);
    l_sub_batch_sts   VARCHAR2(50) := 'SUBMITTED';
    l_err_batch_sts   VARCHAR2(50);

    -------------------
    -- DECLARE Cursors
    -------------------

    ----------

    -- get batch irm_id
    CURSOR c_get_btc_irm_id(cp_btc_id IN VARCHAR2) IS
      SELECT irm_id,
             batch_total,
             date_gl_requested
      FROM   okl_trx_csh_batch_v a
      WHERE  a.id = cp_btc_id;

    ----------

    -- get org_id for contract
    CURSOR c_get_org_id(cp_contract_num IN VARCHAR2) IS
      SELECT authoring_org_id
      FROM   okc_k_headers_b
      WHERE  contract_number = cp_contract_num;

    ----------

    -- get new batch details
    CURSOR c_get_btc_dtls(cp_btc_id IN VARCHAR2) IS
      SELECT 'x'
      FROM   okl_trx_csh_batch_v   a,
             okl_trx_csh_receipt_v b
      WHERE  a.id = cp_btc_id
      AND    a.id = b.btc_id
      AND    rownum = 1;

    ----------

    -- check for unique check number
    CURSOR c_unique_check(cp_check_number IN VARCHAR2, cp_amount IN NUMBER, cp_customer_id IN NUMBER, cp_receipt_date IN DATE) IS
      SELECT check_number
      FROM   okl_trx_csh_receipt_v a
      WHERE  a.check_number = cp_check_number
      AND    a.amount = cp_amount
      AND    a.ile_id = cp_customer_id
      AND    a.date_effective = trunc(cp_receipt_date);

    ----------

    -- get the rct_id's ready for deletion.
    CURSOR get_rct_id(cp_btc_id IN NUMBER) IS
      SELECT rct.id
      FROM   okl_trx_csh_receipt_b rct
      WHERE  rct.btc_id = cp_btc_id;

    get_rct_id_rec get_rct_id%ROWTYPE;

    ----------

    -- get the rct_id's ready for deletion.
    CURSOR get_rca_id(cp_rct_id IN NUMBER) IS
      SELECT rca.id
      FROM   okl_txl_rcpt_apps_b rca
      WHERE  rca.rct_id_details = cp_rct_id;

    get_rca_id_rec get_rca_id%ROWTYPE;

    ----------

    --start code by pgomes on 03/05/2003
    CURSOR l_khr_curr_csr(cp_khr_id IN NUMBER) IS
      SELECT currency_code FROM okl_k_headers_full_v WHERE id = cp_khr_id;

    CURSOR l_inv_curr_csr(cp_consolidated_invoice_id IN NUMBER) IS
      SELECT currency_code
      FROM   okl_cnsld_ar_hdrs_b
      WHERE  id = cp_consolidated_invoice_id;

    l_temp_currency_code okl_k_headers_full_v.currency_code%TYPE;

    --end code by pgomes on 03/05/2003
    CURSOR l_ar_inv_curr_csr(cp_invoice_id IN NUMBER) IS
      SELECT invoice_currency_code
      FROM   ra_customer_trx_all
      WHERE  customer_trx_id = cp_invoice_id;
  BEGIN
    l_return_status := okl_api.start_activity(l_api_name,
                                              g_pkg_name,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              l_return_status);

    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    l_btch_tbl              := p_btch_tbl;
    l_submitted_batch_total := 0;
    i                       := 1;
    l_btc_id                := l_btch_tbl(i).btc_id;

    --akrangan moved the cursor location above
    -- check to see if batch exists, if it does obtain details ....
    OPEN c_get_btc_dtls(l_btc_id);

    FETCH c_get_btc_dtls
      INTO l_batch_exists;

    CLOSE c_get_btc_dtls;

    process_batch_lines(p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        p_batch_tbl     => l_btch_tbl,
                        p_batch_exists  => l_batch_exists,
                        x_return_status => l_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data);
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

    okl_api.end_activity(x_msg_count, x_msg_data);
    -- NEED TO HANDLE ERRORS AT THIS POINT --
  EXCEPTION
    WHEN g_exception_halt_validation THEN
      x_return_status := okl_api.g_ret_sts_error;
      x_return_status := okl_api.handle_exceptions(l_api_name,
                                                   g_pkg_name,
                                                   'OKL_API.G_RET_STS_ERROR',
                                                   x_msg_count,
                                                   x_msg_data,
                                                   '_PVT');
    WHEN okl_api.g_exception_error THEN
      x_return_status := okl_api.handle_exceptions(l_api_name,
                                                   g_pkg_name,
                                                   'OKL_API.G_RET_STS_ERROR',
                                                   x_msg_count,
                                                   x_msg_data,
                                                   '_PVT');
    WHEN okl_api.g_exception_unexpected_error THEN
      x_return_status := okl_api.handle_exceptions(l_api_name,
                                                   g_pkg_name,
                                                   'OKL_API.G_RET_STS_ERROR',
                                                   x_msg_count,
                                                   x_msg_data,
                                                   '_PVT');
    WHEN OTHERS THEN
      x_return_status := okl_api.g_ret_sts_unexp_error;
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);
  END handle_batch_pay;
END okl_btch_cash_applic;

/
