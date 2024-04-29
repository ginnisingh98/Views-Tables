--------------------------------------------------------
--  DDL for Package Body OKL_LA_SALES_TAX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LA_SALES_TAX_PVT" AS
 /* $Header: OKLRSTXB.pls 120.57.12010000.7 2010/04/06 13:20:24 smadhava ship $ */

  G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
  G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
  G_IS_DEBUG_STATEMENT_ON BOOLEAN;

  -- Common Cursors

  -- Cursor to check if the sales tax parameter(switch) is set to yes.
  CURSOR l_tax_system_info IS
  SELECT nvl(tax_upfront_yn,'N')
  FROM   okl_system_params;
  l_upfront_tax_yn VARCHAR2(1);


  -- R12 - START

  -- Global Cursor to get contract header linformation
  CURSOR Product_csr (p_contract_id OKC_K_HEADERS_B.ID%TYPE)
  IS
  SELECT  khr.pdt_id                    product_id
         ,NULL                          product_name
         ,khr.sts_code                  contract_status
         ,khr.start_date                start_date
         ,khr.currency_code             currency_code
         ,khr.authoring_org_id          authoring_org_id
         ,khr.currency_conversion_rate  currency_conversion_rate
         ,khr.currency_conversion_type  currency_conversion_type
         ,khr.currency_conversion_date  currency_conversion_date
         ,khr.scs_code                  scs_code
  FROM    okl_k_headers_full_v  khr
  WHERE   khr.id = p_contract_id;

  g_Product_rec      Product_csr%ROWTYPE;

  -- R12 - END


  -- Cursor to get Transaction type and status descriptions
  CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 ) IS
  select description,  lookup_code
  from   fnd_lookup_values
  where  language     = 'US'
  AND    lookup_type  = lkp_type
  AND    meaning      = mng;

  -- The following cursor checks if BILLED is selected on T and C, user should not
  -- select asset upfront tax to be FINANCED for some assets and CAPITALIZED
  -- for some. Both Financed and Capitalized fee lines cannot be created
  -- together for sales tax. We allow either Financed or Capitalize fee lines only

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR check_feetype_csr (p_contract_id IN NUMBER)
  IS
  SELECT NVL(rule_information11,'BILLED') feetype
  FROM   okc_rules_b rl,
         okc_rule_groups_b rgp,
         okc_k_lines_b cle
  WHERE  rl.dnz_chr_id                    = p_contract_id
  AND    rl.rule_information_category     = 'LAASTX'
  AND    NVL(rule_information11,'BILLED') <> 'BILLED'
  AND    rgp.id = rl.rgp_id
  AND    cle.id = rgp.cle_id
  AND    cle.sts_code <> 'ABANDONED';

  -- Cursor to get rule values
  CURSOR rule_info_csr (p_contract_id IN NUMBER)
  IS
  SELECT rule_information1,
         rule_information2,
         rule_information3,
         rule_information4,
         rule_information5
  FROM   okc_rules_b rl
  WHERE  rl.dnz_chr_id = p_contract_id
  AND    rl.rule_information_category = 'LASTPR';

  -- The following checks if all the lines have the asset upfront tax as
  -- selected on T and C. for instance,user might select  FINANCED or CAPITALIZED
  -- on T and C, but might do the opposite for all asset level taxes. If user
  -- selects FINANCED on T and C but bills all line taxes, we do not need
  -- to create fee lines at all

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR check_lines_csr (p_contract_id IN NUMBER, l_fee_type IN VARCHAR2 )
  IS
  SELECT count(NVL(rule_information11, l_fee_type))
  FROM   okc_rules_b rl,
         okc_rule_groups_b rgp,
         okc_k_lines_b cle
  WHERE  rl.dnz_chr_id = p_contract_id
  AND    rl.rule_information_category = 'LAASTX'
  AND    NVL(rule_information11, l_fee_type) = l_fee_type
  AND    rgp.id = rl.rgp_id
  AND    cle.id = rgp.cle_id
  AND    cle.sts_code <> 'ABANDONED';

  -- Cursor to get financed or capitalized tax amount if
  -- default tax treatment is FINANCED or CAPITALIZED respectively

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR get_fee_amt_csr1(p_contract_id IN NUMBER, p_feetype IN VARCHAR2)
  IS
  SELECT NVL(SUM(NVL(TOTAL_TAX,0)),0)
  FROM   okl_tax_sources txs,
           okc_rule_groups_b rg1,
           okc_rules_b rl1,
           okc_rule_groups_b rg2,
           okc_rules_b rl2,
           okc_k_lines_b cle
  WHERE  txs.KHR_ID = p_contract_id
  AND    txs.khr_id = rg1.dnz_chr_id
  AND    txs.kle_id = rg1.cle_id
  AND    txs.khr_id = rl1.dnz_chr_id
  AND    rg1.rgd_code = 'LAASTX'
  AND    rg1.id       = rl1.rgp_id
  AND    rl1.rule_information_category = 'LAASTX'
  AND    (rl1.rule_information11 = p_feetype
         OR
         rl1.rule_information11 IS NULL)
  AND    txs.TAX_LINE_STATUS_CODE = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE = 'UPFRONT_TAX'
  AND    txs.KHR_ID     = rg2.dnz_chr_id
  AND    txs.KHR_ID     = rl2.dnz_chr_id
  AND    rg2.id         = rl2.rgp_id
  AND    rg2.rgd_code   = 'LAHDTX'
  AND    rl2.rule_information_category = 'LASTPR'
  AND    rl2.rule_information1 = p_feetype
  AND    cle.id = rg1.cle_id
  AND    cle.sts_code <> 'ABANDONED';

  -- Cursor to get financed or capitalized tax Amount if
  -- default tax treatment is BILLED

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR get_fee_amt_csr2 (p_contract_id IN NUMBER, p_feetype IN VARCHAR2)
  IS
  SELECT NVL(SUM(NVL(TOTAL_TAX,0)),0)
  FROM    okl_tax_sources txs
           ,okc_rule_groups_b rg1
           ,okc_rules_b rl1
           ,okc_k_lines_b cle
  WHERE  txs.KHR_ID = p_Contract_id
  AND    txs.khr_id = rg1.dnz_chr_id
  AND    txs.kle_id = rg1.cle_id
  AND    txs.khr_id = rl1.dnz_chr_id
  AND    rg1.rgd_code = 'LAASTX'
  AND    rg1.id       = rl1.rgp_id
  AND    rl1.rule_information_category = 'LAASTX'
  AND    rl1.rule_information11 = p_feetype
  AND    txs.TAX_LINE_STATUS_CODE = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE = 'UPFRONT_TAX'
  AND    cle.id = rg1.cle_id
  AND    cle.sts_code <> 'ABANDONED'; -- Bug 5005269


  -- Use this cursor for billing trx when T and C asset upfront tax is
  -- Financed or Capitalized
  -- R12B eBtax: Added check that upfront tax amount is not zero

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR billing_required_csr1(p_contract_id IN NUMBER,
                               p_transaction_id IN NUMBER) IS
  SELECT 1
  FROM  okl_tax_sources txs,
        okc_rule_groups_b rg1,
        okc_rules_b rl1,
        okc_k_lines_b cle
  WHERE txs.khr_id = p_contract_id
  AND   txs.trx_id = p_transaction_id
  -- R12B ebtax: Active and Inactive lines will be billed during rebook
  -- AND   txs.tax_line_status_code = 'ACTIVE'
  AND   txs.tax_call_type_code = 'UPFRONT_TAX'
  AND   NVL(txs.total_tax,0) <> 0
  AND   rg1.dnz_chr_id = txs.khr_id
  AND   rg1.cle_id = txs.kle_id
  AND   rg1.rgd_code = 'LAASTX'
  AND   rl1.dnz_chr_id = rg1.dnz_chr_id
  AND   rl1.rgp_id = rg1.id
  AND   rl1.rule_information_category = 'LAASTX'
  AND   rl1.rule_information11 = 'BILLED'
  AND   cle.id = rg1.cle_id
  AND   cle.sts_code <> 'ABANDONED';

  -- Use this cursor for billing trx when T and C asset upfront tax is
  -- Billed
  -- R12B eBtax: Added check that upfront tax amount is not zero

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR billing_required_csr2(p_contract_id IN NUMBER,
                               p_transaction_id IN NUMBER) IS
  SELECT 1
  FROM okl_tax_sources txs,
       okc_rule_groups_b rg1,
       okc_rules_b rl1,
       okc_k_lines_b cle
  WHERE txs.khr_id   = p_contract_id
  AND   txs.trx_id = p_transaction_id
  -- R12B ebtax: Active and Inactive lines will be billed during rebook
  -- AND   txs.tax_line_status_code = 'ACTIVE'
  AND   txs.tax_call_type_code = 'UPFRONT_TAX'
  AND   NVL(txs.total_tax,0) <> 0
  AND   rg1.dnz_chr_id = txs.khr_id
  AND   rg1.cle_id = txs.kle_id
  AND   rg1.rgd_code = 'LAASTX'
  AND   rl1.dnz_chr_id = rg1.dnz_chr_id
  AND   rl1.rgp_id = rg1.id
  AND   rl1.rule_information_category = 'LAASTX'
  AND   NVL(rl1.rule_information11,'BILLED') = 'BILLED'
  AND   cle.id = rg1.cle_id
  AND   cle.sts_code <> 'ABANDONED';

  --Bug# 6939336
  -- This cursor gets biling amount at contract header level
  CURSOR contract_billing_csr(p_contract_id IN NUMBER,
                              p_transaction_id IN NUMBER) IS
  SELECT 1
  FROM   okl_tax_sources     txs
  WHERE  txs.khr_id = p_contract_id
  AND    txs.trx_id = p_transaction_id
  AND    txs.kle_id IS NULL
  AND    txs.tax_line_status_code = 'ACTIVE'
  AND    txs.tax_call_type_code = 'UPFRONT_TAX'
  AND    NVL(txs.total_tax,0) <> 0;

  -- ER# 9327076
  -- Check if present contract is a rebook copy
  CURSOR c_chk_rbk_csr (chrid IN okc_k_headers_b.ID%TYPE) IS
      SELECT '!'
        FROM okc_k_headers_b CHR
      WHERE CHR.ID = chrid
	      AND CHR.orig_system_source_code = 'OKL_REBOOK';

   -- Cursor to check if mass rebook is in process
   CURSOR c_chk_mass_rbk_csr (p_chr_id IN NUMBER) IS
      SELECT '!'
        FROM   okc_k_headers_b chr
      WHERE  chr.ID = p_chr_id
       AND EXISTS (SELECT '1'
                   FROM   okl_trx_contracts ktrx
                   WHERE  ktrx.khr_id = chr.ID
                          AND ktrx.tsu_code = 'ENTERED'
                          AND ktrx.rbr_code IS NOT NULL
                          AND ktrx.tcn_type = 'TRBK'
                          --rkuttiya added for 12.1.1 Multi GAAP Project
                          AND ktrx.representation_type = 'PRIMARY')
       AND EXISTS (SELECT '1'
                   FROM   okl_rbk_selected_contract rbk_khr
                   WHERE  rbk_khr.khr_id = chr.ID
                          AND rbk_khr.status <> 'PROCESSED');

  -- Global Variables
  g_source_table                   VARCHAR2(30) := 'OKL_TRX_CONTRACTS';

  -- ER# 9327076  - Added new function to check for prior upfront tax calculation
  FUNCTION check_prior_upfront_tax(p_chr_id  IN OKC_K_HEADERS_B.ID%TYPE)
  RETURN BOOLEAN IS
    CURSOR c_chk_upfront(cp_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
       SELECT 'x'
        FROM   okl_tax_sources
       WHERE  khr_id = cp_chr_id
            AND tax_call_type_code = 'UPFRONT_TAX' ;
    l_chk VARCHAR2(1) := '?';
  BEGIN

    OPEN c_chk_upfront(p_chr_id);
	  FETCH c_chk_upfront INTO l_chk;
	CLOSE c_chk_upfront;

    IF l_chk = '?' THEN
       RETURN FALSE;
    ELSE RETURN TRUE;
    END IF;

  END check_prior_upfront_tax;

  -- Start of comments
  --
  -- Procedure Name  : create_sales_tax_rules
  -- Description     : Creates sales tax rules after the asset is created. If
  --                   header sales tax information does not exist, the
  --                   default values will get set
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments


  PROCEDURE create_sales_tax_rules(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER,
            p_cle_id                 IN  NUMBER)

  IS
    l_rgpv_rec          rgpv_rec_type;
    l_rulv_rec          rulv_rec_type;
    lx_rgpv_rec         rgpv_rec_type;
    lx_rulv_rec         rulv_rec_type;

    l_chr_id  okc_k_headers_b.id%TYPE;
    l_cle_id  okc_k_lines_v.id%TYPE;
    l_rgp_id  NUMBER;

    lv_k_rule_information1        okc_rules_v.rule_information1%TYPE;
    lv_k_rule_information3        okc_rules_v.rule_information3%TYPE;
    lv_k_rule_information4        okc_rules_v.rule_information4%TYPE;
    lv_k_rule_information5        okc_rules_v.rule_information5%TYPE;
    lv_k_rule_information6        okc_rules_v.rule_information6%TYPE;
    lv_k_rule_information7        okc_rules_v.rule_information7%TYPE;

    CURSOR get_contract_deal_type(p_chr_id  okc_k_headers_b.id%TYPE) IS
    select deal_type
    from okl_k_headers
    where deal_type = 'LOAN'
    and id = p_chr_id;

    CURSOR get_contract_sales_tax_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT rul.rule_information1, rul.rule_information3, rul.rule_information4,
           rul.rule_information5, rul.rule_information6, rul.rule_information7
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NULL
    AND   rgp.rgd_code = 'LAHDTX'
    AND   rul.rule_information_category = 'LASTCL';

    CURSOR l_hdr_upfront_tax(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT rul.rule_information1
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NULL
    AND   rgp.rgd_code = 'LAHDTX'
    AND   rul.rule_information_category = 'LASTPR';

    CURSOR l_asset_tax_rule_group(p_chr_id  okc_k_headers_b.id%TYPE,
                                  p_cle_id  NUMBER) IS -- 5179119
    SELECT id
    FROM  OKC_RULE_GROUPS_B rgp
    WHERE rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NOT NULL
    AND   rgp.rgd_code = 'LAASTX'
    AND   rgp.cle_id = p_cle_id; -- 5179119
    l_asset_tax_rule_group_rec l_asset_tax_rule_group%ROWTYPE;
    l_row_found BOOLEAN;

    l_api_name			CONSTANT VARCHAR2(30) := 'CREATE_SALES_TAX_RULES';

    l_flag			VARCHAR2(30) := 'XXXX';
    l_deal_type         	okl_k_headers.deal_type%type;
    l_orig_system_source_code   okc_k_headers_b.orig_system_source_code%type;
    l_header_upfront_tax        okc_rules_v.rule_information1%TYPE;

  BEGIN

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      l_chr_id := p_chr_id;
      l_cle_id := p_cle_id;

      IF okl_context.get_okc_org_id  IS NULL THEN
        okl_context.set_okc_org_context(p_chr_id => l_chr_id);
      END IF;

      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,g_api_type
                               ,x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OPEN  l_hdr_upfront_tax(p_chr_id);
      FETCH l_hdr_upfront_tax into l_header_upfront_tax;
      CLOSE l_hdr_upfront_tax;

      -- get the contract header sales tax info to map to line sales tax
      -- Also, get 'update line from contract header ' flag to check whether
      -- to update with contract sales tax info

      OPEN  get_contract_sales_tax_info(l_chr_id);
      FETCH get_contract_sales_tax_info into    lv_k_rule_information1,
       						lv_k_rule_information3,
                                                lv_k_rule_information4,
                                                lv_k_rule_information5,
                                                lv_k_rule_information6,
                                                lv_k_rule_information7;
      IF (get_contract_sales_tax_info%NOTFOUND) THEN
        l_flag := 'DEFAULT';
      END IF;
      CLOSE get_contract_sales_tax_info;

      IF(NOT(NVL(lv_k_rule_information1,'N') = 'Y'))  THEN
        l_flag := 'DEFAULT';
      END IF;

      -- Create the rule group for sales Tax
      l_rgpv_rec.rgd_code      :=  'LAASTX';
      l_rgpv_rec.chr_id        :=  null;
      l_rgpv_rec.dnz_chr_id    :=  l_chr_id;
      l_rgpv_rec.cle_id        :=  l_cle_id;
      l_rgpv_rec.rgp_type      :=  'KRG';

     --Bug#4990898 ramurt
     OPEN l_asset_tax_rule_group(p_chr_id, p_cle_id); -- 5179119
     FETCH l_asset_tax_rule_group INTO l_asset_tax_rule_group_rec;
     l_row_found := l_asset_tax_rule_group%FOUND;
     CLOSE l_asset_tax_rule_group;

      IF (l_row_found) THEN
        l_rgp_id := l_asset_tax_rule_group_rec.id;
      ELSE
        OKL_RULE_PUB.create_rule_group(
                p_api_version       =>  p_api_version,
                p_init_msg_list     =>  p_init_msg_list,
                x_return_status     =>  x_return_status,
                x_msg_count         =>  x_msg_count,
                x_msg_data          =>  x_msg_data,
                p_rgpv_rec          =>  l_rgpv_rec,
                x_rgpv_rec          =>  lx_rgpv_rec);
        l_rgp_id := lx_rgpv_rec.id;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      -- Create the sales Tax rule
        l_rulv_rec.dnz_chr_id        		:= l_chr_id;
        l_rulv_rec.rgp_id            		:= l_rgp_id;
        l_rulv_rec.rule_information_category    := 'LAASTX';
        l_rulv_rec.sfwt_flag         		:= 'N';
        l_rulv_rec.std_template_yn   		:= 'N';
        l_rulv_rec.warn_yn           		:= 'N';
        l_rulv_rec.template_yn       		:= 'N';
        l_rulv_rec.rule_information5 		:= 'N';

        -- if the header sales info doesnt exist set default values

        IF(l_flag = 'DEFAULT') THEN

         l_deal_type := NULL;
         OPEN get_contract_deal_type(l_chr_id);
         FETCH get_contract_deal_type into l_deal_type;
         CLOSE get_contract_deal_type;

         l_rulv_rec.rule_information6 := 'N';

         IF( l_deal_type IS NULL) THEN -- contract deal type is not loan
           l_rulv_rec.rule_information7 := 'N'; -- Yes for Loan
         ELSE
           l_rulv_rec.rule_information7 := 'Y'; -- Yes for Loan
         END IF;

         l_rulv_rec.rule_information8 := 'N';
         --l_rulv_rec.rule_information9 := lv_k_rule_information6; -- user specified
         --l_rulv_rec.rule_information10 := lv_k_rule_information7; -- user specified

        ELSE

         l_rulv_rec.rule_information6  := lv_k_rule_information3;
         l_rulv_rec.rule_information7  := lv_k_rule_information4;
         l_rulv_rec.rule_information8  := lv_k_rule_information5;
         l_rulv_rec.rule_information9  := lv_k_rule_information6;
         l_rulv_rec.rule_information10 := lv_k_rule_information7;
         l_rulv_rec.rule_information11 := l_header_upfront_tax;

        END IF;

        OKL_RULE_PUB.create_rule(
              p_api_version         => p_api_version,
              p_init_msg_list       => p_init_msg_list,
              x_return_status       => x_return_status,
              x_msg_count           => x_msg_count,
              x_msg_data            => x_msg_data,
              p_rulv_rec            => l_rulv_rec,
              x_rulv_rec            => lx_rulv_rec);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF get_contract_sales_tax_info%ISOPEN THEN
        CLOSE get_contract_sales_tax_info;
      END IF;
      IF l_hdr_upfront_tax%ISOPEN THEN
        CLOSE l_hdr_upfront_tax;
      END IF;
      IF l_asset_tax_rule_group%ISOPEN THEN
        CLOSE l_asset_tax_rule_group;
      END IF;


      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF get_contract_sales_tax_info%ISOPEN THEN
        CLOSE get_contract_sales_tax_info;
      END IF;
      IF l_hdr_upfront_tax%ISOPEN THEN
        CLOSE l_hdr_upfront_tax;
      END IF;
      IF l_asset_tax_rule_group%ISOPEN THEN
        CLOSE l_asset_tax_rule_group;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKC_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

    WHEN OTHERS THEN
      IF get_contract_sales_tax_info%ISOPEN THEN
        CLOSE get_contract_sales_tax_info;
      END IF;
      IF l_asset_tax_rule_group%ISOPEN THEN
        CLOSE l_asset_tax_rule_group;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);
  END create_sales_tax_rules;

  -- Procedure Name  : sync_contract_sales_tax
  -- Description     : Sync the contract sales tax rule information with all the assets
  --                   , if the flag 'Update lines from contract header' at the  header
  --                   level is checked.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  PROCEDURE sync_contract_sales_tax(
            p_api_version    	     IN  NUMBER,
            p_init_msg_list          IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status          OUT NOCOPY VARCHAR2,
            x_msg_count              OUT NOCOPY NUMBER,
            x_msg_data               OUT NOCOPY VARCHAR2,
            p_chr_id                 IN  NUMBER)
  IS
    l_rulv_rec          rulv_rec_type;
    lx_rulv_rec         rulv_rec_type;

    ln_cle_id                     okc_k_lines_v.id%TYPE;

    ln_rule_id                    okc_rules_v.id%TYPE;
    lv_asset_k_rule_information5  okc_rules_v.rule_information5%TYPE;
    l_ak_prompt                   varchar2(100);
    l_rebook_yn                   varchar2(1) := 'N';
    l_orig_system_id1             okc_k_lines_b.orig_system_id1%type;

    lv_k_rule_information1        okc_rules_v.rule_information1%TYPE := null;
    lv_k_rule_information2        okc_rules_v.rule_information1%TYPE := null;
    lv_k_rule_information3        okc_rules_v.rule_information3%TYPE := null;
    lv_k_rule_information4        okc_rules_v.rule_information4%TYPE := null;
    lv_k_rule_information5        okc_rules_v.rule_information5%TYPE := null;
    lv_k_rule_information6        okc_rules_v.rule_information6%TYPE := null;
    lv_k_rule_information7        okc_rules_v.rule_information7%TYPE := null;
    l_header_upfront_tax          okc_rules_v.rule_information1%TYPE;

    l_api_name	CONSTANT VARCHAR2(30) := 'SYNC_CONTRACT_SALES_TAX';

    CURSOR get_contract_sales_tax_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT rul.rule_information1, rul.rule_information3, rul.rule_information4,
           rul.rule_information5, rul.rule_information6, rul.rule_information7
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NULL
    AND   rgp.rgd_code = 'LAHDTX'
    AND   rul.rule_information_category = 'LASTCL';

    CURSOR get_contract_lines(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT cle.id
    FROM   OKC_K_LINES_V cle,
           OKC_LINE_STYLES_V lse
    WHERE  cle.lse_id = lse.id
    AND    lse.lty_code = 'FREE_FORM1'
    AND    lse.lse_type = 'TLS'
    AND    cle.dnz_chr_id = p_chr_id;
--    AND    cle.orig_system_id1 IS NULL;      -- for rebook check

    CURSOR get_rebook_contract_csr(p_chr_id  okc_k_headers_b.id%TYPE) IS
     select 'Y'
     from okc_k_headers_b
     where id = p_chr_id
     and nvl(orig_system_source_code,'XXX')='OKL_REBOOK';

    CURSOR get_asset_sales_tax_info(p_chr_id  okc_k_headers_b.id%TYPE,
                                       p_cle_id  okc_k_lines_v.id%TYPE) IS
    SELECT rul.id, rul.rule_information5, cle.ORIG_SYSTEM_ID1
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp,
		  okc_k_lines_b cle
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id = p_cle_id
    AND   rgp.rgd_code = 'LAASTX'
    AND   rul.rule_information_category = 'LAASTX'
	AND   cle.id = rgp.cle_id
	AND   cle.id = p_cle_id;

    CURSOR get_sales_tax_prc_info(p_chr_id  okc_k_headers_b.id%TYPE) IS
    SELECT rul.rule_information1, rul.rule_information2,
           rul.rule_information3, rul.rule_information4, rul.rule_information4
    FROM  OKC_RULES_V rul,
          OKC_RULE_GROUPS_V rgp
    WHERE rul.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.cle_id is NULL
    AND   rgp.rgd_code = 'LAHDTX'
    AND   rul.rule_information_category = 'LASTPR';

    CURSOR get_segment_prompt(p_ri okc_rules_b.rule_information1%TYPE) IS
    select col.form_left_prompt
    from fnd_descr_flex_col_usage_vl col,
         okc_rule_defs_v  rdef
    where col.application_id = 540
    and col.application_id = rdef.application_id
    and col.descriptive_flexfield_name=rdef.descriptive_flexfield_name
    and col.descriptive_flex_context_code=rdef.rule_code
    and rdef.rule_code = 'LASTPR'
    and col.application_column_name = p_ri;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;

      -- Bug 5129446
      /*
      l_upfront_tax_yn := 'N';
      OPEN l_tax_system_info;
      FETCH l_tax_system_info INTO l_upfront_tax_yn;
      CLOSE l_tax_system_info; */

      IF okl_context.get_okc_org_id  IS NULL THEN
        okl_context.set_okc_org_context(p_chr_id => p_chr_id);
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'sync here1');
      END IF;
      -- call START_ACTIVITY to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,g_api_type
                               ,x_return_status);

      -- check if activity started successfully
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      -- Bug 5129446
      /*
      OPEN  get_sales_tax_prc_info(p_chr_id);
      FETCH get_sales_tax_prc_info into    lv_k_rule_information1,
					   lv_k_rule_information2,
                                           lv_k_rule_information3,
                                           lv_k_rule_information4;
      CLOSE get_sales_tax_prc_info;
      l_header_upfront_tax := lv_k_rule_information1;

      If((l_upfront_tax_yn = 'Y') AND l_header_upfront_tax is null) Then
        x_return_status := OKL_API.G_RET_STS_ERROR;
        OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_HEADER_TAX');
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      --If(lv_k_rule_information1 = G_BILLED and (lv_k_rule_information2 is null or lv_k_rule_information2 = OKL_API.G_MISS_CHAR)) Then
      If((l_upfront_tax_yn = 'Y') AND (lv_k_rule_information2 is null) or (lv_k_rule_information2 = OKL_API.G_MISS_CHAR)) Then

         OPEN  get_segment_prompt('RULE_INFORMATION2');
         FETCH get_segment_prompt into l_ak_prompt;
         CLOSE get_segment_prompt;

         x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
   				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
   				, p_token1_value => l_ak_prompt
   			   );
         raise OKL_API.G_EXCEPTION_ERROR;

      --ElsIf(lv_k_rule_information1 = G_FINANCED and (lv_k_rule_information3 is null or lv_k_rule_information3 = OKL_API.G_MISS_CHAR)) Then
      ElsIf((l_upfront_tax_yn) = 'Y' AND (lv_k_rule_information3 is null) or (lv_k_rule_information3 = OKL_API.G_MISS_CHAR)) Then

         OPEN  get_segment_prompt('RULE_INFORMATION3');
         FETCH get_segment_prompt into l_ak_prompt;
         CLOSE get_segment_prompt;

         x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
   				, p_msg_name => 'OKL_REQUIRED_VALUE'
  				, p_token1 => 'COL_NAME'
   				, p_token1_value => l_ak_prompt
   			   );
         raise OKL_API.G_EXCEPTION_ERROR;

      --ElsIf(lv_k_rule_information1 = G_CAPITALIZED and (lv_k_rule_information4 is null or lv_k_rule_information4 = OKL_API.G_MISS_CHAR)) Then
      ElsIf((l_upfront_tax_yn = 'Y') AND (lv_k_rule_information4 is null) or (lv_k_rule_information4 = OKL_API.G_MISS_CHAR)) Then

         OPEN  get_segment_prompt('RULE_INFORMATION4');
         FETCH get_segment_prompt into l_ak_prompt;
         CLOSE get_segment_prompt;

         x_return_status := OKL_API.g_ret_sts_error;
         OKL_API.SET_MESSAGE(      p_app_name => g_app_name
         			, p_msg_name => 'OKL_REQUIRED_VALUE'
        			, p_token1 => 'COL_NAME'
         			, p_token1_value => l_ak_prompt
         		   );
         raise OKL_API.G_EXCEPTION_ERROR;

      End If;
      */

      -- get the contract header sales tax info to map to line sales tax
      -- Also, get 'update line from contract header ' flag to check whether to update
      -- with contract sales tax info

      OPEN  get_contract_sales_tax_info(p_chr_id);
      FETCH get_contract_sales_tax_info into    lv_k_rule_information1,
      						lv_k_rule_information3,
                                                lv_k_rule_information4,
                                                lv_k_rule_information5,
                                                lv_k_rule_information6,
                                                lv_k_rule_information7;
      IF (get_contract_sales_tax_info%NOTFOUND) THEN
        RETURN;
      END IF;
      CLOSE get_contract_sales_tax_info;

      IF(NOT(nvl(lv_k_rule_information1,'N') = 'Y')) THEN
        OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                              x_msg_data   => x_msg_data);
        RETURN;
      END IF;

	  l_rebook_yn := 'N';
      OPEN get_rebook_contract_csr(p_chr_id  => p_chr_id);
      FETCH get_rebook_contract_csr into l_rebook_yn;
      CLOSE get_rebook_contract_csr;

	  --- get all the contract lines and create/update
      --  the lines with contract sales tax info
      FOR r_get_contract_lines IN get_contract_lines(p_chr_id => p_chr_id) LOOP

       lv_asset_k_rule_information5 := null; -- Reset the value

        -- get 'update from contract' flag
       OPEN get_asset_sales_tax_info(p_chr_id  => p_chr_id,
                                         p_cle_id  => r_get_contract_lines.id);
       FETCH get_asset_sales_tax_info into ln_rule_id, lv_asset_k_rule_information5, l_orig_system_id1;
       CLOSE get_asset_sales_tax_info;

	   IF( (l_rebook_yn = 'Y' AND l_orig_system_id1 IS NULL) OR (l_rebook_yn = 'N')) THEN

        IF (lv_asset_k_rule_information5 IS NOT NULL AND
            lv_asset_k_rule_information5 = 'Y') THEN

          l_rulv_rec.id := ln_rule_id;
          l_rulv_rec.rule_information6 := lv_k_rule_information3;
          l_rulv_rec.rule_information7 := lv_k_rule_information4;
          l_rulv_rec.rule_information8 := lv_k_rule_information5;
          l_rulv_rec.rule_information9 := lv_k_rule_information6;
          l_rulv_rec.rule_information10 := lv_k_rule_information7;
          l_rulv_rec.rule_information11 := l_header_upfront_tax;

          OKL_RULE_PUB.update_rule(
            p_api_version         => p_api_version,
            p_init_msg_list       => p_init_msg_list,
            x_return_status       => x_return_status,
            x_msg_count           => x_msg_count,
            x_msg_data            => x_msg_data,
            p_rulv_rec            => l_rulv_rec,
            x_rulv_rec            => lx_rulv_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

        END IF;

	  END IF; -- close of rebook check

     END LOOP;

     OKL_API.END_ACTIVITY (x_msg_count  => x_msg_count,
                            x_msg_data   => x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_contract_sales_tax_info%ISOPEN THEN
      CLOSE get_contract_sales_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_sales_tax_info%ISOPEN THEN
      CLOSE get_asset_sales_tax_info;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               g_pkg_name,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               g_api_type);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_contract_sales_tax_info%ISOPEN THEN
      CLOSE get_contract_sales_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_sales_tax_info%ISOPEN THEN
      CLOSE get_asset_sales_tax_info;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              g_pkg_name,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              g_api_type);
    WHEN OTHERS THEN
    IF get_contract_sales_tax_info%ISOPEN THEN
      CLOSE get_contract_sales_tax_info;
    END IF;
    IF get_contract_lines%ISOPEN THEN
      CLOSE get_contract_lines;
    END IF;
    IF get_asset_sales_tax_info%ISOPEN THEN
      CLOSE get_asset_sales_tax_info;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              g_pkg_name,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              g_api_type);
  END sync_contract_sales_tax;

  -- Main Sales Tax Procedures
  -- Procedure create/update transaction records for pre-booking
  -- and pre-rebooking processes
  Procedure populate_transaction(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  okc_k_headers_all_b.id%TYPE,
                      p_transaction_type IN  okl_trx_types_tl.name%TYPE,
                      p_transaction_id   IN  okl_trx_contracts_all.id%TYPE DEFAULT NULL,
                      p_source_trx_id    IN  okl_trx_contracts_all.source_trx_id%TYPE DEFAULT NULL,
                      p_source_trx_type  IN  okl_trx_contracts_all.source_trx_type%TYPE DEFAULT NULL,
                      --Bug# 6619311
                      p_transaction_amount IN  okl_trx_contracts_all.amount%TYPE DEFAULT NULL,
                      x_transaction_id   OUT NOCOPY okl_trx_contracts_all.id%TYPE,
                      x_trxh_out_rec     OUT NOCOPY Okl_Trx_Contracts_Pvt.tcnv_rec_type, -- R12 Change
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

     -- Define PL/SQL Records and Tables
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;

    -- Define variables
    l_sysdate         DATE;
    l_sysdate_trunc   DATE;
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_post_to_gl_yn   VARCHAR2(1);

    CURSOR Transaction_Type_csr (p_transaction_type IN okl_trx_types_v.name%TYPE )
    IS
    SELECT id
    FROM  okl_trx_types_tl
    WHERE  name = p_transaction_type
    AND language = 'US';

    Cursor trx_csr( khrId NUMBER, tcntype VARCHAR2 ) is
    Select txh.ID HeaderTransID,
           txh.date_transaction_occurred date_transaction_occurred
    From   okl_trx_contracts txh
    Where  txh.khr_id = khrId
   --rkuttiya added for 12.1.1 Multi GAAP
    AND    txh.representation_type = 'PRIMARY'
   --
    AND    txh.tcn_type = tcntype;

    i                 NUMBER;
    l_amount          NUMBER;
    l_init_msg_list   VARCHAR2(1) := OKL_API.G_FALSE;
    l_msg_count       NUMBER;
    l_msg_data        VARCHAR2(2000);
    l_currency_code   okl_txl_cntrct_lns.currency_code%TYPE;
    l_fnd_profile     VARCHAR2(256);
    l_cust_trx_type_id NUMBER;
    l_has_trans          VARCHAR2(1);

    l_msg_index_out   NUMBER; --TBR

     -- Define constants
    l_api_name        CONSTANT VARCHAR(30) := 'POPULATE_TRANSACTION';
    l_api_version     CONSTANT NUMBER      := 1.0;

    -- Cursor Types
    l_Trx_Type_rec     Transaction_Type_csr%ROWTYPE;
    l_fnd_rec          fnd_lookups_csr%ROWTYPE;
    l_fnd_rec1         fnd_lookups_csr%ROWTYPE;
    l_trx_rec          trx_csr%ROWTYPE;

    p_chr_id           VARCHAR2(2000) := TO_CHAR(p_contract_id);
    l_transaction_type VARCHAR2(256) := p_transaction_type;
    l_transaction_id   NUMBER;

    --Bug# 3153003
    l_upd_trxH_rec  Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    lx_upd_trxH_rec Okl_Trx_Contracts_Pvt.tcnv_rec_type;

    pop_trx_failed exception;

      --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id          NUMBER;

  -- R12 - START

  l_func_curr_code              OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
  l_chr_curr_code               OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
  x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
  x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
  x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

  -- R12 - END



  BEGIN

    okl_debug_pub.logmessage('OKL: POP TRX : START');
    okl_debug_pub.logmessage('OKL: POP TRX : p_contract_id: ' || p_contract_id);
    okl_debug_pub.logmessage('OKL: POP TRX : p_transaction_type: ' || p_transaction_type);
    okl_debug_pub.logmessage('OKL: POP TRX : p_transaction_id: ' || p_transaction_id);
    okl_debug_pub.logmessage('OKL: POP TRX : p_source_trx_id: ' || p_source_trx_id);
    okl_debug_pub.logmessage('OKL: POP TRX : p_source_trx_type: ' || p_source_trx_type);

    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;
    l_sysdate        := SYSDATE;
    l_sysdate_trunc  := trunc(SYSDATE);
    i                := 0;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : START ');
    END IF;


    -- R12 - START

    -- Get product_id
    OPEN  Product_csr (p_contract_id);
    FETCH Product_csr INTO g_Product_rec;
    IF Product_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'Product');
      CLOSE Product_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE Product_csr;

    l_chr_curr_code  := g_Product_rec.CURRENCY_CODE;
    l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(g_Product_rec.authoring_org_id);

    x_currency_conversion_rate := NULL;
    x_currency_conversion_type := NULL;
    x_currency_conversion_date := NULL;

    If ( ( l_func_curr_code IS NOT NULL) AND
         ( l_chr_curr_code <> l_func_curr_code ) ) Then

      x_currency_conversion_type := g_Product_rec.currency_conversion_type;
      x_currency_conversion_date := g_Product_rec.start_date;

      If ( g_Product_rec.currency_conversion_type = 'User') Then
        x_currency_conversion_rate := g_Product_rec.currency_conversion_rate;
        x_currency_conversion_date := g_Product_rec.currency_conversion_date;
      Else
        x_currency_conversion_rate := okl_accounting_util.get_curr_con_rate(
	                                       p_from_curr_code => l_chr_curr_code,
	                                       p_to_curr_code   => l_func_curr_code,
					       p_con_date       => g_Product_rec.start_date,
					       p_con_type       => g_Product_rec.currency_conversion_type);

      End If;

    End If;

    l_currency_code                          := g_Product_rec.currency_code;
    l_trxH_in_rec.pdt_id                     := g_Product_rec.product_id;
    l_trxH_in_rec.currency_code              := l_currency_code;
    l_trxH_in_rec.currency_conversion_rate   := x_currency_conversion_rate;
    l_trxH_in_rec.currency_conversion_type   := x_currency_conversion_type;
    l_trxH_in_rec.currency_conversion_date   := x_currency_conversion_date;

    -- R12 - END



    -- Validate passed parameters
    IF   ( p_contract_id = Okl_Api.G_MISS_NUM       )
      OR ( p_contract_id IS NULL                    ) THEN
        --Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, 'contract');
        Okl_Api.Set_Message(G_APP_NAME, 'OKL_LA_ST_K_ID_ERROR');
        RAISE pop_trx_failed;
    END IF;

    IF   ( p_transaction_type = Okl_Api.G_MISS_CHAR )
      OR ( p_transaction_type IS NULL               ) THEN
        --Okl_Api.Set_Message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN, l_transaction_type);
        Okl_Api.Set_Message(G_APP_NAME, 'OKL_LA_ST_TRX_TYPE_ERROR');
        RAISE pop_trx_failed;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before Transaction_Type_csr ');
    END IF;
    -- Check Transaction_Type
    OPEN  Transaction_Type_csr(l_transaction_type);
    FETCH Transaction_Type_csr INTO l_Trx_Type_rec;
    IF Transaction_Type_csr%NOTFOUND THEN
          Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,'TRANSACTION_TYPE', l_transaction_type);
            /*OKL_API.SET_MESSAGE(
                            p_app_name     =>  G_APP_NAME,
                            p_msg_name     =>  G_INVALID_VALUE,
                            p_token1       =>  'COL_NAME',
                            p_token1_value =>  'TRANSACTION_TYPE');*/

      CLOSE Transaction_Type_csr;
      RAISE pop_trx_failed;
    END IF;
    CLOSE Transaction_Type_csr;

    okl_debug_pub.logmessage('OKL: POP TRX : Transaction_Type_csr.id: ' || l_Trx_Type_rec.id);

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before fnd_lookups_csr ');
    END IF;

    OPEN  fnd_lookups_csr('OKL_TCN_TYPE', l_transaction_type);
    FETCH fnd_lookups_csr INTO l_fnd_rec;

    IF fnd_lookups_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,'TRANSACTION_TYPE', l_transaction_type);
      CLOSE fnd_lookups_csr;
      RAISE pop_trx_failed;
    END IF;
    CLOSE fnd_lookups_csr;

    okl_debug_pub.logmessage('OKL: POP TRX : transaction type: ' || l_transaction_type);
    okl_debug_pub.logmessage('OKL: POP TRX : fnd_lookups_csr: Description ' || l_fnd_rec.description);
    okl_debug_pub.logmessage('OKL: POP TRX : fnd_lookups_csr: lookup_code ' || l_fnd_rec.lookup_code);


    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before trx_csr ');
    END IF;

    -- gboomina Bug 6487183 - Start
    -- For Upfront Tax transaction always create transaction header record
    IF (l_transaction_type <> 'Upfront Tax') THEN
      OPEN  trx_csr(p_contract_id,l_fnd_rec.lookup_code);
      FETCH trx_csr INTO l_trx_rec;
      IF trx_csr%NOTFOUND THEN -- While activation, create a new trans always.
          l_has_trans := OKL_API.G_FALSE;
          okl_debug_pub.logmessage('OKL: POP TRX : No Existing TRX: '||l_fnd_rec.lookup_code);
      Else
          l_has_trans := OKL_API.G_TRUE;
          okl_debug_pub.logmessage('OKL: POP TRX : TRX Exists: '|| l_fnd_rec.lookup_code);
      END IF;
      CLOSE trx_csr;
    ELSE
      l_has_trans := OKL_API.G_FALSE;
    END IF;
    -- gboomina Bug 6487183 - End

    l_trxH_in_rec.khr_id                       := p_contract_id;
    l_trxH_in_rec.source_trx_id                := p_source_trx_id;
    l_trxH_in_rec.source_trx_type              := p_source_trx_type;
    --l_trxH_in_rec.date_transaction_occurred  := sysdate; -- OKL.H Code
    l_trxH_in_rec.date_transaction_occurred    := g_Product_rec.start_date; -- R12 Change
    l_trxH_in_rec.try_id                       := l_Trx_Type_rec.id;
    l_trxH_in_rec.tcn_type                     := l_fnd_rec.lookup_code; --'BKG'/'SYND'/'TRBK';

    --Bug# 6619311
    IF p_transaction_amount IS NOT NULL THEN
      l_trxH_in_rec.amount                      := p_transaction_amount;
    END IF;

    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.khr_id : '|| l_trxH_in_rec.khr_id);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.source_trx_id : '|| l_trxH_in_rec.source_trx_id);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.source_trx_type : '|| l_trxH_in_rec.source_trx_type);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.date_transaction_occurred : '|| l_trxH_in_rec.date_transaction_occurred);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.try_id : '|| l_trxH_in_rec.try_id);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.tcn_type : '|| l_trxH_in_rec.tcn_type);
    okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.amount : '|| l_trxH_in_rec.amount);

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : transaction type '||l_transaction_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : try_id '||l_trxH_in_rec.try_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : tcn_type '||l_trxH_in_rec.tcn_type);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : l_has_trans '||l_has_trans);
    END IF;

    If ( l_has_trans = OKL_API.G_FALSE ) Then

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before fnd_lookups_csr ');
      END IF;

      -- The followinf if segment ensures that Upfront Tax transaction is created
      -- with 'Processed' status
      IF (l_transaction_type = 'Upfront Tax')
      THEN
        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Processed');
      ELSE
        OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Entered');
      END IF;
      FETCH fnd_lookups_csr INTO l_fnd_rec;
      IF fnd_lookups_csr%NOTFOUND THEN
        Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
        CLOSE fnd_lookups_csr;
        RAISE pop_trx_failed;
      END IF;
      CLOSE fnd_lookups_csr;

      l_trxH_in_rec.tsu_code       := l_fnd_rec.lookup_code;
      l_trxH_in_rec.description    := l_fnd_rec.description;

      okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.tsu_code : '|| l_trxH_in_rec.tsu_code);
      okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_in_rec.description : '|| l_trxH_in_rec.description);


      --Added by dpsingh for LE Uptake
      l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_contract_id) ;
      IF  l_legal_entity_id IS NOT NULL THEN
        l_trxH_in_rec.legal_entity_id :=  l_legal_entity_id;
      ELSE
        -- get the contract number
        OPEN contract_num_csr(p_contract_id);
        FETCH contract_num_csr INTO l_cntrct_number;
        CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                      , G_MODULE
                                      ,'OKL: Populate Trx Procedure : before Okl_Trx_Contracts_Pub.create_trx_contracts ');
      END IF;

      -- Create Transaction Header, Lines
      Okl_Trx_Contracts_Pub.create_trx_contracts(
             p_api_version      => p_api_version
            ,p_init_msg_list    => p_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_tcnv_rec         => l_trxH_in_rec
            ,x_tcnv_rec         => l_trxH_out_rec);

      okl_debug_pub.logmessage('OKL: POP TRX : return status '||x_return_status);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE pop_trx_failed;
      END IF;

      IF ((l_trxH_out_rec.id = OKL_API.G_MISS_NUM) OR
          (l_trxH_out_rec.id IS NULL) ) THEN
          OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
          --OKL_API.set_message(G_APP_NAME, 'Header Transaction Id is null or invalid');
          RAISE pop_trx_failed;
      END IF;

      l_fnd_rec := null;

      -- outbound transaction id
      x_transaction_id        := l_trxH_out_rec.id;
      x_trxh_out_rec          := l_trxH_out_rec; -- R12 Change

      okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_out_rec.id : '|| l_trxH_out_rec.id);
      okl_debug_pub.logmessage('OKL: POP TRX : l_trxH_out_rec.description : '|| l_trxH_out_rec.description);

      okl_debug_pub.logmessage('OKL: POP TRX : try id '||l_trxH_out_rec.TRY_ID);
      okl_debug_pub.logmessage('OKL: POP TRX : transaction type '||l_trxH_out_rec.TCN_TYPE);
      okl_debug_pub.logmessage('OKL: POP TRX : tsu code '||l_trxH_out_rec.TSU_CODE);

    ELSE

      --if transaction exists change the date transaction occured
      l_upd_trxH_rec.id                       := l_trx_rec.HeaderTransID;
      l_upd_trxH_rec.date_transaction_occurred := l_trx_rec.date_transaction_occurred;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : transaction ID '||l_trx_rec.HeaderTransID);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before fnd_lookups_csr ');
      END IF;

      OPEN  fnd_lookups_csr('OKL_TRANSACTION_STATUS', 'Entered');
      FETCH fnd_lookups_csr INTO l_fnd_rec;
      IF fnd_lookups_csr%NOTFOUND THEN
        Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_transaction_type);
        --Okl_Api.SET_MESSAGE(G_APP_NAME, 'Cannot Find Transaction Status');
        CLOSE fnd_lookups_csr;
        RAISE pop_trx_failed;
      END IF;
      CLOSE fnd_lookups_csr;

      l_upd_trxH_rec.tsu_code       := l_fnd_rec.lookup_code;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : before Okl_Trx_Contracts_Pub.update_trx_contracts ');
      END IF;

      Okl_Trx_Contracts_Pub.update_trx_contracts(
             p_api_version      => p_api_version
            ,p_init_msg_list    => p_init_msg_list
            ,x_return_status    => x_return_status
            ,x_msg_count        => x_msg_count
            ,x_msg_data         => x_msg_data
            ,p_tcnv_rec         => l_upd_trxH_rec
            ,x_tcnv_rec         => lx_upd_trxH_rec);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE pop_trx_failed;
      END IF;

      IF ((lx_upd_trxH_rec.id = OKL_API.G_MISS_NUM) OR
          (lx_upd_trxH_rec.id IS NULL) ) THEN
          OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'TRANSACTION_ID');
          --OKL_API.set_message(G_APP_NAME, 'TRANSACTION_ID Missing');
          RAISE pop_trx_failed;
      END IF;

      -- outbound transaction id
      x_transaction_id := l_trx_rec.HeaderTransID;
      x_trxh_out_rec   := lx_upd_trxH_rec; -- R12 Change

      okl_debug_pub.logmessage('OKL: POP TRX : return status '||x_return_status);
      okl_debug_pub.logmessage('OKL: POP TRX : lx_upd_trxH_rec.id : '|| lx_upd_trxH_rec.id);
      okl_debug_pub.logmessage('OKL: POP TRX : lx_upd_trxH_rec.description : '|| lx_upd_trxH_rec.description);

      okl_debug_pub.logmessage('OKL: POP TRX : try id '||lx_upd_trxH_rec.TRY_ID);
      okl_debug_pub.logmessage('OKL: POP TRX : transaction type '||lx_upd_trxH_rec.TCN_TYPE);
      okl_debug_pub.logmessage('OKL: POP TRX : tsu code '||lx_upd_trxH_rec.TSU_CODE);


    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Populate Trx Procedure : END ');
    END IF;

    okl_debug_pub.logmessage('OKL: POP TRX : END');

    Exception
      when pop_trx_failed then
         x_return_status := OKL_API.G_RET_STS_ERROR;

  END populate_transaction;


  -- Function to get total estimated financed amount
  Function get_financed_tax ( p_Contract_id  IN NUMBER ,
                              p_default_tax_treatment IN VARCHAR2)
  RETURN NUMBER
  IS

    l_fee_amt NUMBER;

  BEGIN

    --OPEN  get_fee_amt_csr(p_contract_id, p_transaction_id);
    IF (p_default_tax_treatment = 'FINANCE') THEN
      OPEN  get_fee_amt_csr1(p_Contract_id, 'FINANCE');
      FETCH get_fee_amt_csr1 INTO l_fee_amt;
      CLOSE get_fee_amt_csr1;
    END IF;
    IF (p_default_tax_treatment = 'BILLED') THEN
      OPEN  get_fee_amt_csr2(p_Contract_id,'FINANCE');
      FETCH get_fee_amt_csr2 INTO l_fee_amt;
      CLOSE get_fee_amt_csr2;
    END IF;

    --Hard Code the value for the time being until tax
    -- APIs are ready
    --l_fee_amt := 50;

    RETURN l_fee_amt;

  END get_financed_tax;

  -- Function to get total estimated capitalized amount
  Function get_capitalized_tax ( p_Contract_id    IN NUMBER,
                                 p_default_tax_treatment IN VARCHAR2)

  RETURN NUMBER
  IS

  l_fee_amt NUMBER;

  BEGIN

    IF (p_default_tax_treatment = 'CAPITALIZE') THEN
      OPEN  get_fee_amt_csr1 (p_Contract_id, 'CAPITALIZE');
      FETCH get_fee_amt_csr1 INTO l_fee_amt;
      CLOSE get_fee_amt_csr1;
    END IF;
    IF (p_default_tax_treatment = 'BILLED') THEN
      OPEN  get_fee_amt_csr2(p_Contract_id, 'CAPITALIZE');
      FETCH get_fee_amt_csr2 INTO l_fee_amt;
      CLOSE get_fee_amt_csr2;
    END IF;

    --Hard Code the value for the time being until tax
    -- APIs are ready
    --l_fee_amt := 50;

    RETURN l_fee_amt;

  END get_capitalized_tax;

  -- R12B Authoring OA Migration
  -- Function to get total estimated billed amount
  Function get_billed_tax ( p_Contract_id    IN NUMBER,
                            p_default_tax_treatment IN VARCHAR2)

  RETURN NUMBER
  IS

  l_tax_amt NUMBER;

  --Bug# 6668721
  -- This cursor gets billed upfront tax amount at contract
  -- header level
  CURSOR contract_billed_tax_csr(p_contract_id IN NUMBER) IS
  SELECT NVL(SUM(NVL(total_tax,0)),0)
  FROM   okl_tax_sources txs
  WHERE  txs.khr_id = p_contract_id
  AND    txs.kle_id IS NULL
  AND    txs.tax_line_status_code = 'ACTIVE'
  AND    txs.tax_call_type_code = 'UPFRONT_TAX';

  l_contract_billed_tax NUMBER;

  BEGIN

    IF (p_default_tax_treatment = 'BILLED') THEN
      OPEN  get_fee_amt_csr1 (p_Contract_id, 'BILLED');
      FETCH get_fee_amt_csr1 INTO l_tax_amt;
      CLOSE get_fee_amt_csr1;
    END IF;
    IF (p_default_tax_treatment IN ('CAPITALIZE','FINANCE')) THEN
      OPEN  get_fee_amt_csr2(p_Contract_id, 'BILLED');
      FETCH get_fee_amt_csr2 INTO l_tax_amt;
      CLOSE get_fee_amt_csr2;
    END IF;

    --Bug# 6939336
    --Bug# 6668721
    OPEN contract_billed_tax_csr(p_contract_id => p_contract_id);
    FETCH contract_billed_tax_csr INTO l_contract_billed_tax;
    CLOSE contract_billed_tax_csr;

    l_tax_amt := l_tax_amt + l_contract_billed_tax;
    --Bug# 6668721
    --Bug# 6939336

    RETURN l_tax_amt;

  END get_billed_tax;

  FUNCTION get_upfront_tax(p_chr_id  IN NUMBER,
                           p_tax_treatment IN VARCHAR2)
  RETURN NUMBER
  IS

    l_tax_amt NUMBER;
    l_rule_info_rec  rule_info_csr%ROWTYPE;

  BEGIN

    OPEN  rule_info_csr(p_contract_id => p_chr_id);
    FETCH rule_info_csr INTO l_rule_info_rec;
    CLOSE rule_info_csr;

    IF l_rule_info_rec.rule_information1 IS NOT NULL THEN
      IF (p_tax_treatment = 'CAPITALIZED') THEN
        l_tax_amt := get_capitalized_tax (p_contract_id => p_chr_id,
                                          p_default_tax_treatment => l_rule_info_rec.rule_information1);
      ELSIF (p_tax_treatment = 'FINANCED') THEN
        l_tax_amt := get_financed_tax (p_contract_id => p_chr_id,
                                       p_default_tax_treatment => l_rule_info_rec.rule_information1);
      ELSIF (p_tax_treatment = 'BILLED') THEN
        l_tax_amt := get_billed_tax (p_contract_id => p_chr_id,
                                     p_default_tax_treatment => l_rule_info_rec.rule_information1);
      END IF;
    END IF;

    RETURN l_tax_amt;

  END get_upfront_tax;

  PROCEDURE update_fee(
            p_api_version      IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
            p_contract_id      IN  NUMBER,
            p_transaction_id   IN  NUMBER,
            p_fee_line_id      IN  NUMBER,
            p_required_feetype IN  VARCHAR2,
            p_default_feetype  IN  VARCHAR2,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2
            )
  IS
    l_fee_types_rec   OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    lx_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    l_u_line_item_tbl   OKL_CONTRACT_LINE_ITEM_PVT.line_item_tbl_type;
    lx_u_line_item_tbl  OKL_CONTRACT_LINE_ITEM_PVT.line_item_tbl_type;

    l_c_line_item_tbl   OKL_CONTRACT_LINE_ITEM_PVT.line_item_tbl_type;
    lx_c_line_item_tbl  OKL_CONTRACT_LINE_ITEM_PVT.line_item_tbl_type;

    l_rgpv_rec          rgpv_rec_type;
    l_rulv_rec          rulv_rec_type;
    l_rulv_tbl          rulv_tbl_type;
    lx_rgpv_rec         rgpv_rec_type;
    lx_rulv_rec         rulv_rec_type;
    lx_rulv_tbl         rulv_tbl_type;

    l_ins_count NUMBER := 0;
    l_upd_count NUMBER := 0;
    l_del_count NUMBER := 0;
    l_upfront_tax_fee_amount NUMBER;

    -- Cursor to get assets for financed fee association
    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR get_asset_csr1 (p_fee_type IN VARCHAR2)
    IS
    SELECT cle.id, cle.name, cle.item_description
    FROM   okc_k_lines_v cle,
           okc_rule_groups_b rg1,
           okc_rules_b rl1,
           okc_line_styles_b lse,
           okc_rule_groups_b rg2,
           okc_rules_b rl2
    WHERE  cle.chr_ID = p_contract_id
    AND    cle.lse_id     = lse.id
    AND    lse.lty_code   = 'FREE_FORM1'
    AND    cle.dnz_chr_id = rg1.dnz_chr_id
    AND    cle.id         = rg1.cle_id
    AND    cle.dnz_chr_id = rl1.dnz_chr_id
    AND    rg1.id         = rl1.rgp_id
    AND    rg1.rgd_code   = 'LAASTX'
    AND    rl1.rule_information_category = 'LAASTX'
    AND    ( rl1.rule_information11 IS NULL
             OR
             rl1.rule_information11 = p_fee_type)
    AND    cle.dnz_chr_id = rg2.dnz_chr_id
    AND    cle.dnz_chr_id = rl2.dnz_chr_id
    AND    rg2.id         = rl2.rgp_id
    AND    rg2.rgd_code   = 'LAHDTX'
    AND    rl2.rule_information_category = 'LASTPR'
    AND    rl2.rule_information1 = p_fee_type
    AND    cle.sts_code <> 'ABANDONED';

    -- Cursor to get assets for fee association if T and C Tax treatment is
    -- 'BILLED'
    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR get_asset_csr2 (p_fee_type IN VARCHAR2)
    IS
    SELECT cle.id, cle.name, cle.item_description
    FROM   okc_k_lines_v cle,
           okc_rule_groups_b rg1,
           okc_rules_b rl1,
           okc_line_styles_b lse
    WHERE  cle.dnz_chr_id = p_contract_id
    AND    cle.lse_id     = lse.id
    AND    lse.lty_code   = 'FREE_FORM1'
    AND    cle.dnz_chr_id = rg1.dnz_chr_id
    AND    cle.id         = rg1.cle_id
    AND    cle.dnz_chr_id = rl1.dnz_chr_id
    AND    rg1.id         = rl1.rgp_id
    AND    rg1.rgd_code   = 'LAASTX'
    AND    rl1.rule_information_category = 'LAASTX'
    AND    rl1.rule_information11 = p_fee_type
    AND    cle.sts_code <> 'ABANDONED';

    -- Cursor to get tax amounts for assets
    CURSOR get_asset_tax_amt_csr (asset_line_id IN NUMBER)
    IS
    SELECT NVL(SUM(NVL(total_tax,0)),0)
    FROM   okl_tax_sources txs
    WHERE  txs.khr_ID = p_contract_id
    AND    txs.trx_id = p_transaction_id
    AND    txs.kle_id = asset_line_id
    AND    txs.tax_line_status_code = 'ACTIVE'
    AND    txs.tax_call_type_code = 'UPFRONT_TAX';

    -- Cursor to get fee details
    CURSOR l_fee_csr(p_fee_cle_id IN NUMBER) IS
    SELECT NVL(kle_fee.capital_amount,kle_fee.amount) amount,
           kle_fee.fee_type,
           cleb_fee.start_date,
           cleb_fee.end_date,
           cim_fee.id cim_fee_id,
           cim_fee.object1_id1
    FROM okl_k_lines kle_fee,
         okc_k_lines_b cleb_fee,
         okc_k_items cim_fee
    WHERE cleb_fee.id = p_fee_cle_id
    AND kle_fee.id = cleb_fee.id
    AND cim_fee.cle_id = cleb_fee.id
    AND cim_fee.dnz_chr_id = cleb_fee.dnz_chr_id
    AND cim_fee.jtot_object1_code = 'OKL_STRMTYP';

    l_fee_rec l_fee_csr%ROWTYPE;

    -- Cursor to get fee covered asset line
    -- Bug# 6512668: Exclude covered asset lines in Abandoned status
    CURSOR l_cov_asset_line_csr(p_chr_id IN NUMBER,
                                p_fee_cle_id IN NUMBER,
                                p_fin_asset_cle_id IN NUMBER) IS
    SELECT cleb_cov_asset.id cleb_cov_asset_id,
           NVL(kle_cov_asset.capital_amount,kle_cov_asset.amount) amount,
           cim_cov_asset.id cim_cov_asset_id
    FROM okc_k_lines_b cleb_cov_asset,
         okl_k_lines kle_cov_asset,
         okc_k_items cim_cov_asset
    WHERE cleb_cov_asset.cle_id = p_fee_cle_id
    AND   cleb_cov_asset.dnz_chr_id = p_chr_id
    AND   kle_cov_asset.id = cleb_cov_asset.id
    AND   cim_cov_asset.cle_id = cleb_cov_asset.id
    AND   cim_cov_asset.dnz_chr_id = cleb_cov_asset.dnz_chr_id
    AND   cim_cov_asset.object1_id1 = p_fin_asset_cle_id
    AND   cim_cov_asset.jtot_object1_code = 'OKX_COVASST'
    AND   cleb_cov_asset.sts_code <> 'ABANDONED';

    l_cov_asset_line_rec l_cov_asset_line_csr%ROWTYPE;

    -- Cursor to get fee expensee
    CURSOR l_rul_csr(p_chr_id IN NUMBER,
                     p_fee_cle_id IN NUMBER) IS
    SELECT rul_lafexp.id,
           rul_lafexp.rgp_id,
           rul_lafexp.dnz_chr_id,
           rul_lafexp.rule_information_category,
           TO_NUMBER(rul_lafexp.rule_information2) amount
    FROM okc_rule_groups_b rgp_lafexp,
         okc_rules_b rul_lafexp
    WHERE rgp_lafexp.dnz_chr_id = p_chr_id
    AND   rgp_lafexp.cle_id = p_fee_cle_id
    AND   rgp_lafexp.rgd_code = 'LAFEXP'
    AND   rul_lafexp.rgp_id = rgp_lafexp.id
    AND   rul_lafexp.dnz_chr_id = rgp_lafexp.dnz_chr_id
    AND   rul_lafexp.rule_information_category = 'LAFEXP';

    l_rul_rec l_rul_csr%ROWTYPE;

    -- Cursor to check if sales tax fee exists
    -- Bug# 6512668: Exclude fee lines in Abandoned status
    CURSOR check_fee_csr(p_chr_id IN NUMBER,
                         p_fee_type IN VARCHAR2 )  IS
    SELECT cle.id
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.id = kle.id
    AND    cle.dnz_chr_id = p_chr_id
    AND    kle.fee_purpose_code = 'SALESTAX'
    AND    kle.fee_type = p_fee_type
    AND    cle.sts_code <> 'ABANDONED';

    l_del_fee_line_id    OKC_K_LINES_B.id%TYPE;
    l_del_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;

    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR l_del_cov_asset_csr1(p_chr_id IN NUMBER,
                                p_fee_cle_id IN NUMBER) IS
    SELECT cleb_cov_asset.id cleb_cov_asset_id,
           cim_cov_asset.id cim_cov_asset_id
    FROM okc_k_lines_b cleb_cov_asset,
         okc_k_items cim_cov_asset,
         okc_k_lines_b cleb_fin,
         okc_rule_groups_b rgp,
         okc_rules_b rul
    WHERE cleb_cov_asset.cle_id = p_fee_cle_id
    AND   cleb_cov_asset.dnz_chr_id = p_chr_id
    AND   cim_cov_asset.cle_id = cleb_cov_asset.id
    AND   cim_cov_asset.dnz_chr_id = cleb_cov_asset.dnz_chr_id
    AND   cim_cov_asset.jtot_object1_code = 'OKX_COVASST'
    AND   cleb_fin.id = cim_cov_asset.object1_id1
    AND   cleb_fin.chr_id = cim_cov_asset.dnz_chr_id
    AND   cleb_fin.dnz_chr_id = cim_cov_asset.dnz_chr_id
    AND   rgp.dnz_chr_id = cleb_fin.dnz_chr_id
    AND   rgp.cle_id     = cleb_fin.id
    AND   rgp.rgd_code   = 'LAASTX'
    AND   rul.dnz_chr_id = rgp.dnz_chr_id
    AND   rul.rgp_id     = rgp.id
    AND   rul.rule_information_category = 'LAASTX'
    AND   rul.rule_information11 = 'BILLED'
    AND   cleb_fin.sts_code <> 'ABANDONED'
    AND   cleb_cov_asset.sts_code <> 'ABANDONED';

    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR l_del_cov_asset_csr2(p_chr_id IN NUMBER,
                                p_fee_cle_id IN NUMBER) IS
    SELECT cleb_cov_asset.id cleb_cov_asset_id,
           cim_cov_asset.id cim_cov_asset_id
    FROM okc_k_lines_b cleb_cov_asset,
         okc_k_items cim_cov_asset,
         okc_k_lines_b cleb_fin,
         okc_rule_groups_b rgp,
         okc_rules_b rul
    WHERE cleb_cov_asset.cle_id = p_fee_cle_id
    AND   cleb_cov_asset.dnz_chr_id = p_chr_id
    AND   cim_cov_asset.cle_id = cleb_cov_asset.id
    AND   cim_cov_asset.dnz_chr_id = cleb_cov_asset.dnz_chr_id
    AND   cim_cov_asset.jtot_object1_code = 'OKX_COVASST'
    AND   cleb_fin.id = cim_cov_asset.object1_id1
    AND   cleb_fin.chr_id = cim_cov_asset.dnz_chr_id
    AND   cleb_fin.dnz_chr_id = cim_cov_asset.dnz_chr_id
    AND   rgp.dnz_chr_id = cleb_fin.dnz_chr_id
    AND   rgp.cle_id     = cleb_fin.id
    AND   rgp.rgd_code   = 'LAASTX'
    AND   rul.dnz_chr_id = rgp.dnz_chr_id
    AND   rul.rgp_id     = rgp.id
    AND   rul.rule_information_category = 'LAASTX'
    AND   NVL(rul.rule_information11,'BILLED') = 'BILLED'
    AND   cleb_fin.sts_code <> 'ABANDONED'
    AND   cleb_cov_asset.sts_code <> 'ABANDONED';

    l_d_line_item_tbl   OKL_CONTRACT_LINE_ITEM_PVT.line_item_tbl_type;

    l_asset_tax_amt NUMBER;
    update_fee_exception exception;

    x_msg_index_out Number;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;

    -- If upfront tax is 'FINANCED'
    IF (p_required_feetype = 'FINANCE') THEN
      l_upfront_tax_fee_amount := get_financed_tax (p_contract_id, p_default_feetype);

      -- Delete any Sales Tax Fee having Fee Type 'Capitalized'
      OPEN check_fee_csr(p_chr_id => p_contract_id,
                         p_fee_type => 'CAPITALIZED');
      FETCH check_fee_csr INTO l_del_fee_line_id;
      CLOSE check_fee_csr;

    -- If upfront tax is 'CAPITALIZED'
    ELSIF (p_required_feetype = 'CAPITALIZE') THEN
      l_upfront_tax_fee_amount := get_capitalized_tax (p_contract_id, p_default_feetype);

      -- Delete any Sales Tax Fee having Fee Type 'Financed'
      OPEN check_fee_csr(p_chr_id => p_contract_id,
                         p_fee_type => 'FINANCED');
      FETCH check_fee_csr INTO l_del_fee_line_id;
      CLOSE check_fee_csr;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: l_upfront_tax_fee_amount: '||l_upfront_tax_fee_amount);
    END IF;

    IF (l_del_fee_line_id IS NOT NULL) THEN
      l_del_fee_types_rec.line_id := l_del_fee_line_id;
      l_del_fee_types_rec.dnz_chr_id := p_contract_id;

      -- delete fee line
      OKL_MAINTAIN_FEE_PVT.delete_fee_type(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_fee_types_rec  => l_del_fee_types_rec
       );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: after OKL_MAINTAIN_FEE_PVT.delete_fee_type: x_return_status '||x_return_status);
      END IF;

      -- Check if the call was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE update_fee_exception;
      END IF;
    END IF;

    OPEN l_fee_csr(p_fee_cle_id => p_fee_line_id);
    FETCH l_fee_csr INTO l_fee_rec;
    CLOSE l_fee_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: l_fee_rec.amount: '||l_fee_rec.amount);
    END IF;

    IF (l_upfront_tax_fee_amount <> l_fee_rec.amount) THEN

      l_fee_types_rec.line_id          := p_fee_line_id;
      l_fee_types_rec.dnz_chr_id       := p_contract_id;
      l_fee_types_rec.amount           := l_upfront_tax_fee_amount;
      l_fee_types_rec.fee_type         := l_fee_rec.fee_type;
      l_fee_types_rec.effective_from   := l_fee_rec.start_date;
      l_fee_types_rec.effective_to     := l_fee_rec.end_date;
      l_fee_types_rec.item_id          := l_fee_rec.cim_fee_id;
      l_fee_types_rec.item_id1         := l_fee_rec.object1_id1;

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before OKL_MAINTAIN_FEE_PVT.update_fee_type ');
      END IF;

      -- update fee top line
      OKL_MAINTAIN_FEE_PVT.update_fee_type(
        p_api_version    => p_api_version,
        p_init_msg_list  => p_init_msg_list,
        x_return_status  => x_return_status,
        x_msg_count      => x_msg_count,
        x_msg_data       => x_msg_data,
        p_fee_types_rec  => l_fee_types_rec,
        x_fee_types_rec  => lx_fee_types_rec
       );

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: after OKL_MAINTAIN_FEE_PVT.update_fee_type: x_return_status '||x_return_status);
      END IF;

      -- Check if the call was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE update_fee_exception;
      END IF;
    END IF;

    IF (p_default_feetype IN ('CAPITALIZE','FINANCE')) THEN
      l_ins_count :=1;
      l_upd_count :=1;
      FOR j in get_asset_csr1(p_required_feetype)
      LOOP

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before get_asset_tax_amt_csr ');
        END IF;

        -- get asset tax amount
        OPEN  get_asset_tax_amt_csr(j.id);
        FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
        IF get_asset_tax_amt_csr%NOTFOUND THEN

          OKL_API.set_message(G_APP_NAME, 'OKL_LA_ST_ASSET_TAX_AMT_ERROR');
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount for ID'|| j.id);
          END IF;
          CLOSE get_asset_tax_amt_csr;
          RAISE update_fee_exception;
        END IF;
        CLOSE get_asset_tax_amt_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: l_asset_tax_amt '||l_asset_tax_amt);
        END IF;

        l_cov_asset_line_rec.cleb_cov_asset_id := NULL;
        l_cov_asset_line_rec.amount := NULL;
        l_cov_asset_line_rec.cim_cov_asset_id := NULL;
        OPEN l_cov_asset_line_csr(p_chr_id     => p_contract_id,
                                  p_fee_cle_id => p_fee_line_id,
                                  p_fin_asset_cle_id => j.id);
        FETCH l_cov_asset_line_csr INTO l_cov_asset_line_rec;
        CLOSE l_cov_asset_line_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: l_cov_asset_line_rec.cleb_cov_asset_id '||l_cov_asset_line_rec.cleb_cov_asset_id);
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: l_cov_asset_line_rec.amount '||l_cov_asset_line_rec.amount);
        END IF;

        -- Update Fee covered asset amount if covered asset line exists, else create covered asset line
        IF l_cov_asset_line_rec.cleb_cov_asset_id IS NOT NULL THEN

          IF  (l_asset_tax_amt <> l_cov_asset_line_rec.amount) THEN

                l_u_line_item_tbl(l_upd_count).cle_id            := l_cov_asset_line_rec.cleb_cov_asset_id;
                l_u_line_item_tbl(l_upd_count).item_id           := l_cov_asset_line_rec.cim_cov_asset_id;

                l_u_line_item_tbl(l_upd_count).chr_id            := p_contract_id;
                l_u_line_item_tbl(l_upd_count).parent_cle_id     := p_fee_line_id;
                l_u_line_item_tbl(l_upd_count).item_id1          := j.id;
                l_u_line_item_tbl(l_upd_count).item_id2          := '#';
                l_u_line_item_tbl(l_upd_count).item_object1_code := 'OKX_COVASST';
                l_u_line_item_tbl(l_upd_count).item_description  := j.item_description;
                l_u_line_item_tbl(l_upd_count).name              := j.name;
                l_u_line_item_tbl(l_upd_count).capital_amount    := l_asset_tax_amt;

                l_upd_count := l_upd_count + 1;
          END IF;
        ELSE

              l_c_line_item_tbl(l_ins_count).chr_id            := p_contract_id;
              l_c_line_item_tbl(l_ins_count).parent_cle_id     := p_fee_line_id;
              l_c_line_item_tbl(l_ins_count).item_id1          := j.id;
              l_c_line_item_tbl(l_ins_count).item_id2          := '#';
              l_c_line_item_tbl(l_ins_count).item_object1_code := 'OKX_COVASST';
              l_c_line_item_tbl(l_ins_count).item_description  := j.item_description;
              l_c_line_item_tbl(l_ins_count).name              := j.name;
              l_c_line_item_tbl(l_ins_count).capital_amount    := l_asset_tax_amt;

              l_ins_count := l_ins_count + 1;
        END IF;
      END LOOP;

      l_del_count := 1;
      --Delete covered asset lines for assets that have tax treatment 'Billed'
      FOR l_del_cov_asset_rec IN l_del_cov_asset_csr1(p_chr_id     => p_contract_id,
                                                      p_fee_cle_id => p_fee_line_id) LOOP

        --Bug# 6512668: Corrected l_upd_count to l_del_count
        l_d_line_item_tbl(l_del_count).chr_id         := p_contract_id;
        l_d_line_item_tbl(l_del_count).parent_cle_id  := p_fee_line_id;
        l_d_line_item_tbl(l_del_count).cle_id         := l_del_cov_asset_rec.cleb_cov_asset_id;
        l_d_line_item_tbl(l_del_count).item_id        := l_del_cov_asset_rec.cim_cov_asset_id;

        l_del_count := l_del_count + 1;

      END LOOP;

    ELSIF (p_default_feetype = 'BILLED') THEN
      l_ins_count :=1;
      l_upd_count :=1;
      FOR j in get_asset_csr2 (p_required_feetype)
      LOOP

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before get_asset_tax_amt_csr ');
        END IF;

        -- get asset tax amount
        OPEN  get_asset_tax_amt_csr(j.id);
        FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
        IF get_asset_tax_amt_csr%NOTFOUND THEN
          OKL_API.set_message( p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LA_ST_ASSET_TAX_AMT_ERROR');
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount. for ID'|| j.id);
          END IF;
          CLOSE get_asset_tax_amt_csr;
          RAISE update_fee_exception;
        END IF;
        CLOSE get_asset_tax_amt_csr;

        l_cov_asset_line_rec.cleb_cov_asset_id := NULL;
        l_cov_asset_line_rec.amount := NULL;
        l_cov_asset_line_rec.cim_cov_asset_id := NULL;
        OPEN l_cov_asset_line_csr(p_chr_id     => p_contract_id,
                                  p_fee_cle_id => p_fee_line_id,
                                  p_fin_asset_cle_id => j.id);
        FETCH l_cov_asset_line_csr INTO l_cov_asset_line_rec;
        CLOSE l_cov_asset_line_csr;

        -- Update Fee covered asset amount if covered asset line exists, else create covered asset line
        IF l_cov_asset_line_rec.cleb_cov_asset_id IS NOT NULL THEN

          IF  (l_asset_tax_amt <> l_cov_asset_line_rec.amount) THEN

            l_u_line_item_tbl(l_upd_count).cle_id            := l_cov_asset_line_rec.cleb_cov_asset_id;
            l_u_line_item_tbl(l_upd_count).item_id           := l_cov_asset_line_rec.cim_cov_asset_id;

            l_u_line_item_tbl(l_upd_count).chr_id            := p_contract_id;
            l_u_line_item_tbl(l_upd_count).parent_cle_id     := p_fee_line_id;
            l_u_line_item_tbl(l_upd_count).item_id1          := j.id;
            l_u_line_item_tbl(l_upd_count).item_id2          := '#';
            l_u_line_item_tbl(l_upd_count).item_object1_code := 'OKX_COVASST';
            l_u_line_item_tbl(l_upd_count).item_description  := j.item_description;
            l_u_line_item_tbl(l_upd_count).name              := j.name;
            l_u_line_item_tbl(l_upd_count).capital_amount    := l_asset_tax_amt;

            l_upd_count := l_upd_count + 1;
          END IF;
        ELSE

            l_c_line_item_tbl(l_ins_count).chr_id            := p_contract_id;
            l_c_line_item_tbl(l_ins_count).parent_cle_id     := p_fee_line_id;
            l_c_line_item_tbl(l_ins_count).item_id1          := j.id;
            l_c_line_item_tbl(l_ins_count).item_id2          := '#';
            l_c_line_item_tbl(l_ins_count).item_object1_code := 'OKX_COVASST';
            l_c_line_item_tbl(l_ins_count).item_description  := j.item_description;
            l_c_line_item_tbl(l_ins_count).name              := j.name;
            l_c_line_item_tbl(l_ins_count).capital_amount    := l_asset_tax_amt;

            l_ins_count := l_ins_count + 1;
        END IF;

      END LOOP;

      l_del_count := 1;
      --Delete covered asset lines for assets that have tax treatment 'BILLED' or NULL
      FOR l_del_cov_asset_rec IN l_del_cov_asset_csr2(p_chr_id     => p_contract_id,
                                                      p_fee_cle_id => p_fee_line_id) LOOP

        --Bug# 6512668: Corrected l_upd_count to l_del_count
        l_d_line_item_tbl(l_del_count).chr_id         := p_contract_id;
        l_d_line_item_tbl(l_del_count).parent_cle_id  := p_fee_line_id;
        l_d_line_item_tbl(l_del_count).cle_id         := l_del_cov_asset_rec.cleb_cov_asset_id;
        l_d_line_item_tbl(l_del_count).item_id        := l_del_cov_asset_rec.cim_cov_asset_id;

        l_del_count := l_del_count + 1;

      END LOOP;
    END IF;

    -- Associate Assets to the fee
    IF (l_c_line_item_tbl.COUNT > 0) THEN

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before okl_contract_line_item_pvt.create_contract_line_item ');
      END IF;

      okl_contract_line_item_pvt.create_contract_line_item(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             p_line_item_tbl    => l_c_line_item_tbl,
                             x_line_item_tbl    => lx_c_line_item_tbl);


      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: x_return_status '||x_return_status);
      END IF;

      -- Check if the call was successful
      If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
        RAISE update_fee_exception;
      End If;
    END IF;

    IF (l_u_line_item_tbl.COUNT > 0) THEN

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before okl_contract_line_item_pvt.update_contract_line_item ');
      END IF;

      okl_contract_line_item_pvt.update_contract_line_item(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             p_line_item_tbl    => l_u_line_item_tbl,
                             x_line_item_tbl    => lx_u_line_item_tbl);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: x_return_status '||x_return_status);
      END IF;

      -- Check if the call was successful
      If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
        RAISE update_fee_exception;
      End If;
    END IF;

    IF (l_d_line_item_tbl.COUNT > 0) THEN

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before okl_contract_line_item_pvt.delete_contract_line_item ');
      END IF;

      okl_contract_line_item_pvt.delete_contract_line_item(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             p_line_item_tbl    => l_d_line_item_tbl);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: x_return_status '||x_return_status);
      END IF;

      -- Check if the call was successful
      If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
        RAISE update_fee_exception;
      End If;
    END IF;

    IF (p_required_feetype = 'FINANCE') THEN
      -- Following Segment is for updating Expense Item for Financed Fee
      OPEN l_rul_csr(p_chr_id     => p_contract_id,
                     p_fee_cle_id => p_fee_line_id);
      FETCH l_rul_csr INTO l_rul_rec;
      CLOSE l_rul_csr;

      IF (l_rul_rec.amount <> l_upfront_tax_fee_amount) THEN

          -- Populate Rule Values for Expenses
          l_rulv_tbl(1).id                    := l_rul_rec.id;
          l_rulv_tbl(1).rgp_id                := l_rul_rec.rgp_id;
          l_rulv_tbl(1).dnz_chr_id            := l_rul_rec.dnz_chr_id;
          l_rulv_tbl(1).rule_information_category := l_rul_rec.rule_information_category;
          l_rulv_tbl(1).rule_information2     :=  TO_CHAR(l_upfront_tax_fee_amount);

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: before OKL_RULE_PUB.update_rule ');
          END IF;
          OKL_RULE_PUB.update_rule(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rulv_tbl       => l_rulv_tbl,
             x_rulv_tbl       => lx_rulv_tbl);

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: x_return_status '||x_return_status);
          END IF;

          If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
            RAISE update_fee_exception;
          End If;
      END IF;
    END IF;

  EXCEPTION
      when update_fee_exception then
         x_return_status := OKL_API.G_RET_STS_ERROR;

  END update_fee;

  PROCEDURE process_tax_override(
            p_api_version      IN  NUMBER,
            p_init_msg_list    IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id           IN  NUMBER,
            p_transaction_id   IN  NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2,
            x_msg_count        OUT NOCOPY NUMBER,
            x_msg_data         OUT NOCOPY VARCHAR2
            )
  IS

  l_api_name	CONSTANT VARCHAR2(30) := 'UPDATE_FEE';
  l_api_version	CONSTANT NUMBER	      := 1.0;

  l_rule_info_rec  rule_info_csr%ROWTYPE;

  -- Cursor to check if Sales Tax fee exists
  -- Bug# 6512668: Exclude fee line in Abandoned status
  CURSOR l_fee_csr (p_chr_id IN NUMBER)  IS
  SELECT cle.id,
         kle.fee_type
  FROM   okc_k_lines_b cle,
         okl_k_lines kle
  WHERE  cle.id = kle.id
  AND    cle.dnz_chr_id = p_chr_id
  AND    cle.chr_id = p_chr_id
  AND    kle.fee_purpose_code = 'SALESTAX'
  AND    cle.sts_code <> 'ABANDONED';

  l_fee_rec l_fee_csr%ROWTYPE;

  l_upfront_tax_prog_sts OKL_BOOK_CONTROLLER_TRX.progress_status%TYPE;

  BEGIN

    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

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

    OPEN  rule_info_csr(p_contract_id => p_chr_id);
    FETCH rule_info_csr INTO l_rule_info_rec;
    IF rule_info_csr%NOTFOUND THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QA_ST_MISSING');
      CLOSE rule_info_csr;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE rule_info_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: Default Fee Type '||l_rule_info_rec.rule_information1);
    END IF;

    OPEN l_fee_csr(p_chr_id => p_chr_id);
    FETCH l_fee_csr INTO l_fee_rec;
    CLOSE l_fee_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: Sales Tax Fee Line Id '||l_fee_rec.id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: Sales Tax Fee Type '||l_fee_rec.fee_type);
    END IF;

    IF l_fee_rec.id IS NOT NULL THEN

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: Before OKL_LA_SALES_TAX_PVT.update_fee ');
      END IF;

      OKL_LA_SALES_TAX_PVT.update_fee
       (p_api_version      => p_api_version,
        p_init_msg_list    => p_init_msg_list,
        p_contract_id      => p_chr_id,
        p_transaction_id   => p_transaction_id,
        p_fee_line_id      => l_fee_rec.id,
        p_required_feetype => l_fee_rec.fee_type,
        p_default_feetype  => l_rule_info_rec.rule_information1,
        x_return_status    => x_return_status,
        x_msg_count        => x_msg_count,
        x_msg_data         => x_msg_data);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: After OKL_LA_SALES_TAX_PVT.update_fee: x_return_status '||x_return_status);
      END IF;

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      OKL_LA_SALES_TAX_PVT.validate_upfront_tax_fee(
       p_api_version       => p_api_version,
       p_init_msg_list     => p_init_msg_list,
       x_return_status     => x_return_status,
       x_msg_count         => x_msg_count,
       x_msg_data          => x_msg_data,
       p_chr_id            => p_chr_id);

      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Update Fee Procedure: After OKL_LA_SALES_TAX_PVT.validate_upfront_tax_fee: x_return_status '||x_return_status);
      END IF;

      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_upfront_tax_prog_sts := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_ERROR;
      ELSE
        l_upfront_tax_prog_sts := OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_COMPLETE;
      END IF;

      OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_CALC_UPFRONT_TAX ,
        p_progress_status    => l_upfront_tax_prog_sts);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    --Update Contract Status to Passed
    OKL_CONTRACT_STATUS_PUB.update_contract_status(
      p_api_version   => p_api_version,
      p_init_msg_list => p_init_msg_list,
      x_return_status => x_return_status,
      x_msg_count     => x_msg_count,
      x_msg_data      => x_msg_data,
      p_khr_status    => 'PASSED',
      p_chr_id        => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --call to cascade status on to lines
    OKL_CONTRACT_STATUS_PUB.cascade_lease_status
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_chr_id          => p_chr_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Update status of Price Contract process to Pending
    OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_PRICE_CONTRACT,
        p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Update status of Submit Contract process to Pending
    OKL_BOOK_CONTROLLER_PVT.update_book_controller_trx(
        p_api_version        => p_api_version,
        p_init_msg_list      => p_init_msg_list,
        x_return_status      => x_return_status,
        x_msg_count          => x_msg_count,
        x_msg_data           => x_msg_data,
        p_khr_id             => p_chr_id ,
        p_prog_short_name    => OKL_BOOK_CONTROLLER_PVT.G_SUBMIT_CONTRACT,
        p_progress_status    => OKL_BOOK_CONTROLLER_PVT.G_PROG_STS_PENDING);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

     WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

  END process_tax_override;
  -- R12B Authoring OA Migration

  -- Procedure to create Financed fee
  Procedure create_fee(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_id   IN  NUMBER,
                      p_default_feetype  IN  VARCHAR2,
                      p_required_feetype IN  VARCHAR2,
                      p_stream_id        IN  NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2
                      )
  IS
    l_fee_types_rec   OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    lx_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    l_line_item_tbl   okl_contract_line_item_pvt.line_item_tbl_type;
    lx_line_item_tbl  okl_contract_line_item_pvt.line_item_tbl_type;

    l_rgpv_rec          rgpv_rec_type;
    l_rulv_rec          rulv_rec_type;
    l_rulv_tbl          rulv_tbl_type;
    lx_rgpv_rec         rgpv_rec_type;
    lx_rulv_rec         rulv_rec_type;
    lx_rulv_tbl         rulv_tbl_type;

    i NUMBER := 0;
    l_financed_amount NUMBER;
    l_capitalized_amount NUMBER;

    -- R12B Authoring OA Migration
    -- Cursor to check if financed fee exists
    -- Bug# 6512668: Exclude fee line in Abandoned status
    CURSOR check_fee_csr ( l_fee_type IN VARCHAR2 )  IS
    SELECT cle.id
    FROM   OKC_K_LINES_b cle,
           OKL_K_LINES KLE
    WHERE  cle.id = kle.id
    AND    cle.dnz_chr_id = p_contract_id
    AND    kle.fee_purpose_code = 'SALESTAX'
    AND    kle.fee_type = l_fee_type
    AND    cle.sts_code <> 'ABANDONED';

    l_fee_line_id OKC_K_LINES_B.id%TYPE;
    -- R12B Authoring OA Migration

    -- cursor to get item id
    CURSOR stream_csr (stream_type_id IN NUMBER)  IS
    select name
    from   OKL_STRM_TYPE_TL
    where  id = stream_type_id;

    -- Get contract dates
    CURSOR contract_dates_csr IS
    SELECT start_date, end_date
    FROM   okc_k_headers_b
    WHERE  id = p_contract_id;

    -- Cursor to get assets for financed fee association
    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR get_asset_csr1 (p_fee_type IN VARCHAR2)
    IS
    SELECT cle.id, cle.name, cle.item_description
    FROM   okc_k_lines_v cle,
           okc_rule_groups_b rg1,
           okc_rules_b rl1,
           okc_line_styles_b lse,
           okc_rule_groups_b rg2,
           okc_rules_b rl2
    WHERE  cle.chr_ID = p_contract_id
    AND    cle.lse_id     = lse.id
    AND    lse.lty_code   = 'FREE_FORM1'
    AND    cle.dnz_chr_id = rg1.dnz_chr_id
    AND    cle.id         = rg1.cle_id
    AND    cle.dnz_chr_id = rl1.dnz_chr_id
    AND    rg1.id         = rl1.rgp_id
    AND    rg1.rgd_code   = 'LAASTX'
    AND    rl1.rule_information_category = 'LAASTX'
    AND    ( rl1.rule_information11 IS NULL
             OR
             rl1.rule_information11 = p_fee_type)
    AND    cle.dnz_chr_id = rg2.dnz_chr_id
    AND    cle.dnz_chr_id = rl2.dnz_chr_id
    AND    rg2.id         = rl2.rgp_id
    AND    rg2.rgd_code   = 'LAHDTX'
    AND    rl2.rule_information_category = 'LASTPR'
    AND    rl2.rule_information1 = p_fee_type
    AND    cle.sts_code <> 'ABANDONED';


    -- Cursor to get assets for fee association if T and C Tax treatment is
    -- 'BILLED'
    -- Bug# 6512668: Exclude asset lines in Abandoned status
    CURSOR get_asset_csr2 (p_fee_type IN VARCHAR2)
    IS
    SELECT cle.id, cle.name, cle.item_description
    FROM   okc_k_lines_v cle,
           okc_rule_groups_b rg1,
           okc_rules_b rl1,
           okc_line_styles_b lse
    WHERE  cle.dnz_chr_ID = p_contract_id
    AND    cle.lse_id     = lse.id
    AND    lse.lty_code   = 'FREE_FORM1'
    AND    cle.dnz_chr_id = rg1.dnz_chr_id
    AND    cle.id         = rg1.cle_id
    AND    cle.dnz_chr_id = rl1.dnz_chr_id
    AND    rg1.id         = rl1.rgp_id
    AND    rg1.rgd_code   = 'LAASTX'
    AND    rl1.rule_information_category = 'LAASTX'
    AND    rl1.rule_information11 = p_fee_type
    AND    cle.sts_code <> 'ABANDONED';


    -- Cursor to get tax amounts for assets
    CURSOR get_asset_tax_amt_csr (asset_line_id IN NUMBER)
    IS
    SELECT NVL(SUM(NVL(TOTAL_TAX,0)),0)
    FROM   okl_tax_sources txs
    WHERE  txs.KHR_ID = p_contract_id
    AND    txs.trx_id = p_transaction_id
    AND    txs.kle_id = asset_line_id
    AND    txs.TAX_LINE_STATUS_CODE = 'ACTIVE'
    AND    txs.TAX_CALL_TYPE_CODE = 'UPFRONT_TAX';

    -- Cursor Types
    contract_dates_csr_rec contract_dates_csr%ROWTYPE;

    l_finance_fee_exists VARCHAR(1);
    l_capitalized_fee_exists VARCHAR(1);
    l_item_name VARCHAR2(150);
    l_asset_tax_amt NUMBER;
    l_asset_count NUMBER := 0;

     -- Define constants
    create_fee_exception exception;

    x_msg_index_out Number;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;

    -- If upfront tax is 'FINANCED'
    If (p_required_feetype = 'FINANCE') THEN

      --l_financed_amount := get_financed_tax ( p_Contract_id, p_transaction_id);
      l_financed_amount := get_financed_tax ( p_Contract_id, p_default_feetype);
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: FINANCE segment: l_financed_amount: '
                               ||l_financed_amount);
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before check_fee_csr ');
      END IF;

      -- Check If finance fee already exists
      -- if exists do nothing, because we can only create once
      OPEN check_fee_csr ('FINANCED');
      -- R12B Authoring OA Migration
      FETCH check_fee_csr INTO l_fee_line_id;
      -- R12B Authoring OA Migration

      IF check_fee_csr%NOTFOUND THEN
        l_finance_fee_exists := OKL_API.G_FALSE;
      Else
        l_finance_fee_exists := OKL_API.G_TRUE;
      END IF;
      CLOSE check_fee_csr;

      -- Create Fee only if the amount is > 0 and Sale Tax Fee does not
      -- exist already
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: FINANCE segment: before IF condition');
      END IF;
      If ((l_financed_amount > 0) AND
          (l_finance_fee_exists = OKL_API.G_FALSE)) THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before stream_csr ');
        END IF;
        -- get item_id1 value
        OPEN  stream_csr(p_stream_id);
        FETCH stream_csr INTO l_item_name;
        IF stream_csr%NOTFOUND THEN
          OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_LA_ST_STREAM_ERROR',
              p_token1       => 'FEE_TYPE',
              p_token1_value => p_required_feetype);
          CLOSE stream_csr;
          RAISE create_fee_exception;
        END IF;
        CLOSE stream_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before contract_dates_csr ');
        END IF;

        -- get contract dates for fee effective date
        OPEN  contract_dates_csr;
        FETCH contract_dates_csr INTO contract_dates_csr_rec;
        IF contract_dates_csr%NOTFOUND THEN
          --Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Fee Effective dates cannot be derived');
          Okl_Api.SET_MESSAGE(G_APP_NAME, 'Cannot find contract effective dates for sales tax fee creation.');
          CLOSE contract_dates_csr;
          RAISE create_fee_exception;
        END IF;
        CLOSE contract_dates_csr;

        l_fee_types_rec.item_id1         := to_number(p_stream_id);
        l_fee_types_rec.dnz_chr_id       := p_contract_id;
        l_fee_types_rec.fee_purpose_code := 'SALESTAX';
        l_fee_types_rec.fee_type         := 'FINANCED';
        l_fee_types_rec.item_name        := l_item_name;
        l_fee_types_rec.amount           := l_financed_amount;
        l_fee_types_rec.effective_from   := contract_dates_csr_rec.start_date;
        l_fee_types_rec.effective_to     := contract_dates_csr_rec.end_date;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before OKL_MAINTAIN_FEE_PVT ');
        END IF;
        -- create fee top line
        OKL_MAINTAIN_FEE_PVT.create_fee_type(
                                              p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_fee_types_rec  => l_fee_types_rec,
                                              x_fee_types_rec  => lx_fee_types_rec
                                             );
        -- Check if the call was successful
        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;


        IF (p_default_feetype = 'FINANCE') THEN
          i:=1;
          FOR j in get_asset_csr1 ('FINANCE')
          LOOP

            IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before get_asset_tax_amt_csr ');
            END IF;
            -- get asset tax amount
            OPEN  get_asset_tax_amt_csr(j.id);
            FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
            IF get_asset_tax_amt_csr%NOTFOUND THEN
              --Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Asset Tax Amount cannot be derived');
              Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_LA_ST_K_ID_ERROR');
              IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount for ID'|| j.id);
              END IF;
              CLOSE get_asset_tax_amt_csr;
              RAISE create_fee_exception;
            END IF;
            CLOSE get_asset_tax_amt_csr;

            -- Hard Code Asset Tax Amount for now
            --l_asset_tax_amt := 50;

            l_line_item_tbl(i).chr_id            := p_contract_id;
            l_line_item_tbl(i).parent_cle_id     := lx_fee_types_rec.line_id ;
            l_line_item_tbl(i).item_id1          := j.id;
            l_line_item_tbl(i).item_id2          := '#';
            l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
            l_line_item_tbl(i).item_description  := j.item_description;
            l_line_item_tbl(i).name              := j.name;
            l_line_item_tbl(i).capital_amount    := l_asset_tax_amt;

            i := i+1;
          END LOOP;
        END IF;

        IF (p_default_feetype = 'BILLED') THEN
          i:=1;
          FOR j in get_asset_csr2 ('FINANCE')
          LOOP

            IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before get_asset_tax_amt_csr ');
            END IF;
            -- get asset tax amount
            OPEN  get_asset_tax_amt_csr(j.id);
            FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
            IF get_asset_tax_amt_csr%NOTFOUND THEN
              OKL_API.set_message( p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_LA_ST_ASSET_TAX_AMT_ERROR');
              IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount. for ID'|| j.id);
              END IF;
              CLOSE get_asset_tax_amt_csr;
              RAISE create_fee_exception;
            END IF;
            CLOSE get_asset_tax_amt_csr;

            -- Hard Code Asset Tax Amount for now
            --l_asset_tax_amt := 50;

            l_line_item_tbl(i).chr_id            := p_contract_id;
            l_line_item_tbl(i).parent_cle_id     := lx_fee_types_rec.line_id ;
            l_line_item_tbl(i).item_id1          := j.id;
            l_line_item_tbl(i).item_id2          := '#';
            l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
            l_line_item_tbl(i).item_description  := j.item_description;
            l_line_item_tbl(i).name              := j.name;
            l_line_item_tbl(i).capital_amount    := l_asset_tax_amt;

            i := i+1;
          END LOOP;
        END IF;



        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before okl_contract_line_item_pvt ');
        END IF;
        -- Associate Assets to the fee
        okl_contract_line_item_pvt.create_contract_line_item(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             --p_init_msg_list    => 'T',
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             p_line_item_tbl    => l_line_item_tbl,
                             x_line_item_tbl    => lx_line_item_tbl);

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: x_return_status '||x_return_status);
        END IF;
        FOR k in 1..x_msg_count LOOP
          fnd_msg_pub.get (p_encoded => 'F',
                                 p_data => x_msg_data,
                                 p_msg_index_out => x_msg_index_out
                                );
          IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment:'||to_char(k) || ':' || x_msg_data);
          END IF;
         END LOOP;

        -- Check if the call was successful
        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;

        -- Following Segment is for creating Expense Item for Financed Fee
        -- It is implemeted using Rule APIs, so will use the same

        -- Populate Rule Group Values for Expenses
        l_rgpv_rec.rgd_code   := 'LAFEXP';
        l_rgpv_rec.dnz_chr_id := p_contract_id;
        l_rgpv_rec.cle_id     := lx_fee_types_rec.line_id;
        l_rgpv_rec.rgp_type   := 'KRG';

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before OKL_RULE_PUB.create_rule_group ');
        END IF;

        OKL_RULE_PUB.create_rule_group(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_rgpv_rec       => l_rgpv_rec,
            x_rgpv_rec       => lx_rgpv_rec);

        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;

        -- Populate Rule Values for Expenses
        l_rulv_tbl(1).rgp_id                    := lx_rgpv_rec.id;
        l_rulv_tbl(1).dnz_chr_id                := p_contract_id;
        l_rulv_tbl(1).rule_information_category := 'LAFEXP';
        l_rulv_tbl(1).rule_information1         :=  1;
        l_rulv_tbl(1).rule_information2         :=  l_financed_amount;
        l_rulv_tbl(1).WARN_YN                   := 'N';
        l_rulv_tbl(1).STD_TEMPLATE_YN           := 'N';
        l_rulv_tbl(1).template_yn               := 'N';

        l_rulv_tbl(2).rgp_id                    := lx_rgpv_rec.id;
        l_rulv_tbl(2).dnz_chr_id                := p_contract_id;
        l_rulv_tbl(2).rule_information_category := 'LAFREQ';
        l_rulv_tbl(2).OBJECT1_ID1               := 'M';
        l_rulv_tbl(2).OBJECT1_ID2               := '#';
        l_rulv_tbl(2).JTOT_OBJECT1_CODE         := 'OKL_TUOM';
        l_rulv_tbl(2).WARN_YN                   := 'N';
        l_rulv_tbl(2).STD_TEMPLATE_YN           := 'N';
        l_rulv_tbl(2).template_yn               := 'N';

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: FINANCE segment: before OKL_RULE_PUB.create_rule ');
        END IF;
        OKL_RULE_PUB.create_rule(
             p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rulv_tbl       => l_rulv_tbl,
             x_rulv_tbl       => lx_rulv_tbl);

        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;

      -- R12B Authoring OA Migration
      Elsif (l_finance_fee_exists = OKL_API.G_TRUE) Then

        OKL_LA_SALES_TAX_PVT.update_fee
          (p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_contract_id      => p_contract_id,
           p_transaction_id   => p_transaction_id,
           p_fee_line_id      => l_fee_line_id,
           p_required_feetype => p_required_feetype,
           p_default_feetype  => p_default_feetype,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

         If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
           RAISE create_fee_exception;
         End If;
      -- R12B Authoring OA Migration

      End If;

    End If;

    -- If upfront tax is 'CAPITALIZED'
    If (p_required_feetype = 'CAPITALIZE')
    THEN

      --l_capitalized_amount := get_capitalized_tax ( p_Contract_id
      --                                              ,p_transaction_id
      --                                              ,p_default_feetype);
      l_capitalized_amount := get_capitalized_tax ( p_Contract_id
                                                    ,p_default_feetype);


      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: l_capitalized_amount: '
                               ||l_capitalized_amount);
      END IF;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before check_fee_csr ');
      END IF;

      OPEN check_fee_csr ('CAPITALIZED');
      -- R12B Authoring OA Migration
      FETCH check_fee_csr INTO l_fee_line_id;
      -- R12B Authoring OA Migration
      IF check_fee_csr%NOTFOUND THEN
        l_capitalized_fee_exists := OKL_API.G_FALSE;
      Else
        l_capitalized_fee_exists := OKL_API.G_TRUE;
      END IF;
      CLOSE check_fee_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before IF condition');
      END IF;
      -- Create Fee only if the amount is > 0 and fee does not exist
      If ((l_capitalized_amount > 0)  AND
          (l_capitalized_fee_exists = OKL_API.G_FALSE)) THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before stream_csr ');
        END IF;
        -- get item_id1 value
        OPEN  stream_csr(p_stream_id);
        FETCH stream_csr INTO l_item_name;

        IF stream_csr%NOTFOUND THEN
          OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_LA_ST_STREAM_ERROR',
              p_token1       => 'FEE_TYPE',
              p_token1_value => p_required_feetype);
          CLOSE stream_csr;
          RAISE create_fee_exception;
        END IF;
        CLOSE stream_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before contract_dates_csr ');
        END IF;
        -- get contract dates for fee effective date
        OPEN  contract_dates_csr;
        FETCH contract_dates_csr INTO contract_dates_csr_rec;
        IF contract_dates_csr%NOTFOUND THEN
          --Okl_Api.SET_MESSAGE(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Fee Effective dates cannot be derived');
          Okl_Api.SET_MESSAGE(G_APP_NAME, 'Cannot find contract effective dates for sales tax fee creation.');
          CLOSE contract_dates_csr;
          RAISE create_fee_exception;
        END IF;
        CLOSE contract_dates_csr;

        l_fee_types_rec.dnz_chr_id       := p_contract_id;
        l_fee_types_rec.fee_type         := 'CAPITALIZED';
        l_fee_types_rec.fee_purpose_code := 'SALESTAX';
        l_fee_types_rec.item_name        := l_item_name;
        l_fee_types_rec.item_id1         := to_number(p_stream_id);
        l_fee_types_rec.amount           := l_capitalized_amount;
        l_fee_types_rec.effective_from   := contract_dates_csr_rec.start_date;
        l_fee_types_rec.effective_to     := contract_dates_csr_rec.end_date;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before OKL_MAINTAIN_FEE_PVT ');
        END IF;
        -- Create Fee Top Line
        OKL_MAINTAIN_FEE_PVT.create_fee_type(
                                              p_api_version    => p_api_version,
                                              p_init_msg_list  => p_init_msg_list,
                                              x_return_status  => x_return_status,
                                              x_msg_count      => x_msg_count,
                                              x_msg_data       => x_msg_data,
                                              p_fee_types_rec  => l_fee_types_rec,
                                              x_fee_types_rec  => lx_fee_types_rec
                                             );
        -- Check if the call was successful
        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;

        IF (p_default_feetype = 'CAPITALIZE') THEN
          i:=1;
          FOR j in get_asset_csr1 ('CAPITALIZE')
          LOOP
            -- get asset tax amount
            IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before get_asset_tax_amt_csr ');
            END IF;
            OPEN  get_asset_tax_amt_csr(j.id);
            FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
            IF get_asset_tax_amt_csr%NOTFOUND THEN
              OKL_API.set_message( p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_LA_ST_ASSET_TAX_AMT_ERROR');
              IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount. for ID'|| j.id);
              END IF;
              CLOSE get_asset_tax_amt_csr;
              RAISE create_fee_exception;
            END IF;
            CLOSE get_asset_tax_amt_csr;

            -- Hard Code Asset Tax Amount for now
            --l_asset_tax_amt := 50;

            l_line_item_tbl(i).chr_id            := p_contract_id;
            l_line_item_tbl(i).parent_cle_id     := lx_fee_types_rec.line_id;
            l_line_item_tbl(i).item_id1          := j.id;
            l_line_item_tbl(i).item_id2          := '#';
            l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
            l_line_item_tbl(i).item_description  := j.item_description;
            l_line_item_tbl(i).name              := j.name;
            l_line_item_tbl(i).capital_amount    := l_asset_tax_amt;

            i := i+1;

          END LOOP;
        END IF;

        IF (p_default_feetype = 'BILLED') THEN
          i:=1;
          FOR j in get_asset_csr2 ('CAPITALIZE')
          LOOP

            IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Create Fee Procedure: CAPITALIZE segment: before get_asset_tax_amt_csr ');
            END IF;
            -- get asset tax amount
            OPEN  get_asset_tax_amt_csr(j.id);
            FETCH get_asset_tax_amt_csr INTO l_asset_tax_amt;
            IF get_asset_tax_amt_csr%NOTFOUND THEN
              OKL_API.set_message( p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_LA_ST_ASSET_TAX_AMT_ERROR');
              IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Cannot derive asset tax amount. for ID'|| j.id);
              END IF;
              CLOSE get_asset_tax_amt_csr;
              RAISE create_fee_exception;
            END IF;
            CLOSE get_asset_tax_amt_csr;

            -- Hard Code Asset Tax Amount for now
            --l_asset_tax_amt := 50;

            l_line_item_tbl(i).chr_id            := p_contract_id;
            l_line_item_tbl(i).parent_cle_id     := lx_fee_types_rec.line_id ;
            l_line_item_tbl(i).item_id1          := j.id;
            l_line_item_tbl(i).item_id2          := '#';
            l_line_item_tbl(i).item_object1_code := 'OKX_COVASST';
            l_line_item_tbl(i).item_description  := j.item_description;
            l_line_item_tbl(i).name              := j.name;
            l_line_item_tbl(i).capital_amount    := l_asset_tax_amt;

            i := i+1;
          END LOOP;
        END IF;



        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Pre Book Procedure: CAPITALIZE segment: before okl_contract_line_item_pvt ');
        END IF;
        -- Associate Assets to the fee
        okl_contract_line_item_pvt.create_contract_line_item(
                             p_api_version      => p_api_version,
                             p_init_msg_list    => p_init_msg_list,
                             x_return_status    => x_return_status,
                             x_msg_count        => x_msg_count,
                             x_msg_data         => x_msg_data,
                             p_line_item_tbl    => l_line_item_tbl,
                             x_line_item_tbl    => lx_line_item_tbl);

        -- Check if the call was successful
        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE create_fee_exception;
        End If;

      -- R12B Authoring OA Migration
      Elsif (l_capitalized_fee_exists = OKL_API.G_TRUE) Then

        OKL_LA_SALES_TAX_PVT.update_fee
          (p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_contract_id      => p_contract_id,
           p_transaction_id   => p_transaction_id,
           p_fee_line_id      => l_fee_line_id,
           p_required_feetype => p_required_feetype,
           p_default_feetype  => p_default_feetype,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

         If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
           RAISE create_fee_exception;
         End If;
      -- R12B Authoring OA Migration

      End If;

    End If;

  Exception
      when create_fee_exception then
         x_return_status := OKL_API.G_RET_STS_ERROR;

  END create_fee;

  -- R12 - START

  -- Following procedures introduced to meet R12 upfront tax accounting requirements

  -- Start of comments
  --
  -- Procedure Name  : populate_account_api_data
  -- Description     :  This is a private procedure used by create_upfront_tax_accounting
  -- to populate accounting data tables prior to calling central OKL a/c API
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE populate_account_data(
                    p_api_version        IN  NUMBER
                    ,p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                    ,p_trxh_out_rec      IN  Okl_Trx_Contracts_Pvt.tcnv_rec_type
                    ,p_tclv_tbl          IN  okl_trx_contracts_pvt.tclv_tbl_type
                    ,p_acc_gen_tbl       IN  OUT NOCOPY okl_account_dist_pvt.ACC_GEN_TBL_TYPE
                    ,p_tmpl_identify_tbl IN  OUT NOCOPY okl_account_dist_pvt.tmpl_identify_tbl_type
                    ,p_dist_info_tbl     IN  OUT NOCOPY okl_account_dist_pvt.dist_info_tbl_type
                    ,x_return_status     OUT NOCOPY VARCHAR2
                    ,x_msg_count         OUT NOCOPY NUMBER
                    ,x_msg_data          OUT NOCOPY VARCHAR2)
  IS
    -- Cursors plucked from OKL_LA_JE_PVT for a/c - START
  CURSOR fnd_pro_csr
  IS
  SELECT mo_global.get_current_org_id() l_fnd_profile
  FROM   dual;

  fnd_pro_rec fnd_pro_csr%ROWTYPE;

  CURSOR ra_cust_csr
  IS
  SELECT cust_trx_type_id l_cust_trx_type_id
  FROM   ra_cust_trx_types
  WHERE  name = 'Invoice-OKL';

  ra_cust_rec ra_cust_csr%ROWTYPE;

  CURSOR salesP_csr
  IS
  SELECT  ct.object1_id1           id
         ,chr.scs_code             scs_code
  FROM   okc_contacts              ct,
         okc_contact_sources       csrc,
         okc_k_party_roles_b       pty,
         okc_k_headers_b           chr
  WHERE  ct.cpl_id               = pty.id
  AND    ct.cro_code             = csrc.cro_code
  AND    ct.jtot_object1_code    = csrc.jtot_object_code
  AND    ct.dnz_chr_id           = chr.id
  AND    pty.rle_code            = csrc.rle_code
  AND    csrc.cro_code           = 'SALESPERSON'
  AND    csrc.rle_code           = 'LESSOR'
  AND    csrc.buy_or_sell        = chr.buy_or_sell
  AND    pty.dnz_chr_id          = chr.id
  AND    pty.chr_id              = chr.id
  AND    chr.id                  = p_trxh_out_rec.khr_id;

  l_salesP_rec salesP_csr%ROWTYPE;

  CURSOR custBillTo_csr
  IS
  SELECT bill_to_site_use_id cust_acct_site_id
  FROM   okc_k_headers_b
  WHERE  id = p_trxh_out_rec.khr_id;

  l_custBillTo_rec custBillTo_csr%ROWTYPE;

  -- Cursors plucked from OKL_LA_JE_PVT for a/c - END
  l_acc_gen_primary_key_tbl   okl_account_dist_pvt.acc_gen_primary_key;
  l_fact_synd_code            FND_LOOKUPS.Lookup_code%TYPE;
  l_inv_acct_code             OKC_RULES_B.Rule_Information1%TYPE;

  account_data_exception  EXCEPTION;

  --Bug# 6619311
  CURSOR assetBillTo_csr(p_cle_id IN NUMBER)
  IS
  SELECT bill_to_site_use_id cust_acct_site_id
  FROM   okc_k_lines_b
  WHERE  id = p_cle_id;

  l_assetBillTo_rec assetBillTo_csr%ROWTYPE;
  l_acc_gen_primary_key_tbl1 okl_account_dist_pvt.acc_gen_primary_key;

  BEGIN

    okl_debug_pub.logmessage('OKL: populate_account_data : START');

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_acc_gen_primary_key_tbl(1).source_table := 'FINANCIALS_SYSTEM_PARAMETERS';
    OPEN  fnd_pro_csr;
    FETCH fnd_pro_csr INTO fnd_pro_rec;
    IF ( fnd_pro_csr%NOTFOUND )
    THEN
      l_acc_gen_primary_key_tbl(1).primary_key_column := '';
    ELSE
      l_acc_gen_primary_key_tbl(1).primary_key_column := fnd_pro_rec.l_fnd_profile;
    End IF;
    CLOSE fnd_pro_csr;

    l_acc_gen_primary_key_tbl(2).source_table := 'AR_SITE_USES_V';
    OPEN  custBillTo_csr;
    FETCH custBillTo_csr INTO l_custBillTo_rec;
    CLOSE custBillTo_csr;
    l_acc_gen_primary_key_tbl(2).primary_key_column := l_custBillTo_rec.cust_acct_site_id;

    l_acc_gen_primary_key_tbl(3).source_table := 'RA_CUST_TRX_TYPES';
    OPEN  ra_cust_csr;
    FETCH ra_cust_csr INTO ra_cust_rec;
    IF ( ra_cust_csr%NOTFOUND ) THEN
      l_acc_gen_primary_key_tbl(3).primary_key_column := '';
    ELSE
      l_acc_gen_primary_key_tbl(3).primary_key_column := TO_CHAR(ra_cust_rec.l_cust_trx_type_id);
    END IF;
    CLOSE ra_cust_csr;

    l_acc_gen_primary_key_tbl(4).source_table := 'JTF_RS_SALESREPS_MO_V';
    OPEN  salesP_csr;
    FETCH salesP_csr INTO l_salesP_rec;
    CLOSE salesP_csr;
    l_acc_gen_primary_key_tbl(4).primary_key_column := l_salesP_rec.id;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              , 'OKL: populate_account_data Procedure: Calling OKL_SECURITIZATION_PVT ');
    END IF;

    OKL_SECURITIZATION_PVT.Check_Khr_ia_associated(
                                  p_api_version             => p_api_version,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_khr_id                  => p_trxh_out_rec.khr_id,
                                  p_scs_code                => l_salesP_rec.scs_code,
                                  p_trx_date                => p_trxh_out_rec.date_transaction_occurred,

                                  x_fact_synd_code          => l_fact_synd_code,
                                  x_inv_acct_code           => l_inv_acct_code
                                  );


    okl_debug_pub.logmessage('OKL: populate_account_data : OKL_SECURITIZATION_PVT : '||x_return_status);

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
    THEN
      RAISE account_data_exception;
    END IF;

    FOR i in p_tclv_tbl.FIRST..p_tclv_tbl.LAST
    LOOP

      --Bug# 6619311: Populate asset level bill-to site if defined
      l_acc_gen_primary_key_tbl1 := l_acc_gen_primary_key_tbl;
      IF p_tclv_tbl(i).kle_id IS NOT NULL THEN
        l_assetBillTo_rec := NULL;
        OPEN  assetBillTo_csr(p_cle_id => p_tclv_tbl(i).kle_id);
        FETCH assetBillTo_csr INTO l_assetBillTo_rec;
        CLOSE assetBillTo_csr;

        IF l_assetBillTo_rec.cust_acct_site_id IS NOT NULL THEN
          l_acc_gen_primary_key_tbl1(2).primary_key_column := l_assetBillTo_rec.cust_acct_site_id;
        END IF;
      END IF;

      -- Populate account source
      p_acc_gen_tbl(i).acc_gen_key_tbl            := l_acc_gen_primary_key_tbl1;
      p_acc_gen_tbl(i).source_id                  := p_tclv_tbl(i).id;

      -- Populate template info
      p_tmpl_identify_tbl(i).product_id          := p_trxh_out_rec.pdt_id;
      p_tmpl_identify_tbl(i).transaction_type_id := p_trxh_out_rec.try_id;
      p_tmpl_identify_tbl(i).stream_type_id      := p_tclv_tbl(i).sty_id;
      p_tmpl_identify_tbl(i).advance_arrears     := NULL;
      p_tmpl_identify_tbl(i).prior_year_yn       := 'N';
      p_tmpl_identify_tbl(i).memo_yn             := 'N';
      p_tmpl_identify_tbl(i).factoring_synd_flag := l_fact_synd_code;
      p_tmpl_identify_tbl(i).investor_code       := l_inv_acct_code;

      -- Populate distribution info
      p_dist_info_tbl(i).SOURCE_ID                := p_tclv_tbl(i).id;
      p_dist_info_tbl(i).amount                   := p_tclv_tbl(i).amount;
      p_dist_info_tbl(i).ACCOUNTING_DATE          := p_trxh_out_rec.date_transaction_occurred;
      p_dist_info_tbl(i).SOURCE_TABLE             := 'OKL_TXL_CNTRCT_LNS';
      p_dist_info_tbl(i).GL_REVERSAL_FLAG         := 'N';
      p_dist_info_tbl(i).POST_TO_GL               := 'Y';
      p_dist_info_tbl(i).CONTRACT_ID              := p_trxh_out_rec.khr_id;
      p_dist_info_tbl(i).currency_conversion_rate := p_trxh_out_rec.currency_conversion_rate;
      p_dist_info_tbl(i).currency_conversion_type := p_trxh_out_rec.currency_conversion_type;
      p_dist_info_tbl(i).currency_conversion_date := p_trxh_out_rec.currency_conversion_date;
      p_dist_info_tbl(i).currency_code            := p_trxh_out_rec.currency_code;
      okl_debug_pub.logmessage('OKL: populate_account_data : p_tclv_tbl loop : l_dist_info_tbl(i).amount : '||p_dist_info_tbl(i).amount);

    END LOOP;

    okl_debug_pub.logmessage('OKL: populate_account_data : END');

  EXCEPTION
    WHEN account_data_exception
    THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

  END populate_account_data;


  -- Start of comments
  --
  -- Procedure Name  : create_upfront_tax_accounting
  -- Description     :  This procedure creates a/c journal entries for upfront tax lines.
  -- This procedure logic will be executed in its entirety, only if SLA accounting
  -- option AMB is enabled.
  -- When enabled, it creates:
  --      1. TRX header in OKL_TRX_CONTRACTS for type 'Upfront Tax'
  --      2. TRX lines in OKL_TXL_CNTRCT_LNS for each line in ZX_LINES,
  --         store values for cle-id, tax_line_id, tax_amount, etc.
  --      3. Identify tax treatment for each asset line, to derive stream type
  --      4. Call a/c API for upfront tax records in OKL_TXL_CNTRCT_LNS
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE create_upfront_tax_accounting(
                    p_api_version       IN  NUMBER
                    ,p_init_msg_list    IN  VARCHAR2 DEFAULT OKC_API.G_FALSE
                    ,p_contract_id      IN  okc_k_headers_all_b.id%TYPE
                    ,p_transaction_id   IN  okl_trx_contracts_all.khr_id%TYPE
                    ,p_transaction_type IN  VARCHAR2
                    ,x_return_status    OUT NOCOPY VARCHAR2
                    ,x_msg_count        OUT NOCOPY NUMBER
                    ,x_msg_data         OUT NOCOPY VARCHAR2)
  IS

  -- Cursor to check system level accounting option
  -- Upfront tax a/c is done if AMB is enabled
  CURSOR acct_opt_csr
  IS
  SELECT account_derivation
  FROM   okl_sys_acct_opts;
  l_acct_opt okl_sys_acct_opts.account_derivation%TYPE;

  --Bug# 6619311
  -- Cursor to fetch tax lines from EBTax table
  -- for assets having tax treatment same as the
  -- Default tax treatment
  CURSOR tax_line_csr1 (p_default_tax_treatment VARCHAR2)
  IS
  SELECT   NVL(rul.rule_information11, p_default_tax_treatment)
                                     tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V       rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources   txs
         , zx_lines          txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    (rul.rule_information11          = p_default_tax_treatment
          OR
          rul.rule_information11           IS NULL)
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL                           -- change
  AND    txs.TAX_LINE_STATUS_CODE         = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'CONTRACTS'                         -- change
  AND    txl.event_class_code             = 'BOOKING'                           -- change
  AND    txs.entity_code                  = txl.entity_code                     -- change
  AND    txs.event_class_code             = txl.event_class_code                -- change
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type;

  --Bug# 6619311
  -- Cursor to fetch tax lines from EBTax table
  -- for assets having tax treatment as Capitalized or Financed
  -- when the default tax treatment is Billed
  CURSOR tax_line_csr2
  IS
  SELECT   rul.rule_information11    tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V       rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources   txs
         , zx_lines          txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    rul.rule_information11           <> 'BILLED'
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL                           -- change
  AND    txs.TAX_LINE_STATUS_CODE         = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'CONTRACTS'                         -- change
  AND    txl.event_class_code             = 'BOOKING'                           -- change
  AND    txs.entity_code                  = txl.entity_code                     -- change
  AND    txs.event_class_code             = txl.event_class_code                -- change
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type;

  --Bug# 6619311
  -- Cursor to fetch tax lines from EBTax table
  -- for assets having tax treatment as Billed
  -- when the default tax treatment is Capitalized or Financed
  CURSOR tax_line_csr3
  IS
  SELECT   rul.rule_information11    tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V       rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources   txs
         , zx_lines          txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    rul.rule_information11           = 'BILLED'
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL                           -- change
  AND    txs.TAX_LINE_STATUS_CODE         = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'CONTRACTS'                         -- change
  AND    txl.event_class_code             = 'BOOKING'                           -- change
  AND    txs.entity_code                  = txl.entity_code                     -- change
  AND    txs.event_class_code             = txl.event_class_code                -- change
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type;

  --Bug# 6619311
  -- Cursor to fetch tax lines from EBTax table
  -- for contract level taxes
  CURSOR tax_line_csr4
  IS
  SELECT   'BILLED'                  tax_treatment
         , txs.kle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     okl_tax_sources   txs
         , zx_lines          txl
  WHERE  txs.khr_id                       = p_contract_id
  AND    txs.kle_id                       IS NULL
  AND    txs.TAX_LINE_STATUS_CODE         = 'ACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'CONTRACTS'
  AND    txl.event_class_code             = 'BOOKING'
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type;

  -- Cursor to check if previous upfront tax TRX exists,
  -- This will be used by rebook logic to decide if there
  -- is a need for reversal accounting. If the cursor does not
  -- return any rows, skip the reversal accounting part
  CURSOR check_upfront_trx_csr
  IS
  SELECT 1
  FROM   dual
  WHERE  EXISTS (SELECT a.id
                 FROM   okl_trx_contracts_all a
                        ,okl_trx_types_v b
                 WHERE  a.khr_id = p_contract_id
                 AND    a.try_id = b.id
             --rkuttiya added for 12.1.1 Multi GAAP
                 AND    a.representation_type = 'PRIMARY'
             --
                 AND    b.name   = 'Upfront Tax');

  --Bug# 6619311
  -- Cursor to get reversed tax lines for rebook TRX
  -- for assets having tax treatment same as the
  -- Default tax treatment
  CURSOR rev_taxline_csr1(   p_rbk_trx_id            NUMBER
                            ,p_default_tax_treatment VARCHAR2)
  IS
  SELECT  NVL(rul.rule_information11,p_default_tax_treatment)
                                     tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources txs
         , zx_lines txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    (rul.rule_information11          = p_default_tax_treatment
          OR
          rul.rule_information11           IS NULL)
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL
  AND    txs.TAX_LINE_STATUS_CODE         = 'INACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  IN ('CONTRACTS','ASSETS')
  AND    txl.event_class_code             IN ('BOOKING','ASSET_RELOCATION')
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type
  AND    (txs.trx_id,txs.trx_line_id)
          IN
         (SELECT adjusted_doc_trx_id
                 ,adjusted_doc_trx_line_id
          FROM   okl_tax_sources
          WHERE  trx_id                   = p_rbk_trx_id
          AND    tax_line_status_code     = 'INACTIVE'
          AND    adjusted_doc_trx_id      IS NOT NULL
          AND    adjusted_doc_trx_line_id IS NOT NULL);

  --Bug# 6619311
  -- Cursor to get reversed tax lines for rebook TRX
  -- for assets having tax treatment as Capitalized or Financed
  -- when the default tax treatment is Billed
  CURSOR rev_taxline_csr2(   p_rbk_trx_id NUMBER)
  IS
  SELECT   rul.rule_information11    tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources txs
         , zx_lines txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    rul.rule_information11           <> 'BILLED'
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL
  AND    txs.TAX_LINE_STATUS_CODE         = 'INACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  IN ('CONTRACTS','ASSETS')
  AND    txl.event_class_code             IN ('BOOKING','ASSET_RELOCATION')
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type
  AND    (txs.trx_id,txs.trx_line_id)
          IN
         (SELECT adjusted_doc_trx_id
                 ,adjusted_doc_trx_line_id
          FROM   okl_tax_sources
          WHERE  trx_id                   = p_rbk_trx_id
          AND    tax_line_status_code     = 'INACTIVE'
          AND    adjusted_doc_trx_id      IS NOT NULL
          AND    adjusted_doc_trx_line_id IS NOT NULL);

  --Bug# 6619311
  -- Cursor to get reversed tax lines for rebook TRX
  -- for assets having tax treatment as Billed
  -- when the default tax treatment is Capitalized or Financed
  CURSOR rev_taxline_csr3(   p_rbk_trx_id NUMBER)
  IS
  SELECT   rul.rule_information11    tax_treatment
         , rgp.cle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     OKC_RULES_V rul
         , OKC_RULE_GROUPS_V rgp
         , okl_tax_sources txs
         , zx_lines txl
  WHERE  rul.rgp_id                       = rgp.id
  AND    rgp.dnz_chr_id                   = p_contract_id
  AND    rgp.rgd_code                     = 'LAASTX'
  AND    rul.rule_information_category    = 'LAASTX'
  AND    rul.rule_information11           = 'BILLED'
  AND    txs.khr_id                       = rgp.dnz_chr_id
  AND    txs.kle_id                       = rgp.cle_id
  AND    txs.kle_id                       IS NOT NULL
  AND    txs.TAX_LINE_STATUS_CODE         = 'INACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  IN ('CONTRACTS','ASSETS')
  AND    txl.event_class_code             IN ('BOOKING','ASSET_RELOCATION')
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type
  AND    (txs.trx_id,txs.trx_line_id)
          IN
         (SELECT adjusted_doc_trx_id
                 ,adjusted_doc_trx_line_id
          FROM   okl_tax_sources
          WHERE  trx_id                   = p_rbk_trx_id
          AND    tax_line_status_code     = 'INACTIVE'
          AND    adjusted_doc_trx_id      IS NOT NULL
          AND    adjusted_doc_trx_line_id IS NOT NULL);

  --Bug# 6619311
  -- Cursor to get reversed tax lines for rebook TRX
  -- for contract level taxes
  CURSOR rev_taxline_csr4(   p_rbk_trx_id NUMBER)
  IS
  SELECT   'BILLED'                  tax_treatment
         , txs.kle_id                asset_id
         , txs.id                    tax_header_id
         , txl.tax_line_id           tax_line_id
         , txl.tax_amt               tax_amount
  FROM     okl_tax_sources txs
         , zx_lines txl
  WHERE  txs.khr_id                       = p_contract_id
  AND    txs.kle_id                       IS NULL
  AND    txs.TAX_LINE_STATUS_CODE         = 'INACTIVE'
  AND    txs.TAX_CALL_TYPE_CODE           = 'UPFRONT_TAX'
  AND    txs.trx_id                       = txl.trx_id
  AND    txs.trx_line_id                  = txl.trx_line_id
  AND    txl.entity_code                  = 'CONTRACTS'
  AND    txl.event_class_code             = 'BOOKING'
  AND    txs.entity_code                  = txl.entity_code
  AND    txs.event_class_code             = txl.event_class_code
  AND    txl.application_id               = 540
  AND    txl.trx_level_type               = 'LINE'
  AND    txs.application_id               = txl.application_id
  AND    txs.trx_level_type               = txl.trx_level_type
  AND    (txs.trx_id,txs.trx_line_id)
          IN
         (SELECT adjusted_doc_trx_id
                 ,adjusted_doc_trx_line_id
          FROM   okl_tax_sources
          WHERE  trx_id                   = p_rbk_trx_id
          AND    tax_line_status_code     = 'INACTIVE'
          AND    adjusted_doc_trx_id      IS NOT NULL
          AND    adjusted_doc_trx_line_id IS NOT NULL);

  l_tclv_tbl                  okl_trx_contracts_pvt.tclv_tbl_type;
  x_tclv_tbl                  okl_trx_contracts_pvt.tclv_tbl_type;


  l_tmpl_identify_rec         okl_account_dist_pvt.tmpl_identify_rec_type;
  l_tmpl_identify_tbl         okl_account_dist_pvt.tmpl_identify_tbl_type;
  l_template_tbl              okl_account_dist_pvt.avlv_tbl_type;
  l_dist_info_tbl             okl_account_dist_pvt.dist_info_tbl_type;
  l_template_out_tbl          okl_account_dist_pvt.avlv_out_tbl_type;
  l_amount_tbl                okl_account_dist_pvt.amount_out_tbl_type;
  l_ctxt_val_tbl              okl_account_dist_pvt.CTXT_VAL_TBL_TYPE;
  l_acc_gen_tbl               okl_account_dist_pvt.ACC_GEN_TBL_TYPE;
  l_ctxt_tbl                  okl_account_dist_pvt.CTXT_TBL_TYPE;

  counter                     NUMBER := 0;
  j                           NUMBER := 0;
  l_trx_id                    NUMBER;
  l_fnd_rec                   fnd_lookups_csr%ROWTYPE;
  l_trxh_out_rec              Okl_Trx_Contracts_Pvt.tcnv_rec_type;
  l_financed_sty_id           NUMBER;
  l_capitalized_sty_id        NUMBER;
  l_upfront_trx_exists        NUMBER := 0;
  l_rule_info_csr             rule_info_csr%ROWTYPE;
  subtype ac_tax_line_rec is  tax_line_csr2%ROWTYPE;
  TYPE ac_tax_line_tbl        IS TABLE OF ac_tax_line_rec
                              INDEX BY BINARY_INTEGER;
  l_accoutable_tax_lines       ac_tax_line_tbl;
  l_fact_synd_code      FND_LOOKUPS.Lookup_code%TYPE;
  l_inv_acct_code       OKC_RULES_B.Rule_Information1%TYPE;
  upfront_tax_acct_exception  EXCEPTION;

  --Bug# 6619311
  l_billed_sty_id             NUMBER;
  l_transaction_amount        NUMBER;

  BEGIN

    okl_debug_pub.logmessage('OKL: UPF A/C : START');

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              , 'OKL: Booking Procedure: deriving Accounting option ');
    END IF;

    OPEN acct_opt_csr;
    FETCH acct_opt_csr INTO l_acct_opt;

    IF acct_opt_csr%NOTFOUND
    THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_ST_ACCT_ERROR');
      CLOSE acct_opt_csr;
      RAISE upfront_tax_acct_exception;
    END IF;

    CLOSE acct_opt_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              , 'OKL: Booking Procedure: Validating Accounting option ');
    END IF;

    IF (l_acct_opt IS NULL)
    THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_LA_ST_ACCT_ERROR');
      RAISE upfront_tax_acct_exception;
    END IF;

    OPEN  rule_info_csr(p_contract_id);
    FETCH rule_info_csr INTO l_rule_info_csr;
    CLOSE rule_info_csr;

    -- execute the whole logic only if AMB is enabled, otherwise get out
    IF (l_acct_opt <> 'AMB' )
    THEN
      NULL;
    ELSE

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure : before fnd_lookups_csr ');
      END IF;

      OPEN  fnd_lookups_csr('OKL_TCN_TYPE', 'Upfront Tax');
      FETCH fnd_lookups_csr INTO l_fnd_rec;

      IF fnd_lookups_csr%NOTFOUND
      THEN
          Okl_Api.SET_MESSAGE( G_APP_NAME
                              ,G_INVALID_VALUE
                              ,'TRANSACTION_TYPE'
                              ,'Upfront Tax');
          CLOSE fnd_lookups_csr;
          RAISE upfront_tax_acct_exception;
      END IF;

      CLOSE fnd_lookups_csr;

      -- Get Stream ID's for 'Financed' and 'Capitalized' Fee stream purposes,
      -- this ID will be populated in OKL_TXL_CNTRCT_LNS depending on
      -- each inserted record's tax treatment

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                ,G_MODULE
                                ,'OKL: create_upfront_tax_accounting Procedure: deriving financed stream ID ');
      END IF;

      OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id              => p_contract_id,
    			p_primary_sty_purpose => 'UPFRONT_TAX_FINANCED',
    			x_return_status       => x_return_status,
    			x_primary_sty_id      => l_financed_sty_id);

      okl_debug_pub.logmessage('OKL: UPF A/C : UPFRONT_TAX_FINANCED : '||l_financed_sty_id);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      End If;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: deriving capitalized stream ID ');
      END IF;

      OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id              => p_contract_id,
    			p_primary_sty_purpose => 'UPFRONT_TAX_CAPITALIZED',
    			x_return_status       => x_return_status,
    			x_primary_sty_id      => l_capitalized_sty_id);

      okl_debug_pub.logmessage('OKL: UPF A/C : UPFRONT_TAX_CAPITALIZED : '||l_capitalized_sty_id);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE upfront_tax_acct_exception;
      End If;

      --Bug# 6619311
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: deriving billed stream ID ');
      END IF;

      OKL_STREAMS_UTIL.get_primary_stream_type(
    			p_khr_id              => p_contract_id,
    			p_primary_sty_purpose => 'UPFRONT_TAX_BILLED',
    			x_return_status       => x_return_status,
    			x_primary_sty_id      => l_billed_sty_id);

      okl_debug_pub.logmessage('OKL: UPF A/C : UPFRONT_TAX_BILLED : '||l_billed_sty_id);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        RAISE upfront_tax_acct_exception;
      End If;
      --End Bug# 6619311

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: deriving default tax treatment ');
      END IF;

      -- For Rebook transactions a reversal TRX needs to be created
      -- prior to an activation TRX. Hence this condition to perform
      -- reversal a/c
      IF (p_transaction_type = 'Rebook')
      THEN

        l_upfront_trx_exists := 0;

        OPEN  check_upfront_trx_csr;
        FETCH check_upfront_trx_csr INTO l_upfront_trx_exists;
        CLOSE check_upfront_trx_csr;

        -- Perform Rebook reversal a/c only if previous 'Upfront Tax' exists.
        IF (l_upfront_trx_exists = 1)
        THEN

          IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                  ,G_MODULE
                                  ,'OKL: create_upfront_tax_accounting Procedure: deriving asset tax information ');
          END IF;

          --Bug# 6619311
          l_accoutable_tax_lines.DELETE;
          j := 0;
          l_trx_id := NULL;
          l_trxh_out_rec := NULL;
          l_tclv_tbl.DELETE;
          l_acc_gen_tbl.DELETE;
          l_tmpl_identify_tbl.DELETE;
          l_dist_info_tbl.DELETE;
          l_ctxt_tbl.DELETE;

          -- Derive accountable tax lines, based on default tax treatment,
          -- into temporary table prior to processing
          IF (l_rule_info_csr.rule_information1 <> 'BILLED')
          THEN
            --Bug# 6619311: Fetch tax lines for assets having tax treatment as
            --              Capitalized or Financed
            FOR i IN rev_taxline_csr1(  p_transaction_id
                                      , l_rule_info_csr.rule_information1)
            LOOP
              j                         := j+1;
              l_accoutable_tax_lines(j) := i;
            END LOOP;

            --Bug# 6619311: Fetch tax lines for assets having tax treatment as
            --              Billed
            FOR i IN rev_taxline_csr3(  p_transaction_id )
            LOOP
              j                         := j+1;
              l_accoutable_tax_lines(j) := i;
            END LOOP;

          ELSE
            --Bug# 6619311: Fetch tax lines for assets having tax treatment as
            --              Billed
            FOR i IN rev_taxline_csr1(  p_transaction_id
                                      , l_rule_info_csr.rule_information1)
            LOOP
              j                         := j+1;
              l_accoutable_tax_lines(j) := i;
            END LOOP;

            --Bug# 6619311: Fetch tax lines for assets having tax treatment as
            --              Capitalized or Financed
            FOR i IN rev_taxline_csr2(  p_transaction_id )
            LOOP
              j                         := j+1;
              l_accoutable_tax_lines(j) := i;
            END LOOP;
          END IF;

          --Bug# 6619311: Fetch tax lines for contract level taxes
          FOR i IN rev_taxline_csr4(  p_transaction_id )
          LOOP
            j                         := j+1;
            l_accoutable_tax_lines(j) := i;
          END LOOP;


          --Bug# 7506009
          -- Create Upfront Tax accounting only if Tax lines exist
          IF (l_accoutable_tax_lines.COUNT > 0) THEN

          --Bug# 6619311
          l_transaction_amount := 0;
          FOR i IN l_accoutable_tax_lines.FIRST..l_accoutable_tax_lines.LAST
          LOOP
            l_transaction_amount := l_transaction_amount + (-1 * l_accoutable_tax_lines(i).tax_amount);
          END LOOP;

          IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                                   , G_MODULE
                                  ,'OKL: create_upfront_tax_accounting Procedure: Calling populate_transaction procedure ');
          END IF;

          -- Create Upfront Tax Header TRX record in OKL_TRX_CONTRACTS table
          populate_transaction(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => p_contract_id,
                      p_transaction_type => 'Upfront Tax',
                      p_transaction_id   => NULL,
                      p_source_trx_id    => p_transaction_id,
                      p_source_trx_type  => 'TCN',
                      --Bug# 6619311
                      p_transaction_amount => l_transaction_amount,
                      x_transaction_id   => l_trx_id,
                      x_trxh_out_rec     => l_trxh_out_rec,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

          okl_debug_pub.logmessage('OKL: UPF A/C : populate_transaction : return status '||x_return_status);
          -- check transaction creation was successful
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            RAISE upfront_tax_acct_exception;
          End If;

          -- Get Asset tax treatment (Financed or Capitalized),
          -- Tax line Amount for each asset, etc., for processing reversal
          FOR i IN l_accoutable_tax_lines.FIRST..l_accoutable_tax_lines.LAST
          LOOP

            -- Populate TRX line array
            l_tclv_tbl(i).line_number   := i;
            l_tclv_tbl(i).tcn_id        := l_trx_id;
            l_tclv_tbl(i).khr_id        := p_contract_id;
            l_tclv_tbl(i).kle_id        := l_accoutable_tax_lines(i).asset_id;
            l_tclv_tbl(i).tcl_type      := l_fnd_rec.lookup_code;
            l_tclv_tbl(i).tax_line_id   := l_accoutable_tax_lines(i).tax_line_id;
            l_tclv_tbl(i).amount        := -1 * l_accoutable_tax_lines(i).tax_amount; -- (-ve) amount
            l_tclv_tbl(i).currency_code :=l_trxh_out_rec.currency_code;

            IF (l_accoutable_tax_lines(i).tax_treatment = 'FINANCE')
            THEN
              l_tclv_tbl(i).sty_id    := l_financed_sty_id;
            END IF;

            IF (l_accoutable_tax_lines(i).tax_treatment = 'CAPITALIZE')
            THEN
              l_tclv_tbl(i).sty_id    := l_capitalized_sty_id;
            END IF;

            --Bug# 6619311
            IF (l_accoutable_tax_lines(i).tax_treatment = 'BILLED')
            THEN
              l_tclv_tbl(i).sty_id    := l_billed_sty_id;
            END IF;
            --End Bug# 6619311

          END LOOP;

          -- Create TRX lines with the data gathered

          IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                    ,G_MODULE
                                    , 'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Trx_Contracts_Pub.create_trx_cntrct_lines ');
          END IF;

          Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
                                      p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tclv_tbl      => l_tclv_tbl,
                                      x_tclv_tbl      => x_tclv_tbl);

          okl_debug_pub.logmessage('OKL: UPF A/C : create_trx_cntrct_lines : '||x_return_status);

          -- check transaction line creation was successful
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            RAISE upfront_tax_acct_exception;
          END IF;

          -- Populate accounting API data structures
          populate_account_data(
                    p_api_version
                    ,p_init_msg_list
                    ,l_trxh_out_rec
                    ,x_tclv_tbl
                    ,l_acc_gen_tbl
                    ,l_tmpl_identify_tbl
                    ,l_dist_info_tbl
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

          okl_debug_pub.logmessage('OKL: UPF A/C : populate_account_data : '||x_return_status);

          -- check transaction line creation was successful
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            RAISE upfront_tax_acct_exception;
          END IF;

          IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                    ,G_MODULE
                                    ,'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST');
          END IF;

          okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl            => l_template_out_tbl,
                                  x_amount_tbl              => l_amount_tbl,
                                  p_trx_header_id           => l_trxh_out_rec.id);

          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
          THEN
            RAISE upfront_tax_acct_exception;
          END IF;

          OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => l_trxh_out_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_tbl(1).acc_gen_key_tbl);

          IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
          END IF;

          END IF;
          --Bug# 7506009

        END IF; -- upfront tax exists
      END IF; -- Rebook condition


      --Bug# 6619311
      l_accoutable_tax_lines.DELETE;
      j := 0;
      l_trx_id := NULL;
      l_trxh_out_rec := NULL;
      l_tclv_tbl.DELETE;
      l_acc_gen_tbl.DELETE;
      l_tmpl_identify_tbl.DELETE;
      l_dist_info_tbl.DELETE;
      l_ctxt_tbl.DELETE;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                                ,G_MODULE
                                ,'OKL: create_upfront_tax_accounting Procedure: deriving asset tax information ');
      END IF;

      -- Derive accountable tax lines, based on default tax treatment,
      -- into temporary table prior to processing
      IF (l_rule_info_csr.rule_information1 <> 'BILLED')
      THEN

        --Bug# 6619311: Fetch tax lines for assets having tax treatment as
        --              Capitalized or Financed
        FOR i IN tax_line_csr1(p_default_tax_treatment => l_rule_info_csr.rule_information1)
        LOOP
          j                         := j+1;
          l_accoutable_tax_lines(j) := i;
        END LOOP;

        --Bug# 6619311: Fetch tax lines for assets having tax treatment as
        --              Billed
        FOR i IN tax_line_csr3
        LOOP
          j                         := j+1;
          l_accoutable_tax_lines(j) := i;
        END LOOP;

      ELSE

        --Bug# 6619311: Fetch tax lines for assets having tax treatment as
        --              Billed
        FOR i IN tax_line_csr1(p_default_tax_treatment => l_rule_info_csr.rule_information1)
        LOOP
          j                         := j+1;
          l_accoutable_tax_lines(j) := i;
        END LOOP;

        --Bug# 6619311: Fetch tax lines for assets having tax treatment as
        --              Capitalized or Financed
        FOR i IN tax_line_csr2
        LOOP
          j                         := j+1;
          l_accoutable_tax_lines(j) := i;
        END LOOP;

      END IF;

      --Bug# 6619311: Fetch tax lines for contract level taxes
      FOR i IN tax_line_csr4
      LOOP
        j                         := j+1;
        l_accoutable_tax_lines(j) := i;
      END LOOP;


      --Bug# 7506009
      -- Create Upfront Tax accounting only if Tax lines exist
      IF (l_accoutable_tax_lines.COUNT > 0) THEN

      --Bug# 6619311
      l_transaction_amount := 0;
      FOR i IN l_accoutable_tax_lines.FIRST..l_accoutable_tax_lines.LAST
      LOOP
        l_transaction_amount := l_transaction_amount + l_accoutable_tax_lines(i).tax_amount;
      END LOOP;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: Calling populate_transaction procedure ');
      END IF;

      -- Create Upfront Tax Header TRX record in OKL_TRX_CONTRACTS table
      populate_transaction(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => p_contract_id,
                      p_transaction_type => 'Upfront Tax',
                      p_transaction_id   => NULL,
                      p_source_trx_id    => p_transaction_id,
                      p_source_trx_type  => 'TCN',
                      --Bug# 6619311
                      p_transaction_amount => l_transaction_amount,
                      x_transaction_id   => l_trx_id,
                      x_trxh_out_rec     => l_trxh_out_rec,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

      okl_debug_pub.logmessage('OKL: UPF A/C : populate_transaction : return status '||x_return_status);

      -- check transaction creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      -- Get Asset tax treatment (Financed or Capitalized), Tax line Amount for each asset, etc., for processing
      FOR i IN l_accoutable_tax_lines.FIRST..l_accoutable_tax_lines.LAST
      LOOP

        -- Populate TRX line array
        l_tclv_tbl(i).line_number   := i;
        l_tclv_tbl(i).tcn_id        := l_trx_id;
        l_tclv_tbl(i).khr_id        := p_contract_id;
        l_tclv_tbl(i).kle_id        := l_accoutable_tax_lines(i).asset_id;
        l_tclv_tbl(i).tcl_type      := l_fnd_rec.lookup_code;
        l_tclv_tbl(i).tax_line_id   := l_accoutable_tax_lines(i).tax_line_id;
        l_tclv_tbl(i).amount        := l_accoutable_tax_lines(i).tax_amount;
        l_tclv_tbl(i).currency_code := l_trxh_out_rec.currency_code;

        IF (l_accoutable_tax_lines(i).tax_treatment = 'FINANCE') THEN
          l_tclv_tbl(i).sty_id    := l_financed_sty_id;
        END IF;

        IF (l_accoutable_tax_lines(i).tax_treatment = 'CAPITALIZE') THEN
          l_tclv_tbl(i).sty_id    := l_capitalized_sty_id;
        END IF;

        --Bug# 6619311
        IF (l_accoutable_tax_lines(i).tax_treatment = 'BILLED')
        THEN
          l_tclv_tbl(i).sty_id    := l_billed_sty_id;
        END IF;
        --End Bug# 6619311

      END LOOP;

      -- Create TRX lines with the data gathered

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              , 'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Trx_Contracts_Pub.create_trx_cntrct_lines ');
      END IF;

      Okl_Trx_Contracts_Pub.create_trx_cntrct_lines(
                                      p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_tclv_tbl      => l_tclv_tbl,
                                      x_tclv_tbl      => x_tclv_tbl);

      okl_debug_pub.logmessage('OKL: UPF A/C : create_trx_cntrct_lines : '||x_return_status);

      -- check transaction line creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      -- Populate accounting API data structures
      populate_account_data(
                    p_api_version
                    ,p_init_msg_list
                    ,l_trxh_out_rec
                    ,x_tclv_tbl
                    ,l_acc_gen_tbl
                    ,l_tmpl_identify_tbl
                    ,l_dist_info_tbl
                    ,x_return_status
                    ,x_msg_count
                    ,x_msg_data);

      okl_debug_pub.logmessage('OKL: UPF A/C : populate_account_data : '||x_return_status);

      -- check transaction line creation was successful
      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG( FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: create_upfront_tax_accounting Procedure: Calling Okl_Account_Dist_Pub.CREATE_ACCOUNTING_DIST');
      END IF;

      okl_debug_pub.logmessage('OKL: UPF A/C : before calling okl_account_dist_pvt');

      -- Call Accounting API to create distributions
      okl_account_dist_pvt.create_accounting_dist(
                                  p_api_version             => 1.0,
                                  p_init_msg_list           => p_init_msg_list,
                                  x_return_status           => x_return_status,
                                  x_msg_count               => x_msg_count,
                                  x_msg_data                => x_msg_data,
                                  p_tmpl_identify_tbl       => l_tmpl_identify_tbl,
                                  p_dist_info_tbl           => l_dist_info_tbl,
                                  p_ctxt_val_tbl            => l_ctxt_tbl,
                                  p_acc_gen_primary_key_tbl => l_acc_gen_tbl,
                                  x_template_tbl            => l_template_out_tbl,
                                  x_amount_tbl              => l_amount_tbl,
                                  p_trx_header_id           => l_trxh_out_rec.id);

      okl_debug_pub.logmessage('OKL: UPF A/C : after calling okl_account_dist_pvt : '|| x_return_status);

      IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
      THEN
        RAISE upfront_tax_acct_exception;
      END IF;

      OKL_MULTIGAAP_ENGINE_PVT.CREATE_SEC_REP_TRX
                           (p_api_version => p_api_version
                           ,p_init_msg_list => p_init_msg_list
                           ,x_return_status => x_return_status
                           ,x_msg_count => x_msg_count
                           ,x_msg_data => x_msg_data
                           ,P_TCNV_REC => l_trxh_out_rec
                           ,P_TCLV_TBL => x_tclv_tbl
                           ,p_ctxt_val_tbl => l_ctxt_tbl
                           ,p_acc_gen_primary_key_tbl => l_acc_gen_tbl(1).acc_gen_key_tbl);

       IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
            RAISE Okl_Api.G_EXCEPTION_ERROR;
       END IF;

     END IF;
     --Bug# 7506009

    END IF; -- AMB Check

    okl_debug_pub.logmessage('OKL: UPF A/C : END');

  EXCEPTION
    WHEN upfront_tax_acct_exception
    THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;

  END create_upfront_tax_accounting;

  -- R12 - END


  -- Process to process pre booking tax lines
  Procedure process_prebook_tax(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_id   IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2
                          )
  IS

    rule_info_csr_rec           rule_info_csr%ROWTYPE;
    l_asset_count               NUMBER := 0;
    l_stream_id                 NUMBER := 0;
    l_fee_type                  OKC_RULES_B.rule_information1%TYPE;
    l_prev_fee_type             OKC_RULES_B.rule_information1%TYPE;
    l_multiple_fee_type         VARCHAR2(1) := Okl_Api.G_FALSE;
    pre_book_exception          exception;

    -- Cursor to check if sales tax fee exists
    -- Bug# 6512668: Exclude fee line in Abandoned status
    CURSOR check_st_fee_csr(p_chr_id IN NUMBER,
                            p_fee_type IN VARCHAR2)  IS
    SELECT cle.id
    FROM   okc_k_lines_b cle,
           okl_k_lines kle
    WHERE  cle.id = kle.id
    AND    cle.dnz_chr_id = p_chr_id
    AND    kle.fee_purpose_code = 'SALESTAX'
    AND    kle.fee_type = NVL(p_fee_type,kle.fee_type)
    AND    cle.sts_code <> 'ABANDONED';

    l_del_fee_line_id OKC_K_LINES_B.id%TYPE;
    l_del_fee_types_rec  OKL_MAINTAIN_FEE_PVT.fee_types_rec_type;
    l_fee_type_to_delete OKL_K_LINES.fee_type%TYPE;

  BEGIN
    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;
    -- Get rule value to identify upfront tax type

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: START ');
    END IF;

    OPEN  rule_info_csr(p_contract_id);
    FETCH rule_info_csr INTO rule_info_csr_rec;
    IF rule_info_csr%NOTFOUND THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QA_ST_MISSING');
      CLOSE rule_info_csr;
      RAISE pre_book_exception;
    END IF;
    CLOSE rule_info_csr;

    l_asset_count := 0;
    OPEN  check_lines_csr (p_contract_id, rule_info_csr_rec.rule_information1);
    FETCH check_lines_csr INTO l_asset_count;
    CLOSE check_lines_csr;

    -- If upfront tax is 'FINANCED'
    If (rule_info_csr_rec.rule_information1 = 'FINANCE'
        AND
        l_asset_count > 0)
    THEN
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL:  '||p_transaction_type||' Procedure: before calling create fee in FINANCE if');
      END IF;
      create_fee(
                 p_api_version      => p_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_contract_id      => p_contract_id,
                 p_transaction_id   => p_transaction_id,
                 p_default_feetype  => rule_info_csr_rec.rule_information1,
                 p_required_feetype => rule_info_csr_rec.rule_information1,
                 p_stream_id        => to_number(rule_info_csr_rec.rule_information3),
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
      -- Check if the call was successful
      If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
        RAISE pre_book_exception;
      End If;

      -- R12B Authoring OA Migration
      -- Delete Sales Tax Fee of Fee Type Capitalized
      l_del_fee_line_id := NULL;

      -- Check if Sales Tax Fee exists
      OPEN check_st_fee_csr(p_chr_id => p_contract_id,
                            p_fee_type => 'CAPITALIZED');
      FETCH check_st_fee_csr INTO l_del_fee_line_id;
      CLOSE check_st_fee_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||': CAPITALIZED Sales Tax Fee to Delete: '|| l_del_fee_line_id);
      END IF;

      IF l_del_fee_line_id IS NOT NULL THEN

        l_del_fee_types_rec.line_id := l_del_fee_line_id;
        l_del_fee_types_rec.dnz_chr_id := p_contract_id;

        -- delete fee line
        OKL_MAINTAIN_FEE_PVT.delete_fee_type(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_fee_types_rec  => l_del_fee_types_rec
        );

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: after calling OKL_MAINTAIN_FEE_PVT.delete_fee_type: x_return_status '|| x_return_status );
        END IF;

        -- Check if the call was successful
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE pre_book_exception;
        END IF;
      END IF;
      -- R12B Authoring OA Migration

    End If;

    -- If upfront tax is 'CAPITALIZED'
    If (rule_info_csr_rec.rule_information1 = 'CAPITALIZE' AND l_asset_count > 0)
    THEN
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: before calling create fee in CAPITALIZE if ');
      END IF;
      create_fee(
                 p_api_version      => p_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_contract_id      => p_contract_id,
                 p_transaction_id   => p_transaction_id,
                 p_default_feetype  => rule_info_csr_rec.rule_information1,
                 p_required_feetype => rule_info_csr_rec.rule_information1,
                 p_stream_id        => to_number(rule_info_csr_rec.rule_information4),
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
      -- Check if the call was successful
      If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
        RAISE pre_book_exception;
      End If;

      -- R12B Authoring OA Migration
      -- Delete Sales Tax Fee of Fee Type Financed
      l_del_fee_line_id := NULL;

      -- Check if Sales Tax Fee exists
      OPEN check_st_fee_csr(p_chr_id => p_contract_id,
                            p_fee_type => 'FINANCED');
      FETCH check_st_fee_csr INTO l_del_fee_line_id;
      CLOSE check_st_fee_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||': FINANCED Sales Tax Fee to Delete: '|| l_del_fee_line_id);
      END IF;

      IF l_del_fee_line_id IS NOT NULL THEN

        l_del_fee_types_rec.line_id := l_del_fee_line_id;
        l_del_fee_types_rec.dnz_chr_id := p_contract_id;

        -- delete fee line
        OKL_MAINTAIN_FEE_PVT.delete_fee_type(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_fee_types_rec  => l_del_fee_types_rec
        );

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: after calling OKL_MAINTAIN_FEE_PVT.delete_fee_type: x_return_status '|| x_return_status );
        END IF;

        -- Check if the call was successful
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE pre_book_exception;
        END IF;
      END IF;
      -- R12B Authoring OA Migration
    End If;

    -- If upfront tax is 'BILLED'
    IF (rule_info_csr_rec.rule_information1 = 'BILLED') THEN

      l_multiple_fee_type := Okl_Api.G_FALSE;
      l_fee_type := NULL;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: verifying if multiple fee treatments are selected ');
      END IF;
      FOR i in check_feetype_csr (p_contract_id)
      LOOP
        l_fee_type := i.feetype;
        IF (l_fee_type <> l_prev_fee_type) THEN
          l_multiple_fee_type := Okl_Api.G_TRUE;
          EXIT;
        END IF;
        l_prev_fee_type := i.feetype;
      END LOOP;

      IF (l_multiple_fee_type = Okl_Api.G_FALSE AND l_fee_type IS NOT NULL)
      THEN
        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: if multiple fee treatments are NOT selected');
        END IF;
        IF (l_fee_type = 'FINANCE') THEN
          l_stream_id := to_number(rule_info_csr_rec.rule_information3);
        END IF;

        IF (l_fee_type = 'CAPITALIZE') THEN
          l_stream_id := to_number(rule_info_csr_rec.rule_information4);
        END IF;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: before calling create fee for '||l_fee_type|| ' in BILLED if ');
        END IF;
        create_fee(
                 p_api_version      => p_api_version,
                 p_init_msg_list    => p_init_msg_list,
                 p_contract_id      => p_contract_id,
                 p_transaction_id   => p_transaction_id,
                 p_default_feetype  => 'BILLED',
                 p_required_feetype => l_fee_type,
                 p_stream_id        => to_number(l_stream_id),
                 x_return_status    => x_return_status,
                 x_msg_count        => x_msg_count,
                 x_msg_data         => x_msg_data);
        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: after calling create fee for '||
                                 l_fee_type
                                 || ' in BILLED if return status '|| x_return_status );
        END IF;
        -- Check if the call was successful
        If (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) then
          RAISE pre_book_exception;
        End If;

        -- R12B Authoring OA Migration
        -- Delete Sales Tax Fee of Fee Type Financed
        l_del_fee_line_id := NULL;
        IF (l_fee_type = 'FINANCE') THEN
          l_fee_type_to_delete := 'CAPITALIZED';
        ELSIF (l_fee_type = 'CAPITALIZE') THEN
          l_fee_type_to_delete := 'FINANCED';
        END IF;

        -- Check if Sales Tax Fee exists
        OPEN check_st_fee_csr(p_chr_id => p_contract_id,
                              p_fee_type => l_fee_type_to_delete);
        FETCH check_st_fee_csr INTO l_del_fee_line_id;
        CLOSE check_st_fee_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||': '||l_fee_type_to_delete||' Sales Tax Fee to Delete: '|| l_del_fee_line_id);
        END IF;

        IF l_del_fee_line_id IS NOT NULL THEN

          l_del_fee_types_rec.line_id := l_del_fee_line_id;
          l_del_fee_types_rec.dnz_chr_id := p_contract_id;

          -- delete fee line
          OKL_MAINTAIN_FEE_PVT.delete_fee_type(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_fee_types_rec  => l_del_fee_types_rec
          );

          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: after calling OKL_MAINTAIN_FEE_PVT.delete_fee_type: x_return_status '|| x_return_status );
          END IF;

          -- Check if the call was successful
          IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
            RAISE pre_book_exception;
          END IF;
        END IF;
        -- R12B Authoring OA Migration
      End If;
    End If;

    -- R12B Authoring OA Migration
    -- Delete Sales Tax Fee line if no Assets have tax treatment as Financed or Capitalized
    IF (rule_info_csr_rec.rule_information1 IN ('CAPITALIZE','FINANCE') AND l_asset_count = 0) OR
       (rule_info_csr_rec.rule_information1 = 'BILLED' AND NVL(l_fee_type,'BILLED') = 'BILLED') THEN

      l_del_fee_line_id := NULL;

      -- Check if Sales Tax Fee exists
      OPEN check_st_fee_csr(p_chr_id => p_contract_id,
                            p_fee_type => NULL);
      FETCH check_st_fee_csr INTO l_del_fee_line_id;
      CLOSE check_st_fee_csr;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||': Sales Tax Fee to Delete: '|| l_del_fee_line_id);
      END IF;

      IF l_del_fee_line_id IS NOT NULL THEN

        l_del_fee_types_rec.line_id := l_del_fee_line_id;
        l_del_fee_types_rec.dnz_chr_id := p_contract_id;

        -- delete fee line
        OKL_MAINTAIN_FEE_PVT.delete_fee_type(
          p_api_version    => p_api_version,
          p_init_msg_list  => p_init_msg_list,
          x_return_status  => x_return_status,
          x_msg_count      => x_msg_count,
          x_msg_data       => x_msg_data,
          p_fee_types_rec  => l_del_fee_types_rec
        );

        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: after calling OKL_MAINTAIN_FEE_PVT.delete_fee_type: x_return_status '|| x_return_status );
        END IF;

        -- Check if the call was successful
        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE pre_book_exception;
        END IF;
      END IF;
    END IF;
    -- R12B Authoring OA Migration

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: '||p_transaction_type||' Procedure: END ');
    END IF;

    Exception
      when pre_book_exception then
         x_return_status := OKL_API.G_RET_STS_ERROR;

  END process_prebook_tax;

  -- Procedure to process Booking
  Procedure process_booking_tax(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_id   IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2 )
  IS

    -- Cursor to get contract start date for billing
    CURSOR contract_csr IS
    SELECT start_date
    FROM   okc_k_headers_b
    WHERE  id = p_contract_id;

    rule_info_csr_rec                rule_info_csr%ROWTYPE;
    l_ST_params_exist                VARCHAR2(1);
    l_api_name                       CONSTANT VARCHAR(30) := 'process_booking_tax';
    l_booking_financed_tax           NUMBER;
    l_prebook_financed_tax           NUMBER;
    l_booking_capitalized_tax        NUMBER;
    L_prebook_capitalized_tax        NUMBER;
    l_booking_billable_tax           NUMBER;
    l_contract_start_date            OKC_K_HEADERS_B.START_DATE%TYPE;
    l_source_table                   VARCHAR2(30) := 'OKL_TRX_CONTRACTS';
    l_billed_assets                  NUMBER :=0;
    l_asset_count                    NUMBER :=0;
    l_multiple_fee_type              VARCHAR2(1) := Okl_Api.G_FALSE;
    l_fee_type                       OKC_RULES_B.rule_information1%TYPE;
    l_prev_fee_type                  OKC_RULES_B.rule_information1%TYPE;
    l_contract_bill_tax              NUMBER :=0;
    booking_exception                exception;

  BEGIN

    okl_debug_pub.logmessage('OKL: process_booking_tax : START' );

    IF (G_DEBUG_ENABLED = 'Y')
    THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE
                                                            , FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := okl_Api.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: Booking Procedure: START');
    END IF;

    -- 1. Check if user selected Sales Tax parameters. There is a posibility
    --    user does not create Sales Tax T and C

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: Booking Procedure: before rule_info_csr');
    END IF;

    OPEN rule_info_csr(p_contract_id);
    FETCH rule_info_csr INTO rule_info_csr_rec;

    IF rule_info_csr%NOTFOUND
    THEN
      OKL_API.set_message( p_app_name => G_APP_NAME,
                           p_msg_name => 'OKL_QA_ST_MISSING');
      CLOSE rule_info_csr;
      RAISE booking_exception;
    END IF;

    CLOSE rule_info_csr;

    -- Call Tax API
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: Booking Procedure: before calling tax API');
    END IF;

    OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_source_trx_id    => p_transaction_id,
                      p_source_trx_name  => p_transaction_type,
                      p_source_table     => l_source_table,
                      p_tax_call_type    => 'ACTUAL' );

    okl_debug_pub.logmessage('OKL: process_booking_tax : OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax: ACTUAL : '|| x_return_status );

    -- Check if the tax call was successful
    IF (x_return_status <> okl_Api.G_RET_STS_SUCCESS)
    THEN
      RAISE booking_exception;
    END IF;

    --Bug# 6619311: Create upfront tax accounting for all tax treatments
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: Booking Procedure: Calling create_upfront_tax_accounting ');
    END IF;

    create_upfront_tax_accounting
            (
             p_api_version      => p_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_contract_id      => p_contract_id,
             p_transaction_id   => p_transaction_id,
             p_transaction_type => p_transaction_type,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data
            );

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      RAISE booking_exception;
    END IF;

    -- This segment will be executed when user selected Financed or Capitalized
    -- T and C but selected billed option for one or more asset at line level
    IF (rule_info_csr_rec.rule_information1 = 'CAPITALIZE'
        OR
        rule_info_csr_rec.rule_information1 = 'FINANCE')
    THEN

      -- Check if billing required and call billing API as required

      --R12B ebTax changes
      l_billed_assets := 0;
      OPEN billing_required_csr1(p_contract_id,p_transaction_id);
      FETCH billing_required_csr1 into l_billed_assets;
      CLOSE billing_required_csr1;

      --Bug# 6939336
      l_contract_bill_tax := 0;
      OPEN contract_billing_csr(p_contract_id, p_transaction_id);
      FETCH contract_billing_csr INTO l_contract_bill_tax;
      CLOSE contract_billing_csr;

      --Bug# 6939336
      IF (l_billed_assets <> 0 OR l_contract_bill_tax <> 0)
      THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
        THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                  , G_MODULE
                                  ,'OKL: Booking Procedure: before contract_csr');
        END IF;

        OPEN contract_csr;
        FETCH contract_csr INTO l_contract_start_date;

        IF contract_csr%NOTFOUND
        THEN
          OKL_API.set_message( p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LA_ST_K_DATE_ERROR');
          CLOSE contract_csr;
          RAISE booking_exception;
        END IF;

        CLOSE contract_csr;

        OKL_BILL_UPFRONT_TAX_PVT.Bill_Upfront_Tax(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_khr_id           => p_contract_id,
           p_trx_id           => p_transaction_id,
           p_invoice_date     => l_contract_start_date,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE booking_exception;
        END IF;

      END IF;

    END IF;

    -- But we will bill any amount that comes for Billing Tax
    IF (rule_info_csr_rec.rule_information1 = 'BILLED')
    THEN

      -- Check if any of the assets is financed or capitalized and
      -- check tax pre-book and booking tax amounts
      l_multiple_fee_type := Okl_Api.G_FALSE;
      l_fee_type := NULL;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
      THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                , G_MODULE
                                ,'OKL: Booking Procedure: verifying if multiple fee treatments are selected ');
      END IF;

      FOR i in check_feetype_csr (p_contract_id)
      LOOP
        l_fee_type := i.feetype;

        IF (l_fee_type <> l_prev_fee_type)
        THEN
          l_multiple_fee_type := okl_Api.G_TRUE;
          EXIT;
        END IF;

        l_prev_fee_type := i.feetype;
      END LOOP;

      -- User cannot create both Financed and Capitalized sales tax fee lines
      IF (l_multiple_fee_type = okl_Api.G_TRUE)
      THEN
        OKL_API.set_message( p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_LA_ST_MIX_FEE_ERROR');
        RAISE booking_exception;
      END IF;

      -- Now Billing transaction creation logic starts
      -- Check if billing required and call billing API as required
      l_billed_assets := 0;
      OPEN billing_required_csr2(p_contract_id,p_transaction_id);
      FETCH billing_required_csr2 into l_billed_assets;
      CLOSE billing_required_csr2;

      -- R12B eBtax changes
      l_contract_bill_tax := 0;
      OPEN contract_billing_csr(p_contract_id, p_transaction_id);
      FETCH contract_billing_csr INTO l_contract_bill_tax;
      CLOSE contract_billing_csr;

      -- R12B eBtax changes
      IF (l_billed_assets <> 0 OR l_contract_bill_tax <> 0)
      THEN
        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                  , G_MODULE
                                  ,'OKL: Booking Procedure: before contract_csr');
        END IF;
        OPEN contract_csr;
        FETCH contract_csr INTO l_contract_start_date;
        IF contract_csr%NOTFOUND THEN
          OKL_API.set_message( p_app_name => G_APP_NAME,
                               p_msg_name => 'OKL_LA_ST_K_DATE_ERROR');
          CLOSE contract_csr;
          RAISE booking_exception;
        END IF;
        CLOSE contract_csr;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Booking Procedure: before OKL_BILL_UPFRONT_TAX_PVT ');
        END IF;

        OKL_BILL_UPFRONT_TAX_PVT.Bill_Upfront_Tax(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_khr_id           => p_contract_id,
           p_trx_id           => p_transaction_id,
           p_invoice_date     => l_contract_start_date,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE booking_exception;
        END IF;
      END IF;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: Booking Procedure: END');
    END IF;

    okl_debug_pub.logmessage('OKL: process_booking_tax : END' );

  Exception
      when booking_exception then
         x_return_status := OKL_API.G_RET_STS_ERROR;

END process_booking_tax;


  -- Procedure to process Booking
  Procedure process_rebook_tax(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_id   IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_date IN  DATE,
                      p_rbk_contract_id  IN  NUMBER,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2 )
  IS

    -- R12 - START
    CURSOR acct_opt_csr
    IS
    SELECT account_derivation
    FROM   okl_sys_acct_opts;

    l_acct_opt okl_sys_acct_opts.account_derivation%TYPE;
    -- R12 - END

    l_contract_bill_tax         NUMBER :=0;
    rule_info_csr_rec           rule_info_csr%ROWTYPE;
    l_asset_count               NUMBER;
    l_billed_assets             NUMBER :=0;
    l_multiple_fee_type         VARCHAR2(1) := Okl_Api.G_FALSE;
    l_fee_type                  OKC_RULES_B.rule_information1%TYPE;
    l_prev_fee_type             OKC_RULES_B.rule_information1%TYPE;
    rebook_exception            EXCEPTION;

  BEGIN

    okl_debug_pub.logmessage('OKL: process_rebook_tax : START' );

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: Rebook Procedure: START');
    END IF;

    OPEN  rule_info_csr (p_contract_id);
    FETCH rule_info_csr INTO rule_info_csr_rec;

    IF rule_info_csr%NOTFOUND
    THEN
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QA_ST_MISSING');
      CLOSE rule_info_csr;
      RAISE rebook_exception;
    END IF;

    CLOSE rule_info_csr;

    l_asset_count := 0;
    OPEN  check_lines_csr (p_contract_id, rule_info_csr_rec.rule_information1);
    FETCH check_lines_csr INTO l_asset_count;
    CLOSE check_lines_csr;

    OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_source_trx_id    => p_transaction_id,
                      p_source_trx_name  => p_transaction_type,
                      p_source_table     => g_source_table,
                      p_tax_call_type    => 'ACTUAL' );

    okl_debug_pub.logmessage('OKL: process_rebook_tax : OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax: ACTUAL : '|| x_return_status );

    -- Check if the tax call was successful
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS)
    THEN
      RAISE rebook_exception;
    END IF;

    --Bug# 6619311: Create upfront tax accounting for all tax treatments
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: Booking Procedure: Calling create_upfront_tax_accounting ');
    END IF;

    create_upfront_tax_accounting
            (
             p_api_version      => p_api_version,
             p_init_msg_list    => p_init_msg_list,
             p_contract_id      => p_contract_id,
             p_transaction_id   => p_transaction_id,
             p_transaction_type => p_transaction_type,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data
            );

    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
      RAISE rebook_exception;
    END IF;

    -- This segment will be executed when user selected Financed or Capitalized
    -- T and C but selected billed option for one or more asset at line level
    IF (rule_info_csr_rec.rule_information1 = 'CAPITALIZE'
        OR
        rule_info_csr_rec.rule_information1 = 'FINANCE')
    THEN

      -- Check if billing required and call billing API as required
      -- R12B eBTax changes
      l_billed_assets := 0;
      OPEN billing_required_csr1(p_contract_id,p_transaction_id);
      FETCH billing_required_csr1 into l_billed_assets;
      CLOSE billing_required_csr1;

      --Bug# 6939336
      l_contract_bill_tax := 0;
      OPEN contract_billing_csr(p_contract_id, p_transaction_id);
      FETCH contract_billing_csr INTO l_contract_bill_tax;
      CLOSE contract_billing_csr;

      --Bug# 6939336
      IF (l_billed_assets <> 0 OR l_contract_bill_tax <> 0)
      THEN

        OKL_BILL_UPFRONT_TAX_PVT.Bill_Upfront_Tax(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_khr_id           => p_contract_id,
           p_trx_id           => p_transaction_id,
           p_invoice_date     => p_transaction_date,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE rebook_exception;
        END IF;

      END IF;

    END IF; -- rule_info_csr_rec.rule_information1 = 'CAPITALIZE' or 'FINANCED


    -- But we will bill any amount that comes for Billing Tax
    IF (rule_info_csr_rec.rule_information1 = 'BILLED')
    THEN

      -- Check if any of the assets is financed or capitalized and
      -- check tax pre-book and booking tax amounts
      l_multiple_fee_type := Okl_Api.G_FALSE;
      l_fee_type := NULL;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                                ,G_MODULE
                                ,'OKL: Rebook Procedure: verifying if multiple fee treatments are selected ');
      END IF;
      FOR i in check_feetype_csr (p_contract_id)
      LOOP
        l_fee_type := i.feetype;
        IF (l_fee_type <> l_prev_fee_type) THEN
          l_multiple_fee_type := Okl_Api.G_TRUE;
          EXIT;
        END IF;
        l_prev_fee_type := i.feetype;
      END LOOP;

      -- User cannot create both Financed and Capitalized sales tax fee lines
      IF (l_multiple_fee_type = Okl_Api.G_TRUE) THEN
        OKL_API.set_message( p_app_name => G_APP_NAME,
                             p_msg_name => 'OKL_LA_ST_MIX_FEE_ERROR');
        RAISE rebook_exception;
      END IF;

      -- Now Billing transaction creation logic starts
      -- Check if billing required and call billing API as required
      l_billed_assets := 0;
      OPEN billing_required_csr2(p_contract_id,p_transaction_id);
      FETCH billing_required_csr2 into l_billed_assets;
      CLOSE billing_required_csr2;

      -- R12B eBTax changes
      l_contract_bill_tax := 0;
      OPEN contract_billing_csr(p_contract_id, p_transaction_id);
      FETCH contract_billing_csr INTO l_contract_bill_tax;
      CLOSE contract_billing_csr;

      -- R12B eBtax changes
      IF (l_billed_assets <> 0 OR l_contract_bill_tax <> 0) THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Rebook Procedure: before OKL_BILL_UPFRONT_TAX_PVT ');
        END IF;

        OKL_BILL_UPFRONT_TAX_PVT.Bill_Upfront_Tax(
           p_api_version      => p_api_version,
           p_init_msg_list    => p_init_msg_list,
           p_khr_id           => p_contract_id,
           p_trx_id           => p_transaction_id,
           p_invoice_date     => p_transaction_date,
           x_return_status    => x_return_status,
           x_msg_count        => x_msg_count,
           x_msg_data         => x_msg_data);

        IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          RAISE rebook_exception;
        END IF;

      END IF;

    END IF; -- rule_info_csr_rec.rule_information1 = 'BILLED'

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE)
    THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT
                              ,G_MODULE
                              ,'OKL: rebook Procedure: END');
    END IF;

    okl_debug_pub.logmessage('OKL: process_rebook_tax : END' );

  Exception
    when rebook_exception then
      x_return_status := OKL_API.G_RET_STS_ERROR;

  END process_rebook_tax;




  -- Main proccedure to call for all authoring
  -- processes to process upfront sales tax

  Procedure process_sales_tax(
                      p_api_version      IN  NUMBER,
                      p_init_msg_list    IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_commit           IN  VARCHAR2 DEFAULT Okl_Api.G_FALSE,
                      p_contract_id      IN  NUMBER,
                      p_transaction_type IN  VARCHAR2,
                      p_transaction_id   IN  NUMBER DEFAULT NULL,
                      p_transaction_date IN  DATE DEFAULT NULL,
                      p_rbk_contract_id  IN  NUMBER DEFAULT NULL,
                      x_return_status    OUT NOCOPY VARCHAR2,
                      x_msg_count        OUT NOCOPY NUMBER,
                      x_msg_data         OUT NOCOPY VARCHAR2)  IS

     -- Define PL/SQL Records and Tables
    l_trxH_in_rec        Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_in_rec        Okl_Trx_Contracts_Pvt.tclv_rec_type;
    l_trxH_out_rec       Okl_Trx_Contracts_Pvt.tcnv_rec_type;
    l_trxL_out_rec       Okl_Trx_Contracts_Pvt.tclv_rec_type;

    -- Define variables
    l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_transaction_id  NUMBER;
    l_has_trans       VARCHAR2(1);
    -- Bug 4769822 - START
    l_contract_id     NUMBER;
    -- Bug 4769822 - END


    -- R12 Change - START
    rule_info_csr_rec rule_info_csr%ROWTYPE;
    -- R12 Change - END


     -- Define constants
    l_api_name        CONSTANT VARCHAR(30) := 'PROCESS_SALES_TAX';

    CURSOR sys_param_csr IS
    SELECT nvl(tax_upfront_yn,'N')
                 --,           nvl(tax_schedule_yn,'N') -- added for Bug 4748910  -- Not required in R12
    FROM   okl_system_params;

    -- Cursor Types
    l_fnd_rec          fnd_lookups_csr%ROWTYPE;

    l_transaction_type     VARCHAR2(256) := p_transaction_type;
    l_source_table         VARCHAR2(30) := 'OKL_TRX_CONTRACTS';
    l_tax_upfront_yn       okl_system_params.tax_upfront_yn%TYPE;
    -- l_tax_schedule_yn      VARCHAR2(1) := NULL; -- this variable is not required in R12

    -- Bug 4748910 - START

    CURSOR c_currency_code(p_khr_id IN NUMBER) IS
    SELECT start_date, end_date, currency_code
    FROM   OKC_K_HEADERS_B
    WHERE  ID = p_contract_id;

    CURSOR c_try_type(p_name IN VARCHAR2) IS
    SELECT ID
    FROM   OKL_TRX_TYPES_TL
    WHERE  name = p_name
    AND    LANGUAGE = 'US';

    l_currency_code VARCHAR2(15);
    l_start_date    DATE;
    l_end_date      DATE;
    l_try_id        NUMBER;
    l_try_name      VARCHAR2(100) := 'Tax Schedule';
    l_trqv_tbl      okl_trx_requests_pub.trqv_tbl_type;
    x_trqv_tbl      okl_trx_requests_pub.trqv_tbl_type;

    -- BUG 4748910 - END

    -- Bug 6155565
    CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
    SELECT NVL(rule_information1,'N')
    FROM   okc_rules_b rul
    WHERE  rul.dnz_chr_id = p_chr_id
    AND    rul.rule_information_category = 'LARLES';

    l_release_asset_yn VARCHAR2(1);

  BEGIN

    okl_debug_pub.logmessage('OKL: process_sales_tax : START');

    IF (G_DEBUG_ENABLED = 'Y') THEN
      G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
    END IF;

    x_return_status  := Okl_Api.G_RET_STS_SUCCESS;

    x_return_status := OKL_API.START_ACTIVITY(
			p_api_name      => l_api_name,
			p_pkg_name      => g_pkg_name,
			p_init_msg_list => p_init_msg_list,
			l_api_version   => p_api_version,
			P_api_version   => p_api_version,
			p_api_type      => G_API_TYPE,
			x_return_status => x_return_status);

    -- check if activity started successfully
    If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
       raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
       raise OKL_API.G_EXCEPTION_ERROR;
    End If;

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax : START ');
    END IF;

    OPEN  sys_param_csr;
    FETCH sys_param_csr INTO l_tax_upfront_yn;
    IF sys_param_csr%NOTFOUND THEN
      Okl_Api.SET_MESSAGE(G_APP_NAME, 'OKL_LA_ST_OU_UPFRONT_TAX_ERROR');
      CLOSE sys_param_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE sys_param_csr;


    -- First off check upfront tax is enabled, if not
    -- Sales Tax processing is not required for the contract
    IF (l_tax_upfront_yn = 'Y' ) THEN

     -- Bug 6155565
     OPEN  l_chk_rel_ast_csr(p_contract_id);
     FETCH l_chk_rel_ast_csr INTO l_release_asset_yn;
     CLOSE l_chk_rel_ast_csr;

     IF (l_release_asset_yn = 'Y') THEN
          NULL; -- Do not calculate upfront tax for contracts having re-leased assets
     ELSE

      l_transaction_id := p_transaction_id;

      -- Create or update tax transaction
      -- In R12, we will no longer create Pre-Rebook
      -- TRX as we used to in previous release, OKL.H
      -- For Pre-Rebook ebTax calls, we will reuse Rebook
      -- TRX. Remove Pre-Rebook reference in the following
      -- Code segment

      IF (p_transaction_type = 'Pre-Booking') THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax : before populate_transaction ');
        END IF;

         -- R12 Change - START

        l_contract_id := p_contract_id;

        -- create booking transaction at 'Validation' time
        -- instead of 'Pre-Booking' transaction
        populate_transaction(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => l_contract_id,
                      -- p_transaction_type => p_transaction_type, -- R12 Change
                      p_transaction_type => 'Booking', -- R12 Change
                      p_transaction_id   => p_transaction_id,
                      p_source_trx_id    => NULL,
                      p_source_trx_type  => NULL,
                      x_transaction_id   => l_transaction_id,
                      x_trxh_out_rec     => l_trxh_out_rec,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        okl_debug_pub.logmessage('OKL: process_sales_tax : populate_transaction : '|| x_return_status );

        -- check transaction creation was successful
        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        End If;

        -- R12 Change - END
      End If;

      -- Process Pre Booking Tax Call
      If (p_transaction_type = 'Pre-Booking'
          OR
          p_transaction_type = 'Pre-Rebook')    -- Bug 4769822
      THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax : '||p_transaction_type||' before calculate_sales_tax ');
        END IF;

        -- Call Tax API

        -- R12 Change - START

        IF (p_transaction_type = 'Pre-Booking')
        THEN
          l_contract_id      := p_contract_id;
          l_transaction_type := 'Booking';
        ELSIF (p_transaction_type = 'Pre-Rebook') THEN
          l_contract_id := p_rbk_contract_id;
          l_transaction_type := 'Rebook';
        End If;

        -- R12 Change - END

       -- ER# 9327076 - Added condition - For rebook estimated tax call, estimate tax only if prior upfront tax present
	   IF (p_transaction_type = 'Pre-Booking'
	        OR (p_transaction_type = 'Pre-Rebook' AND check_prior_upfront_tax(p_contract_id))) THEN
        OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_source_trx_id    => l_transaction_id,
                      -- p_source_trx_name  => p_transaction_type, -- R12 Change
                      p_source_trx_name  => l_transaction_type, -- R12 Change
                      p_source_table     => l_source_table,
                      p_tax_call_type    => 'ESTIMATED');

        okl_debug_pub.logmessage('OKL: process_sales_tax : OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax: ESTIMATED : '|| x_return_status );

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax...3'|| x_return_status);
        END IF;
        -- Check if the tax call was successful
        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        End If;

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax : '||p_transaction_type||' before process_prebook_tax ');
        END IF;

        process_prebook_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => l_contract_id,   -- Bug 4769822
                      p_transaction_id   => l_transaction_id,
                      -- p_transaction_type => p_transaction_type, -- R12 change
                      p_transaction_type => l_transaction_type, -- R12 change
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data
                          );

        okl_debug_pub.logmessage('OKL: process_sales_tax : process_prebook_tax : '|| x_return_status );

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                  G_MODULE,
                                  'OKL: Process Sales Tax : '||p_transaction_type||
                                  ' after process_prebook_tax: x_return_status' ||x_return_status);
        END IF;

        -- Check if the call was successful
        -- Following code enabled for bug 5005269

        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        End If;

       END IF; -- ER# 9327076

      End If; -- Prebook

      -- Process Booking Activation Tax Call
      If (p_transaction_type = 'Booking') THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Process Sales Tax : '||p_transaction_type||' before process_booking_tax ');
        END IF;

        process_booking_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => p_contract_id,
                      p_transaction_id   => l_transaction_id,
                      p_transaction_type => p_transaction_type,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        okl_debug_pub.logmessage('OKL: process_sales_tax : process_booking_tax : '|| x_return_status );
        -- Check if the call was successful
        -- Bug 5002042
        If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
          raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
          raise OKL_API.G_EXCEPTION_ERROR;
        End If;

      End If; -- Booking

      -- Process Rebook Activation Tax Call
      IF (p_transaction_type = 'Rebook') THEN

        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Process Sales Tax : '||p_transaction_type||' before process_rebook_tax ');
        END IF;

		--ER# 9327076
		IF (check_prior_upfront_tax(p_contract_id)) THEN
        process_rebook_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      p_contract_id      => p_contract_id,
                      p_transaction_id   => p_transaction_id,
                      p_transaction_type => p_transaction_type,
                      p_transaction_date => p_transaction_date,
                      p_rbk_contract_id  => p_rbk_contract_id,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data);

        okl_debug_pub.logmessage('OKL: process_sales_tax : process_rebook_tax : '|| x_return_status );
		END IF;

      End If; -- Rebook

      -- Process Mass Rebook trx
      -- R12 Change - Code segment to process 'Mass-Rebook'
      -- is removed from this location. It is not required as per IA.
      -- If required, take it from OKL.H code line

      -- R12 Change - Code segment to update transaction records to 'Processed'
      -- is removed from this location. It is not required as per IA.
      -- If required, take it from OKL.H code line

    END IF; -- Bug 6155565
   END IF;

    -- R12 Change - Start


    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(  FND_LOG.LEVEL_STATEMENT
                              , G_MODULE
                              ,'OKL: Process Sales Tax : Tax schedule csr ');
    END IF;

    OPEN   rule_info_csr(p_contract_id);
    FETCH  rule_info_csr INTO rule_info_csr_rec;
    IF rule_info_csr%NOTFOUND THEN
      -- R12B Authoring OA Migration - Corrected error message
      OKL_API.set_message( p_app_name     => G_APP_NAME,
                           p_msg_name     => 'OKL_QA_ST_MISSING');
      CLOSE rule_info_csr;
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    CLOSE rule_info_csr;

    -- R12 Change - End

    -- Bug 4748910 - START

    -- Process Tax schedule
    IF (nvl(rule_info_csr_rec.rule_information5,'N') = 'Y'
        AND
        (p_transaction_type = 'Booking'
         OR
         p_transaction_type = 'Rebook')
       )
    THEN

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : START tax schedule ');
      END IF;

      OPEN c_currency_code(p_contract_id);
      FETCH c_currency_code INTO l_start_date, l_end_date, l_currency_code;
      CLOSE c_currency_code;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : after currency code csr ');
      END IF;

      OPEN c_try_type(l_try_name);
      FETCH c_try_type INTO l_try_id;
      CLOSE c_try_type;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : after try type csr');
      END IF;

      l_trqv_tbl(1).request_status_code   := 'PROCESSED';
      l_trqv_tbl(1).request_type_code     := 'TAX_SCHEDULES';
      l_trqv_tbl(1).dnz_khr_id            := p_contract_id;
      l_trqv_tbl(1).currency_code         := l_currency_code;
      l_trqv_tbl(1).start_date            := l_start_date;
      l_trqv_tbl(1).end_date              := l_end_date;
      l_trqv_tbl(1).try_id                := l_try_id;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : before creating trx requests');
      END IF;

      okl_trx_requests_pub.insert_trx_requests(
                                             p_api_version         => p_api_version,
                                             p_init_msg_list       => p_init_msg_list,
                                             x_return_status       => x_return_status,
                                             x_msg_count           => x_msg_count,
                                             x_msg_data            => x_msg_data,
                                             p_trqv_tbl            => l_trqv_tbl,
                                             x_trqv_tbl            => x_trqv_tbl);

      okl_debug_pub.logmessage('OKL: process_sales_tax : okl_trx_requests_pub.insert_trx_requests : '|| x_return_status );

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : after creating trx requests: status-> '|| x_return_status);
      END IF;

      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : before OKL_PROCESS_SALES_TAX_PUB');
      END IF;

      OKL_PROCESS_SALES_TAX_PUB.calculate_sales_tax(
                      p_api_version      => p_api_version,
                      p_init_msg_list    => p_init_msg_list,
                      x_return_status    => x_return_status,
                      x_msg_count        => x_msg_count,
                      x_msg_data         => x_msg_data,
                      p_source_trx_id    => x_trqv_tbl(1).id,
                      p_source_trx_name  => l_try_name,
                      p_source_table     => 'OKL_TRX_REQUESTS',
                      p_tax_call_type    => NULL);

      okl_debug_pub.logmessage('OKL: process_sales_tax : after creating tax schedule : '|| x_return_status );

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,'OKL: Process Sales Tax : after OKL_PROCESS_SALES_TAX_PUB: status-> '|| x_return_status);
      END IF;

      -- Check if the tax call was successful
      If (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) then
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ElSIF (x_return_status = OKL_API.G_RET_STS_ERROR) then
        raise OKL_API.G_EXCEPTION_ERROR;
      End If;

      -- R12 Change - Code segment to update transaction records to 'Processed'
      -- is removed from this location. It is not required as per IA.
      -- If required, take it from OKL.H code line

      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT,
                                G_MODULE,
                                'OKL: Process Sales Tax : END tax schedule ');
      END IF;

    End If; -- Tax Schedule

    -- Bug 4748910 - END

    OKC_API.END_ACTIVITY (x_msg_count	=> x_msg_count,
                          x_msg_data	=> x_msg_data);

    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'OKL: Process Sales Tax : END ');
    END IF;

    okl_debug_pub.logmessage('OKL: process_sales_tax : END');

    Exception
      when OKL_API.G_EXCEPTION_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

      when OKL_API.G_EXCEPTION_UNEXPECTED_ERROR then
		x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

      when OTHERS then
      	x_return_status := OKL_API.HANDLE_EXCEPTIONS(
			p_api_name  => l_api_name,
			p_pkg_name  => g_pkg_name,
			p_exc_name  => 'OTHERS',
			x_msg_count => x_msg_count,
			x_msg_data  => x_msg_data,
			p_api_type  => g_api_type);

  END process_sales_tax;


