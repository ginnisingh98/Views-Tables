--------------------------------------------------------
--  DDL for Package Body OKL_AM_ASSET_DISPOSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_AM_ASSET_DISPOSE_PVT" AS
/* $Header: OKLRADPB.pls 120.35.12010000.2 2008/09/05 22:43:19 smereddy ship $ */

-- Start of comments
--
-- Procedure Name  :  process_accounting_entries
-- Description     :  This procedure is used to do accounting entries for the disposed asset(s)
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- History         : SECHAWLA 31-DEC-02 Bug # 2726739
--                      Added logic to send functional currency code to AE
--                   SECHAWLA 03-JAN-03 Bug # 2683876
--                      Added p_func_curr_code parameter. Changed the logic to use functional curr code passed by the
--                      dispose_asset procedure, instead of deriving the func currency code in process_accounting_entries
--                 : RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
--                 : AKRANGAN 28-Apr-07 SLA Single AE Call Uptake Changes
--                 : rbruno 04-Sep-07 5436987 Asset Disposition Accounting currency code should be contract currency,
--                      also accounting date will be quote eff date
-- End of comments
  --akrangan added for sla populate sources cr start
   G_TRAN_TBL_IDX     NUMBER := 0;
   TYPE G_ID_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   G_TRANS_ID_TBL   G_ID_TBL_TYPE;
  --akrangan added for sla populate sources cr end
  TYPE      asset_dist_rec  IS RECORD ( p_distribution_id  NUMBER,
                                        p_units_assigned   NUMBER);

  TYPE      asset_dist_tbl  IS TABLE OF asset_dist_rec INDEX BY BINARY_INTEGER;
  -- These types can not be moved to a procedure as these are used in procedure parameters of one of the
  -- private procedures.

  PROCEDURE process_accounting_entries(p_api_version     IN NUMBER,
                                       p_init_msg_list   IN VARCHAR2,
                                       x_return_status   OUT NOCOPY VARCHAR2,
                                       x_msg_count       OUT NOCOPY NUMBER,
                                       x_msg_data        OUT NOCOPY VARCHAR2,
                                       p_kle_id          IN NUMBER,
                                       p_try_id          IN NUMBER,
                                       p_sys_date        IN DATE,
                                       p_source_id       IN NUMBER,
                                       p_trx_type        IN VARCHAR2,
                                       p_amount          IN NUMBER,
                                       p_func_curr_code  IN VARCHAR2,
                                       x_total_amount    OUT NOCOPY NUMBER,
                                       p_legal_entity_id IN NUMBER) IS

    -- Cursor to get the product id for the contract header (change to get for contract line)
    CURSOR prod_id_csr(p_kle_id IN NUMBER) IS
      SELECT khr.pdt_id,
             chrb.contract_number,
             khr.id,
             chrb.scs_code, -- rmunjulu 4622198
             chrb.org_id --added by akrangan to get the org_id of the contract
      FROM   okc_k_headers_b chrb,
             okl_k_headers   khr,
             okc_k_lines_b   okc
      WHERE  okc.id = p_kle_id
      AND    khr.id = chrb.id
      AND    okc.chr_id = chrb.id;
    --akrangan sla cr start
    --hdr dff fields cursor
    --this cursor is to populate the
    -- desc flex fields columns in okl_trx_contracts
    CURSOR trx_contracts_dff_csr(p_khr_id IN NUMBER) IS
      SELECT attribute_category,
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
             attribute15
      FROM   okl_k_headers okl
      WHERE  okl.id = p_khr_id;
    --line dff fields cursor
    --this cursor is to populate the
    -- desc flex fields columns in okl_txl_xontract_lines_b
    CURSOR txl_contracts_dff_csr(p_kle_id IN NUMBER) IS
      SELECT attribute_category,
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
             attribute15
      FROM   okl_k_lines okl
      WHERE  okl.id = p_kle_id;
    --record for storing okl_k_lines dffs
    TYPE dff_rec_type IS RECORD(
      attribute_category okl_k_lines.attribute_category%TYPE,
      attribute1         okl_k_lines.attribute1%TYPE,
      attribute2         okl_k_lines.attribute2%TYPE,
      attribute3         okl_k_lines.attribute3%TYPE,
      attribute4         okl_k_lines.attribute4%TYPE,
      attribute5         okl_k_lines.attribute5%TYPE,
      attribute6         okl_k_lines.attribute6%TYPE,
      attribute7         okl_k_lines.attribute7%TYPE,
      attribute8         okl_k_lines.attribute8%TYPE,
      attribute9         okl_k_lines.attribute9%TYPE,
      attribute10        okl_k_lines.attribute10%TYPE,
      attribute11        okl_k_lines.attribute11%TYPE,
      attribute12        okl_k_lines.attribute12%TYPE,
      attribute13        okl_k_lines.attribute13%TYPE,
      attribute14        okl_k_lines.attribute14%TYPE,
      attribute15        okl_k_lines.attribute15%TYPE);
    txl_contracts_dff_rec dff_rec_type;
    --product name and tax owner
    CURSOR product_name_csr(p_pdt_id IN NUMBER) IS
      SELECT NAME,
             tax_owner
      FROM   okl_product_parameters_v
      WHERE  id = p_pdt_id;
    --akrangan sla cr end
    lp_tmpl_identify_rec       okl_account_dist_pub.tmpl_identify_rec_type;
    lp_dist_info_rec           okl_account_dist_pub.dist_info_rec_type;
    lp_ctxt_val_tbl            okl_account_dist_pub.ctxt_val_tbl_type;
    lp_acc_gen_primary_key_tbl okl_account_dist_pub.acc_gen_primary_key;
    lx_template_tbl            okl_account_dist_pub.avlv_tbl_type;
    lx_amount_tbl              okl_account_dist_pub.amount_tbl_type;

    l_return_status   VARCHAR2(1) := okl_api.g_ret_sts_success;
    l_api_name        VARCHAR2(30) := 'process_accounting_entries';
    l_pdt_id          NUMBER := 0;
    l_contract_number VARCHAR2(120);
    l_khr_id          NUMBER;
    l_trans_meaning   VARCHAR2(200);
    l_total_amount    NUMBER := 0;
    --akrangan sla cr start
    --loop variables
    i NUMBER;
    k NUMBER;
    l NUMBER;
    m NUMBER;
    --akranagna sla cr end

    -- rmunjulu 4622198
    l_scs_code       okc_k_headers_b.scs_code%TYPE;
    l_fact_synd_code fnd_lookups.lookup_code%TYPE;
    l_inv_acct_code  okc_rules_b.rule_information1%TYPE;

    --akrangan sla cr start
    --local variables and types declared here
    l_org_id                   NUMBER(15);
    l_currency_code            okl_trx_contracts.currency_code%TYPE;
    l_contract_currency        okl_trx_contracts.currency_code%TYPE;
    l_currency_conversion_type okl_k_headers_full_v.currency_conversion_type%TYPE;
    l_currency_conversion_rate okl_k_headers_full_v.currency_conversion_rate%TYPE;
    l_currency_conversion_date okl_k_headers_full_v.currency_conversion_date%TYPE;
    l_amount                   NUMBER;
    l_total_trx_amount         NUMBER;
    l_validity_date            DATE;
    --trx contracts specific tbl types
    l_tcnv_rec  okl_trx_contracts_pub.tcnv_rec_type;
    lx_tcnv_rec okl_trx_contracts_pub.tcnv_rec_type;
    --txl contracts specific tbl types
    l_tclv_tbl  okl_trx_contracts_pub.tclv_tbl_type;
    lx_tclv_tbl okl_trx_contracts_pub.tclv_tbl_type;
    --accounting engine specific tbl types and variables
    l_template_tbl      okl_account_dist_pub.avlv_tbl_type;
    l_tmpl_identify_tbl okl_account_dist_pvt.tmpl_identify_tbl_type;
    l_dist_info_tbl     okl_account_dist_pvt.dist_info_tbl_type;
    l_ctxt_tbl          okl_account_dist_pvt.ctxt_tbl_type;
    l_template_out_tbl  okl_account_dist_pvt.avlv_out_tbl_type;
    l_amount_out_tbl    okl_account_dist_pvt.amount_out_tbl_type;
    l_acc_gen_tbl       okl_account_dist_pvt.acc_gen_tbl_type;
    l_tcn_id            NUMBER;
    l_line_number       NUMBER := 1;
    --akrangan sla cr end

         -- rbruno bug 5436987
     l_functional_currency_code VARCHAR2(15);
     l_contract_currency_code VARCHAR2(15);
     --l_currency_conversion_type VARCHAR2(30);
     --l_currency_conversion_rate NUMBER;
     --l_currency_conversion_date DATE;
     l_converted_amount NUMBER;

     -- rbruno bug 5436987
     -- Since we do not use the amount or converted amount
     -- set a hardcoded value for the amount (and pass to to
     -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
     -- conversion values )
     l_hard_coded_amount NUMBER := 100;
     --end bug 5436987

  BEGIN
    --akrangan sla cr start
    -- Get the meaning of lookup
    l_trans_meaning := okl_am_util_pvt.get_lookup_meaning(p_lookup_type => 'OKL_ACCOUNTING_EVENT_TYPE',
                                                          p_lookup_code => upper(p_trx_type),
                                                          p_validate_yn => 'Y');

    -- get the product id
    --get org_id for the contract
    OPEN prod_id_csr(p_kle_id);
    FETCH prod_id_csr
      INTO l_pdt_id, l_contract_number, l_khr_id, l_scs_code, -- rmunjulu 4622198,
    l_org_id; --akrangan added
    CLOSE prod_id_csr;

    --akrangan sla cr end
    IF l_pdt_id IS NULL OR l_pdt_id = 0
    THEN
      -- Error: Unable to create accounting entries because of a missing
      -- Product Type for the contract CONTRACT_NUMBER.
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_PRODUCT_ID_ERROR',
                          p_token1       => 'CONTRACT_NUMBER',
                          p_token1_value => l_contract_number);

    END IF;

    -- rmunjulu 4622198 SPECIAL_ACCNT Get special accounting details
    okl_securitization_pvt.check_khr_ia_associated(p_api_version    => p_api_version,
                                                   p_init_msg_list  => okl_api.g_false,
                                                   x_return_status  => l_return_status,
                                                   x_msg_count      => x_msg_count,
                                                   x_msg_data       => x_msg_data,
                                                   p_khr_id         => l_khr_id,
                                                   p_scs_code       => l_scs_code,
                                                   p_trx_date       => p_sys_date,
                                                   x_fact_synd_code => l_fact_synd_code,
                                                   x_inv_acct_code  => l_inv_acct_code);

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    -- rmunjulu 4622198 SPECIAL_ACCNT set the special accounting parameters
    lp_tmpl_identify_rec.factoring_synd_flag := l_fact_synd_code;
    lp_tmpl_identify_rec.investor_code       := l_inv_acct_code;

    --getting currency code and currency related attributes
    l_currency_code := okl_am_util_pvt.get_chr_currency(l_khr_id);
    --currency conversion variables
    IF ((p_func_curr_code IS NOT NULL) AND
       (l_currency_code <> p_func_curr_code))
    THEN
      okl_accounting_util.convert_to_functional_currency(p_khr_id                   => l_khr_id,
                                                         p_to_currency              => p_func_curr_code,
                                                         p_transaction_date         => p_sys_date,
                                                         p_amount                   => p_amount,
                                                         x_return_status            => l_return_status,
                                                         x_contract_currency        => l_contract_currency,
                                                         x_currency_conversion_type => l_currency_conversion_type,
                                                         x_currency_conversion_rate => l_currency_conversion_rate,
                                                         x_currency_conversion_date => l_currency_conversion_date,
                                                         x_converted_amount         => l_amount);
      --setting the currency conversion fields of the rec
      l_tcnv_rec.currency_conversion_type := l_currency_conversion_type;
      l_tcnv_rec.currency_conversion_rate := l_currency_conversion_rate;
      l_tcnv_rec.currency_conversion_date := l_currency_conversion_date;
      --trap the conversion exception
      --if conv rate is not found GL API returns negative
      IF l_return_status <> okl_api.g_ret_sts_success
      THEN
        -- Error occurred when creating accounting entries for transaction TRX_TYPE.
        --currency conversion rate was not found in Oracle GL
        okc_api.set_message(p_app_name     => 'OKL',
                            p_msg_name     => 'OKL_LLA_CONV_RATE_NOT_FOUND',
                            p_token1       => 'FROM_CURRENCY',
                            p_token1_value => l_contract_currency,
                            p_token2       => 'TO_CURRENCY',
                            p_token2_value => p_func_curr_code,
                            p_token3       => 'CONVERSION_TYPE',
                            p_token3_value => l_currency_conversion_type,
                            p_token4       => 'CONVERSION_DATE',
                            p_token4_value => to_char(l_currency_conversion_date,
                                                      'DD-MON-YYYY'));

      END IF;

      -- Raise exception to rollback to savepoint for this block
      IF (l_return_status = okl_api.g_ret_sts_unexp_error)
      THEN
        RAISE okl_api.g_exception_unexpected_error;
      ELSIF (l_return_status = okl_api.g_ret_sts_error)
      THEN
        RAISE okl_api.g_exception_error;
      END IF;
    END IF;

     -- *********************************************
     -- Populate Trx Contracts Header Record
     -- *********************************************
    --setting the record with data
    l_tcnv_rec.khr_id                    := l_khr_id;
    l_tcnv_rec.pdt_id                    := l_pdt_id;
    l_tcnv_rec.try_id                    := p_try_id;
    l_tcnv_rec.tsu_code                  := 'PROCESSED';
    l_tcnv_rec.tcn_type                  := 'ADP';
    l_tcnv_rec.description               := 'Lease transaction on asset disposition';
    l_tcnv_rec.date_transaction_occurred := p_sys_date;
    l_tcnv_rec.currency_code             := l_currency_code;
    l_tcnv_rec.org_id                    := l_org_id;
    l_tcnv_rec.legal_entity_id           := p_legal_entity_id;

    --product name and tax owner code
    OPEN product_name_csr(l_pdt_id);
    FETCH product_name_csr
      INTO l_tcnv_rec.product_name, l_tcnv_rec.tax_owner_code;
    CLOSE product_name_csr;

    --trx contracts hdr dffs
    OPEN trx_contracts_dff_csr(l_khr_id);
    FETCH trx_contracts_dff_csr
      INTO l_tcnv_rec.attribute_category, l_tcnv_rec.attribute1, l_tcnv_rec.attribute2,
           l_tcnv_rec.attribute3, l_tcnv_rec.attribute4, l_tcnv_rec.attribute5,
    l_tcnv_rec.attribute6, l_tcnv_rec.attribute7, l_tcnv_rec.attribute8,
    l_tcnv_rec.attribute9, l_tcnv_rec.attribute10, l_tcnv_rec.attribute11,
    l_tcnv_rec.attribute12, l_tcnv_rec.attribute13, l_tcnv_rec.attribute14,
    l_tcnv_rec.attribute15;
    CLOSE trx_contracts_dff_csr;

    --call trx contracts to populate the hdr record
    okl_trx_contracts_pub.create_trx_contracts(
                         p_api_version   => p_api_version,
                         p_init_msg_list => okl_api.g_false,
                         x_return_status => l_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_tcnv_rec      => l_tcnv_rec,
                         x_tcnv_rec      => lx_tcnv_rec
                                               );

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --assigning the ourput record type value to the record type sent as input
    l_tcnv_rec := lx_tcnv_rec;

     -- *********************************************
     -- Get all The Templates
     -- *********************************************

    -- Form the tmpl_identify_rec in parameter
    lp_tmpl_identify_rec.product_id          := l_pdt_id;
    lp_tmpl_identify_rec.transaction_type_id := p_try_id;
    lp_tmpl_identify_rec.memo_yn             := 'N';
    lp_tmpl_identify_rec.prior_year_yn       := 'N';
    l_validity_date := okl_accounting_util.get_valid_gl_date(p_sys_date);
    --get template info from accounting distributions API
    okl_account_dist_pub.get_template_info(
           p_api_version       => p_api_version,
           p_init_msg_list     => okl_api.g_false,
           x_return_status     => l_return_status,
           x_msg_count         => x_msg_count,
           x_msg_data          => x_msg_data,
           p_tmpl_identify_rec => lp_tmpl_identify_rec,
           x_template_tbl      => l_template_tbl,
           p_validity_date     => l_validity_date
                                           );
    --set error message No Accounting Templates
    IF l_template_tbl.COUNT = 0
    THEN
      l_return_status := okl_api.g_ret_sts_error;
    END IF;

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred No Accounting Templates.
        okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_NO_ACC_TEMPLATES',
                          p_token1       => 'PRODUCT',
                          p_token1_value => l_pdt_id);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

     -- *********************************************
     -- Populate Txl Contracts Lines Record
     -- *********************************************

    --setting the tcl dff records
    OPEN txl_contracts_dff_csr(p_kle_id);
    FETCH txl_contracts_dff_csr
      INTO txl_contracts_dff_rec;
    CLOSE txl_contracts_dff_csr;
    --creating trx_contracts lines by calling the API
    IF l_template_tbl.COUNT > 0
    THEN
        i := l_template_tbl.FIRST;
        LOOP
          l_tclv_tbl(i).line_number := l_line_number;
   l_tclv_tbl(i).tcn_id := l_tcnv_rec.id;
          l_tclv_tbl(i).khr_id := l_khr_id;
          l_tclv_tbl(i).sty_id := l_template_tbl(i).sty_id;
          l_tclv_tbl(i).tcl_type := 'ADP';
          l_tclv_tbl(i).description := 'Lease transaction on asset disposition';
          l_tclv_tbl(i).currency_code := l_currency_code;
          l_tclv_tbl(i).kle_id := p_kle_id;
          l_tclv_tbl(i).org_id := l_org_id;
          --set dffs
          l_tclv_tbl(i).attribute_category := txl_contracts_dff_rec.attribute_category;
          l_tclv_tbl(i).attribute1 := txl_contracts_dff_rec.attribute1;
          l_tclv_tbl(i).attribute2 := txl_contracts_dff_rec.attribute2;
          l_tclv_tbl(i).attribute3 := txl_contracts_dff_rec.attribute3;
          l_tclv_tbl(i).attribute4 := txl_contracts_dff_rec.attribute4;
          l_tclv_tbl(i).attribute5 := txl_contracts_dff_rec.attribute5;
          l_tclv_tbl(i).attribute6 := txl_contracts_dff_rec.attribute6;
          l_tclv_tbl(i).attribute7 := txl_contracts_dff_rec.attribute7;
          l_tclv_tbl(i).attribute8 := txl_contracts_dff_rec.attribute8;
          l_tclv_tbl(i).attribute9 := txl_contracts_dff_rec.attribute9;
          l_tclv_tbl(i).attribute10 := txl_contracts_dff_rec.attribute10;
          l_tclv_tbl(i).attribute11 := txl_contracts_dff_rec.attribute11;
          l_tclv_tbl(i).attribute12 := txl_contracts_dff_rec.attribute12;
          l_tclv_tbl(i).attribute13 := txl_contracts_dff_rec.attribute13;
          l_tclv_tbl(i).attribute14 := txl_contracts_dff_rec.attribute14;
          l_tclv_tbl(i).attribute15 := txl_contracts_dff_rec.attribute15;
          -- This will calculate the amount and generate accounting entries
          -- Set the tmpl_identify_tbl in parameter
          l_tmpl_identify_tbl(i).product_id := l_pdt_id;
          l_tmpl_identify_tbl(i).transaction_type_id := p_try_id;
          l_tmpl_identify_tbl(i).memo_yn := 'N';
          l_tmpl_identify_tbl(i).prior_year_yn := 'N';
          l_tmpl_identify_tbl(i).stream_type_id :=
                                      l_template_tbl(i).sty_id;
          l_tmpl_identify_tbl(i).advance_arrears :=
                                      l_template_tbl(i).advance_arrears;
          l_tmpl_identify_tbl(i).factoring_synd_flag :=
                                      l_template_tbl(i).factoring_synd_flag;
          l_tmpl_identify_tbl(i).investor_code :=
                                      l_template_tbl(i).inv_code;
          l_tmpl_identify_tbl(i).syndication_code :=
                                      l_template_tbl(i).syt_code;
          l_tmpl_identify_tbl(i).factoring_code :=
                                      l_template_tbl(i).fac_code;

          EXIT WHEN(i = l_template_tbl.LAST);
          l_line_number := l_line_number + 1;
          i             := l_template_tbl.NEXT(i);
        END LOOP;
   END IF;
    --create trx contract lines table
    okl_trx_contracts_pub.create_trx_cntrct_lines(p_api_version   => p_api_version,
                                                  p_init_msg_list => okl_api.g_false,
                                                  x_return_status => l_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_tclv_tbl      => l_tclv_tbl,
                                                  x_tclv_tbl      => lx_tclv_tbl);

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;
    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --setting the input table type to the obtained outout table type
    l_tclv_tbl := lx_tclv_tbl;

     -- *********************************************
     -- Populate Accounting Gen
     -- *********************************************

    -- RMUNJULU 28-APR-04 3596626 Added code to set lp_acc_gen_primary_key_tbl
    -- for account generator

    okl_acc_call_pvt.okl_populate_acc_gen(
                          p_contract_id      => l_khr_id,
                          p_contract_line_id => p_kle_id,
                          x_acc_gen_tbl      => lp_acc_gen_primary_key_tbl,
                          x_return_status    => l_return_status
                                          );

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

     -- *********************************************
     -- Accounting Engine Call
     -- *********************************************

    IF l_tclv_tbl.COUNT <> 0
    THEN
      i := l_tclv_tbl.FIRST;
      LOOP
        --Assigning the account generator table
        l_acc_gen_tbl(i).acc_gen_key_tbl := lp_acc_gen_primary_key_tbl;
        l_acc_gen_tbl(i).source_id := l_tclv_tbl(i).id;
        --populating dist info tbl
        l_dist_info_tbl(i).source_id := l_tclv_tbl(i).id;
        l_dist_info_tbl(i).source_table := 'OKL_TXL_CNTRCT_LNS';
 l_dist_info_tbl(i).accounting_date :=  p_sys_date;
        l_dist_info_tbl(i).gl_reversal_flag := 'N';
        l_dist_info_tbl(i).post_to_gl := 'Y';
        l_dist_info_tbl(i).contract_id := l_khr_id;
        l_dist_info_tbl(i).contract_line_id := p_kle_id;
        l_dist_info_tbl(i).currency_code := l_currency_code;
        IF ((p_func_curr_code IS NOT NULL) AND
           (l_currency_code <> p_func_curr_code))
        THEN
          l_dist_info_tbl(i).currency_conversion_rate := l_currency_conversion_rate;
          l_dist_info_tbl(i).currency_conversion_type := l_currency_conversion_type;
          l_dist_info_tbl(i).currency_conversion_date := l_currency_conversion_date;
        END IF;
        EXIT WHEN i = l_tclv_tbl.LAST;
        i := l_tclv_tbl.NEXT(i);
      END LOOP;
    END IF;
    l_tcn_id := l_tcnv_rec.id;
    -- call accounting engine
    -- This will calculate the amount and generate accounting entries
    okl_account_dist_pvt.create_accounting_dist(
                              p_api_version             => p_api_version,
                              p_init_msg_list           => okl_api.g_false,
                              x_return_status           => l_return_status,
                              x_msg_count               => x_msg_count,
                              x_msg_data                => x_msg_data,
                              p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                              p_dist_info_tbl           => l_dist_info_tbl,
                              p_ctxt_val_tbl            => l_ctxt_tbl,
                              p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                              x_template_tbl            => l_template_out_tbl,
                              x_amount_tbl              => l_amount_out_tbl,
                              p_trx_header_id           => l_tcn_id
                                                );
    IF l_amount_out_tbl.COUNT = 0
    THEN
      l_return_status := okl_api.g_ret_sts_error;
    END IF;

    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;

     -- ******************************************************
     --   Update Trx Contracts with Header and Line Amounts
     -- ******************************************************

    --call the update trx contract api to update amount per stream type

    l_tcnv_rec.amount := 0;
    IF (l_tclv_tbl.COUNT) > 0 AND (l_amount_out_tbl.COUNT > 0)
    THEN
      k := l_tclv_tbl.FIRST;
      m := l_amount_out_tbl.FIRST;
      LOOP
        l_tclv_tbl(k).amount := 0;
        IF l_tclv_tbl(k).id = l_amount_out_tbl(m).source_id
        THEN
          lx_amount_tbl := l_amount_out_tbl(m).amount_tbl;
          IF (lx_amount_tbl.COUNT > 0)
          THEN
            l := lx_amount_tbl.FIRST;
            LOOP
              --update line amount
              l_tclv_tbl(k).amount := ( l_tclv_tbl(k).amount
                                           + nvl(lx_amount_tbl(l),0) );
              EXIT WHEN(l = lx_amount_tbl.LAST);
              l := lx_amount_tbl.NEXT(l);
            END LOOP;
         END IF ;
        END IF;
        --update total header amount
         l_tcnv_rec.amount :=
                 l_tcnv_rec.amount + l_tclv_tbl(k).amount;
       EXIT WHEN(k = l_tclv_tbl.LAST) OR (m = l_amount_out_tbl.LAST);
              k := l_tclv_tbl.NEXT(k);
       m := l_amount_out_tbl.NEXT(m);
      END LOOP;
    END IF;
    --call the api to update trx contracts hdr and lines
    okl_trx_contracts_pub.update_trx_contracts(
                       p_api_version   => p_api_version,
                       p_init_msg_list => p_init_msg_list,
                       x_return_status => l_return_status,
                       x_msg_count     => x_msg_count,
                       x_msg_data      => x_msg_data,
                       p_tcnv_rec      => l_tcnv_rec,
                       p_tclv_tbl      => l_tclv_tbl,
                       x_tcnv_rec      => lx_tcnv_rec,
                       x_tclv_tbl      => lx_tclv_tbl
                                               );
    --handle exception
    IF l_return_status <> okl_api.g_ret_sts_success
    THEN
      -- Error occurred when creating accounting entries for transaction TRX_TYPE.
      okl_api.set_message(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_AM_ERR_ACC_ENT',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);

    END IF;

    -- Raise exception to rollback to savepoint for this block
    IF (l_return_status = okl_api.g_ret_sts_unexp_error)
    THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error)
    THEN
      RAISE okl_api.g_exception_error;
    END IF;
    --set output parameters of the api.
    x_total_amount  := l_tcnv_rec.amount;

    OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => l_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => lx_tcnv_rec
                           ,P_TCLV_TBL => lx_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => lp_acc_gen_primary_key_tbl);

    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
        RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;


    x_return_status := l_return_status;

    IF l_return_status = okl_api.g_ret_sts_success
    THEN
      -- Accounting entries created for transaction type  TRX_TYPE.
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => 'OKL_AM_ACC_ENT_CREATED',
                          p_token1       => 'TRX_TYPE',
                          p_token1_value => l_trans_meaning);
    END IF;

  EXCEPTION
    -- RMUNJULU 3596626 Added exception
    WHEN okl_api.g_exception_error THEN
      IF prod_id_csr%ISOPEN
      THEN
        CLOSE prod_id_csr;
      END IF;
      IF trx_contracts_dff_csr%ISOPEN
      THEN
        CLOSE trx_contracts_dff_csr;
      END IF;
      IF txl_contracts_dff_csr%ISOPEN
      THEN
        CLOSE txl_contracts_dff_csr;
      END IF;
      IF product_name_csr%ISOPEN
      THEN
        CLOSE product_name_csr;
      END IF;

      x_return_status := okl_api.g_ret_sts_error;

    -- RMUNJULU 3596626 Added exception
    WHEN okl_api.g_exception_unexpected_error THEN
      IF prod_id_csr%ISOPEN
      THEN
        CLOSE prod_id_csr;
      END IF;
      IF trx_contracts_dff_csr%ISOPEN
      THEN
        CLOSE trx_contracts_dff_csr;
      END IF;
      IF txl_contracts_dff_csr%ISOPEN
      THEN
        CLOSE txl_contracts_dff_csr;
      END IF;
      IF product_name_csr%ISOPEN
      THEN
        CLOSE product_name_csr;
      END IF;

      x_return_status := okl_api.g_ret_sts_unexp_error;

    WHEN OTHERS THEN
      IF prod_id_csr%ISOPEN
      THEN
        CLOSE prod_id_csr;
      END IF;
      IF trx_contracts_dff_csr%ISOPEN
      THEN
        CLOSE trx_contracts_dff_csr;
      END IF;
      IF txl_contracts_dff_csr%ISOPEN
      THEN
        CLOSE txl_contracts_dff_csr;
      END IF;
      IF product_name_csr%ISOPEN
      THEN
        CLOSE product_name_csr;
      END IF;

      -- store SQL error message on message stack for caller
      okl_api.set_message(p_app_name     => 'OKL',
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      x_return_status := okl_api.g_ret_sts_error;
  END process_accounting_entries;


-- Start of comments
--
-- Procedure Name  : do_cost_retirement
-- Description     :  This procedure performs a full / partial cost retirement for an asset in the TAX Book
-- Business Rules  :
-- Parameters      :  p_asset_id   - asset id of the asset that is to be retired
--                    p_asset_number - asset number
--                    p_proceeds_of_sale - amount for which the asset is to be sold
--                    p_tax_book - tax book
--                    p_cost - cost retired
-- Version         : 1.0
-- History         : SECHAWLA 23-DEC-02 Bug # 2701440 : Created
--                   SECHAWLA 16-JAN-03 Bug # 2754280
--                     Changed the app name from OKL to OKC for g_unexpected_error
--                   SECHAWLA 05-FEB-03 Bug # 2781557
--                     Moved the logic to check if asset is added in the current open period, from this procedure
--                     to dispose_asset procedure.
--                   SECHAWLA 03-JUN-03 Bug # 2999419 : Added a new parameter for retirement prorate convention which
--                     contains the prorate convention value set in Oracle Assets for a particular asset and book
--                   SECHAWLA 21-NOV-03 3262519: Added tax owner and delta cost parameter to this procedure
--                   rmunjulu EDAT Added 2 new parameters p_quote_eff_date and p_quote_accpt_date
--                      also set some dates with quote eff date and quote accpt date passed
--                   rmunjulu bug # 4480371
--                   SECHAWLA 10-FEB-06 5016156 raise error if adjustment transaction fails
--                   sechawla 13-FEB-08 6765119 - Cost retired in the tax book should be the current cost in FA
--                      as it exists after the tax book cost adjustment to RV
-- End of comments

  PROCEDURE do_cost_retirement( p_api_version           IN   NUMBER,
                          p_init_msg_list         IN   VARCHAR2,
                                p_tax_owner             IN      VARCHAR2,
                                p_delta_cost            IN      NUMBER,
                                p_asset_id              IN      NUMBER,
                                p_asset_number          IN      VARCHAR2,
                                p_proceeds_of_sale      IN      NUMBER,
                                p_tax_book              IN      VARCHAR2,
                                p_cost                  IN      NUMBER,
                                p_prorate_convention    IN      VARCHAR2,       -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date           OUT     NOCOPY DATE,    -- SECHAWLA 15-DEC-04 4028371 : Added this parameter
                                x_msg_count             OUT  NOCOPY NUMBER,
                                x_msg_data              OUT  NOCOPY VARCHAR2,
                                x_return_status         OUT     NOCOPY VARCHAR2,
                                p_quote_eff_date        IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_quote_accpt_date      IN      DATE DEFAULT NULL  -- rmunjulu EDAT
                               )    IS


   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_dist_trans_rec             FA_API_TYPES.trans_rec_type;
   l_asset_retire_rec           FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl                FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                    FA_API_TYPES.inv_tbl_type;

   -- SECHAWLA 21-NOV-03 3262519: New Declarations
   l_adj_trans_rec              FA_API_TYPES.trans_rec_type;
   l_adj_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_adj_inv_tbl                FA_API_TYPES.inv_tbl_type;
   l_asset_fin_rec_adj      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;

   l_inv_trans_rec          FA_API_TYPES.inv_trans_rec_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;


   -- SECHAWLA 21-NOV-03 3262519: end

   --SECHAWLA 10-FEB-06 5016156 added
    l_adj_error     EXCEPTION;
    l_retire_error              EXCEPTION;

    -- sechawla 13-FEB-08 6765119
    l_current_fa_cost number;

   BEGIN

      -- All the input parameterd to this procedure will definitely have not-null values, as these are required
      -- columns of okx_asset_liens_v

      x_return_status := okl_api.G_RET_STS_SUCCESS;

      --sechawla 13-FEB-08 6765119
      l_current_fa_cost := p_cost;

      -- SECHAWLA 21-NOV-03 3262519 : update the tax book with residual value as asset cost
      ---------------------------------------  Adjustments begin-------------------------------------------

      -- p_tax_owner will have a value only if the contract is on direct finance or sales type of lease
      IF p_tax_owner = 'LESSEE' THEN
        IF p_delta_cost <> 0 THEN --SECHAWLA 15-DEC-04 Bug # 4028371 : added this condition
          --update the tax asset book with residual value as asset cost

          l_adj_trans_rec.transaction_subtype := 'AMORTIZED';
          l_adj_asset_hdr_rec.asset_id :=  p_asset_id;
          l_adj_asset_hdr_rec.book_type_code := p_tax_book;
          l_asset_fin_rec_adj.cost := p_delta_cost;

          -- rmunjulu EDAT -- Set new parameters with dates ------ start +++++++
          IF  p_quote_accpt_date IS NOT NULL
          AND p_quote_eff_date IS NOT NULL THEN

             l_adj_trans_rec.transaction_date_entered := p_quote_eff_date; -- rmunjulu bug # 4480371 p_quote_accpt_date; -- rmunjulu EDAT

             -- rmunjulu EDAT No need to set below dates
             --l_asset_fin_rec_adj.deprn_start_date := p_quote_eff_date; -- rmunjulu EDAT
             --l_asset_fin_rec_adj.prorate_date := p_quote_eff_date;     -- rmunjulu EDAT

          END IF;
          -- rmunjulu EDAT -- Set new parameters with dates ------ end   +++++++

          fa_adjustment_pub.do_adjustment(
                                            p_api_version              => p_api_version,
                                      p_init_msg_list            => OKC_API.G_FALSE,
                                      p_commit                   => FND_API.G_FALSE,
                                      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                                      p_calling_fn               => NULL,
                                      x_return_status            => x_return_status,
                                      x_msg_count                => x_msg_count,
                                      x_msg_data                 => x_msg_data,
                                      px_trans_rec               => l_adj_trans_rec,
                                      px_asset_hdr_rec           => l_adj_asset_hdr_rec,
                                      p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                                      x_asset_fin_rec_new        => l_asset_fin_rec_new,
                                      x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
                                      px_inv_trans_rec           => l_inv_trans_rec,
                                      px_inv_tbl                 => l_adj_inv_tbl,
                                       p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                                      x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                                      x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                            p_group_reclass_options_rec => l_group_reclass_options_rec);

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                -- Error updating asset cost for asset ASSET_NUMBER in BOOK_CLASS book BOOK.
                OKC_API.set_message(    p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_ADJ_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'tax',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_tax_book);
                RAISE l_adj_error;  --SECHAWLA 10-FEB-06 5016156 added

         END IF;

         --sechawla 13-FEB-08 6765119
         l_current_fa_cost := p_cost+ p_delta_cost;

         --akrangan added for sla populate sources cr start
         g_tran_tbl_idx := g_tran_tbl_idx + 1;
         --akrangan fix for bug 6409121 begin
         --changed l_trans_rec to l_adj_trans_rec which is passed to the FA api as input
         --corrected the wrong assignment
         g_trans_id_tbl(g_tran_tbl_idx) := l_adj_trans_rec.transaction_header_id;
         --akrangan fix for bug 6409121 end
         --akrangan added for sla populate sources cr end
       END IF;
      END IF;
      ---------------------------------------  Adjustments End -------------------------------------------

      -- SECHAWLA 21-NOV-03 3262519 : end new code



      --------------------------------------   Retirement Begin ------------------------------------------
      -- transaction information
      l_trans_rec.transaction_type_code := NULL;

      -- rmunjulu EDAT No need to set below date
      --IF  p_quote_accpt_date IS NOT NULL THEN -- rmunjulu EDAT
         --l_trans_rec.transaction_date_entered := p_quote_accpt_date; -- rmunjulu EDAT
      --ELSE
         l_trans_rec.transaction_date_entered := NULL;
      --END IF;

      --SECHAWLA 29-DEC-05 3827148 : added
      l_trans_rec.calling_interface  := 'OKL:'||'Asset Disposition:'||'RFA';


      -- header information
      l_asset_hdr_rec.asset_id := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_tax_book;

      -- retirement information

      --  SECHAWLA 03-JUN-03 2999419 : Use the prorate convention set in Oracle Assets for this asset and book,
      --  instead of using the constant value  MID-MONTH
      --  l_asset_retire_rec.retirement_prorate_convention := 'MID-MONTH';
      l_asset_retire_rec.retirement_prorate_convention := p_prorate_convention;

      IF  p_quote_eff_date IS NOT NULL THEN -- rmunjulu EDAT
         l_asset_retire_rec.date_retired := p_quote_eff_date; -- rmunjulu EDAT
      ELSE
         l_asset_retire_rec.date_retired := NULL;
      END IF;

     --sechawla 13-FEB-08 6765119
     -- l_asset_retire_rec.cost_retired := p_cost;

     -- sechawla 13-FEB-08 6765119
     l_asset_retire_rec.cost_retired := l_current_fa_cost;



      l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
      l_asset_retire_rec.cost_of_removal := 0;
      l_asset_retire_rec.retirement_type_code := 'SALE';
      l_asset_retire_rec.trade_in_asset_id := NULL;
      l_asset_retire_rec.calculate_gain_loss := FND_API.G_FALSE;
      --SECHAWLA 13-JAN-03 Bug # 2701440 : calculate gain and loss should be set to TRUE if multiple partial retirements are performed on the same asset in the same period
      --l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;

      -- p_user_id must be properly set to run calc gain/loss
      --fnd_profile.put('USER_ID',p_user_id);

      l_asset_dist_tbl.DELETE;

      FA_RETIREMENT_PUB.do_retirement(  p_api_version       => p_api_version,
                                        p_init_msg_list     => OKC_API.G_FALSE,
                                        p_commit            => FND_API.G_FALSE,
                                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn        => NULL,
                                        x_return_status     => x_return_status,
                                        x_msg_count         => x_msg_count,
                                        x_msg_data          => x_msg_data,
                                        px_trans_rec        => l_trans_rec,
                                        px_dist_trans_rec   => l_dist_trans_rec,
                                        px_asset_hdr_rec    => l_asset_hdr_rec,
                                        px_asset_retire_rec => l_asset_retire_rec,
                                        p_asset_dist_tbl    => l_asset_dist_tbl,
                                        p_subcomp_tbl       => l_subcomp_tbl,
                                        p_inv_tbl           => l_inv_tbl);


      IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

          -- Error retiring asset ASSET_NUMBER in book BOOK. Retirement transaction was not performed for this asset in Fixed Assets.
          OKC_API.set_message(    p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_RET_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'tax',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_tax_book);
          RAISE l_retire_error;  --SECHAWLA 10-FEB-06 5016156 added
      ELSE -- 15-DEC-04 SECHAWLA 4028371  added else section
       x_fa_trx_date := l_trans_rec.transaction_date_entered;
      END IF;
   --akrangan added for sla populate sources cr start
   g_tran_tbl_idx := g_tran_tbl_idx + 1;
   g_trans_id_tbl(g_tran_tbl_idx) := l_trans_rec.transaction_header_id;
   --akrangan added for sla populate sources cr end


      -- x_return_status of the above procedure call becomes the x_return_status of the current procedure
      -- which is then handled in the calling procedure dispose_asset()

      ---------------------------------------  Retirement End ----------------------------------------------

   EXCEPTION
      --SECHAWLA 10-FEB-06 5016156
      WHEN l_adj_error THEN
           NULL;
      WHEN l_retire_error THEN
           NULL;

      WHEN OTHERS THEN

          -- unexpected error
          -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
          OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

   END do_cost_retirement;


-- Start of comments
--
-- Procedure Name  : do_full_units_retirement
-- Description     :  This procedure retires an asset in FA if period_of_addition = 'N'
--                    This procedure is called only for the corporate book retirement
-- Business Rules  :
-- Parameters      :  p_asset_id   - asset id of the asset that is to be retired
--                    p_asset_number - asset number
--                    p_proceeds_of_sale - amount for which the asset is to be sold
--                    p_book_type_code - corporate / tax book
--                    p_cost - cost retired
-- Version         : 1.0
-- History         : SECHAWLA 10-DEC-02 Bug # 2701440
--                     Changed the parameter name p_corporate_book to p_book_type_code
--                   SECHAWLA 23-DEC-02 Bug # 2701440
--                     Changed the procedure name from do_full_retirement to do_full_units_retirement
--                     Added BOOK_CLASS token in messages.
--                   SECHAWLA 16-JAN-03 Bug # 2754280
--                     Changed the app name from OKL to OKC for g_unexpected_error
--                   SECHAWLA 05-FEB-03 Bug # 2781557
--                     Moved the logic to check if asset is added in the current open period, from this procedure
--                     to dispose_asset procedure.
--                   SECHAWLA 03-JUN-03 2999419: Added a new parameter for retirement prorate convention which
   --                  contains the prorate convention value set in Oracle Assets for a particular asset and book
--                   SECHAWLA 21-NOV-03 3262519: Added tax owner and delta cost parameter to this procedure
--                   rmunjulu EDAT Added 2 new parameters p_quote_eff_date and p_quote_accpt_date
--                      also set some dates with quote eff date and quote accpt date passed
--                   rmunjulu bug # 4480371
--                   SECHAWLA 10-FEB-06 5016156 raise error if adjusment transaction fails

-- End of comments

  PROCEDURE do_full_units_retirement( p_api_version           IN   NUMBER,
                          p_init_msg_list         IN   VARCHAR2,
                                p_tax_owner             IN      VARCHAR2,
                                p_delta_cost            IN      NUMBER,
                                p_asset_id              IN      NUMBER,
                                p_asset_number          IN      VARCHAR2,
                                p_proceeds_of_sale      IN      NUMBER,
                                -- SECHAWLA 10-DEC-02 Bug # 2701440
                                --p_corporate_book        IN      VARCHAR2,
                                p_book_type_code        IN      VARCHAR2,
                                p_units                 IN      NUMBER,
                                p_prorate_convention    IN      VARCHAR2,       -- SECHAWLA 03-JUN-03 2999419: Added this parameter
                                x_fa_trx_date           OUT     NOCOPY DATE,    -- SECHAWLA 15-DEC-04 4028371 : Added this parameter
                                x_msg_count             OUT  NOCOPY NUMBER,
                          x_msg_data              OUT  NOCOPY VARCHAR2,
                                x_return_status         OUT     NOCOPY VARCHAR2,
                                p_quote_eff_date        IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_quote_accpt_date      IN      DATE DEFAULT NULL  -- rmunjulu EDAT

                               )    IS


   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_dist_trans_rec             FA_API_TYPES.trans_rec_type;
   l_asset_retire_rec           FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl                FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                    FA_API_TYPES.inv_tbl_type;

   -- SECHAWLA 21-NOV-03 3262519: New Declarations
   l_adj_trans_rec              FA_API_TYPES.trans_rec_type;
   l_adj_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_adj_inv_tbl                FA_API_TYPES.inv_tbl_type;
   l_asset_fin_rec_adj      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;

   l_inv_trans_rec          FA_API_TYPES.inv_trans_rec_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;
    -- SECHAWLA 21-NOV-03 3262519: end

    --SECHAWLA 10-FEB-06 5016156
    l_adj_error     EXCEPTION;
    l_retire_error    EXCEPTION;

   BEGIN

      -- All the input parameterd to this procedure will definitely have not-null values, as these are required
      -- columns of okx_asset_liens_v

      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- SECHAWLA 21-NOV-03 3262519 : update the corporate book with residual value as asset cost
      ---------------------------------------  Adjustments begin-------------------------------------------

      -- p_tax_owner will have a value only if the contract is on direct finance or sales type of lease
       IF p_tax_owner IN ('LESSOR','LESSEE') THEN
         IF p_delta_cost <> 0 THEN --SECHAWLA 15-DEC-04 Bug # 4028371 : added this condition
          --update the tax asset book with residual value as asset cost

          l_adj_trans_rec.transaction_subtype := 'AMORTIZED';
          l_adj_asset_hdr_rec.asset_id :=  p_asset_id;
          l_adj_asset_hdr_rec.book_type_code := p_book_type_code;
          l_asset_fin_rec_adj.cost := p_delta_cost;

          -- rmunjulu EDAT -- Set new parameters with dates ------ start +++++++
          IF  p_quote_accpt_date IS NOT NULL
          AND p_quote_eff_date IS NOT NULL THEN

             l_adj_trans_rec.transaction_date_entered := p_quote_eff_date; -- rmunjulu bug # 4480371  p_quote_accpt_date; -- rmunjulu EDAT

             -- rmunjulu EDAT No need to set below dates
             --l_asset_fin_rec_adj.deprn_start_date := p_quote_eff_date; -- rmunjulu EDAT
             --l_asset_fin_rec_adj.prorate_date := p_quote_eff_date;     -- rmunjulu EDAT

          END IF;
          -- rmunjulu EDAT -- Set new parameters with dates ------ end   +++++++

          fa_adjustment_pub.do_adjustment(
                                            p_api_version              => p_api_version,
                                      p_init_msg_list            => OKC_API.G_FALSE,
                                      p_commit                   => FND_API.G_FALSE,
                                      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                                      p_calling_fn               => NULL,
                                      x_return_status            => x_return_status,
                                      x_msg_count                => x_msg_count,
                                      x_msg_data                 => x_msg_data,
                                      px_trans_rec               => l_adj_trans_rec,
                                      px_asset_hdr_rec           => l_adj_asset_hdr_rec,
                                      p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                                      x_asset_fin_rec_new        => l_asset_fin_rec_new,
                                      x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
                                      px_inv_trans_rec           => l_inv_trans_rec,
                                      px_inv_tbl                 => l_adj_inv_tbl,
                                       p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                                      x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                                      x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                            p_group_reclass_options_rec => l_group_reclass_options_rec);

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                -- Error updating asset cost for asset ASSET_NUMBER in BOOK_CLASS book BOOK.
                OKC_API.set_message(    p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_ADJ_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'corporate',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_book_type_code);
                RAISE l_adj_error; --SECHAWLA 10-FEB-06 5016156
          END IF;
         --akrangan added for sla populate sources cr start
         g_tran_tbl_idx := g_tran_tbl_idx + 1;
         --akrangan fix for bug 6409121 begin
         --changed l_trans_rec to l_adj_trans_rec which is passed to the FA api as input
         --corrected the wrong assignment
         g_trans_id_tbl(g_tran_tbl_idx) := l_adj_trans_rec.transaction_header_id;
         --akrangan fix for bug 6409121 end
         --akrangan added for sla populate sources cr end
        END IF;
      END IF;
      ---------------------------------------  Adjustments End -------------------------------------------
      -- SECHAWLA 21-NOV-03 3262519 : end new code


      --------------------------------------- Retirements begin -------------------------------------------
      -- transaction information
      l_trans_rec.transaction_type_code := NULL;

      -- rmunjulu EDAT No need to set below date
      --IF  p_quote_accpt_date IS NOT NULL THEN -- rmunjulu EDAT
         --l_trans_rec.transaction_date_entered := p_quote_accpt_date; -- rmunjulu EDAT
      --ELSE
         l_trans_rec.transaction_date_entered := NULL;
      --END IF;

      --SECHAWLA 29-DEC-05 3827148 : added
      l_trans_rec.calling_interface  := 'OKL:'||'Asset Disposition:'||'RFA';


      -- header information
      l_asset_hdr_rec.asset_id := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_book_type_code; -- SECHAWLA 10-DEC-02 Bug # 2701440: changed the parameter name

      -- retirement information

      --  SECHAWLA 03-JUN-03 2999419 : Use the prorate convention set in Oracle Assets for this asset and book,
      --  instead of using the hard coded value of MID-MONTH
      --  l_asset_retire_rec.retirement_prorate_convention := 'MID-MONTH';
      l_asset_retire_rec.retirement_prorate_convention := p_prorate_convention;


      IF  p_quote_eff_date IS NOT NULL THEN -- rmunjulu EDAT
         l_asset_retire_rec.date_retired := p_quote_eff_date; -- rmunjulu EDAT
      ELSE
         l_asset_retire_rec.date_retired := NULL;
      END IF;

     -- l_asset_retire_rec.cost_retired := p_cost;
     --l_asset_retire_rec.units_retired := NULL;

      l_asset_retire_rec.units_retired := p_units;
      l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
      l_asset_retire_rec.cost_of_removal := 0;
      l_asset_retire_rec.retirement_type_code := 'SALE';
      l_asset_retire_rec.trade_in_asset_id := NULL;
      --akrangan changed calculate_gain_loss flag from FALSE to TRUE
      --to address FA enhancement beign
      l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;
      --akrangan changed ends here
      --SECHAWLA 13-JAN-03 Bug # 2701440 : calculate gain and loss should be set to TRUE if multiple partial retirements are performed on the same asset in the same period
      --l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;

      -- p_user_id must be properly set to run calc gain/loss
      --fnd_profile.put('USER_ID',p_user_id);

      l_asset_dist_tbl.DELETE;



      FA_RETIREMENT_PUB.do_retirement(  p_api_version       => p_api_version,
                                        p_init_msg_list     => OKC_API.G_FALSE,
                                        p_commit            => FND_API.G_FALSE,
                                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn        => NULL,
                                        x_return_status     => x_return_status,
                                        x_msg_count         => x_msg_count,
                                        x_msg_data          => x_msg_data,
                                        px_trans_rec        => l_trans_rec,
                                        px_dist_trans_rec   => l_dist_trans_rec,
                                        px_asset_hdr_rec    => l_asset_hdr_rec,
                                        px_asset_retire_rec => l_asset_retire_rec,
                                        p_asset_dist_tbl    => l_asset_dist_tbl,
                                        p_subcomp_tbl       => l_subcomp_tbl,
                                        p_inv_tbl           => l_inv_tbl);

       -- SECHAWLA Bug # 2701440  : Added this message
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
             --SECHAWLA 23-DEC-02 Bug # 2701440 : Added BOOK_CLASS token
             -- Error retiring asset ASSET_NUMBER in book BOOK. Retirement transaction was not performed for this asset in Fixed Assets.
             OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_RET_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'corporate',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_book_type_code);
             RAISE l_retire_error; --SECHAWLA 10-FEB-06 5016156
       ELSE -- 15-DEC-04 SECHAWLA 4028371  added else section
         x_fa_trx_date := l_trans_rec.transaction_date_entered;
       END IF;
       --akrangan added for sla populate sources cr start
         g_tran_tbl_idx := g_tran_tbl_idx + 1;
         g_trans_id_tbl(g_tran_tbl_idx) := l_trans_rec.transaction_header_id;
       --akrangan added for sla populate sources cr end

       -- x_return_status of the above procedure call becomes the x_return_status of the current procedure
       -- which is then handled in the calling procedure dispose_asset()

             --------------------------------------- Retirements end -------------------------------------------
   EXCEPTION
      --SECHAWLA 10-FEB-06 5016156
      WHEN l_adj_error THEN
           NULL;
      WHEN l_retire_error THEN
           NULL;

      WHEN OTHERS THEN

          -- unexpected error
          -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
          OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

   END do_full_units_retirement;

   -- Start of comments
   --
   -- Procedure Name  : do_partial_retirement
   -- Description     :  This procedure is used to partially retire an asset in FA if period_of_addition = 'N'
   --                    This procedure is called only for corporate book retirements
   -- Business Rules  :
   -- Parameters      :  p_asset_id   - asset id of the asset that is to be retired
   --                    p_asset_number - asset number
   --                    p_proceeds_of_sale - amount for which the asset is to be sold
   --                    p_book_type_code - corporate / tax book
   --                    p_total_quantity - units retired
   --                    p_dist_tbl - table of distribution Ids that are to be retired
   -- Version         : 1.0
   -- History         : SECHAWLA 10-DEC-02 Bug # 2701440
   --                     Changed the parameter name p_corporate_book to p_book_type_code
   --                   SECHAWLA 23-DEC-02 Bug # 2701440
   --                     Changed the procedure name from do_partial_retirement to do_partial_units_retirement
   --                     Added BOOK_CLASS token in messages.
   --                   SECHAWLA 16-JAN-03 Bug # 2754280
   --                     Changed the app name from OKL to OKC for g_unexpected_error
   --                   SECHAWLA 05-FEB-03 Bug # 2781557
   --                     Moved the logic to check if asset is added in the current open period, from this procedure
   --                     to dispose_asset procedure.
   --                   SECHAWLA 03-JUN-03 Bug # 2999419: Added a new parameter for retirement prorate convention which
   --                     contains the prorate convention value set in Oracle Assets for a particular asset and book
   --                   SECHAWLA 21-NOV-03 3262519: Added tax owner and delta cost parameter to this procedure
