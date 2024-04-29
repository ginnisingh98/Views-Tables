--------------------------------------------------------
--  DDL for Package OKL_QA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QA_DATA_INTEGRITY" AUTHID CURRENT_USER AS
/* $Header: OKLRQADS.pls 120.21.12010000.5 2010/02/18 02:00:07 rpillay ship $ */

  ---------------------------------------------------------------------------
  -- GLOBAL MESSAGE CONSTANTS
  ---------------------------------------------------------------------------
  G_FND_APP			CONSTANT VARCHAR2(200) := OKC_API.G_FND_APP;
  G_NO_PARENT_RECORD            CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_FORM_UNABLE_TO_RESERVE_REC	CONSTANT VARCHAR2(200) := OKC_API.G_FORM_UNABLE_TO_RESERVE_REC;
  G_FORM_RECORD_DELETED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_DELETED;
  G_FORM_RECORD_CHANGED		CONSTANT VARCHAR2(200) := OKC_API.G_FORM_RECORD_CHANGED;
  G_RECORD_LOGICALLY_DELETED	CONSTANT VARCHAR2(200) := OKC_API.G_RECORD_LOGICALLY_DELETED;
  G_REQUIRED_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_REQUIRED_VALUE;
  G_INVALID_VALUE		CONSTANT VARCHAR2(200) := OKC_API.G_INVALID_VALUE;
  G_COL_NAME_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_COL_NAME_TOKEN;
  G_PARENT_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN		CONSTANT VARCHAR2(200) := OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR            CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXP_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT VARCHAR2(200) := 'SQLcode';
  G_UPPERCASE_REQUIRED		CONSTANT VARCHAR2(200) := 'OKC_UPPERCASE_REQUIRED';
  G_INVALID_END_DATE            CONSTANT VARCHAR2(200) := 'OKC_INVALID_END_DATE';
