--------------------------------------------------------
--  DDL for Package Body OKL_BILL_UPFRONT_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BILL_UPFRONT_TAX_PVT" AS
/* $Header: OKLRBUTB.pls 120.9.12010000.4 2010/04/01 19:49:22 sachandr ship $ */

-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_NO_PARENT_RECORD    CONSTANT  VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FND_APP	            CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_REQUIRED_VALUE      CONSTANT  VARCHAR2(200) := OKL_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE	    CONSTANT  VARCHAR2(200) := OKL_API.G_INVALID_VALUE;
  G_UNEXPECTED_ERROR    CONSTANT  VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN       CONSTANT  VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED	CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UPPERCASE_REQ';
  G_COL_NAME_TOKEN      CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION             CONSTANT  NUMBER      := 1.0;
  G_SCOPE                   CONSTANT  VARCHAR2(4) := '_PVT';

  G_MODULE                 VARCHAR2(40) := 'LEASE.RECEIVABLES';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_LEVEL_PROCEDURE        NUMBER;
  G_IS_DEBUG_PROCEDURE_ON  BOOLEAN;
  G_IS_DEBUG_STATEMENT_ON  BOOLEAN;
  G_IS_STREAM_BASED_BILLING  BOOLEAN := NULL;

  subtype tldv_tbl_type is okl_tld_pvt.tldv_tbl_type;
  l_tldv_tbl tldv_tbl_type;
  ------------------------------------------------------------------
  -- Function GET_TRX_TYPE to extract transaction type
  ------------------------------------------------------------------
  FUNCTION get_trx_type
    (p_name		VARCHAR2,
     p_language	VARCHAR2)
  RETURN NUMBER IS

    CURSOR c_trx_type (cp_name VARCHAR2, cp_language VARCHAR2) IS
    SELECT id
    FROM   OKL_TRX_TYPES_TL
    WHERE  name = cp_name
    AND    LANGUAGE = cp_language;

    l_trx_type	okl_trx_types_v.id%TYPE;

  BEGIN

    l_trx_type := NULL;

    OPEN c_trx_type (p_name, p_language);
    FETCH c_trx_type INTO l_trx_type;
    CLOSE c_trx_type;

    RETURN l_trx_type;

  END get_trx_type;
----------------------------------------------------------------------------------
-- Start of comments
--
-- Procedure Name  : additional_tai_attr
-- Description     : private procedure to populate additional hdr attr
-- Business Rules  :  populates all additional attributes for
--                    okl_trx_ar_invoices_b
-- Parameters      : p_taiv_rec
-- Version         : 1.0
-- History         : akrangan created
--
-- End Of Comments
----------------------------------------------------------------------------------
PROCEDURE additional_tai_attr(
    p_api_version                  IN NUMBER
   ,p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE
   ,x_return_status                OUT NOCOPY VARCHAR2
   ,x_msg_count                    OUT NOCOPY NUMBER
   ,x_msg_data                     OUT NOCOPY VARCHAR2
   ,p_taiv_rec                     IN Okl_Trx_Ar_Invoices_Pub.taiv_rec_type
   ,x_taiv_rec                     OUT NOCOPY Okl_Trx_Ar_Invoices_Pub.taiv_rec_type
 )
is
  l_api_name         CONSTANT VARCHAR2(30) := 'additional_tai_attr';
  l_api_version      CONSTANT NUMBER       := 1.0;
  l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;

	l_legal_entity_id       okl_trx_ar_invoices_b.legal_entity_id%TYPE;

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

        l_cust_bank_acct okx_rcpt_method_accounts_v.bank_account_id%TYPE;

        --28-May-2008 sechawla 6619311 Moved these cursors to bill_upfront_tax procedure
        /*
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
        */

        CURSOR org_id_csr(p_khr_id NUMBER) IS
        SELECT authoring_org_id
        FROM okc_k_headers_b
        WHERE id = p_khr_id;

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

       l_term_id okl_trx_ar_invoices_b.irt_id%type; -- cklee 3/20/07

  CURSOR rcpt_method_csr(p_rct_method_id NUMBER) IS
  SELECT c.creation_method_code
  FROM ar_receipt_methods m,
    ar_receipt_classes c
  WHERE m.receipt_class_id = c.receipt_class_id
   AND m.receipt_method_id = p_rct_method_id;

  l_rct_method_code ar_receipt_classes.creation_method_code%TYPE;

  --Start code added by pgomes on 20-NOV-2002
  SUBTYPE khr_id_type IS okl_k_headers_v.khr_id%TYPE;
  l_khr_id khr_id_type;
  l_currency_code okl_trx_ar_invoices_b.currency_code%TYPE;
  l_currency_conversion_type okl_trx_ar_invoices_b.currency_conversion_type%TYPE;
  l_currency_conversion_rate okl_trx_ar_invoices_b.currency_conversion_rate%TYPE;
  l_currency_conversion_date okl_trx_ar_invoices_b.currency_conversion_date%TYPE;

  --Get currency conversion attributes for a contract
  CURSOR l_curr_conv_csr(cp_khr_id IN khr_id_type) IS
  SELECT currency_code,
    currency_conversion_type,
    currency_conversion_rate,
    currency_conversion_date
  FROM okl_k_headers_full_v
  WHERE id = cp_khr_id;

  CURSOR inv_frmt_csr(cp_khr_id IN NUMBER) IS
  SELECT to_number(rul.rule_information1), -- inf.id, --sechawla 26-may-09 6826580
    rul.rule_information4 review_invoice_yn
  FROM okc_rule_groups_v rgp,
    okc_rules_v rul
  --,  okl_invoice_formats_v inf  --sechawla 26-may-09 6826580
  WHERE rgp.dnz_chr_id = cp_khr_id
   AND rgp.chr_id = rgp.dnz_chr_id
   AND rgp.id = rul.rgp_id
   AND rgp.cle_id IS NULL
   AND rgp.rgd_code = 'LABILL'
   AND rul.rule_information_category = 'LAINVD';
  -- AND rul.rule_information1 = inf.name; --sechawla 26-may-09 6826580

  l_inf_id okl_invoice_formats_v.id%TYPE;

  CURSOR pvt_label_csr(cp_khr_id IN NUMBER) IS
  SELECT rule_information1 private_label
  FROM okc_rule_groups_b a,
       okc_rules_b b
  WHERE a.dnz_chr_id = cp_khr_id
   AND a.rgd_code = 'LALABL'
   AND a.id = b.rgp_id
   AND b.rule_information_category = 'LALOGO';

  l_private_label okc_rules_b.rule_information1%TYPE;