--                   rmunjulu EDAT Added 2 new parameters p_quote_eff_date and p_quote_accpt_date
--                      also set some dates with quote eff date and quote accpt date passed
--                   rmunjulu bug # 4480371
--                   SECHAWLA 10-FEB-06 5016156 raise error if adjustment transaction fails

   -- End of comments
   PROCEDURE do_partial_units_retirement(
                                p_api_version           IN   NUMBER,
                          p_init_msg_list         IN   VARCHAR2,
                                p_tax_owner             IN      VARCHAR2,
                                p_delta_cost            IN      NUMBER,
                                p_asset_id              IN      NUMBER,
                                p_asset_number          IN      VARCHAR2,
                                p_proceeds_of_sale      IN      NUMBER,
                             --   p_corporate_book        IN      VARCHAR2, --SECHAWLA Bug # 2701440
                                p_book_type_code        IN      VARCHAR2,
                                p_total_quantity        IN      NUMBER,
                                p_dist_tbl              IN      asset_dist_tbl,
                                p_prorate_convention    IN      VARCHAR2,       -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date           OUT     NOCOPY DATE,    -- SECHAWLA 15-DEC-04 4028371 : Added this parameter
                                x_msg_count             OUT  NOCOPY NUMBER,
                          x_msg_data              OUT  NOCOPY VARCHAR2,
                                x_return_status         OUT     NOCOPY VARCHAR2,
                                p_quote_eff_date        IN      DATE DEFAULT NULL, -- rmunjulu EDAT
                                p_quote_accpt_date      IN      DATE DEFAULT NULL  -- rmunjulu EDAT
                               )    IS



   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_dist_trans_rec             FA_API_TYPES.trans_rec_type;
   l_asset_retire_rec           FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl                FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                    FA_API_TYPES.inv_tbl_type;
   i                            NUMBER;

   -- SECHAWLA 21-NOV-03 3262519: New Declarations
   l_adj_trans_rec              FA_API_TYPES.trans_rec_type;
   l_adj_asset_hdr_rec          FA_API_TYPES.asset_hdr_rec_type;
   l_adj_inv_tbl                FA_API_TYPES.inv_tbl_type;
   l_asset_fin_rec_adj      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_rec_new      FA_API_TYPES.asset_fin_rec_type;
   l_asset_fin_mrc_tbl_new     FA_API_TYPES.asset_fin_tbl_type;

   l_inv_trans_rec          FA_API_TYPES.inv_trans_rec_type;
   l_asset_deprn_rec_adj     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_rec_new     FA_API_TYPES.asset_deprn_rec_type;
   l_asset_deprn_mrc_tbl_new FA_API_TYPES.asset_deprn_tbl_type;
   l_group_reclass_options_rec  FA_API_TYPES.group_reclass_options_rec_type;
   -- SECHAWLA 21-NOV-03 3262519: end

   --SECHAWLA 10-FEB-06 5016156
    l_adj_error     EXCEPTION;
    l_retire_error              EXCEPTION;

   BEGIN

      -- All the input parameterd to this procedure will definitely have not-null values, as these are required
      -- columns of okx_asset_liens_v

      x_return_status := okl_api.G_RET_STS_SUCCESS;

      -- SECHAWLA 21-NOV-03 3262519 : update the corporate book with residual value as asset cost
      ---------------------------------------  Adjustments begin-------------------------------------------

      -- p_tax_owner will have a value only if the contract is on direct finance or sales type of lease
       IF p_tax_owner IN ('LESSOR','LESSEE') THEN
         IF p_delta_cost <> 0 THEN --SECHAWLA 15-DEC-04 Bug # 4028371 : added this condition
          --update the tax asset book with residual value as asset cost

          l_adj_trans_rec.transaction_subtype := 'AMORTIZED';
          l_adj_asset_hdr_rec.asset_id :=  p_asset_id;
          l_adj_asset_hdr_rec.book_type_code := p_book_type_code;
          l_asset_fin_rec_adj.cost := p_delta_cost;

          -- rmunjulu EDAT -- Set new parameters with dates ------ start +++++++
          IF  p_quote_accpt_date IS NOT NULL
          AND p_quote_eff_date IS NOT NULL THEN

             l_adj_trans_rec.transaction_date_entered := p_quote_eff_date; -- rmunjulu bug # 4480371 p_quote_accpt_date; -- rmunjulu EDAT

             -- rmunjulu EDAT No need to set below dates
             --l_asset_fin_rec_adj.deprn_start_date := p_quote_eff_date; -- rmunjulu EDAT
             --l_asset_fin_rec_adj.prorate_date := p_quote_eff_date;     -- rmunjulu EDAT

          END IF;
          -- rmunjulu EDAT -- Set new parameters with dates ------ end   +++++++

          fa_adjustment_pub.do_adjustment(
                                            p_api_version              => p_api_version,
                                      p_init_msg_list            => OKC_API.G_FALSE,
                                      p_commit                   => FND_API.G_FALSE,
                                      p_validation_level         => FND_API.G_VALID_LEVEL_FULL,
                                      p_calling_fn               => NULL,
                                      x_return_status            => x_return_status,
                                      x_msg_count                => x_msg_count,
                                      x_msg_data                 => x_msg_data,
                                      px_trans_rec               => l_adj_trans_rec,
                                      px_asset_hdr_rec           => l_adj_asset_hdr_rec,
                                      p_asset_fin_rec_adj        => l_asset_fin_rec_adj,
                                      x_asset_fin_rec_new        => l_asset_fin_rec_new,
                                      x_asset_fin_mrc_tbl_new    => l_asset_fin_mrc_tbl_new,
                                      px_inv_trans_rec           => l_inv_trans_rec,
                                      px_inv_tbl                 => l_adj_inv_tbl,
                                       p_asset_deprn_rec_adj      => l_asset_deprn_rec_adj,
                                      x_asset_deprn_rec_new      => l_asset_deprn_rec_new,
                                      x_asset_deprn_mrc_tbl_new  => l_asset_deprn_mrc_tbl_new,
                                            p_group_reclass_options_rec => l_group_reclass_options_rec);

          IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

                -- Error updating asset cost for asset ASSET_NUMBER in BOOK_CLASS book BOOK.
                OKC_API.set_message(    p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_ADJ_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'corporate',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_book_type_code);
                RAISE l_adj_error; --SECHAWLA 10-FEB-06 5016156
          END IF;
         --akrangan added for sla populate sources cr start
         g_tran_tbl_idx := g_tran_tbl_idx + 1;
         --akrangan fix for bug 6409121 begin
         --changed l_trans_rec to l_adj_trans_rec which is passed to the FA api as input
         --corrected the wrong assignment
         g_trans_id_tbl(g_tran_tbl_idx) := l_adj_trans_rec.transaction_header_id;
         --akrangan fix for bug 6409121 end
         --akrangan added for sla populate sources cr end
        END IF;
      END IF;
      ---------------------------------------  Adjustments End -------------------------------------------
      -- SECHAWLA 21-NOV-03 3262519 : end new code


      --------------------------------------- Retirement  Begin ------------------------------------------
      -- transaction information
      l_trans_rec.transaction_type_code := NULL;

      -- rmunjulu EDAT No need to set below date
      --IF  p_quote_accpt_date IS NOT NULL THEN -- rmunjulu EDAT
         --l_trans_rec.transaction_date_entered := p_quote_accpt_date; -- rmunjulu EDAT
      --ELSE
         l_trans_rec.transaction_date_entered := NULL;
      --END IF;

      --SECHAWLA 29-DEC-05 3827148 : added
      l_trans_rec.calling_interface  := 'OKL:'||'Asset Disposition:'||'RFA';


      -- header information
      l_asset_hdr_rec.asset_id := p_asset_id;
      l_asset_hdr_rec.book_type_code := p_book_type_code;  --SECHAWLA Bug # 2701440 : changed the parameter name

      -- retirement information

      --  SECHAWLA 03-JUN-03 2999419: Use the prorate convention set in Oracle Assets for this asset and book,
      --  instead of using the hard coded value of MID-MONTH
      --  l_asset_retire_rec.retirement_prorate_convention := 'MID-MONTH';
      l_asset_retire_rec.retirement_prorate_convention := p_prorate_convention;


      IF  p_quote_eff_date IS NOT NULL THEN -- rmunjulu EDAT
         l_asset_retire_rec.date_retired := p_quote_eff_date; -- rmunjulu EDAT
      ELSE
         l_asset_retire_rec.date_retired := NULL;
      END IF;
      l_asset_retire_rec.units_retired := p_total_quantity;
     -- l_asset_retire_rec.cost_retired := p_cost;
      l_asset_retire_rec.proceeds_of_sale := p_proceeds_of_sale;
      l_asset_retire_rec.cost_of_removal := 0;
      l_asset_retire_rec.retirement_type_code := 'SALE';
      l_asset_retire_rec.trade_in_asset_id := NULL;
      --akrangan changed calculate_gain_loss flag from FALSE to TRUE
      --to address FA enhancement beign
      l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;
      --akrangan changed ends here
      --SECHAWLA 13-JAN-03 Bug # 2701440 : calculate gain and loss should be set to TRUE if multiple partial retirements are performed on the same asset in the same period
      --l_asset_retire_rec.calculate_gain_loss := FND_API.G_TRUE;

      -- p_user_id must be properly set to run calc gain/loss
      --fnd_profile.put('USER_ID',p_user_id);

      l_asset_dist_tbl.DELETE;



      IF p_dist_tbl.COUNT > 0 THEN
        i := p_dist_tbl.FIRST ;
        -- Loop thru all the distributions that are to be retired and assign them to l_asset_dist_tbl
        LOOP
           l_asset_dist_tbl(i+1).distribution_id := p_dist_tbl(i).p_distribution_id;
           l_asset_dist_tbl(i+1).transaction_units := -(p_dist_tbl(i).p_units_assigned);
           l_asset_dist_tbl(i+1).units_assigned := NULL;
        l_asset_dist_tbl(i+1).assigned_to := NULL;
        l_asset_dist_tbl(i+1).expense_ccid := NULL;
        l_asset_dist_tbl(i+1).location_ccid := NULL;

           EXIT WHEN (i = p_dist_tbl.LAST);
           i := p_dist_tbl.NEXT(i);
        END LOOP;
      END IF;


      FA_RETIREMENT_PUB.do_retirement(  p_api_version       => p_api_version,
                                        p_init_msg_list     => OKC_API.G_FALSE,
                                        p_commit            => FND_API.G_FALSE,
                                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn        => NULL,
                                        x_return_status     => x_return_status,
                                        x_msg_count         => x_msg_count,
                                        x_msg_data          => x_msg_data,
                                        px_trans_rec        => l_trans_rec,
                                        px_dist_trans_rec   => l_dist_trans_rec,
                                        px_asset_hdr_rec    => l_asset_hdr_rec,
                                        px_asset_retire_rec => l_asset_retire_rec,
                                        p_asset_dist_tbl    => l_asset_dist_tbl,
                                        p_subcomp_tbl       => l_subcomp_tbl,
                                        p_inv_tbl           => l_inv_tbl);

       -- SECHAWLA Bug # 2701440  : Added this message
       IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN

          --SECHAWLA 23-DEC-02 Bug # 2701440 : Added BOOK_CLASS token
          -- Error retiring asset ASSET_NUMBER in book BOOK. Retirement transaction was not performed for this asset in Fixed Assets.
           OKC_API.set_message(  p_app_name      => 'OKL',
                                  p_msg_name      => 'OKL_AM_RET_TRANS_FAILED',
                                  p_token1        =>  'ASSET_NUMBER',
                                  p_token1_value  =>  p_asset_number,
                                  p_token2        =>  'BOOK_CLASS',
                                  p_token2_value  =>  'corporate',
                                  p_token3        =>  'BOOK',
                                  p_token3_value  =>  p_book_type_code);
            RAISE l_retire_error; --SECHAWLA 10-FEB-06 5016156
       ELSE -- 15-DEC-04 SECHAWLA 4028371  added else section
        x_fa_trx_date := l_trans_rec.transaction_date_entered;
       END IF;
         --akrangan added for sla populate sources cr start
         g_tran_tbl_idx := g_tran_tbl_idx + 1;
         g_trans_id_tbl(g_tran_tbl_idx) := l_trans_rec.transaction_header_id;
         --akrangan added for sla populate sources cr end


       -- x_return_status of the above procedure call becomes the x_return_status of the current procedure
       -- which is then handled in the calling procedure dispose_asset()

       --------------------------------------- Retirements end ------------------------------------------
  EXCEPTION
      --SECHAWLA 10-FEB-06 5016156
      WHEN l_adj_error THEN
           NULL;
      WHEN l_retire_error THEN
           NULL;

      WHEN OTHERS THEN

          -- unexpected error
          -- SECHAWLA 16-JAN-03 Bug # 2754280 : Changed the app name from OKL to OKC
          OKL_API.set_message(
                         p_app_name      => 'OKC',
                         p_msg_name      => g_unexpected_error,
                         p_token1        => g_sqlcode_token,
                         p_token1_value  => sqlcode,
                         p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
          x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

   END do_partial_units_retirement;


   -- Start of comments
   --
   -- Procedure Name  :  dispose_asset
   -- Description     :  This procedure is used to retire an asset in FA. It checks if the asset is to be fully or
   --                    partially retired , based upon the p_quantity parameter and then calls the appropriate routine to
   --                    retire the asset. It then stores the disposition transactions in OKL tables, calls accounting
   --                    engine and then finally cancels all pending transactions in OKL tables for this asset.
   -- Business Rules  :
   -- Parameters      :  p_financial_asset_id   - Financial asset id(kle_id) of the asset that is to be retired
   --                    p_quantity - units that are to be retired (optional)
   --                    p_proceeds_of_sale - amount for which the asset is to be sold
   --
   -- Version         :  1.0
   -- History         :  SECHAWLA 10-DEC-02 Bug # 2701440
   --                      Modified CURSOR l_okxassetlines_csr to select all the tax books that an asset belongs to,
   --                      in addition to the Fixed Asset Information.
   --                    SECHAWLA 23-DEC-02 Bug # 2701440
   --                      Modified logic to perform cost retirement instead of unit retirement for tax books
   --                    SECHAWLA 03-JAN-03 Bug # 2683876
   --                      Modified logic to send currency code while creating/updating amounts columns in txl assets
   --                    SECHAWLA 13-JAN-03 Bug # 2701440 Modified logic to perform :
   --                      1) full tax book retirement when the corporate book gets fully retired. This is to
   --                      take care of the scenario where tax book cost is more than the corporate book cost
   --                      2) full tax book retirement when the corp book is not fully retired but tax book does not
   --                      have enough cost. This takes care of the scenario where tax book cost is less than the corp book cost
   --                    SECHAWLA 05-FEB-03 Bug # 2781557
   --                      Moved the logic to check if the asset was added in the current open period, from individual cost and unit
   --                      retirement procedures to this procedure.
   --                    SECHAWLA 11-MAR-03
   --                      assumed 0 amount for proceeds of sale, if null. Allowed negative values for proceeds of sale
   --                    SECHAWLA 03-JUN-03 2999419: Use the retirement prorate convention set in Oracle
   --                      Assets for a particular asset and book, instead of using the constant value "MID-MONTH"
   --                    RMUNJULU 11-SEP-03 3061751 Added code for SERVICE_K_INTEGRATION
   --                    SECHAWLA 21-NOV-03 3262519 Update the asset cost with residual value, for DF and Sales lease,
   --                      before retiring the asset
   --                    rmunjulu EDAT
   --                     Added 2 new parameters and Changed code to
   --                     1. set date trn occured as quote eff date
   --                     2. set disposal accounting date as quote acceptance date
   --                     3. set service k notification date as quote eff date
   --                     4. expire item in IB date as quote eff date
   --                     5. set trn date as quote eff date to full units retirement
   --                     6. set trn date as quote eff date to partial untis retirement
   --                     7. set trn date as quote eff date to cost retirement
   --                    rmunjulu EDAT 23-Nov-04 Set back IB End date as sysdate
   --                    rmunjulu EDAT 10-Jan-05 Pass quote eff date and quote accpt date to adjust/retire proc
   --                    girao 18-Jan-2005 4106216 NVL the residual value in l_linesfullv_csr
   --                    SECHAWLA 10-FEB-06 5016156 In case of termination w/o purchase, asset cost should
   --                           be updated with NIV (not RV), through Off-lease transactions
   --                    rbruno 04-sep-07 bug 5436987 Adjustment transaction should have amount in functional currency
   --
   --
   -- End of comments
   PROCEDURE dispose_asset (     p_api_version           IN   NUMBER,
                                 p_init_msg_list         IN   VARCHAR2,
                                 x_return_status         OUT  NOCOPY VARCHAR2,
                                 x_msg_count             OUT  NOCOPY NUMBER,
                                 x_msg_data              OUT  NOCOPY VARCHAR2,
                                 p_financial_asset_id    IN      NUMBER,
                                 p_quantity              in      number,
                                 p_proceeds_of_sale      in      number,
                                 p_quote_eff_date        in      date default null, -- rmunjulu edat
                                 p_quote_accpt_date      in      date default null, -- rmunjulu edat
                                 p_legal_entity_id       in      number  -- rravikir legal entity changes
                                    ) IS

   SUBTYPE   thpv_rec_type   IS  OKL_TRX_ASSETS_PUB.thpv_rec_type;
   SUBTYPE   tlpv_rec_type   IS  OKL_TXL_ASSETS_PUB.tlpv_rec_type;



   -- SECHAWLA Bug # 2701440  :
   -- Modified this cursor to select all the tax books that an asset belongs to, in addition to the Fixed Asset Information

   --SECHAWLA 23-DEC-02 Bug # 2701440
   --Added Order By clause to select CORPORATE Book first

   --SECHAWLA 13-JAN-03 Bug # 2701440
   --Changed the cursor to select cost columns from fa_books instead of okx_asset_lines_v, as the latter has info for corporate book only

   --SECHAWLA 03-JUN-03 Bug # 2999419
   --Added prorate_convention_code to the Select clause
   CURSOR l_okxassetlines_csr IS
   SELECT o.asset_id, o.asset_number, o.corporate_book, a.cost, o.depreciation_category, a.original_cost, o.current_units,
          o.dnz_chr_id ,a.book_type_code, b.book_class, prorate_convention_code
   FROM   okx_asset_lines_v o, fa_books a, fa_book_controls b
   WHERE  o.parent_line_id = p_financial_asset_id
   AND    o.asset_id = a.asset_id
   AND    a.book_type_code = b.book_type_code
   AND    a.date_ineffective IS NULL
   AND    a.transaction_header_id_out IS NULL
   ORDER BY book_class;


   --SECHAWLA 23_DEC-02 Bug # 2701440 : Added this cursor to get the cost retired, populated after the retirement of
   -- asset from the corporate book. We need this cost to perform cost retirement of the same asset in the TAX book

   /* SECHAWLA 21-NOV-03 3262519 : This curosr is not required. Cost to be retired from the tax book should be
   -- calculated using tax book cost and not the corporate book cost, as teh 2 costs can be different

   --SECHAWLA 13-JAN-03 Bug # 2701440 : Added Order By Clause to select the latest retirement record first
   CURSOR l_faretirement_csr(p_asset_id IN NUMBER, p_book_type_code IN VARCHAR2) IS
   SELECT cost_retired
   FROM   fa_retirements
   WHERE  asset_id = p_asset_id
   AND    book_type_code = p_book_type_code
   ORDER  BY last_update_date DESC;
  */

   --This cursor is used to get all the active distributions for an asset
   CURSOR l_disthist_csr(p_asset_id NUMBER, p_book_type_code VARCHAR2) IS
   SELECT distribution_id, units_assigned, retirement_id, transaction_units
   FROM   fa_distribution_history
   WHERE  asset_id = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    date_ineffective IS NULL
   AND    transaction_header_id_out IS NULL
  -- AND    retirement_id IS NULL
   ORDER  BY last_update_date;

   -- This cursor is used to get all the pending transactions for an asset. These transactions are to be calcelled
   -- once the asset is retired.
   CURSOR l_assettrx_csr IS
   SELECT h.id
   FROM   OKL_TRX_ASSETS h, okl_txl_assets_v l
   WHERE  h.id = l.tas_id
   AND    h.tsu_code  IN  ('ENTERED', 'ERROR')
   AND    l.kle_id = p_financial_asset_id;

   -- This curosr is used to get all the instances for a Financial asset
   --Changed query to use base tables instead uv for performance
   CURSOR l_itemlocation_csr IS
   SELECT cii.instance_id instance_id, cii.active_end_date instance_end_date
     FROM okc_k_headers_b okhv,
          okc_k_lines_b kle_fa,
          okc_k_lines_tl klet_fa,
          okc_line_styles_b lse_fa,
          okc_k_lines_b kle_il,
          okc_line_styles_b lse_il,
          okc_k_lines_b kle_ib,
          okc_line_styles_b lse_ib,
          okc_k_items ite,
          csi_item_instances cii
    WHERE kle_fa.id = klet_fa.id
    AND klet_fa.language = USERENV('LANG')
    AND kle_fa.chr_id = okhv.id AND lse_fa.id = kle_fa.lse_id
    AND lse_fa.lty_code = 'FREE_FORM1'
    AND kle_il.cle_id = kle_fa.id
    AND lse_il.id = kle_il.lse_id
    AND lse_il.lty_code = 'FREE_FORM2'
    AND kle_ib.cle_id = kle_il.id
    AND lse_ib.id = kle_ib.lse_id
    AND lse_ib.lty_code = 'INST_ITEM'
    AND ite.cle_id = kle_ib.id
    AND ite.jtot_object1_code = 'OKX_IB_ITEM'
    AND cii.instance_id = ite.object1_id1
    AND kle_fa.id = p_financial_asset_id;

   -- This cursor is used to find out the period_of_addtion for the asset that is to be retired
   CURSOR l_periodofaddition_csr(p_asset_id NUMBER, p_book_type_code VARCHAR2, p_period_open_date DATE)  IS
   SELECT count(*)
   FROM   fa_transaction_headers th
   WHERE  th.asset_id              = p_asset_id
   AND    th.book_type_code        = p_book_type_code
   AND    th.transaction_type_code = 'ADDITION'
   AND    th.date_effective > p_period_open_date;

   -- This cursor is used temporarily to get the fiscal year name till FA API is fixed
   CURSOR l_bookcontrols_csr(p_book_type_code VARCHAR2) IS
   SELECT fiscal_year_name
   FROM   fa_book_controls
   WHERE  book_type_code = p_book_type_code;


   --SECHAWLA 21-NOV-2003 3262519 : Added the following cursors

   -- validate the financial asset id
   CURSOR l_okclines_csr(p_financial_asset_id IN NUMBER) IS
   SELECT 'x'
   FROM   okc_k_lines_b cle, okc_line_styles_b lse
   WHERE  cle.lse_id = lse.id
   AND    lse.lty_code = 'FREE_FORM1'
   AND    cle.id = p_financial_asset_id;

   -- get the deal type from the contract
   CURSOR l_dealtype_csr(p_financial_asset_id IN NUMBER) IS
   SELECT lkhr.id, lkhr.deal_type, khr.contract_number
   FROM   okl_k_headers lkhr, okc_k_lines_b cle, okc_k_headers_b khr
   WHERE  khr.id = cle.chr_id
   AND    lkhr.id = khr.id
   AND    cle.id = p_financial_asset_id;

   -- get the residual value for the fin asset
   CURSOR l_linesfullv_csr(p_fin_asset_id IN NUMBER) IS
   SELECT name, NVL(residual_value,0) -- girao Bug 4106216 NVL the residual value
   FROM   okl_k_lines_full_v
   WHERE  id = p_fin_asset_id;

   --SECHAWLA 10-FEB-06 5016156 : begin
   CURSOR l_offlseassettrx_csr(cp_trx_date IN DATE, cp_asset_number IN VARCHAR2) IS
   SELECT h.tsu_code, h.tas_type,  h.date_trans_occurred, l.dnz_asset_id,
          l.asset_number, l.kle_id ,l.DNZ_KHR_ID
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l
   WHERE  h.id = l.tas_id
   AND    h.date_trans_occurred <= cp_trx_date
   AND    h.tas_type in ('AMT','AUD','AUS')
   AND    l.asset_number = cp_asset_number;

   l_trx_status         VARCHAR2(30);
   --SECHAWLA 10-FEB-06 5016156 : end

   l_deal_type          VARCHAR2(30);
   l_chr_id             NUMBER;
   l_dummy              VARCHAR2(1);
   l_contract_number    VARCHAR2(120);
   l_rulv_rec           okl_rule_pub.rulv_rec_type;
   l_tax_owner          VARCHAR2(10);
   l_delta_cost         NUMBER;
   l_residual_value     NUMBER;
   l_name               VARCHAR2(150);
   l_cost               NUMBER;
   --SECHAWLA 21-NOV-2003 3262519 : end new declarations


   l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_tsu_code                   VARCHAR2(30);
   l_try_id             OKL_TRX_TYPES_V.id%TYPE;
   lp_thpv_rec                  thpv_rec_type;
   lp_thpv_empty_rec            thpv_rec_type;
   lp_tlpv_empty_rec            tlpv_rec_type;
   lx_thpv_rec                  thpv_rec_type;
   lp_tlpv_rec           tlpv_rec_type;
   lx_tlpv_rec           tlpv_rec_type;
   l_sys_date                   DATE;
   l_api_version                CONSTANT NUMBER := 1;
   l_trx_type                   VARCHAR2(30) := 'Asset Disposition';
   l_trx_name                   VARCHAR2(30) := 'ASSET_DISPOSITION';
   l_api_name                   CONSTANT VARCHAR2(30) := 'dispose_asset';


   l_dist_quantity              NUMBER;
   l_dist_tbl                   asset_dist_tbl   ;
   i                            NUMBER;
   l_retired_quantity           NUMBER;
   instance_counter             NUMBER;
   l_quantity                   NUMBER;
   l_already_retired            VARCHAR2(1):= 'N';
   l_remaining_units            NUMBER;
   l_active_end_date            DATE;
   l_retired_dist_units         NUMBER;
   l_units_to_be_retired        NUMBER;
   l_non_retired_quantity       NUMBER;
   lx_total_amount              NUMBER;
   l_units_retired              NUMBER;

   --SECHAWLA 23-DEC-02 Bug # 2701440: new declarations
   l_cost_retired               NUMBER;

   --SECHAWLA 03-JAN-03 Bug # 2683876 : new declaration
   l_func_curr_code             GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;

   --SECHAWLA 05-FEB-03 Bug # 2781557 : new declarations
   l_fiscal_year_name           VARCHAR2(30);
   l_period_rec                 FA_API_TYPES.period_rec_type;
   l_count                      NUMBER;
   l_period_of_addition         VARCHAR2(1);

   --SECHAWLA 11-MAR-03 New Declarations
   l_proceeds_of_sale           NUMBER ;

    -- RMUNJULU 3061751
    l_service_int_needed VARCHAR2(1) := 'N';

    -- rmunjulu EDAT
    l_quote_eff_date DATE;
    l_quote_accpt_date DATE;

    --SECHAWLA  15-DEC-04  4028371 New Declarations
   l_fa_trx_date    DATE;

    -- rbruno bug 5436987 start
     l_functional_currency_code VARCHAR2(15);
     l_contract_currency_code VARCHAR2(15);
     l_currency_conversion_type VARCHAR2(30);
     l_currency_conversion_rate NUMBER;
     l_currency_conversion_date DATE;
     l_converted_amount NUMBER;

     -- rbruno bug 5436987
     -- Since we do not use the amount or converted amount
     -- set a hardcoded value for the amount (and pass to to
     -- OKL_ACCOUNTING_UTIL.convert_to_functional_currency and get back
     -- conversion values )
     l_hard_coded_amount NUMBER := 100;
  --rbruno bug 5436987 end



   --akrangan sla populate sources cr start
      l_fxhv_rec         okl_fxh_pvt.fxhv_rec_type;
      l_fxlv_rec         okl_fxl_pvt.fxlv_rec_type;
   --akrangan sla populate sources cr end


   BEGIN

      l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- Get the sysdate
      SELECT SYSDATE INTO l_sys_date FROM DUAL;

      -- rmunjulu EDAT Added condition to default
      IF  p_quote_eff_date IS NOT NULL
      AND p_quote_eff_date <> OKL_API.G_MISS_DATE THEN

         l_quote_eff_date := p_quote_eff_date;

      ELSE

         l_quote_eff_date := l_sys_date;

      END IF;

      -- rmunjulu EDAT Added condition to default
      IF  p_quote_accpt_date IS NOT NULL
      AND p_quote_accpt_date <> OKL_API.G_MISS_DATE THEN

         l_quote_accpt_date := p_quote_accpt_date;

      ELSE

         l_quote_accpt_date := l_sys_date;

      END IF;

      IF p_financial_asset_id IS NULL OR p_financial_asset_id = OKL_API.G_MISS_NUM THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Finacial Asset id is a required parameter
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'FINANCIAL_ASSET_ID');


            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      -- RRAVIKIR Legal Entity Changes
      IF (p_legal_entity_id is null or p_legal_entity_id = OKC_API.G_MISS_NUM) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'legal_entity_id');
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      -- Legal Entity Changes End

      --SECHAWLA 21-NOV-2003 3262519 : Added the following validation
      OPEN  l_okclines_csr(p_financial_asset_id );
      FETCH l_okclines_csr INTO l_dummy;
      IF  l_okclines_csr%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Finacial Asset id is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'FINANCIAL_ASSET_ID');

            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_okclines_csr;
      --SECHAWLA 21-NOV-2003 3262519 : end


      -- SECHAWLA 11-MAR-03 : assign 0 to l_proceeds_of_sale if NULL
      l_proceeds_of_sale := p_proceeds_of_sale ;

      IF l_proceeds_of_sale IS NULL OR l_proceeds_of_sale = OKL_API.G_MISS_NUM THEN
            l_proceeds_of_sale := 0;
            /*
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- proceeds_of_sale is required
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'PROCEEDS_OF_SALE');


            RAISE OKC_API.G_EXCEPTION_ERROR;
           */
      END IF;

      -- SECHAWLA 11-MAR-03 : Allow negative amount
      /*
      IF p_proceeds_of_sale < 0 THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- proceeds_of_sale is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'PROCEEDS_OF_SALE');


            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      */

      IF p_quantity IS NOT NULL THEN
         IF p_quantity < 0 THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Quantity is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'QUANTITY');


            RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
         IF trunc(p_quantity) <> p_quantity THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Units retired should be a whole number.
            OKC_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_WHOLE_UNITS_ERR');
           RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
      END IF;

   --SECHAWLA 21-NOV-2003 3262519 : Added the following  code to get the deal type and tax owner

   -- get the deal type from the contract
   OPEN  l_dealtype_csr(p_financial_asset_id);
   FETCH l_dealtype_csr INTO l_chr_id, l_deal_type, l_contract_number;
   IF  l_dealtype_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
       -- chr id is invalid
       OKC_API.set_message(     p_app_name      => 'OKC',
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'CHR_ID');

       RAISE OKC_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_dealtype_csr;

   IF l_deal_type IN ('LEASEDF','LEASEST') THEN
      -- get the tax owner (LESSOR/LESSEE) for the contract

         okl_am_util_pvt.get_rule_record(p_rgd_code         => 'LATOWN'
                                     ,p_rdf_code         =>'LATOWN'
                                     ,p_chr_id           => l_chr_id
                                     ,p_cle_id           => NULL
                                     ,x_rulv_rec         => l_rulv_rec
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

         IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;

         -- check if tax owner is defined
         IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- tax owner is not defined for contract CONTRACT_NUMBER.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_TAX_OWNER',
                                     p_token1        => 'CONTRACT_NUMBER',
                                     p_token1_value  => l_contract_number);
               RAISE OKC_API.G_EXCEPTION_ERROR;

          ELSE
               -- l_rulv_rec.RULE_INFORMATION1 will contain the value 'LESSEE' or 'LESSOR'
               l_tax_owner := l_rulv_rec.RULE_INFORMATION1;
          END IF;

          -- get the residual value of the fin asset
          OPEN  l_linesfullv_csr(p_financial_asset_id);
          FETCH l_linesfullv_csr INTO l_name, l_residual_value;
          CLOSE l_linesfullv_csr;

          IF l_residual_value IS NULL THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- Residual value is not defined for the asset
             OKC_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_RESIDUAL_VALUE',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);


             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;

          -- rbruno 5436987 -- start
          l_contract_currency_code :=  OKL_AM_UTIL_PVT.get_chr_currency(l_chr_id);
          l_functional_currency_code :=  OKL_AM_UTIL_PVT.get_functional_currency;

          -- currency codes different so need for conversion
          IF l_contract_currency_code <> l_functional_currency_code THEN

             -- convert the residual value obtained to functional currency
             OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	          => l_chr_id,
                     p_to_currency   		      => l_functional_currency_code,
                     p_transaction_date 		  => l_quote_eff_date,
                     p_amount 			          => l_residual_value, -- convert residual value from Contract to Functional currency
                     x_return_status              => l_return_status,
                     x_contract_currency		  => l_contract_currency_code,
                     x_currency_conversion_type	  => l_currency_conversion_type,
                     x_currency_conversion_rate	  => l_currency_conversion_rate,
                     x_currency_conversion_date	  => l_currency_conversion_date,
                     x_converted_amount 		  => l_converted_amount);

             l_residual_value := l_converted_amount; -- residual value is now converted to functional currency

          END IF;
          --rbruno 5436987 -- End


          IF l_residual_value < 0 THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- Residual value is negative for the asset
             OKC_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_INVALID_RESIDUAL',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);


             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
     END IF;



     --SECHAWLA 21-NOV-2003 3262519 : end new code


    -- SECHAWLA Bug # 2701440  : Changed OPEN, FETCH to a curosr FOR LOOP, as this cursor now has multiple rows
    -- for a given asset id : one row for the corporate book and one or more rows for the tax books
    FOR l_okxassetlines_rec IN l_okxassetlines_csr LOOP

          --SECHAWLA 21-NOV-2003 3262519 : calculate delta cost for this book class (corporate / tax)
          IF l_deal_type IN ('LEASEDF','LEASEST') THEN


             --SECHAWLA 10-FEB-06 5016156  Check if any off-lease transactions exist for the asset
             -- This will tell if it is termination with purchase or without purchase
             l_trx_status := NULL;
             FOR  l_offlseassettrx_rec IN l_offlseassettrx_csr(l_quote_eff_date, l_name) LOOP
         l_trx_status := l_offlseassettrx_rec.tsu_code;
         IF l_trx_status IN ('ENTERED','ERROR','CANCELED') THEN
            EXIT;
         END IF;
    END LOOP;

             IF l_trx_status IS NULL THEN -- This means off-lease trx don't exist. It is termination with purchase
             --SECHAWLA 10-FEB-06 5016156: end
                l_delta_cost := l_residual_value - l_okxassetlines_rec.cost;
             --SECHAWLA 10-FEB-06 5016156 : begin
             ELSIF l_trx_status IN ('ENTERED','ERROR') THEN -- if any trx has this status
                   x_return_status := OKL_API.G_RET_STS_ERROR;
                   OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_PENDING_OFFLEASE',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);


                   RAISE OKC_API.G_EXCEPTION_ERROR;


             ELSIF l_trx_status IN ( 'PROCESSED','CANCELED') THEN
                   l_delta_cost := 0; -- no cost update required, as cost has already been updated thru off lease trx
             END IF;                  -- or off-lease trx has been canceled
             --SECHAWLA 10-FEB-06 5016156 : end

          END IF;
          --SECHAWLA 21-NOV-2003 3262519 :  end


        --SECHAWLA 05-FEB-03 Bug # 2781557 : Moved the following code from do_full_units_retirement, as the check
        -- whether the asset is added in the current open period, needs to be done at this stage.

        -- This piece of code is included temporarily as a work around , since FA API has errors
        -- Set the Fiscal Year name in teh cache,if not already set
  --    IF fa_cache_pkg.fazcbc_record.fiscal_year_name IS NULL THEN
        OPEN  l_bookcontrols_csr(l_okxassetlines_rec.book_type_code);
        FETCH l_bookcontrols_csr INTO l_fiscal_year_name;
        IF l_bookcontrols_csr%NOTFOUND OR l_fiscal_year_name IS NULL THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Fiscal Year Name is required
            OKC_API.set_message( p_app_name      => 'OKC',
                               p_msg_name      => G_REQUIRED_VALUE,
                               p_token1        => G_COL_NAME_TOKEN,
                               p_token1_value  => 'Fiscal Year Name');


            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        CLOSE l_bookcontrols_csr;
        fa_cache_pkg.fazcbc_record.fiscal_year_name := l_fiscal_year_name;
  --    END IF;


        IF NOT FA_UTIL_PVT.get_period_rec
             (
              p_book           => l_okxassetlines_rec.book_type_code,
              p_effective_date => NULL,
              x_period_rec     => l_period_rec
             ) THEN

            x_return_status := OKC_API.G_RET_STS_ERROR;
            --Error getting current open period for the book BOOK_TYPE_CODE.
            OKL_API.set_message(
                         p_app_name      => 'OKL',
                         p_msg_name      => 'OKL_AM_OPEN_PERIOD_ERR',
                         p_token1        => 'BOOK_CLASS',
                         p_token1_value  => lower(l_okxassetlines_rec.book_class),
                         p_token2        => 'BOOK_TYPE_CODE',
                         p_token2_value  => l_okxassetlines_rec.book_type_code
                         );


            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --- check period of addition. If 'N' then run retirements
        OPEN  l_periodofaddition_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code,l_period_rec.period_open_date);
        FETCH l_periodofaddition_csr INTO l_count;
        CLOSE l_periodofaddition_csr;

        IF (l_count <> 0) THEN
            l_period_of_addition := 'Y';
        ELSE
            l_period_of_addition := 'N';
        END IF;

        IF l_period_of_addition = 'Y' THEN
           -- Can nor retire asset ASSET_NUMBER as the asset was added to the  book
          -- in the current open period. Please retire the asset manually.
             x_return_status := OKC_API.G_RET_STS_ERROR;

             OKL_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RETIRE_MANUALLY',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  =>  l_okxassetlines_rec.asset_number,
                                     p_token2        =>  'BOOK_CLASS',
                                     p_token2_value  =>  lower(l_okxassetlines_rec.book_class),
                                     p_token3        =>  'BOOK_TYPE_CODE',
                                     p_token3_value  =>  l_okxassetlines_rec.book_type_code);

             RAISE OKC_API.G_EXCEPTION_ERROR;

         END IF;
         /* ansethur for bug 5664106 -- start
         -- SECHAWLA 03-JUN-03 Bug 2999419: Added the following validation
         IF l_okxassetlines_rec.prorate_convention_code IS NULL THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              -- Unable to find retirement prorate convention for asset ASSET_NUMBER and book BOOK_TYPE_CODE.
              OKC_API.set_message(     p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_NO_PRORATE_CONVENTION',
                              p_token1        => 'ASSET_NUMBER',
                              p_token1_value  => l_okxassetlines_rec.asset_number,
                              p_token2        => 'BOOK_CLASS',
                              p_token2_value  => l_okxassetlines_rec.book_class,
                              p_token3        => 'BOOK_TYPE_CODE',
                              p_token3_value  => l_okxassetlines_rec.book_type_code);
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -- SECHAWLA 03-JUN-03 Bug 2999419 : end new code
          */ -- ansethur for bug 5655545 - end


         ----------    SECHAWLA 05-FEB-03 Bug # 2781557 : end moved code    ----------------


        IF p_quantity IS NULL OR p_quantity = OKL_API.G_MISS_NUM OR p_quantity = l_okxassetlines_rec.current_units THEN
           -- user sent request for full retirement

           -- check if asset has already been fully/partially retired .
           l_retired_quantity := 0;
           l_non_retired_quantity := 0;

           --This FOR loop will be executed only for the corporate book, as tax books do not have any distributions
           -- loop thru all the retirement records for this asset and calculate the total retired quantity
           FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
              IF l_disthist_rec.retirement_id IS NOT NULL THEN
                 l_retired_quantity := l_retired_quantity + abs(l_disthist_rec.transaction_units);
              ELSE
                 l_non_retired_quantity := l_non_retired_quantity + l_disthist_rec.units_assigned;
              END IF;
           END LOOP;

           --For TAX books, both l_retired_quantity and l_non_retired_quantity will be 0 at this stage.


           IF l_retired_quantity = 0 AND l_non_retired_quantity > 0 THEN  -- True only for corporate book
               IF l_non_retired_quantity = l_okxassetlines_rec.current_units  THEN --distribution qty = orginal asset qty

                    -- user requested for full retirement and none of the units have been retired so far
                    -- perform full retirement

                    -- we are passing the total number of units and not the cost, for full retirements, because for
                    -- Direct Finance Lease, okx_asset_lines_v, gives OEC as the cost. FA Retirements compares this cost with
                    --cost in fa_books. These 2 costs can be different, which will give error. So we are using units instead
                    -- of cost to avoid that validation check.



                    -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure



                    do_full_units_retirement(
                                        p_api_version          => p_api_version,
                                  p_init_msg_list        => OKC_API.G_FALSE,
                                        p_tax_owner            => l_tax_owner,
                                        p_delta_cost           => l_delta_cost,
                                        p_asset_id             => l_okxassetlines_rec.asset_id,
                                        p_asset_number         => l_okxassetlines_rec.asset_number,
                                        p_proceeds_of_sale     => l_proceeds_of_sale,
                                       -- p_corporate_book       => l_corporate_book,  -- SECHAWLA Bug # 2701440 : changed the parameter name
                                        p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                        --p_cost                 => l_cost,
                                        p_units                => l_okxassetlines_rec.current_units,
                                        p_prorate_convention   => NULL, -- ansethur for Bug:5664106  l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                        x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371 : added
                                        x_msg_count            => x_msg_count,
                                        x_msg_data             => x_msg_data,
                                        x_return_status        => x_return_status,
                                        p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                        p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005


                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_units_retired := l_okxassetlines_rec.current_units;
                 ELSE
                    -- distribution qty is either less or more than the current units
                    -- and hence we need to consider this as partial retirement, even though the sold
                    -- quantity = asset quantity (current_units)

                    IF l_non_retired_quantity  > l_okxassetlines_rec.current_units THEN
                        l_units_to_be_retired := l_okxassetlines_rec.current_units;
                    ELSE
                        l_units_to_be_retired := l_non_retired_quantity;
                    END IF;

                 --   l_dist_quantity := l_current_units;
                    l_dist_quantity := l_units_to_be_retired;
                    i := 0;


                    -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                    -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                    -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                    -- than requested units then retire that distribution fully and move to next distribution for remaining
                    -- units, until all the requested units have been retired.


                    FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                         IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                              l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                              l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                              l_dist_quantity := 0;
                              EXIT;
                         ELSE
                              l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                              l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                              l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                         END IF;
                         i := i + 1;
                    END LOOP;


                    -- If there are no more distributions left and there are still some more units to be retired,
                    -- then the input quantity was invalid. Quantity can not be more than the some total of the units
                    -- assigned to all the distributions.


                    IF l_dist_quantity > 0 THEN  -- quantity to be retired (for non-retired distributions)
                        -- x_return_status := OKL_API.G_RET_STS_ERROR;
                        -- Sold quantity is more than the total quantity assigned to asset distributions.
                        OKC_API.set_message( p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                        --RAISE okc_api.G_EXCEPTION_ERROR;
                    END IF;

                    -- SECHAWLA 21-NOV-03 3262519 : Added p_tax_owner and delta cost parameters to the following procedure call


                    do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_proceeds_of_sale,
                              --  p_corporate_book       => p_corporate_book, --SECHAWLA Bug # 2701440 : changed the parameter name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371 : added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005


                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                         RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_units_retired := l_units_to_be_retired ;
                END IF;   --l_non_retired_quantity = l_quantity


           ELSIF  l_retired_quantity = l_okxassetlines_rec.current_units AND l_non_retired_quantity = 0 THEN -- retired qty = current units
                 -- Asset is already fully retired.
                 OKC_API.set_message(     p_app_name      => 'OKL',
                                          p_msg_name      => 'OKL_AM_ALREADY_RETIRED',
                                          p_token1        => 'ASSET_NUMBER',
                                          p_token1_value  => l_okxassetlines_rec.asset_number);
                 l_already_retired := 'Y';

           ELSIF l_retired_quantity >= l_okxassetlines_rec.current_units AND l_non_retired_quantity > 0 THEN -- There are still some more units that can be retierd
                 -- non-retired qty can be either less or more than l_quantity
                 IF l_non_retired_quantity  >= l_okxassetlines_rec.current_units THEN
                      l_units_to_be_retired := l_okxassetlines_rec.current_units;
                 ELSE
                      l_units_to_be_retired := l_non_retired_quantity;
                 END IF;


                -- l_dist_quantity := l_current_units;
                 l_dist_quantity := l_units_to_be_retired;
                 i := 0;

                 -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                 -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                 -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                 -- than requested units then retire that distribution fully and move to next distribution for remaining
                 -- units, until all the requested units have been retired.


                 FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                      IF l_disthist_rec.retirement_id IS  NULL THEN
                         IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                             l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                             l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                             l_dist_quantity := 0;
                             EXIT;
                         ELSE
                             l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                             l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                             l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                         END IF;
                         i := i + 1;
                      END IF;
                 END LOOP;

                 -- SECHAWLA 21-NOV-03 3262519 : Added p_tax_owner and delta cost parameter to the following procedure call
                 do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_proceeds_of_sale,
                              --  p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440 : changed the parameter name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371 : added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005


                  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                      RAISE OKC_API.G_EXCEPTION_ERROR;
                  END IF;

                  l_units_retired := l_units_to_be_retired;
           ELSIF  l_retired_quantity > l_okxassetlines_rec.current_units AND l_non_retired_quantity = 0 THEN
                  --  x_return_status := OKL_API.G_RET_STS_ERROR;
                  -- Asset ASSET_NUMBER is already retired with invalid retired quantity which is more than the original quantity.
                  OKC_API.set_message(     p_app_name      => 'OKL',
                                           p_msg_name      => 'OKL_AM_INVALID_RETIRED_QTY',
                                           p_token1        => 'ASSET_NUMBER',
                                           p_token1_value  => l_okxassetlines_rec.asset_number);
                  --  RAISE okc_api.G_EXCEPTION_ERROR;

           ELSIF l_retired_quantity < l_okxassetlines_rec.current_units AND l_non_retired_quantity > 0 THEN



                 IF l_non_retired_quantity  >= l_okxassetlines_rec.current_units THEN
                      l_units_to_be_retired := l_okxassetlines_rec.current_units;
                 ELSE
                      l_units_to_be_retired := l_non_retired_quantity;
                 END IF;

               --  l_dist_quantity := l_current_units;
                 l_dist_quantity := l_units_to_be_retired;
                 i := 0;

                 -- l_disthist_csr picks up all active distributions, which could possibly be retired.
                 -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                 -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                 -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                 -- than requested units then retire that distribution fully and move to next distribution for remaining
                 -- units, until all the requested units have been retired.

                 FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                    IF l_disthist_rec.retirement_id IS NULL THEN
                        IF l_disthist_rec.units_assigned >= l_dist_quantity THEN

                            l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                            l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                            l_dist_quantity := 0;
                            EXIT;
                        ELSE
                            l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                            l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                            l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                        END IF;
                        i := i + 1;
                    END IF;
                END LOOP;

                -- If there are no more active distributions left and there are still some more units to be retired,
                -- then the input quantity was invalid. Quantity can not be more than the sum total of the units
                -- assigned to non-retired distributions.

                IF l_dist_quantity > 0 THEN
                   IF l_retired_quantity < l_dist_quantity THEN
                        -- x_return_status := OKL_API.G_RET_STS_ERROR;
                        -- Sold quantity is more than the total quantity assigned to asset distributions.
                        OKC_API.set_message( p_app_name      => 'OKL',
                                             p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                        -- RAISE okc_api.G_EXCEPTION_ERROR;
                   END IF;
                END IF;

                -- SECHAWLA 21-NOV-03 3262519 : Added p_tax_owner and delta cost parameter to the following procedure call
                do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_proceeds_of_sale,
                               -- p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440  :changed the parameter name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371 : added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005

                 IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                 ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                     RAISE OKC_API.G_EXCEPTION_ERROR;
                 END IF;

                 l_units_retired := l_units_to_be_retired;


           --SECHAWLA 23-DEC-02 Bug # 2701440 : Added the following code for tax book retirement
           ELSIF l_retired_quantity = 0 AND l_non_retired_quantity = 0 THEN -- This condition will be true only for TAX books

                IF l_already_retired = 'N' THEN  -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition to stop cost retirement of tax book if asset is already fully retierd in corp book
                    -- do cost retirement for the tax book

                    -- SECHAWLA 21-NOV-2003 3262519 : get the cost that is to be retired
                    IF l_tax_owner = 'LESSEE' THEN -- tax owner will have a value for Direct Finance/Sales Lease only.
                                                   -- Cost Adjustment will happen in tax book through do_cost_retirement
                                                   -- Cost will become Residual Value
                          l_cost := l_okxassetlines_rec.cost; -- Retire Asset Cost -- for bug 5760603 - Earlier RV
                    ELSE  -- tax owner = 'LESSOR' (cost adj does not happen in tax book)
                          -- OR tax owner is null (not DF/Sales lease, no cost adjustment)
                          l_cost := l_okxassetlines_rec.cost; -- Retire the current cost in FA  -- this is FA Cost
                    END IF;
                    -- SECHAWLA 21-NOV-2003 3262519 : end


                    -- SECHAWLA 21-nov-03 3262519 Added tax owner and delta cost parameters
                    do_cost_retirement(
                                p_api_version           => p_api_version,
                          p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_proceeds_of_sale,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                -- p_cost                  => l_cost_retired, -- SECHAWLA 13-JAN-03 Bug # 2701440
                                -- SECHAWLA 13-JAN-03 Bug # 2701440 : If the original request is for Full retirement, do a full cost retirement for the tax book
                                -- p_cost                  => l_okxassetlines_rec.cost, -- SECHAWLA 21-NOV-2003 3262519
                                p_cost                  => l_cost, -- SECHAWLA 21-NOV-2003 3262519
                                p_prorate_convention    =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419: Added this parameter
                                x_fa_trx_date           => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005

                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;
                 END IF;
                -- SECHAWLA 23-DEC-02 Bug # 2701440 : end new code
           END IF;



        ELSE -- input quantity is either less or more than the current units
            -- user requested for partial retirement by p_quantity units

            IF l_okxassetlines_rec.book_class = 'CORPORATE' THEN

                l_dist_quantity := p_quantity;

                i := 0;

                -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                -- than requested units then retire that distribution fully and move to next distribution for remaining
                -- units, until all the requested units have been retired.


                -- l_disthist_csr picks up all active distributions, which could possibly be retired.

                l_retired_dist_units := 0;

                -- This loop is executed only for corporate book, as tax book does not have any distributions
                FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.corporate_book) LOOP
                    -- First retire all non-retired distributions, maintain a unit count of already retired distributions.
                    -- We will use this count at the end, when all non-retired distributions have been retired, to make
                    -- sure that the units retired = input quantity

                    IF l_disthist_rec.retirement_id IS NOT NULL THEN
                        l_retired_dist_units := l_retired_dist_units + abs(l_disthist_rec.transaction_units);
                    ELSE

                        IF l_disthist_rec.units_assigned >= l_dist_quantity THEN

                            l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                            l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                            l_dist_quantity := 0;
                            EXIT;
                        ELSE
                            l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                            l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                            l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                        END IF;
                        i := i + 1;
                    END IF;
                END LOOP;

                -- If there are no more active distributions left and there are still some more units to be retired,
                -- then the input quantity was invalid. Quantity can not be more than the sum total of the units
                -- assigned to non-retired distributions.

                IF l_dist_quantity > 0 THEN -- quantity to be retired (for non-retired distributions)

                    IF l_retired_dist_units < l_dist_quantity THEN -- retired quantity isn't enough to match up with total qty
                        -- Sold quantity is more than the total quantity assigned to asset distributions.
                        OKC_API.set_message( p_app_name      => 'OKL',
                                         p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                    END IF;
                    l_units_to_be_retired := p_quantity - l_dist_quantity;
                ELSE
                    l_units_to_be_retired := p_quantity;
                END IF;

                IF l_dist_tbl.COUNT > 0 THEN
                    -- SECHAWLA 21-NOV-03 3262519 : Added p_tax_owner and delta cost parameter to the following procedure call
                    do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_proceeds_of_sale,
                            --    p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440 : changed the parameter name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired,  -- quantity to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005

                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;


                    /* SECHAWLA 21-NOV-03 3262519 : This fetch is not required. Cost to be retired from the tax book should be
                     -- calculated using tax book cost and not the corporate book cost, as the 2 costs can be different

                    -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this code to get the cost retired for the corporate book
                    -- This cost is used later to perform a cost retirement for the TAX book
                    OPEN   l_faretirement_csr(l_okxassetlines_rec.asset_id,l_okxassetlines_rec.corporate_book);
                    FETCH  l_faretirement_csr INTO l_cost_retired;
                    -- Since asset is first retired from corporate book, this fetch will definitely find a row
                    CLOSE  l_faretirement_csr;
                   */



                    l_units_retired := l_units_to_be_retired;
                ELSE
                    -- If it reaches here, it means it didn't find any new distributions to retire. Since we are not
                    -- processing any records in FA in this case, we consider this asset as already retired.

                    l_already_retired := 'Y';
                END IF;
            --SECHAWLA 23-DEC-02 Bug # 2701440 : Added the following code for tax book retirement
            ELSIF l_okxassetlines_rec.book_class = 'TAX' THEN

                IF l_already_retired = 'N' THEN  -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition to stop cost retirement of tax book if asset is already fully retierd in corp book

                   -- SECHAWLA 21-NOV-2003 3262519 : get the cost that is to be retired
                    IF l_tax_owner = 'LESSEE' THEN -- tax owner will have a value for Direct Finance/Sales Lease only.
                                                   -- Cost Adjustment will happen in tax book through do_cost_retirement
                                                   -- Cost will become Residual Value
                          l_cost := l_okxassetlines_rec.cost; -- for bug 5760603 -- Retire cost Not Rv
                    ELSE  -- tax owner = 'LESSOR' (cost adj does not happen in tax book)
                          -- OR tax owner is null (not DF/Sales lease, no cost adjustment)
                          l_cost := l_okxassetlines_rec.cost; -- cost to be considered is the curent cost
                    END IF;
                    -- SECHAWLA 21-NOV-2003 3262519 : end

                   -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition for teh scenario where tax book's initial cost is less than the corp book cost
                   --IF l_okxassetlines_rec.cost >= l_cost_retired THEN  -- SECHAWLA 21-nov-03 3262519

                   --SECHAWLA 21-NOV-2003 3262519 : Cost to be retired from tax book should be calculated using
                   -- tax book's cost and the quentity retired in the corporate book
                   l_cost_retired := (l_cost /  l_okxassetlines_rec.current_units ) * l_units_retired;

                   IF  l_cost >= l_cost_retired THEN
                       -- This condition should always be true
                       -- do cost retirement for the tax book

                       -- SECHAWLA 21-nov-03 3262519 Added tax owner and delta cost parameters


                       do_cost_retirement(
                                p_api_version           => p_api_version,
                          p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_proceeds_of_sale,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                p_cost                  => l_cost_retired,
                                p_prorate_convention    =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date           => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count             => x_msg_count,
              x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status,
                                p_quote_eff_date       => l_quote_eff_date,     -- rmunjulu EDAT 10-Jan-2005
                                p_quote_accpt_date     => l_quote_accpt_date ); -- rmunjulu EDAT 10-Jan-2005

                       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                       END IF;
                  -- SECHAWLA 13-JAN-03 Bug # 2701440 : If the tax book's cost is less than the cost retierd from the corp book
                  -- but has not been fully retired yet, then perform a full cost retirement for tax book

                  --SECHAWLA 21-NOV-2003 3262519 : This condition will not occur now that we calculate cost to be
                  -- retired from tax book using tax book cost itself
                  --ELSIF l_okxassetlines_rec.cost > 0 THEN  -- SECHAWLA 21-nov-03 3262519
                /*  ELSIF l_cost > 0 THEN  -- SECHAWLA 21-nov-03 3262519
                          -- retire the whole remaining cost

                          -- SECHAWLA 21-nov-03 3262519 Added tax owner and delta cost parameters
                       do_cost_retirement(
                                p_api_version           => p_api_version,
                                p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_proceeds_of_sale,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                --p_cost                  => l_okxassetlines_rec.cost -- SECHAWLA 21-nov-03 3262519
                                p_cost                  => l_cost, -- SECHAWLA 21-nov-03 3262519
                                p_prorate_convention    =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_msg_count             => x_msg_count,
                                x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status);

                       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                       END IF;
                    */
                   END IF;


                 END IF;

                -- SECHAWLA 23-DEC-02 Bug # 2701440 : end new code
            END IF;

        END IF; -- IF l_orderlines_rec.ordered_quantity = l_quantity THEN

       IF l_already_retired = 'N' THEN
         IF  l_okxassetlines_rec.book_class = 'CORPORATE' THEN -- SECHAWLA Bug # 2701440 : Added this condition to
                                                               -- store trx transaction and process a/c entries only
                                                               -- for CORPORATE book
            -- Store Transaction in OKL
            okl_am_util_pvt.get_transaction_id(p_try_name          => l_trx_type,
                                          x_return_status     => x_return_status,
                                          x_try_id            => l_try_id);

            IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                -- Unable to find a transaction type for this transaction.
                OKL_API.set_message(p_app_name    => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => 'Asset Disposition');
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;


            lp_thpv_rec.tas_type := 'RFA';
            lp_thpv_rec.tsu_code := 'PROCESSED';
            lp_thpv_rec.try_id   := l_try_id;
            lp_thpv_rec.date_trans_occurred := l_quote_accpt_date; -- rmunjulu EDAT changed from sysdate to accpt date

            -- RRAVIKIR Legal Entity Changes
            lp_thpv_rec.legal_entity_id := p_legal_entity_id;
            -- Legal Entity Changes End

            OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                            p_init_msg_list         => OKC_API.G_FALSE,
                     x_return_status         => x_return_status,
                     x_msg_count             => x_msg_count,
                     x_msg_data              => x_msg_data,
           p_thpv_rec       => lp_thpv_rec,
           x_thpv_rec       => lx_thpv_rec);

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
              RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
            l_func_curr_code := okl_am_util_pvt.get_functional_currency;
            lp_tlpv_rec.currency_code := l_func_curr_code;

            -- rbruno 5436987 -- start
            --lp_tlpv_rec.currency_code := l_func_curr_code;
            l_contract_currency_code := okl_am_util_pvt.get_chr_currency(l_chr_id);
            lp_tlpv_rec.currency_code := l_contract_currency_code;

	    IF l_func_curr_code <> l_contract_currency_code THEN

             	-- get currency conversion parameters
                OKL_ACCOUNTING_UTIL.convert_to_functional_currency(
                     p_khr_id  		  	          => l_chr_id,
                     p_to_currency   		      => l_func_curr_code,
                     p_transaction_date 		  => l_quote_eff_date,
                     p_amount 			          => l_hard_coded_amount,
                     x_return_status              => x_return_status,
                     x_contract_currency		  => l_contract_currency_code,
                     x_currency_conversion_type	  => l_currency_conversion_type,
                     x_currency_conversion_rate	  => l_currency_conversion_rate,
                     x_currency_conversion_date	  => l_currency_conversion_date,
                     x_converted_amount 		  => l_converted_amount);

                lp_tlpv_rec.currency_conversion_type := l_currency_conversion_type;
                lp_tlpv_rec.currency_conversion_rate := l_currency_conversion_rate;
                lp_tlpv_rec.currency_conversion_date := l_currency_conversion_date;

			END IF;
            -- rbruno 5436987 -- end


            -- Create transaction Line
            lp_tlpv_rec.tas_id        := lx_thpv_rec.id;   -- FK
         lp_tlpv_rec.iay_id        := l_okxassetlines_rec.depreciation_category;
            lp_tlpv_rec.kle_id        := p_financial_asset_id;
            lp_tlpv_rec.line_number   := 1;
            lp_tlpv_rec.tal_type       := 'RFL';
            lp_tlpv_rec.asset_number   := l_okxassetlines_rec.asset_number;
            lp_tlpv_rec.corporate_book   := l_okxassetlines_rec.book_type_code;
         lp_tlpv_rec.original_cost   := l_okxassetlines_rec.original_cost;
         lp_tlpv_rec.current_units   := l_okxassetlines_rec.current_units;
            lp_tlpv_rec.units_retired       := l_units_retired ;
         lp_tlpv_rec.dnz_asset_id  := l_okxassetlines_rec.asset_id;
            lp_tlpv_rec.dnz_khr_id          := l_okxassetlines_rec.dnz_chr_id;

            -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx line
            lp_tlpv_rec.FA_TRX_DATE         := l_fa_trx_date;

         OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
                                           p_init_msg_list         => OKC_API.G_FALSE,
                                        x_return_status         => x_return_status,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                                  p_tlpv_rec          => lp_tlpv_rec,
                                  x_tlpv_rec          => lx_tlpv_rec);

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            -----------------end Store Transaction in OKL -----------------

            -- make call to accounting entries
            process_accounting_entries(
                p_api_version                  => p_api_version,
                p_init_msg_list                => OKC_API.G_FALSE,
                x_return_status                => x_return_status,
                x_msg_count                    => x_msg_count,
                x_msg_data                     => x_msg_data,
                p_kle_id                        => p_financial_asset_id,
                p_try_id                        => l_try_id,
                p_sys_date                      => l_quote_eff_date, -- rbruno EDAT Changed from sysdate to acceptance date -- rbruno bug 5436987
                p_source_id                     => lx_tlpv_rec.id,
                p_trx_type                      => l_trx_name,
                p_amount                        => l_proceeds_of_sale,
                p_func_curr_code                => l_func_curr_code,
                x_total_amount                  => lx_total_amount,
                --akrangan start
                p_legal_entity_id => p_legal_entity_id
                --akrangan end
                );

                -- rollback if error in accounting entries
                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

             -- Store the amount at the header and line level in trx tables

            -- Update amount in the header table
            lp_thpv_rec := lp_thpv_empty_rec;
            lp_thpv_rec.id  := lx_thpv_rec.id;
            lp_thpv_rec.total_match_amount := lx_total_amount;

            OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

             -- Update amount in the lines table.
             lp_tlpv_rec := lp_tlpv_empty_rec;
             lp_tlpv_rec.id := lx_tlpv_rec.id;
             lp_tlpv_rec.match_amount := lx_total_amount;

             --SECHAWLA 03-JAN-03 Added the following statement as a temporary fix to LA's ROUNDING ERROR problem
             lp_tlpv_rec.kle_id := p_financial_asset_id;

             --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
             lp_tlpv_rec.currency_code := l_func_curr_code;

             -- rbruno 5436987 --- start
             --lp_tlpv_rec.currency_code := l_func_curr_code;
	 IF l_func_curr_code <> l_contract_currency_code THEN
                lp_tlpv_rec.currency_conversion_type := l_currency_conversion_type;
                lp_tlpv_rec.currency_conversion_rate := l_currency_conversion_rate;
                lp_tlpv_rec.currency_conversion_date := l_currency_conversion_date;
 	 END IF;
             lp_tlpv_rec.currency_code := l_contract_currency_code;
             --rbruno 5436987  --- end


             OKL_TXL_ASSETS_PUB.update_txl_asset_Def(
                                 p_api_version   => p_api_version,
                                 p_init_msg_list => OKC_API.G_FALSE,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_tlpv_rec      => lp_tlpv_rec,
                                 x_tlpv_rec      => lx_tlpv_rec);

             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

          END IF;
        END IF; -- if l_already_retired = 'N'


     END LOOP;


      --- Expire item in Installed Base
-- commented call to expire_item  djanaswa bug 6736148  start
/*
      IF p_quantity IS NULL OR p_quantity = OKL_API.G_MISS_NUM  THEN
           -- Retire all existing instances
            FOR l_itemlocation_rec in l_itemlocation_csr LOOP

                 IF l_itemlocation_rec.instance_end_date IS NULL THEN-- Instance is not already expired.
                        expire_item (
                        p_api_version            => p_api_version,
                        p_init_msg_list        => OKC_API.G_FALSE,
                        x_msg_count              => x_msg_count,
                        x_msg_data            => x_msg_data,
                        x_return_status        => x_return_status ,
                        p_instance_id            => l_itemlocation_rec.instance_id,
                              p_end_date               => l_sys_date); -- rmunjulu EDAT 23-Nov-04 -- change back to sysdate -- rmunjulu EDAT Changed from sysdate to eff date

                        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;

                 END IF;

            END LOOP;



      ELSE -- quantity < original quantity
             instance_counter := 1;
             -- retire number of instances equal to the input quantity
             FOR l_itemlocation_rec in l_itemlocation_csr LOOP

                 IF l_itemlocation_rec.instance_end_date IS NULL THEN-- Instance is not already expired.
                     expire_item (
                        p_api_version            => p_api_version,
                        p_init_msg_list        => OKC_API.G_FALSE,
                        x_msg_count              => x_msg_count,
                        x_msg_data            => x_msg_data,
                        x_return_status        => x_return_status ,
                        p_instance_id            => l_itemlocation_rec.instance_id,
                              p_end_date               => l_sys_date); -- rmunjulu EDAT 23-Nov-04 Change back to sysdate -- rmunjulu EDAT Changed from sysdate to eff date

                     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                     END IF;

                     IF instance_counter = p_quantity THEN
                        EXIT;
                     END IF;
               instance_counter := instance_counter + 1;
                  END IF;

             END LOOP;

      END IF;
*/
        -------------- end IB Retirement -----------------------
-- commented call to expire_item  djanaswa bug 6736148  end





      -- Loop thru all the pending transactions in okl_trx_assets_v and okl_txl_assets_v
        -- and update the status to 'CANCELED'

        FOR l_assettrx_rec IN l_assettrx_csr LOOP
            -- update the staus (tsu_code) in okl_trx_assets_v
            lp_thpv_rec := lp_thpv_empty_rec;
            lp_thpv_rec.id  := l_assettrx_rec.id;
            lp_thpv_rec.tsu_code := 'CANCELED';

            OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
        END LOOP;



      -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

      -- RMUNJULU 3061751 11-SEP-2003
      -- Check if linked service contract exists for the asset which is disposed
      l_service_int_needed := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_service_k_int_needed(
                                            p_asset_id  => p_financial_asset_id,
                                            p_source    => 'DISPOSE');

      -- Do the Service Contract Integration Notification for DISPOSE
      OKL_AM_LEASE_LOAN_TRMNT_PVT.service_k_integration(
                          p_transaction_id             => p_financial_asset_id,
                          p_transaction_date           => l_quote_accpt_date, -- rmunjulu EDAT changed from sysdate to acceptance date
                          p_source                     => 'DISPOSE_1',
                          p_service_integration_needed => l_service_int_needed);

      -- ++++++++++++++++++++  service contract integration end   ++++++++++++++++++


        -- MDOKAL:  18-SEP-03 - Bug 3082639
                -------------- Securitization Processing  -----------------------

        OKL_AM_SECURITIZATION_PVT.process_securitized_streams(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_kle_id            => p_financial_asset_id,
                            p_sale_price        => p_proceeds_of_sale,
                            p_effective_date    => l_quote_eff_date,   -- rmunjulu EDAT Added
                            p_transaction_date  => l_quote_accpt_date, -- rmunjulu EDAT Added
                            p_call_origin       => OKL_SECURITIZATION_PVT.G_TRX_REASON_ASSET_DISPOSAL);

        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
                -------------- end Securitization Processing  -----------------------
       --akrangan added for sla populate sources cr start
       IF g_trans_id_tbl.COUNT > 0
       THEN
         FOR i IN g_trans_id_tbl.FIRST .. g_trans_id_tbl.LAST
         LOOP
           -- header record
           l_fxhv_rec.source_id    := lx_thpv_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id       := lx_tlpv_rec.dnz_khr_id;
           l_fxhv_rec.try_id       := lx_thpv_rec.try_id;
           -- line record
           l_fxlv_rec.source_id         := lx_tlpv_rec.id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.kle_id            := p_financial_asset_id;
           l_fxlv_rec.asset_id          := lx_tlpv_rec.dnz_asset_id;
           l_fxlv_rec.fa_transaction_id := g_trans_id_tbl(i);
           l_fxlv_rec.asset_book_type_name := lx_tlpv_rec.corporate_book;

           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
         END LOOP;
       END IF;
      --akrangan added for sla populate sources cr end

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
             CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
             CLOSE l_bookcontrols_csr;
        END IF;

        -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_okclines_csr%ISOPEN THEN
           CLOSE l_okclines_csr;
        END IF;

        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        -- SECHAWLA 21-nov-03 3262519 : end

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;


        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
             CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
             CLOSE l_bookcontrols_csr;
        END IF;

         -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_okclines_csr%ISOPEN THEN
           CLOSE l_okclines_csr;
        END IF;

        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        -- SECHAWLA 21-nov-03 3262519 : end

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
             CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
             CLOSE l_bookcontrols_csr;
        END IF;

         -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_okclines_csr%ISOPEN THEN
           CLOSE l_okclines_csr;
        END IF;

        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;
        -- SECHAWLA 21-nov-03 3262519 : end

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END dispose_asset;

   -- Start of comments
   --
   -- Procedure Name  : dispose_asset
   -- Description     :  This procedure is used to retire an asset in FA, from Remarketing. It checks if the asset is
   --                    to be fully or partially retired , based upon the ordered_quantity and then calls the appropriate routine to
   --                    retire the asset. It then stores the disposition transactions in OKL tables, calls accounting
   --                    engine and then finally cancels all pending transactions in OKL tables for this asset
   -- Business Rules  :
   -- Parameters      :  p_order_header_id  - Order Header ID
   --
   -- Version         : 1.0
   -- History         :  SECHAWLA 10-DEC-02 Bug # 2701440
   --                      Modified CURSOR l_okxassetlines_csr to select all the tax books that an asset belongs to,
   --                      in addition to the Fixed Asset Information.
   --                    SECHAWLA 23-DEC-02 Bug # 2701440
   --                      Modified logic to perform cost retirement instead of unit retirement for tax books
   --                    SECHAWLA 03-JAN-03 Bug # 2683876
   --                      Modified logic to send currency code while creating/updating amounts columns in txl assets
   --                    SECHAWLA 13-JAN-03 Bug # 2701440 Modified logic to perform :
   --                      1) full tax book retirement when the corporate book gets fully retired. This is to
   --                      take care of the scenario where tax book cost is more than the corporate book cost
   --                      2) full tax book retirement when the corp book is not fully retired but tax book does not
   --                      have enough cost. This takes care of the scenario where tax book cost is less than the corp book cost
   --                    SECHAWLA 05-FEB-03 Bug # 2781557
   --                      Moved the logic to check if the asset was added in the current open period, from individual cost and unit
   --                      retirement procedures to this procedure.
   --                    SECHAWLA 11-MAR-03
   --                      Removed the validation for NULL order quantity, as it is being NVLed to 1. Added a validation
   --                      for unit_selling_price. If null, assigned 0 to sale_amount
   --                    SECHAWLA 03-JUN-03  2999419: Use the retirement prorate convention set in Oracle
   --                      Assets for a particular asset and book, instead of using the constant value "MID-MONTH"
   --                    RMUNJULU 11-SEP-03 3061751 Added code for SERVICE_K_INTEGRATION
   --                    SECHAWLA 21-NOV-03 3262519 Update the asset cost with residual value, for DF and Sales lease,
   --                      before retiring the asset
   --                    SECHAWLA 21-OCT-04 3924244 Modified procedure to work on order line instead of header
   --                    girao 18-Jan-2005 4106216 NVL the residual value in l_linesfullv_csr
   --                    SECHAWLA 10-FEB-06 5016156 in case of termination w/o purchase, asset cost should
   --                           be updated with NIV (not RV), through Off-lease transactions

   -- End of comments
   PROCEDURE dispose_asset (     p_api_version           IN   NUMBER,
                              p_init_msg_list         IN   VARCHAR2,
                                    x_return_status         OUT  NOCOPY VARCHAR2,
                                    x_msg_count             OUT  NOCOPY NUMBER,
                              x_msg_data              OUT  NOCOPY VARCHAR2,
                        p_order_line_id         IN      NUMBER -- SECHAWLA 21-OCT-04 3924244
                                    ) IS

   SUBTYPE   thpv_rec_type   IS  OKL_TRX_ASSETS_PUB.thpv_rec_type;
   SUBTYPE   tlpv_rec_type   IS  OKL_TXL_ASSETS_PUB.tlpv_rec_type;

   -- This cursor is used to validate Header ID
   CURSOR l_orderheaders_csr(p_header_id NUMBER) IS
   SELECT order_number
   FROM   oe_order_headers_all
   WHERE  header_id = p_header_id;

   -- This cursor is used to get the information about all the line items corresponding to an Order
   CURSOR l_orderlines_csr(p_line_id  NUMBER) IS -- -- SECHAWLA 21-OCT-04 3924244
   SELECT header_id, inventory_item_id, nvl(ordered_quantity,1) ordered_quantity, ship_from_org_id,  unit_selling_price
   FROM   oe_order_lines_all
   WHERE  line_id = p_line_id;

   -- This curosr is used to get the financial asset id for an inventory item
   --Changed the cusrsor to use directly base tables instead uv for performance
   CURSOR l_assetreturn_csr(p_inventory_item_id NUMBER) IS
     SELECT kle.id kle_id,
            cim.number_of_items quantity,
            -- RRAVIKIR Legal Entity changes
            oar.legal_entity_id
            -- Legal Entity changes End
     FROM okc_k_lines_b kle,
          okc_k_headers_all_b okc,
          okl_asset_returns_all_b oar,
          mtl_system_items_b msi,
          okc_k_lines_b kle2,
          okc_line_styles_b lse,
          okc_k_items cim,
          okl_system_params osp
     WHERE okc.id = kle.chr_id
     AND oar.kle_id = kle.id
     AND oar.imr_id = msi.inventory_item_id
     AND msi.organization_id = osp.remk_organization_id
     AND kle.id = kle2.cle_id
     AND kle2.lse_id = lse.id
     AND lse.lty_code = 'ITEM'
     AND kle2.id = cim.cle_id
     AND oar.imr_id = p_inventory_item_id;



   -- SECHAWLA Bug # 2701440  :
   -- Modified this cursor to select all the tax books that an asset belongs to, in addition to the Fixed Asset Information

   --SECHAWLA 23_DEC-02 Bug # 2701440
   --Added Order By clause to selct CORPORATE Book first

   --SECHAWLA 13-JAN-03 Bug # 2701440
   --Changed the cursor to select cost columns from fa_books instead of okx_asset_lines_v, as the latter has info for corporate book only

   --SECHAWLA 06-JUN-03 Bug # 2999419
   --Added prorate_convention_code to the Select clause
   CURSOR l_okxassetlines_csr(p_kle_id IN NUMBER) IS
   SELECT o.asset_id, o.asset_number, o.corporate_book, a.cost, o.depreciation_category, a.original_cost, o.current_units,
          o.dnz_chr_id ,a.book_type_code, b.book_class, a.prorate_convention_code
   FROM   okx_asset_lines_v o, fa_books a, fa_book_controls b
   WHERE  o.parent_line_id = p_kle_id
   AND    o.asset_id = a.asset_id
   AND    a.book_type_code = b.book_type_code
   AND    a.date_ineffective IS NULL
   AND    a.transaction_header_id_out IS NULL
   ORDER BY book_class;

   --SECHAWLA 23_DEC-02 Bug # 2701440 : Added this cursor to get the cost retired, populated after the retirement of
   -- asset from the corporate book. We need this cost to perform cost retirement of the same asset in the TAX book

   /* SECHAWLA 21-NOV-03 3262519 : This curosr is not required. Cost to be retired from the tax book should be
   -- calculated using tax book cost and not the corporate book cost, as teh 2 costs can be different

   --SECHAWLA 13-JAN-03 Bug # 2701440 : Added Order By Clause to select the latest retirement record first
   CURSOR l_faretirement_csr(p_asset_id IN NUMBER, p_book_type_code IN VARCHAR2) IS
   SELECT cost_retired
   FROM   fa_retirements
   WHERE  asset_id = p_asset_id
   AND    book_type_code = p_book_type_code
   ORDER  BY last_update_date DESC;
   */

   -- This cursor is used to get all the active distributions for an asset
   CURSOR l_disthist_csr(p_asset_id NUMBER, p_book_type_code VARCHAR2) IS
   SELECT distribution_id, units_assigned, retirement_id, transaction_units
   FROM   fa_distribution_history
   WHERE  asset_id = p_asset_id
   AND    book_type_code = p_book_type_code
   AND    date_ineffective IS NULL
   AND    transaction_header_id_out IS NULL
   --AND    retirement_id IS NULL
   ORDER  BY last_update_date;

   -- This cursor is used to get all the pending transactions for an asset. These transactions are to be cancelled
   -- once the asset is retired.
   CURSOR l_assettrx_csr(p_financial_asset_id NUMBER) IS
   SELECT h.id
   FROM   OKL_TRX_ASSETS h, okl_txl_assets_v l
   WHERE  h.id = l.tas_id
   AND    h.tsu_code  IN  ('ENTERED', 'ERROR')
   AND    l.kle_id = p_financial_asset_id;

   -- This curosr is used to get all the instances for a Financial asset
   --Query changed to use base tables instead uv for performance
   CURSOR l_itemlocation_csr(p_financial_asset_id NUMBER) IS
     SELECT cii.instance_id instance_id, cii.active_end_date instance_end_date
     FROM okc_k_headers_b okhv,
          okc_k_lines_b kle_fa,
          okc_k_lines_tl klet_fa,
          okc_line_styles_b lse_fa,
          okc_k_lines_b kle_il,
          okc_line_styles_b lse_il,
          okc_k_lines_b kle_ib,
          okc_line_styles_b lse_ib,
          okc_k_items ite,
          csi_item_instances cii
    WHERE kle_fa.id = klet_fa.id
    AND klet_fa.language = USERENV('LANG')
    AND kle_fa.chr_id = okhv.id AND lse_fa.id = kle_fa.lse_id
    AND lse_fa.lty_code = 'FREE_FORM1'
    AND kle_il.cle_id = kle_fa.id
    AND lse_il.id = kle_il.lse_id
    AND lse_il.lty_code = 'FREE_FORM2'
    AND kle_ib.cle_id = kle_il.id
    AND lse_ib.id = kle_ib.lse_id
    AND lse_ib.lty_code = 'INST_ITEM'
    AND ite.cle_id = kle_ib.id
    AND ite.jtot_object1_code = 'OKX_IB_ITEM'
    AND cii.instance_id = ite.object1_id1
    AND kle_fa.id = p_financial_asset_id;


   --SECHAWLA 05-FEB-03 Bug # 2781557 : new cursor
   -- This cursor is used to find out the period_of_addtion for the asset that is to be retired
   CURSOR l_periodofaddition_csr(p_asset_id NUMBER, p_book_type_code VARCHAR2, p_period_open_date DATE)  IS
   SELECT count(*)
   FROM   fa_transaction_headers th
   WHERE  th.asset_id              = p_asset_id
   AND    th.book_type_code        = p_book_type_code
   AND    th.transaction_type_code = 'ADDITION'
   AND    th.date_effective > p_period_open_date;

   --SECHAWLA 05-FEB-03 Bug # 2781557 : new cursor
   -- This cursor is used temporarily to get the fiscal year name till FA API is fixed
   CURSOR l_bookcontrols_csr(p_book_type_code VARCHAR2) IS
   SELECT fiscal_year_name
   FROM   fa_book_controls
   WHERE  book_type_code = p_book_type_code;

   --SECHAWLA 21-NOV-2003 3262519 : Added the following cursor

   -- get the deal type from the contract
   CURSOR l_dealtype_csr(p_financial_asset_id IN NUMBER) IS
   SELECT lkhr.id, lkhr.deal_type, khr.contract_number
   FROM   okl_k_headers lkhr, okc_k_lines_b cle, okc_k_headers_b khr
   WHERE  khr.id = cle.chr_id
   AND    lkhr.id = khr.id
   AND    cle.id = p_financial_asset_id;

   -- get the residual value for the fin asset
   CURSOR l_linesfullv_csr(p_fin_asset_id IN NUMBER) IS
   SELECT name, NVL(residual_value,0)  --girao bug 4106216 NVL the residual value
   FROM   okl_k_lines_full_v
   WHERE  id = p_fin_asset_id;

   --SECHAWLA 10-FEB-06 5016156
   CURSOR l_offlseassettrx_csr(cp_trx_date IN DATE, cp_asset_number IN VARCHAR2) IS
   SELECT h.tsu_code, h.tas_type,  h.date_trans_occurred, l.dnz_asset_id,
          l.asset_number, l.kle_id ,l.DNZ_KHR_ID
   FROM   OKL_TRX_ASSETS h, OKL_TXL_ASSETS_B l
   WHERE  h.id = l.tas_id
   AND    h.date_trans_occurred <= cp_trx_date
   AND    h.tas_type in ('AMT','AUD','AUS')
   AND    l.asset_number = cp_asset_number;

   l_trx_status         VARCHAR2(30);
   --SECHAWLA 10-FEB-06 5016156  : end


   l_deal_type          VARCHAR2(30);
   l_chr_id             NUMBER;
   l_contract_number    VARCHAR2(120);
   l_rulv_rec           okl_rule_pub.rulv_rec_type;
   l_tax_owner          VARCHAR2(10);
   l_delta_cost         NUMBER;
   l_residual_value     NUMBER;
   l_name               VARCHAR2(150);
   l_cost               NUMBER;
   --SECHAWLA 21-NOV-2003 3262519 : end new declarations


   l_dist_quantity          NUMBER;
   l_dist_tbl               asset_dist_tbl;
   l_return_status          VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_order_number           NUMBER;
   i                        NUMBER;
   l_kle_id                 NUMBER;
   l_quantity               NUMBER;
   l_sale_amount            NUMBER;
   l_trx_type               VARCHAR2(30) := 'Asset Disposition';
   l_trx_name               VARCHAR2(30) := 'ASSET_DISPOSITION';
   l_api_name               CONSTANT VARCHAR2(30) := 'dispose_asset';
   l_try_id         OKL_TRX_TYPES_V.id%TYPE;
   l_sys_date               DATE;

   lp_thpv_rec              thpv_rec_type;
   lp_thpv_empty_rec        thpv_rec_type;
   lp_tlpv_empty_rec        tlpv_rec_type;
   lx_thpv_rec              thpv_rec_type;
   lp_tlpv_rec       tlpv_rec_type;
   lx_tlpv_rec       tlpv_rec_type;
   l_api_version            CONSTANT NUMBER := 1;
   instance_counter         NUMBER;
   l_already_retired        VARCHAR2(1):= 'N';
   l_retired_quantity       NUMBER;
   l_non_retired_quantity   NUMBER;
   l_remaining_units        NUMBER;
   l_retired_dist_units     NUMBER;
   l_units_to_be_retired    NUMBER;
   lx_total_amount          NUMBER;
   l_units_retired          NUMBER;

   --SECHAWLA 23_DEC-02 Bug # 2701440: new declarations
   l_cost_retired           NUMBER;

   --SECHAWLA 03-JAN-03 Bug # 2683876 : new declaration
   l_func_curr_code         GL_LEDGERS_PUBLIC_V.CURRENCY_CODE%TYPE;

   --SECHAWLA 05-FEB-03 Bug # 2781557 : new declarations
   l_fiscal_year_name       VARCHAR2(30);
   l_period_rec             FA_API_TYPES.period_rec_type;
   l_count                  NUMBER;
   l_period_of_addition     VARCHAR2(1);

   -- RMUNJULU 3061751
   l_service_int_needed  VARCHAR2(1) := 'N';

   --SECHAWLA 21-OCT-04 3924244
   l_header_id    NUMBER;
   l_inventory_item_id  NUMBER;
   l_ordered_quantity  NUMBER;
   l_ship_from_org_id  NUMBER;
   l_unit_selling_price  NUMBER;

    --SECHAWLA  15-DEC-04  4028371 New Declarations
   l_fa_trx_date    DATE;

   -- Legal Entity changes
   l_legal_entity_id            NUMBER;
   -- Legal Entity changes End
   --akrangan sla populate sources cr start
      l_fxhv_rec         okl_fxh_pvt.fxhv_rec_type;
      l_fxlv_rec         okl_fxl_pvt.fxlv_rec_type;
   --akrangan sla populate sources cr end

   BEGIN

    l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

   -- Get the sysdate
   SELECT SYSDATE INTO l_sys_date FROM DUAL;

   -- SECHAWLA 21-OCT-04 3924244
   IF p_order_line_Id IS NULL OR  p_order_line_Id =  OKL_API.G_MISS_NUM THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Line ID is required
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_LINE_ID');
        RAISE okc_api.G_EXCEPTION_ERROR;
   END IF;

   /* -- SECHAWLA 21-OCT-04 3924244
   OPEN  l_orderheaders_csr(p_order_header_Id);
   FETCH l_orderheaders_csr INTO l_order_number;
   IF l_orderheaders_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Header ID is invalid
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_HEADER_ID');
        RAISE okc_api.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_orderheaders_csr;
   */

   -- SECHAWLA 21-OCT-04 3924244 : begin
   OPEN  l_orderlines_csr(p_order_line_Id);
   FETCH l_orderlines_csr INTO l_header_id, l_inventory_item_id, l_ordered_quantity,
                               l_ship_from_org_id,  l_unit_selling_price;
   IF l_orderlines_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        -- Order Line ID is invalid
        OKL_API.set_message(         p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDER_LINE_ID');
        RAISE okc_api.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_orderlines_csr;

   OPEN  l_orderheaders_csr(l_header_id);
   FETCH l_orderheaders_csr INTO l_order_number;
   CLOSE l_orderheaders_csr;
   -- SECHAWLA 21-OCT-04 3924244 : end


   -- SECHAWLA 21-OCT-04 3924244 : Commented out the loop and changed the cursor attribute references to variable references
   -- loop thru all the line items for a given order, validate the data and then reduce the quantity of each line item
   --FOR l_orderlines_rec IN l_orderlines_csr(p_order_header_id) LOOP



       IF l_ordered_quantity < 0 THEN  -- SECHAWLA 21-OCT-04 3924244
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- ordered quantity is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ORDERED_QUANTITY');


            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        IF trunc(l_ordered_quantity) <> l_ordered_quantity THEN -- SECHAWLA 21-OCT-04 3924244
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- Ordered quantity should be a whole number.
            OKC_API.set_message(     p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_WHOLE_QTY_ERR');
           RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;



       OPEN  l_assetreturn_csr(l_inventory_item_id);  -- SECHAWLA 21-OCT-04 3924244
       FETCH l_assetreturn_csr INTO l_kle_id, l_quantity, l_legal_entity_id; -- RRAVIKIR legal_entity_id added to the Fetch cursor


       IF l_assetreturn_csr%NOTFOUND THEN
           x_return_status := OKL_API.G_RET_STS_ERROR;
           -- Inventory Item for the order ORDER_NUMBER is not defined in Asset Returns.
           OKL_API.set_message(      p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_ASSET_RETURN',
                                     p_token1        => 'ORDER_NUMBER',
                                     p_token1_value  => l_order_number);
           RAISE okc_api.G_EXCEPTION_ERROR;
       END IF;

       IF l_quantity IS NULL OR l_quantity = OKL_API.G_MISS_NUM THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          --  Quantity is required
          OKL_API.set_message(       p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_RETURN_QUANTITY');
          RAISE okc_api.G_EXCEPTION_ERROR;
       END IF;

       -- RRAVIKIR Legal Entity Changes
       IF (l_legal_entity_id is null or l_legal_entity_id = OKC_API.G_MISS_NUM) THEN
          OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                              p_msg_name     => g_required_value,
                              p_token1       => g_col_name_token,
                              p_token1_value => 'legal_entity_id');
          RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       -- Legal Entity Changes End

       IF l_quantity < 0 THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          --  Quantity is invalid
          OKL_API.set_message(       p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'ASSET_RETURN_QUANTITY');
          RAISE okc_api.G_EXCEPTION_ERROR;
       END IF;

       CLOSE l_assetreturn_csr;


       l_already_retired := 'N';

       --SECHAWLA 21-NOV-2003 3262519 : Added the following  code to get the deal type and tax owner

       -- get the deal type from the contract
       OPEN  l_dealtype_csr(l_kle_id);
       FETCH l_dealtype_csr INTO l_chr_id, l_deal_type, l_contract_number;
       IF  l_dealtype_csr%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- chr id is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                p_msg_name      => G_INVALID_VALUE,
                                p_token1        => G_COL_NAME_TOKEN,
                                p_token1_value  => 'CHR_ID');

            RAISE OKC_API.G_EXCEPTION_ERROR;
       END IF;
       CLOSE l_dealtype_csr;

       IF l_deal_type IN ('LEASEDF','LEASEST') THEN
            -- get the tax owner (LESSOR/LESSEE) for the contract

            okl_am_util_pvt.get_rule_record(p_rgd_code         => 'LATOWN'
                                     ,p_rdf_code         =>'LATOWN'
                                     ,p_chr_id           => l_chr_id
                                     ,p_cle_id           => NULL
                                     ,x_rulv_rec         => l_rulv_rec
                                     ,x_return_status    => x_return_status
                                     ,x_msg_count        => x_msg_count
                                     ,x_msg_data         => x_msg_data);

            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            -- check if tax owner is defined
            IF l_rulv_rec.rule_information1 IS NULL OR l_rulv_rec.rule_information1 = OKL_API.G_MISS_CHAR THEN

               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- tax owner is not defined for contract CONTRACT_NUMBER.
               OKL_API.set_message(  p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_NO_TAX_OWNER',
                                     p_token1        => 'CONTRACT_NUMBER',
                                     p_token1_value  => l_contract_number);
               RAISE OKC_API.G_EXCEPTION_ERROR;

            ELSE
               -- l_rulv_rec.RULE_INFORMATION1 will contain the value 'LESSEE' or 'LESSOR'
               l_tax_owner := l_rulv_rec.RULE_INFORMATION1;
            END IF;

            -- get the residual value of the fin asset
            OPEN  l_linesfullv_csr(l_kle_id);
            FETCH l_linesfullv_csr INTO l_name, l_residual_value;
            CLOSE l_linesfullv_csr;

            IF l_residual_value IS NULL THEN
               x_return_status := OKL_API.G_RET_STS_ERROR;
               -- Residual value is not defined for the asset
               OKC_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_NO_RESIDUAL_VALUE',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);


               RAISE OKC_API.G_EXCEPTION_ERROR;
            END IF;

            IF l_residual_value < 0 THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- Residual value is negative for the asset
             OKC_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_INVALID_RESIDUAL',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);


             RAISE OKC_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;



      --SECHAWLA 21-NOV-2003 3262519 : end new code


       -- SECHAWLA Bug # 2701440  : Changed OPEN, FETCH to a curosr FOR LOOP, as this cursor now has multiple rows
       -- for a given asset id : one row for the corporate book and one or more rows for the tax books
       FOR l_okxassetlines_rec IN l_okxassetlines_csr(l_kle_id) LOOP

          --SECHAWLA 21-NOV-2003 3262519 : Calculate delta cost
          IF l_deal_type IN ('LEASEDF','LEASEST') THEN


             --SECHAWLA 10-FEB-06 5016156 Check if any off-lease transactions exist for the asset
             -- This will tell if it is termination with purchase or without purchase
             l_trx_status := NULL;
             FOR  l_offlseassettrx_rec IN l_offlseassettrx_csr(l_sys_date, l_name) LOOP
         l_trx_status := l_offlseassettrx_rec.tsu_code;
         IF l_trx_status IN ('ENTERED','ERROR','CANCELED') THEN
            EXIT;
         END IF;
    END LOOP;



             IF l_trx_status IS NULL THEN -- This means off-lease trx don't exist. It is termination with purchase
                --SECHAWLA 10-FEB-06 5016156  : end
                l_delta_cost := l_residual_value - l_okxassetlines_rec.cost;

             --SECHAWLA 10-FEB-06 5016156 begin
             ELSIF l_trx_status IN ('ENTERED','ERROR') THEN -- if any trx has this status
                   x_return_status := OKL_API.G_RET_STS_ERROR;
                   OKL_API.set_message( p_app_name      => 'OKL',
                               p_msg_name      => 'OKL_AM_PENDING_OFFLEASE',
                               p_token1        => 'ASSET_NUMBER',
                               p_token1_value  => l_name);
                   RAISE OKC_API.G_EXCEPTION_ERROR;


             ELSIF l_trx_status IN ('PROCESSED','CANCELED') THEN
                   l_delta_cost := 0; -- no cost update required, as cost has already been updated thru off lease trx
             END IF;                  -- or off-lease trx has been canceled
             --SECHAWLA 10-FEB-06 5016156 : end

          END IF;

          --SECHAWLA 05-FEB-03 Bug # 2781557 : Moved the following code from do_full_units_retirement, as the check
          -- whether the asset is added in the current open period, needs to be done at this stage.

          -- This piece of code is included temporarily as a work around , since FA API has errors
          -- Set the Fiscal Year name in teh cache,if not already set
          --    IF fa_cache_pkg.fazcbc_record.fiscal_year_name IS NULL THEN
          OPEN  l_bookcontrols_csr(l_okxassetlines_rec.book_type_code);
          FETCH l_bookcontrols_csr INTO l_fiscal_year_name;
          IF l_bookcontrols_csr%NOTFOUND OR l_fiscal_year_name IS NULL THEN
             x_return_status := OKL_API.G_RET_STS_ERROR;
             -- Fiscal Year Name is required
             OKC_API.set_message( p_app_name      => 'OKC',
                               p_msg_name      => G_REQUIRED_VALUE,
                               p_token1        => G_COL_NAME_TOKEN,
                               p_token1_value  => 'Fiscal Year Name');


             RAISE OKC_API.G_EXCEPTION_ERROR;
         END IF;
         CLOSE l_bookcontrols_csr;
         fa_cache_pkg.fazcbc_record.fiscal_year_name := l_fiscal_year_name;
         --    END IF;


        IF NOT FA_UTIL_PVT.get_period_rec
             (
              p_book           => l_okxassetlines_rec.book_type_code,
              p_effective_date => NULL,
              x_period_rec     => l_period_rec
             ) THEN

            x_return_status := OKC_API.G_RET_STS_ERROR;
            --Error getting current open period for the book BOOK_TYPE_CODE.
            OKL_API.set_message(
                         p_app_name      => 'OKL',
                         p_msg_name      => 'OKL_AM_OPEN_PERIOD_ERR',
                         p_token1        => 'BOOK_CLASS',
                         p_token1_value  => lower(l_okxassetlines_rec.book_class),
                         p_token2        => 'BOOK_TYPE_CODE',
                         p_token2_value  => l_okxassetlines_rec.book_type_code
                         );


            RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        --- check period of addition. If 'N' then run retirements
        OPEN  l_periodofaddition_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code,l_period_rec.period_open_date);
        FETCH l_periodofaddition_csr INTO l_count;
        CLOSE l_periodofaddition_csr;

        IF (l_count <> 0) THEN
            l_period_of_addition := 'Y';
        ELSE
            l_period_of_addition := 'N';
        END IF;

        IF l_period_of_addition = 'Y' THEN
           -- Can nor retire asset ASSET_NUMBER as the asset was added to the  book
          -- in the current open period. Please retire the asset manually.
             x_return_status := OKC_API.G_RET_STS_ERROR;

             OKL_API.set_message(    p_app_name      => 'OKL',
                                     p_msg_name      => 'OKL_AM_RETIRE_MANUALLY',
                                     p_token1        => 'ASSET_NUMBER',
                                     p_token1_value  =>  l_okxassetlines_rec.asset_number,
                                     p_token2        =>  'BOOK_CLASS',
                                     p_token2_value  =>  lower(l_okxassetlines_rec.book_class),
                                     p_token3        =>  'BOOK_TYPE_CODE',
                                     p_token3_value  =>  l_okxassetlines_rec.book_type_code);

             RAISE OKC_API.G_EXCEPTION_ERROR;

         END IF;

         ----------    SECHAWLA 05-FEB-03 Bug # 2781557 : end moved code    ----------------

