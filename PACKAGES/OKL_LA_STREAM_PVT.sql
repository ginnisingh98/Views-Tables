--------------------------------------------------------
--  DDL for Package OKL_LA_STREAM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_LA_STREAM_PVT" AUTHID CURRENT_USER as
/* $Header: OKLRSGAS.pls 120.13.12010000.8 2009/08/14 07:59:02 nikshah ship $ */
-- Global variables
  G_PKG_NAME   CONSTANT VARCHAR2(200) := 'OKL_LA_STREAM_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;

  -- Store the yields types
  TYPE yields_type IS RECORD (
    pre_Tax_yield           okl_k_headers.pre_tax_yield%type,
    after_tax_yield         okl_k_headers.after_tax_yield%type,
    pre_tax_irr             okl_k_headers.pre_tax_irr%type,
    after_tax_irr           okl_k_headers.after_tax_irr%type,
    implicit_interest_rate  okl_k_headers.implicit_interest_rate%type,
    sub_pre_Tax_yield       okl_k_headers.sub_pre_tax_yield%type,
    sub_after_tax_yield     okl_k_headers.sub_after_tax_yield%type,
    sub_pre_tax_irr         okl_k_headers.sub_pre_tax_irr%TYPE,
    sub_after_tax_irr       okl_k_headers.sub_after_tax_irr%type,
    sub_impl_interest_rate  okl_k_headers.sub_impl_interest_rate%type);
  SUBTYPE yields_rec_type IS yields_type;

  TYPE strm_rec IS RECORD (
    id                             OKL_STRM_TYPE_B.ID%TYPE ,
    pricing_name                   OKL_ST_GEN_TMPT_LNS.PRICING_NAME%TYPE);
  SUBTYPE strm_rec_type IS strm_rec;
  TYPE okl_strm_type_id_tbl_type IS TABLE OF strm_rec
  INDEX BY BINARY_INTEGER;


  CURSOR l_hdr_pdt_csr(chrId  NUMBER)
  IS
  SELECT chr.orig_system_source_code,
         chr.start_date,
         chr.end_date,
         chr.template_yn,
         chr.authoring_org_id,
         khr.expected_delivery_date,
         chr.inv_organization_id,
         khr.deal_type,
         pdt.id  pid,
         NVL(pdt.reporting_pdt_id, -1) report_pdt_id,
         chr.currency_code currency_code,
         khr.term_duration term
  FROM okc_k_headers_v chr,
       okl_k_headers khr,
       okl_products_v pdt
  WHERE khr.id = chr.id
  AND chr.id = chrId
  AND khr.pdt_id = pdt.id(+);



  -- Get the stream type id
  CURSOR l_strmid_csr (strmName VARCHAR2)
  IS
  SELECT id styid
  FROM okl_strm_type_tl
  WHERE LANGUAGE = 'US'
  AND NAME = strmName;
  -- get the prorate convention code
  CURSOR l_adrconv_csr (bkCode VARCHAR2,
                        assNo  VARCHAR2)
  IS
  SELECT fa.prorate_convention_code
  FROM fa_books fa,
       okx_asset_lines_v xle
  WHERE fa.transaction_header_id_out IS NULL
  AND fa.book_type_code = bkCode
  AND fa.asset_id = xle.asset_id
  AND xle.asset_number = assNo;
  -- get the setup values for tax book and coporate book
  CURSOR l_txtrans_csr (Book  Varchar2)
  IS
  SELECT trns.value,
         books.book_type_code
  FROM okl_sgn_translations trns,
       fa_book_controls books
  WHERE trns.jtot_object1_code = 'FA_BOOK_CONTROLS'
  AND trns.object1_id1 = books.book_type_code
  AND books.book_type_code = Book
  AND trns.sgn_code = 'STMP';
  -- Get the transaction types
  CURSOR Transaction_Type_csr (p_transaction_type IN okl_trx_types_v.name%TYPE)
  IS
  SELECT id trx_try_id
  FROM okl_trx_types_tl
  WHERE NAME = p_transaction_type
  AND LANGUAGE = 'US';
  -- get the transaction contract information
  CURSOR trx_csr(khrId NUMBER,
                 tcntype VARCHAR2,
                 status VARCHAR2)
  IS
  SELECT txh.ID headertransid
  FROM okl_trx_contracts txh
  WHERE txh.tcn_type = tcntype
  AND txh.khr_id = khrId
  --rkuttiya added for 12.1.1  Multi GAAP
  AND txh.representation_type = 'PRIMARY'
  --
  AND txh.tsu_code = status;
  -- get the txl transaction information
  CURSOR l_tx_csr(ass VARCHAR2)
  IS
  SELECT txl.life_in_months,
         txl.corporate_book,
         txl.deprn_method,
         txl.in_service_date,
         txl.salvage_value,
         txl.percent_salvage_value,
         txl.depreciation_cost,
         mth.id1,
         ct.prorate_convention_code
  FROM okl_txl_assets_b txl,
       okx_asst_dep_methods_v mth,
       okx_ast_ct_bk_dfs_v ct
  WHERE mth.method_code = txl.deprn_method
  AND mth.life_in_months = txl.life_in_months
  AND ct.category_id = txl.depreciation_id
  AND ct.book_type_code = txl.corporate_book
  AND txl.asset_number = ass
