--------------------------------------------------------
--  DDL for Package Body OKL_VFA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VFA_PVT" AS
/* $Header: OKLSVFAB.pls 120.3 2006/11/13 07:37:41 dpsingh noship $ */

/************************ HAND-CODED *********************************/
  G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200) := 'OKL_LLA_NO_MATCHING_RECORD';
  G_TABLE_TOKEN                CONSTANT VARCHAR2(200) := 'OKL_API.G_CHILD_TABLE_TOKEN';
  G_FIN_LINE_LTY_CODE                   OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM1';
  G_MODEL_LINE_LTY_CODE                 OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ITEM';
  G_ADDON_LINE_LTY_CODE                 OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'ADD_ITEM';
  G_FA_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FIXED_ASSET';
  G_INST_LINE_LTY_CODE                  OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'FREE_FORM2';
  G_IB_LINE_LTY_CODE                    OKC_LINE_STYLES_V.LTY_CODE%TYPE := 'INST_ITEM';
  G_EXCEPTION_STOP_VALIDATION            EXCEPTION;
---------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_dnz_chr_id
-- Description          : FK validation with OKL_K_HEADERS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                                p_dnz_chr_id    IN  OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS

    ln_dummy number := 0;

    CURSOR c_dnz_chr_id_validate(p_dnz_chr_id IN OKC_K_LINES_V.DNZ_CHR_ID%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT id
                  FROM okc_k_headers_b
                  WHERE id = p_dnz_chr_id);
  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_dnz_chr_id = OKL_API.G_MISS_NUM) OR
       (p_dnz_chr_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    OPEN  c_dnz_chr_id_validate(p_dnz_chr_id);
    IF c_dnz_chr_id_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_dnz_chr_id_validate into ln_dummy;
    CLOSE c_dnz_chr_id_validate;
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'dnz_chr_id');
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'dnz_chr_id');
    -- If the cursor is open then it has to be closed
    IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
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
    IF c_dnz_chr_id_validate%ISOPEN THEN
       CLOSE c_dnz_chr_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_dnz_chr_id;
---------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_fa_cle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_fa_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                               p_id IN  OKC_K_LINES_V.ID%TYPE) IS

    ln_dummy number := 0;
    l_lty_code              OKC_LINE_STYLES_V.LTY_CODE%TYPE;

    CURSOR get_lty_code(p_cle_id IN OKC_K_LINES_V.ID%TYPE) IS
    SELECT lse.lty_code
    FROM okc_k_lines_b cle,
         okc_line_styles_b lse
    WHERE cle.id = p_cle_id
    AND cle.lse_id = lse.id;

    CURSOR c_cle_id_validate1(p_cle_id IN OKC_K_LINES_V.ID%TYPE,
                              p_code IN OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT t1.id
                  FROM okc_line_styles_b t1
                       ,okc_line_styles_b t2
                       ,okc_subclass_top_line t3
                       ,okc_k_lines_b cle
                  WHERE t1.lty_code = p_code
                  AND cle.id = p_cle_id
                  AND cle.lse_id = t1.id
                  AND t2.lty_code = G_FIN_LINE_LTY_CODE
                  AND t1.lse_parent_id = t2.id
                  AND t3.lse_id = t2.id
                  AND t3.scs_code = 'LEASE');


  BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_id = OKL_API.G_MISS_NUM) OR
       (p_id IS NULL) THEN
       -- halt validation as it is a required field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;

    OPEN get_lty_code(p_id);
    IF get_lty_code%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH get_lty_code into l_lty_code;
    CLOSE get_lty_code;

    IF l_lty_code = G_FA_LINE_LTY_CODE THEN
      OPEN  c_cle_id_validate1(p_id,
                               l_lty_code);
      IF c_cle_id_validate1%NOTFOUND THEN
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
      FETCH c_cle_id_validate1 into ln_dummy;
      CLOSE c_cle_id_validate1;
      IF (ln_dummy = 0) then
         -- halt validation as it has no parent record
         RAISE G_EXCEPTION_HALT_VALIDATION;
      END IF;
    ELSE
      -- halt validation as it has no parent record
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'fa_cle_id');
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'fa_cle_id');
    -- If the cursor is open then it has to be closed
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
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
    IF get_lty_code%ISOPEN THEN
       CLOSE get_lty_code;
    END IF;
    IF c_cle_id_validate1%ISOPEN THEN
       CLOSE c_cle_id_validate1;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_fa_cle_id;

  -- Added by dpsingh
---------------------------------------------------------------------------
  -- PROCEDURE Validate_LE_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name   : Validate_LE_Id
  -- Description      :
  -- Business Rules   :
  -- Parameters       :
  -- Version          : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_LE_Id(p_legal_entity_id IN  NUMBER
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_exists                       NUMBER(1);
  item_not_found_error   EXCEPTION;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF (p_legal_entity_id = OKL_API.G_MISS_NUM OR
         p_legal_entity_id IS NULL)
     THEN
       OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'legal_entity_id');
       x_return_status := OKL_API.G_RET_STS_ERROR;
    ELSIF (p_legal_entity_id IS NOT NULL) AND
       (p_legal_entity_id <> Okl_Api.G_MISS_NUM) THEN
           l_exists  := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_legal_entity_id) ;
           IF (l_exists<>1) THEN
              Okl_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
              RAISE item_not_found_error;
           END IF;
     END IF;

  EXCEPTION
    WHEN item_not_found_error THEN
      x_return_status := Okc_Api.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name      => g_unexpected_error
                          ,p_token1        => g_sqlcode_token
                          ,p_token1_value  => SQLCODE
                          ,p_token2        => g_sqlerrm_token
                          ,p_token2_value  => SQLERRM);

       -- notify caller of an UNEXPECTED error
       x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_LE_Id;

------------------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE qc
  ---------------------------------------------------------------------------
  PROCEDURE qc IS
  BEGIN
    null;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    null;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    null;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONTRACT_ASSET_HV
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vfav_rec                     IN vfav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vfav_rec_type IS
    CURSOR okl_contract_asset_hv_pk_csr (p_id IN NUMBER) IS
    SELECT ID,
           MAJOR_VERSION,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           FA_CLE_ID,
           NAME,
           DESCRIPTION,
           ASSET_ID,
           ASSET_NUMBER,
           CORPORATE_BOOK,
           LIFE_IN_MONTHS,
           ORIGINAL_COST,
           COST,
           ADJUSTED_COST,
           CURRENT_UNITS,
           NEW_USED,
           IN_SERVICE_DATE,
           MODEL_NUMBER,
           ASSET_TYPE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
           DEPRECIATION_CATEGORY,
           DEPRN_START_DATE,
           DEPRN_METHOD_CODE,
           RATE_ADJUSTMENT_FACTOR,
           BASIC_RATE,
           ADJUSTED_RATE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           STATUS,
           PRIMARY_UOM_CODE,
           RECOVERABLE_COST,
