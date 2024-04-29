--------------------------------------------------------
--  DDL for Package Body OKL_COPY_ASSET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_COPY_ASSET_PVT" as
/* $Header: OKLRCALB.pls 120.16 2006/11/13 06:30:14 dpsingh noship $ */
-------------------------------------------------------------------------------------------------
-- GLOBAL MESSAGE CONSTANTS
-------------------------------------------------------------------------------------------------
  G_COL_NAME_TOKEN              CONSTANT  VARCHAR2(200) := OKL_API.G_COL_NAME_TOKEN;
  G_REQUIRED_VALUE              CONSTANT  VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_NO_MATCHING_RECORD          CONSTANT  VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_INVALID_YN                  CONSTANT  VARCHAR2(200) := 'OKL_INVALID_YN';
  G_LINE_RECORD                 CONSTANT  VARCHAR2(200) := 'OKL_LLA_LINE_RECORD';
  G_ITEM_RECORD                 CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITEM_RECORD';
  G_TRX_ID                      CONSTANT  VARCHAR2(200) := 'OKL_LLA_TRX_ID';
  G_KLE_ID                      CONSTANT  VARCHAR2(200) := 'OKL_LLA_KLE_ID';
  G_TXD_ID                      CONSTANT  VARCHAR2(200) := 'OKL_LLA_TXD_ID';
  G_ITI_ID                      CONSTANT  VARCHAR2(200) := 'OKL_LLA_ITI_ID';
  G_COPY_LINE                   CONSTANT  VARCHAR2(200) := 'OKL_LLA_COPY_LINE';
  G_UPPERCASE_REQUIRED	        CONSTANT  VARCHAR2(200) := 'OKL_UPPER_CASE_REQUIRED';
  G_UNEXPECTED_ERROR            CONSTANT  VARCHAR2(200) := 'OKL_CONTRACTS_UNEXP_ERROR';
  G_FETCHING_INFO               CONSTANT  VARCHAR2(200) := 'OKL_LLA_FETCHING_INFO';
  G_REC_NAME_TOKEN              CONSTANT  VARCHAR2(200) := 'REC_INFO';
  G_UPDATING_FIN_LINE           CONSTANT  VARCHAR2(200) := 'OKL_LLA_UPDATING_FIN_LINE';
  G_SQLERRM_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN               CONSTANT  VARCHAR2(200) := 'SQLcode';
--bug# 2769267
  G_CONV_RATE_NOT_FOUND         CONSTANT VARCHAR2(200)  := 'OKL_LLA_CONV_RATE_NOT_FOUND';
  G_FROM_CURRENCY_TOKEN         CONSTANT VARCHAR2(200)  := 'FROM_CURRENCY';
  G_TO_CURRENCY_TOKEN           CONSTANT VARCHAR2(200)  := 'TO_CURRENCY';
  G_CONV_TYPE_TOKEN             CONSTANT VARCHAR2(200)  := 'CONVERSION_TYPE';
  G_CONV_DATE_TOKEN             CONSTANT VARCHAR2(200)  := 'CONVERSION_DATE';

--BUG# 3569441
  G_INVALID_INSTALL_LOC_TYPE CONSTANT VARCHAR2(200) := 'OKL_INVALID_INSTALL_LOC_TYPE';
  G_LOCATION_TYPE_TOKEN      CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE';
  G_LOC_TYPE1_TOKEN          CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE1';
  G_LOC_TYPE2_TOKEN          CONSTANT VARCHAR2(30)  := 'LOCATION_TYPE2';

  G_MISSING_USAGE            CONSTANT VARCHAR2(200) := 'OKL_INSTALL_LOC_MISSING_USAGE';
  G_USAGE_TYPE_TOKEN         CONSTANT VARCHAR2(30)  := 'USAGE_TYPE';
  G_ADDRESS_TOKEN            CONSTANT VARCHAR2(30)  := 'ADDRESS';
  G_INSTANCE_NUMBER_TOKEN    CONSTANT VARCHAR2(30)  := 'INSTANCE_NUMBER';
--END BUG# 3569441
-------------------------------------------------------------------------------------------------
-- GLOBAL EXCEPTION
-------------------------------------------------------------------------------------------------
  G_EXCEPTION_HALT_VALIDATION             EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION             EXCEPTION;
  G_API_TYPE                    CONSTANT  VARCHAR2(4) := '_PVT';
  G_API_VERSION                 CONSTANT  NUMBER := 1.0;
  G_SCOPE                       CONSTANT  VARCHAR2(4) := '_PVT';
-------------------------------------------------------------------------------------------------
-- GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
  G_PKG_NAME	                CONSTANT  VARCHAR2(200) := 'OKL_COPY_ASSET_PVT';
  G_APP_NAME		        CONSTANT  VARCHAR2(3)   :=  OKL_API.G_APP_NAME;
  G_FND_APP                     CONSTANT  VARCHAR2(200) := OKL_API.G_FND_APP;
  G_FIN_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                      OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_FEE_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FEE';
  G_SER_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'SOLD_SERVICE';
  G_UBB_LINE_LTY_CODE                     OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'USAGE';
  G_ID2                         CONSTANT  VARCHAR2(200) := '#';
  G_TRY_TYPE                              OKL_TRX_TYPES_V.TRY_TYPE%TYPE   := 'TIE';
  G_TLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'TLS';
  G_SLS_TYPE                              OKC_LINE_STYLES_V.LSE_TYPE%TYPE := 'SLS';
  G_LEASE_SCS_CODE                        OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LEASE';
  G_LOAN_SCS_CODE                         OKC_K_HEADERS_V.SCS_CODE%TYPE   := 'LOAN';
--  G_FA_TRY_NAME                           OKL_TRX_TYPES_V.NAME%TYPE       := 'CREATE ASSET LINES';
--  G_IB_TRY_NAME                           OKL_TRX_TYPES_V.NAME%TYPE       := 'CREATE_IB_LINES';
  G_TRY_NAME                              OKL_TRX_TYPES_TL.NAME%TYPE     := 'Internal Asset Creation';
  G_LANGUAGE                              OKL_TRX_TYPES_TL.LANGUAGE%TYPE := 'US';
  G_GEN_INST_NUM_IB         CONSTANT  VARCHAR2(200) := 'OKL_LLA_GEN_INST_NUM_IB';
  G_GEN_ASSET_NUMBER        CONSTANT  VARCHAR2(200) := 'OKL_LLA_GEN_ASSET_NUMBER';
-------------------------------------------------------------------------------------------------
-- COMPOSITE GLOBAL VARIABLES
-------------------------------------------------------------------------------------------------
    subtype cimv_rec_type is OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    subtype clev_rec_type is OKL_OKC_MIGRATION_PVT.clev_rec_type;
    subtype klev_rec_type is OKL_CONTRACT_PUB.klev_rec_type;
    subtype trxv_rec_type is OKL_TRX_ASSETS_PUB.thpv_rec_type;
    subtype trxv_tbl_type is OKL_TRX_ASSETS_PUB.thpv_tbl_type;
    subtype talv_rec_type is OKL_TXL_ASSETS_PUB.tlpv_rec_type;
    subtype talv_tbl_type is OKL_TXL_ASSETS_PUB.tlpv_tbl_type;
    subtype txdv_tbl_type is OKL_TXD_ASSETS_PUB.adpv_tbl_type;
    subtype txdv_rec_type is OKL_TXD_ASSETS_PUB.adpv_rec_type;
    subtype itiv_rec_type is OKL_TXL_ITM_INSTS_PUB.iipv_rec_type;
    subtype itiv_tbl_type is OKL_TXL_ITM_INSTS_PUB.iipv_tbl_type;
    subtype sidv_rec_type is OKL_SUPP_INVOICE_DTLS_PUB.sidv_rec_type;
    subtype sidv_tbl_type is OKL_SUPP_INVOICE_DTLS_PUB.sidv_tbl_type;
    TYPE g_ib_id_rec IS RECORD (
    id                             NUMBER := OKL_API.G_MISS_NUM,
    dnz_chr_id                     NUMBER := OKL_API.G_MISS_NUM);

    TYPE g_ib_id_tbl IS TABLE OF g_ib_id_rec
        INDEX BY BINARY_INTEGER;

    TYPE g_ib_item_type IS RECORD (
    object1_id1                    OKC_K_ITEMS_V.OBJECT1_ID1%TYPE := OKL_API.G_MISS_CHAR,
    object1_id2                    OKC_K_ITEMS_V.OBJECT1_ID2%TYPE := OKL_API.G_MISS_CHAR);

    TYPE g_ib_item_tbl IS TABLE OF g_ib_item_type
        INDEX BY BINARY_INTEGER;
-----------------------------------------------------------------------------------------------------------
--Added by dpsingh for LE uptake
CURSOR contract_num_csr (p_ctr_id1 NUMBER) IS
  SELECT  contract_number
  FROM OKC_K_HEADERS_B
  WHERE id = p_ctr_id1;

CURSOR get_chr_id_csr(p_kle_id1 NUMBER) IS
  SELECT  DNZ_CHR_ID
  FROM OKC_K_LINES_B
  WHERE ID = p_kle_id1;

  FUNCTION generate_instance_number_ib(x_instance_number_ib  OUT NOCOPY  OKL_TXL_ITM_INSTS_V.INSTANCE_NUMBER_IB%TYPE)
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
/*
  FUNCTION generate_asset_number(p_old_asset_number IN OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE,
                                 x_asset_number     OUT NOCOPY OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE)
  RETURN VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    -- cursor to get sequence number for asset number
    Cursor c_asset_no(p_old_asset_number OKL_TXL_ASSETS_V.ASSET_NUMBER%TYPE) IS
    select p_old_asset_number||'_'||OKL_FAN_SEQ.NEXTVAL
    FROM dual;
  BEGIN
    OPEN  c_asset_no(p_old_asset_number);
    FETCH c_asset_no INTO x_asset_number;
    IF (c_asset_no%NOTFOUND) Then
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    END IF;
    CLOSE c_asset_no;
    RETURN x_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      IF c_asset_no%ISOPEN THEN
        CLOSE c_asset_no;
      END IF;
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      OKL_API.SET_MESSAGE(p_app_name 	 => g_app_name,
                          p_msg_name	 => g_unexpected_error,
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    RETURN x_return_status;
  END generate_asset_number;
*/
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
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_B
                  WHERE asset_number = p_asset_number);

    CURSOR c_okx_asset_lines_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSET_LINES_V
                  WHERE asset_number = p_asset_number);

    CURSOR c_okx_assets_v(p_asset_number OKX_ASSETS_V.ASSET_NUMBER%TYPE) is
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKX_ASSETS_V
                  WHERE asset_number = p_asset_number);

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
                              p_token1	       => g_sqlcode_token,
                              p_token1_value   => sqlcode,
           			          p_token2	       => g_sqlerrm_token,
                 			  p_token2_value   => sqlerrm);
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
                          p_token1	 => g_sqlcode_token,
                          p_token1_value => sqlcode,
			  p_token2	 => g_sqlerrm_token,
			  p_token2_value => sqlerrm);
    RETURN x_return_status;
  END generate_asset_number;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_from _cle_id