-- Start of Bug#3388812 Modification - BAKUCHIB
  AND txl.in_service_date BETWEEN ct.start_dpis AND NVL(ct.end_dpis,txl.in_service_date);
-- End of Bug#3388812  Modification - BAKUCHIB
  -- get the txd transaction information
  CURSOR l_txd_csr(ass VARCHAR2)
  IS
  SELECT txd.cost,
         txd.deprn_method_tax,
         txd.life_in_months_tax,
         txd.salvage_value,
         txd.tax_book,
         mth.id1
  FROM okl_txd_assets_v txd,
       okx_asst_dep_methods_v mth
  WHERE mth.method_code = txd.deprn_method_tax
  AND mth.life_in_months = txd.life_in_months_tax
  AND txd.asset_number = ass;
  -- get the stream id
  CURSOR l_strm_id_csr(khrid NUMBER)
  IS
  SELECT lsm.id
  FROM okl_streams lsm
  WHERE lsm.khr_id = khrid;
  -- get the Header rule information
  CURSOR l_hdrrl_csr(rgcode okc_rule_groups_b.rgd_code%TYPE,
                     rlcat  okc_rules_b.rule_information_category%TYPE,
                     chrId NUMBER)
  IS
  SELECT crl.object1_id1,
         crl.rule_information1,
         crl.rule_information2,
         crl.rule_information3,
         crl.rule_information4,
         crl.rule_information5,
         crl.rule_information6,
         crl.rule_information10,
         crl.rule_information13,
         crl.rule_information11
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId;
  -- get the self referencing Line based rule information
  CURSOR l_rl_csr(rlgpId NUMBER,
                  rgcode okc_rule_groups_b.rgd_code%TYPE,
                  rlcat  okc_rules_b.rule_information_category%TYPE,
                  chrId  NUMBER,
                  cleId  NUMBER )
  IS
  SELECT crl.object1_id1,
         crl.rule_information1,
         crl.rule_information2,
         crl.rule_information3,
         crl.rule_information5,
         crl.rule_information6,
--start bug#2757289 bakuchib
         crl.rule_information7,
         crl.rule_information8,
--end bug#2757289 bakuchib
         crl.rule_information13,
         crl.rule_information10,
         DECODE(crl.object1_id1,'M',1,'Q',3,'S',6,'A',12) decoded_object1_id1
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crl.object2_id1 = rlgpId
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId
  AND crg.cle_id = cleId
--  ORDER BY crl.rule_information1;
--start bug#2757289 bakuchib
  ORDER BY FND_DATE.canonical_to_date(crl.rule_information2);