begin
  -- Set API savepoint
  SAVEPOINT additional_tai_attr;

  -- Check for call compatibility
  IF (NOT FND_API.Compatible_API_Call (l_api_version,
                                	   p_api_version,
                                	   l_api_name,
                                	   G_PKG_NAME ))
  THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  END IF;

  -- Initialize message list if requested
  IF (FND_API.to_Boolean(p_init_msg_list)) THEN
      FND_MSG_PUB.initialize;
	END IF;

  -- Initialize API status to success
  x_return_status := OKL_API.G_RET_STS_SUCCESS;


  -- assign all passed in attributes from IN to OUT record
  x_taiv_rec := p_taiv_rec;
      l_khr_id := p_taiv_rec.khr_id;
      IF l_khr_id IS NOT NULL THEN
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

        -- Private Label
        l_private_label := NULL;

        OPEN pvt_label_csr(l_khr_id);
        FETCH pvt_label_csr
        INTO l_private_label;
        CLOSE pvt_label_csr;
        x_taiv_rec.private_label := l_private_label;
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        l_jtot_object2_code := NULL;

        IF (p_taiv_rec.legal_entity_id IS NULL OR (p_taiv_rec.legal_entity_id = Okl_Api.G_MISS_NUM))  THEN
          l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_khr_id);
        ELSE
          l_legal_entity_id  := p_taiv_rec.legal_entity_id;
        END IF;
        x_taiv_rec.legal_entity_id := l_legal_entity_id;
        --akrangan added for tax only invoice changes begin
	--added gmiss condition
        IF(p_taiv_rec.irm_id IS NULL OR p_taiv_rec.irm_id = Okl_Api.G_MISS_NUM) THEN
        --akrangan added for tax only invoice changes end
          OPEN rule_code_csr(l_khr_id,   'LAPMTH');
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          IF l_object1_id2 <> '#' THEN
            x_taiv_rec.irm_id := l_object1_id2;
          ELSE
            -- This cursor needs to be removed when the view changes to
            -- include id2
            OPEN rcpt_mthd_csr(l_object1_id1);
            FETCH rcpt_mthd_csr
            INTO x_taiv_rec.irm_id;
            CLOSE rcpt_mthd_csr;
          END IF;

        ELSE
          x_taiv_rec.irm_id := p_taiv_rec.irm_id;
        END IF;

        -- Null out local variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_jtot_object2_code := NULL;

        billto_rec.cust_account_id := NULL;
        billto_rec.cust_acct_site_id := NULL;
        billto_rec.payment_term_id := NULL;

        OPEN cur_address_billto(l_khr_id);
        FETCH cur_address_billto
        INTO billto_rec;
        CLOSE cur_address_billto;

        IF (p_taiv_rec.ixx_id IS NULL OR (p_taiv_rec.ixx_id = Okl_Api.G_MISS_NUM))  THEN
          x_taiv_rec.ixx_id := billto_rec.cust_account_id;
        ELSE
          x_taiv_rec.ixx_id := p_taiv_rec.ixx_id;
        END IF;

        IF (p_taiv_rec.ibt_id IS NULL OR (p_taiv_rec.ibt_id = Okl_Api.G_MISS_NUM))  THEN
          x_taiv_rec.ibt_id := billto_rec.cust_acct_site_id;
        ELSE
          x_taiv_rec.ibt_id := p_taiv_rec.ibt_id;
        END IF;

        OPEN std_terms_csr;
        FETCH std_terms_csr
        INTO l_term_id;
        CLOSE std_terms_csr;
	--akrangan added for tax only invoice changes begin
	--changed for handling gmiss values
        IF p_taiv_rec.irt_id IS NULL
	OR p_taiv_rec.irt_id = Okl_Api.G_MISS_NUM  THEN
          x_taiv_rec.irt_id := l_term_id;
	ELSE
          x_taiv_rec.irt_id := p_taiv_rec.irt_id;
        END IF;
	--akrangan added for tax only invoice changes end
        IF (p_taiv_rec.org_id IS NULL OR p_taiv_rec.org_id=OKL_API.G_MISS_NUM) THEN

          OPEN org_id_csr(l_khr_id);
          FETCH org_id_csr
          INTO x_taiv_rec.org_id;
          CLOSE org_id_csr;
        ELSE
          x_taiv_rec.org_id := p_taiv_rec.org_id;
        END IF;

        -- To resolve the bank account for the customer
        -- If receipt method is manual do not supply customer bank account
        -- Id. This is required for Auto Invoice Validation

        -- Null out variable
        l_rct_method_code := NULL;

        OPEN rcpt_method_csr(x_taiv_rec.irm_id);
        FETCH rcpt_method_csr
        INTO l_rct_method_code;
        CLOSE rcpt_method_csr;

        --Null out variables
        l_jtot_object1_code := NULL;
        l_object1_id1 := NULL;
        l_object1_id2 := NULL;
        l_cust_bank_acct := NULL;

        IF(l_rct_method_code <> 'MANUAL') THEN

          OPEN rule_code_csr(l_khr_id,   'LABACC');
          FETCH rule_code_csr
          INTO l_jtot_object1_code,
            l_object1_id1,
            l_object1_id2;
          CLOSE rule_code_csr;

          OPEN bank_acct_csr(l_object1_id1);
          FETCH bank_acct_csr
          INTO l_cust_bank_acct;
          CLOSE bank_acct_csr;

          x_taiv_rec.customer_bank_account_id := l_cust_bank_acct;
        END IF;

        l_inf_id := NULL;

        OPEN inv_frmt_csr(l_khr_id);
        FETCH inv_frmt_csr
        INTO x_taiv_rec.inf_id,
             x_taiv_rec.invoice_pull_yn;
        CLOSE inv_frmt_csr;

      END IF; -- IF l_khr_id IS NOT NULL THEN

      --How to get the set_of_books_id ?

      IF (p_taiv_rec.set_of_books_id IS NULL OR p_taiv_rec.set_of_books_id = OKL_API.G_MISS_NUM) THEN
        x_taiv_rec.set_of_books_id := Okl_Accounting_Util.get_set_of_books_id;
      ELSE
        x_taiv_rec.set_of_books_id := p_taiv_rec.set_of_books_id;
        --TAI
      END IF;

      --Check for currency code

      IF (p_taiv_rec.currency_code IS NULL OR p_taiv_rec.currency_code=OKL_API.G_MISS_CHAR) THEN
        x_taiv_rec.currency_code := l_currency_code;
      ELSE
        x_taiv_rec.currency_code := p_taiv_rec.currency_code;
      END IF;

      --Check for currency conversion type

      IF (p_taiv_rec.currency_conversion_type IS NULL OR p_taiv_rec.currency_conversion_type = OKL_API.G_MISS_CHAR) THEN
        x_taiv_rec.currency_conversion_type := l_currency_conversion_type;
      ELSE
        x_taiv_rec.currency_conversion_type := p_taiv_rec.currency_conversion_type;
      END IF;

      --Check for currency conversion rate

      IF(p_taiv_rec.currency_conversion_type = 'User') THEN

        IF(p_taiv_rec.currency_code = Okl_Accounting_Util.get_func_curr_code) THEN
          x_taiv_rec.currency_conversion_rate := 1;
        ELSE

          IF (p_taiv_rec.currency_conversion_rate IS NULL OR p_taiv_rec.currency_conversion_rate=OKL_API.G_MISS_NUM) THEN
            x_taiv_rec.currency_conversion_rate := l_currency_conversion_rate;
          ELSE
            x_taiv_rec.currency_conversion_rate := p_taiv_rec.currency_conversion_rate;
          END IF;

        END IF;

      ELSE
        x_taiv_rec.currency_conversion_rate := NULL;
      END IF;

      --Check for currency conversion date

      IF (p_taiv_rec.currency_conversion_date IS NULL  OR p_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE) THEN
        x_taiv_rec.currency_conversion_date := l_currency_conversion_date;
      ELSE
        x_taiv_rec.currency_conversion_date := p_taiv_rec.currency_conversion_date;
      END IF;


      IF(p_taiv_rec.currency_conversion_type IS NULL OR p_taiv_rec.currency_conversion_date = OKL_API.G_MISS_DATE) THEN
        x_taiv_rec.currency_conversion_type := 'User';
        x_taiv_rec.currency_conversion_rate := 1;
        x_taiv_rec.currency_conversion_date := SYSDATE;
      END IF;

      -- Populate Customer TRX-TYPE ID From AR setup

      --28-May-2008 sechawla 6619311
      --Moved the following code to bill_upfront_tax procedure so that corrcet trx type can be drived
      --after calculating the total tax amount.
      /*
      IF p_taiv_rec.amount < 0 THEN
        x_taiv_rec.irt_id := NULL;

        OPEN cm_trx_type_csr(x_taiv_rec.set_of_books_id, x_taiv_rec.org_id);
        FETCH cm_trx_type_csr
        INTO x_taiv_rec.cust_trx_type_id;
        CLOSE cm_trx_type_csr;
      ELSE

        OPEN cust_trx_type_csr(x_taiv_rec.set_of_books_id, x_taiv_rec.org_id);
        FETCH cust_trx_type_csr
        INTO x_taiv_rec.cust_trx_type_id;
        CLOSE cust_trx_type_csr;
      END IF;
     */
 -- Set Tax exempt flag to Standard
      x_taiv_rec.tax_exempt_flag := 'S';
      x_taiv_rec.tax_exempt_reason_code := NULL;


  -- Get message count and if count is 1, get message info
	FND_MSG_PUB.Count_And_Get
    (p_count          =>      x_msg_count,
     p_data           =>      x_msg_data);

EXCEPTION
  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    ROLLBACK TO additional_tai_attr;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    ROLLBACK TO additional_tai_attr;
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get
      (p_count         =>      x_msg_count,
       p_data          =>      x_msg_data);

  WHEN OTHERS THEN
	ROLLBACK TO additional_tai_attr;
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR ;
      OKL_API.Set_Message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_UNEXPECTED_ERROR,
                          p_token1        => G_SQLCODE_TOKEN,
                          p_token1_value  => SQLCODE,
                          p_token2        => G_SQLERRM_TOKEN,
                          p_token2_value  => SQLERRM);
      FND_MSG_PUB.Count_And_Get
        (p_count         =>      x_msg_count,
         p_data          =>      x_msg_data);