--Bug# 2981308 :
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
	   --Added by dpsingh for LE uptake
           LEGAL_ENTITY_ID
      FROM Okl_Contract_Asset_Hv
      WHERE Okl_Contract_Asset_Hv.ID = p_id;
    l_okl_contract_asset_hv_pk     okl_contract_asset_hv_pk_csr%ROWTYPE;
    l_vfav_rec                     vfav_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_contract_asset_hv_pk_csr(p_vfav_rec.id);
    FETCH okl_contract_asset_hv_pk_csr INTO
              l_vfav_rec.id,
              l_vfav_rec.major_version,
              l_vfav_rec.object_version_number,
              l_vfav_rec.dnz_chr_id,
              l_vfav_rec.fa_cle_id,
              l_vfav_rec.name,
              l_vfav_rec.description,
              l_vfav_rec.asset_id,
              l_vfav_rec.asset_number,
              l_vfav_rec.corporate_book,
              l_vfav_rec.life_in_months,
              l_vfav_rec.original_cost,
              l_vfav_rec.cost,
              l_vfav_rec.adjusted_cost,
              l_vfav_rec.current_units,
              l_vfav_rec.new_used,
              l_vfav_rec.in_service_date,
              l_vfav_rec.model_number,
              l_vfav_rec.asset_type,
              l_vfav_rec.salvage_value,
              l_vfav_rec.percent_salvage_value,
              l_vfav_rec.depreciation_category,
              l_vfav_rec.deprn_start_date,
              l_vfav_rec.deprn_method_code,
              l_vfav_rec.rate_adjustment_factor,
              l_vfav_rec.basic_rate,
              l_vfav_rec.adjusted_rate,
              l_vfav_rec.start_date_active,
              l_vfav_rec.end_date_active,
              l_vfav_rec.status,
              l_vfav_rec.primary_uom_code,
              l_vfav_rec.recoverable_cost,