-- Description          : validation with OKC_K_LINES_V
-- Business Rules       : The Line should be a top Line
-- Parameters           : 1.P_cle_id should be the top line
--                        2.x_fa_line_id the Fixed asset line Id
--                          as the same will be the okl_txl_tables
--                        3. Return Status
-- Version              : 1.0
-- End of Commnets
  PROCEDURE validate_from_cle_id(p_cle_id        IN OKC_K_LINES_V.ID%TYPE,
                                 x_fa_line_id    OUT NOCOPY OKL_K_LINES_V.ID%TYPE,
                                 x_ib_id_tbl     OUT NOCOPY g_ib_id_tbl,
                                 x_dnz_chr_id    OUT NOCOPY OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                                 x_return_status OUT NOCOPY VARCHAR2)
  IS
    ln_cle_id             OKC_K_LINES_V.CLE_ID%TYPE;
    ln_chr_id             OKC_K_LINES_V.CHR_ID%TYPE;
    lv_lty_code           OKC_LINE_STYLES_V.LTY_CODE%TYPE;
    lv_lse_type           OKC_LINE_STYLES_V.LSE_TYPE%TYPE;

    i                        NUMBER := 0;
    CURSOR c_cle_id_validate(p_cle_id    OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT cle.cle_id
           ,cle.chr_id
           ,lse.lty_code
           ,lse.lse_type
    FROM okc_k_lines_b cle,
         okc_line_styles_v lse
    WHERE cle.lse_id = lse.id
    AND cle.id = p_cle_id;

    CURSOR c_get_fa_line_id(p_cle_id    OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT cle.id,
           cle.dnz_chr_id
    FROM okc_line_styles_b lse,
         okc_k_lines_v cle
    WHERE cle.cle_id = p_cle_id
    AND lse.id = cle.lse_id
    AND lse.lty_code = G_FA_LINE_LTY_CODE;

    CURSOR c_get_ib_line_id(p_cle_id    OKC_K_LINES_V.ID%TYPE)
    IS
    SELECT cle_ib.id,
           cle_ib.dnz_chr_id
    FROM okc_line_styles_b lse_ib,
         okc_k_lines_b cle_ib,
         okc_line_styles_b lse_inst,
         okc_k_lines_b cle_inst
    WHERE cle_inst.cle_id = p_cle_id
    AND cle_inst.lse_id = lse_inst.id
    AND lse_inst.lty_code = G_INST_LINE_LTY_CODE
    AND cle_ib.cle_id = cle_inst.id
    AND cle_ib.lse_id = lse_ib.id
    AND lse_ib.lty_code = G_IB_LINE_LTY_CODE;

    r_get_ib_line_id    c_get_ib_line_id%ROWTYPE;

  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_cle_id = OKL_API.G_MISS_NUM) OR
       (p_cle_id IS NULL) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Cle_id');
       -- halt validation
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_cle_id_validate(p_cle_id);
    IF c_cle_id_validate%NOTFOUND THEN
      -- store SQL error message on message stack
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'Cle_id');
       -- halt validation
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_cle_id_validate into ln_cle_id,
                                 ln_chr_id,
                                 lv_lty_code,
                                 lv_lse_type;
    CLOSE c_cle_id_validate;
    IF (ln_cle_id IS NULL OR
        ln_cle_id = OKL_API.G_MISS_NUM) AND
        ln_chr_id IS NOT NULL AND
        lv_lty_code = G_FIN_LINE_LTY_CODE AND
        lv_lse_type = G_TLS_TYPE THEN
       OPEN  c_get_fa_line_id(p_cle_id);
       IF c_get_fa_line_id%NOTFOUND THEN
         -- store SQL error message on message stack
         OKL_API.set_message(p_app_name     => G_APP_NAME,
                             p_msg_name     => G_NO_MATCHING_RECORD,
                             p_token1       => G_COL_NAME_TOKEN,
                             p_token1_value => 'FA_Cle_id');
         -- halt validation
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
       FETCH c_get_fa_line_id INTO x_fa_line_id,
                                   x_dnz_chr_id;
       CLOSE c_get_fa_line_id;
       FOR r_get_ib_line_id IN c_get_ib_line_id(p_cle_id) LOOP
         IF c_get_ib_line_id%NOTFOUND THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'IB_Cle_id');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         x_ib_id_tbl(i).id      := r_get_ib_line_id.id;
         IF r_get_ib_line_id.dnz_chr_id <> x_dnz_chr_id THEN
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_NO_MATCHING_RECORD,
                               p_token1       => G_COL_NAME_TOKEN,
                               p_token1_value => 'DNZ_CHR_ID');
            x_return_status := OKL_API.G_RET_STS_ERROR;
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         x_ib_id_tbl(i).dnz_chr_id := r_get_ib_line_id.dnz_chr_id;
         i  := i + 1;
       END LOOP;
       IF x_return_status = OKL_API.G_RET_STS_ERROR THEN
          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    ELSE
       OKL_API.set_message(p_app_name  => G_APP_NAME,
                            p_msg_name => G_LINE_RECORD);
       -- halt validation
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- If the cursor is open then it has to be closed
    IF c_cle_id_validate%ISOPEN THEN
       CLOSE c_cle_id_validate;
    END IF;
    IF c_get_fa_line_id%ISOPEN THEN
       CLOSE c_get_fa_line_id;
    END IF;
    IF c_get_ib_line_id%ISOPEN THEN
       CLOSE c_get_ib_line_id;
    END IF;
    -- notify caller of an error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKL_API.SET_MESSAGE(p_app_name => G_APP_NAME,
                      p_msg_name => G_UNEXPECTED_ERROR,
                      p_token1 => G_SQLCODE_TOKEN,
                      p_token1_value => SQLCODE,
                      p_token2 => G_SQLERRM_TOKEN,
                      p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_cle_id_validate%ISOPEN THEN
       CLOSE c_cle_id_validate;
    END IF;
    IF c_get_fa_line_id%ISOPEN THEN
       CLOSE c_get_fa_line_id;
    END IF;
    IF c_get_ib_line_id%ISOPEN THEN
       CLOSE c_get_ib_line_id;
    END IF;
    -- notify caller of an error as UNEXPETED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_from_cle_id;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : validate_items_ids
-- Description          : validation with OKC_K_ITEMS_V
-- Business Rules       : If the id1 and id2 are populated in okc_k_items_v
--                        we need to get current info from FA and
--                        populate the txl_assets table
--                        if id1 and id2 are null then we there is already info
--                        in txl_assets tables and now we copy that info and
--                        create another record in txl_assets table.
--                        This validation will give me information weather
--                        id1 and id2 are null or not.
-- Parameters           : 1.P_cle_id should be the Fixed asset line or ib line
--                        Function will return the Return Status
-- Version              : 1.0
-- End of Commnets
  FUNCTION validate_items_ids(p_cle_id      IN OKC_K_LINES_V.ID%TYPE,
                              p_dnz_chr_id  IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
                              x_object1_id1 OUT NOCOPY OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                              x_object1_id2 OUT NOCOPY OKC_K_ITEMS_V.OBJECT1_ID2%TYPE)
  RETURN VARCHAR2  IS
    x_return_status       VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_validate_items_ids(p_cle_id      IN OKC_K_LINES_V.ID%TYPE,
                                p_dnz_chr_id  IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT object1_id1,
           object1_id2
    FROM okc_k_items_v cim
    WHERE cim.cle_id = p_cle_id
    AND cim.dnz_chr_id = p_dnz_chr_id
    AND cim.object1_id1 IS NOT NULL
    AND cim.object1_id2 IS NOT NULL;
  BEGIN
    -- data is required
    IF (p_cle_id = OKL_API.G_MISS_NUM OR
       p_cle_id IS NULL) AND
       (p_dnz_chr_id = OKL_API.G_MISS_NUM OR
       p_dnz_chr_id IS NULL) THEN
       -- store SQL error message on message stack
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'dnz_chr_id and Cle_id');
       -- halt validation
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_validate_items_ids(p_cle_id,
                               p_dnz_chr_id);
    FETCH c_validate_items_ids into x_object1_id1,
                                    x_object1_id2;
    CLOSE c_validate_items_ids;
    RETURN x_return_status;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    -- If the cursor is open then it has to be closed
    IF c_validate_items_ids%ISOPEN THEN
       CLOSE c_validate_items_ids;
    END IF;
    RETURN x_return_status;
    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_UNEXPECTED_ERROR,
                          p_token1       => G_SQLCODE_TOKEN,
                          p_token1_value => SQLCODE,
                          p_token2       => G_SQLERRM_TOKEN,
                          p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_validate_items_ids%ISOPEN THEN
       CLOSE c_validate_items_ids;
    END IF;
    -- notify caller of an error as UNEXPETED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
    RETURN x_return_status;
  END validate_items_ids;
---------------------------------------------------------------------------------------------------------------
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
--Bug# 2998115:
             DATE_PAY_INVESTOR_START,
             PAY_INVESTOR_FREQUENCY,
             PAY_INVESTOR_EVENT,
             PAY_INVESTOR_REMITTANCE_DAYS,
             FEE_TYPE,
--Bug#3143522 Subsidies :
             SUBSIDY_ID,
             --SUBSIDIZED_OEC,
             --SUBSIDIZED_CAP_AMOUNT,
             PRE_TAX_YIELD,
             AFTER_TAX_YIELD,
             IMPLICIT_INTEREST_RATE,
             IMPLICIT_NON_IDC_INTEREST_RATE,
             PRE_TAX_IRR,
             AFTER_TAX_IRR,
             SUBSIDY_OVERRIDE_AMOUNT,
--quote
             SUB_PRE_TAX_YIELD,
             SUB_AFTER_TAX_YIELD,
             SUB_IMPL_INTEREST_RATE,
             SUB_IMPL_NON_IDC_INT_RATE,
             SUB_PRE_TAX_IRR,
             SUB_AFTER_TAX_IRR,
--Bug# 2994971
             ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 : 11.510+ schema
             QTE_ID,
             FUNDING_DATE,
             STREAM_TYPE_SUBCLASS
--ramurt Bug#4552772
   ,FEE_PURPOSE_CODE
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
--Bug# 2998115 :
         x_klev_rec.DATE_PAY_INVESTOR_START,
         x_klev_rec.PAY_INVESTOR_FREQUENCY,
         x_klev_rec.PAY_INVESTOR_EVENT,
         x_klev_rec.PAY_INVESTOR_REMITTANCE_DAYS,
         x_klev_rec.FEE_TYPE,
--Bug#3143522 Subsidies :
             x_klev_rec.SUBSIDY_ID,
             --x_klev_rec.SUBSIDIZED_OEC,
             --x_klev_rec.SUBSIDIZED_CAP_AMOUNT,
             x_klev_rec.PRE_TAX_YIELD,
             x_klev_rec.AFTER_TAX_YIELD,
             x_klev_rec.IMPLICIT_INTEREST_RATE,
             x_klev_rec.IMPLICIT_NON_IDC_INTEREST_RATE,
             x_klev_rec.PRE_TAX_IRR,
             x_klev_rec.AFTER_TAX_IRR,
             x_klev_rec.SUBSIDY_OVERRIDE_AMOUNT,
--quote
             x_klev_rec.SUB_PRE_TAX_YIELD,
             x_klev_rec.SUB_AFTER_TAX_YIELD,
             x_klev_rec.SUB_IMPL_INTEREST_RATE,
             x_klev_rec.SUB_IMPL_NON_IDC_INT_RATE,
             x_klev_rec.SUB_PRE_TAX_IRR,
             x_klev_rec.SUB_AFTER_TAX_IRR,
--Bug# 2994971 :
             x_klev_rec.ITEM_INSURANCE_CATEGORY,
--Bug# 3973640 : 11.510+ schema
             x_klev_rec.QTE_ID,
             x_klev_rec.FUNDING_DATE,
             x_klev_rec.STREAM_TYPE_SUBCLASS
--ramurt Bug#4552772
   ,x_klev_rec.FEE_PURPOSE_CODE;
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
-- Function Name        : get_tasv_rec
-- Description          : Get Transaction Header Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_tasv_rec(p_tas_id   IN  NUMBER,
                         x_trxv_rec OUT NOCOPY trxv_rec_type)
  RETURN  VARCHAR2
  IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR c_trxv_rec(p_tas_id NUMBER)
    IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           ICA_ID,
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
           TAS_TYPE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN,
           TSU_CODE,
           TRY_ID,
           DATE_TRANS_OCCURRED,
           TRANS_NUMBER,
           COMMENTS,
           REQ_ASSET_ID,
           TOTAL_MATCH_AMOUNT
    FROM OKL_TRX_ASSETS
    WHERE id = p_tas_id;
  BEGIN
    OPEN c_trxv_rec(p_tas_id);
    FETCH c_trxv_rec INTO
           x_trxv_rec.ID,
           x_trxv_rec.OBJECT_VERSION_NUMBER,
           x_trxv_rec.ICA_ID,
           x_trxv_rec.ATTRIBUTE_CATEGORY,
           x_trxv_rec.ATTRIBUTE1,
           x_trxv_rec.ATTRIBUTE2,
           x_trxv_rec.ATTRIBUTE3,
           x_trxv_rec.ATTRIBUTE4,
           x_trxv_rec.ATTRIBUTE5,
           x_trxv_rec.ATTRIBUTE6,
           x_trxv_rec.ATTRIBUTE7,
           x_trxv_rec.ATTRIBUTE8,
           x_trxv_rec.ATTRIBUTE9,
           x_trxv_rec.ATTRIBUTE10,
           x_trxv_rec.ATTRIBUTE11,
           x_trxv_rec.ATTRIBUTE12,
           x_trxv_rec.ATTRIBUTE13,
           x_trxv_rec.ATTRIBUTE14,
           x_trxv_rec.ATTRIBUTE15,
           x_trxv_rec.TAS_TYPE,
           x_trxv_rec.CREATED_BY,
           x_trxv_rec.CREATION_DATE,
           x_trxv_rec.LAST_UPDATED_BY,
           x_trxv_rec.LAST_UPDATE_DATE,
           x_trxv_rec.LAST_UPDATE_LOGIN,
           x_trxv_rec.TSU_CODE,
           x_trxv_rec.TRY_ID,
           x_trxv_rec.DATE_TRANS_OCCURRED,
           x_trxv_rec.TRANS_NUMBER,
           x_trxv_rec.COMMENTS,
           x_trxv_rec.REQ_ASSET_ID,
           x_trxv_rec.TOTAL_MATCH_AMOUNT;
    IF c_trxv_rec%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE c_trxv_rec;
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
     IF c_trxv_rec%ISOPEN THEN
        CLOSE c_trxv_rec;
     END IF;
      -- notify caller of an UNEXPECTED error
     x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
     RETURN(x_return_status);
  END get_tasv_rec;
------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_sidv_rec
-- Description          : Get Supplier Invoice Details Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_sidv_rec(p_cle_id   IN OKL_SUPP_INVOICE_DTLS.ID%TYPE,
                         x_sidv_rec OUT NOCOPY sidv_rec_type)
  RETURN  VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR okl_supp_invoice_dtls_v_pk_csr(p_id OKL_SUPP_INVOICE_DTLS.ID%TYPE) IS
    SELECT ID,
           OBJECT_VERSION_NUMBER,
           CLE_ID,
           FA_CLE_ID,
           INVOICE_NUMBER,
           DATE_INVOICED,
           DATE_DUE,
           SHIPPING_ADDRESS_ID1,
           SHIPPING_ADDRESS_ID2,
           SHIPPING_ADDRESS_CODE,
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
      FROM Okl_Supp_Invoice_Dtls_V sid
      WHERE sid.cle_id = p_id;
    l_okl_supp_invoice_dtls_v_pk   okl_supp_invoice_dtls_v_pk_csr%ROWTYPE;
  BEGIN
    -- Get current database values
    OPEN okl_supp_invoice_dtls_v_pk_csr (p_id => p_cle_id);
    FETCH okl_supp_invoice_dtls_v_pk_csr INTO
              x_sidv_rec.id,
              x_sidv_rec.object_version_number,
              x_sidv_rec.cle_id,
              x_sidv_rec.fa_cle_id,
              x_sidv_rec.invoice_number,
              x_sidv_rec.date_invoiced,
              x_sidv_rec.date_due,
              x_sidv_rec.shipping_address_id1,
              x_sidv_rec.shipping_address_id2,
              x_sidv_rec.shipping_address_code,
              x_sidv_rec.attribute_category,
              x_sidv_rec.attribute1,
              x_sidv_rec.attribute2,
              x_sidv_rec.attribute3,
              x_sidv_rec.attribute4,
              x_sidv_rec.attribute5,
              x_sidv_rec.attribute6,
              x_sidv_rec.attribute7,
              x_sidv_rec.attribute8,
              x_sidv_rec.attribute9,
              x_sidv_rec.attribute10,
              x_sidv_rec.attribute11,
              x_sidv_rec.attribute12,
              x_sidv_rec.attribute13,
              x_sidv_rec.attribute14,
              x_sidv_rec.attribute15,
              x_sidv_rec.created_by,
              x_sidv_rec.creation_date,
              x_sidv_rec.last_updated_by,
              x_sidv_rec.last_update_date,
              x_sidv_rec.last_update_login;
    IF okl_supp_invoice_dtls_v_pk_csr%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'OKL_SUPP_INVOICE_DTLS Record');
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_supp_invoice_dtls_v_pk_csr;
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
      IF okl_supp_invoice_dtls_v_pk_csr%ISOPEN THEN
        CLOSE okl_supp_invoice_dtls_v_pk_csr;
      END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END get_sidv_rec;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_txlv_rec
-- Description          : Get Transaction Line Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_txlv_rec(p_kle_id   IN NUMBER,
                         x_txlv_rec OUT NOCOPY talv_rec_type)
  RETURN  VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
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
-- Multi-Currency Change
           CURRENCY_CODE,
           CURRENCY_CONVERSION_TYPE,
           CURRENCY_CONVERSION_RATE,
           CURRENCY_CONVERSION_DATE
-- Multi-Currency Change
    FROM Okl_Txl_Assets_V tal
    WHERE tal.kle_id  = p_kle_id;
    l_okl_talv_pk                  okl_talv_pk_csr%ROWTYPE;
  BEGIN
    -- Get current database values
    OPEN okl_talv_pk_csr(p_kle_id);
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
--Bug# 2181308
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
-- Multi-Currency Change
              x_txlv_rec.CURRENCY_CODE,
              x_txlv_rec.CURRENCY_CONVERSION_TYPE,
              x_txlv_rec.CURRENCY_CONVERSION_RATE,
              x_txlv_rec.CURRENCY_CONVERSION_DATE;
-- Multi-Currency Change
    IF okl_talv_pk_csr%NOTFOUND THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    CLOSE okl_talv_pk_csr;
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
      IF okl_talv_pk_csr%ISOPEN THEN
        CLOSE okl_talv_pk_csr;
      END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END get_txlv_rec;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_txdv_rec
-- Description          : Get Transaction Detail Line Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION get_txdv_tbl(p_tal_id   IN NUMBER,
                        x_txdv_tbl OUT NOCOPY txdv_tbl_type)
  RETURN  VARCHAR2
  IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    i                          NUMBER := 0;
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
           inventory_item_id ,
-- Multi-Currency Change
           currency_code,
           currency_conversion_type,
           currency_conversion_rate,
           currency_conversion_date
-- Multi-Currency Change
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
        x_txdv_tbl(i).ASSET_NUMBER           := r_okl_asdv_pk_csr.ASSET_NUMBER;
        x_txdv_tbl(i).QUANTITY               := r_okl_asdv_pk_csr.QUANTITY;
        x_txdv_tbl(i).COST                   := r_okl_asdv_pk_csr.COST;
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
-- Multi-Currency Change
        x_txdv_tbl(i).CURRENCY_CODE            := r_okl_asdv_pk_csr.currency_code;
        x_txdv_tbl(i).CURRENCY_CONVERSION_TYPE := r_okl_asdv_pk_csr.currency_conversion_type;
        x_txdv_tbl(i).CURRENCY_CONVERSION_RATE := r_okl_asdv_pk_csr.currency_conversion_rate;
        x_txdv_tbl(i).CURRENCY_CONVERSION_DATE := r_okl_asdv_pk_csr.currency_conversion_date;