end additional_tai_attr;

  PROCEDURE Bill_Upfront_Tax(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            p_khr_id             IN  NUMBER,
            p_trx_id             IN  NUMBER,
            p_invoice_date       IN  DATE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2)  IS

    l_api_name	     CONSTANT VARCHAR2(30) := 'BILL_UPFRONT_TAX';
    l_api_version      CONSTANT NUMBER	   := 1;
    l_return_status    VARCHAR2(1)           := OKL_API.G_RET_STS_SUCCESS;

    l_line_code	     CONSTANT VARCHAR2(30) := 'LINE';
    l_zero_amount      CONSTANT NUMBER       := 0;
    l_def_desc	     CONSTANT VARCHAR2(30) := 'Upfront Tax Billing';

    l_billing_try_id    Okl_Trx_Ar_Invoices_V.try_id%TYPE;

    l_init_taiv_rec     Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    l_init_tilv_rec     Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    l_init_bpd_acc_rec  Okl_Acc_Call_Pub.bpd_acc_rec_type;
    lp_taiv_rec         Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    lp_empty_taiv_rec   Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;--sechawla 13-may-2008 6619311
    lp_tilv_rec         Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    lp_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;
    xp_taiv_rec         Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    xp_tilv_rec         Okl_Txl_Ar_Inv_Lns_Pub.tilv_rec_type;
    xp_bpd_acc_rec      Okl_Acc_Call_Pub.bpd_acc_rec_type;

    CURSOR upfront_tax_csr(p_khr_id IN NUMBER) IS
    SELECT rl.rule_information2
    FROM okc_rule_groups_b rg,
         okc_rules_b rl
    WHERE  rg.dnz_chr_id = p_khr_id
    AND    rg.rgd_code = 'LAHDTX'
    AND    rl.rgp_id = rg.id
    AND    rl.dnz_chr_id = rg.dnz_chr_id
    AND    rl.rule_information_category = 'LASTPR';

    upfront_tax_rec upfront_tax_csr%ROWTYPE;
    --akrangan ebtax billing impacts coding start
    CURSOR l_upfront_tax_treatment_csr(cp_khr_id IN NUMBER) IS
      SELECT r1.rule_information1 asset_upfront_tax
      FROM   okc_rule_groups_b rg,
             okc_rules_b       r1
      WHERE  rg.dnz_chr_id = cp_khr_id
      AND    rg.rgd_code = 'LAHDTX'
      AND    r1.rgp_id = rg.id
      AND    r1.dnz_chr_id = rg.dnz_chr_id
      AND    r1.rule_information_category = 'LASTPR';

    --This cursor selects all asset lines for which upfront tax treatment is set to 'Billied'
    --at asset level,  Plus all asset lines for which tax treatment is set to Null at asset level
    -- (When asset treatment at hdr (K) level is set to 'Billed', these assets (with null tax treatment)
    -- will inherit the 'Billed' treatment from the header),
    --Plus K level taxable lines (K level tax is always 'Billed')
    --For ALC, following cursor will select taxable lines corresponding to the specific asset
    --for which Loc is being changed
    --Since this cursor does not have a filter on the tax line status, it will pick both active and inactive
    --rows in case of rebook. This will insure that the amount billed during rebook is the difference
	--of old and new tax.

    CURSOR l_allbilledtaxablelines_csr(cp_khr_id IN NUMBER, cp_trx_id IN NUMBER) IS
      SELECT trx_id,
             trx_line_id,
             entity_code,
             event_class_code,
             application_id,
             trx_level_type,
             kle_id,
             org_id
      FROM   okl_tax_sources   txs,
             okc_rule_groups_b rg,
             okc_rules_b       r1
      WHERE  txs.khr_id = cp_khr_id
      AND    txs.application_id = 540
      AND    txs.trx_id = cp_trx_id
      AND    txs.trx_level_type = 'LINE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    rg.dnz_chr_id = txs.khr_id
      AND    rg.cle_id = txs.kle_id
      AND    rg.rgd_code = 'LAASTX'
      AND    r1.rgp_id = rg.id --akrangan added for perfomance --hash cartesian join fixed
      AND    nvl(r1.rule_information11, 'BILLED') = 'BILLED' --sechawla 08-nov-07 6618649 : changed rule_information1 to rule_information11
      AND    r1.dnz_chr_id = cp_khr_id --sechawla 08-nov-07 6618649 : added for performance
      AND    r1.RULE_INFORMATION_CATEGORY ='LAASTX' --sechawla 08-nov-07 6618649 : Added this condition
      AND    txs.total_tax <> 0
      UNION
      SELECT trx_id,
             trx_line_id,
             entity_code,
             event_class_code,
             application_id,
             trx_level_type,
             NULL,
             org_id
      FROM   okl_tax_sources txs
      WHERE  txs.khr_id = cp_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.application_id = 540
      AND    txs.trx_id = cp_trx_id
      AND    txs.trx_level_type = 'LINE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txs.total_tax <> 0 ;

    CURSOR l_billedtaxablelines_csr(cp_khr_id IN NUMBER, cp_trx_id IN NUMBER) IS
      SELECT trx_id,
             trx_line_id,
             entity_code,
             event_class_code,
             application_id,
             trx_level_type,
             kle_id,
             org_id
      FROM   okl_tax_sources   txs,
             okc_rule_groups_b rg,
             okc_rules_b       r1
      WHERE  txs.khr_id = cp_khr_id
      AND txs.application_id = 540
      AND txs.trx_id = cp_trx_id
      AND txs.trx_level_type = 'LINE'
      AND txs.tax_call_type_code = 'UPFRONT_TAX'
      AND rg.dnz_chr_id = txs.khr_id
      AND rg.cle_id = txs.kle_id
      AND rg.rgd_code = 'LAASTX'
      AND r1.rgp_id = rg.id --akrangan added for perfomance --hash cartesian join fixed
      AND r1.rule_information11 = 'BILLED' --sechawla 08-nov-07 6618649 : changed rule_information1 to rule_information11
      AND r1.dnz_chr_id = cp_khr_id --sechawla 08-nov-07 6618649 : added for performance
      AND r1.RULE_INFORMATION_CATEGORY ='LAASTX' --sechawla 08-nov-07 6618649 : Added this condition
      AND    txs.total_tax <> 0
      UNION
      SELECT trx_id,
             trx_line_id,
             entity_code,
             event_class_code,
             application_id,
             trx_level_type,
             NULL,
             org_id
      FROM   okl_tax_sources txs
      WHERE  txs.khr_id = cp_khr_id
      AND    txs.kle_id IS NULL
      AND    txs.application_id = 540
      AND    txs.trx_id = cp_trx_id
      AND    txs.trx_level_type = 'LINE'
      AND    txs.tax_call_type_code = 'UPFRONT_TAX'
      AND    txs.total_tax <> 0;
    CURSOR l_fndlanguage_csr IS
      SELECT language_code,
             installed_flag
      FROM   fnd_languages
      WHERE  installed_flag IN ('I', 'B')
      ORDER  BY installed_flag;

     -- to get inventory_org_id
    CURSOR inv_org_id_csr(p_contract_id NUMBER) IS
     SELECT NVL(inv_organization_id,   -99),
            org_id --akrangan added for tax only invoice changes
       FROM okc_k_headers_b
      WHERE id = p_contract_id;

      --sechawla 13-may-2008 6619311 : added this cursor
    CURSOR zx_lines_csr(cp_trx_id IN NUMBER, cp_trx_line_id IN NUMBER, cp_application_id IN NUMBER,
	                    cp_event_class_code IN VARCHAR2,cp_entity_code IN VARCHAR2 , cp_trx_level_type IN VARCHAR2) IS
      SELECT tax_line_id, tax_amt
      FROM   zx_lines
      WHERE   trx_id = cp_trx_id
      AND     trx_line_id = cp_trx_line_id
      AND     application_id = cp_application_id
      AND     event_class_code = cp_event_class_code
      AND     entity_code = cp_entity_code
      AND     trx_level_type = cp_trx_level_type
      AND     nvl(cancel_flag, 'N') <> 'Y';

      --28-May-2008 sechawla 6619311 Moved these cursors to bill_upfront_tax procedure

      CURSOR cust_trx_type_csr(p_sob_id NUMBER, p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Invoice-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;

        CURSOR cm_trx_type_csr(p_sob_id NUMBER, p_org_id NUMBER) IS
        SELECT id1
        FROM okx_cust_trx_types_v
        WHERE name = 'Credit Memo-OKL'
        AND set_of_books_id = p_sob_id
        AND org_id = p_org_id;



    l_total_tax_amt				NUMBER; --sechawla 13-may-2008 6619311

    l_sty_id                    NUMBER;
    l_upfront_tax_treatment_rec l_upfront_tax_treatment_csr%ROWTYPE;
    TYPE txl_ar_inv_lins_tbl
    IS TABLE OF okl_txl_ar_inv_lns_b%ROWTYPE
    INDEX BY BINARY_INTEGER;

    TYPE txl_ar_inv_lns_tl_tbl
    IS TABLE OF okl_txl_ar_inv_lns_tl%ROWTYPE
    INDEX BY BINARY_INTEGER;

    TYPE txd_ar_inv_ln_dtls_tbl
    IS TABLE OF okl_txd_ar_ln_dtls_b%ROWTYPE
    INDEX BY BINARY_INTEGER;

    TYPE txd_ar_inv_ln_dtls_tl_tbl
    IS TABLE OF okl_txd_ar_ln_dtls_tl%ROWTYPE
    INDEX BY BINARY_INTEGER;

    l_txl_ar_inv_lns_tbl    txl_ar_inv_lins_tbl;
    l_txl_ar_inv_lns_tl_tbl txl_ar_inv_lns_tl_tbl;
    l_txd_ar_inv_ln_dtls_tbl txd_ar_inv_ln_dtls_tbl;
    i                       NUMBER;
    k                       NUMBER;
    l_bulk_err_cnt          NUMBER;
    l_source_language       fnd_languages.language_code%TYPE;
    lx_taiv_rec         Okl_Trx_Ar_Invoices_Pub.taiv_rec_type;
    l_inv_org_id        NUMBER;

    -- sechawla 28-may-2008 6619311
    l_cust_trx_type_id      NUMBER;
    l_cm_try_id 		    Okl_Trx_Ar_Invoices_V.try_id%TYPE;

    --akrangan ebtax billing impacts coding end

    -- Bug 9067996

    CURSOR inv_frmt_csr(cp_khr_id IN NUMBER) IS
    SELECT to_number(rul.rule_information1), --inf.id, --sechawla 26-may-09 6826580
           rul.rule_information4 review_invoice_yn
    FROM okc_rule_groups_v rgp,
         okc_rules_v rul
    --,  okl_invoice_formats_v inf --sechawla 26-may-09 6826580
    WHERE rgp.dnz_chr_id = cp_khr_id
    AND rgp.chr_id = rgp.dnz_chr_id
    AND rgp.id = rul.rgp_id
    AND rgp.cle_id IS NULL
    AND rgp.rgd_code = 'LABILL'
    AND rul.rule_information_category = 'LAINVD';
    -- End -- Bug 906799

  BEGIN

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => l_api_version,
			p_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;
    -- Populate Billing Header Record
    lp_taiv_rec := l_init_taiv_rec;

    lp_taiv_rec.khr_id := p_khr_id;
    lp_taiv_rec.amount := l_zero_amount; --sechawla 13-may-2008 6619311 : This amount will be updated later with
    	     							 -- total amount on invoice lines.

    -- sechawla 13-may-2008 6619311 : get both billing and Credit Memo trx type IDs
    l_billing_try_id := get_trx_type ('Billing', 'US');
    l_cm_try_id := get_trx_type ('Credit Memo', 'US');

    lp_taiv_rec.try_id := l_billing_try_id; -- sechawla 13-may-2008 6619311 : This try_id will get updated later
                                            -- to Credit Memo, if total tax amount is negative
    lp_taiv_rec.trx_status_code := 'SUBMITTED';
    lp_taiv_rec.date_invoiced := p_invoice_date;
    lp_taiv_rec.date_entered := SYSDATE;
    lp_taiv_rec.description := 'Upfront Tax Billing';
    lp_taiv_rec.okl_source_billing_trx := 'TAX_ONLY_INVOICE_TAX';
    --akrangan added for tax only invoice changes begin
    --get inv org and org
    OPEN inv_org_id_csr(p_khr_id);
    FETCH inv_org_id_csr
      INTO  l_inv_org_id ,
            lp_taiv_rec.org_id;
    CLOSE inv_org_id_csr;
    --akrangan added for tax only invoice changes end
    --akrangan added for populating additional attributes for taiv_rec start
    --The Additional Attributes are required attributes for populatiing
    -- RA interface tables
    additional_tai_attr(
                         p_api_version    =>  l_api_version
                        ,p_init_msg_list  =>  p_init_msg_list
                        ,x_return_status  =>  x_return_status
                        ,x_msg_count     => x_msg_count
                        ,x_msg_data      => x_msg_data
                        ,p_taiv_rec      => lp_taiv_rec
                        ,x_taiv_rec      => lx_taiv_rec
                        );
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --akrangan added for populating additional attributes for taiv_rec end
    -- Create Billing Header Record


    OKL_TRX_AR_INVOICES_PUB.insert_trx_ar_invoices(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_taiv_rec      => lx_taiv_rec
     ,x_taiv_rec      => xp_taiv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;


    OPEN upfront_tax_csr(p_khr_id => p_khr_id);
    FETCH upfront_tax_csr INTO upfront_tax_rec;
    CLOSE upfront_tax_csr;
    --akrangan ebtax billing impacts coding start
    l_sty_id := to_number(upfront_tax_rec.rule_information2);
    OPEN l_upfront_tax_treatment_csr(cp_khr_id => p_khr_id);
    FETCH l_upfront_tax_treatment_csr INTO l_upfront_tax_treatment_rec;
    CLOSE l_upfront_tax_treatment_csr;

    --contract level asset upfront tax is set to billed
    l_txl_ar_inv_lns_tbl.DELETE;
    i := 1;
    k := 1;
    l_total_tax_amt := 0; --sechawla 13-may-2008 6619311
    IF (l_upfront_tax_treatment_rec.asset_upfront_tax = 'BILLED')
    THEN
      -- Loop through the taxable lines
      FOR l_allbilledtaxablelines_rec IN l_allbilledtaxablelines_csr(p_khr_id,
                                                                     p_trx_id)
		  LOOP
          --sechawla 13-may-2008 6619311 : added this cursor for loop
          --for each taxable line, create as many invoice lines as the number of tax lines.
          --All invoice lines go under a single invoice header.
          --Each invoice line corresponds to the tax line that needs to be billed

          --Loop through tax lines for each taxable line
          FOR zx_lines_rec IN zx_lines_csr(l_allbilledtaxablelines_rec.trx_id,
		                                   l_allbilledtaxablelines_rec.trx_line_id,
										   l_allbilledtaxablelines_rec.application_id,
	                                       l_allbilledtaxablelines_rec.event_class_code,
										   l_allbilledtaxablelines_rec.entity_code ,
										   l_allbilledtaxablelines_rec.trx_level_type)


	          LOOP
               -- Populate Billing Line Tbl
               	l_txl_ar_inv_lns_tbl(i).id := okc_p_util.raw_to_number(sys_guid());
        		l_txl_ar_inv_lns_tbl(i).kle_id := l_allbilledtaxablelines_rec.kle_id;
        		l_txl_ar_inv_lns_tbl(i).amount := zx_lines_rec.tax_amt; --sechawla 13-may-2008 6619311 : changed to store tax amount instead of 0

			    --sechawla 13-may-2008 6619311 : calculate total tax to store on the header
				l_total_tax_amt := l_total_tax_amt + zx_lines_rec.tax_amt;

				l_txl_ar_inv_lns_tbl(i).tai_id := xp_taiv_rec.id;
        		l_txl_ar_inv_lns_tbl(i).sty_id := l_sty_id;
        		l_txl_ar_inv_lns_tbl(i).inv_receiv_line_code := l_line_code;
        		l_txl_ar_inv_lns_tbl(i).line_number := i;
        		l_txl_ar_inv_lns_tbl(i).txs_trx_id := l_allbilledtaxablelines_rec.trx_id;
        		l_txl_ar_inv_lns_tbl(i).txs_trx_line_id := l_allbilledtaxablelines_rec.trx_line_id;
        		l_txl_ar_inv_lns_tbl(i).txl_ar_line_number := i;
        		l_txl_ar_inv_lns_tbl(i).org_id := l_allbilledtaxablelines_rec.org_id;
        		l_txl_ar_inv_lns_tbl(i).created_by := g_user_id;
        		l_txl_ar_inv_lns_tbl(i).creation_date := SYSDATE;
        		l_txl_ar_inv_lns_tbl(i).last_updated_by := g_user_id;
        		l_txl_ar_inv_lns_tbl(i).last_update_date := SYSDATE;
        		l_txl_ar_inv_lns_tbl(i).last_update_login := g_login_id;
        		l_txl_ar_inv_lns_tbl(i).isl_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).ibt_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).tpl_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).cll_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).acn_id_cost := NULL;
        		l_txl_ar_inv_lns_tbl(i).til_id_reverses := NULL;
        		l_txl_ar_inv_lns_tbl(i).object_version_number := 1;
        		l_txl_ar_inv_lns_tbl(i).quantity := 1;
        		l_txl_ar_inv_lns_tbl(i).receivables_invoice_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).late_charge_rec_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).amount_applied := NULL;
        		l_txl_ar_inv_lns_tbl(i).date_bill_period_start := NULL;
        		l_txl_ar_inv_lns_tbl(i).date_bill_period_end := NULL;
        		l_txl_ar_inv_lns_tbl(i).request_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_application_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_update_date := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute_category := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute1 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute2 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute3 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute4 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute5 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute6 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute7 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute8 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute9 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute10 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute11 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute12 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute13 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute14 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute15 := NULL;
        		l_txl_ar_inv_lns_tbl(i).inventory_item_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).inventory_org_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).bank_acct_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).qte_line_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).upgrade_from_two_level_yn := NULL;

        		--sechawla 13-may-2008 6619311 : store the corresponding tax line reference on each invoice line
        		l_txl_ar_inv_lns_tbl(i).tax_line_id := zx_lines_rec.tax_line_id;

				--populate line detail table
        		l_txd_ar_inv_ln_dtls_tbl(i).id := okc_p_util.raw_to_number(sys_guid());
        		l_txd_ar_inv_ln_dtls_tbl(i).object_version_number := 1;
        		l_txd_ar_inv_ln_dtls_tbl(i).created_by := g_user_id;
        		l_txd_ar_inv_ln_dtls_tbl(i).creation_date := SYSDATE;
        		l_txd_ar_inv_ln_dtls_tbl(i).last_updated_by := g_user_id;
        		l_txd_ar_inv_ln_dtls_tbl(i).last_update_date := SYSDATE;
        		l_txd_ar_inv_ln_dtls_tbl(i).til_id_details := l_txl_ar_inv_lns_tbl(i).id;
				l_txd_ar_inv_ln_dtls_tbl(i).sty_id := l_sty_id;
				--added additional attribute tld rec
				l_txd_ar_inv_ln_dtls_tbl(i).amount  := zx_lines_rec.tax_amt; --sechawla 13-may-2008 6619311 : changed to store tax amount instead of 0;
				l_txd_ar_inv_ln_dtls_tbl(i).inventory_org_id := l_inv_org_id;

                --28-May-2008 sechawla 6619311 : populate khr_id and kle_id
                l_txd_ar_inv_ln_dtls_tbl(i).khr_id := p_khr_id;
                l_txd_ar_inv_ln_dtls_tbl(i).kle_id := l_allbilledtaxablelines_rec.kle_id;
                --

                -- Bug 9067996
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inf id:'||lx_taiv_rec.inf_id);
                END IF;

                OKL_INTERNAL_BILLING_PVT.Get_Invoice_format(
                             p_api_version                  => p_api_version
                            ,p_init_msg_list                => OKL_API.G_FALSE
                            ,x_return_status                => l_return_status
                            ,x_msg_count                    => x_msg_count
                            ,x_msg_data                     => x_msg_data
                            ,p_inf_id                       => lx_taiv_rec.inf_id
                            ,p_sty_id                       => l_sty_id
                            ,x_invoice_format_type          => l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_type
                            ,x_invoice_format_line_type     => l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_line_type);
                --Print Input Variables
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'invoice format type :'||l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_type);
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'invoice format line type :'||l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_line_type);
                END IF;

                -- End Bug 9067996

        		--tl table record population
				FOR l_fndlanguage_rec IN l_fndlanguage_csr
        		LOOP
          			l_txl_ar_inv_lns_tl_tbl(k).id := l_txl_ar_inv_lns_tbl(i).id;
          			IF k = 1 THEN
            		--- Base language
            			l_source_language := l_fndlanguage_rec.language_code;
          			END IF;
          			l_txl_ar_inv_lns_tl_tbl(k).LANGUAGE := l_fndlanguage_rec.language_code;
          			l_txl_ar_inv_lns_tl_tbl(k).source_lang := l_source_language;
          			l_txl_ar_inv_lns_tl_tbl(k).sfwt_flag := 'N';
          			l_txl_ar_inv_lns_tl_tbl(k).description := l_def_desc;
          			l_txl_ar_inv_lns_tl_tbl(k).created_by := g_user_id;
          			l_txl_ar_inv_lns_tl_tbl(k).creation_date := SYSDATE;
          			l_txl_ar_inv_lns_tl_tbl(k).last_updated_by := g_user_id;
          			l_txl_ar_inv_lns_tl_tbl(k).last_update_date := SYSDATE;
          			l_txl_ar_inv_lns_tl_tbl(k).last_update_login := g_login_id;
          			l_txl_ar_inv_lns_tl_tbl(k).error_message := NULL;
          			--increment the looping variable
          			k := k + 1;
        		END LOOP;
        		--increment the looping variable
        		i := i + 1;
      		  END LOOP;
      		END LOOP; --sechawla 13-may-2008 6619311 :Added
    ELSE -- total_billed_tax <>0 Asset upfront tax treatment at the hdr level <> 'BILLED'

      -- Loop through the taxable lines
      FOR l_billedtaxablelines_rec IN l_billedtaxablelines_csr(p_khr_id,
                                                               p_trx_id)
      LOOP
           --sechawla 13-may-2008 6619311 : added this cursor for loop
           -- Loop through the tax lines
          FOR zx_lines_rec IN zx_lines_csr(l_billedtaxablelines_rec.trx_id,
		                                   l_billedtaxablelines_rec.trx_line_id,
										   l_billedtaxablelines_rec.application_id,
	                                       l_billedtaxablelines_rec.event_class_code,
										   l_billedtaxablelines_rec.entity_code ,
										   l_billedtaxablelines_rec.trx_level_type)


	          LOOP

        		-- Populate Billing Line Tbl
        		l_txl_ar_inv_lns_tbl(i).id := okc_p_util.raw_to_number(sys_guid());
        		l_txl_ar_inv_lns_tbl(i).kle_id := l_billedtaxablelines_rec.kle_id;
        		l_txl_ar_inv_lns_tbl(i).amount := zx_lines_rec.tax_amt;--sechawla 13-may-2008 6619311 : changed to store tax amount instead of 0

        		--sechawla 13-may-2008 6619311 : calculate total tax to store on the header
				l_total_tax_amt := l_total_tax_amt + zx_lines_rec.tax_amt;

				l_txl_ar_inv_lns_tbl(i).tai_id := xp_taiv_rec.id;
        		l_txl_ar_inv_lns_tbl(i).sty_id := l_sty_id;
        		l_txl_ar_inv_lns_tbl(i).inv_receiv_line_code := l_line_code;
        		l_txl_ar_inv_lns_tbl(i).line_number := i;
        		l_txl_ar_inv_lns_tbl(i).txs_trx_id := l_billedtaxablelines_rec.trx_id;
        		l_txl_ar_inv_lns_tbl(i).txs_trx_line_id := l_billedtaxablelines_rec.trx_line_id;
        		l_txl_ar_inv_lns_tbl(i).txl_ar_line_number := i;
        		l_txl_ar_inv_lns_tbl(i).org_id := l_billedtaxablelines_rec.org_id;
        		l_txl_ar_inv_lns_tbl(i).created_by := g_user_id;
        		l_txl_ar_inv_lns_tbl(i).creation_date := SYSDATE;
        		l_txl_ar_inv_lns_tbl(i).last_updated_by := g_user_id;
        		l_txl_ar_inv_lns_tbl(i).last_update_date := SYSDATE;
        		l_txl_ar_inv_lns_tbl(i).last_update_login := g_login_id;
        		l_txl_ar_inv_lns_tbl(i).isl_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).ibt_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).tpl_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).cll_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).acn_id_cost := NULL;
        		l_txl_ar_inv_lns_tbl(i).til_id_reverses := NULL;
        		l_txl_ar_inv_lns_tbl(i).object_version_number := 1;
        		l_txl_ar_inv_lns_tbl(i).quantity := 1;
        		l_txl_ar_inv_lns_tbl(i).receivables_invoice_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).late_charge_rec_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).amount_applied := NULL;
        		l_txl_ar_inv_lns_tbl(i).date_bill_period_start := NULL;
        		l_txl_ar_inv_lns_tbl(i).date_bill_period_end := NULL;
        		l_txl_ar_inv_lns_tbl(i).request_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_application_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).program_update_date := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute_category := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute1 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute2 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute3 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute4 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute5 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute6 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute7 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute8 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute9 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute10 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute11 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute12 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute13 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute14 := NULL;
        		l_txl_ar_inv_lns_tbl(i).attribute15 := NULL;
        		l_txl_ar_inv_lns_tbl(i).inventory_item_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).inventory_org_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).bank_acct_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).qte_line_id := NULL;
        		l_txl_ar_inv_lns_tbl(i).upgrade_from_two_level_yn := NULL;

        		l_txl_ar_inv_lns_tbl(i).tax_line_id := zx_lines_rec.tax_line_id;--sechawla 13-may-2008 6619311 :Added

				--populate line detail table
        		l_txd_ar_inv_ln_dtls_tbl(i).id := okc_p_util.raw_to_number(sys_guid());
        		l_txd_ar_inv_ln_dtls_tbl(i).object_version_number := 1;
        		l_txd_ar_inv_ln_dtls_tbl(i).created_by := g_user_id;
        		l_txd_ar_inv_ln_dtls_tbl(i).creation_date := SYSDATE;
        		l_txd_ar_inv_ln_dtls_tbl(i).last_updated_by := g_user_id;
        		l_txd_ar_inv_ln_dtls_tbl(i).last_update_date := SYSDATE;
        		l_txd_ar_inv_ln_dtls_tbl(i).til_id_details := l_txl_ar_inv_lns_tbl(i).id;
				l_txd_ar_inv_ln_dtls_tbl(i).sty_id := l_sty_id;
				--added additional attribute tld rec
				l_txd_ar_inv_ln_dtls_tbl(i).amount  := zx_lines_rec.tax_amt; --sechawla 13-may-2008 6619311 : changed to store tax amount instead of 0;
				l_txd_ar_inv_ln_dtls_tbl(i).inventory_org_id := l_inv_org_id;

				--28-May-2008 sechawla 6619311 : populate khr_id and kle_id
                l_txd_ar_inv_ln_dtls_tbl(i).khr_id := p_khr_id;
                l_txd_ar_inv_ln_dtls_tbl(i).kle_id := l_billedtaxablelines_rec.kle_id;
                --
                -- -- Bug 9067996
                IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Inf id:'||lx_taiv_rec.inf_id);
                END IF;

                OKL_INTERNAL_BILLING_PVT.Get_Invoice_format(
                             p_api_version                  => p_api_version
                            ,p_init_msg_list                => OKL_API.G_FALSE
                            ,x_return_status                => l_return_status
                            ,x_msg_count                    => x_msg_count
                            ,x_msg_data                     => x_msg_data
                            ,p_inf_id                       => lx_taiv_rec.inf_id
                            ,p_sty_id                       => l_sty_id
                            ,x_invoice_format_type          => l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_type
                            ,x_invoice_format_line_type     => l_txd_ar_inv_ln_dtls_tbl(i).invoice_format_line_type);
               -- End Bug 9067996

				--language tl table tbl population
        		FOR l_fndlanguage_rec IN l_fndlanguage_csr
        		LOOP
          			l_txl_ar_inv_lns_tl_tbl(k).id := l_txl_ar_inv_lns_tbl(i).id;
          			IF k = 1 THEN
            			--- Base language
            			l_source_language := l_fndlanguage_rec.language_code;
          			END IF;
          			l_txl_ar_inv_lns_tl_tbl(k).LANGUAGE := l_fndlanguage_rec.language_code;
          			l_txl_ar_inv_lns_tl_tbl(k).source_lang := l_source_language;
          			l_txl_ar_inv_lns_tl_tbl(k).sfwt_flag := 'N';
          			l_txl_ar_inv_lns_tl_tbl(k).description := l_def_desc;
          			l_txl_ar_inv_lns_tl_tbl(k).created_by := g_user_id;
          			l_txl_ar_inv_lns_tl_tbl(k).creation_date := SYSDATE;
          			l_txl_ar_inv_lns_tl_tbl(k).last_updated_by := g_user_id;
          			l_txl_ar_inv_lns_tl_tbl(k).last_update_date := SYSDATE;
          			l_txl_ar_inv_lns_tl_tbl(k).last_update_login := g_login_id;
          			l_txl_ar_inv_lns_tl_tbl(k).error_message := NULL;
          			--increment the looping variable
          			k := k + 1;
        		END LOOP;
        		--increment the looping variable
        		i := i + 1;
      		END LOOP;
      	END LOOP;
    END IF;


    --sechawla 13-may-2008 6619311 : Update the invoice header after total tax has been derived.
    lp_taiv_rec := lp_empty_taiv_rec;
    lx_taiv_rec := lp_empty_taiv_rec;

    --28-May-2008 sechawla 6619311
    --Moved the following code from additional_tai_attr so that corrcet trx type can be derived
    --after calculating the total tax amount.
    IF l_total_tax_amt < 0 THEN
        lp_taiv_rec.irt_id := NULL;

        OPEN  cm_trx_type_csr(xp_taiv_rec.set_of_books_id, xp_taiv_rec.org_id);
        FETCH cm_trx_type_csr INTO l_cust_trx_type_id;
        CLOSE cm_trx_type_csr;

        lp_taiv_rec.try_id := l_cm_try_id; --28-May-2008 sechawla 6619311
    ELSE

        OPEN  cust_trx_type_csr(xp_taiv_rec.set_of_books_id, xp_taiv_rec.org_id);
        FETCH cust_trx_type_csr INTO l_cust_trx_type_id;
        CLOSE cust_trx_type_csr;
    END IF;

    lp_taiv_rec.id := xp_taiv_rec.id;
    lp_taiv_rec.amount := l_total_tax_amt;
    lp_taiv_rec.cust_trx_type_id := l_cust_trx_type_id;

    OKL_TRX_AR_INVOICES_PUB.update_trx_ar_invoices(
      p_api_version   => p_api_version
     ,p_init_msg_list => p_init_msg_list
     ,x_return_status => x_return_status
     ,x_msg_count     => x_msg_count
     ,x_msg_data      => x_msg_data
     ,p_taiv_rec      => lp_taiv_rec
     ,x_taiv_rec      => lx_taiv_rec);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
      raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
      raise OKL_API.G_EXCEPTION_ERROR;
    END IF;


    --use for all i loop and bulk insert into invoice lines table
    ---Bulk insert into okl_txl_ar_inv_lns_b
    BEGIN
      IF l_txl_ar_inv_lns_tbl.COUNT > 0
      THEN
        FORALL i IN l_txl_ar_inv_lns_tbl.FIRST .. l_txl_ar_inv_lns_tbl.LAST save
                                                  exceptions
          INSERT INTO okl_txl_ar_inv_lns_b
          VALUES l_txl_ar_inv_lns_tbl(i);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF SQL%bulk_exceptions.COUNT > 0
        THEN
          FOR i IN 1 .. SQL%bulk_exceptions.COUNT
          LOOP
            okl_api.set_message(p_app_name     => 'OKL',
                                p_msg_name     => 'OKL_TX_TRX_INS_ERR',
                                p_token1       => 'TABLE_NAME',
                                p_token1_value => 'OKL_TXL_AR_INV_LNS_B',
                                p_token2       => 'ERROR_CODE',
                                p_token2_value => SQLERRM(-sql%bulk_exceptions(i)
                                                          .error_code),
                                p_token3       => 'ITERATION',
                                p_token3_value => SQL%bulk_exceptions(i)
                                                 .error_index);
          END LOOP;
          x_return_status := okl_api.g_ret_sts_error;
          RAISE okl_api.g_exception_error;
        END IF;
    END;
    --invoice line details population
    BEGIN
      IF l_txd_ar_inv_ln_dtls_tbl.COUNT > 0
      THEN
        FORALL i IN l_txd_ar_inv_ln_dtls_tbl.FIRST .. l_txd_ar_inv_ln_dtls_tbl.LAST save
                                                     exceptions
          INSERT INTO OKL_TXD_AR_LN_DTLS_B
          VALUES l_txd_ar_inv_ln_dtls_tbl(i);
      END IF;

      FOR m in l_txd_ar_inv_ln_dtls_tbl.first..l_txd_ar_inv_ln_dtls_tbl.last LOOP
      INSERT INTO okl_txd_ar_ln_dtls_tl(
             ID,
             LANGUAGE,
             SOURCE_LANG,
             SFWT_FLAG,
             DESCRIPTION,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             ERROR_MESSAGE)
            SELECT tld.ID,
                   l.language_code,
                   userenv('LANG'),
                    'N',
                   l_def_desc,
                   g_user_id,
                   sysdate,
                   g_user_id,
                   sysdate,
                   g_login_id,
                  null
            FROM  okl_txd_ar_ln_dtls_b tld, fnd_languages l
            WHERE l.installed_flag IN ('I', 'B')
            and   tld.id = l_txd_ar_inv_ln_dtls_tbl(m).id ;
       END LOOP;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQL%bulk_exceptions.COUNT > 0
        THEN
          FOR i IN 1 .. SQL%bulk_exceptions.COUNT
          LOOP
            okl_api.set_message(p_app_name     => 'OKL',
                                p_msg_name     => 'OKL_TX_TRX_INS_ERR',
                                p_token1       => 'TABLE_NAME',
                                p_token1_value => 'OKL_TXD_AR_LN_DTLS_B',
                                p_token2       => 'ERROR_CODE',
                                p_token2_value => SQLERRM(-sql%bulk_exceptions(i)
                                                          .error_code),
                                p_token3       => 'ITERATION',
                                p_token3_value => SQL%bulk_exceptions(i)
                                                 .error_index);
          END LOOP;
          x_return_status := okl_api.g_ret_sts_error;
          RAISE okl_api.g_exception_error;
        END IF;
    END;
    --Bulk insert into okl_txl_ar_inv_lns_tl
    --tl table insert
    BEGIN
      IF l_txl_ar_inv_lns_tl_tbl.COUNT > 0
      THEN
        FORALL i IN l_txl_ar_inv_lns_tl_tbl.FIRST .. l_txl_ar_inv_lns_tl_tbl.LAST save
                                                     exceptions
          INSERT INTO okl_txl_ar_inv_lns_tl
          VALUES l_txl_ar_inv_lns_tl_tbl(i);
      END IF;

    EXCEPTION
      WHEN OTHERS THEN
        IF SQL%bulk_exceptions.COUNT > 0
        THEN
          FOR i IN 1 .. SQL%bulk_exceptions.COUNT
          LOOP
            okl_api.set_message(p_app_name     => 'OKL',
                                p_msg_name     => 'OKL_TX_TRX_INS_ERR',
                                p_token1       => 'TABLE_NAME',
                                p_token1_value => 'OKL_TXL_AR_INV_LNS_B',
                                p_token2       => 'ERROR_CODE',
                                p_token2_value => SQLERRM(-sql%bulk_exceptions(i)
                                                          .error_code),
                                p_token3       => 'ITERATION',
                                p_token3_value => SQL%bulk_exceptions(i)
                                                 .error_index);
          END LOOP;
          x_return_status := okl_api.g_ret_sts_error;
          RAISE okl_api.g_exception_error;
        END IF;
    END;
    --line details table
    --akrangan ebtax billing impacts coding ends

      -- Bug 9523844
      IF lx_taiv_rec.trx_status_code =  'SUBMITTED' THEN

       IF l_txd_ar_inv_ln_dtls_tbl.COUNT > 0 THEN
         FOR n in l_txd_ar_inv_ln_dtls_tbl.first..l_txd_ar_inv_ln_dtls_tbl.last LOOP
           l_tldv_tbl(n).id := l_txd_ar_inv_ln_dtls_tbl(n).id;
           l_tldv_tbl(n).object_version_number  := l_txd_ar_inv_ln_dtls_tbl(n).object_version_number ;
           --l_tldv_tbl(n).error_message        := l_txd_ar_inv_ln_dtls_tbl(n).error_message       ;
           --l_tldv_tbl(n).sfwt_flag    := l_txd_ar_inv_ln_dtls_tbl(n).sfwt_flag   ;
           l_tldv_tbl(n).bch_id       := l_txd_ar_inv_ln_dtls_tbl(n).bch_id      ;
           l_tldv_tbl(n).bgh_id     := l_txd_ar_inv_ln_dtls_tbl(n).bgh_id    ;
           l_tldv_tbl(n).idx_id     := l_txd_ar_inv_ln_dtls_tbl(n).idx_id    ;
           l_tldv_tbl(n).tld_id_reverses    := l_txd_ar_inv_ln_dtls_tbl(n).tld_id_reverses   ;
           l_tldv_tbl(n).sty_id     := l_txd_ar_inv_ln_dtls_tbl(n).sty_id    ;
           l_tldv_tbl(n).sel_id     := l_txd_ar_inv_ln_dtls_tbl(n).sel_id    ;
           l_tldv_tbl(n).til_id_details     := l_txd_ar_inv_ln_dtls_tbl(n).til_id_details    ;
           l_tldv_tbl(n).bcl_id     := l_txd_ar_inv_ln_dtls_tbl(n).bcl_id    ;
           l_tldv_tbl(n).bsl_id     := l_txd_ar_inv_ln_dtls_tbl(n).bsl_id    ;
           l_tldv_tbl(n).amount     := l_txd_ar_inv_ln_dtls_tbl(n).amount    ;
           l_tldv_tbl(n).line_detail_number     := l_txd_ar_inv_ln_dtls_tbl(n).line_detail_number    ;
           l_tldv_tbl(n).receivables_invoice_id    := l_txd_ar_inv_ln_dtls_tbl(n).receivables_invoice_id   ;
           l_tldv_tbl(n).late_charge_yn    := l_txd_ar_inv_ln_dtls_tbl(n).late_charge_yn   ;
           --l_tldv_tbl(n).description       := l_txd_ar_inv_ln_dtls_tbl(n).description      ;
           l_tldv_tbl(n).amount_applied    := l_txd_ar_inv_ln_dtls_tbl(n).amount_applied   ;
           l_tldv_tbl(n).date_calculation  := l_txd_ar_inv_ln_dtls_tbl(n).date_calculation ;
           l_tldv_tbl(n).fixed_rate_yn     := l_txd_ar_inv_ln_dtls_tbl(n).fixed_rate_yn    ;
           l_tldv_tbl(n).inventory_item_id := l_txd_ar_inv_ln_dtls_tbl(n).inventory_item_id;
           l_tldv_tbl(n).	attribute_category        := l_txd_ar_inv_ln_dtls_tbl(n).	attribute_category       ;
           l_tldv_tbl(n).attribute1        := l_txd_ar_inv_ln_dtls_tbl(n).attribute1       ;
           l_tldv_tbl(n).attribute2        := l_txd_ar_inv_ln_dtls_tbl(n).attribute2       ;
           l_tldv_tbl(n).attribute3        := l_txd_ar_inv_ln_dtls_tbl(n).attribute3       ;
           l_tldv_tbl(n).attribute4        := l_txd_ar_inv_ln_dtls_tbl(n).attribute4       ;
           l_tldv_tbl(n).attribute5        := l_txd_ar_inv_ln_dtls_tbl(n).attribute5       ;
           l_tldv_tbl(n).attribute6        := l_txd_ar_inv_ln_dtls_tbl(n).attribute6       ;
           l_tldv_tbl(n).attribute7        := l_txd_ar_inv_ln_dtls_tbl(n).attribute7       ;
           l_tldv_tbl(n).attribute8        := l_txd_ar_inv_ln_dtls_tbl(n).attribute8       ;
           l_tldv_tbl(n).attribute9        := l_txd_ar_inv_ln_dtls_tbl(n).attribute9       ;
           l_tldv_tbl(n).attribute10       := l_txd_ar_inv_ln_dtls_tbl(n).attribute10      ;
           l_tldv_tbl(n).attribute11       := l_txd_ar_inv_ln_dtls_tbl(n).attribute11      ;
           l_tldv_tbl(n).attribute12       := l_txd_ar_inv_ln_dtls_tbl(n).attribute12      ;
           l_tldv_tbl(n).attribute13       := l_txd_ar_inv_ln_dtls_tbl(n).attribute13      ;
           l_tldv_tbl(n).attribute14       := l_txd_ar_inv_ln_dtls_tbl(n).attribute14      ;
           l_tldv_tbl(n).attribute15       := l_txd_ar_inv_ln_dtls_tbl(n).attribute15      ;
           l_tldv_tbl(n).request_id        := l_txd_ar_inv_ln_dtls_tbl(n).request_id       ;
           l_tldv_tbl(n).program_application_id        := l_txd_ar_inv_ln_dtls_tbl(n).program_application_id       ;
           l_tldv_tbl(n).program_id   := l_txd_ar_inv_ln_dtls_tbl(n).program_id  ;
           l_tldv_tbl(n).program_update_date  := l_txd_ar_inv_ln_dtls_tbl(n).program_update_date ;
           l_tldv_tbl(n).org_id       := l_txd_ar_inv_ln_dtls_tbl(n).org_id      ;
           l_tldv_tbl(n).inventory_org_id     := l_txd_ar_inv_ln_dtls_tbl(n).inventory_org_id    ;
           l_tldv_tbl(n).created_by   := l_txd_ar_inv_ln_dtls_tbl(n).created_by  ;
           l_tldv_tbl(n).creation_date        := l_txd_ar_inv_ln_dtls_tbl(n).creation_date       ;
           l_tldv_tbl(n).last_updated_by      := l_txd_ar_inv_ln_dtls_tbl(n).last_updated_by     ;
           l_tldv_tbl(n).last_update_date     := l_txd_ar_inv_ln_dtls_tbl(n).last_update_date    ;
           l_tldv_tbl(n).last_update_login    := l_txd_ar_inv_ln_dtls_tbl(n).last_update_login   ;
           l_tldv_tbl(n).TXL_AR_LINE_NUMBER   := l_txd_ar_inv_ln_dtls_tbl(n).TXL_AR_LINE_NUMBER  ;
           l_tldv_tbl(n).INVOICE_FORMAT_TYPE  := l_txd_ar_inv_ln_dtls_tbl(n).INVOICE_FORMAT_TYPE ;
           l_tldv_tbl(n).INVOICE_FORMAT_LINE_TYPE     := l_txd_ar_inv_ln_dtls_tbl(n).INVOICE_FORMAT_LINE_TYPE    ;
           l_tldv_tbl(n).LATE_CHARGE_ASSESS_DATE      := l_txd_ar_inv_ln_dtls_tbl(n).LATE_CHARGE_ASSESS_DATE     ;
           l_tldv_tbl(n).LATE_INT_ASSESS_DATE := l_txd_ar_inv_ln_dtls_tbl(n).LATE_INT_ASSESS_DATE;
           l_tldv_tbl(n).LATE_CHARGE_ASS_YN   := l_txd_ar_inv_ln_dtls_tbl(n).LATE_CHARGE_ASS_YN  ;
           l_tldv_tbl(n).LATE_INT_ASS_YN      := l_txd_ar_inv_ln_dtls_tbl(n).LATE_INT_ASS_YN     ;
           l_tldv_tbl(n).INVESTOR_DISB_STATUS := l_txd_ar_inv_ln_dtls_tbl(n).INVESTOR_DISB_STATUS;
           l_tldv_tbl(n).INVESTOR_DISB_ERR_MG := l_txd_ar_inv_ln_dtls_tbl(n).INVESTOR_DISB_ERR_MG;
           l_tldv_tbl(n).DATE_DISBURSED       := l_txd_ar_inv_ln_dtls_tbl(n).DATE_DISBURSED      ;
           l_tldv_tbl(n).PAY_STATUS_CODE      := l_txd_ar_inv_ln_dtls_tbl(n).PAY_STATUS_CODE     ;
           l_tldv_tbl(n).RBK_ORI_INVOICE_NUMBER       := l_txd_ar_inv_ln_dtls_tbl(n).RBK_ORI_INVOICE_NUMBER      ;
           l_tldv_tbl(n).RBK_ORI_INVOICE_LINE_NUMBER  := l_txd_ar_inv_ln_dtls_tbl(n).RBK_ORI_INVOICE_LINE_NUMBER ;
           l_tldv_tbl(n).RBK_ADJUSTMENT_DATE  := l_txd_ar_inv_ln_dtls_tbl(n).RBK_ADJUSTMENT_DATE ;
           l_tldv_tbl(n).KHR_ID       := l_txd_ar_inv_ln_dtls_tbl(n).KHR_ID      ;
           l_tldv_tbl(n).KLE_ID       := l_txd_ar_inv_ln_dtls_tbl(n).KLE_ID      ;
           l_tldv_tbl(n).TAX_AMOUNT  := l_txd_ar_inv_ln_dtls_tbl(n).TAX_AMOUNT ;
         END LOOP;

         OKL_INTERNAL_BILLING_PVT.create_accounting_dist(p_api_version   => p_api_version ,
                                   p_init_msg_list => p_init_msg_list ,
                                   x_return_status => x_return_status ,
                                   x_msg_count     => x_msg_count ,
                                   x_msg_data      => x_msg_data ,
                                   p_tldv_tbl      => l_tldv_tbl,
                                   p_tai_id        => lx_taiv_rec.ID
                                   );

         IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
           IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             x_return_status := x_return_status;
           END IF;
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         END IF;
        END IF;
      END IF;
      -- End Bug 9523844

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data	 => x_msg_data);

    EXCEPTION
	WHEN OKL_API.G_EXCEPTION_ERROR THEN

	    --sechawla 13-may-2008 6619311
	    IF zx_lines_csr%ISOPEN THEN
	       CLOSE zx_lines_csr;
	    END IF;

	    IF inv_org_id_csr%ISOPEN THEN
	       CLOSE inv_org_id_csr;
	    END IF;

	    IF l_fndlanguage_csr%ISOPEN THEN
	       CLOSE l_fndlanguage_csr;
	    END IF;

	    IF l_billedtaxablelines_csr%ISOPEN THEN
	       CLOSE l_billedtaxablelines_csr;
	    END IF;

	    IF l_allbilledtaxablelines_csr%ISOPEN THEN
	       CLOSE l_allbilledtaxablelines_csr;
	    END IF;

	    IF l_upfront_tax_treatment_csr%ISOPEN THEN
	       CLOSE l_upfront_tax_treatment_csr;
	    END IF;

	    IF upfront_tax_csr%ISOPEN THEN
	       CLOSE upfront_tax_csr;
	    END IF;

	    --28-May-2008 sechawla 6619311
        IF cm_trx_type_csr%ISOPEN THEN
           CLOSE cm_trx_type_csr;
        END IF;

        IF cust_trx_type_csr%ISOPEN THEN
           CLOSE cust_trx_type_csr;
        END IF;

		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

	    --sechawla 13-may-2008 6619311
	    IF zx_lines_csr%ISOPEN THEN
	       CLOSE zx_lines_csr;
	    END IF;

	    IF inv_org_id_csr%ISOPEN THEN
	       CLOSE inv_org_id_csr;
	    END IF;

	    IF l_fndlanguage_csr%ISOPEN THEN
	       CLOSE l_fndlanguage_csr;
	    END IF;

	    IF l_billedtaxablelines_csr%ISOPEN THEN
	       CLOSE l_billedtaxablelines_csr;
	    END IF;

	    IF l_allbilledtaxablelines_csr%ISOPEN THEN
	       CLOSE l_allbilledtaxablelines_csr;
	    END IF;

	    IF l_upfront_tax_treatment_csr%ISOPEN THEN
	       CLOSE l_upfront_tax_treatment_csr;
	    END IF;

	    IF upfront_tax_csr%ISOPEN THEN
	       CLOSE upfront_tax_csr;
	    END IF;

	    --28-May-2008 sechawla 6619311
        IF cm_trx_type_csr%ISOPEN THEN
           CLOSE cm_trx_type_csr;
        END IF;

        IF cust_trx_type_csr%ISOPEN THEN
           CLOSE cust_trx_type_csr;
        END IF;

		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

	WHEN OTHERS THEN
	    --sechawla 13-may-2008 6619311
	    IF zx_lines_csr%ISOPEN THEN
	       CLOSE zx_lines_csr;
	    END IF;

	    IF inv_org_id_csr%ISOPEN THEN
	       CLOSE inv_org_id_csr;
	    END IF;

	    IF l_fndlanguage_csr%ISOPEN THEN
	       CLOSE l_fndlanguage_csr;
	    END IF;

	    IF l_billedtaxablelines_csr%ISOPEN THEN
	       CLOSE l_billedtaxablelines_csr;
	    END IF;

	    IF l_allbilledtaxablelines_csr%ISOPEN THEN
	       CLOSE l_allbilledtaxablelines_csr;
	    END IF;

	    IF l_upfront_tax_treatment_csr%ISOPEN THEN
	       CLOSE l_upfront_tax_treatment_csr;
	    END IF;

	    IF upfront_tax_csr%ISOPEN THEN
	       CLOSE upfront_tax_csr;
	    END IF;

	    --28-May-2008 sechawla 6619311
        IF cm_trx_type_csr%ISOPEN THEN
           CLOSE cm_trx_type_csr;
        END IF;

        IF cust_trx_type_csr%ISOPEN THEN
           CLOSE cust_trx_type_csr;
        END IF;

      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);


  END Bill_Upfront_Tax;

END Okl_Bill_Upfront_Tax_Pvt;

/