--Bug# 2981308 :
              l_vfav_rec.asset_key_id,
              l_vfav_rec.attribute_category,
              l_vfav_rec.attribute1,
              l_vfav_rec.attribute2,
              l_vfav_rec.attribute3,
              l_vfav_rec.attribute4,
              l_vfav_rec.attribute5,
              l_vfav_rec.attribute6,
              l_vfav_rec.attribute7,
              l_vfav_rec.attribute8,
              l_vfav_rec.attribute9,
              l_vfav_rec.attribute10,
              l_vfav_rec.attribute11,
              l_vfav_rec.attribute12,
              l_vfav_rec.attribute13,
              l_vfav_rec.attribute14,
              l_vfav_rec.attribute15,
              l_vfav_rec.created_by,
              l_vfav_rec.creation_date,
              l_vfav_rec.last_updated_by,
              l_vfav_rec.last_update_date,
              l_vfav_rec.last_update_login,
	      --Added by dpsingh for LE uptake
               l_vfav_rec.legal_entity_id;
    x_no_data_found := okl_contract_asset_hv_pk_csr%NOTFOUND;
    CLOSE okl_contract_asset_hv_pk_csr;
    RETURN(l_vfav_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vfav_rec                     IN vfav_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN vfav_rec_type IS
    l_vfav_rec                     vfav_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status       VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_vfav_rec := get_rec(p_vfav_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status:= l_return_status;
    RETURN(l_vfav_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vfav_rec                     IN vfav_rec_type
  ) RETURN vfav_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vfav_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONTRACT_ASSET_H
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vfa_rec                     IN vfa_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vfa_rec_type IS
    CURSOR okl_contract_asset_h_pk_csr (p_id IN NUMBER) IS
    SELECT ID,
           MAJOR_VERSION,
           OBJECT_VERSION_NUMBER,
           DNZ_CHR_ID,
           FA_CLE_ID,
           NAME,
           DESCRIPTION,
           ASSET_ID,
           ASSET_NUMBER,
           CORPORATE_BOOK,
           LIFE_IN_MONTHS,
           ORIGINAL_COST,
           COST,
           ADJUSTED_COST,
           CURRENT_UNITS,
           NEW_USED,
           IN_SERVICE_DATE,
           MODEL_NUMBER,
           ASSET_TYPE,
           SALVAGE_VALUE,
           PERCENT_SALVAGE_VALUE,
           DEPRECIATION_CATEGORY,
           DEPRN_START_DATE,
           DEPRN_METHOD_CODE,
           RATE_ADJUSTMENT_FACTOR,
           BASIC_RATE,
           ADJUSTED_RATE,
           START_DATE_ACTIVE,
           END_DATE_ACTIVE,
           STATUS,
           PRIMARY_UOM_CODE,
           RECOVERABLE_COST,
--Bug# 2981308 :
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
           --Added by dpsingh for LE uptake
           LEGAL_ENTITY_ID
      FROM Okl_Contract_Asset_H
      WHERE Okl_Contract_Asset_H.ID = p_id;
    l_okl_contract_asset_h_pk     okl_contract_asset_h_pk_csr%ROWTYPE;
    l_vfa_rec                     vfa_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_contract_asset_h_pk_csr(p_vfa_rec.id);
    FETCH okl_contract_asset_h_pk_csr INTO
              l_vfa_rec.id,
              l_vfa_rec.major_version,
              l_vfa_rec.object_version_number,
              l_vfa_rec.dnz_chr_id,
              l_vfa_rec.fa_cle_id,
              l_vfa_rec.name,
              l_vfa_rec.description,
              l_vfa_rec.asset_id,
              l_vfa_rec.asset_number,
              l_vfa_rec.corporate_book,
              l_vfa_rec.life_in_months,
              l_vfa_rec.original_cost,
              l_vfa_rec.cost,
              l_vfa_rec.adjusted_cost,
              l_vfa_rec.current_units,
              l_vfa_rec.new_used,
              l_vfa_rec.in_service_date,
              l_vfa_rec.model_number,
              l_vfa_rec.asset_type,
              l_vfa_rec.salvage_value,
              l_vfa_rec.percent_salvage_value,
              l_vfa_rec.depreciation_category,
              l_vfa_rec.deprn_start_date,
              l_vfa_rec.deprn_method_code,
              l_vfa_rec.rate_adjustment_factor,
              l_vfa_rec.basic_rate,
              l_vfa_rec.adjusted_rate,
              l_vfa_rec.start_date_active,
              l_vfa_rec.end_date_active,
              l_vfa_rec.status,
              l_vfa_rec.primary_uom_code,
              l_vfa_rec.recoverable_cost,
--Bug# 2981308
              l_vfa_rec.asset_key_id,
              l_vfa_rec.attribute_category,
              l_vfa_rec.attribute1,
              l_vfa_rec.attribute2,
              l_vfa_rec.attribute3,
              l_vfa_rec.attribute4,
              l_vfa_rec.attribute5,
              l_vfa_rec.attribute6,
              l_vfa_rec.attribute7,
              l_vfa_rec.attribute8,
              l_vfa_rec.attribute9,
              l_vfa_rec.attribute10,
              l_vfa_rec.attribute11,
              l_vfa_rec.attribute12,
              l_vfa_rec.attribute13,
              l_vfa_rec.attribute14,
              l_vfa_rec.attribute15,
              l_vfa_rec.created_by,
              l_vfa_rec.creation_date,
              l_vfa_rec.last_updated_by,
              l_vfa_rec.last_update_date,
              l_vfa_rec.last_update_login,
	      --Added by dpsingh for LE uptake
               l_vfa_rec.legal_entity_id;
    x_no_data_found := okl_contract_asset_h_pk_csr%NOTFOUND;
    CLOSE okl_contract_asset_h_pk_csr;
    RETURN(l_vfa_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vfa_rec                     IN vfa_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN vfa_rec_type IS
    l_vfa_rec                     vfa_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status       VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_vfa_rec := get_rec(p_vfa_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
    RETURN(l_vfa_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vfa_rec                     IN vfa_rec_type
  ) RETURN vfa_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vfa_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CONTRACT_ASSET_HV
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_vfav_rec   IN vfav_rec_type
  ) RETURN vfav_rec_type IS
    l_vfav_rec                     vfav_rec_type := p_vfav_rec;
  BEGIN
    IF (l_vfav_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.id := NULL;
    END IF;
    IF (l_vfav_rec.major_version = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.major_version := NULL;
    END IF;
    IF (l_vfav_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.object_version_number := NULL;
    END IF;
    IF (l_vfav_rec.dnz_chr_id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_vfav_rec.fa_cle_id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.fa_cle_id := NULL;
    END IF;
    IF (l_vfav_rec.name = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.name := NULL;
    END IF;
    IF (l_vfav_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.description := NULL;
    END IF;
    IF (l_vfav_rec.asset_id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.asset_id := NULL;
    END IF;
    IF (l_vfav_rec.asset_number = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.asset_number := NULL;
    END IF;
    IF (l_vfav_rec.corporate_book = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.corporate_book := NULL;
    END IF;
    IF (l_vfav_rec.life_in_months = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.life_in_months := NULL;
    END IF;
    IF (l_vfav_rec.original_cost = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.original_cost := NULL;
    END IF;
    IF (l_vfav_rec.cost = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.cost := NULL;
    END IF;
    IF (l_vfav_rec.adjusted_cost = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.adjusted_cost := NULL;
    END IF;
    IF (l_vfav_rec.current_units = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.current_units := NULL;
    END IF;
    IF (l_vfav_rec.new_used = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.new_used := NULL;
    END IF;
    IF (l_vfav_rec.in_service_date = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.in_service_date := NULL;
    END IF;
    IF (l_vfav_rec.model_number = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.model_number := NULL;
    END IF;
    IF (l_vfav_rec.asset_type = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.asset_type := NULL;
    END IF;
    IF (l_vfav_rec.salvage_value = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.salvage_value := NULL;
    END IF;
    IF (l_vfav_rec.percent_salvage_value = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.percent_salvage_value := NULL;
    END IF;
    IF (l_vfav_rec.depreciation_category = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.depreciation_category := NULL;
    END IF;
    IF (l_vfav_rec.deprn_start_date = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.deprn_start_date := NULL;
    END IF;
    IF (l_vfav_rec.deprn_method_code = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.deprn_method_code := NULL;
    END IF;
    IF (l_vfav_rec.rate_adjustment_factor = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.rate_adjustment_factor := NULL;
    END IF;
    IF (l_vfav_rec.basic_rate = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.basic_rate := NULL;
    END IF;
    IF (l_vfav_rec.adjusted_rate = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.adjusted_rate := NULL;
    END IF;
    IF (l_vfav_rec.start_date_active = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.start_date_active := NULL;
    END IF;
    IF (l_vfav_rec.end_date_active = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.end_date_active := NULL;
    END IF;
    IF (l_vfav_rec.status = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.status := NULL;
    END IF;
    IF (l_vfav_rec.primary_uom_code = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.primary_uom_code := NULL;
    END IF;
    IF (l_vfav_rec.recoverable_cost = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.recoverable_cost := NULL;
    END IF;
--Bug# 2981308:
    IF (l_vfav_rec.asset_key_id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.asset_key_id := NULL;
    END IF;
    IF (l_vfav_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute_category := NULL;
    END IF;
    IF (l_vfav_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute1 := NULL;
    END IF;
    IF (l_vfav_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute2 := NULL;
    END IF;
    IF (l_vfav_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute3 := NULL;
    END IF;
    IF (l_vfav_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute4 := NULL;
    END IF;
    IF (l_vfav_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute5 := NULL;
    END IF;
    IF (l_vfav_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute6 := NULL;
    END IF;
    IF (l_vfav_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute7 := NULL;
    END IF;
    IF (l_vfav_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute8 := NULL;
    END IF;
    IF (l_vfav_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute9 := NULL;
    END IF;
    IF (l_vfav_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute10 := NULL;
    END IF;
    IF (l_vfav_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute11 := NULL;
    END IF;
    IF (l_vfav_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute12 := NULL;
    END IF;
    IF (l_vfav_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute13 := NULL;
    END IF;
    IF (l_vfav_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute14 := NULL;
    END IF;
    IF (l_vfav_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_vfav_rec.attribute15 := NULL;
    END IF;
    IF (l_vfav_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.created_by := NULL;
    END IF;
    IF (l_vfav_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.creation_date := NULL;
    END IF;
    IF (l_vfav_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.last_updated_by := NULL;
    END IF;
    IF (l_vfav_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_vfav_rec.last_update_date := NULL;
    END IF;
    IF (l_vfav_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.last_update_login := NULL;
    END IF;
    --Added by dpsingh for LE uptake
     IF (l_vfav_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_vfav_rec.legal_entity_id := NULL;
    END IF;
    RETURN(l_vfav_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CONTRACT_ASSET_HV --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_vfav_rec                     IN vfav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    OKC_UTIL.ADD_VIEW('OKL_CONTRACT_ASSET_HV', x_return_status);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    IF p_vfav_rec.id = OKL_API.G_MISS_NUM OR
       p_vfav_rec.id IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_vfav_rec.major_version = OKL_API.G_MISS_NUM OR
       p_vfav_rec.major_version IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'major_version');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_vfav_rec.object_version_number = OKL_API.G_MISS_NUM OR
       p_vfav_rec.object_version_number IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
--*******************************Hand Code ***********************************--
    validate_dnz_chr_id(x_return_status, p_vfav_rec.dnz_chr_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_fa_cle_id(x_return_status, p_vfav_rec.fa_cle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    --Added by dpsingh

-- Validate_LE_Id
    Validate_LE_Id(p_vfav_rec.legal_entity_id, x_return_status);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
--*******************************Hand Code ***********************************--
    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate Record for:OKL_CONTRACT_ASSET_HV --
  -----------------------------------------------
  FUNCTION Validate_Record (p_vfav_rec IN vfav_rec_type)
  RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN vfav_rec_type,
    p_to   IN OUT NOCOPY vfa_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.major_version := p_from.major_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.fa_cle_id := p_from.fa_cle_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.corporate_book := p_from.corporate_book;
    p_to.life_in_months := p_from.life_in_months;
    p_to.original_cost := p_from.original_cost;
    p_to.cost := p_from.cost;
    p_to.adjusted_cost := p_from.adjusted_cost;
    p_to.current_units := p_from.current_units;
    p_to.new_used := p_from.new_used;
    p_to.in_service_date := p_from.in_service_date;
    p_to.model_number := p_from.model_number;
    p_to.asset_type := p_from.asset_type;
    p_to.salvage_value := p_from.salvage_value;
    p_to.percent_salvage_value := p_from.percent_salvage_value;
    p_to.depreciation_category := p_from.depreciation_category;
    p_to.deprn_start_date := p_from.deprn_start_date;
    p_to.deprn_method_code := p_from.deprn_method_code;
    p_to.rate_adjustment_factor := p_from.rate_adjustment_factor;
    p_to.basic_rate := p_from.basic_rate;
    p_to.adjusted_rate := p_from.adjusted_rate;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.status := p_from.status;
    p_to.primary_uom_code := p_from.primary_uom_code;
    p_to.recoverable_cost := p_from.recoverable_cost;
--Bug# 2981308 :
    p_to.asset_key_id := p_from.asset_key_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Added by dpsingh for LE uptake
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  PROCEDURE migrate (
    p_from IN vfa_rec_type,
    p_to   IN OUT NOCOPY vfav_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.major_version := p_from.major_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.fa_cle_id := p_from.fa_cle_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.asset_id := p_from.asset_id;
    p_to.asset_number := p_from.asset_number;
    p_to.corporate_book := p_from.corporate_book;
    p_to.life_in_months := p_from.life_in_months;
    p_to.original_cost := p_from.original_cost;
    p_to.cost := p_from.cost;
    p_to.adjusted_cost := p_from.adjusted_cost;
    p_to.current_units := p_from.current_units;
    p_to.new_used := p_from.new_used;
    p_to.in_service_date := p_from.in_service_date;
    p_to.model_number := p_from.model_number;
    p_to.asset_type := p_from.asset_type;
    p_to.salvage_value := p_from.salvage_value;
    p_to.percent_salvage_value := p_from.percent_salvage_value;
    p_to.depreciation_category := p_from.depreciation_category;
    p_to.deprn_start_date := p_from.deprn_start_date;
    p_to.deprn_method_code := p_from.deprn_method_code;
    p_to.rate_adjustment_factor := p_from.rate_adjustment_factor;
    p_to.basic_rate := p_from.basic_rate;
    p_to.adjusted_rate := p_from.adjusted_rate;
    p_to.start_date_active := p_from.start_date_active;
    p_to.end_date_active := p_from.end_date_active;
    p_to.status := p_from.status;
    p_to.primary_uom_code := p_from.primary_uom_code;
    p_to.recoverable_cost := p_from.recoverable_cost;
--Bug# 2981308
    p_to.asset_key_id := p_from.asset_key_id;
    p_to.attribute_category := p_from.attribute_category;
    p_to.attribute1 := p_from.attribute1;
    p_to.attribute2 := p_from.attribute2;
    p_to.attribute3 := p_from.attribute3;
    p_to.attribute4 := p_from.attribute4;
    p_to.attribute5 := p_from.attribute5;
    p_to.attribute6 := p_from.attribute6;
    p_to.attribute7 := p_from.attribute7;
    p_to.attribute8 := p_from.attribute8;
    p_to.attribute9 := p_from.attribute9;
    p_to.attribute10 := p_from.attribute10;
    p_to.attribute11 := p_from.attribute11;
    p_to.attribute12 := p_from.attribute12;
    p_to.attribute13 := p_from.attribute13;
    p_to.attribute14 := p_from.attribute14;
    p_to.attribute15 := p_from.attribute15;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    --Added by dpsingh for LE uptake
    p_to.legal_entity_id := p_from.legal_entity_id;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_CONTRACT_ASSET_HV --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfav_rec                     vfav_rec_type := p_vfav_rec;
    l_vfa_rec                      vfa_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_vfav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_vfav_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  -------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONTRACT_ASSET_HV --
  -------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vfav_tbl.COUNT > 0) THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vfav_rec                     => p_vfav_tbl(i));
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- insert_row for:OKL_CONTRACT_ASSET_HV --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfa_rec                     IN vfa_rec_type,
    x_vfa_rec                     OUT NOCOPY vfa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfa_rec                     vfa_rec_type := p_vfa_rec;
    l_def_vfa_rec                 vfa_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_ASSET_HV --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vfa_rec IN vfa_rec_type,
      x_vfa_rec OUT NOCOPY vfa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfa_rec := p_vfa_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_vfa_rec,                        -- IN
      l_vfa_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CONTRACT_ASSET_H(
      id,
      major_version,
      object_version_number,
      dnz_chr_id,
      fa_cle_id,
      name,
      description,
      asset_id,
      asset_number,
      corporate_book,
      life_in_months,
      original_cost,
      cost,
      adjusted_cost,
      current_units,
      new_used,
      in_service_date,
      model_number,
      asset_type,
      salvage_value,
      percent_salvage_value,
      depreciation_category,
      deprn_start_date,
      deprn_method_code,
      rate_adjustment_factor,
      basic_rate,
      adjusted_rate,
      start_date_active,
      end_date_active,
      status,
      primary_uom_code,
      recoverable_cost,
--Bug# 2981308
      asset_key_id,
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
      --Added by dpsingh for LE uptake
      legal_entity_id)
    VALUES (
      l_vfa_rec.id,
      l_vfa_rec.major_version,
      l_vfa_rec.object_version_number,
      l_vfa_rec.dnz_chr_id,
      l_vfa_rec.fa_cle_id,
      l_vfa_rec.name,
      l_vfa_rec.description,
      l_vfa_rec.asset_id,
      l_vfa_rec.asset_number,
      l_vfa_rec.corporate_book,
      l_vfa_rec.life_in_months,
      l_vfa_rec.original_cost,
      l_vfa_rec.cost,
      l_vfa_rec.adjusted_cost,
      l_vfa_rec.current_units,
      l_vfa_rec.new_used,
      l_vfa_rec.in_service_date,
      l_vfa_rec.model_number,
      l_vfa_rec.asset_type,
      l_vfa_rec.salvage_value,
      l_vfa_rec.percent_salvage_value,
      l_vfa_rec.depreciation_category,
      l_vfa_rec.deprn_start_date,
      l_vfa_rec.deprn_method_code,
      l_vfa_rec.rate_adjustment_factor,
      l_vfa_rec.basic_rate,
      l_vfa_rec.adjusted_rate,
      l_vfa_rec.start_date_active,
      l_vfa_rec.end_date_active,
      l_vfa_rec.status,
      l_vfa_rec.primary_uom_code,
      l_vfa_rec.recoverable_cost,
--bug# 2981308
      l_vfa_rec.asset_key_id,
      l_vfa_rec.attribute_category,
      l_vfa_rec.attribute1,
      l_vfa_rec.attribute2,
      l_vfa_rec.attribute3,
      l_vfa_rec.attribute4,
      l_vfa_rec.attribute5,
      l_vfa_rec.attribute6,
      l_vfa_rec.attribute7,
      l_vfa_rec.attribute8,
      l_vfa_rec.attribute9,
      l_vfa_rec.attribute10,
      l_vfa_rec.attribute11,
      l_vfa_rec.attribute12,
      l_vfa_rec.attribute13,
      l_vfa_rec.attribute14,
      l_vfa_rec.attribute15,
      l_vfa_rec.created_by,
      l_vfa_rec.creation_date,
      l_vfa_rec.last_updated_by,
      l_vfa_rec.last_update_date,
      l_vfa_rec.last_update_login,
     --Added by dpsingh for LE uptake
      l_vfa_rec.legal_entity_id);
    -- Set OUT values
    x_vfa_rec := l_vfa_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------------
  -- insert_row for :OKL_SUPP_INVOICE_DTLS_V --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfav_rec                     vfav_rec_type := p_vfav_rec;
    l_def_vfav_rec                 vfav_rec_type;
    l_vfa_rec                      vfa_rec_type;
    lx_vfa_rec                     vfa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vfav_rec IN vfav_rec_type
    ) RETURN vfav_rec_type IS
      l_vfav_rec vfav_rec_type := p_vfav_rec;
    BEGIN
      l_vfav_rec.CREATION_DATE := SYSDATE;
      l_vfav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_vfav_rec.LAST_UPDATE_DATE := l_vfav_rec.CREATION_DATE;
      l_vfav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vfav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vfav_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_ASSET_HV --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_vfav_rec IN vfav_rec_type,
      x_vfav_rec OUT NOCOPY vfav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfav_rec := p_vfav_rec;
      x_vfav_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_vfav_rec := null_out_defaults(p_vfav_rec);
    -- Set primary key value
    l_vfav_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_vfav_rec,                        -- IN
      l_def_vfav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vfav_rec := fill_who_columns(l_def_vfav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vfav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vfav_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vfav_rec, l_vfa_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vfa_rec,
      lx_vfa_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vfa_rec, l_def_vfav_rec);
    -- Set OUT values
    x_vfav_rec := l_def_vfav_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ----------------------------------------
  -- PL/SQL TBL insert_row for:vfaV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vfav_tbl.COUNT > 0) THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vfav_rec                     => p_vfav_tbl(i),
            x_vfav_rec                     => x_vfav_tbl(i));
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- lock_row for:OKL_CONTRACT_ASSET_HV --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfa_rec                     IN vfa_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_vfa_rec IN vfa_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CONTRACT_ASSET_H
    WHERE OBJECT_VERSION_NUMBER = p_vfa_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_vfa_rec IN vfa_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CONTRACT_ASSET_H
    WHERE ID = p_vfa_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CONTRACT_ASSET_H.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CONTRACT_ASSET_H.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_vfa_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_vfa_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_vfa_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_vfa_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------------
  -- lock_row for: OKL_CONTRACT_ASSET_HV --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfav_rec                     vfav_rec_type;
    l_vfa_rec                      vfa_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_vfav_rec, l_vfa_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vfa_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  --------------------------------------
  -- PL/SQL TBL lock_row for:VFAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_vfav_tbl.COUNT > 0) THEN
      i := p_vfav_tbl.FIRST;
      LOOP
        lock_row(
           p_api_version                  => p_api_version,
           p_init_msg_list                => p_init_msg_list,
           x_return_status                => x_return_status,
           x_msg_count                    => x_msg_count,
           x_msg_data                     => x_msg_data,
           p_vfav_rec                     => p_vfav_tbl(i));
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- update_row for:OKL_CONTRACT_ASSET_HV --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfa_rec                      IN vfa_rec_type,
    x_vfa_rec                      OUT NOCOPY vfa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfa_rec                      vfa_rec_type := p_vfa_rec;
    l_def_vfa_rec                  vfa_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vfa_rec IN vfa_rec_type,
      x_vfa_rec OUT NOCOPY vfa_rec_type
    ) RETURN VARCHAR2 IS
      l_vfa_rec                     vfa_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfa_rec := p_vfa_rec;
      -- Get current database values
      l_vfa_rec := get_rec(p_vfa_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_vfa_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.id := l_vfa_rec.id;
        END IF;
        IF (x_vfa_rec.major_version = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.major_version := l_vfa_rec.major_version;
        END IF;
        IF (x_vfa_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.object_version_number := l_vfa_rec.object_version_number;
        END IF;
        IF (x_vfa_rec.dnz_chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.dnz_chr_id := l_vfa_rec.dnz_chr_id;
        END IF;
        IF (x_vfa_rec.fa_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.fa_cle_id := l_vfa_rec.fa_cle_id;
        END IF;
        IF (x_vfa_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.name := l_vfa_rec.name;
        END IF;
        IF (x_vfa_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.description := l_vfa_rec.description;
        END IF;
        IF (x_vfa_rec.asset_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.asset_id := l_vfa_rec.asset_id;
        END IF;
        IF (x_vfa_rec.asset_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.asset_number := l_vfa_rec.asset_number;
        END IF;
        IF (x_vfa_rec.corporate_book = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.corporate_book := l_vfa_rec.corporate_book;
        END IF;
        IF (x_vfa_rec.life_in_months = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.life_in_months := l_vfa_rec.life_in_months;
        END IF;
        IF (x_vfa_rec.original_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.original_cost := l_vfa_rec.original_cost;
        END IF;
        IF (x_vfa_rec.cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.cost := l_vfa_rec.cost;
        END IF;
        IF (x_vfa_rec.adjusted_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.adjusted_cost := l_vfa_rec.adjusted_cost;
        END IF;
        IF (x_vfa_rec.current_units = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.current_units := l_vfa_rec.current_units;
        END IF;
        IF (x_vfa_rec.new_used = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.new_used := l_vfa_rec.new_used;
        END IF;
        IF (x_vfa_rec.in_service_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.in_service_date := l_vfa_rec.in_service_date;
        END IF;
        IF (x_vfa_rec.model_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.model_number := l_vfa_rec.model_number;
        END IF;
        IF (x_vfa_rec.asset_type = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.asset_type := l_vfa_rec.asset_type;
        END IF;
        IF (x_vfa_rec.salvage_value = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.salvage_value := l_vfa_rec.salvage_value;
        END IF;
        IF (x_vfa_rec.percent_salvage_value = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.percent_salvage_value := l_vfa_rec.percent_salvage_value;
        END IF;
        IF (x_vfa_rec.depreciation_category = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.depreciation_category := l_vfa_rec.depreciation_category;
        END IF;
        IF (x_vfa_rec.deprn_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.deprn_start_date := l_vfa_rec.deprn_start_date;
        END IF;
        IF (x_vfa_rec.deprn_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.deprn_method_code := l_vfa_rec.deprn_method_code;
        END IF;
        IF (x_vfa_rec.rate_adjustment_factor = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.rate_adjustment_factor := l_vfa_rec.rate_adjustment_factor;
        END IF;
        IF (x_vfa_rec.basic_rate = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.basic_rate := l_vfa_rec.basic_rate;
        END IF;
        IF (x_vfa_rec.adjusted_rate = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.adjusted_rate := l_vfa_rec.adjusted_rate;
        END IF;
        IF (x_vfa_rec.start_date_active = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.start_date_active := l_vfa_rec.start_date_active;
        END IF;
        IF (x_vfa_rec.end_date_active = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.end_date_active := l_vfa_rec.end_date_active;
        END IF;
        IF (x_vfa_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.status := l_vfa_rec.status;
        END IF;
        IF (x_vfa_rec.primary_uom_code = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.primary_uom_code := l_vfa_rec.primary_uom_code;
        END IF;
        IF (x_vfa_rec.recoverable_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.recoverable_cost := l_vfa_rec.recoverable_cost;
        END IF;
--Bug# 2981308
        IF (x_vfa_rec.asset_key_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.asset_key_id := l_vfa_rec.asset_key_id;
        END IF;
        IF (x_vfa_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute_category := l_vfa_rec.attribute_category;
        END IF;
        IF (x_vfa_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute1 := l_vfa_rec.attribute1;
        END IF;
        IF (x_vfa_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute2 := l_vfa_rec.attribute2;
        END IF;
        IF (x_vfa_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute3 := l_vfa_rec.attribute3;
        END IF;
        IF (x_vfa_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute4 := l_vfa_rec.attribute4;
        END IF;
        IF (x_vfa_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute5 := l_vfa_rec.attribute5;
        END IF;
        IF (x_vfa_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute6 := l_vfa_rec.attribute6;
        END IF;
        IF (x_vfa_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute7 := l_vfa_rec.attribute7;
        END IF;
        IF (x_vfa_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute8 := l_vfa_rec.attribute8;
        END IF;
        IF (x_vfa_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute9 := l_vfa_rec.attribute9;
        END IF;
        IF (x_vfa_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute10 := l_vfa_rec.attribute10;
        END IF;
        IF (x_vfa_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute11 := l_vfa_rec.attribute11;
        END IF;
        IF (x_vfa_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute12 := l_vfa_rec.attribute12;
        END IF;
        IF (x_vfa_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute13 := l_vfa_rec.attribute13;
        END IF;
        IF (x_vfa_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute14 := l_vfa_rec.attribute14;
        END IF;
        IF (x_vfa_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfa_rec.attribute15 := l_vfa_rec.attribute15;
        END IF;
        IF (x_vfa_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.created_by := l_vfa_rec.created_by;
        END IF;
        IF (x_vfa_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.creation_date := l_vfa_rec.creation_date;
        END IF;
        IF (x_vfa_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.last_updated_by := l_vfa_rec.last_updated_by;
        END IF;
        IF (x_vfa_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfa_rec.last_update_date := l_vfa_rec.last_update_date;
        END IF;
        IF (x_vfa_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.last_update_login := l_vfa_rec.last_update_login;
        END IF;
	 --Added by dpsingh for LE uptake
	 IF (x_vfa_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfa_rec.legal_entity_id := l_vfa_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_ASSET_HV --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vfa_rec IN vfa_rec_type,
      x_vfa_rec OUT NOCOPY vfa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfa_rec := p_vfa_rec;
      x_vfa_rec.OBJECT_VERSION_NUMBER := p_vfa_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_vfa_rec,                        -- IN
      l_vfa_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vfa_rec, l_def_vfa_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CONTRACT_ASSET_H
    SET ID = l_def_vfa_rec.id,
        MAJOR_VERSION = l_def_vfa_rec.major_version,
        OBJECT_VERSION_NUMBER = l_def_vfa_rec.object_version_number,
        DNZ_CHR_ID = l_def_vfa_rec.dnz_chr_id,
        FA_CLE_ID = l_def_vfa_rec.fa_cle_id,
        NAME = l_def_vfa_rec.name,
        DESCRIPTION = l_def_vfa_rec.description,
        ASSET_ID = l_def_vfa_rec.asset_id,
        ASSET_NUMBER = l_def_vfa_rec.asset_number,
        CORPORATE_BOOK = l_def_vfa_rec.corporate_book,
        LIFE_IN_MONTHS = l_def_vfa_rec.life_in_months,
        ORIGINAL_COST = l_def_vfa_rec.original_cost,
        COST = l_def_vfa_rec.cost,
        ADJUSTED_COST = l_def_vfa_rec.adjusted_cost,
        CURRENT_UNITS = l_def_vfa_rec.current_units,
        NEW_USED = l_def_vfa_rec.new_used,
        IN_SERVICE_DATE = l_def_vfa_rec.in_service_date,
        MODEL_NUMBER = l_def_vfa_rec.model_number,
        ASSET_TYPE = l_def_vfa_rec.asset_type,
        SALVAGE_VALUE = l_def_vfa_rec.salvage_value,
        PERCENT_SALVAGE_VALUE = l_def_vfa_rec.percent_salvage_value,
        DEPRECIATION_CATEGORY = l_def_vfa_rec.depreciation_category,
        DEPRN_START_DATE = l_def_vfa_rec.deprn_start_date,
        DEPRN_METHOD_CODE = l_def_vfa_rec.deprn_method_code,
        RATE_ADJUSTMENT_FACTOR = l_def_vfa_rec.rate_adjustment_factor,
        BASIC_RATE = l_def_vfa_rec.basic_rate,
        ADJUSTED_RATE = l_def_vfa_rec.adjusted_rate,
        START_DATE_ACTIVE = l_def_vfa_rec.start_date_active,
        END_DATE_ACTIVE = l_def_vfa_rec.end_date_active,
        STATUS = l_def_vfa_rec.status,
        PRIMARY_UOM_CODE = l_def_vfa_rec.primary_uom_code,
        RECOVERABLE_COST = l_def_vfa_rec.recoverable_cost,
--Bug# 2981308:
        ASSET_KEY_ID = l_def_vfa_rec.asset_key_id,
        ATTRIBUTE_CATEGORY = l_def_vfa_rec.attribute_category,
        ATTRIBUTE1 = l_def_vfa_rec.attribute1,
        ATTRIBUTE2 = l_def_vfa_rec.attribute2,
        ATTRIBUTE3 = l_def_vfa_rec.attribute3,
        ATTRIBUTE4 = l_def_vfa_rec.attribute4,
        ATTRIBUTE5 = l_def_vfa_rec.attribute5,
        ATTRIBUTE6 = l_def_vfa_rec.attribute6,
        ATTRIBUTE7 = l_def_vfa_rec.attribute7,
        ATTRIBUTE8 = l_def_vfa_rec.attribute8,
        ATTRIBUTE9 = l_def_vfa_rec.attribute9,
        ATTRIBUTE10 = l_def_vfa_rec.attribute10,
        ATTRIBUTE11 = l_def_vfa_rec.attribute11,
        ATTRIBUTE12 = l_def_vfa_rec.attribute12,
        ATTRIBUTE13 = l_def_vfa_rec.attribute13,
        ATTRIBUTE14 = l_def_vfa_rec.attribute14,
        ATTRIBUTE15 = l_def_vfa_rec.attribute15,
        CREATED_BY = l_def_vfa_rec.created_by,
        CREATION_DATE = l_def_vfa_rec.creation_date,
        LAST_UPDATED_BY = l_def_vfa_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_vfa_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_vfa_rec.last_update_login,
	--Added by dpsingh for LE uptake
        LEGAL_ENTITY_ID = l_def_vfa_rec.legal_entity_id
    WHERE ID = l_def_vfa_rec.id;
    x_vfa_rec := l_vfa_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ------------------------------------------
  -- update_row for:OKL_CONTRACT_ASSET_HV --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type,
    x_vfav_rec                     OUT NOCOPY vfav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfav_rec                     vfav_rec_type := p_vfav_rec;
    l_def_vfav_rec                 vfav_rec_type;
    l_db_vfav_rec                  vfav_rec_type;
    l_vfa_rec                      vfa_rec_type;
    lx_vfa_rec                     vfa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vfav_rec IN vfav_rec_type
    ) RETURN vfav_rec_type IS
      l_vfav_rec vfav_rec_type := p_vfav_rec;
    BEGIN
      l_vfav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_vfav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vfav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vfav_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vfav_rec IN vfav_rec_type,
      x_vfav_rec OUT NOCOPY vfav_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfav_rec := p_vfav_rec;
      l_db_vfav_rec := get_rec(p_vfav_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_vfav_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.id := l_db_vfav_rec.id;
        END IF;
        IF (x_vfav_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.object_version_number := l_db_vfav_rec.object_version_number;
        END IF;
        IF (x_vfav_rec.major_version = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.major_version := l_db_vfav_rec.major_version;
        END IF;
        IF (x_vfav_rec.dnz_chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.dnz_chr_id := l_db_vfav_rec.dnz_chr_id;
        END IF;
        IF (x_vfav_rec.fa_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.fa_cle_id := l_db_vfav_rec.fa_cle_id;
        END IF;
        IF (x_vfav_rec.name = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.name := l_db_vfav_rec.name;
        END IF;
        IF (x_vfav_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.description := l_db_vfav_rec.description;
        END IF;
        IF (x_vfav_rec.asset_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.asset_id := l_db_vfav_rec.asset_id;
        END IF;
        IF (x_vfav_rec.asset_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.asset_number := l_db_vfav_rec.asset_number;
        END IF;
        IF (x_vfav_rec.corporate_book = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.corporate_book := l_db_vfav_rec.corporate_book;
        END IF;
        IF (x_vfav_rec.life_in_months = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.life_in_months := l_db_vfav_rec.life_in_months;
        END IF;
        IF (x_vfav_rec.original_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.original_cost := l_db_vfav_rec.original_cost;
        END IF;
        IF (x_vfav_rec.cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.cost := l_db_vfav_rec.cost;
        END IF;
        IF (x_vfav_rec.adjusted_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.adjusted_cost := l_db_vfav_rec.adjusted_cost;
        END IF;
        IF (x_vfav_rec.current_units = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.current_units := l_db_vfav_rec.current_units;
        END IF;
        IF (x_vfav_rec.new_used = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.new_used := l_db_vfav_rec.new_used;
        END IF;
        IF (x_vfav_rec.in_service_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.in_service_date := l_db_vfav_rec.in_service_date;
        END IF;
        IF (x_vfav_rec.model_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.model_number := l_db_vfav_rec.model_number;
        END IF;
        IF (x_vfav_rec.asset_type = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.asset_type := l_db_vfav_rec.asset_type;
        END IF;
        IF (x_vfav_rec.salvage_value = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.salvage_value := l_db_vfav_rec.salvage_value;
        END IF;
        IF (x_vfav_rec.percent_salvage_value = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.percent_salvage_value := l_db_vfav_rec.percent_salvage_value;
        END IF;
        IF (x_vfav_rec.depreciation_category = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.depreciation_category := l_db_vfav_rec.depreciation_category;
        END IF;
        IF (x_vfav_rec.deprn_start_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.deprn_start_date := l_db_vfav_rec.deprn_start_date;
        END IF;
        IF (x_vfav_rec.deprn_method_code = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.deprn_method_code := l_db_vfav_rec.deprn_method_code;
        END IF;
        IF (x_vfav_rec.rate_adjustment_factor = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.rate_adjustment_factor := l_db_vfav_rec.rate_adjustment_factor;
        END IF;
        IF (x_vfav_rec.basic_rate = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.basic_rate := l_db_vfav_rec.basic_rate;
        END IF;
        IF (x_vfav_rec.adjusted_rate = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.adjusted_rate := l_db_vfav_rec.adjusted_rate;
        END IF;
        IF (x_vfav_rec.start_date_active = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.start_date_active := l_db_vfav_rec.start_date_active;
        END IF;
        IF (x_vfav_rec.end_date_active = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.end_date_active := l_db_vfav_rec.end_date_active;
        END IF;
        IF (x_vfav_rec.status = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.status := l_db_vfav_rec.status;
        END IF;
        IF (x_vfav_rec.primary_uom_code = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.primary_uom_code := l_db_vfav_rec.primary_uom_code;
        END IF;
        IF (x_vfav_rec.recoverable_cost = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.recoverable_cost := l_db_vfav_rec.recoverable_cost;
        END IF;
--Bug# 2981308:
        IF (x_vfav_rec.asset_key_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.asset_key_id := l_db_vfav_rec.asset_key_id;
        END IF;
        IF (x_vfav_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute_category := l_db_vfav_rec.attribute_category;
        END IF;
        IF (x_vfav_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute1 := l_db_vfav_rec.attribute1;
        END IF;
        IF (x_vfav_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute2 := l_db_vfav_rec.attribute2;
        END IF;
        IF (x_vfav_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute3 := l_db_vfav_rec.attribute3;
        END IF;
        IF (x_vfav_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute4 := l_db_vfav_rec.attribute4;
        END IF;
        IF (x_vfav_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute5 := l_db_vfav_rec.attribute5;
        END IF;
        IF (x_vfav_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute6 := l_db_vfav_rec.attribute6;
        END IF;
        IF (x_vfav_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute7 := l_db_vfav_rec.attribute7;
        END IF;
        IF (x_vfav_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute8 := l_db_vfav_rec.attribute8;
        END IF;
        IF (x_vfav_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute9 := l_db_vfav_rec.attribute9;
        END IF;
        IF (x_vfav_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute10 := l_db_vfav_rec.attribute10;
        END IF;
        IF (x_vfav_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute11 := l_db_vfav_rec.attribute11;
        END IF;
        IF (x_vfav_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute12 := l_db_vfav_rec.attribute12;
        END IF;
        IF (x_vfav_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute13 := l_db_vfav_rec.attribute13;
        END IF;
        IF (x_vfav_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute14 := l_db_vfav_rec.attribute14;
        END IF;
        IF (x_vfav_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_vfav_rec.attribute15 := l_db_vfav_rec.attribute15;
        END IF;
        IF (x_vfav_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.created_by := l_db_vfav_rec.created_by;
        END IF;
        IF (x_vfav_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.creation_date := l_db_vfav_rec.creation_date;
        END IF;
        IF (x_vfav_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.last_updated_by := l_db_vfav_rec.last_updated_by;
        END IF;
        IF (x_vfav_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_vfav_rec.last_update_date := l_db_vfav_rec.last_update_date;
        END IF;
        IF (x_vfav_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.last_update_login := l_db_vfav_rec.last_update_login;
        END IF;
	--Added by dpsingh for LE uptake
	 IF (x_vfav_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_vfav_rec.legal_entity_id := l_db_vfav_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_ASSET_HV --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_vfav_rec IN vfav_rec_type,
      x_vfav_rec OUT NOCOPY vfav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vfav_rec := p_vfav_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_vfav_rec,                        -- IN
      x_vfav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vfav_rec, l_def_vfav_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vfav_rec := fill_who_columns(l_def_vfav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vfav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vfav_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vfav_rec, l_vfa_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------

    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vfa_rec,
      lx_vfa_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vfa_rec, l_def_vfav_rec);
    x_vfav_rec := l_def_vfav_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ----------------------------------------
  -- PL/SQL TBL update_row for:vfav_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type,
    x_vfav_tbl                     OUT NOCOPY vfav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vfav_tbl.COUNT > 0) THEN
      i := p_vfav_tbl.FIRST;
      LOOP
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vfav_rec                     => p_vfav_tbl(i),
            x_vfav_rec                     => x_vfav_tbl(i));
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- delete_row for:OKL_CONTRACT_ASSET_HV --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfa_rec                     IN vfa_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfa_rec                      vfa_rec_type := p_vfa_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_CONTRACT_ASSET_H
    WHERE ID = p_vfa_rec.id;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------
  -- delete_row for:OKL_CONTRACT_ASSET_HV --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_rec                     IN vfav_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vfav_rec                     vfav_rec_type := p_vfav_rec;
    l_vfa_rec                      vfa_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_vfav_rec, l_vfa_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vfa_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONTRACT_ASSET_HV --
  -----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vfav_tbl                     IN vfav_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vfav_tbl.COUNT > 0) THEN
      i := p_vfav_tbl.FIRST;
      LOOP
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vfav_rec                     => p_vfav_tbl(i));
        EXIT WHEN (i = p_vfav_tbl.LAST);
        i := p_vfav_tbl.NEXT(i);
      END LOOP;
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_VFA_PVT;

/