/* -- ansethur for Bug:5664106  Start
         -- SECHAWLA 03-JUN-03 Bug 2999419 : Added the following validation
         IF l_okxassetlines_rec.prorate_convention_code IS NULL THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              -- Unable to find retirement prorate convention for asset ASSET_NUMBER and book BOOK_TYPE_CODE.
              OKC_API.set_message(     p_app_name      => 'OKL',
                              p_msg_name      => 'OKL_AM_NO_PRORATE_CONVENTION',
                              p_token1        => 'ASSET_NUMBER',
                              p_token1_value  => l_okxassetlines_rec.asset_number,
                              p_token2        => 'BOOK_CLASS',
                              p_token2_value  => l_okxassetlines_rec.book_class,
                              p_token3        => 'BOOK_TYPE_CODE',
                              p_token3_value  => l_okxassetlines_rec.book_type_code);
              RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -- SECHAWLA 03-JUN-03 Bug 2999419: end new code
*/ -- ansethur for Bug:5664106 End



          --SECHAWLA 11-MAR-03 : Added the following validation
          IF l_unit_selling_price IS NULL THEN -- SECHAWLA 21-OCT-04 3924244
             l_sale_amount := 0;
          ELSE
             l_sale_amount  := l_ordered_quantity * l_unit_selling_price;  -- SECHAWLA 21-OCT-04 3924244
          END IF;

          IF l_ordered_quantity = l_quantity THEN   -- SECHAWLA 21-OCT-04 3924244
                -- user sent request for full retirement, since all the units were sold


                -- check if asset has already been fully/partially retired .
                l_retired_quantity := 0;
                l_non_retired_quantity := 0;
                FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                    IF l_disthist_rec.retirement_id IS NOT NULL THEN
                       l_retired_quantity := l_retired_quantity + abs(l_disthist_rec.transaction_units);
                    ELSE
                       l_non_retired_quantity := l_non_retired_quantity + l_disthist_rec.units_assigned;
                    END IF;
                END LOOP;

                IF l_retired_quantity = 0 AND l_non_retired_quantity > 0 THEN
                        -- user requested for full retirement and none of the units have been retired so far
                        -- perform full retirement
                   IF l_non_retired_quantity = l_quantity  THEN --distribution qty = orginal asset return qty

                        -- we are passing the total number of units and not the cost, for full retirements, because for
                        -- Direct Finance Lease, okx_asset_lines_v, gives OEC as the cost. FA Retirements compares this cost with
                        --cost in fa_books. These 2 costs can be different, which will give error. So we are using units instead
                        -- of cost to avoid that validation check.

                        -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                        do_full_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_sale_amount,
                                --p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440  : Changed the paramete name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                --p_cost                 => l_cost,
                                p_units                => l_quantity,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status);

                        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;

                        l_units_retired := l_quantity;
                     ELSE -- distribution qty is either less or more than the original asset return qty
                          -- and hence we need to consider this as partial retirement, even though the sold
                          -- quantity = original asset return quantity

                          IF l_non_retired_quantity  > l_quantity THEN
                             l_units_to_be_retired := l_quantity;
                          ELSE
                             l_units_to_be_retired := l_non_retired_quantity;
                          END IF;


                        --  l_dist_quantity := l_quantity;
                          l_dist_quantity := l_units_to_be_retired;
                          i := 0;


                          -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                          -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                          -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                          -- than requested units then retire that distribution fully and move to next distribution for remaining
                          -- units, until all the requested units have been retired.


                          FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                                IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                                    l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                    l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                                    l_dist_quantity := 0;
                                    EXIT;
                                ELSE
                                    l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                    l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                                    l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                                END IF;
                                i := i + 1;
                          END LOOP;


                          -- If there are no more distributions left and there are still some more units to be retired,
                          -- then the input quantity was invalid. Quantity can not be more than the some total of the units
                          -- assigned to all the distributions.


                         IF l_dist_quantity > 0 THEN  -- quantity to be retired (for non-retired distributions)
                            -- x_return_status := OKL_API.G_RET_STS_ERROR;
                            -- Sold quantity is more than the total quantity assigned to asset distributions.
                            OKC_API.set_message( p_app_name      => 'OKL',
                                                 p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                            --RAISE okc_api.G_EXCEPTION_ERROR;
                         END IF;

                        -- SECHAWLA 21-NOV-03 3262519 : Added p_tax_owner and delta cost parameter to the following procedure call
                        do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_sale_amount,
                              --  p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440 : Changed the paramete name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status);


                        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;

                        l_units_retired := l_units_to_be_retired;

                     END IF;   --l_non_retired_quantity = l_quantity
                 ELSIF  l_retired_quantity = l_quantity AND l_non_retired_quantity = 0 THEN -- retired qty = original asset return qty
                        -- Asset is already fully retired.
                        OKC_API.set_message(     p_app_name      => 'OKL',
                                                 p_msg_name      => 'OKL_AM_ALREADY_RETIRED',
                                                 p_token1        => 'ASSET_NUMBER',
                                                 p_token1_value  => l_okxassetlines_rec.asset_number);
                        l_already_retired := 'Y';
                 ELSIF l_retired_quantity >= l_quantity AND l_non_retired_quantity > 0 THEN -- There are still some more units that can be retierd
                       -- non-retired qty can be either less or more than l_quantity

                       IF l_non_retired_quantity  >= l_quantity THEN
                             l_units_to_be_retired := l_quantity;
                       ELSE
                             l_units_to_be_retired := l_non_retired_quantity;
                       END IF;

                     --  l_dist_quantity := l_quantity;
                       l_dist_quantity := l_units_to_be_retired;
                       i := 0;

                        -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                        -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                        -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                        -- than requested units then retire that distribution fully and move to next distribution for remaining
                        -- units, until all the requested units have been retired.


                       FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                          IF l_disthist_rec.retirement_id IS  NULL THEN
                             IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                                l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                                l_dist_quantity := 0;
                                EXIT;
                             ELSE
                                l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                                l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                             END IF;
                             i := i + 1;
                        END IF;
                     END LOOP;

                    -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                    do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_sale_amount,
                             --   p_corporate_book       => l_corporate_book,  -- SECHAWLA Bug # 2701440  : Changed the paramete name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status);


                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                    l_units_retired := l_units_to_be_retired;

                 ELSIF l_retired_quantity > l_quantity AND l_non_retired_quantity = 0 THEN
                      --  x_return_status := OKL_API.G_RET_STS_ERROR;
                        -- Asset ASSET_NUMBER is already retired with invalid retired quantity which is more than the original quantity.
                        OKC_API.set_message(     p_app_name      => 'OKL',
                                                 p_msg_name      => 'OKL_AM_INVALID_RETIRED_QTY',
                                                 p_token1        => 'ASSET_NUMBER',
                                                 p_token1_value  => l_okxassetlines_rec.asset_number);
                      --  RAISE okc_api.G_EXCEPTION_ERROR;
                 ELSIF l_retired_quantity < l_quantity AND l_non_retired_quantity > 0 THEN
                       -- user requested for full retirement, but the asset is already retired partially



                        IF l_non_retired_quantity  >= l_quantity THEN
                             l_units_to_be_retired := l_quantity;
                        ELSE
                             l_units_to_be_retired := l_non_retired_quantity;
                        END IF;

                       -- l_dist_quantity := l_quantity;
                        l_dist_quantity := l_units_to_be_retired;
                        i := 0;

                        -- l_disthist_csr picks up all active distributions, which could possibly be retired.


                        -- loop thru all the distributions of an asset, starting from the first non-retired distribution, compare the requested
                        -- quantity with the distribution units . If distribution has more units than the requested quantity, then
                        -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                        -- than requested units then retire that distribution fully and move to next distribution for remaining
                        -- units, until all the requested units have been retired.


                        FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                            IF l_disthist_rec.retirement_id IS NULL THEN

                                IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                                    l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                    l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                                    l_dist_quantity := 0;
                                    EXIT;
                                ELSE
                                    l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                    l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                                    l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                                END IF;
                                i := i + 1;
                            END IF;

                        END LOOP;

                       -- If there are no more non-retired distributions left and there are still some more units to be retired,
                       -- then the input quantity was invalid. Quantity can not be more than the some total of the units
                       -- assigned to all the distributions.

                       IF l_dist_quantity > 0 THEN
                          IF l_retired_quantity < l_dist_quantity THEN
                             --   x_return_status := OKL_API.G_RET_STS_ERROR;
                             -- Sold quantity is more than the total quantity assigned to asset distributions.
                                OKC_API.set_message( p_app_name      => 'OKL',
                                                     p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                             --   RAISE okc_api.G_EXCEPTION_ERROR;
                          END IF;
                       END IF;

                       -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                       do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_sale_amount,
                               -- p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440 : Changed the paramete name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired,  -- units to be retierd
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status);


                       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                       ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                           RAISE OKC_API.G_EXCEPTION_ERROR;
                       END IF;

                       l_units_retired :=  l_units_to_be_retired;

                  --SECHAWLA 23-DEC-02 Bug # 2701440 : Added the following code for tax book retirement
                  ELSIF l_retired_quantity = 0 AND l_non_retired_quantity = 0 THEN -- This condition will be true only for TAX books

                       IF l_already_retired = 'N' THEN  -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition to stop cost retirement of tax book if asset is already fully retierd in corp book
                            -- do cost retirement for the tax book

                            -- SECHAWLA 21-NOV-2003 3262519 : get the cost that is to be retired
                            IF l_tax_owner = 'LESSEE' THEN -- tax owner will have a value for Direct Finance/Sales Lease only.
                               -- Cost Adjustment will happen in tax book through do_cost_retirement
                               -- Cost will become Residual Value
                               l_cost := l_okxassetlines_rec.cost; -- for bug 5760603 -- Retire cost Not Rv
                            ELSE  -- tax owner = 'LESSOR' (cost adj does not happen in tax book)
                               -- OR tax owner is null (not DF/Sales lease, no cost adjustment)
                               l_cost := l_okxassetlines_rec.cost; -- Retire the current cost in FA
                            END IF;
                            -- SECHAWLA 21-NOV-2003 3262519 : end

                            -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                            do_cost_retirement(
                                p_api_version           => p_api_version,
                          p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_sale_amount,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                --p_cost                  => l_cost_retired, -- SECHAWLA 13-JAN-03 Bug # 2701440
                                -- SECHAWLA 13-JAN-03 Bug # 2701440 : If the original request is for Full retirement, do a full cost retirement for the tax book
                                --p_cost                  => l_okxassetlines_rec.cost,  -- SECHAWLA 21-NOV-2003 3262519
                                p_cost                  => l_cost, -- SECHAWLA 21-NOV-2003 3262519
                                p_prorate_convention    =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date           => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status);

                            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                            END IF;
                       END IF;
                       -- SECHAWLA 23-DEC-02 Bug # 2701440 : end new code

                  END IF;


            ELSE  -- ordered quantity is either less or more than the original quantity

                IF l_okxassetlines_rec.book_class = 'CORPORATE' THEN

                    l_dist_quantity := l_ordered_quantity;  -- SECHAWLA 21-OCT-04 3924244

                    i := 0;



                    -- loop thru all the distributions of an asset, starting from the first distribution, compare the requested
                    -- quantity with the distribution units. If distribution has more units than the requested quantity, then
                    -- retire that distribution partially with quantity requested and exit the loop. If distribution has less
                    -- than requested units then retire that distribution fully and move to next distribution for remaining
                    -- units, until all the requested units have been retired.

                    l_retired_dist_units := 0;
                    FOR  l_disthist_rec IN l_disthist_csr(l_okxassetlines_rec.asset_id, l_okxassetlines_rec.book_type_code) LOOP
                        -- First retire all non-retired distributions, maintain a unit count of already retired distributions.
                        -- We will use this count at the end, when all non-retired distributions have been retired, to make
                        -- sure that the units retired = ordered quantity
                        IF l_disthist_rec.retirement_id IS NOT NULL THEN
                            l_retired_dist_units := l_retired_dist_units + abs(l_disthist_rec.transaction_units);

                        ELSE

                            IF l_disthist_rec.units_assigned >= l_dist_quantity THEN
                                l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                l_dist_tbl(i).p_units_assigned := l_dist_quantity;
                                l_dist_quantity := 0;
                                EXIT;
                            ELSE
                                l_dist_tbl(i).p_distribution_id :=  l_disthist_rec.distribution_id;
                                l_dist_tbl(i).p_units_assigned := l_disthist_rec.units_assigned;
                                l_dist_quantity := l_dist_quantity - l_disthist_rec.units_assigned;
                            END IF;
                            i := i + 1;
                        END IF;
                    END LOOP;


                    -- If there are no more distributions left and there are still some more units to be retired,
                    -- then the input quantity was invalid. Quantity can not be more than the some total of the units
                    -- assigned to all the distributions.


                    IF l_dist_quantity > 0 THEN  -- quantity to be retired (for non-retired distributions)
                        IF l_retired_dist_units < l_dist_quantity THEN  -- retired quantity isn't enough to match up with total qty

                           -- Sold quantity is more than the total quantity assigned to asset distributions.
                           OKC_API.set_message( p_app_name      => 'OKL',
                                         p_msg_name      => 'OKL_AM_INVALID_DIST_QTY');
                        END IF;
                        -- SECHAWLA 21-OCT-04 3924244
                        l_units_to_be_retired := l_ordered_quantity - l_dist_quantity; -- retire whatever is left
                    ELSE
                        l_units_to_be_retired := l_ordered_quantity; -- SECHAWLA 21-OCT-04 3924244
                    END IF;


                    IF l_dist_tbl.COUNT > 0 THEN
                    -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                       do_partial_units_retirement(
                                p_api_version          => p_api_version,
                          p_init_msg_list        => OKC_API.G_FALSE,
                                p_tax_owner            => l_tax_owner,
                                p_delta_cost           => l_delta_cost,
                                p_asset_id             => l_okxassetlines_rec.asset_id,
                                p_asset_number         => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale     => l_sale_amount,
                              --  p_corporate_book       => l_corporate_book, -- SECHAWLA Bug # 2701440 : Changed the paramete name
                                p_book_type_code       => l_okxassetlines_rec.book_type_code,
                                p_total_quantity       => l_units_to_be_retired, -- units to be retired
                                p_dist_tbl             => l_dist_tbl,
                                p_prorate_convention   =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date          => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count            => x_msg_count,
                          x_msg_data             => x_msg_data,
                                x_return_status        => x_return_status);


                        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                        ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                            RAISE OKC_API.G_EXCEPTION_ERROR;
                        END IF;


                        /* SECHAWLA 21-NOV-03 3262519 : This fetch is not required. Cost to be retired from the tax book should be
                           -- calculated using tax book cost and not the corporate book cost, as the 2 costs can be different


                        -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this code to get the cost retired for the corporate book
                        -- This cost is used later to perform a cost retirement for the TAX book
                        OPEN   l_faretirement_csr(l_okxassetlines_rec.asset_id,l_okxassetlines_rec.corporate_book);
                        FETCH  l_faretirement_csr INTO l_cost_retired;
                        -- Since asset is first retired from corporate book, this fetch will definitely find a row
                        CLOSE  l_faretirement_csr;
                        */

                        l_units_retired := l_units_to_be_retired;
                    ELSE
                        -- If it reaches here, it means it didn't find any new distributions to retire. Since we are not
                        -- processing any records in FA in this case, we consider this asset as alredy retired.
                        l_already_retired := 'Y';
                    END IF;

                --SECHAWLA 23-DEC-02 Bug # 2701440 : Added the following code for tax book retirement
                ELSIF l_okxassetlines_rec.book_class = 'TAX' THEN

                    IF l_already_retired = 'N' THEN  -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition to stop cost retirement of tax book if asset is already fully retierd in corp book
                        -- SECHAWLA 21-NOV-2003 3262519 : get the cost that is to be retired
                        IF l_tax_owner = 'LESSEE' THEN -- tax owner will have a value for Direct Finance/Sales Lease only.
                           -- Cost Adjustment will happen in tax book through do_cost_retirement
                           -- Cost will become Residual Value
                          l_cost := l_okxassetlines_rec.cost; -- for bug 5760603 -- Retire cost Not Rv
                        ELSE  -- tax owner = 'LESSOR' (cost adj does not happen in tax book)
                          -- OR tax owner is null (not DF/Sales lease, no cost adjustment)
                          l_cost := l_okxassetlines_rec.cost; -- cost to be considered is the curent cost
                        END IF;
                        -- SECHAWLA 21-NOV-2003 3262519 : end

                        -- SECHAWLA 13-JAN-03 Bug # 2701440 : Added this condition for teh scenario where tax book's initial cost is less than the corp book cost
                        --IF l_okxassetlines_rec.cost >= l_cost_retired THEN  -- SECHAWLA 21-nov-03 3262519

                        --SECHAWLA 21-NOV-2003 3262519 : Cost to be retired from tax book should be calculated using
                        -- tax book's cost and the quentity retired in the corporate book
                        l_cost_retired := (l_cost /  l_okxassetlines_rec.current_units ) * l_units_retired;

                        IF  l_cost >= l_cost_retired THEN
                            -- this condition should always be true

                            -- do cost retirement for the tax book
                            -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                           do_cost_retirement(
                                p_api_version           => p_api_version,
                          p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_sale_amount,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                p_cost                  => l_cost_retired,
                                p_prorate_convention    =>  NULL, -- ansethur for Bug:5664106 l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_fa_trx_date           => l_fa_trx_date, -- 15-DEC-04 SECHAWLA 4028371  added
                                x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status);

                            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                            END IF;

                            --SECHAWLA 21-NOV-2003 3262519 : This condition will not occur now that we calculate cost to be
                            -- retired from tax book using tax book cost itself


                        /*  -- SECHAWLA 13-JAN-03 Bug # 2701440 : If the tax book's cost is less than the cost retierd from the corp book
                          -- but has not been fully retired yet, then perform a full cost retirement for tax book
                         --ELSIF l_okxassetlines_rec.cost > 0 THEN -- SECHAWLA 21-nov-03 3262519
                         ELSIF l_cost > 0 THEN  -- SECHAWLA 21-nov-03 3262519
                            -- retire the whole remaining cost
                            -- SECHAWLA 21-NOV-03, 3262519 : added tax owner and delta cost parameter to the following procedure
                               do_cost_retirement(
                                p_api_version           => p_api_version,
                          p_init_msg_list         => OKC_API.G_FALSE,
                                p_tax_owner             => l_tax_owner,
                                p_delta_cost            => l_delta_cost,
                                p_asset_id              => l_okxassetlines_rec.asset_id,
                                p_asset_number          => l_okxassetlines_rec.asset_number,
                                p_proceeds_of_sale      => l_sale_amount,
                                p_tax_book              => l_okxassetlines_rec.book_type_code,
                                --p_cost                  => l_okxassetlines_rec.cost, -- SECHAWLA 21-nov-03 3262519
                                p_cost                  =>  l_cost, -- SECHAWLA 21-nov-03 3262519
                                p_prorate_convention    => l_okxassetlines_rec.prorate_convention_code, -- SECHAWLA 03-JUN-03 2999419 : Added this parameter
                                x_msg_count             => x_msg_count,
                          x_msg_data              => x_msg_data,
                                x_return_status         => x_return_status);

                            IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                            ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                                RAISE OKC_API.G_EXCEPTION_ERROR;
                            END IF;
                        */

                          END IF;
                     END IF;
                    -- SECHAWLA 23-DEC-02 Bug # 2701440 : end new code

                END IF;
        END IF;

          IF l_already_retired = 'N' THEN
             IF  l_okxassetlines_rec.book_class = 'CORPORATE' THEN -- SECHAWLA Bug # 2701440 : Added this condition to
                                                                   -- store trx transaction and process a/c entries only
                                                                   -- for CORPORATE book
                -- create transaction header
                okl_am_util_pvt.get_transaction_id(
                                          p_try_name          => l_trx_type,
                                          x_return_status     => x_return_status,
                                          x_try_id            => l_try_id);

                IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                    -- Unable to find a transaction type for this transaction.
                    OKL_API.set_message(p_app_name    => 'OKL',
                          p_msg_name            => 'OKL_AM_NO_TRX_TYPE_FOUND',
                          p_token1              => 'TRY_NAME',
                          p_token1_value        => 'Asset Disposition');
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                lp_thpv_rec.tas_type := 'RFA';
                lp_thpv_rec.tsu_code := 'PROCESSED';
                lp_thpv_rec.try_id   := l_try_id;
                lp_thpv_rec.date_trans_occurred := l_sys_date;

                -- RRAVIKIR Legal Entity Changes
                lp_thpv_rec.legal_entity_id := l_legal_entity_id;
                -- Legal Entity Changes End

                OKL_TRX_ASSETS_PUB.create_trx_ass_h_def( p_api_version           => p_api_version,
                                p_init_msg_list         => OKC_API.G_FALSE,
                         x_return_status         => x_return_status,
                         x_msg_count             => x_msg_count,
                         x_msg_data              => x_msg_data,
               p_thpv_rec   => lp_thpv_rec,
               x_thpv_rec   => lx_thpv_rec);


                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
                l_func_curr_code := okl_am_util_pvt.get_functional_currency;
                lp_tlpv_rec.currency_code := l_func_curr_code;


                -- Create transaction Line
                lp_tlpv_rec.tas_id        := lx_thpv_rec.id;   -- FK
             lp_tlpv_rec.iay_id        := l_okxassetlines_rec.depreciation_category;
                lp_tlpv_rec.kle_id        := l_kle_id;
                lp_tlpv_rec.line_number      := 1;
                lp_tlpv_rec.tal_type       := 'RFL';
                lp_tlpv_rec.asset_number   := l_okxassetlines_rec.asset_number;
                lp_tlpv_rec.corporate_book   := l_okxassetlines_rec.book_type_code;
             lp_tlpv_rec.original_cost   := l_okxassetlines_rec.original_cost;
             lp_tlpv_rec.current_units   := l_okxassetlines_rec.current_units;
                lp_tlpv_rec.units_retired       := l_units_retired ;
             lp_tlpv_rec.dnz_asset_id     := l_okxassetlines_rec.asset_id;
                lp_tlpv_rec.dnz_khr_id          := l_okxassetlines_rec.dnz_chr_id;

                -- SECHAWLA 15-DEC-04 4028371 : set FA date on trx line
                lp_tlpv_rec.FA_TRX_DATE         := l_fa_trx_date;

             OKL_TXL_ASSETS_PUB.create_txl_asset_def(p_api_version           => p_api_version,
                                           p_init_msg_list         => OKC_API.G_FALSE,
                                        x_return_status         => x_return_status,
                                        x_msg_count             => x_msg_count,
                                        x_msg_data              => x_msg_data,
                                  p_tlpv_rec          => lp_tlpv_rec,
                                  x_tlpv_rec          => lx_tlpv_rec);

                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;



                -- make call to accounting entries
                process_accounting_entries(
                    p_api_version                  => p_api_version,
                    p_init_msg_list                => OKC_API.G_FALSE,
                    x_return_status                => x_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_kle_id                        => l_kle_id,
                    p_try_id                        => l_try_id,
                    p_sys_date                      => l_sys_date,
                    p_source_id                     => lx_tlpv_rec.id,
                    p_trx_type                      => l_trx_name,
                    p_amount                        => l_sale_amount,
                    p_func_curr_code                => l_func_curr_code,
                    x_total_amount                  => lx_total_amount,
                    p_legal_entity_id               => l_legal_entity_id);

                -- rollback if error in accounting entries
                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                    RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                -- Store the amount at the header and line level in trx tables

                -- Update amount in the header table
                lp_thpv_rec := lp_thpv_empty_rec;
                lp_thpv_rec.id  := lx_thpv_rec.id;
                lp_thpv_rec.total_match_amount := lx_total_amount;

                OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;

                -- Update amount in the lines table.
                lp_tlpv_rec := lp_tlpv_empty_rec;
                lp_tlpv_rec.id := lx_tlpv_rec.id;
                lp_tlpv_rec.match_amount := lx_total_amount;

                --SECHAWLA 03-JAN-03 Added the following statement as a temporary fix to LA's ROUNDING ERROR problem
                lp_tlpv_rec.kle_id := l_kle_id;

                --SECHAWLA 03-JAN-03 2683876 Pass the currency code if creating/updating amounts in txl assets
                lp_tlpv_rec.currency_code := l_func_curr_code;

                OKL_TXL_ASSETS_PUB.update_txl_asset_Def(
                                 p_api_version   => p_api_version,
                                 p_init_msg_list => OKC_API.G_FALSE,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_tlpv_rec      => lp_tlpv_rec,
                                 x_tlpv_rec      => lx_tlpv_rec);

                IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
                END IF;
                --- End store amounts at the header and line level

              END IF;  -- if book_class = corporate

            END IF;  -- if l_already_retired = 'N'


        END LOOP;