-- Multi-Currency Change
        i := i + 1;
       IF c_okl_asdv_pk_csr%NOTFOUND THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
       END IF;
    END LOOP;
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
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Function Name        : get_itiv_rec
-- Description          : Get Transaction item instance Record
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  FUNCTION  get_itiv_rec(p_kle_id   IN NUMBER,
                         x_itiv_rec OUT NOCOPY itiv_rec_type)
  RETURN  VARCHAR2 IS
    x_return_status            VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
    CURSOR okl_itiv_pk_csr (p_kle_id     IN NUMBER) IS
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
  BEGIN
    -- Get current database values
    OPEN okl_itiv_pk_csr (p_kle_id);
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
      OKL_API.set_message(
              G_APP_NAME,
              G_UNEXPECTED_ERROR,
              G_SQLCODE_TOKEN,
              SQLCODE,
              G_SQLERRM_TOKEN,
              SQLERRM);
      IF okl_itiv_pk_csr%ISOPEN THEN
        CLOSE okl_itiv_pk_csr;
      END IF;
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END get_itiv_rec;
--------------------------------------------------------------------------
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
                           p_token1_value => 'Try Name');
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN c_get_try_id(p_try_name);
    FETCH c_get_try_id INTO x_try_id;
    IF c_get_try_id%NOTFOUND THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'Try Name');
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
      OKL_API.set_message(
              G_APP_NAME,
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
--4-------------------------------------------------------------------------
-- FUNCTION get_rec for: OKC_K_ITEMS_V
---------------------------------------------------------------------------
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
      OKL_API.set_message(
              G_APP_NAME,
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
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Create_asset_header
-- Description          : Creation of Asset Header
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
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
  END Create_asset_header;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Update_asset_header
-- Description          : Update of Asset Header
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
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
  END Update_asset_header;
-------------------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Create_asset_lines
-- Description          : Creation of Asset Lines
-- Business Rules       :
-- Parameters           :
-- Version              :
-- End of Commnets
  PROCEDURE Create_asset_lines(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_talv_rec       IN  talv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ASSET_LINE';
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
    OKL_TXL_ASSETS_PUB.create_txl_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_tlpv_rec       => p_talv_rec,
                       x_tlpv_rec       => x_talv_rec);
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
    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_adpv_tbl       => p_txdv_tbl,
                       x_adpv_tbl       => x_txdv_tbl);
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
            p_txdv_rec       IN  txdv_rec_type,
            x_txdv_rec       OUT NOCOPY txdv_rec_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXD_ASSET_DTL';
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
    OKL_TXD_ASSETS_PUB.create_txd_asset_def(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_adpv_rec       => p_txdv_rec,
                       x_adpv_rec       => x_txdv_rec);
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
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_txl_iti(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';
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
    OKL_TXL_ITM_INSTS_PUB.create_txl_itm_insts(
                       p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_iipv_rec       => p_itiv_rec,
                       x_iipv_rec       => x_itiv_rec);
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
  END create_txl_iti;
--------------------------------------------------------------------------------------------------------------
  PROCEDURE create_supp_invoice_dtls(p_api_version   IN NUMBER,
                                     p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                     x_return_status OUT NOCOPY VARCHAR2,
                                     x_msg_count     OUT NOCOPY NUMBER,
                                     x_msg_data      OUT NOCOPY VARCHAR2,
                                     p_cle_id        IN  OKC_K_LINES_V.ID%TYPE,
                                     p_fin_cle_id    IN  OKC_K_LINES_V.ID%TYPE) IS

    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_SID';
    ln_cle_id       OKL_SUPP_INVOICE_DTLS.CLE_ID%TYPE;
    ln_fa_cle_id    OKL_SUPP_INVOICE_DTLS.FA_CLE_ID%TYPE;
    l_sidv_rec      sidv_rec_type;
    lx_sidv_rec     sidv_rec_type;
    lad_sidv_rec    sidv_rec_type;
    ladx_sidv_rec   sidv_rec_type;
    i               NUMBER :=0;
    ln_dummy        NUMBER :=0;
    ln1_dummy       NUMBER :=0;
    CURSOR c_validate_supp(p_cle_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT 1
                  FROM OKL_SUPP_INVOICE_DTLS_V
                  WHERE cle_id = p_cle_id);

   CURSOR c_model_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT cle_ml.id ml_cle_id,
           cle_fa.id fa_cle_id
    FROM OKC_K_LINES_V cle_fa,
         OKC_LINE_STYLES_V lse_fa,
         OKC_K_LINES_V cle_ml,
         OKC_LINE_STYLES_V lse_ml
    WHERE cle_ml.cle_id = p_cle_id
    AND cle_ml.lse_id = lse_ml.id
    AND lse_ml.lty_code = G_MODEL_LINE_LTY_CODE
    AND cle_fa.cle_id = cle_ml.cle_id
    AND cle_fa.dnz_chr_id = cle_ml.dnz_chr_id
    AND cle_fa.lse_id = lse_fa.id
    AND lse_fa.lty_code = G_FA_LINE_LTY_CODE;

    CURSOR c_addon_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT cle_ad.id ad_cle_id,
           cle_fa.id fa_cle_id
    FROM OKC_K_LINES_V cle_ad,
         OKC_LINE_STYLES_V lse_ad,
         OKC_K_LINES_V cle_fa,
         OKC_LINE_STYLES_V lse_fa,
         OKC_K_LINES_V cle_ml,
         OKC_LINE_STYLES_V lse_ml
    WHERE cle_ml.cle_id = p_cle_id
    AND cle_ml.lse_id = lse_ml.id
    AND lse_ml.lty_code = G_MODEL_LINE_LTY_CODE
    AND cle_fa.cle_id = cle_ml.cle_id
    AND cle_fa.dnz_chr_id = cle_ml.dnz_chr_id
    AND cle_fa.lse_id = lse_fa.id
    AND lse_fa.lty_code = G_FA_LINE_LTY_CODE
    AND cle_ad.cle_id = cle_ml.id
    AND cle_ad.dnz_chr_id = cle_ml.dnz_chr_id
    AND cle_ad.lse_id = lse_ad.id
    AND lse_ad.lty_code = G_ADDON_LINE_LTY_CODE;

    CURSOR c_new_addon_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE,
                               p_orig_cle_id OKC_K_LINES_V.ORIG_SYSTEM_ID1%TYPE)
    IS
    SELECT cle_ad.id ad_cle_id,
           cle_fa.id fa_cle_id
    FROM OKC_K_LINES_V cle_ad,
         OKC_LINE_STYLES_V lse_ad,
         OKC_K_LINES_V cle_fa,
         OKC_LINE_STYLES_V lse_fa,
         OKC_K_LINES_V cle_ml,
         OKC_LINE_STYLES_V lse_ml
    WHERE cle_ml.cle_id = p_cle_id
    AND cle_ml.lse_id = lse_ml.id
    AND lse_ml.lty_code = G_MODEL_LINE_LTY_CODE
    AND cle_fa.cle_id = cle_ml.cle_id
    AND cle_fa.dnz_chr_id = cle_ml.dnz_chr_id
    AND cle_fa.lse_id = lse_fa.id
    AND lse_fa.lty_code = G_FA_LINE_LTY_CODE
    AND cle_ad.cle_id = cle_ml.id
    AND cle_ad.orig_system_id1 = p_orig_cle_id
    AND cle_ad.dnz_chr_id = cle_ml.dnz_chr_id
    AND cle_ad.lse_id = lse_ad.id
    AND lse_ad.lty_code = G_ADDON_LINE_LTY_CODE;

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
    OPEN  c_model_line_id(p_cle_id => p_cle_id);
    FETCH c_model_line_id INTO ln_cle_id,
                               ln_fa_cle_id;
    CLOSE c_model_line_id;
    OPEN  c_validate_supp(p_cle_id => ln_cle_id);
    FETCH c_validate_supp INTO ln_dummy;
    CLOSE c_validate_supp;
    -- Copy the supplier Invoice Details associated to Model line
    IF ln_dummy = 1 THEN
      -- Get the SID Record
      x_return_status := get_sidv_rec(p_cle_id   => ln_cle_id,
                                      x_sidv_rec => l_sidv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         OKL_API.set_message(p_app_name      => G_APP_NAME,
                             p_msg_name      => G_NO_MATCHING_RECORD,
                             p_token1        => G_COL_NAME_TOKEN,
                             p_token1_value  => 'OKL_SUPP_INVOICE_DTLS_V record');
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         OKL_API.set_message(p_app_name      => G_APP_NAME,
                             p_msg_name      => G_NO_MATCHING_RECORD,
                             p_token1        => G_COL_NAME_TOKEN,
                             p_token1_value  => 'OKL_SUPP_INVOICE_DTLS_V record');
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      OPEN  c_model_line_id(p_cle_id => p_fin_cle_id);
      FETCH c_model_line_id INTO l_sidv_rec.cle_id,
                                 l_sidv_rec.fa_cle_id;
      CLOSE c_model_line_id;
      OKL_SUPP_INVOICE_DTLS_PUB.create_sup_inv_dtls(
                         p_api_version    => p_api_version,
                         p_init_msg_list  => p_init_msg_list,
                         x_return_status  => x_return_status,
                         x_msg_count      => x_msg_count,
                         x_msg_data       => x_msg_data,
                         p_sidv_rec       => l_sidv_rec,
                         x_sidv_rec       => lx_sidv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    -- Copy the supplier Invoice Details associated to Add on line
    FOR r_addon_line_id IN c_addon_line_id(p_cle_id => p_cle_id) LOOP
      IF r_addon_line_id.ad_cle_id IS NOT NULL OR
         r_addon_line_id.ad_cle_id <> OKL_API.G_MISS_NUM THEN
        OPEN  c_validate_supp(p_cle_id => r_addon_line_id.ad_cle_id);
        FETCH c_validate_supp INTO ln1_dummy;
        CLOSE c_validate_supp;
        IF ln1_dummy = 1 THEN
          x_return_status := get_sidv_rec(p_cle_id   => r_addon_line_id.ad_cle_id,
                                          x_sidv_rec => lad_sidv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_NO_MATCHING_RECORD,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'OKL_SUPP_INVOICE_DTLS_V record');
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             OKL_API.set_message(p_app_name      => G_APP_NAME,
                                 p_msg_name      => G_NO_MATCHING_RECORD,
                                 p_token1        => G_COL_NAME_TOKEN,
                                 p_token1_value  => 'OKL_SUPP_INVOICE_DTLS_V record');
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          OPEN  c_new_addon_line_id(p_cle_id => p_fin_cle_id,
                                    p_orig_cle_id => r_addon_line_id.ad_cle_id);
          FETCH c_new_addon_line_id INTO lad_sidv_rec.cle_id,
                                         lad_sidv_rec.fa_cle_id;
          CLOSE c_new_addon_line_id;
          OKL_SUPP_INVOICE_DTLS_PUB.create_sup_inv_dtls(
                             p_api_version    => p_api_version,
                             p_init_msg_list  => p_init_msg_list,
                             x_return_status  => x_return_status,
                             x_msg_count      => x_msg_count,
                             x_msg_data       => x_msg_data,
                             p_sidv_rec       => lad_sidv_rec,
                             x_sidv_rec       => ladx_sidv_rec);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
          ln1_dummy := 0;
        END IF;
      END IF;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    IF c_validate_supp%ISOPEN THEN
      CLOSE c_validate_supp;
    END IF;
    IF c_model_line_id%ISOPEN THEN
      CLOSE c_model_line_id;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_new_addon_line_id%ISOPEN THEN
      CLOSE c_new_addon_line_id;
    END IF;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    IF c_validate_supp%ISOPEN THEN
      CLOSE c_validate_supp;
    END IF;
    IF c_model_line_id%ISOPEN THEN
      CLOSE c_model_line_id;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_new_addon_line_id%ISOPEN THEN
      CLOSE c_new_addon_line_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    IF c_validate_supp%ISOPEN THEN
      CLOSE c_validate_supp;
    END IF;
    IF c_model_line_id%ISOPEN THEN
      CLOSE c_model_line_id;
    END IF;
    IF c_addon_line_id%ISOPEN THEN
      CLOSE c_addon_line_id;
    END IF;
    IF c_new_addon_line_id%ISOPEN THEN
      CLOSE c_new_addon_line_id;
    END IF;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_supp_invoice_dtls;
-------------------------------------------------------------------------------------------------------
  PROCEDURE Create_asset_lines(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_talv_rec       IN  talv_rec_type,
            p_trans_type     IN  OKL_TRX_ASSETS.TAS_TYPE%TYPE,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ASSET_LINE';
    l_trxv_rec               trxv_rec_type;
    l_talv_rec               talv_rec_type;

--Added by dpsingh for LE uptake
  l_chr_id  NUMBER;
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
    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'try_id');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'try_id');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;
    l_trxv_rec.tas_type            := p_trans_type;

     --Added by dpsingh for LE Uptake
    OPEN get_chr_id_csr(p_talv_rec.kle_id);
    FETCH get_chr_id_csr INTO l_chr_id;
    CLOSE get_chr_id_csr;
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_chr_id) ;
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       l_talv_rec.tal_type       := p_trans_type;
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
    IF p_trans_type NOT IN ('CRB','CRL','CSP','CRV','ALI') THEN
--      x_return_status := generate_asset_number(p_old_asset_number => l_talv_rec.asset_number,
--                                               x_asset_number => l_talv_rec.asset_number);
      x_return_status := generate_asset_number(x_asset_number => l_talv_rec.asset_number);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name  => G_GEN_ASSET_NUMBER);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_GEN_ASSET_NUMBER);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
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
-------------------------------------------------------------------------------------------------------
  PROCEDURE Create_Asset_trx_txl_txd(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cle_id         IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            p_fin_cle_id     IN  OKC_K_LINES_V.ID%TYPE,
            p_trans_type     IN  OKL_TRX_ASSETS.TAS_TYPE%TYPE,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_talv_rec       OUT NOCOPY talv_rec_type,
            x_txdv_tbl       OUT NOCOPY txdv_tbl_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_HEADER_LINE_DETAILS';
    l_trxv_rec               trxv_rec_type;
    l_talv_rec               talv_rec_type;
    l_txdv_tbl               txdv_tbl_type;
    ln_dummy                 NUMBER :=0;
    i                        NUMBER :=0;
    CURSOR c_trans_line_dtl_exist(p_tal_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXD_ASSETS_V
                  WHERE tal_id = p_tal_id);

    CURSOR c_fa_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE
                        ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FA_LINE_LTY_CODE;

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
    -- Get the TAL Rec
    x_return_status := get_txlv_rec(p_kle_id   => p_cle_id,
                                    x_txlv_rec => l_talv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name      => G_APP_NAME,
                           p_msg_name      => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TXL_ASSETS_V record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TXL_ASSETS_V record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since the above get rec itiv will get the old kle_id
    -- w.r.t p_from cle_id(top Line).
    -- but We have to replace the same with new fixed asset id
    -- with respect to new  x_cle_id(top line).
    OPEN  c_fa_line_id(p_fin_cle_id,
                       p_dnz_chr_id);
    FETCH c_fa_line_id INTO l_talv_rec.kle_id;
    CLOSE c_fa_line_id;
    -- Get the TRX Rec
    x_return_status := get_tasv_rec(p_tas_id   => l_talv_rec.tas_id,
                                    x_trxv_rec => l_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TRX_ASSETS record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TRX_ASSETS record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tas_type := p_trans_type;
    l_trxv_rec.tsu_code := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;

     --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_dnz_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_dnz_chr_id);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
    l_talv_rec.tal_type := p_trans_type;
    -- Now we shoudl generate the Serial number
    IF p_trans_type NOT IN ('CRB','CRL','CSP','CRV','ALI') THEN
--      x_return_status := generate_asset_number(p_old_asset_number => l_talv_rec.asset_number,
--                                               x_asset_number => l_talv_rec.asset_number);
      x_return_status := generate_asset_number(x_asset_number => l_talv_rec.asset_number);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                           p_msg_name  => G_GEN_ASSET_NUMBER);
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_GEN_ASSET_NUMBER);
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    l_talv_rec.dnz_khr_id            := p_dnz_chr_id;
    l_talv_rec.tas_id                := x_trxv_rec.id;
    --Bug# 3657624 : Depreciation Rate should not be multiplied by 100
    /*
    --Bug# 3621663 : Flat rate support
    If nvl(l_talv_rec.deprn_rate,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
        l_talv_rec.deprn_rate := l_talv_rec.deprn_rate * 100;
    End If;
    --Bug# 3621663 End
    */
    --Bug# 3657624 End
    -- Now we are creating the new line record
    Create_asset_lines(p_api_version    => p_api_version,
                       p_init_msg_list  => p_init_msg_list,
                       x_return_status  => x_return_status,
                       x_msg_count      => x_msg_count,
                       x_msg_data       => x_msg_data,
                       p_talv_rec       => l_talv_rec,
                       x_talv_rec       => x_talv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_KLE_ID);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_KLE_ID);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Check to see if the Asset Details Records are there
    OPEN  c_trans_line_dtl_exist(l_talv_rec.id);
    FETCH c_trans_line_dtl_exist INTO ln_dummy;
    CLOSE c_trans_line_dtl_exist;
    IF ln_dummy = 1 THEN
       x_return_status := get_txdv_tbl(p_tal_id   => l_talv_rec.id,
                                       x_txdv_tbl => l_txdv_tbl);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TXD_ASSETS_V record');
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TXD_ASSETS_V record');
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
       IF (l_txdv_tbl.COUNT > 0) THEN
         i := l_txdv_tbl.FIRST;
         LOOP
           l_txdv_tbl(i).asset_number := l_talv_rec.asset_number;
           l_txdv_tbl(i).tal_id       := x_talv_rec.id;
           --Bug# 3657624 : Depreciation Rate should not be multiplied by 100
           /*
           --Bug# 3621663 : Flat rate support
           If nvl(l_txdv_tbl(i).deprn_rate_tax,OKL_API.G_MISS_NUM) <> OKL_API.G_MISS_NUM then
               l_txdv_tbl(i).deprn_rate_tax := l_txdv_tbl(i).deprn_rate_tax * 100;
           End If;
           --Bug# 3621663
           */
           --Bug# 3657624 End
           EXIT WHEN (i = l_txdv_tbl.LAST);
           i := l_txdv_tbl.NEXT(i);
         END LOOP;
       END IF;
       Create_asset_line_details(p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 p_txdv_tbl       => l_txdv_tbl,
                                 x_txdv_tbl       => x_txdv_tbl);
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TXD_ID);
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TXD_ID);
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
    IF c_trans_line_dtl_exist%ISOPEN THEN
       CLOSE c_trans_line_dtl_exist;
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
     IF c_fa_line_id%ISOPEN THEN
        CLOSE c_fa_line_id;
     END IF;
     IF c_trans_line_dtl_exist%ISOPEN THEN
        CLOSE c_trans_line_dtl_exist;
     END IF;
  END Create_Asset_trx_txl_txd;
--------------------------------------------------------------------------------------------------------------
PROCEDURE Create_Asset_trx_txl_For_Loan(
            p_api_version     IN  NUMBER,
            p_init_msg_list   IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status   OUT NOCOPY VARCHAR2,
            x_msg_count       OUT NOCOPY NUMBER,
            x_msg_data        OUT NOCOPY VARCHAR2,
            p_cle_id          IN  OKC_K_LINES_V.ID%TYPE,
            p_from_dnz_chr_id IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            p_to_dnz_chr_id   IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            p_fin_cle_id      IN  OKC_K_LINES_V.ID%TYPE,
            p_trans_type      IN  OKL_TRX_ASSETS.TAS_TYPE%TYPE,
            x_trxv_rec        OUT NOCOPY trxv_rec_type,
            x_talv_rec        OUT NOCOPY talv_rec_type,
            x_txdv_tbl        OUT NOCOPY txdv_tbl_type) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_ASSET_TRX_LOAN';
    l_trxv_rec               trxv_rec_type;
    l_talv_rec               talv_rec_type;
    l_txdv_tbl               txdv_tbl_type;
    ln_dummy                 NUMBER :=0;
    i                        NUMBER :=0;

    Cursor get_txl_csr (p_fa_cle_id  IN NUMBER,
                        p_chr_id     IN NUMBER) IS
    Select fin_tl.name                  Asset_Number,
           fin_tl.item_description      description,
           mdl_cle.price_unit           unit_price,
           mdl_cim.number_of_items      units,
           fin_kle.oec                  oec,
           fa_kle.year_built            Year_of_Manufacture
    From   okc_k_items        mdl_cim,
           okc_k_lines_b      mdl_cle,
           okc_line_styles_b  mdl_lse,
           okl_k_lines        fin_kle,
           okc_k_lines_tl     fin_tl,
           okc_k_lines_b      fin_cle,
           okc_line_styles_b  fin_lse,
           okl_k_lines        fa_kle,
           okc_k_lines_b      fa_cle,
           okc_line_styles_b  fa_lse
    where  mdl_cim.cle_id     = mdl_cle.id
    and    mdl_cim.dnz_chr_id = mdl_cle.dnz_chr_id
    and    mdl_cle.cle_id     = fin_cle.id
    and    mdl_cle.dnz_chr_id = fin_cle.dnz_chr_id
    and    mdl_cle.lse_id     = mdl_lse.id
    and    mdl_lse.lty_code   = 'ITEM'
    and    fin_kle.id         = fin_cle.id
    and    fin_tl.id          = fin_cle.id
    and    fin_tl.language    = USERENV('LANG')
    and    fin_cle.lse_id     = fin_lse.id
    and    fin_lse.lty_code   = 'FREE_FORM1'
    and    fin_cle.id         = fa_cle.cle_id
    and    fin_cle.dnz_chr_id = fa_cle.dnz_chr_id
    and    fa_kle.id          = fa_cle.id
    and    fa_cle.lse_id      = fa_lse.id
    and    fa_lse.lty_code    = 'FIXED_ASSET'
    and    fa_cle.id      = p_fa_cle_id
    and    fa_cle.dnz_chr_id  = p_chr_id;

    get_txl_rec get_txl_csr%ROWTYPE;

    CURSOR try_id_csr(p_try_name  OKL_TRX_TYPES_V.NAME%TYPE) IS
    SELECT id
    FROM   OKL_TRX_TYPES_tl
    WHERE  upper(name) = upper(p_try_name)
    AND    language = 'US';

    l_try_id  NUMBER;

    CURSOR c_fa_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE
                        ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.cle_id   = p_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id     = lse.id
    AND lse.lty_code   = G_FA_LINE_LTY_CODE;

--Added by dpsingh for LE uptake
 l_cntrct_number          OKC_K_HEADERS_B.CONTRACT_NUMBER%TYPE;
  l_legal_entity_id         NUMBER;

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

    Open get_txl_csr(p_fa_cle_id  => p_cle_id,
                     p_chr_id     => p_from_dnz_chr_id);
    Fetch get_txl_csr into get_txl_rec;
    IF get_txl_csr%NOTFOUND Then
        OKL_API.set_message(p_app_name      => G_APP_NAME,
                            p_msg_name      => G_NO_MATCHING_RECORD,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'OKL_TXL_ASSETS_V record');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    Else
        --get try id
        Open  try_id_csr(p_try_name => 'Internal Asset Creation');
        Fetch try_id_csr into l_try_id;
        If try_id_csr%NOTFOUND then
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'OKL_TRX_TYPES_V.ID');
             RAISE OKL_API.G_EXCEPTION_ERROR;
        End If;
        Close try_id_csr;

        l_trxv_rec.try_id   := l_try_id;
        l_trxv_rec.tas_type := p_trans_type;
        l_trxv_rec.tsu_code := 'ENTERED';
        l_trxv_rec.date_trans_occurred := sysdate;
        --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_from_dnz_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_from_dnz_chr_id);
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
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;

        OPEN  c_fa_line_id(p_fin_cle_id,
                           p_to_dnz_chr_id);
        FETCH c_fa_line_id INTO l_talv_rec.kle_id;
        CLOSE c_fa_line_id;

        l_talv_rec.tal_type := p_trans_type;

        -- Now we should generate the Asset number
        IF p_trans_type NOT IN ('CRB','CRL','CSP','CRV','ALI') THEN
          x_return_status := generate_asset_number(x_asset_number => l_talv_rec.asset_number);
          IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
            OKL_API.set_message(p_app_name => G_APP_NAME,
                                p_msg_name  => G_GEN_ASSET_NUMBER);
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;
        ELSE
          l_talv_rec.asset_number := get_txl_rec.ASSET_NUMBER;
        END IF;

        l_talv_rec.dnz_khr_id            := p_to_dnz_chr_id;
        l_talv_rec.tas_id                := x_trxv_rec.id;
        l_talv_rec.line_number           := 1;
        l_talv_rec.original_cost         := get_txl_rec.OEC;
        l_talv_rec.current_units         := get_txl_rec.UNITS;
        l_talv_rec.year_manufactured     := get_txl_rec.Year_of_Manufacture;
        l_talv_rec.Depreciation_Cost     := get_txl_rec.OEC;

        -- Now we are creating the new line record
        Create_asset_lines(p_api_version    => p_api_version,
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
    End If;
    Close get_txl_csr;
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
    IF get_txl_csr%ISOPEN THEN
       CLOSE get_txl_csr;
    END IF;
    IF try_id_csr%ISOPEN THEN
       CLOSE try_id_csr;
    END IF;
    IF c_fa_line_id%ISOPEN THEN
       CLOSE c_fa_line_id;
    END IF;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    IF get_txl_csr%ISOPEN THEN
        CLOSE get_txl_csr;
    END IF;
    IF try_id_csr%ISOPEN THEN
       CLOSE try_id_csr;
    END IF;
    IF c_fa_line_id%ISOPEN THEN
       CLOSE c_fa_line_id;
    END IF;

    WHEN OTHERS THEN
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
     IF get_txl_csr%ISOPEN THEN
        CLOSE get_txl_csr;
     END IF;
     IF try_id_csr%ISOPEN THEN
        CLOSE try_id_csr;
     END IF;
     IF c_fa_line_id%ISOPEN THEN
        CLOSE c_fa_line_id;
     END IF;
END  Create_Asset_trx_txl_For_Loan;
---19-----------------------------------------------------------------------------------------------------------
-- Local Procedures for creation of Txl Item Instance record
  PROCEDURE create_txl_itm_insts(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_itiv_rec                     IN itiv_rec_type,
    p_trans_type                   IN OKL_TRX_ASSETS.TAS_TYPE%TYPE,
    p_asset_number                 IN OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
    x_trxv_rec                     OUT NOCOPY trxv_rec_type,
    x_itiv_rec                     OUT NOCOPY itiv_rec_type) IS

    l_trxv_rec               trxv_rec_type;
    l_itiv_rec               itiv_rec_type;
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_TXL_ITM_INSTS';

    --Added by dpsingh for LE uptake
    l_chr_id                      NUMBER;
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

    x_return_status := get_try_id(p_try_name => G_TRY_NAME,
                                  x_try_id   => l_trxv_rec.try_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'try id');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'try id');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;
    l_trxv_rec.tas_type            := p_trans_type;

     --Added by dpsingh for LE Uptake
    OPEN get_chr_id_csr(p_itiv_rec.kle_id);
    FETCH get_chr_id_csr INTO l_chr_id;
    CLOSE get_chr_id_csr;
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(l_chr_id) ;
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       l_itiv_rec.tal_type       := p_trans_type;
    END IF;
    --Generate the Instance Number IB
    x_return_status := generate_instance_number_ib(x_instance_number_ib => l_itiv_rec.instance_number_ib);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                         p_msg_name  => G_GEN_INST_NUM_IB);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_GEN_INST_NUM_IB);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_itiv_rec.instance_number_ib := nvl(p_asset_number,null)||'-'||l_itiv_rec.instance_number_ib;
    -- evaluate conditions, build outcomes for true conditions and
    -- put them on outcome queue
    create_txl_iti(p_api_version   => p_api_version,
                   p_init_msg_list => p_init_msg_list,
                   x_return_status => x_return_status,
                   x_msg_count     => x_msg_count,
                   x_msg_data      => x_msg_data,
                   p_itiv_rec      => l_itiv_rec,
                   x_itiv_rec      => x_itiv_rec);
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
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
  END create_txl_itm_insts;