-- Start of comments
--
-- Procedure Name  : check_sales_tax
-- Description     : Qa Checker Validation for sales tax.
--                   Called by Qa Checker to check for header,
--                   asset level rules and validates Sales Tax
--                   Fee lines
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0, ramurt Created. Bug#4373029
-- End of comments

  PROCEDURE check_sales_tax(
    p_chr_id                   IN  NUMBER,
    x_return_status            OUT NOCOPY VARCHAR2
  ) IS

  cursor fnd_csr( fndType VARCHAR2, fndCode VARCHAR2 ) IS
  Select meaning,
  description
  From  fnd_lookups
  Where lookup_type = fndType
  and lookup_code = fndCode;

  CURSOR l_hdr_csr IS
  SELECT authoring_org_id
  FROM   okc_k_headers_b
  WHERE  id = p_chr_id;
  l_authoring_org_id OKC_K_HEADERS_B.AUTHORING_ORG_ID%TYPE;

  cursor l_hdrrl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                      rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                      chrId NUMBER) IS
  select crl.object1_id1,
         crl.RULE_INFORMATION1,
         crl.RULE_INFORMATION2,
         crl.RULE_INFORMATION3,
         crl.RULE_INFORMATION4,
         crl.RULE_INFORMATION5,
         crl.RULE_INFORMATION6,
         crl.RULE_INFORMATION7,
         crl.RULE_INFORMATION10,
         crl.RULE_INFORMATION11
  from   OKC_RULE_GROUPS_B crg,
         OKC_RULES_B crl
  where  crl.rgp_id = crg.id
  and crg.RGD_CODE = rgcode
  and crl.RULE_INFORMATION_CATEGORY = rlcat
  and crg.dnz_chr_id = chrId;


  cursor l_rl_csr1( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                    rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                    chrId NUMBER,
                    cleId NUMBER ) IS
  select crl.id slh_id,
         crl.object1_id1,
         crl.RULE_INFORMATION1,
         crl.RULE_INFORMATION2,
         crl.RULE_INFORMATION3,
         crl.RULE_INFORMATION5,
         crl.RULE_INFORMATION6,
         crl.RULE_INFORMATION7,
         crl.RULE_INFORMATION8,
         crl.RULE_INFORMATION10
  from   OKC_RULE_GROUPS_B crg,
         OKC_RULES_B crl
  where  crl.rgp_id = crg.id
         and crg.RGD_CODE = rgcode
         and crl.RULE_INFORMATION_CATEGORY = rlcat
         and crg.dnz_chr_id = chrId
         and nvl(crg.cle_id,-1) = cleId
  order by crl.RULE_INFORMATION1;

  l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
  l_exists boolean;
  l_pmnt_exists boolean;
  l_linked_asset_exists boolean;
  --l_tax_treatment  VARCHAR2(100);
  l_tax_header VARCHAR2(100);
  l_fnd_rec fnd_csr%ROWTYPE;
  l_line_fnd_rec fnd_csr%ROWTYPE;
  l_hdr_fnd_rec fnd_csr%ROWTYPE;
  l_fnd_meaning fnd_lookups.MEANING%TYPE;
  l_line_fnd_meaning fnd_lookups.MEANING%TYPE;
  l_hdr_fnd_meaning fnd_lookups.MEANING%TYPE;
  l_fee_type_meaning fnd_lookups.MEANING%TYPE;
  --l_tax_treatment_fee fnd_lookups.MEANING%TYPE;
  l_tax_fee_meaning fnd_lookups.MEANING%TYPE;
  l_st_fee_code fnd_lookups.LOOKUP_CODE%TYPE;
  l_count NUMBER;
  l_amt_link_asset NUMBER;
  l_no_link_assets NUMBER;
  l_bill_strm_type NUMBER;
  l_line_asset_upfront_tax VARCHAR2(150);
  l_prev_line_asset_upfront_tax VARCHAR2(150);
  l_fee_line_found BOOLEAN;
  l_found_asset_not_billed BOOLEAN;
  l_rl_rec l_rl_csr1%ROWTYPE;

  CURSOR st_fee_csr (p_chrId OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT cleb.id,
         kle.fee_type,
         kle.amount
         --decode(kle.fee_type,'CAPITALIZED',kle.capital_amount,kle.amount) amount
  FROM
         okc_k_lines_b cleb,
         okc_k_lines_tl clet,
         okl_k_lines kle,
         okc_line_styles_v sty,
         okc_statuses_v sts
  WHERE  cleb.lse_id = sty.id
  AND    cleb.sts_code = sts.code
  AND    sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    sty.lty_code = 'FEE'
  AND    kle.FEE_PURPOSE_CODE='SALESTAX'
  AND    cleb.dnz_chr_id = p_chrId
  AND    cleb.id = clet.id
  AND    clet.LANGUAGE = USERENV('LANG')
  AND    kle.id = cleb.id;
  l_st_fee_rec st_fee_csr%ROWTYPE;
  l_fee_amount okl_k_lines.amount%TYPE;

  CURSOR st_fee_link_asset_csr(p_cleId OKC_K_LINES_B.ID%TYPE) IS
  SELECT cleb.id,
         nvl(kle.amount,0) amount,
         nvl(kle.capital_amount,0) capital_amount
  FROM  okc_k_lines_b cleb,
        okl_k_lines kle,
        okc_line_styles_b sty
  WHERE cle_id = p_cleId
  AND   cleb.id = kle.id
  AND   cleb.lse_id = sty.id
  AND   sty.lty_code = 'LINK_FEE_ASSET';

  l_st_fee_link_asset_rec st_fee_link_asset_csr%ROWTYPE;

  CURSOR l_asset_tax_rule_csr(p_cleId OKC_K_LINES_B.ID%TYPE) IS
  SELECT crl.id slh_id,
         crl.object1_id1,
         crl.RULE_INFORMATION11
  FROM   OKC_RULE_GROUPS_B crg,
         OKC_RULES_B crl
  WHERE  crl.rgp_id = crg.id
  AND    crg.RGD_CODE = 'LAASTX'
  AND    crl.RULE_INFORMATION_CATEGORY = 'LAASTX'
  AND    crg.dnz_chr_id = p_chr_id
  AND    nvl(crg.cle_id,-1) = p_cleId;
  l_asset_tax_rule_rec l_asset_tax_rule_csr%ROWTYPE;

  CURSOR l_asset_csr IS
  SELECT cle.id,
         name
  FROM   okc_k_lines_v cle,
         okc_line_styles_b sty,
         okc_statuses_b sts
  WHERE  cle.lse_id = sty.id
  AND    cle.dnz_chr_id = p_chr_id
  AND    lty_code = 'FREE_FORM1'
  AND    cle.sts_code = sts.code
  AND    sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  --CURSOR l_fee_asset_csr(p_assetId OKC_K_LINES_B.ID%TYPE, p_fee_type OKL_K_LINES.FEE_TYPE%TYPE) IS
  CURSOR l_fee_asset_csr(p_assetId OKC_K_LINES_B.ID%TYPE) IS
  SELECT item.object1_id1,cleb.id,cleb.cle_id,
         clet_asset.name,
         kle.amount,
         kle.fee_type
  FROM   okc_k_lines_b fee_line,
         okc_k_lines_b cleb,
         okl_k_lines kle,
         okc_k_items item,
         okc_k_lines_tl clet_asset,
         okc_line_styles_b sty
  WHERE  fee_line.id = kle.id
  AND    kle.FEE_PURPOSE_CODE='SALESTAX'
  AND    cleb.lse_id = sty.id
  AND    sty.lty_code = 'LINK_FEE_ASSET'
  AND    item.cle_id = cleb.id
  AND    item.dnz_chr_id = p_chr_id
  AND    cleb.dnz_chr_id = p_chr_id
  AND    cleb.cle_id = fee_line.id
  AND    clet_asset.id = item.object1_id1
  AND    clet_asset.id = p_assetId
  AND    clet_asset.language =  USERENV('LANG');
  --AND    kle.fee_type = p_fee_type;
  --l_fee_asset_rec l_fee_asset_csr%ROWTYPE;

  CURSOR l_tax_amt_csr IS
  SELECT SUM(NVL(TOTAL_TAX,0))
  FROM   okl_tax_sources txs
              --,okl_tax_trx_details txl
  WHERE  txs.khr_id = p_chr_id
  --AND    txs.id = txl.txs_id
  AND    txs.tax_line_status_code = 'ACTIVE'
  AND    txs.tax_call_type_code = 'UPFRONT_TAX';
  l_tax_amount NUMBER;

  CURSOR l_tax_line_amt_csr(p_asset_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT SUM(NVL(TOTAL_TAX,0)) tax_amount  -- SUM added for 4740150 issue
  FROM   okl_tax_sources txs
         --,okl_tax_trx_details txl
  WHERE  txs.khr_id = p_chr_id
 -- AND    txs.id = txl.txs_id
  AND    txs.tax_line_status_code = 'ACTIVE'
  AND    txs.tax_call_type_code = 'UPFRONT_TAX'
  AND    txs.kle_id = p_asset_id;
  l_asset_tax_amount NUMBER;

  -- R12B Authoring OA Migration
  CURSOR st_fee_count_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT COUNT(cleb.id)
  FROM   okc_k_lines_b cleb,
         okl_k_lines kle,
         okc_line_styles_b sty,
         okc_statuses_b sts
  WHERE  cleb.lse_id = sty.id
  AND    sty.lty_code = 'FEE'
  AND    cleb.sts_code = sts.code
  AND    sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    kle.fee_purpose_code = 'SALESTAX'
  AND    cleb.dnz_chr_id = p_chr_id
  AND    cleb.chr_id = p_chr_id
  AND    kle.id = cleb.id;

  -- ER# 9327076 - Cursor to check line level setup for upfront tax
  CURSOR chk_line_upfront_tax (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
     SELECT '!'
     FROM   okc_rule_groups_b crg,
                 okc_rules_b crl
     WHERE  crl.rgp_id = crg.ID
       AND crg.rgd_code = 'LAASTX'
       AND crl.rule_information_category = 'LAASTX'
       AND crg.dnz_chr_id = p_chr_id
       AND crg.cle_id IS NOT NULL
	   AND crl.rule_information11 IN ('BILLED', 'CAPITALIZE', 'FINANCE');

  l_chk_rbk VARCHAR2(1) DEFAULT '?';
  l_chk_mass_rbk VARCHAR2(1) DEFAULT '?';
  l_chk_line_upfront_tax VARCHAR2(1) DEFAULT '?';

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   --OPEN l_hdr_csr;
   --FETCH l_hdr_csr INTO l_authoring_org_id;
   --CLOSE l_hdr_csr;

   --DBMS_APPLICATION_INFO.SET_CLIENT_INFO(l_authoring_org_id);

   l_upfront_tax_yn := 'N';
   OPEN l_tax_system_info;
   FETCH l_tax_system_info INTO l_upfront_tax_yn;
   CLOSE l_tax_system_info;

   -- ER# 9327076
   OPEN c_chk_rbk_csr(p_chr_id);
	    FETCH c_chk_rbk_csr INTO l_chk_rbk;
	CLOSE c_chk_rbk_csr;

    OPEN c_chk_mass_rbk_csr(p_chr_id);
	     FETCH c_chk_mass_rbk_csr INTO l_chk_mass_rbk;
	CLOSE c_chk_mass_rbk_csr;

   IF (nvl(l_upfront_tax_yn,'N') <> 'Y') THEN
      -- ER# 9327076
	  -- This check is only at time of booking - not at time of rebook or mass rebook
	  IF (l_chk_rbk <> '!' AND l_chk_mass_rbk <> '!') THEN
         --Get Header level Upfront Tax T and Cs
		 OPEN l_hdrrl_csr('LAHDTX','LASTPR', p_chr_id);
            FETCH l_hdrrl_csr INTO l_hdrrl_rec;
            l_exists := l_hdrrl_csr%FOUND;
         CLOSE l_hdrrl_csr;

		 -- Get Line Level Upfront Tax T and Cs
	     OPEN chk_line_upfront_tax(p_chr_id);
		   FETCH chk_line_upfront_tax INTO l_chk_line_upfront_tax;
		 CLOSE chk_line_upfront_tax;

		 -- Ensure that none of tax related T and Cs are populated at header and line level
		 IF (l_chk_line_upfront_tax='!' OR (l_exists AND (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL
		                                                              OR l_hdrrl_rec.RULE_INFORMATION2 IS NOT NULL
		                                                             OR l_hdrrl_rec.RULE_INFORMATION3 IS NOT NULL
																	 OR l_hdrrl_rec.RULE_INFORMATION4 IS NOT NULL))) THEN
             OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_UPFRONT_TAX_SYSOP_CHK'); -- Please remove the terms and conditions for upfront tax as upfront tax calculation has not been enabled.
             x_return_status := OKL_API.G_RET_STS_ERROR;
             RAISE G_EXCEPTION_HALT_VALIDATION;
		 END IF;
	  END IF;

      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      return;
   END IF;

   OPEN l_hdrrl_csr('LAHDTX','LASTPR', p_chr_id);
   FETCH l_hdrrl_csr INTO l_hdrrl_rec;
   l_exists := l_hdrrl_csr%FOUND;
   CLOSE l_hdrrl_csr;
   l_tax_header := l_hdrrl_rec.RULE_INFORMATION1;
   l_bill_strm_type := l_hdrrl_rec.RULE_INFORMATION2;

   -- Upfront tax related T and Cs to be checked only
   --   i. if present call if for contract being booked
   --  ii. In case of rebook or massrebook, this check should happen only if upfront tax had earlier been calculated
   IF ((l_chk_rbk <> '!' AND l_chk_mass_rbk <> '!')
         OR check_prior_upfront_tax(p_chr_id) )THEN -- ER# 9327076
   IF (l_tax_header IS NULL ) THEN
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_HEADER_TAX');
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_HEADER_TAX The Upfront Sales Tax at Contract header can not be null.');
     END IF;
   END IF;


   IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rule_info1'||l_hdrrl_rec.RULE_INFORMATION1);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rule_info2'||l_hdrrl_rec.RULE_INFORMATION2);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rule_info3'||l_hdrrl_rec.RULE_INFORMATION3);
     OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'rule_info4'||l_hdrrl_rec.RULE_INFORMATION4);
   END IF;

   --IF (NOT l_exists OR l_tax_treatment IS NULL) THEN
   IF (NOT l_exists ) THEN
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_MISSING');
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_MISSING');
     END IF;
   END IF;


   IF ( l_hdrrl_rec.RULE_INFORMATION2 IS NULL ) THEN
     OPEN fnd_csr('OKL_ASSET_UPFRONT_TAX','BILLED');
     FETCH fnd_csr INTO l_fnd_rec;
     l_fnd_meaning := l_fnd_rec.meaning;
     CLOSE fnd_csr;
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_STREAM_MISSING',
              p_token1       => 'UPFRONT_TAX',
              p_token1_value => l_fnd_meaning);
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_STREAM_MISSING '||'Please enter '
                             ||l_fnd_meaning ||' stream type on Taxes (Sales Tax Processing)'
                             ||' terms and condition for the contract.');
     END IF;
   END IF;
   IF ( l_hdrrl_rec.RULE_INFORMATION3 IS NULL ) THEN
     OPEN fnd_csr('OKL_ASSET_UPFRONT_TAX','FINANCE');
     FETCH fnd_csr INTO l_fnd_rec;
     l_fnd_meaning := l_fnd_rec.meaning;
     CLOSE fnd_csr;
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_STREAM_MISSING',
              p_token1       => 'UPFRONT_TAX',
              p_token1_value => l_fnd_meaning);
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_STREAM_MISSING '||'Please enter '
                             ||l_fnd_meaning ||' stream type on Taxes (Sales Tax Processing)'
                             ||' terms and condition for the contract.');
     END IF;
   END IF;
   IF ( l_hdrrl_rec.RULE_INFORMATION4 IS NULL ) THEN
     OPEN fnd_csr('OKL_ASSET_UPFRONT_TAX','CAPITALIZE');
     FETCH fnd_csr INTO l_fnd_rec;
     l_fnd_meaning := l_fnd_rec.meaning;
     CLOSE fnd_csr;
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_STREAM_MISSING',
              p_token1       => 'UPFRONT_TAX',
              p_token1_value => l_fnd_meaning);
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_STREAM_MISSING '||'Please enter '
                             ||l_fnd_meaning ||' stream type on Taxes (Sales Tax Processing)'
                             ||' terms and condition for the contract.');
     END IF;
   END IF;
   END IF; -- ER# 9327076

  IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  -- R12B Authoring OA Migration
  /*
  l_count := 0;
  l_fee_line_found := false;
  FOR l_st_fee_rec IN st_fee_csr(p_chr_id)
  LOOP
   l_count := l_count + 1;
   OPEN fnd_csr('OKL_FEE_TYPES',l_st_fee_rec.fee_type);
   FETCH fnd_csr INTO l_fnd_rec;
   l_fee_type_meaning := l_fnd_rec.meaning;
   CLOSE fnd_csr;

   IF ( l_st_fee_rec.fee_type = 'FINANCED' )
       OR ( l_st_fee_rec.fee_type = 'CAPITALIZED' ) THEN
       l_fee_line_found := TRUE;
   END IF;
   l_fee_amount := l_st_fee_rec.amount;

   IF ( l_st_fee_rec.amount = 0 ) THEN
     OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_FEE_ZERO',
              p_token1       => 'FEE_TYPE',
              p_token1_value => l_fee_type_meaning);
     x_return_status := OKL_API.G_RET_STS_ERROR;
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_FEE_ZERO '||'The sales tax fee line (type='
               ||l_fee_type_meaning||') amount can not be zero or negative.');
     END IF;
   END IF;

   IF ( l_st_fee_rec.fee_type = 'FINANCED')
      OR ( l_st_fee_rec.fee_type = 'CAPITALIZED') THEN
     l_amt_link_asset := 0;
     l_no_link_assets := 0;
     FOR l_st_fee_link_asset_rec IN st_fee_link_asset_csr(l_st_fee_rec.id)
     LOOP
       IF (l_st_fee_rec.fee_type = 'FINANCED') THEN
         l_amt_link_asset := l_amt_link_asset + l_st_fee_link_asset_rec.amount;
       ELSIF (l_st_fee_rec.fee_type = 'CAPITALIZED') THEN
         l_amt_link_asset := l_amt_link_asset + l_st_fee_link_asset_rec.capital_amount;
       END IF;
       l_no_link_assets := l_no_link_assets + 1;
     END LOOP; --l_st_fee_link_asset_rec
     IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,l_st_fee_rec.amount || ':' || l_amt_link_asset);
     END IF;
     IF (l_st_fee_rec.amount <> l_amt_link_asset) THEN
       OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_ST_FEE_ASSET_AMT',
                p_token1       => 'LINE_TYPE',
                p_token1_value => l_fee_type_meaning);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error: OKL_QA_ST_FEE_ASSET_AMT '||'The sales tax Fee line ('
          ||l_fee_type_meaning||') amount must be equal to the total amount on corresponding linked Fee asset(s).');
       END IF;
     END IF;
   END IF;
  END LOOP;
  */
  -- R12B Authoring OA Migration

  -- R12B Authoring OA Migration
  OPEN st_fee_count_csr(p_chr_id => p_chr_id);
  FETCH st_fee_count_csr INTO l_count;
  CLOSE st_fee_count_csr;

  --IF ( (l_tax_treatment IN ('FINANCE','CAPITALIZE') )  AND l_count > 1 ) THEN
  IF ( l_count > 1 ) THEN
    OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_FEE_GT1');
    x_return_status := OKL_API.G_RET_STS_ERROR;
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_FEE_GT1 ' || 'The contract can not have more than one Sales Tax Fee line defined.');
    END IF;
  END IF;


  --raise exception as we want to halt validation at this.
  IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  l_line_asset_upfront_tax := 'XXX';
  l_prev_line_asset_upfront_tax := 'XXX';
  l_found_asset_not_billed := false;
  FOR l_asset_rec IN l_asset_csr
  LOOP
    OPEN l_asset_tax_rule_csr(l_asset_rec.Id);
    FETCH l_asset_tax_rule_csr INTO l_asset_tax_rule_rec;
    CLOSE l_asset_tax_rule_csr;
    IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_asset_rec.id: '||l_asset_rec.id || ' ' || l_asset_rec.name);
    END IF;
    l_line_asset_upfront_tax := nvl(l_asset_tax_rule_rec.RULE_INFORMATION11,'XXX');

    IF (l_line_asset_upfront_tax <> 'BILLED' AND l_line_asset_upfront_tax <> 'XXX') THEN
      l_found_asset_not_billed := TRUE;
    END IF;

    --raise error capitalized and finance mix not allowed. For sales tax purposes all non billed asset
    --lines should be either capitalized or financed throughout.
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_line_asset_upfront_tax:'||l_line_asset_upfront_tax);
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_prev_line_asset_upfront_tax:'||l_prev_line_asset_upfront_tax);
      END IF;
    IF (l_line_asset_upfront_tax IN ('FINANCE','CAPITALIZE')
         AND l_line_asset_upfront_tax <> l_prev_line_asset_upfront_tax) THEN
      IF (l_prev_line_asset_upfront_tax <> 'XXX') THEN
        OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_ST_ALL_CAP_OR_FIN');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                  OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_ALL_CAP_OR_FIN All asset lines must have sales upfront tax as either Financed or Capitalized.');
        END IF;
        EXIT;
        --RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      l_prev_line_asset_upfront_tax := l_line_asset_upfront_tax;
    END IF;

    IF ((l_line_asset_upfront_tax <> l_tax_header)
           AND l_line_asset_upfront_tax IN ('FINANCE','CAPITALIZE')
           AND l_tax_header IN ('FINANCE','CAPITALIZE')) THEN
      --raise error capitalized and financed mix not allowed.
      OPEN fnd_csr('OKL_ASSET_UPFRONT_TAX',l_tax_header);
      FETCH fnd_csr INTO l_hdr_fnd_rec;
      l_hdr_fnd_meaning := l_hdr_fnd_rec.meaning;
      CLOSE fnd_csr;
      OPEN fnd_csr('OKL_ASSET_UPFRONT_TAX',l_line_asset_upfront_tax);
      FETCH fnd_csr INTO l_line_fnd_rec;
      l_line_fnd_meaning := l_line_fnd_rec.meaning;
      CLOSE fnd_csr;
      OKL_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_ST_CAP_FIN_MIX',
            p_token1       => 'UPFRONT_TAX',
            p_token1_value => l_hdr_fnd_meaning,
            p_token2       => 'UPFRONT_LN_TAX',
            p_token2_value => l_line_fnd_meaning,
            p_token3       => 'ASSET_NUMBER',
            p_token3_value => l_asset_rec.name);
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_CAP_FIN_MIX The upfront tax for the asset line ' ||
                         l_asset_rec.name||' is different from asset upfront tax at Contract header.' );
      END IF;
      null;
    END IF;

    -- R12B Authoring OA Migration
    /*
    IF (l_line_asset_upfront_tax = 'FINANCE') THEN
      l_st_fee_code := 'FINANCED';
    END IF;
    IF (l_line_asset_upfront_tax = 'CAPITALIZE') THEN
      l_st_fee_code := 'CAPITALIZED';
    END IF;

    --debug_message('l_bill_asset_overide: '||l_bill_asset_overide);
    l_linked_asset_exists := FALSE;
    FOR l_fee_asset_rec IN l_fee_asset_csr(l_asset_rec.id)
    LOOP

      OPEN fnd_csr('OKL_FEE_TYPES',l_fee_asset_rec.fee_type);
      FETCH fnd_csr INTO l_fnd_rec;
      l_fee_type_meaning := l_fnd_rec.meaning;
      CLOSE fnd_csr;

      IF (l_line_asset_upfront_tax IN ('FINANCE', 'CAPITALIZE')) THEN
        l_linked_asset_exists := TRUE;
      END IF;

      --IF (l_line_asset_upfront_tax = 'BILLED' AND l_linked_asset_exists) THEN
      IF (l_line_asset_upfront_tax = 'BILLED' ) THEN
         OPEN fnd_csr('OKL_FEE_TYPES','BILLED');
         FETCH fnd_csr INTO l_fnd_rec;
         CLOSE fnd_csr;
         l_tax_fee_meaning := l_fnd_rec.meaning;
        OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_FEE_ASSET_ERROR',
              p_token1       => 'FEE_TYPE',
              p_token1_value => l_tax_fee_meaning,
              p_token2       => 'ASSET_NUMBER',
              p_token2_value => l_asset_rec.name);
         x_return_status := OKL_API.G_RET_STS_ERROR;
         IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
                    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error:  '||'OKL_QA_ST_FEE_ASSET_ERROR '||'The "Bill Upfront Tax" is selected for the asset = '
             ||l_asset_rec.name||'. Please remove this asset association from Sales Tax Fee line ('||l_tax_fee_meaning||').');
         END IF;
         null;
       END IF;
    END LOOP;

    --raise exception as we want to halt validation at this.
    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF ( (l_line_asset_upfront_tax IN ('FINANCE','CAPITALIZE') ) AND (NOT l_linked_asset_exists ) AND l_fee_line_found)THEN
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Here00001' ||l_line_asset_upfront_tax );
      END IF;
      OPEN fnd_csr('OKL_FEE_TYPES',l_st_fee_code);
      FETCH fnd_csr INTO l_fnd_rec;
      CLOSE fnd_csr;
      l_tax_fee_meaning := l_fnd_rec.meaning;
      OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_ST_FEE_ASSET_MISSING',
                p_token1       => 'ASSET_NUMBER',
                p_token1_value => l_asset_rec.name,
                p_token2       => 'LINE_TYPE',
                p_token2_value => l_tax_fee_meaning );
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error: OKL_QA_ST_FEE_ASSET_MISSING '||'The sales tax Fee line ('
            ||l_tax_fee_meaning ||') does not have corresponding linked asset('||l_asset_rec.name||') defined.');
      END IF;
    END IF;
    */
    -- R12B Authoring OA Migration

  END LOOP;

  -- R12B Authoring OA Migration
  /*
  --Bug#4693357 ramurt
  l_tax_amount := 0;
  OPEN l_tax_amt_csr;
  FETCH l_tax_amt_csr INTO l_tax_amount;
  CLOSE l_tax_amt_csr;

  IF ( (l_tax_amount <> 0) AND NOT l_fee_line_found AND l_found_asset_not_billed) THEN
      OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_ST_NO_FEE');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (G_IS_DEBUG_STATEMENT_ON = TRUE) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Error: OKL_QA_ST_NO_FEE '||'The sales tax Fee line must be present for the Contract');
      END IF;
  END IF;

  --Bug#4699379 ramurt
  -- getting the total tax engine calculated sales upfront tax amount by summing calculated amounts
  -- for each asset.
  l_tax_amount := 0;
  l_asset_tax_amount := 0;
  FOR l_asset_rec IN l_asset_csr
  LOOP
    OPEN l_asset_tax_rule_csr(l_asset_rec.Id);
    FETCH l_asset_tax_rule_csr INTO l_asset_tax_rule_rec;
    CLOSE l_asset_tax_rule_csr;
    l_line_asset_upfront_tax := nvl(l_asset_tax_rule_rec.RULE_INFORMATION11,'XXX');

    IF (l_line_asset_upfront_tax IN ('FINANCE','CAPITALIZE')) THEN
      OPEN  l_tax_line_amt_csr(l_asset_rec.id);
      FETCH l_tax_line_amt_csr INTO l_asset_tax_amount;
      l_tax_amount := l_tax_amount + l_asset_tax_amount;
      CLOSE l_tax_line_amt_csr;
    END IF;
  END LOOP;

  OPEN fnd_csr('OKL_FEE_TYPES',l_st_fee_code);
  FETCH fnd_csr INTO l_fnd_rec;
  CLOSE fnd_csr;
  l_tax_fee_meaning := l_fnd_rec.meaning;

  IF (l_tax_amount <> l_fee_amount) THEN
    OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_FEE_AMT',
              p_token1       => 'FEE_TYPE',
              p_token1_value => l_tax_fee_meaning,
              p_token2       => 'UPFRONT_TAX',
              p_token2_value => l_tax_fee_meaning);
    x_return_status := OKL_API.G_RET_STS_ERROR;
  END IF;
  */
  -- R12B Authoring OA Migration

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF st_fee_csr%ISOPEN THEN
      CLOSE st_fee_csr;
    END IF;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;
    IF l_rl_csr1%ISOPEN THEN
      CLOSE l_rl_csr1;
    END IF;
    IF l_asset_tax_rule_csr%ISOPEN THEN
      CLOSE l_asset_tax_rule_csr;
    END IF;
    IF fnd_csr%ISOPEN THEN
      CLOSE fnd_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_fee_asset_csr%ISOPEN THEN
      CLOSE l_fee_asset_csr;
    END IF;
    IF l_asset_csr%ISOPEN THEN
      CLOSE l_asset_csr;
    END IF;
    IF st_fee_link_asset_csr%ISOPEN THEN
      CLOSE st_fee_link_asset_csr;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
    IF l_tax_amt_csr%ISOPEN THEN
      CLOSE l_tax_amt_csr;
    END IF;
    IF l_tax_line_amt_csr%ISOPEN THEN
      CLOSE l_tax_line_amt_csr;
    END IF;
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    IF st_fee_csr%ISOPEN THEN
      CLOSE st_fee_csr;
    END IF;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;
    IF l_rl_csr1%ISOPEN THEN
      CLOSE l_rl_csr1;
    END IF;
    IF l_asset_tax_rule_csr%ISOPEN THEN
      CLOSE l_asset_tax_rule_csr;
    END IF;
    IF fnd_csr%ISOPEN THEN
      CLOSE fnd_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_fee_asset_csr%ISOPEN THEN
      CLOSE l_fee_asset_csr;
    END IF;
    IF l_asset_csr%ISOPEN THEN
      CLOSE l_asset_csr;
    END IF;
    IF st_fee_link_asset_csr%ISOPEN THEN
      CLOSE st_fee_link_asset_csr;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
    IF l_tax_amt_csr%ISOPEN THEN
      CLOSE l_tax_amt_csr;
    END IF;
    IF l_tax_line_amt_csr%ISOPEN THEN
      CLOSE l_tax_line_amt_csr;
    END IF;