--
  G_QA_SUCCESS   		CONSTANT VARCHAR2(200) := 'OKL_CONTRACTS_QA_SUCCESS';
  G_PARTY_COUNT   		CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_PARTY_COUNT';
  G_REQUIRED_RULE   		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE';
  G_REQUIRED_RULE_GROUP         CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_GROUP';
  G_REQUIRED_RULE_VALUES        CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_VALUES';
  G_REQUIRED_RULE_PARTY_ROLE    CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_RULE_PARTY_ROLE';
  G_RULE_DEPENDENT_VALUE        CONSTANT VARCHAR2(200) := 'OKC_RULE_DEPENDENT_VALUE';
  G_INVALID_LINE_DATES          CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_DATES';
  G_REQUIRED_LINE_VALUE		CONSTANT VARCHAR2(200) := 'OKC_REQUIRED_LINE_FIELD';
  G_INVALID_LINE_CURRENCY       CONSTANT VARCHAR2(200) := 'OKC_INVALID_LINE_CURRENCY';
  G_RULE_ROLE_DELETED   		CONSTANT VARCHAR2(200) := 'OKC_RULE_ROLE_DELETED';
  G_RULE_ROLE_CHANGED   		CONSTANT VARCHAR2(200) := 'OKC_RULE_ROLE_CHANGED';
  G_NO_SUBLINE_PARTY   		CONSTANT VARCHAR2(200) := 'OKC_NO_PARTY_SUBLINE';
  G_NO_HEADER_PARTY   		CONSTANT VARCHAR2(200) := 'OKC_NO_PARTY_HEADER';
  G_NO_SUBLINE_RULE   		CONSTANT VARCHAR2(200) := 'OKC_NO_RULE_SUBLINE';
  G_NOT_ALLOWED_RULE            CONSTANT VARCHAR2(200) := 'OKC_NOT_ALLOWED_RULE';
  ------------------------------------------------------------------------------------
  -- GLOBAL EXCEPTION
  ---------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION	EXCEPTION;

  -- GLOBAL VARIABLES
  ---------------------------------------------------------------------------
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QA_CHECK_PVT';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
    cursor l_rl_csr( shid NUMBER,
                     rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
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
           crl.RULE_INFORMATION10
    from   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    where  crl.object2_id1 = shid
           and crl.rgp_id = crg.id
           and crg.RGD_CODE = rgcode
           and crl.RULE_INFORMATION_CATEGORY = rlcat
           and crg.dnz_chr_id = chrId
           and nvl(crg.cle_id,-1) = cleId
    order by crl.RULE_INFORMATION1;

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

    --Bug# 8652738
    -- Modified cursor to only fetch contract header level rules
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
           and crg.chr_id = chrId;

    cursor l_oksrl_csr(rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       chrId NUMBER,
		       cleId NUMBER) IS
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
           and crl.RULE_INFORMATION_CATEGORY = rlcat
           and crg.dnz_chr_id = chrId
	   and nvl(crg.cle_id, -1) = cleId;

    Cursor supp_csr ( faid VARCHAR2 ) IS
    Select inv.date_invoiced
    From okl_supp_invoice_dtls inv
    Where inv.fa_cle_id = faid;

    --Bug#3877032
    CURSOR l_hdr_csr(chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT chr.SCS_CODE,
               chr.START_DATE,
               chr.DATE_SIGNED,
               chr.CURRENCY_CODE,
               chr.TEMPLATE_YN,
               chr.contract_number,
               khr.accepted_date,
               khr.syndicatable_yn,
               khr.DEAL_TYPE,
               khr.term_duration term,
	       nvl(pdt.reporting_pdt_id, -1) report_pdt_id
        FROM OKC_K_HEADERS_B chr,
	     OKL_K_HEADERS khr,
	     OKL_PRODUCTS_V pdt
        WHERE chr.id = chrid
           AND chr.id = khr.id
	   --AND khr.pdt_id = pdt.id(+);
	   AND khr.pdt_id = pdt.id;

    CURSOR l_line_name ( n VARCHAR2 ) IS
    Select count(*) cnt
        FROM OKL_K_LINES_FULL_V kle,
             OKC_LINE_STYLES_B ls
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = 'FREE_FORM1'
              AND kle.name = n;
    l_ln l_line_name%ROWTYPE;

    CURSOR l_topsvclne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE, lineId NUMBER) IS
        SELECT cle.id,
	       sub_kle.price_negotiated amount
        FROM OKC_K_LINES_B cle,
             OKC_K_LINES_B sub_kle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE cle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND cle.dnz_chr_id = chrid
	      AND sts.code = cle.sts_code
	      AND sub_kle.id = lineId
	      AND cle.id = sub_kle.cle_id
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_svclne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT cle.id,
	       cle.price_negotiated amount
        FROM OKC_K_LINES_B cle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE cle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND cle.dnz_chr_id = chrid
	      AND sts.code = cle.sts_code
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_toplne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE, lineId NUMBER) IS
        SELECT kle.name,
               kle.CURRENCY_CODE,
               kle.id,
               kle.RESIDUAL_VALUE,
               kle.TRACKED_RESIDUAL,
               kle.CAPITAL_REDUCTION,
               kle.TRADEIN_AMOUNT,
               kle.RVI_PREMIUM,
               kle.OEC,
               kle.residual_code,
               kle.residual_grnty_amount,
	       sub_kle.capital_amount amount,
               sub_kle.line_number
        FROM OKL_K_LINES_FULL_V kle,
             OKL_K_LINES_FULL_V sub_kle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND kle.dnz_chr_id = chrid
	      AND sts.code = kle.sts_code
	      AND sub_kle.id = lineId
	      AND kle.id = sub_kle.cle_id
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_lne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT kle.name,
	       kle.amount,
               kle.CURRENCY_CODE,
               kle.id,
               kle.RESIDUAL_VALUE,
               kle.TRACKED_RESIDUAL,
               kle.CAPITAL_REDUCTION,
               kle.TRADEIN_AMOUNT,
               kle.RVI_PREMIUM,
               kle.OEC,
               kle.residual_code,
               kle.residual_grnty_amount,
               -- bug 5034519
               kle.start_date,
               --Bug# 4631549
               kle.expected_asset_cost
        FROM OKL_K_LINES_FULL_V kle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND kle.dnz_chr_id = chrid
	      AND sts.code = kle.sts_code
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

   cursor l_subline_csr( kleId  NUMBER) is
   select cim.object1_id1,
          cim.number_of_items,
	  kle.name
   from okl_k_lines_full_v kle,
        OKC_LINE_STYLES_B LS,
        okc_k_items cim,
        okl_k_lines_full_v kle1
   where LS.ID = KLE.LSE_ID
       and ls.lty_code = 'ITEM'
       and kle.id = cim.cle_id
       and kle.id = kle1.id
       and kle1.cle_id = (select cim.object1_id1
                          from okl_k_lines_full_v kle,
                               OKC_LINE_STYLES_B LS,
                               okc_k_items cim
                          where LS.ID = KLE.LSE_ID
                              and ls.lty_code = 'LINK_SERV_ASSET'
                              and kle.id = cim.cle_id
                              and kle.id = kleId);

    Cursor l_svcline_csr( kleId NUMBER) is
    select okx.inventory_item_id,
           okx.quantity
    from  csi_item_instances okx,
          okc_k_lines_b kle,
          OKC_LINE_STYLES_B LS,
          okc_k_items cim
    where okx.instance_ID = cim.object1_id1
	 and  LS.ID = KLE.LSE_ID
         and ls.lty_code = 'COVER_PROD'
         and kle.id = cim.cle_id
         and kle.id = kleId;


     cursor l_txl_csr( kleid NUMBER ) is
     select txl.life_in_months,
           txl.deprn_method,
           txl.in_service_date,
           txl.salvage_value,
           txl.percent_salvage_value,
           txl.depreciation_cost,
           txl.fa_location_id,
           txl.deprn_rate,
           --Bug# 4103361:
           txl.corporate_book,
           txl.depreciation_id
    from okl_txl_assets_b txl
    where txl.kle_id = kleid;

     cursor l_txd_csr( kleid NUMBER ) is
     select txd.cost,
           txd.deprn_method_tax,
           --bug# 4103361
           txd.tax_book
    from okl_txd_assets_v txd,
         okl_txl_assets_b txl
    where txd.tal_id = txl.id
        and txl.kle_id = kleid;


     Cursor l_struct_csr( chrId NUMBER ) is
     select distinct(nvl(crl.RULE_INFORMATION5,-1)) structure
     from   OKC_RULE_GROUPS_B crg,
            OKC_RULES_B crl
     where  crl.rgp_id = crg.id
            and crg.RGD_CODE = 'LALEVL'
            and crl.RULE_INFORMATION_CATEGORY = 'LASLL'
            and crg.dnz_chr_id = chrId
            and crl.RULE_INFORMATION1 is not null;

     Cursor l_itms_csr( ltycode VARCHAR2, kleId NUMBER, chrId NUMBER ) IS
     Select cim.object1_id1 FinAssetId,
            cim.number_of_items number_of_items
     From okc_K_items cim,
	  okl_K_lines_full_v kle,
	  okc_line_styles_b lse
     Where kle.lse_id = lse.id
	and lse.lty_code = ltycode
        and cim.jtot_object1_code = 'OKX_COVASST'
        and cim.cle_id = kle.id
	and kle.cle_id = kleId
        and kle.dnz_chr_id = chrId;


    cursor fee_strm_type_csr ( kleid NUMBER,
                               linestyle VARCHAR2 ) is
    select tl.name strm_name,
           sty.capitalize_yn capitalize_yn,
           kle.id   line_id,
           sty.id   styp_id,
           sty.stream_type_class stream_type_class
    from okl_strm_type_tl tl,
         okl_strm_type_v sty,
         okc_k_items cim,
         okl_k_lines_full_v kle,
         okc_line_styles_b ls
    where tl.id = sty.id
         and tl.language = USERENV('LANG')
         and cim.cle_id = kle.id
         and ls.id = kle.lse_id
         and ls.lty_code = 'FEE'
         and cim.object1_id1 = sty.id
         and cim.object1_id2 = '#'
         and kle.id = kleid;

