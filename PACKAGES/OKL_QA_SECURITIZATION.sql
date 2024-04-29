--------------------------------------------------------
--  DDL for Package OKL_QA_SECURITIZATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKL_QA_SECURITIZATION" AUTHID CURRENT_USER AS
/* $Header: OKLRSZQS.pls 120.3 2005/09/30 16:55:48 avsingh noship $ */

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
  G_PKG_NAME			CONSTANT VARCHAR2(200) := 'OKL_QA_SECURITIZATION';
  G_APP_NAME   CONSTANT VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  ---------------------------------------------------------------------------
    cursor l_lnerl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
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
           crl.RULE_INFORMATION10
    from   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    where  crl.rgp_id = crg.id
           and crg.RGD_CODE = rgcode
           and crl.RULE_INFORMATION_CATEGORY = rlcat
           and crg.dnz_chr_id = chrId
           and crg.cle_id = cleId
    order by crl.RULE_INFORMATION1;

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
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    from   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    where  crl.rgp_id = crg.id
           and crg.RGD_CODE like rgcode
           and crl.RULE_INFORMATION_CATEGORY = rlcat
           and crg.dnz_chr_id = chrId;

    CURSOR l_hdr_csr(chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT chr.SCS_CODE,
               chr.START_DATE,
               chr.DATE_SIGNED,
               chr.CURRENCY_CODE,
               chr.TEMPLATE_YN,
               chr.contract_number,
               khr.accepted_date,
               khr.DEAL_TYPE,
               khr.term_duration term,
               khr.after_tax_yield
        FROM OKC_K_HEADERS_B chr, OKL_K_HEADERS khr
        WHERE chr.id = chrid
           AND chr.id = khr.id;

    CURSOR l_lne_csr1(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT kle.name,
               kle.CURRENCY_CODE,
               kle.id,
               kle.cle_id,
               kle.RESIDUAL_VALUE,
               kle.TRACKED_RESIDUAL,
               kle.CAPITAL_REDUCTION,
               kle.TRADEIN_AMOUNT,
               kle.RVI_PREMIUM,
               kle.OEC,
               kle.residual_code,
               kle.residual_grnty_amount
        FROM OKL_K_LINES_FULL_V kle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND kle.dnz_chr_id = chrid
	      AND sts.code = kle.sts_code
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_lne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT kle.name,
               kle.CURRENCY_CODE,
               kle.id,
               kle.cle_id,
               kle.RESIDUAL_VALUE,
               kle.TRACKED_RESIDUAL,
               kle.CAPITAL_REDUCTION,
               kle.TRADEIN_AMOUNT,
               kle.RVI_PREMIUM,
               kle.OEC,
               kle.residual_code,
               kle.residual_grnty_amount
        FROM OKL_K_LINES_FULL_V kle,
             OKC_LINE_STYLES_B ls,
	     OKC_STATUSES_B sts
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND kle.dnz_chr_id = chrid
	      AND sts.code = kle.sts_code
	      AND sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');


    cursor strm_name_csr ( styid NUMBER ) is
        select tl.name name,
           stm.stream_type_class stream_type_class,
           tl.description ALLOC_BASIS,
           stm.capitalize_yn capitalize_yn,
           stm.periodic_yn  periodic_yn
    from okl_strm_type_b stm,
         OKL_STRM_TYPE_TL tl
    where tl.id = stm.id
         and tl.language = 'US'
         and stm.id = styid;


    Cursor fnd_csr ( lkupcode VARCHAR2 ) IS
    SELECT Meaning
    FROM OKC_RULE_DEFS_V
    WHERE DESCRIPTIVE_FLEXFIELD_NAME = 'OKL Rule Developer DF'
        AND RULE_CODE = lkupcode;

   Cursor t_and_c_csr ( code VARCHAR2 ) IS
   SELECT MEANING
   FROM FND_LOOKUPS
   WHERE LOOKUP_TYPE = 'OKL_LA_SEC_LINKS'
   AND LOOKUP_CODE = code;


    Cursor Invstr_csr ( chrId NUMBER, cleId NUMBER) IS
    SELECT
      PARB.NAME NAME
    FROM
      OKX_PARTIES_V PARB,
      OKC_K_PARTY_ROLES_B CPLB
    WHERE
      PARB.ID1 = CPLB.OBJECT1_ID1  AND
      PARB.ID2 = CPLB.OBJECT1_ID2  AND
      CPLB.JTOT_OBJECT1_CODE = 'OKX_PARTY'   AND
      CPLB.RLE_CODE = 'INVESTOR'  AND
      CPLB.DNZ_CHR_ID = chrId AND
      CPLB.CLE_ID = cleId;

  PROCEDURE check_rule_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

  PROCEDURE check_ia_type_for_strms(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER);

END OKL_QA_SECURITIZATION;

 

/