--end bug#2757289 bakuchib
  -- get the Line rule information
  CURSOR l_rl_csr2(rgcode okc_rule_groups_b.rgd_code%TYPE,
                   rlcat  okc_rules_b.rule_information_category%TYPE,
                   chrId NUMBER,
                   cleId NUMBER)
  IS
  SELECT crl.id slh_id,
         crl.object1_id1,
         crl.rule_information1,
         crl.rule_information2,
         crl.rule_information3,
         crl.rule_information5,
         crl.rule_information6,
--start bug#2757289 bakuchib
         crl.rule_information7,
         crl.rule_information8,
         crl.rule_information13,
--end bug#2757289 bakuchib
         crl.rule_information10
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId
  AND crg.cle_id = cleId
  ORDER BY crl.rule_information1;
  -- get the Line rule information
  CURSOR l_rl_csr1(rgcode okc_rule_groups_b.rgd_code%TYPE,
                   rlcat  okc_rules_b.rule_information_category%TYPE,
                   chrId NUMBER,
                   cleId NUMBER )
  IS
  SELECT crl.id slh_id,
         crl.object1_id1,
         crl.rule_information1,
         crl.rule_information2,
         crl.rule_information3,
         crl.rule_information5,
         crl.rule_information6,
--start bug#2757289 bakuchib
         crl.rule_information7,
         crl.rule_information8,
         crl.rule_information13,
--end bug#2757289 bakuchib
         crl.rule_information10
  FROM okc_rule_groups_b crg,
       okc_rules_b crl
  WHERE crl.rgp_id = crg.id
  AND crg.rgd_code = rgcode
  AND crl.rule_information_category = rlcat
  AND crg.dnz_chr_id = chrId
  AND crg.cle_id = cleId
  ORDER BY crl.rule_information1;
  -- get the Contract Header info
  CURSOR l_hdr_csr(chrId  NUMBER)
  IS
  SELECT chr.orig_system_source_code,
         chr.start_date,
         chr.end_date,
         chr.template_yn,
         chr.authoring_org_id,
         khr.expected_delivery_date,
         chr.inv_organization_id,
         khr.deal_type,
         pdt.id  pid,
         NVL(pdt.reporting_pdt_id, -1) report_pdt_id,
         chr.currency_code currency_code,
         khr.term_duration term
  FROM okc_k_headers_v chr,
       okl_k_headers khr,
       okl_products_v pdt
  WHERE khr.id = chr.id
  AND chr.id = chrId
  AND khr.pdt_id = pdt.id(+);
  -- get the Contract line info
  -- Modified by kthiruva on 02-Sep-05
  -- Added trade-in amount and expected funding date to the Select clause of the
  -- cursor for Pricing Impacts in ESG
  CURSOR l_line_rec_csr(chrid NUMBER, lnetype VARCHAR2)
  IS
  SELECT kle.id,
         kle.oec,
         kle.residual_code,
         kle.capital_amount,
         kle.delivered_date,
         kle.date_funding_required,
         kle.residual_grnty_amount,
         kle.date_funding,
         kle.residual_value,
         kle.date_delivery_expected,
         kle.orig_system_id1 old_line_id,
         kle.amount,
         kle.price_negotiated,
         kle.start_date,
         kle.end_date,
         kle.orig_system_id1,
         kle.fee_type,
         kle.initial_direct_cost,
         tl.item_description,
         tl.name,
         sts.ste_code,
         --Added for Pricing Impact
         kle.tradein_amount,
         kle.date_funding_expected,
         -- Added by RGOOTY: ESG Down Payment
         kle.capital_reduction,
         kle.capitalize_down_payment_yn,
         kle.orig_contract_line_id --sechawla 10-jul-09 PRB ESg enhancements : added
  FROM okl_k_lines_full_v kle,
       okc_line_styles_b lse,
       okc_k_lines_tl tl,
       okc_statuses_b sts
  WHERE kle.lse_id = lse.id
  AND lse.lty_code = lnetype
  AND tl.id = kle.id
  AND tl.language = userenv('LANG')
  AND kle.dnz_chr_id = chrid
  AND sts.code = kle.sts_code
--Start of bug#3121708 modification BAKUCHIB
  AND sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');