END check_sales_tax;

-- Start of comments
--
-- Procedure Name  : check_sales_tax_asset_rules
-- Description     : Page level Validation for sales tax
--                   terms and conditions at asset level
--                   This is called by process_line_rule_group_rules
--                   in okl_rgrp_rules_process_pvt
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0, ramurt Created. Bug#4658944
-- End of comments
PROCEDURE check_sales_tax_asset_rules(
                     p_api_version       IN NUMBER,
                     p_init_msg_list     IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                     x_return_status     OUT NOCOPY VARCHAR2,
                     x_msg_count         OUT NOCOPY NUMBER,
                     x_msg_data          OUT NOCOPY VARCHAR2,
                     p_chr_id            IN NUMBER,
                     p_line_id           IN NUMBER,
                     p_rule_group_id     IN NUMBER,
                     p_rgr_rec           IN rgr_rec_type) IS

  l_exists boolean;
  l_mix_fin_cap VARCHAR2(1);

  -- Bug# 6512668: Exclude asset lines in Abandoned status
  CURSOR l_upfront_tax_other_assets(p_line_upfront_tax OKC_RULES_B.RULE_INFORMATION11%TYPE) IS
  SELECT 'Y'
  FROM   okc_rule_groups_b rgp,
         okc_rules_b rule,
         okc_k_lines_b cle
  WHERE  rule.rgp_id = rgp.id
  AND    rgd_code = 'LAASTX'
  AND    rule_information_category = 'LAASTX'
  AND    rgp.dnz_chr_id = p_chr_id
  AND    nvl(rgp.cle_id,-1) <>  p_line_id
  AND    nvl(RULE_INFORMATION11,'XXX') NOT IN (p_line_upfront_tax,'BILLED','XXX')
  AND    cle.id = rgp.cle_id
  AND    cle.sts_code <> 'ABANDONED';