-- commented call to expire_item  djanaswa bug 6736148  begin

      --- Expire item in Installed Base
/*
      IF l_ordered_quantity >= l_quantity THEN  -- SECHAWLA 21-OCT-04 3924244
           -- Retire all existing instances
            FOR l_itemlocation_rec in l_itemlocation_csr(l_kle_id) LOOP
                IF l_itemlocation_rec.instance_end_date IS NULL THEN-- Instance is not already expired.
                    expire_item (
                        p_api_version            => p_api_version,
                        p_init_msg_list        => OKC_API.G_FALSE,
                        x_msg_count              => x_msg_count,
                        x_msg_data            => x_msg_data,
                        x_return_status        => x_return_status ,
                        p_instance_id            => l_itemlocation_rec.instance_id,
                              p_end_date               => l_sys_date);

                    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                    END IF;

                END IF;

            END LOOP;

      ELSE -- quantity < original quantity
             instance_counter := 1;
             -- retire number of instances equal to the input quantity
             FOR l_itemlocation_rec in l_itemlocation_csr(l_kle_id) LOOP
                 IF l_itemlocation_rec.instance_end_date IS NULL THEN-- Instance is not already expired.
                     expire_item (
                        p_api_version            => p_api_version,
                        p_init_msg_list        => OKC_API.G_FALSE,
                        x_msg_count              => x_msg_count,
                        x_msg_data            => x_msg_data,
                        x_return_status        => x_return_status ,
                        p_instance_id            => l_itemlocation_rec.instance_id,
                              p_end_date               => l_sys_date);

                     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
                     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                        RAISE OKC_API.G_EXCEPTION_ERROR;
                     END IF;

                    IF instance_counter = l_ordered_quantity THEN  -- SECHAWLA 21-OCT-04 3924244
                        EXIT;
                    END IF;
                    instance_counter := instance_counter + 1;
                  END IF;
             END LOOP;

      END IF;
*/
        -------------- end IB Retirement -----------------------