--End of bug#3121708 modification BAKUCHIB
  -- get the Contract fee line info
  -- nikshah -- Bug # 5484903 Fixed,
  -- Removed CURSOR l_fee_csr
  -- get the Contract fee line info
  CURSOR l_subfee_csr(kleId       NUMBER,
                      lnetype    VARCHAR2,
                      obcode     VARCHAR2)
  IS
  SELECT kle.id,
         kle.amount,
         kle.price_negotiated,
         kle.start_date,
         kle.capital_amount
  FROM okl_k_lines_full_v kle,
       okc_line_styles_b LS,
       okc_k_items cim
  WHERE ls.id = kle.lse_id
  AND ls.lty_code = lnetype
  AND cim.jtot_object1_code = obcode
  AND kle.id = cim.cle_id
  AND cim.object1_id1 = kleId;
  -- get strm fee type
  CURSOR fee_strm_type_csr (kleid NUMBER,
                            linestyle VARCHAR2 )
  IS
  SELECT tl.name strm_name,
         sty.capitalize_yn capitalize_yn,
         kle.id   line_id,
         sty.id   styp_id,
         sty.stream_type_class stream_type_class
  FROM okl_strm_type_tl tl,
       okl_strm_type_v sty,
       okc_k_items cim,
       okl_k_lines_full_v kle,
       okc_line_styles_b ls
  WHERE tl.id = sty.id
  AND tl.language = 'US'
  AND cim.cle_id = kle.id
  AND ls.id = kle.lse_id
  AND ls.lty_code = 'FEE'
  AND cim.object1_id1 = sty.id
  AND cim.object1_id2 = '#'
  AND kle.id = kleid;
  -- get Stream name
  CURSOR strm_name_csr (styid NUMBER)
  IS
  SELECT tl.name name,
         stm.stream_type_class stream_type_class,
		 stm.stream_type_purpose,
         tl.description alloc_basis,
         stm.capitalize_yn capitalize_yn,
         stm.periodic_yn  periodic_yn
  FROM okl_strm_type_b stm,
       okl_strm_type_tl tl
  WHERE tl.id = stm.id
  AND tl.language = 'US'
  AND stm.id = styid;
  -- get the install based location
  CURSOR ib_csr (chrId NUMBER)
  IS
  SELECT DISTINCT hl.country country
  FROM hz_locations hl,
       hz_party_sites hps,
       hz_party_site_uses hpsu,
       okl_txl_itm_insts iti,
       okc_line_styles_b lse_ib,
       okc_k_lines_b cle_ib
  WHERE cle_ib.dnz_chr_id = chrId
  AND cle_ib.lse_id = lse_ib.id
  AND lse_ib.lty_code = 'INST_ITEM'
  AND iti.kle_id = cle_ib.id
  AND iti.object_id1_new = hpsu.party_site_use_id
  AND iti.object_id2_new = '#'
  AND hpsu.party_site_id = hps.party_site_id
  AND hps.location_id = hl.location_id;
  -- get the Stream element information
  CURSOR l_strmele_csr(chrId NUMBER,
                       styid NUMBER)
  IS
  SELECT ele.date_billed,
         ele.stream_element_date,
         ele.amount,
         ele.accrued_yn,
         ele.comments,
         str.transaction_number,
         str.sgn_code sgn_code,
         ele.stm_id stm_id,
         ele.se_line_number se_line_number
  FROM okl_strm_elements ele,
       okl_streams str
  WHERE ele.stm_id = str.id
  AND str.khr_id = chrId
  AND str.sty_id = styid
  AND upper(str.say_code) = 'CURR'
  AND upper(str.active_yn) = 'Y'
  ORDER BY ele.stream_element_date;
  -- get the Streams
  CURSOR strm_csr(chrId NUMBER,
                  kleId NUMBER,
                  status VARCHAR2,
                  pp VARCHAR2,
                  styId NUMBER)  IS
  SELECT str.Id strm_id,
         str.sty_id sty_id,
         str.sgn_code sgn_code,
         str.sgn_code alloc_yn,
         str.comments alloc_basis,
         str.transaction_number trn_num
  FROM okl_streams str
  WHERE str.say_code = status
  AND str.khr_id = chrId
  AND NVL(str.kle_id, -1) = kleId
  AND str.sty_id = styId
  AND NVL(str.purpose_code, 'ORIGIN') = pp;
  --Modified by RGOOTY for bug 8540694
  -- get the streams
  CURSOR strms_csr(chrId NUMBER,
                   status VARCHAR2,
                   pp VARCHAR2 )
  IS
  SELECT /*+ index(STR stm_khr_fk_i)*/ STR.ID STRM_ID,
         STR.KLE_ID,
         STR.STY_ID STY_ID,
         STR.SGN_CODE SGN_CODE,
         STR.SGN_CODE ALLOC_YN,
         STR.COMMENTS ALLOC_BASIS,
         STR.TRANSACTION_NUMBER TRN_NUM,
	 STR.DATE_CURRENT
    FROM OKL_STREAMS STR
   WHERE STR.SAY_CODE = status
     AND NVL(STR.PURPOSE_CODE,'ORIGIN') = pp
     AND STR.KHR_ID = chrId
     AND (
          STR.KLE_ID IN
          (SELECT /*+ index(KLE OKC_K_LINES_B_U1 )*/ KLE.ID
             FROM OKC_K_LINES_B KLE,
                  OKC_LINE_STYLES_B LSE,
                  OKC_STATUSES_B STS
            WHERE KLE.LSE_ID = LSE.ID
              AND KLE.DNZ_CHR_ID = chrId
              AND STS.CODE = KLE.STS_CODE
              AND LSE.LTY_CODE NOT IN ('INSURANCE')
          )
         )
  UNION
  SELECT /*+ index(STR stm_khr_fk_i)*/ STR.ID STRM_ID,
         STR.KLE_ID,
         STR.STY_ID STY_ID,
         STR.SGN_CODE SGN_CODE,
         STR.SGN_CODE ALLOC_YN,
         STR.COMMENTS ALLOC_BASIS,
         STR.TRANSACTION_NUMBER TRN_NUM,
	 STR.DATE_CURRENT
    FROM OKL_STREAMS STR
   WHERE STR.SAY_CODE = status
     AND NVL(STR.PURPOSE_CODE,'ORIGIN') = pp
     AND STR.KHR_ID = chrId
     AND STR.KLE_ID IS NULL;
  -- get the lookup
  CURSOR fnd_lookups_csr( lkp_type VARCHAR2, mng VARCHAR2 )
  IS
  SELECT description,
         lookup_code
  FROM fnd_lookup_values
  WHERE language = 'US'
  AND lookup_type = lkp_type
  AND meaning = mng;


   --Added by kthriuva for Variable Rate Project.
   --Cursor to fetch the OEC of all assets put together in the Contract
   CURSOR total_oec_csr(p_chr_id NUMBER)
   IS
   SELECT sum(kle.oec) total_oec
   FROM okl_k_lines_full_v kle,
        okc_line_styles_b lse,
        okc_k_lines_tl tl,
        okc_statuses_b sts
   WHERE kle.lse_id = lse.id
   AND lse.lty_code = 'FREE_FORM1'
   AND tl.id = kle.id
   AND tl.language = userenv('LANG')
   AND kle.dnz_chr_id = p_chr_id
   AND sts.code = kle.sts_code
   AND sts.ste_code not in ('HOLD', 'EXPIRED', 'CANCELLED');



  TYPE strmele_tbl_type IS TABLE OF l_strmele_csr%ROWTYPE INDEX BY BINARY_INTEGER;

  Procedure allocate_streams(
            p_api_version     IN NUMBER,
            p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  NUMBER) ;

  Procedure generate_reporting_streams(
            p_api_version          IN  NUMBER,
            p_init_msg_list        IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id               IN  VARCHAR2,
            p_report_deal_type     IN  VARCHAR2,
            p_generation_context   IN  VARCHAR2,
            p_skip_prc_engine      IN  VARCHAR2,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            x_request_id           IN OUT NOCOPY NUMBER,
            x_trans_status         OUT NOCOPY VARCHAR2,
            p_orp_code             IN  VARCHAR2);

  Procedure generate_streams(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id              IN  VARCHAR2,
            p_generation_context  IN  VARCHAR2,
            p_skip_prc_engine     IN  VARCHAR2,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            x_request_id          OUT NOCOPY NUMBER,
            x_trans_status        OUT NOCOPY VARCHAR2);

  Procedure process_streams(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  VARCHAR2,
            p_process_yn     IN  VARCHAR2,
            p_chr_yields     IN  yields_rec_type,
            p_source_call    IN   VARCHAR2 DEFAULT 'ESG');

  Procedure update_contract_yields(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_chr_id         IN  VARCHAR2,
            p_chr_yields     IN  yields_rec_type);

  Procedure extract_params_lease(
            p_api_version                IN  NUMBER,
            p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id                     IN  VARCHAR2,
            x_return_status              OUT NOCOPY VARCHAR2,
            x_msg_count                  OUT NOCOPY NUMBER,
            x_msg_data                   OUT NOCOPY VARCHAR2,
            x_csm_lease_header           OUT NOCOPY okl_create_streams_pub.csm_lease_rec_type,
            x_csm_one_off_fee_tbl        OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl             OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_req_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type,
            x_csm_line_details_tbl       OUT NOCOPY okl_create_streams_pub.csm_line_details_tbl_type,
            x_rents_tbl                  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            p_orp_code                   IN  VARCHAR2 DEFAULT NULL );

  Procedure extract_params_loan(
            p_api_version                IN  NUMBER,
            p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id                     IN  VARCHAR2,
            x_return_status              OUT NOCOPY VARCHAR2,
            x_msg_count                  OUT NOCOPY NUMBER,
            x_msg_data                   OUT NOCOPY VARCHAR2,
            x_csm_loan_header            OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl         OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl        OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl             OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type,
            p_orp_code                   IN  VARCHAR2 DEFAULT NULL );

  Procedure GEN_INTR_EXTR_STREAM (
            p_api_version          IN NUMBER,
            p_init_msg_list        IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status        OUT NOCOPY VARCHAR2,
            x_msg_count            OUT NOCOPY NUMBER,
            x_msg_data             OUT NOCOPY VARCHAR2,
            p_khr_id               IN  OKC_K_HEADERS_B.ID%TYPE,
            p_generation_ctx_code  IN  VARCHAR2,
            x_trx_number           OUT NOCOPY NUMBER,
            x_trx_status           OUT NOCOPY VARCHAR2);

  PROCEDURE validate_payments(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              p_khr_id         IN OKC_K_HEADERS_B.ID%TYPE,
                              p_paym_tbl       IN OKL_STREAM_GENERATOR_PVT.payment_tbl_type);

  PROCEDURE get_so_residual_value(p_khr_id         IN NUMBER,
                                  p_kle_id         IN NUMBER,
                                  p_subside_yn     IN VARCHAR2 DEFAULT 'N',
                                  x_return_status  OUT NOCOPY VARCHAR2,
                                  x_residual_value OUT NOCOPY NUMBER,
                                  x_start_date     OUT NOCOPY DATE);

  PROCEDURE get_so_asset_oec(p_khr_id        IN NUMBER,
                             p_kle_id        IN NUMBER,
                             p_subside_yn    IN VARCHAR2 DEFAULT 'N',
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_asset_oec     OUT NOCOPY NUMBER,
                             x_start_date    OUT NOCOPY DATE);

  PROCEDURE extract_params_so(
            p_api_version                IN  NUMBER,
            p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id                     IN  OKC_K_HEADERS_B.ID%TYPE,
            p_cle_id                     IN  OKC_K_LINES_B.ID%TYPE,
            x_return_status              OUT NOCOPY VARCHAR2,
            x_msg_count                  OUT NOCOPY NUMBER,
            x_msg_data                   OUT NOCOPY VARCHAR2,
            x_csm_lease_header           OUT NOCOPY okl_create_streams_pub.csm_lease_rec_type,
            x_csm_one_off_fee_tbl        OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl             OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_req_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type,
            x_csm_line_details_tbl       OUT NOCOPY okl_create_streams_pub.csm_line_details_tbl_type,
            x_rents_tbl                  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_loan_header            OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl         OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type);

  --Added new procedure for the Variable Rate Project
  Procedure extract_params_loan_paydown(
            p_api_version                IN  NUMBER,
            p_init_msg_list              IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id                     IN  VARCHAR2,
            p_deal_type                  IN  VARCHAR2,
	    p_paydown_type               IN  VARCHAR2,
	    p_paydown_date               IN  DATE,
	    p_paydown_amount             IN  NUMBER,
            p_balance_type_code          IN  VARCHAR2,
            x_return_status              OUT NOCOPY VARCHAR2,
            x_msg_count                  OUT NOCOPY NUMBER,
            x_msg_data                   OUT NOCOPY VARCHAR2,
            x_csm_loan_header            OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl         OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl        OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl  OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl             OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl       OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type);

  --Added by kthiruva for Bug 5161075
  Procedure extract_params_loan_reamort(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            p_chr_id          IN  VARCHAR2,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            x_csm_loan_header           OUT NOCOPY okl_create_streams_pvt.csm_loan_rec_type,
            x_csm_loan_lines_tbl        OUT NOCOPY okl_create_streams_pvt.csm_loan_line_tbl_type,
            x_csm_loan_levels_tbl       OUT NOCOPY okl_create_streams_pvt.csm_loan_level_tbl_type,
            x_csm_one_off_fee_tbl       OUT NOCOPY okl_create_streams_pub.csm_one_off_fee_tbl_type,
            x_csm_periodic_expenses_tbl OUT NOCOPY okl_create_streams_pub.csm_periodic_expenses_tbl_type,
            x_csm_yields_tbl            OUT NOCOPY okl_create_streams_pub.csm_yields_tbl_type,
            x_csm_stream_types_tbl      OUT NOCOPY okl_create_streams_pub.csm_stream_types_tbl_type);

   --Added by srsreeni for bug 5699923
   PROCEDURE RECREATE_TMT_LN_STRMS(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_chr_id          IN  VARCHAR2,
            p_trx_number      IN  NUMBER,
            p_source_call     IN  VARCHAR2 DEFAULT 'ESG');


   --Added by bkatraga for bug 8399461
   PROCEDURE get_pth_fee_due_amount(
            p_chr_id           IN NUMBER,
            p_kle_id           IN NUMBER,
            p_prev_payout_date IN DATE,
            p_payout_date      IN DATE,
            x_bill_amount      OUT NOCOPY NUMBER,
            x_return_status    OUT NOCOPY VARCHAR2);

  /************************************************************************
  * API to upgrade the ESG Contracts to support the
  *  Prospective Rebooking
  *************************************************************************/
  PROCEDURE upgrade_esg_khr_for_prb(
             p_chr_id             IN         VARCHAR2
            ,x_return_status      OUT NOCOPY VARCHAR2
            ,x_msg_count          OUT NOCOPY NUMBER
            ,x_msg_data           OUT NOCOPY VARCHAR2
            ,x_request_id         OUT NOCOPY NUMBER
            ,x_trans_status       OUT NOCOPY VARCHAR2
            ,x_rep_request_id     OUT NOCOPY NUMBER
            ,x_rep_trans_status   OUT NOCOPY VARCHAR2 );

  /************************************************************************
  * API to generate passthrough expense accrual streams
  *  For ISG and ESG contracts --Bug 8624532 by NIKSHAH
  *************************************************************************/
  PROCEDURE GENERATE_PASSTHRU_EXP_STREAMS(
             p_api_version        IN         NUMBER
            ,p_init_msg_list      IN         VARCHAR2 DEFAULT OKL_API.G_FALSE
            ,P_CHR_ID             IN         NUMBER
            ,P_PURPOSE_CODE       IN         VARCHAR2
            ,x_return_status      OUT NOCOPY VARCHAR2
            ,x_msg_count          OUT NOCOPY NUMBER
            ,x_msg_data           OUT NOCOPY VARCHAR2 );

End OKL_LA_STREAM_PVT;

/