--Bug#3931587
    cursor strm_name_csr ( styid NUMBER ) is
        select tl.name name,
           stm.stream_type_purpose,
           stm.stream_type_class stream_type_class,
           tl.description ALLOC_BASIS,
           stm.capitalize_yn capitalize_yn,
           stm.periodic_yn  periodic_yn
    from okl_strm_type_b stm,
         OKL_STRM_TYPE_TL tl
    where tl.id = stm.id
         and tl.language = USERENV('LANG')
         and stm.id = styid;

   --cursor to check usage line instance quantities
   Cursor asst_qty_csr (FinAsstid NUMBER) is
   select cim.number_of_items,
          fa.id fa_id
   from   okc_k_items cim,
          okc_k_lines_b fa,
          okc_line_styles_b fa_lse
   where  cim.cle_id = fa.id
     and    cim.dnz_chr_id = fa.dnz_chr_id
     and    fa.lse_id      = fa_lse.id
     and    fa_lse.lty_code = 'FIXED_ASSET'
     and    fa.cle_id = FinAsstId;


   Cursor ib_qty_csr (FinAsstid NUMBER) is
   select  count(inst.id)
   from    okc_k_lines_b inst,
           okc_line_styles_b inst_lse
   where   inst.cle_id = FinAsstId
       and     inst.lse_id = inst_lse.id
       and     inst_lse.lty_code = 'FREE_FORM2';

   Cursor cust_csr ( rleCode VARCHAR2, chrId NUMBER ) IS
   Select object1_id1
   From OKC_K_PARTY_ROLES_B
   Where dnz_chr_id = chrId
      and rle_code = rleCode;

   Cursor index_csr( idxId NUMBER ) IS
   Select a.name,
          b.datetime_valid
   from okl_indices a,
        okl_index_values b
   where a.id = b.idx_id
      and a.id = idxId
   order by b.datetime_valid;


   Cursor cust_site_csr( siteId NUMBER, accntId NUMBER, rleCode VARCHAR2 ) IS
   Select 'Y' isThere
   From dual
   where Exists (
       Select a.cust_acct_site_id
       From   HZ_CUST_SITE_USES_ALL  a,
              HZ_CUST_ACCT_SITES_ALL b
       Where b.cust_acct_site_id = a.cust_acct_site_id
           and a.site_use_id = siteId
	   and a.site_use_code = rleCode
	   and b.cust_account_id = accntId);

   Cursor fnd_csr( fndType VARCHAR2, fndCode VARCHAR2 ) IS
   Select meaning,
          description
   From  fnd_lookups
   Where lookup_type = fndType
       and lookup_code = fndCode;

