--------------------------------------------------------
--  DDL for Package Body OKL_CREATE_KLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CREATE_KLE_PVT" as
/* $Header: OKLRKLLB.pls 120.56.12010000.7 2009/07/17 09:10:49 rpillay ship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_FND_APP                 CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_COL_NAME_TOKEN          CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_AMT_TOKEN               CONSTANT  VARCHAR2(200) := 'AMOUNT';
  G_REC_NAME_TOKEN          CONSTANT  VARCHAR2(200) := 'REC_INFO';
  G_PARENT_TABLE_TOKEN	    CONSTANT  VARCHAR2(200) := OKL_API.G_PARENT_TABLE_TOKEN;
  G_CHILD_TABLE_TOKEN	    CONSTANT  VARCHAR2(200) := OKL_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR        CONSTANT  VARCHAR2(200) := 'OKL_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN           CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN           CONSTANT  VARCHAR2(200) := 'SQLcode';
------------------------------------------------------------------------------------
-- GLOBAL OKL MESSAGES
------------------------------------------------------------------------------------
  G_INVALID_YN              CONSTANT  VARCHAR2(200) := 'OKL_INVALID_YN';
  G_INVALID_VALUE           CONSTANT  VARCHAR2(200) := 'OKL_LLA_NEGATIVE';
  G_DECIMAL_VALUE           CONSTANT  VARCHAR2(200) := 'OKL_LLA_DECIMAL_VAL';
  G_NO_PARENT_RECORD        CONSTANT  VARCHAR2(200) := 'OKL_NO_PARENT_RECORD';
  G_REQUIRED_VALUE          CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_NO_MATCHING_RECORD      CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_CALC_AMOUNT             CONSTANT  VARCHAR2(200) := 'OKL_LLA_CALC_AMOUNT';
  G_CREATION_FIN_LINE       CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_FIN_LINE';
  G_UPDATING_FIN_LINE       CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_FIN_LINE';
  G_CREATION_MODEL_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_MODEL_LINE';
  G_UPDATING_MODEL_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_MODEL_LINE';
  G_CREATION_MODEL_ITEM     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_MODEL_ITEM';
  G_UPDATING_MODEL_ITEM     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_MODEL_ITEM';
  G_CREATION_FA_LINE        CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_FA_LINE';
  G_UPDATING_FA_LINE        CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_FA_LINE';
  G_CREATION_FA_ITEM        CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_FA_ITEM';
  G_UPDATING_FA_ITEM        CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_FA_ITEM';
  G_CREATION_ADDON_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_ADDON_LINE';
  G_UPDATING_ADDON_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_ADDON_LINE';
  G_DELETING_ADDON_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_DELETING_ADDON_LINE';
  G_CREATION_ADDON_ITEM     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_ADDON_ITEM';
  G_UPDATING_ADDON_ITEM     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_ADDON_ITEM';
  G_CREATION_INSTS_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_INSTS_LINE';
  G_UPDATING_INSTS_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_INSTS_LINE';
  G_DELETING_INSTS_LINE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_DELETING_INSTS_LINE';
  G_MIN_INST_LINE           CONSTANT  VARCHAR2(200) := 'OKL_LLA_MIN_INST_LINE';
  G_CREATION_IB_LINE        CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_IB_LINE';
  G_UPDATING_IB_LINE        CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_IB_LINE';
  G_DELETING_IB_LINE        CONSTANT  VARCHAR2(200) := 'OKL_LLA_DELETING_IB_LINE';
  G_CREATION_IB_ITEM        CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_IB_ITEM';
  G_UPDATING_IB_ITEM        CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_IB_ITEM';
  G_CREATION_PARTY_ROLE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_CREATION_PARTY_ROLE';
  G_UPDATING_PARTY_ROLE     CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_PARTY_ROLE';
  G_ASSET_NUMBER            CONSTANT  VARCHAR2(200) := 'OKL_LLA_ASSET_NUMBER';
  G_DUPLICATE_SERIAL_NUM    CONSTANT  VARCHAR2(200) := 'OKL_LLA_SERIAL_NUM_DUP';
  G_GEN_INST_NUM_IB         CONSTANT  VARCHAR2(200) := 'OKL_LLA_GEN_INST_NUM_IB';
  G_GEN_ASSET_NUMBER        CONSTANT  VARCHAR2(200) := 'OKL_LLA_GEN_ASSET_NUMBER';
  G_LINE_STYLE              CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_STYLE';
  G_CNT_REC                 CONSTANT  VARCHAR2(200) := 'OKL_LLA_CNT_REC';
  G_ITEM_RECORD             CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITEM_RECORD';
  G_LINE_RECORD             CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
  G_INSTALL_BASE_NUMBER     CONSTANT  VARCHAR2(200) := 'OKL_LLA_INSTALL_BASE_NUMBER';
  G_FETCHING_INFO           CONSTANT  VARCHAR2(200) := 'OKL_LLA_FETCHING_INFO';
  G_INVALID_CRITERIA        CONSTANT  VARCHAR2(200) := 'OKL_LLA_INVALID_CRITERIA';
  G_SALVAGE_VALUE           CONSTANT  VARCHAR2(200) := 'OKL_LLA_SALVAGE_VALUE';
  G_STATUS                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_STATUS';
  G_CHR_ID                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_CHR_ID';
  G_LSE_ID                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_LSE_ID';
  G_KLE_ID                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_KLE_ID';
  G_TRX_ID                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_TRX_ID';
  G_ITI_ID                  CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITI_ID';
  G_AMOUNT_ROUNDING         CONSTANT  VARCHAR2(200) := 'OKL_LA_ROUNDING_ERROR';
------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';

 -- GLOBAL VARIABLES
-----------------------------------------------------------------------------------
  G_PKG_NAME                    CONSTANT  VARCHAR2(200) := 'OKL_CREATE_ASSET_PVT';
  G_APP_NAME                    CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_TRY_NAME                              OKL_TRX_TYPES_TL.NAME%TYPE     := 'Internal Asset Creation';
  G_LANGUAGE                              OKL_TRX_TYPES_TL.LANGUAGE%TYPE := 'US';
--  G_FA_TRY_NAME                           OKL_TRX_TYPES_V.NAME%TYPE       := 'CREATE ASSET LINES';
--  G_IB_TRY_NAME                           OKL_TRX_TYPES_V.NAME%TYPE       := 'CREATE_IB_LINES';
--  G_TRY_TYPE                              OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
  G_FORMULA_OEC                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_OEC';
  G_FORMULA_CAP                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_CAP_AMNT';
  G_FORMULA_RES                           OKL_FORMULAE_V.NAME%TYPE := 'LINE_RESIDUAL_VALUE';
  G_ID2                         CONSTANT  VARCHAR2(200) := '#';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
  G_LEASE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LEASE';
  G_LOAN_SCS_CODE                         OKC_K_HEADERS_V.SCS_CODE%TYPE := 'LOAN';
  G_QUOTE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE := 'QUOTE';
---------------------------------------------------------------------------------------------------------------
  --Added by dpsingh for LE uptake
  CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

  FUNCTION is_duplicate_serial_number(p_serial_number  OKL_TXL_ITM_INSTS.SERIAL_NUMBER%TYPE,
                                      p_item_id        OKL_TXL_ITM_INSTS.INVENTORY_ITEM_ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    ln_serial_number           NUMBER      := 0;
    -- cursor to get sequence number for asset number
    -- Bug 4698117


    CURSOR c_check_dup_serial_num IS
    SELECT 1 FROM OKL_TXL_ITM_INSTS
	  WHERE INVENTORY_ITEM_ID = p_item_id
	  AND SERIAL_NUMBER = p_serial_number
        AND NOT EXISTS (
        select 1 From okc_k_lines_b cleb
        where cleb.id=OKL_TXL_ITM_INSTS.kle_id
        and cleb.STS_CODE = 'ABANDONED'
    );
   --Bug# 4698117: End
  BEGIN
    OPEN  c_check_dup_serial_num;
    FETCH c_check_dup_serial_num INTO ln_serial_number;
    IF (c_check_dup_serial_num%NOTFOUND) Then
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE c_check_dup_serial_num;
    IF (ln_serial_number = 1) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DUPLICATE_SERIAL_NUM,
                           p_token1	      => 'COL_NAME',
                           p_token1_value => p_serial_number);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      IF c_check_dup_serial_num%ISOPEN THEN
        CLOSE c_check_dup_serial_num;
      END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
     RETURN x_return_status;
    WHEN OTHERS THEN
      IF c_check_dup_serial_num%ISOPEN THEN
        CLOSE c_check_dup_serial_num;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    RETURN x_return_status;
  END is_duplicate_serial_number;
---------------------------------------------------------------------------------------------------------------
  FUNCTION generate_instance_number_ib(x_instance_number_ib  OUT NOCOPY OKL_TXL_ITM_INSTS_V.INSTANCE_NUMBER_IB%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    -- cursor to get sequence number for asset number
    Cursor c_instance_no_ib IS
    select TO_CHAR(OKL_IBN_SEQ.NEXTVAL)
    FROM dual;
  BEGIN
    OPEN  c_instance_no_ib;
    FETCH c_instance_no_ib INTO x_instance_number_ib;
    IF (c_instance_no_ib%NOTFOUND) Then
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    END IF;
    CLOSE c_instance_no_ib;
    RETURN x_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_instance_no_ib%ISOPEN THEN
        CLOSE c_instance_no_ib;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    RETURN x_return_status;
  END generate_instance_number_ib;
---------------------------------------------------------------------------------------------------------------
  FUNCTION generate_asset_number(x_asset_number OUT NOCOPY OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    ln_dummy1                  NUMBER := 0;
    ln_dummy2                  NUMBER := 0;
    ln_dummy3                  NUMBER := 0;
    lv_asset_number            OKX_ASSETS_V.ASSET_NUMBER%TYPE;
    -- cursor to get sequence number for asset number
    Cursor c_asset_no IS
    select 'OKL'||OKL_FAN_SEQ.NEXTVAL
    FROM dual;

    -- cursor to get check the existence of asset number
    CURSOR c_txl_asset_number(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE)
    IS
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_B
                  WHERE asset_number = p_asset_number; --);

    /*CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSET_LINES_V
                  WHERE asset_number = p_asset_number; --); */

    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    FROM fa_additions a
    WHERE a.asset_number = p_asset_number
    and exists
     (
       select 1 from okc_k_items b
       where b.jtot_object1_code = 'OKX_ASSET'
       and   b.object1_id1 = to_char(a.asset_id)
     );


    CURSOR c_okx_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number; --);

  BEGIN
    OPEN  c_asset_no;
    FETCH c_asset_no INTO x_asset_number;
    IF (c_asset_no%NOTFOUND) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	   => g_app_name,
                          p_msg_name	   => g_unexpected_error,
                          p_token1	   => g_sqlcode_token,
                          p_token1_value => sqlcode,
           			      p_token2	   => g_sqlerrm_token,
              			  p_token2_value => sqlerrm);
    END IF;
    CLOSE c_asset_no;

    LOOP
      lv_asset_number := x_asset_number;

      OPEN  c_txl_asset_number(lv_asset_number);
      FETCH c_txl_asset_number INTO ln_dummy1;
      IF c_txl_asset_number%NOTFOUND THEN
        ln_dummy1 := 0;
      END IF;
      CLOSE c_txl_asset_number;

      OPEN c_okx_asset_lines_v(lv_asset_number);
      FETCH c_okx_asset_lines_v INTO ln_dummy2;
      IF c_okx_asset_lines_v%NOTFOUND THEN
        ln_dummy2 := 0;
      END IF;
      CLOSE c_okx_asset_lines_v;

      OPEN c_okx_assets_v(lv_asset_number);
      FETCH c_okx_assets_v INTO ln_dummy3;
      IF c_okx_assets_v%NOTFOUND THEN
        ln_dummy3 := 0;
      END IF;
      CLOSE c_okx_assets_v;

      IF ln_dummy1 = 1 OR
         ln_dummy2 = 1 OR
         ln_dummy3 = 1 THEN
        OPEN  c_asset_no;
        FETCH c_asset_no INTO x_asset_number;
        IF (c_asset_no%NOTFOUND) THEN
          x_return_status := OKC_API.G_RET_STS_ERROR;
          OKL_API.SET_MESSAGE(p_app_name 	   => g_app_name,
                              p_msg_name	   => g_unexpected_error,
                              p_token1	   => g_sqlcode_token,
                              p_token1_value => sqlcode,
           			          p_token2	   => g_sqlerrm_token,
                 			  p_token2_value => sqlerrm);
        END IF;
        CLOSE c_asset_no;
      ELSE
        EXIT;
      END IF;
    END LOOP;

    RETURN x_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_asset_no%ISOPEN THEN
        CLOSE c_asset_no;
      END IF;
      IF c_txl_asset_number%ISOPEN THEN
        CLOSE c_txl_asset_number;
      END IF;
      IF c_okx_asset_lines_v%ISOPEN THEN
        CLOSE c_okx_asset_lines_v;
      END IF;
      IF c_okx_assets_v%ISOPEN THEN
        CLOSE c_okx_assets_v;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	     => g_sqlcode_token,
                          p_token1_value => sqlcode,
            			  p_token2	     => g_sqlerrm_token,
            			  p_token2_value => sqlerrm);
    RETURN x_return_status;
  END generate_asset_number;
----------------------------------------------------------------------------------------------------------
  FUNCTION get_sts_code(p_dnz_chr_id IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        p_cle_id     IN  OKC_K_LINES_B.CLE_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        x_sts_code   OUT NOCOPY OKC_K_HEADERS_B.STS_CODE%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_get_tls_sts_code(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT chrv.sts_code
    FROM OKC_K_HEADERS_V chrv
    WHERE chrv.id = p_dnz_chr_id;

    CURSOR c_get_sls_sts_code(p_cle_id OKC_K_LINES_B.CLE_ID%TYPE) IS
    SELECT cle.sts_code
    FROM OKC_K_LINES_V cle
    WHERE cle.id = p_cle_id;
  BEGIN
    -- Both p_dnz_chr_id and p_cle_id are not to be given
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       -- store SQL error message on message stack
       -- Notify Error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID and CLE_ID');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    --  Getting the TOP Line STS CODE
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_tls_sts_code(p_dnz_chr_id);
       FETCH c_get_tls_sts_code INTO x_sts_code;
       IF c_get_tls_sts_code%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.STS_CODE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_tls_sts_code;
       IF (x_sts_code IS NULL OR
          x_sts_code = OKL_API.G_MISS_CHAR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'sts_code');
          RAISE G_EXCEPTION_STOP_VALIDATION;
       END IF;
    END IF;
    --  Getting the SUB Line STS CODE
    IF (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_sls_sts_code(p_cle_id);
       FETCH c_get_sls_sts_code INTO x_sts_code;
       IF c_get_sls_sts_code%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.STS_CODE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_sls_sts_code;
       IF (x_sts_code IS NULL OR
          x_sts_code = OKL_API.G_MISS_CHAR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_REQUIRED_VALUE,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'sts_code');
          RAISE G_EXCEPTION_STOP_VALIDATION;
       END IF;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_tls_sts_code%ISOPEN THEN
        CLOSE c_get_tls_sts_code;
     END IF;
     -- if the cursor is open
     IF c_get_sls_sts_code%ISOPEN THEN
        CLOSE c_get_sls_sts_code;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_tls_sts_code%ISOPEN THEN
        CLOSE c_get_tls_sts_code;
     END IF;
     -- if the cursor is open
     IF c_get_sls_sts_code%ISOPEN THEN
        CLOSE c_get_sls_sts_code;
     END IF;
     RETURN(x_return_status);
  END get_sts_code;
----------------------------------------------------------------------------------------------------------------
  FUNCTION get_end_date(p_dnz_chr_id IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        p_cle_id     IN  OKC_K_LINES_B.CLE_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        x_end_date   OUT NOCOPY OKC_K_HEADERS_B.END_DATE%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_get_tls_end_date(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT chrv.end_Date
    FROM OKC_K_HEADERS_V chrv
    WHERE chrv.id = p_dnz_chr_id;

    CURSOR c_get_sls_end_date(p_cle_id OKC_K_LINES_B.CLE_ID%TYPE) IS
    SELECT cle.end_date
    FROM OKC_K_LINES_V cle
    WHERE cle.id = p_cle_id;
  BEGIN
    -- Both p_dnz_chr_id and p_cle_id are not to be given
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       -- store SQL error message on message stack
       -- Notify Error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID and CLE_ID');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    --  Getting the TOP Line STS CODE
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_tls_end_date(p_dnz_chr_id);
       FETCH c_get_tls_end_date INTO x_end_date;
       IF c_get_tls_end_date%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.END_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_tls_end_date;
    END IF;
    --  Getting the SUB Line STS CODE
    IF (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_sls_end_date(p_cle_id);
       FETCH c_get_sls_end_date INTO x_end_date;
       IF c_get_sls_end_date%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.END_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_sls_end_date;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_tls_end_date%ISOPEN THEN
        CLOSE c_get_tls_end_date;
     END IF;
     -- if the cursor is open
     IF c_get_sls_end_date%ISOPEN THEN
        CLOSE c_get_sls_end_date;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_tls_end_date%ISOPEN THEN
        CLOSE c_get_tls_end_date;
     END IF;
     -- if the cursor is open
     IF c_get_sls_end_date%ISOPEN THEN
        CLOSE c_get_sls_end_date;
     END IF;
     RETURN(x_return_status);
  END get_end_date;
----------------------------------------------------------------------------------------------------------------
  FUNCTION get_start_date(p_dnz_chr_id IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        p_cle_id     IN  OKC_K_LINES_B.CLE_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        x_start_date   OUT NOCOPY OKC_K_HEADERS_B.START_DATE%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    lv_orig_sys_source_code    OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    ln_orig_system_id1         OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    ld_start_date              OKC_K_LINES_B.START_DATE%TYPE;
    CURSOR c_get_tls_start_date(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT chrv.start_Date,
           chrv.orig_system_source_code,
           chrv.orig_system_id1
    FROM OKC_K_HEADERS_V chrv
    WHERE chrv.id = p_dnz_chr_id;

    CURSOR c_get_sls_start_date(p_cle_id OKC_K_LINES_B.CLE_ID%TYPE) IS
    SELECT cle.start_date
    FROM OKC_K_LINES_V cle
    WHERE cle.id = p_cle_id;

    CURSOR c_get_trx_date_trans_occ(p_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT date_transaction_occurred
    FROM okl_trx_contracts
    WHERE khr_id = p_chr_id
    AND tcn_type = 'TRBK'
    AND tsu_code = 'ENTERED'
    --rkuttiya added for 12.1.1 Multi GAAP
    AND representation_type = 'PRIMARY';
    --
  BEGIN
    -- Both p_dnz_chr_id and p_cle_id are not to be given
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       -- store SQL error message on message stack
       -- Notify Error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID and CLE_ID');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    --  Getting the TOP Line STS CODE
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_tls_start_date(p_dnz_chr_id);
       FETCH c_get_tls_start_date INTO x_start_date,
                                       lv_orig_sys_source_code,
                                       ln_orig_system_id1;
       IF c_get_tls_start_date%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.START_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_tls_start_date;
       IF lv_orig_sys_source_code = 'OKL_REBOOK' THEN
         OPEN  c_get_trx_date_trans_occ(p_chr_id => ln_orig_system_id1);
         FETCH c_get_trx_date_trans_occ INTO ld_start_date;
         CLOSE c_get_trx_date_trans_occ;
         x_start_date :=  nvl(ld_start_date,sysdate);
       END IF;
    END IF;
    --  Getting the SUB Line STS CODE
    IF (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_sls_start_date(p_cle_id);
       FETCH c_get_sls_start_date INTO x_start_date;
       IF c_get_sls_start_date%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.START_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_sls_start_date;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_tls_start_date%ISOPEN THEN
        CLOSE c_get_tls_start_date;
     END IF;
     -- if the cursor is open
     IF c_get_sls_start_date%ISOPEN THEN
        CLOSE c_get_sls_start_date;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_tls_start_date%ISOPEN THEN
        CLOSE c_get_tls_start_date;
     END IF;
     -- if the cursor is open
     IF c_get_sls_start_date%ISOPEN THEN
        CLOSE c_get_sls_start_date;
     END IF;
     RETURN(x_return_status);
  END get_start_date;
----------------------------------------------------------------------------------------------------------------
  FUNCTION get_currency_code(p_dnz_chr_id    IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                             p_cle_id        IN  OKC_K_LINES_B.CLE_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                             x_currency_code OUT NOCOPY OKC_K_HEADERS_B.CURRENCY_CODE%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_get_tls_currency_code(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT chrv.currency_code
    FROM OKC_K_HEADERS_V chrv
    WHERE chrv.id = p_dnz_chr_id;

    CURSOR c_get_sls_currency_code(p_cle_id OKC_K_LINES_B.CLE_ID%TYPE) IS
    SELECT cle.currency_code
    FROM OKC_K_LINES_V cle
    WHERE cle.id = p_cle_id;
  BEGIN
    -- Both p_dnz_chr_id and p_cle_id are not to be given
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       -- store SQL error message on message stack
       -- Notify Error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID and CLE_ID');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    --  Getting the TOP Line STS CODE
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_tls_currency_code(p_dnz_chr_id);
       FETCH c_get_tls_currency_code INTO x_currency_code;
       IF c_get_tls_currency_code%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.CURRENCY_CODE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_tls_currency_code;
    END IF;
    --  Getting the SUB Line STS CODE
    IF (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_sls_currency_code(p_cle_id);
       FETCH c_get_sls_currency_code INTO x_currency_code;
       IF c_get_sls_currency_code%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.CURRENCY_CODE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_sls_currency_code;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_tls_currency_code%ISOPEN THEN
        CLOSE c_get_tls_currency_code;
     END IF;
     -- if the cursor is open
     IF c_get_sls_currency_code%ISOPEN THEN
        CLOSE c_get_sls_currency_code;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_tls_currency_code%ISOPEN THEN
        CLOSE c_get_tls_currency_code;
     END IF;
     -- if the cursor is open
     IF c_get_sls_currency_code%ISOPEN THEN
        CLOSE c_get_sls_currency_code;
     END IF;
     RETURN(x_return_status);
  END get_currency_code;
----------------------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Ramesh Seela
-- Function Name        : default_contract_line_values
-- Description          : Default the values of start_date, end_date, sts_code, and currency_code on the line
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets

  FUNCTION default_contract_line_values(p_dnz_chr_id IN  OKC_K_LINES_B.DNZ_CHR_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        p_cle_id     IN  OKC_K_LINES_B.CLE_ID%TYPE DEFAULT OKL_API.G_MISS_NUM,
                        p_clev_rec   IN OUT  NOCOPY clev_rec_type)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    lv_orig_sys_source_code    OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    ln_orig_system_id1         OKC_K_HEADERS_B.ORIG_SYSTEM_ID1%TYPE;
    ld_start_date              OKC_K_LINES_B.START_DATE%TYPE;
    ld_end_date                OKC_K_LINES_B.END_DATE%TYPE;
    lv_currency_code           OKC_K_HEADERS_B.CURRENCY_CODE%TYPE;
    lv_sts_code                OKC_K_HEADERS_B.STS_CODE%TYPE;

    CURSOR c_get_contract_header_details(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT chrv.sts_code,
           chrv.end_date,
           chrv.currency_code,
           chrv.start_Date,
           chrv.orig_system_source_code,
           chrv.orig_system_id1
    FROM OKC_K_HEADERS_V chrv
    WHERE chrv.id = p_dnz_chr_id;

    CURSOR c_get_contract_line_details(p_cle_id OKC_K_LINES_B.CLE_ID%TYPE) IS
    SELECT cle.sts_code,
           cle.end_date,
           cle.currency_code,
           cle.start_date
    FROM OKC_K_LINES_V cle
    WHERE cle.id = p_cle_id;

    CURSOR c_get_trx_date_trans_occ(p_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE) IS
    SELECT date_transaction_occurred
    FROM okl_trx_contracts
    WHERE khr_id = p_chr_id
    AND tcn_type = 'TRBK'
    AND tsu_code = 'ENTERED'
    --rkuttiya added for 12.1.1 Multi GAAP
    AND representation_type = 'PRIMARY';
    --
  BEGIN
    -- Both p_dnz_chr_id and p_cle_id are not to be given
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       -- store SQL error message on message stack
       -- Notify Error
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID and CLE_ID');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    --  Getting the TOP Line STS CODE
    IF (p_dnz_chr_id IS NOT NULL OR
       p_dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_contract_header_details(p_dnz_chr_id);
       FETCH c_get_contract_header_details
       INTO lv_sts_code,
            ld_end_date,
            lv_currency_code,
            ld_start_date,
            lv_orig_sys_source_code,
            ln_orig_system_id1;
       IF c_get_contract_header_details%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.START_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_contract_header_details;
       IF lv_orig_sys_source_code = 'OKL_REBOOK' THEN
         OPEN  c_get_trx_date_trans_occ(p_chr_id => ln_orig_system_id1);
         FETCH c_get_trx_date_trans_occ INTO ld_start_date;
         CLOSE c_get_trx_date_trans_occ;
         ld_start_date :=  nvl(ld_start_date,sysdate);
       END IF;
    END IF;
    --  Getting the SUB Line STS CODE
    IF (p_cle_id IS NOT NULL OR
       p_cle_id <> OKL_API.G_MISS_NUM) THEN
       OPEN c_get_contract_line_details(p_cle_id);
       FETCH c_get_contract_line_details
       INTO lv_sts_code,
            ld_end_date,
            lv_currency_code,
            ld_start_date;
       IF c_get_contract_line_details%NOTFOUND THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_K_HEADERS_V.START_DATE');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       CLOSE c_get_contract_line_details;
    END IF;
    IF (p_clev_rec.sts_code IS NULL OR
        p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
       p_clev_rec.sts_code := lv_sts_code;
    END IF;
    IF (p_clev_rec.end_date IS NULL OR
        p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
       p_clev_rec.end_date := ld_end_date;
    END IF;
    IF (p_clev_rec.start_date IS NULL OR
        p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
       p_clev_rec.start_date := ld_start_date;
    END IF;
    IF (p_clev_rec.currency_code IS NULL OR
        p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
       p_clev_rec.currency_code := lv_currency_code;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- We are here b'cause we have no parent record
      -- If the cursor is open then it has to be closed
     IF c_get_contract_header_details%ISOPEN THEN
        CLOSE c_get_contract_header_details;
     END IF;
     -- if the cursor is open
     IF c_get_contract_line_details%ISOPEN THEN
        CLOSE c_get_contract_line_details;
     END IF;
     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_contract_header_details%ISOPEN THEN
        CLOSE c_get_contract_header_details;
     END IF;
     -- if the cursor is open
     IF c_get_contract_line_details%ISOPEN THEN
        CLOSE c_get_contract_line_details;
     END IF;
     RETURN(x_return_status);
  END default_contract_line_values;
-------------------------------------------------------------------------------------------------
  FUNCTION get_rec_txlv(p_txlv_id   IN  OKL_TXL_ASSETS_V.KLE_ID%TYPE,
                        x_txlv_rec  OUT NOCOPY talv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okl_talv_pk_csr (p_kle_id  IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           TAS_ID,
           ILO_ID,
           ILO_ID_OLD,
           IAY_ID,
           IAY_ID_NEW,
           KLE_ID,
           DNZ_KHR_ID,
           LINE_NUMBER,
           ORG_ID,
           TAL_TYPE,
           ASSET_NUMBER,
           DESCRIPTION,
           FA_LOCATION_ID,
           ORIGINAL_COST,
           CURRENT_UNITS,
           MANUFACTURER_NAME,
           YEAR_MANUFACTURED,
           SUPPLIER_ID,
           USED_ASSET_YN,
           TAG_NUMBER,
           MODEL_NUMBER,
           CORPORATE_BOOK,
           DATE_PURCHASED,
           DATE_DELIVERY,
           IN_SERVICE_DATE,
           LIFE_IN_MONTHS,
           DEPRECIATION_ID,
           DEPRECIATION_COST,
           DEPRN_METHOD,
           DEPRN_RATE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
--Bug# 2981308
           ASSET_KEY_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           DEPRECIATE_YN,
           HOLD_PERIOD_DAYS,
           OLD_SALVAGE_VALUE,
           NEW_RESIDUAL_VALUE,
           OLD_RESIDUAL_VALUE,
           UNITS_RETIRED,
           COST_RETIRED,
           SALE_PROCEEDS,
           REMOVAL_COST,
           DNZ_ASSET_ID,
           DATE_DUE,
           REP_ASSET_ID,
           LKE_ASSET_ID,
           MATCH_AMOUNT,
           SPLIT_INTO_SINGLES_FLAG,
           SPLIT_INTO_UNITS,
           CURRENCY_CODE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_DATE
      FROM Okl_Txl_Assets_V
     WHERE okl_txl_assets_v.kle_id  = p_kle_id;
    l_okl_talv_pk                  okl_talv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okl_talv_pk_csr (p_txlv_id);
    FETCH okl_talv_pk_csr INTO
              x_txlv_rec.ID,
              x_txlv_rec.OBJECT_VERSION_NUMBER,
              x_txlv_rec.SFWT_FLAG,
              x_txlv_rec.TAS_ID,
              x_txlv_rec.ILO_ID,
              x_txlv_rec.ILO_ID_OLD,
              x_txlv_rec.IAY_ID,
              x_txlv_rec.IAY_ID_NEW,
              x_txlv_rec.KLE_ID,
              x_txlv_rec.DNZ_KHR_ID,
              x_txlv_rec.LINE_NUMBER,
              x_txlv_rec.ORG_ID,
              x_txlv_rec.TAL_TYPE,
              x_txlv_rec.ASSET_NUMBER,
              x_txlv_rec.DESCRIPTION,
              x_txlv_rec.FA_LOCATION_ID,
              x_txlv_rec.ORIGINAL_COST,
              x_txlv_rec.CURRENT_UNITS,
              x_txlv_rec.MANUFACTURER_NAME,
              x_txlv_rec.YEAR_MANUFACTURED,
              x_txlv_rec.SUPPLIER_ID,
              x_txlv_rec.USED_ASSET_YN,
              x_txlv_rec.TAG_NUMBER,
              x_txlv_rec.MODEL_NUMBER,
              x_txlv_rec.CORPORATE_BOOK,
              x_txlv_rec.DATE_PURCHASED,
              x_txlv_rec.DATE_DELIVERY,
              x_txlv_rec.IN_SERVICE_DATE,
              x_txlv_rec.LIFE_IN_MONTHS,
              x_txlv_rec.DEPRECIATION_ID,
              x_txlv_rec.DEPRECIATION_COST,
              x_txlv_rec.DEPRN_METHOD,
              x_txlv_rec.DEPRN_RATE,
              x_txlv_rec.SALVAGE_VALUE,
              x_txlv_rec.PERCENT_SALVAGE_VALUE,
--Bug# 2981308
              x_txlv_rec.ASSET_KEY_ID,
              x_txlv_rec.ATTRIBUTE_CATEGORY,
              x_txlv_rec.ATTRIBUTE1,
              x_txlv_rec.ATTRIBUTE2,
              x_txlv_rec.ATTRIBUTE3,
              x_txlv_rec.ATTRIBUTE4,
              x_txlv_rec.ATTRIBUTE5,
              x_txlv_rec.ATTRIBUTE6,
              x_txlv_rec.ATTRIBUTE7,
              x_txlv_rec.ATTRIBUTE8,
              x_txlv_rec.ATTRIBUTE9,
              x_txlv_rec.ATTRIBUTE10,
              x_txlv_rec.ATTRIBUTE11,
              x_txlv_rec.ATTRIBUTE12,
              x_txlv_rec.ATTRIBUTE13,
              x_txlv_rec.ATTRIBUTE14,
              x_txlv_rec.ATTRIBUTE15,
              x_txlv_rec.CREATED_BY,
              x_txlv_rec.CREATION_DATE,
              x_txlv_rec.LAST_UPDATED_BY,
              x_txlv_rec.LAST_UPDATE_DATE,
              x_txlv_rec.LAST_UPDATE_LOGIN,
              x_txlv_rec.DEPRECIATE_YN,
              x_txlv_rec.HOLD_PERIOD_DAYS,
              x_txlv_rec.OLD_SALVAGE_VALUE,
              x_txlv_rec.NEW_RESIDUAL_VALUE,
              x_txlv_rec.OLD_RESIDUAL_VALUE,
              x_txlv_rec.UNITS_RETIRED,
              x_txlv_rec.COST_RETIRED,
              x_txlv_rec.SALE_PROCEEDS,
              x_txlv_rec.REMOVAL_COST,
              x_txlv_rec.DNZ_ASSET_ID,
              x_txlv_rec.DATE_DUE,
              x_txlv_rec.REP_ASSET_ID,
              x_txlv_rec.LKE_ASSET_ID,
              x_txlv_rec.MATCH_AMOUNT,
              x_txlv_rec.SPLIT_INTO_SINGLES_FLAG,
              x_txlv_rec.SPLIT_INTO_UNITS,
              x_txlv_rec.CURRENCY_CODE,
              x_txlv_rec.CURRENCY_CONVERSION_TYPE,
              x_txlv_rec.CURRENCY_CONVERSION_RATE,
              x_txlv_rec.CURRENCY_CONVERSION_DATE;
    IF okl_talv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_talv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okl_talv_pk_csr%ISOPEN THEN
        CLOSE okl_talv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_txlv;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_txdv_rec
-- Description          : Get Transaction Detail Line Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION get_txdv_tbl(p_tal_id        IN NUMBER,
                        p_asset_number  IN OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
                        p_original_cost IN OKL_TXL_ASSETS_B.ORIGINAL_COST%TYPE,
                        x_to_update     OUT NOCOPY VARCHAR2,
                        x_txdv_tbl      OUT NOCOPY txdv_tbl_type)
  RETURN  VARCHAR2
  IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
    lv_to_update               VARCHAR2(3) := 'N';
    CURSOR c_okl_asdv_pk_csr (p_tal_id  IN NUMBER) IS
    SELECT id,
           object_version_number,
           tal_id,
           target_kle_id,
           line_detail_number,
           asset_number,
           description,
           quantity,
           cost,
           tax_book,
           life_in_months_tax,
           deprn_method_tax,
           deprn_rate_tax,
           salvage_value,
           attribute_category,
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
           attribute15,
           created_by,
           creation_date,
           last_updated_by,
           last_update_date,
           last_update_login,
           split_percent,
           inventory_item_id
    FROM Okl_Txd_Assets_V txd
    WHERE txd.tal_id  = p_tal_id;
  BEGIN
    FOR r_okl_asdv_pk_csr IN c_okl_asdv_pk_csr(p_tal_id) LOOP
        x_txdv_tbl(i).ID                     := r_okl_asdv_pk_csr.ID;
        x_txdv_tbl(i).OBJECT_VERSION_NUMBER  := r_okl_asdv_pk_csr.OBJECT_VERSION_NUMBER;
        x_txdv_tbl(i).TAL_ID                 := r_okl_asdv_pk_csr.TAL_ID;
        x_txdv_tbl(i).TARGET_KLE_ID          := r_okl_asdv_pk_csr.TARGET_KLE_ID;
        x_txdv_tbl(i).LINE_DETAIL_NUMBER     := r_okl_asdv_pk_csr.LINE_DETAIL_NUMBER;
        x_txdv_tbl(i).DESCRIPTION            := r_okl_asdv_pk_csr.DESCRIPTION;
        IF (p_asset_number <> r_okl_asdv_pk_csr.ASSET_NUMBER) OR
           (p_original_cost <> r_okl_asdv_pk_csr.COST) THEN
          x_txdv_tbl(i).COST                   := p_original_cost;
          x_txdv_tbl(i).ASSET_NUMBER           := p_asset_number;
          lv_to_update := 'Y';
        ELSE
          x_txdv_tbl(i).COST                   := r_okl_asdv_pk_csr.COST;
          x_txdv_tbl(i).ASSET_NUMBER           := r_okl_asdv_pk_csr.ASSET_NUMBER;
          lv_to_update := 'N';
        END IF;
        x_txdv_tbl(i).QUANTITY               := r_okl_asdv_pk_csr.QUANTITY;
        x_txdv_tbl(i).TAX_BOOK               := r_okl_asdv_pk_csr.TAX_BOOK;
        x_txdv_tbl(i).LIFE_IN_MONTHS_TAX     := r_okl_asdv_pk_csr.LIFE_IN_MONTHS_TAX;
        x_txdv_tbl(i).DEPRN_METHOD_TAX       := r_okl_asdv_pk_csr.DEPRN_METHOD_TAX;
        x_txdv_tbl(i).DEPRN_RATE_TAX         := r_okl_asdv_pk_csr.DEPRN_RATE_TAX;
        x_txdv_tbl(i).SALVAGE_VALUE          := r_okl_asdv_pk_csr.SALVAGE_VALUE;
        x_txdv_tbl(i).ATTRIBUTE_CATEGORY     := r_okl_asdv_pk_csr.ATTRIBUTE_CATEGORY;
        x_txdv_tbl(i).ATTRIBUTE1             := r_okl_asdv_pk_csr.ATTRIBUTE1;
        x_txdv_tbl(i).ATTRIBUTE2             := r_okl_asdv_pk_csr.ATTRIBUTE2;
        x_txdv_tbl(i).ATTRIBUTE3             := r_okl_asdv_pk_csr.ATTRIBUTE3;
        x_txdv_tbl(i).ATTRIBUTE4             := r_okl_asdv_pk_csr.ATTRIBUTE4;
        x_txdv_tbl(i).ATTRIBUTE5             := r_okl_asdv_pk_csr.ATTRIBUTE5;
        x_txdv_tbl(i).ATTRIBUTE6             := r_okl_asdv_pk_csr.ATTRIBUTE6;
        x_txdv_tbl(i).ATTRIBUTE7             := r_okl_asdv_pk_csr.ATTRIBUTE7;
        x_txdv_tbl(i).ATTRIBUTE8             := r_okl_asdv_pk_csr.ATTRIBUTE8;
        x_txdv_tbl(i).ATTRIBUTE9             := r_okl_asdv_pk_csr.ATTRIBUTE9;
        x_txdv_tbl(i).ATTRIBUTE10            := r_okl_asdv_pk_csr.ATTRIBUTE10;
        x_txdv_tbl(i).ATTRIBUTE11            := r_okl_asdv_pk_csr.ATTRIBUTE11;
        x_txdv_tbl(i).ATTRIBUTE12            := r_okl_asdv_pk_csr.ATTRIBUTE12;
        x_txdv_tbl(i).ATTRIBUTE13            := r_okl_asdv_pk_csr.ATTRIBUTE13;
        x_txdv_tbl(i).ATTRIBUTE14            := r_okl_asdv_pk_csr.ATTRIBUTE14;
        x_txdv_tbl(i).ATTRIBUTE15            := r_okl_asdv_pk_csr.ATTRIBUTE15;
        x_txdv_tbl(i).CREATED_BY             := r_okl_asdv_pk_csr.CREATED_BY;
        x_txdv_tbl(i).CREATION_DATE          := r_okl_asdv_pk_csr.CREATION_DATE;
        x_txdv_tbl(i).LAST_UPDATED_BY        := r_okl_asdv_pk_csr.LAST_UPDATED_BY;
        x_txdv_tbl(i).LAST_UPDATE_DATE       := r_okl_asdv_pk_csr.LAST_UPDATE_DATE;
        x_txdv_tbl(i).LAST_UPDATE_LOGIN      := r_okl_asdv_pk_csr.LAST_UPDATE_LOGIN;
        x_txdv_tbl(i).SPLIT_PERCENT          := r_okl_asdv_pk_csr.split_percent;
        x_txdv_tbl(i).INVENTORY_ITEM_ID      := r_okl_asdv_pk_csr.inventory_item_id;
        i := i + 1;
--       IF c_okl_asdv_pk_csr%NOTFOUND THEN
--          x_return_status := OKL_API.G_RET_STS_ERROR;
--          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
--       END IF;
    END LOOP;
    x_to_update := lv_to_update;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
       IF c_okl_asdv_pk_csr%ISOPEN THEN
          CLOSE c_okl_asdv_pk_csr;
       END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  END get_txdv_tbl;
-----------------------------------------------------------------------------------------------
  FUNCTION get_rec_itiv(p_itiv_id   IN  OKL_TXL_ITM_INSTS_V.KLE_ID%TYPE,
                        x_itiv_rec  OUT NOCOPY itiv_rec_type)
  RETURN VARCHAR2 IS

    CURSOR okl_itiv_pk_csr (p_kle_id  IN NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           TAS_ID,
           TAL_ID,
           KLE_ID,
           TAL_TYPE,
           LINE_NUMBER,
           INSTANCE_NUMBER_IB,
           OBJECT_ID1_NEW,
           OBJECT_ID2_NEW,
           JTOT_OBJECT_CODE_NEW,
           OBJECT_ID1_OLD,
           OBJECT_ID2_OLD,
           JTOT_OBJECT_CODE_OLD,
           INVENTORY_ORG_ID,
           SERIAL_NUMBER,
           MFG_SERIAL_NUMBER_YN,
           INVENTORY_ITEM_ID,
           INV_MASTER_ORG_ID,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
    FROM OKL_TXL_ITM_INSTS iti
    WHERE iti.kle_id  = p_kle_id;
    l_okl_itiv_pk                  okl_itiv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okl_itiv_pk_csr (p_itiv_id);
    FETCH okl_itiv_pk_csr INTO
              x_itiv_rec.ID,
              x_itiv_rec.OBJECT_VERSION_NUMBER,
              x_itiv_rec.TAS_ID,
              x_itiv_rec.TAL_ID,
              x_itiv_rec.KLE_ID,
              x_itiv_rec.TAL_TYPE,
              x_itiv_rec.LINE_NUMBER,
              x_itiv_rec.INSTANCE_NUMBER_IB,
              x_itiv_rec.OBJECT_ID1_NEW,
              x_itiv_rec.OBJECT_ID2_NEW,
              x_itiv_rec.JTOT_OBJECT_CODE_NEW,
              x_itiv_rec.OBJECT_ID1_OLD,
              x_itiv_rec.OBJECT_ID2_OLD,
              x_itiv_rec.JTOT_OBJECT_CODE_OLD,
              x_itiv_rec.INVENTORY_ORG_ID,
              x_itiv_rec.SERIAL_NUMBER,
              x_itiv_rec.MFG_SERIAL_NUMBER_YN,
              x_itiv_rec.INVENTORY_ITEM_ID,
              x_itiv_rec.INV_MASTER_ORG_ID,
              x_itiv_rec.ATTRIBUTE_CATEGORY,
              x_itiv_rec.ATTRIBUTE1,
              x_itiv_rec.ATTRIBUTE2,
              x_itiv_rec.ATTRIBUTE3,
              x_itiv_rec.ATTRIBUTE4,
              x_itiv_rec.ATTRIBUTE5,
              x_itiv_rec.ATTRIBUTE6,
              x_itiv_rec.ATTRIBUTE7,
              x_itiv_rec.ATTRIBUTE8,
              x_itiv_rec.ATTRIBUTE9,
              x_itiv_rec.ATTRIBUTE10,
              x_itiv_rec.ATTRIBUTE11,
              x_itiv_rec.ATTRIBUTE12,
              x_itiv_rec.ATTRIBUTE13,
              x_itiv_rec.ATTRIBUTE14,
              x_itiv_rec.ATTRIBUTE15,
              x_itiv_rec.CREATED_BY,
              x_itiv_rec.CREATION_DATE,
              x_itiv_rec.LAST_UPDATED_BY,
              x_itiv_rec.LAST_UPDATE_DATE,
              x_itiv_rec.LAST_UPDATE_LOGIN;
    IF okl_itiv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_itiv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okl_itiv_pk_csr%ISOPEN THEN
        CLOSE okl_itiv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_itiv;
-----------------------------------------------------------------------------------------------------
  FUNCTION get_rec_cplv(p_cplv_id   IN  OKC_K_PARTY_ROLES_B.ID%TYPE,
                        x_cplv_rec  OUT NOCOPY cplv_rec_type)
  RETURN VARCHAR2 IS
  CURSOR okc_cplv_pk_csr (p_cplv_id  OKC_K_PARTY_ROLES_B.ID%TYPE) IS
  SELECT ID,
         OBJECT_VERSION_NUMBER,
         SFWT_FLAG,
         CPL_ID,
         CHR_ID,
         CLE_ID,
         RLE_CODE,
         DNZ_CHR_ID,
         OBJECT1_ID1,
         OBJECT1_ID2,
         JTOT_OBJECT1_CODE,
         COGNOMEN,
         CODE,
         FACILITY,
         MINORITY_GROUP_LOOKUP_CODE,
         SMALL_BUSINESS_FLAG,
         WOMEN_OWNED_FLAG,
         ALIAS,
         ATTRIBUTE_CATEGORY,
         ATTRIBUTE1,
         ATTRIBUTE2,
         ATTRIBUTE3,
         ATTRIBUTE4,
         ATTRIBUTE5,
         ATTRIBUTE6,
         ATTRIBUTE7,
         ATTRIBUTE8,
         ATTRIBUTE9,
         ATTRIBUTE10,
         ATTRIBUTE11,
         ATTRIBUTE12,
         ATTRIBUTE13,
         ATTRIBUTE14,
         ATTRIBUTE15,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN
      FROM Okc_K_Party_Roles_V cpr
     WHERE cpr.id = p_cplv_id;
    l_okc_cplv_pk                  okc_cplv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cplv_pk_csr (p_cplv_id);
    FETCH okc_cplv_pk_csr INTO
              x_cplv_rec.ID,
              x_cplv_rec.OBJECT_VERSION_NUMBER,
              x_cplv_rec.SFWT_FLAG,
              x_cplv_rec.CPL_ID,
              x_cplv_rec.CHR_ID,
              x_cplv_rec.CLE_ID,
              x_cplv_rec.RLE_CODE,
              x_cplv_rec.DNZ_CHR_ID,
              x_cplv_rec.OBJECT1_ID1,
              x_cplv_rec.OBJECT1_ID2,
              x_cplv_rec.JTOT_OBJECT1_CODE,
              x_cplv_rec.COGNOMEN,
              x_cplv_rec.CODE,
              x_cplv_rec.FACILITY,
              x_cplv_rec.MINORITY_GROUP_LOOKUP_CODE,
              x_cplv_rec.SMALL_BUSINESS_FLAG,
              x_cplv_rec.WOMEN_OWNED_FLAG,
              x_cplv_rec.ALIAS,
              x_cplv_rec.ATTRIBUTE_CATEGORY,
              x_cplv_rec.ATTRIBUTE1,
              x_cplv_rec.ATTRIBUTE2,
              x_cplv_rec.ATTRIBUTE3,
              x_cplv_rec.ATTRIBUTE4,
              x_cplv_rec.ATTRIBUTE5,
              x_cplv_rec.ATTRIBUTE6,
              x_cplv_rec.ATTRIBUTE7,
              x_cplv_rec.ATTRIBUTE8,
              x_cplv_rec.ATTRIBUTE9,
              x_cplv_rec.ATTRIBUTE10,
              x_cplv_rec.ATTRIBUTE11,
              x_cplv_rec.ATTRIBUTE12,
              x_cplv_rec.ATTRIBUTE13,
              x_cplv_rec.ATTRIBUTE14,
              x_cplv_rec.ATTRIBUTE15,
              x_cplv_rec.CREATED_BY,
              x_cplv_rec.CREATION_DATE,
              x_cplv_rec.LAST_UPDATED_BY,
              x_cplv_rec.LAST_UPDATE_DATE,
              x_cplv_rec.LAST_UPDATE_LOGIN;
    IF okc_cplv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cplv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cplv_pk_csr%ISOPEN THEN
        CLOSE okc_cplv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_cplv;
--------------------------------------------------------------------------------------------------
  FUNCTION get_rec_ib_cimv(p_cle_id      IN  OKC_K_ITEMS_V.CLE_ID%TYPE,
                           p_dnz_chr_id  IN  OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE,
                           x_cimv_rec OUT NOCOPY cimv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_cimv_pk_csr(p_cle_id     OKC_K_ITEMS_V.CLE_ID%TYPE,
                           p_dnz_chr_id OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE) IS
    SELECT CIM.ID,
           CIM.OBJECT_VERSION_NUMBER,
           CIM.CLE_ID,
           CIM.CHR_ID,
           CIM.CLE_ID_FOR,
           CIM.DNZ_CHR_ID,
           CIM.OBJECT1_ID1,
           CIM.OBJECT1_ID2,
           CIM.JTOT_OBJECT1_CODE,
           CIM.UOM_CODE,
           CIM.EXCEPTION_YN,
           CIM.NUMBER_OF_ITEMS,
           CIM.UPG_ORIG_SYSTEM_REF,
           CIM.UPG_ORIG_SYSTEM_REF_ID,
           CIM.PRICED_ITEM_YN,
           CIM.CREATED_BY,
           CIM.CREATION_DATE,
           CIM.LAST_UPDATED_BY,
           CIM.LAST_UPDATE_DATE,
           CIM.LAST_UPDATE_LOGIN
    FROM okc_k_items_v cim,
    okc_k_lines_b cle,
    okc_line_styles_b lse,
    okc_k_lines_b cle1
    WHERE cim.dnz_chr_id = p_dnz_chr_id
    AND   cim.cle_id = cle.id
    AND   cle.lse_id = lse.id
    AND   lse.lty_code = 'ITEM'
    AND   cle.dnz_chr_id = p_dnz_chr_id --cim.dnz_chr_id
    AND   cle.cle_id = cle1.cle_id
    AND   cle1.id = p_cle_id
    AND   cle1.dnz_chr_id = p_dnz_chr_id; --cim.dnz_chr_id

    /*FROM okc_k_items_v cim
    WHERE cim.dnz_chr_id = p_dnz_chr_id
    AND cim.cle_id in (SELECT cle.id
                       FROM okc_k_lines_v cle,
                            okc_line_styles_v lse
                       WHERE cle.lse_id = lse.id
                       AND lse.lty_code = 'ITEM'
                       AND cle.dnz_chr_id = cim.dnz_chr_id
                       AND cle.cle_id in (SELECT cle1.cle_id
                                          FROM okc_k_lines_v cle1
                                          WHERE cle1.id = p_cle_id
                                          AND cle1.dnz_chr_id = cim.dnz_chr_id));*/
    l_okc_cimv_pk              okc_cimv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cimv_pk_csr(p_cle_id,
                         p_dnz_chr_id);
    FETCH okc_cimv_pk_csr INTO
              x_cimv_rec.ID,
              x_cimv_rec.OBJECT_VERSION_NUMBER,
              x_cimv_rec.CLE_ID,
              x_cimv_rec.CHR_ID,
              x_cimv_rec.CLE_ID_FOR,
              x_cimv_rec.DNZ_CHR_ID,
              x_cimv_rec.OBJECT1_ID1,
              x_cimv_rec.OBJECT1_ID2,
              x_cimv_rec.JTOT_OBJECT1_CODE,
              x_cimv_rec.UOM_CODE,
              x_cimv_rec.EXCEPTION_YN,
              x_cimv_rec.NUMBER_OF_ITEMS,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_cimv_rec.PRICED_ITEM_YN,
              x_cimv_rec.CREATED_BY,
              x_cimv_rec.CREATION_DATE,
              x_cimv_rec.LAST_UPDATED_BY,
              x_cimv_rec.LAST_UPDATE_DATE,
              x_cimv_rec.LAST_UPDATE_LOGIN;
    IF okc_cimv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (okc_cimv_pk_csr%ROWCOUNT > 1) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cimv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cimv_pk_csr%ISOPEN THEN
        CLOSE okc_cimv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_ib_cimv;
----------------------------------------------------------------------------------------------------
  FUNCTION get_rec_cimv(p_cle_id      IN  OKC_K_ITEMS_V.CLE_ID%TYPE,
                        p_dnz_chr_id  IN  OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE,
                        x_cimv_rec OUT NOCOPY cimv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_cimv_pk_csr(p_cle_id     OKC_K_ITEMS_V.CLE_ID%TYPE,
                           p_dnz_chr_id OKC_K_ITEMS_V.DNZ_CHR_ID%TYPE) IS
    SELECT CIM.ID,
           CIM.OBJECT_VERSION_NUMBER,
           CIM.CLE_ID,
           CIM.CHR_ID,
           CIM.CLE_ID_FOR,
           CIM.DNZ_CHR_ID,
           CIM.OBJECT1_ID1,
           CIM.OBJECT1_ID2,
           CIM.JTOT_OBJECT1_CODE,
           CIM.UOM_CODE,
           CIM.EXCEPTION_YN,
           CIM.NUMBER_OF_ITEMS,
           CIM.UPG_ORIG_SYSTEM_REF,
           CIM.UPG_ORIG_SYSTEM_REF_ID,
           CIM.PRICED_ITEM_YN,
           CIM.CREATED_BY,
           CIM.CREATION_DATE,
           CIM.LAST_UPDATED_BY,
           CIM.LAST_UPDATE_DATE,
           CIM.LAST_UPDATE_LOGIN
    FROM okc_k_items_v cim
    WHERE cim.dnz_chr_id = p_dnz_chr_id
    AND cim.cle_id = p_cle_id;
    l_okc_cimv_pk              okc_cimv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cimv_pk_csr(p_cle_id,
                         p_dnz_chr_id);
    FETCH okc_cimv_pk_csr INTO
              x_cimv_rec.ID,
              x_cimv_rec.OBJECT_VERSION_NUMBER,
              x_cimv_rec.CLE_ID,
              x_cimv_rec.CHR_ID,
              x_cimv_rec.CLE_ID_FOR,
              x_cimv_rec.DNZ_CHR_ID,
              x_cimv_rec.OBJECT1_ID1,
              x_cimv_rec.OBJECT1_ID2,
              x_cimv_rec.JTOT_OBJECT1_CODE,
              x_cimv_rec.UOM_CODE,
              x_cimv_rec.EXCEPTION_YN,
              x_cimv_rec.NUMBER_OF_ITEMS,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_cimv_rec.PRICED_ITEM_YN,
              x_cimv_rec.CREATED_BY,
              x_cimv_rec.CREATION_DATE,
              x_cimv_rec.LAST_UPDATED_BY,
              x_cimv_rec.LAST_UPDATE_DATE,
              x_cimv_rec.LAST_UPDATE_LOGIN;
    IF okc_cimv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    IF (okc_cimv_pk_csr%ROWCOUNT > 1) THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cimv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cimv_pk_csr%ISOPEN THEN
        CLOSE okc_cimv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_cimv;
-------------------------------------------------------------------------------------------------
  FUNCTION get_rec_update_cimv(p_cimv_id      IN  OKC_K_ITEMS_V.ID%TYPE,
                               x_cimv_rec OUT NOCOPY cimv_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_cimv_pk_csr(p_cimv_id     OKC_K_ITEMS_V.ID%TYPE) IS
    SELECT  ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            CHR_ID,
            CLE_ID_FOR,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            UOM_CODE,
            EXCEPTION_YN,
            NUMBER_OF_ITEMS,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            PRICED_ITEM_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM okc_k_items_V cim
     WHERE cim.id = p_cimv_id;
    l_okc_cimv_pk              okc_cimv_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    OPEN okc_cimv_pk_csr(p_cimv_id);
    FETCH okc_cimv_pk_csr INTO
              x_cimv_rec.ID,
              x_cimv_rec.OBJECT_VERSION_NUMBER,
              x_cimv_rec.CLE_ID,
              x_cimv_rec.CHR_ID,
              x_cimv_rec.CLE_ID_FOR,
              x_cimv_rec.DNZ_CHR_ID,
              x_cimv_rec.OBJECT1_ID1,
              x_cimv_rec.OBJECT1_ID2,
              x_cimv_rec.JTOT_OBJECT1_CODE,
              x_cimv_rec.UOM_CODE,
              x_cimv_rec.EXCEPTION_YN,
              x_cimv_rec.NUMBER_OF_ITEMS,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF,
              x_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_cimv_rec.PRICED_ITEM_YN,
              x_cimv_rec.CREATED_BY,
              x_cimv_rec.CREATION_DATE,
              x_cimv_rec.LAST_UPDATED_BY,
              x_cimv_rec.LAST_UPDATE_DATE,
              x_cimv_rec.LAST_UPDATE_LOGIN;
    IF okc_cimv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_cimv_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_cimv_pk_csr%ISOPEN THEN
        CLOSE okc_cimv_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_update_cimv;
---------------------------------------------------------------------------------------------------------
  FUNCTION get_party_site_id(p_object_id1_new IN  OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE,
                             x_object_id1_new OUT NOCOPY OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE,
                             x_object_id2_new OUT NOCOPY OKL_TXL_ITM_INSTS_V.OBJECT_ID2_NEW%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR c_get_id1_id2(p_id1 OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE) IS
    SELECT id1
           ,id2
    FROM OKX_PARTY_SITE_USES_V
    WHERE id1 = p_id1
    AND id2 = G_ID2
    AND site_use_type = 'INSTALL_AT';

  BEGIN
    IF (p_object_id1_new IS NULL OR
       p_object_id1_new = OKL_API.G_MISS_NUM) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKX_PARTY_SITE_USES_V.ID1');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    OPEN c_get_id1_id2(p_object_id1_new);
    FETCH c_get_id1_id2 INTO x_object_id1_new,
                             x_object_id2_new;
    IF c_get_id1_id2%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKX_PARTY_SITE_USES_V.ID1 and ID2');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_id1_id2;
    IF (x_object_id1_new IS NULL OR
       x_object_id1_new = OKL_API.G_MISS_CHAR) AND
       (x_object_id2_new IS NULL OR
       x_object_id2_new = OKL_API.G_MISS_CHAR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKX_PARTY_SITE_USES_V.ID1 and ID2');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_object_id1_new IS NULL OR
       x_object_id1_new = OKL_API.G_MISS_CHAR) OR
       (x_object_id2_new IS NULL OR
       x_object_id2_new = OKL_API.G_MISS_CHAR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKX_PARTY_SITE_USES_V.ID1 and ID2');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
    x_return_status := OKL_API.G_RET_STS_ERROR;
    IF c_get_id1_id2%ISOPEN THEN
       CLOSE c_get_id1_id2;
    END IF;
    RETURN(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_id1_id2%ISOPEN THEN
        CLOSE c_get_id1_id2;
     END IF;
     RETURN(x_return_status);
  END get_party_site_id;
---------------------------------------------------------------------------------------------
  FUNCTION get_lse_id(p_lty_code  IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                      x_lse_id    OUT NOCOPY OKC_LINE_STYLES_V.ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;

    CURSOR c_get_lse_id1(p_code OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT lse.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse
    WHERE lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_get_lse_id2(p_code OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT lse1.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1
    WHERE lse1.lty_code = p_code
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_get_lse_id3(p_code  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                         p_code2 OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT lse1.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1
    WHERE lse1.lty_code = p_code
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = p_code2
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);
  BEGIN
    IF (p_lty_code IS NULL OR
       p_lty_code = OKL_API.G_MISS_CHAR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_LINE_STYLES_V.LSE_TYPE');
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    -- Top Line Line Style
    IF p_lty_code = G_FIN_LINE_LTY_CODE THEN
      OPEN  c_get_lse_id1(p_lty_code);
      FETCH c_get_lse_id1 INTO x_lse_id;
      IF c_get_lse_id1%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKC_LINE_STYLES_V.ID');
        x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_get_lse_id1;
    -- Model Line, Fixed Asset line and Instance line
    ELSIF p_lty_code IN (G_MODEL_LINE_LTY_CODE,G_FA_LINE_LTY_CODE,G_INST_LINE_LTY_CODE) THEN
      OPEN c_get_lse_id2(p_lty_code);
      FETCH c_get_lse_id2 INTO x_lse_id;
      IF c_get_lse_id2%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKC_LINE_STYLES_V.ID');
        x_return_status := OKL_API.G_RET_STS_ERROR;
      END IF;
      CLOSE c_get_lse_id2;
    -- Addon line and Install Base line
    ELSIF p_lty_code IN (G_IB_LINE_LTY_CODE,G_ADDON_LINE_LTY_CODE) THEN
      IF p_lty_code = G_IB_LINE_LTY_CODE THEN
        OPEN c_get_lse_id3(p_lty_code,
                           G_INST_LINE_LTY_CODE);
        FETCH c_get_lse_id3 INTO x_lse_id;
        IF c_get_lse_id3%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_LINE_STYLES_V.ID');
          x_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_get_lse_id3;
      ELSIF p_lty_code = G_ADDON_LINE_LTY_CODE THEN
        OPEN c_get_lse_id3(p_lty_code,
                           G_MODEL_LINE_LTY_CODE);
        FETCH c_get_lse_id3 INTO x_lse_id;
        IF c_get_lse_id3%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKC_LINE_STYLES_V.ID');
           x_return_status := OKL_API.G_RET_STS_ERROR;
        END IF;
        CLOSE c_get_lse_id3;
      END IF;
    ELSE
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN x_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_lse_id1%ISOPEN THEN
        CLOSE c_get_lse_id1;
     END IF;
     IF c_get_lse_id2%ISOPEN THEN
        CLOSE c_get_lse_id2;
     END IF;
     IF c_get_lse_id3%ISOPEN THEN
        CLOSE c_get_lse_id3;
     END IF;
     RETURN(x_return_status);
  END get_lse_id;
--------------------------------------------------------------------------------------------------
  FUNCTION get_try_id(p_try_name  IN  OKL_TRX_TYPES_V.NAME%TYPE,
                      x_try_id    OUT NOCOPY OKC_LINE_STYLES_V.ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_get_try_id(p_try_name  OKL_TRX_TYPES_V.NAME%TYPE) IS
    SELECT id
    FROM OKL_TRX_TYPES_tl
    WHERE upper(name) = upper(p_try_name)
    AND language = G_LANGUAGE;
  BEGIN
    IF (p_try_name = OKL_API.G_MISS_CHAR) OR
       (p_try_name IS NULL) THEN
       -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TRX_TYPES_V.NAME');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
     END IF;
     OPEN c_get_try_id(p_try_name);
     FETCH c_get_try_id INTO x_try_id;
     IF c_get_try_id%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TRX_TYPES_V.ID');
       RAISE G_EXCEPTION_HALT_VALIDATION;
     END IF;
     CLOSE c_get_try_id;
     RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF c_get_try_id%ISOPEN THEN
        CLOSE c_get_try_id;
     END IF;
     RETURN(x_return_status);
  END get_try_id;
------------------------------------------------------------------------------------------------------
  FUNCTION get_rec_clev(p_id       IN OKC_K_LINES_V.ID%TYPE,
                        x_clev_rec OUT NOCOPY clev_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okc_clev_pk_csr (p_cle_id NUMBER) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           SFWT_FLAG,
           CHR_ID,
           CLE_ID,
           LSE_ID,
           LINE_NUMBER,
           STS_CODE,
           DISPLAY_SEQUENCE,
           TRN_CODE,
           DNZ_CHR_ID,
           COMMENTS,
           ITEM_DESCRIPTION,
           OKE_BOE_DESCRIPTION,
           COGNOMEN,
           HIDDEN_IND,
           PRICE_UNIT,
           PRICE_UNIT_PERCENT,
           PRICE_NEGOTIATED,
           PRICE_NEGOTIATED_RENEWED,
           PRICE_LEVEL_IND,
           INVOICE_LINE_LEVEL_IND,
           DPAS_RATING,
           BLOCK23TEXT,
           EXCEPTION_YN,
           TEMPLATE_USED,
           DATE_TERMINATED,
           NAME,
           START_DATE,
           END_DATE,
           DATE_RENEWED,
           UPG_ORIG_SYSTEM_REF,
           UPG_ORIG_SYSTEM_REF_ID,
           ORIG_SYSTEM_SOURCE_CODE,
           ORIG_SYSTEM_ID1,
           ORIG_SYSTEM_REFERENCE1,
           REQUEST_ID,
           PROGRAM_APPLICATION_ID,
           PROGRAM_ID,
           PROGRAM_UPDATE_DATE,
           PRICE_LIST_ID,
           PRICING_DATE,
           PRICE_LIST_LINE_ID,
           LINE_LIST_PRICE,
           ITEM_TO_PRICE_YN,
           PRICE_BASIS_YN,
           CONFIG_HEADER_ID,
           CONFIG_REVISION_NUMBER,
           CONFIG_COMPLETE_YN,
           CONFIG_VALID_YN,
           CONFIG_TOP_MODEL_LINE_ID,
           CONFIG_ITEM_TYPE,
           CONFIG_ITEM_ID ,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           PRICE_TYPE,
           CURRENCY_CODE,
	   CURRENCY_CODE_RENEWED,
           LAST_UPDATE_LOGIN
    FROM Okc_K_Lines_V
    WHERE okc_k_lines_v.id  = p_cle_id;
    l_okc_clev_pk              okc_clev_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Get current database values
    OPEN okc_clev_pk_csr (p_id);
    FETCH okc_clev_pk_csr INTO
              x_clev_rec.ID,
              x_clev_rec.OBJECT_VERSION_NUMBER,
              x_clev_rec.SFWT_FLAG,
              x_clev_rec.CHR_ID,
              x_clev_rec.CLE_ID,
              x_clev_rec.LSE_ID,
              x_clev_rec.LINE_NUMBER,
              x_clev_rec.STS_CODE,
              x_clev_rec.DISPLAY_SEQUENCE,
              x_clev_rec.TRN_CODE,
              x_clev_rec.DNZ_CHR_ID,
              x_clev_rec.COMMENTS,
              x_clev_rec.ITEM_DESCRIPTION,
              x_clev_rec.OKE_BOE_DESCRIPTION,
	      x_clev_rec.COGNOMEN,
              x_clev_rec.HIDDEN_IND,
	      x_clev_rec.PRICE_UNIT,
	      x_clev_rec.PRICE_UNIT_PERCENT,
              x_clev_rec.PRICE_NEGOTIATED,
	      x_clev_rec.PRICE_NEGOTIATED_RENEWED,
              x_clev_rec.PRICE_LEVEL_IND,
              x_clev_rec.INVOICE_LINE_LEVEL_IND,
              x_clev_rec.DPAS_RATING,
              x_clev_rec.BLOCK23TEXT,
              x_clev_rec.EXCEPTION_YN,
              x_clev_rec.TEMPLATE_USED,
              x_clev_rec.DATE_TERMINATED,
              x_clev_rec.NAME,
              x_clev_rec.START_DATE,
              x_clev_rec.END_DATE,
	      x_clev_rec.DATE_RENEWED,
              x_clev_rec.UPG_ORIG_SYSTEM_REF,
              x_clev_rec.UPG_ORIG_SYSTEM_REF_ID,
              x_clev_rec.ORIG_SYSTEM_SOURCE_CODE,
              x_clev_rec.ORIG_SYSTEM_ID1,
              x_clev_rec.ORIG_SYSTEM_REFERENCE1,
              x_clev_rec.request_id,
              x_clev_rec.program_application_id,
              x_clev_rec.program_id,
              x_clev_rec.program_update_date,
              x_clev_rec.price_list_id,
              x_clev_rec.pricing_date,
              x_clev_rec.price_list_line_id,
              x_clev_rec.line_list_price,
              x_clev_rec.item_to_price_yn,
              x_clev_rec.price_basis_yn,
              x_clev_rec.config_header_id,
              x_clev_rec.config_revision_number,
              x_clev_rec.config_complete_yn,
              x_clev_rec.config_valid_yn,
              x_clev_rec.config_top_model_line_id,
              x_clev_rec.config_item_type,
              x_clev_rec.CONFIG_ITEM_ID ,
              x_clev_rec.ATTRIBUTE_CATEGORY,
              x_clev_rec.ATTRIBUTE1,
              x_clev_rec.ATTRIBUTE2,
              x_clev_rec.ATTRIBUTE3,
              x_clev_rec.ATTRIBUTE4,
              x_clev_rec.ATTRIBUTE5,
              x_clev_rec.ATTRIBUTE6,
              x_clev_rec.ATTRIBUTE7,
              x_clev_rec.ATTRIBUTE8,
              x_clev_rec.ATTRIBUTE9,
              x_clev_rec.ATTRIBUTE10,
              x_clev_rec.ATTRIBUTE11,
              x_clev_rec.ATTRIBUTE12,
              x_clev_rec.ATTRIBUTE13,
              x_clev_rec.ATTRIBUTE14,
              x_clev_rec.ATTRIBUTE15,
              x_clev_rec.CREATED_BY,
              x_clev_rec.CREATION_DATE,
              x_clev_rec.LAST_UPDATED_BY,
              x_clev_rec.LAST_UPDATE_DATE,
              x_clev_rec.PRICE_TYPE,
              x_clev_rec.CURRENCY_CODE,
	      x_clev_rec.CURRENCY_CODE_RENEWED,
              x_clev_rec.LAST_UPDATE_LOGIN;
    IF  okc_clev_pk_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okc_clev_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okc_clev_pk_csr%ISOPEN THEN
        CLOSE okc_clev_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_clev;
-----------------------------------------------------------------------------------------------
  FUNCTION get_rec_klev(p_id       IN  OKL_K_LINES_V.ID%TYPE,
                        x_klev_rec OUT NOCOPY klev_rec_type)
  RETURN VARCHAR2 IS
    CURSOR okl_k_lines_v_pk_csr (p_kle_id  OKL_K_LINES_V.ID%TYPE) IS
      SELECT ID,
             OBJECT_VERSION_NUMBER,
             KLE_ID,
             STY_ID,
             PRC_CODE,
             FCG_CODE,
             NTY_CODE,
             ESTIMATED_OEC,
             LAO_AMOUNT,
             TITLE_DATE,
             FEE_CHARGE,
             LRS_PERCENT,
             INITIAL_DIRECT_COST,
             PERCENT_STAKE,
             PERCENT,
             EVERGREEN_PERCENT,
             AMOUNT_STAKE,
             OCCUPANCY,
             COVERAGE,
             RESIDUAL_PERCENTAGE,
             DATE_LAST_INSPECTION,
             DATE_SOLD,
             LRV_AMOUNT,
             CAPITAL_REDUCTION,
             DATE_NEXT_INSPECTION_DUE,
             DATE_RESIDUAL_LAST_REVIEW,
             DATE_LAST_REAMORTISATION,
             VENDOR_ADVANCE_PAID,
             WEIGHTED_AVERAGE_LIFE,
             TRADEIN_AMOUNT,
             BOND_EQUIVALENT_YIELD,
             TERMINATION_PURCHASE_AMOUNT,
             REFINANCE_AMOUNT,
             YEAR_BUILT,
             DELIVERED_DATE,
             CREDIT_TENANT_YN,
             DATE_LAST_CLEANUP,
             YEAR_OF_MANUFACTURE,
             COVERAGE_RATIO,
             REMARKETED_AMOUNT,
             GROSS_SQUARE_FOOTAGE,
             PRESCRIBED_ASSET_YN,
             DATE_REMARKETED,
             NET_RENTABLE,
             REMARKET_MARGIN,
             DATE_LETTER_ACCEPTANCE,
             REPURCHASED_AMOUNT,
             DATE_COMMITMENT_EXPIRATION,
             DATE_REPURCHASED,
             DATE_APPRAISAL,
             RESIDUAL_VALUE,
             APPRAISAL_VALUE,
             SECURED_DEAL_YN,
             GAIN_LOSS,
             FLOOR_AMOUNT,
             RE_LEASE_YN,
             PREVIOUS_CONTRACT,
             TRACKED_RESIDUAL,
             DATE_TITLE_RECEIVED,
             AMOUNT,
             ATTRIBUTE_CATEGORY,
             ATTRIBUTE1,
             ATTRIBUTE2,
             ATTRIBUTE3,
             ATTRIBUTE4,
             ATTRIBUTE5,
             ATTRIBUTE6,
             ATTRIBUTE7,
             ATTRIBUTE8,
             ATTRIBUTE9,
             ATTRIBUTE10,
             ATTRIBUTE11,
             ATTRIBUTE12,
             ATTRIBUTE13,
             ATTRIBUTE14,
             ATTRIBUTE15,
             STY_ID_FOR,
             CLG_ID,
             CREATED_BY,
             CREATION_DATE,
             LAST_UPDATED_BY,
             LAST_UPDATE_DATE,
             LAST_UPDATE_LOGIN,
             DATE_FUNDING,
             DATE_FUNDING_REQUIRED,
             DATE_ACCEPTED,
             DATE_DELIVERY_EXPECTED,
             OEC,
             CAPITAL_AMOUNT,
             RESIDUAL_GRNTY_AMOUNT,
             RESIDUAL_CODE,
             RVI_PREMIUM,
             CREDIT_NATURE,
             CAPITALIZED_INTEREST,
             CAPITAL_REDUCTION_PERCENT,
             DATE_PAY_INVESTOR_START,
             PAY_INVESTOR_FREQUENCY,
             PAY_INVESTOR_EVENT,
             PAY_INVESTOR_REMITTANCE_DAYS,
             FEE_TYPE,
             SUBSIDY_ID,
/* subsidy columns removed later, 09/26/2003
             SUBSIDIZED_OEC,
             SUBSIDIZED_CAP_AMOUNT,
*/
             PRE_TAX_YIELD,
             AFTER_TAX_YIELD,
             IMPLICIT_INTEREST_RATE,
             IMPLICIT_NON_IDC_INTEREST_RATE,
             PRE_TAX_IRR,
             AFTER_TAX_IRR,
             SUBSIDY_OVERRIDE_AMOUNT,
             SUB_PRE_TAX_YIELD,
             SUB_AFTER_TAX_YIELD,
             SUB_IMPL_INTEREST_RATE,
             SUB_IMPL_NON_IDC_INT_RATE,
             SUB_PRE_TAX_IRR,
             SUB_AFTER_TAX_IRR,
--Bug# 2994971 :
             ITEM_INSURANCE_CATEGORY,
             --Bug# 3973640: 11.5.10 Schema changes
             QTE_ID,
             FUNDING_DATE,
             STREAM_TYPE_SUBCLASS
-- ramurt Bug#4552772
             ,FEE_PURPOSE_CODE
--Bug# 4631549
   ,EXPECTED_ASSET_COST
--Bug# 5192636
   ,DOWN_PAYMENT_RECEIVER_CODE
   ,CAPITALIZE_DOWN_PAYMENT_YN
   --start NISINHA bug # 6490572
   ,MODEL_NUMBER
   ,MANUFACTURER_NAME
   --end NISINHA bug # 6490572
   FROM OKL_K_LINES_V
    WHERE OKL_K_LINES_V.id     = p_kle_id;
    l_okl_k_lines_v_pk         okl_k_lines_v_pk_csr%ROWTYPE;
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Get current database values
    OPEN okl_k_lines_v_pk_csr (p_id);
    FETCH okl_k_lines_v_pk_csr INTO
        x_klev_rec.ID,
        x_klev_rec.OBJECT_VERSION_NUMBER,
        x_klev_rec.KLE_ID,
        x_klev_rec.STY_ID,
        x_klev_rec.PRC_CODE,
        x_klev_rec.FCG_CODE,
        x_klev_rec.NTY_CODE,
        x_klev_rec.ESTIMATED_OEC,
        x_klev_rec.LAO_AMOUNT,
        x_klev_rec.TITLE_DATE,
        x_klev_rec.FEE_CHARGE,
        x_klev_rec.LRS_PERCENT,
        x_klev_rec.INITIAL_DIRECT_COST,
        x_klev_rec.PERCENT_STAKE,
        x_klev_rec.PERCENT,
        x_klev_rec.EVERGREEN_PERCENT,
        x_klev_rec.AMOUNT_STAKE,
        x_klev_rec.OCCUPANCY,
        x_klev_rec.COVERAGE,
        x_klev_rec.RESIDUAL_PERCENTAGE,
        x_klev_rec.DATE_LAST_INSPECTION,
        x_klev_rec.DATE_SOLD,
        x_klev_rec.LRV_AMOUNT,
        x_klev_rec.CAPITAL_REDUCTION,
        x_klev_rec.DATE_NEXT_INSPECTION_DUE,
        x_klev_rec.DATE_RESIDUAL_LAST_REVIEW,
        x_klev_rec.DATE_LAST_REAMORTISATION,
        x_klev_rec.VENDOR_ADVANCE_PAID,
        x_klev_rec.WEIGHTED_AVERAGE_LIFE,
        x_klev_rec.TRADEIN_AMOUNT,
        x_klev_rec.BOND_EQUIVALENT_YIELD,
        x_klev_rec.TERMINATION_PURCHASE_AMOUNT,
        x_klev_rec.REFINANCE_AMOUNT,
        x_klev_rec.YEAR_BUILT,
        x_klev_rec.DELIVERED_DATE,
        x_klev_rec.CREDIT_TENANT_YN,
        x_klev_rec.DATE_LAST_CLEANUP,
        x_klev_rec.YEAR_OF_MANUFACTURE,
        x_klev_rec.COVERAGE_RATIO,
        x_klev_rec.REMARKETED_AMOUNT,
        x_klev_rec.GROSS_SQUARE_FOOTAGE,
        x_klev_rec.PRESCRIBED_ASSET_YN,
        x_klev_rec.DATE_REMARKETED,
        x_klev_rec.NET_RENTABLE,
        x_klev_rec.REMARKET_MARGIN,
        x_klev_rec.DATE_LETTER_ACCEPTANCE,
        x_klev_rec.REPURCHASED_AMOUNT,
        x_klev_rec.DATE_COMMITMENT_EXPIRATION,
        x_klev_rec.DATE_REPURCHASED,
        x_klev_rec.DATE_APPRAISAL,
        x_klev_rec.RESIDUAL_VALUE,
        x_klev_rec.APPRAISAL_VALUE,
        x_klev_rec.SECURED_DEAL_YN,
        x_klev_rec.GAIN_LOSS,
        x_klev_rec.FLOOR_AMOUNT,
        x_klev_rec.RE_LEASE_YN,
        x_klev_rec.PREVIOUS_CONTRACT,
        x_klev_rec.TRACKED_RESIDUAL,
        x_klev_rec.DATE_TITLE_RECEIVED,
        x_klev_rec.AMOUNT,
        x_klev_rec.ATTRIBUTE_CATEGORY,
        x_klev_rec.ATTRIBUTE1,
        x_klev_rec.ATTRIBUTE2,
        x_klev_rec.ATTRIBUTE3,
        x_klev_rec.ATTRIBUTE4,
        x_klev_rec.ATTRIBUTE5,
        x_klev_rec.ATTRIBUTE6,
        x_klev_rec.ATTRIBUTE7,
        x_klev_rec.ATTRIBUTE8,
        x_klev_rec.ATTRIBUTE9,
        x_klev_rec.ATTRIBUTE10,
        x_klev_rec.ATTRIBUTE11,
        x_klev_rec.ATTRIBUTE12,
        x_klev_rec.ATTRIBUTE13,
        x_klev_rec.ATTRIBUTE14,
        x_klev_rec.ATTRIBUTE15,
        x_klev_rec.STY_ID_FOR,
        x_klev_rec.CLG_ID,
        x_klev_rec.CREATED_BY,
        x_klev_rec.CREATION_DATE,
        x_klev_rec.LAST_UPDATED_BY,
        x_klev_rec.LAST_UPDATE_DATE,
        x_klev_rec.LAST_UPDATE_LOGIN,
        x_klev_rec.DATE_FUNDING,
        x_klev_rec.DATE_FUNDING_REQUIRED,
        x_klev_rec.DATE_ACCEPTED,
        x_klev_rec.DATE_DELIVERY_EXPECTED,
        x_klev_rec.OEC,
        x_klev_rec.CAPITAL_AMOUNT,
        x_klev_rec.RESIDUAL_GRNTY_AMOUNT,
        x_klev_rec.RESIDUAL_CODE,
        x_klev_rec.RVI_PREMIUM,
        x_klev_rec.CREDIT_NATURE,
        x_klev_rec.CAPITALIZED_INTEREST,
        x_klev_rec.CAPITAL_REDUCTION_PERCENT,
        x_klev_rec.DATE_PAY_INVESTOR_START,
        x_klev_rec.PAY_INVESTOR_FREQUENCY,
        x_klev_rec.PAY_INVESTOR_EVENT,
        x_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS,
        x_klev_rec.FEE_TYPE,
        x_klev_rec.SUBSIDY_ID,
/* subsidy colymns removed later, 09/26/2003
        x_klev_rec.SUBSIDIZED_OEC,
        x_klev_rec.SUBSIDIZED_CAP_AMOUNT,
*/
        x_klev_rec.PRE_TAX_YIELD,
        x_klev_rec.AFTER_TAX_YIELD,
        x_klev_rec.IMPLICIT_INTEREST_RATE,
        x_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
        x_klev_rec.PRE_TAX_IRR,
        x_klev_rec.AFTER_TAX_IRR,
        x_klev_rec.SUBSIDY_OVERRIDE_AMOUNT,
        x_klev_rec.SUB_PRE_TAX_YIELD,
        x_klev_rec.SUB_AFTER_TAX_YIELD,
        x_klev_rec.SUB_IMPL_INTEREST_RATE,
        x_klev_rec.SUB_IMPL_NON_IDC_INT_RATE,
        x_klev_rec.SUB_PRE_TAX_IRR,
        x_klev_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971 :
        x_klev_rec.ITEM_INSURANCE_CATEGORY,
        --Bug# 3973640: 11.5.10 Schema changes
        x_klev_rec.QTE_ID,
        x_klev_rec.FUNDING_DATE,
        x_klev_rec.STREAM_TYPE_SUBCLASS
--ramurt Bug#4552772
   ,x_klev_rec.FEE_PURPOSE_CODE
--Bug# 4631549
   ,x_klev_rec.EXPECTED_ASSET_COST
--Bug# 5192636
   ,x_klev_rec.DOWN_PAYMENT_RECEIVER_CODE
   ,x_klev_rec.CAPITALIZE_DOWN_PAYMENT_YN
-- start NISINHA Bug# 6490572
   ,x_klev_rec.MODEL_NUMBER
   ,x_klev_rec.MANUFACTURER_NAME;
--end NISINHA Bug # 6490572

    IF  okl_k_lines_v_pk_csr%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_k_lines_v_pk_csr;
    RETURN(x_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.set_message(G_APP_NAME,
                          G_UNEXPECTED_ERROR,
                          G_SQLCODE_TOKEN,
                          SQLCODE,
                          G_SQLERRM_TOKEN,
                          SQLERRM);
     -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     -- if the cursor is open
     IF okl_k_lines_v_pk_csr%ISOPEN THEN
        CLOSE okl_k_lines_v_pk_csr;
     END IF;
     RETURN(x_return_status);
  END get_rec_klev;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_new_Ast_Num_update
-- Description          : Validate_new_Ast_Num_update
-- Business Rules       : Validate Asset_Number against OKL_TXL_ASSETS_B.ASSET_NUMBER
--                        ,as same should not exists in table
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets
  PROCEDURE validate_new_ast_num_update(x_return_status OUT NOCOPY VARCHAR2,
                                        p_asset_number IN OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                                        p_kle_Id       IN OKL_TXL_ASSETS_V.KLE_ID%TYPE,
                                        p_dnz_chr_id   IN OKC_K_HEADERS_B.ID%TYPE) IS
    ln_okl_txl_assets_v           NUMBER := 0;
    ln_okx_assets_v               NUMBER := 0;
    ln_okx_asset_lines_v          NUMBER := 0;
    ln_okl_txd_assets_v           NUMBER := 0;
    lv_source_code                OKC_K_HEADERS_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    lv_asset_source_code          OKC_K_LINES_B.ORIG_SYSTEM_SOURCE_CODE%TYPE;
    lv_asset_number               OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE;
    lv_release_asset              OKC_RULES_V.RULE_INFORMATION1%TYPE := 'N';
    x_msg_count                   NUMBER;
    x_msg_data                    VARCHAR2(100);

    CURSOR c_get_asset_number(p_kle_Id       OKL_TXL_ASSETS_V.KLE_ID%TYPE)
    IS
    SELECT NAME
    FROM OKC_K_LINES_TL
    WHERE ID = (SELECT CLE_ID
                FROM OKC_K_LINES_B
                WHERE ID = p_kle_Id)
    AND language = USERENV('lang');

    CURSOR c_txl_asset_number(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE,
                              p_kle_Id       OKL_TXL_ASSETS_V.KLE_ID%TYPE)
    IS
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_B
                  WHERE asset_number = p_asset_number
                  AND kle_id <> p_kle_id; --);

    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSET_LINES_V
                  WHERE asset_number = p_asset_number; --);

    CURSOR c_okx_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number; --);

    CURSOR c_txd_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TRX_ASSETS TAS,
                       OKL_TXL_ASSETS_V TXL,
                       OKL_TXD_ASSETS_V TXD
                  WHERE TXD.asset_number = p_asset_number
                  AND   TXD.TAL_ID       = TXL.ID
                  AND   TXL.TAL_TYPE     = 'ALI'
                  AND   TXL.TAS_ID       =  TAS.ID
                  AND   TAS.TSU_CODE     = 'ENTERED'; --);

    CURSOR c_source_code(p_kle_Id OKL_TXL_ASSETS_V.KLE_ID%TYPE) is
    SELECT nvl(chr.orig_system_source_code,'x')
    FROM okc_k_headers_b chr,
         okc_k_lines_b cle
    WHERE cle.id = p_kle_Id
    AND cle.dnz_chr_id = chr.id;

    CURSOR c_check_release_asset(p_dnz_chr_id OKC_K_HEADERS_B.ID%TYPE) is
    SELECT RULE_INFORMATION1
    FROM   OKC_RULES_V
    WHERE  DNZ_CHR_ID = p_dnz_chr_id
    AND    RULE_INFORMATION_CATEGORY = 'LARLES';

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asset_number = OKL_API.G_MISS_CHAR) OR
      (p_asset_number IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'ASSET_NUMBER');
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    -- Get the Release asset code from OKC_RULES_V
    OPEN  c_check_release_asset(p_dnz_chr_id);
    FETCH c_check_release_asset into lv_release_asset;
    IF c_check_release_asset%NOTFOUND THEN
      lv_release_asset := 'N';
/*      x_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_RULES_V.RULE_INFORMATION1');
      RAISE G_EXCEPTION_HALT_VALIDATION;*/
    END IF;
    CLOSE c_check_release_asset;

    --
    -- Check whether asset residual value is securitized
    -- If so, do not allow release of the asset
    --
    IF (upper(lv_release_asset) = 'Y') THEN
       okl_transaction_pvt.check_contract_securitized(
                                 p_api_version        => 1.0,
                                 p_init_msg_list      => OKL_API.G_FALSE,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 p_chr_id             => p_dnz_chr_id,
                                 p_cle_id             => p_kle_id,
                                 p_stream_type_class  => 'RESIDUAL',
                                 p_trx_date           => SYSDATE
                                );

       IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_ASSET_SECU_ERROR',
                              p_token1       => 'ASSET_NUM',
                              p_token1_value => p_asset_number
                             );

          x_return_status := OKL_API.G_RET_STS_ERROR;
          RETURN; -- no further processing
       END IF;
    END IF;

    -- For released assets, we should not handle asset number validation.
    IF (upper(lv_release_asset) = 'N') THEN -- Start of release asset check

      -- Get the asset number from the system
      OPEN  c_get_asset_number(p_kle_id);
      FETCH c_get_asset_number into lv_asset_number;
      IF c_get_asset_number%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_get_asset_number;

      -- Check the asset number being changed
      IF (p_asset_number <> lv_asset_number) THEN -- Start of Asset number equality check

        OPEN  c_source_code(p_kle_id);
        FETCH c_source_code into lv_source_code;
        CLOSE c_source_code;

        IF lv_source_code NOT IN ('OKL_REBOOK') THEN
          -- Enforce validation
          -- Validate if the Asset Number exists in OKL_TXL_ASSETS_B
          OPEN  c_txl_asset_number(p_asset_number,
                                   p_kle_id);
          FETCH c_txl_asset_number into ln_okl_txl_assets_v;
          IF c_txl_asset_number%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txl_asset_number;

          -- Validate if the Asset Number exists in OKX_ASSETS_V
          OPEN  c_okx_assets_v(p_asset_number);
          FETCH c_okx_assets_v into ln_okx_assets_v;
          IF c_okx_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_assets_v;

          -- Validate if the Asset Number exists in OKX_ASSET_LINES_V
          OPEN  c_okx_asset_lines_v(p_asset_number);
          FETCH c_okx_asset_lines_v into ln_okx_asset_lines_v;
          IF c_okx_asset_lines_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_asset_lines_v;

          -- Validate if the Asset Number exists in OKL_TXD_ASSETS_V
          -- for Split Asset scenario.
          OPEN  c_txd_assets_v(p_asset_number);
          FETCH c_txd_assets_v into ln_okl_txd_assets_v;
          IF c_txd_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txd_assets_v;

        ELSIF (lv_source_code = 'x'  OR lv_source_code = OKL_API.G_MISS_CHAR)THEN
          -- Enforce validation
          -- Validate if the Asset Number exists in OKL_TXL_ASSETS_B
          OPEN  c_txl_asset_number(p_asset_number,
                                   p_kle_id);
          FETCH c_txl_asset_number into ln_okl_txl_assets_v;
          IF c_txl_asset_number%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txl_asset_number;

          -- Validate if the Asset Number exists in OKX_ASSETS_V
          OPEN  c_okx_assets_v(p_asset_number);
          FETCH c_okx_assets_v into ln_okx_assets_v;
          IF c_okx_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_assets_v;

          -- Validate if the Asset Number exists in OKX_ASSET_LINES_V
          OPEN  c_okx_asset_lines_v(p_asset_number);
          FETCH c_okx_asset_lines_v into ln_okx_asset_lines_v;
          IF c_okx_asset_lines_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_asset_lines_v;

          -- Validate if the Asset Number exists in OKL_TXD_ASSETS_V
          -- for Split Asset scenario.
          OPEN  c_txd_assets_v(p_asset_number);
          FETCH c_txd_assets_v into ln_okl_txd_assets_v;
          IF c_txd_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txd_assets_v;

          -- Since we have add this check only the cases if the asset number
          -- cannot be duplicate  when created new fo re_book scenario
        ELSIF lv_source_code = 'OKL_REBOOK' THEN
          -- Validate if the Asset Number exists in OKL_TXL_ASSETS_V
          OPEN  c_txl_asset_number(p_asset_number,
                                   p_kle_Id);
          FETCH c_txl_asset_number into ln_okl_txl_assets_v;
          IF c_txl_asset_number%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txl_asset_number;

          -- Validate if the Asset Number exists in OKX_ASSETS_V
          OPEN  c_okx_assets_v(p_asset_number);
          FETCH c_okx_assets_v into ln_okx_assets_v;
          IF c_okx_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_assets_v;

          -- Validate if the Asset Number exists in OKX_ASSET_LINES_V
          OPEN  c_okx_asset_lines_v(p_asset_number);
          FETCH c_okx_asset_lines_v into ln_okx_asset_lines_v;
          IF c_okx_asset_lines_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_okx_asset_lines_v;

          -- Validate if the Asset Number exists in OKL_TXD_ASSETS_V
          -- for Split Asset scenario.
          OPEN  c_txd_assets_v(p_asset_number);
          FETCH c_txd_assets_v into ln_okl_txd_assets_v;
          IF c_txd_assets_v%NOTFOUND THEN
            x_return_status := OKL_API.G_RET_STS_SUCCESS;
          END IF;
          CLOSE c_txd_assets_v;
        END IF;

        IF (ln_okl_txl_assets_v = 1)  OR (ln_okx_assets_v = 1) OR
           (ln_okx_asset_lines_v = 1) OR (ln_okl_txd_assets_v = 1) THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ASSET_NUMBER);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSIF (ln_okl_txl_assets_v = 1) AND (ln_okx_assets_v = 1) AND
              (ln_okx_asset_lines_v = 1) AND (ln_okl_txd_assets_v = 1) THEN
          -- store SQL error message on message stack
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ASSET_NUMBER);
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
      END IF; -- End of Asset number equality check
    END IF; -- End of release asset check
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
    IF c_txl_asset_number%ISOPEN THEN
       CLOSE c_txl_asset_number;
    END IF;
    IF c_source_code%ISOPEN THEN
      CLOSE c_source_code;
    END IF;
    IF c_okx_assets_v%ISOPEN THEN
       CLOSE c_okx_assets_v;
    END IF;
    IF c_okx_asset_lines_v%ISOPEN THEN
       CLOSE c_okx_asset_lines_v;
    END IF;
    IF c_check_release_asset%ISOPEN THEN
       CLOSE c_check_release_asset;
    END IF;

    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
    IF c_txl_asset_number%ISOPEN THEN
       CLOSE c_txl_asset_number;
    END IF;
    IF c_source_code%ISOPEN THEN
      CLOSE c_source_code;
    END IF;
    IF c_okx_assets_v%ISOPEN THEN
       CLOSE c_okx_assets_v;
    END IF;
    IF c_okx_asset_lines_v%ISOPEN THEN
       CLOSE c_okx_asset_lines_v;
    END IF;
    IF c_check_release_asset%ISOPEN THEN
       CLOSE c_check_release_asset;
    END IF;

    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_txl_asset_number%ISOPEN THEN
       CLOSE c_txl_asset_number;
    END IF;
    IF c_source_code%ISOPEN THEN
      CLOSE c_source_code;
    END IF;
    IF c_okx_assets_v%ISOPEN THEN
       CLOSE c_okx_assets_v;
    END IF;
    IF c_okx_asset_lines_v%ISOPEN THEN
       CLOSE c_okx_asset_lines_v;
    END IF;
    IF c_check_release_asset%ISOPEN THEN
       CLOSE c_check_release_asset;
    END IF;

    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_new_ast_num_update;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_new_Asset_Number
-- Description          : Validation for new Asset Number
-- Business Rules       : Validate Asset_Number against OKL_TXL_ASSETS_B.ASSET_NUMBER
--                        ,as same should not exists in table
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets
  PROCEDURE validate_new_asset_number(x_return_status OUT NOCOPY VARCHAR2,
                                      p_asset_number IN OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                                      p_dnz_chr_id   IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    ln_okl_txl_assets_v           NUMBER := 0;
    ln_okx_assets_v               NUMBER := 0;
    ln_okx_asset_lines_v          NUMBER := 0;
    ln_okl_txd_assets_v           NUMBER := 0;
    lv_release_asset              OKC_RULES_V.RULE_INFORMATION1%TYPE := 'N';

    CURSOR c_txl_asset_number(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_B
                  WHERE asset_number = p_asset_number; --);
    /*CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSET_LINES_V
                  WHERE asset_number = p_asset_number; --); */
    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    FROM fa_additions a
    WHERE a.asset_number = p_asset_number
    and exists
     (
       select 1 from okc_k_items b
       where b.jtot_object1_code = 'OKX_ASSET'
       and   b.object1_id1 = to_char(a.asset_id)
     );

    CURSOR c_okx_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number; --);

    CURSOR c_txd_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TRX_ASSETS TAS,
                       OKL_TXL_ASSETS_V TXL,
                       OKL_TXD_ASSETS_V TXD
                  WHERE TXD.asset_number = p_asset_number
                  AND   TXD.TAL_ID       = TXL.ID
                  AND   TXL.TAL_TYPE     = 'ALI'
                  AND   TXL.TAS_ID       =  TAS.ID
                  AND   TAS.TSU_CODE     = 'ENTERED'; --);

    CURSOR c_check_release_asset(p_dnz_chr_id   IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE) is
    SELECT RULE_INFORMATION1
    FROM   OKC_RULES_V
    WHERE  DNZ_CHR_ID = p_dnz_chr_id
    AND    RULE_INFORMATION_CATEGORY = 'LARLES';

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asset_number = OKL_API.G_MISS_CHAR) OR (p_asset_number IS NULL) THEN
      -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'ASSET_NUMBER');
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    IF (p_dnz_chr_id = OKL_API.G_MISS_NUM) OR (p_dnz_chr_id IS NULL) THEN
      -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'DNZ_CHR_ID');
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    -- Get the Release asset code from OKC_RULES_V
    OPEN  c_check_release_asset(p_dnz_chr_id);
    FETCH c_check_release_asset into lv_release_asset;
    IF c_check_release_asset%NOTFOUND THEN
      lv_release_asset := 'N';
/*      x_return_status := OKL_API.G_RET_STS_ERROR;
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_RULES_V.RULE_INFORMATION1');
      RAISE G_EXCEPTION_HALT_VALIDATION;*/
    END IF;
    CLOSE c_check_release_asset;

    -- For released assets, we should not handle asset number validation.
    IF (upper(lv_release_asset) = 'N') THEN -- Start of release asset check
      -- Enforce validation
      -- Validate if the Asset Number exists in OKL_TXL_ASSETS_B
      OPEN  c_txl_asset_number(p_asset_number);
      FETCH c_txl_asset_number into ln_okl_txl_assets_v;
      IF c_txl_asset_number%NOTFOUND THEN
         x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_txl_asset_number;

      -- Validate if the Asset Number exists in OKX_ASSETS_V
      OPEN  c_okx_assets_v(p_asset_number);
      FETCH c_okx_assets_v into ln_okx_assets_v;
      IF c_okx_assets_v%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_okx_assets_v;

      -- Validate if the Asset Number exists in OKX_ASSET_LINES_V
      OPEN  c_okx_asset_lines_v(p_asset_number);
      FETCH c_okx_asset_lines_v into ln_okx_asset_lines_v;
      IF c_okx_asset_lines_v%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_okx_asset_lines_v;

      -- Validate if the Asset Number exists in OKL_TXD_ASSETS_V
      -- for Split Asset scenario.
      OPEN  c_txd_assets_v(p_asset_number);
      FETCH c_txd_assets_v into ln_okl_txd_assets_v;
      IF c_txd_assets_v%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE c_txd_assets_v;

      IF (ln_okl_txl_assets_v = 1) OR (ln_okx_assets_v = 1) OR
         (ln_okx_asset_lines_v = 1) OR (ln_okl_txd_assets_v = 1) THEN
        -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_ASSET_NUMBER);
         RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSIF (ln_okl_txl_assets_v = 1) AND (ln_okx_assets_v = 1) AND
            (ln_okx_asset_lines_v = 1) AND (ln_okl_txd_assets_v = 1) THEN
        -- store SQL error message on message stack
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ASSET_NUMBER);
        RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
    IF c_txl_asset_number%ISOPEN THEN
       CLOSE c_txl_asset_number;
    END IF;
    IF c_okx_assets_v%ISOPEN THEN
       CLOSE c_okx_assets_v;
    END IF;
    IF c_okx_asset_lines_v%ISOPEN THEN
       CLOSE c_okx_asset_lines_v;
    END IF;
    IF c_txd_assets_v%ISOPEN THEN
       CLOSE c_txd_assets_v;
    END IF;
    IF c_check_release_asset%ISOPEN THEN
       CLOSE c_check_release_asset;
    END IF;

    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_txl_asset_number%ISOPEN THEN
       CLOSE c_txl_asset_number;
    END IF;
    IF c_okx_assets_v%ISOPEN THEN
       CLOSE c_okx_assets_v;
    END IF;
    IF c_okx_asset_lines_v%ISOPEN THEN
       CLOSE c_okx_asset_lines_v;
    END IF;
    IF c_txd_assets_v%ISOPEN THEN
       CLOSE c_txd_assets_v;
    END IF;
    IF c_check_release_asset%ISOPEN THEN
       CLOSE c_check_release_asset;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_new_asset_number;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_asset_tax_book
-- Description          : Validation Asset tax Book
-- Business Rules       : Validate Asset_Number, tax_book and tal type should be unique
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets
  PROCEDURE Validate_asset_tax_book(x_return_status OUT NOCOPY VARCHAR2,
                                    p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE,
                                    p_tax_book     OKL_TXD_ASSETS_B.TAX_BOOK%TYPE,
                                    p_tal_id       OKL_TXL_ASSETS_B.ID%TYPE) IS
    ln_asset_lines_dtls           NUMBER := 0;
    CURSOR c_asset_lines_dtls_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE,
                                p_tax_book     OKL_TXD_ASSETS_B.TAX_BOOK%TYPE,
                                p_tal_id       OKL_TXL_ASSETS_B.ID%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXD_ASSETS_B txd,
                       OKL_TXL_ASSETS_B txl
                  WHERE txl.asset_number = p_asset_number
                  AND txl.asset_number = txd.asset_number
                  AND txl.tal_type IN ('CFA','CIB','CRB','CRL','CSP','CRV')
                  AND txd.tal_id = txl.id
                  AND txd.tal_id = p_tal_id
                  AND txd.tax_book = p_tax_book; --);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_asset_number = OKL_API.G_MISS_CHAR OR
       p_asset_number IS NULL) OR
       (p_tal_id = OKL_API.G_MISS_NUM OR
       p_tal_id IS NULL) OR
       (p_tax_book = OKL_API.G_MISS_CHAR OR
       p_tax_book IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'ASSET_NUMBER ,TAX BOOK and TAL ID');
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce validation
    -- Validate if the Asset Number exists in OKX_ASSET_LINES_V
    OPEN  c_asset_lines_dtls_v(p_asset_number => p_asset_number,
                               p_tax_book => p_tax_book,
                               p_tal_id => p_tal_id);
    FETCH c_asset_lines_dtls_v into ln_asset_lines_dtls;
    IF c_asset_lines_dtls_v%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE c_asset_lines_dtls_v;
    IF (ln_asset_lines_dtls = 1) THEN
       -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_ASSET_NUMBER);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
    IF c_asset_lines_dtls_v%ISOPEN THEN
       CLOSE c_asset_lines_dtls_v;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_asset_lines_dtls_v%ISOPEN THEN
       CLOSE c_asset_lines_dtls_v;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END Validate_asset_tax_book;
----------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_instance_number_ib
-- Description          : validate_instance_number_ib
-- Business Rules       : Validate instance_number_ib against OKL_TXL_ITM_INSTS.INSTANCE_NUMBER_IB
--                        ,as same should not exists in table
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_instance_number_ib(x_return_status OUT NOCOPY VARCHAR2,
                                        p_inst_num_ib IN OKL_TXL_ITM_INSTS.INSTANCE_NUMBER_IB%TYPE) IS
    ln_dummy number := 0;
    CURSOR c_inst_num_ib_validate(p_inst_ib  OKL_TXL_ITM_INSTS.INSTANCE_NUMBER_IB%TYPE) is
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ITM_INSTS
                  WHERE instance_number_ib = p_inst_ib; --);

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_inst_num_ib = OKL_API.G_MISS_CHAR OR
       p_inst_num_ib IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'INSTANCE_NUMBER_IB');
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce validation
    OPEN  c_inst_num_ib_validate(p_inst_num_ib);
    FETCH c_inst_num_ib_validate into ln_dummy;
    IF c_inst_num_ib_validate%NOTFOUND THEN
       -- Since no parent record existing in OKL_TXL_ITM_INSTS
       x_return_status := OKL_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE c_inst_num_ib_validate;
    IF (ln_dummy = 1) THEN
       -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_INSTALL_BASE_NUMBER);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    -- If the cursor is open then it has to be closed
    IF c_inst_num_ib_validate%ISOPEN THEN
       CLOSE c_inst_num_ib_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
     -- store SQL error message on message stack
     OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                         p_msg_name     => G_UNEXPECTED_ERROR,
                         p_token1       => G_SQLCODE_TOKEN,
                         p_token1_value => SQLCODE,
                         p_token2       => G_SQLERRM_TOKEN,
                         p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_inst_num_ib_validate%ISOPEN THEN
       CLOSE c_inst_num_ib_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_instance_number_ib;
------------------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_lse_id
-- Description          : validation and get the lty_code
--                        with OKC_LINE_STYLES_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets
  PROCEDURE validate_lse_id(p_clev_rec      IN clev_rec_type,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_lty_code      OUT NOCOPY OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                            x_lse_type      OUT NOCOPY OKC_LINE_STYLES_V.LSE_TYPE%TYPE) IS
    CURSOR c_lse_id_validate(p_lse_id     OKC_LINE_STYLES_V.ID%TYPE) IS
    SELECT lty_code,
           lse_type
    FROM OKC_LINE_STYLES_V
    WHERE id = p_lse_id;
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_clev_rec.lse_id = OKL_API.G_MISS_NUM) OR
       (p_clev_rec.lse_id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.LSE_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_lse_id_validate(p_clev_rec.lse_id);
    FETCH c_lse_id_validate into x_lty_code,
                                 x_lse_type;
            -- If there are no records then
    IF c_lse_id_validate%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.LSE_ID');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_lse_id_validate;
    -- If we have null records coming up
    IF (x_lty_code = OKL_API.G_MISS_CHAR OR
       x_lty_code IS NULL) AND
       (x_lse_type =  OKL_API.G_MISS_CHAR OR
       x_lse_type IS NULL) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.LSE_ID');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
    IF c_lse_id_validate%ISOPEN THEN
       CLOSE c_lse_id_validate;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_lse_id_validate%ISOPEN THEN
       CLOSE c_lse_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_lse_id;
---------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_cle_lse_id
-- Description          : validation of the cle_id
--                        with OKC_k_LINES_V and Check if the line style is TLS
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_cle_lse_id(p_clev_rec      IN clev_rec_type,
                                p_lty_code      IN OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                x_lty_code      OUT NOCOPY OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    ln_cle_id          OKC_K_LINES_V.ID%TYPE := 0;
    lv_lse_type        OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    lv_lty_code        OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    CURSOR c_cle_id_validate(p_cle_id     OKC_K_LINES_V.CLE_ID%TYPE) IS
    SELECT lse.lty_code
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.id = p_cle_id
    AND lse.id = cle.lse_id;

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_clev_rec.cle_id = OKL_API.G_MISS_NUM OR
       p_clev_rec.cle_id IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.CLE_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- check the valid id is there
    OPEN  c_cle_id_validate(p_clev_rec.cle_id);
    IF c_cle_id_validate%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.CLE_ID');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_cle_id_validate into lv_lty_code;
    CLOSE c_cle_id_validate;
    --Business Rules
    IF p_lty_code  = G_MODEL_LINE_LTY_CODE AND
       lv_lty_code = G_FIN_LINE_LTY_CODE THEN
       x_lty_code  := lv_lty_code;
    ELSIF p_lty_code = G_ADDON_LINE_LTY_CODE AND
       lv_lty_code   = G_MODEL_LINE_LTY_CODE THEN
       x_lty_code  := lv_lty_code;
    ELSIF p_lty_code = G_FA_LINE_LTY_CODE AND
       lv_lty_code   = G_FIN_LINE_LTY_CODE THEN
       x_lty_code  := lv_lty_code;
    ELSIF p_lty_code = G_INST_LINE_LTY_CODE AND
       lv_lty_code   = G_FIN_LINE_LTY_CODE THEN
       x_lty_code  := lv_lty_code;
    ELSIF p_lty_code = G_IB_LINE_LTY_CODE AND
       lv_lty_code   = G_INST_LINE_LTY_CODE THEN
       x_lty_code  := lv_lty_code;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
       -- halt validation as it has invalid Value
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    IF c_cle_id_validate%ISOPEN THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    IF c_cle_id_validate%ISOPEN THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cle_lse_id;
----------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_dnz_chr_id
-- Description          : validation with OKC_K_LINES_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_dnz_chr_id(p_clev_rec IN clev_rec_type,
                                x_return_status OUT NOCOPY VARCHAR2) IS
    ln_dummy      NUMBER := 0;
    CURSOR c_dnz_chr_id_validate(p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT 1
                  FROM OKC_K_HEADERS_B chrv
                  WHERE chrv.id = p_dnz_chr_id; --);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_clev_rec.dnz_chr_id = OKL_API.G_MISS_NUM) OR
       (p_clev_rec.dnz_chr_id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    -- since we are creating a asset line
    -- we assume the cle_id will not null
    -- as the same is not top line and it will be sub line
    OPEN  c_dnz_chr_id_validate(p_clev_rec.dnz_chr_id);
    IF c_dnz_chr_id_validate%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID');
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_dnz_chr_id_validate into ln_dummy;
    CLOSE c_dnz_chr_id_validate;
    IF (ln_dummy = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID');
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
    IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_chr_id;
--------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : check_required_values
-- Description          : check_required_values
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  FUNCTION check_required_values(p_item1    IN OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                                 p_item2    IN OKC_K_ITEMS_V.OBJECT1_ID2%TYPE,
                                 p_ast_no   IN OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
                                 p_ast_desc IN OKL_TXL_ASSETS_TL.DESCRIPTION%TYPE,
                                 p_cost     IN OKL_TXL_ASSETS_B.ORIGINAL_COST%TYPE,
                                 p_units    IN OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE,
                                 p_ib_loc1  IN OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE,
                                 p_ib_loc2  IN OKL_TXL_ITM_INSTS_V.OBJECT_ID2_NEW%TYPE,
                                 p_fa_loc   IN OKL_TXL_ASSETS_B.FA_LOCATION_ID%TYPE,
                                 p_refinance_amount IN OKL_K_LINES.REFINANCE_AMOUNT%TYPE,
                                 p_chr_id   IN OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
  RETURN VARCHAR2 IS
    x_return_status          VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    ln_dummy                 NUMBER := 0;
    ln1_dummy                NUMBER := 0;
    ln2_dummy                NUMBER := 0;
    ln3_dummy                NUMBER := p_units;
    lv_deal_type             OKL_K_HEADERS_V.DEAL_TYPE%TYPE := null;
    lv_scs_code              OKC_K_HEADERS_V.SCS_CODE%TYPE := null;
    --Bug# 4419339
    l_orig_system_source_code   okc_k_headers_b.orig_system_source_code%TYPE;
    CURSOR get_deal_type(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
    IS
    SELECT khr.deal_type,
           chr.scs_code,
           --Bug# 4419339
           chr.orig_system_source_code
    FROM OKL_K_HEADERS_V khr,
         OKC_K_HEADERS_B chr
    WHERE khr.id = p_dnz_chr_id
    AND chr.id = khr.id;
  BEGIN
    IF (p_chr_id <> OKL_API.G_MISS_NUM OR
       p_chr_id IS NOT NULL) THEN
    OPEN  get_deal_type(p_dnz_chr_id => p_chr_id);
    FETCH get_deal_type into lv_deal_type,
                             lv_scs_code,
                             --Bug# 4419339
                             l_orig_system_source_code;
    CLOSE get_deal_type;
    END IF;
    -- data is required
    IF (p_item1 = OKL_API.G_MISS_CHAR OR
       p_item1 IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_item2 = OKL_API.G_MISS_CHAR OR
       p_item2 IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_ast_no = OKL_API.G_MISS_CHAR OR
       p_ast_no IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Asset Number');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_ast_desc = OKL_API.G_MISS_CHAR OR
       p_ast_desc IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Description');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_cost = OKL_API.G_MISS_NUM OR
       p_cost IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Unit Cost');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    ELSE
      ln_dummy := sign(p_cost);
      IF ln_dummy = -1 THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Unit Cost');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_STOP_VALIDATION;
      END IF;
    END IF;
    IF (ln3_dummy = OKL_API.G_MISS_NUM OR
       ln3_dummy IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Units');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    ELSE
      ln1_dummy := sign(p_units);
      IF ln1_dummy = -1 THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_INVALID_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Units');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_STOP_VALIDATION;
      END IF;
      ln2_dummy := instr(to_char(p_units),'.');
      IF ln2_dummy <> 0 THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_DECIMAL_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Units');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_STOP_VALIDATION;
      END IF;
    END IF;
    IF (p_ib_loc1 = OKL_API.G_MISS_CHAR OR
       p_ib_loc1 IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Installed Site');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_ib_loc2 = OKL_API.G_MISS_CHAR OR
       p_ib_loc2 IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Installed Site');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    IF (p_fa_loc = OKL_API.G_MISS_NUM OR
       p_fa_loc IS NULL) AND lv_scs_code <> 'QUOTE'  AND
       --Bug# 4419339
       nvl(l_orig_system_source_code,okl_api.g_miss_char) <> 'OKL_LEASE_APP' AND
       --Bug# 5098124 : Added condition for 'OKL_QUOTE'
       nvl(l_orig_system_source_code,okl_api.g_miss_char) <> 'OKL_QUOTE' THEN
      IF (lv_deal_type <> 'LOAN' AND (p_refinance_amount IS NULL OR
          p_refinance_amount = OKL_API.G_MISS_NUM)) THEN
        -- store SQL error message on message stack
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Fixed Asset Location');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_STOP_VALIDATION;
      END IF;
    END IF;
    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    RETURN(x_return_status);
    WHEN OTHERS THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'Error Message from Required values');
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    RETURN(x_return_status);
  END check_required_values;
--------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_kle_id
-- Description          : validation with OKL_TXL_ASSETS_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_kle_id(p_klev_rec      IN klev_rec_type,
                            x_record_exists OUT NOCOPY VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2) IS
    ln_dummy      NUMBER := 0;
    CURSOR c_kle_id_validate(p_kle_id OKL_TXL_ASSETS_V.KLE_ID%TYPE) IS
    SELECT 1
    --FROM dual
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_V
                  WHERE kle_id = p_kle_id; --);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_klev_rec.id = OKL_API.G_MISS_NUM) OR
       (p_klev_rec.id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TXL_ASSETS_V.KLE_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_kle_id_validate(p_klev_rec.id);
    FETCH c_kle_id_validate into ln_dummy;
    IF c_kle_id_validate%NOTFOUND THEN
       x_record_exists := null;
    END IF;
    CLOSE c_kle_id_validate;
    -- If there are no records then
    IF ln_dummy = 0 THEN
       x_record_exists := null;
    ELSE
       x_record_exists := 'X';
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_kle_id_validate%ISOPEN THEN
       CLOSE c_kle_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_kle_id;
--------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_iti_kle_id
-- Description          : validation with OKL_TXL_ITM_INSTS_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_iti_kle_id(p_klev_rec      IN klev_rec_type,
                            x_record_exists OUT NOCOPY VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2) IS
    ln_dummy      NUMBER := 0;
    CURSOR c_iti_kle_id_validate(p_kle_id OKL_TXL_ITM_INSTS_V.KLE_ID%TYPE) IS
    SELECT 1
    --FROM dual
    --WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ITM_INSTS_V
                  WHERE kle_id = p_kle_id; --);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_klev_rec.id = OKL_API.G_MISS_NUM) OR
       (p_klev_rec.id IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TXL_ITM_INSTS_V.KLE_ID');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_iti_kle_id_validate(p_klev_rec.id);
    FETCH c_iti_kle_id_validate into ln_dummy;
    IF c_iti_kle_id_validate%NOTFOUND THEN
       x_record_exists := null;
    END IF;
    CLOSE c_iti_kle_id_validate;
    -- If there are no records then
    IF ln_dummy = 0 THEN
       x_record_exists := null;
    ELSE
       x_record_exists := 'X';
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_iti_kle_id_validate%ISOPEN THEN
       CLOSE c_iti_kle_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_iti_kle_id;
----------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_sts_code
-- Description          : validation with OKC_K_LINES_V
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_sts_code(p_clev_rec IN clev_rec_type,
                              x_return_status OUT NOCOPY VARCHAR2) IS

    lv_sts_code       OKC_K_LINES_V.STS_CODE%TYPE;
    lv_lty_code       OKC_LINE_STYLES_V.lty_CODE%TYPE;

    CURSOR c_lty_code_validate(p_lse_id       OKC_LINE_STYLES_B.ID%TYPE) IS
    SELECT lse.lty_code
    FROM OKC_LINE_STYLES_V lse
    WHERE lse.id = p_lse_id;

    CURSOR c_sub_sub_line_sts_code(p_dnz_chr_id   OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                   p_cle_id       OKC_K_LINES_V.ID%TYPE,
                                   p_lty_code     OKC_LINE_STYLES_V.lty_CODE%TYPE) IS
    SELECT cle.sts_code
    FROM OKC_K_LINES_V cle
    WHERE cle.id in (SELECT cle.cle_id
                     FROM OKC_K_LINES_V cle
                     WHERE id in (SELECT cle.cle_id
                                  FROM OKC_LINE_STYLES_V lse,
                                       OKC_K_LINES_V cle
                                  WHERE dnz_chr_id = p_dnz_chr_id
                                  AND cle.lse_id = lse.id
                                  AND cle.id = p_cle_id
                                  AND lse.lty_code = p_lty_code));

    CURSOR c_sub_line_sts_code(p_dnz_chr_id   OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                               p_cle_id       OKC_K_LINES_V.ID%TYPE,
                               p_lty_code     OKC_LINE_STYLES_V.lty_CODE%TYPE) IS
    SELECT cle.sts_code
    FROM OKC_K_LINES_V cle
    WHERE id in (SELECT cle.cle_id
                 FROM OKC_LINE_STYLES_V lse,
                      OKC_K_LINES_V cle
                 WHERE dnz_chr_id = p_dnz_chr_id
                 AND cle.lse_id = lse.id
                 AND cle.id = p_cle_id
                 AND lse.lty_code = p_lty_code);

    CURSOR c_top_line_sts_code(p_dnz_chr_id   OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                               p_cle_id       OKC_K_LINES_V.ID%TYPE,
                               p_chr_id   OKC_K_LINES_V.CHR_ID%TYPE) IS
    SELECT cle.sts_code
    FROM OKC_K_LINES_V cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.cle_id is null
    AND cle.id = p_cle_id
    AND cle.chr_id = p_chr_id;
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    IF (p_clev_rec.sts_code = OKL_API.G_MISS_CHAR OR
       p_clev_rec.sts_code IS NULL) THEN
       -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.STS_CODE');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- First Get the Lty _code we are going to validate
    OPEN c_lty_code_validate(p_clev_rec.lse_id);
    IF c_lty_code_validate%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_LINE_STYLE_V.LTY_CODE');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_lty_code_validate INTO lv_lty_code;
    CLOSE c_lty_code_validate;
    -- Depending on the lty code query the appropriate query
    IF lv_lty_code = G_ADDON_LINE_LTY_CODE OR
       lv_lty_code = G_IB_LINE_LTY_CODE THEN
       OPEN c_sub_sub_line_sts_code(p_clev_rec.dnz_chr_id,
                                    p_clev_rec.id,
                                    lv_lty_code);
        IF c_sub_sub_line_sts_code%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.STS_CODE');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       FETCH c_sub_sub_line_sts_code INTO lv_sts_code;
       CLOSE c_sub_sub_line_sts_code;
    ELSIF lv_lty_code = G_MODEL_LINE_LTY_CODE OR
          lv_lty_code = G_FA_LINE_LTY_CODE OR
          lv_lty_code = G_INST_LINE_LTY_CODE THEN
       OPEN c_sub_line_sts_code(p_clev_rec.dnz_chr_id,
                                p_clev_rec.id,
                                lv_lty_code);
       IF c_sub_line_sts_code%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.STS_CODE');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       FETCH c_sub_line_sts_code INTO lv_sts_code;
       CLOSE c_sub_line_sts_code;
    ELSIF lv_lty_code = G_FIN_LINE_LTY_CODE THEN
       OPEN c_top_line_sts_code(p_clev_rec.dnz_chr_id,
                                p_clev_rec.id,
                                p_clev_rec.chr_id);
       IF c_top_line_sts_code%NOTFOUND THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V.STS_CODE');
         -- halt validation as it is a required field
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       FETCH c_top_line_sts_code INTO lv_sts_code;
       CLOSE c_top_line_sts_code;
    END IF;
    -- Check the Sts code is entered only
    IF lv_sts_code NOT IN ('ENTERED',
                           'SIGNED',
                           'ACTIVE',
                           'HOLD',
                           'NEW',
                           'PENDING_APPROVAL',
                           'APPROVED',
                           'COMPLETE',
                           'INCOMPLETE',
                           'PASSED') THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_STATUS,
                          p_token1       => 'STATUS',
                          p_token1_value => lv_sts_code);
      -- halt validation as it is a required field
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
    IF c_lty_code_validate%ISOPEN THEN
       CLOSE c_lty_code_validate;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_sub_sub_line_sts_code%ISOPEN THEN
       CLOSE c_sub_sub_line_sts_code;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_sub_line_sts_code%ISOPEN THEN
       CLOSE c_sub_line_sts_code;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_top_line_sts_code%ISOPEN THEN
       CLOSE c_top_line_sts_code;
    END IF;
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_lty_code_validate%ISOPEN THEN
       CLOSE c_lty_code_validate;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_sub_sub_line_sts_code%ISOPEN THEN
       CLOSE c_sub_sub_line_sts_code;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_sub_line_sts_code%ISOPEN THEN
       CLOSE c_sub_line_sts_code;
    END IF;
    -- If the cursor is open then it has to be closed
    IF c_top_line_sts_code%ISOPEN THEN
       CLOSE c_top_line_sts_code;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_sts_code;
----------------------------------------------------------------------------------------------------------
  PROCEDURE Create_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TRX_ASSET_HEADER';
  BEGIN
    x_return_status      := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.create_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_asset_header;
--------------------------------------------------------------------------------------------------
-- Local Procedures for Update of Header record
-- Incase where the error condition should be updated
  PROCEDURE Update_asset_header(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_trxv_rec       IN  trxv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TRX_ASSET_HEADER';
  BEGIN
    x_return_status        := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TRX_ASSETS_PUB.update_trx_ass_h_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_thpv_rec       => p_trxv_rec,
                       x_thpv_rec       => x_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_TRX_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_asset_header;
------------------------------------------------------------------------------------------------------
  PROCEDURE Create_asset_lines(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_talv_rec       IN  talv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ASSET_LINE';
    l_trxv_rec               trxv_rec_type;
    l_talv_rec               talv_rec_type;

    --Added by dpsingh for LE uptake
    l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_legal_entity_id          NUMBER;

  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Create New Header record and new Line record
    -- Before creating Header record
    -- we should make sure atleast the required record is given
    l_trxv_rec.tas_type            := 'CFA';
    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;

    --Added by dpsingh for LE Uptake

    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_talv_rec.dnz_khr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_talv_rec.dnz_khr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now creating the new header record
    Create_asset_header(p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_trxv_rec       => l_trxv_rec,
                        x_trxv_rec       => x_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';
       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';
       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are creating the new line record
    l_talv_rec                 := p_talv_rec;
    l_talv_rec.tas_id          := x_trxv_rec.id;
    IF (l_talv_rec.tal_type = OKL_API.G_MISS_CHAR OR
       l_talv_rec.tal_type IS NUll) THEN
       l_talv_rec.tal_type       := 'CFA';
    END IF;
    IF (l_talv_rec.line_number = OKL_API.G_MISS_NUM OR
       l_talv_rec.line_number IS NUll) THEN
       l_talv_rec.line_number       := 1;
    ELSE
       l_talv_rec.line_number       := l_talv_rec.line_number + 1;
    END IF;
    IF (l_talv_rec.description = OKL_API.G_MISS_CHAR OR
        l_talv_rec.description IS NUll) THEN
        l_talv_rec.description := 'CREATION OF FIXED ASSETS' ;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => l_talv_rec,
                       x_tlpv_rec       => x_talv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_KLE_ID);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_KLE_ID);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_asset_lines;
-------------------------------------------------------------------------------------------------------------------
-- Local Procedures for update of line record
  PROCEDURE Update_asset_lines(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_talv_rec       IN  talv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TXL_ASSET_LINE';
  BEGIN
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TXL_ASSETS_PUB.update_txl_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => p_talv_rec,
                       x_tlpv_rec       => x_talv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_KLE_ID);
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_KLE_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_KLE_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_asset_lines;

-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Create_asset_line_details
-- Description          : Creation of asset_line_details
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE Create_asset_line_details(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_txdv_tbl       IN  txdv_tbl_type,
            x_txdv_tbl       OUT NOCOPY txdv_tbl_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXD_ASSET_DTL';
    i                        NUMBER := 0;
    l_txdv_tbl               txdv_tbl_type := p_txdv_tbl;
  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (p_txdv_tbl.COUNT > 0) THEN
      i := p_txdv_tbl.FIRST;
      LOOP
        Validate_asset_tax_book(x_return_status => x_return_status,
                                p_asset_number  => l_txdv_tbl(i).asset_number,
                                p_tax_book      => l_txdv_tbl(i).tax_book,
                                p_tal_id        => l_txdv_tbl(i).tal_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_adpv_rec       => p_txdv_tbl(i),
                           x_adpv_rec       => x_txdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_txdv_tbl.LAST);
        i := p_txdv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END Create_asset_line_details;

-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : update_asset_line_details
-- Description          : Updating of asset_line_details
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE update_asset_line_details(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_txdv_tbl       IN  txdv_tbl_type,
            x_txdv_tbl       OUT NOCOPY txdv_tbl_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TXD_ASSET_DTL';
    i                        NUMBER := 0;
    l_txdv_tbl               txdv_tbl_type := p_txdv_tbl;
  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (p_txdv_tbl.COUNT > 0) THEN
      i := p_txdv_tbl.FIRST;
      LOOP
        Validate_asset_tax_book(x_return_status => x_return_status,
                                p_asset_number  => l_txdv_tbl(i).asset_number,
                                p_tax_book      => l_txdv_tbl(i).tax_book,
                                p_tal_id        => l_txdv_tbl(i).tal_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        OKL_TXD_ASSETS_PUB.update_txd_asset_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_adpv_rec       => p_txdv_tbl(i),
                           x_adpv_rec       => x_txdv_tbl(i));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_txdv_tbl.LAST);
        i := p_txdv_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END update_asset_line_details;

-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : update_asset_line_details
-- Description          : Updating of asset_line_details
-- Business Rules       : To keep the Asset Number unique all through
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE update_asset_line_details(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_asset_number   IN  OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
            p_original_cost  IN  OKL_TXL_ASSETS_B.ORIGINAL_COST%TYPE,
            p_tal_id         IN  OKL_TXL_ASSETS_B.ID%TYPE)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_TXD_ASSET_DTL';
    i                        NUMBER := 0;
    l_txdv_tbl               txdv_tbl_type;
    lx_txdv_tbl               txdv_tbl_type;
    lv_to_update             VARCHAR2(3);
  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_txdv_tbl(p_tal_id        => p_tal_id,
                                    p_asset_number  => p_asset_number,
                                    p_original_cost => p_original_cost,
                                    x_to_update     => lv_to_update,
                                    x_txdv_tbl      => l_txdv_tbl);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF lv_to_update = 'Y' THEN
        OKL_TXD_ASSETS_PUB.update_txd_asset_def(
                           p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_adpv_tbl       => l_txdv_tbl,
                           x_adpv_tbl       => lx_txdv_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END update_asset_line_details;

  -- 5530990
  PROCEDURE Update_Asset_Cost(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cleb_fin_id    IN  NUMBER,
            p_chr_id         IN  NUMBER,
            p_oec            IN  NUMBER) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_ASSET_COST';

    CURSOR l_chk_rbk_csr(p_chr_id IN NUMBER) is
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

    CURSOR l_talv_csr(p_cleb_fin_id IN NUMBER,
                      p_chr_id      IN NUMBER) IS
    SELECT tal.id,
           tal.asset_number
    FROM okl_txl_assets_b tal,
         okc_k_lines_b cleb_fa
    WHERE cleb_fa.cle_id = p_cleb_fin_id
    AND   cleb_fa.dnz_chr_id = p_chr_id
    AND   cleb_fa.lse_id = 42
    AND   tal.kle_id = cleb_fa.id;

    l_tal_id       OKL_TXL_ASSETS_B.id%TYPE;
    l_asset_number OKL_TXL_ASSETS_B.asset_number%TYPE;

    l_talv_rec talv_rec_type;
    x_talv_rec talv_rec_type;

  BEGIN
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_rbk_khr := '?';
    OPEN l_chk_rbk_csr (p_chr_id => p_chr_id);
    FETCH l_chk_rbk_csr INTO l_rbk_khr;
    CLOSE l_chk_rbk_csr;

    IF l_rbk_khr = '!' Then

      OKL_ACTIVATE_ASSET_PVT.recalculate_asset_cost
        (p_api_version   => p_api_version,
         p_init_msg_list => p_init_msg_list,
         x_return_status => x_return_status,
         x_msg_count     => x_msg_count,
         x_msg_data      => x_msg_data,
         p_chr_id        => p_chr_id,
         p_cle_id        => p_cleb_fin_id
        );

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSE

      OPEN l_talv_csr(p_cleb_fin_id => p_cleb_fin_id,
                      p_chr_id      => p_chr_id);
      FETCH l_talv_csr INTO l_tal_id, l_asset_number;
      CLOSE l_talv_csr;

      IF l_tal_id IS NOT NULL THEN

        l_talv_rec.id := l_tal_id;
        l_talv_rec.original_cost := p_oec;
        l_talv_rec.depreciation_cost := p_oec;

        update_asset_lines(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_talv_rec       => l_talv_rec,
                           x_talv_rec       => x_talv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        update_asset_line_details(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_asset_number  => l_asset_number,
                                  p_original_cost => l_talv_rec.original_cost,
                                  p_tal_id        => l_talv_rec.id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

      END IF;

    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
END Update_Asset_Cost;
--Bug# 5530990

--------------------------------------------------------------------------------------------------------------
-- Local Procedures for creation of Txl Item Instance record
  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_trxv_rec                     OUT NOCOPY trxv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_trxv_rec               trxv_rec_type;
    l_itiv_rec               itiv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';

    --Added by dpsingh for LE uptake
    CURSOR get_chr_id_csr(p_kle_id1 NUMBER) IS
    SELECT  DNZ_CHR_ID
    FROM OKC_K_LINES_B
    WHERE  ID = p_kle_id1;

    l_chr_id NUMBER;
    l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
    l_legal_entity_id          NUMBER;

  BEGIN
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Create New Header record and new Line record
    -- Before creating Header record
    -- we should make sure atleast the required record is given
    l_trxv_rec.tas_type            := 'CFA';
    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;

    --Added by dpsingh for LE Uptake
    OPEN get_chr_id_csr(p_itiv_rec.kle_id);
    FETCH get_chr_id_csr INTO l_chr_id;
    CLOSE get_chr_id_csr;

    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id( l_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(l_chr_id);
       FETCH contract_num_csr INTO l_cntrct_number;
       CLOSE contract_num_csr;
	Okl_Api.set_message(p_app_name     => g_app_name,
                             p_msg_name     => 'OKL_LE_NOT_EXIST_CNTRCT',
			     p_token1           =>  'CONTRACT_NUMBER',
			     p_token1_value  =>  l_cntrct_number);
         RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now creating the new header record
    Create_asset_header(p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_trxv_rec       => l_trxv_rec,
                        x_trxv_rec       => x_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';
       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       l_trxv_rec                     :=  x_trxv_rec;
       l_trxv_rec.tsu_code            := 'ERROR';
       Update_asset_header(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_trxv_rec       => l_trxv_rec,
                           x_trxv_rec       => x_trxv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are creating the new line record
    l_itiv_rec                 := p_itiv_rec;
    l_itiv_rec.tas_id          := x_trxv_rec.id;
    IF (l_itiv_rec.tal_type = OKL_API.G_MISS_CHAR OR
       l_itiv_rec.tal_type IS NUll) THEN
       l_itiv_rec.tal_type       := 'CFA';
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TXL_ITM_INSTS_PUB.create_txl_itm_insts(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_iipv_rec       => l_itiv_rec,
                       x_iipv_rec       => x_itiv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_txl_itm_insts;
--------------------------------------------------------------------------------------------------------------
-- Local Procedures for update of Txl Item Instance record
  PROCEDURE update_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPD_TXL_ITM_INSTS';
  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    OKL_TXL_ITM_INSTS_PUB.update_txl_itm_insts(p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               p_iipv_rec       => p_itiv_rec,
                                               x_iipv_rec       => x_itiv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITI_ID);
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_txl_itm_insts;
---------------------------------------------------------------------------------------------
  PROCEDURE Create_financial_asset_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_FIN_AST_LINES';
    l_clev_rec               clev_rec_type;
  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_clev_rec := p_clev_rec;
-- # 4334903 use new function default_contract_line_values
/*
    IF (p_clev_rec.sts_code IS NULL OR
       p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
      x_return_status := get_sts_code(p_dnz_chr_id => p_clev_rec.dnz_chr_id,
                                      p_cle_id     => null,
                                      x_sts_code   => l_clev_rec.sts_code);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF l_clev_rec.sts_code NOT IN ('ENTERED',
                                   'SIGNED',
                                   'ACTIVE',
                                   'HOLD',
                                   'NEW',
                                   'PENDING_APPROVAL',
                                   'APPROVED',
                                   'COMPLETE',
                                   'INCOMPLETE',
                                   'PASSED') THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_STATUS,
                          p_token1       => 'STATUS',
                          p_token1_value => l_clev_rec.sts_code);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (p_clev_rec.end_date IS NULL OR
       p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
      x_return_status := get_end_date(p_dnz_chr_id => p_clev_rec.dnz_chr_id,
                                      p_cle_id     => null,
                                      x_end_date   => l_clev_rec.end_date);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF (p_clev_rec.start_date IS NULL OR
       p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
      x_return_status := get_start_date(p_dnz_chr_id => p_clev_rec.dnz_chr_id,
                                        p_cle_id     => null,
                                        x_start_date => l_clev_rec.start_date);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF (p_clev_rec.currency_code IS NULL OR
       p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
      x_return_status := get_currency_code(p_dnz_chr_id    => p_clev_rec.dnz_chr_id,
                                           p_cle_id        => null,
                                           x_currency_code => l_clev_rec.currency_code);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
*/
    IF ((p_clev_rec.sts_code IS NULL OR
         p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) OR
        (p_clev_rec.end_date IS NULL OR
         p_clev_rec.end_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.start_date IS NULL OR
         p_clev_rec.start_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.currency_code IS NULL OR
         p_clev_rec.currency_code = OKL_API.G_MISS_CHAR)
       ) THEN
       x_return_status := default_contract_line_values(p_dnz_chr_id    => p_clev_rec.dnz_chr_id,
                                                       p_cle_id        => null,
                                                       p_clev_rec => l_clev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF l_clev_rec.sts_code NOT IN ('ENTERED',
                                   'SIGNED',
                                   'ACTIVE',
                                   'HOLD',
                                   'NEW',
                                   'PENDING_APPROVAL',
                                   'APPROVED',
                                   'COMPLETE',
                                   'INCOMPLETE',
                                   'PASSED') THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_STATUS,
                          p_token1       => 'STATUS',
                          p_token1_value => l_clev_rec.sts_code);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_clev_rec      => l_clev_rec,
                                          p_klev_rec      => p_klev_rec,
                                          x_clev_rec      => x_clev_rec,
                                          x_klev_rec      => x_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATION_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CREATION_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_financial_asset_line;
---------------------------------------------------------------------------------------------
  PROCEDURE update_financial_asset_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_FIN_AST_LINES';
    l_return_status          VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status  := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calling the Process
    OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_clev_rec      => p_clev_rec,
                                          p_klev_rec      => p_klev_rec,
                                          x_clev_rec      => x_clev_rec,
                                          x_klev_rec      => x_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UPDATING_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UPDATING_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_financial_asset_line;

---------------
--Bug# 2994971
---------------
  PROCEDURE populate_insurance_category(p_api_version   IN NUMBER,
                                        p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_count     OUT NOCOPY NUMBER,
                                        x_msg_data      OUT NOCOPY VARCHAR2,
                                        p_cle_id        IN  NUMBER,
                                        p_inv_item_id   IN  NUMBER,
                                        p_inv_org_id    IN  NUMBER) IS

  l_api_name   CONSTANT VARCHAR2(30) := 'POPULATE_INS_CATEGORY';

  --cursor to get asset category
  cursor l_msi_csr(p_inv_item_id in number,
                   p_inv_org_id  in number) is
  select msi.asset_category_id
  from   mtl_system_items msi
  where  msi.organization_id   = p_inv_org_id
  and    msi.inventory_item_id = p_inv_item_id;

  l_asset_category_id mtl_system_items.asset_category_id%TYPE default NULL;
  l_clev_rec  okl_okc_migration_pvt.clev_rec_type;
  l_klev_rec  okl_contract_pub.klev_rec_type;
  lx_clev_rec  okl_okc_migration_pvt.clev_rec_type;
  lx_klev_rec  okl_contract_pub.klev_rec_type;


  BEGIN

    x_return_status          := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --fetch asset category
    l_asset_category_id := NULL;
    open l_msi_csr (p_inv_item_id => p_inv_item_id,
                    p_inv_org_id  => p_inv_org_id);
    fetch l_msi_csr into l_asset_category_id;
    if l_msi_csr%NOTFOUND then
        null;
    end if;
    close l_msi_csr;


    l_clev_rec.id := p_cle_id;
    l_klev_rec.id := p_cle_id;
    l_klev_rec.item_insurance_category := l_asset_category_id;

    okl_contract_pub.update_contract_line(
                         p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_clev_rec      => l_clev_rec,
                         p_klev_rec      => l_klev_rec,
                         x_clev_rec      => lx_clev_rec,
                         x_klev_rec      => lx_klev_rec
                         );

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    if l_msi_csr%ISOPEN then
       close l_msi_csr;
    end if;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    if l_msi_csr%ISOPEN then
       close l_msi_csr;
    end if;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    if l_msi_csr%ISOPEN then
       close l_msi_csr;
    end if;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
End POPULATE_INSURANCE_CATEGORY;
-------------------
--Bug# 2994971
------------------

---22------------------------------------------------------------------------------------------
  PROCEDURE Create_model_line_item(p_api_version    IN  NUMBER,
                                   p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
-- 4414408                                   p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                   p_clev_rec       IN  clev_rec_type,
                                   p_klev_rec       IN  klev_rec_type,
                                   p_cimv_rec       IN  cimv_rec_type,
                                   x_clev_rec       OUT NOCOPY clev_rec_type,
                                   x_klev_rec       OUT NOCOPY klev_rec_type,
                                   x_cimv_rec       OUT NOCOPY cimv_rec_type) IS
    l_clev_rec               clev_rec_type;
    r_clev_rec               clev_rec_type;
    l_talv_rec               talv_rec_type;
    l_cimv_rec               cimv_rec_type;
--    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_MODEL_ITEM';

    ------------------
    --Bug# 2994971
    -----------------
    l_inv_item_id  number;
    l_inv_org_id   number;
    l_asset_cle_id number;

  BEGIN
    x_return_status          := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 4414408 redundant validation
/*
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
-- 4414408
--  IF l_lty_code = G_FIN_LINE_LTY_CODE THEN
       r_clev_rec := p_clev_rec;

-- # 4334903 use new function default_contract_line_values
/*
       IF (p_clev_rec.sts_code IS NULL OR
          p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_sts_code(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_sts_code   => r_clev_rec.sts_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.end_date IS NULL OR
          p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_end_date(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_end_date   => r_clev_rec.end_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
     IF (p_clev_rec.start_date IS NULL OR
          p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_start_date(p_dnz_chr_id => null,
                                           p_cle_id     => p_clev_rec.cle_id,
                                           x_start_date => r_clev_rec.start_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.currency_code IS NULL OR
          p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_currency_code(p_dnz_chr_id    => null,
                                              p_cle_id        => p_clev_rec.cle_id,
                                              x_currency_code => r_clev_rec.currency_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
*/

    IF ((p_clev_rec.sts_code IS NULL OR
         p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) OR
        (p_clev_rec.end_date IS NULL OR
         p_clev_rec.end_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.start_date IS NULL OR
         p_clev_rec.start_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.currency_code IS NULL OR
         p_clev_rec.currency_code = OKL_API.G_MISS_CHAR)
       ) THEN
       x_return_status := default_contract_line_values(p_dnz_chr_id    => null,
                                                       p_cle_id        => r_clev_rec.cle_id,
                                                       p_clev_rec      => r_clev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

       -- Now the all the records are there we can create Model Line
       OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => r_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_MODEL_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_MODEL_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                   := p_cimv_rec;
       l_cimv_rec.cle_id            := x_clev_rec.id;
       l_cimv_rec.dnz_chr_id        := x_clev_rec.dnz_chr_id;
       l_cimv_rec.jtot_object1_code := 'OKX_SYSITEM';
       l_cimv_rec.exception_yn      := 'N';
       -- Creation of Item Record for the above record information
       OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cimv_rec      => l_cimv_rec,
                                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_MODEL_ITEM);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_MODEL_ITEM);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       ---------------
       --Bug# 2994971
       ---------------
       If nvl(x_cimv_rec.object1_id1,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR and
          nvl(x_cimv_rec.object1_id2,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR then

           --Bug# 3438811 :
           --l_inv_item_id  := to_char(x_cimv_rec.object1_id1);
           --l_inv_org_id   := to_char(x_cimv_rec.object1_id2);
           l_inv_item_id  := to_number(x_cimv_rec.object1_id1);
           l_inv_org_id   := to_number(x_cimv_rec.object1_id2);
           l_asset_cle_id := x_clev_rec.cle_id;

           populate_insurance_category(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_cle_id        => l_asset_cle_id,
                                       p_inv_item_id   => l_inv_item_id,
                                       p_inv_org_id    => l_inv_org_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        End If;
       ---------------
       --Bug# 2994971
       ---------------

--   #4414408
--  ELSE
--     OKL_API.set_message(p_app_name     => G_APP_NAME,
--                         p_msg_name     => G_LINE_STYLE);
--     RAISE OKL_API.G_EXCEPTION_ERROR;
--  END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_model_line_item;
---------------------------------------------------------------------------------------------
  PROCEDURE update_model_line_item(p_api_version    IN  NUMBER,
                                   p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                   x_return_status  OUT NOCOPY VARCHAR2,
                                   x_msg_count      OUT NOCOPY NUMBER,
                                   x_msg_data       OUT NOCOPY VARCHAR2,
                                   p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                   p_clev_rec       IN  clev_rec_type,
                                   p_klev_rec       IN  klev_rec_type,
                                   p_cimv_rec       IN  cimv_rec_type,
                                   x_clev_rec       OUT NOCOPY clev_rec_type,
                                   x_klev_rec       OUT NOCOPY klev_rec_type,
                                   x_cimv_rec       OUT NOCOPY cimv_rec_type) IS

    l_clev_rec               clev_rec_type;
    l_talv_rec               talv_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_MODEL_ITEM';

    ------------------
    --Bug# 2994971
    -----------------
    l_inv_item_id  number;
    l_inv_org_id   number;
    l_asset_cle_id number;

  BEGIN
    x_return_status          := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_lty_code = G_FIN_LINE_LTY_CODE THEN
       -- Now the all the records are there we can create Model Line
       OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => p_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_MODEL_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_MODEL_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                      := p_cimv_rec;
       IF l_cimv_rec.cle_id <> x_clev_rec.id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF l_cimv_rec.dnz_chr_id <> x_clev_rec.dnz_chr_id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Creation of Item Record for the above record information
       OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cimv_rec      => l_cimv_rec,
                                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_MODEL_ITEM);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_MODEL_ITEM);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       ---------------
       --Bug# 2994971
       ---------------
       If nvl(x_cimv_rec.object1_id1,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR and
          nvl(x_cimv_rec.object1_id2,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR then

           --Bug# 3438811 :
           --l_inv_item_id  := to_char(x_cimv_rec.object1_id1);
           --l_inv_org_id   := to_char(x_cimv_rec.object1_id2);
           l_inv_item_id  := to_number(x_cimv_rec.object1_id1);
           l_inv_org_id   := to_number(x_cimv_rec.object1_id2);
           l_asset_cle_id := x_clev_rec.cle_id;

           populate_insurance_category(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_cle_id        => l_asset_cle_id,
                                       p_inv_item_id   => l_inv_item_id,
                                       p_inv_org_id    => l_inv_org_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
        End If;
       ---------------
       --Bug# 2994971
       ---------------


    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_UNEXP_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_model_line_item;
--------------------------------------------------------------------------------------------------
  PROCEDURE create_fa_line_item(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
--                              p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
-- 4414408
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_talv_rec       IN  talv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_trxv_rec       OUT NOCOPY trxv_rec_type,
                                x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_clev_rec               clev_rec_type;
    r_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_talv_rec               talv_rec_type;
    l_trxv_rec               trxv_rec_type;
    i                        NUMBER := 0;

--  l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    lv_id1                   OKC_K_ITEMS_V.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR;
    lv_id2                   OKC_K_ITEMS_V.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR;
    ln_dummy                 NUMBER := 0;
    lv_dummy                 VARCHAR2(3);
    ln_tas_id                OKL_TRX_ASSETS.ID%TYPE;
    ln_line_number           OKL_TXL_ASSETS_V.LINE_NUMBER%TYPE;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_FA_LINE_ITEM';
    CURSOR c_asset_exist_chr(p_id1   OKX_ASSETS_V.ID1%TYPE,
                             p_id2   OKX_ASSETS_V.ID2%TYPE,
                             p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
    IS
    SELECT 1
    --FROM DUAL
    --WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSET_LINES_V
                  WHERE id1 = p_id1
                  AND id2 = p_id2
                  AND dnz_chr_id <> p_dnz_chr_id
                  AND line_status NOT IN ('EXPRIED','TERMINATED','ABANDONED'); --);
  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name,
                                               p_init_msg_list,
                                               '_PVT',
                                               x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
-- #4414408
/*
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- since Fixed Assets Line  is a sub line of Fin Asset line we have to check weather
    -- which line are creating under which line
--  IF l_lty_code = G_FIN_LINE_LTY_CODE THEN

       r_clev_rec := p_clev_rec;

-- # 4414408 New function default_contract_line_values
/*
       IF (p_clev_rec.sts_code IS NULL OR
          p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_sts_code(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_sts_code   => r_clev_rec.sts_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.end_date IS NULL OR
          p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_end_date(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_end_date   => r_clev_rec.end_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.start_date IS NULL OR
          p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_start_date(p_dnz_chr_id => null,
                                           p_cle_id     => p_clev_rec.cle_id,
                                           x_start_date => r_clev_rec.start_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.currency_code IS NULL OR
          p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_currency_code(p_dnz_chr_id    => null,
                                              p_cle_id        => p_clev_rec.cle_id,
                                              x_currency_code => r_clev_rec.currency_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
*/
    IF ((p_clev_rec.sts_code IS NULL OR
         p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) OR
        (p_clev_rec.end_date IS NULL OR
         p_clev_rec.end_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.start_date IS NULL OR
         p_clev_rec.start_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.currency_code IS NULL OR
         p_clev_rec.currency_code = OKL_API.G_MISS_CHAR)
       ) THEN
       x_return_status := default_contract_line_values(p_dnz_chr_id    => null,
                                                       p_cle_id        => r_clev_rec.cle_id,
                                                       p_clev_rec      => r_clev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
       -- Now the all the records are there we can create Fixed Asset Line
       OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => r_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_FA_LINE);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_FA_LINE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                   := p_cimv_rec;
       l_cimv_rec.cle_id            := x_clev_rec.id;
       l_cimv_rec.dnz_chr_id        := x_clev_rec.dnz_chr_id;
       lv_id1                       := l_cimv_rec.object1_id1;
       lv_id2                       := l_cimv_rec.object1_id2;
       l_cimv_rec.jtot_object1_code := 'OKX_ASSET';
       -- Now we should check weather the associated id1,id2 for a given asset number is null or not
       IF (lv_id1 IS NOT NULL OR
          lv_id1 <> OKL_API.G_MISS_CHAR) AND
          (lv_id2 IS NOT NULL OR
          lv_id2 <> OKL_API.G_MISS_CHAR) THEN
          -- Check to See the Fixed asset is not already in another contract
          OPEN  c_asset_exist_chr(lv_id1,lv_id2,l_cimv_rec.dnz_chr_id);
          FETCH c_asset_exist_chr into ln_dummy;
          CLOSE c_asset_exist_chr;
          IF ln_dummy <> 1 THEN
             -- Creation of Item Record for the above record information
             OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                        p_init_msg_list => p_init_msg_list,
                                                        x_return_status => x_return_status,
                                                        x_msg_count     => x_msg_count,
                                                        x_msg_data      => x_msg_data,
                                                        p_cimv_rec      => l_cimv_rec,
                                                        x_cimv_rec      => x_cimv_rec);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_CREATION_FA_ITEM);
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_CREATION_FA_ITEM);
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             -- We need to do this as part of Asset Release since the p_new_yn flag is N
             -- So that the adjustment will be done while activation of the re-lease asseted contract.
             -- We need to know if the kle_id is already there or not
             -- ideally it should be null since it is a new record
             validate_kle_id(p_klev_rec      => x_klev_rec,
                             x_record_exists => lv_dummy,
                             x_return_status => x_return_status);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             IF (lv_dummy = OKL_API.G_MISS_CHAR OR
                lv_dummy IS NUll) THEN
               l_talv_rec                 := p_talv_rec;
               l_talv_rec.kle_id          := x_clev_rec.id;
               l_talv_rec.dnz_khr_id      := x_clev_rec.dnz_chr_id;
               l_talv_rec.line_number     := 1 ;
               -- Create another kle_id record for the same header
               Create_asset_lines(p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_talv_rec       => l_talv_rec,
                                  x_trxv_rec       => x_trxv_rec,
                                  x_talv_rec       => x_talv_rec);
               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
             ELSE
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_KLE_ID);
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          ELSE
            OKL_API.set_message(p_app_name    => G_APP_NAME,
                               p_msg_name     => G_CREATION_FA_ITEM);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSE
         -- Since id1,id12 are null , hence NO Asset Number we are creating a new asset Number
          -- Creation of Item Record for the above record information
          OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_cimv_rec      => l_cimv_rec,
                                                     x_cimv_rec      => x_cimv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_CREATION_FA_ITEM);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_CREATION_FA_ITEM);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- We need to know if the kle_id is already there or not
          -- ideally it should be null since it is a new record
          validate_kle_id(p_klev_rec      => x_klev_rec,
                          x_record_exists => lv_dummy,
                          x_return_status => x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          IF (lv_dummy = OKL_API.G_MISS_CHAR OR
             lv_dummy IS NUll) THEN
             l_talv_rec                 := p_talv_rec;
             l_talv_rec.kle_id          := x_clev_rec.id;
             l_talv_rec.dnz_khr_id      := x_clev_rec.dnz_chr_id;
             l_talv_rec.line_number     := 1 ;
             -- Create another kle_id record for the same header
             Create_asset_lines(p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_talv_rec       => l_talv_rec,
                                x_trxv_rec       => x_trxv_rec,
                                x_talv_rec       => x_talv_rec);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          ELSE
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_KLE_ID);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
-- #4414408
--    ELSE
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => G_LINE_STYLE);
--        RAISE OKL_API.G_EXCEPTION_ERROR;
--    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_asset_exist_chr%ISOPEN THEN
       CLOSE c_asset_exist_chr;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_asset_exist_chr%ISOPEN THEN
       CLOSE c_asset_exist_chr;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_fa_line_item;
-------------------------------------------------------------------------------------------------
  PROCEDURE update_fa_line_item(p_api_version    IN  NUMBER,
                                p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                x_return_status  OUT NOCOPY VARCHAR2,
                                x_msg_count      OUT NOCOPY NUMBER,
                                x_msg_data       OUT NOCOPY VARCHAR2,
                                p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
                                p_clev_rec       IN  clev_rec_type,
                                p_klev_rec       IN  klev_rec_type,
                                p_cimv_rec       IN  cimv_rec_type,
                                p_talv_rec       IN  talv_rec_type,
                                x_clev_rec       OUT NOCOPY clev_rec_type,
                                x_klev_rec       OUT NOCOPY klev_rec_type,
                                x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_talv_rec               talv_rec_type;
    l_trxv_rec               trxv_rec_type;
    i                        NUMBER := 0;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    ln_dummy                 NUMBER := 0;
    lv_dummy                 VARCHAR2(3);
    ln_tas_id                OKL_TRX_ASSETS.ID%TYPE;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_FA_LINE_ITEM';
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- since Fixed Assets Line  is a sub line of Fin Asset line we have to check weather
    -- which line are creating under which line
    IF l_lty_code = G_FIN_LINE_LTY_CODE THEN
       OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => p_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_FA_LINE);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_FA_LINE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                      := p_cimv_rec;
       IF l_cimv_rec.cle_id <> x_clev_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF l_cimv_rec.dnz_chr_id <> x_clev_rec.dnz_chr_id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Creation of Item Record for the above record information
       OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cimv_rec      => l_cimv_rec,
                                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_FA_ITEM);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_FA_ITEM);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
--       x_clev_rec := l_clev_rec;
-- We commented the same out because does not make sense
-- because we are now populating the txl assets in both the cases
-- i.e., when the OKC_K_ITEMS.OBJECT1_ID1 and OBJECT1_ID2 is null or not null
--       IF (x_cimv_rec.object1_id1 IS NULL OR
--           x_cimv_rec.object1_id1 = OKL_API.G_MISS_CHAR) AND
--          (x_cimv_rec.object1_id2 IS NULL OR
--           x_cimv_rec.object1_id2 = OKL_API.G_MISS_CHAR) THEN
         validate_kle_id(p_klev_rec      => x_klev_rec,
                        x_record_exists => lv_dummy,
                        x_return_status => x_return_status);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         IF (lv_dummy IS NOT NUll OR
             lv_dummy <> OKL_API.G_MISS_CHAR) THEN
            IF p_talv_rec.kle_id <> x_klev_rec.id THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_KLE_ID);
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            update_asset_lines(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_talv_rec       => p_talv_rec,
                               x_talv_rec       => x_talv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         ELSE
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_KLE_ID);
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
--       END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  --  x_clev_rec := l_clev_rec;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_fa_line_item;
-------------------------------------------------------------------------------------------------
  PROCEDURE create_addon_line_item_rec(p_api_version    IN  NUMBER,
                                       p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_msg_count      OUT NOCOPY NUMBER,
                                       x_msg_data       OUT NOCOPY VARCHAR2,
                                       p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                       p_clev_rec       IN  clev_rec_type,
                                       p_klev_rec       IN  klev_rec_type,
                                       p_cimv_rec       IN  cimv_rec_type,
                                       x_clev_rec       OUT NOCOPY clev_rec_type,
                                       x_klev_rec       OUT NOCOPY klev_rec_type,
                                       x_cimv_rec       OUT NOCOPY cimv_rec_type) IS
    l_clev_rec               clev_rec_type;
    r_clev_rec               clev_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    i                        NUMBER := 0;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_AO_LNE_ITEM';
    ln_display_sequence      OKC_K_LINES_V.DISPLAY_SEQUENCE%TYPE := 0;
    ln_num_of_items          OKC_K_ITEMS.NUMBER_OF_ITEMS%TYPE := 0;

    CURSOR get_dis_seq_qty(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           P_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.display_sequence,
           cim.number_of_items
    FROM okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items cim,
         okc_k_lines_b cle
    WHERE cle.id = p_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND lse1.id = cle.lse_id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE;
  BEGIN
    x_return_status   := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check the cle_id that is of the top Model line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- since Add on is a sub line of Model line we have to check weather
    -- which line are creating under which line
    IF l_lty_code = G_MODEL_LINE_LTY_CODE THEN
       r_clev_rec := p_clev_rec;
       IF (p_clev_rec.sts_code IS NULL OR
           p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_sts_code(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_sts_code   => r_clev_rec.sts_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.end_date IS NULL OR
           p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_end_date(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_end_date   => r_clev_rec.end_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.start_date IS NULL OR
           p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_start_date(p_dnz_chr_id => null,
                                           p_cle_id     => p_clev_rec.cle_id,
                                           x_start_date => r_clev_rec.start_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.currency_code IS NULL OR
          p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_currency_code(p_dnz_chr_id    => null,
                                              p_cle_id        => p_clev_rec.cle_id,
                                              x_currency_code => r_clev_rec.currency_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       OPEN get_dis_seq_qty(r_clev_rec.cle_id,
                            r_clev_rec.dnz_chr_id);
       IF get_dis_seq_qty%NOTFOUND THEN
         OKL_API.set_message(p_app_name => G_APP_NAME,
                             p_msg_name => G_LINE_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       FETCH get_dis_seq_qty INTO ln_display_sequence,
                                  ln_num_of_items;
       CLOSE get_dis_seq_qty;
       IF (p_clev_rec.display_sequence IS NULL OR
           p_clev_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
         r_clev_rec.display_sequence := ln_display_sequence + 1;
       END IF;
       -- Calling the Process
       OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => r_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_ADDON_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_ADDON_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                   := p_cimv_rec;
       l_cimv_rec.cle_id            := x_clev_rec.id;
       l_cimv_rec.dnz_chr_id        := x_clev_rec.dnz_chr_id;
       l_cimv_rec.jtot_object1_code := 'OKX_SYSITEM';
       -- Check the number of items
       IF l_cimv_rec.number_of_items <> ln_num_of_items THEN
           OKL_API.set_message(p_app_name => G_APP_NAME,
                               p_msg_name => G_ITEM_RECORD);
            RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Creation of Item Record for the above record information
       OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cimv_rec      => l_cimv_rec,
                                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_ADDON_ITEM);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CREATION_ADDON_ITEM);
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    IF get_dis_seq_qty%ISOPEN THEN
       CLOSE get_dis_seq_qty;
    END IF;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    IF get_dis_seq_qty%ISOPEN THEN
       CLOSE get_dis_seq_qty;
    END IF;
  END create_addon_line_item_rec;
-----------------------------------------------------------------------------------------------------------
  PROCEDURE Update_addon_line_item_rec(p_api_version    IN  NUMBER,
                                       p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_msg_count      OUT NOCOPY NUMBER,
                                       x_msg_data       OUT NOCOPY VARCHAR2,
                                       p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                       p_clev_rec       IN  clev_rec_type,
                                       p_klev_rec       IN  klev_rec_type,
                                       p_cimv_rec       IN  cimv_rec_type,
                                       x_clev_rec       OUT NOCOPY clev_rec_type,
                                       x_klev_rec       OUT NOCOPY klev_rec_type,
                                       x_cimv_rec       OUT NOCOPY cimv_rec_type) IS
    l_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    i                        NUMBER;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_AO_LNE_ITEM';
    ln_display_sequence      OKC_K_LINES_V.DISPLAY_SEQUENCE%TYPE;
    ln_num_of_items          OKC_K_ITEMS.NUMBER_OF_ITEMS%TYPE;

    CURSOR get_dis_seq_qty(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           P_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.display_sequence,
           cim.number_of_items
    FROM okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items cim,
         okc_k_lines_b cle
    WHERE cle.id = p_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND lse1.id = cle.lse_id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE;

  BEGIN
    x_return_status     := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_klev(p_clev_rec.id,
                                    l_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- since Add on is a sub line of Model line we have to check weather
    -- which line are creating under which line
    IF l_lty_code = G_MODEL_LINE_LTY_CODE THEN
      -- Now the all the records are there we can create ADD on  Line
      -- Calling the Process
       l_clev_rec    := p_clev_rec;
       OPEN get_dis_seq_qty(l_clev_rec.cle_id,
                            l_clev_rec.dnz_chr_id);
       IF get_dis_seq_qty%NOTFOUND THEN
         OKL_API.set_message(p_app_name => G_APP_NAME,
                             p_msg_name => G_LINE_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       FETCH get_dis_seq_qty INTO ln_display_sequence,
                                  ln_num_of_items;
       CLOSE get_dis_seq_qty;
       IF (p_clev_rec.display_sequence IS NULL OR
           p_clev_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
         l_clev_rec.display_sequence := ln_display_sequence + 1;
       END IF;
      OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                            p_init_msg_list => p_init_msg_list,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_clev_rec      => l_clev_rec,
                                            p_klev_rec      => l_klev_rec,
                                            x_clev_rec      => x_clev_rec,
                                            x_klev_rec      => x_klev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_ADDON_LINE);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_ADDON_LINE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_cimv_rec                      := p_cimv_rec;
      x_return_status := get_rec_cimv(x_clev_rec.id,
                                      x_clev_rec.dnz_chr_id,
                                      l_cimv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_cimv_rec.cle_id <> x_clev_rec.id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_cimv_rec.dnz_chr_id <> x_clev_rec.dnz_chr_id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- We have the below has to been given from the screen
      l_cimv_rec.object1_id1     := p_cimv_rec.object1_id1;
      l_cimv_rec.object1_id2     := p_cimv_rec.object1_id2;
      l_cimv_rec.number_of_items := p_cimv_rec.number_of_items;
      -- Check the number of items
      IF l_cimv_rec.number_of_items <> ln_num_of_items THEN
          OKL_API.set_message(p_app_name => G_APP_NAME,
                              p_msg_name => G_ITEM_RECORD);
           RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Creation of Item Record for the above record information
      OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_cimv_rec      => l_cimv_rec,
                                                 x_cimv_rec      => x_cimv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_ADDON_ITEM);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_ADDON_ITEM);
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_dis_seq_qty%ISOPEN THEN
       CLOSE get_dis_seq_qty;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_dis_seq_qty%ISOPEN THEN
       CLOSE get_dis_seq_qty;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_dis_seq_qty%ISOPEN THEN
       CLOSE get_dis_seq_qty;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_addon_line_item_rec;
-------------------------------------------------------------------------------------------------------
  Procedure create_addon_line_rec(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            P_new_yn          IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number    IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec        IN  clev_rec_type,
            p_klev_rec        IN  klev_rec_type,
            p_cimv_rec        IN  cimv_rec_type,
            x_clev_rec        OUT NOCOPY clev_rec_type,
            x_klev_rec        OUT NOCOPY klev_rec_type,
            x_cimv_rec        OUT NOCOPY cimv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_AO_LNE_REC';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    ln_fa_id                 OKC_K_LINES_V.ID%TYPE;

    CURSOR get_fa_id(p_top_line OKC_K_LINES_V.ID%TYPE,
                     p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT distinct to_char(cle.cle_id)
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.id = p_top_line
                       AND cle.dnz_chr_id = p_dnz_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    OPEN  get_fa_id(p_top_line =>   p_clev_rec.cle_id,
                    p_dnz_chr_id => p_clev_rec.dnz_chr_id);
    IF get_fa_id%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH get_fa_id INTO ln_fa_id;
    CLOSE get_fa_id;

    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => ln_fa_id,
                                   p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are creating Add on Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Add on Line
    -- Since there could be mutilple records we have to accept
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_ADDON_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       create_addon_line_item_rec(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_lty_code      => l_lty_code,
                                  p_clev_rec      => p_clev_rec,
                                  p_klev_rec      => p_klev_rec,
                                  p_cimv_rec      => p_cimv_rec,
                                  x_clev_rec      => x_clev_rec,
                                  x_klev_rec      => x_klev_rec,
                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Add on line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_addon_line_rec;
-------------------------------------------------------------------------------------------------------
  Procedure Update_addon_line_rec(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            P_new_yn          IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number    IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec        IN  clev_rec_type,
            p_klev_rec        IN  klev_rec_type,
            p_cimv_rec        IN  cimv_rec_type,
            x_clev_rec        OUT NOCOPY clev_rec_type,
            x_klev_rec        OUT NOCOPY klev_rec_type,
            x_cimv_rec        OUT NOCOPY cimv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_AO_LNE_REC';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    ln_fa_id                 OKC_K_LINES_V.ID%TYPE;

    CURSOR get_fa_id(p_top_line OKC_K_LINES_V.ID%TYPE,
                     p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT distinct to_char(cle.cle_id)
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.id = p_top_line
                       AND cle.dnz_chr_id = p_dnz_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_clev_rec := p_clev_rec;
    x_return_status := get_sts_code(p_dnz_chr_id => null,
                                    p_cle_id     => l_clev_rec.cle_id,
                                    x_sts_code   => l_clev_rec.sts_code);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_sts_code(p_clev_rec       => l_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OPEN  get_fa_id(p_top_line =>   l_clev_rec.cle_id,
                    p_dnz_chr_id => l_clev_rec.dnz_chr_id);
    IF get_fa_id%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH get_fa_id INTO ln_fa_id;
    CLOSE get_fa_id;
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => ln_fa_id,
                                   p_dnz_chr_id     => l_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    x_return_status := get_lse_id(p_lty_code => G_ADDON_LINE_LTY_CODE,
                                  x_lse_id   => l_clev_rec.lse_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => l_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => l_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are updating Add on Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Add on Line
    -- Since there could be mutilple records we have to accept
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code =  G_ADDON_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       update_addon_line_item_rec(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_lty_code      => l_lty_code,
                                  p_clev_rec      => l_clev_rec,
                                  p_klev_rec      => p_klev_rec,
                                  p_cimv_rec      => p_cimv_rec,
                                  x_clev_rec      => x_clev_rec,
                                  x_klev_rec      => x_klev_rec,
                                  x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Add on line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_addon_line_rec;
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_addon_line_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'DEL_ADDON_REC';
    l_delete_clev_rec        clev_rec_type;
    l_delete_klev_rec        klev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.init_msg_list(p_init_msg_list);
    l_delete_clev_rec := p_clev_rec;
    -- To Get the cle top Line Record
    x_return_status := get_rec_clev(p_clev_rec.id,
                                    l_delete_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(p_clev_rec.id,
                                    l_delete_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_delete_klev_rec.id <> l_delete_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    validate_sts_code(p_clev_rec       => l_delete_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => l_delete_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => l_delete_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are deleting Add on Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Add on Line
    -- Since there could be mutilple records we have to accept
    IF (l_delete_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_delete_clev_rec.chr_id IS NULL) AND
       (l_delete_clev_rec.dnz_chr_id IS NOT NULL OR
       l_delete_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_delete_clev_rec.cle_id IS NOT NULL OR
       l_delete_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_ADDON_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       OKL_CONTRACT_PUB.delete_contract_line(
                        p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
                        p_line_id       => l_delete_clev_rec.id);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DELETING_ADDON_LINE);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DELETING_ADDON_LINE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Add on line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to the below since we need to calculate the OEC again
    x_clev_rec := l_delete_clev_rec;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END delete_addon_line_rec;
-------------------------------------------------------------------------------------------------
  PROCEDURE Create_inst_line(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
-- #4414408                             p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                             p_clev_rec       IN  clev_rec_type,
                             p_klev_rec       IN  klev_rec_type,
                             x_clev_rec       OUT NOCOPY clev_rec_type,
                             x_klev_rec       OUT NOCOPY klev_rec_type) IS
    l_clev_rec               clev_rec_type;
    r_clev_rec               clev_rec_type;
--    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_INSTS_LINE';
  BEGIN

    x_return_status         := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 4414408 redundant validation
/*
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- since Fixed Assets Line  is a sub line of Fin Asset line we have to check weather
    -- which line are creating under which line
--    IF l_lty_code = G_FIN_LINE_LTY_CODE THEN

       r_clev_rec := p_clev_rec;

-- # 4414408 use new function default_contract_line_values
/*
       IF (p_clev_rec.sts_code IS NULL OR
          p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_sts_code(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_sts_code   => r_clev_rec.sts_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.end_date IS NULL OR
          p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_end_date(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_end_date   => r_clev_rec.end_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.start_date IS NULL OR
          p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_start_date(p_dnz_chr_id => null,
                                           p_cle_id     => p_clev_rec.cle_id,
                                           x_start_date => r_clev_rec.start_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.currency_code IS NULL OR
          p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_currency_code(p_dnz_chr_id    => null,
                                              p_cle_id        => p_clev_rec.cle_id,
                                              x_currency_code => r_clev_rec.currency_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
*/
    IF ((p_clev_rec.sts_code IS NULL OR
         p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) OR
        (p_clev_rec.end_date IS NULL OR
         p_clev_rec.end_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.start_date IS NULL OR
         p_clev_rec.start_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.currency_code IS NULL OR
         p_clev_rec.currency_code = OKL_API.G_MISS_CHAR)
       ) THEN
       x_return_status := default_contract_line_values(p_dnz_chr_id    => null,
                                                       p_cle_id        => r_clev_rec.cle_id,
                                                       p_clev_rec      => r_clev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

       -- Now the all the records are there we can create Instance Line
       OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => r_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_INSTS_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_INSTS_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
--  #4414408
--    ELSE
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => G_LINE_STYLE);
--          RAISE OKL_API.G_EXCEPTION_ERROR;
--    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_inst_line;
-------------------------------------------------------------------------------------------------
  PROCEDURE update_inst_line(p_api_version    IN  NUMBER,
                             p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                             x_return_status  OUT NOCOPY VARCHAR2,
                             x_msg_count      OUT NOCOPY NUMBER,
                             x_msg_data       OUT NOCOPY VARCHAR2,
                             p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                             p_clev_rec       IN  clev_rec_type,
                             p_klev_rec       IN  klev_rec_type,
                             x_clev_rec       OUT NOCOPY clev_rec_type,
                             x_klev_rec       OUT NOCOPY klev_rec_type) IS

    l_clev_rec               clev_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_INSTS_LINE';
  BEGIN
    x_return_status         := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (l_api_name
                                               ,p_init_msg_list
                                               ,'_PVT'
                                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- since Fixed Assets Line  is a sub line of Fin Asset line we have to check weather
    -- which line are creating under which line
    IF l_lty_code = G_FIN_LINE_LTY_CODE THEN
       -- Now the all the records are there we can create Instance Line
       OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => p_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_INSTS_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_INSTS_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_inst_line;
-------------------------------------------------------------------------------------------------
  PROCEDURE Create_installed_base_line(p_api_version    IN  NUMBER,
                                       p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_msg_count      OUT NOCOPY NUMBER,
                                       x_msg_data       OUT NOCOPY VARCHAR2,
-- 4414408                                       p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                       p_clev_rec       IN  clev_rec_type,
                                       p_klev_rec       IN  klev_rec_type,
                                       p_cimv_rec       IN  cimv_rec_type,
                                       p_itiv_rec       IN  itiv_rec_type,
                                       x_clev_rec       OUT NOCOPY clev_rec_type,
                                       x_klev_rec       OUT NOCOPY klev_rec_type,
                                       x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                       x_trxv_rec       OUT NOCOPY trxv_rec_type,
                                       x_itiv_rec       OUT NOCOPY itiv_rec_type) IS
    l_clev_rec               clev_rec_type;
    r_clev_rec               clev_rec_type;
    l_cimv_rec               cimv_rec_type;
    r_cimv_rec               cimv_rec_type;
    lv_dummy                 VARCHAR2(3) := OKL_API.G_MISS_CHAR ;
--    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_itiv_rec               itiv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_IB_LINE';
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 4414408 redundant validation
/*
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- since IB Line  is a sub line of instance line we have to check weather
    -- which line are creating under which line
--    IF l_lty_code = G_INST_LINE_LTY_CODE THEN

       r_clev_rec := p_clev_rec;

-- # 4414408 use new function default_contract_line_values
/*
       IF (p_clev_rec.sts_code IS NULL OR
          p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_sts_code(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_sts_code   => r_clev_rec.sts_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.end_date IS NULL OR
          p_clev_rec.end_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_end_date(p_dnz_chr_id => null,
                                         p_cle_id     => p_clev_rec.cle_id,
                                         x_end_date   => r_clev_rec.end_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.start_date IS NULL OR
          p_clev_rec.start_date = OKL_API.G_MISS_DATE) THEN
         x_return_status := get_start_date(p_dnz_chr_id => null,
                                           p_cle_id     => p_clev_rec.cle_id,
                                           x_start_date => r_clev_rec.start_date);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
       IF (p_clev_rec.currency_code IS NULL OR
          p_clev_rec.currency_code = OKL_API.G_MISS_CHAR) THEN
         x_return_status := get_currency_code(p_dnz_chr_id    => null,
                                              p_cle_id        => p_clev_rec.cle_id,
                                              x_currency_code => r_clev_rec.currency_code);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       END IF;
*/

    IF ((p_clev_rec.sts_code IS NULL OR
         p_clev_rec.sts_code = OKL_API.G_MISS_CHAR) OR
        (p_clev_rec.end_date IS NULL OR
         p_clev_rec.end_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.start_date IS NULL OR
         p_clev_rec.start_date = OKL_API.G_MISS_DATE) OR
        (p_clev_rec.currency_code IS NULL OR
         p_clev_rec.currency_code = OKL_API.G_MISS_CHAR)
       ) THEN
       x_return_status := default_contract_line_values(p_dnz_chr_id    => null,
                                                       p_cle_id        => r_clev_rec.cle_id,
                                                       p_clev_rec      => r_clev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
       -- Now the all the records are there we can create Instance Line
       OKL_CONTRACT_PUB.create_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => r_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_IB_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_IB_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                   := p_cimv_rec;
       l_cimv_rec.cle_id            := x_clev_rec.id;
       l_cimv_rec.dnz_chr_id        := x_clev_rec.dnz_chr_id;
       l_cimv_rec.JTOT_OBJECT1_CODE := 'OKX_IB_ITEM';
       l_cimv_rec.exception_yn      := 'N';
       IF (l_cimv_rec.object1_id1 IS NULL OR
           l_cimv_rec.object1_id1 = OKL_API.G_MISS_CHAR) AND
          (l_cimv_rec.object1_id2 IS NULL OR
           l_cimv_rec.object1_id2 = OKL_API.G_MISS_CHAR) THEN
          -- We have create the item rec,tal rec,trx rec and also create the iti rec
          -- Creation of Item Record for the above record information
          OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_cimv_rec      => l_cimv_rec,
                                                     x_cimv_rec      => x_cimv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_IB_ITEM);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_IB_ITEM);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          -- Rest of the record Creation will Follow
          -- We need to know if the kle_id is already there or not
          -- ideally it should be null since it is a new record
          IF (x_klev_rec.id IS NOT NULL OR
             x_klev_rec.id <> OKL_API.G_MISS_NUM) THEN
             lv_dummy := null;
          END IF;
          IF (lv_dummy = OKL_API.G_MISS_CHAR OR
              lv_dummy IS NUll) THEN
              l_itiv_rec                   := p_itiv_rec;
             -- To the Item Info from model Line
             x_return_status := get_rec_ib_cimv(p_cle_id     => x_clev_rec.cle_id,
                                                p_dnz_chr_id => x_cimv_rec.dnz_chr_id,
                                                x_cimv_rec   => r_cimv_rec);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_FETCHING_INFO,
                                   p_token1       => G_REC_NAME_TOKEN,
                                   p_token1_value => 'OKC_K_ITEMS_V Record');
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_FETCHING_INFO,
                                   p_token1       => G_REC_NAME_TOKEN,
                                   p_token1_value => 'OKC_K_ITEMS_V Record');
                RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
              -- Creating iti record
              l_itiv_rec.inventory_item_id    := to_number(r_cimv_rec.object1_id1);
              l_itiv_rec.inventory_org_id     := to_number(r_cimv_rec.object1_id2);
              IF (l_itiv_rec.line_number IS NULL OR
                 l_itiv_rec.line_number = OKL_API.G_MISS_NUM) THEN
                 l_itiv_rec.line_number       := 1;
              END IF;
              l_itiv_rec.kle_id               := x_klev_rec.id;
              l_itiv_rec.jtot_object_code_new := 'OKX_PARTSITE';
              -- Create another iti_id record for the tas_id of the header
              create_txl_itm_insts(p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_itiv_rec       => l_itiv_rec,
                                   x_trxv_rec       => x_trxv_rec,
                                   x_itiv_rec       => x_itiv_rec);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_ITI_ID);
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_ITI_ID);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          ELSE
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_ITI_ID);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSIF (l_cimv_rec.object1_id1 IS NOT NULL OR
             l_cimv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) AND
             (l_cimv_rec.object1_id2 IS NOT NULL OR
             l_cimv_rec.object1_id2 <> OKL_API.G_MISS_CHAR)THEN
           -- Creation of Item Record for the above record information
           OKL_OKC_MIGRATION_PVT.create_contract_item(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => x_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_cimv_rec      => l_cimv_rec,
                                                      x_cimv_rec      => x_cimv_rec);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CREATION_IB_ITEM);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_CREATION_IB_ITEM);
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           -- Rest of the record Creation will Follow
           -- We need to know if the kle_id is already there or not
           -- ideally it should be null since it is a new record
           IF (x_klev_rec.id IS NOT NULL OR
              x_klev_rec.id <> OKL_API.G_MISS_NUM) THEN
              lv_dummy := null;
           END IF;
           IF (lv_dummy = OKL_API.G_MISS_CHAR OR
               lv_dummy IS NUll) THEN
               l_itiv_rec                   := p_itiv_rec;
              -- To the Item Info from model Line
              x_return_status := get_rec_ib_cimv(p_cle_id     => x_clev_rec.cle_id,
                                                 p_dnz_chr_id => x_cimv_rec.dnz_chr_id,
                                                 x_cimv_rec   => r_cimv_rec);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_FETCHING_INFO,
                                    p_token1       => G_REC_NAME_TOKEN,
                                    p_token1_value => 'OKC_K_ITEMS_V Record');
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_FETCHING_INFO,
                                    p_token1       => G_REC_NAME_TOKEN,
                                    p_token1_value => 'OKC_K_ITEMS_V Record');
                 RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              -- Creating iti record
              l_itiv_rec.inventory_item_id    := to_number(r_cimv_rec.object1_id1);
              l_itiv_rec.inventory_org_id     := to_number(r_cimv_rec.object1_id2);
              IF (l_itiv_rec.line_number IS NULL OR
                 l_itiv_rec.line_number = OKL_API.G_MISS_NUM) THEN
                 l_itiv_rec.line_number       := 1;
              END IF;
              l_itiv_rec.kle_id               := x_klev_rec.id;
              l_itiv_rec.jtot_object_code_new := 'OKX_PARTSITE';
              -- Create another iti_id record for the tas_id of the header
              create_txl_itm_insts(p_api_version    => p_api_version,
                                   p_init_msg_list  => p_init_msg_list,
                                   x_return_status  => x_return_status,
                                   x_msg_count      => x_msg_count,
                                   x_msg_data       => x_msg_data,
                                   p_itiv_rec       => l_itiv_rec,
                                   x_trxv_rec       => x_trxv_rec,
                                   x_itiv_rec       => x_itiv_rec);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_ITI_ID);
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_ITI_ID);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
          ELSE
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_ITI_ID);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSE
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
--    #4414408
--    ELSE
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => G_LINE_STYLE);
--       x_return_status := OKL_API.G_RET_STS_ERROR;
--       RAISE OKL_API.G_EXCEPTION_ERROR;
--    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_installed_base_line;
---34----------------------------------------------------------------------------------------------
  PROCEDURE update_installed_base_line(p_api_version    IN  NUMBER,
                                       p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                       x_return_status  OUT NOCOPY VARCHAR2,
                                       x_msg_count      OUT NOCOPY NUMBER,
                                       x_msg_data       OUT NOCOPY VARCHAR2,
                                       p_lty_code       IN  OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                                       p_clev_rec       IN  clev_rec_type,
                                       p_klev_rec       IN  klev_rec_type,
                                       p_cimv_rec       IN  cimv_rec_type,
                                       p_itiv_rec       IN  itiv_rec_type,
                                       x_clev_rec       OUT NOCOPY clev_rec_type,
                                       x_klev_rec       OUT NOCOPY klev_rec_type,
                                       x_cimv_rec       OUT NOCOPY cimv_rec_type,
                                       x_itiv_rec       OUT NOCOPY itiv_rec_type) IS

    l_clev_rec               clev_rec_type;
    l_cimv_rec               cimv_rec_type;
    l_itiv_rec               itiv_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    ln_tas_id                OKL_TRX_ASSETS.ID%TYPE;
    lv_dummy                 VARCHAR2(3) := OKL_API.G_MISS_CHAR ;
    i                        NUMBER := 0;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_IB_LINE';
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check the cle_id that is of the top Fin Asset line
    validate_cle_lse_id(p_clev_rec      => p_clev_rec,
                        p_lty_code      => p_lty_code,
                        x_lty_code      => l_lty_code,
                        x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- since IB Line  is a sub line of instance line we have to check weather
    -- which line are creating under which line
    IF l_lty_code = G_INST_LINE_LTY_CODE THEN
       -- Now the all the records are there we can create Instance Line
       OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                             p_init_msg_list => p_init_msg_list,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_clev_rec      => p_clev_rec,
                                             p_klev_rec      => p_klev_rec,
                                             x_clev_rec      => x_clev_rec,
                                             x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_IB_LINE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_IB_LINE);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cimv_rec                   := p_cimv_rec;
       IF l_cimv_rec.cle_id <> x_clev_rec.id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF l_cimv_rec.dnz_chr_id <> x_clev_rec.dnz_chr_id THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITEM_RECORD);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF (l_cimv_rec.object1_id1 IS NULL OR
           l_cimv_rec.object1_id1 = OKL_API.G_MISS_CHAR) AND
          (l_cimv_rec.object1_id2 IS NULL OR
           l_cimv_rec.object1_id2 = OKL_API.G_MISS_CHAR) THEN
          -- We have create the item rec,tal rec,trx rec and also create the iti rec
          -- Creation of Item Record for the above record information
          OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_cimv_rec      => l_cimv_rec,
                                                     x_cimv_rec      => x_cimv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UPDATING_IB_ITEM);
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_UPDATING_IB_ITEM);
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          validate_iti_kle_id(p_klev_rec      => x_klev_rec,
                              x_record_exists => lv_dummy,
                              x_return_status => x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_ITI_ID);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_ITI_ID);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          IF (lv_dummy IS NOT NUll OR
             lv_dummy <> OKL_API.G_MISS_CHAR) THEN
             IF p_itiv_rec.kle_id <> x_klev_rec.id THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_ITI_ID);
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             update_txl_itm_insts(p_api_version    => p_api_version,
                                  p_init_msg_list  => p_init_msg_list,
                                  x_return_status  => x_return_status,
                                  x_msg_count      => x_msg_count,
                                  x_msg_data       => x_msg_data,
                                  p_itiv_rec       => p_itiv_rec,
                                  x_itiv_rec       => x_itiv_rec);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_ITI_ID);
               RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_ITI_ID);
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
          ELSE
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_ITI_ID);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSIF (l_cimv_rec.object1_id1 IS NOT NULL OR
              l_cimv_rec.object1_id1 <> OKL_API.G_MISS_CHAR) AND
             (l_cimv_rec.object1_id2 IS NOT NULL OR
             l_cimv_rec.object1_id2 <> OKL_API.G_MISS_CHAR) THEN
           -- Creation of Item Record for the above record information
           OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                      p_init_msg_list => p_init_msg_list,
                                                      x_return_status => x_return_status,
                                                      x_msg_count     => x_msg_count,
                                                      x_msg_data      => x_msg_data,
                                                      p_cimv_rec      => l_cimv_rec,
                                                      x_cimv_rec      => x_cimv_rec);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UPDATING_IB_ITEM);
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_UPDATING_IB_ITEM);
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
       ELSE
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_UPDATING_IB_ITEM);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_STYLE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_installed_base_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Creation of Financial Asset -------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE create_fin_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_FIN_AST_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

--  4414408 The validation is now performed in create_all_line procedure
/*
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity ended successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
*/
--  4414408 The validations in Validate_lse_id and Validate_dnz_chr_id are redundant
/*
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- creating of finanical Asset Lines which is the top Line
    -- While createing the cle_id will be null, chr_id will be not null
    -- and also the dnz_chr_id will be not null.Lse_id given will also helps
    -- to decide that this line is finanical Asset Line
    l_clev_rec          := p_clev_rec;
    IF (l_clev_rec.cle_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.cle_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.chr_id IS NOT NULL OR
       l_clev_rec.chr_id <> OKL_API.G_MISS_NUM) AND
--     #4414408
--       l_lty_code = G_FIN_LINE_LTY_CODE AND
--       l_lse_type = G_TLS_TYPE THEN
         l_clev_rec.lse_id = G_FIN_LINE_LTY_ID THEN
       -- We need to do this because we wanted the asset number be unique
       -- both in the transaction level and the line levels
       l_clev_rec.name             := p_asset_number;
       -- Entering the Asset Description
       create_financial_asset_line(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_clev_rec      => l_clev_rec,
                                   p_klev_rec      => p_klev_rec,
                                   x_clev_rec      => x_clev_rec,
                                   x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Financial Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_fin_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for update of Financial Asset -------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE Update_fin_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            p_validate_fin_line  IN  VARCHAR2 DEFAULT OKL_API.G_TRUE) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_FIN_AST_LINES';
    l_clev_rec               clev_rec_type := p_clev_rec;
    l_klev_rec               klev_rec_type := p_klev_rec;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    ln_fa_id                 OKC_K_LINES_V.ID%TYPE;

    -- Temp variables for capital reduction and tradein amount
    tradein_amount           OKL_K_LINES.TRADEIN_AMOUNT%TYPE;
    capital_reduction        OKL_K_LINES.CAPITAL_REDUCTION%TYPE;

    CURSOR get_fa_id(p_top_line OKC_K_LINES_V.ID%TYPE,
                     p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    -- #4414408
    SELECT cle.id
--    FROM okc_subclass_top_line stl,
--         okc_line_styles_b lse2,
--         okc_line_styles_b lse1,
      FROM okc_k_lines_b cle
    WHERE cle.cle_id = p_top_line
    AND cle.dnz_chr_id = p_dnz_chr_id
--    AND lse1.id = cle.lse_id
--    AND lse1.lty_code = G_FA_LINE_LTY_CODE
--    AND lse1.lse_parent_id = lse2.id
--    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
--    AND lse2.id = stl.lse_id
--    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);
    AND cle.lse_id = G_FA_LINE_LTY_ID;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (p_validate_fin_line = OKL_API.G_TRUE) THEN
       validate_sts_code(p_clev_rec      => l_clev_rec,
                         x_return_status => x_return_status);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       OPEN  get_fa_id(p_top_line   => l_clev_rec.id,
                       p_dnz_chr_id => l_clev_rec.dnz_chr_id);
       FETCH get_fa_id INTO ln_fa_id;
       -- 4414408
       IF get_fa_id%NOTFOUND THEN
         OKL_API.set_message(p_app_name => G_APP_NAME,
                             p_msg_name => G_LINE_RECORD);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       CLOSE get_fa_id;
       -- To Check We Got the Valid info
       IF UPPER(p_new_yn) NOT IN ('Y','N') OR
          (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
          UPPER(p_new_yn) IS NULL) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_YN,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'p_new_yn');
          -- Halt Validation
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Validate to see if the asset_number given is not null
       -- and also Validate asset_number does not exists
       -- in OKL_TXL_ASSETS_V
       IF UPPER(p_new_yn) = 'Y' THEN
          validate_new_ast_num_update(x_return_status  => x_return_status,
                                      p_asset_number   => p_asset_number,
                                      p_kle_id         => ln_fa_id,
                                      p_dnz_chr_id     => l_clev_rec.dnz_chr_id);
          -- Check if activity started successfully
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSIF UPPER(p_new_yn) = 'N' THEN
          validate_new_ast_num_update(x_return_status  => x_return_status,
                                      p_asset_number   => p_asset_number,
                                      p_kle_id         => ln_fa_id,
                                      p_dnz_chr_id     => l_clev_rec.dnz_chr_id);
          -- Check if activity started successfully
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       END IF;
       -- Validate Line Style id and get the line type code
       -- and line style type for further processing
       validate_lse_id(p_clev_rec      => l_clev_rec,
                       x_return_status => x_return_status,
                       x_lty_code      => l_lty_code,
                       x_lse_type      => l_lse_type);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Validate the Dnz_Chr_id
       validate_dnz_chr_id(p_clev_rec      => l_clev_rec,
                           x_return_status => x_return_status);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
/*
    -- nnirnaka 12/24/02 commented this out as this already happens in
    -- contract line update

    IF (l_klev_rec.capital_reduction <> OKL_API.G_MISS_NUM AND
        l_klev_rec.capital_reduction IS NOT NULL) THEN
      capital_reduction := l_klev_rec.capital_reduction;
      l_klev_rec.capital_reduction :=
         OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_klev_rec.capital_reduction,
                                                       l_clev_rec.currency_code);

      IF (capital_reduction <> 0 AND l_klev_rec.capital_reduction = 0) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_AMOUNT_ROUNDING,
                             p_token1       => 'AMT',
                             p_token1_value => to_char(capital_reduction));
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    IF (l_klev_rec.tradein_amount <> OKL_API.G_MISS_NUM AND
        l_klev_rec.tradein_amount IS NOT NULL) THEN
      tradein_amount := l_klev_rec.tradein_amount;
      l_klev_rec.tradein_amount :=
         OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_klev_rec.tradein_amount,
                                                       l_clev_rec.currency_code);

      IF (tradein_amount <> 0 AND l_klev_rec.tradein_amount = 0) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_AMOUNT_ROUNDING,
                             p_token1       => 'AMT',
                             p_token1_value => to_char(tradein_amount));
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    END IF;

    -- End Modification for Multi Currency
*/

    -- Updating of finanical Asset Lines which is the top Line
    -- While Updating the cle_id will be null, chr_id will be not null
    -- and also the dnz_chr_id will be not null.Lse_id given will also helps
    -- to decide that this line is finanical Asset Line
    IF (l_clev_rec.cle_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.cle_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.chr_id IS NOT NULL OR
       l_clev_rec.chr_id <> OKL_API.G_MISS_NUM) AND
--       l_lty_code = G_FIN_LINE_LTY_CODE AND
--       l_lse_type = G_TLS_TYPE THEN
          l_clev_rec.lse_id = G_FIN_LINE_LTY_ID THEN

       -- Calling the Process
       update_financial_asset_line(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_clev_rec      => l_clev_rec,
                                   p_klev_rec      => l_klev_rec,
                                   x_clev_rec      => x_clev_rec,
                                   x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => 'LINE_STYLE',
                          p_token1_value => 'Financial Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_fin_line;
-------------------------------------------------------------------------------------------------------
----------------- Main Process for update of Financial Asset for Capital Cost -------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE Update_fin_cap_cost(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_FIN_CAP_COST';
    l_clev_rec               clev_rec_type := p_clev_rec;
    l_klev_rec               klev_rec_type := p_klev_rec;
    lx_clev_rec              clev_rec_type;
    lx_klev_rec              klev_rec_type;
    CURSOR c_get_lse_id_sts(p_top_line_id OKC_K_LINES_V.ID%TYPE) IS
    SELECT lse.id,
           cle.sts_code
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse,
         okc_k_lines_v cle
    WHERE cle.id = p_top_line_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    --Bug# 8652738
    CURSOR l_chk_rbk_csr(p_chr_id IN NUMBER) is
    SELECT '!'
    FROM   okc_k_headers_b CHR,
           okl_trx_contracts ktrx
    WHERE  ktrx.khr_id_new = chr.id
    AND    ktrx.tsu_code = 'ENTERED'
    AND    ktrx.rbr_code is NOT NULL
    AND    ktrx.tcn_type = 'TRBK'
    AND    ktrx.representation_type = 'PRIMARY'
    AND    chr.id = p_chr_id
    AND    chr.orig_system_source_code = 'OKL_REBOOK';

    l_rbk_khr      VARCHAR2(1) DEFAULT '?';

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OPEN  c_get_lse_id_sts(p_top_line_id => l_clev_rec.id);
    FETCH c_get_lse_id_sts INTO l_clev_rec.lse_id,
                                l_clev_rec.sts_code;
    -- 4414408
    IF c_get_lse_id_sts%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    CLOSE c_get_lse_id_sts;
    -- Here we update the capital Amount for the Top line of klev_rec
    --Bug# 3877032 :
    --IF (l_klev_rec.capital_reduction_percent IS NULL OR
       --l_klev_rec.capital_reduction_percent = OKL_API.G_MISS_NUM ) AND
       --(l_klev_rec.capital_reduction IS NULL OR
       --l_klev_rec.capital_reduction = OKL_API.G_MISS_NUM ) AND
       --(l_klev_rec.tradein_amount IS NULL OR
       --l_klev_rec.tradein_amount = OKL_API.G_MISS_NUM ) THEN

     IF l_klev_rec.capital_reduction_percent = OKL_API.G_MISS_NUM  AND
       l_klev_rec.capital_reduction = OKL_API.G_MISS_NUM  AND
       l_klev_rec.tradein_amount = OKL_API.G_MISS_NUM  THEN
       -- Updating of finanical Asset Lines with all the values
       Update_fin_line(p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       P_new_yn             => P_new_yn,
                       p_asset_number       => p_asset_number,
                       p_clev_rec           => l_clev_rec,
                       p_klev_rec           => l_klev_rec,
                       x_clev_rec           => x_clev_rec,
                       x_klev_rec           => x_klev_rec,
                       p_validate_fin_line  => OKL_API.G_TRUE); -- 4414408
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       -- Here we update the capital Amount for the Top line of klev_rec
       -- But further we first have to update the top line with values
       -- and then call the formula enigne which will calculat the capital amount
       -- and update the top line again, we have to take this route because we
       -- will have to depend on Formula engine which in turn will calculate
       -- by querying the data.
       Update_fin_line(p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       P_new_yn             => P_new_yn,
                       p_asset_number       => p_asset_number,
                       p_clev_rec           => l_clev_rec,
                       p_klev_rec           => l_klev_rec,
                       x_clev_rec           => x_clev_rec,
                       x_klev_rec           => x_klev_rec,
                       p_validate_fin_line  => OKL_API.G_TRUE);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                       p_init_msg_list => p_init_msg_list,
                                       x_return_status => x_return_status,
                                       x_msg_count     => x_msg_count,
                                       x_msg_data      => x_msg_data,
                                       p_formula_name  => G_FORMULA_CAP,
                                       p_contract_id   => x_clev_rec.dnz_chr_id,
                                       p_line_id       => x_clev_rec.id,
                                       x_value         => x_klev_rec.capital_amount);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CALC_AMOUNT,
                             p_token1       => G_AMT_TOKEN,
                             p_token1_value => 'Capital Amount');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_CALC_AMOUNT,
                             p_token1       => G_AMT_TOKEN,
                             p_token1_value => 'Capital Amount');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Updating of finanical Asset Lines with all the values
       Update_fin_line(p_api_version        => p_api_version,
                       p_init_msg_list      => p_init_msg_list,
                       x_return_status      => x_return_status,
                       x_msg_count          => x_msg_count,
                       x_msg_data           => x_msg_data,
                       P_new_yn             => P_new_yn,
                       p_asset_number       => p_asset_number,
                       p_clev_rec           => x_clev_rec,
                       p_klev_rec           => x_klev_rec,
                       x_clev_rec           => lx_clev_rec,
                       x_klev_rec           => lx_klev_rec,
                       p_validate_fin_line  => OKL_API.G_TRUE);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --Bug# 8652738
       -- Recalculate Asset Depreciation cost when down payment is updated
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => x_clev_rec.dnz_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr;
       CLOSE l_chk_rbk_csr;

       IF l_rbk_khr = '!' Then

         OKL_ACTIVATE_ASSET_PVT.recalculate_asset_cost
         (p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_chr_id        => x_clev_rec.dnz_chr_id,
          p_cle_id        => x_clev_rec.id
          );

         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;

       END IF;
       --Bug# 8652738

       x_clev_rec    := lx_clev_rec;
       x_klev_rec    := lx_klev_rec;
    END IF;
    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (x_clev_rec.dnz_chr_id is NOT NULL) AND
       (x_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_clev_rec.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_get_lse_id_sts%ISOPEN THEN
      CLOSE c_get_lse_id_sts;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_get_lse_id_sts%ISOPEN THEN
      CLOSE c_get_lse_id_sts;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_get_lse_id_sts%ISOPEN THEN
      CLOSE c_get_lse_id_sts;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_fin_cap_cost;
-----------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : oec_calc_upd_fin_rec
-- Description          : oec_calc_upd_fin_rec
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE oec_calc_upd_fin_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type,
            x_oec            OUT NOCOPY OKL_K_LINES_V.OEC%TYPE,
            p_validate_fin_line  IN  VARCHAR2 DEFAULT OKL_API.G_TRUE) IS

    ln_oec                   OKL_K_LINES_V.OEC%TYPE := 0;
--    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    l_update_clev_rec        clev_rec_type;
    l_update_klev_rec        klev_rec_type;

-- #4414408 Top line ID is now passed to the API
/*
    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.cle_id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE,G_QUOTE_SCS_CODE);
*/
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
/*
    OPEN  c_model_top_line(p_model_line_id => p_model_line_id,
                           p_dnz_chr_id    => p_dnz_chr_id);
    FETCH c_model_top_line INTO ln_top_line_id;
-- #4414408 Moved the IF statement  below fetch statement
    IF c_model_top_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'cle_id');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--   #4414408 This condition will never be met
--    IF (c_model_top_line%ROWCOUNT > 1) THEN
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => 'More than one',
--                           p_token1       => 'Model line',
--                           p_token1_value => 'cle_id');
--       RAISE G_EXCEPTION_HALT_VALIDATION;
--    END IF;

    CLOSE c_model_top_line;
*/
    -- to get the OEC
/*
    x_oec := OKL_SEEDED_FUNCTIONS_PVT.LINE_OEC(p_dnz_chr_id => p_dnz_chr_id,
                                               p_cle_id     => ln_top_line_id);
*/
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_OEC,
                                    p_contract_id   => p_dnz_chr_id,
                                    p_line_id       => p_top_line_id,
                                    x_value         => x_oec);

   IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'OEC');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'OEC');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the cle top Line Record
    x_return_status := get_rec_clev(p_top_line_id, -- 4414408
                                    l_update_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(p_top_line_id,  -- 4414408
                                    l_update_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_update_klev_rec.id <> l_update_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_update_klev_rec.oec   := x_oec;

    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    l_update_klev_rec.oec :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_update_klev_rec.oec,
                                                        l_update_clev_rec.currency_code);

    IF (x_oec <> 0 AND l_update_klev_rec.oec = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(x_oec));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency

    Update_fin_line(p_api_version       => p_api_version,
                    p_init_msg_list     => p_init_msg_list,
                    x_return_status     => x_return_status,
                    x_msg_count         => x_msg_count,
                    x_msg_data          => x_msg_data,
                    P_new_yn            => P_new_yn,
                    p_asset_number      => p_asset_number,
                    p_clev_rec          => l_update_clev_rec,
                    p_klev_rec          => l_update_klev_rec,
                    x_clev_rec          => x_fin_clev_rec,
                    x_klev_rec          => x_fin_klev_rec,
                    p_validate_fin_line => p_validate_fin_line); -- 4414408
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
    -- 4414408
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    -- 4414408
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END oec_calc_upd_fin_rec;
-----------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : cap_amt_calc_upd_fin_rec
-- Description          : cap_amt_calc_upd_fin_rec
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE cap_amt_calc_upd_fin_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE, -- 4414408
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type,
            x_cap_amt        OUT NOCOPY OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE,
            p_validate_fin_line IN VARCHAR2 DEFAULT OKL_API.G_TRUE) IS

    ln_cap_amt               OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
--    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    l_update_clev_rec        clev_rec_type;
    l_update_klev_rec        klev_rec_type;
-- #4414408 Top line ID is a parameter passed to the API
/*
    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.cle_id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);
*/

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
/*
    OPEN  c_model_top_line(p_model_line_id => p_model_line_id,
                           p_dnz_chr_id    => p_dnz_chr_id);
    FETCH c_model_top_line INTO ln_top_line_id;
-- #4414408 Moved the IF statement  below fetch statement
    IF c_model_top_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'cle_id');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--   #4414408 This condition will never be met
--    IF (c_model_top_line%ROWCOUNT > 1) THEN
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => 'More than one',
--                           p_token1       => 'Model line',
--                           p_token1_value => 'cle_id');
--       RAISE G_EXCEPTION_HALT_VALIDATION;
--    END IF;
    CLOSE c_model_top_line;
*/
    -- to get the Capital Amount
/*
    x_cap_amt := OKL_FORMULA_FUNCTION_PVT.line_capitalamount(p_chr_id  => p_dnz_chr_id,
                                                             p_line_id => ln_top_line_id);
*/
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_CAP,
                                    p_contract_id   => p_dnz_chr_id,
                                    p_line_id       => p_top_line_id, -- 4414408
                                    x_value         => x_cap_amt);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'Capital Amount');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'Capital Amount');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- To Get the cle top Line Record
    x_return_status := get_rec_clev(p_top_line_id, -- 4414408
                                    l_update_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(p_top_line_id, -- 4414408
                                    l_update_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_update_klev_rec.id <> l_update_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_update_klev_rec.capital_amount   := x_cap_amt;

    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    l_update_klev_rec.capital_amount :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_update_klev_rec.capital_amount,
                                                        l_update_clev_rec.currency_code);

    IF (x_cap_amt <> 0 AND l_update_klev_rec.capital_amount = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(x_cap_amt));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency

    Update_fin_line(p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    P_new_yn             => P_new_yn,
                    p_asset_number       => p_asset_number,
                    p_clev_rec           => l_update_clev_rec,
                    p_klev_rec           => l_update_klev_rec,
                    x_clev_rec           => x_fin_clev_rec,
                    x_klev_rec           => x_fin_klev_rec,
                    p_validate_fin_line  => p_validate_fin_line); -- 4414408
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END cap_amt_calc_upd_fin_rec;
-----------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : res_value_calc_upd_fin_rec
-- Description          : res_value_calc_upd_fin_rec
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE res_value_calc_upd_fin_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE, -- 4414408
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type,
            x_res_value      OUT NOCOPY OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
            p_validate_fin_line IN VARCHAR2 DEFAULT OKL_API.G_TRUE) IS

    ln_res_value             OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
--    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    l_update_clev_rec        clev_rec_type;
    l_update_klev_rec        klev_rec_type;
    -- 4414408
/*
    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.cle_id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);
*/
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
/*
    OPEN  c_model_top_line(p_model_line_id => p_model_line_id,
                           p_dnz_chr_id    => p_dnz_chr_id);
    FETCH c_model_top_line INTO ln_top_line_id;
-- #4414408 Moved the IF statement  below fetch statement
    IF c_model_top_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'cle_id');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
--   #4414408 This condition will never be met
--    IF (c_model_top_line%ROWCOUNT > 1) THEN
--       OKL_API.set_message(p_app_name     => G_APP_NAME,
--                           p_msg_name     => 'More than one',
--                           p_token1       => 'Model line',
--                           p_token1_value => 'cle_id');
--       RAISE G_EXCEPTION_HALT_VALIDATION;
--    END IF;
    CLOSE c_model_top_line;
*/
    -- to get the Residual value
/*
    x_res_value := OKL_SEEDED_FUNCTIONS_PVT.line_residualvalue(p_chr_id  => p_dnz_chr_id,
                                                               p_line_id => ln_top_line_id);
*/

    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_formula_name  => G_FORMULA_RES,
                                    p_contract_id   => p_dnz_chr_id,
                                    p_line_id       => p_top_line_id, -- 4414408
                                    x_value         => x_res_value);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'Residual Value');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CALC_AMOUNT,
                          p_token1       => G_AMT_TOKEN,
                          p_token1_value => 'Residual Value');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the cle top Line Record
    x_return_status := get_rec_clev(p_top_line_id, -- 4414408
                                    l_update_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(p_top_line_id, -- 4414408
                                    l_update_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_update_klev_rec.id <> l_update_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- commented for multi currency requirement. No need to round the value, as
    -- it is taken care in the call to accounting util package called below.
--    l_update_klev_rec.residual_value   := round(x_res_value,2);
    l_update_klev_rec.residual_value   := x_res_value;

    -- Modified by rravikir
    -- Call to Accounting Util package to address Multi Currency requirement
    -- Start
    l_update_klev_rec.residual_value :=
        OKL_ACCOUNTING_UTIL.CROSS_CURRENCY_ROUND_AMOUNT(l_update_klev_rec.residual_value,
                                                        l_update_clev_rec.currency_code);

    IF (x_res_value <> 0 AND l_update_klev_rec.residual_value = 0) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_AMOUNT_ROUNDING,
                          p_token1       => 'AMT',
                          p_token1_value => to_char(x_res_value));
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- End Modification for Multi Currency

    Update_fin_line(p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    P_new_yn             => P_new_yn,
                    p_asset_number       => p_asset_number,
                    p_clev_rec           => l_update_clev_rec,
                    p_klev_rec           => l_update_klev_rec,
                    x_clev_rec           => x_fin_clev_rec,
                    x_klev_rec           => x_fin_klev_rec,
                    p_validate_fin_line  => p_validate_fin_line); -- 4414408
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- If the cursor is open then it has to be closed
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
--    IF c_model_top_line%ISOPEN THEN
--       CLOSE c_model_top_line;
--    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END res_value_calc_upd_fin_rec;

-----------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : res_value_calc_upd_fin_rec
-- Description          : res_value_calc_upd_fin_rec
-- Business Rules       :
-- Parameters           :
-- Version              : 1.0
-- End of Commnets

  PROCEDURE get_res_per_upd_fin_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_res_value      IN  OKL_K_LINES_V.RESIDUAL_VALUE%TYPE,
            p_oec            IN  OKL_K_LINES_V.OEC%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type,
            p_validate_fin_line IN VARCHAR2 DEFAULT OKL_API.G_TRUE) IS

    ln_res_per               OKL_K_LINES_V.RESIDUAL_PERCENTAGE%TYPE := 0;
    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    l_update_clev_rec        clev_rec_type;
    l_update_klev_rec        klev_rec_type;

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    IF (p_dnz_chr_id IS NULL OR
       p_dnz_chr_id = OKL_API.G_MISS_NUM) OR
       (p_top_line_id IS NULL OR
       p_top_line_id = OKL_API.G_MISS_NUM) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Chr_id,top_line');
       RAISE G_EXCEPTION_STOP_VALIDATION;
   END IF;
   -- gboomina bug 6139003 - Start
   -- Modified this condition to calculate residual percent
   -- only for valid values
   IF (p_oec IS NOT NULL AND
      p_oec <> OKL_API.G_MISS_NUM) AND
      (p_res_value IS NOT NULL AND
      p_res_value <> OKL_API.G_MISS_NUM) THEN
    -- gboomina bug 6139003 - End
      --Bug# 4631549
      If p_oec = 0 then
          ln_res_per := 0;
      else
          ln_res_per :=  ROUND(p_res_value * 100/p_oec,2);
      end if;
   END IF;
    -- To Get the cle top Line Record
    x_return_status := get_rec_clev(p_top_line_id,
                                    l_update_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(p_top_line_id,
                                    l_update_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF l_update_klev_rec.id <> l_update_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_update_klev_rec.residual_percentage   := ln_res_per;
    Update_fin_line(p_api_version        => p_api_version,
                    p_init_msg_list      => p_init_msg_list,
                    x_return_status      => x_return_status,
                    x_msg_count          => x_msg_count,
                    x_msg_data           => x_msg_data,
                    P_new_yn             => P_new_yn,
                    p_asset_number       => p_asset_number,
                    p_clev_rec           => l_update_clev_rec,
                    p_klev_rec           => l_update_klev_rec,
                    x_clev_rec           => x_fin_clev_rec,
                    x_klev_rec           => x_fin_klev_rec,
                    p_validate_fin_line  => p_validate_fin_line); -- 4414408
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END get_res_per_upd_fin_rec;
-------------------------------------------------------------------------------------------------------
----------------------------- Main Process for Creation of model Line -----------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE create_model_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_MODEL_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    l_update_clev_rec        clev_rec_type;
    l_update_klev_rec        klev_rec_type;
    ln_lse_id                OKC_LINE_STYLES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    l_qty                    OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE := 0;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--  4414408 The validation is now performed in create_all_line procedure
/*
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity ended successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
*/
--  4414408 The validations in Validate_lse_id and Validate_dnz_chr_id are redundant
/*
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- We have to Populate the Model Line Record
    l_clev_rec                   := p_clev_rec;
    -- Now we are Creating Model Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Model Line
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
--  #414408
--       l_lty_code = G_MODEL_LINE_LTY_CODE AND
--       l_lse_type = G_SLS_TYPE THEN
       l_clev_rec.lse_id = G_MODEL_LINE_LTY_ID THEN
       create_model_line_item(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
--                              p_lty_code      => l_lty_code,
-- #4414408  redundant parameter
                              p_clev_rec      => l_clev_rec,
                              p_klev_rec      => p_klev_rec,
                              p_cimv_rec      => p_cimv_rec,
                              x_clev_rec      => x_clev_rec,
                              x_klev_rec      => x_klev_rec,
                              x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Model Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_model_line;
-------------------------------------------------------------------------------------------------------
----------------------------- Main Process for update of model Line -----------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE Update_model_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_MODEL_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    ln_fa_id                 OKC_K_LINES_V.ID%TYPE;

    CURSOR get_fa_id(p_top_line OKC_K_LINES_V.ID%TYPE,
                     p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_top_line
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND lse1.id = cle.lse_id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_sts_code(p_clev_rec       => p_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To get the fixed asset line asset to see
    -- the asset number does not duplicate
    OPEN  get_fa_id(p_top_line => p_clev_rec.cle_id,
                    p_dnz_chr_id => p_clev_rec.dnz_chr_id);
    IF get_fa_id%NOTFOUND THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH get_fa_id INTO ln_fa_id;
    CLOSE get_fa_id;

    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => ln_fa_id,
                                   p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSIF UPPER(p_new_yn) = 'N' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => ln_fa_id,
                                   p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We have to Populate the Model Line Record
    l_clev_rec                   := p_clev_rec;
    -- Now we are updating Model Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Model Line
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_MODEL_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       update_model_line_item(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_lty_code      => l_lty_code,
                              p_clev_rec      => l_clev_rec,
                              p_klev_rec      => p_klev_rec,
                              p_cimv_rec      => p_cimv_rec,
                              x_clev_rec      => x_clev_rec,
                              x_klev_rec      => x_klev_rec,
                              x_cimv_rec      => x_cimv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Model Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF get_fa_id%ISOPEN THEN
      CLOSE get_fa_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_model_line;
-----------------------------------------------------------------------------------------------
----------------- Main Process for Fixed Asset Line Creation-----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_fixed_asset_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_talv_rec       IN  talv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_FXD_AST_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--  4414408 The validation is now performed in create_all_line procedure
/*
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => p_asset_number,
                                 p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity ended successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
*/
--  4414408 The validations in Validate_lse_id and Validate_dnz_chr_id are redundant
/*
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- Now we are going to create the Fixed Assets Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Fixed Assets Line
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
-- #4414408
--       l_lty_code = G_FA_LINE_LTY_CODE AND
--       l_lse_type = G_SLS_TYPE THEN
       l_clev_rec.lse_id = G_FA_LINE_LTY_ID THEN
       create_fa_line_item(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
--                           p_lty_code      => l_lty_code,
                           p_clev_rec      => p_clev_rec,
                           p_klev_rec      => p_klev_rec,
                           p_cimv_rec      => p_cimv_rec,
                           p_talv_rec      => p_talv_rec,
                           x_clev_rec      => x_clev_rec,
                           x_klev_rec      => x_klev_rec,
                           x_cimv_rec      => x_cimv_rec,
                           x_trxv_rec      => x_trxv_rec,
                           x_talv_rec      => x_talv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Fixed Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_fixed_asset_line;
-------------------------------------------------------------------------------------------------------
----------------------------- Main Process for update of fixed asset Line -----------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE Update_fixed_asset_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_talv_rec       IN  talv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_FXD_AST_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_sts_code(p_clev_rec       => p_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => p_talv_rec.kle_id,
                                   p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSIF UPPER(p_new_yn) = 'N' THEN
       validate_new_ast_num_update(x_return_status  => x_return_status,
                                   p_asset_number   => p_asset_number,
                                   p_kle_id         => p_talv_rec.kle_id,
                                   p_dnz_chr_id     => p_clev_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We have to Populate the Model Line Record
    l_clev_rec                   := p_clev_rec;
    -- Now we are updating Fixed Asset Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is Fixed Asset Line
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_FA_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       update_fa_line_item(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_lty_code      => l_lty_code,
                            P_new_yn        => p_new_yn,
                            p_clev_rec      => l_clev_rec,
                            p_klev_rec      => p_klev_rec,
                            p_cimv_rec      => p_cimv_rec,
                            p_talv_rec      => p_talv_rec,
                            x_clev_rec      => x_clev_rec,
                            x_klev_rec      => x_klev_rec,
                            x_cimv_rec      => x_cimv_rec,
                            x_talv_rec      => x_talv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Fixed Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_fixed_asset_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Creation of Add on Line ---------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE create_add_on_line(p_api_version    IN  NUMBER,
                              p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
                              x_return_status  OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY VARCHAR2,
                              P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
                              p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                              p_clev_tbl       IN  clev_tbl_type,
                              p_klev_tbl       IN  klev_tbl_type,
                              p_cimv_tbl       IN  cimv_tbl_type,
                              x_clev_tbl       OUT NOCOPY clev_tbl_type,
                              x_klev_tbl       OUT NOCOPY klev_tbl_type,
                              x_fin_clev_rec   OUT NOCOPY clev_rec_type,
                              x_fin_klev_rec   OUT NOCOPY klev_rec_type,
                              x_cimv_tbl       OUT NOCOPY cimv_tbl_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_ADD_LINE';
    i                        NUMBER := 0;
    j                        NUMBER := 0;
    k                        NUMBER := 0;
    l_klev_rec               klev_rec_type;
    l_clev_tbl               clev_tbl_type;
    x_klev_rec               klev_rec_type;
    ln_oec                   OKL_K_LINES_V.OEC%TYPE := 0;
    ln_add_cle_id            OKC_K_LINES_V.CLE_ID%TYPE := 0;
    ln_add_dnz_chr_id        OKC_K_LINES_V.DNZ_CHR_ID%TYPE := 0;
    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    ln_klev_fin_oec          OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res          OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap          OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;

    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
--  #4414408
    SELECT cle.cle_id
    FROM okc_k_lines_b cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = G_MODEL_LINE_LTY_ID;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clev_tbl.COUNT > 0) AND
       (p_cimv_tbl.COUNT > 0)THEN
       i := p_clev_tbl.FIRST;
       k := p_cimv_tbl.FIRST;
       IF (p_klev_tbl.COUNT = 0) THEN
       -- Since p_klev_tbl is not Mandtory we could get and give blank record
         l_clev_tbl := p_clev_tbl;
         LOOP
           x_return_status := get_lse_id(p_lty_code => G_ADDON_LINE_LTY_CODE,
                                         x_lse_id   => l_clev_tbl(i).lse_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
           create_addon_line_rec(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 P_new_yn        => P_new_yn,
                                 p_asset_number  => p_asset_number,
                                 p_clev_rec      => l_clev_tbl(i),
                                 p_klev_rec      => l_klev_rec,
                                 p_cimv_rec      => p_cimv_tbl(k),
                                 x_clev_rec      => x_clev_tbl(i),
                                 x_klev_rec      => x_klev_rec,
                                 x_cimv_rec      => x_cimv_tbl(k));
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
           ln_add_cle_id       := x_clev_tbl(i).cle_id;
           ln_add_dnz_chr_id   := x_clev_tbl(i).dnz_chr_id;
           -- Assume that there will be one to one for item and add on line
           EXIT WHEN (i = p_clev_tbl.LAST);
           i := l_clev_tbl.NEXT(i);
           k := p_cimv_tbl.NEXT(k);
           x_klev_tbl(i) :=  x_klev_rec;
         END LOOP;
       ELSE
         IF (p_clev_tbl.COUNT <> p_klev_tbl.COUNT) OR
            (p_clev_tbl.COUNT <> p_cimv_tbl.COUNT) OR
            (p_klev_tbl.COUNT <> p_cimv_tbl.COUNT) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_CNT_REC);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         j := p_klev_tbl.FIRST;
         l_clev_tbl := p_clev_tbl;
         LOOP
           x_return_status := get_lse_id(p_lty_code => G_ADDON_LINE_LTY_CODE,
                                         x_lse_id   => l_clev_tbl(i).lse_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
           create_addon_line_rec(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 P_new_yn        => P_new_yn,
                                 p_asset_number  => p_asset_number,
                                 p_clev_rec      => l_clev_tbl(i),
                                 p_klev_rec      => p_klev_tbl(j),
                                 p_cimv_rec      => p_cimv_tbl(k),
                                 x_clev_rec      => x_clev_tbl(i),
                                 x_klev_rec      => x_klev_tbl(j),
                                 x_cimv_rec      => x_cimv_tbl(k));
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
           ln_add_cle_id       := x_clev_tbl(i).cle_id;
           ln_add_dnz_chr_id   := x_clev_tbl(i).dnz_chr_id;
           -- Assume that there will be one to one for item and add on line
           EXIT WHEN (i = p_clev_tbl.LAST);
           i := l_clev_tbl.NEXT(i);
           j := p_klev_tbl.NEXT(j);
           k := p_cimv_tbl.NEXT(K);
         END LOOP;
       END IF;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       OPEN  c_model_top_line(p_model_line_id => ln_add_cle_id,
                              p_dnz_chr_id    => ln_add_dnz_chr_id);
       FETCH c_model_top_line INTO ln_top_line_id;

       IF c_model_top_line%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'cle_id');
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;

       CLOSE c_model_top_line;

       -- Calculate the OEC to Populate the OKL_K_LINES_V.OEC
       oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            P_new_yn             => P_new_yn,
                            p_asset_number       => p_asset_number,
			    -- 4414408
                            p_top_line_id        => ln_top_line_id,
                            p_dnz_chr_id         => ln_add_dnz_chr_id,
                            x_fin_clev_rec       => x_fin_clev_rec,
                            x_fin_klev_rec       => x_fin_klev_rec,
                            x_oec                => ln_klev_fin_oec,
                            p_validate_fin_line  => OKL_API.G_TRUE);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
       cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                P_new_yn             => P_new_yn,
                                p_asset_number       => p_asset_number,
				-- 4414408
                                p_top_line_id        => ln_top_line_id,
                                p_dnz_chr_id         => ln_add_dnz_chr_id,
                                x_fin_clev_rec       => x_fin_clev_rec,
                                x_fin_klev_rec       => x_fin_klev_rec,
                                x_cap_amt            => ln_klev_fin_cap,
                                p_validate_fin_line  => OKL_API.G_TRUE);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
       res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                  p_init_msg_list      => p_init_msg_list,
                                  x_return_status      => x_return_status,
                                  x_msg_count          => x_msg_count,
                                  x_msg_data           => x_msg_data,
                                  P_new_yn             => P_new_yn,
                                  p_asset_number       => p_asset_number,
				  -- 4414408
                                  p_top_line_id        => ln_top_line_id,
                                  p_dnz_chr_id         => ln_add_dnz_chr_id,
                                  x_fin_clev_rec       => x_fin_clev_rec,
                                  x_fin_klev_rec       => x_fin_klev_rec,
                                  x_res_value          => ln_klev_fin_res,
                                  p_validate_fin_line  => OKL_API.G_TRUE);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       --Bug# 5530990
       -- Update Original Cost and Depreciation Cost in
       -- OKL_TXL_ASSETS_B and OKL_TXD_ASSETS_B when
       -- Add on line is added
       update_asset_cost(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         p_cleb_fin_id        => ln_top_line_id,
                         p_chr_id             => ln_add_dnz_chr_id,
                         p_oec                => ln_klev_fin_oec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

    ELSE
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_CNT_REC);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_add_on_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Update of Add on Line ---------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE update_add_on_line(
            p_api_version   IN NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            p_cimv_tbl       IN  cimv_tbl_type,
            x_clev_tbl       OUT NOCOPY clev_tbl_type,
            x_klev_tbl       OUT NOCOPY klev_tbl_type,
            x_cimv_tbl       OUT NOCOPY cimv_tbl_type,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type) IS

    i                        NUMBER := 0;
    j                        NUMBER := 0;
    k                        NUMBER := 0;
    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_ADD_LINE';
    l_klev_rec               klev_rec_type;
    l_clev_tbl               clev_tbl_type;
    x_klev_rec               klev_rec_type;
    ln_add_cle_id            OKC_K_LINES_V.CLE_ID%TYPE := 0;
    ln_add_dnz_chr_id        OKC_K_LINES_V.DNZ_CHR_ID%TYPE := 0;
    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    ln_klev_fin_oec          OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res          OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap          OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;

    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    --  #4414408
    SELECT cle.cle_id
    FROM okc_k_lines_b cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = G_MODEL_LINE_LTY_ID;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clev_tbl.COUNT > 0) AND
       (p_klev_tbl.COUNT > 0) AND
       (p_cimv_tbl.COUNT > 0)THEN
       IF (p_clev_tbl.COUNT <> p_klev_tbl.COUNT) OR
          (p_clev_tbl.COUNT <> p_cimv_tbl.COUNT) OR
          (p_klev_tbl.COUNT <> p_cimv_tbl.COUNT) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name => G_CNT_REC);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       i := p_clev_tbl.FIRST;
       j := p_klev_tbl.FIRST;
       k := p_cimv_tbl.FIRST;
       l_clev_tbl := p_clev_tbl;
       LOOP
         update_addon_line_rec(p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               P_new_yn        => P_new_yn,
                               p_asset_number  => p_asset_number,
                               p_clev_rec      => l_clev_tbl(i),
                               p_klev_rec      => p_klev_tbl(j),
                               p_cimv_rec      => p_cimv_tbl(k),
                               x_clev_rec      => x_clev_tbl(i),
                               x_klev_rec      => x_klev_tbl(j),
                               x_cimv_rec      => x_cimv_tbl(k));
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         ln_add_cle_id       := x_clev_tbl(i).cle_id;
         ln_add_dnz_chr_id   := x_clev_tbl(i).dnz_chr_id;
         -- Assume that there will be one to one for item and add on line
         EXIT WHEN (i = p_clev_tbl.LAST);
         i := p_clev_tbl.NEXT(i);
         j := p_klev_tbl.NEXT(j);
         k := p_clev_tbl.NEXT(k);
       END LOOP;
    ELSE
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_CNT_REC);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_model_top_line(p_model_line_id => ln_add_cle_id,
                           p_dnz_chr_id    => ln_add_dnz_chr_id);
    FETCH c_model_top_line INTO ln_top_line_id;

    IF c_model_top_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'cle_id');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    CLOSE c_model_top_line;

    -- Calculate the OEC to Populate the OKL_K_LINES_V.OEC
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => p_asset_number,
			 -- 4414408
                         p_top_line_id        => ln_top_line_id,
                         p_dnz_chr_id         => ln_add_dnz_chr_id,
                         x_fin_clev_rec       => x_fin_clev_rec,
                         x_fin_klev_rec       => x_fin_klev_rec,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => p_asset_number,
			     -- 4414408
                             p_top_line_id        => ln_top_line_id,
                             p_dnz_chr_id         => ln_add_dnz_chr_id,
                             x_fin_clev_rec       => x_fin_clev_rec,
                             x_fin_klev_rec       => x_fin_klev_rec,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => ln_top_line_id,
                               p_dnz_chr_id         => ln_add_dnz_chr_id,
                               x_fin_clev_rec       => x_fin_clev_rec,
                               x_fin_klev_rec       => x_fin_klev_rec,
                               x_res_value          => ln_klev_fin_res,
                               p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 5530990
    -- Update Original Cost and Depreciation Cost in
    -- OKL_TXL_ASSETS_B and OKL_TXD_ASSETS_B when
    -- Add on line is updated
    update_asset_cost(p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_cleb_fin_id        => ln_top_line_id,
                      p_chr_id             => ln_add_dnz_chr_id,
                      p_oec                => ln_klev_fin_oec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (x_fin_clev_rec.dnz_chr_id is NOT NULL) AND
       (x_fin_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_fin_clev_rec.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_add_on_line;
-------------------------------------------------------------------------------------------------------
---------------------------- Main Process for Delete of Add on Line -----------------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_add_on_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_tbl       IN  clev_tbl_type,
            p_klev_tbl       IN  klev_tbl_type,
            x_fin_clev_rec   OUT NOCOPY clev_rec_type,
            x_fin_klev_rec   OUT NOCOPY klev_rec_type) IS

    i                        NUMBER := 0;
    j                        NUMBER := 0;
    l_api_name      CONSTANT VARCHAR2(30) := 'DELETE_ADDON_LN';
    ln_add_cle_id            OKC_K_LINES_V.CLE_ID%TYPE := 0;
    ln_add_dnz_chr_id        OKC_K_LINES_V.DNZ_CHR_ID%TYPE := 0;
    ln_top_line_id           OKC_K_LINES_V.CLE_ID%TYPE := 0;
    l_clev_tbl               clev_tbl_type;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;

    -- To Find out the Top line ID
    CURSOR c_model_top_line(p_model_line_id OKC_K_LINES_V.ID%TYPE,
                            p_dnz_chr_id    OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    --  #4414408
    SELECT cle.cle_id
    FROM okc_k_lines_b cle
    WHERE cle.id = p_model_line_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = G_MODEL_LINE_LTY_ID;

  BEGIN
    x_return_status       := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_clev_tbl.COUNT > 0) AND
       (p_klev_tbl.COUNT > 0) THEN
       IF (p_clev_tbl.COUNT <> p_klev_tbl.COUNT) THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_CNT_REC);
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       i := p_clev_tbl.FIRST;
       j := p_klev_tbl.FIRST;
       LOOP
         delete_addon_line_rec(p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_clev_rec      => p_clev_tbl(i),
                               p_klev_rec      => p_klev_tbl(j),
                               x_clev_rec      => l_clev_tbl(i));
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         ln_add_cle_id     := l_clev_tbl(i).cle_id;
         ln_add_dnz_chr_id := l_clev_tbl(i).dnz_chr_id;
         -- Assume that there will be one to one for item and add on line
         EXIT WHEN (i = p_clev_tbl.LAST);
         i := p_clev_tbl.NEXT(i);
         j := p_klev_tbl.NEXT(j);
       END LOOP;
    ELSE
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_CNT_REC);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    OPEN  c_model_top_line(p_model_line_id => ln_add_cle_id,
                           p_dnz_chr_id    => ln_add_dnz_chr_id);
    FETCH c_model_top_line INTO ln_top_line_id;

    IF c_model_top_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'cle_id');
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    CLOSE c_model_top_line;

    -- Calculate the OEC to Populate the OKL_K_LINES_V.OEC
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => p_asset_number,
			 -- 4414408
                         p_top_line_id        => ln_top_line_id,
                         p_dnz_chr_id         => ln_add_dnz_chr_id,
                         x_fin_clev_rec       => x_fin_clev_rec,
                         x_fin_klev_rec       => x_fin_klev_rec,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => p_asset_number,
			     -- 4414408
                             p_top_line_id        => ln_top_line_id,
                             p_dnz_chr_id         => ln_add_dnz_chr_id,
                             x_fin_clev_rec       => x_fin_clev_rec,
                             x_fin_klev_rec       => x_fin_klev_rec,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => ln_top_line_id,
                               p_dnz_chr_id         => ln_add_dnz_chr_id,
                               x_fin_clev_rec       => x_fin_clev_rec,
                               x_fin_klev_rec       => x_fin_klev_rec,
                               x_res_value          => ln_klev_fin_res,
                               p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 5530990
    -- Update Original Cost and Depreciation Cost in
    -- OKL_TXL_ASSETS_B and OKL_TXD_ASSETS_B when
    -- Add on line is deleted
    update_asset_cost(p_api_version        => p_api_version,
                      p_init_msg_list      => p_init_msg_list,
                      x_return_status      => x_return_status,
                      x_msg_count          => x_msg_count,
                      x_msg_data           => x_msg_data,
                      p_cleb_fin_id        => ln_top_line_id,
                      p_chr_id             => ln_add_dnz_chr_id,
                      p_oec                => ln_klev_fin_oec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
     RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (x_fin_clev_rec.dnz_chr_id is NOT NULL) AND
       (x_fin_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_fin_clev_rec.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END delete_add_on_line;
-----------------------------------------------------------------------------------------------
------------------ Main Process for Instance Line Creation-------------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_instance_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_itiv_rec       IN  itiv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_itiv_rec       OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_INSTANCE_LINES';
    l_clev_rec               clev_rec_type;
    ln_lse_id                OKC_LINE_STYLES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--  4414408 The validations in Validate_lse_id and Validate_dnz_chr_id are redundant
/*
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- Now we are going to create the instance Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is instance Line
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
--     #4414408
--       l_lty_code = G_INST_LINE_LTY_CODE AND
--       l_lse_type = G_SLS_TYPE THEN
       l_clev_rec.lse_id = G_INST_LINE_LTY_ID THEN
       validate_instance_number_ib(x_return_status => x_return_status,
                                   p_inst_num_ib   => p_itiv_rec.instance_number_ib);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       Create_inst_line(p_api_version   => p_api_version,
                        p_init_msg_list => p_init_msg_list,
                        x_return_status => x_return_status,
                        x_msg_count     => x_msg_count,
                        x_msg_data      => x_msg_data,
-- 4414408              p_lty_code      => l_lty_code,
                        p_clev_rec      => l_clev_rec,
                        p_klev_rec      => p_klev_rec,
                        x_clev_rec      => x_clev_rec,
                        x_klev_rec      => x_klev_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Instance Asset line');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_instance_line;
-----------------------------------------------------------------------------------------------
------------------ Main Process for Updating Instance Line ------------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_instance_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_itiv_rec       IN  itiv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_itiv_rec       OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_INSTANCE_LINES';
    l_clev_rec               clev_rec_type;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_sts_code(p_clev_rec       => p_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are going to create the instance Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is instance Line
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_INST_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       IF (p_itiv_rec.instance_number_ib IS NOT NULL OR
          p_itiv_rec.instance_number_ib <> OKL_API.G_MISS_CHAR) THEN
          update_inst_line(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_lty_code      => l_lty_code,
                           p_clev_rec      => p_clev_rec,
                           p_klev_rec      => p_klev_rec,
                           x_clev_rec      => x_clev_rec,
                           x_klev_rec      => x_klev_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       ELSE
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Instance Asset line');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Instance Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_instance_line;
-----------------------------------------------------------------------------------------------
------------------ Main Process for Install Base Line Creation---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_instance_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_itiv_rec       IN  itiv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_itiv_rec       OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_INSTANCE_IB_LINES';
    l_clev_rec               clev_rec_type;
    l_cimv_rec               cimv_rec_type;
    ln_lse_id                OKC_LINE_STYLES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--  4414408 The validations in Validate_lse_id and Validate_dnz_chr_id are redundant
/*
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    -- Now we are going to create the instance Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is instance Line
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
-- 4414408
--       l_lty_code = G_IB_LINE_LTY_CODE AND
--       l_lse_type = G_SLS_TYPE THEN
       l_clev_rec.lse_id = G_IB_LINE_LTY_ID THEN
       validate_instance_number_ib(x_return_status => x_return_status,
                                   p_inst_num_ib   => p_itiv_rec.instance_number_ib);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       Create_installed_base_line(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
-- 4414408                        p_lty_code      => l_lty_code,
                                  p_clev_rec      => l_clev_rec,
                                  p_klev_rec      => p_klev_rec,
                                  p_cimv_rec      => p_cimv_rec,
                                  p_itiv_rec      => p_itiv_rec,
                                  x_clev_rec      => x_clev_rec,
                                  x_klev_rec      => x_klev_rec,
                                  x_cimv_rec      => x_cimv_rec,
                                  x_trxv_rec      => x_trxv_rec,
                                  x_itiv_rec      => x_itiv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Install Base Asset line');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_instance_ib_line;
-----------------------------------------------------------------------------------------------
------------------ Main Process for Updating Instance IB Line ---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_instance_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_rec       IN  clev_rec_type,
            p_klev_rec       IN  klev_rec_type,
            p_cimv_rec       IN  cimv_rec_type,
            p_itiv_rec       IN  itiv_rec_type,
            x_clev_rec       OUT NOCOPY clev_rec_type,
            x_klev_rec       OUT NOCOPY klev_rec_type,
            x_cimv_rec       OUT NOCOPY cimv_rec_type,
            x_itiv_rec       OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_INSTANCE_IB_LINES';
    l_clev_rec               clev_rec_type;
    l_cimv_rec               cimv_rec_type;
    lv_dummy                 VARCHAR2(3);
    lv_ib_id1                OKX_INSTALL_ITEMS_V.ID1%TYPE;
    lv_ib_id2                OKX_INSTALL_ITEMS_V.ID2%TYPE;
    -- Variables for validation of line style
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;
    l_talv_rec               talv_rec_type;
    l_trxv_rec               trxv_rec_type;
    l_itiv_rec               itiv_rec_type;
    ln_tas_id                OKL_TRX_ASSETS.ID%TYPE;
    ln_line_number           OKL_TXL_ASSETS_V.LINE_NUMBER%TYPE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    validate_sts_code(p_clev_rec       => p_clev_rec,
                      x_return_status  => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => p_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => p_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now we are going to create the installed_base_Line
    -- Here we have have Dnz_Chr_id ,lse_id and cle_id
    -- The Record Should have the cle_id
    -- if the given line style is instance base Line
    l_clev_rec := p_clev_rec;
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       l_lty_code = G_IB_LINE_LTY_CODE AND
       l_lse_type = G_SLS_TYPE THEN
       IF (p_itiv_rec.instance_number_ib IS NOT NULL OR
          p_itiv_rec.instance_number_ib <> OKL_API.G_MISS_CHAR) THEN
          l_cimv_rec      := p_cimv_rec;
          update_installed_base_line(p_api_version   => p_api_version,
                                     p_init_msg_list => p_init_msg_list,
                                     x_return_status => x_return_status,
                                     x_msg_count     => x_msg_count,
                                     x_msg_data      => x_msg_data,
                                     p_lty_code      => l_lty_code,
                                     p_clev_rec      => p_clev_rec,
                                     p_klev_rec      => p_klev_rec,
                                     p_cimv_rec      => p_cimv_rec,
                                     p_itiv_rec      => p_itiv_rec,
                                     x_clev_rec      => x_clev_rec,
                                     x_klev_rec      => x_klev_rec,
                                     x_cimv_rec      => x_cimv_rec,
                                     x_itiv_rec      => x_itiv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
       ELSE
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Install Base Asset line');
         x_return_status := OKL_API.G_RET_STS_ERROR;
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_INVALID_CRITERIA,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Instance Asset line');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Update_instance_ib_line;
-----------------------------------------------------------------------------------------------
------------------------ Main Process for Create Party Roles-----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_PTY_RLE_LINES';
    l_clev_rec               clev_rec_type;
    l_cplv_rec               cplv_rec_type;
    l_klev_rec               klev_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;

    --Bug# 4558486
    l_kplv_rec               OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
    x_kplv_rec               OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_clev(p_id       => p_cplv_rec.cle_id,
                                    x_clev_rec => l_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_klev(p_id       => p_cplv_rec.cle_id,
                                    x_klev_rec => l_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_clev_rec.id <> l_klev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => l_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => l_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We can create a party item info only if the line is Model Line
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       (l_lty_code = G_MODEL_LINE_LTY_CODE OR
        l_lty_code = G_ADDON_LINE_LTY_CODE) AND
       l_lse_type = G_SLS_TYPE THEN
       x_return_status := get_rec_cplv(p_cplv_id  => p_cplv_rec.id,
                                       x_cplv_rec => l_cplv_rec);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_PARTY_ROLES_V Record');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_PARTY_ROLES_V Record');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;

       IF (p_cplv_rec.cle_id IS NOT NULL OR
          p_cplv_rec.cle_id <> OKL_API.G_MISS_NUM) THEN
          l_cplv_rec.cle_id := p_cplv_rec.cle_id;
       ELSE
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_REQUIRED_VALUE,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'cle_id in creation party roles');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_cplv_rec.chr_id := null;
       -- Creation of Party Item Record for the above record information
       --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
       --              to create records in tables
       --              okc_k_party_roles_b and okl_k_party_roles
       /*
       OKL_OKC_MIGRATION_PVT.create_k_party_role(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cplv_rec      => l_cplv_rec,
                                                  x_cplv_rec      => x_cplv_rec);
       */

       OKL_K_PARTY_ROLES_PVT.create_k_party_role
         (p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_cplv_rec      => l_cplv_rec,
          x_cplv_rec      => x_cplv_rec,
          p_kplv_rec      => l_kplv_rec,
          x_kplv_rec      => x_kplv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_PARTY_ROLE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_CREATION_PARTY_ROLE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => 'LINE_STYLE',
                          p_token1_value => 'Model/Addon Line for Party Roles');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_party_roles_rec;
-----------------------------------------------------------------------------------------------
------------------------ Main Process for Update Party Roles-----------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_party_roles_rec(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cplv_rec       IN  cplv_rec_type,
            x_cplv_rec       OUT NOCOPY cplv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'UPDATE_PTY_RLE_LINES';
    l_clev_rec               clev_rec_type;
    l_cplv_rec               cplv_rec_type;
    l_klev_rec               klev_rec_type;
    l_lty_code               OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    l_lse_type               OKC_LINE_STYLES_V.LSE_TYPE%TYPE;

    --Bug# 4558486
    l_kplv_rec               OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
    x_kplv_rec               OKL_K_PARTY_ROLES_PVT.kplv_rec_type;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_cplv(p_cplv_id  => p_cplv_rec.id,
                                    x_cplv_rec => l_cplv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_PARTY_ROLES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_PARTY_ROLES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_clev(p_id       => l_cplv_rec.cle_id,
                                    x_clev_rec => l_clev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_klev(p_id       => l_cplv_rec.cle_id,
                                    x_klev_rec => l_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_clev_rec.id <> l_klev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate Line Style id and get the line type code
    -- and line style type for further processing
    validate_lse_id(p_clev_rec      => l_clev_rec,
                    x_return_status => x_return_status,
                    x_lty_code      => l_lty_code,
                    x_lse_type      => l_lse_type);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Validate the Dnz_Chr_id
    validate_dnz_chr_id(p_clev_rec      => l_clev_rec,
                        x_return_status => x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We can create a party item info only if the line is Model Line
    IF (l_clev_rec.chr_id = OKL_API.G_MISS_NUM OR
       l_clev_rec.chr_id IS NULL) AND
       (l_clev_rec.dnz_chr_id IS NOT NULL OR
       l_clev_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) AND
       (l_clev_rec.cle_id IS NOT NULL OR
       l_clev_rec.cle_id <> OKL_API.G_MISS_NUM) AND
       (l_lty_code = G_MODEL_LINE_LTY_CODE OR
        l_lty_code = G_ADDON_LINE_LTY_CODE) AND
       l_lse_type = G_SLS_TYPE THEN
       l_cplv_rec.object1_id1 := p_cplv_rec.object1_id1;
       l_cplv_rec.object1_id2 := p_cplv_rec.object1_id2;
       -- Creation of Party Item Record for the above record information
       --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
       --              to update records in tables
       --              okc_k_party_roles_b and okl_k_party_roles
       /*
       OKL_OKC_MIGRATION_PVT.update_k_party_role(p_api_version   => p_api_version,
                                                  p_init_msg_list => p_init_msg_list,
                                                  x_return_status => x_return_status,
                                                  x_msg_count     => x_msg_count,
                                                  x_msg_data      => x_msg_data,
                                                  p_cplv_rec      => l_cplv_rec,
                                                  x_cplv_rec      => x_cplv_rec);
       */
       l_kplv_rec.id := l_cplv_rec.id;
       OKL_K_PARTY_ROLES_PVT.update_k_party_role
         (p_api_version   => p_api_version,
          p_init_msg_list => p_init_msg_list,
          x_return_status => x_return_status,
          x_msg_count     => x_msg_count,
          x_msg_data      => x_msg_data,
          p_cplv_rec      => l_cplv_rec,
          x_cplv_rec      => x_cplv_rec,
          p_kplv_rec      => l_kplv_rec,
          x_kplv_rec      => x_kplv_rec);

       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_PARTY_ROLE);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_UPDATING_PARTY_ROLE);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_CRITERIA,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Model/Addon Line for Party Roles');
       x_return_status := OKL_API.G_RET_STS_ERROR;
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (x_cplv_rec.dnz_chr_id is NOT NULL) AND
       (x_cplv_rec.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => x_cplv_rec.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_party_roles_rec;

--Bug# 3631094
--------------------------------------------------------------------------------
--Start of comments
--Procedure Name : check_off_lease_trx (local)
--Description    : procedure checks if off lease transaction
--                 is under-way for this asset
--History        : 21-May-2004  avsingh Created
--Notes          : local procedure (this could change and get more complex
--                 in future that is why a separate local proc)
--                 IN Parameters-
--                               p_asset_id - asset id
--                 OUT Parameters -
--                               x_pending_trx_yn  - 'Y' - pending off_lease trx
--                                                   'N' - no pending off_lease trx
--End of comments
--------------------------------------------------------------------------------

  Procedure check_off_lease_trx
                            (p_api_version   IN  NUMBER,
                             p_init_msg_list IN  VARCHAR2,
                             x_return_status OUT NOCOPY VARCHAR2,
                             x_msg_count     OUT NOCOPY NUMBER,
                             x_msg_data      OUT NOCOPY VARCHAR2,
                             p_asset_id      IN  NUMBER,
                             x_pending_trx_yn OUT NOCOPY VARCHAR2) is

  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_OFF_LEASE_TRX';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to find whether unprocessed off lease transaction exists
  cursor  l_off_lease_csr (p_asset_id in number) is
  select  'Y'
  from    fa_additions fa
  where   fa.asset_id   = p_asset_id
  and     exists
          (select '1'
           from    okl_trx_assets   h,
                   okl_txl_assets_b l
           where   h.id = l.tas_id
           and     h.TAS_TYPE in ('AMT','AUD','AUS')
           and     l.asset_number = fa.asset_number
           and     h.tsu_code     = 'ENTERED');


  l_off_lease_trx_exists   varchar2(1);

  Begin
      x_return_status := OKL_API.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --check with cursor
      l_off_lease_trx_exists := 'N';
      open l_off_lease_csr (p_asset_id => p_asset_id);
      fetch l_off_lease_csr into l_off_lease_trx_exists;
      if l_off_lease_csr%NOTFOUND then
          null;
      end if;
      close l_off_lease_csr;

      x_pending_trx_yn   := l_off_lease_trx_exists;
 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    if l_off_lease_csr%ISOPEN then
        close l_off_lease_csr;
    end if;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    if l_off_lease_csr%ISOPEN then
        close l_off_lease_csr;
    end if;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    if l_off_lease_csr%ISOPEN then
        close l_off_lease_csr;
    end if;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END check_off_lease_trx;

--------------------------------------------------------------------------------
--Start of comments
--Procedure Name : Get_Pdt_Params (local)
--Description    : Multi-GAAP - Calls product api to fetch
--                 product specific parameters
--History        : 21-May-2004  ashish.singh Created
--Notes          : local procedure
--                 IN Parameters-
--                               p_chr_id   - contract id
--                 OUT Parameters -
--                               x_rep_pdt_id    - Reporting product id
--                               x_tax_owner     - tax owner
--                               x_deal_type     - local product deal type
--                               x_rep_deal_type - Reporting product deal type
--End of comments
--------------------------------------------------------------------------------
  Procedure Get_Pdt_Params (p_api_version   IN  NUMBER,
                            p_init_msg_list IN  VARCHAR2,
                            x_return_status OUT NOCOPY VARCHAR2,
                            x_msg_count     OUT NOCOPY NUMBER,
                            x_msg_data      OUT NOCOPY VARCHAR2,
                            p_chr_id        IN  NUMBER,
                            x_rep_pdt_id    OUT NOCOPY NUMBER,
                            x_tax_owner     OUT NOCOPY VARCHAR2,
                            x_deal_type     OUT NOCOPY VARCHAR2,
                            x_rep_deal_type OUT NOCOPY VARCHAR2) is

  l_pdtv_rec                okl_setupproducts_pub.pdtv_rec_type;
  l_pdt_parameter_rec       okl_setupproducts_pub.pdt_parameters_rec_type;
  l_rep_pdt_parameter_rec   okl_setupproducts_pub.pdt_parameters_rec_type;
  l_pdt_date                DATE;
  l_no_data_found           BOOLEAN;
  l_error_condition         Exception;
  l_return_status           VARCHAR2(1) default OKL_API.G_RET_STS_SUCCESS;

  --cursor to get pdt_id and k_start date
  cursor l_chr_csr (p_chr_id in number) is
  SELECT chrb.start_date,
         khr.pdt_id
  FROM   OKC_K_HEADERS_B chrb,
         OKL_K_HEADERS   khr
  WHERE  khr.id          = chrb.id
  AND    chrb.id         = p_chr_id;

  l_chr_rec l_chr_csr%ROWTYPE;

  Begin

     --get pdt id and date from k header
     open l_chr_csr(p_chr_id => p_chr_id);
     Fetch l_chr_csr into l_chr_rec;
     If l_chr_csr%NOTFOUND then
         Null;
     End If;
     close l_chr_csr;

     l_pdtv_rec.id    := l_chr_rec.pdt_id;
     l_pdt_date       := l_chr_rec.start_date;
     l_no_data_found  := TRUE;
     x_return_status  := OKL_API.G_RET_STS_SUCCESS;

     okl_setupproducts_pub.Getpdt_parameters(p_api_version       => p_api_version,
                                             p_init_msg_list     => p_init_msg_list,
                      	                     x_return_status     => l_return_status,
            		                     x_no_data_found     => l_no_data_found,
                                             x_msg_count         => x_msg_count,
                              		     x_msg_data          => x_msg_data,
					     p_pdtv_rec          => l_pdtv_rec,
					     p_product_date      => l_pdt_date,
					     p_pdt_parameter_rec => l_pdt_parameter_rec);

     IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
         x_rep_pdt_id    := Null;
         x_tax_owner     := Null;
     Else
         x_rep_pdt_id    := l_pdt_parameter_rec.reporting_pdt_id;
         x_tax_owner     := l_pdt_parameter_rec.tax_owner;
         x_deal_type     := l_pdt_parameter_rec.deal_type;
         --get reporting product param values
         l_no_data_found := TRUE;
         l_pdtv_rec.id := x_rep_pdt_id;
         okl_setupproducts_pub.Getpdt_parameters(p_api_version      => p_api_version,
                                                 p_init_msg_list     => p_init_msg_list,
                                                 x_return_status     => l_return_status,
                                                 x_no_data_found     => l_no_data_found,
                              		         x_msg_count         => x_msg_count,
                               		         x_msg_data          => x_msg_data,
			                         p_pdtv_rec          => l_pdtv_rec,
    			                         p_product_date      => l_pdt_date,
    			                         p_pdt_parameter_rec => l_rep_pdt_parameter_rec);

          IF l_return_status <> OKL_API.G_RET_STS_SUCCESS Then
             x_rep_deal_type := NULL;
          Else
             x_rep_deal_type :=  l_rep_pdt_parameter_rec.deal_type;
          End If;
     End If;

     Exception
     When l_error_condition Then
         If l_chr_csr%ISOPEN then
             close l_chr_csr;
         End If;
     When Others Then
         If l_chr_csr%ISOPEN then
             close l_chr_csr;
         End If;
         x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  End Get_Pdt_Params;
--Bug# 3631094

  --Bug# 3950089: start
  ------------------------------------------------------------------------------
  --Start of comments
  --
  --Procedure Name        : get_nbv
  --Purpose               : Get Net Book Value- used internally
  --Modification History  :
  --27-Jan-2005    rpillay   Created
  ------------------------------------------------------------------------------
  PROCEDURE get_nbv(p_api_version     IN  NUMBER,
                    p_init_msg_list   IN  VARCHAR2,
                    x_return_status   OUT NOCOPY VARCHAR2,
                    x_msg_count       OUT NOCOPY NUMBER,
                    x_msg_data        OUT NOCOPY VARCHAR2,
                    p_asset_id        IN  NUMBER,
                    p_book_type_code  IN  VARCHAR2,
                    p_chr_id          IN  NUMBER,
                    p_release_date    IN  DATE,
                    x_nbv             OUT NOCOPY Number) IS

    l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_api_name        CONSTANT VARCHAR2(30) := 'GET_NBV';
    l_api_version	    CONSTANT NUMBER	:= 1.0;

    l_asset_hdr_rec            FA_API_TYPES.asset_hdr_rec_type;
    l_asset_fin_rec            FA_API_TYPES.asset_fin_rec_type;
    l_asset_deprn_rec          FA_API_TYPES.asset_deprn_rec_type;

    l_nbv                      NUMBER;
    l_converted_amount         NUMBER;
    l_contract_currency        OKL_K_HEADERS_FULL_V.currency_code%TYPE;
    l_currency_conversion_type OKL_K_HEADERS_FULL_V.currency_conversion_type%TYPE;
    l_currency_conversion_rate OKL_K_HEADERS_FULL_V.currency_conversion_rate%TYPE;
    l_currency_conversion_date OKL_K_HEADERS_FULL_V.currency_conversion_date%TYPE;

  BEGIN
     --call start activity to set savepoint
     l_return_status := OKL_API.START_ACTIVITY( substr(l_api_name,1,26),
                                                p_init_msg_list,
                                                '_PVT',
                                                x_return_status);
     IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;

     l_asset_hdr_rec.asset_id          := p_asset_id;
     l_asset_hdr_rec.book_type_code    := p_book_type_code;

     if NOT fa_cache_pkg.fazcbc(x_book => l_asset_hdr_rec.book_type_code) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_CACHE_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Asset Current Cost
     if not FA_UTIL_PVT.get_asset_fin_rec
              (p_asset_hdr_rec         => l_asset_hdr_rec,
               px_asset_fin_rec        => l_asset_fin_rec,
               p_transaction_header_id => NULL,
               p_mrc_sob_type_code     => 'P'
              ) then

       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_ASSET_FIN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     -- To fetch Depreciation Reserve
     if not FA_UTIL_PVT.get_asset_deprn_rec
                (p_asset_hdr_rec         => l_asset_hdr_rec ,
                 px_asset_deprn_rec      => l_asset_deprn_rec,
                 p_period_counter        => NULL,
                 p_mrc_sob_type_code     => 'P'
                 ) then
       OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                           p_msg_name     => 'OKL_LLA_FA_DEPRN_REC_ERROR'
                          );
       Raise OKL_API.G_EXCEPTION_ERROR;
     end if;

     l_nbv := l_asset_fin_rec.cost - l_asset_deprn_rec.deprn_reserve;

     l_converted_amount := 0;
     OKL_ACCOUNTING_UTIL.CONVERT_TO_CONTRACT_CURRENCY(
        p_khr_id                   => p_chr_id,
        p_from_currency            => NULL,
        p_transaction_date         => p_release_date,
        p_amount                   => l_nbv,
        x_return_status            => x_return_status,
        x_contract_currency        => l_contract_currency,
        x_currency_conversion_type => l_currency_conversion_type,
        x_currency_conversion_rate => l_currency_conversion_rate,
        x_currency_conversion_date => l_currency_conversion_date,
        x_converted_amount         => l_converted_amount);

      IF(x_return_status <> Okl_Api.G_RET_STS_SUCCESS) THEN
        Okl_Api.Set_Message(p_app_name     => Okl_Api.G_APP_NAME,
                            p_msg_name     => 'OKL_CONV_TO_FUNC_CURRENCY_FAIL');
        RAISE Okl_Api.G_EXCEPTION_ERROR;
      END IF;

      x_nbv := l_converted_amount;

     --Call end Activity
     OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR Then
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS
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
  END get_nbv;
  --Bug# 3950089: end

  -------------------------------------------
  --Bug# 3533936 : Process for release Assets
  -------------------------------------------
  PROCEDURE Create_release_asset_line
            (p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_asset_id       IN  VARCHAR2,
             p_chr_id         IN  NUMBER,
             x_cle_id         OUT NOCOPY NUMBER) IS


  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'CREATE_RELEASE_ASSET';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to fetch original financial asset line id
  CURSOR l_orig_ast_csr(p_asset_id  varchar2) IS
  SELECT cle_orig.cle_id   finasst_id,
         asr.id            asset_return_id,
         cle_orig.dnz_chr_id  dnz_chr_id,
         --Bug# 4869443
         --trunc(cle_orig.date_terminated) date_terminated
         trunc(decode(sign(cle_orig.end_date - cle_orig.date_terminated),-1,cle_orig.end_date,cle_orig.date_terminated)) date_terminated,
         --Bug# 6328924
         asr.legal_entity_id
  FROM   OKL_ASSET_RETURNS_B asr,
         OKC_K_LINES_B       cle_orig,
         OKC_LINE_STYLES_B   lse_orig,
         OKC_K_ITEMS         cim_orig
  WHERE  asr.kle_id                 =  cle_orig.cle_id
  AND    asr.ars_code               = 'RE_LEASE'
  AND    cim_orig.object1_id1       =  p_asset_id
  AND    cim_orig.object1_id2       = '#'
  AND    cim_orig.jtot_object1_code = 'OKX_ASSET'
  AND    cle_orig.id                =  cim_orig.cle_id
  AND    cle_orig.dnz_chr_id        =  cim_orig.dnz_chr_id
  AND    cle_orig.lse_id            =  lse_orig.id
  AND    lse_orig.lty_code          =  'FIXED_ASSET';

  l_orig_ast_rec     l_orig_ast_csr%ROWTYPE;
  l_new_finasst_id   NUMBER;

  --cursor to fetch all the lines
  CURSOR	l_lines_csr(p_from_cle_id in number) IS
    SELECT 	level,
		id,
		chr_id,
		cle_id,
		dnz_chr_id,
                orig_system_id1
    FROM 	okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_from_cle_id;

  l_lines_rec l_lines_csr%ROWTYPE;

  --cursor to fetch rules linked to lines
  CURSOR l_rgp_csr(p_cle_id in number,
                   p_chr_id in number) IS
  SELECT rgpb.id
  FROM   OKC_RULE_GROUPS_B rgpb
  WHERE  rgpb.cle_id       = p_cle_id
  AND    rgpb.dnz_chr_id   = p_chr_id;


  l_rgp_id   OKC_RULE_GROUPS_B.ID%TYPE;
  l_rgpv_rec okl_okc_migration_pvt.rgpv_rec_type;


  --cursor to get cost and salvage value for corporate book
  CURSOR l_corpbook_csr (p_cle_id in number,
                         p_chr_id in number) IS
  select txlb.depreciation_cost,
         txlb.current_units,
         txlb.salvage_value,
         txlb.percent_salvage_value,
         --Bug : 3569441
         txlb.id,
         txlb.corporate_book,
         --Bug# 3631094
         txlb.in_service_date,
         txlb.deprn_method,
         txlb.life_in_months,
         txlb.deprn_rate,
         txlb.depreciation_id,
         txlb.asset_number
  from   okl_txl_assets_b txlb,
         okc_k_lines_b    fa_cleb,
         okc_line_styles_b fa_lseb
  where  txlb.kle_id        = fa_cleb.id
  and    txlb.tal_type      = 'CRL'
  and    fa_cleb.cle_id     = p_cle_id
  and    fa_cleb.dnz_chr_id = p_chr_id
  and    fa_cleb.lse_id     = fa_lseb.id
  and    fa_lseb.lty_code   = 'FIXED_ASSET';

  l_corpbook_rec   l_corpbook_csr%ROWTYPE;

  --cursor to get model line details
  CURSOR l_modelline_csr(p_cle_id   in number,
                         p_chr_id   in number) IS
  select model_cleb.id   model_cle_id,
         model_cim.id    model_cim_id
  from   okc_k_items       model_cim,
         okc_k_lines_b     model_cleb,
         okc_line_styles_b model_lseb
  where  model_cim.cle_id       =  model_cleb.id
  and    model_cim.dnz_chr_id   = model_cleb.dnz_chr_id
  and    model_cleb.cle_id      = p_cle_id
  and    model_cleb.dnz_chr_id  = p_chr_id
  and    model_cleb.lse_id      = model_lseb.id
  and    model_lseb.lty_code    = 'ITEM';

  l_modelline_rec l_modelline_csr%ROWTYPE;

  l_clev_rec      clev_rec_type;
  l_klev_rec      klev_rec_type;
  lx_clev_rec     clev_rec_type;
  lx_klev_rec     klev_rec_type;
  l_cimv_rec      cimv_rec_type;
  lx_cimv_rec     cimv_rec_type;

  l_dt_clev_rec      clev_rec_type;
  l_dt_klev_rec      klev_rec_type;
  lx_dt_clev_rec     clev_rec_type;
  lx_dt_klev_rec     klev_rec_type;


  --cursor to get any existing addons for deletion
  CURSOR l_addonline_csr (p_cle_id  in number,
                          p_chr_id  in number) IS

  select addon_cleb.id     addon_cle_id
  from   okc_k_lines_b     addon_cleb,
         okc_line_styles_b addon_lseb,
         okc_k_lines_b     model_cleb,
         okc_line_styles_b model_lseb
  where  addon_cleb.cle_id      = model_cleb.id
  and    addon_cleb.dnz_chr_id  = model_cleb.dnz_chr_id
  and    addon_cleb.lse_id      = addon_lseb.id
  and    addon_lseb.lty_code    = 'ADD_ITEM'
  and    model_cleb.cle_id      = p_cle_id
  and    model_cleb.dnz_chr_id  = p_chr_id
  and    model_cleb.lse_id      = model_lseb.id
  and    model_lseb.lty_code    = 'ITEM';

  l_addonline_id    OKC_K_LINES_B.ID%TYPE;

  --cursor to get any existing subsidies for deletion
  CURSOR l_subsidyline_csr (p_cle_id    in number,
                        p_chr_id    in number) IS
  select subsidy_cleb.id  subsidy_cle_id
  from   okc_k_lines_b    subsidy_cleb,
         okc_line_styles_b subsidy_lseb
  where  subsidy_cleb.cle_id   = p_cle_id
  and    subsidy_cleb.dnz_chr_id = p_chr_id
  and    subsidy_cleb.lse_id     = subsidy_lseb.id
  and    subsidy_lseb.lty_code   = 'SUBSIDY';

  l_subsidyline_id  OKC_K_LINES_B.ID%TYPE;


  --cursor to get party roles attached to copied line
  CURSOR l_cpl_csr (p_cle_id   in  number,
                    p_chr_id   in  number) IS
  select cplb.id
  from   okc_k_party_roles_b cplb
  where  cle_id             = p_cle_id
  and    dnz_chr_id         = p_chr_id;

  l_cpl_id       OKC_K_PARTY_ROLES_B.ID%TYPE;
  l_cplv_rec     OKL_OKC_MIGRATION_PVT.cplv_rec_type;


  --cursor to get supplier invoice details
  CURSOR l_sid_csr (p_cle_id in NUMBER) IS
  select sid.id
  from   okl_supp_invoice_dtls sid
  where  cle_id   = p_cle_id;

  l_sid_id       OKL_SUPP_INVOICE_DTLS.ID%TYPE;
  l_sidv_rec     OKL_SUPP_INVOICE_DTLS_PUB.sidv_rec_type;

  --cursor to get item sources for fa and ib lines
  CURSOR   l_orig_cim_csr(p_orig_cle_id in number) IS
  SELECT   object1_id1,
           object1_id2
  from     okc_k_items
  WHERE    cle_id     = p_orig_cle_id;

  l_orig_cim_rec   l_orig_cim_csr%ROWTYPE;

  --cursor to get corresponding cim record fro fa and ib lines
  CURSOR   l_cim_csr (p_cle_id in number, p_chr_id in number) IS
  SELECT   id
  from     okc_k_items
  WHERE    cle_id     = p_cle_id
  And      dnz_chr_id = p_chr_id;

  l_cim_id        OKC_K_ITEMS.ID%TYPE;
  l_upd_cimv_rec  OKL_OKC_MIGRATION_PVT.cimv_rec_type;
  lx_upd_cimv_rec OKL_OKC_MIGRATION_PVT.cimv_rec_type;


  --Cursor to get hdr date
  CURSOR l_hdr_csr (p_chr_id IN NUMBER) is
  SELECT chrb.start_date,
         chrb.end_date,
         chrb.sts_code,
         --Bug# 4869443
         chrb.orig_system_source_code,
         --Bug# 6328924
         khr.legal_entity_id
  FROM   okc_k_headers_b chrb,
         okl_k_headers khr
  WHERE  chrb.id  = p_chr_id
  AND    khr.id   = chrb.id;

  l_hdr_rec    l_hdr_csr%ROWTYPE;

  --Bug : 3569441
  --cursor to get all the tax books
  CURSOR l_taxbook_csr(p_tal_id in number) is
  select txdb.tax_book,
         txdb.id
  from   okl_txd_assets_b txdb
  where  txdb.tal_id      = p_tal_id;

  l_taxbook_rec l_taxbook_csr%ROWTYPE;

  --Bug# 3950089: Fetch NBV using FA apis
  /*
  --cursor to get nbv for each book
  CURSOR l_nbv_csr (p_book_type_code varchar2,
                    p_asset_id       number) IS
  Select (fb.cost - fds.deprn_reserve) nbv
  from   fa_books          fb,
         fa_deprn_periods  fdp,
         fa_deprn_summary  fds
  where  fb.book_type_code  = p_book_type_code
  and    fb.asset_id        = p_asset_id
  and    fb.transaction_header_id_out is null
  and    fdp.book_type_code = fb.book_type_code
  and    fdp.period_close_date is null
  and    fds.book_type_code = fb.book_type_code
  and    fds.asset_id       = fb.asset_id
  and    fds.period_counter = (fdp.period_counter - 1);
  */

  l_nbv NUMBER;

  l_talv_rec       talv_rec_type;
  lx_talv_rec      talv_rec_type;
  l_txdv_rec       txdv_rec_type;
  lx_txdv_rec      txdv_rec_type;
  --END BUG# : 3569441

  --Bug# 3631094 : cursor to get category book defaults
  Cursor l_defaults_csr (p_book in varchar2,
                         p_cat  in number,
                         p_date in date) is
  select fcb.LIFE_IN_MONTHS,
         fcb.DEPRN_METHOD,
         fcb.ADJUSTED_RATE,
         fcb.BASIC_RATE
  from   FA_CATEGORY_BOOK_DEFAULTS fcb
  where  fcb.book_type_code  = p_book
  and    fcb.category_id     = p_cat
  and    p_date between fcb.start_dpis and nvl(fcb.end_dpis,p_date);

  l_defaults_rec l_defaults_csr%ROWTYPE;

  Cursor town_rul_csr (pchrid number) is
  Select rule_information1 tax_owner,
         id
  From   okc_rules_b rul
  where  rul.dnz_chr_id = pchrid
  and    rul.rule_information_category = 'LATOWN'
  and    nvl(rul.STD_TEMPLATE_YN,'N')  = 'N';

  l_town_rul      okc_rules_b.rule_information1%TYPE;
  l_town_rul_id   okc_rules_b.id%TYPE;

  l_rep_asset_book       okl_txl_assets_b.corporate_book%TYPE;
  l_rep_asset_book_done  varchar2(1);
  l_rep_pdt_id           number;
  l_tax_owner            varchar2(30);
  l_rep_deal_type        okl_k_headers.deal_type%TYPE;
  l_multi_gaap_yn        varchar2(1);
  l_adjust_asset_to_zero varchar2(1);
  l_deal_type            okl_k_headers.deal_type%TYPE;

  l_mg_txdv_rec       txdv_rec_type;
  lx_mg_txdv_rec      txdv_rec_type;
  l_corp_nbv          number;
  l_pending_trx_yn    varchar2(1);

  --cursor to get asset number
  cursor l_Asset_no_csr(p_asset_id in number) is
  select asset_number
  from   fa_additions
  where  asset_id = p_asset_id;

  l_asset_number  fa_additions.asset_number%TYPE;
  l_mg_txd_id     okl_txd_assets_b.id%TYPE;
  --Bug# 3631094

    --Bug# 3783518 :
    CURSOR l_chk_rbk_csr (p_chr_id in NUMBER) is
    select 'Y'
    from   okc_k_headers_b chrb
    where  nvl(chrb.orig_system_source_code,'XXXX') = 'OKL_REBOOK'
    and    chrb.id   = p_chr_id;

    l_rbk_yn  varchar2(1);
    --Bug# 3783518 :

    --Bug# 4558486
    l_kplv_rec               OKL_K_PARTY_ROLES_PVT.kplv_rec_type;

    --Bug# 4869443
    l_icx_date_format  varchar2(240);
    l_termination_date varchar2(240);
    l_k_start_date     varchar2(240);
    --Bug# 4869443
  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --------------------------------
      --Bug# 3783518 : Check if it is a rebook. New asset should not be added on rebook of a rlease asset contract
      --------------------------------
      l_rbk_yn := 'N';
      open l_chk_rbk_csr(p_chr_id  => p_chr_id);
      fetch l_chk_rbk_csr into l_rbk_yn;
      if l_chk_rbk_csr%NOTFOUND then
         null;
      end if;
      close l_chk_rbk_csr;

      If l_rbk_yn = 'Y' then
           OKL_API.set_message(
                                p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_REL_ASSET_RBK_NEW_AST_ADD');
           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;
      ------------------
      --end Bug# 3783518
      ------------------
      --------------------------------
      --0. Check if off-lease processing is not going on
      -------------------------------

      ---------------------
      --bug# 4869443
      ---------------------
      open l_hdr_csr (p_chr_id => p_chr_id);
      Fetch l_hdr_csr into l_hdr_rec;
      close l_hdr_csr;

      l_pending_trx_yn := 'N';
      check_off_lease_trx
                            (p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_asset_id      => p_asset_id,
                             x_pending_trx_yn => l_pending_trx_yn);
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      If l_pending_trx_yn = 'Y' then

          open l_asset_no_csr(p_asset_id => p_asset_id);
          fetch l_asset_no_csr into l_asset_number;
          if l_asset_no_csr%NOTFOUND then
              null;
          end if;
          close l_asset_no_csr;

          OKL_API.set_message(
                                p_app_name     => G_APP_NAME,
                                p_msg_name     => 'OKL_LA_OFF_LEASE_TRX',
                                p_token1       => 'ASSET_NUMBER',
                                p_token1_value => l_asset_number);
           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE OKL_API.G_EXCEPTION_ERROR;

      End If;


      ------------------------
      --1. get the original asset id
      ------------------------
      Open l_orig_ast_csr (p_asset_id => p_asset_id);
      Fetch l_orig_ast_csr into l_orig_ast_rec;
      If l_orig_ast_csr%NOTFOUND then
          --raise error: Unable to fetch data for asset to release
          --from the old contract
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LA_RELEASE_AST_DTLS');
         RAISE Okl_Api.G_EXCEPTION_ERROR; -- rmunjulu bug 6805958
      End If;
      Close l_orig_ast_csr;


      --Bug# 4869443
      If nvl(l_hdr_rec.orig_system_source_code,OKL_API.G_MISS_CHAR) <> 'OKL_RELEASE' then --is a release asset case
          If (l_hdr_rec.start_date <= l_orig_ast_rec.date_terminated) then
              -- Raise Error: start date of the contract should not be less than or equal to termination
              -- date of the asset.
              l_icx_date_format := nvl(fnd_profile.value('ICX_DATE_FORMAT_MASK'),'DD-MON-RRRR');

              l_termination_date := to_char(l_orig_ast_rec.date_terminated,l_icx_date_format);
              l_k_start_date := to_char(l_hdr_rec.start_date,l_icx_date_format);

              open l_asset_no_csr(p_asset_id => p_asset_id);
              fetch l_asset_no_csr into l_asset_number;
              if l_asset_no_csr%NOTFOUND then
                  null;
              end if;
              close l_asset_no_csr;

              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_RELEASE_AST_TRMN_DATE',
                                  p_token1       => 'TERMINATION_DATE',
                                  p_token1_value => l_termination_date,
                                  p_token2       => 'ASSET_NUMBER',
                                  p_token2_value => l_asset_number,
                                  p_token3       => 'CONTRACT_START_DATE',
                                  p_token3_value => l_k_start_date);
              RAISE Okl_Api.G_EXCEPTION_ERROR; -- rmunjulu bug 6805958 changed to OKL_API from OKC_API
          End If;

          --Bug# 6328924
          If (l_hdr_rec.legal_entity_id <> l_orig_ast_rec.legal_entity_id) then
              -- Raise Error: The legal entity associated with Asset must be the same as
              --              the legal entity associated with the contract

              open l_asset_no_csr(p_asset_id => p_asset_id);
              fetch l_asset_no_csr into l_asset_number;
              if l_asset_no_csr%NOTFOUND then
                  null;
              end if;
              close l_asset_no_csr;

              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LA_RELEASE_ASSET_LGL_ENTY',
                                  p_token1       => 'ASSET_NUMBER',
                                  p_token1_value => l_asset_number);
              RAISE Okl_Api.G_EXCEPTION_ERROR;
          End If;

      End If;
      --Bug# 4869443

      --------------------------
      --2. copy asset line
      -------------------------
      OKL_COPY_ASSET_PUB.copy_asset_lines
                          (p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           p_from_cle_id        => l_orig_ast_rec.finasst_id,
                           p_to_cle_id          => OKL_API.G_MISS_NUM ,
                           p_to_chr_id          => p_chr_id,
                           p_to_template_yn     => 'N',
                           p_copy_reference     => 'COPY',
                           p_copy_line_party_yn => 'N',
                           p_renew_ref_yn       => 'N',
                           p_trans_type         => 'CRL',
                           x_cle_id             => l_new_finasst_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      ---------------------------
      --3. delete addon lines
      --------------------------
      Open l_addonline_csr(p_cle_id => l_new_finasst_id,
                           p_chr_id => p_chr_id);
      Loop
          Fetch l_addonline_csr into l_addonline_id;
          Exit when l_addonline_csr%NOTFOUND;
          OKL_CONTRACT_PUB.delete_contract_line
                           (p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_line_id            => l_addonline_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
      End Loop;
      Close l_addonline_csr;

      -----------------------------
      --4.delete subsidy lines
      ----------------------------
      Open l_subsidyline_csr (p_cle_id => l_new_finasst_id,
                              p_chr_id => p_chr_id);
      Loop
           Fetch l_subsidyline_csr into l_subsidyline_id;
           Exit when l_subsidyline_csr%NOTFOUND;
           OKL_CONTRACT_PUB.delete_contract_line
                           (p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_line_id            => l_subsidyline_id);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;
      End Loop;
      Close l_subsidyline_csr;


      ---------------------------------------------------
      --5. Delete the rules associated with original line
      --   Update contract header dates on to lines
      --   Plug in asset and ib ids
      --   Delete Parties
      --   Delete supplier invoice details
      --------------------------------------------------
      ---
      --Bug# 4869443 : cursor open moved up
      --
      --open l_hdr_csr (p_chr_id => p_chr_id);
      --Fetch l_hdr_csr into l_hdr_rec;
      --close l_hdr_csr;

      open l_lines_csr(p_from_cle_id => l_new_finasst_id);
      Loop
          Fetch l_lines_csr into l_lines_rec;
          Exit when l_lines_csr%NOTFOUND;

          --update line start and end dates
          l_dt_clev_rec.id         := l_lines_rec.id;
          l_dt_klev_rec.id         := l_lines_rec.id;
          l_dt_clev_rec.start_date := l_hdr_rec.start_date;
          l_dt_clev_rec.end_date   := l_hdr_rec.end_date;
          l_dt_clev_rec.sts_code   := l_hdr_rec.sts_code;

          okl_contract_pub.update_contract_line
                           (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_clev_rec       => l_dt_clev_rec,
                            p_klev_rec       => l_dt_klev_rec,
                            x_clev_rec       => lx_dt_clev_rec,
                            x_klev_rec       => lx_dt_klev_rec);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          END IF;


          --plug in asset and ib ids
          Open l_orig_cim_csr(p_orig_cle_id => l_lines_rec.orig_system_id1);
          Fetch l_orig_cim_csr into l_orig_cim_rec;
          If l_orig_cim_csr%NOTFOUND then
              Null;
          Else
              Open l_cim_csr(p_cle_id => l_lines_rec.id, p_chr_id => p_chr_id);
              Fetch l_cim_csr into l_cim_id;
              If l_cim_csr%NOTFOUND then
                  NULL;
              Else

                  l_upd_cimv_rec.id := l_cim_id;
                  l_upd_cimv_rec.object1_id1 := l_orig_cim_rec.object1_id1;
                  l_upd_cimv_rec.object1_id2 := l_orig_cim_rec.object1_id2;

                  OKL_OKC_MIGRATION_PVT.update_contract_item
                           (p_api_version        => p_api_version,
                            p_init_msg_list      => p_init_msg_list,
                            x_return_status      => x_return_status,
                            x_msg_count          => x_msg_count,
                            x_msg_data           => x_msg_data,
                            p_cimv_rec           => l_upd_cimv_rec,
                            x_cimv_rec           => lx_upd_cimv_rec);

                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  END IF;
              End If;
              Close l_cim_csr;
          End If;
          Close l_orig_cim_csr;

          --Get rule groups associated with each line
          Open l_rgp_csr(p_cle_id => l_lines_rec.id, p_chr_id => p_chr_id);
          Loop
              Fetch l_rgp_csr into l_rgp_id;
              Exit when l_rgp_csr%NOTFOUND;
              --delete the rule group instance
              l_rgpv_rec.id := l_rgp_id;
              OKL_RULE_PUB.delete_rule_group
                           (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_rgpv_rec       => l_rgpv_rec );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;
          End Loop;
          Close l_rgp_csr;

          --get supplier invoice details linked with each line
          Open  l_sid_csr (p_cle_id => l_lines_rec.id);
          Loop
              Fetch l_sid_csr into l_sid_id;
              Exit when l_sid_csr%NOTFOUND;
              --delete sidv rec
              l_sidv_rec.id := l_sid_id;
              OKL_SUPP_INVOICE_DTLS_PUB.delete_sup_inv_dtls
                          (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_sidv_rec       => l_sidv_rec );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;
          End Loop;
          Close l_sid_csr;

          --get party roles linked with each line
          Open  l_cpl_csr (p_cle_id => l_lines_rec.id, p_chr_id => p_chr_id);
          Loop
              Fetch l_cpl_csr into l_cpl_id;
              Exit when l_cpl_csr%NOTFOUND;
              --delete cplv rec
              l_cplv_rec.id := l_cpl_id;
              --Bug# 4558486: Changed call to okl_k_party_roles_pvt api
              --              to delete records in tables
              --              okc_k_party_roles_b and okl_k_party_roles
              /*
              OKL_OKC_MIGRATION_PVT.delete_k_party_role
                          ( p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_cplv_rec       => l_cplv_rec );
              */
              l_kplv_rec.id := l_cplv_rec.id;
              OKL_K_PARTY_ROLES_PVT.delete_k_party_role
                          ( p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_cplv_rec       => l_cplv_rec,
                            p_kplv_rec       => l_kplv_rec);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              END IF;
          End Loop;
          Close l_cpl_csr;
      End Loop;
      close l_lines_csr;

      -------------------------------------------------------
      --6. Update the costs and salvage value from FA
      ------------------------------------------------------
      Open l_corpbook_csr(p_cle_id => l_new_finasst_id,
                          p_chr_id => p_chr_id);
      Fetch l_corpbook_csr into l_corpbook_rec;
      If l_corpbook_csr%NOTFOUND then
          --error
          NULL;
      End If;
      Close l_corpbook_csr;

      --Bug# 3950089: Fetch NBV using FA apis
      /*
      --BUG# : 3569441
      l_nbv := Null;
      Open l_nbv_csr(p_book_type_code => l_corpbook_rec.corporate_book,
                     p_asset_id       => p_asset_id);
      Fetch l_nbv_csr into l_nbv;
      If l_nbv_csr%NOTFOUND then
          null;
      End If;
      Close l_nbv_csr;
      */

      l_nbv := Null;
      get_nbv(p_api_version     => p_api_version,
              p_init_msg_list   => p_init_msg_list,
	        x_return_status   => x_return_status,
              x_msg_count       => x_msg_count,
              x_msg_data        => x_msg_data,
              p_asset_id        => p_asset_id,
              p_book_type_code  => l_corpbook_rec.corporate_book,
              p_chr_id          => p_chr_id,
              p_release_date    => l_hdr_rec.start_date,
              x_nbv             => l_nbv);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF l_nbv is not NULL then
          --update okl_txl_Assets
          l_talv_rec.id                    := l_corpbook_rec.id;
          l_talv_rec.DEPRECIATION_COST     := l_nbv;
          l_talv_rec.ORIGINAL_COST         := l_nbv;
          l_corp_nbv                       := l_nbv;

          Update_asset_lines(
            p_api_version    =>  p_api_version,
            p_init_msg_list  =>  p_init_msg_list,
            x_return_status  =>  x_return_status,
            x_msg_count      =>  x_msg_count,
            x_msg_data       =>  x_msg_data,
            p_talv_rec       =>  l_talv_rec,
            x_talv_rec       =>  lx_talv_rec);

          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
             RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      END IF;
      --BUG# :END 3569441

      Open l_modelline_csr (p_cle_id => l_new_finasst_id,
                            p_chr_id => p_chr_id);
      Fetch l_modelline_csr into l_modelline_rec;
      If l_modelline_csr%NOTFOUND then
          --error
          NULL;
      End If;
      Close l_modelline_csr;

      l_clev_rec.id                  := l_modelline_rec.model_cle_id;
      l_klev_rec.id                  := l_modelline_rec.model_cle_id;
      --BUG# : 3569441
      If l_nbv is NULL then
          l_clev_rec.price_unit          := (l_corpbook_rec.depreciation_cost/l_corpbook_rec.current_units);
      ElsIf l_nbv is NOT NULL then
          l_clev_rec.price_unit          := (l_nbv/l_corpbook_rec.current_units);
      End If;
      --BUG# End : 3569441
      l_cimv_rec.id                  := l_modelline_rec.model_cim_id;
      l_cimv_rec.number_of_items     := l_corpbook_rec.current_units;

      okl_contract_pub.update_contract_line
                           (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_clev_rec       => l_clev_rec,
                            p_klev_rec       => l_klev_rec,
                            x_clev_rec       => lx_clev_rec,
                            x_klev_rec       => lx_klev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      okl_okc_migration_pvt.update_contract_item
                           (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_cimv_rec       => l_cimv_rec,
                            x_cimv_rec       => lx_cimv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      --update financial asset line for OEC and residual value
      l_clev_rec.id                  := l_new_finasst_id;
      l_klev_rec.id                  := l_new_finasst_id;
      l_clev_rec.price_unit          := OKL_API.G_MISS_NUM;
      l_klev_rec.residual_percentage := l_corpbook_rec.percent_salvage_value;
      l_klev_rec.residual_value      := l_corpbook_rec.salvage_value;
      --BUG : 3569441
      l_klev_rec.oec                 := l_nbv;
      --l_klev_rec.oec                 := l_corpbook_rec.depreciation_cost;

      okl_contract_pub.update_contract_line
                           (p_api_version    => p_api_version,
                            p_init_msg_list  => p_init_msg_list,
                            x_return_status  => x_return_status,
                            x_msg_count      => x_msg_count,
                            x_msg_data       => x_msg_data,
                            p_clev_rec       => l_clev_rec,
                            p_klev_rec       => l_klev_rec,
                            x_clev_rec       => lx_clev_rec,
                            x_klev_rec       => lx_klev_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      END IF;

      --Bug# 3631094 : Creation of reporting tax book
      l_rep_asset_book      :=  OKL_SYSTEM_PARAMS_ALL_PUB.get_system_param_value(OKL_SYSTEM_PARAMS_ALL_PUB.G_RPT_PROD_BOOK_TYPE_CODE);
      l_rep_Asset_book_done := 'N';
      --BUG# : 3569441
      OPEN l_taxbook_csr(p_tal_id => l_corpbook_rec.id);
      Loop
          Fetch l_taxbook_csr into l_taxbook_rec;
          Exit when l_taxbook_csr%NOTFOUND;
          If l_taxbook_rec.tax_book = nvl(l_rep_Asset_book,OKL_API.G_MISS_CHAR) then
              l_rep_Asset_book_done := 'Y';
              l_mg_txd_id           := l_taxbook_rec.id;
          End If;
          --Bug# 3950089: Fetch NBV using FA apis
          /*
          l_nbv := NULL;
          Open l_nbv_csr(p_book_type_code => l_taxbook_rec.tax_book,
                         p_asset_id       => p_asset_id);
          Fetch l_nbv_csr into l_nbv;
          If l_nbv_csr%NOTFOUND then
              NULL;
          End If;
          Close l_nbv_csr;
          */

          l_nbv := Null;
          get_nbv(p_api_version     => p_api_version,
                  p_init_msg_list   => p_init_msg_list,
	            x_return_status   => x_return_status,
                  x_msg_count       => x_msg_count,
                  x_msg_data        => x_msg_data,
                  p_asset_id        => p_asset_id,
                  p_book_type_code  => l_taxbook_rec.tax_book,
                  p_chr_id          => p_chr_id,
                  p_release_date    => l_hdr_rec.start_date,
                  x_nbv             => l_nbv);

          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          If l_nbv is NOT NULL then
              --update okl_txd_Assets_b
              l_txdv_rec.id      := l_taxbook_rec.id;
              l_txdv_rec.cost    := l_nbv;
              OKL_TXD_ASSETS_PUB.UPDATE_TXD_ASSET_DEF
                                 (
                                 p_api_version    =>  p_api_version,
                                 p_init_msg_list  =>  p_init_msg_list,
                                 x_return_status  =>  x_return_status,
                                 x_msg_count      =>  x_msg_count,
                                 x_msg_data       =>  x_msg_data,
                                 p_adpv_rec       =>  l_txdv_rec,
                                 x_adpv_rec       =>  lx_txdv_rec);

              IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_ERROR;
              END IF;
          END IF;
      End Loop;
      Close l_taxbook_csr;
      --BUG# : END 3569441

      --Bug# 3631094 :
      Get_Pdt_Params (p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      p_chr_id        => p_chr_id,
                      x_rep_pdt_id    => l_rep_pdt_id,
                      x_tax_owner     => l_tax_owner,
                      x_deal_type     => l_deal_type,
                      x_rep_deal_type => l_rep_deal_type);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      If l_tax_owner is null then
         Open town_rul_csr(pchrid => p_chr_id);
         Fetch town_rul_csr into l_town_rul,
                                 l_town_rul_id;
         If town_rul_csr%NOTFOUND Then
            OKC_API.set_message(
                            p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'Tax Owner');
             x_return_status := OKC_API.G_RET_STS_ERROR;
             RAISE OKL_API.G_EXCEPTION_ERROR;
         Else
             l_tax_owner := rtrim(ltrim(l_town_rul,' '),' ');
          End If;
      Close town_rul_csr;
      End If;

      l_Multi_GAAP_YN := 'N';
      l_adjust_asset_to_zero := 'N';
      --checks wheter Multi-GAAP processing needs tobe done
      If l_rep_pdt_id is not NULL Then
      --Bug 7708944. SGIYER 01/15/2009.
      -- Implemented MG changes based on PM recommendation.
        l_Multi_GAAP_YN := 'Y';
/*
         If l_deal_type = 'LEASEOP' and
         nvl(l_rep_deal_type,'X') = 'LEASEOP' and
         nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
         End If;

         If l_deal_type in ('LEASEDF','LEASEST') and
         nvl(l_rep_deal_type,'X') = 'LEASEOP' and
         nvl(l_tax_owner,'X') = 'LESSOR' Then
             l_Multi_GAAP_YN := 'Y';
         End If;

         If l_deal_type in ('LEASEDF','LEASEST') and
         nvl(l_rep_deal_type,'X') = 'LEASEOP' and
         nvl(l_tax_owner,'X') = 'LESSEE' Then
             l_Multi_GAAP_YN := 'Y';
         End If;

         If l_deal_type = 'LOAN' and
         nvl(l_rep_deal_type,'X') = 'LEASEOP' and
         nvl(l_tax_owner,'X') = 'LESSEE' Then
             l_Multi_GAAP_YN := 'Y';
         End If;
*/
         -- If the reporting product is DF/ST lease, the asset should
         -- be created and written to zero in the reporting book.

      --Bug 7708944. SGIYER 01/15/2009.
      -- Implemented MG changes based on PM recommendation.
         If l_deal_type = 'LEASEOP' and
         nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
         nvl(l_tax_owner,'X') = 'LESSOR' Then
             --l_Multi_GAAP_YN := 'Y';
             l_adjust_asset_to_zero := 'Y';
         End If;

         If l_deal_type in ('LEASEDF','LEASEST') and
         nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
         nvl(l_tax_owner,'X') = 'LESSOR' Then
             --l_Multi_GAAP_YN := 'Y';
             l_adjust_asset_to_zero := 'Y';
         End If;

         If l_deal_type in ('LEASEDF','LEASEST') and
         nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST') and
         nvl(l_tax_owner,'X') = 'LESSEE' Then
             --l_Multi_GAAP_YN := 'Y';
             l_adjust_asset_to_zero := 'Y';
         End If;
      End If;

      --Bug 7708944. SGIYER 01/15/2009.
      -- Implemented MG changes based on PM recommendation.
      If l_Multi_GAAP_YN = 'Y' and nvl(l_rep_deal_type,'X') in ('LEASEDF','LEASEST','LEASEOP') then
          If nvl(l_rep_Asset_book_done,OKL_API.G_MISS_CHAR) = 'N' then
              l_mg_txdv_rec.tal_id       :=  l_corpbook_rec.id;
              l_mg_txdv_rec.asset_number :=  l_corpbook_rec.asset_number;
              l_mg_txdv_rec.tax_book     :=  l_rep_Asset_book;
              --If nvl(l_adjust_asset_to_zero,OKL_API.G_MISS_CHAR) = 'Y' then
              --l_mg_txdv_rec.cost := 0;
              --ElsIf nvl(l_adjust_asset_to_zero,OKL_API.G_MISS_CHAR) = 'N' then
              l_mg_txdv_rec.cost := l_corp_nbv;
              --End If;
              --get defaults from category books
              open l_defaults_csr (p_book => l_rep_asset_book,
                                   p_cat  => l_corpbook_rec.depreciation_id,
                                   p_date => l_corpbook_rec.in_service_date);
              Fetch l_defaults_csr into l_defaults_rec;

              -- Bug# 5028512 - Modified - Start
              If l_defaults_csr%NOTFOUND then
                  l_mg_txdv_rec.deprn_method_tax    := l_corpbook_rec.deprn_method;
                  l_mg_txdv_rec.life_in_months_tax  := l_corpbook_rec.life_in_months;
                   -- Depreciation Rates no longer needs to be adjusted by 100
                   --l_mg_txdv_rec.deprn_rate_tax      := (l_corpbook_rec.deprn_rate * 100);
                   l_mg_txdv_rec.deprn_rate_tax      := l_corpbook_rec.deprn_rate;
              Else
                  l_mg_txdv_rec.deprn_method_tax    := l_defaults_rec.deprn_method;
                  l_mg_txdv_rec.life_in_months_tax  := l_defaults_rec.life_in_months;
                  -- Depreciation Rates no longer needs to be adjusted by 100
                  -- l_mg_txdv_rec.deprn_rate_tax      := (l_defaults_rec.adjusted_rate * 100);
                  l_mg_txdv_rec.deprn_rate_tax      := l_defaults_rec.adjusted_rate;
              End If;
              -- Bug# 5028512 - Modified - End

              --Create transaction for Multi-Gaap Book
              OKL_TXD_ASSETS_PUB.CREATE_TXD_ASSET_DEF
                                 (
                                 p_api_version    =>  p_api_version,
                                 p_init_msg_list  =>  p_init_msg_list,
                                 x_return_status  =>  x_return_status,
                                 x_msg_count      =>  x_msg_count,
                                 x_msg_data       =>  x_msg_data,
                                 p_adpv_rec       =>  l_mg_txdv_rec,
                                 x_adpv_rec       =>  lx_mg_txdv_rec);

              IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_ERROR;
              END IF;
           End If; -- if multi gaap asset book is not doen
       End If; --If l_mutigaap_yn
       x_cle_id:= l_new_finasst_id;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_Release_asset_Line;

  --Bug# 3533936:
  ----------------------------------------------------------
  --copy and sync line components from updated line with new
  --released asset id to new line
  --called from release asset line
  ---------------------------------------------------------
  PROCEDURE copy_updated_asset_components
            (p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_cle_id         IN  NUMBER,
             p_orig_cle_id    IN  NUMBER,
             p_chr_id         IN  NUMBER) IS

  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'COPY_UPDATED_ASSET';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to get rule groups attached to old line
  CURSOR l_rgp_csr(p_orig_cle_id in number,
                   p_chr_id  in number) is
  SELECT rgpb.id
  FROM   okc_rule_groups_b rgpb
  WHERE  rgpb.cle_id     = p_cle_id
  AND    rgpb.dnz_chr_id = p_chr_id;

  l_rgp_id   OKC_RULE_GROUPS_B.ID%TYPE;
  lx_rgp_id   OKC_RULE_GROUPS_B.ID%TYPE;

  --cursor to get party roles attached to old line
  CURSOR l_cpl_csr (p_orig_cle_id in number,
                    p_chr_id in number) is
  SELECT cplb.id,
         cplb.rle_code
  FROM   okc_k_party_roles_b cplb
  WHERE  cplb.cle_id     = p_orig_cle_id
  AND    cplb.dnz_chr_id = p_chr_id;

  l_cpl_rec l_cpl_csr%ROWTYPE;
  lx_cpl_id OKC_K_PARTY_ROLES_B.ID%TYPE;

  --cursor to get any covered asset lines where old line was referenced
  CURSOR l_lnk_ast_csr (p_orig_cle_id in NUMBER,
                        p_chr_id in NUMBER) is
  SELECT cim.id
  FROM   okc_k_items cim,
         okc_k_lines_b cleb,
         okc_line_styles_b lseb
  WHERE  cim.object1_id1   = to_char(p_orig_cle_id)
  AND    cim.object1_id2   = '#'
  AND    cim.jtot_object1_code = 'OKX_COVASST'
  AND    cim.cle_id            = cleb.id
  AND    cim.dnz_chr_id        = cleb.dnz_chr_id
  AND    cleb.dnz_chr_id       = p_chr_id
  AND    cleb.chr_id           is NULL
  AND    cleb.lse_id           = lseb.id
  AND    lseb.lty_code         in ('LINK_SERV_ASSET','LINK_FEE_ASSET','LINK_USAGE_ASSET');

  l_cim_id OKC_K_ITEMS.ID%TYPE;
  l_cimv_rec OKL_OKC_MIGRATION_PVT.cimv_rec_type;
  lx_cimv_rec OKL_OKC_MIGRATION_PVT.cimv_rec_type;

  --cursor to get information about SLH/SLL to sync back
  CURSOR l_slh_csr(p_cle_id      in number,
                   p_orig_cle_id in number,
                   p_chr_id      in number) IS
  SELECT

         RULSLH.ID,
         RULSLL.ID
  FROM   OKC_RULES_B       RULSLL_OLD,
         OKC_RULES_B       RULSLH_OLD,
         OKC_RULE_GROUPS_B RGPB_OLD,
         OKC_RULES_B       RULSLL,
         OKC_RULES_B       RULSLH,
         OKC_RULE_GROUPS_B RGPB
  WHERE  TO_CHAR(RULSLH_OLD.ID)               = NVL(RULSLL.OBJECT2_ID1,-99) --the new sll has old slh's id
  AND    RULSLH_OLD.OBJECT1_ID1               = RULSLH.OBJECT1_ID1   --stream type ids are same for old and new slh
  AND    RULSLL_OLD.RULE_INFORMATION_CATEGORY = 'LASLL'
  AND    RULSLL_OLD.DNZ_CHR_ID                = RGPB_OLD.DNZ_CHR_ID
  AND    RULSLL_OLD.RGP_ID                    = RGPB_OLD.ID
  AND    RULSLH_OLD.RULE_INFORMATION_CATEGORY = 'LASLH'
  AND    RULSLH_OLD.DNZ_CHR_ID                = RGPB_OLD.DNZ_CHR_ID
  AND    RULSLH_OLD.RGP_ID                    = RGPB_OLD.ID
  AND    TO_CHAR(RULSLH_OLD.ID)               = RULSLL_OLD.OBJECT2_ID1
  AND    RGPB_OLD.RGD_CODE                    = 'LALEVL'
  AND    RGPB_OLD.CHR_ID                      IS NULL
  AND    RGPB_OLD.DNZ_CHR_ID                  = p_chr_id
  AND    RGPB_OLD.CLE_ID                      = p_orig_cle_id
  --
  AND    RULSLL.RULE_INFORMATION_CATEGORY = 'LASLL'
  AND    RULSLL.DNZ_CHR_ID                = RGPB.DNZ_CHR_ID
  AND    RULSLL.RGP_ID                    = RGPB.ID
  AND    RULSLH.RULE_INFORMATION_CATEGORY = 'LASLH'
  AND    RULSLH.DNZ_CHR_ID                = RGPB.DNZ_CHR_ID
  AND    RULSLH.RGP_ID                    = RGPB.ID
  AND    TO_CHAR(RULSLH.ID)              <> NVL(RULSLL.OBJECT2_ID1,-99)
  AND    RGPB.RGD_CODE                    = 'LALEVL'
  AND    RGPB.CHR_ID                      IS NULL
  AND    RGPB.DNZ_CHR_ID                  = p_chr_id
  AND    RGPB.CLE_ID                      = p_cle_id;

  l_slh_id     OKC_RULES_B.ID%TYPE;
  l_sll_id     OKC_RULES_B.ID%TYPE;

  l_rulv_rec   OKL_RULE_PUB.rulv_rec_type;
  lx_rulv_rec  OKL_RULE_PUB.rulv_rec_type;

  --Fetch any new subsidy associated to old line
  Cursor l_subsidy_csr (p_orig_cle_id in number,
                        p_chr_id      in number) IS
  Select sub_kle.subsidy_id              subsidy_id,
         sub_cleb.id                     subsidy_cle_id,
         subb.name                       name,
         subt.description                description,
         sub_kle.amount                  amount,
         sub_kle.subsidy_override_amount subsidy_override_amount,
         sub_cleb.dnz_chr_id             dnz_chr_id,
         sub_cleb.cle_id                 asset_cle_id,
         sub_cplb.id                     cpl_id,
         pov.vendor_id                   vendor_id,
         pov.vendor_name                 vendor_name
  from
         okl_subsidies_b        subb,
         okl_subsidies_tl       subt,
         po_vendors             pov,
         okc_k_party_roles_b    sub_cplb,
         okl_k_lines            sub_kle,
         okc_k_lines_b          sub_cleb,
         okc_line_styles_b      sub_lseb
  where  subt.id                     =  subb.id
  and    subt.language               = userenv('LANG')
  and    subb.id                     = sub_kle.subsidy_id
  and    pov.vendor_id               = to_number(sub_cplb.object1_id1)
  and    sub_cplb.object1_id2        =   '#'
  and    sub_cplb.jtot_object1_code  = 'OKX_VENDOR'
  and    sub_cplb.rle_code           = 'OKL_VENDOR'
  and    sub_cplb.cle_id             = sub_cleb.id
  and    sub_cplb.dnz_chr_id         = sub_cleb.dnz_chr_id
  and    sub_kle.id                  = sub_cleb.id
  and    sub_cleb.cle_id             = p_orig_cle_id
  and    sub_cleb.dnz_chr_id         = p_chr_id
  and    sub_cleb.sts_code           <> 'ABANDONED'
  and    sub_cleb.lse_id             = sub_lseb.id
  and    sub_lseb.lty_code           = 'SUBSIDY';

  l_subsidy_rec  l_subsidy_csr%ROWTYPE;

  l_asb_rec      okl_asset_subsidy_pvt.asb_rec_type;
  lx_asb_rec      okl_asset_subsidy_pvt.asb_rec_type;

  --Fetch refund details records against the old subsidy line
  Cursor l_subrfnd_csr (p_cpl_id in number) is
  Select ppyd.id
  from  okl_party_payment_dtls ppyd
  where ppyd.cpl_id  = p_cpl_id;

  l_ppyd_id       OKL_PARTY_PAYMENT_DTLS.ID%TYPE;

  l_srfvv_rec     OKL_SUBSIDY_RFND_DTLS_PVT.srfvv_rec_type;
  lx_srfvv_rec    OKL_SUBSIDY_RFND_DTLS_PVT.srfvv_rec_type;

  Begin
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --1. Copy rules from old line to new line
      open l_rgp_csr(p_orig_cle_id => p_orig_cle_id,
                     p_chr_id      => p_chr_id);
      Loop
          Fetch l_rgp_csr into l_rgp_id;
          Exit when l_rgp_csr%NOTFOUND;
          okl_copy_contract_pub.Copy_Rules
                  (p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_rgp_id         => l_rgp_id,
                   p_cle_id         => p_cle_id,
                   p_to_template_yn => 'N',
                   x_rgp_id         => lx_rgp_id);
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      End Loop;
      close l_rgp_csr;

      --2. Copy party roles from old line to new line
      open l_cpl_csr(p_orig_cle_id => p_orig_cle_id,
                     p_chr_id      => p_chr_id);
      Loop
          Fetch l_cpl_csr into l_cpl_rec;
          Exit when l_cpl_csr%NOTFOUND;
          okl_copy_contract_pub.copy_party_roles
                  (p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_cpl_id         => l_cpl_rec.id,
                   p_cle_id         => p_cle_id,
                   p_rle_code       => l_cpl_rec.rle_code,
                   x_cpl_id         => lx_cpl_id);
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      End Loop;
      close l_cpl_csr;

      --3. Relink covered asset lines
      Open l_lnk_ast_csr (p_orig_cle_id => p_orig_cle_id,
                          p_chr_id      => p_chr_id);
      Loop
          Fetch l_lnk_ast_csr into l_cim_id;
          Exit when l_lnk_ast_csr%NOTFOUND;
          l_cimv_rec.id       := l_cim_id;
          l_cimv_rec.object1_id1 := to_char(p_cle_id);
          OKL_OKC_MIGRATION_PVT.update_contract_item
                               (p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_cimv_rec      => l_cimv_rec,
                                x_cimv_rec      => lx_cimv_rec);
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      End Loop;
      Close l_lnk_ast_csr;

      --4. Relink SLH-SLL
      Open l_slh_csr (p_cle_id      => p_cle_id,
                      p_orig_cle_id => p_orig_cle_id,
                      p_chr_id      => p_chr_id
                     );
      Loop
          Fetch l_slh_csr into l_slh_id, l_sll_id;
          Exit when l_slh_csr%NOTFOUND;
          l_rulv_rec.id := l_sll_id;
          l_rulv_rec.object2_id1 := to_char(l_slh_id);
          OKL_RULE_PUB.update_rule
                 (p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_rulv_rec      => l_rulv_rec,
                  x_rulv_rec      => lx_rulv_rec);
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      End Loop;
      Close l_slh_csr;

      --5. Sync back any new subsidy that has been added
      Open l_subsidy_csr(p_orig_cle_id => p_orig_cle_id,
                         p_chr_id      => p_chr_id);
      Loop
          Fetch l_subsidy_csr into l_subsidy_rec;
          Exit when l_subsidy_csr%NOTFOUND;
          l_asb_rec.subsidy_id              := l_subsidy_rec.subsidy_id;
          l_asb_rec.name                    := l_subsidy_rec.name;
          l_asb_rec.description             := l_subsidy_rec.description;
          l_asb_rec.amount                  := l_subsidy_rec.amount;
          l_asb_rec.subsidy_override_amount := l_subsidy_rec.subsidy_override_amount;
          l_asb_rec.dnz_chr_id              := l_subsidy_rec.dnz_chr_id;
          l_asb_rec.asset_cle_id            := p_cle_id;
          l_asb_rec.vendor_id               := l_subsidy_rec.vendor_id;
          l_asb_rec.vendor_name             := l_asb_rec.vendor_name;

          OKL_ASSET_SUBSIDY_PVT.create_asset_subsidy
                 (p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_asb_rec       => l_asb_rec,
                  x_asb_rec       => lx_asb_rec);
          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;

          --update link to party payment details
          Open l_subrfnd_csr(p_cpl_id  => l_subsidy_rec.cpl_id);
          Fetch l_subrfnd_csr into l_ppyd_id;
          If l_subrfnd_csr%NOTFOUND then
              NULL;
          Else
              l_srfvv_rec.id := l_ppyd_id;
              l_srfvv_rec.cpl_id := lx_asb_rec.cpl_id;
              OKL_SUBSIDY_RFND_DTLS_PVT.update_refund_dtls
                 (p_api_version   => p_api_version,
                  p_init_msg_list => p_init_msg_list,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_srfvv_rec     => l_srfvv_rec,
                  x_srfvv_rec     => lx_srfvv_rec);
              IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
                  RAISE Okc_Api.G_EXCEPTION_ERROR;
              END IF;
          End If;
          Close l_subrfnd_csr;
      End Loop;
      Close l_subsidy_csr;


    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END copy_updated_asset_components;

  --Bug# 3533936:
  ------------------------------------------------------
  --update_release_asset_line called from
  --update_all_line
  -----------------------------------------------------

 PROCEDURE update_release_asset_line
            (p_api_version    IN  NUMBER,
             p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
             x_return_status  OUT NOCOPY VARCHAR2,
             x_msg_count      OUT NOCOPY NUMBER,
             x_msg_data       OUT NOCOPY VARCHAR2,
             p_asset_id       IN  VARCHAR2,
             p_chr_id         IN  NUMBER,
             p_clev_fin_id    IN  NUMBER,
             x_cle_id         OUT NOCOPY NUMBER) IS


  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'UPDATE_RELEASE_ASSET';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to find the existing asset id on release asset line
    cursor l_cim_fa_csr(p_fin_asst_id in number) is
    select
           fa_cim.object1_id1 asset_id,
           fa_cim.dnz_chr_id  chr_id
    from   okc_k_items fa_cim,
           okc_k_lines_b fa_cleb,
           okc_line_styles_b fa_lseb
    where  fa_cim.cle_id       = fa_cleb.id
    and    fa_cim.dnz_chr_id   = fa_cleb.dnz_chr_id
    and    fa_cleb.cle_id      = p_fin_asst_id
    and    fa_cleb.lse_id      = fa_lseb.id
    and    fa_lseb.lty_code    = 'FIXED_ASSET';

  l_asset_id okc_k_items.OBJECT1_ID1%TYPE;
  l_chr_id   okc_k_items.DNZ_CHR_ID%TYPE;

  --cursor to fetch all the lines
  CURSOR        l_lines_csr(p_from_cle_id in number) IS
    SELECT      level,
                id,
                chr_id,
                cle_id,
                dnz_chr_id,
                orig_system_id1
    FROM        okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_from_cle_id;

  l_lines_rec l_lines_csr%ROWTYPE;

  --bug# 3783518 : is asset number equal in case of rebook
  cursor l_chk_rbk_ast(p_cle_id in number, p_chr_id in number, p_asset_id number) is
 select 'N' change_flag,
        chrb.orig_system_source_code
  from   fa_additions_b    fab,
         okl_txl_assets_b  txlb,
         okc_k_lines_b     fa_cleb,
         okc_line_styles_b fa_lseb,
         okc_k_headers_b   chrb
  where  fab.asset_number   = txlb.asset_number
  and    fab.asset_id       = p_asset_id
  and    txlb.kle_id        = fa_cleb.id
  and    fa_cleb.dnz_chr_id = chrb.id
  and    fa_cleb.cle_id     = p_cle_id
  and    fa_cleb.lse_id     = fa_lseb.id
  and    fa_lseb.lty_code   = 'FIXED_ASSET'
  and    chrb.id            = p_chr_id
  and    chrb.orig_system_source_code = 'OKL_REBOOK';

  l_rbk_ast_change_yn varchar2(1);
  l_k_source          okc_k_headers_b.orig_system_source_code%TYPE;

  BEGIN
      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --------------------
      --Bug# 3783518
      --------------------
      for l_chk_rbk_rec in l_chk_rbk_ast(p_cle_id => p_clev_fin_id,
                                         p_chr_id => p_chr_id,
                                         p_asset_id => p_asset_id)
      Loop
          l_rbk_ast_change_yn := l_chk_rbk_rec.change_flag;
          l_k_source          := l_chk_rbk_rec.orig_system_source_code;
      end loop;

      If nvl(l_k_source,OKL_API.G_MISS_CHAR) = 'OKL_REBOOK' then
          If l_rbk_ast_change_yn    = 'Y' then
          --raise error : can not add new asset on a rebook
              OKL_API.set_message(
                                    p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_REL_ASSET_RBK_NEW_AST_ADD');
              x_return_status := OKC_API.G_RET_STS_ERROR;
              RAISE OKL_API.G_EXCEPTION_ERROR;
          ElsIf l_rbk_ast_change_yn = 'N' then
              x_cle_id  := p_clev_fin_id;

          End If;
      Else
      --------------------
      --End : Bug# 3783518
      --------------------
      If nvl(p_asset_id,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR then
          x_cle_id     := p_clev_fin_id;
      Else
          open l_cim_fa_csr(p_fin_asst_id => p_clev_fin_id);
          Fetch l_cim_fa_csr into l_asset_id, l_chr_id;
          If l_cim_fa_csr%NOTFOUND then
              --raise error : invalid line information
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => 'OKL_LLA_LINE_RECORD');
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          End If;
          close l_cim_fa_csr;
          If nvl(p_asset_id,OKL_API.G_MISS_CHAR) = nvl(l_asset_id,OKL_API.G_MISS_CHAR) then
              x_cle_id := p_clev_fin_id;
          Else

              --Create new release asset line
              Create_release_asset_line
                  (p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_asset_id       => p_asset_id,
                   p_chr_id         => l_chr_id,
                   x_cle_id         => x_cle_id);

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;

              --Copy rules, party roles, supplier invoice details
              Open l_lines_csr(p_from_cle_id => x_cle_id);
              Loop
                  fetch l_lines_csr into l_lines_rec;
                  Exit when l_lines_csr%NOTFOUND;
                  copy_updated_asset_components
                       (p_api_version    => p_api_version,
                        p_init_msg_list  => p_init_msg_list,
                        x_return_status  => x_return_status,
                        x_msg_count      => x_msg_count,
                        x_msg_data       => x_msg_data,
                        p_cle_id         => l_lines_rec.id,
                        p_orig_cle_id    => l_lines_rec.orig_system_id1,
                        p_chr_id         => l_chr_id);
                  IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
                  ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                      RAISE OKL_API.G_EXCEPTION_ERROR;
                  END IF;
              End Loop;
              Close l_lines_csr;


              --Delete old line
              OKL_CONTRACT_PUB.delete_contract_line(
                    p_api_version    => p_api_version,
                    p_init_msg_list  => p_init_msg_list,
                    x_return_status  => x_return_status,
                    x_msg_count      => x_msg_count,
                    x_msg_data       => x_msg_data,
                    p_line_id        =>  p_clev_fin_id
                     );

              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;


          End If;
      End If; --Bug# 3783518
      End If;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_Release_asset_Line;


  --Bug# 3533936
  ---------------------------------------------------------
  --Local procedure to resolve residual value on release
  --asset line
  --------------------------------------------------------
  PROCEDURE Resolve_Residual_Value(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_asset_number   IN  VARCHAR2,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            --bug# 4631549
            p_call_mode      IN  Varchar2,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_klev_fin_rec   OUT NOCOPY klev_rec_type) IS

  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'RESOLVE_RESIDUL';
  l_api_version          CONSTANT NUMBER := 1.0;


  l_top_line_id     OKC_K_LINES_B.ID%TYPE;
  l_oec             OKL_K_LINES.OEC%TYPE;
  l_residual_value  OKL_K_LINES.RESIDUAL_VALUE%TYPE;
  lx_residual_value OKL_K_LINES.RESIDUAL_VALUE%TYPE;


  --cursor to get model line id
  CURSOR l_modelline_csr(p_cle_id IN NUMBER,
                         p_chr_id IN NUMBER) IS
  SELECT model_cleb.id
  FROM   OKC_K_LINES_B        model_cleb,
         OKC_LINE_STYLES_B    model_lseb
  WHERE  model_cleb.cle_id     = p_cle_id
  AND    model_cleb.dnz_chr_id = p_chr_id
  AND    model_cleb.lse_id     = model_lseb.id
  AND    model_lseb.lty_code   = 'ITEM';

  l_model_line_id   OKC_K_LINES_B.ID%TYPE;

  --Bug# 4631549
  cursor  l_exp_cost_csr (p_kle_id in number) is
  select  kle.expected_asset_cost
  from    okl_k_lines kle
  where   kle.id = p_kle_id;

  l_exp_cost_rec l_exp_cost_csr%ROWTYPE;

Begin

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --Bug# 4631549
      If nvl(p_call_mode,okl_api.g_miss_char) = 'RELEASE_CONTRACT' then
          open l_exp_cost_csr (p_kle_id => p_clev_fin_rec.id);
          fetch l_exp_cost_csr into l_exp_cost_rec;
          close l_exp_cost_csr;
      end if;

     Open l_modelline_csr(p_cle_id  => p_clev_fin_rec.id,
                         p_chr_id  => p_clev_fin_rec.dnz_chr_id);
     Fetch l_modelline_csr into l_model_line_id;
     If l_modelline_csr%NOTFOUND then
         --raise errorr: invliad line information
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => 'OKL_LLA_LINE_RECORD');
         RAISE Okc_Api.G_EXCEPTION_ERROR;
     End If;
     Close l_modelline_csr;

     IF (p_klev_fin_rec.residual_percentage IS NOT NULL OR
         p_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM) AND
         (p_klev_fin_rec.residual_value IS NOT NULL OR
          p_klev_fin_rec.residual_value <> OKL_API.G_MISS_NUM) THEN

      l_top_line_id    := p_clev_fin_rec.id;
      --Bug# 4631549
      If nvl(p_call_mode,okl_api.g_miss_char) = 'RELEASE_CONTRACT' then
          l_oec := l_exp_cost_rec.expected_asset_cost;
      else
          l_oec  := p_klev_fin_rec.oec;
      end if;
      l_residual_value := p_klev_fin_rec.residual_value;

      get_res_per_upd_fin_rec(p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              P_new_yn             => 'N',
                              p_asset_number       => p_clev_fin_rec.name,
                              p_res_value          => l_residual_value,
                              p_oec                => l_oec,
                              p_top_line_id        => l_top_line_id,
                              p_dnz_chr_id         => p_clev_fin_rec.dnz_chr_id,
                              x_fin_clev_rec       => x_clev_fin_rec,
                              x_fin_klev_rec       => x_klev_fin_rec,
                              p_validate_fin_line  => OKL_API.G_TRUE); -- 4414408

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 P_new_yn             => 'N',
                                 p_asset_number       => p_asset_number,
				 -- 4414408
                                 p_top_line_id        => l_top_line_id,
                                 p_dnz_chr_id         => p_clev_fin_rec.dnz_chr_id,
                                 x_fin_clev_rec       => x_clev_fin_rec,
                                 x_fin_klev_rec       => x_klev_fin_rec,
                                 x_res_value          => lx_residual_value,
                                 p_validate_fin_line  => OKL_API.G_TRUE); -- 4414408

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSIF (p_klev_fin_rec.residual_percentage IS NULL OR
       p_klev_fin_rec.residual_percentage = OKL_API.G_MISS_NUM) AND
       (p_klev_fin_rec.residual_value IS NOT NULL OR
       p_klev_fin_rec.residual_value <> OKL_API.G_MISS_NUM) THEN

      l_top_line_id    := p_clev_fin_rec.id;
      --Bug# 4631549
      If nvl(p_call_mode,okl_api.g_miss_char) = 'RELEASE_CONTRACT' then
          l_oec := l_exp_cost_rec.expected_asset_cost;
      else
          l_oec  := p_klev_fin_rec.oec;
      end if;
      l_residual_value := p_klev_fin_rec.residual_value;


      get_res_per_upd_fin_rec(p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              P_new_yn             => 'N',
                              p_asset_number       => p_clev_fin_rec.name,
                              p_res_value          => l_residual_value,
                              p_oec                => l_oec,
                              p_top_line_id        => l_top_line_id,
                              p_dnz_chr_id         => p_clev_fin_rec.dnz_chr_id,
                              x_fin_clev_rec       => x_clev_fin_rec,
                              x_fin_klev_rec       => x_klev_fin_rec,
                              p_validate_fin_line  => OKL_API.G_TRUE);

      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

    ELSIF (p_klev_fin_rec.residual_percentage IS NOT NULL OR
       p_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM) AND
       (p_klev_fin_rec.residual_value IS NULL OR
       p_klev_fin_rec.residual_value = OKL_API.G_MISS_NUM) THEN

     --Bug# 4631549
     l_top_line_id    := p_clev_fin_rec.id;

      res_value_calc_upd_fin_rec(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 P_new_yn        => 'N',
                                 p_asset_number  => p_asset_number,
				 -- 4414408
                                 p_top_line_id   => p_clev_fin_rec.id,
                                 p_dnz_chr_id    => p_clev_fin_rec.dnz_chr_id,
                                 x_fin_clev_rec  => x_clev_fin_rec,
                                 x_fin_klev_rec  => x_klev_fin_rec,
                                 x_res_value     => lx_residual_value,
                                 p_validate_fin_line  => OKL_API.G_TRUE);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

   OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  End Resolve_Residual_Value;

  --Bug# 3533936
  -----------------------------------------------------
  --Modify Release Asset line based on the user inputs
  --provided for modifiable columns during Release
  ----------------------------------------------------
   PROCEDURE Modify_Release_Asset_Line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
	     --akrangan Bug# 5362977 start
            p_clev_model_rec IN  clev_rec_type,
	     --akrangan Bug# 5362977 end
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            p_cle_id         IN  NUMBER,
            --Bug# 4631549
            p_call_mode      IN  VARCHAR2,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_klev_fin_rec   OUT NOCOPY klev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_klev_model_rec OUT NOCOPY klev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_klev_fa_rec    OUT NOCOPY klev_rec_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_klev_ib_tbl    OUT NOCOPY klev_tbl_type
            ) IS



  l_return_status        VARCHAR2(1)  DEFAULT Okl_Api.G_RET_STS_SUCCESS;
  l_api_name             CONSTANT VARCHAR2(30) := 'MODIFY_RELEASE_ASSET';
  l_api_version          CONSTANT NUMBER := 1.0;

  --cursor to get fixed asset details
  cursor l_fa_csr (p_fin_cle_id in number,
                   p_chr_id     in number) is
  select txlb.id,
         txlb.depreciation_cost,
         txlb.current_units,
         txlb.percent_salvage_value,
         txlb.salvage_value,
         txlb.asset_number
  from   okl_trx_assets    trx,
         okl_txl_assets_b  txlb,
         okc_k_lines_b     cleb_fa,
         okc_line_styles_b lseb_fa
  where  trx.id             = txlb.tas_id
  and    trx.tsu_code       = 'ENTERED'
  --Bug# 3783518
  --and    trx.tas_type       = 'CRL'
  and    txlb.kle_id        = cleb_fa.id
  --Bug# 3783518
  --and    txlb.tal_type      = 'CRL'
  and    cleb_fa.cle_id     = p_fin_cle_id
  and    cleb_fa.dnz_chr_id = p_chr_id
  and    cleb_fa.lse_id     = lseb_fa.id
  and    lseb_fa.lty_code   = 'FIXED_ASSET';


  l_fa_rec l_fa_csr%ROWTYPE;

  --cursor to get install base details
  cursor l_ib_csr (p_fin_cle_id in number,
                   p_chr_id     in number) is
  select iti.id,
         iti.serial_number,
         iti.instance_number_ib,
         iti.object_id1_new,
         iti.object_id2_new
  from   okl_trx_assets    trx,
         okl_txl_itm_insts iti,
         okc_k_lines_b     cleb_ib,
         okc_line_styles_b lseb_ib,
         okc_k_lines_b     cleb_inst,
         okc_line_styles_b lseb_inst
  where  trx.id               = iti.tas_id
  and    trx.tsu_code         = 'ENTERED'
  --akrangan bug 5362977 start
   AND    trx.tas_type         IN  ('CRL','CFA','CRB')
  --akrangan bug 5362977 end
  and    iti.kle_id           = cleb_ib.id
  --akrangan bug 5362977 start
  AND    iti.tal_type         IN ('CRL','CFA','CRB')
  --akrangan bug 5362977 end
  and    cleb_ib.cle_id       = cleb_inst.id
  and    cleb_ib.dnz_chr_id   = cleb_inst.dnz_chr_id
  and    cleb_ib.lse_id       = lseb_ib.id
  and    lseb_ib.lty_code     = 'INST_ITEM'
  and    cleb_inst.cle_id     = p_fin_cle_id
  and    cleb_inst.dnz_chr_id = p_chr_id
  and    cleb_inst.lse_id     = lseb_inst.id
  and    lseb_inst.lty_code   = 'FREE_FORM2';

  l_ib_rec l_ib_csr%ROWTYPE;

  l_clev_fin_rec     clev_rec_type;
  l_klev_fin_rec     klev_rec_type;
  l_talv_fa_rec      talv_rec_type;
  l_itiv_ib_tbl      itiv_tbl_type;

  l_rel_ast_clev_fin_rec clev_rec_type;
  l_rel_ast_klev_fin_rec klev_rec_type;
  l_rel_ast_talv_rec     talv_rec_type;
  l_rel_ast_itiv_ib_tbl  itiv_tbl_type;

  i  Number;
  j  Number;

 --cursor to fetch all the lines
  CURSOR        l_lines_csr(p_from_cle_id in number) IS
    SELECT      level,
                cleb.id,
                cleb.chr_id,
                cleb.cle_id,
                cleb.dnz_chr_id,
                cleb.lse_id
    FROM        okc_k_lines_b cleb
    CONNECT BY  PRIOR cleb.id = cle_id
    START WITH  cleb.id = p_from_cle_id;

  l_lines_rec l_lines_csr%ROWTYPE;

  --cursor to get lty_code
  CURSOR l_lty_csr (p_lse_id in number) is
  SELECT lty_code
  from   okc_line_styles_b
  where  id = p_lse_id;

  l_lty_code    OKC_LINE_STYLES_B.lty_code%TYPE;

  lx_clev_rec   clev_rec_type;
  lx_klev_rec   klev_rec_type;

  --BUG# NBV:
  --cursor to get model and fixed asset lines
  cursor l_cleb_csr (p_cle_id in number,
                     p_chr_id in number,
                     p_lty_code in varchar2) is
  select cleb.id,
         cleb.price_unit
  from   okc_k_lines_b cleb,
         okc_line_styles_b lseb
  where  cleb.cle_id      = p_cle_id
  and    cleb.dnz_chr_id  = p_chr_id
  and    cleb.lse_id      = lseb.id
  and    lseb.lty_code    = p_lty_code;

  l_cleb_rec  l_cleb_csr%ROWTYPE;
  rec_count   NUMBER;

  l_clev_price_tbl   clev_tbl_type;
  lx_clev_price_tbl  clev_tbl_type;
  l_klev_price_tbl   klev_tbl_type;
  lx_klev_price_tbl  klev_tbl_type;
 --akrangan Bug# 5362977 start
     l_clev_fa_rec     clev_rec_type;
     l_klev_fa_rec     klev_rec_type;
     lx_clev_fa_rec    clev_rec_type;
     lx_klev_fa_rec    klev_rec_type;
     l_cimv_model_rec  cimv_rec_type;
     x_cimv_model_rec  cimv_rec_type;

     --cursor to check if the contract is undergoing on-line rebook
     CURSOR l_chk_rbk_csr(p_chr_id IN NUMBER) is
     SELECT '!'
     FROM   okc_k_headers_b chr,
            okl_trx_contracts ktrx
     WHERE  ktrx.khr_id_new = chr.id
     AND    ktrx.tsu_code = 'ENTERED'
     AND    ktrx.rbr_code is NOT NULL
     AND    ktrx.tcn_type = 'TRBK'
     --rkuttiya added for 12.1.1 Multi GAAP
     AND   representation_type = 'PRIMARY'
     --
     AND    chr.id = p_chr_id
     AND    chr.orig_system_source_code = 'OKL_REBOOK';

     l_rbk_khr      VARCHAR2(1);
     --akrangan Bug# 5362977 end

  BEGIN

      x_return_status := Okl_Api.G_RET_STS_SUCCESS;
      -- Call start_activity to create savepoint, check compatibility
      -- and initialize message list
      x_return_status := Okl_Api.START_ACTIVITY(
                        p_api_name      => l_api_name,
                        p_pkg_name      => g_pkg_name,
                        p_init_msg_list => p_init_msg_list,
                        l_api_version   => l_api_version,
                        p_api_version   => p_api_version,
                        p_api_type      => '_PVT',
                        x_return_status => x_return_status);
      -- Check if activity started successfully
      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
         -- akrangan Bug# 5362977 start
         l_rbk_khr := '?';
         OPEN l_chk_rbk_csr (p_chr_id => p_clev_fin_rec.dnz_chr_id);
         FETCH l_chk_rbk_csr INTO l_rbk_khr;
         CLOSE l_chk_rbk_csr;
         -- akrangan Bug# 5176649 end


      --1. update modifiable parameters on financial asset line

      l_clev_fin_rec.id                    := p_cle_id;
      l_klev_fin_rec.id                    := p_cle_id;
      l_klev_fin_rec.PRESCRIBED_ASSET_YN   := p_klev_fin_rec.PRESCRIBED_ASSET_YN;

      l_klev_fin_rec.RESIDUAL_GRNTY_AMOUNT := p_klev_fin_rec.RESIDUAL_GRNTY_AMOUNT;

      l_klev_fin_rec.RESIDUAL_CODE         := p_klev_fin_rec.RESIDUAL_CODE;

      If nvl(p_klev_fin_rec.RESIDUAL_VALUE,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM and
         nvl(p_klev_fin_rec.RESIDUAL_PERCENTAGE,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM  then
          l_klev_fin_rec.RESIDUAL_VALUE        := p_klev_fin_rec.RESIDUAL_VALUE;
          l_klev_fin_rec.RESIDUAL_PERCENTAGE   := p_klev_fin_rec.RESIDUAL_PERCENTAGE;
      End If;

      If nvl(p_klev_fin_rec.RESIDUAL_PERCENTAGE,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM and
         nvl(p_klev_fin_rec.RESIDUAL_VALUE,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM then
          l_klev_fin_rec.RESIDUAL_PERCENTAGE   := p_klev_fin_rec.RESIDUAL_PERCENTAGE;
          l_klev_fin_rec.RESIDUAL_VALUE        := NULL;
      End If;

      If nvl(p_klev_fin_rec.RESIDUAL_PERCENTAGE,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM and
         nvl(p_klev_fin_rec.RESIDUAL_VALUE,OKL_API.G_MISS_NUM) <>  OKL_API.G_MISS_NUM then
          l_klev_fin_rec.RESIDUAL_VALUE        := p_klev_fin_rec.RESIDUAL_VALUE;
          l_klev_fin_rec.RESIDUAL_PERCENTAGE   := NULL;
      End If;

      --BUG# : NBV - update price unit on fixed asset and model lines
      rec_count := 0;
      open l_cleb_csr(p_cle_id   => p_cle_id,
                      p_chr_id   => p_clev_fin_rec.dnz_chr_id,
                      p_lty_code => 'FIXED_ASSET');
      fetch l_cleb_csr into l_cleb_rec;
      If l_cleb_csr%NOTFOUND then
          Null;
      Else
          rec_count                              := rec_count+1;
          l_clev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_klev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_clev_price_tbl(rec_count).price_unit := p_talv_fa_rec.original_cost;
      End If;
      close l_cleb_csr;

      open l_cleb_csr(p_cle_id   => p_cle_id,
                      p_chr_id   => p_clev_fin_rec.dnz_chr_id,
                      p_lty_code => 'ITEM');
      fetch l_cleb_csr into l_cleb_rec;
      If l_cleb_csr%NOTFOUND then
          Null;
      Else
          rec_count                              := rec_count+1;
          l_clev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_klev_price_tbl(rec_count).id         := l_cleb_rec.id;
          l_clev_price_tbl(rec_count).price_unit := p_talv_fa_rec.original_cost;
      End If;
      close l_cleb_csr;

      If l_clev_price_tbl.COUNT > 0 then

          OKL_CONTRACT_PUB.update_contract_line(
                  p_api_version    => p_api_version,
                  p_init_msg_list  => p_init_msg_list,
                  x_return_status  => x_return_status,
                  x_msg_count      => x_msg_count,
                  x_msg_data       => x_msg_data,
                  p_clev_tbl       => l_clev_price_tbl,
                  p_klev_tbl       => l_klev_price_tbl,
                  x_clev_tbl       => lx_clev_price_tbl,
                  x_klev_tbl       => lx_klev_price_tbl);

          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;

          --Bug# 4631549
          If nvl(p_call_mode,okl_api.g_miss_char) = 'RELEASE_ASSET' then
              --Calculate oec
              OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                              p_init_msg_list => p_init_msg_list,
                                              x_return_status => x_return_status,
                                              x_msg_count     => x_msg_count,
                                              x_msg_data      => x_msg_data,
                                              p_formula_name  => G_FORMULA_OEC,
                                              p_contract_id   => p_clev_fin_rec.dnz_chr_id,
                                              p_line_id       => p_cle_id,
                                              x_value         => l_klev_fin_rec.oec);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                  OKL_API.set_message(p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_CALC_AMOUNT,
                                      p_token1       => G_AMT_TOKEN,
                                      p_token1_value => 'OEC');
                  RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                  OKL_API.set_message(p_app_name     => G_APP_NAME,
                                      p_msg_name     => G_CALC_AMOUNT,
                                      p_token1       => G_AMT_TOKEN,
                                      p_token1_value => 'OEC');
                  RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
          End If;
      END IF;
      --END BUG: NBV



      --set adjustments to null
      l_klev_fin_rec.CAPITAL_REDUCTION_PERCENT := null;
      l_klev_fin_rec.CAPITAL_REDUCTION         := null;
      l_klev_fin_rec.TRADEIN_AMOUNT            := null;

      --Bug#5601721 -- start
      l_klev_fin_rec.DOWN_PAYMENT_RECEIVER_CODE := null;
      l_klev_fin_rec.CAPITALIZE_DOWN_PAYMENT_YN:= null;
      l_klev_fin_rec.CAPITALIZED_INTEREST  := null;
      update_financial_asset_line(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_clev_rec       => l_clev_fin_rec,
            p_klev_rec       => l_klev_fin_rec,
            x_clev_rec       => l_rel_ast_clev_fin_rec,
            x_klev_rec       => l_rel_ast_klev_fin_rec);

      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
      --Bug#5601721 -- end

      --Bug# 4631549
      If nvl(p_call_mode,okl_api.g_miss_char) = 'RELEASE_ASSET' then
          --calculate capital_amount
          OKL_EXECUTE_FORMULA_PUB.EXECUTE(p_api_version   => p_api_version,
                                      p_init_msg_list => p_init_msg_list,
                                      x_return_status => x_return_status,
                                      x_msg_count     => x_msg_count,
                                      x_msg_data      => x_msg_data,
                                      p_formula_name  => G_FORMULA_CAP,
                                      p_contract_id   => p_clev_fin_rec.dnz_chr_id,
                                      p_line_id       => p_cle_id,
                                      x_value         => l_klev_fin_rec.capital_amount);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_CALC_AMOUNT,
                            p_token1       => G_AMT_TOKEN,
                            p_token1_value => 'Capital Amount');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_CALC_AMOUNT,
                            p_token1       => G_AMT_TOKEN,
                            p_token1_value => 'Capital Amount');
              RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
       End If;

  -- akrangan bug 5362977 start
         l_clev_fin_rec.item_description := p_talv_fa_rec.description;
  -- akrangan bug 5362977 end
      update_financial_asset_line(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_clev_rec       => l_clev_fin_rec,
            p_klev_rec       => l_klev_fin_rec,
            x_clev_rec       => l_rel_ast_clev_fin_rec,
            x_klev_rec       => l_rel_ast_klev_fin_rec);

      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;
        -- akrangan Bug# 5362977 start
         IF l_rbk_khr = '!' THEN
           l_clev_fa_rec.id := p_clev_fa_rec.id;
           l_klev_fa_rec.id := p_clev_fa_rec.id;

           l_clev_fa_rec.item_description := p_talv_fa_rec.description;

           l_klev_fa_rec.Year_Built       := p_talv_fa_rec.year_manufactured;
           OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_clev_rec      => l_clev_fa_rec,
                                                 p_klev_rec      => l_klev_fa_rec,
                                                 x_clev_rec      => lx_clev_fa_rec,
                                                 x_klev_rec      => lx_klev_fa_rec);

           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
             RAISE Okc_Api.G_EXCEPTION_ERROR;
           END IF;

           x_return_status := get_rec_cimv(p_clev_model_rec.id,
                                           p_clev_fin_rec.dnz_chr_id,
                                           l_cimv_model_rec);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_FETCHING_INFO,
                              p_token1       => G_REC_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V Record');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_FETCHING_INFO,
                              p_token1       => G_REC_NAME_TOKEN,
                              p_token1_value => 'OKC_K_ITEMS_V Record');
              RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;

           l_cimv_model_rec.object1_id1 := p_cimv_model_rec.object1_id1;
           l_cimv_model_rec.object1_id2 := p_cimv_model_rec.object1_id2;

           OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                     p_init_msg_list => p_init_msg_list,
                                                     x_return_status => x_return_status,
                                                     x_msg_count     => x_msg_count,
                                                     x_msg_data      => x_msg_data,
                                                     p_cimv_rec      => l_cimv_model_rec,
                                                     x_cimv_rec      => x_cimv_model_rec);

           IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
             RAISE Okc_Api.G_EXCEPTION_ERROR;
           END IF;

         END IF;
         --akrangan Bug# 5362977 end

      --2. update modifiable parameters on FA transaction line
      --get fixed asset details
      open l_fa_csr(p_fin_cle_id => p_cle_id,
                    p_chr_id     => p_clev_fin_rec.dnz_chr_id);
      fetch l_fa_csr into l_fa_rec;
      If l_fa_csr%NOTFOUND then
          --raise error:invalid line information
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_LLA_LINE_RECORD');
          RAISE Okc_Api.G_EXCEPTION_ERROR;
      End If;
      close l_fa_csr;

      l_talv_fa_rec.id                    := l_fa_rec.id;
      l_talv_fa_rec.DEPRN_METHOD          := p_talv_fa_rec.DEPRN_METHOD;
      l_talv_fa_rec.LIFE_IN_MONTHS        := p_talv_fa_rec.LIFE_IN_MONTHS;
      l_talv_fa_rec.DEPRN_RATE            := p_talv_fa_rec.DEPRN_RATE;
      l_talv_fa_rec.FA_LOCATION_ID        := p_talv_fa_rec.FA_LOCATION_ID;
      l_talv_fa_rec.SALVAGE_VALUE         := p_talv_fa_rec.SALVAGE_VALUE;
      l_talv_fa_rec.PERCENT_SALVAGE_VALUE := p_talv_fa_rec.PERCENT_SALVAGE_VALUE;
             -- akrangan Bug# 5362977 start
         IF l_rbk_khr = '!' THEN
           l_talv_fa_rec.year_manufactured     := p_talv_fa_rec.year_manufactured;
           l_talv_fa_rec.manufacturer_name     := p_talv_fa_rec.manufacturer_name;
           l_talv_fa_rec.model_number          := p_talv_fa_rec.model_number;
           l_talv_fa_rec.description           := p_talv_fa_rec.description;
         END IF;
             -- akrangan Bug# 5362977 end
      Update_asset_lines(
            p_api_version    =>  p_api_version,
            p_init_msg_list  =>  p_init_msg_list,
            x_return_status  =>  x_return_status,
            x_msg_count      =>  x_msg_count,
            x_msg_data       =>  x_msg_data,
            p_talv_rec       =>  l_talv_fa_rec,
            x_talv_rec       =>  l_rel_ast_talv_rec);

      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
         RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      --3. update modifiable parameters on IB transaction line
      i := 0;
      open l_ib_csr(p_fin_cle_id => p_cle_id,
                    p_chr_id     => p_clev_fin_rec.dnz_chr_id);
      Loop
          fetch l_ib_csr into l_ib_rec;
          Exit when l_ib_csr%NOTFOUND;
          i := i+1;
          l_itiv_ib_tbl(i).id               := l_ib_rec.id;
          l_itiv_ib_tbl(i).SERIAL_NUMBER    := l_ib_rec.SERIAL_NUMBER;
          l_itiv_ib_tbl(i).OBJECT_ID1_NEW   := l_ib_rec.OBJECT_ID1_NEW;
          l_itiv_ib_tbl(i).OBJECT_ID2_NEW   := l_ib_rec.OBJECT_ID2_NEW;
      End Loop;
      Close l_ib_csr;

      If l_itiv_ib_tbl.COUNT > 0  and p_itiv_ib_tbl.COUNT > 0 Then
          For i in l_itiv_ib_tbl.FIRST..l_itiv_ib_tbl.LAST
          Loop
              --currently only one install site is possible for one serial number
              --therefor the if clause commented below is not required
              For j in p_itiv_ib_tbl.FIRST..p_itiv_ib_tbl.LAST
              Loop
                  --If (l_itiv_ib_tbl(i).SERIAL_NUMBER = p_itiv_ib_tbl(j).SERIAL_NUMBER) OR
                     --(nvl(l_itiv_ib_tbl(i).SERIAL_NUMBER,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR
                      --and nvl(p_itiv_ib_tbl(j).SERIAL_NUMBER,OKL_API.G_MISS_CHAR) = OKL_API.G_MISS_CHAR)  then
                     l_itiv_ib_tbl(i).OBJECT_ID1_OLD := l_itiv_ib_tbl(i).OBJECT_ID1_NEW;
                     l_itiv_ib_tbl(i).OBJECT_ID2_OLD := l_itiv_ib_tbl(i).OBJECT_ID2_NEW;
                     l_itiv_ib_tbl(i).OBJECT_ID1_NEW := p_itiv_ib_tbl(j).OBJECT_ID1_NEW;
                     l_itiv_ib_tbl(i).OBJECT_ID2_NEW := p_itiv_ib_tbl(j).OBJECT_ID2_NEW;
		       --akrangan Bug# 5362977 start
                        IF l_rbk_khr = '!' THEN
                          l_itiv_ib_tbl(i).INVENTORY_ITEM_ID := p_cimv_model_rec.object1_id1;
                          l_itiv_ib_tbl(i).INVENTORY_ORG_ID  := p_cimv_model_rec.object1_id2;
                        END IF;
                        --akrangan Bug# 5362977 end

                  --End If;
              End Loop;
          End Loop;
          OKL_TXL_ITM_INSTS_PUB.update_txl_itm_insts(p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               p_iipv_tbl       => l_itiv_ib_tbl,
                                               x_iipv_tbl       => l_rel_ast_itiv_ib_tbl);

          IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
      End If;

      --------------------------------------------------
      --update residual value as per standard
      -------------------------------------------------
      Resolve_Residual_Value(
            p_api_version    => p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_asset_number   => l_fa_rec.asset_number,
            p_clev_fin_rec   => l_rel_ast_clev_fin_rec,
            p_klev_fin_rec   => l_rel_ast_klev_fin_rec,
            --Bug# 4631549
            p_call_mode      => p_call_mode,
            x_clev_fin_rec   => x_clev_fin_rec,
            x_klev_fin_rec   => x_klev_fin_rec);

      IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
          RAISE Okc_Api.G_EXCEPTION_ERROR;
      END IF;

      -------------------------------------------
      --Get all the lines
      -------------------------------------------
      i := 1;
      Open l_lines_csr (p_from_cle_id => x_clev_fin_rec.id);
      loop
          Fetch l_lines_csr into l_lines_rec;
          Exit when l_lines_csr%NOTFOUND;
          x_return_status := get_rec_clev(l_lines_rec.id,
                                          lx_clev_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_FETCHING_INFO,
                                  p_token1       => G_REC_NAME_TOKEN,
                                  p_token1_value => 'OKC_K_LINES_V Record');
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_FETCHING_INFO,
                                  p_token1       => G_REC_NAME_TOKEN,
                                  p_token1_value => 'OKC_K_LINES_V Record');
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;
          x_return_status := get_rec_klev(l_lines_rec.id,
                                          lx_klev_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_FETCHING_INFO,
                                  p_token1       => G_REC_NAME_TOKEN,
                                  p_token1_value => 'OKL_K_LINES_V Record');
              RAISE Okc_Api.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_FETCHING_INFO,
                                  p_token1       => G_REC_NAME_TOKEN,
                                  p_token1_value => 'OKL_K_LINES_V Record');
              RAISE Okc_Api.G_EXCEPTION_ERROR;
          END IF;

          Open l_lty_csr(p_lse_id => l_lines_rec.lse_id);
          Fetch l_lty_csr into l_lty_code;
          Close l_lty_csr;

          If l_lty_code = 'ITEM' then
              x_clev_model_rec := lx_clev_rec;
              x_klev_model_rec := lx_klev_rec;
          ElsIf l_lty_code = 'FIXED_ASSET' then
              x_clev_fa_rec  := lx_clev_rec;
              x_klev_fa_rec  := lx_klev_rec;
          ElsIf l_lty_code = 'INST_ITEM' then
              x_clev_ib_tbl(i) := lx_clev_rec;
              x_klev_ib_tbl(i) := lx_klev_rec;
              i := i+1;
          End If;
      End Loop;
      Close l_lines_csr;



    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Modify_Release_asset_Line;

-----------------------------------------------------------------------------------------------
--------------------- Main Process for All Lines Line Creation---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Create_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_ALL_LINES';
    l_asset_number               OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE;
    m_clev_fin_rec               clev_rec_type;
    m_klev_fin_rec               klev_rec_type;
    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_clev_fin_rec_out           clev_rec_type;
    l_klev_fin_rec_out           klev_rec_type;
    l_clev_model_rec             clev_rec_type;
    l_klev_model_rec             klev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_clev_model_rec_out         clev_rec_type;
    l_klev_model_rec_out         klev_rec_type;
    l_cimv_model_rec_out         cimv_rec_type;
    l_clev_fa_rec                clev_rec_type;
    l_klev_fa_rec                klev_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_trxv_fa_rec                trxv_rec_type;
    l_talv_fa_rec                talv_rec_type;
    l_clev_fa_rec_out            clev_rec_type;
    l_klev_fa_rec_out            klev_rec_type;
    l_cimv_fa_rec_out            cimv_rec_type;
    l_trxv_fa_rec_out            trxv_rec_type;
    l_talv_fa_rec_out            talv_rec_type;
    l_clev_inst_rec              clev_rec_type;
    l_klev_inst_rec              klev_rec_type;
    l_itiv_inst_tbl              itiv_tbl_type;
    l_clev_inst_rec_out          clev_rec_type;
    l_klev_inst_rec_out          klev_rec_type;
    l_itiv_inst_tbl_out          itiv_tbl_type;
    l_clev_ib_rec                clev_rec_type;
    l_klev_ib_rec                klev_rec_type;
    l_cimv_ib_rec                cimv_rec_type;
    l_trxv_ib_rec                trxv_rec_type;
    l_itiv_ib_tbl                itiv_tbl_type;
    r_itiv_ib_tbl                itiv_tbl_type;
    l_clev_ib_rec_out            clev_rec_type;
    l_klev_ib_rec_out            klev_rec_type;
    l_cimv_ib_rec_out            cimv_rec_type;
    l_trxv_ib_rec_out            trxv_rec_type;
    l_itiv_ib_tbl_out            itiv_tbl_type;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    ln_clev_model_price_unit     OKC_K_LINES_V.PRICE_UNIT%TYPE := 0;
    ln_cimv_model_no_items       OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE := 0;
    lv_object_id1_new            OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE;
    lv_scs_code                  OKC_K_HEADERS_V.SCS_CODE%TYPE := null;
    ln_dummy                     NUMBER := 0;
    ln_dummy1                    NUMBER := 0;
    i                            NUMBER := 0;
    j                            NUMBER := 0;
    k                            NUMBER := 0;
    m                            NUMBER := 0;
    n                            NUMBER := 0;
    p                            NUMBER := 0;

    -- added by rravikir (Estimated property tax)
    ln_chr_id                    OKC_K_HEADERS_B.ID%TYPE;
    ln_cle_id                    OKL_K_LINES_V.ID%TYPE;
    -- end
    TYPE instance_id_tbl IS TABLE OF NUMBER
        INDEX BY BINARY_INTEGER;
    lt_instance_id_tbl           instance_id_tbl;
    CURSOR c_get_scs_code(p_dnz_chr_id OKC_K_HEADERS_B.ID%TYPE)
    IS
    SELECT scs_code,
           --Bug# 4419339
           orig_system_source_code
    FROM OKC_K_HEADERS_B
    WHERE id = p_dnz_chr_id;


    --Bug# 4419339
    l_orig_system_source_code okc_k_headers_b.orig_system_source_code%TYPE;

    CURSOR c_ib_sno_asset(p_asset_number OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE)
    IS
    SELECT CII.SERIAL_NUMBER IB_SERIAL_NUMBER,
           CII.INSTANCE_ID
    FROM
    OKC_K_HEADERS_V OKHV, OKC_K_LINES_V KLE_FA, OKC_LINE_STYLES_B LSE_FA, OKC_K_LINES_B KLE_IL,
    OKC_LINE_STYLES_B LSE_IL, OKC_K_LINES_B KLE_IB, OKC_LINE_STYLES_B LSE_IB, OKC_K_ITEMS ITE,
    CSI_ITEM_INSTANCES CII
    WHERE
    kle_fa.chr_id = okhv.id AND lse_fa.id = kle_fa.lse_id AND lse_fa.lty_code = 'FREE_FORM1'
    AND kle_il.cle_id = kle_fa.id AND lse_il.id = kle_il.lse_id AND lse_il.lty_code = 'FREE_FORM2'
    AND kle_ib.cle_id = kle_il.id AND lse_ib.id = kle_ib.lse_id AND lse_ib.lty_code = 'INST_ITEM'
    AND ite.cle_id = kle_ib.id AND ite.jtot_object1_code = 'OKX_IB_ITEM'
    AND cii.instance_id = ite.object1_id1 AND kle_fa.name = p_asset_number;

    l_top_line_id NUMBER;
    l_oec NUMBER;
    l_residual_value NUMBER;

    --Bug# 3533936:
    l_rel_ast_fin_cle_id   NUMBER;

    --cursor to check if contract has re-lease assets
    CURSOR l_chk_rel_ast_csr (p_chr_id IN Number) IS
    SELECT 'Y'
    FROM   okc_k_headers_b CHR
    WHERE   nvl(chr.orig_system_source_code,'XXXX') <> 'OKL_RELEASE'
    and     chr.ID = p_chr_id
    AND     exists (SELECT '1'
                  FROM   OKC_RULES_B rul
                  WHERE  rul.dnz_chr_id = chr.id
                  AND    rul.rule_information_category = 'LARLES'
                  AND    nvl(rule_information1,'N') = 'Y');

    l_chk_rel_ast   Varchar2(1) default 'N';

    l_rel_ast_clev_fin_rec      clev_rec_type;
    l_rel_ast_klev_fin_rec      klev_rec_type;
    l_rel_ast_clev_model_rec    clev_rec_type;
    l_rel_ast_klev_model_rec    klev_rec_type;
    l_rel_ast_clev_fa_rec       clev_rec_type;
    l_rel_ast_klev_fa_rec       klev_rec_type;
    l_rel_ast_clev_ib_tbl       clev_tbl_type;
    l_rel_ast_klev_ib_tbl       klev_tbl_type;
    --End Bug# 3533936:

--| start          29-Oct-2008 cklee Bug: 7492324  move code logic to               |
--|                                OKL_TXL_ASSETS_PVT.CREATE_TXL_ASSET_DEF     |
    --Bug# 4186455 : Do not default SV for LOANS
    --cursor to check deal type of the contract
/*    Cursor l_deal_type_csr (p_chr_id in number) is
    select khr.deal_type,
           khr.pdt_id,
           pdt.reporting_pdt_id
    from   okl_products pdt,
           okl_k_headers            khr
    where  pdt.id           =  khr.pdt_id
    and    khr.id           =  p_chr_id;

    l_deal_type_rec    l_deal_type_csr%ROWTYPE;

    --dkagrawa changed cursor to use view OKL_PROD_QLTY_VAL_UV than okl_product_parameters_v
    --cursor to get deal type corresponding to a product
    Cursor l_pdt_deal_csr (p_pdt_id in number) is
    SELECT ppv.quality_val deal_type
    FROM   okl_prod_qlty_val_uv ppv
    WHERE  ppv.quality_name IN ('LEASE','INVESTOR')
    AND    ppv.pdt_id = p_pdt_id;

    l_pdt_deal_rec l_pdt_deal_csr%ROWTYPE;*/
    --End Bug# 4186455 : Do not default SV for LOANS
 --| end         29-Oct-2008 cklee Bug: 7492324  move code logic to               |
--|                                OKL_TXL_ASSETS_PVT.CREATE_TXL_ASSET_DEF     |


  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    l_clev_fin_rec   := p_clev_fin_rec;
    l_klev_fin_rec   := p_klev_fin_rec;
    l_cimv_model_rec := p_cimv_model_rec;
    l_clev_fa_rec    := p_clev_fa_rec;
    l_cimv_fa_rec    := p_cimv_fa_rec;
    l_talv_fa_rec    := p_talv_fa_rec;
    l_itiv_inst_tbl  := p_itiv_ib_tbl;
    l_itiv_ib_tbl    := p_itiv_ib_tbl;

    IF (l_clev_fin_rec.dnz_chr_id IS NULL OR
       l_clev_fin_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID for All Lines');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--start:|           14-May-2008 cklee  Bug 6405415               				     |
    IF l_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM and
       l_klev_fin_rec.residual_percentage IS NOT NULL THEN
      IF NOT l_klev_fin_rec.residual_percentage between 0 and 100 THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_VALID_RESIDUAL_PERCENT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
--end:|           14-May-2008 cklee  Bug 6405415               				     |

    OPEN  c_get_scs_code(p_dnz_chr_id => l_clev_fin_rec.dnz_chr_id);
    --Bug#4418339
    FETCH c_get_scs_code INTO lv_scs_code, l_orig_system_source_code;
    IF c_get_scs_code%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID');
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    CLOSE c_get_scs_code;

    ------------------------------------------------------
    --Bug# 3533936 : Release Asset Case - all line details
    -- should default from exising asset
    ------------------------------------------------------
    l_chk_rel_ast := 'N';
    Open l_chk_rel_ast_csr(p_chr_id => l_clev_fin_rec.dnz_chr_id);
    Fetch l_chk_rel_ast_csr into l_chk_rel_ast;
    If l_chk_rel_ast_csr%NOTFOUND then
        null;
    end if;
    close l_chk_rel_ast_csr;


    If p_new_yn = 'N'  And l_chk_rel_ast = 'Y' Then

        Create_release_asset_line
            (p_api_version    => p_api_version,
             p_init_msg_list  => p_init_msg_list,
             x_return_status  => x_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_asset_id       => l_cimv_fa_rec.object1_id1,
             p_chr_id         => l_clev_fin_rec.dnz_chr_id,
             x_cle_id         => l_rel_ast_fin_cle_id);

        --ramurt Bug#4945190
        ln_chr_id := l_clev_fin_rec.dnz_chr_id;
        ln_cle_id := l_rel_ast_fin_cle_id;

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        Modify_Release_Asset_Line(
            p_api_version    =>  p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_clev_fin_rec   => l_clev_fin_rec,
            p_klev_fin_rec   => l_klev_fin_rec,
	    --akrangan Bug# 5362977 start
            p_clev_model_rec => l_clev_model_rec,
            --akrangan Bug# 5362977 end
            p_cimv_model_rec => l_cimv_model_rec,
            p_clev_fa_rec    => l_clev_fa_rec,
            p_cimv_fa_rec    => l_cimv_fa_rec,
            p_talv_fa_rec    => l_talv_fa_rec,
            p_itiv_ib_tbl    => l_itiv_ib_tbl,
            p_cle_id         => l_rel_ast_fin_cle_id,
            --Bug# 4631549
            p_call_mode      => 'RELEASE_ASSET',
            x_clev_fin_rec   => l_rel_ast_clev_fin_rec,
            x_klev_fin_rec   => l_rel_ast_klev_fin_rec,
            x_clev_model_rec => l_rel_ast_clev_model_rec,
            x_klev_model_rec => l_rel_ast_klev_model_rec,
            x_clev_fa_rec    => l_rel_ast_clev_fa_rec,
            x_klev_fa_rec    => l_rel_ast_klev_fa_rec,
            x_clev_ib_tbl    => l_rel_ast_clev_ib_tbl,
            x_klev_ib_tbl    => l_rel_ast_klev_ib_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        x_clev_fin_rec   := l_rel_ast_clev_fin_rec;
        x_clev_model_rec := l_rel_ast_clev_model_rec;
        x_clev_fa_rec    := l_rel_ast_clev_fa_rec;
        If l_rel_ast_clev_ib_tbl.COUNT > 0 then
            x_clev_ib_rec    := l_rel_ast_clev_ib_tbl(1);
        End If;
    Else
    ----------------------------------------------------------
    --End Bug# 3533936
    ----------------------------------------------------------



-- Code is commneted as per Nagen mail on 01/23/2002 10.11am
-- code is put in place as per Manish on 09/16/2002
    IF (p_asset_number IS NULL OR
       p_asset_number = OKL_API.G_MISS_CHAR) AND
       (lv_scs_code IS NOT NULL OR
       lv_scs_code <> OKL_API.G_MISS_CHAR) AND
       --Bug#4419339
       --(lv_scs_code = 'QUOTE') AND
       --Bug# 4721141 : changed AND to OR
       (lv_scs_code = 'QUOTE') OR
       --Bug# 5098124 : Added 'OKL_QUOTE'
       (l_orig_system_source_code = 'OKL_LEASE_APP')  OR
       (l_orig_system_source_code = 'OKL_QUOTE')  THEN
       x_return_status := generate_asset_number(x_asset_number => l_asset_number);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_GEN_ASSET_NUMBER);
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_GEN_ASSET_NUMBER);
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       l_talv_fa_rec.asset_number := l_asset_number;
    ELSE
       --Bug# 4053845:
       --l_asset_number := p_asset_number;
       l_asset_number := UPPER(p_asset_number);
    END IF;

    IF l_itiv_ib_tbl.COUNT > 0 THEN
      p := l_itiv_ib_tbl.FIRST;
      LOOP
        -- Check for Required Values
        x_return_status := check_required_values(p_item1    => l_cimv_model_rec.object1_id1,
                                                 p_item2    => l_cimv_model_rec.object1_id2,
                                                 p_ast_no   => l_talv_fa_rec.asset_number,
                                                 p_ast_desc => l_talv_fa_rec.description,
                                                 p_cost     => l_talv_fa_rec.original_cost,
                                                 p_units    => l_talv_fa_rec.current_units,
                                                 p_ib_loc1  => l_itiv_ib_tbl(p).object_id1_new,
                                                 p_ib_loc2  => l_itiv_ib_tbl(p).object_id2_new,
                                                 p_fa_loc   => l_talv_fa_rec.fa_location_id,
                                                 p_refinance_amount => l_klev_fin_rec.refinance_amount,
                                                 p_chr_id   => l_clev_fin_rec.dnz_chr_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (p = l_itiv_ib_tbl.LAST);
        p := l_itiv_ib_tbl.NEXT(p);
      END LOOP;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF P_new_yn = 'Y' THEN
       ln_clev_model_price_unit := abs(l_talv_fa_rec.original_cost);
       ln_cimv_model_no_items   := l_talv_fa_rec.current_units;
    ELSIF p_new_yn = 'N' THEN
       IF l_clev_model_rec.price_unit = OKL_API.G_MISS_NUM THEN
          l_clev_model_rec.price_unit := null;
       END IF;
       IF l_cimv_model_rec.number_of_items = OKL_API.G_MISS_NUM THEN
          l_cimv_model_rec.number_of_items := null;
       END IF;
       ln_clev_model_price_unit := abs(l_talv_fa_rec.original_cost);
       ln_cimv_model_no_items   := l_talv_fa_rec.current_units;
       -- we need to modify the code, let it go a temp
	--       ln_clev_model_price_unit := nvl(l_clev_model_rec.price_unit,0);
	--       ln_cimv_model_no_items   := nvl(l_cimv_model_rec.number_of_items,0);
	    END IF;
	    --Build the Top Line Record
	    -- First get the Top line Style id
            -- 4414408 Assign the line style id directly
/*
	    x_return_status := get_lse_id(p_lty_code => G_FIN_LINE_LTY_CODE,
					  x_lse_id   => l_clev_fin_rec.lse_id);
	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;
*/
            l_clev_fin_rec.lse_id           := G_FIN_LINE_LTY_ID;
	    l_clev_fin_rec.chr_id           := l_clev_fin_rec.dnz_chr_id;
	    l_clev_fin_rec.cle_id           := null;
	--    l_clev_fin_rec.name             := l_asset_number;
            --Bug# 4053845
            l_clev_fin_rec.name             := upper(l_clev_fin_rec.name);
	    l_clev_fin_rec.item_description := l_talv_fa_rec.description;
	    l_clev_fin_rec.exception_yn     := 'N';
	    IF (l_clev_fin_rec.display_sequence IS NUll OR
	       l_clev_fin_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
	       l_clev_fin_rec.display_sequence := 1;
	    END IF;
    -- To Check We Got the Valid info
    IF UPPER(p_new_yn) NOT IN ('Y','N') OR
       (UPPER(p_new_yn) = OKL_API.G_MISS_CHAR OR
       UPPER(p_new_yn) IS NULL) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_INVALID_YN,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'p_new_yn');
       -- Halt Validation
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- 4414408 Validate the Asset Number
    -- Validate to see if the asset_number given is not null
    -- and also Validate asset_number does not exists
    -- in OKL_TXL_ASSETS_V
    IF UPPER(p_new_yn) = 'Y' THEN
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => l_asset_number,
                                 p_dnz_chr_id     => l_clev_fin_rec.dnz_chr_id);
       -- Check if activity started successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       validate_new_asset_number(x_return_status  => x_return_status,
                                 p_asset_number   => l_asset_number,
                                 p_dnz_chr_id     => l_clev_fin_rec.dnz_chr_id);
       -- Check if activity ended successfully
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    END IF;

	    -- Creation of the Financial Asset Line
	    create_fin_line(p_api_version   => p_api_version,
			    p_init_msg_list => p_init_msg_list,
			    x_return_status => x_return_status,
			    x_msg_count     => x_msg_count,
			    x_msg_data      => x_msg_data,
			    P_new_yn        => P_new_yn,
			    p_asset_number  => l_asset_number,
			    p_clev_rec      => l_clev_fin_rec,
			    p_klev_rec      => l_klev_fin_rec,
			    x_clev_rec      => x_clev_fin_rec,
			    x_klev_rec      => l_klev_fin_rec_out);
	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;

        -- added by rravikir (Estimated property tax)
        ln_chr_id := x_clev_fin_rec.dnz_chr_id;
        ln_cle_id := x_clev_fin_rec.id;
        -- end

	    -- We have to Populate the Model Line Record
	    -- First get the Model line Style id
            -- 4414408 Assign the line style id directly
/*
	    x_return_status := get_lse_id(p_lty_code => G_MODEL_LINE_LTY_CODE,
					  x_lse_id   => l_clev_model_rec.lse_id);
	    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	      RAISE OKL_API.G_EXCEPTION_ERROR;
	    END IF;
*/
	    IF (l_clev_model_rec.display_sequence IS NUll OR
	       l_clev_model_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
	       l_clev_model_rec.display_sequence  := x_clev_fin_rec.display_sequence + 1;
	    END IF;
	    l_clev_model_rec.lse_id          := G_MODEL_LINE_LTY_ID;
	    l_clev_model_rec.chr_id          := null;
	    l_clev_model_rec.cle_id          := x_clev_fin_rec.id;
	    l_clev_model_rec.exception_yn    := 'N';
	    l_clev_model_rec.price_unit      := ln_clev_model_price_unit;
            l_clev_model_rec.dnz_chr_id      := x_clev_fin_rec.dnz_chr_id;
    --Build Model cimv rec
    l_cimv_model_rec.exception_yn    := 'N';
    l_cimv_model_rec.number_of_items := ln_cimv_model_no_items;
    -- Creation of the Model Line and Item Record
    create_model_line(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      P_new_yn        => P_new_yn,
                      p_asset_number  => l_asset_number,
                      p_clev_rec      => l_clev_model_rec,
                      p_klev_rec      => l_klev_model_rec,
                      p_cimv_rec      => l_cimv_model_rec,
                      x_clev_rec      => x_clev_model_rec,
                      x_klev_rec      => l_klev_model_rec_out,
                      x_cimv_rec      => l_cimv_model_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the OEC to Populate the OKL_K_LINES_V.OEC
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => l_asset_number,
			 -- 4414408
                         p_top_line_id        => x_clev_model_rec.cle_id,
                         p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                         x_fin_clev_rec       => x_clev_fin_rec,
                         x_fin_klev_rec       => l_klev_fin_rec_out,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_FALSE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => l_asset_number,
			     -- 4414408
                             p_top_line_id        => x_clev_model_rec.cle_id,
                             p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                             x_fin_clev_rec       => x_clev_fin_rec,
                             x_fin_klev_rec       => l_klev_fin_rec_out,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_FALSE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    -- We need to Back calculate the Residual Percentage if value not given
    -- or if given should be in sync with residual value

    IF  l_klev_fin_rec_out.residual_percentage = OKL_API.G_MISS_NUM THEN
      l_klev_fin_rec_out.residual_percentage := null;
    END IF;

    IF l_klev_fin_rec_out.residual_value = OKL_API.G_MISS_NUM THEN
      l_klev_fin_rec_out.residual_value := null;
    END IF;

    IF (l_klev_fin_rec_out.residual_percentage IS NOT NULL OR
       l_klev_fin_rec_out.residual_percentage <> OKL_API.G_MISS_NUM) AND
       (l_klev_fin_rec_out.residual_value IS NOT NULL OR
       l_klev_fin_rec_out.residual_value <> OKL_API.G_MISS_NUM) THEN

      l_top_line_id := x_clev_fin_rec.id;
      l_oec := l_klev_fin_rec_out.oec;
      l_residual_value := l_klev_fin_rec_out.residual_value;

      get_res_per_upd_fin_rec(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              P_new_yn        => P_new_yn,
                              p_asset_number  => l_asset_number,
                              p_res_value     => l_residual_value,  --l_klev_fin_rec_out.residual_value
                              p_oec           => l_oec,  --l_klev_fin_rec_out.oec
                              p_top_line_id   => l_top_line_id, --x_clev_fin_rec.id,
                              p_dnz_chr_id    => x_clev_model_rec.dnz_chr_id,
                              x_fin_clev_rec  => x_clev_fin_rec,
                              x_fin_klev_rec  => l_klev_fin_rec_out,
                              p_validate_fin_line  => OKL_API.G_FALSE); -- #4414408
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 P_new_yn             => P_new_yn,
                                 p_asset_number       => l_asset_number,
				 -- 4414408
                                 p_top_line_id        => l_top_line_id,
                                 p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                 x_fin_clev_rec       => x_clev_fin_rec,
                                 x_fin_klev_rec       => l_klev_fin_rec_out,
                                 x_res_value          => ln_klev_fin_res,
                                 p_validate_fin_line  => OKL_API.G_FALSE); -- #4414408
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (l_klev_fin_rec_out.residual_percentage IS NULL OR
       l_klev_fin_rec_out.residual_percentage = OKL_API.G_MISS_NUM) AND
       (l_klev_fin_rec_out.residual_value IS NOT NULL OR
       l_klev_fin_rec_out.residual_value <> OKL_API.G_MISS_NUM) THEN

      l_top_line_id := x_clev_fin_rec.id;
      l_oec := l_klev_fin_rec_out.oec;
      l_residual_value := l_klev_fin_rec_out.residual_value;

      get_res_per_upd_fin_rec(p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              P_new_yn             => P_new_yn,
                              p_asset_number       => l_asset_number,
                              p_res_value          => l_residual_value,  --l_klev_fin_rec_out.residual_value
                              p_oec                => l_oec,  --l_klev_fin_rec_out.oec
                              p_top_line_id        => l_top_line_id, --x_clev_fin_rec.id,
                              p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                              x_fin_clev_rec       => x_clev_fin_rec,
                              x_fin_klev_rec       => l_klev_fin_rec_out,
                              p_validate_fin_line  => OKL_API.G_FALSE); -- #4414408
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (l_klev_fin_rec_out.residual_percentage IS NOT NULL OR
       l_klev_fin_rec_out.residual_percentage <> OKL_API.G_MISS_NUM) AND
       (l_klev_fin_rec_out.residual_value IS NULL OR
       l_klev_fin_rec_out.residual_value = OKL_API.G_MISS_NUM) THEN
      res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                 p_init_msg_list      => p_init_msg_list,
                                 x_return_status      => x_return_status,
                                 x_msg_count          => x_msg_count,
                                 x_msg_data           => x_msg_data,
                                 P_new_yn             => P_new_yn,
                                 p_asset_number       => l_asset_number,
				 -- 4414408
                                 p_top_line_id        => x_clev_model_rec.cle_id,
                                 p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                 x_fin_clev_rec       => x_clev_fin_rec,
                                 x_fin_klev_rec       => l_klev_fin_rec_out,
                                 x_res_value          => ln_klev_fin_res,
                                 p_validate_fin_line  => OKL_API.G_FALSE); -- #4414408
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF (l_klev_fin_rec_out.oec IS NOT NULL OR
       l_klev_fin_rec_out.oec <> OKL_API.G_MISS_NUM) AND
       (l_klev_fin_rec_out.residual_value IS NOT NULL OR
       l_klev_fin_rec_out.residual_value <> OKL_API.G_MISS_NUM) THEN
      IF l_klev_fin_rec_out.residual_value > l_klev_fin_rec_out.oec THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SALVAGE_VALUE);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Required cle Line Information
    -- Creation of the Fixed Asset Line Process
    -- Getting the Line style Info
    -- 4414408 Assign the line style ID directly
/*
    x_return_status := get_lse_id(p_lty_code => G_FA_LINE_LTY_CODE,
                                  x_lse_id   => l_clev_fa_rec.lse_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
*/
    IF (l_clev_fa_rec.display_sequence IS NUll OR
       l_clev_fa_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
       l_clev_fa_rec.display_sequence  := x_clev_model_rec.display_sequence + 2;
    END IF;
    l_clev_fa_rec.lse_id               := G_FA_LINE_LTY_ID;
    l_clev_fa_rec.chr_id               := null;
    l_clev_fa_rec.cle_id               := x_clev_fin_rec.id;
    l_clev_fa_rec.dnz_chr_id           := x_clev_fin_rec.dnz_chr_id;
    l_clev_fa_rec.exception_yn         := 'N';
    l_clev_fa_rec.price_unit           := ln_clev_model_price_unit;
    l_clev_fa_rec.item_description     := l_talv_fa_rec.description;
    --Bug# 4053845
    l_clev_fa_rec.name                 := upper(l_clev_fa_rec.name);
    -- A Bug fix Since we populate the year manufactured into OKL_TXL_ASSETS_B only
    -- We cannot use the information after the assets have been put into FA
    -- So we decided to populate the year Manufactured into OKL_K_LINES.YEAR_BUILT
    -- As the Datatype matches for both.
    l_klev_fa_rec.Year_Built       := l_talv_fa_rec.year_manufactured;
    --start NISINHA Bug 6490572
    l_klev_fa_rec.model_number       := l_talv_fa_rec.model_number;
    l_klev_fa_rec.manufacturer_name  := l_talv_fa_rec.manufacturer_name;
    --end NISINHA Bug 6490572
    -- Required Item Information
    l_cimv_fa_rec.exception_yn         := 'N';
    IF p_new_yn = 'Y' THEN
      l_cimv_fa_rec.object1_id1          := null;
      l_cimv_fa_rec.object1_id2          := null;
    ELSIF p_new_yn = 'N' THEN
      l_cimv_fa_rec.object1_id2          := '#';
    END IF;
    l_cimv_fa_rec.number_of_items      := ln_cimv_model_no_items;
    -- Txl Asset Information
    IF (l_talv_fa_rec.asset_number IS NULL OR
       l_talv_fa_rec.asset_number = OKL_API.G_MISS_CHAR) THEN
       l_talv_fa_rec.asset_number := l_asset_number;
    --bug# 4053845
    ELSE
       l_talv_fa_rec.asset_number := UPPER(l_talv_fa_rec.asset_number);
    END IF;
    IF P_new_yn= 'Y' THEN
     --fix for #3481999
     IF ( l_talv_fa_rec.depreciation_cost IS NULL OR
          l_talv_fa_rec.depreciation_cost = OKL_API.G_MISS_NUM ) THEN
        l_talv_fa_rec.depreciation_cost := l_klev_fin_rec_out.oec;
     END IF;

      l_talv_fa_rec.original_cost := l_klev_fin_rec_out.oec;
      l_talv_fa_rec.tal_type := 'CFA';
      --------------
      --Bug# 4082635
      -------------
--| start          29-Oct-2008 cklee Bug: 7492324  move code logic to               |
--|                                OKL_TXL_ASSETS_PVT.CREATE_TXL_ASSET_DEF     |

/*
      If nvl(l_talv_fa_rec.salvage_value,OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM AND
         nvl(l_talv_fa_rec.percent_salvage_value, OKL_API.G_MISS_NUM) = OKL_API.G_MISS_NUM  then
          --Bug# 4186455 : Do not populate salvage value for Loan and loan revolving deal types
          for l_deal_type_rec in l_deal_type_csr(p_chr_id => l_clev_fin_rec.dnz_chr_id)
          loop
              If l_deal_type_rec.deal_type = 'LOAN' then
                  If nvl(l_deal_type_rec.reporting_pdt_id,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
                      for l_pdt_deal_rec in l_pdt_deal_csr(p_pdt_id => l_deal_type_rec.reporting_pdt_id)
                      loop
                          If l_pdt_deal_rec.deal_type = 'LEASEOP' then -- reporting pdt is operating lease
                              l_talv_fa_rec.salvage_value := nvl(l_klev_fin_rec_out.residual_value,0);

                          End If;
                      End loop;
                  End If;
              Elsif l_deal_type_rec.deal_type = 'LOAN-REVOLVING' then
                  null;
              Else -- for LEASEOP, LEASEDF, LEASEST
                  l_talv_fa_rec.salvage_value := nvl(l_klev_fin_rec_out.residual_value,0);
              End If;
          End Loop;
      End If;*/
--| end         29-Oct-2008 cklee Bug: 7492324  move code logic to               |
--|                                OKL_TXL_ASSETS_PVT.CREATE_TXL_ASSET_DEF     |
      ------------------
      --End Bug# 4082635
      ------------------
    ELSIF p_new_yn = 'N' THEN
      l_talv_fa_rec.depreciation_cost := l_klev_fin_rec_out.oec;
      l_talv_fa_rec.original_cost := l_klev_fin_rec_out.oec;
      l_talv_fa_rec.tal_type := 'CRL';
    END IF;
    -- Creation of the Fixed Asset Line and item/Txl Asset Info
    Create_fixed_asset_line(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => l_asset_number,
                            p_clev_rec      => l_clev_fa_rec,
                            p_klev_rec      => l_klev_fa_rec,
                            p_cimv_rec      => l_cimv_fa_rec,
                            p_talv_rec      => l_talv_fa_rec,
                            x_clev_rec      => x_clev_fa_rec,
                            x_klev_rec      => l_klev_fa_rec_out,
                            x_cimv_rec      => l_cimv_fa_rec_out,
                            x_trxv_rec      => l_trxv_fa_rec_out,
                            x_talv_rec      => l_talv_fa_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_new_yn = 'N' THEN
      FOR r_ib_sno_asset IN c_ib_sno_asset(l_talv_fa_rec_out.asset_number) LOOP
        r_itiv_ib_tbl(k).serial_number := r_ib_sno_asset.ib_serial_number;
        IF r_ib_sno_asset.ib_serial_number IS NULL OR
           r_ib_sno_asset.ib_serial_number = OKL_API.G_MISS_CHAR THEN
          r_itiv_ib_tbl(k).mfg_serial_number_yn := 'N';
        ELSE
          r_itiv_ib_tbl(k).mfg_serial_number_yn := 'Y';
        END IF;
        r_itiv_ib_tbl(k).dnz_cle_id := x_clev_fa_rec.cle_id;
        IF l_itiv_ib_tbl.COUNT > 0 THEN
          m := l_itiv_ib_tbl.FIRST;
          LOOP
            r_itiv_ib_tbl(k).object_id1_new := l_itiv_ib_tbl(m).object_id1_new;
            EXIT WHEN (m = l_itiv_ib_tbl.LAST);
            m := l_itiv_ib_tbl.NEXT(m);
          END LOOP;
        END IF;
        lt_instance_id_tbl(k) := r_ib_sno_asset.instance_id;
        k := k + 1;
      END LOOP;
      l_itiv_ib_tbl   := r_itiv_ib_tbl;
      IF l_itiv_ib_tbl.COUNT > 0 THEN
         ln_dummy1 :=  l_itiv_ib_tbl.COUNT;
         -- We have intialize the J , since there could be any index integer
         j := l_itiv_ib_tbl.FIRST;
         LOOP
           IF (l_itiv_ib_tbl(j).mfg_serial_number_yn IS NULL OR
              l_itiv_ib_tbl(j).mfg_serial_number_yn = OKL_API.G_MISS_CHAR) THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           ELSIF l_itiv_ib_tbl(j).mfg_serial_number_yn = 'Y' THEN
              IF ln_dummy1 <> ln_cimv_model_no_items THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_CNT_REC);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              ln_dummy := ln_cimv_model_no_items;
           ELSIF l_itiv_ib_tbl(j).mfg_serial_number_yn = 'N' THEN
              ln_dummy := 1;
           END IF;
           EXIT WHEN (j = l_itiv_ib_tbl.LAST);
           j := l_itiv_ib_tbl.NEXT(j);
         END LOOP;
      ELSE
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_CNT_REC);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF p_new_yn = 'Y' THEN
      -- We have to make sure the count of the itiv_tbl
      -- should be equal to qty of items
      -- Since inst tbl and ib inst are same
      -- it is Good enough to do one
      IF l_itiv_ib_tbl.COUNT > 0 THEN
         ln_dummy1 :=  l_itiv_ib_tbl.COUNT;
         -- We have intialize the J , since there could be any index integer
         j := l_itiv_ib_tbl.FIRST;
         LOOP

           l_itiv_ib_tbl(j).dnz_cle_id := x_clev_fa_rec.cle_id; -- For importing Serial Item fix

           IF (l_itiv_ib_tbl(j).mfg_serial_number_yn IS NULL OR
              l_itiv_ib_tbl(j).mfg_serial_number_yn = OKL_API.G_MISS_CHAR) THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           ELSIF l_itiv_ib_tbl(j).mfg_serial_number_yn = 'Y' THEN
              IF ln_dummy1 <> ln_cimv_model_no_items THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => G_CNT_REC);
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              ln_dummy := ln_cimv_model_no_items;
           ELSIF l_itiv_ib_tbl(j).mfg_serial_number_yn = 'N' THEN
              ln_dummy := 1;
           END IF;
           EXIT WHEN (j = l_itiv_ib_tbl.LAST);
           j := l_itiv_ib_tbl.NEXT(j);
         END LOOP;
      ELSE
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_CNT_REC);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Since we have to create the instance
    -- Depending of the qty in l_cimv_model_rec.number_of_items
    -- we have use loop
    j := l_itiv_ib_tbl.FIRST;
    FOR i IN 1..ln_dummy LOOP
      IF (l_itiv_ib_tbl(j).instance_number_ib IS NULL OR
         l_itiv_ib_tbl(j).instance_number_ib = OKL_API.G_MISS_CHAR) THEN
         x_return_status := generate_instance_number_ib(x_instance_number_ib => l_itiv_ib_tbl(j).instance_number_ib);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_GEN_INST_NUM_IB);
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_GEN_INST_NUM_IB);
           RAISE OKL_API.G_EXCEPTION_ERROR;
         END IF;
         l_itiv_ib_tbl(j).instance_number_ib := l_asset_number||' '||l_itiv_ib_tbl(j).instance_number_ib;
         l_itiv_inst_tbl(j).instance_number_ib := l_itiv_ib_tbl(j).instance_number_ib;
      END IF;
      -- Creation of the Instance Line Process
      -- Getting the Line style Info
      -- 4414408 Assign the line style ID directly
/*
      x_return_status := get_lse_id(p_lty_code => G_INST_LINE_LTY_CODE,
                                    x_lse_id   => l_clev_inst_rec.lse_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
*/
      IF (l_clev_inst_rec.display_sequence IS NUll OR
         l_clev_inst_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
         l_clev_inst_rec.display_sequence  := x_clev_fa_rec.display_sequence + 3;
      END IF;
      -- Required cle Line Information
      l_clev_inst_rec.lse_id            := G_INST_LINE_LTY_ID;
      l_clev_inst_rec.chr_id            := null;
      l_clev_inst_rec.cle_id            := x_clev_fin_rec.id;
      l_clev_inst_rec.dnz_chr_id        := x_clev_fin_rec.dnz_chr_id;
      l_clev_inst_rec.exception_yn      := 'N';
      -- Creation of the Instance Line
      Create_instance_line(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_clev_rec      => l_clev_inst_rec,
                           p_klev_rec      => l_klev_inst_rec,
                           p_itiv_rec      => l_itiv_inst_tbl(j),
                           x_clev_rec      => l_clev_inst_rec_out,
                           x_klev_rec      => l_klev_inst_rec_out,
                           x_itiv_rec      => l_itiv_inst_tbl_out(j));
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- Creation of the ib Line Process
      -- Getting the Line style Info
      -- 4414408 Assign the IB line style ID directly
/*
      x_return_status := get_lse_id(p_lty_code => G_IB_LINE_LTY_CODE,
                                    x_lse_id   => l_clev_ib_rec.lse_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
*/
      IF (l_clev_ib_rec.display_sequence IS NUll OR
         l_clev_ib_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
         l_clev_ib_rec.display_sequence  := l_clev_inst_rec_out.display_sequence + 4;
      END IF;
      -- Required cle Line Information
      l_clev_ib_rec.lse_id            := G_IB_LINE_LTY_ID;
      l_clev_ib_rec.chr_id            := null;
      l_clev_ib_rec.cle_id            := l_clev_inst_rec_out.id;
      l_clev_ib_rec.dnz_chr_id        := x_clev_fin_rec.dnz_chr_id;
      l_clev_ib_rec.exception_yn      := 'N';
      -- Required Item Information
      l_cimv_ib_rec.exception_yn      := 'N';
      l_cimv_ib_rec.object1_id1       := null;
      l_cimv_ib_rec.object1_id2       := null;
      -- Since the screen can give only party_site_id via l_itiv_tbl(j).object_id1_new
      -- We have to use the below function
      lv_object_id1_new := l_itiv_ib_tbl(j).object_id1_new;
      x_return_status := get_party_site_id(p_object_id1_new => lv_object_id1_new,
                                           x_object_id1_new => l_itiv_ib_tbl(j).object_id1_new,
                                           x_object_id2_new => l_itiv_ib_tbl(j).object_id2_new);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF P_new_yn= 'Y' THEN
        l_itiv_ib_tbl(j).tal_type := 'CFA';
      ELSIF p_new_yn = 'N' THEN
        l_itiv_ib_tbl(j).tal_type := 'CRL';
        m := lt_instance_id_tbl.FIRST;
        l_cimv_ib_rec.object1_id1 := lt_instance_id_tbl(m);
        l_cimv_ib_rec.object1_id2 := '#';
      END IF;
       -- Creation of the ib Line
      Create_instance_ib_line(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_clev_rec      => l_clev_ib_rec,
                              p_klev_rec      => l_klev_ib_rec,
                              p_cimv_rec      => l_cimv_ib_rec,
                              p_itiv_rec      => l_itiv_ib_tbl(j),
                              x_clev_rec      => x_clev_ib_rec,
                              x_klev_rec      => l_klev_ib_rec_out,
                              x_cimv_rec      => l_cimv_ib_rec_out,
                              x_trxv_rec      => l_trxv_ib_rec_out,
                              x_itiv_rec      => l_itiv_ib_tbl_out(j));
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      EXIT WHEN (j = l_itiv_inst_tbl.LAST);
      j := l_itiv_inst_tbl.NEXT(j);
      m := m + 1;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF; --release asset --Bug# 3533936

  -- Added by rravikir (Estimated property tax) -- Bug 3947959
  -- Property tax rules are not created for Quotes, they are taken care in the
  -- respective API.
  IF (lv_scs_code IS NOT NULL AND lv_scs_code <> 'QUOTE') THEN
    OKL_LA_PROPERTY_TAX_PVT.create_est_prop_tax_rules(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_chr_id             => ln_chr_id,
            p_cle_id             => ln_cle_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug#4658856 ramurt
    OKL_LA_SALES_TAX_PVT.create_sales_tax_rules(
            p_api_version        => p_api_version,
            p_init_msg_list      => p_init_msg_list,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data,
            p_chr_id             => ln_chr_id,
            p_cle_id             => ln_cle_id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
  END IF;
  -- end

  OKL_API.END_ACTIVITY (x_msg_count,
                        x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END Create_all_line;
-----------------------------------------------------------------------------------------------
--------------------- Main Process for All Lines Line Updating---------------------------------
-----------------------------------------------------------------------------------------------
  PROCEDURE Update_all_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_fin_rec   IN  clev_rec_type,
            p_klev_fin_rec   IN  klev_rec_type,
            p_clev_model_rec IN  clev_rec_type,
            p_cimv_model_rec IN  cimv_rec_type,
            p_clev_fa_rec    IN  clev_rec_type,
            p_cimv_fa_rec    IN  cimv_rec_type,
            p_talv_fa_rec    IN  talv_rec_type,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_rec    IN  itiv_rec_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_clev_model_rec OUT NOCOPY clev_rec_type,
            x_clev_fa_rec    OUT NOCOPY clev_rec_type,
            x_clev_ib_rec    OUT NOCOPY clev_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_ALL_LINES';
    l_clev_fin_rec               clev_rec_type;
    l_klev_fin_rec               klev_rec_type;
    l_clev_fin_rec_out           clev_rec_type;
    l_klev_fin_rec_out           klev_rec_type;
    l_clev_model_rec             clev_rec_type;
    l_klev_model_rec             klev_rec_type;
    l_cimv_model_rec             cimv_rec_type;
    l_clev_model_rec_out         clev_rec_type;
    l_klev_model_rec_out         klev_rec_type;
    l_cimv_model_rec_out         cimv_rec_type;
    l_clev_fa_rec                clev_rec_type;
    l_klev_fa_rec                klev_rec_type;
    l_cimv_fa_rec                cimv_rec_type;
    l_trxv_fa_rec                trxv_rec_type;
    l_talv_fa_rec                talv_rec_type;
    l_clev_fa_rec_out            clev_rec_type;
    l_klev_fa_rec_out            klev_rec_type;
    l_cimv_fa_rec_out            cimv_rec_type;
    l_trxv_fa_rec_out            trxv_rec_type;
    l_talv_fa_rec_out            talv_rec_type;
    l_clev_inst_rec              clev_rec_type;
    l_klev_inst_rec              klev_rec_type;
    l_itiv_inst_rec              itiv_rec_type;
    l_clev_inst_rec_out          clev_rec_type;
    l_klev_inst_rec_out          klev_rec_type;
    l_itiv_inst_rec_out          itiv_rec_type;
    l_clev_ib_rec                clev_rec_type;
    l_klev_ib_rec                klev_rec_type;
    l_cimv_ib_rec                cimv_rec_type;
    l_trxv_ib_rec                trxv_rec_type;
    l_itiv_ib_rec                itiv_rec_type;
    l_clev_ib_rec_out            clev_rec_type;
    l_klev_ib_rec_out            klev_rec_type;
    l_cimv_ib_rec_out            cimv_rec_type;
    l_trxv_ib_rec_out            trxv_rec_type;
    l_itiv_ib_rec_out            itiv_rec_type;
    n_itiv_ib_rec                itiv_rec_type;
    nx_itiv_ib_rec               itiv_rec_type;

    r_clev_fin_rec               clev_rec_type;
    r_klev_fin_rec               klev_rec_type;
    r_clev_model_rec             clev_rec_type;
    r_klev_model_rec             klev_rec_type;
    r_cimv_model_rec             cimv_rec_type;
    r_clev_fa_rec                clev_rec_type;
    r_klev_fa_rec                klev_rec_type;
    r_cimv_fa_rec                cimv_rec_type;
    r_talv_fa_rec                talv_rec_type;
    r_clev_inst_rec              clev_rec_type;
    r_klev_inst_rec              klev_rec_type;
    r_itiv_inst_rec              itiv_rec_type;
    r_clev_ib_rec                clev_rec_type;
    r_klev_ib_rec                klev_rec_type;
    r_cimv_ib_rec                cimv_rec_type;
    r_itiv_ib_rec                itiv_rec_type;
    ln_addon_oec                 OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    ln_clev_model_price_unit     OKC_K_LINES_V.PRICE_UNIT%TYPE := 0;
    ln_cimv_model_no_items       OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE := 0;
    lv_object_id1_new            OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE;
    lv_model_object_id1          OKC_K_ITEMS_V.OBJECT1_ID1%TYPE;
    lv_model_object_id2          OKC_K_ITEMS_V.OBJECT1_ID2%TYPE;
    ln_dummy                     NUMBER := 0;
    ln_dummy1                    NUMBER := 0;
    i                            NUMBER := 0;
    j                            NUMBER := 0;
    l_new_yn                     VARCHAR2(3);
    l_go_for_calc                VARCHAR2(3):= 'Y';

    -- rravikir added
    ln_txl_itm_id                OKL_TXL_ITM_INSTS.ID%TYPE;
    k_itiv_ib_rec                itiv_rec_type;
    kx_itiv_ib_rec               itiv_rec_type;
    lv_object_id1                OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE;
    lv_object_id2                OKL_TXL_ITM_INSTS.OBJECT_ID2_NEW%TYPE;
    ln_inv_itm_id                OKL_TXL_ITM_INSTS.INVENTORY_ITEM_ID%TYPE;
    ln_inv_org_id                OKL_TXL_ITM_INSTS.INVENTORY_ORG_ID%TYPE;
    lv_jtot_object_code_new      OKL_TXL_ITM_INSTS.JTOT_OBJECT_CODE_NEW%TYPE;
    -- end rravikir

    CURSOR c_asset_iti(p_asset_number OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
                       p_dnz_chr_id   OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
    IS
    select cle_ib.id id
    from okc_line_styles_b lse_ib,
        okc_k_lines_b cle_ib,
        okc_line_styles_b lse_inst,
        okc_k_lines_b cle_inst,
        okc_line_styles_b lse_tl,
        okc_k_lines_v cleb_tl
    where cleb_tl.name = P_asset_number
    and cleb_tl.dnz_chr_id = p_dnz_chr_id
    and cleb_tl.lse_id = lse_tl.id
    and lse_tl.lty_code = G_FIN_LINE_LTY_CODE
    and lse_tl.lse_type = G_TLS_TYPE
    and cle_inst.cle_id = cleb_tl.id
    and cle_inst.lse_id = lse_inst.id
    and lse_inst.lty_code = G_INST_LINE_LTY_CODE
    and cle_ib.cle_id = cle_inst.id
    and cle_ib.lse_id = lse_ib.id
    and lse_ib.lty_code = G_IB_LINE_LTY_CODE;

    -- rravikir added
    CURSOR c_get_txl_itm_insts(p_top_line_id  OKC_K_LINES_B.ID%TYPE,
                               p_txl_inst_id  OKL_TXL_ITM_INSTS.ID%TYPE)
    IS
    select iti.id, iti.inventory_item_id, iti.inventory_org_id,
           iti.object_id1_new, iti.object_id2_new, iti.jtot_object_code_new
    from okl_txl_itm_insts iti,
         okc_line_styles_b lse_ib,
         okc_k_lines_b cle_ib,
         okc_line_styles_b lse_inst,
         okc_k_lines_b cle_inst
    where cle_inst.cle_id =  p_top_line_id
    and   cle_inst.lse_id = lse_inst.id
    and   lse_inst.lty_code = G_INST_LINE_LTY_CODE
    and   cle_ib.cle_id = cle_inst.id
    and   cle_ib.lse_id = lse_ib.id
    and   lse_ib.lty_code = G_IB_LINE_LTY_CODE
    and   cle_ib.id = iti.kle_id
    and   cle_ib.id <> p_txl_inst_id;
    -- end rravikir

    l_top_line_id NUMBER;
    l_oec NUMBER;

    --Bug# 3533936: Enhancements for release assets
    l_rel_ast_fin_cle_id   NUMBER;
    l_itiv_ib_tbl          itiv_tbl_type;

    --cursor to get existing residual values
    --and down payment values Bug# 5192636
    cursor l_cle_csr          (p_cle_id in number,
                               p_chr_id in number) is
    select fin_kle.DOWN_PAYMENT_RECEIVER_CODE,
           fin_kle.CAPITALIZE_DOWN_PAYMENT_YN,
           fin_kle.residual_value,
           fin_kle.residual_percentage
    from
           okl_k_lines       fin_kle,
           okc_k_lines_b     fin_cleb
    where  fin_kle.id          = fin_cleb.id
    and    fin_cleb.id         = p_cle_id
    and    fin_cleb.chr_id     = p_chr_id
    and    fin_cleb.dnz_chr_id = p_chr_id;

    l_cle_rec     l_cle_csr%ROWTYPE;

    --cursor to get asset id from fa
    cursor l_fab_csr (p_asset_number in varchar2) is
    select asset_id
    from   fa_additions_b
    where  asset_number  = p_Asset_number;

    l_asset_id  fa_additions_b.asset_id%TYPE;

    --cursor to check if contract has re-lease assets
    CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
    SELECT 'Y',
           --Bug# 4631549
           chr.orig_system_source_code,
           chr.orig_system_id1 orig_chr_id,
           chr.start_date
    FROM   okc_k_headers_b CHR,
           okc_rules_b     rul
    WHERE  CHR.ID = p_chr_id
    AND    rul.dnz_chr_id = CHR.id
    AND    rul.rule_information_category = 'LARLES'
    AND    NVL(rule_information1,'N') = 'Y';

    l_chk_rel_ast   Varchar2(1) default 'N';
    --Bug# 4631549
    l_orig_system_source_code OKC_K_HEADERS_B.orig_system_source_code%TYPE;
    l_orig_chr_id             OKC_K_HEADERS_B.ID%TYPE;
    l_start_date              OKC_K_HEADERS_B.START_DATE%TYPE;

    l_rel_ast_clev_fin_rec      clev_rec_type;
    l_rel_ast_klev_fin_rec      klev_rec_type;
    l_rel_ast_clev_model_rec    clev_rec_type;
    l_rel_ast_klev_model_rec    klev_rec_type;
    l_rel_ast_clev_fa_rec       clev_rec_type;
    l_rel_ast_klev_fa_rec       klev_rec_type;
    l_rel_ast_clev_ib_tbl       clev_tbl_type;
    l_rel_ast_klev_ib_tbl       klev_tbl_type;
    --End Bug# 3533936

    --Bug# 4161221: start
    CURSOR c_addon_line_id(p_model_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           p_chr_id       OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM  okc_k_lines_b cle,
          okc_line_styles_b lse
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_ADDON_LINE_LTY_CODE
    AND cle.cle_id = p_model_cle_id;

    r_cimv_addon_rec             cimv_rec_type;
    rx_cimv_addon_rec            cimv_rec_type;
    --Bug# 4161221: end


    --Bug# 4899328
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

    l_line_capital_amount  okl_k_lines.capital_amount%TYPE;

  --Bug# 4631549
  cursor l_orig_cle_csr (p_cle_id in number
                         ) is
  select cleb.orig_system_id1 orig_cle_id
  from   okc_k_lines_b cleb
  where  cleb.id   = p_cle_id;

  l_orig_cle_rec l_orig_cle_csr%ROWTYPE;

  cursor l_fbk_csr (p_asset_id in number) is
  select fab.book_type_code
  from   fa_books fab,
         fa_book_controls fbc
  where  fab.asset_id = p_asset_id
  and    fab.transaction_header_id_out is null
  and    fab.book_type_code = fbc.book_type_code
  and    fbc.book_class = 'CORPORATE';

  l_fbk_rec l_fbk_csr%ROWTYPE;

  l_corp_net_book_value number;
  l_expected_cost       number;

  l_clev_fin_rec2        okl_okc_migration_pvt.clev_rec_type;
  lx_clev_fin_rec2       okl_okc_migration_pvt.clev_rec_type;
  l_klev_fin_rec2        okl_contract_pub.klev_rec_type;
  lx_klev_fin_rec2       okl_contract_pub.klev_rec_type;
  --End Bug# 4631549
  BEGIN

    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
--start:|           14-May-2008 cklee  Bug 6405415               				     |
    IF p_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM and
       p_klev_fin_rec.residual_percentage IS NOT NULL THEN
      IF NOT p_klev_fin_rec.residual_percentage between 0 and 100 THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => 'OKL_VALID_RESIDUAL_PERCENT');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
--end:|           14-May-2008 cklee  Bug 6405415               				     |

    --Bug# 4959361
    OKL_LLA_UTIL_PVT.check_line_update_allowed
      (p_api_version     => p_api_version,
       p_init_msg_list   => p_init_msg_list,
       x_return_status   => x_return_status,
       x_msg_count       => x_msg_count,
       x_msg_data        => x_msg_data,
       p_cle_id          => p_clev_fin_rec.id);

    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4959361

    l_new_yn         := p_new_yn;
    l_clev_fin_rec   := p_clev_fin_rec;
    l_klev_fin_rec   := p_klev_fin_rec;

    --Bug# 6888733: start

    if l_klev_fin_rec.RESIDUAL_GRNTY_AMOUNT = fnd_api.g_miss_num then
      l_klev_fin_rec.RESIDUAL_GRNTY_AMOUNT := null;
    end if;

    --Bug# 6888733: end

    l_clev_model_rec := p_clev_model_rec;
    l_cimv_model_rec := p_cimv_model_rec;
    l_clev_fa_rec    := p_clev_fa_rec;
    l_cimv_fa_rec    := p_cimv_fa_rec;
    l_talv_fa_rec    := p_talv_fa_rec;
    l_itiv_inst_rec  := p_itiv_ib_rec;
    l_clev_ib_rec    := p_clev_ib_rec;
    l_itiv_ib_rec    := p_itiv_ib_rec;
    IF (l_clev_fin_rec.dnz_chr_id IS NULL OR
       l_clev_fin_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V.DNZ_CHR_ID for All Lines');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    ------------------------------------------------------
    --Bug# 3533936 : Release Asset Case - all line details
    -- should default from exising asset
    ------------------------------------------------------
    l_chk_rel_ast := 'N';
    Open l_chk_rel_ast_csr(p_chr_id => l_clev_fin_rec.dnz_chr_id);
    FETCH l_chk_rel_ast_csr INTO l_chk_rel_ast,
                                 --Bug# 4631549
                                 l_orig_system_source_code,
                                 l_orig_chr_id,
                                 l_start_date;
    If l_chk_rel_ast_csr%NOTFOUND then
        null;
    end if;
    close l_chk_rel_ast_csr;

    If l_new_yn   = 'N'  And l_chk_rel_ast = 'Y' Then

        open l_fab_csr(p_asset_number => p_asset_number );
        fetch l_fab_csr into l_asset_id;
        If l_fab_csr%NOTFOUND then
           --error invalid line
           NULL;
        End If;
        close l_fab_csr;


        If l_klev_fin_rec.id  = OKL_API.G_MISS_NUM then
            l_klev_fin_rec.id := l_clev_fin_rec.id;
        End If;


        l_itiv_ib_tbl(1) := l_itiv_ib_rec;

        --Bug# 4631549
        If nvl(l_orig_system_source_code,okl_api.g_miss_char) <> 'OKL_RELEASE' Then
        update_release_asset_line
            (p_api_version     => p_api_version,
             p_init_msg_list   => p_init_msg_list,
             x_return_status   => x_return_status,
             x_msg_count       => x_msg_count,
             x_msg_data        => x_msg_data,
             p_asset_id        => to_char(l_asset_id),
             p_chr_id          => l_clev_fin_rec.dnz_chr_id,
             p_clev_fin_id     => l_clev_fin_rec.id,
             x_cle_id          => l_rel_ast_fin_cle_id);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;



        Modify_Release_Asset_Line(
            p_api_version    =>  p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_clev_fin_rec   => l_clev_fin_rec,
            p_klev_fin_rec   => l_klev_fin_rec,
	     --akrangan Bug# 5362977 start
            p_clev_model_rec => l_clev_model_rec,
            --akrangan Bug# 5362977 end
            p_cimv_model_rec => l_cimv_model_rec,
            p_clev_fa_rec    => l_clev_fa_rec,
            p_cimv_fa_rec    => l_cimv_fa_rec,
            p_talv_fa_rec    => l_talv_fa_rec,
            p_itiv_ib_tbl    => l_itiv_ib_tbl,
            p_cle_id         => l_rel_ast_fin_cle_id,
            --Bug# 4631549
            p_call_mode      => 'RELEASE_ASSET',
            x_clev_fin_rec   => l_rel_ast_clev_fin_rec,
            x_klev_fin_rec   => l_rel_ast_klev_fin_rec,
            x_clev_model_rec => l_rel_ast_clev_model_rec,
            x_klev_model_rec => l_rel_ast_klev_model_rec,
            x_clev_fa_rec    => l_rel_ast_clev_fa_rec,
            x_klev_fa_rec    => l_rel_ast_klev_fa_rec,
            x_clev_ib_tbl    => l_rel_ast_clev_ib_tbl,
            x_klev_ib_tbl    => l_rel_ast_klev_ib_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        x_clev_fin_rec   := l_rel_ast_clev_fin_rec;
        x_clev_model_rec := l_rel_ast_clev_model_rec;
        x_clev_fa_rec    := l_rel_ast_clev_fa_rec;
        If l_rel_ast_clev_ib_tbl.COUNT > 0 then
            x_clev_ib_rec    := l_rel_ast_clev_ib_tbl(1);
        End If;

        --Bug# 4631549
        ElsIf nvl(l_orig_system_source_code,OKL_API.G_MISS_CHAR) = 'OKL_RELEASE' Then

           Modify_Release_Asset_Line(
            p_api_version    =>  p_api_version,
            p_init_msg_list  => p_init_msg_list,
            x_return_status  => x_return_status,
            x_msg_count      => x_msg_count,
            x_msg_data       => x_msg_data,
            p_clev_fin_rec   => l_clev_fin_rec,
            p_klev_fin_rec   => l_klev_fin_rec,
	     --akrangan Bug# 5362977 start
            p_clev_model_rec => l_clev_model_rec,
            --akrangan Bug# 5362977 end
            p_cimv_model_rec => l_cimv_model_rec,
            p_clev_fa_rec    => l_clev_fa_rec,
            p_cimv_fa_rec    => l_cimv_fa_rec,
            p_talv_fa_rec    => l_talv_fa_rec,
            p_itiv_ib_tbl    => l_itiv_ib_tbl,
            p_cle_id         => l_clev_fin_rec.id,
            --Bug# 4631549
            p_call_mode      => 'RELEASE_CONTRACT',
            x_clev_fin_rec   => l_rel_ast_clev_fin_rec,
            x_klev_fin_rec   => l_rel_ast_klev_fin_rec,
            x_clev_model_rec => l_rel_ast_clev_model_rec,
            x_klev_model_rec => l_rel_ast_klev_model_rec,
            x_clev_fa_rec    => l_rel_ast_clev_fa_rec,
            x_klev_fa_rec    => l_rel_ast_klev_fa_rec,
            x_clev_ib_tbl    => l_rel_ast_clev_ib_tbl,
            x_klev_ib_tbl    => l_rel_ast_klev_ib_tbl);

        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        x_clev_fin_rec   := l_rel_ast_clev_fin_rec;
        x_clev_model_rec := l_rel_ast_clev_model_rec;
        x_clev_fa_rec    := l_rel_ast_clev_fa_rec;
        IF l_rel_ast_clev_ib_tbl.COUNT > 0 THEN
            x_clev_ib_rec    := l_rel_ast_clev_ib_tbl(1);
        END IF;
            open l_orig_cle_csr (p_cle_id => x_clev_fin_rec.id);
            fetch l_orig_cle_csr into l_orig_cle_rec;
            close l_orig_cle_csr;

            open l_fbk_csr (p_asset_id => l_asset_id);
            fetch l_fbk_csr into l_fbk_rec;
            close l_fbk_csr;

            OKL_RELEASE_PVT.Calculate_Expected_Cost
                               (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_new_chr_id     => x_clev_fin_rec.dnz_chr_id,
                                p_orig_chr_id    => l_orig_chr_id,
                                p_orig_cle_id    => l_orig_cle_rec.orig_cle_id,
                                p_asset_id       => l_asset_id,
                                p_book_type_code => l_fbk_rec.book_type_code,
                                p_release_date   => l_start_date,
                                p_nbv            => l_corp_net_book_value,
                                x_expected_cost  => l_expected_cost);

            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            END IF;

            l_clev_fin_rec2.id := x_clev_fin_rec.id;
            l_klev_fin_rec2.id := x_clev_fin_rec.id;
            l_klev_fin_rec2.expected_asset_cost := l_expected_cost;

            OKL_CONTRACT_PUB.update_contract_line
                                (p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_clev_rec       => l_clev_fin_rec2,
                                p_klev_rec       => l_klev_fin_rec2,
                                x_clev_rec       => lx_clev_fin_rec2,
                                x_klev_rec       => lx_klev_fin_rec2);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             END IF;
         End If;
         --End Bug# 4631549

    Else
    --End Bug# 3533936



    -- Check for Required Values
    x_return_status := check_required_values(p_item1    => l_cimv_model_rec.object1_id1,
                                             p_item2    => l_cimv_model_rec.object1_id2,
                                             p_ast_no   => l_talv_fa_rec.asset_number,
                                             p_ast_desc => l_talv_fa_rec.description,
                                             p_cost     => l_talv_fa_rec.original_cost,
                                             p_units    => l_talv_fa_rec.current_units,
                                             p_ib_loc1  => l_itiv_ib_rec.object_id1_new,
                                             p_ib_loc2  => l_itiv_ib_rec.object_id2_new,
                                             p_fa_loc   => l_talv_fa_rec.fa_location_id,
                                             p_refinance_amount => l_klev_fin_rec.refinance_amount,
                                             p_chr_id   => l_clev_fin_rec.dnz_chr_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the txlv fa Line Record
    x_return_status := get_rec_txlv(l_clev_fa_rec.id,
                                    r_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (l_talv_fa_rec.asset_number IS NUll OR
        l_talv_fa_rec.asset_number = OKL_API.G_MISS_CHAR) THEN
        l_talv_fa_rec.asset_number  := r_talv_fa_rec.asset_number;
--    ELSIF l_talv_fa_rec.asset_number = r_talv_fa_rec.asset_number THEN
--        l_new_yn  := 'N';
    END IF;
    IF (l_talv_fa_rec.original_cost IS NUll OR
        l_talv_fa_rec.original_cost = OKL_API.G_MISS_NUM) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V.ORIGINAL_COST');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (l_talv_fa_rec.current_units IS NUll OR
        l_talv_fa_rec.current_units = OKL_API.G_MISS_NUM) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V.CURRENT_UNITS');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_clev_model_rec.price_unit         := l_talv_fa_rec.original_cost;
    l_clev_fa_rec.price_unit            := l_talv_fa_rec.original_cost;
    l_cimv_model_rec.number_of_items    := l_talv_fa_rec.current_units;
    l_cimv_fa_rec.number_of_items       := l_talv_fa_rec.current_units;
    -- To Get the kle top Line Record
    x_return_status := get_rec_clev(l_clev_fin_rec.id,
                                    r_clev_fin_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle top Line Record
    x_return_status := get_rec_klev(l_clev_fin_rec.id,
                                    r_klev_fin_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_clev_fin_rec.id <> r_klev_fin_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build the clev Top Line Record
    l_clev_fin_rec.cle_id           := null;
    IF (l_clev_fin_rec.chr_id IS NUll OR
       l_clev_fin_rec.chr_id = OKL_API.G_MISS_NUM) THEN
       l_clev_fin_rec.chr_id  := r_clev_fin_rec.chr_id;
    END IF;
    IF (l_clev_fin_rec.name IS NUll OR
       l_clev_fin_rec.name = OKL_API.G_MISS_CHAR) AND
       (r_clev_fin_rec.name <> p_asset_number) THEN
       l_clev_fin_rec.name  := p_asset_number;
    END IF;
    IF (l_clev_fin_rec.exception_yn IS NUll OR
       l_clev_fin_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
       l_clev_fin_rec.exception_yn  := r_clev_fin_rec.exception_yn;
    END IF;
    IF (l_clev_fin_rec.display_sequence IS NUll OR
       l_clev_fin_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
       l_clev_fin_rec.display_sequence := r_clev_fin_rec.display_sequence;
    END IF;
    IF (l_clev_fin_rec.lse_id IS NUll OR
       l_clev_fin_rec.lse_id = OKL_API.G_MISS_NUM) THEN
       l_clev_fin_rec.lse_id := r_clev_fin_rec.lse_id;
    END IF;
    IF (l_clev_fin_rec.line_number IS NUll OR
       l_clev_fin_rec.line_number = OKL_API.G_MISS_CHAR) THEN
       l_clev_fin_rec.line_number := r_clev_fin_rec.line_number;
    END IF;
    IF (l_clev_fin_rec.sts_code IS NUll OR
       l_clev_fin_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
       l_clev_fin_rec.sts_code  := r_clev_fin_rec.sts_code;
    END IF;
    --Build the klev Top Line Record
    IF l_new_yn = 'Y' THEN
       ln_clev_model_price_unit := abs(l_talv_fa_rec.original_cost);
       ln_cimv_model_no_items   := l_talv_fa_rec.current_units;
    ELSIF l_new_yn = 'N' THEN
       IF l_clev_model_rec.price_unit = OKL_API.G_MISS_NUM THEN
          l_clev_model_rec.price_unit := null;
       END IF;
       IF l_cimv_model_rec.number_of_items = OKL_API.G_MISS_NUM THEN
          l_cimv_model_rec.number_of_items := null;
       END IF;
       ln_clev_model_price_unit := abs(l_talv_fa_rec.original_cost);
       ln_cimv_model_no_items   := l_talv_fa_rec.current_units;
       -- we need to modify the code, let it go a temp
--       ln_clev_model_price_unit := nvl(l_clev_model_rec.price_unit,0);
--       ln_cimv_model_no_items   := nvl(l_cimv_model_rec.number_of_items,0);
    END IF;
    l_klev_fin_rec.id := r_klev_fin_rec.id;

    l_clev_fin_rec.item_description := l_talv_fa_rec.description;
    -- Update of the Financial Asset Line
    update_fin_line(p_api_version   => p_api_version,
                    p_init_msg_list => p_init_msg_list,
                    x_return_status => x_return_status,
                    x_msg_count     => x_msg_count,
                    x_msg_data      => x_msg_data,
                    P_new_yn        => l_new_yn,
                    p_asset_number  => p_asset_number,
                    p_clev_rec      => l_clev_fin_rec,
                    p_klev_rec      => l_klev_fin_rec,
                    x_clev_rec      => x_clev_fin_rec,
                    x_klev_rec      => l_klev_fin_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --We have to build the Model Line Record for the calculations of the
    -- oec of the top line
    -- To Get the cle Model Line Record
    x_return_status := get_rec_clev(l_clev_model_rec.id,
                                    r_clev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle Model Line Record
    x_return_status := get_rec_klev(l_clev_model_rec.id,
                                    r_klev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_model_rec.id <> r_clev_model_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Build clev Model Line Record
    l_clev_model_rec.chr_id          := null;
    IF (l_clev_model_rec.cle_id IS NUll OR
        l_clev_model_rec.cle_id = OKL_API.G_MISS_NUM) THEN
        l_clev_model_rec.cle_id  := r_clev_model_rec.cle_id;
    END IF;
    IF (l_clev_model_rec.dnz_chr_id IS NUll OR
        l_clev_model_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
        l_clev_model_rec.dnz_chr_id  := r_clev_model_rec.dnz_chr_id;
    END IF;
    IF (l_clev_model_rec.lse_id IS NUll OR
        l_clev_model_rec.lse_id = OKL_API.G_MISS_NUM) THEN
        l_clev_model_rec.lse_id  := r_clev_model_rec.lse_id;
    END IF;
    IF (l_clev_model_rec.display_sequence IS NUll OR
        l_clev_model_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
        l_clev_model_rec.display_sequence  := r_clev_model_rec.display_sequence;
    END IF;
    IF (l_clev_model_rec.exception_yn IS NUll OR
        l_clev_model_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
        l_clev_model_rec.exception_yn  := r_clev_model_rec.exception_yn;
    END IF;
    IF (l_clev_model_rec.line_number IS NUll OR
        l_clev_model_rec.line_number = OKL_API.G_MISS_CHAR) THEN
        l_clev_model_rec.line_number  := r_clev_model_rec.line_number;
    END IF;
    IF (l_clev_model_rec.sts_code IS NUll OR
        l_clev_model_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
        l_clev_model_rec.sts_code  := r_clev_model_rec.sts_code;
    END IF;
    -- Build klev Model Line Record
    l_klev_model_rec := r_klev_model_rec;
    -- To Get the cimv Model Line Record
    x_return_status := get_rec_cimv(l_clev_model_rec.id,
                                    l_clev_model_rec.dnz_chr_id,
                                    r_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build Model cimv item rec
    l_cimv_model_rec.id  := r_cimv_model_rec.id;
    IF (l_cimv_model_rec.exception_yn IS NUll OR
        l_cimv_model_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
        l_cimv_model_rec.exception_yn  := r_cimv_model_rec.exception_yn;
    END IF;
    IF (l_cimv_model_rec.dnz_chr_id IS NUll OR
        l_cimv_model_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
        l_cimv_model_rec.dnz_chr_id  := r_cimv_model_rec.dnz_chr_id;
    END IF;
    IF (l_cimv_model_rec.cle_id IS NUll OR
        l_cimv_model_rec.cle_id = OKL_API.G_MISS_NUM) THEN
        l_cimv_model_rec.cle_id := r_cimv_model_rec.cle_id;
    END IF;
    -- We need to check the below since we do not have to call the formula
    -- Engine avery time. Which means that we have to call the formula Engine
    -- only if the price unit and number of items change.
/*
    IF l_clev_model_rec.price_unit      <> r_clev_model_rec.price_unit AND
       l_cimv_model_rec.number_of_items <> r_cimv_model_rec.number_of_items THEN
       l_klev_fin_rec.residual_percentage <> r_klev_fin_rec.residual_percentage AND
       l_klev_fin_rec.residual_value <> r_klev_fin_rec.residual_value THEN
       l_go_for_calc := 'Y';
    ELSIF l_clev_model_rec.price_unit   <> r_clev_model_rec.price_unit OR
       l_cimv_model_rec.number_of_items <> r_cimv_model_rec.number_of_items THEN
       l_klev_fin_rec.residual_percentage <> r_klev_fin_rec.residual_percentage OR
       l_klev_fin_rec.residual_value <> r_klev_fin_rec.residual_value THEN
       l_go_for_calc := 'Y';
    ELSE
       l_go_for_calc := 'N';
    END IF;
*/
    -- Updating of the Model Line and Item Record
    update_model_line(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      P_new_yn        => l_new_yn,
                      p_asset_number  => p_asset_number,
                      p_clev_rec      => l_clev_model_rec,
                      p_klev_rec      => l_klev_model_rec,
                      p_cimv_rec      => l_cimv_model_rec,
                      x_clev_rec      => x_clev_model_rec,
                      x_klev_rec      => l_klev_model_rec_out,
                      x_cimv_rec      => l_cimv_model_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 4161221: start
    -- Update No. of Units on Add-on line when there is a change in the
    -- No. of Units on Asset line.
    FOR r_addon_line_id IN c_addon_line_id(p_model_cle_id => x_clev_model_rec.id,
                                           p_chr_id => x_clev_model_rec.dnz_chr_id) LOOP

      -- To Get the cimv Addon Line Record
      x_return_status := get_rec_cimv(r_addon_line_id.id,
                                      x_clev_model_rec.dnz_chr_id,
                                      r_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;

      IF (NVL(r_cimv_addon_rec.number_of_items,0) <>
          NVL(l_cimv_model_rec_out.number_of_items,0)) THEN

        --Build addon cimv item rec
        r_cimv_addon_rec.number_of_items  := l_cimv_model_rec_out.number_of_items;
        -- Updating of the addon Item Record

        OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                   p_init_msg_list => p_init_msg_list,
                                                   x_return_status => x_return_status,
                                                   x_msg_count     => x_msg_count,
                                                   x_msg_data      => x_msg_data,
                                                   p_cimv_rec      => r_cimv_addon_rec,
                                                   x_cimv_rec      => rx_cimv_addon_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UPDATING_ADDON_ITEM);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_UPDATING_ADDON_ITEM);
            RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Bug# 4161221: end

    lv_model_object_id1  := l_cimv_model_rec_out.object1_id1;
    lv_model_object_id2  := l_cimv_model_rec_out.object1_id2;
    IF l_go_for_calc = 'Y' THEN
      -- Calculate the OEC to Populate the OKL_K_LINES_V.OEC
      oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           P_new_yn             => P_new_yn,
                           p_asset_number       => p_asset_number,
			   -- 4414408
                           p_top_line_id        => l_clev_fin_rec.id,
                           p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                           x_fin_clev_rec       => x_clev_fin_rec,
                           x_fin_klev_rec       => l_klev_fin_rec_out,
                           x_oec                => ln_klev_fin_oec,
                           p_validate_fin_line  => OKL_API.G_TRUE);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
      cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => l_clev_fin_rec.id,
                               p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                               x_fin_clev_rec       => x_clev_fin_rec,
                               x_fin_klev_rec       => l_klev_fin_rec_out,
                               x_cap_amt            => ln_klev_fin_cap,
                               p_validate_fin_line  => OKL_API.G_TRUE);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_klev_fin_rec.residual_percentage = OKL_API.G_MISS_NUM THEN
        l_klev_fin_rec.residual_percentage := null;
      ELSIF l_klev_fin_rec.residual_value = OKL_API.G_MISS_NUM THEN
        l_klev_fin_rec.residual_value := null;
      END IF;
      -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
      IF (l_klev_fin_rec.residual_percentage IS NOT NULL OR
         l_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM) AND
         (l_klev_fin_rec.residual_value IS NOT NULL OR
         l_klev_fin_rec.residual_value <> OKL_API.G_MISS_NUM) THEN
         IF l_klev_fin_rec.residual_value <> r_klev_fin_rec.residual_value THEN

           l_top_line_id := x_clev_fin_rec.id;
           l_oec := l_klev_fin_rec_out.oec;

           get_res_per_upd_fin_rec(p_api_version        => p_api_version,
                                   p_init_msg_list      => p_init_msg_list,
                                   x_return_status      => x_return_status,
                                   x_msg_count          => x_msg_count,
                                   x_msg_data           => x_msg_data,
                                   P_new_yn             => P_new_yn,
                                   p_asset_number       => p_asset_number,
                                   p_res_value          => l_klev_fin_rec.residual_value,
                                   p_oec                => l_oec,  --l_klev_fin_rec_out.oec
                                   p_top_line_id        => l_top_line_id, --x_clev_fin_rec.id,
                                   p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                   x_fin_clev_rec       => x_clev_fin_rec,
                                   x_fin_klev_rec       => l_klev_fin_rec_out,
                                   p_validate_fin_line  => OKL_API.G_TRUE);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         ELSIF l_klev_fin_rec.residual_percentage <> r_klev_fin_rec.residual_percentage THEN
           res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                      p_init_msg_list      => p_init_msg_list,
                                      x_return_status      => x_return_status,
                                      x_msg_count          => x_msg_count,
                                      x_msg_data           => x_msg_data,
                                      P_new_yn             => P_new_yn,
                                      p_asset_number       => p_asset_number,
				      -- 4414408
                                      p_top_line_id        => x_clev_model_rec.cle_id,
                                      p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                      x_fin_clev_rec       => x_clev_fin_rec,
                                      x_fin_klev_rec       => l_klev_fin_rec_out,
                                      x_res_value          => ln_klev_fin_res,
                                      p_validate_fin_line  => OKL_API.G_TRUE);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
         END IF;
      ELSIF (l_klev_fin_rec.residual_percentage IS NULL OR
        l_klev_fin_rec.residual_percentage = OKL_API.G_MISS_NUM) AND
        (l_klev_fin_rec.residual_value IS NOT NULL OR
        l_klev_fin_rec.residual_value <> OKL_API.G_MISS_NUM) THEN

        l_top_line_id := x_clev_fin_rec.id;
        l_oec := l_klev_fin_rec_out.oec;

        get_res_per_upd_fin_rec(p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                P_new_yn             => P_new_yn,
                                p_asset_number       => p_asset_number,
                                p_res_value          => l_klev_fin_rec.residual_value,
                                p_oec                => l_oec,  --l_klev_fin_rec_out.oec
                                p_top_line_id        => l_top_line_id, --x_clev_fin_rec.id,
                                p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                x_fin_clev_rec       => x_clev_fin_rec,
                                x_fin_klev_rec       => l_klev_fin_rec_out,
                                p_validate_fin_line  => OKL_API.G_TRUE);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      ELSIF (l_klev_fin_rec.residual_percentage IS NOT NULL OR
        l_klev_fin_rec.residual_percentage <> OKL_API.G_MISS_NUM) AND
        (l_klev_fin_rec.residual_value IS NULL OR
        l_klev_fin_rec.residual_value = OKL_API.G_MISS_NUM) THEN
        res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                                   p_init_msg_list      => p_init_msg_list,
                                   x_return_status      => x_return_status,
                                   x_msg_count          => x_msg_count,
                                   x_msg_data           => x_msg_data,
                                   P_new_yn             => P_new_yn,
                                   p_asset_number       => p_asset_number,
				   -- 4414408
                                   p_top_line_id        => x_clev_model_rec.cle_id,
                                   p_dnz_chr_id         => x_clev_model_rec.dnz_chr_id,
                                   x_fin_clev_rec       => x_clev_fin_rec,
                                   x_fin_klev_rec       => l_klev_fin_rec_out,
                                   x_res_value          => ln_klev_fin_res,
                                   p_validate_fin_line  => OKL_API.G_TRUE);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
    END IF;
    IF (l_klev_fin_rec_out.oec IS NOT NULL OR
       l_klev_fin_rec_out.oec <> OKL_API.G_MISS_NUM) AND
       (l_klev_fin_rec_out.residual_value IS NOT NULL OR
       l_klev_fin_rec_out.residual_value <> OKL_API.G_MISS_NUM) THEN
      IF l_klev_fin_rec_out.residual_value > l_klev_fin_rec_out.oec THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_SALVAGE_VALUE);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Updating of the Fixed Asset Line Process
    -- To Get the cle fa Line Record
    x_return_status := get_rec_clev(l_clev_fa_rec.id,
                                    r_clev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle fa Line Record
    x_return_status := get_rec_klev(l_clev_fa_rec.id,
                                    r_klev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_fa_rec.id <> r_clev_fa_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Build clev fa Line Record
    l_clev_fa_rec.chr_id          := null;
    IF (l_clev_fa_rec.cle_id IS NUll OR
        l_clev_fa_rec.cle_id = OKL_API.G_MISS_NUM) THEN
        l_clev_fa_rec.cle_id  := r_clev_fa_rec.cle_id;
    END IF;
    IF (l_clev_fa_rec.dnz_chr_id IS NUll OR
        l_clev_fa_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
        l_clev_fa_rec.dnz_chr_id  := r_clev_fa_rec.dnz_chr_id;
    END IF;
    IF (l_clev_fa_rec.display_sequence IS NUll OR
        l_clev_fa_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
        l_clev_fa_rec.display_sequence  := r_clev_fa_rec.display_sequence;
    END IF;
    IF (l_clev_fa_rec.lse_id IS NUll OR
        l_clev_fa_rec.lse_id = OKL_API.G_MISS_NUM) THEN
        l_clev_fa_rec.lse_id  := r_clev_fa_rec.lse_id;
    END IF;
    IF (l_clev_fa_rec.exception_yn IS NUll OR
        l_clev_fa_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
        l_clev_fa_rec.exception_yn  := r_clev_fa_rec.exception_yn;
    END IF;
    IF (l_clev_fa_rec.line_number IS NUll OR
        l_clev_fa_rec.line_number = OKL_API.G_MISS_CHAR) THEN
        l_clev_fa_rec.line_number  := r_clev_fa_rec.line_number;
    END IF;
    IF (l_clev_fa_rec.sts_code IS NUll OR
        l_clev_fa_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
        l_clev_fa_rec.sts_code  := r_clev_fa_rec.sts_code;
    END IF;
    -- Build klev fa Line Record
    l_klev_fa_rec := r_klev_fa_rec;
    -- To Get the cimv fa Line Record
    x_return_status := get_rec_cimv(l_clev_fa_rec.id,
                                    l_clev_fa_rec.dnz_chr_id,
                                    r_cimv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build cimv fa item rec
    l_cimv_fa_rec.id  := r_cimv_fa_rec.id;
    IF (l_cimv_fa_rec.exception_yn IS NUll OR
        l_cimv_fa_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
        l_cimv_fa_rec.exception_yn  := r_cimv_fa_rec.exception_yn;
    END IF;
    IF (l_cimv_fa_rec.dnz_chr_id IS NUll OR
        l_cimv_fa_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
        l_cimv_fa_rec.dnz_chr_id  := r_cimv_fa_rec.dnz_chr_id;
    END IF;
    IF (l_cimv_fa_rec.cle_id IS NUll OR
        l_cimv_fa_rec.cle_id = OKL_API.G_MISS_NUM) THEN
        l_cimv_fa_rec.cle_id := r_cimv_fa_rec.cle_id;
    END IF;
    IF (l_cimv_fa_rec.object1_id1 IS NUll OR
        l_cimv_fa_rec.object1_id1 = OKL_API.G_MISS_CHAR) THEN
        l_cimv_fa_rec.object1_id1 := null;
    ELSE
        l_cimv_fa_rec.object1_id1 := r_cimv_ib_rec.cle_id;
    END IF;
    IF (l_cimv_fa_rec.object1_id2 IS NUll OR
        l_cimv_fa_rec.object1_id2 = OKL_API.G_MISS_CHAR) THEN
        l_cimv_fa_rec.object1_id2 := null;
    ELSE
        l_cimv_fa_rec.object1_id2 := r_cimv_ib_rec.cle_id;
    END IF;
    --Build talv fa item rec
    l_talv_fa_rec.id                    := r_talv_fa_rec.id;
    l_talv_fa_rec.object_version_number := r_talv_fa_rec.object_version_number;
    l_talv_fa_rec.tas_id                := r_talv_fa_rec.tas_id;
    l_talv_fa_rec.sfwt_flag             := r_talv_fa_rec.sfwt_flag;
    l_talv_fa_rec.tal_type              := r_talv_fa_rec.tal_type;
    l_talv_fa_rec.line_number           := r_talv_fa_rec.line_number;
    l_talv_fa_rec.asset_number          := p_asset_number;
    IF (l_talv_fa_rec.kle_id IS NUll OR
        l_talv_fa_rec.kle_id = OKL_API.G_MISS_NUM) THEN
        l_talv_fa_rec.kle_id  := r_talv_fa_rec.kle_id;
    END IF;
    IF (l_talv_fa_rec.original_cost IS NUll OR
        l_talv_fa_rec.original_cost = OKL_API.G_MISS_NUM) THEN
        l_talv_fa_rec.original_cost  := r_talv_fa_rec.original_cost;
    END IF;
    IF (l_talv_fa_rec.depreciation_cost IS NUll OR
        l_talv_fa_rec.depreciation_cost = OKL_API.G_MISS_NUM) THEN
        l_talv_fa_rec.depreciation_cost  := r_talv_fa_rec.depreciation_cost;
    END IF;

    IF (l_talv_fa_rec.description IS NUll OR
        l_talv_fa_rec.description = OKL_API.G_MISS_CHAR) THEN
        l_talv_fa_rec.description  := r_talv_fa_rec.description;
    END IF;
    IF (l_talv_fa_rec.current_units IS NUll OR
        l_talv_fa_rec.current_units = OKL_API.G_MISS_NUM) THEN
        l_talv_fa_rec.current_units  := r_talv_fa_rec.current_units;
    END IF;

    --Bug# 4899328: For online rebook, update depreciation_cost and
    -- original_cost to line capital amount instead of line oec
    --check for rebook contract
    l_rbk_khr := '?';
    OPEN l_chk_rbk_csr (p_chr_id => l_clev_fin_rec.dnz_chr_id);
    FETCH l_chk_rbk_csr INTO l_rbk_khr;
    CLOSE l_chk_rbk_csr;

    If l_rbk_khr = '!' Then

      l_line_capital_amount := NVL(l_klev_fin_rec_out.capital_amount,ln_klev_fin_cap);
      l_talv_fa_rec.depreciation_cost := NVL(l_line_capital_amount,l_talv_fa_rec.depreciation_cost);
      l_talv_fa_rec.original_cost  := NVL(l_line_capital_amount,l_talv_fa_rec.original_cost);

    Else
      -- We are doing the below to make sure the oec is euqated to depreciation cost
      -- and the original cost.
      l_talv_fa_rec.depreciation_cost := NVL(l_klev_fin_rec_out.oec,l_talv_fa_rec.depreciation_cost);
      l_talv_fa_rec.original_cost  := NVL(l_klev_fin_rec_out.oec,ln_klev_fin_oec);
    End If;
    --Bug# 4899328: End

    l_clev_fa_rec.item_description := l_talv_fa_rec.description;
    -- A Bug fix Since we populate the year manufactured into OKL_TXL_ASSETS_B only
    -- We cannot use the information after the assets have been put into FA
    -- So we decided to populate the year Manufactured into OKL_K_LINES.YEAR_BUILT
    -- As the Datatype matches for both.
    l_klev_fa_rec.Year_Built           := l_talv_fa_rec.year_manufactured;
    -- Updating of the Fixed Asset Line and item/Txl Asset Info

    -- start NISINHA Bug# 6490572
    l_klev_fa_rec.model_number         := l_talv_fa_rec.model_number;
    l_klev_fa_rec.manufacturer_name    := l_talv_fa_rec.manufacturer_name;
    --end  NISINHA Bug# 6490572
    update_fixed_asset_line(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => l_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => l_clev_fa_rec,
                            p_klev_rec      => l_klev_fa_rec,
                            p_cimv_rec      => l_cimv_fa_rec,
                            p_talv_rec      => l_talv_fa_rec,
                            x_clev_rec      => x_clev_fa_rec,
                            x_klev_rec      => l_klev_fa_rec_out,
                            x_cimv_rec      => l_cimv_fa_rec_out,
                            x_talv_rec      => l_talv_fa_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Updating Asset Lines Details Asset Number
    update_asset_line_details(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_asset_number  => p_asset_number,
                              p_original_cost => l_talv_fa_rec_out.original_cost,
                              p_tal_id        => l_talv_fa_rec_out.ID);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF p_new_yn = 'Y' THEN
      -- Updating of the Install Base Line Process
      -- To Get the cle IB Line Record
      x_return_status := get_rec_clev(l_clev_ib_rec.id,
                                      r_clev_ib_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- To Get the kle IB Line Record
      x_return_status := get_rec_klev(l_clev_ib_rec.id,
                                      r_klev_ib_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF r_clev_ib_rec.id <> r_klev_ib_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_LINE_RECORD);
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Build the clev Top Line Record
      l_clev_ib_rec.chr_id := null;
      IF (l_clev_ib_rec.cle_id IS NUll OR
         l_clev_ib_rec.cle_id = OKL_API.G_MISS_NUM) THEN
         l_clev_ib_rec.cle_id  := r_clev_ib_rec.cle_id;
      END IF;
      IF (l_clev_ib_rec.dnz_chr_id IS NUll OR
         l_clev_ib_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
         l_clev_ib_rec.dnz_chr_id  := r_clev_ib_rec.dnz_chr_id;
      END IF;
      IF (l_clev_ib_rec.lse_id IS NUll OR
         l_clev_ib_rec.lse_id = OKL_API.G_MISS_NUM) THEN
         l_clev_ib_rec.lse_id  := r_clev_ib_rec.lse_id;
      END IF;
      IF (l_clev_ib_rec.display_sequence IS NUll OR
         l_clev_ib_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
         l_clev_ib_rec.display_sequence := r_clev_ib_rec.display_sequence;
      END IF;
      IF (l_clev_ib_rec.exception_yn IS NUll OR
         l_clev_ib_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
         l_clev_ib_rec.exception_yn  := r_clev_ib_rec.exception_yn;
      END IF;
      IF (l_clev_ib_rec.line_number IS NUll OR
         l_clev_ib_rec.line_number = OKL_API.G_MISS_CHAR) THEN
         l_clev_ib_rec.line_number  := r_clev_ib_rec.line_number;
      END IF;
      IF (l_clev_ib_rec.sts_code IS NUll OR
         l_clev_ib_rec.sts_code = OKL_API.G_MISS_CHAR) THEN
         l_clev_ib_rec.sts_code  := r_clev_ib_rec.sts_code;
      END IF;
      --Build the klev Top Line Record
      l_klev_ib_rec  := r_klev_ib_rec;
      -- To Get the cimv ib Line Record
      x_return_status := get_rec_cimv(l_clev_ib_rec.id,
                                      l_clev_fin_rec.dnz_chr_id,
                                      r_cimv_ib_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Build cimv ib item rec
      l_cimv_ib_rec.id  := r_cimv_ib_rec.id;
      IF (l_cimv_ib_rec.exception_yn IS NUll OR
          l_cimv_ib_rec.exception_yn = OKL_API.G_MISS_CHAR) THEN
          l_cimv_ib_rec.exception_yn  := r_cimv_ib_rec.exception_yn;
      END IF;
      IF (l_cimv_ib_rec.dnz_chr_id IS NUll OR
          l_cimv_ib_rec.dnz_chr_id = OKL_API.G_MISS_NUM) THEN
          l_cimv_ib_rec.dnz_chr_id  := r_cimv_ib_rec.dnz_chr_id;
      END IF;
      IF (l_cimv_ib_rec.cle_id IS NUll OR
          l_cimv_ib_rec.cle_id = OKL_API.G_MISS_NUM) THEN
          l_cimv_ib_rec.cle_id := r_cimv_ib_rec.cle_id;
      END IF;
      IF (l_cimv_ib_rec.cle_id IS NUll OR
          l_cimv_ib_rec.cle_id = OKL_API.G_MISS_NUM) THEN
          l_cimv_ib_rec.cle_id := r_cimv_ib_rec.cle_id;
      END IF;
      IF (l_cimv_ib_rec.cle_id IS NUll OR
          l_cimv_ib_rec.cle_id = OKL_API.G_MISS_NUM) THEN
          l_cimv_ib_rec.cle_id := r_cimv_ib_rec.cle_id;
      END IF;
      IF (l_cimv_ib_rec.object1_id1 IS NUll OR
          l_cimv_ib_rec.object1_id1 = OKL_API.G_MISS_CHAR) THEN
          l_cimv_ib_rec.object1_id1 := null;
      ELSE
          l_cimv_ib_rec.object1_id1 := r_cimv_ib_rec.cle_id;
      END IF;
      IF (l_cimv_ib_rec.object1_id2 IS NUll OR
          l_cimv_ib_rec.object1_id2 = OKL_API.G_MISS_CHAR) THEN
          l_cimv_ib_rec.object1_id2 := null;
      ELSE
          l_cimv_ib_rec.object1_id2 := r_cimv_ib_rec.cle_id;
      END IF;
      -- To Get the itiv ib Line Record
      x_return_status := get_rec_itiv(l_clev_ib_rec.id,
                                      r_itiv_ib_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_TXL_ITM_INSTS_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_TXL_ITM_INSTS_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      --Build itiv ib item rec
      l_itiv_ib_rec.id                    := r_itiv_ib_rec.id;
      l_itiv_ib_rec.object_version_number := r_itiv_ib_rec.object_version_number;
      l_itiv_ib_rec.tas_id                := r_itiv_ib_rec.tas_id;
      l_itiv_ib_rec.line_number           := r_itiv_ib_rec.line_number;
      IF (l_itiv_ib_rec.kle_id IS NUll OR
          l_itiv_ib_rec.kle_id = OKL_API.G_MISS_NUM) THEN
          l_itiv_ib_rec.kle_id  := r_itiv_ib_rec.kle_id;
      END IF;
      IF (l_itiv_ib_rec.instance_number_ib IS NUll OR
          l_itiv_ib_rec.instance_number_ib = OKL_API.G_MISS_CHAR) THEN
          l_itiv_ib_rec.instance_number_ib  := r_itiv_ib_rec.instance_number_ib;
      END IF;
      -- Since the screen can give only party_site_id via l_itiv_tbl(j).object_id1_new
      -- We have to use the below function
      lv_object_id1_new := l_itiv_ib_rec.object_id1_new;
      x_return_status := get_party_site_id(p_object_id1_new => lv_object_id1_new,
                                           x_object_id1_new => l_itiv_ib_rec.object_id1_new,
                                           x_object_id2_new => l_itiv_ib_rec.object_id2_new);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Party_site_id');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Party_site_id');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_itiv_ib_rec.object_id1_new IS NUll OR
          l_itiv_ib_rec.object_id1_new = OKL_API.G_MISS_CHAR) THEN
          l_itiv_ib_rec.object_id1_new  := r_itiv_ib_rec.object_id1_new;
      END IF;
      IF (l_itiv_ib_rec.object_id2_new IS NUll OR
          l_itiv_ib_rec.object_id2_new = OKL_API.G_MISS_CHAR) THEN
          l_itiv_ib_rec.object_id2_new  := r_itiv_ib_rec.object_id2_new;
      END IF;
      IF (l_itiv_ib_rec.jtot_object_code_new IS NUll OR
          l_itiv_ib_rec.jtot_object_code_new = OKL_API.G_MISS_CHAR) THEN
          l_itiv_ib_rec.jtot_object_code_new  := r_itiv_ib_rec.jtot_object_code_new;
      END IF;
      IF (l_itiv_ib_rec.mfg_serial_number_yn IS NUll OR
          l_itiv_ib_rec.mfg_serial_number_yn = OKL_API.G_MISS_CHAR) THEN
          l_itiv_ib_rec.mfg_serial_number_yn  := r_itiv_ib_rec.mfg_serial_number_yn;
      END IF;
      IF (l_itiv_ib_rec.inventory_item_id IS NUll OR
          l_itiv_ib_rec.inventory_item_id = OKL_API.G_MISS_NUM) AND
          lv_model_object_id1 = r_itiv_ib_rec.inventory_item_id  THEN
          l_itiv_ib_rec.inventory_item_id  := r_itiv_ib_rec.inventory_item_id;
      ELSIF (l_itiv_ib_rec.inventory_item_id IS NOT NUll OR
          l_itiv_ib_rec.inventory_item_id <> OKL_API.G_MISS_NUM) AND
          lv_model_object_id1 <> r_itiv_ib_rec.inventory_item_id THEN
          l_itiv_ib_rec.inventory_item_id  := lv_model_object_id1;
      ELSIF (l_itiv_ib_rec.inventory_item_id IS NUll OR
          l_itiv_ib_rec.inventory_item_id = OKL_API.G_MISS_NUM) OR
          lv_model_object_id1 <> r_itiv_ib_rec.inventory_item_id THEN
          l_itiv_ib_rec.inventory_item_id  := lv_model_object_id1;
      END IF;
      IF (l_itiv_ib_rec.inventory_org_id IS NUll OR
          l_itiv_ib_rec.inventory_org_id = OKL_API.G_MISS_NUM) AND
          lv_model_object_id2 = r_itiv_ib_rec.inventory_org_id THEN
          l_itiv_ib_rec.inventory_org_id  := r_itiv_ib_rec.inventory_org_id;
      ELSIF (l_itiv_ib_rec.inventory_org_id IS NOT NUll OR
          l_itiv_ib_rec.inventory_org_id <> OKL_API.G_MISS_NUM) AND
          lv_model_object_id2 <> r_itiv_ib_rec.inventory_org_id THEN
          l_itiv_ib_rec.inventory_org_id  := lv_model_object_id2;
      ELSIF (l_itiv_ib_rec.inventory_org_id IS NUll OR
          l_itiv_ib_rec.inventory_org_id = OKL_API.G_MISS_NUM) OR
          lv_model_object_id2 <> r_itiv_ib_rec.inventory_org_id THEN
          l_itiv_ib_rec.inventory_org_id  := lv_model_object_id2;
      END IF;
      -- Updating of the ib Line
      update_instance_ib_line(p_api_version   => p_api_version,
                              p_init_msg_list => p_init_msg_list,
                              x_return_status => x_return_status,
                              x_msg_count     => x_msg_count,
                              x_msg_data      => x_msg_data,
                              p_clev_rec      => l_clev_ib_rec,
                              p_klev_rec      => l_klev_ib_rec,
                              p_cimv_rec      => l_cimv_ib_rec,
                              p_itiv_rec      => l_itiv_ib_rec,
                              x_clev_rec      => x_clev_ib_rec,
                              x_klev_rec      => l_klev_ib_rec_out,
                              x_cimv_rec      => l_cimv_ib_rec_out,
                              x_itiv_rec      => l_itiv_ib_rec_out);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Updating of the Instance Line
      -- To Get the cle IB Line Record
      x_return_status := get_rec_clev(l_clev_ib_rec.cle_id,
                                      r_clev_inst_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- To Get the kle IB Line Record
      x_return_status := get_rec_klev(l_clev_ib_rec.cle_id,
                                      r_klev_inst_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF r_clev_inst_rec.id <> r_klev_inst_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_LINE_RECORD);
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_clev_inst_rec := r_clev_inst_rec;
      l_klev_inst_rec := r_klev_inst_rec;
      -- upating of the Instance Line
      update_instance_line(p_api_version   => p_api_version,
                           p_init_msg_list => p_init_msg_list,
                           x_return_status => x_return_status,
                           x_msg_count     => x_msg_count,
                           x_msg_data      => x_msg_data,
                           p_clev_rec      => l_clev_inst_rec,
                           p_klev_rec      => l_klev_inst_rec,
                           p_itiv_rec      => l_itiv_inst_rec,
                           x_clev_rec      => l_clev_inst_rec_out,
                           x_klev_rec      => l_klev_inst_rec_out,
                           x_itiv_rec      => l_itiv_inst_rec_out);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF p_new_yn = 'N' THEN
      FOR r_asset_iti IN c_asset_iti(p_asset_number => p_asset_number,
                                     p_dnz_chr_id   => x_clev_fa_rec.dnz_chr_id)  LOOP
        -- To Get the itiv ib Line Record
        x_return_status := get_rec_itiv(r_asset_iti.id,
                                        n_itiv_ib_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKL_TXL_ITM_INSTS_V Record');
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKL_TXL_ITM_INSTS_V Record');
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        n_itiv_ib_rec.object_id1_new := p_itiv_ib_rec.object_id1_new;
        n_itiv_ib_rec.object_id1_old := p_itiv_ib_rec.object_id1_new;
        OKL_TXL_ITM_INSTS_PUB.update_txl_itm_insts(p_api_version    => p_api_version,
                                                   p_init_msg_list  => p_init_msg_list,
                                                   x_return_status  => x_return_status,
                                                   x_msg_count      => x_msg_count,
                                                   x_msg_data       => x_msg_data,
                                                   p_iipv_rec       => n_itiv_ib_rec,
                                                   x_iipv_rec       => nx_itiv_ib_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITI_ID);
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_ITI_ID);
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        END IF;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    -- rravikir modified.
    -- Update the OKL_TXL_ITM_INSTS table, when the item or install site gets changed.
    ln_txl_itm_id           := l_itiv_ib_rec_out.id;
    lv_object_id1           := l_itiv_ib_rec_out.object_id1_new;
    lv_object_id2           := l_itiv_ib_rec_out.object_id2_new;
    ln_inv_itm_id           := l_itiv_ib_rec_out.inventory_item_id;
    ln_inv_org_id           := l_itiv_ib_rec_out.inventory_org_id;
    lv_jtot_object_code_new := l_itiv_ib_rec_out.jtot_object_code_new;
    l_top_line_id           := x_clev_fin_rec.id;
    FOR r_get_txl_itm_insts IN c_get_txl_itm_insts(p_top_line_id => l_top_line_id,
                                                   p_txl_inst_id => ln_txl_itm_id)  LOOP
      k_itiv_ib_rec.id                   :=  r_get_txl_itm_insts.id;
      k_itiv_ib_rec.object_id1_new       :=  lv_object_id1;
      k_itiv_ib_rec.object_id2_new       :=  lv_object_id2;
      k_itiv_ib_rec.inventory_item_id    :=  ln_inv_itm_id;
      k_itiv_ib_rec.inventory_org_id     :=  ln_inv_org_id;
      k_itiv_ib_rec.jtot_object_code_new :=  lv_jtot_object_code_new;
      OKL_TXL_ITM_INSTS_PUB.update_txl_itm_insts(p_api_version    => p_api_version,
                                                 p_init_msg_list  => p_init_msg_list,
                                                 x_return_status  => x_return_status,
                                                 x_msg_count      => x_msg_count,
                                                 x_msg_data       => x_msg_data,
                                                 p_iipv_rec       => k_itiv_ib_rec,
                                                 x_iipv_rec       => kx_itiv_ib_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ITI_ID);
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ITI_ID);
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- end rravikir

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (l_clev_inst_rec_out.dnz_chr_id is NOT NULL) AND
       (l_clev_inst_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => l_clev_inst_rec_out.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
  End If; --release asset : Bug# 3533936
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_all_line;
-------------------------------------------------------------------------------------------------------
----------------- Main Process for Creation of instance and Install base line  ------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE create_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_current_units  IN  OKL_TXL_ASSETS_V.CURRENT_UNITS%TYPE,
            p_clev_ib_rec    IN  clev_rec_type,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type,
            x_clev_fin_rec   OUT NOCOPY clev_rec_type,
            x_klev_fin_rec   OUT NOCOPY klev_rec_type,
            x_cimv_model_rec OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec    OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec    OUT NOCOPY talv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'CREATE_INTS_IB_LINE';
    l_clev_ib_rec                clev_rec_type;
    l_klev_ib_rec                klev_rec_type;
    l_clev_inst_rec              clev_rec_type;
    l_klev_inst_rec              klev_rec_type;
    l_cimv_ib_rec                cimv_rec_type;
    l_itiv_ib_tbl                itiv_tbl_type := p_itiv_ib_tbl;
    l_clev_inst_rec_out          clev_rec_type;
    l_klev_inst_rec_out          klev_rec_type;
    l_itiv_inst_tbl_out          itiv_tbl_type;
    l_clev_ib_rec_out            clev_rec_type;
    l_cimv_ib_rec_out            cimv_rec_type;
    l_klev_ib_rec_out            klev_rec_type;
    l_itiv_ib_tbl_out            itiv_tbl_type;
    x_clev_ib_rec                clev_rec_type;
    l_trxv_ib_rec_out            trxv_rec_type;
    lv_object_id1_new            OKL_TXL_ITM_INSTS_V.OBJECT_ID1_NEW%TYPE;
    j                            NUMBER := 0;
    ln_dummy                     NUMBER := 0;
    ln_dummy1                    NUMBER := 0;
    -- rravikir added
    l_itiv_rec                   itiv_rec_type;
    lk_itiv_rec                  itiv_rec_type;
    lx_itiv_rec                  itiv_rec_type;
    k                            NUMBER := 0;
    ln_remain_inst               NUMBER := 0;
    lb_record_created            BOOLEAN := FALSE;
    lb_update_oec_required       BOOLEAN := FALSE;
    ln_item_id                   OKL_TXL_ITM_INSTS.INVENTORY_ITEM_ID%TYPE;
    -- end
    ln_final_current_units       OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE;
    ln_model_line_id             OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    ln_fa_line_id                OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    r_clev_model_rec             clev_rec_type;
    r_klev_model_rec             klev_rec_type;
    r_cimv_model_rec             cimv_rec_type;
    r_clev_addon_rec             clev_rec_type;
    r_klev_addon_rec             klev_rec_type;
    r_cimv_addon_rec             cimv_rec_type;
    rx_clev_addon_rec            clev_rec_type;
    rx_klev_addon_rec            klev_rec_type;
    rx_cimv_addon_rec            cimv_rec_type;
    r_clev_fa_rec                clev_rec_type;
    r_klev_fa_rec                klev_rec_type;
    r_cimv_fa_rec                cimv_rec_type;
    r_talv_fa_rec                talv_rec_type;
    l_clev_model_rec_out         clev_rec_type;
    l_klev_model_rec_out         klev_rec_type;
    l_clev_fa_rec_out            clev_rec_type;
    l_klev_fa_rec_out            klev_rec_type;
    ln_model_qty                 OKC_K_ITEMS_V.NUMBER_OF_ITEMS%TYPE := 0;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;

    CURSOR c_remain_inst_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                              p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT count(cle.id)
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_INST_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_model_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                        p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_fa_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                     p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_addon_line_id(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_ADDON_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT cle.id
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.cle_id = p_cle_id
                       AND cle.dnz_chr_id = p_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));

    CURSOR c_model_item(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                        p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cim.number_of_items
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items_v cim,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

        --akrangan Bug# 5362977 start
       --cursor to check if contract has re-lease assets
       CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
       SELECT 'Y'
       FROM   OKC_RULES_B rul
       WHERE  rul.dnz_chr_id = p_chr_id
       AND    rul.rule_information_category = 'LARLES'
       AND    NVL(rule_information1,'N') = 'Y';

       l_chk_rel_ast VARCHAR2(1);

       --cursor to check if the contract is undergoing on-line rebook
       cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
       SELECT '!'
       FROM   okc_k_headers_b chr,
              okl_trx_contracts ktrx
       WHERE  ktrx.khr_id_new = chr.id
       AND    ktrx.tsu_code = 'ENTERED'
       AND    ktrx.rbr_code is NOT NULL
       AND    ktrx.tcn_type = 'TRBK'
       --rkuttiya added for 12.1.1 multi GAAP
       AND    ktrx.representation_type = 'PRIMARY'
       --
       AND    chr.id = p_chr_id
       AND    chr.orig_system_source_code = 'OKL_REBOOK';

       l_rbk_khr      VARCHAR2(1);
       --akrangan Bug# 5362977 end


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Get the Ib rec first and then we can get the instance line above the IB line
    x_return_status := get_rec_clev(p_clev_ib_rec.id,
                                    l_clev_ib_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Now getting the inst line
    x_return_status := get_rec_clev(l_clev_ib_rec.cle_id,
                                    l_clev_inst_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Since a record is already created in TXL_ITM_INSTS, we need to update this
    -- record, and create 'n-1' records.
    -- rravikir modified
    IF (l_clev_inst_rec.id IS NOT NULL OR
        l_clev_inst_rec.id <> OKL_API.G_MISS_NUM) THEN
      -- We are here b'cause we have to update the okl_txl_itm_inst rec
      -- So we are calling the update api for the okl_txl_itm_insts rec

      -- Now getting the item information OKL_TXL_ITM_INSTS
      x_return_status := get_rec_itiv(l_clev_ib_rec.id,
                                      l_itiv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- checking for mfg_serial_number_yn flag
      k := l_itiv_ib_tbl.FIRST;
      IF l_itiv_ib_tbl(k).mfg_serial_number_yn <> 'Y' THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_REQUIRED_VALUE,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'mfg_serial_number_yn cannot be N');
        x_return_status := OKL_API.G_RET_STS_ERROR;
        IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;

      l_itiv_rec.object_id1_new       := l_itiv_ib_tbl(k).object_id1_new;
      l_itiv_rec.object_id2_new       := l_itiv_ib_tbl(k).object_id2_new;
      l_itiv_rec.mfg_serial_number_yn := l_itiv_ib_tbl(k).mfg_serial_number_yn;
      l_itiv_rec.serial_number        := l_itiv_ib_tbl(k).serial_number;
      l_itiv_rec.dnz_cle_id           := l_itiv_ib_tbl(k).dnz_cle_id;

      ln_item_id := l_itiv_rec.inventory_item_id;

      -- Check for uniqueness of Serial number
      x_return_status := is_duplicate_serial_number(p_serial_number => l_itiv_rec.serial_number,
                                                    p_item_id       => l_itiv_rec.inventory_item_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_itiv_rec.object_id2_new := '#';

      update_txl_itm_insts(p_api_version    => p_api_version,
                           p_init_msg_list  => p_init_msg_list,
                           x_return_status  => x_return_status,
                           x_msg_count      => x_msg_count,
                           x_msg_data       => x_msg_data,
                           p_itiv_rec       => l_itiv_rec,
                           x_itiv_rec       => lx_itiv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ITI_ID);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_ITI_ID);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      lb_record_created := TRUE;
    END IF;
    -- end rravikir modified


    -- We need to verify the p_current_units is same as the existing NUmber of items
    -- in the model line

    -- rravikir modified
    -- Should be able to create more # of serial numbers than the current units.
    OPEN c_model_item(l_clev_inst_rec.cle_id,
                      l_clev_inst_rec.dnz_chr_id);
    IF c_model_item%NOTFOUND THEN
       OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name => G_ITEM_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_model_item INTO ln_model_qty;
    CLOSE c_model_item;

    -- If the serial #'s entered is not equal to the units in model line,
    -- we should update the fixed line , model line and also update the top line
    -- with latest OEC
    IF ln_model_qty <> l_itiv_ib_tbl.COUNT THEN

         --akrangan Bug# 5362977 start
         -- Do not allow update of units if the contract has Re-lease assets
         l_chk_rel_ast := 'N';
         OPEN l_chk_rel_ast_csr(p_chr_id => l_clev_inst_rec.dnz_chr_id);
         FETCH l_chk_rel_ast_csr INTO l_chk_rel_ast;
         CLOSE l_chk_rel_ast_csr;

         IF l_chk_rel_ast = 'Y' THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => 'OKL_LA_REL_UNITS_NO_UPDATE');
           RAISE OKL_API.G_EXCEPTION_ERROR;
         ELSE

      lb_update_oec_required := TRUE;
    END IF;
         --akrangan Bug# 5362977 end
       END IF;

    -- end modified

    -- We have to make sure the count of the itiv_tbl
    -- should be equal to qty of items
    -- Since inst tbl and ib inst are same
    -- it is Good enough to do one
    ln_dummy1 := l_itiv_ib_tbl.COUNT - 1;
    IF ln_dummy1 > 0 THEN
       --ln_dummy1 :=  l_itiv_ib_tbl.COUNT;
       -- We have intialize the J , since there could be any index integer
       j := l_itiv_ib_tbl.FIRST;
       j := l_itiv_ib_tbl.NEXT(j);
       LOOP
         IF (l_itiv_ib_tbl(j).mfg_serial_number_yn IS NULL OR
            l_itiv_ib_tbl(j).mfg_serial_number_yn = OKL_API.G_MISS_CHAR) THEN
            x_return_status := OKL_API.G_RET_STS_ERROR;
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_REQUIRED_VALUE,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'mfg_serial_number_yn');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         ELSIF l_itiv_ib_tbl(j).mfg_serial_number_yn <> 'Y' THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_REQUIRED_VALUE,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'mfg_serial_number_yn cannot be N');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (j = l_itiv_ib_tbl.LAST);
         j := l_itiv_ib_tbl.NEXT(j);
       END LOOP;
       IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSIF (NOT lb_record_created) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CNT_REC);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we have to create the instance
    -- Depending of the qty in l_cimv_model_rec.number_of_items
    -- we have use loop
    ln_dummy := l_itiv_ib_tbl.COUNT - 1;
    IF (ln_dummy > 0) THEN
      j := l_itiv_ib_tbl.FIRST;
      j := l_itiv_ib_tbl.NEXT(j);
      FOR i IN 1..ln_dummy LOOP
      -- 4414408 Assign the line style ID directly
/*
        -- Creation of the Instance Line Process
        -- Getting the Line style Info
        x_return_status := get_lse_id(p_lty_code => G_INST_LINE_LTY_CODE,
                                      x_lse_id   => l_clev_inst_rec.lse_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
*/
        IF (l_clev_inst_rec.display_sequence IS NUll OR
          l_clev_inst_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
          l_clev_inst_rec.display_sequence  := l_clev_inst_rec.display_sequence + 1;
        END IF;
        -- Required cle Line Information
        -- Since we have a local Record of the Instance line
        -- We can you the same
        l_clev_inst_rec.lse_id            := G_INST_LINE_LTY_ID;
        l_clev_inst_rec.chr_id            := null;
        l_clev_inst_rec.cle_id            := l_clev_inst_rec.cle_id;
        l_clev_inst_rec.dnz_chr_id        := l_clev_inst_rec.dnz_chr_id;
        l_clev_inst_rec.exception_yn      := 'N';
        IF (l_itiv_ib_tbl(j).instance_number_ib IS NULL OR
          l_itiv_ib_tbl(j).instance_number_ib = OKL_API.G_MISS_CHAR)  THEN
          x_return_status := generate_instance_number_ib(x_instance_number_ib => l_itiv_ib_tbl(j).instance_number_ib);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_GEN_INST_NUM_IB);
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_GEN_INST_NUM_IB);
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          l_itiv_ib_tbl(j).instance_number_ib := p_asset_number||' '||l_itiv_ib_tbl(j).instance_number_ib;
        END IF;

        -- Creation of the Instance Line
        Create_instance_line(p_api_version   => p_api_version,
                             p_init_msg_list => p_init_msg_list,
                             x_return_status => x_return_status,
                             x_msg_count     => x_msg_count,
                             x_msg_data      => x_msg_data,
                             p_clev_rec      => l_clev_inst_rec,
                             p_klev_rec      => l_klev_inst_rec,
                             p_itiv_rec      => l_itiv_ib_tbl(j),
                             x_clev_rec      => l_clev_inst_rec_out,
                             x_klev_rec      => l_klev_inst_rec_out,
                             x_itiv_rec      => l_itiv_ib_tbl_out(j));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
      -- 4414408 Assign the line style ID directly
/*
        -- Creation of the ib Line Process
        -- Getting the Line style Info
        x_return_status := get_lse_id(p_lty_code => G_IB_LINE_LTY_CODE,
                                      x_lse_id   => l_clev_ib_rec.lse_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
*/
        IF (l_clev_ib_rec.display_sequence IS NUll OR
           l_clev_ib_rec.display_sequence = OKL_API.G_MISS_NUM) THEN
           l_clev_ib_rec.display_sequence  := l_clev_ib_rec_out.display_sequence + 1;
        END IF;
        -- Required cle Line Information
        l_clev_ib_rec.lse_id            := G_IB_LINE_LTY_ID;
        l_clev_ib_rec.chr_id            := null;
        l_clev_ib_rec.cle_id            := l_clev_inst_rec_out.id;
        l_clev_ib_rec.dnz_chr_id        := l_clev_inst_rec_out.dnz_chr_id;
        l_clev_ib_rec.exception_yn      := 'N';
        -- Required Item Information
        l_cimv_ib_rec.exception_yn      := 'N';
        l_cimv_ib_rec.object1_id1       := null;
        l_cimv_ib_rec.object1_id2       := null;
        -- Since the screen can give only party_site_id via l_itiv_tbl(j).object_id1_new
        -- We have to use the below function
        lv_object_id1_new := l_itiv_ib_tbl(j).object_id1_new;
        x_return_status := get_party_site_id(p_object_id1_new => lv_object_id1_new,
                                             x_object_id1_new => l_itiv_ib_tbl(j).object_id1_new,
                                             x_object_id2_new => l_itiv_ib_tbl(j).object_id2_new);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'Party_site_id');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'Party_site_id');
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- Check for uniqueness of Serial number
        x_return_status := is_duplicate_serial_number(p_serial_number => l_itiv_ib_tbl(j).serial_number,
                                                      p_item_id       => ln_item_id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;

        -- Creation of the ib Line
        Create_instance_ib_line(p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_clev_rec      => l_clev_ib_rec,
                                p_klev_rec      => l_klev_ib_rec,
                                p_cimv_rec      => l_cimv_ib_rec,
                                p_itiv_rec      => l_itiv_ib_tbl(j),
                                x_clev_rec      => x_clev_ib_rec,
                                x_klev_rec      => l_klev_ib_rec_out,
                                x_cimv_rec      => l_cimv_ib_rec_out,
                                x_trxv_rec      => l_trxv_ib_rec_out,
                                x_itiv_rec      => x_itiv_ib_tbl(j));
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (j = l_itiv_ib_tbl.LAST);
        x_clev_ib_tbl(i) := x_clev_ib_rec;
        j := l_itiv_ib_tbl.NEXT(j);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (NOT lb_record_created) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CNT_REC);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF; -- End if (ln_dummy > 0)

    -- We need to execute the following 'IF' loop, when the current units
    -- is changed, by editing more or less serial #'s.
    IF (lb_update_oec_required) THEN
    -- we should get the remaining inst line , so that we can update
    -- the fixed line , model line and also update the top line with latest OEC
    OPEN c_remain_inst_line(l_clev_inst_rec.cle_id,
                            l_clev_inst_rec.dnz_chr_id);
    IF c_remain_inst_line%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETING_INSTS_LINE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_remain_inst_line INTO ln_remain_inst;
    CLOSE c_remain_inst_line;

    -- To get the Model Line
    -- Since we have update the model line
    OPEN c_model_line(l_clev_inst_rec.cle_id,
                      l_clev_inst_rec.dnz_chr_id);
    IF c_model_line%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Model Asset Line record');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_model_line INTO ln_model_line_id;
    CLOSE c_model_line;

    -- To get the Fixed Asset Line
    -- Since we have update the Fixed Asset Line
    OPEN c_fa_line(l_clev_inst_rec.cle_id,
                   l_clev_inst_rec.dnz_chr_id);
    IF c_fa_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Fixed Asset Line record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_fa_line INTO ln_fa_line_id;
    CLOSE c_fa_line;

    -- We have to build the Model Line Record for the calculations of the
    -- oec of the top line

    -- To Get the cle Model Line Record
    x_return_status := get_rec_clev(ln_model_line_id,
                                    r_clev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- To Get the kle Model Line Record
    x_return_status := get_rec_klev(ln_model_line_id,
                                    r_klev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF r_klev_model_rec.id <> r_clev_model_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- To Get the cimv Model Line Record
    x_return_status := get_rec_cimv(r_clev_model_rec.id,
                                    r_clev_model_rec.dnz_chr_id,
                                    r_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Build Model cimv item rec
    r_cimv_model_rec.number_of_items  := ln_remain_inst;
    -- Updating of the Model Line and Item Record
    update_model_line(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      P_new_yn        => P_new_yn,
                      p_asset_number  => p_asset_number,
                      p_clev_rec      => r_clev_model_rec,
                      p_klev_rec      => r_klev_model_rec,
                      p_cimv_rec      => r_cimv_model_rec,
                      x_clev_rec      => l_clev_model_rec_out,
                      x_klev_rec      => l_klev_model_rec_out,
                      x_cimv_rec      => x_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- We need to check if there are add on line and then we update the Addon number of items also
    -- Since there can be multiple Addo lines
    FOR r_addon_line_id IN c_addon_line_id(p_cle_id => l_clev_model_rec_out.cle_id,
                                           p_chr_id => l_clev_model_rec_out.dnz_chr_id) LOOP
      --We have to build the addon Line Record for the calculations of the
      -- oec of the top line
      -- To Get the cle addon Line Record
      x_return_status := get_rec_clev(r_addon_line_id.id,
                                      r_clev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the kle Model Line Record
      x_return_status := get_rec_klev(r_addon_line_id.id,
                                      r_klev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF r_klev_addon_rec.id <> r_clev_addon_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_LINE_RECORD);
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the cimv Model Line Record
      x_return_status := get_rec_cimv(r_clev_addon_rec.id,
                                      r_clev_addon_rec.dnz_chr_id,
                                      r_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      --Build addon cimv item rec
      r_cimv_addon_rec.number_of_items  := ln_remain_inst;
      -- Updating of the addon Line and Item Record
      update_addon_line_rec(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_addon_rec,
                            p_klev_rec      => r_klev_addon_rec,
                            p_cimv_rec      => r_cimv_addon_rec,
                            x_clev_rec      => rx_clev_addon_rec,
                            x_klev_rec      => rx_klev_addon_rec,
                            x_cimv_rec      => rx_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Since we need to populate the OEC into fixed asset line also
    -- So we need to calcualte the same here it self
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => p_asset_number,
			 -- 4414408
                         p_top_line_id        => l_clev_inst_rec.cle_id,
                         p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                         x_fin_clev_rec       => x_clev_fin_rec,
                         x_fin_klev_rec       => x_klev_fin_rec,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => p_asset_number,
			     -- 4414408
                             p_top_line_id        => l_clev_inst_rec.cle_id,
                             p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                             x_fin_clev_rec       => x_clev_fin_rec,
                             x_fin_klev_rec       => x_klev_fin_rec,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => l_clev_inst_rec.cle_id,
                               p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                               x_fin_clev_rec       => x_clev_fin_rec,
                               x_fin_klev_rec       => x_klev_fin_rec,
                               x_res_value          => ln_klev_fin_res,
                               p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Updating of the Fixed Asset Line Process
    -- To Get the cle fa Line Record
    x_return_status := get_rec_clev(ln_fa_line_id,
                                    r_clev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- To Get the kle fa Line Record
    x_return_status := get_rec_klev(ln_fa_line_id,
                                    r_klev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    IF r_klev_fa_rec.id <> r_clev_fa_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- To Get the cimv fa Line Record
    x_return_status := get_rec_cimv(r_clev_fa_rec.id,
                                    r_clev_fa_rec.dnz_chr_id,
                                    r_cimv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Build cimv fa item rec
    r_cimv_fa_rec.number_of_items  := ln_remain_inst;
    --Build talv fa item rec
    x_return_status := get_rec_txlv(r_clev_fa_rec.id,
                                    r_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Build talv fa item rec
    r_talv_fa_rec.current_units  := ln_remain_inst;

       --akrangan Bug# 5362977 start
       -- For online rebook, update depreciation_cost and
       -- original_cost to line capital amount instead of line oec
       --check for rebook contract
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => r_clev_fa_rec.dnz_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr;
       CLOSE l_chk_rbk_csr;

       If l_rbk_khr = '!' Then
         r_talv_fa_rec.depreciation_cost := NVL(x_klev_fin_rec.capital_amount,ln_klev_fin_cap);
         r_talv_fa_rec.original_cost := NVL(x_klev_fin_rec.capital_amount,ln_klev_fin_cap);
       else

    r_talv_fa_rec.depreciation_cost := x_klev_fin_rec.oec;
       r_talv_fa_rec.original_cost := x_klev_fin_rec.oec;
       end if;
       --akrangan Bug# 5362977  end

    r_clev_fa_rec.item_description := r_talv_fa_rec.description;
    -- Updating of the Fixed Asset Line and item/Txl Asset Info
    update_fixed_asset_line(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_fa_rec,
                            p_klev_rec      => r_klev_fa_rec,
                            p_cimv_rec      => r_cimv_fa_rec,
                            p_talv_rec      => r_talv_fa_rec,
                            x_clev_rec      => l_clev_fa_rec_out,
                            x_klev_rec      => l_klev_fa_rec_out,
                            x_cimv_rec      => x_cimv_fa_rec,
                            x_talv_rec      => x_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
         --akrangan Bug# 5362977 start
       -- Update Tax Book details - okl_txd_assets_b
       update_asset_line_details(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_asset_number  => p_asset_number,
                                 p_original_cost => x_talv_fa_rec.original_cost,
                                 p_tal_id        => x_talv_fa_rec.ID);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --akrangan Bug# 5362977 end

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (l_clev_fa_rec_out.dnz_chr_id is NOT NULL) AND
       (l_clev_fa_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => l_clev_fa_rec_out.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;

    END IF;

    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_ints_ib_line;
-------------------------------------------------------------------------------------------------------
----------------- Main Process for Updating of instance and Install base line  ------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE update_ints_ib_line(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            P_new_yn         IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number   IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_top_line_id    IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_HEADERS_V.ID%TYPE,
            p_itiv_ib_tbl    IN  itiv_tbl_type,
            x_clev_ib_tbl    OUT NOCOPY clev_tbl_type,
            x_itiv_ib_tbl    OUT NOCOPY itiv_tbl_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'UPDATE_INTS_IB_LINE';
    i                            NUMBER := 0;
    l_itiv_ib_tbl                itiv_tbl_type;
    l_clev_inst_rec              clev_rec_type;
    l_klev_inst_rec              klev_rec_type;
    l_clev_ib_rec                clev_rec_type;
    l_clev_inst_rec_out          clev_rec_type;
    l_klev_inst_rec_out          klev_rec_type;
    l_itiv_ib_tbl_out            itiv_tbl_type;
    l_klev_ib_rec                klev_rec_type;
    l_cimv_ib_rec                cimv_rec_type;
    l_klev_ib_rec_out            klev_rec_type;
    l_cimv_ib_rec_out            cimv_rec_type;
    l_trxv_ib_rec_out            trxv_rec_type;
    ln_remain_inst               NUMBER := 0;
    ln_model_line_id             OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    lv_object_id1_new            OKL_TXL_ITM_INSTS.OBJECT_ID1_NEW%TYPE := OKL_API.G_MISS_CHAR;
    ln_fa_line_id                OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    r_clev_model_rec             clev_rec_type;
    r_klev_model_rec             klev_rec_type;
    r_cimv_model_rec             cimv_rec_type;
    r_clev_fa_rec                clev_rec_type;
    r_klev_fa_rec                klev_rec_type;
    r_cimv_fa_rec                cimv_rec_type;
    r_talv_fa_rec                talv_rec_type;
    l_clev_model_rec_out         clev_rec_type;
    l_klev_model_rec_out         klev_rec_type;
    l_cimv_model_rec_out         cimv_rec_type;
    l_clev_fa_rec_out            clev_rec_type;
    l_klev_fa_rec_out            klev_rec_type;
    lx_cimv_fa_rec               cimv_rec_type;
    lx_talv_fa_rec               talv_rec_type;
    lx_clev_fin_rec              clev_rec_type;
    lx_klev_fin_rec              klev_rec_type;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    r_clev_addon_rec             clev_rec_type;
    r_klev_addon_rec             klev_rec_type;
    r_cimv_addon_rec             cimv_rec_type;
    rx_clev_addon_rec            clev_rec_type;
    rx_klev_addon_rec            klev_rec_type;
    rx_cimv_addon_rec            cimv_rec_type;
    ln_model_item                OKL_TXL_ITM_INSTS.INVENTORY_ITEM_ID%TYPE;

    CURSOR c_remain_inst_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                              p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT count(cle.id)
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_INST_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_model_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                        p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_model_item(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                        p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cim.object1_id1
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_items cim,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.id = cim.cle_id
    AND cim.dnz_chr_id = cle.dnz_chr_id
    AND cim.jtot_object1_code = 'OKX_SYSITEM';

    CURSOR c_fa_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                     p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE);

    CURSOR c_addon_line_id(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_ADDON_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT cle.id
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.cle_id = p_cle_id
                       AND cle.dnz_chr_id = p_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));
      --akrangan Bug# 5362977 start
       --cursor to check if contract has re-lease assets
       CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
       SELECT 'Y'
       FROM   OKC_RULES_B rul
       WHERE  rul.dnz_chr_id = p_chr_id
       AND    rul.rule_information_category = 'LARLES'
       AND    NVL(rule_information1,'N') = 'Y';

       l_chk_rel_ast VARCHAR2(1);

       --cursor to check if the contract is undergoing on-line rebook
       cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
       SELECT '!'
       FROM   okc_k_headers_b chr,
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

       l_rbk_khr      VARCHAR2(1);
       --akrangan Bug# 5362977 end

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We must have top line id to go further
    IF (p_top_line_id IS NUll OR
       p_top_line_id = OKL_API.G_MISS_NUM) AND
       (p_dnz_chr_id IS NUll OR
       p_dnz_chr_id = OKL_API.G_MISS_NUM) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_REQUIRED_VALUE,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Top Line and Dnz_chr_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Get the model item
    OPEN c_model_item(p_top_line_id,
                      p_dnz_chr_id);
    IF c_model_item%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Item_Id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_model_item INTO ln_model_item;
    CLOSE c_model_item;

    -- we have to update the txl_itm_insts table only if the p_itiv_ib_tbl(i).id is given
    -- otherwise we have to create instance line and install base line and then create
    -- okl_txl_itm_insts record
    l_itiv_ib_tbl := p_itiv_ib_tbl;
    IF l_itiv_ib_tbl.COUNT > 0 THEN
       -- We have intialize the I, since there could be any index integer
       i := l_itiv_ib_tbl.FIRST;
       LOOP
         IF l_itiv_ib_tbl(i).id IS NULL OR
            l_itiv_ib_tbl(i).id = OKL_API.G_MISS_NUM THEN

            -- 4334903 Assign the line style ID directly
/*
           -- Creation of the Instance Line Process
           -- Getting the Line style Info
           x_return_status := get_lse_id(p_lty_code => G_INST_LINE_LTY_CODE,
                                         x_lse_id   => l_clev_inst_rec.lse_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
*/
            --akrangan Bug# 5362977 start
              -- Do not allow update of units if the contract has Re-lease assets
              l_chk_rel_ast := 'N';
              OPEN l_chk_rel_ast_csr(p_chr_id => p_dnz_chr_id);
              FETCH l_chk_rel_ast_csr INTO l_chk_rel_ast;
              CLOSE l_chk_rel_ast_csr;

              IF l_chk_rel_ast = 'Y' THEN
                OKL_API.set_message(p_app_name     => G_APP_NAME,
                                    p_msg_name     => 'OKL_LA_REL_UNITS_NO_UPDATE');
                RAISE OKL_API.G_EXCEPTION_ERROR;
              END IF;
              --akrangan Bug# 5362977 end

           l_clev_inst_rec.display_sequence  := 1;
           -- Required cle Line Information
           -- Since we have a local Record of the Instance line
           -- We can you the same
           l_clev_inst_rec.lse_id            := G_INST_LINE_LTY_ID;
           l_clev_inst_rec.chr_id            := null;
           l_clev_inst_rec.cle_id            := p_top_line_id;
           l_clev_inst_rec.dnz_chr_id        := p_dnz_chr_id;
           l_clev_inst_rec.exception_yn      := 'N';
           IF (l_itiv_ib_tbl(i).instance_number_ib IS NULL OR
             l_itiv_ib_tbl(i).instance_number_ib = OKL_API.G_MISS_CHAR)  THEN
             x_return_status := generate_instance_number_ib(x_instance_number_ib => l_itiv_ib_tbl(i).instance_number_ib);
             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_GEN_INST_NUM_IB);
               EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_GEN_INST_NUM_IB);
               EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
             END IF;
             l_itiv_ib_tbl(i).instance_number_ib := p_asset_number||' '||l_itiv_ib_tbl(i).instance_number_ib;
           END IF;
           -- Creation of the Instance Line
           Create_instance_line(p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_clev_rec      => l_clev_inst_rec,
                                p_klev_rec      => l_klev_inst_rec,
                                p_itiv_rec      => l_itiv_ib_tbl(i),
                                x_clev_rec      => l_clev_inst_rec_out,
                                x_klev_rec      => l_klev_inst_rec_out,
                                x_itiv_rec      => l_itiv_ib_tbl_out(i));
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
           -- 4414408 Assign the line style ID directly
/*
           -- Creation of the ib Line Process
           -- Getting the Line style Info
           x_return_status := get_lse_id(p_lty_code => G_IB_LINE_LTY_CODE,
                                         x_lse_id   => l_clev_ib_rec.lse_id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
*/
           l_clev_ib_rec.lse_id            := G_IB_LINE_LTY_ID;
           l_clev_ib_rec.display_sequence  := 2;
           -- Required cle Line Information
           l_clev_ib_rec.chr_id            := null;
           l_clev_ib_rec.cle_id            := l_clev_inst_rec_out.id;
           l_clev_ib_rec.dnz_chr_id        := l_clev_inst_rec_out.dnz_chr_id;
           l_clev_ib_rec.exception_yn      := 'N';
           -- Required Item Information
           l_cimv_ib_rec.exception_yn      := 'N';
           l_cimv_ib_rec.object1_id1       := null;
           l_cimv_ib_rec.object1_id2       := null;
           -- Since the screen can give only party_site_id via l_itiv_ib_tbl(i).object_id1_new
           -- We have to use the below function
           lv_object_id1_new := l_itiv_ib_tbl(i).object_id1_new;
           x_return_status := get_party_site_id(p_object_id1_new => lv_object_id1_new,
                                                x_object_id1_new => l_itiv_ib_tbl(i).object_id1_new,
                                                x_object_id2_new => l_itiv_ib_tbl(i).object_id2_new);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'Party_site_id');
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_NO_MATCHING_RECORD,
                                 p_token1       => G_COL_NAME_TOKEN,
                                 p_token1_value => 'Party_site_id');
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;

           -- Check for uniqueness of Serial number
           x_return_status := is_duplicate_serial_number(p_serial_number => l_itiv_ib_tbl(i).serial_number,
                                                         p_item_id       => ln_model_item);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;

           -- Creation of the ib Line
           Create_instance_ib_line(p_api_version   => p_api_version,
                                   p_init_msg_list => p_init_msg_list,
                                   x_return_status => x_return_status,
                                   x_msg_count     => x_msg_count,
                                   x_msg_data      => x_msg_data,
                                   p_clev_rec      => l_clev_ib_rec,
                                   p_klev_rec      => l_klev_ib_rec,
                                   p_cimv_rec      => l_cimv_ib_rec,
                                   p_itiv_rec      => l_itiv_ib_tbl(i),
                                   x_clev_rec      => x_clev_ib_tbl(i),
                                   x_klev_rec      => l_klev_ib_rec_out,
                                   x_cimv_rec      => l_cimv_ib_rec_out,
                                   x_trxv_rec      => l_trxv_ib_rec_out,
                                   x_itiv_rec      => x_itiv_ib_tbl(i));
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
         ELSIF l_itiv_ib_tbl(i).id IS NOT NULL OR
               l_itiv_ib_tbl(i).id <> OKL_API.G_MISS_NUM THEN

           -- Check for uniqueness of Serial number
           x_return_status := is_duplicate_serial_number(p_serial_number => l_itiv_ib_tbl(i).serial_number,
                                                         p_item_id       => ln_model_item);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;

           -- We are here b'cause we have to update the okl_txl_itm_inst rec
           -- So we are calling the update api for the okl_txl_itm_insts rec
           l_itiv_ib_tbl(i).object_id2_new := '#';
           update_txl_itm_insts(p_api_version    => p_api_version,
                                p_init_msg_list  => p_init_msg_list,
                                x_return_status  => x_return_status,
                                x_msg_count      => x_msg_count,
                                x_msg_data       => x_msg_data,
                                p_itiv_rec       => l_itiv_ib_tbl(i),
                                x_itiv_rec       => x_itiv_ib_tbl(i));
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_ITI_ID);
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_ITI_ID);
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
         ELSE
           OKL_API.set_message(p_app_name => G_APP_NAME,
                               p_msg_name => G_LINE_RECORD);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i = l_itiv_ib_tbl.LAST);
         i := l_itiv_ib_tbl.NEXT(i);
       END LOOP;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_CNT_REC);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- we should get the remaining inst line , so that we can update
    -- the fixed line , model line and also update the top line with latest OEC
    OPEN c_remain_inst_line(p_top_line_id,
                            p_dnz_chr_id);
    IF c_remain_inst_line%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETING_INSTS_LINE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_remain_inst_line INTO ln_remain_inst;
    CLOSE c_remain_inst_line;
    -- To get the Model Line
    -- Since we have update the model line
    OPEN c_model_line(p_top_line_id,
                      p_dnz_chr_id);
    IF c_model_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Model Asset Line record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_model_line INTO ln_model_line_id;
    CLOSE c_model_line;
    -- To get the Fixed Asset Line
    -- Since we have update the Fixed Asset Line
    OPEN c_fa_line(p_top_line_id,
                   p_dnz_chr_id);
    IF c_fa_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Fixed Asset Line record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_fa_line INTO ln_fa_line_id;
    CLOSE c_fa_line;
    --We have to build the Model Line Record for the calculations of the
    -- oec of the top line
    -- To Get the cle Model Line Record
    x_return_status := get_rec_clev(ln_model_line_id,
                                    r_clev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle Model Line Record
    x_return_status := get_rec_klev(ln_model_line_id,
                                    r_klev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_model_rec.id <> r_clev_model_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the cimv Model Line Record
    x_return_status := get_rec_cimv(r_clev_model_rec.id,
                                    r_clev_model_rec.dnz_chr_id,
                                    r_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build Model cimv item rec
    r_cimv_model_rec.number_of_items  := ln_remain_inst;
    -- Updating of the Model Line and Item Record
    update_model_line(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      P_new_yn        => P_new_yn,
                      p_asset_number  => p_asset_number,
                      p_clev_rec      => r_clev_model_rec,
                      p_klev_rec      => r_klev_model_rec,
                      p_cimv_rec      => r_cimv_model_rec,
                      x_clev_rec      => l_clev_model_rec_out,
                      x_klev_rec      => l_klev_model_rec_out,
                      x_cimv_rec      => l_cimv_model_rec_out);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to check if there are add on line and then we update the Addon number of items also
    -- Since there can be multiple Addo lines
    FOR r_addon_line_id IN c_addon_line_id(p_cle_id => p_top_line_id,
                                           p_chr_id => p_dnz_chr_id) LOOP
      --We have to build the addon Line Record for the calculations of the
      -- oec of the top line
      -- To Get the cle addon Line Record
      x_return_status := get_rec_clev(r_addon_line_id.id,
                                      r_clev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the kle Model Line Record
      x_return_status := get_rec_klev(r_addon_line_id.id,
                                      r_klev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF r_klev_addon_rec.id <> r_clev_addon_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_LINE_RECORD);
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the cimv Model Line Record
      x_return_status := get_rec_cimv(r_clev_addon_rec.id,
                                      r_clev_addon_rec.dnz_chr_id,
                                      r_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      --Build addon cimv item rec
      r_cimv_addon_rec.number_of_items  := ln_remain_inst;
      -- Updating of the addon Line and Item Record
      update_addon_line_rec(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_addon_rec,
                            p_klev_rec      => r_klev_addon_rec,
                            p_cimv_rec      => r_cimv_addon_rec,
                            x_clev_rec      => rx_clev_addon_rec,
                            x_klev_rec      => rx_klev_addon_rec,
                            x_cimv_rec      => rx_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we need to populate the OEC into fixed asset line also
    -- So we need to calcualte the same here it self
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => p_asset_number,
			 -- 4414408
                         p_top_line_id        => p_top_line_id,
                         p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                         x_fin_clev_rec       => lx_clev_fin_rec,
                         x_fin_klev_rec       => lx_klev_fin_rec,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => p_asset_number,
			     -- 4414408
                             p_top_line_id        => p_top_line_id,
                             p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                             x_fin_clev_rec       => lx_clev_fin_rec,
                             x_fin_klev_rec       => lx_klev_fin_rec,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => p_top_line_id,
                               p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                               x_fin_clev_rec       => lx_clev_fin_rec,
                               x_fin_klev_rec       => lx_klev_fin_rec,
                               x_res_value          => ln_klev_fin_res,
                               p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Updating of the Fixed Asset Line Process
    -- To Get the cle fa Line Record
    x_return_status := get_rec_clev(ln_fa_line_id,
                                    r_clev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle fa Line Record
    x_return_status := get_rec_klev(ln_fa_line_id,
                                    r_klev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_fa_rec.id <> r_clev_fa_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the cimv fa Line Record
    x_return_status := get_rec_cimv(r_clev_fa_rec.id,
                                    r_clev_fa_rec.dnz_chr_id,
                                    r_cimv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build cimv fa item rec
    r_cimv_fa_rec.number_of_items  := ln_remain_inst;
    --Build talv fa item rec
    x_return_status := get_rec_txlv(r_clev_fa_rec.id,
                                    r_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build talv fa item rec
    r_talv_fa_rec.current_units  := ln_remain_inst;
        --akrangan Bug# 5362977 start
       -- For online rebook, update depreciation_cost and
       -- original_cost to line capital amount instead of line oec
       --check for rebook contract
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => r_clev_fa_rec.dnz_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr;
       CLOSE l_chk_rbk_csr;

       If l_rbk_khr = '!' Then
         r_talv_fa_rec.depreciation_cost := NVL(lx_klev_fin_rec.capital_amount,ln_klev_fin_cap);
         r_talv_fa_rec.original_cost := NVL(lx_klev_fin_rec.capital_amount,ln_klev_fin_cap);
       else

    r_talv_fa_rec.depreciation_cost := lx_klev_fin_rec.oec;
           r_talv_fa_rec.original_cost := lx_klev_fin_rec.oec;
       end if;
       --akrangan Bug# 5362977 end

    r_clev_fa_rec.item_description := r_talv_fa_rec.description;
    -- Updating of the Fixed Asset Line and item/Txl Asset Info
    update_fixed_asset_line(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_fa_rec,
                            p_klev_rec      => r_klev_fa_rec,
                            p_cimv_rec      => r_cimv_fa_rec,
                            p_talv_rec      => r_talv_fa_rec,
                            x_clev_rec      => l_clev_fa_rec_out,
                            x_klev_rec      => l_klev_fa_rec_out,
                            x_cimv_rec      => lx_cimv_fa_rec,
                            x_talv_rec      => lx_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
          --akrangan Bug# 5362977 start
       -- Update Tax Book details - okl_txd_assets_b
       update_asset_line_details(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_asset_number  => p_asset_number,
                                 p_original_cost => lx_talv_fa_rec.original_cost,
                                 p_tal_id        => lx_talv_fa_rec.ID);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --akrangan Bug# 5362977 end

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (l_clev_fa_rec_out.dnz_chr_id is NOT NULL) AND
       (l_clev_fa_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => l_clev_fa_rec_out.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_remain_inst_line%ISOPEN THEN
      CLOSE c_remain_inst_line;
    END IF;
    IF c_model_line%ISOPEN THEN
      CLOSE c_model_line;
    END IF;
    IF c_fa_line%ISOPEN THEN
      CLOSE c_fa_line;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_remain_inst_line%ISOPEN THEN
      CLOSE c_remain_inst_line;
    END IF;
    IF c_model_line%ISOPEN THEN
      CLOSE c_model_line;
    END IF;
    IF c_fa_line%ISOPEN THEN
      CLOSE c_fa_line;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_remain_inst_line%ISOPEN THEN
      CLOSE c_remain_inst_line;
    END IF;
    IF c_model_line%ISOPEN THEN
      CLOSE c_model_line;
    END IF;
    IF c_fa_line%ISOPEN THEN
      CLOSE c_fa_line;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_model_item%ISOPEN THEN
      CLOSE c_model_item;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END update_ints_ib_line;
-------------------------------------------------------------------------------------------------------
----------------- Main Process for Deletion of instance and Install base line  ------------------------
-------------------------------------------------------------------------------------------------------
  PROCEDURE delete_ints_ib_line(
            p_api_version         IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 DEFAULT OKC_API.G_FALSE,
            x_return_status       OUT NOCOPY VARCHAR2,
            x_msg_count           OUT NOCOPY NUMBER,
            x_msg_data            OUT NOCOPY VARCHAR2,
            P_new_yn              IN  OKL_TXL_ASSETS_V.USED_ASSET_YN%TYPE,
            p_asset_number        IN  OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
            p_clev_ib_tbl         IN  clev_tbl_type,
            x_clev_fin_rec        OUT NOCOPY clev_rec_type,
            x_klev_fin_rec        OUT NOCOPY klev_rec_type,
            x_cimv_model_rec      OUT NOCOPY cimv_rec_type,
            x_cimv_fa_rec         OUT NOCOPY cimv_rec_type,
            x_talv_fa_rec         OUT NOCOPY talv_rec_type) IS
    l_api_name          CONSTANT VARCHAR2(30) := 'DELETE_INTS_IB_LINE';
    l_clev_ib_tbl                clev_tbl_type := p_clev_ib_tbl;
    l_clev_ib_rec                clev_rec_type;
    l_clev_inst_rec              clev_rec_type;
    ln_remain_inst               NUMBER := 0;
    ln_model_line_id             OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    ln_fa_line_id                OKC_K_LINES_V.ID%TYPE := OKL_API.G_MISS_NUM;
    r_clev_model_rec             clev_rec_type;
    r_klev_model_rec             klev_rec_type;
    r_cimv_model_rec             cimv_rec_type;
    r_clev_fa_rec                clev_rec_type;
    r_klev_fa_rec                klev_rec_type;
    r_cimv_fa_rec                cimv_rec_type;
    r_talv_fa_rec                talv_rec_type;
    l_clev_model_rec_out         clev_rec_type;
    l_klev_model_rec_out         klev_rec_type;
    l_clev_fa_rec_out            clev_rec_type;
    l_klev_fa_rec_out            klev_rec_type;
    ln_klev_fin_oec              OKL_K_LINES_V.OEC%TYPE := 0;
    ln_klev_fin_res              OKL_K_LINES_V.RESIDUAL_VALUE%TYPE := 0;
    ln_klev_fin_cap              OKL_K_LINES_V.CAPITAL_AMOUNT%TYPE := 0;
    r_clev_addon_rec             clev_rec_type;
    r_klev_addon_rec             klev_rec_type;
    r_cimv_addon_rec             cimv_rec_type;
    rx_clev_addon_rec            clev_rec_type;
    rx_klev_addon_rec            klev_rec_type;
    rx_cimv_addon_rec            cimv_rec_type;
    j                            NUMBER := 0;
    lb_last_record_updated       BOOLEAN := FALSE;

    -- rravikir added
    l_itiv_rec                   itiv_rec_type;
    lx_itiv_rec                  itiv_rec_type;
    -- end

    CURSOR c_remain_inst_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                              p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT count(cle.id)
    FROM okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_INST_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE;

    CURSOR c_model_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                        p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code = 'LEASE';

    CURSOR c_fa_line(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                     p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_FA_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_FIN_LINE_LTY_CODE
    AND lse2.id = stl.lse_id
    AND stl.scs_code = 'LEASE';

    CURSOR c_addon_line_id(p_cle_id OKC_K_LINES_V.CLE_ID%TYPE,
                           p_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT cle.id
    FROM okc_subclass_top_line stl,
         okc_line_styles_b lse3,
         okc_line_styles_b lse2,
         okc_line_styles_b lse1,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_chr_id
    AND cle.lse_id = lse1.id
    AND lse1.lty_code = G_ADDON_LINE_LTY_CODE
    AND lse1.lse_parent_id = lse2.id
    AND lse2.lty_code = G_MODEL_LINE_LTY_CODE
    AND lse2.lse_parent_id = lse3.id
    AND lse3.lty_code = G_FIN_LINE_LTY_CODE
    AND lse3.id = stl.lse_id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.cle_id in (SELECT cle.id
                       FROM okc_subclass_top_line stl,
                            okc_line_styles_b lse2,
                            okc_line_styles_b lse1,
                            okc_k_lines_b cle
                       WHERE cle.cle_id = p_cle_id
                       AND cle.dnz_chr_id = p_chr_id
                       AND cle.lse_id = lse1.id
                       AND lse1.lty_code = G_MODEL_LINE_LTY_CODE
                       AND lse1.lse_parent_id = lse2.id
                       AND lse2.lty_code = G_FIN_LINE_LTY_CODE
                       AND lse2.id = stl.lse_id
                       AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE));
		            --Bug# 5362977 start
       --cursor to check if contract has re-lease assets
       CURSOR l_chk_rel_ast_csr (p_chr_id IN NUMBER) IS
       SELECT 'Y'
       FROM   OKC_RULES_B rul
       WHERE  rul.dnz_chr_id = p_chr_id
       AND    rul.rule_information_category = 'LARLES'
       AND    NVL(rule_information1,'N') = 'Y';

       l_chk_rel_ast VARCHAR2(1);

       --cursor to check if the contract is undergoing on-line rebook
       cursor l_chk_rbk_csr(p_chr_id IN NUMBER) is
       SELECT '!'
       FROM   okc_k_headers_b chr,
              okl_trx_contracts ktrx
       WHERE  ktrx.khr_id_new = chr.id
       AND    ktrx.tsu_code = 'ENTERED'
       AND    ktrx.rbr_code is NOT NULL
       AND    ktrx.tcn_type = 'TRBK'
       --rkuttiya added fopr 12.1.1 Multi GAAP
       AND    ktrx.representation_type = 'PRIMARY'
       --
       AND    chr.id = p_chr_id
       AND    chr.orig_system_source_code = 'OKL_REBOOK';

       l_rbk_khr      VARCHAR2(1);
       --Bug# 5362977 end


  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- Call start_activity to create savepoint, check compatibility
    -- and initialize message list
    x_return_status := OKL_API.START_ACTIVITY (
                               l_api_name
                               ,p_init_msg_list
                               ,'_PVT'
                               ,x_return_status);
    -- Check if activity started successfully
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF l_clev_ib_tbl.COUNT > 0 THEN
       -- We have intialize the J , since there could be any index integer
       j := l_clev_ib_tbl.FIRST;
       LOOP
         IF l_clev_ib_tbl(j).id IS NUll OR
            l_clev_ib_tbl(j).id = OKL_API.G_MISS_NUM THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_REQUIRED_VALUE,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'IB OKC_K_LINES_B.ID');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         x_return_status := get_rec_clev(l_clev_ib_tbl(j).id,
                                         l_clev_ib_rec);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKC_K_LINES_V Record');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKC_K_LINES_V Record');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         x_return_status := get_rec_clev(l_clev_ib_rec.cle_id,
                                         l_clev_inst_rec);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKC_K_LINES_V Record');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_FETCHING_INFO,
                               p_token1       => G_REC_NAME_TOKEN,
                               p_token1_value => 'OKC_K_LINES_V Record');
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;

         -- we should get the remaining inst line , so that we can update
         -- the fixed line , model line and also update the top line with latest OEC
         OPEN c_remain_inst_line(l_clev_inst_rec.cle_id,
                                 l_clev_inst_rec.dnz_chr_id);
         IF c_remain_inst_line%NOTFOUND THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_DELETING_INSTS_LINE);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         FETCH c_remain_inst_line INTO ln_remain_inst;
        CLOSE c_remain_inst_line;

        -- Last record of the OKL_TXL_ITM_INSTS should not be deleted. It
        -- has to update the MFG_FLAG to 'N' and nullify the serial number.
        IF ln_remain_inst < 2 THEN
          x_return_status := get_rec_itiv(l_clev_ib_rec.id,
                                          l_itiv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_FETCHING_INFO,
                                 p_token1       => G_REC_NAME_TOKEN,
                                 p_token1_value => 'OKC_K_LINES_V Record');
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_FETCHING_INFO,
                                 p_token1       => G_REC_NAME_TOKEN,
                                 p_token1_value => 'OKC_K_LINES_V Record');
             RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          l_itiv_rec.mfg_serial_number_yn := 'N';
          l_itiv_rec.serial_number        := null;

          update_txl_itm_insts(p_api_version    => p_api_version,
                               p_init_msg_list  => p_init_msg_list,
                               x_return_status  => x_return_status,
                               x_msg_count      => x_msg_count,
                               x_msg_data       => x_msg_data,
                               p_itiv_rec       => l_itiv_rec,
                               x_itiv_rec       => lx_itiv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_ITI_ID);
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_ITI_ID);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
          lb_last_record_updated := TRUE;
/*          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_MIN_INST_LINE);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);*/
        END IF;

        IF (NOT lb_last_record_updated) THEN
          validate_sts_code(p_clev_rec       => l_clev_inst_rec,
                            x_return_status  => x_return_status);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
	     --Bug# 5362977 start
             -- Do not allow update of units if the contract has Re-lease assets
             l_chk_rel_ast := 'N';
             OPEN l_chk_rel_ast_csr(p_chr_id => l_clev_inst_rec.dnz_chr_id);
             FETCH l_chk_rel_ast_csr INTO l_chk_rel_ast;
             CLOSE l_chk_rel_ast_csr;

             IF l_chk_rel_ast = 'Y' THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => 'OKL_LA_REL_UNITS_NO_UPDATE');
               RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
             --Bug# 5362977 end

          OKL_CONTRACT_PUB.delete_contract_line(
                            p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            p_line_id       => l_clev_inst_rec.id);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_DELETING_IB_LINE);
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name     => G_APP_NAME,
                                 p_msg_name     => G_DELETING_IB_LINE);
             EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
           END IF;
         END IF;
         EXIT WHEN (j = l_clev_ib_tbl.LAST);
         j := l_clev_ib_tbl.NEXT(j);
       END LOOP;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_CNT_REC);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- we should get the remaining inst line , so that we can update
    -- the fixed line , model line and also update the top line with latest OEC
    OPEN c_remain_inst_line(l_clev_inst_rec.cle_id,
                            l_clev_inst_rec.dnz_chr_id);
    IF c_remain_inst_line%NOTFOUND THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_DELETING_INSTS_LINE);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_remain_inst_line INTO ln_remain_inst;
    CLOSE c_remain_inst_line;
    -- To get the Model Line
    -- Since we have update the model line
    OPEN c_model_line(l_clev_inst_rec.cle_id,
                      l_clev_inst_rec.dnz_chr_id);
    IF c_model_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Model Asset Line record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_model_line INTO ln_model_line_id;
    CLOSE c_model_line;
    -- To get the Fixed Asset Line
    -- Since we have update the Fixed Asset Line
    OPEN c_fa_line(l_clev_inst_rec.cle_id,
                  l_clev_inst_rec.dnz_chr_id);
    IF c_fa_line%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Fixed Asset Line record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    FETCH c_fa_line INTO ln_fa_line_id;
    CLOSE c_fa_line;
    --We have to build the Model Line Record for the calculations of the
    -- oec of the top line
    -- To Get the cle Model Line Record
    x_return_status := get_rec_clev(ln_model_line_id,
                                    r_clev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle Model Line Record
    x_return_status := get_rec_klev(ln_model_line_id,
                                    r_klev_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_model_rec.id <> r_clev_model_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the cimv Model Line Record
    x_return_status := get_rec_cimv(r_clev_model_rec.id,
                                    r_clev_model_rec.dnz_chr_id,
                                    r_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build Model cimv item rec
    r_cimv_model_rec.number_of_items  := ln_remain_inst;
    -- Updating of the Model Line and Item Record
    update_model_line(p_api_version   => p_api_version,
                      p_init_msg_list => p_init_msg_list,
                      x_return_status => x_return_status,
                      x_msg_count     => x_msg_count,
                      x_msg_data      => x_msg_data,
                      P_new_yn        => P_new_yn,
                      p_asset_number  => p_asset_number,
                      p_clev_rec      => r_clev_model_rec,
                      p_klev_rec      => r_klev_model_rec,
                      p_cimv_rec      => r_cimv_model_rec,
                      x_clev_rec      => l_clev_model_rec_out,
                      x_klev_rec      => l_klev_model_rec_out,
                      x_cimv_rec      => x_cimv_model_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- We need to check if there are add on line and then we update the Addon number of items also
    -- Since there can be multiple Addo lines
    FOR r_addon_line_id IN c_addon_line_id(p_cle_id => l_clev_model_rec_out.cle_id,
                                           p_chr_id => l_clev_model_rec_out.dnz_chr_id) LOOP
      --We have to build the addon Line Record for the calculations of the
      -- oec of the top line
      -- To Get the cle addon Line Record
      x_return_status := get_rec_clev(r_addon_line_id.id,
                                      r_clev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the kle Model Line Record
      x_return_status := get_rec_klev(r_addon_line_id.id,
                                      r_klev_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKL_K_LINES_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      IF r_klev_addon_rec.id <> r_clev_addon_rec.id THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_LINE_RECORD);
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      -- To Get the cimv Model Line Record
      x_return_status := get_rec_cimv(r_clev_addon_rec.id,
                                      r_clev_addon_rec.dnz_chr_id,
                                      r_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_FETCHING_INFO,
                             p_token1       => G_REC_NAME_TOKEN,
                             p_token1_value => 'OKC_K_ITEMS_V Record');
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      --Build addon cimv item rec
      r_cimv_addon_rec.number_of_items  := ln_remain_inst;
      -- Updating of the addon Line and Item Record
      update_addon_line_rec(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_addon_rec,
                            p_klev_rec      => r_klev_addon_rec,
                            p_cimv_rec      => r_cimv_addon_rec,
                            x_clev_rec      => rx_clev_addon_rec,
                            x_klev_rec      => rx_klev_addon_rec,
                            x_cimv_rec      => rx_cimv_addon_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since we need to populate the OEC into fixed asset line also
    -- So we need to calcualte the same here it self
    oec_calc_upd_fin_rec(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_new_yn             => P_new_yn,
                         p_asset_number       => p_asset_number,
			 -- 4414408
                         p_top_line_id        => l_clev_inst_rec.cle_id,
                         p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                         x_fin_clev_rec       => x_clev_fin_rec,
                         x_fin_klev_rec       => x_klev_fin_rec,
                         x_oec                => ln_klev_fin_oec,
                         p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Capital Amount to Populate the OKL_K_LINES_V.CAPITAL_AMOUNT
    cap_amt_calc_upd_fin_rec(p_api_version        => p_api_version,
                             p_init_msg_list      => p_init_msg_list,
                             x_return_status      => x_return_status,
                             x_msg_count          => x_msg_count,
                             x_msg_data           => x_msg_data,
                             P_new_yn             => P_new_yn,
                             p_asset_number       => p_asset_number,
			     -- 4414408
                             p_top_line_id        => l_clev_inst_rec.cle_id,
                             p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                             x_fin_clev_rec       => x_clev_fin_rec,
                             x_fin_klev_rec       => x_klev_fin_rec,
                             x_cap_amt            => ln_klev_fin_cap,
                             p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Calculate the Residual Value to Populate the OKL_K_LINES_V.RESIDUAL_VALUE
    res_value_calc_upd_fin_rec(p_api_version        => p_api_version,
                               p_init_msg_list      => p_init_msg_list,
                               x_return_status      => x_return_status,
                               x_msg_count          => x_msg_count,
                               x_msg_data           => x_msg_data,
                               P_new_yn             => P_new_yn,
                               p_asset_number       => p_asset_number,
			       -- 4414408
                               p_top_line_id        => l_clev_inst_rec.cle_id,
                               p_dnz_chr_id         => l_clev_model_rec_out.dnz_chr_id,
                               x_fin_clev_rec       => x_clev_fin_rec,
                               x_fin_klev_rec       => x_klev_fin_rec,
                               x_res_value          => ln_klev_fin_res,
                               p_validate_fin_line  => OKL_API.G_TRUE);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Updating of the Fixed Asset Line Process
    -- To Get the cle fa Line Record
    x_return_status := get_rec_clev(ln_fa_line_id,
                                    r_clev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the kle fa Line Record
    x_return_status := get_rec_klev(ln_fa_line_id,
                                    r_klev_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_K_LINES_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF r_klev_fa_rec.id <> r_clev_fa_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- To Get the cimv fa Line Record
    x_return_status := get_rec_cimv(r_clev_fa_rec.id,
                                    r_clev_fa_rec.dnz_chr_id,
                                    r_cimv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKC_K_ITEMS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build cimv fa item rec
    r_cimv_fa_rec.number_of_items  := ln_remain_inst;
    --Build talv fa item rec
    x_return_status := get_rec_txlv(r_clev_fa_rec.id,
                                    r_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_FETCHING_INFO,
                           p_token1       => G_REC_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ASSETS_V Record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --Build talv fa item rec
    r_talv_fa_rec.current_units  := ln_remain_inst;

       --Bug# 5362977 start
       -- For online rebook, update depreciation_cost and
       -- original_cost to line capital amount instead of line oec
       --check for rebook contract
       l_rbk_khr := '?';
       OPEN l_chk_rbk_csr (p_chr_id => r_clev_fa_rec.dnz_chr_id);
       FETCH l_chk_rbk_csr INTO l_rbk_khr;
       CLOSE l_chk_rbk_csr;

       If l_rbk_khr = '!' Then
         r_talv_fa_rec.depreciation_cost := NVL(x_klev_fin_rec.capital_amount,ln_klev_fin_cap);
         r_talv_fa_rec.original_cost := NVL(x_klev_fin_rec.capital_amount,ln_klev_fin_cap);
       else

    r_talv_fa_rec.depreciation_cost := x_klev_fin_rec.oec;
          r_talv_fa_rec.original_cost := x_klev_fin_rec.oec;
       end if;
       --Bug# 5362977 end


    r_clev_fa_rec.item_description := r_talv_fa_rec.description;
    -- Updating of the Fixed Asset Line and item/Txl Asset Info
    update_fixed_asset_line(p_api_version   => p_api_version,
                            p_init_msg_list => p_init_msg_list,
                            x_return_status => x_return_status,
                            x_msg_count     => x_msg_count,
                            x_msg_data      => x_msg_data,
                            P_new_yn        => P_new_yn,
                            p_asset_number  => p_asset_number,
                            p_clev_rec      => r_clev_fa_rec,
                            p_klev_rec      => r_klev_fa_rec,
                            p_cimv_rec      => r_cimv_fa_rec,
                            p_talv_rec      => r_talv_fa_rec,
                            x_clev_rec      => l_clev_fa_rec_out,
                            x_klev_rec      => l_klev_fa_rec_out,
                            x_cimv_rec      => x_cimv_fa_rec,
                            x_talv_rec      => x_talv_fa_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
        --Bug# 5176649 start
       -- Update Tax Book details - okl_txd_assets_b
       update_asset_line_details(p_api_version   => p_api_version,
                                 p_init_msg_list => p_init_msg_list,
                                 x_return_status => x_return_status,
                                 x_msg_count     => x_msg_count,
                                 x_msg_data      => x_msg_data,
                                 p_asset_number  => p_asset_number,
                                 p_original_cost => x_talv_fa_rec.original_cost,
                                 p_tal_id        => x_talv_fa_rec.ID);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       --Bug# 5176649 end

    -- We need to change the status of the header whenever there is updating happening
    -- after the contract status is approved
    IF (l_clev_fa_rec_out.dnz_chr_id is NOT NULL) AND
       (l_clev_fa_rec_out.dnz_chr_id <> OKL_API.G_MISS_NUM) THEN
      --cascade edit status on to lines
      okl_contract_status_pub.cascade_lease_status_edit
               (p_api_version     => p_api_version,
                p_init_msg_list   => p_init_msg_list,
                x_return_status   => x_return_status,
                x_msg_count       => x_msg_count,
                x_msg_data        => x_msg_data,
                p_chr_id          => l_clev_fa_rec_out.dnz_chr_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END delete_ints_ib_line;

End OKL_CREATE_KLE_PVT;

/
