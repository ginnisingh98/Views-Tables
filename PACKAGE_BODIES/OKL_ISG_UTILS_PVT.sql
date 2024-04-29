--------------------------------------------------------
--  DDL for Package Body OKL_ISG_UTILS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_ISG_UTILS_PVT" AS
/* $Header: OKLRIGUB.pls 120.8 2007/10/12 20:10:08 djanaswa ship $ */


-- Start of comments
--
-- Procedure Name	: get_primary_stream_type
-- Description		: Return Primary Stream type for given purpose code
-- Business Rules	:
-- Parameters		: khr_id
--                  : Primary_sty_purpose
-- Version		: 1.0
--              : 2.0   Now passing contract deal type to get the stream type
----              3.0    Added code to support multi GAPP product
-- End of comments

PROCEDURE get_primary_stream_type
(
 p_khr_id  		   	     IN NUMBER,
 p_pdt_id              IN NUMBER,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE,
 x_primary_sty_name       OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE
)

IS

    CURSOR get_k_info_csr(  l_khr_id NUMBER ) IS
    SELECT

           pdt.id  pdt_id,
           chr.start_date,
           khr.deal_type,
           nvl(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = chr.id
        AND chr.id = l_khr_id
        AND khr.pdt_id = pdt.id(+);

CURSOR get_primary_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT
  TLN.PRIMARY_STY_ID,
  STY.NAME PRIMARY_STY_NAME
FROM
  OKL_ST_GEN_TMPT_LNS TLN,
  OKL_ST_GEN_TEMPLATES TMPT,
  OKL_ST_GEN_TMPT_SETS Tst,
  OKL_AE_TMPT_SETS AES,
  OKL_PRODUCTS_V PDT,
  OKL_STRM_TYPE_v STY

WHERE
  TLN.GTT_ID = TMPT.ID AND
  TMPT.GTS_ID = Tst.ID AND
  Tst.ID = AES.GTS_ID AND
  --TST.deal_type = p_deal_type AND
  AES.ID = PDT.AES_ID AND
  TLN.PRIMARY_STY_ID = STY.ID
  AND TLN.PRIMARY_YN = 'Y'
AND PDT.ID = l_pdt_id
AND    (TMPT.START_DATE <= l_contract_start_date)
AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
AND	   STY.STREAM_TYPE_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_deal_type              okl_k_headers.deal_type%Type;
  l_report_product_id      NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;
  l_primary_strm_name 			  	OKL_STRM_TYPE_v.name%Type;

  BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_product_id, l_contract_start_date,l_deal_type,l_report_product_id;
  CLOSE get_k_info_csr;

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN get_primary_strm_type_csr (l_product_id, l_contract_start_date);
    FETCH get_primary_strm_type_csr INTO l_primary_sty_id,l_primary_strm_name;
      IF  get_primary_strm_type_csr%NOTFOUND THEN
          x_primary_sty_id := null;
          x_primary_sty_name := null;
       ELSE
            x_primary_sty_id := l_primary_sty_id;
            x_primary_sty_name := l_primary_strm_name;
	   END IF;
    CLOSE get_primary_strm_type_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;
   x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END get_primary_stream_type;

PROCEDURE get_primary_stream_type
(
 p_khr_id  		   	     IN NUMBER,
 p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
 p_primary_sty_purpose   IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
 x_return_status		OUT NOCOPY VARCHAR2,
 x_primary_sty_id 		OUT NOCOPY okl_strm_type_b.ID%TYPE,
 x_primary_sty_name       OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE
)

IS

    CURSOR get_k_info_csr(  l_khr_id NUMBER ) IS
    SELECT

           pdt.id  pdt_id,
           chr.start_date,
           khr.deal_type,
           nvl(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = chr.id
        AND chr.id = l_khr_id
        AND khr.pdt_id = pdt.id(+);

CURSOR get_primary_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT
  TLN.PRIMARY_STY_ID,
  STY.NAME PRIMARY_STY_NAME
FROM
  OKL_ST_GEN_TMPT_LNS TLN,
  OKL_ST_GEN_TEMPLATES TMPT,
  OKL_ST_GEN_TMPT_SETS Tst,
  OKL_AE_TMPT_SETS AES,
  OKL_PRODUCTS_V PDT,
  OKL_STRM_TYPE_v STY

WHERE
  TLN.GTT_ID = TMPT.ID AND
  TMPT.GTS_ID = Tst.ID AND
  Tst.ID = AES.GTS_ID AND
  TST.deal_type = p_deal_type AND
  AES.ID = PDT.AES_ID AND
  TLN.PRIMARY_STY_ID = STY.ID
  AND TLN.PRIMARY_YN = 'Y'
AND PDT.ID = l_pdt_id
AND    (TMPT.START_DATE <= l_contract_start_date)
AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
AND	   STY.STREAM_TYPE_PURPOSE =   p_primary_sty_purpose;

  l_product_id 			  					NUMBER;
  l_deal_type              okl_k_headers.deal_type%Type;
  l_report_product_id      NUMBER;
  l_contract_start_date 	DATE;
  l_primary_sty_id 			  	NUMBER;
  l_primary_strm_name 			  	OKL_STRM_TYPE_v.name%Type;

  BEGIN

  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_product_id, l_contract_start_date,l_deal_type,l_report_product_id;
  CLOSE get_k_info_csr;

  IF (l_deal_type <> p_deal_type) THEN
      l_product_id := l_report_product_id;
  END IF;


  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN get_primary_strm_type_csr (l_product_id, l_contract_start_date);
    FETCH get_primary_strm_type_csr INTO l_primary_sty_id,l_primary_strm_name;
      IF  get_primary_strm_type_csr%NOTFOUND THEN
          x_primary_sty_id := null;
          x_primary_sty_name := null;
       ELSE
            x_primary_sty_id := l_primary_sty_id;
            x_primary_sty_name := l_primary_strm_name;
	   END IF;
    CLOSE get_primary_strm_type_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;
   x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_primary_strm_type_csr%ISOPEN THEN
	    CLOSE get_primary_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END get_primary_stream_type;

PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_pdt_id              IN NUMBER,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE) AS

/*CURSOR get_k_info_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id; */
--           30-NOV-04 GKADARKA V115.3 -- Fixes for bug 4036231
--                  Added support for multi GAPP product
--                  Changed the below cursor to get report product id also

    CURSOR get_k_info_csr(  l_khr_id NUMBER ) IS
    SELECT

           pdt.id  pdt_id,
           chr.start_date,
           khr.deal_type,
           nvl(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = chr.id
        AND chr.id = l_khr_id
        AND khr.pdt_id = pdt.id(+);

CURSOR get_depend_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT
  TLN.DEPENDENT_STY_ID,
  STY1.NAME DEPENDENT_STY_NAME
FROM
  OKL_ST_GEN_TMPT_LNS TLN,
  OKL_ST_GEN_TEMPLATES TMPT,
  OKL_ST_GEN_TMPT_SETS Tst,
  OKL_AE_TMPT_SETS AES,
  OKL_PRODUCTS_V PDT,
  OKL_STRM_TYPE_v STY
  ,  OKL_STRM_TYPE_v STY1
WHERE
  TLN.GTT_ID = TMPT.ID AND
  TMPT.GTS_ID = Tst.ID AND
  Tst.ID = AES.GTS_ID AND
  --TST.deal_type = p_deal_type AND
  AES.ID = PDT.AES_ID AND
  TLN.PRIMARY_STY_ID = STY.ID
 AND TLN.DEPENDENT_STY_ID = STY1.ID (+)
  AND TLN.PRIMARY_YN = 'N'
AND PDT.ID = l_pdt_id
AND    (TMPT.START_DATE <= l_contract_start_date)
AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
AND   STY1.STREAM_TYPE_PURPOSE = p_dependent_sty_purpose;

l_product_id 			  					NUMBER;
  l_deal_type              okl_k_headers.deal_type%Type;
  l_report_product_id      NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;
  l_dependetn_sty_name		  					OKL_STRM_TYPE_v.name%Type;

BEGIN
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


    OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_product_id, l_contract_start_date,l_deal_type,l_report_product_id;
  CLOSE get_k_info_csr;

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN get_depend_strm_type_csr (l_product_id, l_contract_start_date);
    FETCH get_depend_strm_type_csr INTO l_dependetn_sty_id,l_dependetn_sty_name;
      IF  get_depend_strm_type_csr%NOTFOUND THEN
             x_dependent_sty_id := null;
             x_dependent_sty_name := null;

       ELSE
                x_dependent_sty_id := l_dependetn_sty_id;
                x_dependent_sty_name := l_dependetn_sty_name;
	 END IF;
     CLOSE get_depend_strm_type_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;
               x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


END get_dependent_stream_type;


-- Start of comments
--
-- Procedure Name	: get_dependent_stream_type
-- Description		: Return dependent Stream type for given purpose code
-- Business Rules	:
-- Parameters		: khr_id
--                  : dependent_sty_purpose
-- Version		: 1.0
--              : 2.0   Now passing contract deal type to get the stream type
----              3.0    Added code to support multi GAPP product
-- End of comments

PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE) AS

/*CURSOR get_k_info_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id; */
--           30-NOV-04 GKADARKA V115.3 -- Fixes for bug 4036231
--                  Added support for multi GAPP product
--                  Changed the below cursor to get report product id also

    CURSOR get_k_info_csr(  l_khr_id NUMBER ) IS
    SELECT

           pdt.id  pdt_id,
           chr.start_date,
           khr.deal_type,
           nvl(pdt.reporting_pdt_id, -1) report_pdt_id
    FROM   okc_k_headers_v chr,
           okl_k_headers khr,
           okl_products_v pdt
    WHERE khr.id = chr.id
        AND chr.id = l_khr_id
        AND khr.pdt_id = pdt.id(+);

CURSOR get_depend_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT
  TLN.DEPENDENT_STY_ID,
  STY1.NAME DEPENDENT_STY_NAME
FROM
  OKL_ST_GEN_TMPT_LNS TLN,
  OKL_ST_GEN_TEMPLATES TMPT,
  OKL_ST_GEN_TMPT_SETS Tst,
  OKL_AE_TMPT_SETS AES,
  OKL_PRODUCTS_V PDT,
  OKL_STRM_TYPE_v STY
  ,  OKL_STRM_TYPE_v STY1
WHERE
  TLN.GTT_ID = TMPT.ID AND
  TMPT.GTS_ID = Tst.ID AND
  Tst.ID = AES.GTS_ID AND
  TST.deal_type = p_deal_type AND
  AES.ID = PDT.AES_ID AND
  TLN.PRIMARY_STY_ID = STY.ID
 AND TLN.DEPENDENT_STY_ID = STY1.ID (+)
  AND TLN.PRIMARY_YN = 'N'
AND PDT.ID = l_pdt_id
AND    (TMPT.START_DATE <= l_contract_start_date)
AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
AND   STY1.STREAM_TYPE_PURPOSE = p_dependent_sty_purpose;

l_product_id 			  					NUMBER;
  l_deal_type              okl_k_headers.deal_type%Type;
  l_report_product_id      NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;
  l_dependetn_sty_name		  					OKL_STRM_TYPE_v.name%Type;

BEGIN
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;


  /*OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_product_id, l_contract_start_date;
  CLOSE get_k_info_csr; */

    OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_product_id, l_contract_start_date,l_deal_type,l_report_product_id;
  CLOSE get_k_info_csr;

  IF (l_deal_type <> p_deal_type) THEN
      l_product_id := l_report_product_id;
  END IF;

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN get_depend_strm_type_csr (l_product_id, l_contract_start_date);
    FETCH get_depend_strm_type_csr INTO l_dependetn_sty_id,l_dependetn_sty_name;
      IF  get_depend_strm_type_csr%NOTFOUND THEN
             x_dependent_sty_id := null;
             x_dependent_sty_name := null;

       ELSE
                x_dependent_sty_id := l_dependetn_sty_id;
                x_dependent_sty_name := l_dependetn_sty_name;
	 END IF;
     CLOSE get_depend_strm_type_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;
               x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


END get_dependent_stream_type;

-- Start of comments
--
-- Procedure Name	: validate_strm_gen_template
-- Description		: Procedure to validate stream generation template
-- Business Rules	:
-- Parameters		: khr_id
--                  :
-- Version		: 1.0
-- End of comments

PROCEDURE validate_strm_gen_template(
           p_api_version                 IN  NUMBER,
           p_init_msg_list               IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
           x_return_status               OUT NOCOPY VARCHAR2,
           x_msg_count                   OUT NOCOPY NUMBER,
           x_msg_data                    OUT NOCOPY VARCHAR2,
           p_khr_id                      IN  NUMBER
         ) AS

CURSOR get_k_info_csr (l_khr_id NUMBER)IS
SELECT  deal_type
FROM     okl_k_headers_h
WHERE id = l_khr_id;

CURSOR get_strm_type_purpose(l_lookup_code VARCHAR2) IS
SELECT LOOKUP_CODE FROM fnd_lookups
WHERE lookup_type = 'OKL_STREAM_TYPE_PURPOSE' AND
lookup_code = l_lookup_code;

-- cursor to get all lines in a contract which line type is in
--('FEE', 'SOLD_SERVICE', 'LINK_SERV_ASSET', 'FREE_FORM1', 'LINK_FEE_ASSET')

cursor l_get_k_lines_csr( p_chr_id NUMBER) is
 select kle.id,
    lse.lty_code,
           kle.oec,
          kle.residual_code,
           kle.capital_amount,
           kle.delivered_date,
           kle.date_funding_required,
           kle.residual_grnty_amount,
           kle.date_funding,
           kle.residual_value,
           kle.amount,
           kle.price_negotiated,
           kle.start_date,
           kle.end_date,
           kle.orig_system_id1,
           kle.fee_type,
           kle.initial_direct_cost,
           tl.item_description,
           tl.name
     from  okl_k_lines_full_v kle,
           okc_line_styles_b lse,
           okc_k_lines_tl tl,
           okc_statuses_b sts
     where KLE.LSE_ID = LSE.ID
          and lse.lty_code IN ('FEE', 'SOLD_SERVICE', 'LINK_SERV_ASSET', 'FREE_FORM1', 'LINK_FEE_ASSET')
   and tl.id = kle.id
          and tl.language = userenv('LANG')
          and kle.dnz_chr_id = p_chr_id
   and sts.code = kle.sts_code
   and sts.ste_code not in ('HOLD', 'TERMINATED', 'EXPIRED','CANCELLED');

   -- Cursor to get all payments for a asset line

       cursor l_rl_csr( chrId NUMBER,cleId NUMBER ) IS
        select crl.id slh_id,
           crl.object1_id1, --stream type id
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10
    from   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    where  crl.rgp_id = crg.id
           and crg.RGD_CODE = 'LALEVL'
           and crl.RULE_INFORMATION_CATEGORY = 'LASLH'
           and crg.dnz_chr_id = chrId
           and crg.cle_id = cleId
    order by crl.RULE_INFORMATION1;

    -- Cursor to get stream_type_purpose

    cursor l_strm_purpose_code(p_sty_id NUMBER) IS
    SELECT  STREAM_TYPE_PURPOSE from okl_strm_type_b
       where id = p_sty_id;

      -- Cursor to get passthrought percentage

    CURSOR c_pt_perc( kleid NUMBER) IS
      SELECT NVL(TO_NUMBER(rul.rule_information1), 100) pass_through_percentage
      FROM   okc_rule_groups_b rgp,
             okc_rules_b rul
      WHERE  rgp.cle_id = kleid
        AND  rgp.rgd_code = 'LAPSTH'
        AND  rgp.id = rul.rgp_id
        AND  rul.rule_information_category = 'LAPTPR';

 -- cursor to get line expense

 CURSOR c_rec_exp (p_khr_id NUMBER, p_kle_id NUMBER) IS
      SELECT TO_NUMBER(rul.rule_information1) periods,
             TO_NUMBER(rul.rule_information2) amount --,
      FROM   okc_rules_b rul,
             okc_rules_b rul2,
             okc_rule_groups_b rgp,
             okc_k_lines_b cle,
             okl_k_lines kle
      WHERE  rgp.dnz_chr_id = p_khr_id
        AND  rgp.cle_id = cle.id
 AND  kle.id = p_kle_id
        AND  cle.sts_code IN ('PASSED', 'COMPLETE')
 AND  kle.fee_type <> 'FINANCED'
 AND  kle.fee_type <> 'ABSORBED'
 AND  kle.fee_type <> 'ROLLOVER'
        AND  rgp.rgd_code = 'LAFEXP'
        AND  rgp.id = rul.rgp_id
        AND  rgp.id = rul2.rgp_id
        AND  rul.rule_information_category = 'LAFEXP'
        AND  rul2.rule_information_category = 'LAFREQ';

        -- cursoer to get initial direct cost

 CURSOR c_fee_idc (p_kle_id NUMBER) IS
      SELECT  NVL(initial_direct_cost, 0)
      FROM    okl_k_lines
      WHERE   id = p_kle_id;


 l_api_name		CONSTANT  VARCHAR2(30) := 'VALIDATE_STRM_GEN_TEMPLATE';
l_product_id 			  					NUMBER;
l_contract_start_date 	DATE;
l_deal_type        VARCHAR2(30);
l_kle_id          NUMBER;
l_lty_code        VARCHAR(30);
l_sty_id          NUMBER;
l_sty_name_purpose    OKL_STRM_TYPE_B.stream_type_purpose%TYPE;
l_primary_flag        VARCHAR2(3) := OKL_API.G_FALSE;
l_dep_flag            VARCHAR2(3) := OKL_API.G_FALSE;
l_return_status   VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
l_primary_sty_id   okl_strm_type_b.ID%TYPE;
l_primary_sty_name  OKL_STRM_TYPE_v.name%TYPE;
l_dependent_sty_id   okl_strm_type_b.ID%TYPE;
l_dependent_sty_name  OKL_STRM_TYPE_v.name%TYPE;
l_fee_type           VARCHAR2(30);
l_recurr_yn VARCHAR2(3):= OKL_API.G_FALSE;
l_pass_through_percentage NUMBER;
l_rec_period NUMBER;
l_expense_amount NUMBER;
l_idc          NUMBER;
l_lookup_strm_purpose    OKL_STRM_TYPE_B.stream_type_purpose%TYPE;


BEGIN
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := okl_api.start_activity (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (x_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

  OPEN get_k_info_csr (p_khr_id);
  FETCH get_k_info_csr INTO l_deal_type;
  CLOSE get_k_info_csr;

 FOR l_get_k_lines_rec IN l_get_k_lines_csr(p_khr_id) LOOP

    l_kle_id := l_get_k_lines_rec.id;
    l_lty_code := l_get_k_lines_rec.lty_code;
    l_fee_type := l_get_k_lines_rec.fee_type;

    IF (l_lty_code = 'FEE') THEN

            OPEN c_pt_perc(l_kle_id); -- only for fees
            FETCH c_pt_perc INTO l_pass_through_percentage;
            CLOSE c_pt_perc;

            OPEN c_rec_exp(p_khr_id,l_kle_id); -- only for fees
            FETCH c_rec_exp INTO l_rec_period,l_expense_amount;
            CLOSE c_rec_exp;

            OPEN c_fee_idc(l_kle_id); --only for fees
            FETCH c_fee_idc INTO l_idc;
            CLOSE c_fee_idc;
    END IF;

    FOR l_rl_rec IN l_rl_csr(p_khr_id,l_kle_id) LOOP
         l_sty_id := l_rl_rec.object1_id1;


         OPEN l_strm_purpose_code (l_sty_id);
         FETCH l_strm_purpose_code INTO l_sty_name_purpose;
         CLOSE l_strm_purpose_code;




       l_return_status         := Okl_Api.G_RET_STS_SUCCESS;

        IF (l_sty_name_purpose = 'RENT') THEN

               l_primary_flag := OKL_API.G_TRUE;

                get_primary_stream_type(
                            p_khr_id  	             => p_khr_id,
							p_deal_type              => l_deal_type,
                            p_primary_sty_purpose    => l_sty_name_purpose,
                            x_return_status		     => l_return_status,
                            x_primary_sty_id 	     => l_primary_sty_id,
                            x_primary_sty_name       => l_primary_sty_name);

                 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                       OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                          p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                          p_token1       => 'PURPOSE_CODE',
                          p_token1_value => l_sty_name_purpose,
                          p_token2		     => 'PRODUCT',
    			          p_token2_value	 => l_deal_type);

                        RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;



             IF (l_deal_type = 'LEASEOP' AND (l_lty_code = 'FREE_FORM1' OR l_lty_code IS NULL)) THEN

                 get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'RENT_ACCRUAL',
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('RENT_ACCRUAL');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);



                        RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
             END IF;

             IF (l_deal_type IN ('LOAN', 'LOAN-REVOLVING'))  THEN

                get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'LOAN_PAYMENT',
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                          OPEN get_strm_type_purpose ('LOAN_PAYMENT');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);



                 END IF;
             END IF;

         END IF;

          IF (l_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING')) OR
         ( l_fee_type = 'FINANCED' OR l_fee_type = 'ROLLOVER' ) THEN

              get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'LEASE_INCOME',     -- PRE-TAX INCOME
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('LEASE_INCOME');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                        RAISE OKL_API.G_EXCEPTION_ERROR;
                 END IF;
          END IF;

         IF (l_deal_type IN ('LEASEDF', 'LEASEST', 'LOAN', 'LOAN-REVOLVING')) THEN

            get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'PRINCIPAL_PAYMENT',     -- PRINCIPAL PAYMENT
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('PRINCIPAL_PAYMENT');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                 END IF;

            get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'INTEREST_PAYMENT',     -- INTEREST PAYMENT
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
                          OPEN get_strm_type_purpose ('INTEREST_PAYMENT');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);


                 END IF;
               get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'PRINCIPAL_BALANCE',     -- PRINCIPAL_BALANCE
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('PRINCIPAL_BALANCE');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                 END IF;

          END IF;


          IF (l_sty_name_purpose = 'RESIDUAL') THEN


                get_primary_stream_type(
                            p_khr_id  	             => p_khr_id,
							p_deal_type             => l_deal_type,
                            p_primary_sty_purpose    => l_sty_name_purpose,
                            x_return_status		     => l_return_status,
                            x_primary_sty_id 	     => l_primary_sty_id,
                            x_primary_sty_name       => l_primary_sty_name);

                 IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN


                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_sty_name_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                 END IF;



           END IF;



          IF ((l_lty_code = 'SOLD_SERVICE') OR (l_lty_code = 'LINK_SERV_ASSET')) THEN

             get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'SERVICE_INCOME',     -- SERVICE INCOME
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('SERVICE_INCOME');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                 END IF;
           END IF;
           IF (l_lty_code IN ('FEE', 'FREE_FORM1') OR l_lty_code IS NULL) AND
            (l_sty_name_purpose <> 'SECURITY_DEPOSIT') THEN

                If ( l_fee_type = 'INCOME' AND l_rec_period IS NULL OR l_rec_period <= 1 ) Then
	                get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'AMORTIZED_FEE_EXPENSE',     -- AMORTIZED_FEE_EXPENSE
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('AMORTIZED_FEE_EXPENSE');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                    END IF;
                 ELSIF (l_fee_type <>  'FINANCED' OR l_fee_type = 'ROLLOVER') THEN
                   get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'FEE_INCOME',     -- AMORTIZED_FEE_EXPENSE
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('FEE_INCOME');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);
                    END IF;

            END IF;

            IF (l_lty_code = 'FEE') THEN
               IF ((l_idc IS NOT NULL) AND (l_idc >=0)) THEN

                    get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'AMORTIZED_FEE_EXPENSE',     -- PASS_THRU_REV_ACCRUAL
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('AMORTIZED_FEE_EXPENSE');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);
                    END IF;
                END IF;

                IF ((l_expense_amount IS NOT NULL) AND (l_expense_amount >=0 )) THEN
                  get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'PERIODIC_EXPENSE_PAYABLE',     -- PERIODIC EXPENSE PAYABLE
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('PERIODIC_EXPENSE_PAYABLE');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);

                    END IF;


                  IF l_pass_through_percentage IS NOT NULL THEN
                     get_dependent_stream_type(
                         p_khr_id  	             => p_khr_id,
						 p_deal_type             => l_deal_type,
                         p_dependent_sty_purpose => 'PASS_THRU_REV_ACCRUAL',     -- PASS_THRU_REV_ACCRUAL
                         x_return_status		=>     l_return_status,
                         x_dependent_sty_id 	=> l_dependent_sty_id,
                         x_dependent_sty_name =>l_dependent_sty_name);

                    IF l_return_status <> OKL_API.G_RET_STS_SUCCESS THEN

                          OPEN get_strm_type_purpose ('PASS_THRU_REV_ACCRUAL');
                          FETCH get_strm_type_purpose INTO l_lookup_strm_purpose;
                          CLOSE get_strm_type_purpose;

                           OKL_API.set_message(p_app_name     => OKL_API.G_APP_NAME,
                                               p_msg_name     => 'OKL_ISG_STRM_TMPL_VAL_MSG',
                                               p_token1       => 'PURPOSE_CODE',
                                               p_token1_value => l_lookup_strm_purpose,
                                               p_token2		     => 'PRODUCT',
    			                               p_token2_value	 => l_deal_type);
                    END IF;
                 END IF;


                END IF;
             END IF;


            END IF;





    END LOOP;





 END LOOP;

 x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

  okl_api.end_activity(x_msg_count => x_msg_count,
                         x_msg_data  => x_msg_data);

 EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

         IF get_k_info_csr%ISOPEN THEN
	        CLOSE get_k_info_csr;
	      END IF;

         IF get_strm_type_purpose%ISOPEN THEN
	        CLOSE get_strm_type_purpose;
	      END IF;

         IF l_get_k_lines_csr%ISOPEN THEN
	        CLOSE l_get_k_lines_csr;
	     END IF;

         IF l_rl_csr%ISOPEN THEN
	         CLOSE l_rl_csr;
	      END IF;

         IF l_strm_purpose_code%ISOPEN THEN
	        CLOSE l_strm_purpose_code;
	     END IF;

         IF c_pt_perc%ISOPEN THEN
	        CLOSE c_pt_perc;
	     END IF;

        IF c_rec_exp%ISOPEN THEN
	        CLOSE c_rec_exp;
	    END IF;

        IF c_fee_idc%ISOPEN THEN
	       CLOSE c_fee_idc;
	    END IF;

      x_return_status := OKL_API.G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

         IF get_k_info_csr%ISOPEN THEN
	        CLOSE get_k_info_csr;
	      END IF;

         IF get_strm_type_purpose%ISOPEN THEN
	        CLOSE get_strm_type_purpose;
	      END IF;

         IF l_get_k_lines_csr%ISOPEN THEN
	        CLOSE l_get_k_lines_csr;
	     END IF;

         IF l_rl_csr%ISOPEN THEN
	         CLOSE l_rl_csr;
	      END IF;

         IF l_strm_purpose_code%ISOPEN THEN
	        CLOSE l_strm_purpose_code;
	     END IF;

         IF c_pt_perc%ISOPEN THEN
	        CLOSE c_pt_perc;
	     END IF;

        IF c_rec_exp%ISOPEN THEN
	        CLOSE c_rec_exp;
	    END IF;

        IF c_fee_idc%ISOPEN THEN
	       CLOSE c_fee_idc;
	    END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

         IF get_k_info_csr%ISOPEN THEN
	        CLOSE get_k_info_csr;
	      END IF;

         IF get_strm_type_purpose%ISOPEN THEN
	        CLOSE get_strm_type_purpose;
	      END IF;

         IF l_get_k_lines_csr%ISOPEN THEN
	        CLOSE l_get_k_lines_csr;
	     END IF;

         IF l_rl_csr%ISOPEN THEN
	         CLOSE l_rl_csr;
	      END IF;

         IF l_strm_purpose_code%ISOPEN THEN
	        CLOSE l_strm_purpose_code;
	     END IF;

         IF c_pt_perc%ISOPEN THEN
	        CLOSE c_pt_perc;
	     END IF;

        IF c_rec_exp%ISOPEN THEN
	        CLOSE c_rec_exp;
	    END IF;

        IF c_fee_idc%ISOPEN THEN
	       CLOSE c_fee_idc;
	    END IF;

      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