-- commented call to expire_item  djanaswa bug 6736148 end



         -- Loop thru all the pending transactions in okl_trx_assets_v and okl_txl_assets_v
        -- and update the status to 'CANCELED'

        FOR l_assettrx_rec IN l_assettrx_csr(l_kle_id) LOOP
            -- update the staus (tsu_code) in okl_trx_assets_v
            lp_thpv_rec := lp_thpv_empty_rec;
            lp_thpv_rec.id  := l_assettrx_rec.id;
            lp_thpv_rec.tsu_code := 'CANCELED';
            OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_thpv_rec          => lp_thpv_rec,
                            x_thpv_rec          => lx_thpv_rec);

             IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
                  RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;
        END LOOP;

      -- ++++++++++++++++++++  service contract integration begin ++++++++++++++++++

      -- RMUNJULU 3061751 11-SEP-2003
      -- Check if linked service contract exists for the asset which is disposed
      l_service_int_needed := OKL_AM_LEASE_LOAN_TRMNT_PVT.check_service_k_int_needed(
                                            p_asset_id  => l_kle_id,
                                            p_source    => 'DISPOSE');

      -- Do the Service Contract Integration Notification for DISPOSE
      OKL_AM_LEASE_LOAN_TRMNT_PVT.service_k_integration(
                          p_transaction_id             => l_kle_id,
                          p_transaction_date           => SYSDATE,
                          p_source                     => 'DISPOSE_2',
                          p_service_integration_needed => l_service_int_needed);

      -- ++++++++++++++++++++  service contract integration end   ++++++++++++++++++

   --END LOOP; -- SECHAWLA 21-OCT-04 3924244

   -- MDOKAL:  18-SEP-03 - Bug 3082639
            -------------- Securitization Processing  -----------------------

    OKL_AM_SECURITIZATION_PVT.process_securitized_streams(
                            p_api_version       => p_api_version,
                            p_init_msg_list     => OKC_API.G_FALSE,
                            x_return_status     => x_return_status,
                            x_msg_count         => x_msg_count,
                            x_msg_data          => x_msg_data,
                            p_kle_id            => l_kle_id,
                            p_sale_price        => l_sale_amount,
                            p_call_origin       => OKL_SECURITIZATION_PVT.G_TRX_REASON_ASSET_DISPOSAL);

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
        RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
        -------------- end Securitization Processing  -----------------------
       --akrangan added for sla populate sources cr start
       IF g_trans_id_tbl.COUNT > 0
       THEN
         FOR i IN g_trans_id_tbl.FIRST .. g_trans_id_tbl.LAST
         LOOP
           -- header record
           l_fxhv_rec.source_id    := lx_thpv_rec.id;
           l_fxhv_rec.source_table := 'OKL_TRX_ASSETS';
           l_fxhv_rec.khr_id       := lx_tlpv_rec.dnz_khr_id;
           l_fxhv_rec.try_id       := lx_thpv_rec.try_id;
           -- line record
           l_fxlv_rec.source_id         := lx_tlpv_rec.id;
           l_fxlv_rec.source_table      := 'OKL_TXL_ASSETS_B';
           l_fxlv_rec.kle_id            := lx_tlpv_rec.kle_id;
           l_fxlv_rec.asset_id          := lx_tlpv_rec.dnz_asset_id;
           l_fxlv_rec.fa_transaction_id := g_trans_id_tbl(i);
           l_fxlv_rec.asset_book_type_name := lx_tlpv_rec.corporate_book;

           okl_sla_acc_sources_pvt.populate_sources(p_api_version   => p_api_version,
                                                    p_init_msg_list => okc_api.g_false,
                                                    p_fxhv_rec      => l_fxhv_rec,
                                                    p_fxlv_rec      => l_fxlv_rec,
                                                    x_return_status => x_return_status,
                                                    x_msg_count     => x_msg_count,
                                                    x_msg_data      => x_msg_data);

           IF (x_return_status = okc_api.g_ret_sts_unexp_error)
           THEN
             RAISE okl_api.g_exception_unexpected_error;
           ELSIF (x_return_status = okc_api.g_ret_sts_error)
           THEN
             RAISE okl_api.g_exception_error;
           END IF;
         END LOOP;
       END IF;
      --akrangan added for sla populate sources cr end

     OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
   EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN

        IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
        END IF;

        IF l_assetreturn_csr%ISOPEN THEN
           CLOSE l_assetreturn_csr;
        END IF;

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
           CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
           CLOSE l_bookcontrols_csr;
        END IF;

        -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;

        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
        END IF;

        IF l_assetreturn_csr%ISOPEN THEN
           CLOSE l_assetreturn_csr;
        END IF;

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
           CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
           CLOSE l_bookcontrols_csr;
        END IF;

        -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN

        IF l_orderheaders_csr%ISOPEN THEN
           CLOSE l_orderheaders_csr;
        END IF;

        IF l_assetreturn_csr%ISOPEN THEN
           CLOSE l_assetreturn_csr;
        END IF;

        IF l_okxassetlines_csr%ISOPEN THEN
           CLOSE l_okxassetlines_csr;
        END IF;

        IF l_orderlines_csr%ISOPEN THEN
           CLOSE l_orderlines_csr;
        END IF;

        IF l_disthist_csr%ISOPEN THEN
           CLOSE l_disthist_csr;
        END IF;

        IF l_assettrx_csr%ISOPEN THEN
           CLOSE l_assettrx_csr;
        END IF;

        IF l_itemlocation_csr%ISOPEN THEN
           CLOSE l_itemlocation_csr;
        END IF;

        --SECHAWLA 05-FEB-03 Bug # 2781557 : Close the 2 new cursors
        IF l_periodofaddition_csr%ISOPEN THEN
           CLOSE l_periodofaddition_csr;
        END IF;

        IF l_bookcontrols_csr%ISOPEN THEN
           CLOSE l_bookcontrols_csr;
        END IF;

        -- SECHAWLA 21-nov-03 3262519 : close new cursors
        IF l_dealtype_csr%ISOPEN THEN
           CLOSE l_dealtype_csr;
        END IF;

        IF l_linesfullv_csr%ISOPEN THEN
           CLOSE l_linesfullv_csr;
        END IF;

        --SECHAWLA 10-FEB-06 5016156
        IF l_offlseassettrx_csr%ISOPEN THEN
           CLOSE l_offlseassettrx_csr;
        END IF;

        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END dispose_asset;