BEGIN
   x_return_status := OKL_API.G_RET_STS_SUCCESS;

   l_upfront_tax_yn := 'N';
   OPEN l_tax_system_info;
   FETCH l_tax_system_info INTO l_upfront_tax_yn;
   CLOSE l_tax_system_info;

   IF (nvl(l_upfront_tax_yn,'N') <> 'Y') THEN
     x_return_status := OKL_API.G_RET_STS_SUCCESS;
     return;
   END IF;

   --Murthy
   l_exists := false;
   IF (p_rgr_rec.RULE_INFORMATION11 = 'CAPITALIZE') THEN
     OPEN l_upfront_tax_other_assets('CAPITALIZE');
     FETCH l_upfront_tax_other_assets INTO l_mix_fin_cap;
     l_exists := l_upfront_tax_other_assets%FOUND;
     CLOSE l_upfront_tax_other_assets;
   ELSIF (p_rgr_rec.RULE_INFORMATION11 = 'FINANCE') THEN
     OPEN l_upfront_tax_other_assets('FINANCE');
     FETCH l_upfront_tax_other_assets INTO l_mix_fin_cap;
     l_exists := l_upfront_tax_other_assets%FOUND;
     CLOSE l_upfront_tax_other_assets;
   END IF;
   IF (l_exists) THEN
       OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_ST_ALL_CAP_OR_FIN');
       x_return_status := OKL_API.G_RET_STS_ERROR;
   END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_upfront_tax_other_assets%ISOPEN THEN
      CLOSE l_upfront_tax_other_assets;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
  WHEN OTHERS THEN
    IF l_upfront_tax_other_assets%ISOPEN THEN
      CLOSE l_upfront_tax_other_assets;
    END IF;
    IF l_tax_system_info%ISOPEN THEN
      CLOSE l_tax_system_info;
    END IF;
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END check_sales_tax_asset_rules;