--Added by rkuttiya for bug 5716089
  CURSOR l_payment_strm_csr (p_chr_id number) IS
SELECT tl.NAME stream_name, styb.id sty_id,styb.stream_type_purpose, rgpb.cle_id
kle_id,
       rulb2.rule_information2 start_date,rulb2.rule_information3 level_periods,
       rulb2.rule_information7 stub_days,rulb2.rule_information8 stub_amount,
       rulb2.rule_information10 arrear_yn
  FROM okc_k_lines_b cleb,
       okc_rule_groups_b rgpb,
       okc_rules_b rulb,
       okc_rules_b rulb2,
       okl_strm_type_b styb,
       okl_strm_type_tl tl
 WHERE rgpb.chr_id IS NULL
   AND rgpb.dnz_chr_id = cleb.dnz_chr_id
   AND rgpb.cle_id = cleb.ID
   AND cleb.dnz_chr_id = p_chr_id
   AND rgpb.rgd_code = 'LALEVL'
   AND rulb.rgp_id = rgpb.ID
   AND rulb.rule_information_category = 'LASLH'
   AND TO_CHAR (styb.ID) = rulb.object1_id1
   AND rulb2.object2_id1 = TO_CHAR (rulb.ID)
   AND rulb2.rgp_id = rgpb.ID
   AND rulb2.rule_information_category = 'LASLL'
   AND tl.ID = styb.ID
   AND tl.LANGUAGE = 'US';

   CURSOR l_product_csr (p_chr_id number) IS