-------------------------------------------------------------------------------------------------------
  PROCEDURE Create_Asset_header_instance(
            p_api_version    IN  NUMBER,
            p_init_msg_list  IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status  OUT NOCOPY VARCHAR2,
            x_msg_count      OUT NOCOPY NUMBER,
            x_msg_data       OUT NOCOPY VARCHAR2,
            p_cle_id         IN  OKC_K_LINES_V.ID%TYPE,
            p_new_cle_id     IN  OKC_K_LINES_V.ID%TYPE,
            p_dnz_chr_id     IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE,
            p_trans_type     IN OKL_TRX_ASSETS.TAS_TYPE%TYPE,
            p_asset_number   IN OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE,
            p_fin_cle_id     IN  OKC_K_LINES_V.ID%TYPE,
            x_trxv_rec       OUT NOCOPY trxv_rec_type,
            x_itiv_rec       OUT NOCOPY itiv_rec_type)
  IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_HEADER_LINE_DETAILS';
    l_trxv_rec               trxv_rec_type;
    l_itiv_rec               itiv_rec_type;

    CURSOR c_ib_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE
                        ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_IB_LINE_LTY_CODE
    AND cle.cle_id in (SELECT cle.id
                       FROM OKC_K_LINES_V cle,
                            OKC_LINE_STYLES_V lse
                       WHERE cle.cle_id = p_cle_id
                       AND cle.lse_id = lse.id
                       AND lse.lty_code = G_INST_LINE_LTY_CODE
                       AND cle.dnz_chr_id = p_dnz_chr_id);
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
    -- Get the TAL Rec
    x_return_status := get_itiv_rec(p_kle_id   => p_cle_id,
                                    x_itiv_rec => l_itiv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ITM_INSTS_V record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'OKL_TXL_ITM_INSTS_V record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Since the above get rec itiv will get the old kle_id
    -- w.r.t p_from cle_id(top Line).
    -- but We have to replace the same with new install base id
    -- with respect to new  x_cle_id(top line).
    OPEN  c_ib_line_id(p_fin_cle_id,
                       p_dnz_chr_id);
    FETCH c_ib_line_id INTO l_itiv_rec.kle_id;
    CLOSE c_ib_line_id;
    -- Get the TRX Rec
    x_return_status := get_tasv_rec(p_tas_id   => l_itiv_rec.tas_id,
                                    x_trxv_rec => l_trxv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TRX_ASSETS record');
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_NO_MATCHING_RECORD,
                           p_token1        => G_COL_NAME_TOKEN,
                           p_token1_value  => 'OKL_TRX_ASSETS record');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_trxv_rec.tsu_code            := 'ENTERED';
    l_trxv_rec.date_trans_occurred := sysdate;
    l_trxv_rec.tas_type            := p_trans_type;

    --Added by dpsingh for LE Uptake
    l_legal_entity_id  := OKL_LEGAL_ENTITY_UTIL.get_khr_le_id(p_dnz_chr_id) ;
    IF  l_legal_entity_id IS NOT NULL THEN
       l_trxv_rec.legal_entity_id :=  l_legal_entity_id;
    ELSE
        -- get the contract number
       OPEN contract_num_csr(p_dnz_chr_id);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_TRX_ID);
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
    l_itiv_rec.tal_type := p_trans_type;
    l_itiv_rec.tas_id   := x_trxv_rec.id;
    --Generate the Instance Number IB
    x_return_status := generate_instance_number_ib(x_instance_number_ib => l_itiv_rec.instance_number_ib);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                         p_msg_name  => G_GEN_INST_NUM_IB);
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name => G_APP_NAME,
                          p_msg_name => G_GEN_INST_NUM_IB);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_itiv_rec.kle_id := p_new_cle_id;
    l_itiv_rec.dnz_cle_id := p_fin_cle_id;
    l_itiv_rec.instance_number_ib := nvl(p_asset_number,null)||'-'||l_itiv_rec.instance_number_ib;
    -- Now we are creating the new item instance record
    create_txl_iti(p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_itiv_rec       => l_itiv_rec,
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
    IF c_ib_line_id%ISOPEN THEN
       CLOSE c_ib_line_id;
    END IF;
  END Create_Asset_header_instance;
----------------------------------------------------------------------------------------------
--Bug#3143522    : Subsidies
--Name    : Copy_Party_Payment_dtls
--Purpose : To copy party payment details linked to a subsidy line
--Copy of aubsidy line vendor payment details
--*******THIS CODE WILL NOT BE CALLED AS Copy of refund details is taken care in OKL
--*******Base COPY API (OKL_COPY_CONTRACT_PUB)
----------------------------------------------------------------------------------------------
PROCEDURE CREATE_PARTY_PYMT_DTLS (p_api_version      in number,
                                  p_init_msg_list    in varchar2,
                                  x_return_status    out nocopy varchar2,
                                  x_msg_count        OUT NOCOPY NUMBER,
                                  x_msg_data         OUT NOCOPY VARCHAR2,
                                  p_from_cle_id      in number,
                                  p_to_cle_id        in number) is

l_return_status        VARCHAR2(1)  default OKL_API.G_RET_STS_SUCCESS;
l_api_name             CONSTANT varchar2(30) := 'CREATE_PARTY_PYMT_DTLS';
l_api_version          CONSTANT NUMBER := 1.0;


--cursor to fetch party payment details on source line
cursor l_ppyd_csr (p_from_cle_id in number) is
select  ppyd.cpl_id
       ,ppyd.vendor_id
       ,ppyd.PAY_SITE_ID
       ,ppyd.PAYMENT_TERM_ID
       ,ppyd.PAYMENT_METHOD_CODE
       ,ppyd.PAY_GROUP_CODE
       ,ppyd.ATTRIBUTE_CATEGORY
       ,ppyd.ATTRIBUTE1
       ,ppyd.ATTRIBUTE2
       ,ppyd.ATTRIBUTE3
       ,ppyd.ATTRIBUTE4
       ,ppyd.ATTRIBUTE5
       ,ppyd.ATTRIBUTE6
       ,ppyd.ATTRIBUTE7
       ,ppyd.ATTRIBUTE8
       ,ppyd.ATTRIBUTE9
       ,ppyd.ATTRIBUTE10
       ,ppyd.ATTRIBUTE11
       ,ppyd.ATTRIBUTE12
       ,ppyd.ATTRIBUTE13
       ,ppyd.ATTRIBUTE14
       ,ppyd.ATTRIBUTE15
       ,cleb_sub.id subsidy_cle_id
from   okl_party_payment_dtls ppyd,
       okc_k_party_roles_b    cplb,
       okc_k_lines_b          cleb_sub
where  ppyd.cpl_id        = cplb.id
and    cplb.cle_id        = cleb_sub.id
and    cleb_sub.cle_id    = p_from_cle_id
and    cleb_sub.sts_code  <> 'ABANDONED';

l_ppyd_rec l_ppyd_csr%rowtype;

--cursor to get party role record from new line
cursor l_cplb_csr (p_to_cle_id     in number,
                   p_parent_cle_id in number)is
select cplb.id
from   okc_k_party_roles_b    cplb,
       okc_k_lines_b          cleb_sub
where  cplb.cle_id               = cleb_sub.id
and    cleb_sub.cle_id           = p_to_cle_id
and    cleb_sub.orig_system_id1  = p_parent_cle_id
and    cleb_sub.dnz_chr_id       = cleb_sub.dnz_chr_id
and    cleb_sub.sts_code   <> 'ABANDONED';

l_new_cpl_id number;
l_ppydv_rec    okl_pyd_pvt.ppydv_rec_type;
x_ppydv_rec    okl_pyd_pvt.ppydv_rec_type;

begin

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


     open l_ppyd_csr(p_from_cle_id => p_from_cle_id);
     Loop
         Fetch l_ppyd_csr into l_ppyd_rec;
         Exit when l_ppyd_csr%NOTFOUND;
         open l_cplb_csr(p_to_cle_id => p_to_cle_id,
                         p_parent_cle_id => l_ppyd_rec.subsidy_cle_id);
         Fetch l_cplb_csr into  l_new_cpl_id;
         If l_cplb_csr%NOTFOUND then
             null;
         Else
             l_ppydv_rec.cpl_id               := l_new_cpl_id;
             l_ppydv_rec.vendor_id            := l_ppyd_rec.vendor_id;
             l_ppydv_rec.pay_site_id          := l_ppyd_rec.pay_site_id;
             l_ppydv_rec.PAYMENT_TERM_ID      := l_ppyd_rec.PAYMENT_TERM_ID;
             l_ppydv_rec.PAYMENT_METHOD_CODE  := l_ppyd_rec.PAYMENT_METHOD_CODE;
             l_ppydv_rec.PAY_GROUP_CODE       := l_ppyd_rec.PAY_GROUP_CODE;
             l_ppydv_rec.ATTRIBUTE_CATEGORY   := l_ppyd_rec.ATTRIBUTE_CATEGORY;
             l_ppydv_rec.ATTRIBUTE1           := l_ppyd_rec.ATTRIBUTE1;
             l_ppydv_rec.ATTRIBUTE2           := l_ppyd_rec.ATTRIBUTE2;
             l_ppydv_rec.ATTRIBUTE3           := l_ppyd_rec.ATTRIBUTE3;
             l_ppydv_rec.ATTRIBUTE4           := l_ppyd_rec.ATTRIBUTE4;
             l_ppydv_rec.ATTRIBUTE5           := l_ppyd_rec.ATTRIBUTE5;
             l_ppydv_rec.ATTRIBUTE6           := l_ppyd_rec.ATTRIBUTE6;
             l_ppydv_rec.ATTRIBUTE7           := l_ppyd_rec.ATTRIBUTE7;
             l_ppydv_rec.ATTRIBUTE8           := l_ppyd_rec.ATTRIBUTE8;
             l_ppydv_rec.ATTRIBUTE9           := l_ppyd_rec.ATTRIBUTE9;
             l_ppydv_rec.ATTRIBUTE10          := l_ppyd_rec.ATTRIBUTE10;
             l_ppydv_rec.ATTRIBUTE11          := l_ppyd_rec.ATTRIBUTE11;
             l_ppydv_rec.ATTRIBUTE12          := l_ppyd_rec.ATTRIBUTE12;
             l_ppydv_rec.ATTRIBUTE13          := l_ppyd_rec.ATTRIBUTE13;
             l_ppydv_rec.ATTRIBUTE14          := l_ppyd_rec.ATTRIBUTE14;
             l_ppydv_rec.ATTRIBUTE15          := l_ppyd_rec.ATTRIBUTE15;

             -------------------------------------------------------
             --call API to create record
             -------------------------------------------------------
             OKL_PYD_PVT.Insert_Row
                  (p_api_version    => p_api_version,
                   p_init_msg_list  => p_init_msg_list,
                   x_return_status  => x_return_status,
                   x_msg_count      => x_msg_count,
                   x_msg_data       => x_msg_data,
                   p_ppydv_rec      => l_ppydv_rec,
                   x_ppydv_rec      => x_ppydv_rec);

             IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
             ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
             END IF;
        End If;
        close l_cplb_csr;
    End Loop;
    close l_ppyd_csr;
    OKL_API.END_ACTIVITY (x_msg_count,x_msg_data );
    EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    If l_cplb_csr%ISOPEN then
        close l_cplb_csr;
    End If;
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                               l_api_name,
                               G_PKG_NAME,
                               'OKL_API.G_RET_STS_ERROR',
                               x_msg_count,
                               x_msg_data,
                               '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    If l_cplb_csr%ISOPEN then
        close l_cplb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OKL_API.G_RET_STS_UNEXP_ERROR',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
    WHEN OTHERS THEN
    If l_ppyd_csr%ISOPEN then
        close l_ppyd_csr;
    End If;
    If l_cplb_csr%ISOPEN then
        close l_cplb_csr;
    End If;
    x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                              l_api_name,
                              G_PKG_NAME,
                              'OTHERS',
                              x_msg_count,
                              x_msg_data,
                              '_PVT');