-- Start of comments
--
-- Procedure Name  :  undo_retirement
-- Description     :  This procedure is used to undo the asset retirement
-- Business Rules  :
-- Parameters      :  p_retirement_id

-- Version         : 1.0
-- End of comments

   PROCEDURE undo_retirement( p_api_version           IN   NUMBER,
                              p_init_msg_list         IN   VARCHAR2,
                                    x_return_status         OUT  NOCOPY VARCHAR2,
                                    x_msg_count             OUT  NOCOPY NUMBER,
                              x_msg_data              OUT  NOCOPY VARCHAR2,
                        p_retirement_id         IN      NUMBER) IS

   l_trans_rec                  FA_API_TYPES.trans_rec_type;
   l_asset_hdr_rec              FA_API_TYPES.asset_hdr_rec_type;
   l_asset_retire_rec           FA_API_TYPES.asset_retire_rec_type;
   l_asset_dist_tbl             FA_API_TYPES.asset_dist_tbl_type;
   l_subcomp_tbl                FA_API_TYPES.subcomp_tbl_type;
   l_inv_tbl                    FA_API_TYPES.inv_tbl_type;
   l_return_status              VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   l_api_name                   CONSTANT VARCHAR2(30) := 'undo_retirement';
   l_api_version                CONSTANT NUMBER := 1;
   l_dummy                      VARCHAR2(1);

   -- This cursor is used to validate the retirement ID
   CURSOR l_faretirement_csr(p_retirement_id NUMBER) IS
   SELECT 'x'
   FROM   fa_retirements
   WHERE  retirement_id = p_retirement_id;

   BEGIN
       l_return_status :=  OKL_API.START_ACTIVITY(l_api_name,
                                                 G_PKG_NAME,
                                                 p_init_msg_list,
                                                 l_api_version,
                                                 p_api_version,
                                                 '_PVT',
                                                 x_return_status);

      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      IF  p_retirement_id IS NULL OR p_retirement_id = OKL_API.G_MISS_NUM THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- retirement id is required
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_REQUIRED_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'RETIREMENT_ID');


            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN  l_faretirement_csr(p_retirement_id);
      FETCH l_faretirement_csr INTO l_dummy;
      IF l_faretirement_csr%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            -- retirement id is invalid
            OKC_API.set_message(     p_app_name      => 'OKC',
                                     p_msg_name      => G_INVALID_VALUE,
                                     p_token1        => G_COL_NAME_TOKEN,
                                     p_token1_value  => 'RETIREMENT_ID');


            RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      CLOSE l_faretirement_csr;

      -- transaction information
      l_trans_rec.transaction_type_code := NULL;
      l_trans_rec.transaction_date_entered := NULL;


      --SECHAWLA 29-DEC-05 3827148 : added
      l_trans_rec.calling_interface  := 'OKL:'||'Asset Disposition:'||'RFA';

      -- retirement information
      l_asset_retire_rec.retirement_id := p_retirement_id;


      FA_RETIREMENT_PUB.undo_retirement(  p_api_version       => p_api_version,
                                        p_init_msg_list     => OKC_API.G_FALSE,
                                        p_commit            => FND_API.G_FALSE,
                                        p_validation_level  => FND_API.G_VALID_LEVEL_FULL,
                                        p_calling_fn        => NULL,
                                        x_return_status     => x_return_status,
                                        x_msg_count         => x_msg_count,
                                        x_msg_data          => x_msg_data,
                                        px_trans_rec        => l_trans_rec,
                                        px_asset_hdr_rec    => l_asset_hdr_rec,
                                        px_asset_retire_rec => l_asset_retire_rec );

     IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
     END IF;


      OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
      EXCEPTION
      WHEN OKC_API.G_EXCEPTION_ERROR THEN
        IF l_faretirement_csr%ISOPEN THEN
           CLOSE l_faretirement_csr;
        END IF;
        x_return_status := OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        IF l_faretirement_csr%ISOPEN THEN
           CLOSE l_faretirement_csr;
        END IF;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OKC_API.G_RET_STS_UNEXP_ERROR',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
      WHEN OTHERS THEN
        IF l_faretirement_csr%ISOPEN THEN
           CLOSE l_faretirement_csr;
        END IF;
        x_return_status :=OKC_API.HANDLE_EXCEPTIONS
        (
          l_api_name,
          G_PKG_NAME,
          'OTHERS',
          x_msg_count,
          x_msg_data,
          '_PVT'
        );
   END undo_retirement;