END validate_strm_gen_template;

-- Start of comments
--
-- Procedure Name	: get_dependent_stream_type
-- Description		: Return dependent Stream type for given purpose code and primary stream type id
-- Business Rules	:
-- Parameters		: khr_id
--                  : Primary Stram Type id
--                  : dependent_sty_purpose
-- Version		: 1.0
--              : 2.0   Now passing contract deal type to get the stream type
-- End of comments

    PROCEDURE get_dependent_stream_type(
            p_khr_id  		   	     IN NUMBER,
            p_deal_type              IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
            p_primary_sty_id         IN okl_strm_type_b.ID%TYPE,
            p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
            x_return_status		 OUT NOCOPY VARCHAR2,
            x_dependent_sty_id 	 OUT NOCOPY okl_strm_type_b.ID%TYPE,
            x_dependent_sty_name   OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE) AS

CURSOR get_k_info_csr (l_khr_id NUMBER)IS
SELECT pdt_id, start_date
FROM     okl_k_headers_full_v
WHERE id = l_khr_id;

CURSOR get_depend_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
SELECT
  TLN.DEPENDENT_STY_ID,
  STY1.NAME DEPENDENT_STY_NAME
FROM
  OKL_ST_GEN_TMPT_LNS TLN,
  OKL_ST_GEN_TEMPLATES TMPT,
  OKL_ST_GEN_TMPT_SETS Tst,
  OKL_AE_TMPT_SETS AES,
  OKL_PRODUCTS_V PDT,
  OKL_STRM_TYPE_v STY
  ,  OKL_STRM_TYPE_v STY1