end create_party_pymt_dtls;
---------------
--Bug# 2994971
---------------
  PROCEDURE populate_insurance_category(p_api_version   IN NUMBER,
                                        p_init_msg_list IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
                                        x_return_status OUT NOCOPY VARCHAR2,
                                        x_msg_count     OUT NOCOPY NUMBER,
                                        x_msg_data      OUT NOCOPY VARCHAR2,
                                        p_cle_id        IN  NUMBER
                                        ) IS

  l_api_name   CONSTANT VARCHAR2(30) := 'POPULATE_INS_CATEGORY';

  --cursor to get inventory item details
  cursor l_cleb_csr (p_cle_id in number) is
  select kle_fin.item_insurance_category,
         cim_model.object1_id1,
         cim_model.object1_id2
  from   okc_k_items cim_model,
         okc_k_lines_b cleb_model,
         okc_line_styles_b lseb_model,
         okl_k_lines   kle_fin
  where  cim_model.cle_id    = cleb_model.id
  and    cleb_model.cle_id   = p_cle_id
  and    lseb_model.id       = cleb_model.lse_id
  and    lseb_model.lty_code = 'ITEM'
  and    kle_fin.id          = p_cle_id;


  l_cleb_rec   l_cleb_csr%ROWTYPE;

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

  l_inv_item_id  number;
  l_inv_org_id   number;


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

    --fetch inv item details
    open l_cleb_csr(p_cle_id => p_cle_id);
    fetch l_cleb_csr into l_cleb_rec;
    if l_cleb_csr%NOTFOUND then
        null;
    end if;
    close l_cleb_csr;

    --------------------------------------------------------------------------
    --if inv item id and org id are found and item_insurance_category is null :
    ---------------------------------------------------------------------------
    if nvl(l_cleb_rec.object1_id1,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR and
       nvl(l_cleb_rec.object1_id2,okl_api.g_miss_char) <> OKL_API.G_MISS_CHAR and
       nvl(l_cleb_rec.item_insurance_category,okl_api.g_miss_num) = OKL_API.G_MISS_NUM then


        l_inv_item_id := to_number(l_cleb_rec.object1_id1);
        l_inv_org_id  := to_number(l_cleb_rec.object1_id2);

        --fetch asset category
        l_asset_category_id := NULL;
        open l_msi_csr (p_inv_item_id => l_inv_item_id,
                        p_inv_org_id  => l_inv_org_id);
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
    End If;

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

-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy of Asset Line -------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_asset_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            P_from_cle_id        IN  NUMBER,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id             OUT NOCOPY NUMBER) IS
    l_api_name      CONSTANT VARCHAR2(30) := 'CREATE_COPY_ASSETS';
    ln_txl_rec               NUMBER := 0;
    ln_iti_rec               NUMBER := 0;
    lv_deal_type             OKL_K_HEADERS_V.DEAL_TYPE%TYPE;
    ln_oec                   OKL_K_LINES_V.OEC%TYPE;
    l_from_fa_kle_id         OKL_K_LINES_V.ID%TYPE;
    l_from_ib_kle_id         OKL_K_LINES_V.ID%TYPE;
    l_from_dnz_chr_id        OKC_K_LINES_V.DNZ_CHR_ID%TYPE;
    ln_cle_id                OKL_K_LINES_V.ID%TYPE;
    l_dummy                  NUMBER := 0;
    l_txdv_tbl               txdv_tbl_type;
    l_talv_rec               talv_rec_type;
    l_itiv_rec               itiv_rec_type;
    lx_asset_trxv_rec        trxv_rec_type;
    lx_instance_trxv_rec     trxv_rec_type;
    lx_txdv_tbl              txdv_tbl_type;
    lx_txlv_rec              talv_rec_type;
    lx_itiv_rec              itiv_rec_type;
    l_txdv_rec               txdv_rec_type;
    lx_txdv_rec              txdv_rec_type;
    l_clev_rec               clev_rec_type;
    l_klev_rec               klev_rec_type;
    lx_clev_rec              clev_rec_type;
    lx_klev_rec              klev_rec_type;
    l_fa_clev_rec            clev_rec_type;
    l_fa_klev_rec            klev_rec_type;
    lx_fa_clev_rec           clev_rec_type;
    lx_fa_klev_rec           klev_rec_type;

    ln_txd_line_number       NUMBER := 0;
    lv_gen_asset_number      OKL_TXL_ASSETS_B.ASSET_NUMBER%TYPE;
    l_fa_object1_id1         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE;
    l_fa_object1_id2         OKC_K_ITEMS_V.OBJECT1_ID2%TYPE;
    l_ib_object1_id1         OKC_K_ITEMS_V.OBJECT1_ID1%TYPE;
    l_ib_object1_id2         OKC_K_ITEMS_V.OBJECT1_ID2%TYPE;
    lt_ib_id_tbl             g_ib_id_tbl;
    lt_new_ib_id_tbl         g_ib_id_tbl;
    lt_ib_item_tbl           g_ib_item_tbl;
    l_cimv_rec               cimv_rec_type;
    lx_cimv_rec              cimv_rec_type;
    i                        NUMBER := 0;
    j                        NUMBER := 0;

    CURSOR l_chr_csr( cleId NUMBER ) IS
    Select khr.id,
           khr.authoring_org_id,
	   khr.currency_code,
	   khr.start_date
    From OKL_K_LINES_FULL_V kle,
         OKL_K_HEADERS_FULL_V KHR
    Where kle.id = cleId
      and KHR.ID = KLE.DNZ_CHR_ID;

    l_chr_rec l_chr_csr%ROWTYPE;
    l_func_curr_code OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;
    l_chr_curr_code  OKL_K_HEADERS_FULL_V.CURRENCY_CODE%TYPE;

    x_contract_currency		okl_k_headers_full_v.currency_code%TYPE;
    x_currency_conversion_type	okl_k_headers_full_v.currency_conversion_type%TYPE;
    x_currency_conversion_rate	okl_k_headers_full_v.currency_conversion_rate%TYPE;
    x_currency_conversion_date	okl_k_headers_full_v.currency_conversion_date%TYPE;

    CURSOR c_check_txl_rec(p_fa_kle_id   OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ASSETS_V
                  WHERE kle_Id = p_fa_kle_id);

    CURSOR c_check_iti_rec(p_ib_kle_id   OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT '1'
                  FROM OKL_TXL_ITM_INSTS_V
                  WHERE kle_id = p_ib_kle_id);

    CURSOR c_asset_info(p_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                        p_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE) IS
    SELECT *
    FROM OKX_ASSETS_V
    WHERE id1 = p_object1_id1
    AND id2  = p_object1_id2;

    CURSOR c_asset_loc_info(p_asset_id OKX_AST_DST_HST_V.ASSET_ID%TYPE) IS
    SELECT  location_id
    FROM OKX_AST_DST_HST_V
    WHERE asset_id = p_asset_id
    AND transaction_header_id_out is null
    AND sysdate between start_date_active and nvl(end_date_active,sysdate+1)
    AND rownum < 2;

    CURSOR c_asset_details_info(p_object1_id1 OKX_AST_BKS_V.ID1%TYPE) IS
    SELECT *
    FROM OKX_AST_BKS_V
    WHERE id1 = p_object1_id1
    AND book_class = 'TAX';

    CURSOR c_ib_info(p_object1_id1 OKC_K_ITEMS_V.OBJECT1_ID1%TYPE,
                     p_object1_id2 OKC_K_ITEMS_V.OBJECT1_ID2%TYPE) IS
    SELECT *
    FROM OKX_INSTALL_ITEMS_V
    WHERE id1 = p_object1_id1
    AND id2  = p_object1_id2;

    CURSOR c_new_fa_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE
                            ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.cle_id = p_cle_id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FA_LINE_LTY_CODE;

    CURSOR c_year_manufactured(p_kle_id OKL_K_LINES_V.ID%TYPE)
    IS
    SELECT kle.Year_Built
    FROM OKL_K_LINES_V kle
    WHERE kle.id = p_kle_id;

    CURSOR c_new_ib_line_id(p_cle_id OKL_K_LINES_V.ID%TYPE
                           ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id,
           cle.dnz_chr_id
    FROM OKC_K_LINES_V cle,
         OKC_LINE_STYLES_V lse
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_IB_LINE_LTY_CODE
    AND cle.cle_id in (SELECT cle.id
                       FROM OKC_K_LINES_V cle,
                            OKC_LINE_STYLES_V lse
                       WHERE cle.cle_id = p_cle_id
                       AND cle.lse_id = lse.id
                       AND lse.lty_code = G_INST_LINE_LTY_CODE
                       AND cle.dnz_chr_id = p_dnz_chr_id);

    CURSOR c_new_model_item_info(p_cle_id OKL_K_LINES_V.ID%TYPE
                                 ,p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT cim.object1_id1,
           cim.object1_id2
    FROM OKC_LINE_STYLES_V lse,
         OKC_K_ITEMS_V cim,
         OKC_K_LINES_V cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.cle_id = p_cle_id
    AND cle.id = cim.cle_id
    AND cle.dnz_chr_id = cim.dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_MODEL_LINE_LTY_CODE;

    CURSOR c_get_iti_object_id1(p_party_site_id HZ_PARTY_SITE_USES.PARTY_SITE_ID%TYPE)
    IS
    SELECT psu.party_site_use_id
    FROM HZ_PARTY_SITE_USES psu,
         HZ_PARTY_SITES ps
    WHERE ps.party_site_id =   psu.party_site_id
    AND psu.site_use_type = 'INSTALL_AT'
    AND psu.party_site_id = p_party_site_id;

    --Bug# 3569441 : Get install location type code
    CURSOR l_loc_type_csr(p_instance_id in number) is
    SELECT install_location_type_code,
           owner_party_id
    FROM   csi_item_instances
    WHERE  instance_id = p_instance_id;

    l_loc_type_rec l_loc_type_csr%ROWTYPE;

    CURSOR l_site_use_csr (p_location_id in number) is
    SELECT psu.party_site_use_id
    FROM   hz_party_site_uses psu,
           hz_party_sites     ps
    WHERE  psu.party_site_id     = ps.party_site_id
    AND    psu.site_use_type     = 'INSTALL_AT'
    AND    ps.location_id        = p_location_id;

    l_site_use_rec    l_site_use_csr%ROWTYPE;

    --Cursor to get address for error
    Cursor l_address_csr (pty_site_id in number ) is
    select substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null, null,null,null,null,null,null,'n','n',80,1,1),1,80)
    from hz_locations hl,
         hz_party_sites ps
    where hl.location_id = ps.location_id
    and   ps.party_site_id = pty_site_id;

    Cursor l_address_csr2 (loc_id in number) is
    select substr(arp_addr_label_pkg.format_address(null,hl.address1,hl.address2,hl.address3, hl.address4,hl.city,hl.county,hl.state,hl.province,hl.postal_code,null,hl.country,null, null,null,null,null,null,null,'n','n',80,1,1),1,80)
    from hz_locations hl
    where hl.location_id = loc_id;

    l_address varchar2(80);
    --End BUG# 3569441


    CURSOR c_get_deal_type(p_top_line_id OKL_K_LINES_V.ID%TYPE,
                           p_dnz_chr_id OKC_K_LINES_V.DNZ_CHR_ID%TYPE)
    IS
    SELECT khrv.deal_type,
           klev.oec
    FROM okl_k_headers_v khrv,
         okc_subclass_top_line stl,
         okc_line_styles_b lse,
         okc_k_lines_v cle,
         okl_k_lines_v klev
    WHERE cle.cle_id is null
    AND cle.id = klev.id
    AND cle.chr_id = cle.dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lty_code = G_FIN_LINE_LTY_CODE
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.id = stl.lse_Id
    AND stl.scs_code in (G_LEASE_SCS_CODE,G_LOAN_SCS_CODE)
    AND cle.dnz_chr_id = khrv.id
    AND cle.dnz_chr_id = p_dnz_chr_id
    AND cle.id = p_top_line_id;

    r_asset_info          c_asset_info%ROWTYPE;
    r_asset_details_info  c_asset_details_info%ROWTYPE;
    r_ib_info             c_ib_info%ROWTYPE;

    Cursor deal_type_stscode_csr(p_chr_id IN NUMBER) is
    Select deal_type, sts_code
    From   okl_k_headers_full_v
    Where  id = p_chr_id;

    l_deal_type  okl_k_headers_full_v.deal_type%type;
    lv_sts_code  okl_k_headers_full_v.deal_type%type;

    --Bug# 2981308
    --cursor to fetch asset key ccid
    cursor l_fab_csr(p_asset_id in number) is
    select asset_key_ccid
    from   fa_additions_b
    where  asset_id = p_asset_id;

   --Bug# 3621663 : Flat rate support
    cursor l_life_in_months_csr (p_deprn_method in varchar2,
                                 p_life_in_months in number) is
    select 'Y'
    from   fa_methods
    where  method_code = p_deprn_method
    and    life_in_months = p_life_in_months
    and    life_in_months is not null;

    l_life_in_months_exists varchar2(1);

    cursor l_rate_csr (p_deprn_method in varchar2,
                       p_rate         in number) is
    select 'Y'
    from   fa_flat_rates ffr,
           fa_methods    fm
    where  fm.method_code     = p_deprn_method
    and    ffr.method_id      = fm.method_id
    and    ffr.adjusted_rate  = p_rate
    and    ffr.adjusting_rate  = 0;

    l_rate_exists varchar2(1);
    --Bug# 3621663

   --Bug# 3877032
    l_fin_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    l_fin_klev_rec    okl_contract_pub.klev_rec_type;
    lx_fin_clev_rec   okl_okc_migration_pvt.clev_rec_type;
    lx_fin_klev_rec   okl_contract_pub.klev_rec_type;

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
    -- Validating the chr_id and cle_id
    validate_from_cle_id(p_cle_id        => p_from_cle_id,
                         x_fa_line_id    => l_from_fa_kle_id,
                         x_ib_id_tbl     => lt_ib_id_tbl,
                         x_dnz_chr_id    => l_from_dnz_chr_id,
                         x_return_status => x_return_status);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- since avery validation is passed
    -- First to copy a contract line then get the cle id
    OKL_COPY_CONTRACT_PUB.COPY_CONTRACT_LINES(
                          p_api_version        => p_api_version,
                          p_init_msg_list      => p_init_msg_list,
                          x_return_status      => x_return_status,
                          x_msg_count          => x_msg_count,
                          x_msg_data           => x_msg_data,
                          p_from_cle_id        => p_from_cle_id,
                          p_to_cle_id          => p_to_cle_id,
                          p_to_chr_id          => p_to_chr_id,
                          p_to_template_yn     => p_to_template_yn,
                          p_copy_reference     => p_copy_reference,
                          p_copy_line_party_yn => p_copy_line_party_yn,
                          p_renew_ref_yn       => p_renew_ref_yn,
                          x_cle_id             => x_cle_id);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_COPY_LINE);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_COPY_LINE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    ln_cle_id := x_cle_id;
    -- We need to update the asset number
    -- Fixed asset item info
    x_return_status := validate_items_ids(p_cle_id      => l_from_fa_kle_id,
                                          p_dnz_chr_id  => l_from_dnz_chr_id,
                                          x_object1_id1 => l_fa_object1_id1,
                                          x_object1_id2 => l_fa_object1_id2);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITEM_RECORD);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITEM_RECORD);
     -- TO put error message
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Install Base Item info
    IF lt_ib_id_tbl.COUNT > 0 THEN
       i := lt_ib_id_tbl.FIRST;
       LOOP
         x_return_status := validate_items_ids(p_cle_id      => lt_ib_id_tbl(i).id,
                                               p_dnz_chr_id  => l_from_dnz_chr_id,
                                               x_object1_id1 => lt_ib_item_tbl(i).object1_id1,
                                               x_object1_id2 => lt_ib_item_tbl(i).object1_id2);
         IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
         ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i = lt_ib_id_tbl.LAST);
         i := lt_ib_id_tbl.NEXT(i);
       END LOOP;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITEM_RECORD);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITEM_RECORD);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF (l_fa_object1_id1 IS NULL OR
       l_fa_object1_id1 = OKL_API.G_MISS_CHAR) AND
       (l_fa_object1_id2 IS NULL OR
       l_fa_object1_id2 = OKL_API.G_MISS_CHAR) THEN

      --check if it is a 'LOAN' contract
      Open deal_type_stscode_csr(p_chr_id => l_from_dnz_chr_id);
      Fetch deal_type_stscode_csr into l_deal_type, lv_sts_code;
      Close deal_type_stscode_csr;

      IF (l_deal_type in ('LOAN','LOAN-REVOLVING') AND lv_sts_code = 'BOOKED') THEN
        Create_Asset_trx_txl_For_Loan(p_api_version    => p_api_version,
                                      p_init_msg_list    => p_init_msg_list,
                                      x_return_status    => x_return_status,
                                      x_msg_count        => x_msg_count,
                                      x_msg_data         => x_msg_data,
                                      p_cle_id           => l_from_fa_kle_id,
                                      p_fin_cle_id       => ln_cle_id,
                                      p_from_dnz_chr_id  => l_from_dnz_chr_id,
                                      p_to_dnz_chr_id    => p_to_chr_id,
                                      p_trans_type       => p_trans_type,
                                      x_trxv_rec         => lx_asset_trxv_rec,
                                      x_talv_rec         => lx_txlv_rec,
                                      x_txdv_tbl         => lx_txdv_tbl);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        lv_gen_asset_number := lx_txlv_rec.asset_number;
      ELSE
        -- Check to see if the txl info is there or not
        OPEN  c_check_txl_rec(l_from_fa_kle_id);
        IF c_check_txl_rec%NOTFOUND THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_NO_MATCHING_RECORD,
                              p_token1       => G_COL_NAME_TOKEN,
                              p_token1_value => 'OKL_TXL_ASSETS_V.KLE_ID');
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
        FETCH c_check_txl_rec INTO ln_txl_rec;
        CLOSE c_check_txl_rec;

        IF ln_txl_rec = 1 THEN
           -- Copy the Asset Info
           Create_Asset_trx_txl_txd(p_api_version   => p_api_version,
                                    p_init_msg_list => p_init_msg_list,
                                    x_return_status => x_return_status,
                                    x_msg_count     => x_msg_count,
                                    x_msg_data      => x_msg_data,
                                    p_cle_id        => l_from_fa_kle_id,
                                    p_fin_cle_id    => x_cle_id,
                                    p_dnz_chr_id    => p_to_chr_id,
                                    p_trans_type    => p_trans_type,
                                    x_trxv_rec      => lx_asset_trxv_rec,
                                    x_talv_rec      => lx_txlv_rec,
                                    x_txdv_tbl      => lx_txdv_tbl);
           IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
           ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
             RAISE OKL_API.G_EXCEPTION_ERROR;
           END IF;
           lv_gen_asset_number := lx_txlv_rec.asset_number;
        ELSE
          RAISE OKL_API.G_EXCEPTION_ERROR;
        END IF;
      END IF;
      -- Calling the api to copy the Supplier Invoice Details info
      create_supp_invoice_dtls(p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_cle_id        => p_from_cle_id,
                               p_fin_cle_id    => x_cle_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => ' Error in copy Supplier Invoice Details');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => ' Error in copy Supplier Invoice Details');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSIF (l_fa_object1_id1 IS NOT NULL OR
          l_fa_object1_id1 <> OKL_API.G_MISS_CHAR) AND
          (l_fa_object1_id2 IS NOT NULL OR
      l_fa_object1_id2 <> OKL_API.G_MISS_CHAR) THEN
      -- Now we have to create txl assets info for existing FA asset
      OPEN  c_asset_info(p_object1_id1 => l_fa_object1_id1,
                         p_object1_id2 => l_fa_object1_id2);
      FETCH c_asset_info into r_asset_info;
      CLOSE c_asset_info;
      OPEN  c_asset_loc_info(p_asset_id => l_fa_object1_id1);
      FETCH c_asset_loc_info into l_talv_rec.fa_location_id;
      CLOSE c_asset_loc_info;
      --we have to populate the txl with the existing asset info
      OPEN  c_new_fa_line_id(p_cle_id     => x_cle_id,
                             p_dnz_chr_id => p_to_chr_id);
      IF c_new_fa_line_id%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'New Fa Line Id');
        -- TO put error message
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      FETCH c_new_fa_line_id into l_talv_rec.kle_id;
      CLOSE c_new_fa_line_id;

      OPEN c_year_manufactured(p_kle_id =>l_talv_rec.kle_id);
      IF c_year_manufactured%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'New kle Fa Line Id');
        -- TO put error message
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      FETCH c_year_manufactured into l_talv_rec.year_manufactured;
      CLOSE c_year_manufactured;
      l_talv_rec.dnz_khr_id            := p_to_chr_id;
      ----------------------------------------------------------------------
      --Bug# 3562847 : Removed org_id assignment below
      --               verified l_talv_rec.org_id not being used anywhere in
      --               processing of l_talv_rec transaction record
      ---------------------------------------------------------------------
      --l_talv_rec.org_id                := r_asset_info.org_id;
      l_talv_rec.asset_number          := r_asset_info.asset_number;
      l_talv_rec.description           := r_asset_info.description;

      OPEN  c_get_deal_type(p_top_line_id => x_cle_id,
                            p_dnz_chr_id  => p_to_chr_id);
      IF c_get_deal_type%NOTFOUND THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1       => G_COL_NAME_TOKEN,
                            p_token1_value => 'New Top line Id');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      FETCH c_get_deal_type INTO lv_deal_type,
                                 ln_oec;
      CLOSE c_get_deal_type;
      --bug# 2769267 : contract is active cost should be taken from fa
      --l_talv_rec.original_cost         := ln_oec;
      --l_talv_rec.depreciation_cost     := ln_oec;
      --open cursor to get currency parameters from contract header
      OPEN  l_chr_csr( p_from_cle_id );
      FETCH l_chr_csr INTO l_chr_rec;
      CLOSE l_chr_csr;
      --get the functional currency code
      l_chr_curr_code  := l_chr_rec.CURRENCY_CODE;
      l_func_curr_code := OKL_ACCOUNTING_UTIL.get_func_curr_code;
      If  (l_chr_curr_code <> l_func_curr_code) Then
          l_talv_rec.original_cost := NULL;
          okl_accounting_util.convert_to_contract_currency(
                          p_khr_id                    => l_chr_rec.id,
                          p_from_currency             => l_func_curr_code,
                          p_transaction_date          => l_chr_rec.start_date,
                          p_amount 	              => r_asset_info.cost,
                          x_contract_currency	      => x_contract_currency,
                          x_currency_conversion_type  => x_currency_conversion_type,
                          x_currency_conversion_rate  => x_currency_conversion_rate,
                          x_currency_conversion_date  => x_currency_conversion_date,
                          x_converted_amount          => l_talv_rec.original_cost);
          IF (r_asset_info.cost >= 0) and (l_talv_rec.original_cost < 0) then
                --currency conversion rate was not found in Oracle GL
                OKC_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_CONV_RATE_NOT_FOUND,
                               p_token1       => G_FROM_CURRENCY_TOKEN,
                               p_token1_value => x_contract_currency,
                               p_token2       => G_TO_CURRENCY_TOKEN,
                               p_token2_value => l_func_curr_code,
                               p_token3       => G_CONV_TYPE_TOKEN,
                               p_token3_value => x_currency_conversion_type,
                               p_token4       => G_CONV_DATE_TOKEN,
                               p_token4_value => to_char(x_currency_conversion_date,'DD-MON-YYYY'));
                RAISE OKL_API.G_EXCEPTION_ERROR;
          End If;
          l_talv_rec.depreciation_cost := l_talv_rec.original_cost;
      Else--currencies are same
          l_talv_rec.original_cost         := r_asset_info.cost;
          l_talv_rec.depreciation_cost     := r_asset_info.cost;
      End If;
      --bug# 2769267
      l_talv_rec.current_units         := r_asset_info.current_units;
      l_talv_rec.manufacturer_name     := r_asset_info.manufacturer_name;
      IF upper(r_asset_info.new_used) = 'NEW' THEN
         l_talv_rec.used_asset_yn         := null;
      ELSIF (r_asset_info.new_used IS NULL OR
            r_asset_info.new_used = OKL_API.G_MISS_CHAR) THEN
         l_talv_rec.used_asset_yn         := null;
      ELSE
         l_talv_rec.used_asset_yn         := 'Y';
      END IF;
      l_talv_rec.tag_number            := r_asset_info.tag_number;
      l_talv_rec.model_number          := r_asset_info.model_number;

      l_talv_rec.corporate_book        := r_asset_info.corporate_book;
      l_talv_rec.in_service_date       := r_asset_info.in_service_date;
      l_talv_rec.life_in_months        := r_asset_info.life_in_months;
      l_talv_rec.depreciation_id       := r_asset_info.depreciation_category;
      l_talv_rec.deprn_method          := r_asset_info.deprn_method_code;
      l_talv_rec.deprn_rate            := r_asset_info.adjusted_rate;

     --Bug# 3621663 : Flat rate method support
      l_life_in_months_exists := 'N';
      Open l_life_in_months_csr(p_deprn_method   => r_asset_info.deprn_method_code,
                                p_life_in_months => r_asset_info.life_in_months);
      Fetch l_life_in_months_csr into l_life_in_months_exists;
      If l_life_in_months_csr%NOTFOUND then
          null;
      End If;
      Close l_life_in_months_csr;

      If l_life_in_months_exists = 'Y' then
          l_talv_rec.life_in_months := r_asset_info.life_in_months;
          l_talv_rec.deprn_rate     := null;
      ElsIf l_life_in_months_exists = 'N' then
          l_rate_exists := 'N';
          Open l_rate_csr (p_deprn_method => r_asset_info.deprn_method_code,
                           p_rate         => r_asset_info.adjusted_rate);
          Fetch l_rate_csr into l_rate_exists;
          If l_rate_csr%NOTFOUND then
             Null;
          End If;
          Close l_rate_csr;
          If l_rate_exists = 'Y' then
              --Bug# 3657624 : Depreciation Rate should not be multiplied by 100
              --l_talv_rec.deprn_rate     := r_asset_info.adjusted_rate*100;
              l_talv_rec.deprn_rate     := r_asset_info.adjusted_rate;
              l_talv_rec.life_in_months := Null;
          End If;
      End If;
      --Bug# 3621663 : End

      --Bug# 2769267
      --ssiruvol currency conversion while copying from FA onto contract lines.
      --OPEN  l_chr_csr( p_from_cle_id );
      --FETCH l_chr_csr INTO l_chr_rec;
      --CLOSE l_chr_csr;

      --l_chr_curr_code  := l_chr_rec.CURRENCY_CODE;
      --l_func_curr_code := OKC_CURRENCY_API.GET_OU_CURRENCY(l_chr_rec.authoring_org_id);

      -- Bug# 3950089
      -- Populate either Salvage percent or Salvage value in okl_txl_assets_b
      IF (r_asset_info.percent_salvage_value IS NULL) THEN

        IF ( l_chr_curr_code <> l_func_curr_code ) Then
          l_talv_rec.salvage_value := NULL;
          okl_accounting_util.convert_to_contract_currency(
                          p_khr_id                    => l_chr_rec.id,
                          p_from_currency             => l_func_curr_code,
                          p_transaction_date          => l_chr_rec.start_date,
                          p_amount 	              => r_asset_info.salvage_value,
                          x_contract_currency	      => x_contract_currency,
                          x_currency_conversion_type  => x_currency_conversion_type,
                          x_currency_conversion_rate  => x_currency_conversion_rate,
                          x_currency_conversion_date  => x_currency_conversion_date,
                          x_converted_amount          => l_talv_rec.salvage_value);
          IF (r_asset_info.salvage_value >= 0) and (l_talv_rec.salvage_value < 0) then
                --currency conversion rate was not found in Oracle GL
                OKC_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_CONV_RATE_NOT_FOUND,
                               p_token1       => G_FROM_CURRENCY_TOKEN,
                               p_token1_value => x_contract_currency,
                               p_token2       => G_TO_CURRENCY_TOKEN,
                               p_token2_value => l_func_curr_code,
                               p_token3       => G_CONV_TYPE_TOKEN,
                               p_token3_value => x_currency_conversion_type,
                               p_token4       => G_CONV_DATE_TOKEN,
                               p_token4_value => to_char(x_currency_conversion_date,'DD-MON-YYYY'));
                RAISE OKL_API.G_EXCEPTION_ERROR;
          End If;
        Else
          l_talv_rec.salvage_value := r_asset_info.salvage_value;
        End If;

      ELSE
        --Bug# 3950089
        l_talv_rec.percent_salvage_value := r_asset_info.percent_salvage_value * 100;
      END IF;

      --Bug# 2981308 : fetch asset asset key ccid from FA and assign
      open l_fab_csr (p_asset_id => r_asset_info.asset_id);
      fetch l_fab_csr into l_talv_rec.asset_key_id;
      if l_fab_csr%NOTFOUND then
          Null;
      end if;
      close l_fab_csr;
      --End Bug# 2981308

      -- Now we are going to the txl info with the fixed asset info for the asset number
      Create_asset_lines(p_api_version   => p_api_version,
                         p_init_msg_list => p_init_msg_list,
                         x_return_status => x_return_status,
                         x_msg_count     => x_msg_count,
                         x_msg_data      => x_msg_data,
                         p_talv_rec      => l_talv_rec,
                         p_trans_type    => p_trans_type,
                         x_trxv_rec      => lx_asset_trxv_rec,
                         x_talv_rec      => lx_txlv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      lv_gen_asset_number := lx_txlv_rec.asset_number;

      -- We have to create Txd info if the Asset has tax book info we need to load the txd also
      -- Since We will have more than one row we need to load the values thru loop
      FOR r_asset_details_info IN c_asset_details_info(p_object1_id1 => l_fa_object1_id1) LOOP
        -- Loading the txd info
        l_txdv_rec.tal_id                := lx_txlv_rec.id;
        l_txdv_rec.line_detail_number    := ln_txd_line_number;
--          l_txdv_rec.asset_number          := r_asset_details_info.asset_number;
        l_txdv_rec.asset_number          := lv_gen_asset_number;
        l_txdv_rec.description           := r_asset_details_info.description;
        l_txdv_rec.quantity              := r_asset_details_info.current_units;
        --Bug# 2769267 : commented the code below
        /*
        --IF r_asset_details_info.cost = 0 THEN
          -- Based on the deal type we need populate the original_cost as price_unit of line
          -- which is oec/current_units for the line
         -- OPEN  c_get_deal_type(p_top_line_id => x_cle_id,
--                                p_dnz_chr_id  => p_to_chr_id);
--          IF c_get_deal_type%NOTFOUND THEN
--            OKL_API.set_message(p_app_name     => G_APP_NAME,
--                                p_msg_name     => G_NO_MATCHING_RECORD,
--                                p_token1       => G_COL_NAME_TOKEN,
--                                p_token1_value => 'New Top line Id');
--            RAISE OKL_API.G_EXCEPTION_ERROR;
--          END IF;
--          FETCH c_get_deal_type INTO lv_deal_type,
--                                     ln_oec;
--          CLOSE c_get_deal_type;
--          IF  lv_deal_type in ('LEASEDF','LEASEST') THEN
--            l_txdv_rec.cost     := ln_oec;
--          ELSE
--            l_txdv_rec.cost     := r_asset_details_info.cost;
--          END IF;
--        ELSE
--          l_txdv_rec.cost     := r_asset_details_info.cost;
--        END IF;
--        */
        --Bug# 2769267 : active contracts costs should be taken from FA and converted if required
        If  (l_chr_curr_code <> l_func_curr_code) Then
            l_txdv_rec.cost := NULL;
            okl_accounting_util.convert_to_contract_currency(
                          p_khr_id                    => l_chr_rec.id,
                          p_from_currency             => l_func_curr_code,
                          p_transaction_date          => l_chr_rec.start_date,
                          p_amount 	              => r_asset_details_info.cost,
                          x_contract_currency	      => x_contract_currency,
                          x_currency_conversion_type  => x_currency_conversion_type,
                          x_currency_conversion_rate  => x_currency_conversion_rate,
                          x_currency_conversion_date  => x_currency_conversion_date,
                          x_converted_amount          => l_txdv_rec.cost);
            IF (r_asset_details_info.cost >= 0) and (l_txdv_rec.cost < 0) then
                --currency conversion rate was not found in Oracle GL
                OKC_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_CONV_RATE_NOT_FOUND,
                               p_token1       => G_FROM_CURRENCY_TOKEN,
                               p_token1_value => x_contract_currency,
                               p_token2       => G_TO_CURRENCY_TOKEN,
                               p_token2_value => l_func_curr_code,
                               p_token3       => G_CONV_TYPE_TOKEN,
                               p_token3_value => x_currency_conversion_type,
                               p_token4       => G_CONV_DATE_TOKEN,
                               p_token4_value => to_char(x_currency_conversion_date,'DD-MON-YYYY'));
                RAISE OKL_API.G_EXCEPTION_ERROR;
            End If;
        Else
            l_txdv_rec.cost         := r_asset_details_info.cost;
        End If;
        --Bug# 2769627 End
        l_txdv_rec.tax_book              := r_asset_details_info.book_type_code;
        l_txdv_rec.life_in_months_tax    := r_asset_details_info.life_in_months;
        l_txdv_rec.deprn_method_tax      := r_asset_details_info.deprn_method_code;
        l_txdv_rec.deprn_rate_tax        := r_asset_details_info.adjusted_rate;
        l_txdv_rec.salvage_value         := r_asset_details_info.salvage_value;

        --Bug# 3621663 : Flat rate method support
        l_life_in_months_exists := 'N';
        Open l_life_in_months_csr(p_deprn_method   => r_asset_details_info.deprn_method_code,
                                  p_life_in_months => r_asset_details_info.life_in_months);
        Fetch l_life_in_months_csr into l_life_in_months_exists;
        If l_life_in_months_csr%NOTFOUND then
            null;
        End If;
        Close l_life_in_months_csr;

        If l_life_in_months_exists = 'Y' then
            l_txdv_rec.life_in_months_tax := r_asset_details_info.life_in_months;
            l_txdv_rec.deprn_rate_tax     := null;
        ElsIf l_life_in_months_exists = 'N' then
            l_rate_exists := 'N';
            Open l_rate_csr (p_deprn_method => r_asset_details_info.deprn_method_code,
                             p_rate         => r_asset_details_info.adjusted_rate);
            Fetch l_rate_csr into l_rate_exists;
            If l_rate_csr%NOTFOUND then
               Null;
            End If;
            Close l_rate_csr;
            If l_rate_exists = 'Y' then
                --Bug# 3657624 : Depreciation Rate should not be multiplied by 100
                --l_txdv_rec.deprn_rate_tax   := r_asset_details_info.adjusted_rate*100;
                l_txdv_rec.deprn_rate_tax   := r_asset_details_info.adjusted_rate;
                l_txdv_rec.life_in_months_tax := Null;
            End If;
        End If;
        --Bug# 3621663 : End
        -- We are going to Create teh Asset Details info
        Create_asset_line_details(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_txdv_rec      => l_txdv_rec,
                                  x_txdv_rec      => lx_txdv_rec);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        ln_txd_line_number := ln_txd_line_number + 1;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- we have to null out the object1_id1 and object1_id2 in okc_k_items
      -- since the copy lines are for a new contract
      x_return_status := get_rec_cimv(lx_txlv_rec.kle_id,
                                      p_to_chr_id,
                                      l_cimv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'OKC_K_ITEMS_V record');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => G_NO_MATCHING_RECORD,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'OKC_K_ITEMS_V record');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_cimv_rec.cle_id <> lx_txlv_rec.kle_id THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_MATCHING_RECORD,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'OKC_K_ITEMS_V.CLE_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      IF l_cimv_rec.dnz_chr_id <> p_to_chr_id THEN
        OKL_API.set_message(p_app_name => G_APP_NAME,
                            p_msg_name => G_NO_MATCHING_RECORD,
                            p_token1        => G_COL_NAME_TOKEN,
                            p_token1_value  => 'OKC_K_ITEMS_V.DNZ_CHR_ID');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      l_cimv_rec.object1_id1     := null;
      l_cimv_rec.object1_id2     := null;
      -- Updating of Item Record for the above record information
      OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_cimv_rec      => l_cimv_rec,
                                                 x_cimv_rec      => lx_cimv_rec);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
      -- Calling the api to copy the Supplier Invoice Details info
      create_supp_invoice_dtls(p_api_version   => p_api_version,
                               p_init_msg_list => p_init_msg_list,
                               x_return_status => x_return_status,
                               x_msg_count     => x_msg_count,
                               x_msg_data      => x_msg_data,
                               p_cle_id        => p_from_cle_id,
                               p_fin_cle_id    => x_cle_id);
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => ' Error in copy Supplier Invoice Details');
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.set_message(p_app_name     => G_APP_NAME,
                            p_msg_name     => ' Error in copy Supplier Invoice Details');
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_ITEM_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := get_rec_clev(x_cle_id,
                                    l_clev_rec);
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
    x_return_status := get_rec_klev(x_cle_id,
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
    IF l_klev_rec.id <> l_clev_rec.id THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_LINE_RECORD);
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_clev_rec.name := lv_gen_asset_number;
    OKL_CONTRACT_PUB.update_contract_line(p_api_version   => p_api_version,
                                          p_init_msg_list => p_init_msg_list,
                                          x_return_status => x_return_status,
                                          x_msg_count     => x_msg_count,
                                          x_msg_data      => x_msg_data,
                                          p_clev_rec      => l_clev_rec,
                                          p_klev_rec      => l_klev_rec,
                                          x_clev_rec      => lx_clev_rec,
                                          x_klev_rec      => lx_klev_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UPDATING_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
       OKL_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_UPDATING_FIN_LINE);
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Ib Line creation/copy
    FOR r_new_ib_line_id IN c_new_ib_line_id(p_cle_id     => x_cle_id,
                                             p_dnz_chr_id => p_to_chr_id) LOOP
      IF c_new_ib_line_id%NOTFOUND THEN
        x_return_status := OKL_API.G_RET_STS_ERROR;
        EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
      END IF;
      lt_new_ib_id_tbl(j).id         := r_new_ib_line_id.id;
      lt_new_ib_id_tbl(j).dnz_chr_id := r_new_ib_line_id.dnz_chr_id;
      j := j + 1;
    END LOOP;
    IF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_NO_MATCHING_RECORD,
                          p_token1       => G_COL_NAME_TOKEN,
                          p_token1_value => 'New ib Line Id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    IF lt_new_ib_id_tbl.COUNT <> lt_ib_id_tbl.COUNT THEN
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Install Base Item info
    IF lt_ib_id_tbl.COUNT > 0 THEN
       i := lt_ib_id_tbl.FIRST;
       j := lt_new_ib_id_tbl.FIRST;
       LOOP
         IF (lt_ib_item_tbl(i).object1_id1 IS NULL OR
            lt_ib_item_tbl(i).object1_id1 = OKL_API.G_MISS_CHAR) AND
            (lt_ib_item_tbl(i).object1_id2 IS NULL OR
            lt_ib_item_tbl(i).object1_id2 = OKL_API.G_MISS_CHAR) THEN
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            -- Check to see if the iti info is there or not
            OPEN  c_check_iti_rec(lt_ib_id_tbl(i).id);
            IF c_check_iti_rec%NOTFOUND THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_NO_MATCHING_RECORD,
                                   p_token1       => G_COL_NAME_TOKEN,
                                   p_token1_value => 'OKL_TXL_ITM_INSTS_V.KLE_ID');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            FETCH c_check_iti_rec INTO ln_iti_rec;
            CLOSE c_check_iti_rec;
            IF ln_iti_rec = 1 THEN
              -- Copy the Instance rec
              Create_Asset_header_instance(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_cle_id        => lt_ib_id_tbl(i).id,
                                           p_new_cle_id    => lt_new_ib_id_tbl(j).id,
                                           p_fin_cle_id    => x_cle_id,
                                           p_dnz_chr_id    => p_to_chr_id,
                                           p_trans_type    => p_trans_type,
                                           p_asset_number  => lx_txlv_rec.asset_number,
                                           x_trxv_rec      => lx_instance_trxv_rec,
                                           x_itiv_rec      => lx_itiv_rec);
              IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
              ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
              END IF;
            ELSE
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
         ELSIF (lt_ib_item_tbl(i).object1_id1 IS NOT NULL OR
            lt_ib_item_tbl(i).object1_id1 <> OKL_API.G_MISS_CHAR) AND
            (lt_ib_item_tbl(i).object1_id2 IS NOT NULL OR
            lt_ib_item_tbl(i).object1_id2 <> OKL_API.G_MISS_CHAR) THEN
            -- to get the item info to populate the inventory item id and inventory org id
            -- into the txl itm insts table

            OPEN  c_new_model_item_info(p_cle_id     => x_cle_id,
                                        p_dnz_chr_id => p_to_chr_id);
            IF c_new_model_item_info%NOTFOUND THEN
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            FETCH c_new_model_item_info INTO l_itiv_rec.inventory_item_id,
                                             l_itiv_rec.inventory_org_id;
            CLOSE c_new_model_item_info;

            OPEN  c_ib_info(lt_ib_item_tbl(i).object1_id1,
                            lt_ib_item_tbl(i).object1_id2);
            IF c_ib_info%NOTFOUND THEN
               OKL_API.set_message(p_app_name     => G_APP_NAME,
                                   p_msg_name     => G_NO_MATCHING_RECORD,
                                   p_token1       => G_COL_NAME_TOKEN,
                                   p_token1_value => 'OKX_INSTALL_ITEMS_V.OBJECT1_ID1');
              x_return_status := OKL_API.G_RET_STS_ERROR;
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;
            FETCH c_ib_info INTO r_ib_info;
            CLOSE c_ib_info;
            l_itiv_rec.object_id2_new := G_ID2;
            l_itiv_rec.jtot_object_code_new := 'OKX_PARTSITE';
            l_itiv_rec.instance_number_ib := r_ib_info.name;
            l_itiv_rec.line_number := 1;
            IF lt_ib_id_tbl.COUNT > 0 AND
              r_ib_info.serial_number IS NOT NULL  THEN
              l_itiv_rec.mfg_serial_number_yn := 'Y';
              l_itiv_rec.serial_number := r_ib_info.serial_number;

            ELSE
              l_itiv_rec.mfg_serial_number_yn := 'N';
              l_itiv_rec.serial_number := r_ib_info.serial_number;
            END IF;
            l_itiv_rec.kle_id := lt_new_ib_id_tbl(j).id;
            l_itiv_rec.dnz_cle_id := x_cle_id;

            --Bug# 3569441 :
            OPEN l_loc_type_csr(p_instance_id => r_ib_info.id1);
            Fetch l_loc_type_csr into l_loc_type_rec;
            If l_loc_type_csr%NOTFOUND then
                Null;
            End If;
            CLOSE l_loc_type_csr;

            If nvl(l_loc_type_rec.install_location_type_code,OKL_API.G_MISS_CHAR) not in ('HZ_PARTY_SITES','HZ_LOCATIONS') then

                --Raise Error
                OKL_API.Set_Message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_INVALID_INSTALL_LOC_TYPE,
                              p_token1       => G_LOCATION_TYPE_TOKEN,
                              p_token1_value => l_loc_type_rec.install_location_type_code,
                              p_token2       => G_LOC_TYPE1_TOKEN,
                              p_token2_value => 'HZ_PARTY_SITES',
                              p_token3       => G_LOC_TYPE2_TOKEN,
                              p_token3_value => 'HZ_LOCATIONS');
                x_return_status := OKL_API.G_RET_STS_ERROR;
                RAISE OKL_API.G_EXCEPTION_ERROR;

            Elsif nvl(l_loc_type_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_PARTY_SITES' then

                OPEN  c_get_iti_object_id1(r_ib_info.install_location_id);
                FETCH c_get_iti_object_id1 INTO l_itiv_rec.object_id1_new;
                IF c_get_iti_object_id1%NOTFOUND THEN
                    Open l_address_csr(pty_site_id => r_ib_info.install_location_id);
                    Fetch l_address_csr into l_address;
                    Close l_address_csr;
                    --Raise Error : not defined as install_at
                    OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => r_ib_info.instance_number);
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    RAISE OKL_API.G_EXCEPTION_ERROR;
                END IF;
                CLOSE c_get_iti_object_id1;

            Elsif nvl(l_loc_type_rec.install_location_type_code,OKL_API.G_MISS_CHAR) = 'HZ_LOCATIONS' then

                OPEN  l_site_use_csr(r_ib_info.install_location_id);
                FETCH l_site_use_csr INTO l_site_use_rec;
                IF l_site_use_csr%NOTFOUND THEN
                    open l_address_csr2(loc_id => r_ib_info.install_location_id);
                    fetch l_address_csr2 into l_address;
                    close l_address_csr2;
                    --Raise Error : not defined as install_at
                    OKL_API.Set_Message(p_app_name  => G_APP_NAME,
                              p_msg_name     => G_MISSING_USAGE,
                              p_token1       => G_USAGE_TYPE_TOKEN,
                              p_token1_value => 'INSTALL_AT',
                              p_token2       => G_ADDRESS_TOKEN,
                              p_token2_value => l_address,
                              p_token3       => G_INSTANCE_NUMBER_TOKEN,
                              p_token3_value => r_ib_info.instance_number);
                    x_return_status := OKL_API.G_RET_STS_ERROR;
                    RAISE OKL_API.G_EXCEPTION_ERROR;

                END IF;
                l_itiv_rec.object_id1_new := l_site_use_rec.party_site_use_id;
                CLOSE l_site_use_csr;

            End If;
            --End Bug# 3569441 :

            create_txl_itm_insts(p_api_version    => p_api_version,
                                 p_init_msg_list  => p_init_msg_list,
                                 x_return_status  => x_return_status,
                                 x_msg_count      => x_msg_count,
                                 x_msg_data       => x_msg_data,
                                 p_itiv_rec       => l_itiv_rec,
                                 p_trans_type    =>  p_trans_type,
                                 p_asset_number  =>  lx_txlv_rec.asset_number,
                                 x_trxv_rec       => lx_instance_trxv_rec,
                                 x_itiv_rec       => lx_itiv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
            END IF;

            -- we have to null out the object1_id1 and object1_id2 in okc_k_items
            -- since the copy lines are for a new contract
            x_return_status := get_rec_cimv(lx_itiv_rec.kle_id,
                                            p_to_chr_id,
                                            l_cimv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'OKC_K_ITEMS_V record');
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_NO_MATCHING_RECORD,
                                p_token1       => G_COL_NAME_TOKEN,
                                p_token1_value => 'OKC_K_ITEMS_V record');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            IF l_cimv_rec.cle_id <> lx_itiv_rec.kle_id THEN
              OKL_API.set_message(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_NO_MATCHING_RECORD,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'KLE_ID');
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
            l_cimv_rec.object1_id1     := null;
            l_cimv_rec.object1_id2     := null;
            -- Updating of Item Record for the above record information
            OKL_OKC_MIGRATION_PVT.update_contract_item(p_api_version   => p_api_version,
                                                       p_init_msg_list => p_init_msg_list,
                                                       x_return_status => x_return_status,
                                                       x_msg_count     => x_msg_count,
                                                       x_msg_data      => x_msg_data,
                                                       p_cimv_rec      => l_cimv_rec,
                                                       x_cimv_rec      => lx_cimv_rec);
            IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
            ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
              RAISE OKL_API.G_EXCEPTION_ERROR;
            END IF;
         ELSE
           OKL_API.set_message(p_app_name     => G_APP_NAME,
                               p_msg_name     => G_ITEM_RECORD);
           x_return_status := OKL_API.G_RET_STS_ERROR;
           EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
         END IF;
         EXIT WHEN (i = lt_ib_id_tbl.LAST);
         i := lt_ib_id_tbl.NEXT(i);
         j := lt_new_ib_id_tbl.NEXT(j);
       END LOOP;
       IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
       ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
    ELSE
      OKL_API.set_message(p_app_name     => G_APP_NAME,
                          p_msg_name     => G_LINE_RECORD);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    /*-----------------------------------------------------------
    --This code commented as Copy refund details has been moved
    --to OKL base COPY API (OKL_COPY_CONTRACT_PUB)
    --This code put into copy contract
    --Bug # 3143522: Subsidies - copy subsidy line payment details
    --CREATE_PARTY_PYMT_DTLS (p_api_version      => p_api_version,
                            --p_init_msg_list    => p_init_msg_list,
                            --x_return_status    => x_return_status,
                            --x_msg_count        => x_msg_count,
                            --x_msg_data         => x_msg_data,
                            --p_from_cle_id      => p_from_cle_id,
                            --p_to_cle_id        => x_cle_id);

     --IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     --ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        --RAISE OKL_API.G_EXCEPTION_ERROR;
     --END IF;
    --End Bug# : Subsidies enhancement
    --This code put into copy contract
    -------------------------------------------------------------*/

    --------------
    --bug# 2994971
    --------------
    populate_insurance_category(p_api_version   => p_api_version,
                                p_init_msg_list => p_init_msg_list,
                                x_return_status => x_return_status,
                                x_msg_count     => x_msg_count,
                                x_msg_data      => x_msg_data,
                                p_cle_id        => x_cle_id
                               );

     IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
     ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
     END IF;
    --------------
    --bug# 2994971
    --------------

    --bug# 3877032
    ---------------------------
    --recalculate capital amount
    ---------------------------
    OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                  p_init_msg_list => p_init_msg_list,
                                  x_return_status => x_return_status,
                                  x_msg_count     => x_msg_count,
                                  x_msg_data      => x_msg_data,
                                  p_formula_name  => 'LINE_CAP_AMNT',
                                  p_contract_id   => p_to_chr_id,
                                  p_line_id       => x_cle_id,
                                  x_value         => l_fin_klev_rec.capital_amount);
   If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
        raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
         raise OKC_API.G_EXCEPTION_ERROR;
   End If;

   l_fin_klev_rec.id := x_cle_id;
   l_fin_clev_rec.id := x_cle_id;

   okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                         p_init_msg_list => p_init_msg_list,
                                         x_return_status => x_return_status,
                                         x_msg_count     => x_msg_count,
                                         x_msg_data      => x_msg_data,
                                         p_clev_rec      => l_fin_clev_rec,
                                         p_klev_rec      => l_fin_klev_rec,
                                         x_clev_rec      => lx_fin_clev_rec,
                                         x_klev_rec      => lx_fin_klev_rec);
   If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
         raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
   Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
         raise OKC_API.G_EXCEPTION_ERROR;
   End If;
   ---------------------------
   --recalculate capital amount
   ---------------------------



    OKL_API.END_ACTIVITY (x_msg_count,
                          x_msg_data );
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_year_manufactured%ISOPEN THEN
          CLOSE c_year_manufactured;
      END IF;
      IF c_get_deal_type%ISOPEN THEN
         CLOSE c_get_deal_type;
      END IF;
      IF c_check_txl_rec%ISOPEN THEN
         CLOSE c_check_txl_rec;
      END IF;
      IF c_check_iti_rec%ISOPEN THEN
         CLOSE c_check_iti_rec;
      END IF;
      IF c_asset_info%ISOPEN THEN
         CLOSE c_asset_info;
      END IF;
      IF c_asset_loc_info%ISOPEN THEN
         CLOSE c_asset_loc_info;
      END IF;
      IF c_asset_details_info%ISOPEN THEN
         CLOSE c_asset_details_info;
      END IF;
      IF c_ib_info%ISOPEN THEN
         CLOSE c_ib_info;
      END IF;
      IF c_new_fa_line_id%ISOPEN THEN
         CLOSE c_new_fa_line_id;
      END IF;
      IF c_new_ib_line_id%ISOPEN THEN
         CLOSE c_new_ib_line_id;
      END IF;
      IF c_new_model_item_info%ISOPEN THEN
         CLOSE c_new_model_item_info;
      END IF;
      IF c_get_iti_object_id1%ISOPEN THEN
         CLOSE c_get_iti_object_id1;
      END IF;
      --Bug# 2981308 :
      IF l_fab_csr%ISOPEN then
          close l_fab_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_year_manufactured%ISOPEN THEN
          CLOSE c_year_manufactured;
      END IF;
      IF c_get_deal_type%ISOPEN THEN
         CLOSE c_get_deal_type;
      END IF;
      IF c_get_iti_object_id1%ISOPEN THEN
         CLOSE c_get_iti_object_id1;
      END IF;
      IF c_check_txl_rec%ISOPEN THEN
         CLOSE c_check_txl_rec;
      END IF;
      IF c_check_iti_rec%ISOPEN THEN
         CLOSE c_check_iti_rec;
      END IF;
      IF c_asset_loc_info%ISOPEN THEN
         CLOSE c_asset_loc_info;
      END IF;
      IF c_asset_info%ISOPEN THEN
         CLOSE c_asset_info;
      END IF;
      IF c_asset_details_info%ISOPEN THEN
         CLOSE c_asset_details_info;
      END IF;
      IF c_ib_info%ISOPEN THEN
         CLOSE c_ib_info;
      END IF;
      IF c_new_fa_line_id%ISOPEN THEN
         CLOSE c_new_fa_line_id;
      END IF;
      IF c_new_ib_line_id%ISOPEN THEN
         CLOSE c_new_ib_line_id;
      END IF;
      IF c_new_model_item_info%ISOPEN THEN
         CLOSE c_new_model_item_info;
      END IF;
      --Bug# 2981308 :
      IF l_fab_csr%ISOPEN then
          close l_fab_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_year_manufactured%ISOPEN THEN
          CLOSE c_year_manufactured;
      END IF;
      IF c_get_deal_type%ISOPEN THEN
         CLOSE c_get_deal_type;
      END IF;
      IF c_get_iti_object_id1%ISOPEN THEN
         CLOSE c_get_iti_object_id1;
      END IF;
      IF c_check_txl_rec%ISOPEN THEN
         CLOSE c_check_txl_rec;
      END IF;
      IF c_check_iti_rec%ISOPEN THEN
         CLOSE c_check_iti_rec;
      END IF;
      IF c_asset_info%ISOPEN THEN
         CLOSE c_asset_info;
      END IF;
      IF c_asset_loc_info%ISOPEN THEN
         CLOSE c_asset_loc_info;
      END IF;
      IF c_asset_details_info%ISOPEN THEN
         CLOSE c_asset_details_info;
      END IF;
      IF c_ib_info%ISOPEN THEN
         CLOSE c_ib_info;
      END IF;
      IF c_new_fa_line_id%ISOPEN THEN
         CLOSE c_new_fa_line_id;
      END IF;
      IF c_new_ib_line_id%ISOPEN THEN
         CLOSE c_new_ib_line_id;
      END IF;
      IF c_new_model_item_info%ISOPEN THEN
         CLOSE c_new_model_item_info;
      END IF;
      --Bug# 2981308 :
      IF l_fab_csr%ISOPEN then
          close l_fab_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END copy_asset_lines;