-- Start of comments
--
-- Procedure Name  :  expire_item
-- Description     :  This procedure is expire an item in installed base
-- Business Rules  :
-- Parameters      :  p_instance_id
--                    p_end_date

-- Version         : 1.0
-- End of comments


   PROCEDURE expire_item (
  p_api_version IN  NUMBER,
  p_init_msg_list IN  VARCHAR2 ,
  x_msg_count   OUT NOCOPY NUMBER,
  x_msg_data     OUT NOCOPY VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2,
  p_instance_id IN  NUMBER,
  p_end_date     IN  DATE ) IS

     -- subtypes moved from okl_am_item_location_pvt

  SUBTYPE instance_rec   IS
  csi_datastructures_pub.instance_rec;
  SUBTYPE transaction_rec  IS
  csi_datastructures_pub.transaction_rec;
  SUBTYPE id_tbl   IS
  csi_datastructures_pub.id_tbl;
  SUBTYPE instance_query_rec  IS
  csi_datastructures_pub.instance_query_rec;
  SUBTYPE party_query_rec  IS
  csi_datastructures_pub.party_query_rec;
  SUBTYPE party_account_query_rec IS
  csi_datastructures_pub.party_account_query_rec;
  SUBTYPE instance_header_tbl  IS
  csi_datastructures_pub.instance_header_tbl;
  SUBTYPE extend_attrib_values_tbl IS
  csi_datastructures_pub.extend_attrib_values_tbl;
  SUBTYPE party_tbl   IS
  csi_datastructures_pub.party_tbl;
  SUBTYPE party_account_tbl  IS
  csi_datastructures_pub.party_account_tbl;
  SUBTYPE pricing_attribs_tbl  IS
  csi_datastructures_pub.pricing_attribs_tbl;
  SUBTYPE organization_units_tbl IS
  csi_datastructures_pub.organization_units_tbl;
  SUBTYPE instance_asset_tbl  IS
  csi_datastructures_pub.instance_asset_tbl;


 -- Get Item Instance parameters
 l_instance_query_rec instance_query_rec;
 l_party_query_rec     party_query_rec;
 l_account_query_rec   party_account_query_rec;
 l_instance_header_tbl instance_header_tbl;

 -- Expire Item Instance parameters
 l_instance_rec      instance_rec;
 l_txn_rec          transaction_rec;
 l_instance_id_lst     id_tbl;

 l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
 l_overall_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

 l_api_name      CONSTANT VARCHAR2(30) := 'expire_item';
 l_api_version     CONSTANT NUMBER := 1;
 l_msg_count        NUMBER  := FND_API.G_MISS_NUM;
 l_msg_data      VARCHAR2(2000);

  BEGIN

 -- ***************************************************************
 -- Check API version, initialize message list and create savepoint
 -- ***************************************************************

 l_return_status := OKL_API.START_ACTIVITY (
  l_api_name,
  G_PKG_NAME,
  p_init_msg_list,
  l_api_version,
  p_api_version,
  '_PVT',
  x_return_status);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- ************************
 -- Get Item Instance record
 -- ************************

 l_instance_query_rec.instance_id := p_instance_id;

 csi_item_instance_pub.get_item_instances (
  p_api_version         => l_api_version,
  p_commit             => FND_API.G_FALSE,
  p_init_msg_list            => FND_API.G_FALSE,
  p_validation_level        => FND_API.G_VALID_LEVEL_FULL,
  p_instance_query_rec    => l_instance_query_rec,
  p_party_query_rec        => l_party_query_rec,
  p_account_query_rec        => l_account_query_rec,
  p_transaction_id        => NULL,
  p_resolve_id_columns    => FND_API.G_FALSE,
  p_active_instance_only    => FND_API.G_TRUE,
  x_instance_header_tbl    => l_instance_header_tbl,
  x_return_status            => l_return_status,
  x_msg_count             => l_msg_count,
  x_msg_data             => l_msg_data);

 IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 ELSIF (NVL (l_instance_header_tbl.COUNT, 0) <> 1) THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 END IF;

 -- *************************************
 -- Initialize parameters to be passed in
 -- *************************************

 l_instance_rec.instance_id  :=  l_instance_header_tbl(1).instance_id;
 l_instance_rec.object_version_number :=  l_instance_header_tbl(1).object_version_number;

 l_instance_rec.active_end_date := p_end_date;


 okl_am_util_pvt.initialize_txn_rec (l_txn_rec);

 -- **************************************
 -- Call Installed Base API to expire item
 -- **************************************

 csi_item_instance_pub.expire_item_instance (
  p_api_version  => l_api_version,
  p_commit      => FND_API.G_FALSE,
  p_init_msg_list  => FND_API.G_FALSE,
  p_validation_level => FND_API.G_VALID_LEVEL_FULL,
  p_instance_rec  => l_instance_rec,
  --p_expire_children => FND_API.G_FALSE, -- 10-AUG-04 SECHAWLA 3819339
        p_expire_children => FND_API.G_TRUE, -- 10-AUG-04 SECHAWLA 3819339 Expire all child instances before expiring parent
  p_txn_rec      => l_txn_rec,
  x_instance_id_lst => l_instance_id_lst,
  x_return_status  => l_return_status,
  x_msg_count      => l_msg_count,
  x_msg_data      => l_msg_data);

 IF l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
 ELSIF l_return_status = OKL_API.G_RET_STS_ERROR THEN
  RAISE OKL_API.G_EXCEPTION_ERROR;
 END IF;

 -- **************
 -- Return results
 -- **************

 x_return_status := l_overall_status;

 OKL_API.END_ACTIVITY (x_msg_count, x_msg_data);

EXCEPTION

 WHEN OKL_API.G_EXCEPTION_ERROR THEN
  x_return_status := OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OKL_API.G_RET_STS_UNEXP_ERROR',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

 WHEN OTHERS THEN

  x_return_status :=OKL_API.HANDLE_EXCEPTIONS
   (
   l_api_name,
   G_PKG_NAME,
   'OTHERS',
   x_msg_count,
   x_msg_data,
   '_PVT'
   );

  END expire_item;


END OKL_AM_ASSET_DISPOSE_PVT;

/