WHERE
  TLN.GTT_ID = TMPT.ID AND
  TMPT.GTS_ID = Tst.ID AND
  Tst.ID = AES.GTS_ID AND
  TST.deal_type = p_deal_type AND
  AES.ID = PDT.AES_ID AND
  TLN.PRIMARY_STY_ID = STY.ID AND
   TLN.PRIMARY_STY_ID = p_primary_sty_id
 AND TLN.DEPENDENT_STY_ID = STY1.ID (+)
  AND TLN.PRIMARY_YN = 'N'
AND PDT.ID = l_pdt_id
AND    (TMPT.START_DATE <= l_contract_start_date)
AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
AND   STY1.STREAM_TYPE_PURPOSE = p_dependent_sty_purpose;

l_product_id 			  					NUMBER;
  l_contract_start_date 	DATE;
  l_dependetn_sty_id 			  					NUMBER;
  l_dependetn_sty_name		  					OKL_STRM_TYPE_v.name%Type;
  -- kthiruva bug#4371472 start
  l_deal_type           okl_k_headers.deal_type%Type;
  l_report_product_id   NUMBER;
  -- kthiruva bug#4371472 end
BEGIN
  x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

   -- kthiruva bug#4371472 start
   FOR tmp_rec in G_GET_K_INFO_CSR (p_khr_id)
     LOOP
      l_product_id := tmp_rec.pdt_id;
      l_contract_start_date := tmp_rec.start_date;
      l_deal_type  := tmp_rec.deal_type;
      l_report_product_id := tmp_rec.report_pdt_id;
     END LOOP;

    IF (l_deal_type <> p_deal_type) THEN
        l_product_id := l_report_product_id;
    END IF;
   -- kthiruva bug#4371472 end

  IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN

    OPEN get_depend_strm_type_csr (l_product_id, l_contract_start_date);
    FETCH get_depend_strm_type_csr INTO l_dependetn_sty_id,l_dependetn_sty_name;
      IF  get_depend_strm_type_csr%NOTFOUND THEN
             x_dependent_sty_id := null;
             x_dependent_sty_name := null;

       ELSE
                x_dependent_sty_id := l_dependetn_sty_id;
                x_dependent_sty_name := l_dependetn_sty_name;
	 END IF;
     CLOSE get_depend_strm_type_csr;

  ELSE

	        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_NO_PDT_FOUND');
            RAISE Okl_Api.G_EXCEPTION_ERROR;

  END IF;
               x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF get_k_info_csr%ISOPEN THEN
	    CLOSE get_k_info_csr;
	 END IF;
     IF get_depend_strm_type_csr%ISOPEN THEN
	    CLOSE get_depend_strm_type_csr;
	 END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;