-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy of Asset Line -------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_asset_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_from_cle_id_tbl    IN  klev_tbl_type,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type)
  IS
    l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_COPY_ASSETS';
    l_api_version        CONSTANT NUMBER := 1;
    i                             NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_from_cle_id_tbl.COUNT > 0) THEN
      i := p_from_cle_id_tbl.FIRST;
      LOOP
        copy_asset_lines(p_api_version        => p_api_version,
                         p_init_msg_list      => p_init_msg_list,
                         x_return_status      => x_return_status,
                         x_msg_count          => x_msg_count,
                         x_msg_data           => x_msg_data,
                         P_from_cle_id        => p_from_cle_id_tbl(i).id,
                         p_to_cle_id          => p_to_cle_id,
                         p_to_chr_id          => p_to_chr_id,
                         p_to_template_yn     => p_to_template_yn,
                         p_copy_reference     => p_copy_reference,
                         p_copy_line_party_yn => p_copy_line_party_yn,
                         p_renew_ref_yn       => p_renew_ref_yn,
                         p_trans_type         => p_trans_type,
                         x_cle_id             => x_cle_id_tbl(i).id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        EXIT WHEN (i = p_from_cle_id_tbl.LAST);
        i := p_from_cle_id_tbl.NEXT(i);
      END LOOP;
    END IF;
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
  END copy_asset_lines;
-----------------------------------------------------------------------------------------------------
  PROCEDURE link_cov_asst(p_api_version              IN  NUMBER,
                          p_init_msg_list            IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
                          x_return_status            OUT NOCOPY VARCHAR2,
                          x_msg_count                OUT NOCOPY NUMBER,
                          x_msg_data                 OUT NOCOPY VARCHAR2,
                          p_orig_lnk_cle_id          IN  NUMBER,
                          p_new_lnk_cim_id           IN  NUMBER,
                          p_object_code              IN  VARCHAR2,
                          p_new_chr_id               IN  NUMBER) IS
    l_api_name         VARCHAR2(30) := 'LINK_COV_ASSET';
    l_new_cle_id       OKC_K_LINES_B.ID%TYPE;
    l_new_lnk_cim_id   NUMBER;
    l_cimv_rec         OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    lx_cimv_rec        OKL_OKC_MIGRATION_PVT.cimv_rec_type;
    --cursor to fetch original fin linked asset line id
    CURSOR l_orig_ast_csr(p_orig_lnk_cle_id IN NUMBER,
                          p_new_chr_id      IN NUMBER) IS
    SELECT new_cle.id
    FROM OKC_K_LINES_B new_cle,
         OKC_K_ITEMS   orig_lnk_cim
    WHERE
    --Bug# 2998115 :
   --Bug# 3868709 : Query fixed for Performance issue
   ((new_cle.ORIG_SYSTEM_ID1 = orig_lnk_cim.object1_id1)
      OR
      exists (select null
              from   OKC_K_LINES_B rbk_cle
              where  rbk_cle.id  = orig_lnk_cim.object1_id1
              AND rbk_cle.ORIG_SYSTEM_ID1 = new_cle.id)
     )
    AND new_cle.chr_id          = p_new_chr_id
    AND orig_lnk_cim.cle_id     = p_orig_lnk_cle_id
    AND orig_lnk_cim.jtot_object1_code = 'OKX_COVASST'
    AND not exists (select null
                   from OKC_K_LINES_B another_cle
                   where another_cle.orig_system_id1 = new_cle.orig_system_id1
                   and another_cle.lse_id = new_cle.lse_id
                   and another_cle.chr_id = new_cle.chr_id
                   and another_cle.id <> new_cle.id);

    --Bug# 3877032 : CAP AMNT
    cursor l_cap_amnt_csr(p_cim_id in number) is
    select  cov_ast_cim.object1_id1,
            cov_ast_cim.dnz_chr_id
    from   okc_k_lines_b          cov_ast_cleb,
           okc_line_styles_b      cov_ast_lseb,
           okl_k_lines            fee_kle,
           okc_k_items            cov_ast_cim
    where  fee_kle.id            = cov_ast_cleb.cle_id
    and    fee_kle.fee_type      = 'CAPITALIZED'
    and    cov_ast_lseb.id       =  cov_ast_cleb.lse_id
    and    cov_ast_lseb.lty_code = 'LINK_FEE_ASSET'
    and    cov_ast_cleb.id       =  cov_ast_cim.cle_id
    and    cov_ast_cim.id        = p_cim_id
    and    cov_ast_cim.jtot_object1_code = 'OKX_COVASST'
    --Bug# 4057305 : exclude the linked asset lines for which the asset does not
    --               exist on the same contract
    and    exists (select '1'
                   from   okc_k_lines_b fin_ast_cleb,
                          okc_line_styles_b fin_ast_lseb
                   where  fin_ast_cleb.id         =  cov_ast_cim.object1_id1
                   and    fin_ast_cleb.lse_id     =  fin_ast_lseb.id
                   and    fin_ast_lseb.lty_code   =  'FREE_FORM1'
                   and    fin_ast_cleb.dnz_chr_id = cov_ast_cim.dnz_chr_id);


    l_fin_clev_rec    okl_okc_migration_pvt.clev_rec_type;
    l_fin_klev_rec    okl_contract_pub.klev_rec_type;
    lx_fin_clev_rec   okl_okc_migration_pvt.clev_rec_type;
    lx_fin_klev_rec   okl_contract_pub.klev_rec_type;

  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_new_lnk_cim_id := p_new_lnk_cim_id;
    IF p_object_code in ('OKL_USAGE','OKX_LEASE') THEN --for covered usage contract and syndicated contract
      l_cimv_rec.id                := l_new_lnk_cim_id;
      l_cimv_rec.object1_id1       := OKL_API.G_MISS_CHAR;
      l_cimv_rec.object1_id2       := OKL_API.G_MISS_CHAR;
      l_cimv_rec.jtot_object1_code := OKL_API.G_MISS_CHAR;
    Else --for covered asset
      OPEN  l_orig_ast_csr(p_orig_lnk_cle_id => p_orig_lnk_cle_id,
                          p_new_chr_id      => p_new_chr_id);
      FETCH l_orig_ast_csr into l_new_cle_id;
      IF l_orig_ast_csr%NOTFOUND THEN
        --null out the new link
        l_cimv_rec.id                := l_new_lnk_cim_id;
        l_cimv_rec.object1_id1       := OKL_API.G_MISS_CHAR;
        l_cimv_rec.object1_id2       := OKL_API.G_MISS_CHAR;
        l_cimv_rec.jtot_object1_code := OKL_API.G_MISS_CHAR;
      ELSE
        --update the new link with new asset
        l_cimv_rec.id := l_new_lnk_cim_id;
        l_cimv_rec.object1_id1 := to_char(l_new_cle_id);
      END IF;
      CLOSE l_orig_ast_csr;
    END IF;
    --update link contract item accordingly
    okl_okc_migration_pvt.update_contract_item(p_api_version    => p_api_version,
                                               p_init_msg_list  => p_init_msg_list,
                                               x_return_status  => x_return_status,
                                               x_msg_count      => x_msg_count,
                                               x_msg_data       => x_msg_data,
                                               p_cimv_rec       => l_cimv_rec,
                                               x_cimv_rec       => lx_cimv_rec);
    IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    --Bug# 3877032
    If nvl(lx_cimv_rec.object1_id1,okl_api.g_miss_char) <> okl_api.g_miss_char then
        for l_cap_amnt_rec in l_cap_amnt_csr(lx_cimv_rec.id)
        Loop
             l_fin_klev_rec.id := to_number(l_cap_amnt_rec.object1_id1);
             l_fin_clev_rec.dnz_chr_id := l_cap_amnt_rec.dnz_chr_id;
             l_fin_clev_rec.id := to_number(l_cap_amnt_rec.object1_id1);
             OKL_EXECUTE_FORMULA_PUB.execute(p_api_version   => p_api_version,
                                           p_init_msg_list => p_init_msg_list,
                                           x_return_status => x_return_status,
                                           x_msg_count     => x_msg_count,
                                           x_msg_data      => x_msg_data,
                                           p_formula_name  => 'LINE_CAP_AMNT',
                                           p_contract_id   => l_fin_clev_rec.dnz_chr_id,
                                           p_line_id       => to_number(l_fin_klev_rec.id),
                                           x_value         => l_fin_klev_rec.capital_amount);
           If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                 raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                 raise OKC_API.G_EXCEPTION_ERROR;
           End If;


           okl_contract_pub.update_contract_line(p_api_version   => p_api_version,
                                                 p_init_msg_list => p_init_msg_list,
                                                 x_return_status => x_return_status,
                                                 x_msg_count     => x_msg_count,
                                                 x_msg_data      => x_msg_data,
                                                 p_clev_rec      => l_fin_clev_rec,
                                                 p_klev_rec      => l_fin_klev_rec,
                                                 x_clev_rec      => lx_fin_clev_rec,
                                                 x_klev_rec      => lx_fin_klev_rec);
           If x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR Then
                 raise OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
           Elsif x_return_status = OKC_API.G_RET_STS_ERROR Then
                 raise OKC_API.G_EXCEPTION_ERROR;
           End If;
        End Loop;
    End If;

  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF l_orig_ast_csr%ISOPEN THEN
        CLOSE l_orig_ast_csr;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF l_orig_ast_csr%ISOPEN THEN
        CLOSE l_orig_ast_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF l_orig_ast_csr%ISOPEN THEN
        CLOSE l_orig_ast_csr;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END link_cov_asst;

  --
  -- NAME: copy_service_line_link
  --
  -- DESCRIPTION: This process copies records from OKC_K_REL_OBJS
  --              in case a linked service line exists at copied contract.
  --
  PROCEDURE copy_service_line_link(
                                   x_return_status   OUT NOCOPY VARCHAR2,
                                   x_msg_count       OUT NOCOPY NUMBER,
                                   x_msg_data        OUT NOCOPY VARCHAR2,
                                   p_to_chr_id       IN  OKC_K_HEADERS_B.ID%TYPE,
                                   p_from_line_id    IN  OKC_K_LINES_B.ID%TYPE
                                  ) IS
  CURSOR line_style_csr(p_top_line_id OKC_K_LINES_B.ID%TYPE) IS
  SELECT lse.lty_code,
         cle.dnz_chr_id
  FROM   okc_line_styles_b lse,
         okc_k_lines_b cle
  WHERE cle.id       = p_top_line_id
  AND   cle.lse_id   = lse.id
  AND   lse.lse_parent_id is null
  AND   lse.lse_type = G_TLS_TYPE;

  CURSOR h_new_link_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT 'Y'
  FROM   okc_k_rel_objs
  WHERE  chr_id = p_chr_id
  AND    cle_id IS NULL
  AND    rty_code = 'OKLSRV'
  AND    jtot_object1_code = 'OKL_SERVICE';

  CURSOR h_old_link_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
  SELECT cle_id,
         chr_id,
         rty_code,
         object1_id1,
         object1_id2,
         jtot_object1_code
  FROM   okc_k_rel_objs
  WHERE  chr_id = p_chr_id
  AND    cle_id IS NULL
  AND    rty_code = 'OKLSRV'
  AND    jtot_object1_code = 'OKL_SERVICE';

  --
  -- returns linked service top line
  -- and its sub-lines
  --
  CURSOR srv_link_csr (p_srv_top_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT rel.id,
         rel.cle_id,
         rel.chr_id,
         rel.rty_code,
         rel.object1_id1,
         rel.object1_id2,
         rel.jtot_object1_code
  FROM   okc_k_rel_objs rel
  WHERE  rty_code          = 'OKLSRV'
  AND    cle_id is not null
  AND    jtot_object1_code = 'OKL_SERVICE_LINE'
  AND    cle_id            = p_srv_top_line_id
  UNION
  SELECT rel.id,
         rel.cle_id,
         rel.chr_id,
         rel.rty_code,
         rel.object1_id1,
         rel.object1_id2,
         rel.jtot_object1_code
  FROM   okc_k_rel_objs rel,
         okc_k_lines_b line
  WHERE  rty_code              = 'OKLSRV'
  AND    rel.cle_id is not null
  AND    rel.jtot_object1_code = 'OKL_COV_PROD'
  AND    rel.cle_id            = line.id
  AND    line.cle_id           = p_srv_top_line_id;

  CURSOR copy_line_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE,
                        p_line_id OKC_K_LINES_V.ID%TYPE) IS
  SELECT id
  FROM   okc_k_lines_b
  WHERE  orig_system_id1 = p_line_id
  AND    dnz_chr_id      = p_chr_id;

  copy_service_failed EXCEPTION;
  l_lty_code          OKC_LINE_STYLES_B.LTY_CODE%TYPE;
  l_from_chr_id       OKC_K_HEADERS_B.ID%TYPE;
  l_h_link_exist      VARCHAR2(1) := 'N';
  l_to_line_id        OKC_K_LINES_V.ID%TYPE;

  l_crjv_rec          OKC_K_REL_OBJS_PUB.crjv_rec_type;
  x_crjv_rec          OKC_K_REL_OBJS_PUB.crjv_rec_type;

  BEGIN

     x_return_status := OKL_API.G_RET_STS_SUCCESS;

     l_lty_code := '?';
     OPEN  line_style_csr(p_from_line_id);
     IF line_style_csr%NOTFOUND THEN
        OKL_API.set_message(p_app_name  => G_APP_NAME,
                            p_msg_name  => G_LINE_RECORD);
        -- halt validation
        RAISE copy_service_failed;
     END IF;

     FETCH line_style_csr INTO l_lty_code,
                               l_from_chr_id;
     CLOSE line_style_csr;

     --
     -- Copy link only in case of SERVICE line
     --
     IF (l_lty_code = G_SER_LINE_LTY_CODE) THEN -- SERVICE LINE

        FOR h_old_link_rec IN h_old_link_csr(l_from_chr_id)
        LOOP
           --
           -- Link exist for this contract
           -- so, check for header link after copy
           -- if no link exists, create one
           --
           l_h_link_exist := '?';
           OPEN h_new_link_csr(p_to_chr_id);
           FETCH h_new_link_csr INTO l_h_link_exist;
           CLOSE h_new_link_csr;

           IF (l_h_link_exist <> 'Y') THEN -- create header link first
              l_crjv_rec := NULL;
              l_crjv_rec.chr_id            := p_to_chr_id;
              l_crjv_rec.cle_id            := NULL;
              l_crjv_rec.rty_code          := h_old_link_rec.rty_code;
              l_crjv_rec.object1_id1       := h_old_link_rec.object1_id1;
              l_crjv_rec.object1_id2       := h_old_link_rec.object1_id2;
              l_crjv_rec.jtot_object1_code := h_old_link_rec.jtot_object1_code;

              OKC_K_REL_OBJS_PUB.create_row (
                                             p_api_version => 1.0,
                                             p_init_msg_list => OKC_API.G_FALSE,
                                             x_return_status => x_return_status,
                                             x_msg_count     => x_msg_count,
                                             x_msg_data      => x_msg_data,
                                             p_crjv_rec      => l_crjv_rec,
                                             x_crjv_rec      => x_crjv_rec
                                            );

              IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                 RAISE OKC_API.G_EXCEPTION_ERROR;
              END IF;
           END IF; -- l_h_link_exist = 'Y'

           --
           -- Now check for service line link
           -- If link exists for this service top line
           -- create links for the top as well as sub-lines
           --
           FOR srv_link_rec IN srv_link_csr (p_from_line_id)
           LOOP
             l_crjv_rec := NULL;
             l_crjv_rec.chr_id            := p_to_chr_id;
             l_crjv_rec.rty_code          := srv_link_rec.rty_code;
             l_crjv_rec.object1_id1       := srv_link_rec.object1_id1;
             l_crjv_rec.object1_id2       := srv_link_rec.object1_id2;
             l_crjv_rec.jtot_object1_code := srv_link_rec.jtot_object1_code;

             IF (srv_link_rec.cle_id IS NOT NULL) THEN  -- get corresponding copied line ID
                OPEN copy_line_csr(p_to_chr_id,
                                   srv_link_rec.cle_id);
                FETCH copy_line_csr INTO l_to_line_id;
                CLOSE copy_line_csr;

                l_crjv_rec.cle_id := l_to_line_id;
             END IF;

             OKC_K_REL_OBJS_PUB.create_row (
                                            p_api_version => 1.0,
                                            p_init_msg_list => OKC_API.G_FALSE,
                                            x_return_status => x_return_status,
                                            x_msg_count     => x_msg_count,
                                            x_msg_data      => x_msg_data,
                                            p_crjv_rec      => l_crjv_rec,
                                            x_crjv_rec      => x_crjv_rec
                                           );

             IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
                RAISE OKC_API.G_EXCEPTION_ERROR;
             END IF;

           END LOOP;
        END LOOP; -- h_old_link_csr
     END IF;

  EXCEPTION
     WHEN copy_service_failed THEN
       x_return_status := OKL_API.G_RET_STS_ERROR;
  END copy_service_line_link;

-----------------------------------------------------------------------------------------------
--------------------------- Main Process for Copy of All Lines --------------------------------
-----------------------------------------------------------------------------------------------
  Procedure copy_all_lines(
            p_api_version        IN  NUMBER,
            p_init_msg_list      IN  VARCHAR2 DEFAULT OKL_API.G_FALSE,
            x_return_status      OUT NOCOPY VARCHAR2,
            x_msg_count          OUT NOCOPY NUMBER,
            x_msg_data           OUT NOCOPY VARCHAR2,
            p_from_cle_id_tbl    IN  klev_tbl_type,
            p_to_cle_id          IN  NUMBER DEFAULT OKL_API.G_MISS_NUM,
            p_to_chr_id          IN  NUMBER,
            p_to_template_yn	 IN  VARCHAR2,
            p_copy_reference	 IN  VARCHAR2,
            p_copy_line_party_yn IN  VARCHAR2,
            p_renew_ref_yn       IN  VARCHAR2,
            p_trans_type         IN  VARCHAR2,
            x_cle_id_tbl         OUT NOCOPY klev_tbl_type)
  IS
    l_api_name           CONSTANT VARCHAR2(30) := 'CREATE_COPY_ASSETS';
    l_api_version        CONSTANT NUMBER := 1;
    i                             NUMBER := 0;
    lv_lty_code                   OKC_LINE_STYLES_B.LTY_CODE%TYPE;
    lx_cle_id_tbl                 klev_tbl_type;
    l_new_lnk_cle_id              OKC_K_LINES_B.ID%TYPE;
    l_orig_lnk_cle_id             OKC_K_LINES_B.ID%TYPE;
    l_new_lnk_cim_id              OKC_K_ITEMS.ID%TYPE;
    l_jtot_object1_code           OKC_K_ITEMS.JTOT_OBJECT1_CODE%TYPE;
    l_object1_id1                 OKC_K_ITEMS.OBJECT1_ID1%TYPE;
    l_object1_id2                 OKC_K_ITEMS.OBJECT1_ID2%TYPE;
    l_cle_id                      OKC_K_LINES_B.ID%TYPE;
    l_dnz_chr_id                  OKC_K_LINES_B.DNZ_CHR_ID%TYPE;
    l_level                       NUMBER;
    l_orig_system_id1             OKC_K_LINES_B.ORIG_SYSTEM_ID1%TYPE;

    lsx_cle_id_tbl                klev_tbl_type;
    j                             NUMBER := 0;
    k                             NUMBER := 0;
    m                             NUMBER := 0;
    ln_old_chr_id                 OKC_K_HEADERS_B.ID%TYPE;

    CURSOR c_get_lty_code(p_top_line_id OKC_K_LINES_B.ID%TYPE) IS

    SELECT lse.lty_code,
           cle.dnz_chr_id
    FROM okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.id = p_top_line_id
    AND cle.lse_id = lse.id
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE;

    CURSOR c_get_tls_spk(p_dnz_chr_id OKC_K_LINES_B.DNZ_CHR_ID%TYPE)
    IS
    SELECT cle.id top_line_id
    FROM okc_line_styles_b lse,
         okc_k_lines_b cle
    WHERE cle.dnz_chr_id = p_dnz_chr_id
    AND cle.lse_id = lse.id
    AND lse.lse_parent_id is null
    AND lse.lse_type = G_TLS_TYPE
    AND lse.lty_code in (G_FEE_LINE_LTY_CODE,G_SER_LINE_LTY_CODE,G_UBB_LINE_LTY_CODE);

    --cursor to fetch all the lines under a top line
    cursor  l_cle_csr(p_cle_id IN NUMBER) IS
    SELECT level,
	   id,
	   dnz_chr_id,
           orig_system_id1
    FROM okc_k_lines_b
    CONNECT BY  PRIOR id = cle_id
    START WITH  id = p_cle_id;

    --cursor to fetch copied link lines for fixing
    Cursor l_lnk_csr (p_cle_id IN NUMBER) is
    SELECT new_lnk_cle.id,
           new_lnk_cle.orig_system_id1,
           new_lnk_cim.id,
           new_lnk_cim.jtot_object1_code,
           new_lnk_cim.object1_id1,
           new_lnk_cim.object1_id2
    FROM okc_k_items     new_lnk_cim,
         okc_k_lines_b   new_lnk_cle
    WHERE new_lnk_cim.cle_id     = new_lnk_cle.id
    AND new_lnk_cim.dnz_chr_id = new_lnk_cle.dnz_chr_id
    --Bug# 4899328
    -- To link cov assets when copying only sub-lines
    --AND new_lnk_cle.cle_id     = p_cle_id;
    AND new_lnk_cle.id     = p_cle_id;

    -- Get contract context
    CURSOR h_context_csr (p_chr_id OKC_K_HEADERS_V.ID%TYPE) IS
    SELECT authoring_org_id,
           inv_organization_id
    FROM   okc_k_headers_b
    WHERE  id = p_chr_id;

    l_auth_org_id OKC_K_HEADERS_V.AUTHORING_ORG_ID%TYPE;
    l_inv_org_id  OKC_K_HEADERS_V.INV_ORGANIZATION_ID%TYPE;

  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing

    --
    -- Set the context once again
    --
    OPEN h_context_csr (p_to_chr_id);
    FETCH h_context_csr INTO l_auth_org_id,
                             l_inv_org_id;
    CLOSE h_context_csr;

    OKL_CONTEXT.SET_OKC_ORG_CONTEXT(l_auth_org_id,l_inv_org_id);


    IF (p_from_cle_id_tbl.COUNT > 0) THEN
      i := p_from_cle_id_tbl.FIRST;
      LOOP
        OPEN  c_get_lty_code(p_from_cle_id_tbl(i).id);
        IF c_get_lty_code%NOTFOUND THEN
          OKL_API.set_message(p_app_name  => G_APP_NAME,
                              p_msg_name => G_LINE_RECORD);
          -- halt validation
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;
        FETCH c_get_lty_code INTO lv_lty_code,
                                  ln_old_chr_id;
        CLOSE c_get_lty_code;
        IF lv_lty_code = G_FIN_LINE_LTY_CODE THEN
          copy_asset_lines(p_api_version        => p_api_version,
                           p_init_msg_list      => p_init_msg_list,
                           x_return_status      => x_return_status,
                           x_msg_count          => x_msg_count,
                           x_msg_data           => x_msg_data,
                           P_from_cle_id        => p_from_cle_id_tbl(i).id,
                           p_to_cle_id          => p_to_cle_id,
                           p_to_chr_id          => p_to_chr_id,
                           p_to_template_yn     => p_to_template_yn,
                           p_copy_reference     => p_copy_reference,
                           p_copy_line_party_yn => p_copy_line_party_yn,
                           p_renew_ref_yn       => p_renew_ref_yn,
                           p_trans_type         => p_trans_type,
                           x_cle_id             => x_cle_id_tbl(i).id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;
        ELSE
          OKL_COPY_CONTRACT_PUB.COPY_CONTRACT_LINES(
                                p_api_version        => p_api_version,
                                p_init_msg_list      => p_init_msg_list,
                                x_return_status      => x_return_status,
                                x_msg_count          => x_msg_count,
                                x_msg_data           => x_msg_data,
                                p_from_cle_id        => p_from_cle_id_tbl(i).id,
                                p_to_cle_id          => p_to_cle_id,
                                p_to_chr_id          => p_to_chr_id,
                                p_to_template_yn     => p_to_template_yn,
                                p_copy_reference     => p_copy_reference,
                                p_copy_line_party_yn => p_copy_line_party_yn,
                                p_renew_ref_yn       => p_renew_ref_yn,
                                x_cle_id             => x_cle_id_tbl(i).id);
          IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_COPY_LINE);
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
          ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            OKL_API.set_message(p_app_name     => G_APP_NAME,
                                p_msg_name     => G_COPY_LINE);
            EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
          END IF;

          --Bug# 2872267:
          /*-----------------------------------------------------------------
          --
          -- Copy Link detail from OKC_K_REL_OBJS
          -- in case of Service Integration, where
          -- OKL service line(s) is/are linked with OKS Service contract
          --
          --copy_service_line_link(
                                 --x_return_status   => x_return_status,
                                 --x_msg_count       => x_msg_count,
                                 --x_msg_data        => x_msg_data,
                                 --p_to_chr_id       => p_to_chr_id,
                                 --p_from_line_id    => p_from_cle_id_tbl(i).id
                                --);

          --IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
            --RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          --ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
            --RAISE OKL_API.G_EXCEPTION_ERROR;
          --END IF;
          ---------------------------------------------------------------------*/

        END IF;
        EXIT WHEN (i = p_from_cle_id_tbl.LAST);
        i := p_from_cle_id_tbl.NEXT(i);
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
         RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    lx_cle_id_tbl := x_cle_id_tbl;
    -- We need to do this only for split contract cases where in we need the other toplines
    -- fee, service, usage. Since the UI will collect only the asset lines and not other lines.
    IF p_trans_type = 'CSP' THEN
      FOR r_get_tls_spk IN c_get_tls_spk(p_dnz_chr_id => ln_old_chr_id) LOOP
        OKL_COPY_CONTRACT_PUB.COPY_CONTRACT_LINES(
                              p_api_version        => p_api_version,
                              p_init_msg_list      => p_init_msg_list,
                              x_return_status      => x_return_status,
                              x_msg_count          => x_msg_count,
                              x_msg_data           => x_msg_data,
                              p_from_cle_id        => r_get_tls_spk.top_line_id,
                              p_to_cle_id          => p_to_cle_id,
                              p_to_chr_id          => p_to_chr_id,
                              p_to_template_yn     => p_to_template_yn,
                              p_copy_reference     => p_copy_reference,
                              p_copy_line_party_yn => p_copy_line_party_yn,
                              p_renew_ref_yn       => p_renew_ref_yn,
                              x_cle_id             => lsx_cle_id_tbl(j).id);
        IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_COPY_LINE);
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR);
        ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
          OKL_API.set_message(p_app_name     => G_APP_NAME,
                              p_msg_name     => G_COPY_LINE);
          EXIT WHEN (x_return_status = OKL_API.G_RET_STS_ERROR);
        END IF;
        j := j + 1 ;
      END LOOP;
      IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    IF lx_cle_id_tbl.COUNT > 0 AND
       lsx_cle_id_tbl.COUNT > 0 THEN
      k := lx_cle_id_tbl.LAST;
      k := k + 1;
      m := lsx_cle_id_tbl.FIRST;
      LOOP
        lx_cle_id_tbl(k).id := lsx_cle_id_tbl(m).id;
        EXIT WHEN (m = lsx_cle_id_tbl.LAST);
        m := lsx_cle_id_tbl.NEXT(m);
        k := k + 1;
      END LOOP;
      x_cle_id_tbl := lx_cle_id_tbl;
    END IF;
    ---------------------------------------------------------------------------
    --special process to change the linked line links for covered asset
    ---------------------------------------------------------------------------
    IF lx_cle_id_tbl.LAST is NOT NULL THEN
      FOR j in 1..lx_cle_id_tbl.last LOOP
        OPEN  l_cle_csr(lx_cle_id_tbl(j).id);
        LOOP
          Fetch l_cle_csr INTO l_level,
                               l_cle_id,
                               l_dnz_chr_id,
                               l_orig_system_id1;
          EXIT when l_cle_csr%NOTFOUND;
          OPEN l_lnk_csr(p_cle_id => l_cle_id);
          LOOP
            FETCH l_lnk_csr INTO
                       l_new_lnk_cle_id,
                       l_orig_lnk_cle_id,
                       l_new_lnk_cim_id,
                       l_jtot_object1_code,
                       l_object1_id1,
                       l_object1_id2;
            EXIT when l_lnk_csr%NOTFOUND;
            IF l_jtot_object1_code in  ('OKX_COVASST', 'OKL_USAGE', 'OKX_LEASE') AND
               (l_object1_id1 is not null) THEN
               link_cov_asst(p_api_version      =>  p_api_version,
                             p_init_msg_list    =>  p_init_msg_list,
                             x_return_status    =>  x_return_status,
                             x_msg_count        =>  x_msg_count,
                             x_msg_data         =>  x_msg_data,
                             p_orig_lnk_cle_id  =>  l_orig_lnk_cle_id,
                             p_new_lnk_cim_id   =>  l_new_lnk_cim_id,
                             p_object_code      =>  l_jtot_object1_code,
                             p_new_chr_id       =>  l_dnz_chr_id );
               IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
               ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
                 RAISE OKL_API.G_EXCEPTION_ERROR;
               END IF;
            END IF;
          END LOOP;
          CLOSE l_lnk_csr;
        END LOOP;
        CLOSE l_cle_csr;
      END LOOP;
    END IF;
    -------------------------------------------------------------------------
    --end of special processing for fixing linked lines
    -------------------------------------------------------------------------
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      IF c_get_lty_code%ISOPEN THEN
        CLOSE c_get_lty_code;
      END IF;
      x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                                 l_api_name,
                                 G_PKG_NAME,
                                 'OKL_API.G_RET_STS_ERROR',
                                 x_msg_count,
                                 x_msg_data,
                                 '_PVT');
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      IF c_get_lty_code%ISOPEN THEN
        CLOSE c_get_lty_code;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OKL_API.G_RET_STS_UNEXP_ERROR',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
    WHEN OTHERS THEN
      IF c_get_lty_code%ISOPEN THEN
        CLOSE c_get_lty_code;
      END IF;
      x_return_status :=OKL_API.HANDLE_EXCEPTIONS(
                                l_api_name,
                                G_PKG_NAME,
                                'OTHERS',
                                x_msg_count,
                                x_msg_data,
                                '_PVT');
  END copy_all_lines;
End okl_copy_asset_pvt;

/