SELECT khr.pdt_id, khr.start_date, prod.reporting_pdt_id
  FROM okl_products prod, okl_k_headers_full_v khr
 WHERE khr.ID = p_chr_id AND prod.ID = khr.pdt_id;


CURSOR l_rep_strm_csr (rep_pdt_id number,styid number,primary_sty_purpose
varchar2,contract_start_date date ) IS
SELECT primary_sty_id
  FROM okl_strm_tmpt_lines_uv stl
 WHERE stl.primary_yn = 'Y'
   AND stl.pdt_id = rep_pdt_id
   AND (stl.start_date <= contract_start_date)
   AND (stl.end_date >= contract_start_date OR stl.end_date IS NULL)
   AND primary_sty_purpose = primary_sty_purpose
   AND primary_sty_id = styid;

-- rkuttiya end changes for BUG # 5716089

 -- rviriyal bug 5982201 start
   cursor contract_dtls(chrId Number) is
       select start_date, end_date
       from okc_k_headers_b
       where id =chrId;

   cursor vend_dtls(OBJECT1_ID1 NUMBER) is
       select START_DATE_ACTIVE, END_DATE_ACTIVE, NAME
       from okx_vendors_v
       where ID1 = OBJECT1_ID1;

   Cursor party_id_csr (role_code varchar2, chrId NUMBER ) IS
      Select distinct OBJECT1_ID1
      From OKC_K_PARTY_ROLES_B
      Where dnz_chr_id = chrId
         and rle_code = role_code;

   --rviriyal bug 5982201 end



  PROCEDURE check_variable_rate(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_prefunding_status(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_advanced_rentals(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);


  PROCEDURE check_fee_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);


  PROCEDURE check_rule_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_acceptance_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_pmnt_start_dt(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_srvc_amnt(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_service_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_cov_service_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_service_line_hdr(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_fee_service_payment(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_tax_book_cost(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_capital_fee(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_asset_tax(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_subsidies(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_subsidies_errors(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_credit_line(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_invoice_format(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_tax_book_mapping(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  --Bug# 3504680
  PROCEDURE check_sales_type_lease(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  -- Bug 3325126
  PROCEDURE check_payment_struct(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  -- Bug 4017608
  PROCEDURE check_rollover_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN NUMBER);

  -- Bug 3670104
  PROCEDURE check_contract_dt_signed(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN NUMBER);

  -- Bug 4186455
  PROCEDURE check_residual_value(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN NUMBER);

  -- Bug 4670841
  PROCEDURE check_purchase_option(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN NUMBER);

  --Bug# 4899328
  PROCEDURE check_asset_deprn_cost(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

  -- Bug 5032883
  PROCEDURE check_late_int_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

  -- Bug 5032883
  PROCEDURE check_late_charge_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

--added bu rkuttiya for bug #5716089
   PROCEDURE check_reporting_pdt_strm(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );
--

   --akrangan bug 5362977 start
PROCEDURE check_asset_category(	x_return_status            OUT NOCOPY VARCHAR2,
				p_chr_id                   IN NUMBER);
 --akrangan bug 5362977 end

  -- rviriyal bug 5982201 start
     procedure check_vendor_active(
       x_return_status             OUT NOCOPY VARCHAR2,
       p_chr_id                    IN NUMBER
     );
      procedure check_vendor_end_date(
       x_return_status             OUT NOCOPY VARCHAR2,
       p_chr_id                    IN NUMBER
     );
     procedure check_cust_active(
       x_return_status             OUT NOCOPY VARCHAR2,
       p_chr_id                    IN NUMBER
     );

   -- rviriyal bug 5982201 end
        --Bug# 6711559 -- start
  PROCEDURE check_book_class_cmptblty(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );
   --Bug# 6711559 -- end

  -- Bug 8652738
  PROCEDURE check_exp_delivery_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

  -- Bug# 5690875
  PROCEDURE check_pre_funding(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  );

END OKL_QA_DATA_INTEGRITY;

/