END get_dependent_stream_type;

    -- Added by RGOOTY: Start
    -- Functions Added for improving the performance for ISG
    PROCEDURE get_dep_stream_type(
                p_khr_id  		IN NUMBER,
                p_deal_type             IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
                p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
                x_return_status		OUT NOCOPY VARCHAR2,
                x_dependent_sty_id 	OUT NOCOPY okl_strm_type_b.ID%TYPE,
                x_dependent_sty_name    OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE,
                p_get_k_info_rec        IN G_GET_K_INFO_CSR%ROWTYPE) AS

        CURSOR get_depend_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
        SELECT
          TLN.DEPENDENT_STY_ID,
          STY1.NAME DEPENDENT_STY_NAME
        FROM
          OKL_ST_GEN_TMPT_LNS TLN,
          OKL_ST_GEN_TEMPLATES TMPT,
          OKL_ST_GEN_TMPT_SETS Tst,
          OKL_AE_TMPT_SETS AES,
          OKL_PRODUCTS_V PDT,
          OKL_STRM_TYPE_v STY
          ,  OKL_STRM_TYPE_v STY1
        WHERE
          TLN.GTT_ID = TMPT.ID AND
          TMPT.GTS_ID = Tst.ID AND
          Tst.ID = AES.GTS_ID AND
          TST.deal_type = p_deal_type AND
          AES.ID = PDT.AES_ID AND
          TLN.PRIMARY_STY_ID = STY.ID
         AND TLN.DEPENDENT_STY_ID = STY1.ID (+)
          AND TLN.PRIMARY_YN = 'N'
        AND PDT.ID = l_pdt_id
        AND    (TMPT.START_DATE <= l_contract_start_date)
        AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
        AND   STY1.STREAM_TYPE_PURPOSE = p_dependent_sty_purpose;

      l_product_id 		NUMBER;
      l_deal_type               okl_k_headers.deal_type%Type;
      l_report_product_id       NUMBER;
      l_contract_start_date 	DATE;
      l_dependetn_sty_id	NUMBER;
      l_dependetn_sty_name	OKL_STRM_TYPE_v.name%Type;

    BEGIN
      x_return_status         := Okl_Api.G_RET_STS_SUCCESS;

      IF p_get_k_info_rec.pdt_id IS NULL
      THEN
          OPEN G_GET_K_INFO_CSR (p_khr_id);
          FETCH G_GET_K_INFO_CSR INTO l_product_id, l_contract_start_date,l_deal_type,l_report_product_id;
          CLOSE G_GET_K_INFO_CSR;
      ELSE
        l_product_id := p_get_k_info_rec.pdt_id;
        l_contract_start_date := p_get_k_info_rec.start_date;
        l_deal_type := p_get_k_info_rec.deal_type;
        l_report_product_id := p_get_k_info_rec.report_pdt_id;
      END IF;

      IF (l_deal_type <> p_deal_type) THEN
          l_product_id := l_report_product_id;
      END IF;

      IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN
        OPEN get_depend_strm_type_csr (l_product_id, l_contract_start_date);
        FETCH get_depend_strm_type_csr INTO l_dependetn_sty_id,l_dependetn_sty_name;
          IF  get_depend_strm_type_csr%NOTFOUND THEN
                x_dependent_sty_id := null;
                x_dependent_sty_name := null;
           ELSE
		x_dependent_sty_id := l_dependetn_sty_id;
                x_dependent_sty_name := l_dependetn_sty_name;
    	 END IF;
         CLOSE get_depend_strm_type_csr;

      ELSE
        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_NO_PDT_FOUND');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
    EXCEPTION
      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_ERROR ;

      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END get_dep_stream_type;

    -- Overloaded get_dep_stream_type
    PROCEDURE get_dep_stream_type(
                p_khr_id  		IN NUMBER,
                p_deal_type             IN OKL_ST_GEN_TMPT_SETS.deal_type%TYPE,
                p_primary_sty_id        IN okl_strm_type_b.ID%TYPE,
                p_dependent_sty_purpose IN okl_strm_type_b.STREAM_TYPE_PURPOSE%TYPE,
                x_return_status		OUT NOCOPY VARCHAR2,
                x_dependent_sty_id 	OUT NOCOPY okl_strm_type_b.ID%TYPE,
                x_dependent_sty_name    OUT NOCOPY OKL_STRM_TYPE_v.name%TYPE,
                p_get_k_info_rec        IN G_GET_K_INFO_CSR%ROWTYPE) AS

        CURSOR get_depend_strm_type_csr (l_pdt_id NUMBER, l_contract_start_date DATE) IS
        SELECT
          TLN.DEPENDENT_STY_ID,
          STY1.NAME DEPENDENT_STY_NAME
        FROM
          OKL_ST_GEN_TMPT_LNS TLN,
          OKL_ST_GEN_TEMPLATES TMPT,
          OKL_ST_GEN_TMPT_SETS Tst,
          OKL_AE_TMPT_SETS AES,
          OKL_PRODUCTS_V PDT,
          OKL_STRM_TYPE_v STY
          ,  OKL_STRM_TYPE_v STY1
        WHERE
          TLN.GTT_ID = TMPT.ID AND
          TMPT.GTS_ID = Tst.ID AND
          Tst.ID = AES.GTS_ID AND
          TST.deal_type = p_deal_type AND
          AES.ID = PDT.AES_ID AND
          TLN.PRIMARY_STY_ID = STY.ID AND
           TLN.PRIMARY_STY_ID = p_primary_sty_id
         AND TLN.DEPENDENT_STY_ID = STY1.ID (+)
          AND TLN.PRIMARY_YN = 'N'
        AND PDT.ID = l_pdt_id
        AND    (TMPT.START_DATE <= l_contract_start_date)
        AND    (TMPT.END_DATE >= l_contract_start_date OR TMPT.END_DATE IS NULL)
        AND   STY1.STREAM_TYPE_PURPOSE = p_dependent_sty_purpose;

      l_product_id 		NUMBER;
      l_contract_start_date 	DATE;
      l_dependetn_sty_id 	NUMBER;
      l_dependetn_sty_name	OKL_STRM_TYPE_v.name%Type;
      --bug#4371472 kthiruva start
      l_deal_type           okl_k_headers.deal_type%Type;
      l_report_product_id   NUMBER;
      --bug#4371472 kthiruva end

    BEGIN
      x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
      IF p_get_k_info_rec.pdt_id IS NULL
      THEN
          FOR tmp_rec in G_GET_K_INFO_CSR (p_khr_id)
          LOOP
            l_product_id := tmp_rec.pdt_id;
            l_contract_start_date := tmp_rec.start_date;
          END LOOP;
      ELSE
        l_product_id := p_get_k_info_rec.pdt_id;
        l_contract_start_date := p_get_k_info_rec.start_date;
        --bug#4371472 kthiruva start
        l_deal_type  := p_get_k_info_rec.deal_type;
        l_report_product_id := p_get_k_info_rec.report_pdt_id;
        --bug#4371472 kthiruva end
      END IF;
      --bug#4371472 kthiruva start
      IF (l_deal_type <> p_deal_type) THEN
          l_product_id := l_report_product_id;
      END IF;
      --bug#4371472 kthiruva end

      IF (l_product_id IS NOT NULL) AND (l_contract_start_date IS NOT NULL) THEN
        OPEN get_depend_strm_type_csr (l_product_id, l_contract_start_date);
        FETCH get_depend_strm_type_csr INTO l_dependetn_sty_id,l_dependetn_sty_name;
          IF  get_depend_strm_type_csr%NOTFOUND THEN
                x_dependent_sty_id := null;
                x_dependent_sty_name := null;
           ELSE
                x_dependent_sty_id := l_dependetn_sty_id;
                x_dependent_sty_name := l_dependetn_sty_name;
    	 END IF;
         CLOSE get_depend_strm_type_csr;
      ELSE
        Okl_Api.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => 'OKL_NO_PDT_FOUND');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;
      x_return_status         := Okl_Api.G_RET_STS_SUCCESS;
    EXCEPTION
      WHEN Okl_Api.G_EXCEPTION_ERROR THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_ERROR ;

      WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN
         IF G_GET_K_INFO_CSR%ISOPEN THEN
    	    CLOSE G_GET_K_INFO_CSR;
    	 END IF;
         IF get_depend_strm_type_csr%ISOPEN THEN
    	    CLOSE get_depend_strm_type_csr;
    	 END IF;
         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    END get_dep_stream_type;
    -- Added by RGOOTY: End


