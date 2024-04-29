--------------------------------------------------------
--  DDL for Package Body OKL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VENDORMERGE_GRP" AS
  /* $Header: OKLRVMAB.pls 120.5 2007/09/10 15:34:35 pagarg noship $ */

  L_MODULE                   FND_LOG_MESSAGES.MODULE%TYPE;
  L_DEBUG_ENABLED            VARCHAR2(10);
  IS_DEBUG_PROCEDURE_ON      BOOLEAN;
  IS_DEBUG_STATEMENT_ON      BOOLEAN;
  ------------------------------------------------------------------------------
  -- PROCEDURE MERGE_VENDOR
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : MERGE_VENDOR
  -- Description     : This procedure updates OKL data when two vendors
  --                   are merged.
  -- Business Rules  : This procedure updates OKL data when two vendors
  --                   are merged.
  --
  -- Parameters      : p_vendor_id -        Represents Merge To Vendor.
  --                   p_dup_vendor_id -    Represents Merge From Vendor.
  --                   p_vendor_site_id -   Represents Merge To Vendor Site.
  --                   p_dup_vendor_site_id Represents Merge From Vendor Site
  --                   p_party_id -         Represents Merge To Party.
  --                   P_dup_party_id -     Represents Merge From Party
  --                   p_party_site_id -    Represents Merge To Party Site
  --                   p_dup_party_site_id -Represents Merge From Party Site
  --
  -- Version         : 1.0
  -- History         : 26-Dec-2006 Bug# 4541415 PAGARG created
  --
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE MERGE_VENDOR
    (p_api_version            IN            NUMBER
    ,p_init_msg_list          IN            VARCHAR2 DEFAULT FND_API.G_FALSE
    ,p_commit                 IN            VARCHAR2 DEFAULT FND_API.G_FALSE
    ,p_validation_level       IN            NUMBER   DEFAULT FND_API.G_VALID_LEVEL_FULL
    ,p_return_status          OUT  NOCOPY   VARCHAR2
    ,p_msg_count              OUT  NOCOPY   NUMBER
    ,p_msg_data               OUT  NOCOPY   VARCHAR2
    ,p_vendor_id              IN            NUMBER
    ,p_dup_vendor_id          IN            NUMBER
    ,p_vendor_site_id         IN            NUMBER
    ,p_dup_vendor_site_id     IN            NUMBER
    ,p_party_id               IN            NUMBER
    ,P_dup_party_id           IN            NUMBER
    ,p_party_site_id          IN            NUMBER
    ,p_dup_party_site_id      IN            NUMBER
    )
  IS
    -- Variables Declarations
    l_api_version   CONSTANT NUMBER       DEFAULT G_INIT_VERSION;
    l_api_name      CONSTANT VARCHAR2(30) DEFAULT 'MERGE_VENDOR';
    l_return_status          VARCHAR2(1);
    l_counter                NUMBER;
    l_program_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||l_api_name;
    l_last_updated_by        NUMBER;
    l_last_update_date       DATE;
    l_last_update_login      NUMBER;
    l_cplv_rec               OKC_CPL_PVT.cplv_rec_type;
    l_kplv_rec               OKL_KPL_PVT.kplv_rec_type;

    --This cursor fetches all those contracts, which have both source and destination
    --Vendors as the parties to the contract
    CURSOR chk_vendor_chr_csr (p_src_vendor_id NUMBER, p_des_vendor_id NUMBER)
    IS
      SELECT CHR.CONTRACT_NUMBER
           , CHR.ID
      FROM OKC_K_HEADERS_ALL_B CHR
         , OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
      WHERE CPRS.CHR_ID = CHR.ID
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_vendor_id
        AND CPRD.OBJECT1_ID1 = p_des_vendor_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CHR.SCS_CODE = 'LEASE'
        AND CPRS.CLE_ID IS NULL
        AND CPRD.CLE_ID IS NULL
        AND CPRS.CHR_ID = CPRD.CHR_ID
      GROUP BY CHR.CONTRACT_NUMBER, CHR.ID
      ORDER BY CHR.CONTRACT_NUMBER;
    chk_vendor_chr_rec chk_vendor_chr_csr%ROWTYPE;

    --This cursor fetches all those contracts along with the contract line id,
	--which have both source and destination Vendors as the parties to the contract line
    CURSOR chk_vendor_chr_ln_csr (p_src_vendor_id NUMBER, p_des_vendor_id NUMBER)
    IS
      SELECT CHR.CONTRACT_NUMBER
           , CHR.ID
           , CPRD.CLE_ID
      FROM OKC_K_HEADERS_ALL_B CHR
         , OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
      WHERE CPRS.DNZ_CHR_ID = CHR.ID
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_vendor_id
        AND CPRD.OBJECT1_ID1 = p_des_vendor_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CHR.SCS_CODE = 'LEASE'
        AND CPRS.CHR_ID IS NULL
        AND CPRD.CHR_ID IS NULL
        AND CPRS.CLE_ID = CPRD.CLE_ID
      GROUP BY CHR.CONTRACT_NUMBER, CHR.ID, CPRD.CLE_ID
      ORDER BY CHR.CONTRACT_NUMBER;
    chk_vendor_chr_ln_rec chk_vendor_chr_ln_csr%ROWTYPE;

    --This cursor returns the Party Role Id for both source and destination vendor
    --for a given Contract. It returns the Id for Party Role defined at Contract
    --Header level
    CURSOR party_role_dtls_csr (p_src_vendor_id NUMBER, p_des_vendor_id NUMBER, p_chr_id NUMBER)
    IS
      SELECT CPRS.ID CPRS_CPL_ID
           , CPRD.ID CPRD_CPL_ID
      FROM OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
      WHERE CPRS.DNZ_CHR_ID = p_chr_id
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_vendor_id
        AND CPRD.OBJECT1_ID1 = p_des_vendor_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRS.CLE_ID IS NULL
        AND CPRD.CLE_ID IS NULL
        AND CPRS.CHR_ID = CPRD.CHR_ID;
    party_role_dtls_rec party_role_dtls_csr%ROWTYPE;

    --This cursor returns the Party Role Id for both source and destination vendor
    --for a given Contract Line. It returns the Id for Party Role defined at Contract
    --Line level
    CURSOR party_role_dtls_ln_csr (p_src_vendor_id NUMBER, p_des_vendor_id NUMBER, p_chr_id NUMBER, p_cle_id NUMBER)
    IS
      SELECT CPRS.ID CPRS_CPL_ID
           , CPRD.ID CPRD_CPL_ID
      FROM OKC_K_PARTY_ROLES_B CPRS
         , OKC_K_PARTY_ROLES_B CPRD
      WHERE CPRS.DNZ_CHR_ID = p_chr_id
        AND CPRS.DNZ_CHR_ID = CPRD.DNZ_CHR_ID
        AND CPRS.OBJECT1_ID1 <> CPRD.OBJECT1_ID1
        AND CPRS.OBJECT1_ID1 = p_src_vendor_id
        AND CPRD.OBJECT1_ID1 = p_des_vendor_id
        AND CPRS.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRD.JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPRS.CHR_ID IS NULL
        AND CPRD.CHR_ID IS NULL
        AND CPRS.CLE_ID = p_cle_id
        AND CPRS.CLE_ID = CPRD.CLE_ID;
    party_role_dtls_ln_rec party_role_dtls_ln_csr%ROWTYPE;

    --This cursor verifies whether there is passthrough setup being done at either
    --Contract or Line level for the source/merged vendor
    CURSOR chk_passthrough_csr (p_chr_id NUMBER, p_cle_id NUMBER, p_src_cpl_id NUMBER)
    IS
      SELECT 1
      FROM OKL_PARTY_PAYMENT_HDR PPH
         , OKL_PARTY_PAYMENT_DTLS PPD
      WHERE DNZ_CHR_ID = p_chr_id
        AND NVL(CLE_ID, -1) = NVL(p_cle_id, NVL(CLE_ID, -1))
        AND PPH.ID = PPD.PAYMENT_HDR_ID
        AND PPD.CPL_ID = p_src_cpl_id;
    chk_passthrough_rec chk_passthrough_csr%ROWTYPE;

    --This cursor is used to fetch the Line Name for the given Line Id.
    --It is specific to Passthrough Fee line. Line Name is needed to be passed
    --as token value in the error message
    CURSOR fee_name_csr(p_cle_id NUMBER)
    IS
      SELECT STY.NAME FEE_NAME
      FROM OKC_K_ITEMS ITM
         , OKL_STRM_TYPE_TL STY
         , OKC_K_LINES_B CLE
      WHERE ITM.OBJECT1_ID1 = STY.ID
        AND ITM.JTOT_OBJECT1_CODE = 'OKL_STRMTYP'
        AND STY.LANGUAGE = USERENV('LANG')
        AND ITM.CLE_ID = CLE.ID
        AND CLE.LSE_ID = 52
        AND CLE.ID = p_cle_id
      UNION
      SELECT NAME
      FROM okc_k_lines_v
      WHERE id = p_cle_id
        AND lse_id = 48;
    l_fee_name OKL_STRM_TYPE_TL.NAME%TYPE;

  BEGIN
    l_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_debug_enabled := okl_debug_pub.check_log_enabled;

    l_last_updated_by   := FND_GLOBAL.USER_ID;
    l_last_update_date  := TRUNC(SYSDATE);
    l_last_update_login := FND_GLOBAL.LOGIN_ID;

    is_debug_procedure_on := okl_debug_pub.check_log_on(l_module
                                                       ,fnd_log.level_procedure);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on) THEN
        okl_debug_pub.log_debug(fnd_log.level_procedure
                               ,l_module
                               ,'start debug okl_vendormerge_grp.merge_vendor');
    END IF;  -- check for logging on STATEMENT level
    is_debug_statement_on := okl_debug_pub.check_log_on(l_module
                                                        ,fnd_log.level_statement);
    -- call START_ACTIVITY to create savepoint, check compatibility
    -- and initialize message list
    l_return_status := okl_api.start_activity(p_api_name      => l_api_name
                                             ,p_pkg_name      => G_PKG_NAME
                                             ,p_init_msg_list => p_init_msg_list
                                             ,p_api_version   => p_api_version
                                             ,l_api_version   => l_api_version
                                             ,p_api_type      => G_API_TYPE
                                             ,x_return_status => l_return_status);
    -- check if activity started successfully

    IF (l_return_status = okl_api.g_ret_sts_unexp_error) THEN
      RAISE okl_api.g_exception_unexpected_error;
    ELSIF (l_return_status = okl_api.g_ret_sts_error) THEN
      RAISE okl_api.g_exception_error;
    END IF;

    --Update OKL_TAX_ATTR_DEFINITIONS for references of Vendor Site
    UPDATE OKL_TAX_ATTR_DEFINITIONS
    SET VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_SITE_ID = p_dup_vendor_site_id;

    --Sales and Front End Objects
    --Update OKL_SERVICES_B for references of Vendor
    UPDATE OKL_SERVICES_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_ASSET_COMPONENTS_B for references of Vendor
    UPDATE OKL_ASSET_COMPONENTS_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_COST_ADJUSTMENTS_B for references of Vendor
    UPDATE OKL_COST_ADJUSTMENTS_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_FEES_B for references of Vendor
    UPDATE OKL_FEES_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_LEASE_OPPS_ALL_B for references of Vendor
    UPDATE OKL_LEASE_OPPS_ALL_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_LEASE_OPPS_ALL_B for references of Vendor
    UPDATE OKL_LEASE_OPPS_ALL_B
    SET ORIGINATING_VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE ORIGINATING_VENDOR_ID = p_dup_vendor_id;

    --Update OKL_LEASE_APPS_ALL_B for references of Vendor
    UPDATE OKL_LEASE_APPS_ALL_B
    SET ORIGINATING_VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE ORIGINATING_VENDOR_ID = p_dup_vendor_id;

    --Disbursements
    --Update OKL_CURE_FUND_SUMS_ALL for references of Vendor
    UPDATE OKL_CURE_FUND_SUMS_ALL
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_CURE_FUND_TRANS_ALL for references of Vendor
    UPDATE OKL_CURE_FUND_TRANS_ALL
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_CURE_REFUND_HEADERS_B for references of Vendor Site
    UPDATE OKL_CURE_REFUND_HEADERS_B
    SET VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_SITE_ID = p_dup_vendor_site_id;

    --Update OKL_CURE_REFUNDS_ALL for references of Vendor Site
    UPDATE OKL_CURE_REFUNDS_ALL
    SET VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_SITE_ID = p_dup_vendor_site_id;

    --Update OKL_CURE_REFUND_STAGE for references of Vendor
    UPDATE OKL_CURE_REFUND_STAGE
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_CURE_REPORTS_ALL for references of Vendor
    UPDATE OKL_CURE_REPORTS_ALL
    SET VENDOR_ID = p_vendor_id,
        VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id
      AND VENDOR_SITE_ID = p_dup_vendor_site_id;

    -- OKL_TRX_AP_INVS_ALL_B
    UPDATE OKL_TRX_AP_INVS_ALL_B
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    UPDATE OKL_TRX_AP_INVS_ALL_B
    SET IPVS_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE IPVS_ID = p_dup_vendor_site_id;

    --Insurance Objects
    --Update OKL_INS_POLICIES_ALL_B for references of Vendor
    UPDATE OKL_INS_POLICIES_ALL_B
    SET ISU_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE ISU_ID = p_dup_vendor_id;

    --Update OKL_INS_PRODUCTS_B for references of Vendor
    UPDATE OKL_INS_PRODUCTS_B
    SET ISU_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE ISU_ID = p_dup_vendor_id;

    --Update OKL_INSURER_RANKINGS for references of Vendor
    UPDATE OKL_INSURER_RANKINGS
    SET ISU_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE ISU_ID = p_dup_vendor_id;

    --Update OKC_RULES_B for reference of Vendor in object1_id1, which will
    --be identified based on value for JTOT_OBJECT1_CODE
    UPDATE OKC_RULES_B RUL
    SET OBJECT1_ID1 = TO_CHAR(p_vendor_id),
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE OBJECT1_ID1 = TO_CHAR(p_dup_vendor_id)
      AND JTOT_OBJECT1_CODE = 'OKX_VENDOR'
      AND EXISTS (SELECT ID
                  FROM OKL_K_HEADERS KHR
                  WHERE KHR.ID = RUL.DNZ_CHR_ID);

    --Update OKC_RULES_B for reference of Vendor Site in object2_id1, which will
    --be identified based on value for JTOT_OBJECT2_CODE
    UPDATE OKC_RULES_B RUL
    SET OBJECT2_ID1 = TO_CHAR(p_vendor_site_id),
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE OBJECT2_ID1 = TO_CHAR(p_dup_vendor_site_id)
      AND JTOT_OBJECT2_CODE IN ('OKX_PAYTO', 'OKX_VENDSITE')
      AND EXISTS (SELECT ID
                  FROM OKL_K_HEADERS KHR
                  WHERE KHR.ID = RUL.DNZ_CHR_ID);

    --Update OKC_RULES_B for reference of Vendor Site in object3_id1, which will
    --be identified based on value for JTOT_OBJECT3_CODE
    UPDATE OKC_RULES_B RUL
    SET OBJECT3_ID1 = TO_CHAR(p_vendor_site_id),
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE OBJECT3_ID1 = TO_CHAR(p_dup_vendor_site_id)
      AND JTOT_OBJECT3_CODE IN ('OKX_PAYTO', 'OKX_VENDSITE')
      AND EXISTS (SELECT ID
                  FROM OKL_K_HEADERS KHR
                  WHERE KHR.ID = RUL.DNZ_CHR_ID);

    --Update OKL_SUBSIDIES_ALL_B for reference of Vendor
    UPDATE OKL_SUBSIDIES_ALL_B
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_TXL_ASSETS_B for references of Vendor in SUPPLIER_ID
    UPDATE OKL_TXL_ASSETS_B
    SET SUPPLIER_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE SUPPLIER_ID = p_dup_vendor_id;

    --Update OKL_TXL_ASSETS_B for references of Vendor in RESIDUAL_SHR_PARTY_ID
    UPDATE OKL_TXL_ASSETS_B
    SET RESIDUAL_SHR_PARTY_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE RESIDUAL_SHR_PARTY_ID = p_dup_vendor_id;

    --Update OKL_TRX_SUBSIDY_POOLS for references of Vendor
    UPDATE OKL_TRX_SUBSIDY_POOLS
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_EXT_PAY_INVS_ALL_B for references of Vendor and Vendor Site
    --Both the updates can be done in single update as both Vendor and Vendor
    --Site will be there together in any record
    UPDATE OKL_EXT_PAY_INVS_ALL_B
    SET VENDOR_ID = p_vendor_id,
        VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id
      AND VENDOR_SITE_ID = p_dup_vendor_site_id;

    --Update OKL_QUOTE_SUBPOOL_USAGE for references of Vendor
    UPDATE OKL_QUOTE_SUBPOOL_USAGE
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Update OKL_EXT_BILLING_INTF_ALL for references of Vendor
    UPDATE OKL_EXT_BILLING_INTF_ALL
    SET TAX_VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE TAX_VENDOR_ID = p_dup_vendor_id;

    --Update OKL_EXT_BILLING_INTF_ALL for references of Vendor Site
    --Need a separate update as both Vendor and Vendor Site may not be available
    --together in all the records
    UPDATE OKL_EXT_BILLING_INTF_ALL
    SET TAX_VENDOR_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE TAX_VENDOR_SITE_ID = p_dup_vendor_site_id;

    --Update OKL_CNSLD_AP_INVS_ALL for references of Vendor
    UPDATE OKL_CNSLD_AP_INVS_ALL
    SET VENDOR_ID = p_vendor_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id;

    --Check if both Source and the Destination Vendor exists on the same contract
    --at line level for the same line.
    OPEN chk_vendor_chr_ln_csr(p_vendor_id, p_dup_vendor_id);
    LOOP
      FETCH chk_vendor_chr_ln_csr INTO chk_vendor_chr_ln_rec;
      EXIT WHEN chk_vendor_chr_ln_csr%NOTFOUND;

      --If there is such a contract which has both the vendors on the same line
      --then obtain the Party Role id for these vendors for a given line.
      OPEN party_role_dtls_ln_csr(p_dup_vendor_id, p_vendor_id, chk_vendor_chr_ln_rec.id, chk_vendor_chr_ln_rec.cle_id);
      FETCH party_role_dtls_ln_csr INTO party_role_dtls_ln_rec;
      CLOSE party_role_dtls_ln_csr;

      --Check for Passthrough setup at Contract Lines
      OPEN chk_passthrough_csr(chk_vendor_chr_ln_rec.id, chk_vendor_chr_ln_rec.cle_id, party_role_dtls_ln_rec.CPRS_CPL_ID);
      FETCH chk_passthrough_csr INTO chk_passthrough_rec;
        IF chk_passthrough_csr%FOUND
        THEN
          --If both the vendors are setup for Passthrough line then set the message
          --and raise the error.
          --Obtain the Passthrough Line name to be passed as token in error message
          OPEN fee_name_csr(chk_vendor_chr_ln_rec.cle_id);
          FETCH fee_name_csr INTO l_fee_name;
          CLOSE fee_name_csr;
          --Set the Error
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_VM_PASSTHROUGH_LINE_ERROR',
              p_token1        => 'LINE',
              p_token1_value  => l_fee_name,
              p_token2        => 'CONTRACT',
              p_token2_value  => chk_vendor_chr_ln_rec.contract_number);

          l_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          --If there is no passthrough setup which uses both the vendors at line level
          --then remove the party role using source vendor for the given line.
          l_kplv_rec.id := party_role_dtls_ln_rec.CPRS_CPL_ID;
          l_cplv_rec.id := party_role_dtls_ln_rec.CPRS_CPL_ID;

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call OKL_KPL_PVT.DELETE_ROW');
          END IF;

          --Remove the Party Role at the line level for the vendor getting merged
          --Call the following API to remove the record in OKL
          OKL_KPL_PVT.DELETE_ROW
               (p_api_version      => l_api_version,
                p_init_msg_list    => 'F',
                x_return_status    => l_return_status,
                x_msg_count        => p_msg_count,
                x_msg_data         => p_msg_data,
                p_kplv_rec         => l_kplv_rec);

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'end debug call OKL_KPL_PVT.DELETE_ROW');
          END IF;

          -- write to log
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_STATEMENT
               ,L_MODULE || ' Result of OKL_KPL_PVT.DELETE_ROW'
               ,'l_return_status ' || l_return_status);
          END IF; -- end of statement level debug

          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE');
          END IF;

          --Remove the Party Role at the line level for the vendor getting merged
          --Call the following API to remove the record in OKC
          OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE
               (p_api_version      => l_api_version,
                p_init_msg_list    => 'F',
                x_return_status    => l_return_status,
                x_msg_count        => p_msg_count,
                x_msg_data         => p_msg_data,
                p_cplv_rec         => l_cplv_rec);

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'end debug call OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE');
          END IF;

          -- write to log
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_STATEMENT
               ,L_MODULE || ' Result of OKC_CONTRACT_PARTY_PVT.DELETE_K_PARTY_ROLE'
               ,'l_return_status ' || l_return_status);
          END IF; -- end of statement level debug

          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      CLOSE chk_passthrough_csr;
    END LOOP;
    CLOSE chk_vendor_chr_ln_csr;

    --Check if both Source and the Destination Vendor exists on the same contract
    --at Contract Level
    OPEN chk_vendor_chr_csr(p_dup_vendor_id, p_vendor_id);
    LOOP
      FETCH chk_vendor_chr_csr INTO chk_vendor_chr_rec;
      EXIT WHEN chk_vendor_chr_csr%NOTFOUND;

      --If there is such a contract which has both the vendors at Contract level
      --then obtain the Party Role id for these vendors.
      OPEN party_role_dtls_csr(p_dup_vendor_id, p_vendor_id, chk_vendor_chr_rec.id);
      FETCH party_role_dtls_csr INTO party_role_dtls_rec;
      CLOSE party_role_dtls_csr;

      --Handle the Termination Quote Parties if both the vendors are parties
      --to same termination quote
      --Update the CPL_ID and PARTY_OBJECT1_ID1 of the merged vendor to point to
      --destination vendor
      UPDATE OKL_QUOTE_PARTIES QPT
      SET PARTY_OBJECT1_ID1 = TO_CHAR(p_vendor_id),
          LAST_UPDATED_BY = l_last_updated_by,
          LAST_UPDATE_DATE = l_last_update_date,
          LAST_UPDATE_LOGIN = l_last_update_login,
          CPL_ID = party_role_dtls_rec.CPRD_CPL_ID
      WHERE PARTY_OBJECT1_ID1 = TO_CHAR(p_dup_vendor_id)
        AND PARTY_JTOT_OBJECT1_CODE = 'OKX_VENDOR'
        AND CPL_ID = party_role_dtls_rec.CPRS_CPL_ID
        AND EXISTS (SELECT 1
                    FROM OKL_TRX_QUOTES_ALL_B QTE
                    WHERE QTE.ID = QPT.QTE_ID
                      AND QTE.KHR_ID = chk_vendor_chr_rec.id
                   );

      --Contract level evergreen passthrough terms and cond setup error
      --Check for Passthrough setup at Contract Header
      OPEN chk_passthrough_csr(chk_vendor_chr_rec.id, NULL, party_role_dtls_rec.CPRS_CPL_ID);
      FETCH chk_passthrough_csr INTO chk_passthrough_rec;
        IF chk_passthrough_csr%FOUND
        THEN
          --If both the vendors are used for Passthrough setup then set the message
          --and raise the error.
          --Set the Error
          OKL_API.SET_MESSAGE(
              p_app_name      => G_APP_NAME,
              p_msg_name      => 'OKL_VM_PASSTHROUGH_HDR_ERROR',
              p_token1        => 'CONTRACT',
              p_token1_value  => chk_vendor_chr_rec.contract_number);

          l_return_status := OKL_API.G_RET_STS_ERROR;
          RAISE OKL_API.G_EXCEPTION_ERROR;
        ELSE
          --If there is no passthrough setup which uses both the vendors at
          --contract level then remove the party role for source vendor
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'begin debug call OKL_JTOT_CONTACT_EXTRACT_PUB.DELETE_PARTY');
          END IF;

          --Remove the Party Role from the contract for the vendor getting merged
          OKL_JTOT_CONTACT_EXTRACT_PUB.DELETE_PARTY(
              l_api_version
             ,'F'
             ,l_return_status
             ,p_msg_count
             ,p_msg_data
             ,chk_vendor_chr_rec.id
             ,party_role_dtls_rec.CPRS_CPL_ID);

          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_PROCEDURE_ON)
          THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_PROCEDURE
               ,L_MODULE
               ,'end debug call OKL_JTOT_CONTACT_EXTRACT_PUB.DELETE_PARTY');
          END IF;

          -- write to log
          IF(L_DEBUG_ENABLED = 'Y' AND IS_DEBUG_STATEMENT_ON) THEN
            OKL_DEBUG_PUB.LOG_DEBUG(
                FND_LOG.LEVEL_STATEMENT
               ,L_MODULE || ' Result of OKL_JTOT_CONTACT_EXTRACT_PUB.DELETE_PARTY'
               ,'l_return_status ' || l_return_status);
          END IF; -- end of statement level debug

          IF(l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR)THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        END IF;
      CLOSE chk_passthrough_csr;
    END LOOP;
    CLOSE chk_vendor_chr_csr;

    --Termination Quotes Objects
    --Update OKL_QUOTE_PARTIES for references of Vendor, which will be identified
    --based on value for PARTY_JTOT_OBJECT1_CODE
    --This is needed for the cases in which there is only source vendor added in
    --the contract.
    UPDATE OKL_QUOTE_PARTIES
    SET PARTY_OBJECT1_ID1 = TO_CHAR(p_vendor_id),
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE PARTY_OBJECT1_ID1 = TO_CHAR(p_dup_vendor_id)
      AND PARTY_JTOT_OBJECT1_CODE = 'OKX_VENDOR';

    --Update OKL_PARTY_PAYMENT_DTLS for references of Vendor and Vendor Site
    --Passthrough setup update is fine in the case where there is only source
    --vendor used on the setup.
    UPDATE OKL_PARTY_PAYMENT_DTLS
    SET VENDOR_ID = p_vendor_id,
        PAY_SITE_ID = p_vendor_site_id,
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE VENDOR_ID = p_dup_vendor_id
      AND PAY_SITE_ID = p_dup_vendor_site_id;

    --Update OKC_K_PARTY_ROLES_B for references of Vendor
    --This will take care of the cases where only source vendor and not the destination
	--vendor is added to the contract. Both the vendor added to contract case is
	--handled separately above.
    UPDATE OKC_K_PARTY_ROLES_B CPR
    SET OBJECT1_ID1 = TO_CHAR(p_vendor_id),
        LAST_UPDATED_BY = l_last_updated_by,
        LAST_UPDATE_DATE = l_last_update_date,
        LAST_UPDATE_LOGIN = l_last_update_login
    WHERE OBJECT1_ID1 = TO_CHAR(p_dup_vendor_id)
      AND JTOT_OBJECT1_CODE = 'OKX_VENDOR'
      AND EXISTS (SELECT ID
                  FROM OKL_K_HEADERS KHR
                  WHERE KHR.ID = CPR.DNZ_CHR_ID);

    OKL_API.END_ACTIVITY(
        x_msg_count => p_msg_count
       ,x_msg_data  => p_msg_data);

    -- NULL is intentionally treated as false by this statement.
    IF p_commit = fnd_api.G_TRUE
	THEN
       COMMIT;
    END IF;

    p_return_status := l_return_status;
    okl_api.end_activity(x_msg_count =>  p_msg_count
                        ,x_msg_data  => p_msg_data);

    IF (l_debug_enabled = 'Y' AND is_debug_procedure_on)
    THEN
      okl_debug_pub.log_debug(fnd_log.level_procedure
                             ,l_module
                             ,'end debug okl_vendormerge_grp.merge_vendor');
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR
    THEN
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;
      IF chk_vendor_chr_ln_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_ln_csr;
      END IF;
      IF party_role_dtls_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_csr;
      END IF;
      IF party_role_dtls_ln_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_ln_csr;
      END IF;
      IF chk_passthrough_csr%ISOPEN
      THEN
        CLOSE chk_passthrough_csr;
      END IF;
      IF fee_name_csr%ISOPEN
      THEN
        CLOSE fee_name_csr;
      END IF;
      p_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_ERROR',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR
    THEN
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;
      IF chk_vendor_chr_ln_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_ln_csr;
      END IF;
      IF party_role_dtls_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_csr;
      END IF;
      IF party_role_dtls_ln_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_ln_csr;
      END IF;
      IF chk_passthrough_csr%ISOPEN
      THEN
        CLOSE chk_passthrough_csr;
      END IF;
      IF fee_name_csr%ISOPEN
      THEN
        CLOSE fee_name_csr;
      END IF;
      p_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OKL_API.G_RET_STS_UNEXP_ERROR',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
    WHEN OTHERS
    THEN
      IF chk_vendor_chr_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_csr;
      END IF;
      IF chk_vendor_chr_ln_csr%ISOPEN
      THEN
        CLOSE chk_vendor_chr_ln_csr;
      END IF;
      IF party_role_dtls_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_csr;
      END IF;
      IF party_role_dtls_ln_csr%ISOPEN
      THEN
        CLOSE party_role_dtls_ln_csr;
      END IF;
      IF chk_passthrough_csr%ISOPEN
      THEN
        CLOSE chk_passthrough_csr;
      END IF;
      IF fee_name_csr%ISOPEN
      THEN
        CLOSE fee_name_csr;
      END IF;
      p_return_status := OKL_API.HANDLE_EXCEPTIONS(
                           p_api_name  => l_api_name,
                           p_pkg_name  => G_PKG_NAME,
                           p_exc_name  => 'OTHERS',
                           x_msg_count => p_msg_count,
                           x_msg_data  => p_msg_data,
                           p_api_type  => G_API_TYPE);
  END MERGE_VENDOR;
END OKL_VENDORMERGE_GRP;

/