-----------------------------------------------------------------------------
 -- PROCEDURE validate_upfront_tax_fee
 -----------------------------------------------------------------------------
 -- Start of comments
 --
 -- Procedure Name  : validate_upfront_tax_fee
 -- Description     : Procedure will be called to validate upfront tax fee and
 --                   payments during online and batch contract activation.
 -- Business Rules  :
 -- Parameters      : p_chr_id
 -- Version         : 1.0
 -- History         : 24-Apr-2007 rpillay Created
 -- End of comments

  PROCEDURE validate_upfront_tax_fee(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2) IS

    l_api_name	CONSTANT VARCHAR2(30) := 'VALIDATE_UPFRONT_TAX_FEE';
    l_api_version	CONSTANT NUMBER	      := 1.0;

    /* Cursor to get the top fee line for Sales Tax financed fee of a given contract. */
    CURSOR l_fn_top_fee_ln_csr (p_chr_id IN OKC_K_HEADERS_B.ID%TYPE) IS
    SELECT kle.id,
           kle.amount,
           clev.name,
           lsev.name line_type
    FROM okc_k_lines_v clev,
         okl_k_lines kle,
         okc_statuses_b okcsts,
         okc_line_styles_v lsev
    WHERE clev.dnz_chr_id = p_chr_id
    AND clev.chr_id = p_chr_id
    AND kle.id = clev.id
    AND kle.fee_type = 'FINANCED'
    AND kle.fee_purpose_code = 'SALESTAX'
    AND lsev.id = clev.lse_id
    AND okcsts.code = clev.sts_code
    AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED');

    /* Cursor to get the financed fee sub-lines (applied to assets) for a
       given contract. */
    CURSOR l_fn_sub_ln_fee_csr ( p_chr_id IN OKC_K_HEADERS_B.ID%TYPE,
                                 p_fee_line_id IN OKL_K_LINES.ID%TYPE) IS
    SELECT kle.id,
           kle.amount,
           cleb.end_date,
           cleb.start_date
    FROM okc_k_lines_b cleb,
         okl_k_lines kle,
         okc_statuses_b okcsts
    WHERE cleb.dnz_chr_id = p_chr_id
    AND kle.id = cleb.id
    AND cleb.cle_id = p_fee_line_id
    AND okcsts.code = cleb.sts_code
    AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','ABANDONED');

    /* Cursor to get the financed fee top/sub-line payments for a
       given contract. */
    CURSOR l_fn_fee_pmt_csr (p_chr_id IN OKC_K_HEADERS_B.ID%TYPE,
                             p_fee_line_id IN OKL_K_LINES.ID%TYPE) IS
    SELECT Fnd_Date.canonical_to_date(sll.rule_information2) start_date,
           SLL.rule_information3 periods,
           DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
           TRUNC(ADD_MONTHS(Fnd_Date.canonical_to_date(sll.rule_information2),
           TO_NUMBER(sll.rule_information3)*DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)) - 1) end_date,
           styt.name stream_type
    FROM   okc_rules_b sll,
           okc_rules_b slh,
           okc_rule_groups_b rgp,
           okl_strm_type_b sty,
           okl_strm_type_tl styt
    WHERE  rgp.dnz_chr_id              = p_chr_id
    AND  rgp.cle_id                    = p_fee_line_id
    AND  rgp.rgd_code                  = 'LALEVL'
    AND  rgp.id                        = slh.rgp_id
    AND  slh.rule_information_category = 'LASLH'
    AND  slh.object1_id1               = TO_CHAR(sty.id)
    AND  styt.language                 = USERENV('LANG')
    AND  sty.id                        = styt.id
    AND  TO_CHAR(slh.id)               = sll.object2_id1
    AND  sll.rule_information_category = 'LASLL';

    /* Cursor to get the financed fee top/sub-line payments HEADER for a
       given contract. */
    CURSOR l_fn_fee_pmtH_csr (p_chr_id IN OKC_K_HEADERS_B.ID%TYPE,
                              p_fee_line_id IN OKL_K_LINES.ID%TYPE) IS

    SELECT slh.id
    FROM   okc_rules_b slh,
           okc_rule_groups_b rgp,
           okl_strm_type_b sty,
           okl_strm_type_tl styt
    WHERE  rgp.dnz_chr_id              = p_chr_id
    AND  rgp.cle_id                    = p_fee_line_id
    AND  rgp.rgd_code                  = 'LALEVL'
    AND  rgp.id                        = slh.rgp_id
    AND  slh.rule_information_category = 'LASLH'
    AND  slh.object1_id1               = TO_CHAR(sty.id)
    AND  styt.language                 = USERENV('LANG')
    AND  sty.id                        = styt.id;

    CURSOR l_strm_slh_csr (p_khr_id OKC_K_HEADERS_B.ID%TYPE,
                           p_kle_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT styt.name stream_type,
           rule.id rule_id,
           rgp.id rgp_id
    FROM   okc_rules_b rule,
           okc_rule_groups_b rgp,
           okl_strm_type_b sty,
           okl_strm_type_tl styt
    WHERE  NVL(rgp.cle_id, -1)            = p_kle_id
    AND    rgp.dnz_chr_id                 = p_khr_id
    AND    rgp.rgd_code                   = 'LALEVL'
    AND    rgp.id                         = rule.rgp_id
    AND    rule.rule_information_category = 'LASLH'
    AND    TO_NUMBER(rule.object1_id1)    = sty.id
    AND    styt.LANGUAGE                  = USERENV('LANG')
    AND    sty.id                         = styt.id;

    CURSOR l_strm_sll_csr (p_rule_id OKC_RULES_B.ID%TYPE,
                           p_rgp_id  OKC_RULE_GROUPS_B.ID%TYPE) IS
    SELECT Fnd_Date.canonical_to_date(sll.rule_information2) start_date,
           sll.rule_information1 seq,
           sll.rule_information6 amt,
           sll.rule_information7 stub_day,
           sll.rule_information13 rate
    FROM   okc_rules_b sll
    WHERE  sll.rgp_id                    = p_rgp_id
    AND    sll.object2_id1               = TO_CHAR(p_rule_id)
    AND    sll.rule_information_category = 'LASLL'
    ORDER BY 1,2;

    l_prev_pmnt NUMBER;


    x_err_msg VARCHAR2(1000);

    l_fn_sub_ln_fee_cnt   NUMBER := 0;
    l_payment_top_ln_cnt  NUMBER := 0; -- Counter for financed payments top lines
    l_payment_sub_ln_cnt  NUMBER := 0; -- Counter for financed payments sub-lines
    l_fn_top_ln_fee_amt   NUMBER := 0; -- Financed top line total fee amount.
    l_fn_sub_ln_fee_amt   NUMBER := 0; -- Financed sum of sub-line fee amount.
    l_top_ln_pmt_exist    BOOLEAN := FALSE;
    l_fn_sln_fee_amt_chk  BOOLEAN := FALSE; -- If there are sub-lines payments exists.

    l_fn_top_fee_ln_rec   l_fn_top_fee_ln_csr%ROWTYPE;
    l_fn_fee_pmtH_rec     l_fn_fee_pmtH_csr%ROWTYPE;

    --Bug# 6609598
    l_tot_pmnt NUMBER;

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

    OPEN l_fn_top_fee_ln_csr(p_chr_id => p_chr_id);
    FETCH l_fn_top_fee_ln_csr INTO l_fn_top_fee_ln_rec;
    CLOSE l_fn_top_fee_ln_csr;

    -- If Sales tax Financed Fee exists
    IF (l_fn_top_fee_ln_rec.id IS NOT NULL) THEN

      /* Check Payments for the top fee line if they exist. */
      --Bug# 6609598
      /* FEE line should have only 1 payment defined. */
      l_tot_pmnt := 0;
      FOR l_fn_fee_pmtH_rec IN  l_fn_fee_pmtH_csr(p_chr_id      => p_chr_id,
                                                   p_fee_line_id => l_fn_top_fee_ln_rec.id)
      LOOP
        l_tot_pmnt := l_tot_pmnt + 1;
        l_top_ln_pmt_exist := TRUE;
      END LOOP;

      IF ( l_tot_pmnt > 1 ) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
	  OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_ONLY_1PAY',
                  p_token1       => 'line',
                  p_token1_value => l_fn_top_fee_ln_rec.name
                 );
      END IF;

      /* Check payments for financed fee sub-line, if it exist both for top
         line and sub-line error out. If payment end date is past fee line end date error out. */

      FOR l_fn_sub_ln_fee_rec IN l_fn_sub_ln_fee_csr (p_chr_id => p_chr_id,
                                                      p_fee_line_id => l_fn_top_fee_ln_rec.id)
      LOOP

        l_fn_sub_ln_fee_cnt := l_fn_sub_ln_fee_cnt + 1;

        /* Store the sum of financed fee sub-line amount. */
        l_fn_sub_ln_fee_amt := l_fn_sub_ln_fee_amt + l_fn_sub_ln_fee_rec.amount;

        /* Sub-line fees exists. */
        l_fn_sln_fee_amt_chk := TRUE;

        /* Check Payments for the financed fee sub-line if they exist. */

	  FOR l_fn_fee_pmtH IN l_fn_fee_pmtH_csr (p_chr_id => p_chr_id,
                                                p_fee_line_id => l_fn_sub_ln_fee_rec.id )
	  LOOP
	    IF (l_top_ln_pmt_exist) THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;
	      OKL_API.set_message(
	        p_app_name     => G_APP_NAME,
	  	  p_msg_name     => 'OKL_QA_FN_PMTS_TOP_SUB_EXIST',
	        p_token1       => 'FEE_LINE',
	        p_token1_value => l_fn_top_fee_ln_rec.name);
	    END IF;

	    l_payment_sub_ln_cnt := l_payment_sub_ln_cnt + 1;

	  END LOOP;

	  FOR l_fn_fee_pmt_rec IN l_fn_fee_pmt_csr (p_chr_id => p_chr_id,
                                                  p_fee_line_id => l_fn_sub_ln_fee_rec.id)
	  LOOP
	    /* Check if the payment end date is within in the financed
	       fee sub-line's end date, if not error out. */

          IF ( TRUNC(l_fn_fee_pmt_rec.start_date) < TRUNC(l_fn_sub_ln_fee_rec.start_date) ) THEN

            x_return_status := Okl_Api.G_RET_STS_ERROR;
	      OKL_API.set_message(
	        p_app_name     => G_APP_NAME,
	        p_msg_name     => 'OKL_QA_FN_SLN_PMT_SD',
	        p_token1       => 'FEE_LINE',
	        p_token1_value => l_fn_top_fee_ln_rec.name);
	    END IF;

          IF ( TRUNC(l_fn_fee_pmt_rec.end_date) > TRUNC(l_fn_sub_ln_fee_rec.end_date) ) THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;
	      OKL_API.set_message(
	        p_app_name     => G_APP_NAME,
	  	  p_msg_name     => 'OKL_QA_FN_SLN_PMT_ED',
	        p_token1       => 'FEE_LINE',
	        p_token1_value => l_fn_top_fee_ln_rec.name);
	    END IF;

	  END LOOP;
      END LOOP;

      /* Check if a financed top line fee amount is not equal to sub-line fee amount,
         if exists, if not error out. */

      IF ( (l_fn_sln_fee_amt_chk) AND (l_fn_top_fee_ln_rec.amount <> l_fn_sub_ln_fee_amt)) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
	  OKL_API.set_message(
	    p_app_name     => G_APP_NAME,
	    p_msg_name     => 'OKL_QA_FN_FEE_AMT_NEQ',
	    p_token1       => 'FEE_LINE',
	    p_token1_value => l_fn_top_fee_ln_rec.name);
      END IF;

      /* If no payments are defiend for the fee line then error out. */

      IF ((NOT l_top_ln_pmt_exist) AND (NOT l_fn_sln_fee_amt_chk)) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
	  OKL_API.set_message(
	    p_app_name     => G_APP_NAME,
	    p_msg_name     => 'OKL_QA_RQ_NO_PMTS',
	    p_token1       => 'FEE_LINE',
	    p_token1_value => l_fn_top_fee_ln_rec.name);
      END IF;

      /* Check if a payment is defined for EACH of the financed fee sub-lines HEADER,
         if not error out. If there are multiple payments defiend for a financed
         fee sub-line HEADER error out. */

      IF ((NOT l_top_ln_pmt_exist) AND (l_fn_sub_ln_fee_cnt > l_payment_sub_ln_cnt)) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        OKL_API.set_message(
	    p_app_name     => G_APP_NAME,
	    p_msg_name     => 'OKL_QA_FN_PMTS_MISS_SLN',
	    p_token1       => 'FEE_LINE',
	    p_token1_value => l_fn_top_fee_ln_rec.name);
      ELSIF ((NOT l_top_ln_pmt_exist) AND (l_fn_sub_ln_fee_cnt <  l_payment_sub_ln_cnt)) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
	  OKL_API.set_message(
	    p_app_name     => G_APP_NAME,
	    p_msg_name     => 'OKL_QA_FN_MUL_SLN_PMTS',
	    p_token1       => 'FEE_LINE',
	    p_token1_value => l_fn_top_fee_ln_rec.name);
      END IF;


      FOR l_strm_slh_rec IN l_strm_slh_csr (p_chr_id,
                                            l_fn_top_fee_ln_rec.id)
      LOOP
        l_prev_pmnt := NULL;
        FOR l_strm_sll_rec IN l_strm_sll_csr (l_strm_slh_rec.rule_id,
                                              l_strm_slh_rec.rgp_id)
        LOOP
          IF (l_strm_sll_rec.stub_day IS NOT NULL) THEN -- do not check
            l_prev_pmnt := NULL; -- reset
          ELSE
            -- Check payment amount here
            IF (l_prev_pmnt = TO_NUMBER(NVL(l_strm_sll_rec.amt,'0'))) THEN
              -- Error
              Okl_Api.set_message(
                G_APP_NAME,
                'OKL_QA_INVALID_PMNT',
                'LINE_TYPE',
                l_fn_top_fee_ln_rec.line_type,
                'PMNT_TYPE',
                l_strm_slh_rec.stream_type
              );
              x_return_status := Okl_Api.G_RET_STS_ERROR;
            ELSE
              l_prev_pmnt := TO_NUMBER(NVL(l_strm_sll_rec.amt,'0'));
            END IF; --check

          END IF; --stub
        END LOOP; --l_strm_sll_csr
      END LOOP; --l_strm_slh_csr

    END IF;

    OKL_API.END_ACTIVITY(x_msg_count => x_msg_count, x_msg_data  => x_msg_data);

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

     WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

     WHEN OTHERS THEN
        x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                        p_api_name  => l_api_name,
                        p_pkg_name  => g_pkg_name,
                        p_exc_name  => 'OTHERS',
                        x_msg_count => x_msg_count,
                        x_msg_data  => x_msg_data,
                        p_api_type  => g_api_type);

 END validate_upfront_tax_fee;

END OKL_LA_SALES_TAX_PVT;

/