-- Added by DJANASWA: Start  6274342
-- Start of comments
--      API name        : get_arrears_pay_dates_option
--      Pre-reqs        : None
--      Function        : Gets the Arrears Payment Dates Option set at
--                        Setup/System Options/Accounting Options
--                        or overwritten at STG
--      Parameters      :
--      IN      :  p_khr_id  IN NUMBER  Required
--               Corresponds to the column ID
--               in the table okl_k_headers.
--      Version : 1.0
--      History   :  Added by DJANASWA for ER 6274342
-- End of comments


PROCEDURE get_arrears_pay_dates_option(
    p_khr_id                   IN  NUMBER,
    x_arrears_pay_dates_option OUT NOCOPY VARCHAR2,
    x_return_status            OUT NOCOPY VARCHAR2)
  IS
    l_arrears_pay_dates_option  VARCHAR2(60);
    l_api_name                  VARCHAR2(30) := 'get_arrears_pay_dates_option';
    l_return_status             VARCHAR2(1);


CURSOR c_arrears_option_at_sgt_csr (p_khr_id NUMBER)
IS
SELECT
  tst.isg_arrears_pay_dates_option
FROM
  okl_st_gen_tmpt_sets tst,
  okl_ae_tmpt_sets_all aes,
  okl_products_v pdt,
  okl_k_headers  khr
