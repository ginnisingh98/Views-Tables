--------------------------------------------------------
--  DDL for Package Body OKL_QA_DATA_INTEGRITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QA_DATA_INTEGRITY" AS
/* $Header: OKLRQADB.pls 120.153.12010000.21 2010/04/06 11:34:56 nikshah ship $ */

    G_MODULE VARCHAR2(255) := 'okl.stream.esg.okl_esg_transport_pvt';
    G_DEBUG_ENABLED CONSTANT VARCHAR2(10) := OKL_DEBUG_PUB.CHECK_LOG_ENABLED;
    G_IS_DEBUG_STATEMENT_ON BOOLEAN;
--rviriyal Bug#5982201
-- sjalasut, added global message constants as part of subsidy pools enhancement. START
G_SUB_POOL_NOT_ACTIVE CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_NOT_ACTIVE';
G_SUB_POOL_BALANCE_INVALID CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_INVALID_BAL';
G_SUB_POOL_ASSET_DATES_GAP CONSTANT fnd_new_messages.message_name%TYPE DEFAULT 'OKL_SUB_POOL_ASSET_DATES';
-- sjalasut, added global message constants as part of subsidy pools enhancement. END
G_PROD_PARAMS_NOT_FOUND   CONSTANT VARCHAR2(200)  := 'OKL_LLA_PDT_PARAM_NOT_FOUND';
G_PROD_NAME_TOKEN         CONSTANT VARCHAR2(200)  := 'PRODUCT_NAME';

-- bug 6760186 start
G_IB_LINE_LTY_ID         NUMBER        := 45;
G_TSU_CODE_ENTERED       Varchar2(30)  := 'ENTERED';
G_TRX_LINE_TYPE_BOOK     Varchar2(30)  := 'CFA';
-- bug 6760186 end


  -- Start of comments
  --
  -- Procedure Name  : check_evergreen_allowed
  -- Description     : Bug#4917116 For LOAN and LOAN-REVOLVING evergreen
  --                   eligible should not be set.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_evergreen_allowed(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

   l_eg_eligible               OKC_RULES_B.RULE_INFORMATION1%TYPE;

   --Cursor to get the deal type of the contract
   CURSOR deal_type_csr (p_chr_id IN NUMBER) IS
   SELECT DEAL_TYPE
   FROM   OKL_K_HEADERS
   WHERE  ID = p_chr_id;

   --Cursor to get the Evergreen eligible flag
   CURSOR eligible_csr (p_chr_id IN NUMBER) IS
   SELECT RULE_INFORMATION1
   FROM OKC_RULES_B
   WHERE RULE_INFORMATION_CATEGORY = 'LAEVEL'
   AND DNZ_CHR_ID = p_chr_id;

   l_deal_type OKL_K_HEADERS.DEAL_TYPE%TYPE;

  BEGIN

   -- initialize return status
   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   OPEN eligible_csr (p_chr_id);
   FETCH eligible_csr INTO l_eg_eligible;
   CLOSE eligible_csr;

   IF (NVL(l_eg_eligible,'N') = 'Y') THEN
     OPEN deal_type_csr(p_chr_id);
     FETCH deal_type_csr INTO l_deal_type;
     CLOSE deal_type_csr;

     IF (NVL(l_deal_type,'X') IN ('LOAN', 'LOAN-REVOLVING')) THEN

       Okl_Api.set_message(
           p_app_name        => G_APP_NAME,
           p_msg_name        => 'OKL_EVERGREEN_NOT_ALLOWED',
           p_token1	     => 'DEAL_TYPE',
           p_token1_value    => l_deal_type);

       x_return_status := Okl_Api.G_RET_STS_ERROR;

     END IF;
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
      -- store SQL error message on message stack
	  Okl_Api.SET_MESSAGE(
          p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1	   	    => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF eligible_csr%ISOPEN THEN
         CLOSE eligible_csr;
       END IF;

      IF deal_type_csr%ISOPEN THEN
        CLOSE deal_type_csr;
      END IF;

  END check_evergreen_allowed;

  -- Start of comments
  --
  -- Procedure Name  : check_evergreen_pth
  -- Description     : Bug#4872437 ramurt. Check the fields Evergreen Passthrough Vendor
  --                   and Evergreen Passthrough Vendor Site for mandatory if
  --                   the Evergreen Eligible flag is checked in T and C
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_evergreen_pth(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

   l_eg_eligible               OKC_RULES_B.RULE_INFORMATION1%TYPE;
   l_eg_passthru_vendor        OKC_RULES_B.OBJECT1_ID1%TYPE;
   l_eg_passthru_vendor_site   OKC_RULES_B.OBJECT2_ID1%TYPE;

   --Cursor to get the Evergreen eligible flag
   CURSOR eligible_csr (p_chr_id IN NUMBER) IS
   SELECT RULE_INFORMATION1
   FROM OKC_RULES_B
   WHERE RULE_INFORMATION_CATEGORY = 'LAEVEL'
   AND DNZ_CHR_ID = p_chr_id;

   --Cursor to get the values of Evergreen Passthrough Vendor and Evergreen Passthrough Vendor Site
   CURSOR evergreen_passthru_csr (p_chr_id IN NUMBER) IS
   SELECT OBJECT1_ID1,OBJECT2_ID1
   FROM OKC_RULES_B
   WHERE RULE_INFORMATION_CATEGORY = 'LAEVPT'
   AND DNZ_CHR_ID = p_chr_id;

   --Cursor to get the deal type of the contract
   CURSOR deal_type_csr (p_chr_id IN NUMBER) IS
   SELECT DEAL_TYPE
   FROM   OKL_K_HEADERS
   WHERE  ID = p_chr_id;

   l_deal_type OKL_K_HEADERS.DEAL_TYPE%TYPE;
  BEGIN

   -- initialize return status
   x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  OPEN eligible_csr (p_chr_id);
  FETCH eligible_csr INTO l_eg_eligible;
  CLOSE eligible_csr;

  OPEN deal_type_csr(p_chr_id);
  FETCH deal_type_csr INTO l_deal_type;
  CLOSE deal_type_csr;

   IF (l_eg_eligible = 'Y') THEN
     IF (NVL(l_deal_type,'X') NOT IN ('LOAN', 'LOAN-REVOLVING')) THEN

       OPEN evergreen_passthru_csr (p_chr_id);
       FETCH evergreen_passthru_csr INTO l_eg_passthru_vendor, l_eg_passthru_vendor_site;
       CLOSE evergreen_passthru_csr;

       IF (l_eg_passthru_vendor IS NULL OR l_eg_passthru_vendor_site IS NULL) THEN

         Okl_Api.set_message(
             p_app_name => G_APP_NAME,
             p_msg_name => 'OKL_REQ_EVERGREEN_PTH');

         x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
     END IF;
   END IF;

  EXCEPTION
     WHEN OTHERS THEN
      -- store SQL error message on message stack
	  Okl_Api.SET_MESSAGE(
          p_app_name        => G_APP_NAME,
          p_msg_name        => G_UNEXPECTED_ERROR,
          p_token1	   	    => G_SQLCODE_TOKEN,
          p_token1_value    => SQLCODE,
          p_token2          => G_SQLERRM_TOKEN,
          p_token2_value    => SQLERRM);
      x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

      IF eligible_csr%ISOPEN THEN
        CLOSE eligible_csr;
      END IF;

      IF deal_type_csr%ISOPEN THEN
        CLOSE deal_type_csr;
      END IF;

      IF evergreen_passthru_csr%ISOPEN THEN
        CLOSE evergreen_passthru_csr;
      END IF;

  END check_evergreen_pth;

------------------------------------------------------------------------------
-- PROCEDURE get_bill_to
--
--  This procedure returns bill to id from contract header
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_bill_to(
                         x_return_status  OUT NOCOPY VARCHAR2,
                         p_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                         x_bill_to_id     OUT NOCOPY OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE
                        ) IS

   l_proc_name   VARCHAR2(35) := 'GET_BILL_TO';

   CURSOR bill_to_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT bill_to_site_use_id
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   bill_to_failed EXCEPTION;

   BEGIN
     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     x_bill_to_id := NULL;
     OPEN bill_to_csr (p_chr_id);
     FETCH bill_to_csr INTO x_bill_to_id;
     IF bill_to_csr%NOTFOUND THEN
        RAISE bill_to_failed;
     END IF;
     CLOSE bill_to_csr;

     IF (x_bill_to_id IS NULL) THEN
        RAISE bill_to_failed;
     END IF;

     RETURN;

   EXCEPTION

     WHEN bill_to_failed THEN
        IF bill_to_csr%ISOPEN THEN
           CLOSE bill_to_csr;
        END IF;

        x_return_status := Okl_Api.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;

   END get_bill_to;

------------------------------------------------------------------------------
-- PROCEDURE get_cust_account
--
--  This procedure returns bill to id from contract header
--
-- Calls:
-- Called By:
------------------------------------------------------------------------------
   PROCEDURE get_cust_account(
                         x_return_status  OUT NOCOPY VARCHAR2,
                         p_chr_id         IN  OKC_K_HEADERS_B.ID%TYPE,
                         x_cust_acc_id    OUT NOCOPY OKC_K_HEADERS_B.CUST_ACCT_ID%TYPE
                        ) IS

   l_proc_name   VARCHAR2(35) := 'GET_CUST_ACCOUNT';

   CURSOR cust_acc_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
   SELECT cust_acct_id
   FROM   okc_k_headers_b
   WHERE  id = p_chr_id;

   cust_acc_failed EXCEPTION;

   BEGIN
     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     x_cust_acc_id := NULL;
     OPEN cust_acc_csr (p_chr_id);
     FETCH cust_acc_csr INTO x_cust_acc_id;
     IF cust_acc_csr%NOTFOUND THEN
        RAISE cust_acc_failed;
     END IF;
     CLOSE cust_acc_csr;

     IF (x_cust_acc_id IS NULL) THEN
        RAISE cust_acc_failed;
     END IF;

     RETURN;

   EXCEPTION

     WHEN cust_acc_failed THEN
        IF cust_acc_csr%ISOPEN THEN
           CLOSE cust_acc_csr;
        END IF;

        x_return_status := Okl_Api.G_RET_STS_ERROR;

     WHEN OTHERS THEN
       x_return_status := Okc_Api.G_RET_STS_ERROR;

   END get_cust_account;

--Bug# 2833653
  -- Start of comments
  --
  -- Procedure Name  : Are_Assets_Inactive
  -- Description     : Local function to determine if all the assets on contract are Not active
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  -- Start of comments
  --
  FUNCTION Are_Assets_Inactive (p_chr_id IN NUMBER) RETURN  VARCHAR2 IS

      --Bug# 4928841 :Modified cursor definition
      /*
      CURSOR inactive_assets_csr(chrId IN NUMBER) IS
      SELECT 'Y'
      FROM   DUAL
      WHERE  EXISTS
      (
      SELECT 'Y'
      FROM   OKC_K_ITEMS fa_cim,
             OKC_K_LINES_B fa_cle,
             OKC_LINE_STYLES_B fa_lse,
             OKC_STATUSES_B fa_sts
      WHERE  fa_cim.cle_id = fa_cle.id
      AND    fa_cim.dnz_chr_id = fa_cle.dnz_chr_id
      AND    fa_cle.dnz_chr_id = chrid
      AND    fa_cle.lse_id     = fa_lse.id
      AND    fa_lse.lty_code   = 'FIXED_ASSET'
      AND    fa_cle.sts_code   = fa_sts.code
      AND    fa_sts.ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED')
      AND    fa_cim.object1_id1 IS NULL
      AND    EXISTS (SELECT '1'
                     FROM   OKC_K_LINES_B     fa_cle2,
                            OKC_LINE_STYLES_B fa_lse2,
                            OKC_STATUSES_B    fa_sts2
                     WHERE  fa_cle2.lse_id = fa_lse2.id
                     AND    fa_lse2.lty_code = 'FIXED_ASSET'
                     AND    fa_cle2.sts_code = fa_sts2.code
                     AND    fa_sts2.ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED')
                     AND    fa_cle2.dnz_chr_id = chrid
                    )
      UNION
      SELECT 'Y'
      FROM   OKC_K_ITEMS fa_cim,
             OKC_K_LINES_B fa_cle,
             OKC_LINE_STYLES_B fa_lse,
             OKC_STATUSES_B fa_sts
      WHERE  fa_cim.cle_id = fa_cle.id
      AND    fa_cim.dnz_chr_id = fa_cle.dnz_chr_id
      AND    fa_cle.dnz_chr_id = chrid
      AND    fa_cle.lse_id     = fa_lse.id
      AND    fa_lse.lty_code   = 'FIXED_ASSET'
      AND    fa_cle.sts_code   = fa_sts.code
      AND    fa_sts.ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED')
      AND    fa_cim.object1_id1 IS NOT NULL
      AND NOT EXISTS(SELECT '1'
                     FROM   FA_ADDITIONS_B FAB
                     WHERE  FAB.Asset_id = TO_NUMBER(fa_cim.object1_id1)
                    )
      AND    EXISTS (SELECT '1'
                     FROM   OKC_K_LINES_B     fa_cle2,
                            OKC_LINE_STYLES_B fa_lse2,
                            OKC_STATUSES_B    fa_sts2
                     WHERE  fa_cle2.lse_id  = fa_lse2.id
                     AND    fa_lse2.lty_code = 'FIXED_ASSET'
                     AND    fa_cle2.sts_code = fa_sts2.code
                     AND    fa_sts2.ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED')
                     AND    fa_cle2.dnz_chr_id = chrid
                    ) ); */

      CURSOR inactive_assets_csr(chrId IN NUMBER) IS
      SELECT 'Y'
      FROM   DUAL
      WHERE  EXISTS
      (
	SELECT 1
	FROM OKC_K_LINES_B fa_cle,
	OKC_LINE_STYLES_B fa_lse,
	OKC_STATUSES_B fa_sts,
	OKC_K_ITEMS fa_cim,
	FA_ADDITIONS_B FAB
	WHERE fa_cim.cle_id = fa_cle.id
	AND fa_cim.dnz_chr_id = fa_cle.dnz_chr_id
	AND fa_cle.dnz_chr_id =  chrId
	AND fa_cle.lse_id = fa_lse.id
	AND fa_lse.lty_code = 'FIXED_ASSET'
	AND fa_cle.sts_code = fa_sts.code
	AND fa_sts.ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED')
	AND FAB.Asset_id(+) = fa_cim.object1_id1
	AND FAB.Asset_id is null
      );
      --End Bug# 4928841 :Modified cursor definition

      l_inactive_assets VARCHAR2(1) DEFAULT 'N';
      --cursor to check if there are any lines on the contract
      CURSOR l_lines_exist_csr(chrid NUMBER) IS
      SELECT 'Y'
      FROM    okc_k_headers_b chrb
      WHERE   chrb.id = chrid
      AND EXISTS (SELECT '1'
                  FROM   okc_k_lines_b cleb
                  WHERE  cleb.chr_id = chrb.id
                  AND    cleb.dnz_chr_id = chrb.id);
     l_lines_exist VARCHAR2(1) DEFAULT 'N';
     l_halt_process EXCEPTION;
BEGIN
    l_inactive_assets := 'N';
    l_lines_exist := 'N';
    OPEN l_lines_exist_csr(chrid => p_chr_id);
    FETCH l_lines_exist_csr INTO l_lines_exist;
    IF l_lines_exist_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_lines_exist_csr;

    IF l_lines_exist = 'N' THEN
       l_inactive_assets := 'Y';
       RAISE l_halt_process;
    END IF;

    OPEN inactive_assets_csr(chrid => p_chr_id);
    FETCH inactive_assets_csr INTO l_inactive_assets;
    IF inactive_assets_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE inactive_assets_csr;
    RETURN(l_inactive_assets);
    EXCEPTION
    WHEN l_halt_process THEN
        RETURN(l_inactive_assets);
    WHEN OTHERS THEN
         IF inactive_assets_csr%ISOPEN THEN
             CLOSE inactive_assets_csr;
         END IF;
         IF l_lines_exist_csr%ISOPEN THEN
             CLOSE l_lines_exist_csr;
         END IF;
         RETURN('Y');
END are_assets_Inactive;
--Bug# 2833653

  -- Procedure Name  : check_service_line_hdr
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_service_line_hdr(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);
    x_link_line_tbl   Okl_Service_Integration_Pub.LINK_LINE_TBL_TYPE;
    x_service_contract_id  NUMBER;

    i NUMBER;

    l_hdr_rec1 l_hdr_csr%ROWTYPE;
    l_hdr_rec2 l_hdr_csr%ROWTYPE;

    cust_rec1 cust_csr%ROWTYPE;
    cust_rec2 cust_csr%ROWTYPE;

    l_oksrl_rec l_oksrl_csr%ROWTYPE;
    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

    l_okl_bill_to_id OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE;
    l_oks_bill_to_id OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Service_Integration_Pub.get_service_link_line (
                                   p_api_version   => 1.0,
                                   p_init_msg_list => Okl_Api.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_lease_contract_id => p_chr_id,
                                   x_link_line_tbl => x_link_line_tbl,
                                   x_service_contract_id => x_service_contract_id);

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF ( NVL(x_service_contract_id, -1 ) = -1 ) THEN
        x_return_status := Okl_Api.G_RET_STS_SUCCESS;
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
	RETURN;
    END IF;

    OPEN l_hdr_csr( p_chr_id );
    FETCH l_hdr_csr INTO l_hdr_rec1;
    CLOSE l_hdr_csr;

    OPEN l_hdr_csr( x_service_contract_id );
    FETCH l_hdr_csr INTO l_hdr_rec2;
    CLOSE l_hdr_csr;

    IF ( l_hdr_rec1.CURRENCY_CODE <> l_hdr_rec2.CURRENCY_CODE ) THEN
           Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OKL_OKS_CURR');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    OPEN cust_csr('LESSEE', p_chr_id );
    FETCH cust_csr INTO cust_rec1;
    CLOSE cust_csr;

    OPEN cust_csr('CUSTOMER',  x_service_contract_id );
    FETCH cust_csr INTO cust_rec2;
    CLOSE cust_csr;

    IF ( cust_rec1.Object1_id1 <> cust_rec2.Object1_id1 ) THEN
           Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OKL_OKS_CUST');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

/* Rule migration

    OPEN  l_hdrrl_csr('LABILL', 'BTO', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr into l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
*/
      get_bill_to(
                  x_return_status => x_return_status,
                  p_chr_id        => p_chr_id,
                  x_bill_to_id    => l_okl_bill_to_id
                 );

/* Rule migration
    OPEN  l_oksrl_csr('BTO', x_service_contract_id, -1);
    FETCH l_oksrl_csr into l_oksrl_rec;
    CLOSE l_oksrl_csr;
*/

      get_bill_to(
                  x_return_status => x_return_status,
                  p_chr_id        => x_service_contract_id,
                  x_bill_to_id    => l_oks_bill_to_id
                 );

    --If( l_hdrrl_rec.object1_id1 <> l_oksrl_rec.object1_id1 ) Then
    IF( l_okl_bill_to_id <> l_oks_bill_to_id) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OKL_OKS_BTO');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_service_line_hdr;


  -- Start of comments
  --
  -- Procedure Name  : check_cov_service_lines
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_cov_service_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);
    x_link_line_tbl   Okl_Service_Integration_Pub.LINK_LINE_TBL_TYPE;
    x_service_contract_id  NUMBER;

    l_svclne l_svclne_csr%ROWTYPE;

    i NUMBER;
    n NUMBER;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Service_Integration_Pub.get_service_link_line (
                                   p_api_version   => 1.0,
                                   p_init_msg_list => Okl_Api.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_lease_contract_id => p_chr_id,
                                   x_link_line_tbl => x_link_line_tbl,
                                   x_service_contract_id => x_service_contract_id);

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF ( NVL(x_service_contract_id, -1 ) = -1 ) THEN
        x_return_status := Okl_Api.G_RET_STS_SUCCESS;
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
	RETURN;
    END IF;

    n := 0;
    FOR l_svclne IN l_svclne_csr( 'COVER_PROD', x_service_contract_id )
    LOOP
        n := n+1;
    END LOOP;

    IF ( n > x_link_line_tbl.COUNT ) THEN
           Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OKL_OKS_COV');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;


    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_cov_service_lines;

  -- Start of comments
  --
  -- Procedure Name  : check_service_lines
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_service_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);
    x_link_line_tbl   Okl_Service_Integration_Pub.LINK_LINE_TBL_TYPE;
    x_service_contract_id  NUMBER;

    CURSOR srv_csr (p_serv_top_line_id NUMBER) IS
    SELECT item_id inventory_item_id,
           SUM(service_item_qty) quantity
    FROM   okl_la_cov_asset_uv
    WHERE  serv_top_line_id = p_serv_top_line_id
    GROUP BY item_id;

    l_lne l_lne_csr%ROWTYPE;
    l_sublne l_subline_csr%ROWTYPE;
    --l_svclne l_svcline_csr%ROWTYPE;
    l_svclne srv_csr%ROWTYPE;

    l_toplne l_toplne_csr%ROWTYPE;
    l_topsvclne l_topsvclne_csr%ROWTYPE;
    l_rl_rec1 l_rl_csr1%ROWTYPE;

    i NUMBER;
    j NUMBER;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Service_Integration_Pub.get_service_link_line (
                                   p_api_version   => 1.0,
                                   p_init_msg_list => Okl_Api.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_lease_contract_id => p_chr_id,
                                   x_link_line_tbl => x_link_line_tbl,
                                   x_service_contract_id => x_service_contract_id);

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF ( NVL(x_service_contract_id, -1 ) = -1 ) THEN
        x_return_status := Okl_Api.G_RET_STS_SUCCESS;
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
	RETURN;
    END IF;

    FOR l_svclne IN l_svclne_csr( 'SERVICE', x_service_contract_id )
    LOOP
        j := -1;
        FOR i IN 1..x_link_line_tbl.COUNT
        LOOP

            OPEN  l_topsvclne_csr( 'SERVICE', x_service_contract_id, x_link_line_tbl(i).oks_service_line_id );
	    FETCH l_topsvclne_csr INTO l_topsvclne;
	    CLOSE l_topsvclne_csr;

	    IF( l_svclne.id = l_topsvclne.id ) THEN
	        j := 0;
		EXIT;
	    END IF;
	END LOOP;

        IF ( j = -1 ) THEN
               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_OKL_OKS_LNK');
               x_return_status := Okl_Api.G_RET_STS_ERROR;
	       EXIT;
        END IF;
    END LOOP;

    FOR i IN 1..x_link_line_tbl.COUNT
    LOOP


        OPEN l_subline_csr( x_link_line_tbl(i).okl_service_line_id);
	FETCH l_subline_csr INTO l_sublne;
	CLOSE l_subline_csr;

/* removed bug 3257597
        OPEN l_svcline_csr( x_link_line_tbl(i).oks_service_line_id);
	FETCH l_svcline_csr INTO l_svclne;
	CLOSE l_svcline_csr;
*/
        OPEN srv_csr (x_link_line_tbl(i).okl_service_line_id);
        FETCH srv_csr INTO l_svclne;
        CLOSE srv_csr;

        IF ( l_svclne.inventory_item_id <> l_sublne.object1_id1 ) THEN

            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_OKL_OKS_ITMS',
                  p_token1       => 'line',
                  p_token1_value => l_sublne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;

	END IF;

        IF ( l_svclne.quantity <> l_sublne.number_of_items ) THEN

            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_OKL_OKS_NITMS',
                  p_token1       => 'line',
                  p_token1_value => l_sublne.name);

            x_return_status := Okl_Api.G_RET_STS_ERROR;

        END IF;


        OPEN  l_toplne_csr( 'SOLD_SERVICE', p_chr_id, x_link_line_tbl(i).okl_service_line_id );
	FETCH l_toplne_csr INTO l_toplne;
	CLOSE l_toplne_csr;

        OPEN l_rl_csr1( 'LALEVL', 'LASLL', p_chr_id, l_toplne.id);
	FETCH l_rl_csr1 INTO l_rl_rec1;
	IF ( l_rl_csr1%FOUND ) THEN
            Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_OKL_OKS_PYMNTS',
                p_token1       => 'line',
                p_token1_value => l_toplne.name);
             x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;
	CLOSE l_rl_csr1;

    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF ( l_toplne_csr%ISOPEN ) THEN
        CLOSE l_toplne_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    IF ( l_toplne_csr%ISOPEN ) THEN
        CLOSE l_toplne_csr;
    END IF;

  END check_service_lines;

  -- Start of comments
  --
  -- Procedure Name  : check_srvc_amnt
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_srvc_amnt(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    x_msg_count       NUMBER;
    x_msg_data        VARCHAR2(256);
    x_link_line_tbl   Okl_Service_Integration_Pub.LINK_LINE_TBL_TYPE;
    x_service_contract_id  NUMBER;

    CURSOR srv_amt_csr (p_serv_top_line_id NUMBER) IS
    SELECT item_id inventory_item_id,
           SUM(NVL(price_negotiated,0)) amount
    FROM   okl_la_cov_asset_uv
    WHERE  serv_top_line_id = p_serv_top_line_id
    GROUP BY item_id;

    l_lne l_toplne_csr%ROWTYPE;
    --l_svclne l_topsvclne_csr%ROWTYPE;
    l_svclne srv_amt_csr%ROWTYPE;

    amount1 okl_k_lines.AMOUNT%TYPE;
    amount2 okl_k_lines.AMOUNT%TYPE;

    i NUMBER;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Service_Integration_Pub.get_service_link_line (
                                   p_api_version   => 1.0,
                                   p_init_msg_list => Okl_Api.G_FALSE,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_lease_contract_id => p_chr_id,
                                   x_link_line_tbl => x_link_line_tbl,
                                   x_service_contract_id => x_service_contract_id);

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF ( NVL(x_service_contract_id, -1 ) = -1 ) THEN
        x_return_status := Okl_Api.G_RET_STS_SUCCESS;
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
	RETURN;
    END IF;

    FOR i IN 1..x_link_line_tbl.COUNT
    LOOP

/* removed bug# 3257597
        OPEN l_topsvclne_csr( 'SERVICE', x_service_contract_id, x_link_line_tbl(i).oks_service_line_id );
	FETCH l_topsvclne_csr INTO l_svclne;
	amount1 := nvl(l_svclne.amount, -1);
	CLOSE l_topsvclne_csr;
*/


        OPEN l_toplne_csr( 'SOLD_SERVICE', p_chr_id, x_link_line_tbl(i).okl_service_line_id );
	FETCH l_toplne_csr INTO l_lne;
	amount2 := NVL(l_lne.amount,-1);
	CLOSE l_toplne_csr;


        OPEN srv_amt_csr (l_lne.id); -- pass okl service top line id
        FETCH srv_amt_csr INTO l_svclne;
        amount1 := NVL(l_svclne.amount, -1);
        CLOSE srv_amt_csr;

        IF ( amount1 <> amount2 ) THEN
               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_OKL_OKS_AMNTS',
                  p_token1       => 'line',
                  p_token1_value => l_lne.line_number);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
	END IF;

    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF ( l_toplne_csr%ISOPEN ) THEN
        CLOSE l_toplne_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    IF ( l_toplne_csr%ISOPEN ) THEN
        CLOSE l_toplne_csr;
    END IF;

  END check_srvc_amnt;

  -- Start of comments
  --
  -- Procedure Name  : check_acceptance_date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_acceptance_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    l_hdr_rec l_hdr_csr%ROWTYPE;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN l_hdr_csr( p_chr_id );
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;

    IF ( l_hdr_rec.accepted_date IS NULL) THEN
        Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_ACCPTD_DATE');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;

  END check_acceptance_date;

-- Bug 4865431
PROCEDURE check_payment_schedule(
  x_return_status OUT NOCOPY VARCHAR2,
  p_chr_id IN NUMBER,
  p_stream_purpose_code IN VARCHAR2,
  p_message_name IN VARCHAR2) IS

TYPE l_payment_details_rec IS RECORD (
  start_date DATE := NULL,
  number_of_periods NUMBER := NULL,
  stub_days NUMBER := NULL,
  stub_amount NUMBER := NULL,
  advance_or_arrears VARCHAR2(1) := NULL
);
TYPE l_payment_details_tbl IS TABLE OF l_payment_details_rec INDEX BY BINARY_INTEGER;
TYPE l_tbl_rec IS RECORD (
  kle_id NUMBER,
  l_payment_details l_payment_details_tbl
);
TYPE l_tbl_type IS TABLE OF l_tbl_rec INDEX BY BINARY_INTEGER;

l_pmnt_tab l_tbl_type;
l_pmnt_tab_counter NUMBER;
l_payment_details_counter NUMBER;

CURSOR l_payment_lines_csr IS
    SELECT
    rgpb.cle_id kle_id,
    rulb2.RULE_INFORMATION2 start_date,
    rulb2.RULE_INFORMATION3 level_periods,
    rulb2.RULE_INFORMATION7 stub_days,
    rulb2.RULE_INFORMATION8 stub_amount,
    rulb2.RULE_INFORMATION10 arrear_yn
    FROM   okc_k_lines_b     cleb,
           okc_rule_groups_b rgpb,
           okc_rules_b       rulb,
           okc_rules_b       rulb2,
           okl_strm_type_b   styb
    WHERE  rgpb.chr_id     IS NULL
    AND    rgpb.dnz_chr_id = cleb.dnz_chr_id
    AND    rgpb.cle_id     = cleb.id
    AND    cleb.dnz_chr_id = p_chr_id
    AND    rgpb.rgd_code   = 'LALEVL'
    AND    rulb.rgp_id     = rgpb.id
    AND    rulb.rule_information_category  = 'LASLH'
    AND    TO_CHAR(styb.id)                = rulb.object1_id1
    AND    rulb2.object2_id1                = TO_CHAR(rulb.id)
    AND    rulb2.rgp_id                    = rgpb.id
    AND    rulb2.rule_information_category = 'LASLL'
    AND    styb.STREAM_TYPE_PURPOSE = p_stream_purpose_code
    ORDER BY kle_id, start_date, level_periods;

TYPE payment_rec_type IS RECORD (kle_id NUMBER,
  start_date VARCHAR2(450),
  number_of_periods VARCHAR2(450),
  stub_days VARCHAR2(450),
  stub_amount VARCHAR2(450),
  advance_or_arrears VARCHAR2(450)
);

TYPE payment_table IS TABLE OF payment_rec_type INDEX BY BINARY_INTEGER;

l_payment_table payment_table;
l_payment_table2 payment_table;
l_payment_table_counter NUMBER;
l_limit NUMBER := 10000;
l_prev_kle_id NUMBER;
l_num_schedules NUMBER;
schedule_mismatch EXCEPTION;
l_start_date DATE;
l_number_of_periods NUMBER;
l_stub_days NUMBER;
l_advance_or_arrears VARCHAR2(30);

PROCEDURE print_tab(p_table IN l_tbl_type) IS
BEGIN
 NULL;
 FOR i IN p_table.first..p_table.last
 LOOP
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i='||i || '->kle_id='|| p_table(i).kle_id);
  END IF;
  FOR j IN p_table(i).l_payment_details.first..p_table(i).l_payment_details.last
  LOOP
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'-->j=' || j );
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>start_date=' || p_table(i).l_payment_details(j).start_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>number_of_periods=' || p_table(i).l_payment_details(j).number_of_periods);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>stub_days=' || p_table(i).l_payment_details(j).stub_days);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>stub_amount=' || p_table(i).l_payment_details(j).stub_amount);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'------>advance_or_arrears=' || p_table(i).l_payment_details(j).advance_or_arrears);
    END IF;
  END LOOP;
 END LOOP;
END;

PROCEDURE print_payment_orig_table(p_table IN payment_table) IS
BEGIN
 NULL;
 IF (p_table.COUNT > 0) THEN
 FOR i IN p_table.first..p_table.last
 LOOP
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'i='||i || '->kle_id='|| p_table(i).kle_id);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'start_date=' || p_table(i).start_date);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'number_of_periods=' || p_table(i).number_of_periods);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub_days=' || p_table(i).stub_days);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'stub_amount=' || p_table(i).stub_amount);
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'advance_or_arrears=' || p_table(i).advance_or_arrears);
  END IF;
 END LOOP;
 END IF;
END;

BEGIN
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;
  l_payment_table_counter := 1;
  OPEN l_payment_lines_csr;
  LOOP
    FETCH l_payment_lines_csr BULK COLLECT INTO l_payment_table2 LIMIT l_limit;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_payment_table2.count=' || l_payment_table2.COUNT);
    END IF;
    IF (l_payment_table2.COUNT > 0) THEN
      FOR i IN l_payment_table2.FIRST..l_payment_table2.LAST
      LOOP
        l_payment_table(l_payment_table_counter) := l_payment_table2(i);
        l_payment_table_counter := l_payment_table_counter + 1;
      END LOOP;
    ELSE
      EXIT;
    END IF;
  END LOOP;
  CLOSE l_payment_lines_csr;
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_payment_table_counter=' || l_payment_table_counter);
  END IF;
  print_payment_orig_table(l_payment_table);

  IF (l_payment_table.COUNT > 0) THEN
    -- Prepare formatted table from l_payment_table
    l_pmnt_tab_counter := 0;
    l_payment_details_counter := 1;
    l_prev_kle_id := 0;

    FOR i IN l_payment_table.first..l_payment_table.last
    LOOP
      IF (l_prev_kle_id <> l_payment_table(i).kle_id) THEN
        l_pmnt_tab_counter := l_pmnt_tab_counter + 1;
        l_payment_details_counter := 1;
        l_pmnt_tab(l_pmnt_tab_counter).kle_id := l_payment_table(i).kle_id;

        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).start_date := Fnd_Date.canonical_to_date(l_payment_table(i).start_date);
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).number_of_periods := l_payment_table(i).number_of_periods;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_days := l_payment_table(i).stub_days;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_amount := l_payment_table(i).stub_amount;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).advance_or_arrears := l_payment_table(i).advance_or_arrears;

        l_prev_kle_id := l_payment_table(i).kle_id;
        l_payment_details_counter := l_payment_details_counter + 1;
      ELSE
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).start_date := Fnd_Date.canonical_to_date(l_payment_table(i).start_date);
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).number_of_periods := l_payment_table(i).number_of_periods;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_days := l_payment_table(i).stub_days;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).stub_amount := l_payment_table(i).stub_amount;
        l_pmnt_tab(l_pmnt_tab_counter).l_payment_details(l_payment_details_counter).advance_or_arrears := l_payment_table(i).advance_or_arrears;

        l_prev_kle_id := l_payment_table(i).kle_id;
        l_payment_details_counter := l_payment_details_counter + 1;
      END IF;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Now Printing l_pmnt_tab...');
    END IF;
    print_tab(l_pmnt_tab);

    -- Check only if there are at least two asset lines
    IF (l_pmnt_tab.COUNT > 1) THEN

      l_num_schedules := l_pmnt_tab(1).l_payment_details.COUNT;
      IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
              OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_num_schedules=' || l_num_schedules);
      END IF;
      FOR i IN 2..l_pmnt_tab.LAST
      LOOP
        IF (l_num_schedules <> l_pmnt_tab(i).l_payment_details.COUNT) THEN
          RAISE schedule_mismatch;
        END IF;
      END LOOP;


      FOR j IN l_pmnt_tab(1).l_payment_details.first..l_pmnt_tab(1).l_payment_details.last
      LOOP
        l_start_date := l_pmnt_tab(1).l_payment_details(j).start_date;
        l_number_of_periods := l_pmnt_tab(1).l_payment_details(j).number_of_periods;
        l_stub_days := l_pmnt_tab(1).l_payment_details(j).stub_days;
        l_advance_or_arrears := l_pmnt_tab(1).l_payment_details(j).advance_or_arrears;
        FOR i IN 2..l_pmnt_tab.LAST
        LOOP
          IF (Fnd_Date.canonical_to_date(l_start_date) <> Fnd_Date.canonical_to_date(l_pmnt_tab(i).l_payment_details(j).start_date)) OR
             (NVL(l_number_of_periods,0) <> NVL(l_pmnt_tab(i).l_payment_details(j).number_of_periods,0)) OR
             (NVL(l_stub_days,0) <> NVL(l_pmnt_tab(i).l_payment_details(j).stub_days,0)) OR
             (NVL(l_advance_or_arrears,'N') <> NVL(l_pmnt_tab(i).l_payment_details(j).advance_or_arrears,'N')) THEN

            RAISE schedule_mismatch;
          END IF;
        END LOOP; -- i
      END LOOP; -- j
    END IF;

  END IF;

EXCEPTION
  WHEN schedule_mismatch
  THEN
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Okl_Api.set_message(
         p_app_name => G_APP_NAME,
         p_msg_name => p_message_name);
  WHEN OTHERS
  THEN
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    Okl_Api.set_message(
         p_app_name => G_APP_NAME,
         p_msg_name => p_message_name);

END;



  -- Start of comments
  --
  -- Procedure Name  : check_payment_type
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  /* AKP -- Commented out for OKL.H: drop0. */
  PROCEDURE check_payment_type(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);
    x_msg_count NUMBER;
    x_msg_data VARCHAR2(2000);
    x_pdt_parameter_rec  Okl_Setupproducts_Pub.pdt_parameters_rec_type;


    -- gboomina modified for Bug 6329395 - Start
    CURSOR c_contract_name ( p_id VARCHAR2 ) IS
    SELECT contract_number
    FROM okc_k_headers_v WHERE id = p_id;
    l_contract_number OKC_K_HEADERS_ALL_B.CONTRACT_NUMBER%TYPE;
    -- gboomina modified for Bug 6329395 - End

    -- Bug 5114815
    CURSOR contract_start_date_csr(p_id NUMBER) IS
    SELECT start_date
    FROM   okc_k_headers_b
    WHERE  id = p_id;
    l_contract_start_date DATE;

    l_hdr     l_hdr_csr%ROWTYPE;
    l_txl     l_txl_csr%ROWTYPE;
    l_txd     l_txd_csr%ROWTYPE;
    l_itm     l_itms_csr%ROWTYPE;
    l_struct_rec l_struct_csr%ROWTYPE;
    l_structure  NUMBER;
    l_rl_rec1 l_rl_csr1%ROWTYPE;
    i NUMBER;


    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_supp_rec supp_csr%ROWTYPE;
    l_lne l_lne_csr%ROWTYPE;
    l_fee_strm_type_rec  fee_strm_type_csr%ROWTYPE;
    l_strm_name_rec strm_name_csr%ROWTYPE;

    l_inflow_defined_yn VARCHAR2(1);
    l_outflow_defined_yn VARCHAR2(1);

    l_deal_type VARCHAR2(30);
    l_interest_calculation_basis VARCHAR2(30);
    l_revenue_recognition_method VARCHAR2(30);
    l_rent_payment_found BOOLEAN := FALSE;
    l_principal_payment_found BOOLEAN := FALSE;
    l_pricing_engine VARCHAR2(30);
    l_payment_in_advance BOOLEAN := FALSE;
    l_rent_payment_in_advance BOOLEAN := FALSE;
    l_prin_payment_in_advance BOOLEAN := FALSE;
    l_int_payment_in_advance BOOLEAN := FALSE;
    l_loan_start_date DATE := NULL;
    l_variable_start_date DATE := NULL;
    l_loan_periods NUMBER := NULL;
    l_variable_periods NUMBER := NULL;
    l_payment_date DATE;
    l_payment_date2 DATE;
    l_line_ind NUMBER;
    l_base_rate_defined BOOLEAN := FALSE;
    l_var_int_schedule_defined BOOLEAN := FALSE;

    CURSOR l_pmnt_strm_hdr(
                   rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                   rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                   chrId NUMBER) IS
    SELECT crg.cle_id,
           crl.id,
           stty.stream_type_purpose,
           crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           AND stty.stream_type_purpose IN (
             'RENT', 'PRINCIPAL_PAYMENT', 'VARIABLE_INTEREST_SCHEDULE',
             'LOAN_PAYMENT'
           )
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

  l_pmnt_strm_hdr_rec l_pmnt_strm_hdr%ROWTYPE;

    CURSOR l_pmnt_strm_check(
                   rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                   rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                   pmnt_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE,
                   chrId NUMBER) IS
    SELECT crg.cle_id,
           crl.id,
           crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           AND stty.stream_type_purpose = pmnt_strm_purpose
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

    CURSOR l_pmnt_strm_check2(
                   rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                   rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                   pmnt_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE,
                   chrId NUMBER) IS
    SELECT crg.cle_id,
           crl.id,
           crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           AND stty.stream_type_purpose = pmnt_strm_purpose
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

  l_pmnt_strm_check_rec l_pmnt_strm_check%ROWTYPE;
  l_pmnt_strm_check_rec2 l_pmnt_strm_check2%ROWTYPE;
    CURSOR l_pmnt_lns_in_hdr(p_id OKC_RULES_B.ID%TYPE, chrId NUMBER) IS
    SELECT
    crl2.object1_id1,
    crl2.object1_id2,
    crl2.rule_information2,
    NVL(crl2.rule_information3,0) rule_information3,
    crl2.rule_information4,
    crl2.rule_information5,
    crl2.rule_information6,
    crl2.rule_information7,
    crl2.rule_information8,
    crl2.rule_information10
    FROM   OKC_RULES_B crl1, OKC_RULES_B crl2
    WHERE crl1.id = crl2.object2_id1
    AND crl1.id = p_id
    AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
    AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
    AND crl1.dnz_chr_id = chrId
    AND crl2.dnz_chr_id = chrId
    ORDER BY crl2.rule_information2 ASC;

    CURSOR l_pmnt_lns_in_hdr2(p_id OKC_RULES_B.ID%TYPE, chrId NUMBER) IS
    SELECT
    crl2.object1_id1,
    crl2.object1_id2,
    crl2.rule_information2,
    NVL(crl2.rule_information3,0) rule_information3,
    crl2.rule_information4,
    crl2.rule_information5,
    crl2.rule_information6,
    crl2.rule_information7,
    crl2.rule_information8,
    crl2.rule_information10
    FROM   OKC_RULES_B crl1, OKC_RULES_B crl2
    WHERE crl1.id = crl2.object2_id1
    AND crl1.id = p_id
    AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
    AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
    AND crl1.dnz_chr_id = chrId
    AND crl2.dnz_chr_id = chrId
    ORDER BY crl2.rule_information2 ASC;

    l_pmnt_lns_in_hdr_rec l_pmnt_lns_in_hdr%ROWTYPE;
    l_pmnt_lns_in_hdr_rec2 l_pmnt_lns_in_hdr2%ROWTYPE;

    CURSOR cust_print_lead_days_csr(p_id NUMBER) IS
      SELECT term.printing_lead_days
         FROM  okc_k_headers_b khr
              ,hz_customer_profiles cp
              ,ra_terms_b term
         WHERE khr.id = p_id
         AND khr.bill_to_site_use_id = cp.site_use_id
         AND cp.standard_terms = term.term_id;
    l_cust_print_lead_days NUMBER := null;

    CURSOR rate_delay_csr(p_id NUMBER) IS
      SELECT TO_NUMBER(RULE_INFORMATION3)
      FROM OKC_RULES_B RULE,
           OKC_RULE_GROUPS_B RGP
      WHERE RGP.ID = RULE.RGP_ID
      AND   RGP.DNZ_CHR_ID = p_id
      AND   RGD_CODE = 'LABILL'
      AND   RULE_INFORMATION_CATEGORY = 'LAINVD';

   -- Fix for bug 7131756: Added columns captital_reduction,
   --                      capitalize_down_payment_yn,
   --                      capital_reduction_percent, OEC
   CURSOR oec_csr (p_id NUMBER) IS
   SELECT a.capital_amount capital_amount,
          b.name asset_number,
	  capital_reduction,
          NVL(capitalize_down_payment_yn,'N') capitalize_down_payment_yn,
          capital_reduction_percent,
	  oec,
          e.ste_code ste_code -- 5264170
   FROM   OKL_K_LINES a,
          OKC_K_LINES_TL b,
          OKC_LINE_STYLES_V C,
          OKC_K_LINES_B d,
          OKC_STATUSES_B e
   WHERE  a.ID = p_id
   AND    a.ID = b.ID
   AND    b.LANGUAGE = USERENV('LANG')
   AND    c.lty_code ='FREE_FORM1'
   AND    d.ID = p_ID
   AND    d.lse_id = c.id
   AND    d.sts_code = e.code;

    l_rate_delay NUMBER := null;
    l_rent_start_date DATE;
    l_rent_periods NUMBER;
    l_principal_start_date DATE;
    l_principal_periods NUMBER;
    l_curr_cle_id NUMBER;
    l_tot_principal_payment NUMBER;
    l_capital_amount OKL_K_LINES.CAPITAL_AMOUNT%TYPE;
    l_oec_amount OKL_K_LINES.OEC%TYPE;
    l_capital_reduction OKL_K_LINES.CAPITAL_REDUCTION%TYPE;
    l_capital_reduction_percent OKL_K_LINES.CAPITAL_REDUCTION_PERCENT%TYPE;
    l_capitalize_down_payment_yn OKL_K_LINES.CAPITALIZE_DOWN_PAYMENT_YN%TYPE;
    l_asset_number OKC_K_LINES_TL.NAME%TYPE;
    l_ste_code OKC_STATUSES_B.STE_CODE%TYPE;

    line_ind NUMBER;
    ind NUMBER;
    l_global_total_periods NUMBER;
    l_line_total_periods NUMBER;
    l_pmnt_lns_in_hdr_rec_comp l_pmnt_lns_in_hdr%ROWTYPE;
    l_pmnt_lns_in_hdr_rec      l_pmnt_lns_in_hdr%ROWTYPE;
    l_min_start_date DATE;
    l_mismatch_exception EXCEPTION;
    l_global_min_start_date DATE;
    l_loop_counter NUMBER;
    l_pmnt_type VARCHAR2(200);

    l_tot_unsched_prin_payment NUMBER;
    -- gboomina Bug 6401848 - Start
    l_net_subsidy_amount NUMBER;
    -- gboomina Bug 6401848 - End
	l_non_cap_down_payment_amount NUMBER;

    FUNCTION tot_unsched_prin_payment(
                                      x_return_status OUT NOCOPY VARCHAR2,
                                      p_chr_id IN NUMBER,
                                      p_kle_id IN NUMBER) RETURN NUMBER IS
    l_tot_amount NUMBER := 0;
    BEGIN
      IF (G_DEBUG_ENABLED = 'Y') THEN
        G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
      END IF;
     x_return_status := Okl_Api.G_RET_STS_SUCCESS;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In tot_unsched_prin_payment: 0...');
     END IF;
     --print('In tot_unsched_prin_payment: p_chr_id= ' || p_chr_id || ' p_kle_id=' || p_kle_id);
     FOR l_pmnt_strm_check_rec2 IN l_pmnt_strm_check2('LALEVL','LASLH','UNSCHEDULED_PRINCIPAL_PAYMENT', p_chr_id)
     LOOP
       --print('In tot_unsched_prin_payment: 1...');
       IF (l_pmnt_strm_check_rec2.cle_id = p_kle_id) THEN
       --print('In tot_unsched_prin_payment: 2...');
         FOR l_pmnt_lns_in_hdr_rec2 IN l_pmnt_lns_in_hdr2(l_pmnt_strm_check_rec2.id ,p_chr_id)
         LOOP
       --print('In tot_unsched_prin_payment: 3...');
           l_tot_amount := l_tot_amount + NVL(l_pmnt_lns_in_hdr_rec2.rule_information8,0);
         END LOOP;
       END IF;
     END LOOP;
     --print('Out of main FOR LOOP...');
     RETURN(l_tot_amount);

     EXCEPTION WHEN OTHERS THEN
       --print('Exception In tot_unsched_prin_payment...sqlcode=' || sqlcode || ' sqlerrm=' || sqlerrm);
       x_return_status := Okl_Api.G_RET_STS_ERROR;
       RETURN(0);
    END; -- tot_unsched_prin_payment

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type...');
    END IF;

    Okl_K_Rate_Params_Pvt.get_product(
      p_api_version         => 1,
      p_init_msg_list       => Okc_Api.G_FALSE,
      x_return_status       => x_return_status,
      x_msg_count           => x_msg_count,
      x_msg_data            => x_msg_data,
      p_khr_id              => p_chr_id,
      x_pdt_parameter_rec   => x_pdt_parameter_rec);

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:After get_product...x_return_status='||x_return_status);
    END IF;
    IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       Okc_Api.set_message(
                           p_app_name     => G_APP_NAME,
                           p_msg_name     => G_PROD_PARAMS_NOT_FOUND,
                           p_token1       => G_PROD_NAME_TOKEN ,
                           p_token1_value => l_deal_type);
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_deal_type := x_pdt_parameter_rec.deal_type;
    l_interest_calculation_basis := x_pdt_parameter_rec.interest_calculation_basis;
    l_revenue_recognition_method := x_pdt_parameter_rec.revenue_recognition_method;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before l_pmnt_strm_hdr_rec...x_return_status='||x_return_status);
    END IF;
    FOR l_pmnt_strm_hdr_rec IN l_pmnt_strm_hdr ( 'LALEVL', 'LASLH', p_chr_id )
    LOOP

       FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_hdr_rec.id ,p_chr_id)
        LOOP
        IF ( l_pmnt_strm_hdr_rec.stream_type_purpose = 'RENT' ) THEN
          l_rent_payment_found := TRUE;
          IF (NVL(l_pmnt_lns_in_hdr_rec.rule_information10,'N') = 'N') THEN
            l_payment_in_advance := TRUE;
            l_rent_payment_in_advance := TRUE;
          END IF;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before assigning l_rent_start_date....');
          END IF;
          l_rent_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rent_start_date=' || l_rent_start_date);
          END IF;
          l_rent_periods := l_pmnt_lns_in_hdr_rec.rule_information3;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_rent_periods=' || l_rent_periods);
          END IF;
        ELSIF ( l_pmnt_strm_hdr_rec.stream_type_purpose = 'PRINCIPAL_PAYMENT' ) THEN
          l_principal_payment_found := TRUE;
          IF (NVL(l_pmnt_lns_in_hdr_rec.rule_information10,'N') = 'N') THEN
            l_payment_in_advance := TRUE;
            l_prin_payment_in_advance := TRUE;
          END IF;
          l_principal_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_principal_start_date=' || l_principal_start_date);
          END IF;
          l_principal_periods := l_pmnt_lns_in_hdr_rec.rule_information3;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_principal_periods=' || l_principal_periods);
          END IF;
        ELSIF ( l_pmnt_strm_hdr_rec.stream_type_purpose = 'LOAN_PAYMENT' ) THEN
          l_loan_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
          l_loan_periods := l_hdrrl_rec.rule_information3;
        ELSIF ( l_pmnt_strm_hdr_rec.stream_type_purpose = 'VARIABLE_INTEREST_SCHEDULE' ) THEN
          l_var_int_schedule_defined := TRUE;
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before assigning l_variable_start_date....');
          END IF;
          l_variable_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
          IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_variable_start_date = ' || l_variable_start_date);
          END IF;
          l_variable_periods := l_pmnt_lns_in_hdr_rec.rule_information3;
          IF (NVL(l_pmnt_lns_in_hdr_rec.rule_information10,'N') = 'N') THEN
            l_payment_in_advance := TRUE;
            l_int_payment_in_advance := TRUE;
          END IF;
        END IF;

        -- Bug 4547537 Begin
        IF ( l_pmnt_strm_hdr_rec.stream_type_purpose IN
             ( 'RENT', 'LOAN_PAYMENT', 'PRINCIPAL_PAYMENT' ) ) THEN
          IF ( TRUNC(NVL(l_pmnt_lns_in_hdr_rec.rule_information5,'-1')) <> '0')
          THEN
            -- non Level
            IF (l_pmnt_lns_in_hdr_rec.rule_information7 IS NOT NULL AND
                l_pmnt_lns_in_hdr_rec.rule_information8 IS NOT NULL ) THEN

               Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_PAYMENT_STUB_NA');
              x_return_status := Okl_Api.G_RET_STS_ERROR;
            END IF;
          END IF;
        END IF;
        -- Bug 4547537 End

      END LOOP;
    END LOOP;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before first check...x_return_status='||x_return_status);
    END IF;
    -- Both RENT and PRINCIPAL_PAYMENT not allowed
    IF (l_rent_payment_found AND l_principal_payment_found) THEN
       Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LA_VAR_RATE_PAYMENT');
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before second check...x_return_status='||x_return_status);
    END IF;
   -- If payment in advance, check rate delays > print lead days
   IF (l_payment_in_advance) THEN
     NULL; -- Todo: AKP
     IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'FLOAT' AND
       l_revenue_recognition_method IN ('ESTIMATED_AND_BILLED', 'ACTUAL')) THEN
       Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LA_VAR_RATE_ADVANCE',
                    p_token1       => 'DEAL_TYPE',
                    p_token1_value => l_deal_type,
                    p_token2       => 'ICB',
                    p_token2_value => l_interest_calculation_basis);
       x_return_status := Okl_Api.G_RET_STS_ERROR;
     END IF;

     -- 4918119: For REAMORT contracts, advance payment is not allowed
     -- Disable this QA check: 5114544
     IF (l_interest_calculation_basis = 'REAMORT') THEN
       IF (l_deal_type IN ('LEASEOP', 'LEASEST', 'LEASEDF') ) THEN
         NULL;
       ELSE
         Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LA_VAR_RATE_ADVANCE',
                    p_token1       => 'DEAL_TYPE',
                    p_token1_value => l_deal_type,
                    p_token2       => 'ICB',
                    p_token2_value => l_interest_calculation_basis);
         x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
     END IF;
    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before rate_delay_csr...');
    END IF;
     -- get rate delay (rule group/rule)
     OPEN rate_delay_csr(p_chr_id);
     FETCH rate_delay_csr INTO l_rate_delay;
     CLOSE rate_delay_csr;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before print_lead_csr...');
    END IF;
     -- get cust print lead days
     OPEN  cust_print_lead_days_csr(p_chr_id);
     FETCH cust_print_lead_days_csr INTO l_cust_print_lead_days;
     CLOSE cust_print_lead_days_csr;

     -- gboomina modified for Bug 6329395 - Start
     OPEN  c_contract_name(p_chr_id);
     FETCH c_contract_name INTO l_contract_number;
     CLOSE c_contract_name;
     -- gboomina modified for Bug 6329395 - End

     -- udhenuko bug#6786775
     -- Added an if condition in OKL_QA_DATA_INTEGRITY.check_payment_type to throw the error message
     --for contracts having Interest Calculation Method NOT EQUAL TO Fixed and Revenue Recognition Method NOT EQUAL TO
     --'STREAMS' for cases where print lead day value used in payment terms is greater than Rate delay.
     IF l_interest_calculation_basis <> 'FIXED'
          AND l_revenue_recognition_method <> 'STREAMS'
     THEN
       IF ((l_rate_delay IS NOT NULL AND l_cust_print_lead_days IS NOT NULL) AND
          (l_rate_delay <= l_cust_print_lead_days)) THEN
           Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_RATE_DELAY',
                    p_token1       => 'CONT_ID',
                    p_token1_value => l_contract_number);
           x_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
       END IF;
     END IF;
     -- udhenuko End bug#6786775

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before third check...x_return_status='||x_return_status);
    END IF;
   -- If Principal payment is defined, check if base_rate defined
   IF (l_principal_payment_found) THEN
     --print('Yes, Principal payment found: Checking base rate...');
     Okl_K_Rate_Params_Pvt.check_base_rate(
                             p_khr_id => p_chr_id,
                             x_base_rate_defined => l_base_rate_defined,
                             x_return_status => l_return_status);

     --print('l_return_status=' || l_return_status);
     IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := l_return_status;
       RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
     END IF;

     IF NOT(l_base_rate_defined) THEN
       -- 4907390
       Okl_Api.set_message(Okc_Api.G_APP_NAME, G_REQUIRED_VALUE,
                           G_COL_NAME_TOKEN, 'Base Rate');
       /*OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_BASE_MISSING',
                    p_token1       => 'CONT_ID',
                    p_token1_value => p_chr_id); */
       x_return_status := Okl_Api.G_RET_STS_ERROR;
     --ELSE
       --print('base_rate defined...');
     END IF;
   END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before fourth check...x_return_status='||x_return_status);
     END IF;
	   -- Bug 4674139
	   -- Check if variable interest schedule is defined for LOAN FLOAT
	   IF (l_deal_type = 'LOAN' AND
	       l_interest_calculation_basis = 'FLOAT' ) OR
	      -- Bug 4742650 (do it for LOAN-REVOLVING also)
	      (l_deal_type = 'LOAN-REVOLVING' AND
	       l_interest_calculation_basis = 'FLOAT' ) THEN
	     IF NOT(l_var_int_schedule_defined) THEN
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          	       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Var Int Schedule Not Defined...');
        END IF;
	       Okl_Api.set_message(
			    p_app_name     => G_APP_NAME,
			    p_msg_name     => 'OKL_LA_VAR_SCHEDULED_ALLOWED');
	       x_return_status := Okl_Api.G_RET_STS_ERROR;
	     ELSE
        IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          	       OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Var Int Schedule Defined...');
        END IF;
	     END IF;
	   ELSE -- Bug 4742650 (Do not allow var int sched for other type of contracts)
	     IF (l_var_int_schedule_defined) THEN
	       Okl_Api.set_message(
			    p_app_name     => G_APP_NAME,
			    p_msg_name     => 'OKL_LLA_VAR_RATE_SCHEDULE_NA');
	       x_return_status := Okl_Api.G_RET_STS_ERROR;
	     END IF;
	   END IF;

     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
       	    OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before fifth check...x_return_status='||x_return_status);
     END IF;
   -- Bug 4886871
   -- Check if variable interest schedule is same as loan payment schedule
   /*
   IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'FLOAT' AND
       l_revenue_recognition_method = 'ACTUAL') THEN
     NULL;
     print('l_variable_start_date=' || l_variable_start_date);
     print('l_rent_start_date=' || l_rent_start_date);
     print('l_principal_start_date=' || l_principal_start_date);
     print('l_variable_periods=' || l_variable_periods);
     print('l_rent_periods=' || l_rent_periods);
     print('l_principal_periods=' || l_principal_periods);
     IF ((l_rent_start_date = l_variable_start_date AND
          l_rent_periods = l_variable_periods ) OR
         (l_principal_start_date = l_variable_start_date AND
          l_principal_periods = l_variable_periods )) THEN
       NULL;
     ELSE
       OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_SCHEDULE',
                    p_token1       => 'CONT_ID',
                    p_token1_value => p_chr_id);
       x_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;
   END IF;
   */

   -- Bug 5114815
   IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'FLOAT' ) OR
      (l_deal_type = 'LOAN-REVOLVING' AND
       l_interest_calculation_basis = 'FLOAT' )  THEN
     FOR l_cnt_start_date IN contract_start_date_csr(p_chr_id)
     LOOP
       l_contract_start_date := l_cnt_start_date.start_date;
     END LOOP;
     IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_contract_start_date=' || l_contract_start_date);
     END IF;
     IF (l_variable_start_date <> l_contract_start_date) THEN
       OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_SCHEDULE2');
       x_return_status := OKL_API.G_RET_STS_ERROR;
     END IF;
   END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before sixth check...x_return_status='||x_return_status);
    END IF;
   -- Check same payment date for all assets (RENT currently)
   -- Commented this check from here and copied from check_variable_rate_old
   /*
   IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'REAMORT') THEN

     FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','RENT',p_chr_id)
     LOOP
       l_line_ind := 0;
       FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_check_rec.id ,p_chr_id)
       Loop
         If ( l_line_ind = 0 ) Then
           l_payment_date := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
           print('l_payment_date=' || l_payment_date);
           l_line_ind := 1;
         ELSE
           l_payment_date2 := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
           print('l_payment_date2=' || l_payment_date2);
           IF (l_payment_date <> l_payment_date2) THEN
             OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_PAYMENT_DATE',
                    p_token1       => 'CONT_ID',
                    p_token1_value => p_chr_id,
                    p_token2       => 'PAYMENT_TYPE',
                    p_token2_value => 'RENT');
             x_return_status := OKL_API.G_RET_STS_ERROR;
           END IF;
         End If;
       END Loop;
     END LOOP;
   END IF;
   */

    /*
    -- Bug 4865431
    -------------------------------------------------------------
    --Reamort Rent stream processing start for Variable rate Contracts.
    -------------------------------------------------------------
   IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'REAMORT') THEN

     FOR l_loop_counter IN 1..2
     LOOP

        IF (l_loop_counter = 1) THEN
          l_pmnt_type := 'RENT';
        ELSE
          l_pmnt_type := 'PRINCIPAL_PAYMENT';
        END IF;

        ind := 0;
        l_global_total_periods := 0;
        l_line_total_periods := 0;
        --FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','RENT',p_chr_id)
        FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH',l_pmnt_type,p_chr_id)
        LOOP
        BEGIN
          line_ind := 0;
          FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_check_rec.id ,p_chr_id)
          Loop
            If ( ind = 0 ) Then
              ind := 1;
              l_pmnt_lns_in_hdr_rec_comp := l_pmnt_lns_in_hdr_rec;
              -- global min start date is start date for first payment line for that SLH
              l_global_min_start_date := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
              print('l_global_min_start_date=' || l_global_min_start_date);
            End If;
            If (line_ind = 0) Then
              l_min_start_date := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
              print('l_min_start_date=' || l_min_start_date);
              line_ind := 1;
              l_line_total_periods := l_pmnt_lns_in_hdr_rec.rule_information3;
            Else
              l_line_total_periods := l_line_total_periods + l_pmnt_lns_in_hdr_rec.rule_information3;
            End If;
            print('l_line_total_periods=' || l_line_total_periods);
            If( l_pmnt_lns_in_hdr_rec.rule_information7 IS NULL
              AND l_pmnt_lns_in_hdr_rec.rule_information8 IS NULL) Then
              If( nvl(l_pmnt_lns_in_hdr_rec.rule_information10,'N') <> 'Y') Then
                RAISE l_mismatch_exception;
              End If;
              If (ind = 0) Then
                null;--dont compare two records as we are at first record now.
              Else
                If ( l_global_min_start_date
                       <> l_min_start_date
                     OR l_pmnt_lns_in_hdr_rec_comp.rule_information4
                       <> l_pmnt_lns_in_hdr_rec.rule_information4
                     OR l_pmnt_lns_in_hdr_rec_comp.object1_id1
                       <> l_pmnt_lns_in_hdr_rec.object1_id1
                     OR l_pmnt_lns_in_hdr_rec_comp.object1_id2
                       <> l_pmnt_lns_in_hdr_rec.object1_id2 ) Then
                  x_return_status := OKL_API.G_RET_STS_ERROR;
                  RAISE l_mismatch_exception;
                End If;
              End If;
            End If;
          End Loop;
          -- the sum of all SLL periods across all SLH's should match.
          If (l_global_total_periods = 0 ) Then
            l_global_total_periods := l_line_total_periods;
          Elsif(l_global_total_periods <> l_line_total_periods) Then
               RAISE l_mismatch_exception;
          END IF;
        EXCEPTION WHEN l_mismatch_exception Then
          x_return_status := OKL_API.G_RET_STS_ERROR;
          --message
          OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_SLL_MISMATCH');
        END;
        END LOOP;
        IF l_pmnt_lns_in_hdr%ISOPEN THEN
          CLOSE l_pmnt_lns_in_hdr;
        END IF;
        IF l_pmnt_strm_check%ISOPEN THEN
          CLOSE l_pmnt_strm_check;
        END IF;
      END LOOP;
    END IF;
    -------------------------------------------------------------
    --End REAMORT processing for rent streams for variable rate contracts.
    -------------------------------------------------------------
   */

    -- Bug 4865431
    -------------------------------------------------------------
    --Reamort Rent stream processing start for Variable rate Contracts.
    -------------------------------------------------------------
   IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'REAMORT') THEN
     check_payment_schedule(
           x_return_status => l_return_status,  -- 4907390
           p_chr_id => p_chr_id,
           p_stream_purpose_code => 'RENT',
           p_message_name => 'OKL_QA_VARINT_SLL_MISMATCH');
     IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN -- 4907390
       x_return_status := l_return_status;
     END IF;

	  --veramach bug 6389295 start
 	  IF (l_revenue_recognition_method <> 'STREAMS') then
 	  --veramach bug 6389295 end
     check_payment_schedule(
           x_return_status => l_return_status,  -- 4907390
           p_chr_id => p_chr_id,
           p_stream_purpose_code => 'PRINCIPAL_PAYMENT',
           p_message_name => 'OKL_QA_VARINT_SLL_MISMATCH');
     IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN -- 4907390
       x_return_status := l_return_status;
     END IF;
	  --veramach bug 6389295 start
 	  END IF;
 	  --veramach bug 6389295 end

   END IF;


   -- Check same payment date for all assets (PRINCIPAL_PAYMENT currently)
   -- FoR LOAN and REAMORT only
   -- Also check if principal amount is same as asset capital amount
   /*IF (l_deal_type = 'LOAN' AND
       l_interest_calculation_basis = 'REAMORT') THEN */

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before seventh check...x_return_status='||x_return_status);
    END IF;
     --FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','PRINCIPAL_PAYMENT',p_chr_id)
     FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','PRINCIPAL_PAYMENT', p_chr_id)
     LOOP
       l_line_ind := 0;
       l_tot_principal_payment := 0;
       l_curr_cle_id := l_pmnt_strm_check_rec.cle_id;
       FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_check_rec.id ,p_chr_id)
       LOOP
         -- Check same payment date for LOAN REAMORT only
         /*
         IF (l_deal_type = 'LOAN' AND
             l_interest_calculation_basis = 'REAMORT') THEN
           If ( l_line_ind = 0 ) Then
             l_payment_date := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
             l_line_ind := 1;
           ELSE
             l_payment_date2 := FND_DATE.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
             IF (l_payment_date <> l_payment_date2) THEN
               OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_LLA_VAR_RATE_PAYMENT_DATE',
                    p_token1       => 'CONT_ID',
                    p_token1_value => p_chr_id,
                    p_token2       => 'PAYMENT_TYPE',
                    p_token2_value => 'PRINCIPAL_PAYMENT');
               x_return_status := OKL_API.G_RET_STS_ERROR;
             END IF;
           END IF;
         END IF; */

         -- Now get the running principal amount

         l_tot_principal_payment := l_tot_principal_payment +
              NVL(l_pmnt_lns_in_hdr_rec.rule_information3,0) * NVL(l_pmnt_lns_in_hdr_rec.rule_information6, 0) +
              NVL(l_pmnt_lns_in_hdr_rec.rule_information8, 0);
           --print('Inside: rule_information3=' || l_pmnt_lns_in_hdr_rec.rule_information3);
           --print('Inside: rule_information6=' || l_pmnt_lns_in_hdr_rec.rule_information6);
           --print('Inside: rule_information8=' || l_pmnt_lns_in_hdr_rec.rule_information8);
           --print('Inside: l_tot_principal_payment=' || l_tot_principal_payment);

       END LOOP;

       FOR r IN oec_csr(l_curr_cle_id)
       LOOP
             l_capital_amount := r.capital_amount;
             l_asset_number := r.asset_number;
             l_ste_code := r.ste_code; -- 5264170
	     -- Fix for bug 7131756
       	     l_oec_amount := r.oec;
	     l_capital_reduction := r.capital_reduction;
	     l_capital_reduction_percent := r.capital_reduction_percent;
	     l_capitalize_down_payment_yn := r.capitalize_down_payment_yn;
       END LOOP;

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_asset_number=' || l_asset_number || ' l_capital_amount=' || l_capital_amount);
       END IF;
       -- 5264170
       IF l_ste_code NOT IN ('CANCELLED','TERMINATED','HOLD','EXPIRED') THEN
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tot_principal_payment=' || l_tot_principal_payment);
       END IF;
       -- Now get total unscheduled principal payment for this line, if any
       -- 4887014
       l_tot_unsched_prin_payment :=
                       tot_unsched_prin_payment(l_return_status, -- 4907390
                                         p_chr_id, l_curr_cle_id);
       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_tot_unsched_prin_payment=' || l_tot_unsched_prin_payment);
       END IF;

       -- gboomina Bug 6401848 - Start
       -- 4898747
       Okl_Subsidy_Process_Pvt.get_asset_subsidy_amount(
            p_api_version                  => 1.0,
            p_init_msg_list                => Okl_Api.G_FALSE,
            x_return_status                => l_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_asset_cle_id                 => l_curr_cle_id,
            p_accounting_method            => 'NET',
            x_subsidy_amount               => l_net_subsidy_amount);

       IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
                OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_net_subsidy_amount=' || l_net_subsidy_amount);
         OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'l_return_status=' || l_return_status);
       END IF;
	   -- Fix for Bug 7131756
	   l_non_cap_down_payment_amount := 0;
	   IF (l_capitalize_down_payment_yn = 'N') THEN
	      IF (l_capital_reduction IS NOT NULL) THEN
	        l_non_cap_down_payment_amount := l_capital_reduction;
	      ELSIF (l_capital_reduction_percent IS NOT NULL) THEN
		    l_non_cap_down_payment_amount := l_capital_reduction_percent/100*l_oec_amount;
	      END IF;
	   END IF;
       /* IF (ABS(l_capital_amount -  l_net_subsidy_amount -  -- 4898747
             (l_tot_principal_payment+l_tot_unsched_prin_payment)) > 0.01) OR
          (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN -- 4907390 */
	   IF (ABS(l_capital_amount - l_non_cap_down_payment_amount  -  -- 7131756
             (l_tot_principal_payment+l_tot_unsched_prin_payment)) > 0.01) THEN
             Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_PRIN_MISMATCH');
             x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
       -- gboomina Bug 6401848 - End
       END IF;
       l_tot_principal_payment := 0;

     END LOOP;

   IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
        OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before get_pricing_engine...x_return_status='||x_return_status);
   END IF;
   Okl_Streams_Util.get_pricing_engine(p_khr_id => p_chr_id,
                                       x_pricing_engine => l_pricing_engine,
                                       x_return_status => l_return_status);
   IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
     x_return_status := l_return_status;
     RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
   END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before eighth check...x_return_status='||x_return_status);
    END IF;
    IF (l_deal_type IN ('LEASEOP', 'LEASEST', 'LEASEDF') ) AND
       (l_interest_Calculation_basis IN ('FIXED', 'REAMORT', 'FLOAT_FACTORS'))
    THEN
      IF NOT(l_rent_payment_found) THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_RENT_MISSING');
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --return;
      ELSE -- RENT defined
        -- Bug 4748524
        IF (l_interest_calculation_basis = 'FLOAT_FACTORS') AND
           (l_rent_payment_in_advance) THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_ARREARS_1');
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
      END IF;
      IF (l_principal_payment_found) THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_ERROR');
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --return;
      END IF;
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before ninth check...x_return_status='||x_return_status);
    END IF;
    IF (((l_deal_type = 'LOAN') AND
         (l_interest_Calculation_basis IN
          ('FIXED', 'FLOAT', 'CATCHUP/CLEANUP')))  OR
        ((l_deal_type = 'LOAN') AND
         (l_interest_Calculation_basis = 'REAMORT')))
    THEN
      IF NOT(l_rent_payment_found) THEN
        IF (l_principal_payment_found) THEN
          IF (l_pricing_engine <> 'EXTERNAL') THEN
                  Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    --p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_MISSING');
                    p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_ISG');
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  --return;
          END IF;
        ELSE
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_RENT_MISSING');
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --return;
        END IF;
      END IF;
      /*IF (l_principal_payment_found) THEN
        IF (l_pricing_engine <> 'EXTERNAL') THEN
                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  --p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_MISSING');
                  p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_ISG');
                x_return_status := OKL_API.G_RET_STS_ERROR;
                return;
        END IF;*/
      /*ELSE
        IF (l_pricing_engine = 'INTERNAL') THEN
                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_ISG');
                x_return_status := OKL_API.G_RET_STS_ERROR;
                return;
        END IF;*/
      /*END IF;*/
    END IF;

    IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
          OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'In Check Payment Type:Before tenth check...x_return_status='||x_return_status);
    END IF;
    IF ((l_deal_type = 'LOAN-REVONVING' ) AND
        (l_interest_Calculation_basis = 'FLOAT'))
    THEN
      IF (l_rent_payment_found) THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_RENT_ERROR');
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --return;
      END IF;
      IF (l_principal_payment_found) THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LLA_VAR_RATE_PRIN_ERROR');
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                RETURN;
      END IF;
    END IF;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before exitting: x_return_status=' || x_return_status);
  END IF;
  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_rl_csr1%ISOPEN THEN
      CLOSE l_rl_csr1;
    END IF;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_txl_csr%ISOPEN THEN
      CLOSE l_txl_csr;
    END IF;

  END check_payment_type;

  -- Start of comments
  --
  -- Procedure Name  : check_variable_rate
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

PROCEDURE check_variable_rate(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
) IS
x_msg_count NUMBER;
x_msg_data VARCHAR2(2000);
l_return_status VARCHAR2(1);

BEGIN
  IF (G_DEBUG_ENABLED = 'Y') THEN
    G_IS_DEBUG_STATEMENT_ON := OKL_DEBUG_PUB.CHECK_LOG_ON(G_MODULE, FND_LOG.LEVEL_STATEMENT);
  END IF;
  x_return_status := Okl_Api.G_RET_STS_SUCCESS;

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'Before calling validate_k_rate_params...');
  END IF;
  Okl_K_Rate_Params_Pvt.validate_k_rate_params(
    p_api_version    => 1,
    p_init_msg_list  => Okl_Api.G_FALSE,
    x_return_status  => x_return_status,
    x_msg_count      => x_msg_count,
    x_msg_data       => x_msg_data,
    p_khr_id         => p_chr_id,
    p_validate_flag  => 'F');

  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After validate_k_rate_params x_return_status=' || x_return_status);
  END IF;
  IF (x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
    --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    --RAISE OKL_API.G_EXCEPTION_HALT_VALIDATION;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
  END IF;

  l_return_status := Okl_Api.G_RET_STS_SUCCESS;
  check_payment_type(
    x_return_status   => l_return_status,
    p_chr_id          => p_chr_id);
  IF (G_IS_DEBUG_STATEMENT_ON = true) THEN
      OKL_DEBUG_PUB.LOG_DEBUG(FND_LOG.LEVEL_STATEMENT, G_MODULE,'After check_payment_type l_return_status=' || l_return_status);
  END IF;

  IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
    --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    NULL;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    -- Close cursors if still open
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    --x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    -- verify that cursor was closed

END check_variable_rate;

/* -- AKP: Commented out for OKL.H drop0. */

  -- Start of comments
  --
  -- Procedure Name  : check_variable_rate_old
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_variable_rate_old(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    l_hdr_rec l_hdr_csr%ROWTYPE;
    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    index_rec index_csr%ROWTYPE;
    index_date DATE;
    index_name VARCHAR2(256);
    var_meth VARCHAR2(256);
    calc_meth VARCHAR2(256);
    l_deal_type VARCHAR2(256);

--Bug#3931587
    CURSOR l_pmnt_strm_check(rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                       rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       --pmnt_strm_name OKL_STRMTYP_SOURCE_V.NAME%TYPE,
                       pmnt_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE,
                       chrId NUMBER) IS
    SELECT crg.cle_id,
           crl.id,
           crl.object1_id1,
           crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION2,
           crl.RULE_INFORMATION3,
           crl.RULE_INFORMATION4,
           crl.RULE_INFORMATION5,
           crl.RULE_INFORMATION6,
           crl.RULE_INFORMATION10,
           crl.RULE_INFORMATION11
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = crl.object1_id1
           --and stty.code = pmnt_strm_name
           AND stty.stream_type_purpose = pmnt_strm_purpose
           AND crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;
  l_pmnt_strm_check_rec l_pmnt_strm_check%ROWTYPE;
    CURSOR l_pmnt_lns_in_hdr(p_id OKC_RULES_B.ID%TYPE, chrId NUMBER) IS
    SELECT
    crl2.object1_id1,
    crl2.object1_id2,
    crl2.rule_information2,
    NVL(crl2.rule_information3,0) rule_information3,
    crl2.rule_information4,
    crl2.rule_information5,
    crl2.rule_information6,
    crl2.rule_information7,
    crl2.rule_information8,
    crl2.rule_information10
    FROM   OKC_RULES_B crl1, OKC_RULES_B crl2
    WHERE crl1.id = crl2.object2_id1
    AND crl1.id = p_id
    AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
    AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
    AND crl1.dnz_chr_id = chrId
    AND crl2.dnz_chr_id = chrId
    ORDER BY crl2.rule_information2 ASC;

    l_pmnt_lns_in_hdr_rec l_pmnt_lns_in_hdr%ROWTYPE;
-- this record is required to compare the different records in cursor loop
    l_pmnt_lns_in_hdr_rec_comp l_pmnt_lns_in_hdr%ROWTYPE;
    variable_int_yn VARCHAR2(256);
    ind NUMBER;
    l_no_pmnt_lns_found  NUMBER;
    line_ind NUMBER;
    l_global_min_start_date DATE;
    l_min_start_date DATE;
    l_global_total_periods NUMBER;
    l_line_total_periods NUMBER;
    l_mismatch_exception EXCEPTION;
    l_variable_int_yn BOOLEAN;
    l_var_rate_reamort_exception EXCEPTION;
    l_invalid_combination EXCEPTION;
    l_loan_rev_var_rate EXCEPTION;
    l_process_formula_exception EXCEPTION;

    --Bug#3877032
    CURSOR l_hdr_csr1(chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT CHR.SCS_CODE,
               CHR.START_DATE,
               CHR.END_DATE,
               CHR.DATE_SIGNED,
               CHR.CURRENCY_CODE,
               CHR.TEMPLATE_YN,
               CHR.contract_number,
               khr.accepted_date,
               khr.syndicatable_yn,
               khr.DEAL_TYPE,
               khr.term_duration term,
	       NVL(pdt.reporting_pdt_id, -1) report_pdt_id
        FROM OKC_K_HEADERS_B CHR,
	     OKL_K_HEADERS khr,
	     OKL_PRODUCTS_V pdt
        WHERE CHR.id = chrid
           AND CHR.id = khr.id
	   --AND khr.pdt_id = pdt.id(+);
	   AND khr.pdt_id = pdt.id;

    l_hdr_rec1 l_hdr_csr1%ROWTYPE;
    lx_return_status  VARCHAR2(1);

    PROCEDURE l_formula_processing(x_return_status  OUT NOCOPY VARCHAR2,
                                   p_chr_id IN  OKC_K_HEADERS_B.ID%TYPE) IS
    BEGIN
      -- initialize return status
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      ind := 0;
      --Bug#3931587
      --FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE INTEREST SCHEDULE',p_chr_id)
      --FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE_INTEREST',p_chr_id)
      FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE_INTEREST_SCHEDULE',p_chr_id)
      LOOP
        ind := ind + 1;
        IF (l_pmnt_strm_check_rec.cle_id IS NOT NULL) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          --message
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_LINE_LEVEL');
        END IF;
        l_no_pmnt_lns_found := 0;
        FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_check_rec.id, p_chr_id)
        LOOP
          l_no_pmnt_lns_found := l_no_pmnt_lns_found + 1 ;
          EXIT WHEN l_pmnt_lns_in_hdr%NOTFOUND;
          IF ( l_pmnt_lns_in_hdr_rec.rule_information6 <> 0 ) THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            --message
            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_SLL_AMOUNT');
          END IF;
          IF ( ( l_hdr_rec.deal_type = 'LOAN' OR l_hdr_rec.deal_type = 'LOAN-REVOLVING')
             AND
             ( NVL(l_pmnt_lns_in_hdr_rec.rule_information10,'N') = 'N' ) ) THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            --message
            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_ADV');
          END IF;
        END LOOP;
        IF(l_no_pmnt_lns_found = 0) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          --message
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_NO_SLL');
        END IF;
      END LOOP;
      IF (ind = 0) THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        --message
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_VARINT_NOT_DEFINED');
      END IF;

      --IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      --   OKL_API.set_message(
      --    p_app_name      => G_APP_NAME,
      --    p_msg_name      => G_QA_SUCCESS);
      --END IF;

      IF l_pmnt_lns_in_hdr%ISOPEN THEN
        CLOSE l_pmnt_lns_in_hdr;
      END IF;
      IF l_pmnt_strm_check%ISOPEN THEN
        CLOSE l_pmnt_strm_check;
      END IF;

    EXCEPTION WHEN OTHERS THEN
      IF l_pmnt_lns_in_hdr%ISOPEN THEN
        CLOSE l_pmnt_lns_in_hdr;
      END IF;
      IF l_pmnt_strm_check%ISOPEN THEN
       CLOSE l_pmnt_strm_check;
      END IF;
    END l_formula_processing;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN l_hdr_csr( p_chr_id );
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;

    OPEN l_hdrrl_csr( 'LAIIND', 'LAINTP', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    -- boolean variable to check if interest rate rule exists and if variable rate is Y
    l_variable_int_yn := l_hdrrl_csr%FOUND AND (l_hdrrl_rec.rule_information1 = 'Y');
    l_deal_type := l_hdr_rec.deal_type;
    CLOSE l_hdrrl_csr;

    OPEN l_hdrrl_csr( 'LAIIND', 'LAIVAR', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF (l_variable_int_yn) THEN -- dedey
       IF ( l_hdrrl_csr%NOTFOUND ) OR
          ( l_hdrrl_rec.rule_information1 IS NULL ) OR
          ( l_hdrrl_rec.rule_information2 IS NULL )  THEN
           Okl_Api.set_message(
                 p_app_name     => G_APP_NAME,
                 p_msg_name     => 'OKL_QA_NO_VARMETH');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
    END IF;
    CLOSE l_hdrrl_csr;
    var_meth := l_hdrrl_rec.rule_information1;

    OPEN l_hdrrl_csr( 'LAIIND', 'LAICLC', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
    calc_meth := l_hdrrl_rec.rule_information5;

    -------------------------------------------------------------
    --Bug#4018298
    --Start variable interest processing based on Product.
    -------------------------------------------------------------
    BEGIN
    IF (l_deal_type = 'LOAN') THEN
      IF (l_variable_int_yn ) THEN
        IF (var_meth = 'FLOAT' AND calc_meth = 'FORMULA') THEN
          l_formula_processing(x_return_status => lx_return_status, p_chr_id => p_chr_id) ;
              IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    x_return_status := lx_return_status;
              END IF;
        ELSIF (var_meth = 'FIXEDADJUST' AND calc_meth = 'REAMORT') THEN
          -- variable interest schedule payments not allowed for reamort.
          RAISE l_var_rate_reamort_exception;
        ELSE
          RAISE l_invalid_combination;
        END IF;
      ELSIF (NOT l_variable_int_yn ) THEN
        --return success
        Okl_Api.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => G_QA_SUCCESS);
            RETURN;
      END IF;
    ELSIF(l_deal_type = 'LOAN-REVOLVING') THEN
      IF (l_variable_int_yn) THEN
        IF (var_meth = 'FLOAT' AND calc_meth = 'FORMULA') THEN
          l_formula_processing(x_return_status => lx_return_status, p_chr_id => p_chr_id) ;
              IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
                    x_return_status := lx_return_status;
              END IF;
        ELSE
          RAISE l_invalid_combination;
        END IF;
      ELSIF (NOT l_variable_int_yn ) THEN
        RAISE l_loan_rev_var_rate;
      END IF;
    ELSE -- operating, direct finance, sales type leases
      IF (l_variable_int_yn ) THEN
        IF (var_meth = 'FIXEDADJUST' AND calc_meth = 'REAMORT') THEN
          -- variable interest schedule payments not allowed for reamort.
          RAISE l_var_rate_reamort_exception;
        ELSE
          RAISE l_invalid_combination;
        END IF;
      ELSIF (NOT l_variable_int_yn ) THEN
        --return success
        Okl_Api.set_message(
            p_app_name      => G_APP_NAME,
            p_msg_name      => G_QA_SUCCESS);
            RETURN;
      END IF;
    END IF;
    -----------------------------------------------
    EXCEPTION
    -----------------------------------------------
    WHEN l_invalid_combination THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_VARIABLE_INV_COMB',
                p_token1       => 'VAR_METHOD',
                p_token1_value => var_meth,
                p_token2       => 'CALC_METHOD',
                p_token2_value => calc_meth);
    WHEN l_loan_rev_var_rate THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_LV_VARINT');
    WHEN l_var_rate_reamort_exception THEN
      --Bug#3365616
      --Bug#3554026 checking for scs_code instead of deal_type
      IF (l_hdr_rec.scs_code = 'LEASE') THEN
        --Bug#3931587
        --OPEN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE INTEREST SCHEDULE',p_chr_id);
        --OPEN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE_INTEREST',p_chr_id);
        OPEN l_pmnt_strm_check('LALEVL','LASLH','VARIABLE_INTEREST_SCHEDULE',p_chr_id);
        FETCH l_pmnt_strm_check INTO l_pmnt_strm_check_rec;
        IF( l_pmnt_strm_check%FOUND) THEN
          Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_LN_VARINT_REAMORT');
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
        CLOSE l_pmnt_strm_check;
      END IF;
    END;
    -------------------------------------------------------------
    --End variable interest processing based on Product.
    -------------------------------------------------------------

    IF l_pmnt_lns_in_hdr%ISOPEN THEN
      CLOSE l_pmnt_lns_in_hdr;
    END IF;
    IF l_pmnt_strm_check%ISOPEN THEN
      CLOSE l_pmnt_strm_check;
    END IF;

    -------------------------------------------------------------
    --Reamort Rent stream processing start for Variable rate Contracts.
    -------------------------------------------------------------
    IF (l_variable_int_yn) THEN
      IF ( calc_meth  = 'REAMORT' ) THEN

        /*
        *--Bug#3369032
        *If (l_hdr_rec.deal_type = 'LOAN-REVOLVING') Then
        *  OKL_API.set_message(
        *          p_app_name     => G_APP_NAME,
        *          p_msg_name     => 'OKL_QA_LN_REV_REAMORT');
        *  x_return_status := OKL_API.G_RET_STS_ERROR;
        *End If;
        */

        ind := 0;
        l_global_total_periods := 0;
        l_line_total_periods := 0;
        FOR l_pmnt_strm_check_rec IN l_pmnt_strm_check('LALEVL','LASLH','RENT',p_chr_id)
        LOOP
        BEGIN
          line_ind := 0;
          FOR l_pmnt_lns_in_hdr_rec IN l_pmnt_lns_in_hdr(l_pmnt_strm_check_rec.id ,p_chr_id)
          LOOP
            IF ( ind = 0 ) THEN
              ind := 1;
              l_pmnt_lns_in_hdr_rec_comp := l_pmnt_lns_in_hdr_rec;
              -- global min start date is start date for first payment line for that SLH
              l_global_min_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
            END IF;
            IF (line_ind = 0) THEN
              l_min_start_date := Fnd_Date.canonical_to_date(l_pmnt_lns_in_hdr_rec.rule_information2);
              line_ind := 1;
              l_line_total_periods := l_pmnt_lns_in_hdr_rec.rule_information3;
            ELSE
              l_line_total_periods := l_line_total_periods + l_pmnt_lns_in_hdr_rec.rule_information3;
            END IF;
            IF( l_pmnt_lns_in_hdr_rec.rule_information7 IS NULL
              AND l_pmnt_lns_in_hdr_rec.rule_information8 IS NULL) THEN
              IF( NVL(l_pmnt_lns_in_hdr_rec.rule_information10,'N') <> 'Y') THEN
                RAISE l_mismatch_exception;
              END IF;
              IF (ind = 0) THEN
                NULL;--dont compare two records as we are at first record now.
              ELSE
                IF ( l_global_min_start_date
                       <> l_min_start_date
                     OR l_pmnt_lns_in_hdr_rec_comp.rule_information4
                       <> l_pmnt_lns_in_hdr_rec.rule_information4
                     OR l_pmnt_lns_in_hdr_rec_comp.object1_id1
                       <> l_pmnt_lns_in_hdr_rec.object1_id1
                     OR l_pmnt_lns_in_hdr_rec_comp.object1_id2
                       <> l_pmnt_lns_in_hdr_rec.object1_id2 ) THEN
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
                  RAISE l_mismatch_exception;
                END IF;
              END IF;
            END IF;
          END LOOP;
          -- the sum of all SLL periods across all SLH's should match.
          IF (l_global_total_periods = 0 ) THEN
            l_global_total_periods := l_line_total_periods;
          ELSIF(l_global_total_periods <> l_line_total_periods) THEN
               RAISE l_mismatch_exception;
          END IF;
        EXCEPTION WHEN l_mismatch_exception THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          --message
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARINT_SLL_MISMATCH');
        END;
        END LOOP;
        IF l_pmnt_lns_in_hdr%ISOPEN THEN
          CLOSE l_pmnt_lns_in_hdr;
        END IF;
        IF l_pmnt_strm_check%ISOPEN THEN
          CLOSE l_pmnt_strm_check;
        END IF;
      END IF;
    END IF;
    -------------------------------------------------------------
    --End REAMORT processing for rent streams for variable rate contracts.
    -------------------------------------------------------------

   /*
    OPEN l_hdrrl_csr( 'LAIIND', 'LAINTP', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    If ( l_hdrrl_csr%NOTFOUND ) OR
       ( nvl(l_hdrrl_rec.rule_information1, 'N') = 'N' )Then
        CLOSE l_hdrrl_csr;
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
	return;
    End If;

    If (l_hdrrl_rec.RULE_INFORMATION1 = 'Y') AND
       (INSTR(l_hdr_rec.deal_type,'LOAN') < 1)  Then
        OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VAR_RATE_LN');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    End If;
    CLOSE l_hdrrl_csr;
   */

    OPEN l_hdrrl_csr( 'LAIIND', 'LAIVAR', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;

    var_meth := l_hdrrl_rec.rule_information1;

    FOR index_rec IN index_csr( TO_NUMBER(l_hdrrl_rec.rule_information2) )
    LOOP
        index_date := NVL(index_rec.datetime_valid, SYSDATE);
	index_name := index_rec.name;
	EXIT;
    END LOOP;

    IF ( TRUNC(l_hdr_rec.start_date) < TRUNC(index_date) ) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_INDEXDATE');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    OPEN l_hdrrl_csr( 'LAIIND', 'LAICLC', p_chr_id );
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF ( l_hdrrl_csr%NOTFOUND ) OR
       ( l_hdrrl_rec.rule_information4 IS NULL ) OR
       ( l_hdrrl_rec.rule_information5 IS NULL )  THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_VARCLC');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_hdrrl_csr;

    calc_meth := l_hdrrl_rec.rule_information5;

    OPEN l_hdr_csr1( p_chr_id );
    FETCH l_hdr_csr1 INTO l_hdr_rec1;
    CLOSE l_hdr_csr1;

    IF ( TRUNC(l_hdr_rec1.start_date)
    > TRUNC(Fnd_Date.canonical_to_date(l_hdrrl_rec.rule_information4)) )
    OR
    ( TRUNC(l_hdr_rec1.end_date)
    < TRUNC(Fnd_Date.canonical_to_date(l_hdrrl_rec.rule_information4)) ) THEN
      Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_INT_START_DATE_EFF');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    /*If ( l_hdr_rec.start_date < FND_DATE.canonical_to_date(l_hdrrl_rec.rule_information4) ) Then
        OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_CLCDATE');
        x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;
   */

    /*
    *If ( var_meth = 'FLOAT' ) AND
    *   ( calc_meth <> 'FORMULA') Then
    *    OKL_API.set_message(
    *          p_app_name     => G_APP_NAME,
    *          p_msg_name     => 'OKL_QA_VARFLOAT');
    *    x_return_status := OKL_API.G_RET_STS_ERROR;
    *End If;
    */

/*
    If ( var_meth = 'FLOAT' ) AND
       ( calc_meth = 'FORMULA' ) Then

        OPEN l_hdrrl_csr( 'LAIIND', 'LAFORM', p_chr_id );
        FETCH l_hdrrl_csr INTO l_hdrrl_rec;
        If ( l_hdrrl_csr%NOTFOUND ) OR
           ( l_hdrrl_rec.rule_information1 IS NULL )  Then
            OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VARNOFORM');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
        End If;
        CLOSE l_hdrrl_csr;

    End If;

*/

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;

  END check_variable_rate_old;

  -- Start of comments
  --
  -- Procedure Name  : check_prefunding_status
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_prefunding_status(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status	VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    -- sjalasut, modified the cursor to refer khr_id from okl_txl_ap_inv_lns_all_b
    -- instead of okl_trx_ap_invoices_b. changes made as part of OKLR12B
    -- disbursements project
    CURSOR l_prefund_csr( chrId NUMBER ) IS
    SELECT 'Y'
    FROM okl_trx_ap_invoices_b hdr
        ,okl_txl_ap_inv_lns_all_b tpl
    WHERE hdr.funding_type_code = 'PREFUNDING'
      AND hdr.trx_status_code NOT IN ('APPROVED', 'PROCESSED', 'ERROR')
      AND hdr.id = tpl.tap_id
     	AND tpl.khr_id = chrId;

    l_prefund_yn VARCHAR2(1);

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN l_prefund_csr( p_chr_id );
    FETCH l_prefund_csr INTO l_prefund_yn;
    IF ( l_prefund_csr%FOUND AND (l_prefund_yn = 'Y')) THEN
        Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_PREFUND_MIN');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_prefund_csr;

  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF l_prefund_csr%ISOPEN THEN
      CLOSE l_prefund_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_prefund_csr%ISOPEN THEN
      CLOSE l_prefund_csr;
    END IF;

  END check_prefunding_status;

  -- Bug# 4350255
  -- Added Validations for Asset Line Passthrough
  -- Start of comments
  --
  -- Procedure Name  : check_fee_service_ast_pth
  -- Description     : Check Passthorugh stream type in ASSET, FEE and SERVICE line.
  --                   If it is null, raise error
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_fee_service_ast_pth(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

   --Bug 4917691 fmiao start-----------------------------
   --1. If evg hdr is defined, vendor params detail is required
   --Find out whether contract evg hdr is existing --
   CURSOR evg_hdr_csr (p_chr_id IN NUMBER) IS
   SELECT '1'
   FROM okl_party_payment_hdr
   WHERE dnz_chr_id = p_chr_id
   AND cle_id IS NULL;

   l_evg_hdr_exist VARCHAR2(1);

   --Find out all the vendors for the contract
   CURSOR chr_vendor_csr (p_chr_id IN NUMBER) IS
   SELECT object1_id1, po.vendor_name
   FROM okc_k_party_roles_b, po_vendors po
   WHERE chr_id = p_chr_id
   AND rle_code = 'OKL_VENDOR'
   AND po.vendor_id = object1_id1;

   -- Find out whether vendor evg pt params exists
   CURSOR evg_dtls_csr (p_vendor_id IN NUMBER, p_chr_id IN NUMBER) IS
   SELECT '1'
   FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
   WHERE ppy.vendor_id = p_vendor_id
   AND ppy.payment_hdr_id = pph.id
   AND pph.dnz_chr_id = p_chr_id
   AND pph.cle_id IS NULL;

   l_evg_dtls_exist VARCHAR2(1);

   --2. Check the disb amt not exceed line payment amt --
   -- Find out lines for a contract
   CURSOR lines_csr(p_chr_id IN NUMBER) IS
   SELECT cle.id,cle.name,lse.lty_code
   FROM okl_k_lines_full_v cle, okc_line_styles_v lse
   WHERE cle.dnz_chr_id = p_chr_id
   AND cle.lse_id = lse.id
   AND lse.lty_code IN ('FREE_FORM1','FEE','SOLD_SERVICE');

   -- Find out the disb fixed amt for each line for all vendors--
   CURSOR disb_amt_csr (p_chr_id IN NUMBER, p_cle_id IN NUMBER,
                        p_term IN okl_party_payment_hdr.PASSTHRU_TERM%TYPE) IS
   SELECT SUM(ppy.disbursement_fixed_amount)
   FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
   WHERE pph.dnz_chr_id = p_chr_id
   AND NVL(pph.cle_id, -9999) = p_cle_id
   AND pph.id = ppy.payment_hdr_id
	  AND pph.passthru_term = p_term
   GROUP BY ppy.payment_hdr_id;

   -- Find out the disb fixed amt for all vendors on the contract--
   CURSOR disb_amt_csr1 (p_chr_id IN NUMBER) IS
   SELECT SUM(ppy.disbursement_fixed_amount), pph.passthru_term, pph.payout_basis
   FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
   WHERE pph.dnz_chr_id = p_chr_id
   AND pph.cle_id IS NULL
   AND pph.id = ppy.payment_hdr_id
   GROUP BY ppy.payment_hdr_id,pph.passthru_term, pph.payout_basis;

   -- Bug#8399461 - RGOOTY
   --Cursor to get the Passthrough Disbursement information
   CURSOR c_pass(khrId NUMBER, cleId NUMBER) IS
   SELECT vDtls.DISBURSEMENT_BASIS,
          vDtls.DISBURSEMENT_FIXED_AMOUNT,
          vDtls.DISBURSEMENT_PERCENT,
          vDtls.PROCESSING_FEE_BASIS,
          vDtls.PROCESSING_FEE_FIXED_AMOUNT,
          vDtls.PROCESSING_FEE_PERCENT,
          vDtls.PAYMENT_START_DATE,
          vDtls.PAYMENT_FREQUENCY,
          chr.END_DATE CONTRACT_END_DATE
     FROM okl_party_payment_hdr vHdr,
          okl_party_payment_dtls vDtls,
          okc_k_headers_b chr
    WHERE vDtls.payment_hdr_id = vHdr.id
      AND vHdr.CLE_ID = cleId
      AND vHdr.DNZ_CHR_ID = khrId
      AND vHdr.PASSTHRU_TERM = 'BASE'
      AND vHdr.DNZ_CHR_ID = chr.id;

   --Cursor to get the number of disbursements
   CURSOR c_num_of_disb(p_contract_end_date DATE, p_payout_date DATE, p_frequency VARCHAR2)
   IS
     SELECT CEIL(Months_between(p_contract_end_date, p_payout_date)/
            DECODE(p_frequency,'A',12,'S',6,'Q',3,1))
       FROM DUAL;

   l_fixed_amt okl_party_payment_dtls.disbursement_fixed_amount%TYPE;
   l_payout_basis okl_party_payment_hdr.payout_basis%TYPE;
   l_passthru_term okl_party_payment_hdr.passthru_term%TYPE;

   --Found out payout basis
   CURSOR payout_basis_csr (p_chr_id IN NUMBER,p_cle_id IN NUMBER )IS
   SELECT pph.passthru_term, pph.payout_basis
   FROM okl_party_payment_hdr pph
   WHERE pph.dnz_chr_id = p_chr_id
   AND pph.cle_id = p_cle_id;

   --Find out the payment info for contract line
   CURSOR pymnt_amt_csr (p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
   SELECT Fnd_Date.canonical_to_date(sll.rule_information2) start_date,
	         DECODE(sll.rule_information7, NULL,
                 (ADD_MONTHS(Fnd_Date.canonical_to_date(sll.rule_information2),
                   NVL(TO_NUMBER(sll.rule_information3),1) *
                   DECODE(sll.object1_id1, 'M',1,'Q',3,'S',6,'A',12)) - 1),
                 Fnd_Date.canonical_to_date(sll.rule_information2) +
                   TO_NUMBER(sll.rule_information7) - 1) end_date,
         TO_NUMBER(sll.rule_information6) amount
    FROM okc_rules_b sll,
         okc_rules_b slh,
         okc_rule_groups_b rgp
    WHERE rgp.dnz_chr_id = p_chr_id
    AND rgp.cle_id = p_cle_id
    AND rgp.rgd_code = 'LALEVL'
    AND slh.rgp_id = rgp.id
    AND slh.rule_information_category = 'LASLH'
    AND sll.object2_id1 = slh.id
    AND sll.rule_information_category = 'LASLL'
    AND sll.rgp_id = rgp.id
    AND NVL(sll.rule_information6,0) <> 0
    ORDER BY start_date, end_date;

    TYPE amt_type IS TABLE OF okc_rules_b.rule_information6%TYPE;
    pymnt_amt amt_type;
    TYPE sdate_type IS TABLE OF okc_rules_b.rule_information2%TYPE;
    start_date sdate_type;
    TYPE edate_type IS TABLE OF okc_rules_b.rule_information2%TYPE;
    end_date edate_type;
    l_payment_amt okc_rules_b.rule_information6%TYPE;

	--3. Disb basis for all vendors should be same
    CURSOR disb_basis_csr (p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
    SELECT ppy.disbursement_basis, po.vendor_name
    FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph, okc_k_party_roles_b rle, po_vendors po
    WHERE pph.dnz_chr_id = p_chr_id
    AND pph.cle_id = p_cle_id
    AND pph.id = ppy.payment_hdr_id
	AND ppy.cpl_id = rle.id
    AND rle.rle_code = 'OKL_VENDOR'
	AND rle.object1_id1 = po.vendor_id;

    l_disb_basis okl_party_payment_dtls.disbursement_basis%TYPE;

	--4. Total process fee fixed amt not exceed line amt
    CURSOR proc_fee_amt_csr (p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
    SELECT SUM(ppy.processing_fee_fixed_amount)
    FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
    WHERE pph.dnz_chr_id = p_chr_id
    AND pph.cle_id = p_cle_id
    AND pph.id = ppy.payment_hdr_id;

    l_proc_fee_amt okl_party_payment_dtls.processing_fee_fixed_amount%TYPE;

    CURSOR pth_amount_csr(p_chr_id IN NUMBER, p_cle_id IN NUMBER) IS
    SELECT SUM(ppy.disbursement_fixed_amount)
    FROM okl_party_payment_dtls ppy, okl_party_payment_hdr pph
    WHERE pph.dnz_chr_id = p_chr_id
    AND pph.cle_id = p_cle_id
    AND pph.id = ppy.payment_hdr_id;

    l_pth_amt    okl_party_payment_dtls.disbursement_fixed_amount%TYPE;

    --Bug 4917691 fmiao end ------------------------------------


  CURSOR con_type_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT 'Y'
  FROM   okc_k_headers_b
  WHERE  orig_system_source_code = 'OKL_REBOOK'
  AND    id = p_chr_id;

  --------------
  --Bug# 4350255
  --------------
  CURSOR pth_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT line.id,
         DECODE(style.lty_code,'SOLD_SERVICE','SERVICE',style.lty_code) line_type,
         NVL(line.name,line.item_description) name,
         line.fee_type,
         style.name line_style,
         line.amount amount,
         line.start_date,
         line.end_date,
         pph.id payment_hdr_id,
         pph.passthru_start_date,
         pph.passthru_term,
         pph.passthru_stream_type_id
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v style,
         okc_statuses_v sts,
         okl_party_payment_hdr pph
  WHERE  line.lse_id                    = style.id
  AND    line.sts_code                  = sts.code
  AND    sts.ste_code                   NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    style.lty_code                 IN ('SOLD_SERVICE','FEE','FREE_FORM1')
  AND    line.dnz_chr_id                = p_chr_id
  AND    pph.cle_id                     = line.id
  AND    pph.dnz_chr_id                 = p_chr_id;

  CURSOR pth_dtl_csr(p_payment_hdr_id IN NUMBER) IS
  SELECT disbursement_basis,
         disbursement_fixed_amount,
         disbursement_percent,
         payment_start_date,
         vendor_id
  FROM   okl_party_payment_dtls
  WHERE  payment_hdr_id = p_payment_hdr_id;

  CURSOR vendor_csr(p_vendor_id IN NUMBER) IS
  SELECT vendor_name
  FROM   po_vendors
  WHERE  vendor_id = p_vendor_id;

  l_vendor_name po_vendors.vendor_name%TYPE;
  l_pct_sum NUMBER;
  l_pth_dtl_present_yn VARCHAR2(1);

  --Bug#3877032
  /*CURSOR pth_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.id,
         decode(style.lty_code,'SOLD_SERVICE','SERVICE',style.lty_code) line_type,
         nvl(line.name,line.item_description) name,
         line.fee_type,
         rule.object1_id1,
         style.name line_style
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v style,
         okc_statuses_v sts,
         okc_rule_groups_b rgp,
         okc_rules_b rule
  WHERE  rgp.id                         = rule.rgp_id
  AND    line.id                        = rgp.cle_id
  AND    line.lse_id                    = style.id
  AND    line.sts_code                  = sts.code
  AND    sts.ste_code                   NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    style.lty_code                 IN ('SOLD_SERVICE','FEE')
  AND    rgp.rgd_code                   = 'LAPSTH'
  AND    rule.rule_information_category = 'LASTRM'
  AND    line.dnz_chr_id                = p_chr_id
  AND    rgp.dnz_chr_id                 = p_chr_id;*/


  -- Added cursor - bug# 8399461
  --Cursor to get the fee payment frequency
  CURSOR c_feepayment_freq(khrId NUMBER, cleId NUMBER) IS
    SELECT rul.object1_id1 frequency
      FROM okc_rule_groups_b rgp,
           okc_rules_b rul
     WHERE rgp.dnz_chr_id = khrId
       AND rgp.cle_id = cleId
       AND rgp.RGD_CODE = 'LALEVL'
       AND rgp.id = rul.rgp_id
       AND rul.RULE_INFORMATION_CATEGORY = 'LASLL'
       AND ROWNUM < 2;

  --------------
  --Bug# 4350255
  --------------

  l_type VARCHAR2(1);
  l_present_yn VARCHAR2(1);
  l_strm_name_rec strm_name_csr%ROWTYPE;

  i NUMBER := 1;
  l_found NUMBER := 0; -- Added for bug 5201664


  -- Added variables for bug# 8399461
  l_pymnt_frequency VARCHAR2(1);
  l_frequency VARCHAR2(1);
  l_months_factor NUMBER;
  l_num_of_disb NUMBER;
  l_last_payout_date DATE;
  l_bill_amount NUMBER;


  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    --Bug 4917691 fmiao start ---------------------------------------

    --1.If evg hdr is defined, all the vendors should have evg pt params defined
	l_evg_hdr_exist := NULL;
	OPEN evg_hdr_csr (p_chr_id);
	FETCH evg_hdr_csr INTO l_evg_hdr_exist;
	CLOSE evg_hdr_csr;

	IF (l_evg_hdr_exist IS NOT NULL) THEN
      FOR chr_vendor_rec IN chr_vendor_csr (p_chr_id)
      LOOP
        OPEN evg_dtls_csr (chr_vendor_rec.object1_id1, p_chr_id);
        FETCH evg_dtls_csr INTO l_evg_dtls_exist;
        CLOSE evg_dtls_csr;
	-- changed below condition for bug 5201664
         IF (l_evg_dtls_exist IS NOT NULL) THEN
              l_found := 1;
              EXIT;
        END IF;
        l_evg_dtls_exist := NULL;
      END LOOP;

      IF (l_found = 0) THEN

          Okl_Api.set_message(
      			p_app_name => G_APP_NAME,
      			p_msg_name => 'OKL_QA_EVG_PT_NO_DTLS');
      	  x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
       -- end bug 5201664
	END IF;

    -- 2.Check the disb amt of all vendors for a line not exceed line pymnt amt

    FOR lines_rec IN lines_csr (p_chr_id)
    LOOP

      IF (lines_rec.lty_code = 'FREE_FORM1') THEN

	    FOR payout_basis_rec IN payout_basis_csr (p_chr_id, lines_rec.id)
		 LOOP


	    IF (payout_basis_rec.passthru_term IS NULL) THEN
	      OPEN disb_amt_csr1 (p_chr_id);
	      FETCH disb_amt_csr1 INTO l_fixed_amt,l_passthru_term, l_payout_basis;
	      CLOSE disb_amt_csr1;
	    ELSE
	      OPEN disb_amt_csr (p_chr_id, lines_rec.id,payout_basis_rec.passthru_term);
          FETCH disb_amt_csr INTO l_fixed_amt;
          CLOSE disb_amt_csr;
	    END IF;

        IF (l_fixed_amt IS NOT NULL) THEN
	      OPEN pymnt_amt_csr (p_chr_id, lines_rec.id);
	      FETCH pymnt_amt_csr BULK COLLECT INTO start_date, end_date, pymnt_amt;
	      CLOSE pymnt_amt_csr;

	      IF (payout_basis_rec.passthru_term = 'EVERGREEN' AND
	        payout_basis_rec.payout_basis IN ('BILLING','FULL_RECEIPT','PARTIAL_RECEIPT')) THEN
            FOR i IN pymnt_amt.first..pymnt_amt.last
				LOOP
				  l_payment_amt := pymnt_amt(i);
            END LOOP;
	        IF (l_fixed_amt > l_payment_amt) THEN
	          Okl_Api.set_message(
                      p_app_name => G_APP_NAME,
                      p_msg_name => 'OKL_QA_FIXED_AMT_EXC_PYMNT_AMT',
                      p_token1       => 'DISB_AMOUNT',
					  p_token1_value => l_fixed_amt,
                      p_token2       => 'TERM',
					  p_token2_value => payout_basis_rec.passthru_term,
                      p_token3       => 'PYMNT_AMT',
					  p_token3_value => l_payment_amt,
                      p_token4       => 'LINE',
					  p_token4_value => lines_rec.name);
	          x_return_status := Okl_Api.G_RET_STS_ERROR;
	        END IF;
	      END IF;
	    END IF;
		 END LOOP;
      ELSE -- 'FEE' 'SOLD_SERVICE'

	    FOR payout_basis_rec IN payout_basis_csr (p_chr_id, lines_rec.id)
		 LOOP

	      OPEN disb_amt_csr (p_chr_id, lines_rec.id, payout_basis_rec.passthru_term);
	      FETCH disb_amt_csr INTO l_fixed_amt;
	      CLOSE disb_amt_csr;

         -- Bug# 8399461 - Commented so that validation considers percentage in calculation of disbursement amount
         --IF (l_fixed_amt IS NOT NULL) THEN
	        OPEN pymnt_amt_csr (p_chr_id, lines_rec.id);
	        FETCH pymnt_amt_csr BULK COLLECT INTO start_date, end_date, pymnt_amt;
            CLOSE pymnt_amt_csr;

	        IF (payout_basis_rec.passthru_term = 'EVERGREEN' AND
		        payout_basis_rec.payout_basis IN ('BILLING','FULL_RECEIPT','PARTIAL_RECEIPT')) THEN
              FOR i IN pymnt_amt.first..pymnt_amt.last
              LOOP
                l_payment_amt := pymnt_amt(i);
              END LOOP;

	          IF (l_fixed_amt > l_payment_amt) THEN
	            Okl_Api.set_message(
                      p_app_name => G_APP_NAME,
                      p_msg_name => 'OKL_QA_FIXED_AMT_EXC_PYMNT_AMT',
                      p_token1       => 'DISB_AMOUNT',
					  p_token1_value => l_fixed_amt,
                      p_token2       => 'TERM',
					  p_token2_value => payout_basis_rec.passthru_term,
                      p_token3       => 'PYMNT_AMT',
					  p_token3_value => l_payment_amt,
                      p_token4       => 'LINE',
					  p_token4_value => lines_rec.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
	          END IF;
			 END IF ;

	        IF (payout_basis_rec.passthru_term = 'BASE' AND
		           payout_basis_rec.payout_basis IN ('BILLING','DUE_DATE','FULL_RECEIPT','PARTIAL_RECEIPT')) THEN


              -- Bug#8399461 - RGOOTY - Added logic to calculate total payment amount
              -- Get the total payment amount defined for the passthrough fee
              l_payment_amt := 0;
              FOR l_rl_rec1 IN l_rl_csr1( 'LALEVL', 'LASLL', p_chr_id, lines_rec.id )
              LOOP
                IF (l_rl_rec1.rule_information8 IS NOT NULL) THEN
                  l_payment_amt := l_payment_amt + TO_NUMBER(NVL(l_rl_rec1.rule_information8,'0'));
                ELSE
                  l_payment_amt := l_payment_amt + ( TO_NUMBER(NVL(l_rl_rec1.rule_information6,'0')) *
                                                 TO_NUMBER(NVL(l_rl_rec1.rule_information3,'1')) );
                END IF;
              END LOOP;

              -- Bug# 8399461 Calculate the total passthrough disbursement amount
              --If disbursement frequency is null then take the fee payment frequency
              OPEN c_feepayment_freq(p_chr_id, lines_rec.id);
                FETCH c_feepayment_freq INTO l_pymnt_frequency;
              CLOSE c_feepayment_freq;

              l_fixed_amt := 0;
              -- loop through the passthrough vendors for this passthrough fee
              FOR r_pass IN c_pass(p_chr_id,lines_rec.id)
              LOOP
                -- get disbursement frequency for this vendor. In case disbursement
                -- frequency is not defined, then fee payment frequency is considered
                l_frequency := NVL(r_pass.PAYMENT_FREQUENCY,l_pymnt_frequency);

                -- Calculate the factor of period in terms of months
                -- ex. If period is quarterly - factor = 3, annual - factor =12
                l_months_factor := OKL_STREAM_GENERATOR_PVT.get_months_factor(
                                  p_frequency     => l_frequency,
                                  x_return_status => x_return_status);
                IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                   RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;

                -- determine the number of disbursements
                OPEN c_num_of_disb(r_pass.CONTRACT_END_DATE, r_pass.PAYMENT_START_DATE, l_frequency);
                  FETCH c_num_of_disb INTO l_num_of_disb;
                CLOSE c_num_of_disb;

                -- if disbursement basis is fixed
                IF (r_pass.disbursement_basis = 'AMOUNT' ) THEN
                  l_fixed_amt := l_fixed_amt + NVL(l_num_of_disb * r_pass.disbursement_fixed_amount,0);
                  -- elseif disbursement basis is percentage
                ELSIF (r_pass.disbursement_basis = 'PERCENT' ) THEN
                  l_last_payout_date := ADD_MONTHS(r_pass.PAYMENT_START_DATE, (l_num_of_disb-1)*l_months_factor);
                  OKL_LA_STREAM_PVT.get_pth_fee_due_amount(p_chr_id           =>  p_chr_id,
                                      p_kle_id           =>  lines_rec.id,
                                      p_prev_payout_date =>  NULL,
                                      p_payout_date      =>  l_last_payout_date,
                                      x_bill_amount      =>  l_bill_amount,
                                      x_return_status    =>  x_return_status);
                  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;

                  l_fixed_amt := l_fixed_amt + NVL((l_bill_amount * r_pass.DISBURSEMENT_PERCENT)/100,0);
                END IF;

                -- if processing fee basis is fixed
                IF (r_pass.PROCESSING_FEE_BASIS = 'AMOUNT' ) THEN
                  l_fixed_amt := l_fixed_amt + NVL(l_num_of_disb * r_pass.PROCESSING_FEE_FIXED_AMOUNT,0);
                -- elseif processing fee basis is percentage
                ELSIF (r_pass.PROCESSING_FEE_BASIS = 'PERCENT' ) THEN
                  l_last_payout_date := ADD_MONTHS(r_pass.PAYMENT_START_DATE, (l_num_of_disb-1)*l_months_factor);
                  OKL_LA_STREAM_PVT.get_pth_fee_due_amount(p_chr_id           =>  p_chr_id,
                                      p_kle_id           =>  lines_rec.id,
                                      p_prev_payout_date =>  NULL,
                                      p_payout_date      =>  l_last_payout_date,
                                      x_bill_amount      =>  l_bill_amount,
                                      x_return_status    =>  x_return_status);
                  IF x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF x_return_status = OKL_API.G_RET_STS_ERROR THEN
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
                  l_fixed_amt := l_fixed_amt + NVL((l_bill_amount * r_pass.PROCESSING_FEE_PERCENT)/100,0);
                END IF;
              END LOOP;
              -- Bug#8399461 - RGOOTY: End

              --IF  (pymnt_amt.COUNT > 0) THEN -- 5207361
              --l_payment_amt := pymnt_amt(1);
              --ELSE
              --l_payment_amt := NULL;
              --END IF;

              IF (l_fixed_amt > l_payment_amt) THEN
                Okl_Api.set_message(
                      p_app_name => G_APP_NAME,
                      p_msg_name => 'OKL_QA_FIXED_AMT_EXC_PYMNT_AMT',
                      p_token1       => 'DISB_AMOUNT',
                      p_token1_value => l_fixed_amt,
                      p_token2       => 'TERM',
                      p_token2_value => payout_basis_rec.passthru_term,
                      p_token3       => 'PYMNT_AMT',
                      p_token3_value => l_payment_amt,
                      p_token4       => 'LINE',
                      p_token4_value => lines_rec.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
              END IF;
            END IF;
          --END IF;
        END LOOP;
      END IF;

      --3.Validate all vendors for 1 line should have the same disb basis

      l_disb_basis := NULL;
      FOR disb_basis_rec IN disb_basis_csr (p_chr_id, lines_rec.id)
      LOOP

        IF (l_disb_basis IS NOT NULL AND
            l_disb_basis <> disb_basis_rec.disbursement_basis) THEN

          Okl_Api.set_message(
                                p_app_name => G_APP_NAME,
                                p_msg_name => 'OKL_QA_INVALID_VEND_DISB_BASIS',
                              p_token1       => 'BASIS',
                              p_token1_value => disb_basis_rec.disbursement_basis,
                              p_token2       => 'VENDOR',
                              p_token2_value => disb_basis_rec.vendor_name,
                              p_token3       => 'LINE',
                              p_token3_value => lines_rec.name);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
        l_disb_basis := disb_basis_rec.disbursement_basis;

      END LOOP;

      --4.Validate processing fee amt no greater than line amt
      OPEN proc_fee_amt_csr (p_chr_id, lines_rec.id);
      FETCH proc_fee_amt_csr INTO l_proc_fee_amt;
      CLOSE proc_fee_amt_csr;

      OPEN pth_amount_csr (p_chr_id, lines_rec.id);
      FETCH pth_amount_csr INTO l_pth_amt;
      CLOSE pth_amount_csr;

      IF (l_proc_fee_amt IS NOT NULL AND l_pth_amt IS NOT NULL AND
          l_proc_fee_amt > l_pth_amt) THEN
            Okl_Api.set_message(
                                p_app_name => G_APP_NAME,
                                  p_msg_name => 'OKL_QA_PROC_FEE_GT_LINE_AMT',
                                p_token1       => 'PROC_AMT',
                                p_token1_value => l_proc_fee_amt,
                                p_token2       => 'PTH_AMT',
                                p_token2_value => l_pth_amt,
                                p_token3       => 'LINE',
                                p_token3_value => lines_rec.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;
    END LOOP;

    --Bug 4917691 fmiao end


    -- Bug# 4350255
    /*l_type := '?';
    OPEN con_type_csr (p_chr_id);
    FETCH con_type_csr INTO l_type;
    IF con_type_csr%NOTFOUND THEN
      l_type := 'N';
    END IF;
    CLOSE con_type_csr;*/

    --
    -- Do not check for rebook copy contracts
    --
    -- Bug# 4350255: Checks are needed for rebook copy contracts
    -- as Passthrough parameters can be modified on Rebook
    --IF (l_type <> 'Y') THEN
       FOR pth_rec IN pth_csr (p_chr_id)
       LOOP

         -- Bug# 4350255: start
         -- Passthru Stream Type is mandatory for Base term
         IF (pth_rec.passthru_term = 'BASE') THEN
           IF (pth_rec.passthru_stream_type_id IS NULL) THEN
               Okl_Api.set_message(
                               G_APP_NAME,
                               'OKL_QA_PASTH_STRM',
                               'LINE_TYPE',
                               pth_rec.line_style,
                               'STRM_TYPE',
                               pth_rec.name
                               );
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;

           IF (pth_rec.passthru_start_date
              NOT BETWEEN pth_rec.start_date AND pth_rec.end_date) THEN
               Okl_Api.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_QA_PTH_STRT_DATE',
                                   p_token1       => 'LINE',
                                   p_token1_value => pth_rec.line_style||'/'||pth_rec.name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
         END IF;

         -- Passthru Stream Type should be valid for the contract's
         -- Stream Generation Template
         IF (pth_rec.passthru_stream_type_id IS NOT NULL) THEN
             --Bug# 3931587
             l_present_yn :=   Okl_Streams_Util.strm_tmpt_contains_strm_type
                                   (p_khr_id  => p_chr_id,
                                    p_sty_id  => pth_rec.passthru_stream_type_id);

             IF (l_present_yn = 'N') THEN

               OPEN  strm_name_csr ( TO_NUMBER(pth_rec.passthru_stream_type_id) );
               FETCH strm_name_csr INTO l_strm_name_rec;
               IF strm_name_csr%NOTFOUND THEN
                 CLOSE strm_name_csr;
                 RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
               END IF;
               CLOSE strm_name_csr;

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'LLA_QA_PTH_STRM_TMPL',
                  p_token1       => 'STRM_NAME',
                  p_token1_value => l_strm_name_rec.name,
                  p_token2       => 'LINE_TYPE',
                  p_token2_value => pth_rec.line_style||'/'||pth_rec.name
                 );
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
         END IF;

         l_pct_sum := 0;
         l_pth_dtl_present_yn := 'N';
         FOR pth_dtl_rec IN pth_dtl_csr(p_payment_hdr_id => pth_rec.payment_hdr_id)
         LOOP

           l_pth_dtl_present_yn := 'Y';

           IF (pth_dtl_rec.disbursement_basis = 'PERCENT') THEN
             l_pct_sum := l_pct_sum +  NVL(pth_dtl_rec.disbursement_percent,0);
           END IF;

           IF (pth_rec.passthru_term = 'BASE') THEN
             IF (pth_dtl_rec.payment_start_date IS NOT NULL AND
                 pth_dtl_rec.payment_start_date NOT BETWEEN pth_rec.start_date AND pth_rec.end_date) THEN

                OPEN vendor_csr(p_vendor_id => pth_dtl_rec.vendor_id);
                FETCH vendor_csr INTO l_vendor_name;
                CLOSE vendor_csr;

                Okl_Api.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_QA_PYMT_STRT_DATE',
                                    p_token1       => 'LINE',
                                    p_token1_value => pth_rec.line_style||'/'||pth_rec.name,
                                    p_token2       => 'VENDOR',
                                    p_token2_value => l_vendor_name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;
           END IF;

         END LOOP;

         IF (l_pth_dtl_present_yn = 'N') THEN

           IF (pth_rec.passthru_term = 'BASE') THEN
             Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_PTH_BASE_NO_DTL',
               p_token1       => 'LINE',
               p_token1_value => pth_rec.line_style||'/'||pth_rec.name
               );
             x_return_status := Okl_Api.G_RET_STS_ERROR;

           ELSIF (pth_rec.passthru_term = 'EVERGREEN') THEN
             Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_PTH_EVGN_NO_DTL',
               p_token1       => 'LINE',
               p_token1_value => pth_rec.line_style||'/'||pth_rec.name
               );
             x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;

         END IF;

         IF (l_pct_sum > 100) THEN

           IF (pth_rec.passthru_term = 'BASE') THEN
               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_BASE_PERCENT_SUM',
                  p_token1       => 'LINE',
                  p_token1_value => pth_rec.line_style||'/'||pth_rec.name
                 );
                x_return_status := Okl_Api.G_RET_STS_ERROR;

           ELSIF (pth_rec.passthru_term = 'EVERGREEN') THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_EVGN_PERCENT_SUM',
                  p_token1       => 'LINE',
                  p_token1_value => pth_rec.line_style||'/'||pth_rec.name
                 );
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;

         END IF;
         -- Bug# 4350255: end

       END LOOP;
    --END IF;

  EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_fee_service_ast_pth;


  -- Start of comments
  --
  -- Procedure Name  : check_advance_rentals
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_advanced_rentals(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);


    CURSOR l_contract_name ( n VARCHAR2 ) IS
    SELECT COUNT(*) cnt
    FROM okc_k_headers_v WHERE contract_number = n;
    l_cn l_contract_name%ROWTYPE;


    l_hdr     l_hdr_csr%ROWTYPE;
    l_txl     l_txl_csr%ROWTYPE;
    l_txd     l_txd_csr%ROWTYPE;
    l_itm     l_itms_csr%ROWTYPE;
    l_struct_rec l_struct_csr%ROWTYPE;
    l_structure  NUMBER;
    l_rl_rec1 l_rl_csr1%ROWTYPE;
    i NUMBER;


    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_supp_rec supp_csr%ROWTYPE;
    l_lne l_lne_csr%ROWTYPE;
    l_fee_strm_type_rec  fee_strm_type_csr%ROWTYPE;
    l_strm_name_rec strm_name_csr%ROWTYPE;

    l_inflow_defined_yn VARCHAR2(1);
    l_outflow_defined_yn VARCHAR2(1);

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR l_hdrrl_rec IN l_hdrrl_csr ( 'LALEVL', 'LASLH', p_chr_id )
    LOOP

        OPEN  strm_name_csr ( l_hdrrl_rec.object1_id1 );
        FETCH strm_name_csr INTO l_strm_name_rec;
        IF strm_name_csr%NOTFOUND THEN
            CLOSE strm_name_csr;
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        CLOSE strm_name_csr;

        --Bug#3931587
        --If ( l_strm_name_rec.name = 'ADVANCED RENTALS' ) Then
        IF ( l_strm_name_rec.stream_type_purpose = 'ADVANCE_RENT' ) THEN

                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NOSUP_ADVRENTS',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                RETURN;

        END IF;

    END LOOP;

  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_rl_csr1%ISOPEN THEN
      CLOSE l_rl_csr1;
    END IF;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_txl_csr%ISOPEN THEN
      CLOSE l_txl_csr;
    END IF;

  END check_advanced_rentals;

  -- Start of comments
  --
  -- Procedure Name  : check_est_prop_tax
  -- Description     : Check LASLH record for each asset line and raise error
  --                   based on existence of payment streams of purpose code
  --                   'ESTIMATED_PROPERTY_TAX'
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_est_prop_tax(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR l_lne_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
    SELECT kle.id,
           kle.name
    FROM OKC_K_LINES_V kle,
         OKC_LINE_STYLES_B ls,
         OKC_STATUSES_B sts
    WHERE kle.lse_id = ls.id
    AND ls.lty_code = ltycode
    AND kle.dnz_chr_id = chrid
    AND sts.code = kle.sts_code
    AND sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_assetrl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                       rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       chrId NUMBER,
                       cleId NUMBER) IS
    SELECT crl.RULE_INFORMATION1,
           crl.RULE_INFORMATION3
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl
    WHERE  crl.rgp_id = crg.id
    AND crg.RGD_CODE = rgcode
    AND crl.RULE_INFORMATION_CATEGORY = rlcat
    AND crg.dnz_chr_id = chrId
    AND crg.cle_id = cleId;

    CURSOR l_strm_asset_csr(rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                       rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       pmnt_strm_purpose OKL_STRM_TYPE_B.STREAM_TYPE_PURPOSE%TYPE,
                       chrId NUMBER,
                       cleId NUMBER) IS
    SELECT crl.id,
           crl.object1_id1
    FROM   OKC_RULE_GROUPS_B crg,
           OKC_RULES_B crl,
           OKL_STRM_TYPE_B stty
    WHERE  stty.id = TO_NUMBER(crl.object1_id1)
    AND stty.stream_type_purpose = pmnt_strm_purpose
    AND crl.rgp_id = crg.id
    AND crg.RGD_CODE = rgcode
    AND crl.RULE_INFORMATION_CATEGORY = rlcat
    AND crg.cle_id = cleId
    AND crg.dnz_chr_id = chrId;

    CURSOR est_head_csr (p_chr_id NUMBER) IS
    SELECT 'Y'
    FROM   okc_rule_groups_b rgp,
           okc_rules_b rule,
           okl_strm_type_b stty
    WHERE  rgp.id                         = rule.rgp_id
    AND    stty.id                        = TO_NUMBER(rule.object1_id1)
    AND    rgp.rgd_code                   = 'LALEVL'
    AND    rule.rule_information_category = 'LASLH'
    AND    rgp.cle_id                     IS NULL
    AND    stty.stream_type_purpose       = 'ESTIMATED_PROPERTY_TAX'
    AND    rgp.dnz_chr_id                 = p_chr_id;

    l_est_head VARCHAR2(1);

    l_assetrl_rec    l_assetrl_csr%ROWTYPE;
    l_strm_asset_rec l_strm_asset_csr%ROWTYPE;
    l_rule_not_found  BOOLEAN;
    l_fnd_rec fnd_csr%ROWTYPE;
    l_fnd_meaning FND_LOOKUPS.MEANING%TYPE;
    l_billtx_method FND_LOOKUPS.MEANING%TYPE;

  BEGIN

     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     OPEN fnd_csr('OKL_STREAM_TYPE_PURPOSE','ESTIMATED_PROPERTY_TAX');
     FETCH fnd_csr INTO l_fnd_rec;
     CLOSE fnd_csr;
     l_fnd_meaning := l_fnd_rec.meaning;

     -- Fix Bug 4088346
     l_est_head := '?';
     OPEN est_head_csr(p_chr_id);
     FETCH est_head_csr INTO l_est_head;
     CLOSE est_head_csr;

     IF (l_est_head = 'Y') THEN
        Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_EST_HEAD',
                  p_token1       => 'PURPOSE_DESC',
                  p_token1_value => l_fnd_meaning);
        x_return_status := Okl_Api.G_RET_STS_ERROR;
     END IF;
     -- Fix Bug 4088346

     FOR l_lne_rec IN l_lne_csr('FREE_FORM1', p_chr_id)
     LOOP

       l_assetrl_rec := NULL;
       OPEN l_assetrl_csr('LAASTX','LAPRTX', p_chr_id, l_lne_rec.id);
       FETCH l_assetrl_csr INTO l_assetrl_rec;
       l_rule_not_found := l_assetrl_csr%NOTFOUND;
       CLOSE l_assetrl_csr;

       IF (l_assetrl_rec.RULE_INFORMATION1 = 'Y'
           AND (l_assetrl_rec.RULE_INFORMATION3 = 'ESTIMATED'
                OR l_assetrl_rec.RULE_INFORMATION3 = 'ESTIMATED_AND_ACTUAL') ) THEN
         OPEN l_strm_asset_csr('LALEVL','LASLH','ESTIMATED_PROPERTY_TAX',p_chr_id, l_lne_rec.id);
         FETCH l_strm_asset_csr INTO l_strm_asset_rec;
         IF (l_strm_asset_csr%NOTFOUND) THEN
           Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_EST_PROPTAX1',
                  p_token1       => 'ASSET_NUM',
                  p_token1_value => l_lne_rec.name,
                  p_token2       => 'PURPOSE_DESC',
                  p_token2_value => l_fnd_meaning);
           x_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
         CLOSE l_strm_asset_csr;
       ELSIF (l_rule_not_found OR l_assetrl_rec.RULE_INFORMATION1 = 'N') THEN
         OPEN l_strm_asset_csr('LALEVL','LASLH','ESTIMATED_PROPERTY_TAX',p_chr_id, l_lne_rec.id);
         FETCH l_strm_asset_csr INTO l_strm_asset_rec;
         IF (l_strm_asset_csr%FOUND) THEN
           Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_EST_PROPTAX2',
                  p_token1       => 'ASSET_NUM',
                  p_token1_value => l_lne_rec.name,
                  p_token2       => 'PURPOSE_DESC',
                  p_token2_value => l_fnd_meaning);
           x_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
         CLOSE l_strm_asset_csr;
       ELSIF ( l_assetrl_rec.RULE_INFORMATION1 = 'Y'
              AND (l_assetrl_rec.RULE_INFORMATION3 IS NULL OR
               l_assetrl_rec.RULE_INFORMATION3 = 'ACTUAL' OR
               l_assetrl_rec.RULE_INFORMATION3 = 'NONE') ) THEN
         OPEN l_strm_asset_csr('LALEVL','LASLH','ESTIMATED_PROPERTY_TAX',p_chr_id, l_lne_rec.id);
         FETCH l_strm_asset_csr INTO l_strm_asset_rec;
         IF (l_strm_asset_csr%FOUND) THEN
           IF ( l_assetrl_rec.RULE_INFORMATION3 IS NOT NULL) THEN
             OPEN fnd_csr('OKL_PROP_TAX_BILL_METHOD',l_assetrl_rec.RULE_INFORMATION3);
             FETCH fnd_csr INTO l_fnd_rec;
             CLOSE fnd_csr;
             l_billtx_method := l_fnd_rec.meaning;
           ELSE
             l_billtx_method := ' ';
           END IF;
           Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_EST_PROPTAX3',
                  p_token1       => 'ASSET_NUM',
                  p_token1_value => l_lne_rec.name,
                  p_token2       => 'PURPOSE_DESC',
                  p_token2_value => l_fnd_meaning,
                  p_token3       => 'BILL_TAX',
                  p_token3_value => l_billtx_method);
           x_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
         CLOSE l_strm_asset_csr;
       END IF;

     END LOOP;

  EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_assetrl_csr%ISOPEN THEN
      CLOSE l_assetrl_csr;
    END IF;
    IF l_strm_asset_csr%ISOPEN THEN
      CLOSE l_strm_asset_csr;
    END IF;

  END check_est_prop_tax;

  -- Start of comments
  --
  -- Procedure Name  : check_stub_payment
  -- Description     : Check LASLL records and raise error if it only contains
  --                   Stub. There must be atleast one actual payment defined.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_stub_payment(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

--Bug#3931587
  CURSOR stream_csr (p_slh_id VARCHAR2) IS
  SELECT strm.stream_type_purpose
  --SELECT strm.name
  FROM   okl_strm_type_v strm,
         okc_rules_b rule
  WHERE  rule.id                        = p_slh_id
  AND    rule.rule_information_category = 'LASLH'
  AND    rule.object1_id1               = strm.id;

  CURSOR hdr_stub_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT
         'Y' only_stub,
         rule.object2_id1
  FROM   okc_rules_b rule,
         okc_rule_groups_b rgp
  WHERE  rgp.id                 = rule.rgp_id
  AND    rgp.rgd_code           = 'LALEVL'
  AND    rgp.chr_id             = p_chr_id
  AND    rgp.dnz_chr_id         = rgp.chr_id
  AND    rgp.cle_id             IS NULL
  AND    rule.rule_information7 IS NOT NULL
  AND    NOT EXISTS (
                     SELECT 'Y'
                     FROM   okc_rules_b rule2
                     WHERE  rule2.rule_information3 IS NOT NULL
                     AND    rule2.rgp_id      = rgp.id
                     AND    rule2.object2_id1 = rule.object2_id1
                    );

  --Bug#3877032
  CURSOR line_stub_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT style.lty_code,
         style.name,
         rule.object2_id1,
         'Y' stub_only
  FROM   okc_rules_b rule,
         okc_rule_groups_b rgp,
         okc_k_lines_b line,
         okc_line_styles_v style,
         okc_statuses_b sts
  WHERE  rgp.id                 = rule.rgp_id
  AND    rgp.rgd_code           = 'LALEVL'
  AND    rgp.dnz_chr_id         = p_chr_id
  AND    rgp.cle_id             = line.id
  AND    line.lse_id            = style.id
  AND    line.sts_code          = sts.code
  AND    sts.ste_code           NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    rule.rule_information7 IS NOT NULL
  AND    NOT EXISTS (
                     SELECT 'Y'
                     FROM   okc_rules_b rule2
                     WHERE  rule2.rule_information3 IS NOT NULL
                     AND    rule2.rgp_id      = rgp.id
                     AND    rule2.object2_id1 = rule.object2_id1
                    );

  l_strm_type okl_strm_type_v.name%TYPE;

  BEGIN

     x_return_status := Okl_Api.G_RET_STS_SUCCESS;
     FOR hdr_stub_rec IN hdr_stub_csr (p_chr_id)
     LOOP
        IF (hdr_stub_rec.only_stub = 'Y') THEN

          OPEN stream_csr (hdr_stub_rec.object2_id1);
          FETCH stream_csr INTO l_strm_type;
          CLOSE stream_csr;

          --Bug#3931587
          --Bug#3925464
          --IF (l_strm_type <> 'UNSCHEDULED_PRINCIPAL_PAYMENT') Then
          -- Bug 4887014
          IF (l_strm_type NOT IN ( 'UNSCHEDULED_PRINCIPAL_PAYMENT',
                                   'UNSCHEDULED_LOAN_PAYMENT'     ) ) THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_HDR_STUB_ONLY',
                  p_token1       => 'STREAM_TYPE',
                  p_token1_value => l_strm_type);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;
        END IF;

     END LOOP;

     -- Now check line
     FOR line_stub_rec IN line_stub_csr(p_chr_id)
     LOOP
        IF (line_stub_rec.stub_only = 'Y') THEN
          OPEN stream_csr (line_stub_rec.object2_id1);
          FETCH stream_csr INTO l_strm_type;
          CLOSE stream_csr;

          --Bug#3931587
          --Bug#3925464
          --IF (l_strm_type <> 'UNSCHEDULED_PRINCIPAL_PAYMENT') Then
          -- Bug 4887014
          IF (l_strm_type NOT IN ( 'UNSCHEDULED_PRINCIPAL_PAYMENT',
                                   'UNSCHEDULED_LOAN_PAYMENT'     ) ) THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_LINE_STUB_ONLY',
                  p_token1       => 'LINE_TYPE',
                  p_token1_value => line_stub_rec.name,
                  p_token2       => 'STREAM_TYPE',
                  p_token2_value => l_strm_type);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

        END IF;

     END LOOP;

  EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_stub_payment;

  -- Start of comments
  --
  -- Procedure Name  : check_serial_asset
  -- Description     : Check for serialized item attached to asset
  --                   Item qty must match the total serial numbers
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_serial_asset(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  --Bug#3877032
  CURSOR serial_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT top.name,
         top.id top_id,
         item.id item_id,
         kitem.object1_id1,
         kitem.number_of_items,
         mtl.description,
         mtl.serial_number_control_code
  FROM   okc_k_lines_v top,
         okc_k_lines_b item,
         okc_line_styles_b item_style,
         okc_line_styles_b top_style,
         okc_k_items kitem,
         mtl_system_items mtl
  WHERE  top.dnz_chr_id               = p_chr_id
  AND    top.lse_id                   = top_style.id
  AND    top_style.lty_code           = 'FREE_FORM1'
  AND    top.id                       = item.cle_id
  AND    item.id                      = kitem.cle_id
  AND    item.dnz_chr_id              = top.dnz_chr_id
  AND    item.dnz_chr_id              = kitem.dnz_chr_id
  AND    kitem.jtot_object1_code      = 'OKX_SYSITEM'
  AND    mtl.inventory_item_id        = kitem.object1_id1
  AND    TO_CHAR(mtl.organization_id) = kitem.object1_id2
  AND    item.lse_id                  = item_style.id
  AND    item_style.lty_code          = 'ITEM';

  --Bug#3877032
  CURSOR ib_csr (p_top_cle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT COUNT(inst.serial_number) no_srl
  FROM   okc_k_lines_b ib,
         okc_k_lines_b f2,
         okc_line_styles_b style,
         okl_txl_itm_insts inst
  WHERE  f2.cle_id      = p_top_cle_id
  AND    f2.lse_id      = style.id
  AND    f2.dnz_chr_id  = p_chr_id
  AND    ib.dnz_chr_id  = p_chr_id
  AND    style.lty_code = 'FREE_FORM2'
  AND    f2.id          = ib.cle_id
  AND    ib.id          = inst.kle_id;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR serial_rec IN serial_csr (p_chr_id)
    LOOP
       IF (serial_rec.serial_number_control_code <> 1) THEN -- serialized item
          FOR ib_rec IN ib_csr (serial_rec.top_id)
          LOOP
             IF (ib_rec.no_srl <> serial_rec.number_of_items) THEN
                 Okl_Api.set_message(
                   G_APP_NAME,
                   'OKL_QA_SRL_ITEM_ERROR',
                   'ASSET_NUM',
                   serial_rec.name,
                   'ITEM_NUM',
                   serial_rec.description,
                   'NO_ITEM',
                   serial_rec.number_of_items
                  );
                x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;
          END LOOP;
       END IF;
    END LOOP;

  EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_serial_asset;


  -- Start of comments
  --                  Added by Durga Janaswamy, bug 6760186
  -- Procedure Name  : check_ib_location
  -- Description     : Match whether the install location in OLM  is same as
  --                   that of Install Base Instance for a given serial number of
  --                   an asset and inventory item id.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
-- start


PROCEDURE check_ib_location (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

CURSOR ib_line_csr(p_chr_id NUMBER) IS
   SELECT cle.id,
          cle.cle_id
   FROM   okc_k_lines_b cle,
          okc_statuses_b sts
   WHERE  cle.lse_id = G_IB_LINE_LTY_ID
   AND    cle.dnz_chr_id = p_chr_id
   AND    cle.sts_code = sts.code
   AND    sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED');


CURSOR okl_cimv_csr (p_cle_id NUMBER) IS
       SELECT
            cim.id,
            cim.object1_id1,
            cim.object1_id2,
            cim.jtot_object1_code,
            cim.number_of_items
      FROM  okc_k_items_v cim
      WHERE cle_id = p_cle_id;


CURSOR okl_iipv_csr (p_kle_id NUMBER) IS
    SELECT id,
           kle_id,
           tal_type,
           instance_number_ib,
           object_id1_new,  -- party_site_use_id
           object_id2_new,
           jtot_object_code_new,
           inventory_org_id,
           serial_number,
           mfg_serial_number_yn,
           inventory_item_id,
           inv_master_org_id
    FROM okl_txl_itm_insts iti
    WHERE iti.kle_id  = p_kle_id
    AND   iti.tal_type = G_TRX_LINE_TYPE_BOOK
    AND   EXISTS (SELECT '1' FROM  okl_trx_assets
                   WHERE  okl_trx_assets.tas_type = G_TRX_LINE_TYPE_BOOK
                   AND    okl_trx_assets.tsu_code = G_TSU_CODE_ENTERED
                   AND    okl_trx_assets.id       = iti.tas_id);


CURSOR serialized_csr (p_inv_item_id NUMBER, p_inventory_org_id NUMBER) IS
SELECT 'X'
FROM   mtl_system_items     mtl
WHERE  mtl.inventory_item_id = p_inv_item_id
AND    mtl.organization_id   = p_inventory_org_id
AND    mtl.serial_number_control_code in (2,5,6);


CURSOR okl_csi_ib_csr (p_serial_number VARCHAR2, p_inventory_item_id NUMBER,
                       p_inv_master_organization_id NUMBER, p_contract_start_date DATE) IS
  SELECT instance_id,
         install_location_id,
         install_location_type_code
   FROM csi_item_instances inst,
        csi_instance_statuses stat
   WHERE inst.serial_number like p_serial_number  -- nullable col
   AND inst.inventory_item_id = p_inventory_item_id
   AND inst.inv_master_organization_id = p_inv_master_organization_id
   AND NVL (inst.active_end_date, (p_contract_start_date + 1)) >   p_contract_start_date
   AND stat.instance_status_id = inst.instance_status_id
   AND NVL(stat.terminated_flag, 'N')  <> 'Y';


-- bug 6795295 changed name of cursor
--CURSOR intall_location_csr (p_party_site_use_id  NUMBER) IS
CURSOR party_site_id_csr (p_party_site_use_id  NUMBER) IS
SELECT party_site_id
FROM   hz_party_site_uses
WHERE party_site_use_id = p_party_site_use_id;

-- bug 6795295 changed name of cursor
-- CURSOR location_csr (p_party_site_id NUMBER) IS
CURSOR location_id_csr (p_party_site_id NUMBER) IS
   SELECT location_id
   FROM hz_party_sites
   WHERE PARTY_SITE_ID = p_party_site_id;


CURSOR asset_num_csr(p_cle_id NUMBER) IS
   SELECT name
   FROM   okc_k_lines_b cle1,
          okc_k_lines_tl cle_tl,
          okc_k_lines_b cle2
   WHERE  cle_tl.id = cle2.id
   AND    cle1.id =  p_cle_id
   AND    cle2.id = cle1.cle_id
   AND    cle_tl.language = USERENV('LANG');


CURSOR location_name_csr (p_location_id NUMBER) IS
SELECT
substr(arp_addr_label_pkg.format_address(null,l.address1,l.address2,l.address3,l.address4,l.city,l.county,
l.state,l.province,l.postal_code,null,l.country,null,null,null,null,null,null,null,'n','n',80,1,1),1,80)
FROM hz_locations l
WHERE l.location_id = p_location_id;

CURSOR location_for_party_csr (p_party_site_id NUMBER) IS
SELECT
substr(arp_addr_label_pkg.format_address(null,l.address1,l.address2,l.address3,l.address4,l.city,l.county,
l.state,l.province,l.postal_code,null,l.country,null,null,null,null,null,null,null,'n','n',80,1,1),1,80)
FROM hz_locations l,
     hz_party_sites site
WHERE site.party_site_id = p_party_site_id
AND l.location_id = site.location_id;

CURSOR header_details_csr (p_chr_id NUMBER) IS
SELECT h.start_date, mtl.master_organization_id
FROM okc_k_headers_b h,
     mtl_parameters mtl
WHERE h.id = p_chr_id
AND   mtl.organization_id = h.inv_organization_id;


l_instance_id                   csi_item_instances.instance_id%TYPE;
l_install_location_id           csi_item_instances.install_location_id%TYPE;
l_install_location_type_code    csi_item_instances.install_location_type_code%TYPE;
l_location_id                   hz_party_sites.location_id%TYPE;
l_serial_number_control_code    VARCHAR2(3);
l_trx_line_type_book            VARCHAR2(10);
l_party_site_id                 hz_party_site_uses.party_site_id%TYPE;
l_asset_num                     okc_k_lines_tl.name%TYPE;
l_okl_location_name             VARCHAR2(160);
l_ib_location_name              VARCHAR2(160);
l_contract_start_date           okc_k_headers_b.start_date%TYPE;
l_inv_organization_id           okc_k_headers_b.inv_organization_id%TYPE;


BEGIN

     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

   l_contract_start_date:= NULL;
   l_inv_organization_id := NULL;

   OPEN header_details_csr (p_chr_id);
   FETCH header_details_csr INTO l_contract_start_date, l_inv_organization_id;
   CLOSE header_details_csr;


    FOR ib_line_rec IN ib_line_csr (p_chr_id)
         LOOP

            FOR okl_cimv_rec IN okl_cimv_csr (ib_line_rec.id)
                LOOP

                IF (okl_cimv_rec.jtot_object1_code IS NOT NULL) AND
                      (okl_cimv_rec.object1_id1) IS NOT NULL THEN
                      --ib instance is already plugged in (do nothing)
                   NULL;

                   ELSIF (okl_cimv_csr%NOTFOUND) OR
                         (okl_cimv_rec.jtot_object1_code IS NULL OR
                         okl_cimv_rec.object1_id1 IS NULL) THEN
                    -- Call get_iipv_rec

                       FOR okl_iipv_rec IN okl_iipv_csr (ib_line_rec.id)
                           LOOP
                               l_serial_number_control_code := NULL;

                               OPEN serialized_csr (okl_iipv_rec.inventory_item_id, okl_iipv_rec.inventory_org_id);
                               FETCH serialized_csr INTO l_serial_number_control_code;
                               CLOSE serialized_csr;

                               IF l_serial_number_control_code <> 'X' THEN
                                   NULL;  -- not serialized

                               ELSIF  ( okl_iipv_rec.serial_number IS NULL) THEN
                                      NULL;  -- no serial_number is entered

                               ELSIF  (okl_iipv_rec.object_id1_new IS NULL) THEN
                                      NULL;  -- no install location is entered

                               ELSE
                                     l_instance_id := NULL;
                                     l_install_location_id := NULL;
                                     l_install_location_type_code := NULL;

                                    OPEN okl_csi_ib_csr (okl_iipv_rec.serial_number,
                                                          okl_iipv_rec.inventory_item_id,
                                                          l_inv_organization_id,
                                                          l_contract_start_date );
                                    FETCH okl_csi_ib_csr INTO l_instance_id,
                                       l_install_location_id, l_install_location_type_code;
                                    CLOSE okl_csi_ib_csr;

                                   IF (l_instance_id IS NULL) THEN
                                          NULL;   -- no ib instance

                                   ELSIF l_install_location_type_code = 'HZ_PARTY_SITES' THEN
                                            l_party_site_id := NULL;
                                            OPEN party_site_id_csr (okl_iipv_rec.object_id1_new);
                                            FETCH party_site_id_csr INTO l_party_site_id;
                                            CLOSE party_site_id_csr;

                                            IF l_install_location_id <>  l_party_site_id THEN
                                                   l_asset_num := NULL;
                                                   OPEN asset_num_csr (ib_line_rec.cle_id);
                                                   FETCH asset_num_csr into l_asset_num;
                                                   CLOSE asset_num_csr;

                                                   l_okl_location_name := NULL;
                                                   l_ib_location_name := NULL;
                                                   OPEN location_for_party_csr (l_party_site_id);
                                                   FETCH location_for_party_csr INTO l_okl_location_name;
                                                   CLOSE location_for_party_csr;

                                                   OPEN location_for_party_csr (l_install_location_id);
                                                   FETCH location_for_party_csr INTO l_ib_location_name;
                                                   CLOSE location_for_party_csr;

                           Okl_Api.set_message(
                                                         p_app_name => G_APP_NAME,
                                                         p_msg_name => 'OKL_QA_IB_LOCATION_ERROR',
                                                         p_token1   =>  'ASSET_NUM',
                                                         p_token1_value => l_asset_num,
                                                         p_token2   =>  'SERIAL_NUM',
                                                         p_token2_value => okl_iipv_rec.serial_number,
                                                         p_token3   =>  'OKL_INSTALL_SITE',
                                                         p_token3_value => l_okl_location_name,
                                                         p_token4   =>  'IB_INSTALL_SITE',
                                                         p_token4_value => l_ib_location_name
                                                             );
                                                x_return_status := Okl_Api.G_RET_STS_ERROR;
                                             END IF;

                                     ELSIF l_install_location_type_code = 'HZ_LOCATIONS' THEN
                                            l_party_site_id := NULL;
                                            l_location_id := NULL;
                                            OPEN party_site_id_csr (okl_iipv_rec.object_id1_new);
                                            FETCH party_site_id_csr INTO l_party_site_id;
                                            CLOSE party_site_id_csr;

                                                OPEN location_id_csr (l_party_site_id);
                                                FETCH   location_id_csr INTO l_location_id;
                                                CLOSE location_id_csr;

                                              IF l_install_location_id <> l_location_id THEN
                                                   l_asset_num := NULL;
                                                   OPEN asset_num_csr (ib_line_rec.cle_id);
                                                   FETCH asset_num_csr into l_asset_num;
                                                   CLOSE asset_num_csr;

                                                   l_okl_location_name := NULL;
                                                   l_ib_location_name := NULL;
                                                   OPEN location_name_csr (l_location_id);
                                                   FETCH location_name_csr INTO l_okl_location_name;
                                                   CLOSE location_name_csr;

                                                   OPEN location_name_csr (l_install_location_id);
                                                   FETCH location_name_csr INTO l_ib_location_name;
                                                   CLOSE location_name_csr;

                                                        Okl_Api.set_message(
                                                         p_app_name => G_APP_NAME,
                                                         p_msg_name => 'OKL_QA_IB_LOCATION_ERROR',
                                                         p_token1   =>  'ASSET_NUM',
                                                         p_token1_value => l_asset_num,
                                                         p_token2   =>  'SERIAL_NUM',
                                                         p_token2_value => okl_iipv_rec.serial_number,
                                                         p_token3   =>  'OKL_INSTALL_SITE',
                                                         p_token3_value => l_okl_location_name,
                                                         p_token4   =>  'IB_INSTALL_SITE',
                                                         p_token4_value => l_ib_location_name
                                                             );
                                                      x_return_status := Okl_Api.G_RET_STS_ERROR;
                                                 END IF;
                                        END IF;
                        END IF;

                     END LOOP;
               END IF;
             END LOOP;
END LOOP;


 EXCEPTION
    WHEN OTHERS THEN

    IF ib_line_csr%ISOPEN THEN
    CLOSE ib_line_csr;
    END IF;

    IF okl_cimv_csr%ISOPEN THEN
    CLOSE okl_cimv_csr;
    END IF;


    IF okl_iipv_csr%ISOPEN THEN
    CLOSE okl_iipv_csr;
    END IF;


    IF serialized_csr%ISOPEN THEN
    CLOSE serialized_csr;
    END IF;


    IF okl_csi_ib_csr%ISOPEN THEN
    CLOSE okl_csi_ib_csr;
    END IF;


    IF party_site_id_csr%ISOPEN THEN
    CLOSE party_site_id_csr;
    END IF;


    IF location_id_csr%ISOPEN THEN
    CLOSE location_id_csr;
    END IF;

    IF asset_num_csr%ISOPEN THEN
    CLOSE asset_num_csr;
    END IF;

    IF location_name_csr%ISOPEN THEN
    CLOSE location_name_csr;
    END IF;

    IF location_for_party_csr%ISOPEN THEN
    CLOSE location_for_party_csr;
    END IF;

    IF header_details_csr%ISOPEN THEN
    CLOSE header_details_csr;
    END IF;

    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

END check_ib_location;
-- end

  -- Start of comments
  --
  -- Procedure Name  : check_lessee_as_vendor
  -- Description     : Check the presence of lessee vendor mapping for
  --                   LOAN-REVOLVING contracts only
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_lessee_as_vendor(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  --Bug#3877032
  CURSOR con_type_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT NVL(okc.orig_system_source_code,'X') orig_system_source_code,
         NVL(okl.deal_type,'X') deal_type
  --FROM   okl_k_headers_full_v
  FROM   okc_k_headers_b okc,
         okl_k_headers okl
  WHERE  okc.id = p_chr_id
  AND    okc.id = okl.id;

  CURSOR check_vendor_csr (p_chr_id IN NUMBER) IS
  SELECT 'Y'
  FROM   okl_lessee_as_vendors_uv
  WHERE  dnz_chr_id = p_chr_id;

  l_type            OKL_K_HEADERS_FULL_V.DEAL_TYPE%TYPE;
  l_source          OKL_K_HEADERS_FULL_V.ORIG_SYSTEM_SOURCE_CODE%TYPE;
  l_loan_yn         VARCHAR2(1) := 'N';
  l_vendor_present  VARCHAR2(1) := 'N';

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_type   := 'X';
    l_source := 'X';
    OPEN con_type_csr (p_chr_id);
    FETCH con_type_csr INTO l_source,
                            l_type;
    CLOSE con_type_csr;

    IF (l_type   = 'LOAN-REVOLVING'
        AND
        l_source <> 'OKL_REBOOK') THEN

       l_vendor_present := 'N';
       OPEN check_vendor_csr (p_chr_id);
       FETCH check_vendor_csr INTO l_vendor_present;
       CLOSE check_vendor_csr;

       IF (l_vendor_present = 'N') THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_LESSEE_VENDOR'
                 );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;

       IF (NVL(Okl_Funding_Pvt.get_total_funded(p_chr_id), 0) <> 0) THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_LA_OVERFUND_CHK_4RL'
                 );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;

    END IF; -- loan_yn

  EXCEPTION

  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_lessee_as_vendor;
  -- Start of comments
  --
  -- Procedure Name  : check_payment_period
  -- Description     : Check payment periods for Financial Asset and Fee lines
  --                   Consider lines which is not In-activated, terminated etc.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_payment_period(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    /*
    *CURSOR strm_profile_csr IS
    *SELECT fnd_profile.VALUE('OKL_STREAMS_GEN_PATH')
    *FROM   dual;
    */

    l_strm_profile VARCHAR2(50);
    lx_return_status VARCHAR2(1);

    CURSOR c_fin_fee (p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
      SELECT cle.id,
             DECODE (lse.lty_code, 'FREE_FORM1', 'ASSET', 'FEE', 'FEE',
                                   'SOLD_SERVICE','SERVICE') line_type
      FROM   okc_k_lines_b cle,
             okc_line_styles_b lse,
             okc_statuses_b sts
      WHERE  cle.chr_id   = p_khr_id
        AND  cle.lse_id   = lse.id
        AND  cle.sts_code = sts.code
        AND  sts.ste_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED')
        AND  lse.lty_code IN ('FREE_FORM1', 'FEE', 'SOLD_SERVICE');

    CURSOR c_strm_sll (p_khr_id OKC_K_HEADERS_B.ID%TYPE,
                       p_kle_id OKC_K_LINES_B.ID%TYPE) IS
      SELECT sll.rule_information2 start_date,
             SLL.rule_information3 periods,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             ( select STYT.NAME from  OKL_STRM_TYPE_B STY ,OKL_STRM_TYPE_TL STYT where STY.ID = STYT.ID AND STYT.LANGUAGE = USERENV ( 'LANG' )
               AND to_number(SLH.OBJECT1_ID1) =  STY.ID ) STREAM_TYPE
             --styt.name stream_type
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp
             --okl_strm_type_b sty,
             --okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id                = p_khr_id
        AND  rgp.cle_id                    = p_kle_id
        AND  rgp.rgd_code                  = 'LALEVL'
        AND  rgp.id                        = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  rgp.id                        = sll.rgp_id
        --AND  slh.object1_id1               = TO_CHAR(sty.id)  4929573
        --AND  styt.LANGUAGE                 = USERENV('LANG')
        --AND  sty.id                        = styt.id
        AND  TO_CHAR(slh.id)               = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL';
      --ORDER BY fnd_date.canonical_to_date(sll.rule_information2);

/*
    CURSOR c_strm_sll_ext (p_khr_id OKC_K_HEADERS_B.ID%TYPE,
                           p_kle_id OKC_K_LINES_B.ID%TYPE) IS
      SELECT
             SUM(NVL(TO_NUMBER(SLL.rule_information3),0)) periods,
             DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
             styt.name stream_type
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id                = p_khr_id
        AND  rgp.cle_id                    = p_kle_id
        AND  rgp.rgd_code                  = 'LALEVL'
        AND  rgp.id                        = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH'
        AND  slh.object1_id1               = TO_CHAR(sty.id)
        AND  styt.language                 = USERENV('LANG')
        AND  sty.id                        = styt.id
        AND  TO_CHAR(slh.id)               = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'
      GROUP BY DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12),
               styt.name;
*/

    --Bug#3877032
    CURSOR c_strm_slh_ext (p_khr_id OKC_K_HEADERS_B.ID%TYPE,
                           p_kle_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT (select STYT.NAME from OKL_STRM_TYPE_B STY ,OKL_STRM_TYPE_TL STYT
            where STY.ID = STYT.ID AND STYT.LANGUAGE = USERENV ( 'LANG' )
            AND to_number(RULE.OBJECT1_ID1) =  STY.ID ) STREAM_TYPE,
           rule.id rule_id,
           rgp.id rgp_id
    FROM   okc_rules_b rule,
           okc_rule_groups_b rgp
           --okl_strm_type_b sty, Bug 4929573
           --okl_strm_type_tl styt
    WHERE  rgp.cle_id                     = p_kle_id
    AND    rgp.dnz_chr_id                 = p_khr_id
    AND    rgp.rgd_code                   = 'LALEVL'
    AND    rgp.id                         = rule.rgp_id
    AND    rule.rule_information_category = 'LASLH'  ;
    --AND    rule.object1_id1               = TO_CHAR(sty.id)
    --AND    styt.LANGUAGE                  = USERENV('LANG')
    --AND    sty.id                         = styt.id;

    CURSOR c_strm_sll_ext (p_rule_id OKC_RULES_B.ID%TYPE,
                           p_rgp_id  OKC_RULE_GROUPS_B.ID%TYPE) IS
    SELECT sll.rule_information2 start_date,
           sll.rule_information3 periods,
           sll.rule_information7 stub_day,
           DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp
    FROM   okc_rules_b sll
    WHERE  sll.rgp_id                    = p_rgp_id
    AND    sll.object2_id1               = TO_CHAR(p_rule_id)
    AND    sll.rule_information_category = 'LASLL'
     -- cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
    ORDER BY sll.rule_information2    ;


      CURSOR contract_csr (p_khr_id OKC_K_HEADERS_B.ID%TYPE) IS
      SELECT start_date,
             end_date
      FROM   OKC_K_HEADERS_B
      WHERE  ID = p_khr_id;

      l_start_date OKC_K_HEADERS_B.START_DATE%TYPE;
      l_end_date   OKC_K_HEADERS_B.END_DATE%TYPE;

      l_strm_sll_start_date DATE;
      l_strm_sll_periods    NUMBER;

      l_strm_sll_ext_periods     NUMBER;
      l_strm_sll_ext_stub_day    NUMBER;
      l_strm_sll_ext_mpp         NUMBER;
      l_strm_sll_ext_stream_type VARCHAR2(100);
      l_pmnt_end_date            DATE;

    -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
    CURSOR c_strm_sll_count (p_khr_id OKC_K_HEADERS_B.ID%TYPE,
                       p_kle_id OKC_K_LINES_B.ID%TYPE) IS
      SELECT COUNT(sll.id)
      FROM   okc_rules_b sll,
             okc_rules_b slh,
             okc_rule_groups_b rgp,
             okl_strm_type_b sty,
             okl_strm_type_tl styt
      WHERE  rgp.dnz_chr_id                = p_khr_id
        AND  rgp.cle_id                    = p_kle_id
        AND  rgp.rgd_code                  = 'LALEVL'
        AND  rgp.id                        = slh.rgp_id
        AND  slh.rule_information_category = 'LASLH' --| 17-Jan-06 cklee Fixed bug#4956483                                          |
        AND  slh.object1_id1               = TO_CHAR(sty.id)
        AND  styt.LANGUAGE                 = USERENV('LANG')
        AND  sty.id                        = styt.id
        AND  TO_CHAR(slh.id)               = sll.object2_id1
        AND  sll.rule_information_category = 'LASLL'; --| 17-Jan-06 cklee Fixed bug#4956483                                          |

    CURSOR c_strm_sll_ext_count (p_rule_id OKC_RULES_B.ID%TYPE,
                           p_rgp_id  OKC_RULE_GROUPS_B.ID%TYPE) IS
    SELECT COUNT(sll.id)
    FROM   okc_rules_b sll
    WHERE  sll.rgp_id                    = p_rgp_id
    AND    sll.object2_id1               = TO_CHAR(p_rule_id)
    AND    sll.rule_information_category = 'LASLL'; --| 17-Jan-06 cklee Fixed bug#4956483                                          |

      l_start_day NUMBER;
      l_sll_count NUMBER := 0;
    -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
    payment_end_date_invalid EXCEPTION; -- 5189866


  BEGIN

     x_return_status := Okl_Api.G_RET_STS_SUCCESS;

     --l_strm_profile := 'NONE';
     Okl_Streams_Util.get_pricing_engine(p_khr_id => p_chr_id,
                                         x_pricing_engine => l_strm_profile,
                                         x_return_status => lx_return_status);
     IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
     END IF;

     /*
     *OPEN strm_profile_csr;
     *FETCH strm_profile_csr INTO l_strm_profile;
     *CLOSE strm_profile_csr;
     */

     OPEN contract_csr (p_chr_id);
     FETCH contract_csr INTO l_start_date,
                             l_end_date;
     CLOSE contract_csr;

     --IF (l_strm_profile IN ('INTERNAL', 'NONE')) THEN
     IF (l_strm_profile = 'INTERNAL') THEN

        FOR l_fin_fee IN c_fin_fee(p_chr_id)
        LOOP

        -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938
        l_start_day := NULL;  --vthiruva Bug#4392051.16-jun..resetting for each asset
        -- mvasudev,06-02-2005,Bug#4392051
        OPEN c_strm_sll_count(p_chr_id,l_fin_fee.id);
        FETCH c_strm_sll_count INTO l_sll_count;
        CLOSE c_strm_sll_count;


        IF l_sll_count > 1 THEN
            l_start_day := TO_CHAR(l_start_date,'DD');
        END IF;
        -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl.h 4437938


          FOR l_strm_sll IN c_strm_sll(p_chr_id,
                                       l_fin_fee.id)
          LOOP

             l_strm_sll_start_date := Fnd_Date.canonical_to_date(l_strm_sll.start_date);
             l_strm_sll_periods    := TO_NUMBER(l_strm_sll.periods);

             IF(l_strm_sll_start_date IS NULL) THEN

                Okl_Api.set_message(
                      G_APP_NAME,
                      'OKL_NO_SLL_SDATE'
                     );
                x_return_status := Okl_Api.G_RET_STS_ERROR;

             ELSE
                -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl. 4437938
                --IF (TRUNC(ADD_MONTHS(l_strm_sll_start_date, l_strm_sll_periods*l_strm_sll.mpp) - 1))
                     IF (TRUNC(Okl_Lla_Util_Pvt.calculate_end_date(l_strm_sll_start_date,                 l_strm_sll_periods*l_strm_sll.mpp,l_start_day, l_end_date ))) --Bug#5441811
                --IF (TRUNC(Okl_Lla_Util_Pvt.calculate_end_date(l_strm_sll_start_date, l_strm_sll_periods*l_strm_sll.mpp,l_start_day)))
                -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl. 4437938
                                                                               > (TRUNC(l_end_date)) THEN
                    Okl_Api.set_message(
                      G_APP_NAME,
                      'OKL_QA_INVALID_STRM_END_DATE',
                      'STRM_TYPE',
                      l_strm_sll.stream_type,
                      'LINE_TYPE',
                      l_fin_fee.line_type
                     );
                   x_return_status := Okl_Api.G_RET_STS_ERROR;
                   exit;
                   --raise payment_end_date_invalid; --5189866

                END IF;
/* already there, check_pmnt_start_dt()

                IF (l_strm_sll_start_date < l_start_date) THEN
                   OKL_API.set_message(
                        G_APP_NAME,
                        'OKL_QA_INVALID_STRM_START_DATE',
                        'STRM_TYPE',
                        l_strm_sll.stream_type,
                        'LINE_TYPE',
                        l_fin_fee.line_type
                     );
                   x_return_status := OKL_API.G_RET_STS_ERROR;
                END IF;

*/
            END IF;

          END LOOP;

        END LOOP;

     --ELSE -- EXTERNAL stream generation
     ELSIF (l_strm_profile = 'EXTERNAL') THEN

        FOR l_fin_fee IN c_fin_fee(p_chr_id)
        LOOP

          FOR l_strm_slh_ext IN c_strm_slh_ext (p_chr_id,
                                                l_fin_fee.id)
          LOOP
             l_strm_sll_ext_periods := 0;
             l_strm_sll_ext_stub_day := 0;

              -- START: cklee/mvasudev,06-02-2005,Bug#4392051/okl. 4437938
              l_pmnt_end_date := l_start_date;

                     OPEN c_strm_sll_ext_count(l_strm_slh_ext.rule_id,
                                                          l_strm_slh_ext.rgp_id);
                     FETCH c_strm_sll_ext_count INTO l_sll_count;
                     CLOSE c_strm_sll_ext_count;


                IF l_sll_count > 1 THEN
                    l_start_day := TO_CHAR(l_start_date,'DD');
                END IF;
                -- END: cklee/mvasudev,06-02-2005,Bug#4392051/okl. 4437938


             FOR l_strm_sll_ext IN c_strm_sll_ext(l_strm_slh_ext.rule_id,
                                                  l_strm_slh_ext.rgp_id)
             LOOP
               -- START: cklee/mvasudev, 05/11/2006, Bug#4364266/okl.h 4437938
        /*
                 l_strm_sll_ext_periods     := TO_NUMBER(NVL(l_strm_sll_ext.periods, 0)) + l_strm_sll_ext_periods;
                 l_strm_sll_ext_mpp         := l_strm_sll_ext.mpp;
                 l_strm_sll_ext_stub_day    := TO_NUMBER(NVL(l_strm_sll_ext.stub_day,0)) + l_strm_sll_ext_stub_day;
                 */
                 -- 5189866
                 l_pmnt_end_date := Fnd_Date.canonical_to_date(l_strm_sll_ext.start_date);
         IF l_sll_count > 1 THEN
           l_start_day := TO_CHAR(l_pmnt_end_date,'DD');
             END IF;

        IF l_strm_sll_ext.stub_day IS NOT NULL THEN
                   l_pmnt_end_date := l_pmnt_end_date + TO_NUMBER(NVL(l_strm_sll_ext.stub_day,0));

            --vthiruva Bug#4392051..16-jun start..commented
            /*IF l_sll_count > 1 THEN
                       l_start_day := TO_CHAR(l_pmnt_end_date,'DD');
            END IF;*/
            --vthiruva 16-jun end..commented

        ELSIF l_strm_sll_ext.periods IS NOT NULL THEN
             --vthiruva Bug#4392051..16-jun start..including l_start_day if l_sll_count > 1
             IF l_sll_count > 1 THEN
                   l_pmnt_end_date := Okl_Lla_Util_Pvt.calculate_end_date(l_pmnt_end_date, TO_NUMBER(NVL(l_strm_sll_ext.periods,0)) * l_strm_sll_ext.mpp,l_start_day, l_end_date) + 1; --Bug#5441811
                   --l_pmnt_end_date := Okl_Lla_Util_Pvt.calculate_end_date(l_pmnt_end_date, TO_NUMBER(NVL(l_strm_sll_ext.periods,0)) * l_strm_sll_ext.mpp,l_start_day) + 1;
             ELSE
                   l_pmnt_end_date := Okl_Lla_Util_Pvt.calculate_end_date(l_pmnt_end_date, TO_NUMBER(NVL(l_strm_sll_ext.periods,0)) * l_strm_sll_ext.mpp) + 1;
             END IF;
             --vthiruva 16-jun end..including l_start_day
        END IF;

             -- 5189866
             l_pmnt_end_date := l_pmnt_end_date - 1;
             IF ( TRUNC(l_pmnt_end_date) > TRUNC(l_end_date)) THEN

                    Okl_Api.set_message(
                         G_APP_NAME,
                         'OKL_QA_INVALID_STRM_END_DATE',
                         'STRM_TYPE',
                         l_strm_slh_ext.stream_type,
                         'LINE_TYPE',
                         l_fin_fee.line_type
                        );
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
                 --raise payment_end_date_invalid;
                 exit;
              END IF;

             END LOOP;

             --l_pmnt_end_date := l_pmnt_end_date - 1; -- 5189866

             /*
             l_pmnt_end_date := ADD_MONTHS(l_start_date, l_strm_sll_ext_periods * l_strm_sll_ext_mpp) - 1;
             IF (l_strm_sll_ext_stub_day <> 0) THEN
                l_pmnt_end_date := l_pmnt_end_date + l_strm_sll_ext_stub_day;
             END IF;
             */
               -- END: cklee/mvasudev, 05/11/2006, Bug#4364266/okl.h 4437938

             --5189866
             /*IF ( TRUNC(l_pmnt_end_date) > TRUNC(l_end_date)) THEN

                    Okl_Api.set_message(
                         G_APP_NAME,
                         'OKL_QA_INVALID_STRM_END_DATE',
                         'STRM_TYPE',
                         l_strm_slh_ext.stream_type,
                         'LINE_TYPE',
                         l_fin_fee.line_type
                        );
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
              END IF;*/

          END LOOP;

        END LOOP;
     END IF; -- Stream profile

 EXCEPTION

  WHEN payment_end_date_invalid THEN -- 5189866
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    -- verify that cursor was closed
    /*
    *IF strm_profile_csr%ISOPEN THEN
    *  CLOSE strm_profile_csr;
    *END IF;
    */

    IF contract_csr%ISOPEN THEN
      CLOSE contract_csr;
    END IF;

  END check_payment_period;


  -- Start of comments
  --
  -- Procedure Name  : check_fee_lines
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

/*
  PROCEDURE check_fee_lines(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);


    CURSOR l_contract_name ( n VARCHAR2 ) IS
    Select count(*) cnt
    From okc_k_headers_v where contract_number = n;
    l_cn l_contract_name%ROWTYPE;


    l_hdr     l_hdr_csr%ROWTYPE;
    l_txl     l_txl_csr%ROWTYPE;
    l_txd     l_txd_csr%ROWTYPE;
    l_lne     l_lne_csr%ROWTYPE;
    l_itm     l_itms_csr%ROWTYPE;
    l_struct_rec l_struct_csr%ROWTYPE;
    l_structure  NUMBER;
    l_rl_rec1 l_rl_csr1%ROWTYPE;
    i NUMBER;


    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_supp_rec supp_csr%ROWTYPE;
    l_lne l_lne_csr%ROWTYPE;
    l_fee_strm_type_rec  fee_strm_type_csr%ROWTYPE;
    l_strm_name_rec strm_name_csr%ROWTYPE;

    l_inflow_defined_yn VARCHAR2(1);
    l_outflow_defined_yn VARCHAR2(1);

    n NUMBER := 0;

  BEGIN

    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    FOR l_lne IN l_lne_csr('FEE', p_chr_id)
    LOOP

        l_inflow_defined_yn := 'N';
        l_outflow_defined_yn := 'N';

        OPEN  fee_strm_type_csr  ( l_lne.id, 'FEE' );
        FETCH fee_strm_type_csr into l_fee_strm_type_rec;
        CLOSE fee_strm_type_csr;

      If ( l_fee_strm_type_rec.strm_name <> 'SECURITY DEPOSIT') Then

        OPEN  l_rl_csr1( 'LAFEXP', 'LAFEXP', TO_NUMBER(p_chr_id), l_lne.id );
        FETCH l_rl_csr1 into l_rl_rec1;
        IF l_rl_csr1%FOUND THEN
            l_outflow_defined_yn := 'Y';
        END IF;
        CLOSE l_rl_csr1;

        n := 0;
        FOR l_rl_rec1 in l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne.id )
        LOOP
            n := n + 1;
        END LOOP;

        If ( n > 1 ) Then

                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_ONLY_1PAY',
                  p_token1       => 'line',
                  p_token1_value => l_fee_strm_type_rec.strm_name);
                x_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;

        End If;

        OPEN  l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne.id );
        FETCH l_rl_csr1 into l_rl_rec1;
        IF l_rl_csr1%FOUND THEN
            l_inflow_defined_yn := 'Y';
        END IF;
        CLOSE l_rl_csr1;

        If (  l_inflow_defined_yn = 'Y' ) Then

            OPEN  strm_name_csr ( l_rl_rec1.object1_id1 );
            FETCH strm_name_csr into l_strm_name_rec;
            IF strm_name_csr%NOTFOUND THEN
                CLOSE strm_name_csr;
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;
            CLOSE strm_name_csr;

            If ( l_strm_name_rec.name <> l_fee_strm_type_rec.strm_name ) Then

                    OKL_API.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_STRM_DONT_MATCH',
                      p_token1       => 'line',
                      p_token1_value => l_fee_strm_type_rec.strm_name);
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    RAISE G_EXCEPTION_HALT_VALIDATION;

            End If;

        End If;

        If ( ( l_fee_strm_type_rec.capitalize_yn = 'Y' ) AND
             ( l_outflow_defined_yn = 'Y' OR l_inflow_defined_yn = 'Y' ) ) Then

                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_FLOWS_CAPFEE',
                  p_token1       => 'line',
                  p_token1_value => l_fee_strm_type_rec.strm_name);
                x_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE G_EXCEPTION_HALT_VALIDATION;

        End If;

        If ( l_fee_strm_type_rec.stream_type_class <> 'EXPENSE'  AND l_outflow_defined_yn = 'Y' ) Then

                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_OUTFLOWS_EXPENSE',
                  p_token1       => 'line',
                  p_token1_value => l_fee_strm_type_rec.strm_name);
                x_return_status := OKL_API.G_RET_STS_ERROR;

        End If;

        If (  l_outflow_defined_yn = 'Y' AND l_inflow_defined_yn = 'Y'  ) Then
                OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_INOUT_FLOWS',
                  p_token1       => 'line',
                  p_token1_value => l_fee_strm_type_rec.strm_name);
                x_return_status := OKL_API.G_RET_STS_ERROR;
        End If;

      End If;

    END LOOP;

  IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;


  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_rl_csr1%ISOPEN THEN
      CLOSE l_rl_csr1;
    END IF;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_txl_csr%ISOPEN THEN
      CLOSE l_txl_csr;
    END IF;

  End check_fee_lines;
*/

-- Added for bug 5115701 -- start

 FUNCTION Are_assets_associated (p_chr_id IN NUMBER, p_kle_id in number) RETURN  VARCHAR2 IS


     CURSOR l_assets_asso_csr(chrId IN NUMBER, kleId in NUMBER) IS
    SELECT cleb.id
    FROM okc_k_lines_b cleb

    WHERE cleb.dnz_chr_id = chrId
    AND cleb.chr_id = chrId
    AND CLEB.ID =kleId
    and exists
    (  SELECT '1'
    FROM okc_k_lines_b cleb1,
         okc_statuses_b okcsts1
    WHERE cleb1.dnz_chr_id = cleb.chr_id
    AND cleb1.cle_id = cleb.id
    AND okcsts1.code = cleb1.sts_code
    AND okcsts1.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED'));

    l_assets_associated VARCHAR2(1) DEFAULT 'N';

BEGIN
    l_assets_associated := 'N';


    OPEN l_assets_asso_csr(chrid => p_chr_id,  kleId => p_kle_id);
    FETCH l_assets_asso_csr INTO l_assets_associated;
    IF l_assets_asso_csr%NOTFOUND THEN
        NULL;
    END IF;
    CLOSE l_assets_asso_csr;
    RETURN(l_assets_associated);
    EXCEPTION

    WHEN OTHERS THEN
         IF l_assets_asso_csr%ISOPEN THEN
             CLOSE l_assets_asso_csr;
         END IF;
         RETURN('Y');
END Are_assets_associated;
-- Added for bug 5115701 -- End


  PROCEDURE check_fee_lines(
                            x_return_status            OUT NOCOPY VARCHAR2,
                            p_chr_id                   IN  NUMBER
                           ) IS
  CURSOR fee_line_csr (p_chrId OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT l.id,
         l.line_number,
         l.start_date,
         l.end_date,
         l.name,
         l.amount,
         l.capital_amount,
         l.fee_type
  FROM   okl_k_lines_full_v l,
         okc_line_styles_v sty,
         okc_statuses_v sts
  WHERE  l.lse_id = sty.id
  AND    l.sts_code = sts.code
  AND    sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    sty.lty_code = 'FEE'
  AND    l.dnz_chr_id = p_chrId;

  CURSOR fee_meaning_csr (p_fee_type_code FND_LOOKUPS.LOOKUP_CODE%TYPE) IS
  SELECT meaning
  FROM   fnd_lookups
  WHERE  lookup_code = p_fee_type_code
  AND    lookup_type = 'OKL_FEE_TYPES';

  --------------
  --Bug# 4350255
  --------------

  CURSOR pth_hdr_csr(p_chr_id IN NUMBER,
                     p_cle_id IN NUMBER) IS
  SELECT 1
  FROM   okl_party_payment_hdr pph
  WHERE  cle_id = p_cle_id
  AND    dnz_chr_id = p_chr_id
  AND    passthru_term = 'BASE';

  --------------
  --Bug# 4350255
  --------------

  l_fee_type    FND_LOOKUPS.MEANING%TYPE;
  l_pmnt_amount NUMBER;

  l_tot_pmnt    NUMBER := 0;
  l_exp_present VARCHAR2(1) := 'N';
  l_pth_present VARCHAR2(1) := 'N';
  l_tot_secdep  NUMBER := 0;

  l_exp_period  NUMBER;
  l_exp_amount  NUMBER;
  l_exp_freq    VARCHAR2(20);
  l_mult_factor NUMBER;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    l_tot_secdep := 0;
    FOR fee_line_rec IN fee_line_csr (p_chr_id)
    LOOP


             -- Get Fee type meaning
       FOR fee_meaning_rec IN fee_meaning_csr (fee_line_rec.fee_type)
       LOOP
          l_fee_type := fee_meaning_rec.meaning;
       END LOOP;

       -- gk added
     IF fee_line_rec.fee_type NOT IN ('FINANCED','ROLLOVER','CAPITALIZED') THEN

     IF Are_assets_associated(p_chr_id => p_chr_id, p_kle_id => fee_line_rec.ID  ) = 'Y' THEN
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_ASSET_CANT_ASSOC',
                   p_token1       => 'fee_type',
                  p_token1_value => l_fee_type,
                  p_token2       => 'line',
                  p_token2_value => fee_line_rec.name

                 );

          x_return_status := Okl_Api.G_RET_STS_ERROR;
     END IF;
     END IF;
-- gk added

       --
       -- 1. FEE line should have only 1 payment defined
       --
       l_tot_pmnt := 0;
       FOR l_rl_rec1 IN l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), fee_line_rec.id )
       LOOP
          l_tot_pmnt := l_tot_pmnt + 1;
       END LOOP;

       IF ( l_tot_pmnt > 1 ) THEN

          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_ONLY_1PAY',
                  p_token1       => 'line',
                  p_token1_value => fee_line_rec.name
                 );

          x_return_status := Okl_Api.G_RET_STS_ERROR;

       END IF;

       --
       -- 2. For FEE_TYPE = Miscellaneous, Security Deposit, Pass through, Financed, Income
       --    Payments must be defined
       --
       --Bug# 4996899: Financed fee payments will be validated separately by check_financed_fees procedure
       --IF (fee_line_rec.fee_type IN ('MISCELLANEOUS', 'SECDEPOSIT', 'PASSTHROUGH', 'FINANCED','INCOME')) THEN
         IF (fee_line_rec.fee_type IN ('MISCELLANEOUS', 'SECDEPOSIT', 'PASSTHROUGH', 'INCOME')) THEN
          l_tot_pmnt := 0;
          FOR l_rl_rec1 IN l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), fee_line_rec.id )
          LOOP
             l_tot_pmnt := l_tot_pmnt + 1;
          END LOOP;

          IF (l_tot_pmnt = 0) THEN
             Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_PMNT',
                  p_token1       => 'FEE_TYPE',
                  p_token1_value => l_fee_type,
                  p_token2       => 'STRM_TYPE',
                  p_token2_value => fee_line_rec.name
                 );

             x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

       END IF; -- check 2

       --
       -- 3. For FEE_TYPE = Miscellaneous, Expense, Absorbed, Financed
       --    Expense must be defined, expense must be within fee effectivity
       --    Also expense amount must be equal to Fee line amount
       --
       --    Absorbed Fee Type has been removed from financed expense check
       --    as per Bug# 3316775
       --
       IF (fee_line_rec.fee_type IN ('MISCELLANEOUS', 'EXPENSE', 'FINANCED')) THEN

          l_exp_present := '?';
          FOR l_rl_rec1 IN l_rl_csr1( 'LAFEXP', 'LAFEXP', TO_NUMBER(p_chr_id), fee_line_rec.id )
          LOOP
            l_exp_present := 'Y';
            l_exp_period  := TO_NUMBER(l_rl_rec1.rule_information1);
            l_exp_amount  := TO_NUMBER(l_rl_rec1.rule_information2);
          END LOOP;

          FOR l_rl_rec1 IN l_rl_csr1( 'LAFEXP', 'LAFREQ', TO_NUMBER(p_chr_id), fee_line_rec.id )
          LOOP
            l_exp_freq  := l_rl_rec1.object1_id1;
          END LOOP;

          IF (l_exp_present <> 'Y') THEN
             Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_EXP',
                  p_token1       => 'FEE_TYPE',
                  p_token1_value => l_fee_type,
                  p_token2       => 'STRM_TYPE',
                  p_token2_value => fee_line_rec.name
                 );

             x_return_status := Okl_Api.G_RET_STS_ERROR;

          ELSE

             --
             -- Expense period between contract effectivity
             --
             l_mult_factor := 1;
             IF (l_exp_freq = 'M') THEN
              l_mult_factor := 1;
             ELSIF (l_exp_freq = 'Q') THEN
              l_mult_factor := 3;
             ELSIF (l_exp_freq = 'S') THEN
              l_mult_factor := 6;
             ELSIF (l_exp_freq = 'A') THEN
              l_mult_factor := 12;
             END IF;

             IF (TRUNC(fee_line_rec.end_date) < (TRUNC(ADD_MONTHS(fee_line_rec.start_date, l_exp_period * l_mult_factor)-1))) THEN
                 Okl_Api.set_message(
                                     G_APP_NAME,
                                     'OKL_QA_RECUR_PERIOD',
                                     'STRM_TYPE',
                                     fee_line_rec.name
                                    );
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;

             l_exp_amount := l_exp_amount * l_exp_period;
             --l_exp_amount := l_exp_amount * l_exp_period * l_mult_factor;

             IF (fee_line_rec.amount <> l_exp_amount) THEN
                 Okl_Api.set_message(
                                     G_APP_NAME,
                                     'OKL_QA_EXP_AMT_MISMATCH',
                                     'FEE_TYPE',
                                     l_fee_type,
                                     'STRM_TYPE',
                                     fee_line_rec.name
                                    );
                 x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;

         END IF; -- expense

       END IF; -- check 3

       --
       -- 4. For FEE_TYPE = Passthrough and Expense
       --    Passthrough must be defined
       --
       IF (fee_line_rec.fee_type = 'PASSTHROUGH') THEN

          -- Bug# 4350255
          l_pth_present := '?';
          FOR pth_hdr_rec IN pth_hdr_csr( p_chr_id => TO_NUMBER(p_chr_id),
                                          p_cle_id => fee_line_rec.id )
          LOOP
            l_pth_present := 'Y';
          END LOOP;

          IF (l_pth_present <> 'Y') THEN
             Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_PTH',
                  p_token1       => 'STRM_TYPE',
                  p_token1_value => fee_line_rec.name
                 );

             x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

       END IF; -- check 4

       --
       -- 5. Only one Security Deposite in a contract
       --
       IF (fee_line_rec.fee_type = 'SECDEPOSIT') THEN
         l_tot_secdep := l_tot_secdep + 1;
       END IF;

       --
       -- 6. No GENERAL Fee type should be there on a contract
       --
       IF (fee_line_rec.fee_type = 'GENERAL') THEN
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_GEN_NOTALLOW'
                 );

          x_return_status := Okl_Api.G_RET_STS_ERROR;
          --GOTO check_next_line;
       END IF;

       --
       -- 7. Payment amount for Security Deposite,Passthrough, Income
       --    must be equal to Fee line amount
       --
       IF (fee_line_rec.fee_type IN ('SECDEPOSIT','PASSTHROUGH', 'INCOME') ) THEN

          l_pmnt_amount := 0;
          FOR l_rl_rec1 IN l_rl_csr1( 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), fee_line_rec.id )
          LOOP

             IF (l_rl_rec1.rule_information8 IS NOT NULL) THEN
                l_pmnt_amount := l_pmnt_amount + TO_NUMBER(NVL(l_rl_rec1.rule_information8,'0'));
             ELSE
                l_pmnt_amount := l_pmnt_amount + ( TO_NUMBER(NVL(l_rl_rec1.rule_information6,'0')) *
                                                   TO_NUMBER(NVL(l_rl_rec1.rule_information3,'1')) );
             END IF;

             IF (fee_line_rec.fee_type = 'SECDEPOSIT'
                 AND
                 l_rl_rec1.rule_information7 IS NOT NULL) THEN
                  Okl_Api.set_message(
                                      G_APP_NAME,
                                      'OKL_QA_SECR_STUB',
                                      'STRM_TYPE',
                                      fee_line_rec.name
                                     );
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;
          END LOOP;

          IF (l_pmnt_amount <> fee_line_rec.amount) THEN
              Okl_Api.set_message(
                                  G_APP_NAME,
                                  'OKL_QA_SECR_PAYMENT',
                                  'FEE_TYPE',
                                  l_fee_type,
                                  'STRM_TYPE',
                                  fee_line_rec.name
                                 );
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

       END IF; --7

    END LOOP; -- fee_line_csr

    -- check 5 cont.
    IF (l_tot_secdep > 1) THEN
       Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SECDEP_MORE1'
                 );

       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      NULL;
  END check_fee_lines;




    ----------------------------------------------------------------------------
    --start of comments
    --API Name    : check_rolloverQuotes
    --Description : API called to validate the rollover quote on a contract.
    --              Check if the Rollover fee amount is equal to Rollover
    --              qupte amount.
    --Parameters  : IN  - p_chr_id - Contract Number
    --              OUT - x_return_status - Return Status
    --History     : 23-Aug-2004 Manu Created
    --
    --
    --end of comments
    -----------------------------------------------------------------------------

    PROCEDURE check_rolloverQuotes(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER)  IS


      l_return_status   VARCHAR2(1)           := Okl_Api.G_RET_STS_SUCCESS;
      l_api_version    CONSTANT NUMBER          := 1.0;
      l_init_msg_list   VARCHAR2(1) DEFAULT Okc_Api.G_FALSE;
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(1000);
      l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_ROLLOVERQUOTES';

      l_not_found    BOOLEAN := FALSE;
      l_amt        NUMBER;
      l_found        VARCHAR2(1);


    /* Cursor to get the top fee line and the rollover quote
       for top fee line of a given contract. */

    CURSOR l_rq_top_fee_ln_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE ) IS
    SELECT kle.id, kle.qte_id, kle.amount, cleb.name
    FROM okc_k_lines_v cleb,
         okl_k_lines kle
    WHERE cleb.dnz_chr_id = chrID
        AND kle.ID = cleb.ID
        AND kle.fee_type = 'ROLLOVER'
        -- AND cleb.sts_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED', 'ABANDONED');
        AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'));


    /* Cursor to get the top fee line and the rollover quote
       for top fee line of a given contract. */

    CURSOR l_rq_top_fee_ln_csr1 ( chrID IN OKC_K_HEADERS_B.ID%TYPE ) IS
    SELECT kle.qte_id
    FROM okc_k_lines_b cleb,
         okl_k_lines kle
    WHERE cleb.dnz_chr_id = chrID
        AND kle.ID = cleb.ID
        AND kle.fee_type = 'ROLLOVER'
        -- AND cleb.sts_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED', 'ABANDONED');
        AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'));


    /* Cursor to get the rollover quote fee sub-lines (applied to assets) for a
       given contract. */

    CURSOR l_rq_sub_ln_fee_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                                 feeTopLine IN OKL_K_LINES.ID%TYPE) IS
    SELECT kle.id, kle.amount, cleb.end_date
    FROM okc_k_lines_b cleb,
         okl_k_lines kle
    WHERE cleb.dnz_chr_id = chrID
        AND kle.ID = cleb.ID
        AND cleb.CLE_ID = feeTopLine
        -- AND cleb.sts_code NOT IN ('HOLD','EXPIRED','TERMINATED','CANCELLED', 'ABANDONED');
        AND    NOT EXISTS (
                     SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 --Bug# 4959361: Include Terminated lines when fetching sub-line amount
                 --AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'));
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','ABANDONED'));


    /* Cursor to get the Quote Number. */

    CURSOR l_qte_number_csr ( qteID IN OKL_TRX_QUOTES_V.ID%TYPE ) IS
    SELECT quote_number
    FROM okl_trx_quotes_v
    WHERE id = qteID;


    /* Cursor to get the rollover quote fee top/sub-line payments for a
       given contract. */

    CURSOR l_rq_fee_pmt_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                              feeLine IN OKL_K_LINES.ID%TYPE) IS

    SELECT sll.rule_information2 start_date,
           SLL.rule_information3 periods,
           DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
           TRUNC(ADD_MONTHS(Fnd_Date.canonical_to_date(sll.rule_information2),
             TO_NUMBER(SLL.rule_information3)*DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)) - 1) end_date,
           styt.name stream_type
          FROM   okc_rules_b sll,
                 okc_rules_b slh,
                 okc_rule_groups_b rgp,
                 okl_strm_type_b sty,
                 okl_strm_type_tl styt
          WHERE  rgp.dnz_chr_id                = chrID
            AND  rgp.cle_id                    = feeLine
            AND  rgp.rgd_code                  = 'LALEVL'
            AND  rgp.id                        = slh.rgp_id
            AND  slh.rule_information_category = 'LASLH'
            AND  slh.object1_id1               = TO_CHAR(sty.id)
            AND  styt.LANGUAGE                 = USERENV('LANG')
            AND  sty.id                        = styt.id
            AND  TO_CHAR(slh.id)               = sll.object2_id1
            AND  sll.rule_information_category = 'LASLL';


    /* Cursor to get the rollover quote fee top/sub-line payments HEADER for a
       given contract. */

    CURSOR l_rq_fee_pmtH_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                              feeLine IN OKL_K_LINES.ID%TYPE) IS

    SELECT slh.id
          FROM   okc_rules_b slh,
                 okc_rule_groups_b rgp,
                 okl_strm_type_b sty,
                 okl_strm_type_tl styt
          WHERE  rgp.dnz_chr_id                = chrID
            AND  rgp.cle_id                    = feeLine
            AND  rgp.rgd_code                  = 'LALEVL'
            AND  rgp.id                        = slh.rgp_id
            AND  slh.rule_information_category = 'LASLH'
            AND  slh.object1_id1               = TO_CHAR(sty.id)
            AND  styt.LANGUAGE                 = USERENV('LANG')
            AND  sty.id                        = styt.id;

    l_top_fee_ln_id OKL_K_LINES.ID%TYPE;
    l_top_fee_ln_name OKC_K_LINES_V.NAME%TYPE;
    l_sub_fee_ln_id OKL_K_LINES.ID%TYPE;
    l_qte_id OKL_K_LINES.QTE_ID%TYPE;
    l_qte_num OKL_TRX_QUOTES_V.QUOTE_NUMBER%TYPE;
    p_term_tbl Okl_Trx_Quotes_Pub.qtev_tbl_type;
    x_term_tbl Okl_Trx_Quotes_Pub.qtev_tbl_type;
    x_err_msg VARCHAR2(1000);

    l_tq_rec_count NUMBER        := 0; -- Rollover fee line count on a contract
    l_rq_sub_ln_fee_cnt   NUMBER := 0;
    l_rq_dup_trm_qt_cnt   NUMBER := 0;
    l_pmt_dup_sub_ln_cnt  NUMBER := 0; -- Counter for duplicate payments for a sub-line.
    l_payment_top_ln_cnt  NUMBER := 0; -- Counter for rollover payments top lines
    l_payment_sub_ln_cnt  NUMBER := 0; -- Counter for rollover payments sub-lines
    l_rq_top_ln_fee_amt   NUMBER := 0; -- Rollover top line total fee amount.
    l_rq_sub_ln_fee_amt   NUMBER := 0; -- Rollover sum of sub-line fee amount.
    l_top_ln_pmt_exist   BOOLEAN := FALSE;
    l_rq_sln_fee_amt_chk BOOLEAN := FALSE; -- If there are sub-lines payments exists.

  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      -- OPEN l_rq_top_fee_ln_csr ( chrID => p_chr_id );
      FOR l_rq_top_fee_ln IN l_rq_top_fee_ln_csr ( chrID => p_chr_id )
      LOOP
        --FETCH l_rq_top_fee_ln_csr INTO l_top_fee_ln_id, l_qte_id;
        --IF( l_rq_top_fee_ln_csr%FOUND ) THEN

        /* Store the amount for rollover fee top line */
        l_rq_top_ln_fee_amt := l_rq_top_fee_ln.amount;

        /* Store the Top Fee Line Name */
        l_top_fee_ln_name   := l_rq_top_fee_ln.name;

        /* Call the API to validate the rollover termination quotes
           for a given contract. This API is also called before
           activating the contract. */

        l_return_status := x_return_status;
        Okl_Maintain_Fee_Pvt.validate_rollover_feeLine(
            p_api_version     => l_api_version,
            p_init_msg_list   => l_init_msg_list,
            x_return_status   => l_return_status,
            x_msg_count       => l_msg_count,
            x_msg_data        => l_msg_data,
            p_chr_id          => p_chr_id,
            p_qte_id          => l_rq_top_fee_ln.qte_id,
            p_for_qa_check    => TRUE);

           -- dedey 01/21/05 Bug 4134571
           IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
              x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;

        /* Check Payments for the top fee line if they exist. If there are multiple
           payments for the top line error out.
           CHECK FOR PAYMENT HEADER. */
        FOR l_rq_fee_pmtH IN l_rq_fee_pmtH_csr ( chrID => p_chr_id, feeLine => l_rq_top_fee_ln.id )
        LOOP
          l_top_ln_pmt_exist := TRUE;
          l_payment_top_ln_cnt := l_payment_top_ln_cnt + 1;


          /* ALREADY CHECKED. Please enter only one payment type per fee line.
             (line=SERVICE AND MAINTENANCE)
          IF (l_payment_top_ln_cnt > 1) THEN
             OPEN l_qte_number_csr(qteID => l_rq_top_fee_ln.qte_id);
             FETCH l_qte_number_csr INTO l_qte_num;
             CLOSE l_qte_number_csr;
             x_return_status := OKL_API.G_RET_STS_ERROR;
             OKL_API.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_QA_RQ_MLTP_PMTS_TOP_LN',
                               p_token1       => 'quoteNum',
                            p_token1_value => l_qte_num);
          END IF;
          ********************************/
        END LOOP;
        l_payment_top_ln_cnt := 0;

        /* Check for any given contract, each rollover fee line must
           point to a different termination quote. */

        l_rq_dup_trm_qt_cnt := 0;
        FOR l_rq_top_fee_ln1 IN l_rq_top_fee_ln_csr1 ( chrID => p_chr_id )
        LOOP
          IF (l_rq_top_fee_ln1.qte_id = l_rq_top_fee_ln.qte_id) THEN
            l_rq_dup_trm_qt_cnt := l_rq_dup_trm_qt_cnt + 1;
            IF ( l_rq_dup_trm_qt_cnt > 1 ) THEN
              OPEN l_qte_number_csr(qteID => l_rq_top_fee_ln.qte_id);
              FETCH l_qte_number_csr INTO l_qte_num;
              CLOSE l_qte_number_csr;
              x_return_status := Okl_Api.G_RET_STS_ERROR;
              Okl_Api.set_message(
                          p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_QA_DUP_TERM_QUOTE');
            END IF;
          END IF;
        END LOOP;
        l_rq_dup_trm_qt_cnt := 0;

        /* Check payments for rollover quote fee sub-line, if it exist both for top
           line and sub-line error out. If there are multiple payments for sub-line
           error out. If payment end date is past fee line end date error out. */

        FOR l_rq_sub_ln_fee IN l_rq_sub_ln_fee_csr( chrID => p_chr_id, feeTopLine => l_rq_top_fee_ln.id )
        LOOP

          l_rq_sub_ln_fee_cnt := l_rq_sub_ln_fee_cnt + 1;

          /* Store the sum of  for rollover fee sub-line amount. */
          l_rq_sub_ln_fee_amt := l_rq_sub_ln_fee_amt + l_rq_sub_ln_fee.amount;

          /* Sub-line fees exists. */
          l_rq_sln_fee_amt_chk := TRUE;

      OPEN l_qte_number_csr(qteID => l_rq_top_fee_ln.qte_id);
      FETCH l_qte_number_csr INTO l_qte_num;
      CLOSE l_qte_number_csr;

          /* Check Payments for the rollovr quote fee sub-line if they exist. If there are multiple
         payments for the sub-line error out.
         CHECK FOR PAYMENT HEADER. */

      FOR l_rq_fee_pmtH IN l_rq_fee_pmtH_csr ( chrID => p_chr_id, feeLine => l_rq_sub_ln_fee.id )
      LOOP
        IF (l_top_ln_pmt_exist) THEN
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_RQ_PMTS_TOP_SUB_EXIST',
                             p_token1       => 'QUOTE_NUMBER',
                              p_token1_value => l_qte_num);
        END IF;


        l_payment_sub_ln_cnt := l_payment_sub_ln_cnt + 1;


        /**************
        l_pmt_dup_sub_ln_cnt := 0;

        FOR l_rq_fee_pmt1 IN l_rq_fee_pmt_csr ( chrID => p_chr_id, feeLine => l_rq_sub_ln_fee.id )
        LOOP
          IF ( l_rq_fee_pmt.id = l_rq_fee_pmt1.id ) THEN
            l_pmt_dup_sub_ln_cnt := l_pmt_dup_sub_ln_cnt + 1;
          END IF;
        END LOOP;
        *****************/

        /* Check if the there are multiple payments for the rollover quote
           fee sub-line, if so error out.

        IF (l_pmt_dup_sub_ln_cnt > 1) THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
          OKL_API.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_RQ_MLTP_PMTS_SLN',
                             p_token1       => 'quoteNum',
                              p_token1_value => l_qte_num);
        END IF;

        l_pmt_dup_sub_ln_cnt := 0;
        ******************/
      END LOOP;

      FOR l_rq_fee_pmt IN l_rq_fee_pmt_csr ( chrID => p_chr_id, feeLine => l_rq_sub_ln_fee.id )
      LOOP
       /* Check if the payment end date is within in the rollover quote
           fee sub-line's end date, if not error out. */

        IF ( TRUNC(l_rq_fee_pmt.end_date) > TRUNC(l_rq_sub_ln_fee.end_date) ) THEN
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_RQ_SLN_PMT_ED',
                             p_token1       => 'QUOTE_NUMBER',
                              p_token1_value => l_qte_num);
        END IF;

      END LOOP;

        END LOOP;

        /* Check if a rollover top line fee amount is not equal to sub-line fee amount,
           if exists, if not error out. */

        IF ( (l_rq_sln_fee_amt_chk) AND (l_rq_top_ln_fee_amt <> l_rq_sub_ln_fee_amt) ) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_RQ_FEE_AMT_NEQ',
                         p_token1       => 'QUOTE_NUMBER',
                          p_token1_value => l_qte_num);
        END IF;
        l_rq_top_ln_fee_amt := 0;
        l_rq_sub_ln_fee_amt := 0;

        /* If no payments are defiend for the fee line then error out. */

        IF ((NOT l_top_ln_pmt_exist) AND (NOT l_rq_sln_fee_amt_chk)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_RQ_NO_PMTS',
                         p_token1       => 'FEE_LINE',
                          p_token1_value => l_top_fee_ln_name);

        END IF;


        /* Check if a payment is defined for EACH of the rollover quote fee sub-lines HEADER,
           if not error out. If there are multiple payments defiend for a rollover quote
           fee sub-line HEADER error out. */

        IF ((NOT l_top_ln_pmt_exist) AND (l_rq_sub_ln_fee_cnt >  l_payment_sub_ln_cnt)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_RQ_PMTS_MISS_SLN',
                         p_token1       => 'QUOTE_NUMBER',
                          p_token1_value => l_qte_num);
    ELSIF ((NOT l_top_ln_pmt_exist) AND (l_rq_sub_ln_fee_cnt <  l_payment_sub_ln_cnt)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_RQ_MUL_SLN_PMTS',
                         p_token1       => 'QUOTE_NUMBER',
                          p_token1_value => l_qte_num);
        END IF;
        l_rq_sub_ln_fee_cnt  := 0;
        l_payment_sub_ln_cnt := 0;
        -- Bug 3987419
        l_top_ln_pmt_exist   := FALSE; -- Setting back to FALSE to check for next fee line.

        -- Bug 4094336
        l_rq_sln_fee_amt_chk := FALSE; -- Setting back to FALSE.

      END LOOP;

    --TURN_ON_THE_FUNC_CONSTRAINTS;

     EXCEPTION

          WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;

                IF l_rq_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr;
          END IF;

                IF l_rq_top_fee_ln_csr1%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr1;
          END IF;

                IF l_rq_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_rq_sub_ln_fee_csr;
          END IF;

                IF l_qte_number_csr%ISOPEN THEN
                  CLOSE l_qte_number_csr;
          END IF;

                IF l_rq_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_rq_fee_pmt_csr;
          END IF;

          WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

                IF l_rq_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr;
          END IF;

                IF l_rq_top_fee_ln_csr1%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr1;
          END IF;

                IF l_rq_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_rq_sub_ln_fee_csr;
          END IF;

                IF l_qte_number_csr%ISOPEN THEN
                  CLOSE l_qte_number_csr;
          END IF;

                IF l_rq_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_rq_fee_pmt_csr;
          END IF;

          WHEN OTHERS THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;

                IF l_rq_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr;
          END IF;

                IF l_rq_top_fee_ln_csr1%ISOPEN THEN
                  CLOSE l_rq_top_fee_ln_csr1;
          END IF;

                IF l_rq_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_rq_sub_ln_fee_csr;
          END IF;

                IF l_qte_number_csr%ISOPEN THEN
                  CLOSE l_qte_number_csr;
          END IF;

                IF l_rq_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_rq_fee_pmt_csr;
          END IF;

            /*

            x_return_status := OKL_API.HANDLE_EXCEPTIONS(
              p_api_name  => l_api_name,
              p_pkg_name  => g_pkg_name,
              p_exc_name  => 'OTHERS',
              x_msg_count => l_msg_count,
              x_msg_data  => l_msg_data,
              p_api_type  => g_api_type);
          */

  END check_rolloverQuotes;

      --Bug# 4996899
    ----------------------------------------------------------------------------
    --start of comments
    --API Name    : check_financed_fees
    --Description : API called to validate the financed fees on a contract.
    --Parameters  : IN  - p_chr_id - Contract Number
    --              OUT - x_return_status - Return Status
    --History     : 03-Mar-2006 rpillay Created
    --
    --
    --end of comments
    -----------------------------------------------------------------------------

    PROCEDURE check_financed_fees(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER)  IS


      l_return_status   VARCHAR2(1)           := Okl_Api.G_RET_STS_SUCCESS;
      l_api_version    CONSTANT NUMBER          := 1.0;
      l_init_msg_list   VARCHAR2(1) DEFAULT Okc_Api.G_FALSE;
      l_msg_count       NUMBER;
      l_msg_data        VARCHAR2(1000);
      l_api_name        CONSTANT VARCHAR2(30) := 'CHECK_FINANCED_FEES';

      l_not_found    BOOLEAN := FALSE;
      l_amt        NUMBER;
      l_found    VARCHAR2(1);


    /* Cursor to get the top fee line for financed fees of a given contract. */

    -- R12B Authoring OA Migration
    -- Validation of Sales Tax Financed Fee will be done
    -- after the Calculate Upfront Tax process
    CURSOR l_fn_top_fee_ln_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE ) IS
    SELECT kle.id, kle.amount, cleb.name
    FROM okc_k_lines_v cleb,
         okl_k_lines kle,
         okc_statuses_b okcsts
    WHERE cleb.dnz_chr_id = chrID
    AND cleb.chr_id = chrID
    AND kle.ID = cleb.ID
    AND kle.fee_type = 'FINANCED'
    AND okcsts.code = cleb.sts_code
    AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED')
    AND NVL(kle.fee_purpose_code,'XXX') <> 'SALESTAX';


    /* Cursor to get the financed fee sub-lines (applied to assets) for a
       given contract. */

    CURSOR l_fn_sub_ln_fee_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                                 feeTopLine IN OKL_K_LINES.ID%TYPE) IS
    SELECT kle.id, kle.amount, cleb.end_date
    ,cleb.start_date   -- added for bug 5115701
    FROM okc_k_lines_b cleb,
         okl_k_lines kle,
         okc_statuses_b okcsts
    WHERE cleb.dnz_chr_id = chrID
    AND kle.ID = cleb.ID
    AND cleb.CLE_ID = feeTopLine
    AND okcsts.code = cleb.sts_code
    --Bug# 4959361: Include Terminated lines when fetching sub-line amount
    AND okcsts.ste_code NOT IN ('EXPIRED','HOLD','CANCELLED','ABANDONED');


    /* Cursor to get the financed fee top/sub-line payments for a
       given contract. */

    CURSOR l_fn_fee_pmt_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                              feeLine IN OKL_K_LINES.ID%TYPE) IS

    SELECT Fnd_Date.canonical_to_date(sll.rule_information2) start_date, -- formated for bug 5115701,
           SLL.rule_information3 periods,
           DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12) mpp,
           TRUNC(ADD_MONTHS(Fnd_Date.canonical_to_date(sll.rule_information2),
             TO_NUMBER(SLL.rule_information3)*DECODE(sll.object1_id1, 'M', 1, 'Q', 3, 'S', 6, 'A', 12)) - 1) end_date,
           styt.name stream_type
          FROM   okc_rules_b sll,
                 okc_rules_b slh,
                 okc_rule_groups_b rgp,
                 okl_strm_type_b sty,
                 okl_strm_type_tl styt
          WHERE  rgp.dnz_chr_id                = chrID
            AND  rgp.cle_id                    = feeLine
            AND  rgp.rgd_code                  = 'LALEVL'
            AND  rgp.id                        = slh.rgp_id
            AND  slh.rule_information_category = 'LASLH'
            AND  slh.object1_id1               = TO_CHAR(sty.id)
            AND  styt.LANGUAGE                 = USERENV('LANG')
            AND  sty.id                        = styt.id
            AND  TO_CHAR(slh.id)               = sll.object2_id1
            AND  sll.rule_information_category = 'LASLL';


    /* Cursor to get the financed fee top/sub-line payments HEADER for a
       given contract. */

    CURSOR l_fn_fee_pmtH_csr ( chrID IN OKC_K_HEADERS_B.ID%TYPE,
                              feeLine IN OKL_K_LINES.ID%TYPE) IS

    SELECT slh.id
          FROM   okc_rules_b slh,
                 okc_rule_groups_b rgp,
                 okl_strm_type_b sty,
                 okl_strm_type_tl styt
          WHERE  rgp.dnz_chr_id                = chrID
            AND  rgp.cle_id                    = feeLine
            AND  rgp.rgd_code                  = 'LALEVL'
            AND  rgp.id                        = slh.rgp_id
            AND  slh.rule_information_category = 'LASLH'
            AND  slh.object1_id1               = TO_CHAR(sty.id)
            AND  styt.LANGUAGE                 = USERENV('LANG')
            AND  sty.id                        = styt.id;

    l_top_fee_ln_id OKL_K_LINES.ID%TYPE;
    l_top_fee_ln_name OKC_K_LINES_V.NAME%TYPE;
    l_sub_fee_ln_id OKL_K_LINES.ID%TYPE;
    x_err_msg VARCHAR2(1000);

    l_fn_sub_ln_fee_cnt   NUMBER := 0;
    l_pmt_dup_sub_ln_cnt  NUMBER := 0; -- Counter for duplicate payments for a sub-line.
    l_payment_top_ln_cnt  NUMBER := 0; -- Counter for financed payments top lines
    l_payment_sub_ln_cnt  NUMBER := 0; -- Counter for financed payments sub-lines
    l_fn_top_ln_fee_amt   NUMBER := 0; -- Financed top line total fee amount.
    l_fn_sub_ln_fee_amt   NUMBER := 0; -- Financed sum of sub-line fee amount.
    l_top_ln_pmt_exist   BOOLEAN := FALSE;
    l_fn_sln_fee_amt_chk BOOLEAN := FALSE; -- If there are sub-lines payments exists.

  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      FOR l_fn_top_fee_ln IN l_fn_top_fee_ln_csr ( chrID => p_chr_id )
      LOOP

        /* Store the amount for financed fee top line */
        l_fn_top_ln_fee_amt := l_fn_top_fee_ln.amount;

        /* Store the Top Fee Line Name */
        l_top_fee_ln_name   := l_fn_top_fee_ln.name;

        /* Check Payments for the top fee line if they exist. */
        FOR l_fn_fee_pmtH IN l_fn_fee_pmtH_csr ( chrID => p_chr_id, feeLine => l_fn_top_fee_ln.id )
        LOOP
          l_top_ln_pmt_exist := TRUE;
        END LOOP;

        /* Check payments for financed fee sub-line, if it exist both for top
           line and sub-line error out. If payment end date is past fee line end date error out. */

        FOR l_fn_sub_ln_fee IN l_fn_sub_ln_fee_csr( chrID => p_chr_id, feeTopLine => l_fn_top_fee_ln.id )
        LOOP

          l_fn_sub_ln_fee_cnt := l_fn_sub_ln_fee_cnt + 1;

          /* Store the sum of financed fee sub-line amount. */
          l_fn_sub_ln_fee_amt := l_fn_sub_ln_fee_amt + l_fn_sub_ln_fee.amount;

          /* Sub-line fees exists. */
          l_fn_sln_fee_amt_chk := TRUE;

          /* Check Payments for the financed fee sub-line if they exist. */

        FOR l_fn_fee_pmtH IN l_fn_fee_pmtH_csr ( chrID => p_chr_id, feeLine => l_fn_sub_ln_fee.id )
        LOOP
          IF (l_top_ln_pmt_exist) THEN
                x_return_status := Okl_Api.G_RET_STS_ERROR;
              Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_FN_PMTS_TOP_SUB_EXIST',
                             p_token1       => 'FEE_LINE',
                             p_token1_value => l_top_fee_ln_name);
          END IF;

          l_payment_sub_ln_cnt := l_payment_sub_ln_cnt + 1;

        END LOOP;

        FOR l_fn_fee_pmt IN l_fn_fee_pmt_csr ( chrID => p_chr_id, feeLine => l_fn_sub_ln_fee.id )
        LOOP
         /* Check if the payment end date is within in the financed
             fee sub-line's end date, if not error out. */

             -- added for bug 5115701 - start

         IF ( TRUNC(l_fn_fee_pmt.start_date) < TRUNC(l_fn_sub_ln_fee.start_date) ) THEN

                x_return_status := Okl_Api.G_RET_STS_ERROR;
              Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_FN_SLN_PMT_SD',
                             p_token1       => 'FEE_LINE',
                             p_token1_value => l_top_fee_ln_name);
          END IF;

           -- added for bug 5115701 - end

          IF ( TRUNC(l_fn_fee_pmt.end_date) > TRUNC(l_fn_sub_ln_fee.end_date) ) THEN
                x_return_status := Okl_Api.G_RET_STS_ERROR;
              Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_FN_SLN_PMT_ED',
                             p_token1       => 'FEE_LINE',
                             p_token1_value => l_top_fee_ln_name);
          END IF;

        END LOOP;
        END LOOP;

        /* Check if a financed top line fee amount is not equal to sub-line fee amount,
           if exists, if not error out. */

        IF ( (l_fn_sln_fee_amt_chk) AND (l_fn_top_ln_fee_amt <> l_fn_sub_ln_fee_amt) ) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_FN_FEE_AMT_NEQ',
                         p_token1       => 'FEE_LINE',
                         p_token1_value => l_top_fee_ln_name);
        END IF;
        l_fn_top_ln_fee_amt := 0;
        l_fn_sub_ln_fee_amt := 0;

        /* If no payments are defiend for the fee line then error out. */

        IF ((NOT l_top_ln_pmt_exist) AND (NOT l_fn_sln_fee_amt_chk)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_RQ_NO_PMTS',
                         p_token1       => 'FEE_LINE',
                         p_token1_value => l_top_fee_ln_name);

        END IF;


        /* Check if a payment is defined for EACH of the financed fee sub-lines HEADER,
           if not error out. If there are multiple payments defiend for a financed
           fee sub-line HEADER error out. */

        IF ((NOT l_top_ln_pmt_exist) AND (l_fn_sub_ln_fee_cnt >  l_payment_sub_ln_cnt)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_FN_PMTS_MISS_SLN',
                         p_token1       => 'FEE_LINE',
                         p_token1_value => l_top_fee_ln_name);
      ELSIF ((NOT l_top_ln_pmt_exist) AND (l_fn_sub_ln_fee_cnt <  l_payment_sub_ln_cnt)) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_FN_MUL_SLN_PMTS',
                         p_token1       => 'FEE_LINE',
                         p_token1_value => l_top_fee_ln_name);
        END IF;
        l_fn_sub_ln_fee_cnt  := 0;
        l_payment_sub_ln_cnt := 0;
        -- Bug 3987419
        l_top_ln_pmt_exist   := FALSE; -- Setting back to FALSE to check for next fee line.

        -- Bug 4094336
        l_fn_sln_fee_amt_chk := FALSE; -- Setting back to FALSE.

      END LOOP;

     EXCEPTION

          WHEN Okl_Api.G_EXCEPTION_ERROR THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;

            IF l_fn_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_fn_top_fee_ln_csr;
          END IF;

            IF l_fn_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_fn_sub_ln_fee_csr;
          END IF;

            IF l_fn_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_fn_fee_pmt_csr;
          END IF;

          WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
            x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

            IF l_fn_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_fn_top_fee_ln_csr;
          END IF;

            IF l_fn_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_fn_sub_ln_fee_csr;
          END IF;

            IF l_fn_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_fn_fee_pmt_csr;
          END IF;

          WHEN OTHERS THEN
            x_return_status := Okl_Api.G_RET_STS_ERROR;

            IF l_fn_top_fee_ln_csr%ISOPEN THEN
                  CLOSE l_fn_top_fee_ln_csr;
          END IF;

            IF l_fn_sub_ln_fee_csr%ISOPEN THEN
                  CLOSE l_fn_sub_ln_fee_csr;
          END IF;

            IF l_fn_fee_pmt_csr%ISOPEN THEN
                  CLOSE l_fn_fee_pmt_csr;
          END IF;

    END check_financed_fees;
    --Bug# 4996899

    ----------------------------------------------------------------------------
    --start of comments
    --API Name    : check_rollover_lines
    --Description : API called to give warning in QA checker if the contract
    --              has a rollover fee and it's start date is a future date
    --              (greater than sysdate).
    --Parameters  : IN  - p_chr_id - Contract Number
    --              OUT - x_return_status - Return Status
    --History     : 17-Nov-2004 Manu Created
    --
    --
    --end of comments
    -----------------------------------------------------------------------------
  PROCEDURE check_rollover_lines(
              x_return_status OUT NOCOPY VARCHAR2,
              p_chr_id IN NUMBER) IS

    --p_api_version VARCHAR2(4000) := '1.0';
    p_init_msg_list VARCHAR2(4000) DEFAULT Okl_Api.G_FALSE;

    l_return_status   VARCHAR2(1)           := Okl_Api.G_RET_STS_SUCCESS;
    l_in_future       BOOLEAN := FALSE;
    l_found           VARCHAR2(1);
    x_msg_count NUMBER;
    x_msg_data  VARCHAR2(256);

    /* Cursor to if the contract start date is not in the future
       (less than or equal to SYSDATE). */

    CURSOR l_k_std_csr ( chrID OKC_K_HEADERS_B.ID%TYPE ) IS
    SELECT 1
        FROM okc_k_lines_b cleb,
             okl_k_lines kle,
             okc_k_headers_b khr
        WHERE khr.id = chrID
            AND cleb.dnz_chr_id = khr.id
            AND kle.ID = cleb.ID
            AND kle.fee_type = 'ROLLOVER'
            AND TRUNC(khr.start_date) > SYSDATE
            AND    NOT EXISTS (
                         SELECT 'Y'
                     FROM   okc_statuses_b okcsts
                     WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'));

    BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;

      /* Check if the if the contract has a rollover fee and it's start date
         is not in the future date (less than or equal sysdate). */

      OPEN l_k_std_csr ( p_chr_id );
      FETCH l_k_std_csr INTO l_found;
      l_in_future := l_k_std_csr%FOUND; -- IN future
      CLOSE l_k_std_csr;

      IF( l_in_future ) THEN  -- Contract Start date in future
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          l_in_future := NULL;
          l_found := NULL;
          Okl_Api.set_message(
                     p_app_name      => G_APP_NAME,
                     p_msg_name      => 'OKL_LLA_RQ_SD_IN_FUTURE');
          RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

    EXCEPTION

       WHEN Okl_Api.G_EXCEPTION_ERROR THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;

          IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
        END IF;

       WHEN  G_EXCEPTION_HALT_VALIDATION THEN
          NULL; -- no processing necessary; validation can continue with next column

          IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
        END IF;

       WHEN OTHERS THEN
         -- store SQL error message on message stack
         Okl_Api.SET_MESSAGE(
           p_app_name        => G_APP_NAME,
           p_msg_name        => G_UNEXPECTED_ERROR,
           p_token1       => G_SQLCODE_TOKEN,
           p_token1_value    => SQLCODE,
           p_token2          => G_SQLERRM_TOKEN,
           p_token2_value    => SQLERRM);

          IF l_k_std_csr%ISOPEN THEN
            CLOSE l_k_std_csr;
        END IF;

         x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_rollover_lines;

  -- Start of comments
  --
  -- Procedure Name  : check_stream_template
  -- Description     : Bug#3931587 Validating if streams are defined
  --                 : in contract product template.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_stream_template(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    CURSOR l_lne_pmnt_csr(chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
        SELECT ls.lty_code,
               ls.name line_type,
               kle.id,
               kle.name
        FROM   OKL_K_LINES_FULL_V kle,
               OKC_LINE_STYLES_V ls,
               OKC_STATUSES_B sts
        WHERE  kle.lse_id     = ls.id
        AND    ls.lty_code    IN ('FREE_FORM1', 'FEE', 'SOLD_SERVICE')
        AND    kle.dnz_chr_id = chrid
        AND    sts.code       = kle.sts_code
        AND    sts.ste_code   NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    CURSOR l_fee_strm_csr (chrid OKL_K_HEADERS.KHR_ID%TYPE,
                           lineid OKC_K_LINES_B.ID%TYPE) IS
    SELECT itm.object1_id1
    FROM   okc_k_items itm
    WHERE  cle_id = lineid
    AND    dnz_chr_id = chrid
    AND    jtot_object1_code = 'OKL_STRMTYP';

    CURSOR l_hdr_pmnt_csr (chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
    SELECT rule.object1_id1
    FROM   okc_rule_groups_v rgp,
           okc_rules_v rule
    WHERE  rgp.id                         = rule.rgp_id
    AND    rgp.cle_id                     IS NULL
    AND    rgp.dnz_chr_id                 = chrid
    AND    rgp.rgd_code                   = 'LALEVL'
    AND    rule.rule_information_category = 'LASLH';

    l_present_yn VARCHAR(1);

    l_fee_strm_type_rec fee_strm_type_csr%ROWTYPE;
    l_strm_name_rec strm_name_csr%ROWTYPE;

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for header payment
    FOR l_hdr_pmnt_rec IN l_hdr_pmnt_csr (p_chr_id)
    LOOP

       l_present_yn :=   Okl_Streams_Util.strm_tmpt_contains_strm_type
                                   (p_khr_id  => p_chr_id,
                                    p_sty_id  => TO_NUMBER(l_hdr_pmnt_rec.object1_id1));

       IF (l_present_yn = 'N') THEN
          OPEN  strm_name_csr ( TO_NUMBER(l_hdr_pmnt_rec.object1_id1) );
          FETCH strm_name_csr INTO l_strm_name_rec;
          IF strm_name_csr%NOTFOUND THEN
             CLOSE strm_name_csr;
             RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE strm_name_csr;

          Okl_Api.set_message(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => 'LLA_QA_HDRPMNT_STRMTMPL',
                         p_token1       => 'STRM_NAME',
                         p_token1_value => l_strm_name_rec.name
                        );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR l_lne_pmnt IN l_lne_pmnt_csr(p_chr_id)
    LOOP

      FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne_pmnt.id )
      LOOP

        --murthy

        l_present_yn :=   Okl_Streams_Util.strm_tmpt_contains_strm_type
                                   (p_khr_id  => p_chr_id,
                                    p_sty_id  => TO_NUMBER(l_rl_rec1.object1_id1));

        IF (l_present_yn = 'N') THEN

          OPEN  strm_name_csr ( TO_NUMBER(l_rl_rec1.object1_id1) );
          FETCH strm_name_csr INTO l_strm_name_rec;
          IF strm_name_csr%NOTFOUND THEN
              CLOSE strm_name_csr;
              RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
          CLOSE strm_name_csr;

          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'LLA_QA_PMNT_STRM_TMPL',
                  p_token1       => 'STRM_NAME',
                  p_token1_value => l_strm_name_rec.name,
                  p_token2       => 'LINE_TYPE',
                  p_token2_value => l_lne_pmnt.line_type||'/'||l_lne_pmnt.name
                 );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

      END LOOP;

      -- Check FEE line stream
      IF (l_lne_pmnt.lty_code = 'FEE') THEN

         FOR l_fee_strm_rec IN l_fee_strm_csr (p_chr_id,
                                               l_lne_pmnt.id)
         LOOP
            l_present_yn :=   Okl_Streams_Util.strm_tmpt_contains_strm_type
                                   (p_khr_id  => p_chr_id,
                                    p_sty_id  => TO_NUMBER(l_fee_strm_rec.object1_id1));

            IF (l_present_yn = 'N') THEN

              OPEN  strm_name_csr ( l_fee_strm_rec.object1_id1 );
              FETCH strm_name_csr INTO l_strm_name_rec;
              IF strm_name_csr%NOTFOUND THEN
                  CLOSE strm_name_csr;
                  RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;
              CLOSE strm_name_csr;

              Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'LLA_QA_FEE_STRM_TMPL',
                      p_token1       => 'STRM_NAME',
                      p_token1_value => l_strm_name_rec.name,
                      p_token2       => 'LINE_TYPE',
                      p_token2_value => l_lne_pmnt.line_type||'/'||l_lne_pmnt.name
                     );
              x_return_status := Okl_Api.G_RET_STS_ERROR;
            END IF;
         END LOOP;
      END IF; -- Fee Line

    END LOOP;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    x_return_status := Okl_Api.G_RET_STS_ERROR;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;

  END check_stream_template;

  -- Start of comments
  --
  -- Procedure Name  : check_residual_value
  -- Description     : Bug#4186455
  --                 : Throws a message if asset residual value is less than 20%
  --                 : and tax owner for the contract is LESSOR. The message
  --                 : is conifgurable to error or warning.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_residual_value(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
  l_tax_owner VARCHAR2(100);

  --Bug# 4631549
  l_release_contract_yn VARCHAR2(1);
  l_oec                 NUMBER;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
    l_tax_owner := l_hdrrl_rec.RULE_INFORMATION1;

    --Bug# 4631549
    l_release_contract_yn := okl_api.g_false;
    l_release_contract_yn := okl_lla_util_pvt.check_release_contract(p_chr_id => p_chr_id);

    FOR l_lne IN l_lne_csr('FREE_FORM1', p_chr_id)
    LOOP

      --Bug# 4631549
      If l_release_contract_yn = okl_api.g_true then
          l_oec := l_lne.expected_asset_cost;
      else
          l_oec := l_lne.oec;
      end if;

      --Bug# 4631549
      IF (( nvl(l_lne.residual_value,0) < (0.2 * l_OEC)) AND (l_tax_owner = 'LESSOR')) THEN
      --IF (( NVL(l_lne.residual_value,0) < (0.2 * l_lne.OEC)) AND (l_tax_owner = 'LESSOR')) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_RV_OEC_TOWN',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;

    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;

  END check_residual_value;

  -- Start of comments
  --
  -- Procedure Name  : check_product_status
  -- Description     : Bug#4622438 checking product status
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_product_status(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

           CURSOR chk_product_status (p_chr_id IN NUMBER) IS
             SELECT
              pdt.name
              ,pdt.PRODUCT_STATUS_CODE
        FROM  okl_products_v    pdt
              ,okl_k_headers_v  khr
              ,okc_k_headers_b  CHR
        WHERE  1=1
        AND    khr.id = p_chr_id
        AND    pdt_id = pdt.id
        AND    khr.id = CHR.id;

        l_product_status_code okl_products_v.PRODUCT_STATUS_CODE%TYPE;
        l_product_name  okl_products_v.NAME%TYPE;
  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check for header payment
    OPEN chk_product_status (p_chr_id => TO_NUMBER(p_chr_id));
    FETCH chk_product_status INTO l_product_name,l_product_status_code;
    CLOSE chk_product_status;

    IF (l_product_status_code = 'INVALID') THEN
   --   x_return_status := OKL_API.G_RET_STS_SUCCESS;

        Okl_Api.set_message(
            p_app_name    => G_APP_NAME,
            p_msg_name    => 'OKL_LLA_INVALID_PRODUCT',
            p_token1    => 'PRODUCT_NAME',
            p_token1_value    => l_product_name);
        x_return_status := Okl_Api.G_RET_STS_ERROR;

    END IF;
    /*IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;*/



  EXCEPTION

  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF chk_product_status%ISOPEN THEN
         CLOSE chk_product_status;
       END IF;


  END check_product_status;

  -- Start of comments
  --
  -- Procedure Name  : check_loan_payment
  -- Description     : Bug#7271259 checking loan payment
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_loan_payment(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

       CURSOR chk_deal_type (p_chr_id IN NUMBER) IS
       select 'Y'
       from okl_k_headers
       where id = p_chr_id
       and deal_type = 'LOAN';

       CURSOR get_payment_lns (p_chr_id IN NUMBER) IS
       SELECT rgp.id,rgp.cle_id
       FROM OKC_RULE_GROUPS_B rgp,
            OKC_RULES_B crl2,
            okc_k_lines_b cleb,
            OKL_STRM_TYPE_B stty
       WHERE stty.id = crl2.object1_id1
       AND stty.stream_type_purpose = 'RENT'
       AND rgp.id = crl2.rgp_id
       AND crl2.RULE_INFORMATION_CATEGORY = 'LASLH'
       AND rgp.rgd_code = 'LALEVL'
       and rgp.dnz_chr_id = cleb.dnz_chr_id
       AND cleb.dnz_chr_id = p_chr_id
       AND cleb.id = rgp.cle_id
       AND rgp.cle_id is not null
       AND cleb.lse_id = 33
       AND NOT EXISTS (
                 SELECT 'Y'
                 FROM   okc_statuses_v okcsts
                 WHERE  okcsts.code = cleb.sts_code
                 AND    okcsts.ste_code IN ('EXPIRED','HOLD','CANCELLED','TERMINATED', 'ABANDONED'));

       CURSOR get_line_amt (p_id IN NUMBER) IS
        SELECT  nvl(capital_amount,0)  capital_amount, kle.name name
        FROM  okl_k_lines_full_v kle
        WHERE  kle.id = p_id;

       CURSOR get_payment_line_amt (p_rgp_id IN NUMBER, p_chr_id IN NUMBER) IS
    select nvl(sum(tot_amt),0)
        from(
          SELECT to_number((NVL(crl2.rule_information3,0) * NVL(crl2.rule_information6,0))) tot_amt
          FROM   OKC_RULES_B crl1,
             OKC_RULES_B crl2
          WHERE  crl1.id = crl2.object2_id1
          AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
          AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
          AND crl1.dnz_chr_id = p_chr_id
          AND crl2.dnz_chr_id = p_chr_id
          AND crl1.rgp_id = p_rgp_id
      AND crl2.rgp_id = p_rgp_id
      union all
          SELECT
          to_number(nvl(crl2.rule_information8,0))  tot_amt
          FROM   OKC_RULES_B crl1,
             OKC_RULES_B crl2
          WHERE crl1.id = crl2.object2_id1
          AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
          AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
          AND crl1.dnz_chr_id = p_chr_id
          AND crl2.dnz_chr_id = p_chr_id
          AND crl1.rgp_id = p_rgp_id
      AND crl2.rgp_id = p_rgp_id
    );

        l_cle_id NUMBER;
        l_chr_id NUMBER;
        l_capital_amount okl_k_lines.capital_amount%type;
        l_ast_name okl_k_lines_full_v.name%type := null;
        l_payment_amount okl_k_lines.capital_amount%type;
        l_deal_type_yn varchar2(1) := 'N';
  BEGIN
    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    --chk_deal_type for loan contract
    OPEN chk_deal_type (p_chr_id);
    FETCH chk_deal_type INTO l_deal_type_yn;
    CLOSE chk_deal_type;

    IF (l_deal_type_yn = 'Y') THEN

     FOR l_lne IN get_payment_lns(p_chr_id)
      LOOP

     -- check for line payment
     OPEN get_line_amt (l_lne.cle_id);
     FETCH get_line_amt INTO l_capital_amount,l_ast_name;
     CLOSE get_line_amt;

     -- check for payment line payment
     OPEN get_payment_line_amt (l_lne.id, p_chr_id);
     FETCH get_payment_line_amt INTO l_payment_amount;
     CLOSE get_payment_line_amt;

     IF(l_payment_amount < l_capital_amount) THEN
        Okl_Api.set_message(
            p_app_name    => G_APP_NAME,
            p_msg_name    => 'OKL_LLA_INVALID_PAYMNT_AMT',
            p_token1    => 'AST_NUMBER',
            p_token1_value    => l_ast_name);
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

   END LOOP;

  END IF;

  EXCEPTION

  WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_loan_payment;

  --akrangan bug 5362977 start
 -- Start of comments
     --
     -- Procedure Name  : check_service_contracts
     -- Description     : Displays a error message if the IB instance that is
     --                   going to be expired during Rebook has Service
     --                   contracts associated to it.
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments

     PROCEDURE check_service_contracts(
       x_return_status            OUT NOCOPY VARCHAR2,
       p_chr_id                   IN  NUMBER
     ) IS

       --cursor to check if the contract is undergoing on-line rebook
       cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
       SELECT '!',
              orig_system_id1
       FROM   okc_k_headers_b CHR,
              okl_trx_contracts ktrx
       WHERE  ktrx.khr_id_new = chr.id
       AND    ktrx.tsu_code = 'ENTERED'
       AND    ktrx.rbr_code is NOT NULL
       AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP
       AND    ktrx.representation_type = 'PRIMARY'
--
       AND    chr.id = p_chr_id
       AND    chr.orig_system_source_code = 'OKL_REBOOK';

       l_rbk_khr      VARCHAR2(1) DEFAULT '?';
       l_orig_chr_id  NUMBER;

       CURSOR l_line_csr (p_chr_id IN NUMBER) IS
       SELECT model_cle.id                rbk_model_cle_id,
              model_cle.orig_system_id1   orig_model_cle_id,
              fin_ast_cle.id              rbk_fin_ast_cle_id,
              fin_ast_cle.orig_system_id1 orig_fin_ast_cle_id,
              fin_ast_cle.name            asset_number
       FROM   okc_k_lines_b  model_cle,
              okc_k_lines_v  fin_ast_cle,
              okc_statuses_b sts
       WHERE  fin_ast_cle.chr_id     =  p_chr_id
       AND    fin_ast_cle.dnz_chr_id =  p_chr_id
       AND    fin_ast_cle.lse_id   = 33 -- Financial Asset Line
       AND    model_cle.dnz_chr_id = p_chr_id
       AND    model_cle.cle_id     = fin_ast_cle.id
       AND    model_cle.lse_id     = 34  --Model Line
       and    sts.code = fin_ast_cle.sts_code
       and    sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

       CURSOR l_ib_line_csr (p_chr_id IN NUMBER,
                             p_fin_ast_cle_id IN NUMBER
                              ) IS
       SELECT ib_cim.object1_id1  instance_id
       FROM   okc_k_lines_b  ib_cle,
              okc_k_lines_b  inst_cle,
              okc_statuses_b sts,
              okc_k_items    ib_cim
       WHERE  inst_cle.dnz_chr_id   = p_chr_id
       AND    inst_cle.cle_id       = p_fin_ast_cle_id
       AND    inst_cle.lse_id       = 43 -- FREE_FORM2 Line
       AND    ib_cle.dnz_chr_id     = p_chr_id
       AND    ib_cle.cle_id         = inst_cle.id
       AND    ib_cle.lse_id         = 45  --IB Line
       AND    ib_cim.cle_id         = ib_cle.id
       AND    ib_cim.dnz_chr_id     = p_chr_id
       AND    sts.code = ib_cle.sts_code
       AND    sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

       CURSOR l_item_csr(p_chr_id   IN NUMBER,
                         p_cle_id   IN NUMBER) IS
       SELECT cim.object1_id1,
              cim.object1_id2,
              cim.number_of_items
       FROM   okc_k_items cim
       WHERE  cim.cle_id = p_cle_id
       AND    cim.dnz_chr_id = p_chr_id;

       l_rbk_item_rec   l_item_csr%ROWTYPE;
       l_orig_item_rec  l_item_csr%ROWTYPE;

       CURSOR srl_num_to_exp_csr(p_orig_fin_ast_cle_id IN NUMBER,
                                 p_rbk_fin_ast_cle_id  IN NUMBER,
                                 p_orig_chr_id         IN NUMBER,
                                 p_rbk_chr_id          IN NUMBER) IS
       SELECT orig_ib_cim.object1_id1 instance_id
       FROM   okc_k_items         orig_ib_cim,
              okc_k_lines_b       orig_ib_cle,
              okc_k_lines_b       orig_inst_cle,
              okc_statuses_b      inst_sts
       WHERE orig_inst_cle.dnz_chr_id = p_orig_chr_id
       AND   orig_inst_cle.cle_id = p_orig_fin_ast_cle_id
       AND   orig_inst_cle.lse_id = 43
       AND   orig_ib_cle.cle_id = orig_inst_cle.id
       AND   orig_ib_cle.dnz_chr_id =  p_orig_chr_id
       AND   orig_ib_cle.lse_id = 45
       AND   orig_ib_cim.cle_id = orig_ib_cle.id
       AND   orig_ib_cim.dnz_chr_id = p_orig_chr_id
       AND   orig_ib_cim.object1_id1 IS NOT NULL
       AND   inst_sts.code = orig_ib_cle.sts_code
       AND   inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED')
       AND   NOT EXISTS (
              SELECT 1
              FROM okc_k_lines_b  rbk_inst_cle,
                   okc_statuses_b rbk_inst_sts
              WHERE rbk_inst_cle.orig_system_id1  = orig_inst_cle.id
              AND   rbk_inst_cle.lse_id = 43
              AND   rbk_inst_cle.dnz_chr_id = p_rbk_chr_id
              AND   rbk_inst_cle.cle_id = p_rbk_fin_ast_cle_id
              AND   rbk_inst_sts.code = rbk_inst_cle.sts_code
              AND   rbk_inst_sts.ste_code NOT IN ('HOLD', 'EXPIRED', 'TERMINATED', 'CANCELLED'));

       CURSOR check_svc_chr(p_object1_id1 IN VARCHAR2,
                            p_jtot_object_code IN VARCHAR2) IS
       SELECT svc_cle.dnz_chr_id
       FROM okc_k_lines_b   svc_cle,
            okc_k_items     svc_item,
            okc_statuses_b  sts,
            okc_k_headers_b svc_chr
       WHERE  svc_item.object1_id1 = p_object1_id1
       AND    svc_item.jtot_object1_code =  p_jtot_object_code
       AND    svc_cle.id = svc_item.cle_id
       AND    svc_cle.dnz_chr_id = svc_item.dnz_chr_id
       AND    svc_cle.sts_code = sts.code
       AND    sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
       AND    svc_chr.id       = svc_cle.dnz_chr_id
       AND    svc_chr.scs_code = 'SERVICE';

       CURSOR check_usage_svc_chr(p_instance_id IN NUMBER,
                                  p_jtot_object_code IN VARCHAR2,
                                  p_source_object_code IN VARCHAR2) IS
       SELECT svc_cle.dnz_chr_id
       FROM   okc_k_lines_b   svc_cle,
              okc_k_items     svc_item,
              okc_statuses_b  sts,
              okc_k_headers_b svc_chr,
              cs_counter_groups csg,
              cs_counters cc
       WHERE  svc_item.object1_id1 = TO_CHAR(cc.counter_id)
       AND    svc_item.jtot_object1_code =  p_jtot_object_code
       AND    svc_cle.id = svc_item.cle_id
       AND    svc_cle.dnz_chr_id = svc_item.dnz_chr_id
       AND    svc_cle.sts_code = sts.code
       AND    sts.ste_code NOT IN ('HOLD','EXPIRED','CANCELLED','TERMINATED')
       AND    svc_chr.id = svc_cle.dnz_chr_id
       AND    svc_chr.scs_code = 'SERVICE'
       AND    csg.source_object_id = p_instance_id
       AND    csg.source_object_code = p_source_object_code
       AND    csg.counter_group_id = cc.counter_group_id;

       i NUMBER;
       TYPE l_instance_tbl_type IS TABLE OF VARCHAR(40) INDEX BY BINARY_INTEGER;
       l_instance_tbl l_instance_tbl_type;

       l_svc_chr_id NUMBER;
       l_svc_chr_exists VARCHAR2(1);
     BEGIN

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       --check for rebook contract
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr,l_orig_chr_id;
       CLOSE l_chk_rbk_csr;

       If l_rbk_khr = '!' Then

         l_svc_chr_exists := 'N';

         For l_line_rec In l_line_csr(p_chr_id => p_chr_id)
         Loop

           OPEN l_item_csr (p_chr_id => p_chr_id,
                            p_cle_id => l_line_rec.rbk_model_cle_id);
           FETCH l_item_csr INTO l_rbk_item_rec;
           CLOSE l_item_csr;

           OPEN l_item_csr (p_chr_id => l_orig_chr_id,
                            p_cle_id => l_line_rec.orig_model_cle_id);
           FETCH l_item_csr INTO l_orig_item_rec;
           CLOSE l_item_csr;

           -- Check for associated service contracts if:
           --   1. the Inventory Item has changed
           --   2. the Item is serialized and IB lines have been removed.
           IF (l_orig_item_rec.object1_id1 <> l_rbk_item_rec.object1_id1) THEN

             i := 1;
             FOR l_ib_line_rec in l_ib_line_csr(p_chr_id => l_orig_chr_id,
                                                p_fin_ast_cle_id => l_line_rec.orig_fin_ast_cle_id)
             LOOP
               l_instance_tbl(i) := l_ib_line_rec.instance_id;
               i := i + 1;
             END LOOP;

           ELSE
             i := 1;
             FOR srl_num_to_exp_rec IN
                 srl_num_to_exp_csr(p_orig_fin_ast_cle_id => l_line_rec.orig_fin_ast_cle_id,
                                    p_rbk_fin_ast_cle_id  => l_line_rec.rbk_fin_ast_cle_id,
                                    p_orig_chr_id         => l_orig_chr_id,
                                    p_rbk_chr_id          => p_chr_id) LOOP

               l_instance_tbl(i) := srl_num_to_exp_rec.instance_id;
               i := i + 1;

             END LOOP;
           END IF;

           IF l_instance_tbl.COUNT > 0 THEN
             FOR i IN l_instance_tbl.FIRST .. l_instance_tbl.LAST LOOP

               l_svc_chr_id := NULL;
               -- Check for Service Contracts
               OPEN check_svc_chr(p_object1_id1      => l_instance_tbl(i)
                                 ,p_jtot_object_code => 'OKX_CUSTPROD');
               FETCH check_svc_chr INTO l_svc_chr_id;
               CLOSE check_svc_chr;

               IF l_svc_chr_id IS NULL THEN
                 -- Check for Usage based Service Contracts
                 OPEN check_usage_svc_chr(p_instance_id        => TO_NUMBER(l_instance_tbl(i))
                                         ,p_jtot_object_code   => 'OKX_COUNTER'
                                         ,p_source_object_code => 'CP');
                 FETCH check_usage_svc_chr INTO l_svc_chr_id;
                 CLOSE check_usage_svc_chr;
               END IF;

               IF l_svc_chr_id IS NOT NULL THEN
                 l_svc_chr_exists := 'Y';
                 EXIT;
               END IF;

             END LOOP;
           END IF;

           IF l_svc_chr_exists = 'Y' THEN
             OKL_API.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_CANNOT_DEL_IB_INST',
                    p_token1       => 'ASSET_NUMBER',
                    p_token1_value => l_line_rec.asset_number);
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT;
           END IF;

         End Loop;
       End If;

     EXCEPTION
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       OKL_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1                => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

     END check_service_contracts;
--akrangan  bug 5362977 end

  -- Start of comments
  --
  -- Procedure Name  : check_sales_quote
  -- Description     : Bug#4419339 sales quote validations
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_sales_quote(
                               x_return_status            OUT NOCOPY VARCHAR2,
                               p_chr_id                   IN  NUMBER
                               ) IS
  CURSOR l_hdr_csr IS
  SELECT tradein_amount
  FROM   okl_k_headers_v
  WHERE  id = p_chr_id;
  l_hdr_rec l_hdr_csr%ROWTYPE;

  CURSOR l_line_csr IS
  SELECT cle.id,
         cle.name,
         kle.tradein_amount,
         capital_reduction,
         capitalize_down_payment_yn,
     -- Bug 6417667 Start
     kle.capital_reduction_percent,
     kle.oec
     -- Bug 6417667 End
         --down_payment_yes_no
  FROM
         okl_k_lines kle,
         okc_k_lines_v cle,
         okc_line_styles_b sty,
         okc_statuses_b sts
  WHERE  cle.id = kle.id
  AND    dnz_chr_id = p_chr_id
  AND    cle.lse_id = sty.id
  AND    sty.lty_code = 'FREE_FORM1'
  AND    cle.sts_code = sts.code
  AND    sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  CURSOR l_down_pmnt_check_csr(p_cle_id OKC_K_LINES_B.ID%TYPE)  IS
  SELECT crg.cle_id,
         crl.id,
         crl.object1_id1,
         crl.RULE_INFORMATION6
  FROM   OKC_RULE_GROUPS_B crg,
         OKC_RULES_B crl,
         OKL_STRM_TYPE_B stty
  WHERE  stty.id = crl.object1_id1
  AND stty.stream_type_purpose = 'DOWN_PAYMENT'
  AND crl.rgp_id = crg.id
  AND crg.RGD_CODE = 'LALEVL'
  AND crl.RULE_INFORMATION_CATEGORY = 'LASLH'
  AND crg.cle_id = p_cle_id
  AND crg.dnz_chr_id = p_chr_id;
  l_down_pmnt_check_rec l_down_pmnt_check_csr%ROWTYPE;

  CURSOR l_down_pmnt_line_csr(p_id OKC_RULES_B.ID%TYPE, p_cle_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT crl2.object1_id1,
         crl2.object1_id2,
         crl2.rule_information2,
         NVL(crl2.rule_information3,0) rule_information3,
         NVL(crl2.rule_information6,0) rule_information6
  FROM   OKC_RULES_B crl1, OKC_RULES_B crl2, OKC_RULE_GROUPS_B rgp
  WHERE crl1.id = crl2.object2_id1
  AND crl1.id = p_id
  AND rgp.cle_id = p_cle_id
  AND rgp.id = crl1.rgp_id
  AND crl2.RULE_INFORMATION_CATEGORY = 'LASLL'
  AND crl1.RULE_INFORMATION_CATEGORY = 'LASLH'
  AND crl1.dnz_chr_id = p_chr_id
  AND crl2.dnz_chr_id = p_chr_id;

  l_asset_tradein_yes BOOLEAN;
  l_exists BOOLEAN;
  l_asset_tradein_amt NUMBER;
  l_hdr_tradein_amt   NUMBER;
  l_num_pmnt_lines    NUMBER;
  -- Start fix for bug 7131895
  l_pricing_engine    VARCHAR2(30);
  l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
  l_tax_owner VARCHAR2(100);
  l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
  -- End fix for bug 7131895

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;
    l_asset_tradein_yes := FALSE;
    l_asset_tradein_amt := 0;

    l_hdr_tradein_amt := NULL;
    OPEN l_hdr_csr;
    FETCH l_hdr_csr INTO l_hdr_rec;
    l_hdr_tradein_amt := l_hdr_rec.tradein_amount;
    CLOSE l_hdr_csr;
    -- Start fix for bug 7131895
    OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;
    l_tax_owner := l_hdrrl_rec.RULE_INFORMATION1;
    -- End fix for bug 7131895

    IF (l_hdr_tradein_amt IS NULL) THEN
        l_asset_tradein_yes := TRUE;
    END IF;

    FOR l_line_rec IN l_line_csr
    LOOP
      IF (l_line_rec.tradein_amount IS NOT NULL) THEN
        l_asset_tradein_yes := TRUE;
        l_asset_tradein_amt := l_asset_tradein_amt + l_line_rec.tradein_amount;
      END IF;

    --Bug 6417667 Start
    IF (l_line_rec.capital_reduction IS NOT NULL
     OR l_line_rec.capital_reduction_percent IS NOT NULL) THEN  -- Added for bug 5473440
    --Bug 6417667 End
      IF (l_line_rec.capitalize_down_payment_yn = 'N') THEN

        --check payment line existence with one period having the entire capital_reduction
        --in that payment. that is the amounts must be equal.
        OPEN l_down_pmnt_check_csr(l_line_rec.id);
        FETCH l_down_pmnt_check_csr INTO l_down_pmnt_check_rec;
        l_exists := l_down_pmnt_check_csr%FOUND;
        CLOSE l_down_pmnt_check_csr;

        IF (NOT l_exists) THEN
          --RAISE ERROR no down payments exist.
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SQ_NO_DOWN_PMNT');
          x_return_status := Okl_Api.G_RET_STS_ERROR;

        END IF;

        IF ( l_down_pmnt_check_rec.cle_id IS NULL) THEN
          --RAISE ERROR cannot define at contract header level.
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SQ_DOWN_PMNT_HDR');
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

        l_num_pmnt_lines := 0;

        FOR l_down_pmnt_line_rec IN l_down_pmnt_line_csr(l_down_pmnt_check_rec.id, l_line_rec.id)
        LOOP
          --check for number of payments also.

          l_num_pmnt_lines := l_num_pmnt_lines + 1;
          IF(l_down_pmnt_line_rec.rule_information3 <> 1) THEN
            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SQ_PERIOD_MISMATCH');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

          --Bug 6417667 Start
          --Bug# 8652738: Added ROUND() for forward port of Bug 7601328
      -- Not using NVL function because Down payment amount or percent value can be zero.
      IF((l_line_rec.capital_reduction IS NOT NULL AND l_line_rec.capital_reduction <> l_down_pmnt_line_rec.rule_information6)
           OR (l_line_rec.capital_reduction_percent IS NOT NULL AND ROUND(((l_line_rec.capital_reduction_percent/100)*l_line_rec.oec),2) <> l_down_pmnt_line_rec.rule_information6)) THEN
      --Bug 6417667 End
            Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SQ_DOWN_PMNT_MISMATCH');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

        END LOOP;

        IF (l_num_pmnt_lines > 1) THEN
         --RAISE ERROR cannot have more than one down payment line.
         Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_SQ_DOWN_PMNT_LN_GT1');
         x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

      ELSE -- Capitalize Flag = 'Y', Start fix for bug 7131895
        Okl_Streams_Util.get_pricing_engine(p_khr_id => p_chr_id,
                                            x_pricing_engine => l_pricing_engine,
                                            x_return_status => l_return_status);
        IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
          x_return_status := l_return_status;
          RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;

        --RAISE ERROR if pricing engine is 'EXTERNAL' and tax owner='LESSOR'
    IF ((l_pricing_engine = 'EXTERNAL') AND (l_tax_owner ='LESSOR')) THEN
            Okl_Api.set_message(
                    p_app_name     => G_APP_NAME,
                    p_msg_name     => 'OKL_QA_SQ_DOWN_PMNT_TAXOWNER');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
    -- End fix for bug 7131895
        --if payment existence throw error
        OPEN l_down_pmnt_check_csr(l_line_rec.id);
        FETCH l_down_pmnt_check_csr INTO l_down_pmnt_check_rec;
        l_exists := l_down_pmnt_check_csr%FOUND;
        CLOSE l_down_pmnt_check_csr;

        IF (l_exists) THEN
          --RAISE ERROR no payment required for non capitalized assets.
          Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_SQ_CAPITALIZED_AST');
          x_return_status := Okl_Api.G_RET_STS_ERROR;

        END IF;

      END IF;

    END IF; --Added for bug#5473440

    END LOOP;

    IF(l_hdr_tradein_amt IS NOT NULL) THEN
     IF (l_asset_tradein_amt <> l_hdr_tradein_amt) THEN
      Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_SQ_TRADEIN_AMT');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
     END IF;
    END IF;

    IF (NOT l_asset_tradein_yes) THEN
      Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_SQ_TRADEIN_ASSOC');
      x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_line_csr%ISOPEN THEN
      CLOSE l_line_csr;
    END IF;

  END check_sales_quote;

  -- Start of comments
  --
  -- Procedure Name  : check_functional_constraints
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_func_constrs_4new(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);


    --Bug#3877032
    CURSOR l_contract_name ( n VARCHAR2 ) IS
    SELECT 'Y'
    --Select count(*) cnt
    FROM okc_k_headers_b WHERE contract_number = n;
    l_cn l_contract_name%ROWTYPE;


    l_hdr     l_hdr_csr%ROWTYPE;
    l_txl     l_txl_csr%ROWTYPE;
    l_txd     l_txd_csr%ROWTYPE;
    l_lne     l_lne_csr%ROWTYPE;
    l_itm     l_itms_csr%ROWTYPE;
    l_struct_rec l_struct_csr%ROWTYPE;
    l_structure  NUMBER;
    l_rl_rec1 l_rl_csr1%ROWTYPE;
    i NUMBER;


    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_supp_rec supp_csr%ROWTYPE;

    l_asst asst_qty_csr%ROWTYPE;
    l_ib_qty   NUMBER;

    --Bug#3877032
    CURSOR l_rpt_csr( bk VARCHAR2, dat DATE ) IS
    SELECT 'Y'
       FROM   fa_book_controls
       WHERE  book_class = 'TAX'
       --and  nvl(initial_date,dat) <= dat Bug#3636801
       AND  NVL(date_ineffective,dat+1) > dat
       AND  book_type_code = bk;

    l_rpt_rec l_rpt_csr%ROWTYPE;
    l_report_tax_book VARCHAR2(256);

    CURSOR party_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE,
                      p_cle_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT object1_id1
    FROM   okc_k_party_roles_b
    WHERE  dnz_chr_id        = p_chr_id
    AND    cle_id            = p_cle_id
    AND    jtot_object1_code = 'OKX_VENDOR';

    CURSOR passthru_site_csr (p_vendor_id OKX_VENDOR_SITES_V.VENDOR_ID%TYPE,
                              p_site_id   OKX_VENDOR_SITES_V.ID1%TYPE) IS
    SELECT 'Y'
    FROM   okx_vendor_sites_v
    WHERE  id1            = p_site_id
    AND    vendor_id      = p_vendor_id
    AND    status         = 'A'
    AND    TRUNC(SYSDATE) >= NVL(TRUNC(start_date_active), TRUNC(SYSDATE));

    CURSOR line_amt_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE,
                         p_lty_code OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT line.id,
           line.line_number,
           line.amount
    FROM   okl_k_lines_full_v line,
           okc_line_styles_v style,
           okc_statuses_b sts
    WHERE  line.lse_id     = style.id
    AND    style.lty_code  = p_lty_code
    AND    sts.code        = line.sts_code
    AND    sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
    AND    line.dnz_chr_id = p_chr_id;

    CURSOR sub_line_amt_csr (p_line_id OKC_K_LINES_B.ID%TYPE) IS
    SELECT SUM(NVL(capital_amount,0))
    FROM   okl_k_lines_full_v line
    WHERE  line.cle_id = p_line_id;

    CURSOR txd_csr1 (Kleid NUMBER) IS
    SELECT
          sgn.value book_type,
          COUNT(*) book_count
    FROM  Okl_txd_assets_v txd,
          okl_txl_assets_b txl,
          okl_sgn_translations sgn
    WHERE txd.tal_id            = txl.id
    AND   txl.kle_id            = Kleid
    AND   sgn.jtot_object1_code = 'FA_BOOK_CONTROLS'
    AND   sgn.object1_id1       = txd.tax_book
    AND   sgn.sgn_code          = 'STMP'                -- Bug# 3533552
    GROUP BY sgn.value;

    l_tot_sub_line_amt NUMBER;

    l_passthru_site_id   OKC_RULES_B.OBJECT1_ID1%TYPE;
    l_passthru_vendor_id OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE;
    l_site_valid         VARCHAR2(1) := '?';
    l_passthru_present   VARCHAR2(1) := 'N';

    lx_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(1000);
    --l_tax_owner         VARCHAR2(100);

    --------------
    --Bug# 4103361
    --------------
    -- cursor to check valid combination of asset book and category
    CURSOR l_bk_cat_csr(p_cat_id IN NUMBER,
                        p_book_type_code IN VARCHAR2) IS
    SELECT 'Y'
    FROM    OKX_AST_CAT_BKS_V
    WHERE   category_id     = p_cat_id
    AND     book_type_code  = p_book_type_code;

    l_valid_bk_cat   VARCHAR2(1);

    --------------
    --Bug# 7131806
    --------------
    -- cursor to check valid corporate book tied to the ledger
    CURSOR l_corpbook_csr(p_book_type_code IN VARCHAR2) IS
    SELECT 'Y'
    FROM FA_BOOK_CONTROLS fa,
         OKL_SYS_ACCT_OPTS sys
    WHERE book_class='CORPORATE'
    AND   fa.set_of_books_id = sys.set_of_books_id
    AND   book_type_code  = p_book_type_code;

    l_valid_corpbook   VARCHAR2(1);

    --cursor to fetch category name for message token
    CURSOR l_fa_cat_csr(p_cat_id IN NUMBER) IS
    SELECT name
    FROM   okx_asst_catgrs_v
    WHERE  category_id   = p_cat_id;

    l_fa_cat_name  okx_asst_catgrs_v.name%TYPE;

    --------------
    --Bug# 4103361
    --------------

    --------------
    --Bug# 4350255
    --------------
    CURSOR pth_hdr_csr(p_chr_id IN NUMBER,
                       p_cle_id IN NUMBER) IS
    SELECT 1
    FROM   okl_party_payment_hdr pph
    WHERE  cle_id = p_cle_id
    AND    dnz_chr_id = p_chr_id;

    l_pth_present VARCHAR2(1);

    CURSOR pth_dtl_csr(p_chr_id IN NUMBER,
                       p_cle_id IN NUMBER) IS
    SELECT ppd.vendor_id,
           ppd.pay_site_id,
           pph.passthru_term
    FROM   okl_party_payment_hdr pph,
           okl_party_payment_dtls ppd
    WHERE  pph.cle_id = p_cle_id
    AND    pph.dnz_chr_id = p_chr_id
    AND    ppd.payment_hdr_id = pph.id;

    l_vendor_id OKC_K_PARTY_ROLES_B.OBJECT1_ID1%TYPE;

    CURSOR vendor_csr(p_vendor_id IN NUMBER) IS
    SELECT vendor_name
    FROM   po_vendors
    WHERE  vendor_id = p_vendor_id;

    l_vendor_name po_vendors.vendor_name%TYPE;


    CURSOR l_kle_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
    SELECT NVL(kle.name,kle.item_description) name,
       kle.id,
           ls.name line_style
    FROM OKL_K_LINES_FULL_V kle,
         OKC_LINE_STYLES_v ls,
     OKC_STATUSES_B sts
     WHERE kle.lse_id = ls.id
     AND ls.lty_code = ltycode
     AND kle.dnz_chr_id = chrid
     AND sts.code = kle.sts_code
     AND sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    --------------
    --Bug# 4350255
    --------------

    --Bug# 4631549
    l_release_contract_yn varchar2(1);
    l_oec number;

    -- Bug 5216135 : kbbhavsa : 29-May-06 : start
    -- cursor to fecth link line id for top line id
    CURSOR l_kle_link_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE, cleid OKL_K_LINES_FULL_V.CLE_ID%TYPE) IS
    SELECT kle.id
    FROM OKL_K_LINES_FULL_V kle,
         OKC_LINE_STYLES_v ls,
         OKC_STATUSES_B sts
     WHERE kle.lse_id = ls.id
     AND ls.lty_code = ltycode
     AND kle.dnz_chr_id = chrid
     AND sts.code = kle.sts_code
     AND sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
     and kle.cle_id =  cleid;

     l_link_cle_id OKL_K_LINES_FULL_V.ID%TYPE;
     -- Bug 5216135 : kbbhavsa : 29-May-06 : End

  CURSOR system_corp_book_csr(p_chr_id NUMBER) IS
  SELECT A.ASST_ADD_BOOK_TYPE_CODE,
         C.secondary_rep_method secondary_rep_method
  FROM   okl_system_params_all a,
         okc_k_headers_all_b b,
         okl_sys_acct_opts_all c
  WHERE  b.id = p_chr_id
  AND    b.authoring_org_id = a.org_id
  AND    c.org_id = a.org_id;

  l_system_corp_book okl_system_params_all.ASST_ADD_BOOK_TYPE_CODE%TYPE;
  l_secondary_rep_method okl_sys_acct_opts_all.secondary_rep_method%TYPE;

CURSOR chk_rpt_prod_id (p_chr_id IN NUMBER) IS
             SELECT
              pdt.reporting_pdt_id
        FROM  okl_products_v    pdt
              ,okl_k_headers_v  khr
              ,okc_k_headers_b  CHR
        WHERE  1=1
        AND    khr.id = p_chr_id
        AND    pdt_id = pdt.id
        AND    khr.id = CHR.id;

         l_reporting_pdt_id  okl_products_v.reporting_pdt_id%TYPE;


  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    /*Bug#4186455
    *--Bug#3877032
    *OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    *FETCH l_hdrrl_csr into l_hdrrl_rec;
    *CLOSE l_hdrrl_csr;
    *l_tax_owner := l_hdrrl_rec.RULE_INFORMATION1;
    */

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    --MGAAP 7263041
    OPEN  system_corp_book_csr(p_chr_id);
    FETCH system_corp_book_csr INTO l_system_corp_book,l_secondary_rep_method;
    IF system_corp_book_csr%NOTFOUND THEN
       CLOSE system_corp_book_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE system_corp_book_csr;

    OPEN chk_rpt_prod_id (p_chr_id);
    FETCH chk_rpt_prod_id INTO l_reporting_pdt_id;
    IF chk_rpt_prod_id%NOTFOUND THEN
       CLOSE chk_rpt_prod_id;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE chk_rpt_prod_id;

    IF (NVL(l_secondary_rep_method, '?') = 'NOT_APPLICABLE') THEN
      IF (l_reporting_pdt_id IS NOT NULL AND
          l_reporting_pdt_id <> OKL_API.G_MISS_NUM) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_RPT_MISMATCH'); -- MGAAP 7263041
            x_return_status := Okl_Api.G_RET_STS_ERROR;
            RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    /*Bug# 3670104
    *If( l_hdr.DATE_SIGNED >= l_hdr.START_DATE) Then
    *        OKL_API.set_message(
    *          p_app_name     => G_APP_NAME,
    *          p_msg_name     => 'OKL_QA_DATESIGNED_LT_START');
    *         -- notify caller of an error
    *        x_return_status := OKL_API.G_RET_STS_ERROR;
    *End If;
    */

    OPEN  l_contract_name(l_hdr.contract_number);
    FETCH l_contract_name INTO l_cn;
    IF l_contract_name%NOTFOUND THEN
       CLOSE l_contract_name;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_contract_name;

    /*
    *If( l_cn.cnt > 1) Then
    *        OKL_API.set_message(
    *          p_app_name     => G_APP_NAME,
    *          p_msg_name     => 'OKL_QA_CN_NOTUNQ');
    *         -- notify caller of an error
    *        x_return_status := OKL_API.G_RET_STS_ERROR;
    *End If;
    */


    FOR l_struct_rec IN l_struct_csr ( TO_NUMBER(p_chr_id) )
    LOOP

        IF ( l_struct_rec.structure <> -1 ) THEN
            l_structure := TO_NUMBER(l_struct_rec.structure);
        END IF;

    END LOOP;

    IF( ( l_structure > 3) AND (l_hdr.DEAL_TYPE <> 'LOAN-REVOLVING')) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_STRUCTURE_NA');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    --bug# 2753114
    IF( l_hdr.report_pdt_id <> -1 ) THEN

        l_report_tax_book := OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);

        OPEN  l_rpt_csr( l_report_tax_book, l_hdr.start_date );
        FETCH l_rpt_csr INTO l_rpt_rec;
        --Bug#3877032
        IF ( l_rpt_csr%NOTFOUND ) THEN
        --IF ( nvl(l_rpt_rec.isThere, 'N' ) = 'N' ) THEN
            Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_NO_REPTXBK');
              -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
        CLOSE l_rpt_csr;

    END IF;

    OPEN  l_lne_csr('FREE_FORM1', p_chr_id);
    FETCH l_lne_csr INTO l_lne;
    IF( (l_hdr.DEAL_TYPE = 'LOAN-REVOLVING') AND l_lne_csr%FOUND AND (l_hdr.report_pdt_id = -1) ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ASST_LNR');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        CLOSE l_lne_csr;
            RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF( (l_hdr.DEAL_TYPE <> 'LOAN-REVOLVING') AND l_lne_csr%NOTFOUND ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_ASSETS');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_lne_csr;

    --Bug# 4631549
    l_release_contract_yn := okl_api.g_false;
    l_release_contract_yn := okl_lla_util_pvt.check_release_contract(p_chr_id => p_chr_id);

    FOR l_lne IN l_lne_csr('FREE_FORM1', p_chr_id)
    LOOP

/* -- not checking for asset number uniquesness. Re-Book !!!
      OPEN  l_line_name(l_lne.name);
      FETCH l_line_name into l_ln;
      IF l_line_name%NOTFOUND THEN
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      CLOSE l_line_name;

      If( l_ln.cnt > 1) Then
              OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_AN_NOTUNQ');
               -- notify caller of an error
              x_return_status := OKL_API.G_RET_STS_ERROR;
      End If;

*/

      --Bug# 4631549
     If l_release_contract_yn = okl_api.g_true then
         l_oec := l_lne.expected_asset_cost;
     else
         l_oec := l_lne.oec;
     end if;

      --Bug# 4631549
      IF ( l_lne.RESIDUAL_VALUE > l_OEC ) Then
      --IF ( l_lne.RESIDUAL_VALUE > l_lne.OEC ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_RES_GT_OEC',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;

      --Bug# 4631549
      If ( l_lne.CAPITAL_REDUCTION > l_OEC) Then
      --IF ( l_lne.CAPITAL_REDUCTION > l_lne.OEC) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_CAPRED_LT_OEC',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;
      --Bug# 4631549
      If ( l_lne.TRADEIN_AMOUNT > l_OEC) Then
      --IF ( l_lne.TRADEIN_AMOUNT > l_lne.OEC) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_TRADN_LT_CAP',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;

      IF (( UPPER(l_lne.residual_code) = 'NONE') AND (l_lne.residual_grnty_amount IS NOT NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_RESIDUAL_GRNTY',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;

      IF ((INSTR( l_hdr.DEAL_TYPE, 'OP' )>0) AND ( l_lne.RVI_PREMIUM IS NOT NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OP_NORVINSU',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;

      i := 0;
      IF ( l_structure > 0 ) THEN
          FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), l_lne.id )
          LOOP
              IF( l_rl_rec1.rule_information2 IS NOT NULL) THEN
                  i := i + 1;
              END IF;
          END LOOP;
          IF (i > 1) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_GT_ONE_PMT',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
            x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;
      END IF;

      OPEN asst_qty_csr(FinAsstId => l_lne.id);
      FETCH asst_qty_csr INTO l_asst;
      CLOSE asst_qty_csr;

      IF ((INSTR( l_hdr.DEAL_TYPE, 'OP' )>0) OR
          (INSTR( l_hdr.DEAL_TYPE, 'DF' )>0)) OR
          (l_hdr.DEAL_TYPE = 'LEASEST')  THEN

          OPEN  l_txl_csr(l_asst.fa_id);
          FETCH l_txl_csr INTO l_txl;
          IF l_txl_csr%NOTFOUND THEN
              CLOSE l_txl_csr;
              Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_NO_DEPRECIATION',
                      p_token1       => 'line',
                      p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          CLOSE l_txl_csr;

          IF( l_txl.fa_location_id IS NULL ) THEN
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_FA_LOCATION',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

          OPEN  l_txd_csr(l_asst.fa_id);
          FETCH l_txd_csr INTO l_txd;
          IF l_txd_csr%NOTFOUND THEN
              CLOSE l_txd_csr;
              Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_NO_TAX',
                      p_token1       => 'line',
                      p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
              RAISE G_EXCEPTION_HALT_VALIDATION;
          END IF;
          CLOSE l_txd_csr;

--|start   28-Oct-2008 cklee Fixed Bug 7492324                                      |

          IF((l_txl.life_in_months IS NULL AND l_txl.deprn_rate IS NULL)OR
             (l_txl.deprn_method IS NULL)OR(l_txl.in_service_date IS NULL)OR
             ((nvl(l_txl.salvage_value,0) IS NULL)AND(nvl(l_txl.percent_salvage_value,0) IS NULL))OR(l_txl.depreciation_cost IS NULL))THEN
--|end   28-Oct-2008 cklee Fixed Bug 7492324                                      |

              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_DEPRECIATION',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          ELSIF((l_txd.cost IS NULL)OR(l_txd.deprn_method_tax IS NULL))THEN
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_TAX',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;

/*   made a separate process check_tax_book_cost()

          ElsIf(l_txd.cost < l_txl.depreciation_cost)Then
              OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_BASISPCNT_GT_100',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := OKL_API.G_RET_STS_ERROR;
*/
              IF(l_hdr.term > ( 0.75*l_txl.life_in_months))THEN
                  Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_OP_TERM_LIM',
                      p_token1       => 'line',
                      p_token1_value => l_lne.name);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
              END IF;
          END IF;

          --
          -- Check for Tax Book of same type Bug# 3066346
          --
          FOR l_txd_rec1 IN txd_csr1 (l_asst.fa_id)
          LOOP
             IF (l_txd_rec1.book_count > 1) THEN
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_MULTI_TAX_BOOK',
                  p_token1       => 'ASSET_NUM',
                  p_token1_value => l_lne.name,
                  p_token2       => 'BOOK_TYPE',
                  p_token2_value => l_txd_rec1.book_type);
              x_return_status := Okl_Api.G_RET_STS_ERROR;

             END IF;
          END LOOP;

          --------------
          --Bug# 7131806
          --------------
          l_valid_corpbook := '?';
          OPEN l_corpbook_csr(p_book_type_code => l_txl.corporate_book);
          FETCH l_corpbook_csr INTO l_valid_corpbook;
          CLOSE l_corpbook_csr;

          IF l_valid_corpbook = '?' THEN
             Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVALID_CORP_BOOK',
                  p_token1       => 'ASSET_NUMBER',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

          IF (l_txl.corporate_book <> l_system_corp_book) THEN
             Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_CORP_MISMATCH'); -- MGAAP 7263041
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

          --------------
          --Bug# 4103361
          --------------
          --check asset category book combination for corporate book
          l_valid_bk_cat := '?';
          OPEN l_bk_cat_csr(p_cat_id         => l_txl.depreciation_id,
                            p_book_type_code => l_txl.corporate_book);
          FETCH l_bk_cat_csr INTO l_valid_bk_cat;
          IF l_bk_cat_csr%NOTFOUND THEN
              NULL;
          END IF;
          CLOSE l_bk_cat_csr;

          IF l_valid_bk_cat = '?' THEN
              --get asset category name
              OPEN l_fa_cat_csr(p_cat_id => l_txl.depreciation_id);
              FETCH l_fa_cat_csr INTO l_fa_cat_name;
              IF l_fa_cat_csr%NOTFOUND THEN
                 NULL;
              END IF;
              CLOSE l_fa_cat_csr;

              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVALID_FA_BOOK_CAT',
                  p_token1       => 'FA_CATEGORY',
                  p_token1_value => l_fa_cat_name,
                  p_token2       => 'FA_BOOK',
                  p_token2_value => l_txl.corporate_book,
                  p_token3       => 'line',
                  p_token3_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;

           --check asset category-book combination for tax books
           FOR l_txd_rec IN l_txd_csr(kleid => l_asst.fa_id)
           LOOP
               l_valid_bk_cat := '?';
               OPEN l_bk_cat_csr(p_cat_id         => l_txl.depreciation_id,
                                 p_book_type_code => l_txd_rec.tax_book);
               FETCH l_bk_cat_csr INTO l_valid_bk_cat;
               IF l_bk_cat_csr%NOTFOUND THEN
                   NULL;
               END IF;
               CLOSE l_bk_cat_csr;

               IF l_valid_bk_cat = '?' THEN
               --get asset category name
                   OPEN l_fa_cat_csr(p_cat_id => l_txl.depreciation_id);
                   FETCH l_fa_cat_csr INTO l_fa_cat_name;
                   IF l_fa_cat_csr%NOTFOUND THEN
                       NULL;
                   END IF;
                   CLOSE l_fa_cat_csr;

                   Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_INVALID_FA_BOOK_CAT',
                      p_token1       => 'FA_CATEGORY',
                      p_token1_value => l_fa_cat_name,
                      p_token2       => 'FA_BOOK',
                      p_token2_value => l_txd_rec.tax_book,
                      p_token3       => 'line',
                      p_token3_value => l_lne.name);
                   x_return_status := Okl_Api.G_RET_STS_ERROR;
                END IF;
           END LOOP;
          --------------
          --Bug# 4103361
          --------------

      END IF;



      IF((INSTR( l_hdr.DEAL_TYPE, 'LOAN' )>0) AND (l_hdr.report_pdt_id = -1)) THEN

          OPEN  l_txl_csr(l_asst.fa_id);
          FETCH l_txl_csr INTO l_txl;
          CLOSE l_txl_csr;

          IF((l_lne.RESIDUAL_VALUE > 0)OR
             (l_txl.salvage_value > 0)OR
             (l_txl.percent_salvage_value > 0)) THEN

              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_LNCTRT_NORVSV',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;

          END IF;

          IF( l_txl.fa_location_id IS NOT NULL ) THEN
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_LOAN_FA_LOCATION',
                  p_token1       => 'line',
                  p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
          END IF;

      END IF;

      OPEN  supp_csr(l_asst.fa_id);
      FETCH supp_csr INTO l_supp_rec;
      IF supp_csr%NOTFOUND THEN
          NULL;
      -- bug 5034519. changed from contract start date to asset start date
      -- also changed message from OKL_QA_VNDRDATES_GT_STARTDATE
      --ELSIF( l_supp_rec.date_invoiced > l_hdr.start_date ) THEN
      ELSIF( l_supp_rec.date_invoiced > l_lne.start_date ) THEN
          Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              --p_msg_name     => 'OKL_QA_VNDRDATES_GT_STARTDATE',
              p_msg_name     => 'OKL_QA_INV_SUPPDATE',
              p_token1       => 'line',
              p_token1_value => l_lne.name);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;
      CLOSE supp_csr;

      /*Bug#3877032
      *OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
      *FETCH l_hdrrl_csr into l_hdrrl_rec;
      *CLOSE l_hdrrl_csr;
      */

      /*Bug#4186455
      *If (( l_lne.residual_value < (0.2 * l_lne.OEC)) AND (l_tax_owner = 'LESSOR')) then
      *--If (( l_lne.residual_value < (0.2 * l_lne.OEC)) AND (l_hdrrl_rec.RULE_INFORMATION1 = 'LESSOR')) then
      *      OKL_API.set_message(
      *        p_app_name     => G_APP_NAME,
      *        p_msg_name     => 'OKL_QA_RV_OEC_TOWN',
      *        p_token1       => 'line',
      *        p_token1_value => l_lne.name);
      *      x_return_status := OKL_API.G_RET_STS_ERROR;
      *END IF;
      */

      OPEN  l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne.id );
      FETCH l_rl_csr1 INTO l_rl_rec1;
      IF l_rl_csr1%NOTFOUND THEN
              Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_NO_PAYMENTS',
                p_token1       => 'line',
                p_token1_value => l_lne.name);
              x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;
      CLOSE l_rl_csr1;


    END LOOP;

    FOR l_lne IN l_lne_csr('USAGE', p_chr_id)
    LOOP

        i := 0;
        l_ib_qty   := 0;
        FOR l_itm IN l_itms_csr('LINK_USAGE_ASSET', l_lne.id, p_chr_id)
        LOOP
            OPEN asst_qty_csr(FinAsstId => l_itm.FinAssetId);
            FETCH asst_qty_csr INTO l_asst;
            IF asst_qty_csr%NOTFOUND THEN
               CLOSE asst_qty_csr;
               RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSE
                OPEN ib_qty_csr(FinAsstId => l_itm.FinAssetId);
                FETCH ib_qty_csr INTO l_ib_qty;
                IF ib_qty_csr%NOTFOUND THEN
                    CLOSE ib_qty_csr;
                    RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
                END IF;
                CLOSE ib_qty_csr;
            END IF;
            CLOSE asst_qty_csr;
            i := i + 1;

            IF l_asst.number_of_items <> l_ib_qty THEN
              Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_USAGE_1ITM',
                p_token1       => 'usage line',
                p_token1_value => TO_CHAR(i));
              x_return_status := Okl_Api.G_RET_STS_ERROR;
            END IF;

        END LOOP;


        IF ( i = 0 ) THEN
              Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_UBB_1ASSET');
              x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

    END LOOP;


    --
    -- Passthrough validation for FEE and Service line
    -- Bug# dedey
    --
    FOR l_lne IN l_kle_csr('FEE', p_chr_id)
    LOOP

       -- Bug# 4350255
       FOR pth_dtl_rec IN  pth_dtl_csr(p_chr_id => p_chr_id,
                                       p_cle_id => l_lne.id)
       LOOP

          l_site_valid := '?';
          OPEN passthru_site_csr (pth_dtl_rec.vendor_id,
                                  pth_dtl_rec.pay_site_id);
          FETCH passthru_site_csr INTO l_site_valid;
          CLOSE passthru_site_csr;

          IF (l_site_valid <> 'Y') THEN

             OPEN vendor_csr(p_vendor_id => pth_dtl_rec.vendor_id);
             FETCH vendor_csr INTO l_vendor_name;
             CLOSE vendor_csr;

             IF (pth_dtl_rec.passthru_term = 'BASE') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_BASE_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             ELSIF (pth_dtl_rec.passthru_term = 'EVERGREEN') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_EVGN_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             END IF;
          END IF;
       END LOOP;

    END LOOP; -- FEE line

    FOR l_lne IN l_kle_csr('SOLD_SERVICE', p_chr_id)
    LOOP

       -- Bug# 4350255
       -- Vendor must be defined for Service line
       l_vendor_id := NULL;
       OPEN party_csr (p_chr_id,
                       l_lne.id);
       FETCH party_csr INTO l_vendor_id;
       CLOSE party_csr;

       IF (l_vendor_id IS NULL) THEN
         Okl_Api.set_message(
                             G_APP_NAME,
                             'OKL_QA_SERVICE_VENDOR',
                             'LINE',
                             l_lne.name
                            );
         x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;

       -- Payments are mandatory for Service Line if
       -- Passthrough has been defined
       l_pth_present := '?';
       FOR pth_hdr_rec IN pth_hdr_csr( p_chr_id => TO_NUMBER(p_chr_id),
                                       p_cle_id => l_lne.id)
       LOOP
         l_pth_present := 'Y';
       END LOOP;

       IF (l_pth_present = 'Y') THEN

    -- Bug 5216135 : kbbhavsa : 29-May-06 : start
            OPEN  l_kle_link_csr( 'LINK_SERV_ASSET', p_chr_id, l_lne.id );
         FETCH l_kle_link_csr INTO l_link_cle_id;
         -- check if service line is linked to Aseet or not
         -- if linked then check payment for linked service asset sub line
         -- and if not linked then check payment at service top line
         IF l_kle_link_csr%FOUND THEN
           OPEN  l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_link_cle_id );
         ELSE
           OPEN  l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne.id );
         END IF;
           CLOSE l_kle_link_csr;
        -- Bug 5216135 : kbbhavsa : 29-May-06 : end

         FETCH l_rl_csr1 INTO l_rl_rec1;

         IF l_rl_csr1%NOTFOUND THEN
     -- Bug 5216135 : kbbhavsa : 29-May-06 : start
            IF l_link_cle_id IS NULL THEN
              -- service not linked to asset, and payment not found at top service line
              Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_PTH_NO_PAYMENTS',
                p_token1       => 'LINE',
                p_token1_value => l_lne.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
            ELSE
              -- service linked to asset, and payment not found at linked service asset sub line
              IF l_rl_csr1%ISOPEN THEN
                CLOSE l_rl_csr1;
              END IF;
              -- service linked to asset, now checking payment at top service line
              OPEN  l_rl_csr1( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne.id );
              FETCH l_rl_csr1 INTO l_rl_rec1;
                IF l_rl_csr1%NOTFOUND THEN
                  -- service linked to asset, and payment not found at top service line
                   Okl_Api.set_message(
                        p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_QA_PTH_NO_PAYMENTS',
                        p_token1       => 'LINE',
                        p_token1_value => l_lne.name);
                        x_return_status := Okl_Api.G_RET_STS_ERROR;
                END IF;
            END IF;
            -- Bug 5216135 : kbbhavsa : 29-May-06 : end
          END IF;
        CLOSE l_rl_csr1;
       END IF;

       -- Bug# 4350255
       FOR pth_dtl_rec IN  pth_dtl_csr(p_chr_id => p_chr_id,
                                       p_cle_id => l_lne.id)
       LOOP

          l_site_valid := '?';
          OPEN passthru_site_csr (pth_dtl_rec.vendor_id,
                                  pth_dtl_rec.pay_site_id);
          FETCH passthru_site_csr INTO l_site_valid;
          CLOSE passthru_site_csr;

          IF (l_site_valid <> 'Y') THEN
             OPEN vendor_csr(p_vendor_id => pth_dtl_rec.vendor_id);
             FETCH vendor_csr INTO l_vendor_name;
             CLOSE vendor_csr;

             IF (pth_dtl_rec.passthru_term = 'BASE') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_BASE_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             ELSIF (pth_dtl_rec.passthru_term = 'EVERGREEN') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_EVGN_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             END IF;
          END IF;
       END LOOP;

    END LOOP; -- SERVICE line

    --
    -- Passthrough validation for ASSET line
    -- Bug# 4350255
    --
    FOR l_lne IN l_kle_csr('FREE_FORM1', p_chr_id)
    LOOP

       -- Bug# 4350255
       FOR pth_dtl_rec IN  pth_dtl_csr(p_chr_id => p_chr_id,
                                       p_cle_id => l_lne.id)
       LOOP

          l_site_valid := '?';
          OPEN passthru_site_csr (pth_dtl_rec.vendor_id,
                                  pth_dtl_rec.pay_site_id);
          FETCH passthru_site_csr INTO l_site_valid;
          CLOSE passthru_site_csr;

          IF (l_site_valid <> 'Y') THEN
             OPEN vendor_csr(p_vendor_id => pth_dtl_rec.vendor_id);
             FETCH vendor_csr INTO l_vendor_name;
             CLOSE vendor_csr;

             IF (pth_dtl_rec.passthru_term = 'BASE') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_BASE_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             ELSIF (pth_dtl_rec.passthru_term = 'EVERGREEN') THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INVLD_EVGN_PTH_SITE',
                  p_token1       => 'LINE',
                  p_token1_value => l_lne.line_style||'/'||l_lne.name,
                  p_token2       => 'VENDOR',
                  p_token2_value => l_vendor_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;

             END IF;
          END IF;
       END LOOP;

    END LOOP; -- ASSET line

    -- Bug# 3064121
    FOR line_amt_rec IN line_amt_csr (p_chr_id,
                                      'SOLD_SERVICE')
    LOOP
       l_tot_sub_line_amt := 0;
       OPEN sub_line_amt_csr (line_amt_rec.id);
       FETCH sub_line_amt_csr INTO l_tot_sub_line_amt;
       CLOSE sub_line_amt_csr;

       IF (l_tot_sub_line_amt <> line_amt_rec.amount) THEN
          Okl_Api.set_message(
                              G_APP_NAME,
                              'OKL_QA_SRV_AMT_MISMATCH',
                              'LINE_TYPE',
                              'SERVICE',
                              'LINE_NUMBER',
                              line_amt_rec.line_number
                             );
          x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;

    END LOOP;
    -- Bug# 3064121

    --
    -- Check payment start and end date
    --

    check_payment_period(
                         p_chr_id        => p_chr_id,
                         x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    --
    -- Bug# 2901495
    -- Check credit lines
    --
    Okl_La_Validation_Util_Pvt.validate_crdtln_err (
                         p_api_version    => 1.0,
                         p_init_msg_list  => Okl_Api.G_FALSE,
                         x_return_status  => lx_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_chr_id         => p_chr_id
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    -- Bug# 4350255
    -- Modified the procedure check_fee_service_pth to
    -- include validations for Asset line Passthrough
    --
    -- Check FEE, SERVICE, ASSET passthrough rule
    --
    check_fee_service_ast_pth(
                         p_chr_id        => p_chr_id,
                         x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    --
    -- Check LASLL for stub and actual payments
    --
    check_stub_payment(
                       p_chr_id        => p_chr_id,
                       x_return_status => lx_return_status
                      );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    --
    -- Check for loan revolving contract
    --
    check_lessee_as_vendor(
                           p_chr_id        => p_chr_id,
                           x_return_status => lx_return_status
                          );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    --
    -- Check for serialized item
    --

    check_serial_asset(
                       p_chr_id        => p_chr_id,
                       x_return_status => lx_return_status
                      );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    -- bug 6760186 start
    -- Check for ib_location
    --

    check_ib_location (
                       p_chr_id        => p_chr_id,
                       x_return_status => lx_return_status
                      );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;
    -- bug 6760186 end

    /* Manu 30-Aug-2004 START
       Call to Rollover Quotes QA Validation checks. */

    check_rolloverQuotes(
                        p_chr_id        => p_chr_id,
                        x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    /* Manu 30-Aug-2004 END */

    --Bug# 4996899
    check_financed_fees(
                        p_chr_id        => p_chr_id,
                        x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;
    --Bug# 4996899

    check_stream_template(
                        p_chr_id        => p_chr_id,
                        x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

     --Bug#4622438
     check_product_status(
                        p_chr_id        => p_chr_id,
                        x_return_status => lx_return_status
                        );

    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

    --Bug#4373029
    Okl_La_Sales_Tax_Pvt.check_sales_tax(
                                         p_chr_id        => p_chr_id,
                                         x_return_status => lx_return_status
                                        );
    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

--akrangan  bug 5362977 starts
      check_service_contracts(
         p_chr_id        => p_chr_id,
         x_return_status => lx_return_status
         );

       IF (lx_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
         x_return_status := lx_return_status;
       END IF;
--akrangan  bug 5362977 ends

    --Murthy
    check_sales_quote(
                    p_chr_id        => p_chr_id,
                    x_return_status => lx_return_status
                   );
    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;

    --Smereddy Bug#7271259
    check_loan_payment(
                    p_chr_id        => p_chr_id,
                    x_return_status => lx_return_status
                   );
    IF (lx_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := lx_return_status;
    END IF;

  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_txl_csr%ISOPEN THEN
      CLOSE l_txl_csr;
    END IF;
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_lne_csr%ISOPEN THEN
      CLOSE l_lne_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF l_txl_csr%ISOPEN THEN
      CLOSE l_txl_csr;
    END IF;

  END check_func_constrs_4new;

  -- Start of comments
  --
  -- Procedure Name  : check_purchase_option
  -- Description     : Generates warning for validation of automatically process fixed
  --                   purchase option.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_purchase_option(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    --l_hdr      l_hdr_csr%ROWTYPE;
    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_tax_owner okc_rules_b.RULE_INFORMATION1%TYPE;
    l_purchase_opt_type okc_rules_b.RULE_INFORMATION11%TYPE;
    l_contract_residual_value NUMBER;
    l_msg_count NUMBER;
    l_msg_data VARCHAR2(2000);

    CURSOR l_asset_csr IS
    SELECT cle.id,
           name,
           kle.residual_value
    FROM   okc_k_lines_v cle,
           okl_k_lines kle,
           okc_line_styles_b sty,
           okc_statuses_b sts
    WHERE  cle.lse_id = sty.id
    AND    cle.dnz_chr_id = p_chr_id
    AND    cle.id = kle.id
    AND    lty_code = 'FREE_FORM1'
    AND    cle.sts_code = sts.code
    AND    sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    /*
    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr into l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;
    */

    OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    l_tax_owner := l_hdrrl_rec.RULE_INFORMATION1;
    CLOSE l_hdrrl_csr;

    -- Bug 5000754: Moved the code later so that RV check is properly done
    -- on end of term purchase
    /*
    OPEN  l_hdrrl_csr('AMTFOC', 'AMBPOC', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION11 IS NOT NULL)) THEN
      l_purchase_opt_type := l_hdrrl_rec.RULE_INFORMATION11;
    END IF;
    CLOSE l_hdrrl_csr;

    IF ((l_purchase_opt_type = '$1BO') AND (l_tax_owner = 'LESSOR')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_TOWN_1DBO');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    */

    --Bug#4778020 Tax owner warning message for early termination.
    OPEN  l_hdrrl_csr('AMTEOC', 'AMBPOC', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION11 IS NOT NULL)) THEN
      l_purchase_opt_type := l_hdrrl_rec.RULE_INFORMATION11;
    END IF;
    CLOSE l_hdrrl_csr;
    IF ((l_purchase_opt_type = '$1BO') AND (l_tax_owner = 'LESSOR')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_TOWN_1DBO');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    -- Bug 5000754 : End of term purchase
    OPEN  l_hdrrl_csr('AMTFOC', 'AMBPOC', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION11 IS NOT NULL)) THEN
      l_purchase_opt_type := l_hdrrl_rec.RULE_INFORMATION11;
    END IF;
    CLOSE l_hdrrl_csr;

    IF ((l_purchase_opt_type = '$1BO') AND (l_tax_owner = 'LESSOR')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_TOWN_1DBO');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    /*OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   =>1.0
                                   ,p_init_msg_list => 'F'
                                   ,x_return_status =>l_return_status
                                   ,x_msg_count     =>l_msg_count
                                   ,x_msg_data      =>l_msg_data
                                   ,p_formula_name  =>'CONTRACT_RESIDUAL_VALUE'
                                   ,p_contract_id   =>p_chr_id
                                   ,x_value         =>l_contract_residual_value);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      x_return_status := l_return_status;
    END IF;
    */

    FOR l_asset_rec IN l_asset_csr
    LOOP
      IF (l_purchase_opt_type = '$1BO' AND l_asset_rec.residual_value> 1.0) THEN
        Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_CNTRCT_RES_VAL_GT1',
                p_token1       => 'ASSET_NUM',
                p_token1_value => l_asset_rec.name);
        x_return_status := Okl_Api.G_RET_STS_ERROR;
      END IF;
    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;

    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;

  END check_purchase_option;

  -- Start of comments
  --
  -- Procedure Name  : check_rule_constraints
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_rule_constrs_4new(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);
    l_quote_eff_days NUMBER;
    l_quote_eff_max_days NUMBER;
    l_eot_tolerance_days NUMBER;

/* Bug 3825314
 *
 *  Cursor l_synd_csr ( chrId NUMBER ) IS
 *  select kl.dnz_chr_id syndId
 *  from OKC_K_ITEMS_V ITM,
 *       OKC_K_LINES_V KL,
 *       OKL_K_HEADERS_FULL_V KHR,
 *       OKC_LINE_STYLES_B lse
 *  where KL.LSE_ID=lse.id
 *     and lse.lty_code='SHARED'
 *     AND KL.CHR_ID =KL.DNZ_CHR_ID
 *     AND KL.DNZ_CHR_ID = ITM.DNZ_CHR_ID
 *     AND ITM.CLE_ID = KL.ID
 *     AND to_char(KHR.ID) = ITM.OBJECT1_ID1
 *     and khr.id = chrId;
 *
 *  l_synd_rec l_synd_csr%ROWTYPE;
 *
 */
    CURSOR l_rl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                     rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                     chrId OKC_RULE_GROUPS_B.DNZ_CHR_ID%TYPE ) IS
        SELECT crl.RULE_INFORMATION1, crl.RULE_INFORMATION2
        FROM   OKC_RULE_GROUPS_B crg, OKC_RULES_B crl
        WHERE  crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrId;

    l_hdr      l_hdr_csr%ROWTYPE;

    l_rl l_rl_csr%ROWTYPE;

    TYPE options_rec_type IS RECORD (
        purchase_option VARCHAR2(256),
        purchase_option_type VARCHAR2(256),
        formula_name VARCHAR2(256),
        purchase_option_amount NUMBER
    );

    TYPE options_tbl_type IS TABLE OF options_rec_type INDEX BY BINARY_INTEGER;

    l_options options_tbl_type;

    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

    cust_site_rec cust_site_csr%ROWTYPE;
    cust_rec cust_csr%ROWTYPE;

    CURSOR l_inst_csr( chrId NUMBER ) IS
    SELECT inst.object_id1_new
    FROM   OKL_TXL_ITM_INSTS inst,
           OKL_K_LINES_FULL_V kle,
       OKC_LINE_STYLES_B lse
    WHERE inst.kle_id = kle.id
       AND lse.id = kle.lse_id
       AND lse.lty_code = 'INST_ITEM'
       AND kle.dnz_chr_id = chrId;

    l_inst_rec l_inst_csr%ROWTYPE;

    CURSOR l_shipto_csr( chrId NUMBER ) IS
    SELECT inv.shipping_address_id1
    FROM   OKL_SUPP_INVOICE_DTLS inv,
           OKL_K_LINES_FULL_V kle,
       OKC_LINE_STYLES_B lse
    WHERE inv.cle_id = kle.id
       AND lse.id = kle.lse_id
       AND lse.lty_code = 'ITEM'
       AND kle.dnz_chr_id = chrId;

    l_shipto_rec l_shipto_csr%ROWTYPE;

    CURSOR l_party_uses_csr ( instId NUMBER, ptyId NUMBER, rleCode VARCHAR2 ) IS
    SELECT 'Y' isThere
    FROM dual
    WHERE EXISTS(
        SELECT A.party_site_use_id
    FROM   HZ_PARTY_SITE_USES A,
           HZ_PARTY_SITES     B
    WHERE b.party_site_id = a.party_site_id
        AND a.party_site_use_id = instId
        AND a.site_use_type = rleCode
        AND b.party_id = ptyId);

    l_party_uses_rec l_party_uses_csr%ROWTYPE;

    l_bto_site_use_id NUMBER;
    l_cust_acct_id    NUMBER;
    l_party_site_id   NUMBER;
    l_inst_site_id    NUMBER;
    l_shipto_id       NUMBER;

    l_rl1 l_rl_csr1%ROWTYPE;

    i NUMBER;

    fnd_rec fnd_csr%ROWTYPE;

    l_auto_fixed_pur_opt_yn okc_rules_b.RULE_INFORMATION1%TYPE;
    l_evergreen_flag okc_rules_b.RULE_INFORMATION1%TYPE;
    l_purchase_opt_type okc_rules_b.RULE_INFORMATION11%TYPE;

    l_late_charge_policy OKC_RULES_B.RULE_INFORMATION1%TYPE; -- Bug 4925675
    l_rl2 l_rl_csr%ROWTYPE;
/*
    CURSOR bill_to_csr (p_cust_acct okx_cust_site_uses_v.cust_account_id%TYPE,
                        p_bill_to   okx_cust_site_uses_v.id1%TYPE
                       ) IS
    SELECT 'Y'
    FROM   okx_cust_site_uses_v
    WHERE  id1                   = p_bill_to
    AND    cust_account_id       = p_cust_acct
    AND    site_use_code         = 'BILL_TO'
    AND    b_status              = 'A'
    AND    cust_acct_site_status = 'A';
    --AND    NVL(ORG_ID, -99)      = SYS_CONTEXT('OKC_CONTEXT','ORG_ID');

    --l_cust_acct     okc_rules_b.object1_id1%TYPE;
    l_cust_acct     OKC_K_HEADERS_B.CUST_ACCT_ID%TYPE;

    l_bill_to       okc_rules_b.object1_id1%TYPE;
    l_bill_to_valid VARCHAR2(1) := 'N';
*/

    -- Bug# 8219011
    CURSOR pymt_method_csr(p_cust_acct_id   IN NUMBER,
                           p_bill_to_id     IN NUMBER,
                           p_pymt_method_id IN NUMBER) IS
    SELECT 'Y'
    FROM  OKX_RECEIPT_METHODS_V
    WHERE customer_id = p_cust_acct_id
--For bug 8325912    AND site_use_id = p_bill_to_id
    AND id1 = p_pymt_method_id;

    l_pymt_method_valid_yn VARCHAR2(1);

    CURSOR bank_acct_csr(p_cust_acct_id IN NUMBER,
                         p_bill_to_id   IN NUMBER,
                         p_bank_acct_id IN NUMBER) IS
    SELECT 'Y'
    FROM okx_rcpt_method_accounts_v okx_custbkac
    WHERE SYSDATE < NVL(end_date_active,SYSDATE+1)
    AND customer_id = p_cust_acct_id
--For bug 8325912    AND customer_site_use_id = p_bill_to_id
    AND id1 = p_bank_acct_id;

    l_bank_acct_valid_yn VARCHAR2(1);
    -- Bug# 8219011

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

      get_bill_to(
                  x_return_status => x_return_status,
                  p_chr_id        => TO_NUMBER(p_chr_id),
                  x_bill_to_id    => l_bto_site_use_id
                 );

    --If( l_hdrrl_csr%NOTFOUND ) Then
    IF( l_bto_site_use_id IS NULL) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NOBTO');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    ELSE

        get_cust_account(
                  x_return_status => x_return_status,
                  p_chr_id        => TO_NUMBER(p_chr_id),
                  x_cust_acc_id   => l_cust_acct_id
                 );


        OPEN  cust_site_csr(l_bto_site_use_id, l_cust_acct_id, 'BILL_TO');
        FETCH cust_site_csr INTO cust_site_rec;
    CLOSE cust_site_csr;
    IF ( NVL(cust_site_rec.isThere, 'N') = 'N' ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_BILLTO_ACCNT');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

        OPEN  cust_csr('LESSEE', TO_NUMBER(p_chr_id));
        FETCH cust_csr INTO cust_rec;
    CLOSE cust_csr;
        l_party_site_id := NVL( TO_NUMBER(cust_rec.object1_id1), -1);

    FOR l_inst_rec IN l_inst_csr ( TO_NUMBER(p_chr_id) )
    LOOP

        l_inst_site_id := NVL( TO_NUMBER(l_inst_rec.object_id1_new), -1);

            OPEN  l_party_uses_csr(l_inst_site_id, l_party_site_id, 'INSTALL_AT');
            FETCH l_party_uses_csr INTO l_party_uses_rec;
        CLOSE l_party_uses_csr;
        IF ( NVL(l_party_uses_rec.isThere, 'N') = 'N' ) THEN
                Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_INST_ACCN');
                 -- notify caller of an error
                x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

    END LOOP;

    FOR l_shipto_rec IN l_shipto_csr( TO_NUMBER(p_chr_id) )
    LOOP

        l_shipto_id := NVL( TO_NUMBER(l_shipto_rec.shipping_address_id1), -1);

            IF( l_shipto_id <> -1 ) THEN

                OPEN  cust_site_csr(l_bto_site_use_id, l_shipto_id, 'SHIP_TO');
                FETCH cust_site_csr INTO cust_site_rec;
            CLOSE cust_site_csr;
            IF ( NVL(cust_site_rec.isThere, 'N') = 'N' ) THEN
                    Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_BTO_SHIPTO');
                     -- notify caller of an error
                    x_return_status := Okl_Api.G_RET_STS_ERROR;
            END IF;

        END IF;

    END LOOP;

      --Bug# 8219011
      l_hdrrl_rec := NULL;
      OPEN l_hdrrl_csr('LABILL', 'LAPMTH', TO_NUMBER(p_chr_id));
      FETCH l_hdrrl_csr INTO l_hdrrl_rec;
      CLOSE l_hdrrl_csr;

      IF (l_hdrrl_rec.object1_id1 IS NOT NULL) THEN

        l_pymt_method_valid_yn := 'N';
        OPEN pymt_method_csr(p_cust_acct_id   => l_cust_acct_id,
                             p_bill_to_id     => l_bto_site_use_id,
                             p_pymt_method_id => l_hdrrl_rec.object1_id1);
        FETCH pymt_method_csr INTO l_pymt_method_valid_yn;
        CLOSE pymt_method_csr;

        IF (l_pymt_method_valid_yn = 'N') THEN
          Okl_Api.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_PYMT_METHOD_INVALID');
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
      END IF;

      l_hdrrl_rec := NULL;
      OPEN l_hdrrl_csr('LABILL', 'LABACC', TO_NUMBER(p_chr_id));
      FETCH l_hdrrl_csr INTO l_hdrrl_rec;
      CLOSE l_hdrrl_csr;

      IF (l_hdrrl_rec.object1_id1 IS NOT NULL) THEN

        l_bank_acct_valid_yn := 'N';
        OPEN bank_acct_csr(p_cust_acct_id => l_cust_acct_id,
                           p_bill_to_id   => l_bto_site_use_id,
                           p_bank_acct_id => l_hdrrl_rec.object1_id1);
        FETCH bank_acct_csr INTO l_bank_acct_valid_yn;
        CLOSE bank_acct_csr;

        IF (l_bank_acct_valid_yn = 'N') THEN
          Okl_Api.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_BANK_ACCT_INVALID');
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
      END IF;
      --Bug# 8219011

    END IF;
    IF (l_hdrrl_csr%ISOPEN) THEN
       CLOSE l_hdrrl_csr;
    END IF;

    --Bug#3947959
    check_est_prop_tax(
              p_chr_id        => p_chr_id,
              x_return_status => l_return_status
             );

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := l_return_status;
    END IF;

    -- Bug 4915341 (redundant check commented out)
    /*
    -- Bug#4872437 ramurt
    check_evergreen_pth(l_return_status, p_chr_id);

    IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
       x_return_status := l_return_status;
    END IF;
    -- Bug#4872437 changes end
    */

/*  commented out for bug 5032883
    OPEN  l_hdrrl_csr('LALCGR', 'LAHUDT', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;

    IF(( l_hdrrl_csr%FOUND ) AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL) AND
       ( TRUNC(Fnd_Date.canonical_to_date(l_hdrrl_rec.RULE_INFORMATION1)) < TRUNC(l_hdr.START_DATE) )) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LATE_CH_DATE');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_hdrrl_csr;
*/
/*  commented out for bug 5032883
    OPEN  l_hdrrl_csr('LALIGR', 'LAHUDT', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;

    IF(( l_hdrrl_csr%FOUND ) AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL) AND
       (TRUNC( Fnd_Date.canonical_to_date(l_hdrrl_rec.RULE_INFORMATION1)) < TRUNC(l_hdr.START_DATE) )) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LATE_INT_DATE');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_hdrrl_csr;
*/
    OPEN  l_hdrrl_csr('LAREBL', 'LAREBL', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;

    IF((l_hdrrl_csr%FOUND)AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL) AND
       (TRUNC( Fnd_Date.canonical_to_date(l_hdrrl_rec.RULE_INFORMATION1)) < TRUNC(l_hdr.START_DATE))) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_REBOOK_LMT_DATE');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_hdrrl_csr;

    OPEN  l_hdrrl_csr('AMTEOC', 'AMBPOC', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;

    IF( l_hdrrl_csr%NOTFOUND ) THEN
        l_options(1).purchase_option_type :=  NULL;
    ELSE
        l_options(1).purchase_option_type := l_hdrrl_rec.RULE_INFORMATION11;
        l_options(1).purchase_option := l_hdrrl_rec.RULE_INFORMATION1;
        IF (NVL(l_hdrrl_rec.RULE_INFORMATION2,-1) <> -1) THEN
            l_options(1).purchase_option_amount := TO_NUMBER(l_hdrrl_rec.RULE_INFORMATION2);
        END IF;
        l_options(1).formula_name := l_hdrrl_rec.RULE_INFORMATION3;
    END IF;
    CLOSE l_hdrrl_csr;

    OPEN  l_hdrrl_csr('AMTFOC', 'AMBPOC', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;

    IF( l_hdrrl_csr%NOTFOUND ) THEN
        l_options(2).purchase_option_type :=  NULL;
    ELSE
        l_options(2).purchase_option_type := l_hdrrl_rec.RULE_INFORMATION11;
        l_options(2).purchase_option := l_hdrrl_rec.RULE_INFORMATION1;
        IF (NVL(l_hdrrl_rec.RULE_INFORMATION2,-1) <> -1) THEN
            l_options(2).purchase_option_amount := TO_NUMBER(l_hdrrl_rec.RULE_INFORMATION2);
        END IF;
        l_options(2).formula_name := l_hdrrl_rec.RULE_INFORMATION3;
    END IF;
    CLOSE l_hdrrl_csr;

    IF(( (INSTR( l_hdr.DEAL_TYPE, 'LOAN' )<1) OR (l_hdr.report_pdt_id <> -1)) AND
        (l_options(1).purchase_option_type IS NULL ) AND
        (l_options(2).purchase_option_type IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_PURCHASE_OPTNS');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;


    IF( INSTR( l_hdr.DEAL_TYPE, 'LOAN' )<1) THEN

  FOR i IN 1..l_options.COUNT
  LOOP

    IF((l_options(i).formula_name IS NULL)AND(l_options(i).purchase_option = 'USE_FORMULA')) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_FORMULA');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF((INSTR( l_hdr.DEAL_TYPE, 'LOAN' )>0)AND(l_options(i).purchase_option_type <> 'NONE')) THEN
                                                                      --FND Lookup change from NONE.
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LNCTRT_NOFMV');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;


    IF((l_options(i).purchase_option_type = 'FMV')AND(l_options(i).purchase_option_amount IS NOT NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_FMV_NO_FLD');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF((l_options(i).purchase_option_type = 'FRV')AND(l_options(i).purchase_option_amount IS NOT NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_FRV_NO_FLD');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;



    IF ((INSTR( l_hdr.DEAL_TYPE,'OP') > 0 ) AND (l_options(i).purchase_option_type = '$1BO')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_OP_1DBO');
             -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  END LOOP;



-- End of term.
    IF((l_options(2).purchase_option_type IS NOT NULL)AND(l_options(2).purchase_option_type <> 'FMV')AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NULL )AND(l_options(2).purchase_option_amount IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_EOTOPTIONS_NOTSET');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  END IF;

    OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;


    IF ((INSTR( l_hdr.DEAL_TYPE,'OP') > 0 ) AND (l_hdrrl_rec.RULE_INFORMATION1 <> 'LESSOR')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_OP_LESSOR');
             -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    /*If ((INSTR( l_hdr.DEAL_TYPE,'ST') > 0 ) AND (l_hdrrl_rec.RULE_INFORMATION1 <> 'LESSEE')) then
        OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_LESSEE');
             -- notify caller of an error
        x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;*/

    IF ((l_hdr.DEAL_TYPE = 'LOAN') AND (l_hdrrl_rec.RULE_INFORMATION1 <> 'LESSEE')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LOAN_LESSEE');
             -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  /* Bug#4778020 tax owner message for early termination also moved to procedure check_purchase_option.
  If( INSTR( l_hdr.DEAL_TYPE, 'LOAN' )<1) Then
    --Lessor and $1buyout check: error thrown only for early termination(AMTEOC).
    --message for end of terms check(AMTFOC) moved to check_purchase_option which is
    --user configurable to warning.
    --FOR i in 1..l_options.COUNT
    --LOOP
    --    If ((l_options(i).purchase_option_type = '$1BO') AND (l_hdrrl_rec.RULE_INFORMATION1 = 'LESSOR')) then
        If ((l_options(1).purchase_option_type = '$1BO') AND (l_hdrrl_rec.RULE_INFORMATION1 = 'LESSOR')) then
            OKL_API.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_NO_TOWN_1DBO');
                 -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
        End If;

    --END LOOP;
  End If;
  */

  --$1Buyout changes Begin
  OPEN  l_hdrrl_csr('AMTFOC', 'AMTINV', TO_NUMBER(p_chr_id));
  FETCH l_hdrrl_csr INTO l_hdrrl_rec;
  IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL)) THEN
     l_auto_fixed_pur_opt_yn := l_hdrrl_rec.RULE_INFORMATION1;
  END IF;
  CLOSE l_hdrrl_csr;

  OPEN  l_hdrrl_csr('AMTFOC', 'AMBPOC', TO_NUMBER(p_chr_id));
  FETCH l_hdrrl_csr INTO l_hdrrl_rec;
  IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION11 IS NOT NULL)) THEN
    l_purchase_opt_type := l_hdrrl_rec.RULE_INFORMATION11;
  END IF;
  CLOSE l_hdrrl_csr;
  IF (NVL(l_auto_fixed_pur_opt_yn,'N') = 'Y'
    AND NVL(l_purchase_opt_type,'XXX') NOT IN ('FPO','$1BO')) THEN
    --error message
    Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_AUTO_PUR_OPT_TYPE');
    x_return_status := Okl_Api.G_RET_STS_ERROR;
  END IF;

  OPEN  l_hdrrl_csr('LAEVEL', 'LAEVEL', TO_NUMBER(p_chr_id));
  FETCH l_hdrrl_csr INTO l_hdrrl_rec;
  IF((l_hdrrl_csr%FOUND) AND (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL)) THEN
    l_evergreen_flag := l_hdrrl_rec.RULE_INFORMATION1;
  END IF;
  CLOSE l_hdrrl_csr;

  IF (NVL(l_evergreen_flag,'N') = 'Y' AND NVL(l_auto_fixed_pur_opt_yn,'N') = 'Y')  THEN
    --error message
    Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_EVG_AUTO_FIXED_PUR_OPT');
    x_return_status := Okl_Api.G_RET_STS_ERROR;
  END IF;
  --$1Buyout changes End

    OPEN  l_hdrrl_csr('LARVIN', 'LARVAU', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    IF( l_hdrrl_csr%FOUND AND (NVL(l_hdrrl_rec.RULE_INFORMATION1,'N') = 'Y')) THEN

        CLOSE l_hdrrl_csr;
        OPEN  l_hdrrl_csr('LARVIN', 'LARVAM', TO_NUMBER(p_chr_id));
        FETCH l_hdrrl_csr INTO l_hdrrl_rec;

        IF ( l_hdrrl_csr%NOTFOUND OR l_hdrrl_rec.RULE_INFORMATION4 IS NULL) THEN
            Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_RVI_RATE');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        ELSIF(TO_NUMBER(l_hdrrl_rec.RULE_INFORMATION4)  > 100) THEN
            Okl_Api.set_message(
                      p_app_name     => G_APP_NAME,
                      p_msg_name     => 'OKL_QA_RVI_GT_100');
                     -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;

    END IF;
    CLOSE l_hdrrl_csr;

    OPEN l_rl_csr('LARNOP', 'LAEOTR', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(INSTR(l_hdr.DEAL_TYPE,'DF') > 0) AND (l_rl.RULE_INFORMATION1 = 'FMV')) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_CTRTDF_NOFMV');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    OPEN l_rl_csr('LARNOP', 'LAMITR', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(INSTR( l_hdr.DEAL_TYPE,'DF') > 0) AND (l_rl.RULE_INFORMATION1 = 'FMV')) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_CTRTDF_NOFMV');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    OPEN l_rl_csr('LAASTX', 'LAASTX', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(l_rl.RULE_INFORMATION1 = 'Y') AND (l_rl.RULE_INFORMATION2 IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_EXEMPT');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    OPEN l_rl_csr('LAASTX', 'LAAVTX', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(l_rl.RULE_INFORMATION1 = 'Y') AND (l_rl.RULE_INFORMATION2 IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_EXEMPT');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    OPEN l_rl_csr('LAGRNP', 'LAGRNP', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(l_rl.RULE_INFORMATION1 = 'Y') AND (l_rl.RULE_INFORMATION2 IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_GUARANTEE');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    OPEN l_rl_csr('LARNOP', 'LAREND', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(l_rl.RULE_INFORMATION1 = 'Y') AND (l_rl.RULE_INFORMATION2 IS NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_RENEWAL_NOTICE');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

/* Bug 3825314
 *
 *  OPEN l_synd_csr(p_chr_id);
 *  FETCH l_synd_csr INTO l_synd_rec;
 *  IF(nvl(l_hdr.syndicatable_yn,'N') = 'Y' AND l_synd_csr%FOUND) THEN
 *
 *      OPEN l_rl_csr('LASYND', 'LASYST', l_synd_rec.syndId);
 *      FETCH l_rl_csr INTO l_rl;
 *      IF(l_rl_csr%FOUND)AND(to_number(nvl(l_rl.RULE_INFORMATION2,-1)) > 100) THEN
 *        OKL_API.set_message(
 *          p_app_name     => G_APP_NAME,
 *          p_msg_name     => 'OKL_QA_SYND_STAKE');
 *          x_return_status := OKL_API.G_RET_STS_ERROR;
 *      END IF;
 *      CLOSE l_rl_csr;
 *
 *  END IF;
 *  CLOSE l_synd_csr;
 *
 */

    OPEN l_rl_csr('LAEVEL', 'LAEOTR', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF ((l_rl_csr%FOUND)AND(l_rl.RULE_INFORMATION1 = 'FMV') AND (l_rl.RULE_INFORMATION2 IS NOT NULL)) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_EVERGREEN');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    CLOSE l_rl_csr;

    --Check for Termination Quote Rules
    l_row_notfound := FALSE;
    OPEN l_rl_csr('AMTQPR', 'AMQTEF', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF (l_rl_csr%NOTFOUND) THEN
      l_row_notfound := l_rl_csr%NOTFOUND;
    END IF;
    CLOSE l_rl_csr;
    l_quote_eff_days := l_rl.RULE_INFORMATION1;
    l_quote_eff_max_days := l_rl.RULE_INFORMATION2;

    OPEN l_rl_csr('AMTQPR', 'AMTSET', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF (l_rl_csr%NOTFOUND) THEN
      l_row_notfound := l_rl_csr%NOTFOUND;
    END IF;
    CLOSE l_rl_csr;
    l_eot_tolerance_days := l_rl.RULE_INFORMATION1;

    IF (l_row_notfound OR l_quote_eff_days IS NULL OR l_quote_eff_max_days IS NULL
        OR l_eot_tolerance_days IS NULL ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_TERMINATION_QUOTE');
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;


    i := 0;
    FOR l_lne IN l_lne_csr('USAGE', p_chr_id)
    LOOP

        i := i + 1;

        FOR l_rl1 IN l_rl_csr1('LAUSBB', 'LAUSBB', p_chr_id, l_lne.id)
    LOOP

        IF (( NVL(l_rl1.RULE_INFORMATION6, 'XXX') = 'VRT' ) OR ( NVL(l_rl1.RULE_INFORMATION6, 'XXX') = 'QTY' )) AND
           (( l_rl1.RULE_INFORMATION2 IS NULL  ) OR ( l_rl1.RULE_INFORMATION5 IS NULL )) THEN

                   OPEN fnd_csr('OKS_USAGE_TYPE', l_rl1.RULE_INFORMATION6);
                   FETCH fnd_csr INTO fnd_rec;
                   CLOSE fnd_csr;

                   Okl_Api.set_message(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_QA_USAGE_CHECK',
             p_token1       => 'LINE_NUM',
                         p_token1_value => TO_CHAR(i),
             p_token2       => 'USAGE_TYPE',
             p_token2_value => fnd_rec.meaning);

                   x_return_status := Okl_Api.G_RET_STS_ERROR;

        ELSIF (( NVL(l_rl1.RULE_INFORMATION6, 'XXX') = 'FRT' ) AND ( l_rl1.RULE_INFORMATION7 IS NULL )) THEN

                   OPEN fnd_csr('OKS_USAGE_TYPE', l_rl1.RULE_INFORMATION6);
                   FETCH fnd_csr INTO fnd_rec;
                   CLOSE fnd_csr;

                   Okl_Api.set_message(
                         p_app_name     => G_APP_NAME,
                         p_msg_name     => 'OKL_QA_FIXED_USAGE',
             p_token1       => 'LINE_NUM',
                         p_token1_value => TO_CHAR(i),
             p_token2       => 'USAGE_TYPE',
             p_token2_value => fnd_rec.meaning);

                   x_return_status := Okl_Api.G_RET_STS_ERROR;

        END IF;

    END LOOP;

    END LOOP;

    -- Bug 4865510
    OPEN l_rl_csr('LARVIN', 'LARVAU', p_chr_id);
    FETCH l_rl_csr INTO l_rl;
    IF (l_rl_csr%FOUND) THEN
      IF (nvl(l_rl.RULE_INFORMATION1,'N') = 'Y') THEN
        IF (INSTR( l_hdr.DEAL_TYPE,'DF') > 0) THEN
          NULL;
        ELSE
          Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_RVI_NA',
                p_token1 => 'BOOK_CLASS',
                p_token1_value => l_hdr.deal_type);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
      END IF; -- If 'Y'
    END IF; -- IF found
    CLOSE l_rl_csr;

    -- Bug 4925675
    OPEN l_rl_csr('LALCGR', 'LALCPR', p_chr_id);
    FETCH l_rl_csr INTO l_rl;

    IF (l_rl_csr%FOUND) THEN
       l_late_charge_policy := l_rl.rule_information1;
       CLOSE l_rl_csr;

       OPEN l_rl_csr('LALCGR', 'LALCEX', p_chr_id);
       FETCH l_rl_csr INTO l_rl2;
       IF (l_rl_csr%FOUND) THEN
         CLOSE l_rl_csr;
         IF (l_late_charge_policy IS NOT NULL AND
             l_rl2.rule_information1 = 'Y') THEN
           Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_QA_LATE_CHARGE_ERROR');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
         END IF;
       ELSE
         CLOSE l_rl_csr;
       END IF;
    ELSE
      CLOSE l_rl_csr;
    END IF;


  IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
      Okl_Api.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
  END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    IF l_rl_csr%ISOPEN THEN
      CLOSE l_rl_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF fnd_csr%ISOPEN THEN
      CLOSE fnd_csr;
    END IF;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rl_csr%ISOPEN THEN
      CLOSE l_rl_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    IF fnd_csr%ISOPEN THEN
      CLOSE fnd_csr;
    END IF;
  END check_rule_constrs_4new;

  PROCEDURE check_rule_4new_lnrev(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

    CURSOR l_rl_csr( rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                     rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                     chrid OKC_RULE_GROUPS_B.DNZ_CHR_ID%TYPE ) IS
        SELECT crl.RULE_INFORMATION1, crl.RULE_INFORMATION2
        FROM   OKC_RULE_GROUPS_B crg, OKC_RULES_B crl
        WHERE  crl.rgp_id = crg.id
           AND crg.RGD_CODE = rgcode
           AND crl.RULE_INFORMATION_CATEGORY = rlcat
           AND crg.dnz_chr_id = chrid;

    l_hdr      l_hdr_csr%ROWTYPE;

    l_rl l_rl_csr%ROWTYPE;

    TYPE options_rec_type IS RECORD (
        purchase_option VARCHAR2(256),
        purchase_option_type VARCHAR2(256),
        formula_name VARCHAR2(256),
        purchase_option_amount NUMBER
    );

    TYPE options_tbl_type IS TABLE OF options_rec_type INDEX BY BINARY_INTEGER;

    l_options options_tbl_type;

    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    i NUMBER;
    l_okl_bill_to_id OKC_K_HEADERS_B.BILL_TO_SITE_USE_ID%TYPE;

    -- Bug# 8219011
    l_cust_acct_id    NUMBER;
    CURSOR pymt_method_csr(p_cust_acct_id   IN NUMBER,
                           p_bill_to_id     IN NUMBER,
                           p_pymt_method_id IN NUMBER) IS
    SELECT 'Y'
    FROM  OKX_RECEIPT_METHODS_V
    WHERE customer_id = p_cust_acct_id
--For bug 8325912    AND site_use_id = p_bill_to_id
    AND id1 = p_pymt_method_id;

    l_pymt_method_valid_yn VARCHAR2(1);

    CURSOR bank_acct_csr(p_cust_acct_id IN NUMBER,
                         p_bill_to_id   IN NUMBER,
                         p_bank_acct_id IN NUMBER) IS
    SELECT 'Y'
    FROM okx_rcpt_method_accounts_v okx_custbkac
    WHERE SYSDATE < NVL(end_date_active,SYSDATE+1)
    AND customer_id = p_cust_acct_id
--For bug 8325912    AND customer_site_use_id = p_bill_to_id
    AND id1 = p_bank_acct_id;

    l_bank_acct_valid_yn VARCHAR2(1);
    -- Bug# 8219011

  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

/* Rule migration
    OPEN  l_hdrrl_csr('LABILL', 'BTO', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr into l_hdrrl_rec;
*/
      get_bill_to(
                  x_return_status => x_return_status,
                  p_chr_id        => p_chr_id,
                  x_bill_to_id    => l_okl_bill_to_id
                 );

    --If( l_hdrrl_csr%NOTFOUND ) Then
    IF( l_okl_bill_to_id IS NULL ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NOBTO');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;
    --CLOSE l_hdrrl_csr;

    --Bug# 8219011
    IF (l_okl_bill_to_id IS NOT NULL) THEN


      get_cust_account(
        x_return_status => x_return_status,
        p_chr_id        => TO_NUMBER(p_chr_id),
        x_cust_acc_id   => l_cust_acct_id
      );

      l_hdrrl_rec := NULL;
      OPEN l_hdrrl_csr('LABILL', 'LAPMTH', TO_NUMBER(p_chr_id));
      FETCH l_hdrrl_csr INTO l_hdrrl_rec;
      CLOSE l_hdrrl_csr;

      IF (l_hdrrl_rec.object1_id1 IS NOT NULL) THEN

        l_pymt_method_valid_yn := 'N';
        OPEN pymt_method_csr(p_cust_acct_id   => l_cust_acct_id,
                             p_bill_to_id     => l_okl_bill_to_id,
                             p_pymt_method_id => l_hdrrl_rec.object1_id1);
        FETCH pymt_method_csr INTO l_pymt_method_valid_yn;
        CLOSE pymt_method_csr;

        IF (l_pymt_method_valid_yn = 'N') THEN
          Okl_Api.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_PYMT_METHOD_INVALID');
        END IF;
      END IF;

      l_hdrrl_rec := NULL;
      OPEN l_hdrrl_csr('LABILL', 'LABACC', TO_NUMBER(p_chr_id));
      FETCH l_hdrrl_csr INTO l_hdrrl_rec;
      CLOSE l_hdrrl_csr;

      IF (l_hdrrl_rec.object1_id1 IS NOT NULL) THEN

        l_bank_acct_valid_yn := 'N';
        OPEN bank_acct_csr(p_cust_acct_id => l_cust_acct_id,
                           p_bill_to_id   => l_okl_bill_to_id,
                           p_bank_acct_id => l_hdrrl_rec.object1_id1);
        FETCH bank_acct_csr INTO l_bank_acct_valid_yn;
        CLOSE bank_acct_csr;

        IF (l_bank_acct_valid_yn = 'N') THEN
          Okl_Api.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_BANK_ACCT_INVALID');
        END IF;
      END IF;
    END IF;
    --Bug# 8219011

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_rl_csr%ISOPEN THEN
      CLOSE l_rl_csr;
    END IF;
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
  END check_rule_4new_lnrev;

  PROCEDURE check_rule_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);

     CURSOR Product_csr (p_contract_id IN okl_products_v.id%TYPE  ) IS
        SELECT pdt.id        product_id
              ,pdt.name      product_name
              ,CHR.sts_code  contract_status
              ,khr.deal_type deal_type
        FROM  okl_products_v    pdt
              ,okl_k_headers_v  khr
              ,okc_k_headers_b  CHR
        WHERE  1=1
        AND    khr.id = p_contract_id
        AND    pdt_id = pdt.id
        AND    khr.id = CHR.id;

      l_pdt_rec Product_csr%ROWTYPE;
      l_hdrrl_rec l_hdrrl_csr%ROWTYPE;

   BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  Product_csr(p_chr_id);
    FETCH Product_csr INTO l_pdt_rec;
    IF Product_csr%NOTFOUND THEN
       CLOSE Product_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE Product_csr;

    IF ( l_pdt_rec.deal_type <> 'LOAN-REVOLVING' ) THEN
        --Bug# 2833653
        IF Are_Assets_Inactive(p_chr_id => p_chr_id) = 'Y' THEN
            check_rule_constrs_4new(x_return_status, p_chr_id);
        END IF;
    ELSE
        check_rule_4new_lnrev(x_return_status, p_chr_id);
    END IF;

    IF (x_return_status = Okl_Api.G_RET_STS_ERROR ) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Bug 4917116
    check_evergreen_allowed(x_return_status, p_chr_id);
    IF (x_return_status = Okl_Api.G_RET_STS_ERROR ) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF Product_csr%ISOPEN THEN
      CLOSE Product_csr;
    END IF;

   END check_rule_constraints;

  PROCEDURE check_functional_constraints(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_dummy VARCHAR2(1) := '?';
    l_count NUMBER := 0;
    l_row_notfound BOOLEAN;
    l_token VARCHAR2(2000);
    --Added by dpsingh for LE Uptake
    l_diff         NUMBER;

    CURSOR con_le_roll_qt_le_csr(p_contract_id  IN NUMBER) IS
    SELECT 1 FROM
    OKC_K_HEADERS_B chr,
    OKL_K_HEADERS khr,
    OKL_K_LINES kle,
    OKC_K_LINES_B cle,
    OKL_TRX_QUOTES_B qte,
    OKC_LINE_STYLES_B cls
      WHERE cle.id = kle.id
           AND chr.id = p_contract_id
           AND chr.id = cle.chr_id
       AND chr.id = cle.dnz_chr_id
           AND cls.lty_code = 'FEE'
       AND cle.lse_id = cls.id
       AND kle.qte_id = qte.id
           AND chr.id = khr.id
       AND khr.legal_entity_id <> qte.legal_entity_id;

     CURSOR Product_csr (p_contract_id IN okl_products_v.id%TYPE  ) IS
        SELECT pdt.id        product_id
              ,pdt.name      product_name
              ,CHR.sts_code  contract_status
              --Bug# 4869443
              ,chr.start_date start_date
              ,chr.orig_system_source_code orig_system_source_code
              ,rul.rule_information1 Release_asset_yn
        FROM  okl_products_v    pdt
              ,okl_k_headers_v  khr
              ,okc_k_headers_b  CHR
              ,okc_rules_b      RUL
        WHERE  1=1
        AND    khr.id = p_chr_id
        AND    pdt_id = pdt.id
        AND    khr.id = CHR.id
        AND    rul.dnz_chr_id = p_chr_id
        AND    rul.rule_information_category = 'LARLES';
      l_pdt_rec Product_csr%ROWTYPE;

      -------------------
      --Bug# 4869443
      ------------------
      Cursor l_orig_ast_csr (p_chr_id in number) is
      select --trunc(orig_cleb.date_terminated) date_terminated,
             trunc(decode(sign(orig_cleb.end_date - orig_cleb.date_terminated),-1,orig_cleb.end_date,orig_cleb.date_terminated)) date_terminated,
             orig_clet.name asset_number
      from   okc_k_lines_b   orig_cleb,
             okc_k_lines_tl  orig_clet,
             okc_k_lines_b   cleb
      where  orig_clet.id  = orig_cleb.id
      and    orig_clet.language = userenv('LANG')
      and    orig_cleb.id       = cleb.orig_system_id1
      and    cleb.chr_id        = p_chr_id
      and    cleb.dnz_chr_id    = p_chr_id
      and    cleb.sts_code      <> 'ABANDONED'
      and    cleb.lse_id        = 33; --for financial asset line

      l_orig_ast_rec l_orig_ast_csr%ROWTYPE;
      l_termination_date varchar2(240);
      l_k_start_date     varchar2(240);
      l_icx_date_format  varchar2(240);
      -------------------
      --Bug# 4869443
      ------------------
--start:|   23-May-2008 cklee fixed bug: 6781324                                     |
    cursor l_salvage_csr(p_chr_id in number) is
    select txl.id,
           txl.asset_number,
           txl.original_cost,
           txl.salvage_value,
           txl.percent_salvage_value
    from   okl_txl_assets_b txl
    where  txl.dnz_khr_id = p_chr_id;

  ln_comp_prn_oec        NUMBER := 0;
  ln_comp_prn_salv       NUMBER := 0;
--end:|   23-May-2008 cklee fixed bug: 6781324                                     |

   BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

--start:|   23-May-2008 cklee fixed bug: 6781324                                     |
    For l_salvage_rec In l_salvage_csr(p_chr_id => p_chr_id)
    Loop

      IF (l_salvage_rec.original_cost IS NOT NULL AND
          l_salvage_rec.salvage_value IS NOT NULL OR
          l_salvage_rec.percent_salvage_value IS NOT NULL) THEN
          ln_comp_prn_oec := (l_salvage_rec.original_cost/100);
       --Bug# 3950089
        IF(nvl(l_salvage_rec.salvage_value,0) > l_salvage_rec.original_cost) THEN
       --IF(p_talv_rec.salvage_value > p_talv_rec.original_cost) THEN
          -- original cost is greater than salvage value
          -- halt validation as the above statments are true
--          RAISE G_EXCEPTION_HALT_VALIDATION;
         OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_VALIDATE_SALVAGE_VALUE',
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => l_salvage_rec.asset_number);


       --Bug# 3950089
        ELSIF (l_salvage_rec.percent_salvage_value > 100) THEN
       --ELSIF (p_talv_rec.percent_salvage_value > ln_comp_prn_oec) THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- halt validation as the above statments are true
--          RAISE G_EXCEPTION_HALT_VALIDATION;
         OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_VALIDATE_SALVAGE_VALUE',
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => l_salvage_rec.asset_number);
        END IF;
      ELSIF (l_salvage_rec.original_cost IS NOT NULL
         AND l_salvage_rec.salvage_value IS NOT NULL
         AND l_salvage_rec.percent_salvage_value IS NOT NULL) THEN
         ln_comp_prn_oec := (l_salvage_rec.original_cost/100);
         ln_comp_prn_salv := (l_salvage_rec.salvage_value/100);
         IF (l_salvage_rec.salvage_value > l_salvage_rec.original_cost) AND
          (l_salvage_rec.percent_salvage_value > ln_comp_prn_oec) THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- And original cost is greater than salvage value
          -- halt validation as the above statments are true
--          RAISE G_EXCEPTION_HALT_VALIDATION;
         OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_VALIDATE_SALVAGE_VALUE',
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => l_salvage_rec.asset_number);
         ELSIF (l_salvage_rec.salvage_value > l_salvage_rec.original_cost) OR
          (l_salvage_rec.percent_salvage_value > ln_comp_prn_oec) OR
          (ln_comp_prn_salv <> l_salvage_rec.percent_salvage_value)  THEN
          -- To Check if computed original_cost is greater than percent_salvage_value
          -- or original cost is greater than salvage value
          -- or the computed salvage value is not equal to percentage salvage value
          -- halt validation as the above statments are true
--          RAISE G_EXCEPTION_HALT_VALIDATION;
         OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => 'OKL_VALIDATE_SALVAGE_VALUE',
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => l_salvage_rec.asset_number);
         END IF;
      END IF;
    End Loop;
--end:|   23-May-2008 cklee fixed bug: 6781324                                     |

    OPEN  Product_csr(p_chr_id);
    FETCH Product_csr INTO l_pdt_rec;
    IF Product_csr%NOTFOUND THEN
       CLOSE Product_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE Product_csr;

    --Bug# 4869443
    If (nvl(l_pdt_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) <> 'OKL_RELEASE') and
       (nvl(l_pdt_rec.release_Asset_yn,'N') = 'Y') then
    Open l_orig_ast_csr(p_chr_id => p_chr_id);
    Loop
        Fetch l_orig_ast_csr into l_orig_ast_rec;
        Exit when l_orig_ast_csr%NOTFOUND;
        If l_pdt_rec.start_date <= l_orig_ast_rec.date_terminated Then
            -- Raise Error: start date of the contract should not be less than or equal to termination
            -- date of the asset.
            l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

            l_termination_date := to_char(l_orig_ast_rec.date_terminated,l_icx_date_format);
            l_k_start_date     := to_char(l_pdt_rec.start_date,l_icx_date_format);

            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_RELEASE_AST_TRMN_DATE',
                                  p_token1       => 'TERMINATION_DATE',
                                  p_token1_value => l_termination_date,
                                  p_token2       => 'ASSET_NUMBER',
                                  p_token2_value => l_orig_ast_rec.asset_number,
                                  p_token3       => 'CONTRACT_START_DATE',
                                  p_token3_value => l_k_start_date);
             x_return_status := OKL_API.G_RET_STS_ERROR;
        End If;
    End Loop;
    Close l_orig_ast_csr;

    IF (x_return_status = OKL_API.G_RET_STS_ERROR ) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    End If;
    --End Bug# 4869443

   --Added by dpsingh for LE Uptake
OPEN con_le_roll_qt_le_csr(p_chr_id);
FETCH con_le_roll_qt_le_csr INTO l_diff;
CLOSE con_le_roll_qt_le_csr;
IF l_diff = 1 THEN
    x_return_status := OKL_API.G_RET_STS_ERROR;
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_ROLLOVER_QUOTE_CONTRACT');
    RAISE G_EXCEPTION_HALT_VALIDATION;
END IF;

    --Bug# 2833653
    IF Are_Assets_Inactive(p_chr_id => p_chr_id) = 'Y' THEN
        check_func_constrs_4new(x_return_status, p_chr_id);
    END IF;

    IF (x_return_status = Okl_Api.G_RET_STS_ERROR ) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF Product_csr%ISOPEN THEN
      CLOSE Product_csr;
    END IF;
    --Bug# 4869443
    IF l_orig_ast_csr%ISOPEN THEN
      CLOSE l_orig_Ast_csr;
    END IF;

   END check_functional_constraints;

  -- Start of comments
  --
  -- Procedure Name  : check_tax_book_cost
  -- Description     : This process checks asset cost at TAX book for OP and DF lease.
  --                   If asset cost at TAX book is less than asset cost
  --                   at CORPORATE book, raise error
  --                   It is a configurable process
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0, dedey
  -- End of comments

  PROCEDURE check_tax_book_cost(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  l_hdr l_hdr_csr%ROWTYPE;
  l_txl l_txl_csr%ROWTYPE;
  l_asst asst_qty_csr%ROWTYPE;

  --Bug#3877032
  CURSOR txd_csr( kleid NUMBER ) IS
  SELECT txd.cost,
         txd.deprn_method_tax,
         txd.tax_book
  FROM   okl_txd_assets_b txd,
         okl_txl_assets_b txl
  WHERE  txd.tal_id = txl.id
  AND    txl.kle_id = kleid;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    IF ((INSTR( l_hdr.DEAL_TYPE, 'OP' )>0) OR
        (INSTR( l_hdr.DEAL_TYPE, 'DF' )>0))  THEN

      FOR l_lne IN l_lne_csr('FREE_FORM1', p_chr_id)
      LOOP

          OPEN asst_qty_csr(FinAsstId => l_lne.id);
          FETCH asst_qty_csr INTO l_asst;
          CLOSE asst_qty_csr;

          OPEN  l_txl_csr(l_asst.fa_id);
          FETCH l_txl_csr INTO l_txl;
          IF l_txl_csr%NOTFOUND THEN
              CLOSE l_txl_csr;
              RAISE G_EXCEPTION_HALT_VALIDATION; -- checking done on func. constraints
          END IF;
          CLOSE l_txl_csr;

          FOR l_txd_rec IN txd_csr (l_asst.fa_id)
          LOOP
             IF (l_txd_rec.cost < l_txl.depreciation_cost) THEN
                 Okl_Api.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_BASISPCNT_GT_100',
                     p_token1       => 'Line',
                     p_token1_value => l_lne.name,
                     p_token2       => 'Tax Book',
                     p_token2_value => l_txd_rec.tax_book);

                 x_return_status := Okl_Api.G_RET_STS_ERROR;
             END IF;
          END LOOP;

      END LOOP; -- l_lne_csr

    END IF; -- OP and DF lease


    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN G_EXCEPTION_HALT_VALIDATION THEN

        NULL; -- Do not do anything

     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF l_hdr_csr%ISOPEN THEN
          CLOSE l_hdr_csr;
       END IF;

       IF asst_qty_csr%ISOPEN THEN
          CLOSE asst_qty_csr;
       END IF;

       IF l_txl_csr%ISOPEN THEN
          CLOSE l_txl_csr;
       END IF;

       IF l_txd_csr%ISOPEN THEN
          CLOSE l_txd_csr;
       END IF;

  END check_tax_book_cost;
  -- Start of comments
  --
  -- Procedure Name  : check_capital_fee
  -- Description     : This process checks FEE lines with Capitalized Fee type
  --                   Validations include:
  --                     1. If fee line type stream type is capitalized and fee
  --                        line has no sub lines then 'ERROR'
  --                     2. Sum of capital_amount on capitalized fee sublines should be
  --                        equal to capital_amount on capitalized fee top line, else 'ERROR'.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0, dedey
  -- End of comments

  PROCEDURE check_capital_fee(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  CURSOR contract_csr (p_chr_id OKC_K_HEADERS_B.ID%TYPE) IS
  SELECT start_date
  FROM   okc_k_headers_b
  WHERE  id = p_chr_id;

  CURSOR fee_topline_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.id,
         NVL(line.capital_amount,0) capital_amount,
         line.start_date,
         strm.code strm_type
  FROM   okl_k_lines_full_v line,
         okc_k_items item,
         okl_strmtyp_source_v strm,
         okc_line_styles_v style,
         okc_statuses_b sts
  WHERE  line.dnz_chr_id             = p_chr_id
  AND    line.lse_id                 = style.id
  AND    line.sts_code               = sts.code
  AND    line.id                     = item.cle_id
  AND    item.object1_id1            = strm.id1
  AND    item.jtot_object1_code      = 'OKL_STRMTYP'
  AND    NVL(strm.capitalize_yn,'N') = 'Y'
  AND    sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
  AND    style.lty_code              = 'FEE'
  -- Bug 6497111 Start Udhenuko Added.
  AND    NVL(line.fee_purpose_code,'XXX') <> 'SALESTAX';
  -- Bug 6497111 End

  CURSOR fee_subline_csr (p_cle_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT id,
         NVL(capital_amount,0) capital_amount
  FROM   okl_k_lines_full_v line,
         okc_statuses_b sts
  WHERE  line.cle_id   = p_cle_id
  AND    line.sts_code = sts.code
  --Bug# 4959361: Include Terminated lines when fetching sub-line amount
  --AND    sts.ste_code not in ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');
  AND    sts.ste_code not in ( 'HOLD', 'EXPIRED', 'CANCELLED');

  --Bug#3877032
  CURSOR link_asset_csr (p_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT line.start_date
  FROM   okc_k_lines_b line,
         okc_k_items item
  WHERE  item.cle_id = p_line_id
  AND    item.object1_id1       = line.id
  AND    item.object1_id2       = '#'
  AND    line.dnz_chr_id        = p_chr_id
  AND    item.dnz_chr_id        = p_chr_id
  AND    item.jtot_object1_code = 'OKX_COVASST';

  l_subline_present     VARCHAR2(1);
  l_contract_start_date DATE;
  l_asset_start_date    DATE;
  l_sub_cap_amt         NUMBER;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

/*
    OPEN contract_csr (p_chr_id);
    FETCH contract_csr INTO l_contract_start_date;
    CLOSE contract_csr;
*/

    FOR fee_topline_rec IN fee_topline_csr(p_chr_id)
    LOOP

/* Checked against linked asset line
       IF (l_contract_start_date <> fee_topline_rec.start_date) THEN
           OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_CAP_FEE_ST_DATE',
               p_token1       => 'FEE_TYPE',
               p_token1_value => fee_topline_rec.strm_type
              );

           x_return_status := OKL_API.G_RET_STS_ERROR;
       END IF;
*/
       l_subline_present := 'N';
       l_sub_cap_amt     := 0;

       FOR fee_subline_rec IN fee_subline_csr (fee_topline_rec.id)
       LOOP
          l_subline_present := 'Y';
          l_sub_cap_amt := l_sub_cap_amt + fee_subline_rec.capital_amount;

/* removed for rebook change control
          OPEN link_asset_csr (fee_subline_rec.id);
          FETCH link_asset_csr INTO l_asset_start_date;
          CLOSE link_asset_csr;

          IF (l_asset_start_date <> fee_topline_rec.start_date) THEN
             OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_CAP_FEE_ST_DATE',
               p_token1       => 'FEE_TYPE',
               p_token1_value => fee_topline_rec.strm_type
              );

             x_return_status := OKL_API.G_RET_STS_ERROR;
          END IF;
*/
       END LOOP;

       IF (l_subline_present = 'N') THEN
           Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_CAP_FEE_NO_SUBLINE',
               p_token1       => 'FEE_TYPE',
               p_token1_value => fee_topline_rec.strm_type
              );

           x_return_status := Okl_Api.G_RET_STS_ERROR;

       ELSIF (fee_topline_rec.capital_amount <> l_sub_cap_amt) THEN
           Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_QA_CAP_FEE_AMT_ERROR',
               p_token1       => 'FEE_TYPE',
               p_token1_value => fee_topline_rec.strm_type
              );

           x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;

    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_capital_fee;

  -- Start of comments
  --
  -- Procedure Name  : check_fee_service_payment
  -- Description     : This process checks for payment type RENT
  --                   attached at FEE or SERVICE line level.
  --                   In case RENT is defined at FEE and SERVICE line
  --                   raise error during QA check
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0, dedey
  -- End of comments

  PROCEDURE check_fee_service_payment(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

--Bug#3931587
  CURSOR pmnt_csr (p_chr_id    OKC_K_HEADERS_B.ID%TYPE,
                   p_line_type OKC_LINE_STYLES_B.LTY_CODE%TYPE) IS
  SELECT COUNT(1)
  FROM   okc_rules_b rule,
         okc_rule_groups_b rgp,
         okc_k_lines_b line,
         okc_line_styles_b style,
         okl_strm_type_b strm
  WHERE  rgp.dnz_chr_id                 = p_chr_id
  AND    rgp.cle_id                     IS NOT NULL
  AND    rgp.cle_id                     = line.id
  AND    line.lse_id                    = style.id
  AND    style.lty_code                 = p_line_type
  AND    rgp.id                         = rule.rgp_id
  AND    rule.rule_information_category = 'LASLH'
  AND    rule.jtot_object1_code         = 'OKL_STRMTYP'
  AND    rule.object1_id1               = strm.id
  --AND    strm.code                      = 'RENT';
  AND    strm.stream_type_purpose       = 'RENT';

  l_count NUMBER := 0;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- Check for RENT on FEE line

    l_count := 0;
    OPEN pmnt_csr (p_chr_id,
                   'FEE');
    FETCH pmnt_csr INTO l_count;
    CLOSE pmnt_csr;

    IF (l_count <> 0) THEN
       Okl_Api.set_message(
                           G_APP_NAME,
                           'OKL_QA_INVALID_PMNT_TYPE',
                           'LINE_TYPE',
                           'FEE'
                          );
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    -- Check for RENT on SERVICE line
    l_count := 0;
    OPEN pmnt_csr (p_chr_id,
                   'SOLD_SERVICE');
    FETCH pmnt_csr INTO l_count;
    CLOSE pmnt_csr;

    IF (l_count <> 0) THEN
       Okl_Api.set_message(
                           G_APP_NAME,
                           'OKL_QA_INVALID_PMNT_TYPE',
                           'LINE_TYPE',
                           'SERVICE'
                          );
       x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

  END check_fee_service_payment;

  -- Start of comments
  --
  -- Procedure Name  : check_pmnt_start_dt
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_pmnt_start_dt(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

    CURSOR l_lne_pmnt_csr(ltycode VARCHAR2, chrid OKL_K_HEADERS.KHR_ID%TYPE) IS
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
               kle.start_date,
               kle.end_date
        FROM OKL_K_LINES_FULL_V kle,
             OKC_LINE_STYLES_B ls,
         OKC_STATUSES_B sts
        WHERE kle.lse_id = ls.id
              AND ls.lty_code = ltycode
              AND kle.dnz_chr_id = chrid
          AND sts.code = kle.sts_code
          AND sts.ste_code NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

    l_hdr_rec l_hdr_csr%ROWTYPE;
    --l_lne l_lne_csr%ROWTYPE;
    l_rl_rec1 l_rl_csr1%ROWTYPE;
    l_rl_rec l_rl_csr%ROWTYPE;

    l_fee_strm_type_rec fee_strm_type_csr%ROWTYPE;
    l_strm_name_rec strm_name_csr%ROWTYPE;
  BEGIN

    -- initialize return status
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN l_hdr_csr( p_chr_id );
    FETCH l_hdr_csr INTO l_hdr_rec;
    CLOSE l_hdr_csr;

    FOR l_lne_pmnt IN l_lne_pmnt_csr('FREE_FORM1', p_chr_id)
    LOOP

      FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLH', TO_NUMBER(p_chr_id), l_lne_pmnt.id )
      LOOP

        OPEN  strm_name_csr ( l_rl_rec1.object1_id1 );
        FETCH strm_name_csr INTO l_strm_name_rec;
        IF strm_name_csr%NOTFOUND THEN
            CLOSE strm_name_csr;
            RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
        END IF;
        CLOSE strm_name_csr;

        FOR l_rl_rec IN l_rl_csr (l_rl_rec1.slh_id, 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), l_lne_pmnt.id )
        LOOP
           IF(( l_rl_rec.rule_information2 IS NOT NULL) AND
              (TRUNC( Fnd_Date.canonical_to_date(l_rl_rec.rule_information2)) < TRUNC(l_lne_pmnt.start_date)))THEN

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_PMNT_LN_START_DT',
                  p_token1       => 'line',
                  p_token1_value => l_lne_pmnt.name,
                  p_token2       => 'payment type',
                  p_token2_value => l_strm_name_rec.name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
        END LOOP;
      END LOOP;
    END LOOP;

    FOR l_lne_pmnt IN l_lne_pmnt_csr('FEE', p_chr_id)
    LOOP
        FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), l_lne_pmnt.id )
        LOOP
           IF(( l_rl_rec1.rule_information2 IS NOT NULL) AND
          (TRUNC( Fnd_Date.canonical_to_date(l_rl_rec1.rule_information2)) < TRUNC(l_lne_pmnt.start_date)))THEN
          --( FND_DATE.canonical_to_date(l_rl_rec1.rule_information2) < l_hdr_rec.start_date))Then

               OPEN  fee_strm_type_csr  ( l_lne_pmnt.id, 'FEE' );
               FETCH fee_strm_type_csr INTO l_fee_strm_type_rec;
               CLOSE fee_strm_type_csr;

               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_PMNT_LN_START_DT',
                  p_token1       => 'line',
                  p_token1_value => l_fee_strm_type_rec.strm_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
        END LOOP;
    END LOOP;


    FOR l_lne_pmnt IN l_lne_pmnt_csr('SOLD_SERVICE', p_chr_id)
    LOOP
        FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), l_lne_pmnt.id )
        LOOP
           IF(( l_rl_rec1.rule_information2 IS NOT NULL) AND
          ( TRUNC(Fnd_Date.canonical_to_date(l_rl_rec1.rule_information2)) < TRUNC(l_lne_pmnt.start_date)))THEN
               Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_PMNT_LN_START_DT',
                  p_token1       => 'line',
                  p_token1_value => l_lne_pmnt.name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
           END IF;
        END LOOP;
    END LOOP;

    FOR l_rl_rec1 IN l_rl_csr1 ( 'LALEVL', 'LASLL', TO_NUMBER(p_chr_id), -1 )
    LOOP
       IF(( l_rl_rec1.rule_information2 IS NOT NULL) AND
          ( TRUNC(Fnd_Date.canonical_to_date(l_rl_rec1.rule_information2)) < TRUNC(l_hdr_rec.start_date)))THEN
           Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_PMNT_START_DT');
           x_return_status := Okl_Api.G_RET_STS_ERROR;
       END IF;
    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;
    -- no processing necessary; validation can continue with next column
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1            => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;

  END check_pmnt_start_dt;

  -- Start of comments
  --
  -- Procedure Name  : check_asset_tax
  -- Description     : This process checks tax rules attached to Asset.
  --                   1. If Tax status = Override, Override rate must be present
  --                   2. If Tax status = Exempt, Exempt number must be present
  --                   3. If Tax status = NULL, both override and exempt must be null
  --                   4. If both override and exempt are not null raise error
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0, dedey
  -- End of comments

  PROCEDURE check_asset_tax(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

  CURSOR asset_line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT line.id,
         line.name
  FROM   okl_k_lines_full_v line,
         okc_line_styles_v style,
         okc_statuses_b sts
  WHERE line. dnz_chr_id = p_chr_id
  AND   line.lse_id      = style.id
  AND   style.lty_code     = 'FREE_FORM1'
  AND   line.sts_code    = sts.code
  AND   sts.ste_code     NOT IN ( 'HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  CURSOR tax_rule_csr (rgcode OKC_RULE_GROUPS_B.RGD_CODE%TYPE,
                       rlcat  OKC_RULES_B.RULE_INFORMATION_CATEGORY%TYPE,
                       chrId NUMBER,
                       cleId NUMBER) IS
  SELECT crl.id slh_id,
         crl.object1_id1,
         crl.RULE_INFORMATION1,
         crl.RULE_INFORMATION2,
         crl.RULE_INFORMATION3,
         crl.RULE_INFORMATION4,
         crl.RULE_INFORMATION5,
         crl.RULE_INFORMATION6,
         crl.RULE_INFORMATION7,
         crl.RULE_INFORMATION10
  FROM   OKC_RULE_GROUPS_B crg,
         OKC_RULES_B crl
  WHERE  crl.rgp_id                        = crg.id
         AND crg.RGD_CODE                  = rgcode
         AND crl.RULE_INFORMATION_CATEGORY = rlcat
         AND crg.cle_id                    = cleId;

  tax_failed EXCEPTION;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR asset_line_rec IN asset_line_csr (p_chr_id)
    LOOP
       FOR tax_rule_rec IN tax_rule_csr ('LAASTX',
                                         'LAASTX',
                                         p_chr_id,
                                         asset_line_rec.id)
       LOOP

         IF (tax_rule_rec.rule_information1 = 'E'             -- Exempt
             AND
             tax_rule_rec.rule_information2 IS NULL) THEN
                Okl_Api.set_message(
                                G_APP_NAME,
                                'OKL_QA_EXEMPT_ERROR',
                                'ASSET_NUM',
                                asset_line_rec.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --RAISE tax_failed;
         ELSIF (tax_rule_rec.rule_information1 IS NULL -- Null
                AND
                tax_rule_rec.rule_information2 IS NOT NULL) THEN
                Okl_Api.set_message(
                                G_APP_NAME,
                                'OKL_QA_TAX_NULL',
                                'ASSET_NUM',
                                asset_line_rec.name);
                x_return_status := Okl_Api.G_RET_STS_ERROR;
                --RAISE tax_failed;
         END IF;
       END LOOP;

    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN tax_failed THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_asset_tax;


PROCEDURE check_subsidies_errors(
            x_return_status OUT NOCOPY VARCHAR2,
            p_chr_id IN NUMBER) IS

  --p_api_version VARCHAR2(4000) := '1.0';
  p_init_msg_list VARCHAR2(4000) DEFAULT Okl_Api.G_FALSE;
  x_msg_count NUMBER;
  x_msg_data  VARCHAR2(256);
  subsidy_applicable_yn VARCHAR2(10);
  l_subsidy_id NUMBER;
  l_asset_id NUMBER;
  x_subsidized VARCHAR2(1);

  CURSOR get_subsidy_for_asset(p_chr_id NUMBER) IS
  SELECT kle.subsidy_id   subsidy_id,
              cleb.cle_id      asset_cle_id,
              clet.name        subsidy_name,
              clet_asst.name   asset_number,
              cleb.id     subsidy_cle_id,
              cleb_asst.start_date asset_start_date,
              kle.amount,
              kle.subsidy_override_amount
  FROM   okl_k_lines       kle,
         okc_k_lines_tl    clet,
         okc_k_lines_b     cleb,
         okc_line_styles_b lseb,
         okc_k_lines_tl    clet_asst,
         okc_k_lines_b     cleb_asst,
         okc_line_styles_b lseb_asst
  WHERE  kle.id               =  cleb.id
  AND    clet.id              =  cleb.id
  AND    clet.LANGUAGE        =  USERENV('LANG')
  AND    cleb.cle_id          =  cleb_asst.id
  AND    cleb.dnz_chr_id      =  cleb_asst.dnz_chr_id
  AND    cleb.sts_code        <> 'ABANDONED'
  AND    lseb.id              =  cleb.lse_id
  AND    lseb.lty_code        = 'SUBSIDY'
  AND    clet_asst.id         = cleb_asst.id
  AND    clet_asst.LANGUAGE   = USERENV('LANG')
  AND    lseb_asst.id         = cleb_asst.lse_id
  AND    lseb_asst.lty_code   = 'FREE_FORM1'
  AND    cleb_asst.sts_code   <> 'ABANDONED'
  AND    cleb_asst.dnz_chr_id = p_chr_id
  AND    cleb_asst.chr_id     = p_chr_id ;
  get_subsidy_for_asset_rec get_subsidy_for_asset%ROWTYPE;

  CURSOR check_subsidy_recourse(p_subsidy_id NUMBER) IS
  SELECT recourse_yn
  FROM okl_subsidies_b
  WHERE id = p_subsidy_id;

  recourse_yn VARCHAR2(1);

  CURSOR check_refund_details(p_subsidy_cle_id NUMBER) IS
  SELECT pyd.vendor_id
  FROM okl_party_payment_dtls pyd,
       okc_k_party_roles_b cplb,
       okc_k_lines_b cleb
  WHERE pyd.cpl_id = cplb.id
  AND   cplb.cle_id = cleb.id
  AND   cplb.chr_id IS NULL
  AND   cplb.RLE_CODE = 'OKL_VENDOR'
  AND   cleb.id = p_subsidy_cle_id;

  check_refund_details_rec check_refund_details%ROWTYPE;

  lv_subsidy_pool_applicable_yn VARCHAR2(10);
  lx_subsidy_pool_id okl_subsidy_pools_b.id%TYPE;
  lx_sub_pool_curr_code okl_subsidy_pools_b.currency_code%TYPE;
  lx_pool_status okl_subsidy_pools_b.decision_status_code%TYPE;
  lx_pool_balance okl_subsidy_pools_b.total_subsidy_amount%TYPE;
  lv_subsidy_amount okl_k_lines.subsidy_override_amount%TYPE;
  -- sjalasut, added local variables to support logging
  l_module CONSTANT fnd_log_messages.MODULE%TYPE := 'okl.plsql.OKL_QA_DATA_INTEGRITY.CHECK_SUBSIDIES_ERRORS';
  l_debug_enabled VARCHAR2(10);
  is_debug_statement_on BOOLEAN;


  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    -- check if debug is enabled
    l_debug_enabled := Okl_Debug_Pub.check_log_enabled;
    -- check for logging on STATEMENT level
    is_debug_statement_on := Okl_Debug_Pub.check_log_on(l_module,Fnd_Log.LEVEL_STATEMENT);

    Okl_Subsidy_Process_Pvt.is_contract_subsidized(
                         p_api_version => 1.0,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_chr_id => p_chr_id,
                         x_subsidized => x_subsidized);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF (x_subsidized = Okl_Api.G_FALSE) THEN
      Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
      RETURN;
    END IF;

    FOR get_subsidy_for_asset_rec IN get_subsidy_for_asset(p_chr_id)
    LOOP
      l_subsidy_id := get_subsidy_for_asset_rec.subsidy_id;
      l_asset_id := get_subsidy_for_asset_rec.asset_cle_id;

      /*
       * sjalasut, Feb 18, 2005: Modified the call to include new parameter p_qa_checker_call and pass it as 'Y'
       * this parameter bypasses the subsidy pool check in the validate_subsidy_applicability procedure
       * as the same is being called here to pinpoint exact nature of failure in the subsidy / subsidy pool configuration.
       * Modification introduced as part of subsidy pools enhancement
       * START code changes
       */
      subsidy_applicable_yn := Okl_Asset_Subsidy_Pvt.validate_subsidy_applicability(p_subsidy_id => l_subsidy_id
                                                                                   ,p_asset_cle_id => l_asset_id
                                                                                   ,p_qa_checker_call => 'Y');
      /*
       * END code changes
       */

      IF (subsidy_applicable_yn = 'N') THEN
          Okl_Api.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_SUBSIDY_CRITERIA_MATCH',
                p_token1       => 'SUBSIDY_NAME',
                p_token1_value => get_subsidy_for_asset_rec.subsidy_name,
                p_token2       => 'ASSET_NUMBER',
                p_token2_value => get_subsidy_for_asset_rec.asset_number);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;

      OPEN check_subsidy_recourse(get_subsidy_for_asset_rec.subsidy_id);
      FETCH check_subsidy_recourse INTO recourse_yn;
      CLOSE check_subsidy_recourse;
      IF (recourse_yn = 'Y') THEN
        OPEN check_refund_details(get_subsidy_for_asset_rec.subsidy_cle_id);
        FETCH check_refund_details INTO check_refund_details_rec;
        IF (check_refund_details%NOTFOUND) THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => 'OKL_LA_SUBSIDY_PARTY_PYMT',
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => get_subsidy_for_asset_rec.subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => get_subsidy_for_asset_rec.asset_number);
        END IF;
        CLOSE check_refund_details;
      END IF;

      /*
       * sjalasut, Feb 18, 2005: added code to check for applicability of subsidy pool if the subsidy in context is attached with a subsidy pool.
       * code added as part of subsidy pools enhancement START
       */
      lv_subsidy_pool_applicable_yn := 'N'; -- need to reset this var as this is being used in a loop. the last usage should not be compared
      -- check if the subsidy has been associated with a subsidy pool, further pool validation depends only if the
      -- subsidy has an association with the pool
      lv_subsidy_pool_applicable_yn := Okl_Asset_Subsidy_Pvt.is_sub_assoc_with_pool(p_subsidy_id => l_subsidy_id
                                                                                   ,x_subsidy_pool_id => lx_subsidy_pool_id
                                                                                   ,x_sub_pool_curr_code => lx_sub_pool_curr_code);
      IF(lv_subsidy_pool_applicable_yn = 'Y')THEN
        -- write to log
        IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
          Okl_Debug_Pub.log_debug(Fnd_Log.LEVEL_STATEMENT,
                                  l_module,
                                  'subsidy '|| l_subsidy_id || ' is attached to subsidy pool '|| lx_subsidy_pool_id
                                  );
        END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on

        -- is active by code is called first as reading from a column is more economical than comparing date values
        -- if the pool status code is not ACTIVE then no date comparision would be done.
        lv_subsidy_pool_applicable_yn := Okl_Asset_Subsidy_Pvt.is_sub_pool_active(p_subsidy_pool_id => lx_subsidy_pool_id
                                                                                 ,x_pool_status => lx_pool_status );
        IF(lv_subsidy_pool_applicable_yn <> 'Y')THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_NOT_ACTIVE,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => get_subsidy_for_asset_rec.subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => get_subsidy_for_asset_rec.asset_number);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        -- validate if the asset start date lies between the effective dates of the subsidy pool
        lv_subsidy_pool_applicable_yn := Okl_Asset_Subsidy_Pvt.is_sub_pool_active_by_date(p_subsidy_pool_id => lx_subsidy_pool_id
                                                                   ,p_asset_date => get_subsidy_for_asset_rec.asset_start_date );
        IF(lv_subsidy_pool_applicable_yn <> 'Y')THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_ASSET_DATES_GAP,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => get_subsidy_for_asset_rec.subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => get_subsidy_for_asset_rec.asset_number);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        lx_pool_balance := 0;
        lv_subsidy_pool_applicable_yn := Okl_Asset_Subsidy_Pvt.is_balance_valid_before_add(p_subsidy_pool_id => lx_subsidy_pool_id
                                                                                          ,x_pool_balance => lx_pool_balance);
        IF(lv_subsidy_pool_applicable_yn <> 'Y')THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
          Okl_Api.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_BALANCE_INVALID,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => get_subsidy_for_asset_rec.subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => get_subsidy_for_asset_rec.asset_number);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        -- the check of subsidy pool balance is valid after addition of the subsidy amount is being written in separate PL/SQL
        -- block as we dont stop processing if error occurs here. all the assets should be processed
        BEGIN
          lv_subsidy_amount := 0;
          lv_subsidy_amount := NVL(get_subsidy_for_asset_rec.subsidy_override_amount,NVL(get_subsidy_for_asset_rec.amount,0));
          Okl_Asset_Subsidy_Pvt.is_balance_valid_after_add (p_subsidy_id => l_subsidy_id
                                ,p_asset_id => l_asset_id
                                ,p_subsidy_amount => lv_subsidy_amount
                                ,p_subsidy_name => get_subsidy_for_asset_rec.subsidy_name
                                ,x_return_status => x_return_status
                                ,x_msg_count     => x_msg_count
                                ,x_msg_data      => x_msg_data);
          -- write to log
          IF(NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on) THEN
            Okl_Debug_Pub.log_debug(Fnd_Log.LEVEL_STATEMENT,
                                    l_module,
                                    'okl_asset_subsidy_pvt.is_balance_valid_after_add returned with '|| x_return_status||' x_msg_data '||x_msg_data
                                    );
          END IF; -- end of NVL(l_debug_enabled,'N')='Y' AND is_debug_statement_on
        EXCEPTION WHEN OTHERS THEN
          x_return_status := Okl_Api.G_RET_STS_ERROR;
/*comment out to avoid duplicated error: cklee 09/12/2005
          OKL_API.set_message(
               p_app_name     => G_APP_NAME,
               p_msg_name     => G_SUB_POOL_BALANCE_INVALID,
               p_token1       => 'SUBSIDY_NAME',
               p_token1_value => get_subsidy_for_asset_rec.subsidy_name ,
               p_token2       => 'ASSET_NUMBER',
               p_token2_value => get_subsidy_for_asset_rec.asset_number);
*/
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END;
      END IF; -- end of lv_subsidy_pool_applicable_yn = 'Y'

      /*
       * sjalasut, Feb 18, 2005: added code to check for applicability of subsidy pool if the subsidy in context is attached with a subsidy pool.
       * code added as part of subsidy pools enhancement
       * END
       */
    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF check_subsidy_recourse%ISOPEN THEN
         CLOSE check_subsidy_recourse;
       END IF;

       IF check_refund_details%ISOPEN THEN
         CLOSE check_refund_details;
       END IF;

  END check_subsidies_errors;

PROCEDURE check_subsidies(
            x_return_status OUT NOCOPY VARCHAR2,
            p_chr_id IN NUMBER) IS

  --p_api_version VARCHAR2(4000) := '1.0';
  p_init_msg_list VARCHAR2(4000) DEFAULT Okl_Api.G_FALSE;
  stored_subsidy_amount NUMBER;
  calc_subsidy_amount NUMBER;
  x_subsidy_amount NUMBER;
  x_msg_count NUMBER;
  x_msg_data  VARCHAR2(256);
  x_subsidized VARCHAR2(1);

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_Subsidy_Process_Pvt.is_contract_subsidized(
                         p_api_version => 1.0,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count => x_msg_count,
                         x_msg_data => x_msg_data,
                         p_chr_id => p_chr_id,
                         x_subsidized => x_subsidized);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    IF (x_subsidized = Okl_Api.G_FALSE) THEN
      Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
      RETURN;
    END IF;

    Okl_Subsidy_Process_Pvt.get_contract_subsidy_amount(p_api_version => 1.0,
                                          p_init_msg_list => Okl_Api.G_FALSE,
                                          x_return_status => x_return_status,
                                          x_msg_count => x_msg_count,
                                          x_msg_data => x_msg_data,
                                          p_chr_id => p_chr_id,
                                          x_subsidy_amount => x_subsidy_amount);
    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    stored_subsidy_amount := x_subsidy_amount;
    Okl_Subsidy_Process_Pvt.calculate_contract_subsidy(p_api_version => 1.0,
                                          p_init_msg_list => Okl_Api.G_FALSE,
                                          x_return_status => x_return_status,
                                          x_msg_count => x_msg_count,
                                          x_msg_data => x_msg_data,
                                          p_chr_id => p_chr_id,
                                          x_subsidy_amount => x_subsidy_amount);

    IF x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF x_return_status = Okl_Api.G_RET_STS_ERROR THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;

    calc_subsidy_amount := x_subsidy_amount;
    IF (stored_subsidy_amount <> calc_subsidy_amount) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_SUBSIDY_AMOUNT_MATCH');
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END;

  -- Start of comments
  --
  -- Procedure Name  : check_credit_line
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_credit_line(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(1000);

  BEGIN
    --
    -- Check credit lines
    --
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    Okl_La_Validation_Util_Pvt.validate_crdtln_wrng (
                         p_api_version    => 1.0,
                         p_init_msg_list  => Okl_Api.G_FALSE,
                         x_return_status  => l_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_chr_id         => p_chr_id
                        );

    IF (l_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
       x_return_status := l_return_status;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  END check_credit_line;

  -- Start of comments
  --
  -- Procedure Name  : check_invoice_format
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_invoice_format(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(1000);
    l_invoice_format    OKC_RULES_B.RULE_INFORMATION1%TYPE;

    --Bug#3877032
    CURSOR l_invoice_format_csr IS
    SELECT rule.rule_information1
    FROM okc_rules_b rule,
         okc_rule_groups_b rgp
    WHERE rule.rgp_id = rgp.id
    AND   rgp.dnz_chr_id = p_chr_id
    AND   rgp.chr_id = p_chr_id
    AND   rgp.rgd_code = 'LABILL'
    AND   rule.rule_information_category = 'LAINVD';

  BEGIN
    --
    -- Check invoice format
    --
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN l_invoice_format_csr;
    FETCH l_invoice_format_csr INTO l_invoice_format;
    IF (l_invoice_format_csr%NOTFOUND OR l_invoice_format IS NULL) THEN
      x_return_status := Okl_Api.G_RET_STS_ERROR;
      Okl_Api.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_NO_INV_FORMAT');
    END IF;
    CLOSE l_invoice_format_csr;


    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  END check_invoice_format;

  -- Start of comments
  --
  -- Procedure Name  : check_tax_book_mapping
  -- Description     : Checks if tax book mapping exists for the tax book
  --                   to identify it as 'FEDERAL' or 'STATE'.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_tax_book_mapping(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR l_assets_txl_lines IS
    SELECT txl.asset_number asset_num,
           fa.id fa_id,
           txd.tax_book
    FROM  okc_k_items cim,
          okc_k_lines_V fa,
          okc_line_styles_b fa_lse,
          OKL_TRX_ASSETS trx,
          okl_txl_assets_b  txl,
          okl_txd_assets_v  txd,
          okc_statuses_b sts
    WHERE  cim.cle_id = fa.id
    AND  cim.dnz_chr_id = p_chr_id
    AND  fa.lse_id      = fa_lse.id
    AND  txd.tal_id     = txl.id
    AND  txl.kle_id     = fa.id
    AND  txl.tas_id     = trx.id
    AND  fa_lse.lty_code = 'FIXED_ASSET'
    AND  fa.dnz_chr_id = cim.dnz_chr_id
    AND  sts.code = fa.sts_code
    AND  sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
    AND  trx.tsu_code = 'ENTERED'
    AND  txl.tal_type = 'CFA';

    --Bug#3877032
    CURSOR l_check_tax_map_for_asset(p_tax_book VARCHAR2 ) IS
    SELECT 'Y'
    FROM  okl_sgn_translations sgn
    WHERE sgn.jtot_object1_code = 'FA_BOOK_CONTROLS'
    AND   sgn.object1_id1       = p_tax_book
    AND   sgn.sgn_code = 'STMP';

    l_assets_txl_lines_rec l_assets_txl_lines%ROWTYPE;
    l_tax_mapping_found VARCHAR2(1) DEFAULT 'N';
    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR l_assets_txl_lines_rec IN l_assets_txl_lines
    LOOP
      l_tax_mapping_found := 'N';
      OPEN l_check_tax_map_for_asset(l_assets_txl_lines_rec.tax_book);
      FETCH l_check_tax_map_for_asset INTO l_tax_mapping_found;
        IF (l_check_tax_map_for_asset%NOTFOUND) THEN
          Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_TAX_MAP',
              p_token1       => 'TAX_BOOK',
              p_token1_value => l_assets_txl_lines_rec.tax_book,
              p_token2       => 'ASSET_NUM',
              p_token2_value => l_assets_txl_lines_rec.asset_num);
          x_return_status := Okl_Api.G_RET_STS_ERROR;
        END IF;
      CLOSE l_check_tax_map_for_asset;
    END LOOP;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    IF l_check_tax_map_for_asset%ISOPEN THEN
      CLOSE l_check_tax_map_for_asset;
    END IF;

  END check_tax_book_mapping;

  --Bug# 3504680
  -- Start of comments
  --
  -- Procedure Name  : check_sales_type_lease
  -- Description     : Generates warning if the deal type is sales and the tax owner
  --                   is Lessee.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_sales_type_lease(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_hdr      l_hdr_csr%ROWTYPE;
    l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
    l_return_status    VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;

  BEGIN

    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    OPEN  l_hdrrl_csr('LATOWN', 'LATOWN', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr INTO l_hdrrl_rec;
    CLOSE l_hdrrl_csr;

    IF ((INSTR( l_hdr.DEAL_TYPE,'ST') > 0 ) AND (l_hdrrl_rec.RULE_INFORMATION1 <> 'LESSEE')) THEN
        Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_ST_LESSEE');
             -- notify caller of an error
        x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

    IF l_hdr_csr%ISOPEN THEN
      CLOSE l_hdr_csr;
    END IF;

    IF l_hdrrl_csr%ISOPEN THEN
      CLOSE l_hdrrl_csr;
    END IF;

  END check_sales_type_lease;

  -- Start of comments
  --
  -- Procedure Name  : check_payment_struct
  -- Description     : Bug 3325126,
  --                   Check for same payment amount in 2 consiqutive
  --                   payment line for LOAN, LOAN-REVOLVING contracts
  --                   and for contracts having financed fee line
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_payment_struct (
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    l_return_status     VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(1000);
    l_invoice_format    OKC_RULES_B.RULE_INFORMATION1%TYPE;

    CURSOR l_chr_csr (p_chr_id NUMBER) IS
    SELECT khr.id,
           khr.deal_type
    FROM   OKL_K_HEADERS khr
    WHERE  khr.id        = p_chr_id;

    CURSOR l_lne_csr (p_chr_id NUMBER) IS
    SELECT lne.id id,
           style.name line_type
    FROM   okc_k_lines_b lne,
           okc_line_styles_v style
    WHERE  dnz_chr_id = p_chr_id
    AND    style.id   = lne.lse_id;

    -- R12B Authoring OA Migration
    -- Validation of Sales Tax Financed Fee will be done
    -- after the Calculate Upfront Tax process

    CURSOR l_financed_csr (p_chr_id NUMBER) IS
    SELECT cle.id,
           style.name line_type
    FROM   okl_k_lines kle,
           okc_k_lines_b cle,
           okc_line_styles_v style
    WHERE  cle.dnz_chr_id = p_chr_id
    AND    cle.id         = kle.id
    AND    cle.lse_id     = style.id
    AND    kle.fee_type   = 'FINANCED'
    AND    NVL(kle.fee_purpose_code,'XXX') <> 'SALESTAX';

    --Bug#3877032
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
    l_prev_rate NUMBER; -- Bug 4766555
  BEGIN
    --
    -- Check payment lines for similar structure
    -- No 2 consecutive payment lines have same amount
    --
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    FOR l_chr_rec IN l_chr_csr (p_chr_id)
    LOOP
       IF (l_chr_rec.deal_type IN ('LOAN','LOAN-REVOLVING')) THEN
           FOR l_lne_rec IN l_lne_csr (p_chr_id)
           LOOP
              FOR l_strm_slh_rec IN l_strm_slh_csr (p_chr_id,
                                                    l_lne_rec.id)
              LOOP
                 l_prev_pmnt := NULL;
                 l_prev_rate := NULL; -- Bug 4766555
                 FOR l_strm_sll_rec IN l_strm_sll_csr (l_strm_slh_rec.rule_id,
                                                       l_strm_slh_rec.rgp_id)
                 LOOP
                    IF (l_strm_sll_rec.stub_day IS NOT NULL) THEN -- do not check
                        l_prev_pmnt := NULL; -- reset
                        l_prev_rate := NULL; -- reset
                    ELSE
                      -- Check payment amount here
                      IF (l_prev_pmnt = TO_NUMBER(NVL(l_strm_sll_rec.amt,'0')))
                        AND  -- Bug 4766555
                      (TO_NUMBER(NVL(l_prev_rate,0)) = TO_NUMBER(NVL(l_strm_sll_rec.rate,'0')))
                      THEN
                         -- Error
                         Okl_Api.set_message(
                                       G_APP_NAME,
                                       'OKL_QA_INVALID_PMNT',
                                       'LINE_TYPE',
                                       l_lne_rec.line_type,
                                       'PMNT_TYPE',
                                       l_strm_slh_rec.stream_type
                                      );
                         x_return_status := Okl_Api.G_RET_STS_ERROR;
                      ELSE
                         l_prev_pmnt := TO_NUMBER(NVL(l_strm_sll_rec.amt,'0'));
                         l_prev_rate := TO_NUMBER(NVL(l_strm_sll_rec.rate,'0'));
                      END IF; --check

                    END IF; --stub
                 END LOOP; --l_strm_sll_csr

              END LOOP; --l_strm_slh_csr

           END LOOP; --l_lne_csr

           -- Check the same for header payment, if any
           FOR l_strm_slh_rec IN l_strm_slh_csr (p_chr_id,
                                                 -1)
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
                                    'OKL_QA_INVALID_PMNT_HDR',
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
       ELSE

           -- check for Financed Fee only
           FOR l_financed_rec IN l_financed_csr (p_chr_id)
           LOOP
              FOR l_strm_slh_rec IN l_strm_slh_csr (p_chr_id,
                                                    l_financed_rec.id)
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
                                       l_financed_rec.line_type,
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
           END LOOP; --l_financed_csr

       END IF;-- deal_type
    END LOOP; --l_chr_csr;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

 EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1          => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

  END check_payment_struct;

  -- Start of comments
  --
  -- Procedure Name  : check_contract_dt_signed
  -- Description     : Bug 3670104,
  --                   Raise warning if contract signed date is not earlier than
  --                   contract start date.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_contract_dt_signed(
            x_return_status OUT NOCOPY VARCHAR2,
            p_chr_id IN NUMBER) IS

  l_hdr     l_hdr_csr%ROWTYPE;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    IF( l_hdr.DATE_SIGNED >= l_hdr.START_DATE) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_DATESIGNED_LT_START');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;
    END IF;

    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        NULL; -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

       IF l_hdr_csr%ISOPEN THEN
         CLOSE l_hdr_csr;
       END IF;

  END check_contract_dt_signed;

  --Bug# 4899328: Start
  -- Start of comments
  --
  -- Procedure Name  : check_asset_deprn_cost
  -- Description     : Displays a warning message if there is a difference
  --                   between the current depreciable cost in FA and the
  --                   depreciable cost updated/calculated during online rebook.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_asset_deprn_cost(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    --cursor to check if the contract is undergoing on-line rebook
    cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
    SELECT '!'
    FROM   okc_k_headers_b CHR,
           okl_trx_contracts ktrx
    WHERE  ktrx.khr_id_new = chr.id
    AND    ktrx.tsu_code = 'ENTERED'
    AND    ktrx.rbr_code is NOT NULL
    AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP
    AND    ktrx.representation_type = 'PRIMARY'
--
    AND    chr.id = p_chr_id
    AND    chr.orig_system_source_code = 'OKL_REBOOK';

    l_rbk_khr      VARCHAR2(1) DEFAULT '?';

    cursor l_corp_book_csr(p_chr_id in number) is
    select txl.id                tal_id ,
           txl.asset_number      asset_number,
           fab.cost              original_cost,
           txl.depreciation_cost new_cost
    from   okl_trx_assets           trx,
           okl_txl_assets_b         txl,
           okc_k_lines_b            cleb,
           okc_statuses_b sts,
           fa_books      fab,
           fa_additions  fa
    where  trx.id             = txl.tas_id
    and    trx.tsu_code       = 'ENTERED'
    and    trx.tas_type       = 'CRB'
    and    txl.kle_id         = cleb.id
    and    txl.tal_type       = 'CRB'
    and    cleb.dnz_chr_id    = p_chr_id
    and    cleb.lse_id        = 42
    and    sts.code           = cleb.sts_code
    and    sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED')
    and    fab.book_type_code  = txl.corporate_book
    and    fab.asset_id        = fa.asset_id
    and    fa.asset_number     = txl.asset_number
    and    fab.transaction_header_id_out is null;

    cursor l_tax_book_csr(p_tal_id in number) is
    select txd.asset_number,
           txd.tax_book,
           txd.cost new_cost,
           fab.cost original_cost
    from   okl_txd_assets_b txd,
           fa_books      fab,
           fa_additions  fa
    where  txd.tal_id          = p_tal_id
    and    fab.book_type_code  = txd.tax_book
    and    fab.asset_id        = fa.asset_id
    and    fa.asset_number     = txd.asset_number
    and    fab.transaction_header_id_out is null;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    --check for rebook contract
    l_rbk_khr := '?';
    OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);
    FETCH l_chk_rbk_csr INTO l_rbk_khr;
    CLOSE l_chk_rbk_csr;

    If l_rbk_khr = '!' Then

      For l_corp_book_rec In l_corp_book_csr(p_chr_id => p_chr_id)
      Loop

        If NVL(l_corp_book_rec.original_cost,0) <> NVL(l_corp_book_rec.new_cost,0) Then

          OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_LA_DEPRN_COST_CHG',
              p_token1       => 'ASSET_NUMBER',
              p_token1_value => l_corp_book_rec.asset_number);
          x_return_status := OKL_API.G_RET_STS_ERROR;

        Else

          For l_tax_book_rec In l_tax_book_csr(p_tal_id => l_corp_book_rec.tal_id)
          Loop

            If NVL(l_tax_book_rec.original_cost,0) <> NVL(l_tax_book_rec.new_cost,0) Then
              OKL_API.set_message(
                p_app_name     => G_APP_NAME,
                p_msg_name     => 'OKL_LA_DEPRN_COST_CHG',
                p_token1       => 'ASSET_NUMBER',
                p_token1_value => l_tax_book_rec.asset_number);
              x_return_status := OKL_API.G_RET_STS_ERROR;

              Exit;
            End If;

          End Loop;
        End If;
      End Loop;
    End If;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1             => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_asset_deprn_cost;
  --Bug# 4899328: End

  --Bug# 5032883: Start
  -- Start of comments
  --
  -- Procedure Name  : check_late_int_date
  -- Description     : Displays a warning message if the late interest date
  --                   : is earlier than contract start date
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_late_int_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS
     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
     l_hdr      l_hdr_csr%ROWTYPE;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr into l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;


    OPEN  l_hdrrl_csr('LALIGR', 'LAHUDT', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr into l_hdrrl_rec;

    If(( l_hdrrl_csr%FOUND ) AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL) AND
       (TRUNC( FND_DATE.canonical_to_date(l_hdrrl_rec.RULE_INFORMATION1)) < TRUNC(l_hdr.START_DATE) )) Then
            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LATE_INT_DATE');
             -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;
    CLOSE l_hdrrl_csr;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1             => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_late_int_date;
  -- bug 5032883 end;

  --Bug# 5032883: Start
  -- Start of comments
  --
  -- Procedure Name  : check_late_charge_date
  -- Description     : Displays a warning message if the late interest date
  --                 : is earlier than contract start date
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_late_charge_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS
     l_return_status     VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
     l_hdrrl_rec l_hdrrl_csr%ROWTYPE;
     l_hdr      l_hdr_csr%ROWTYPE;
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr into l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;


    OPEN  l_hdrrl_csr('LALCGR', 'LAHUDT', TO_NUMBER(p_chr_id));
    FETCH l_hdrrl_csr into l_hdrrl_rec;

    If(( l_hdrrl_csr%FOUND ) AND
       (l_hdrrl_rec.RULE_INFORMATION1 IS NOT NULL) AND
       ( TRUNC(FND_DATE.canonical_to_date(l_hdrrl_rec.RULE_INFORMATION1)) < TRUNC(l_hdr.START_DATE) )) Then
            OKL_API.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_LATE_CH_DATE');
             -- notify caller of an error
            x_return_status := OKL_API.G_RET_STS_ERROR;
    End If;
    CLOSE l_hdrrl_csr;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
        OKL_API.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1             => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_late_charge_date;
  -- bug 5032883 end;

 -- Bug 5716089 rkuttiya start
       -- Start of comments
       --
       -- Procedure Name  : check_reporting_pdt_strm
       -- Description     : ensure that all stream types selected in the
       --                 : contract exist as well in the reporting product
       -- Business Rules  :
       -- Parameters      :
       -- Version         : 1.0
    -- End of comments

PROCEDURE check_reporting_pdt_strm (
   x_return_status   OUT NOCOPY      VARCHAR2,
   p_chr_id          IN              NUMBER
)
IS
   l_return_status   VARCHAR2 (1)             := OKL_API.G_RET_STS_SUCCESS;
   l_product_rec     l_product_csr%ROWTYPE;
   l_rep_strm_rec    l_rep_strm_csr%ROWTYPE;
BEGIN
   x_return_status :=l_return_status;

   OPEN l_product_csr (p_chr_id => p_chr_id);
   FETCH l_product_csr INTO l_product_rec;

   IF l_product_rec.reporting_pdt_id is null
   THEN
      CLOSE l_product_csr;
      RETURN;
   END IF;

   CLOSE l_product_csr;

   FOR l_payment_strm_rec IN l_payment_strm_csr (p_chr_id => p_chr_id)
   LOOP
      OPEN l_rep_strm_csr (rep_pdt_id               =>
l_product_rec.reporting_pdt_id,
                           styid                    =>
l_payment_strm_rec.sty_id,
                           primary_sty_purpose      =>
l_payment_strm_rec.stream_type_purpose,
  contract_start_date      => l_product_rec.start_date
                          );
      FETCH l_rep_strm_csr INTO l_rep_strm_rec;

      IF l_rep_strm_csr%NOTFOUND
      THEN
         CLOSE l_rep_strm_csr;
         OKL_API.set_message (p_app_name      => G_APP_NAME,
                              p_msg_name      => 'OKL_QA_CHK_REP_PDT_STRM',
                              p_token1        => 'STREAM_TYPE',
                              p_token1_value  => l_payment_strm_rec.stream_name
                             );

         -- notify caller of an error
         x_return_status := OKL_API.G_RET_STS_ERROR;
         Return;
      END IF;

      CLOSE l_rep_strm_csr;
   END LOOP;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
            OKL_API.set_message(
              p_app_name      => G_APP_NAME,
              p_msg_name      => G_QA_SUCCESS);
    END IF;

    EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1                => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

 x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END;

-- Bug 5716089 rkuttiya end

--akrangan  bug 5362977 starts
 -- Start of comments
     --
     -- Procedure Name  : check_asset_category
     -- Description     : Displays a warning message if the inventory item has
     --                   changed during rebook and the asset category is not
     --                   the default for the newly selected item.
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments

     PROCEDURE check_asset_category(
       x_return_status            OUT NOCOPY VARCHAR2,
       p_chr_id                   IN  NUMBER
     ) IS

       --cursor to check if the contract is undergoing on-line rebook
       cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
       SELECT '!',
              chr.orig_system_id1
       FROM   okc_k_headers_b CHR,
              okl_trx_contracts ktrx
       WHERE  ktrx.khr_id_new = chr.id
       AND    ktrx.tsu_code = 'ENTERED'
       AND    ktrx.rbr_code is NOT NULL
       AND    ktrx.tcn_type = 'TRBK'
--rkuttiya added for 12.1.1 Multi GAAP
       and    ktrx.representation_type = 'PRIMARY'
--
       AND    chr.id = p_chr_id
       AND    chr.orig_system_source_code = 'OKL_REBOOK';

       l_rbk_khr      VARCHAR2(1) DEFAULT '?';
       l_orig_chr_id  okc_k_headers_b.id%TYPE;

       CURSOR l_fin_ast_cle_csr (p_chr_id IN NUMBER) IS
       SELECT cle.id,
              cle.orig_system_id1
       FROM  okc_k_lines_b  cle,
             okc_statuses_b sts
       WHERE cle.chr_id = p_chr_id
       AND   cle.lse_id = 33  --Financial Asset Line
       and   sts.code = cle.sts_code
       and   sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

       CURSOR l_sub_line_csr(p_chr_id   IN NUMBER
                            ,p_lty_code IN VARCHAR2
                            ,p_cle_id   IN NUMBER) IS
       SELECT cle.id,
              cim.object1_id1,
              cim.object1_id2
       FROM   okc_k_lines_b  cle,
              okc_k_items cim,
              okc_line_styles_b lse,
              okc_statuses_b sts
       WHERE cle.dnz_chr_id = p_chr_id
       AND   cle.cle_id = p_cle_id
       AND   cle.lse_id = lse.id
       AND   lse.lty_code = p_lty_code
       AND   cim.cle_id = cle.id
       AND   cim.dnz_chr_id = cle.dnz_chr_id
       AND   sts.code = cle.sts_code
       AND   sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

       l_orig_model_line_rec l_sub_line_csr%ROWTYPE;
       l_rbk_model_line_rec  l_sub_line_csr%ROWTYPE;
       l_fa_line_rec    l_sub_line_csr%ROWTYPE;

       CURSOR l_inv_item_csr(p_inv_item_id IN NUMBER,
                             p_org_id IN NUMBER) IS
       SELECT asset_category_id
       FROM mtl_system_items
       WHERE inventory_item_id = p_inv_item_id
       AND organization_id = p_org_id;

       l_inv_item_rec l_inv_item_csr%ROWTYPE;

       CURSOR l_fa_csr(p_asset_id IN NUMBER) IS
       SELECT asset_category_id,
              asset_number
       FROM fa_additions
       WHERE asset_id = p_asset_id;

       l_fa_rec l_fa_csr%ROWTYPE;

     BEGIN

       x_return_status := OKL_API.G_RET_STS_SUCCESS;

       --check for rebook contract
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr,l_orig_chr_id;
       CLOSE l_chk_rbk_csr;

       If l_rbk_khr = '!' Then

         For l_fin_ast_cle_rec In l_fin_ast_cle_csr(p_chr_id => p_chr_id)
         Loop

           OPEN l_sub_line_csr(p_chr_id => p_chr_id,
                               p_lty_code => 'ITEM',
                               p_cle_id => l_fin_ast_cle_rec.id);
           FETCH l_sub_line_csr INTO l_rbk_model_line_rec;
           CLOSE l_sub_line_csr;

           OPEN l_sub_line_csr(p_chr_id => l_orig_chr_id,
                               p_lty_code => 'ITEM',
                               p_cle_id => l_fin_ast_cle_rec.orig_system_id1);
           FETCH l_sub_line_csr INTO l_orig_model_line_rec;
           CLOSE l_sub_line_csr;

           -- Inventory Item has been changed during Rebook
           IF (l_orig_model_line_rec.object1_id1 <> l_rbk_model_line_rec.object1_id1) THEN

             OPEN l_sub_line_csr(p_chr_id => l_orig_chr_id,
                                 p_lty_code => 'FIXED_ASSET',
                                 p_cle_id => l_fin_ast_cle_rec.orig_system_id1);
             FETCH l_sub_line_csr INTO l_fa_line_rec;
             CLOSE l_sub_line_csr;

             OPEN l_inv_item_csr(p_inv_item_id => TO_NUMBER(l_rbk_model_line_rec.object1_id1),
                                 p_org_id      => TO_NUMBER(l_rbk_model_line_rec.object1_id2));
             FETCH l_inv_item_csr INTO l_inv_item_rec;
             CLOSE l_inv_item_csr;

             OPEN l_fa_csr(p_asset_id => TO_NUMBER(l_fa_line_rec.object1_id1));
             FETCH l_fa_csr INTO l_fa_rec;
             CLOSE l_fa_csr;

             -- Existing Asset Category is different from the Default Asset Category
             -- for the new Inventory Item.
             IF (l_inv_item_rec.asset_category_id IS NOT NULL AND
                 l_inv_item_rec.asset_category_id <> l_fa_rec.asset_category_id) THEN

               OKL_API.set_message(
                 p_app_name     => G_APP_NAME,
                 p_msg_name     => 'OKL_QA_DFLT_ASSET_CATEGORY',
                 p_token1       => 'ASSET_NUMBER',
                 p_token1_value => l_fa_rec.asset_number);
               x_return_status := OKL_API.G_RET_STS_ERROR;

             END IF;
           END IF;
         End Loop;
       End If;

       IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message(
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_QA_SUCCESS);
       END IF;

     EXCEPTION
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       OKL_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1                => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

       x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

     END check_asset_category;

--akrangan  bug 5362977 ends

-- rviriyal Bug# 5982201 Start
     -- Start of comments
     --
     -- Procedure Name  : check_vendor_active
     -- Description     : Displays an error message if the vendor on the contract is
     --                   not active on start date of the contract
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
   procedure check_vendor_active(
               x_return_status OUT NOCOPY VARCHAR2,
               p_chr_id IN NUMBER) AS

       cnt_start_date DATE;
       cnt_end_date DATE;
       vend_start_date DATE;
       vend_end_date DATE;
       vend_name varchar(240);

   begin
       x_return_status := Okl_Api.G_RET_STS_SUCCESS;

       open contract_dtls(p_chr_id);
       fetch contract_dtls into cnt_start_date, cnt_end_date;
       close contract_dtls;

       for vendor_rec in party_id_csr('OKL_VENDOR', p_chr_id)
       loop
           open vend_dtls(vendor_rec.OBJECT1_ID1);
           fetch vend_dtls into vend_start_date, vend_end_date, vend_name;
           close vend_dtls;

       --bug 7213709 start
       If vend_end_date is not null then
         if (trunc(vend_end_date)>=trunc(cnt_start_date)
            and trunc(vend_end_date)<=trunc(cnt_end_date) )
            or (trunc(vend_end_date)<trunc(cnt_start_date)) then
              Okl_Api.set_message(
                  p_app_name     => G_APP_NAME,
                  p_msg_name     => 'OKL_QA_VNDR_START_DT',
                  p_token1       => 'NAME',
                  p_token1_value =>  vend_name);
               x_return_status := Okl_Api.G_RET_STS_ERROR;
        end if;
       end if;

       /*
           if( trunc(cnt_start_date) < trunc(vend_start_date) OR
               (trunc(cnt_start_date) >= trunc(vend_start_date) AND
                trunc(cnt_start_date) >  trunc(vend_end_date))
             )THEN
             Okl_Api.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_VNDR_START_DT',
                     p_token1       => 'NAME',
                     p_token1_value =>  vend_name);
                  x_return_status := Okl_Api.G_RET_STS_ERROR;
           end if;
        */
       --bug 7213709 end

       end loop;

       IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message(
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_QA_SUCCESS);
       END IF;

       EXCEPTION
        WHEN OTHERS THEN
       -- store SQL error message on message stack
        OKL_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1                => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   End check_vendor_active;

   -- Start of comments
     --
     -- Procedure Name  : check_vendor_end_date
     -- Description     : Displays a warning message if the vendor on the contract
     --                   becomes inactive before the end date of the contract
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
   procedure check_vendor_end_date(
               x_return_status OUT NOCOPY VARCHAR2,
               p_chr_id IN NUMBER) AS

       cnt_start_date DATE;
       cnt_end_date DATE;
       vend_start_date DATE;
       vend_end_date DATE;
       vend_name varchar(240);

   begin

       x_return_status := Okl_Api.G_RET_STS_SUCCESS;
       open contract_dtls(p_chr_id);
       fetch contract_dtls into cnt_start_date, cnt_end_date;
       close contract_dtls;

       for vendor_rec in party_id_csr('OKL_VENDOR', p_chr_id)
       loop
           open vend_dtls(vendor_rec.OBJECT1_ID1);
           fetch vend_dtls into vend_start_date, vend_end_date, vend_name;
           close vend_dtls;

           if( trunc(cnt_start_date) >= trunc(vend_start_date) AND
               trunc(cnt_start_date) <=  trunc(vend_end_date)  AND
               trunc(cnt_end_date) >    trunc(vend_end_date)
             )THEN

              Okl_Api.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_VNDR_END_DT',
                     p_token1       => 'NAME',
                     p_token1_value =>  vend_name,
                     p_token2       => 'VNDR_END_DT',
                     p_token2_value =>  to_char(vend_end_date));
                  x_return_status := Okl_Api.G_RET_STS_ERROR;


           end if;

       end loop;

       IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message(
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_QA_SUCCESS);
       END IF;

       EXCEPTION
        WHEN OTHERS THEN
       -- store SQL error message on message stack
        OKL_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1                => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   End check_vendor_end_date;

   -- Start of comments
     --
     -- Procedure Name  : check_cust_active
     -- Description     : Displays an error message if customer and/or customer account
     --                   selected on the contract are inactive.
     -- Business Rules  :
     -- Parameters      :
     -- Version         : 1.0
     -- End of comments
   procedure check_cust_active(
               x_return_status OUT NOCOPY VARCHAR2,
               p_chr_id IN NUMBER) AS

       cursor cust_dtls(OBJECT1_ID1 NUMBER) is
       select STATUS, name
       from OKX_PARTIES_V
       where Id1 = OBJECT1_ID1;

       cust_status varchar(1);
       cust_name varchar(240);

       cursor cust_acct_dtls(p_chr_id NUMBER) is
       select STATUS, DESCRIPTION
       from OKX_CUSTOMER_ACCOUNTS_V
       where Id1 = (select cust_acct_id from okc_k_headers_b where id =p_chr_id);

       cust_acct_status varchar(1);
       cust_acct_desc varchar(30);

   begin
       x_return_status := Okl_Api.G_RET_STS_SUCCESS;

       for party_rec in party_id_csr('LESSEE', p_chr_id)
       loop
           open cust_dtls(party_rec.OBJECT1_ID1);
           fetch cust_dtls into cust_status, cust_name;
           close cust_dtls;

           if( cust_status is not null AND cust_status <> 'A')THEN
             Okl_Api.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_CUST_NOT_ACTIVE'
                     );
                  x_return_status := Okl_Api.G_RET_STS_ERROR;

           end if;

       end loop;
       IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           open cust_acct_dtls(p_chr_id);
           fetch cust_acct_dtls into cust_acct_status, cust_acct_desc;
           close cust_acct_dtls;

           if(cust_acct_status is not null and cust_acct_status <> 'A')THEN

              Okl_Api.set_message(
                     p_app_name     => G_APP_NAME,
                     p_msg_name     => 'OKL_QA_CUST_ACCT_INACTIVE',
                     p_token1       => 'ACCT',
                     p_token1_value =>  cust_acct_desc
                    );
                  x_return_status := Okl_Api.G_RET_STS_ERROR;


           end if;
       END IF;

       IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message(
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_QA_SUCCESS);
       END IF;

       EXCEPTION
        WHEN OTHERS THEN
       -- store SQL error message on message stack
        OKL_API.SET_MESSAGE(
            p_app_name        => G_APP_NAME,
            p_msg_name        => G_UNEXPECTED_ERROR,
            p_token1                => G_SQLCODE_TOKEN,
            p_token1_value    => SQLCODE,
            p_token2          => G_SQLERRM_TOKEN,
            p_token2_value    => SQLERRM);

           x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
   End check_cust_active;
   --rviriyal Bug# 5982201 End
   -- Start of comments
  --
  -- Procedure Name  : check_book_class_cmptblty
  -- Description     : Bug 6711559  ,
  --                   Raise Warning Message if the Present Value of rent is
  --                   the same or higher than the Asset Comparison amount.
  --                   The message should read "Present Value of Rent is 90% or
  --                   higher than Fair Value of Assets.  This is inconsistent
  --                   with Operating Lease Product ZZZ".
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_book_class_cmptblty(
            x_return_status OUT NOCOPY VARCHAR2,
            p_chr_id IN NUMBER) IS

  l_hdr     l_hdr_csr%ROWTYPE;
  x_msg_count         NUMBER;
  x_msg_data          VARCHAR2(1000);
  x_total_pv_rent     NUMBER;
  x_fair_value_assets NUMBER;


 CURSOR chk_product_status (p_chr_id IN NUMBER) IS
             SELECT
              pdt.name
        FROM  okl_products_v    pdt
              ,okl_k_headers_v  khr
              ,okc_k_headers_b  CHR
        WHERE  1=1
        AND    khr.id = p_chr_id
        AND    pdt_id = pdt.id
        AND    khr.id = CHR.id;

         l_product_name  okl_products_v.NAME%TYPE;
         l_lne     l_lne_csr%ROWTYPE;

  BEGIN
    x_return_status := Okl_Api.G_RET_STS_SUCCESS;

    OPEN  l_hdr_csr(p_chr_id);
    FETCH l_hdr_csr INTO l_hdr;
    IF l_hdr_csr%NOTFOUND THEN
       CLOSE l_hdr_csr;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE l_hdr_csr;

    OPEN chk_product_status (p_chr_id);
    FETCH chk_product_status INTO l_product_name;
    CLOSE chk_product_status;

    OPEN  l_lne_csr('FREE_FORM1', p_chr_id);
    FETCH l_lne_csr INTO l_lne;
    IF ( l_lne_csr%NOTFOUND ) THEN
            Okl_Api.set_message(
              p_app_name     => G_APP_NAME,
              p_msg_name     => 'OKL_QA_NO_ASSETS');
             -- notify caller of an error
            x_return_status := Okl_Api.G_RET_STS_ERROR;

   ELSE

    OKL_GENERATE_PV_RENT_PVT.generate_total_pv_rent
       (p_api_version => 1.0
       ,p_init_msg_list  => Okl_Api.G_FALSE
       ,p_khr_id         =>   p_chr_id
       ,x_total_pv_rent  =>    x_total_pv_rent
       ,x_return_status => x_return_status
       ,x_msg_count => x_msg_count
       ,x_msg_data => x_msg_data
       );

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   =>1.0
                                   ,p_init_msg_list => Okl_Api.G_FALSE
                                   ,x_return_status =>x_return_status
                                   ,x_msg_count     =>x_msg_count
                                   ,x_msg_data      =>x_msg_data
                                   ,p_formula_name  =>'FAIR_VALUE_ASSETS'
                                   ,p_contract_id   =>p_chr_id
                                   ,x_value         =>x_fair_value_assets);

    IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
        RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_fair_value_assets := x_fair_value_assets * 0.9;
  IF (l_hdr.DEAL_TYPE = 'LEASEOP') THEN
      IF (x_total_pv_rent >= x_fair_value_assets) THEN
       Okl_Api.set_message(
           p_app_name        => G_APP_NAME,
           p_msg_name        => 'OKL_QA_OP_FASB_MSG',
           p_token1             => 'PRODUCT_NAME',
           p_token1_value    => l_product_name);

       x_return_status := Okl_Api.G_RET_STS_ERROR;

       END IF;
    ELSIF (l_hdr.DEAL_TYPE IN  ('LEASEDF','LEASEST')) THEN
      IF (x_total_pv_rent < x_fair_value_assets) THEN

       Okl_Api.set_message(
           p_app_name        => G_APP_NAME,
           p_msg_name        => 'OKL_QA_DF_FASB_MSG',
           p_token1             => 'PRODUCT_NAME',
           p_token1_value    => l_product_name);

       x_return_status := Okl_Api.G_RET_STS_ERROR;

       END IF;
     END IF;
 END IF;
    CLOSE l_lne_csr;
    IF x_return_status = Okl_Api.G_RET_STS_SUCCESS THEN
        Okl_Api.set_message(
          p_app_name      => G_APP_NAME,
          p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION

     WHEN  G_EXCEPTION_HALT_VALIDATION THEN
        x_return_status := Okl_Api.G_RET_STS_ERROR;
        IF l_hdr_csr%ISOPEN THEN
       CLOSE l_hdr_csr;
    END IF;
       IF l_lne_csr%ISOPEN THEN
       CLOSE l_lne_csr;
       END IF;
       IF chk_product_status%ISOPEN THEN
       CLOSE chk_product_status;
       END IF;

        -- error reported, just exit from this process
     WHEN OTHERS THEN
       -- store SQL error message on message stack
       Okl_Api.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1       => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

       x_return_status := Okl_Api.G_RET_STS_UNEXP_ERROR;

        IF l_hdr_csr%ISOPEN THEN
       CLOSE l_hdr_csr;
    END IF;
       IF l_lne_csr%ISOPEN THEN
       CLOSE l_lne_csr;
       END IF;
       IF chk_product_status%ISOPEN THEN
       CLOSE chk_product_status;
       END IF;


  END check_book_class_cmptblty;

  --Bug# 8652738: Start
  -- Start of comments
  --
  -- Procedure Name  : check_exp_delivery_date
  -- Description     : Displays a warning message if there is a difference
  --                   between the expected delivery date and in service date
  --                   for an asset.
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_exp_delivery_date(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS

    CURSOR l_chr_csr(p_chr_id IN NUMBER) IS
    SELECT khr.expected_delivery_date
    FROM   okl_k_headers khr
    WHERE  khr.id = p_chr_id;

    l_chr_rec l_chr_csr%ROWTYPE;

    CURSOR l_larles_csr(p_chr_id IN NUMBER) IS
    SELECT rul.rule_information1 release_asset_yn
    FROM   okc_rules_b rul
    WHERE  rul.dnz_chr_id = p_chr_id
    AND    rul.rule_information_category = 'LARLES';

    l_larles_rec l_larles_csr%ROWTYPE;

    CURSOR l_corp_book_csr(p_chr_id in number) is
    SELECT txl.id                   tal_id,
           txl.asset_number         asset_number,
           txl.in_service_date      in_service_date
    FROM   okl_trx_assets           trx,
           okl_txl_assets_b         txl,
           okc_k_lines_b            cleb_fa,
           okc_statuses_b sts
    WHERE  trx.id               = txl.tas_id
    AND    trx.tsu_code         = 'ENTERED'
    AND    trx.tas_type         IN ('CFA','CRB')
    AND    txl.kle_id           = cleb_fa.id
    AND    txl.tal_type         IN ('CFA','CRB')
    AND    cleb_fa.dnz_chr_id   = p_chr_id
    AND    cleb_fa.lse_id       = 42
    AND    sts.code             = cleb_fa.sts_code
    AND    sts.ste_code NOT IN ('HOLD', 'TERMINATED', 'EXPIRED', 'CANCELLED');

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN l_chr_csr(p_chr_id => p_chr_id);
    FETCH l_chr_csr INTO l_chr_rec;
    CLOSE l_chr_csr;

    OPEN l_larles_csr(p_chr_id => p_chr_id);
    FETCH l_larles_csr INTO l_larles_rec;
    CLOSE l_larles_csr;

    IF ( l_chr_rec.expected_delivery_date is NOT NULL ) AND
       ( NVL(l_larles_rec.release_asset_yn,'N') = 'N' ) THEN

      FOR l_corp_book_rec In l_corp_book_csr(p_chr_id => p_chr_id)
      LOOP

        IF (l_corp_book_rec.in_service_date IS NOT NULL AND
            l_chr_rec.expected_delivery_date <> l_corp_book_rec.in_service_date) THEN

          OKL_API.set_message(
            p_app_name     => G_APP_NAME,
            p_msg_name     => 'OKL_QA_EXP_DELIVERY_DATE_WRN',
            p_token1       => 'ASSET_NUMBER',
            p_token1_value => l_corp_book_rec.asset_number);

            x_return_status := OKL_API.G_RET_STS_ERROR;

        END IF;
      END LOOP;

      IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
           OKL_API.set_message(
             p_app_name      => G_APP_NAME,
             p_msg_name      => G_QA_SUCCESS);
      END IF;

    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1          => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_exp_delivery_date;
  --Bug# 8652738: End

  --Bug# 5690875: Start
  -- Start of comments
  --
  -- Procedure Name  : check_pre_funding
  -- Description     : Displays a warning message if pre-funding amounts
  --                   have not been allocated to assets and/or expenses
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE check_pre_funding(
    x_return_status            OUT NOCOPY VARCHAR2,
    p_chr_id                   IN  NUMBER
  ) IS


  CURSOR l_pre_funding_csr(p_chr_id  NUMBER)
  IS
  select NVL(SUM(trx.amount),0) amount
  from okl_trx_ap_invoices_b trx
      ,okl_txl_ap_inv_lns_all_b txl
  where trx.id = txl.tap_id
  and trx.funding_type_code = 'PREFUNDING'
  and trx.trx_status_code in ('APPROVED', 'PROCESSED')
  and txl.khr_id = p_chr_id;

  l_pre_funding_rec l_pre_funding_csr%ROWTYPE;

  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OPEN l_pre_funding_csr(p_chr_id => p_chr_id);
    FETCH l_pre_funding_csr INTO l_pre_funding_rec;
    CLOSE l_pre_funding_csr;

    IF (l_pre_funding_rec.amount <> 0) THEN

      OKL_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => 'OKL_QA_PRE_FUNDING_WRN');

      x_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;

    IF x_return_status = OKL_API.G_RET_STS_SUCCESS THEN
      OKL_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_QA_SUCCESS);
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(
         p_app_name        => G_APP_NAME,
         p_msg_name        => G_UNEXPECTED_ERROR,
         p_token1          => G_SQLCODE_TOKEN,
         p_token1_value    => SQLCODE,
         p_token2          => G_SQLERRM_TOKEN,
         p_token2_value    => SQLERRM);

    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

  END check_pre_funding;
  --Bug# 5690875: End


END Okl_Qa_Data_Integrity;

/