WHERE
    khr.id = p_khr_id
AND pdt.id = khr.pdt_id
AND aes.id = pdt.aes_id
AND tst.id = aes.gts_id
;

  BEGIN


    -- Initialize the status
    l_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  c_arrears_option_at_sgt_csr (p_khr_id => p_khr_id);
    FETCH c_arrears_option_at_sgt_csr  INTO l_arrears_pay_dates_option;
    CLOSE c_arrears_option_at_sgt_csr;

    -- Return things
    x_arrears_pay_dates_option := l_arrears_pay_dates_option;
    x_return_status := l_return_status;

 EXCEPTION
  WHEN Okl_Api.G_EXCEPTION_ERROR THEN
     IF c_arrears_option_at_sgt_csr%ISOPEN THEN
            CLOSE c_arrears_option_at_sgt_csr;
     END IF;
     x_return_status := Okl_Api.G_RET_STS_ERROR ;

  WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
     IF c_arrears_option_at_sgt_csr%ISOPEN THEN
            CLOSE c_arrears_option_at_sgt_csr;
     END IF;
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS THEN
     IF c_arrears_option_at_sgt_csr%ISOPEN THEN
            CLOSE c_arrears_option_at_sgt_csr;
     END IF;

      OKL_API.SET_MESSAGE (
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_DB_ERROR,
        p_token1       => G_PROG_NAME_TOKEN,
        p_token1_value => l_api_name,
        p_token2       => G_SQLCODE_TOKEN,
        p_token2_value => sqlcode,
        p_token3       => G_SQLERRM_TOKEN,
        p_token3_value => sqlerrm);
     x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
  END get_arrears_pay_dates_option;
-- end DJANASWA ER6274342

END OKL_ISG_UTILS_PVT;

/
