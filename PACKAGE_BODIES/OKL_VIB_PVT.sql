--------------------------------------------------------
--  DDL for Package Body OKL_VIB_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_VIB_PVT" AS
/* $Header: OKLSVIBB.pls 120.2 2006/11/13 07:38:09 dpsingh noship $ */
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
-- Procedure Name       : Validate_ib_cle_id
-- Description          : FK validation with OKL_K_LINES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_ib_cle_id(x_return_status OUT NOCOPY VARCHAR2,
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
                              p_code IN OKC_LINE_STYLES_V.LTY_CODE%TYPE,
                              p_code2 IN OKC_LINE_STYLES_V.LTY_CODE%TYPE) IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT t1.id
                  FROM okc_line_styles_b t1
                       ,okc_line_styles_b t2
                       ,okc_line_styles_b t3
                       ,okc_subclass_top_line t4
                       ,okc_k_lines_b cle
                  WHERE t1.lty_code = p_code
                  AND cle.id = p_cle_id
                  AND cle.lse_id = t1.id
                  AND t2.lty_code = p_code2
                  AND t1.lse_parent_id = t2.id
                  AND t2.lse_parent_id = t3.id
                  AND t3.lty_code = G_FIN_LINE_LTY_CODE
                  AND t4.lse_id = t3.id
                  AND t4.scs_code = 'LEASE');
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

    IF l_lty_code = G_IB_LINE_LTY_CODE THEN
      OPEN  c_cle_id_validate1(p_id,
                               l_lty_code,
                               G_INST_LINE_LTY_CODE);
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
                        p_token1_value => 'ib_cle_id');
    -- Notify Error
    x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKL_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ib_cle_id');
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
  END validate_ib_cle_id;

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
     item_not_found_error    EXCEPTION;
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
  -- FUNCTION get_rec for: OKL_CONTRACT_IB_HV
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vibv_rec                     IN vibv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vibv_rec_type IS
    CURSOR okl_contract_ib_hv_pk_csr(p_id IN NUMBER) IS
    SELECT  ID,
            MAJOR_VERSION,
            OBJECT_VERSION_NUMBER,
            DNZ_CHR_ID,
            IB_CLE_ID,
            NAME,
            DESCRIPTION,
            INVENTORY_ITEM_ID,
            CURRENT_SERIAL_NUMBER,
            INSTALL_SITE_USE_ID,
            QUANTITY,
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
      FROM Okl_Contract_Ib_Hv
      WHERE Okl_Contract_Ib_Hv.ID = p_id;

    l_vibv_rec                     vibv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_contract_ib_hv_pk_csr (p_vibv_rec.id);
    FETCH okl_contract_ib_hv_pk_csr INTO
              l_vibv_rec.id,
              l_vibv_rec.major_version,
              l_vibv_rec.object_version_number,
              l_vibv_rec.dnz_chr_id,
              l_vibv_rec.ib_cle_id,
              l_vibv_rec.name,
              l_vibv_rec.description,
              l_vibv_rec.inventory_item_id,
              l_vibv_rec.current_serial_number,
              l_vibv_rec.install_site_use_id,
              l_vibv_rec.quantity,
              l_vibv_rec.attribute_category,
              l_vibv_rec.attribute1,
              l_vibv_rec.attribute2,
              l_vibv_rec.attribute3,
              l_vibv_rec.attribute4,
              l_vibv_rec.attribute5,
              l_vibv_rec.attribute6,
              l_vibv_rec.attribute7,
              l_vibv_rec.attribute8,
              l_vibv_rec.attribute9,
              l_vibv_rec.attribute10,
              l_vibv_rec.attribute11,
              l_vibv_rec.attribute12,
              l_vibv_rec.attribute13,
              l_vibv_rec.attribute14,
              l_vibv_rec.attribute15,
              l_vibv_rec.created_by,
              l_vibv_rec.creation_date,
              l_vibv_rec.last_updated_by,
              l_vibv_rec.last_update_date,
              l_vibv_rec.last_update_login,
	      --Added by dpsingh for LE uptake
              l_vibv_rec.legal_entity_id;
    x_no_data_found := okl_contract_ib_hv_pk_csr%NOTFOUND;
    CLOSE okl_contract_ib_hv_pk_csr;
    RETURN(l_vibv_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vibv_rec                     IN vibv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN vibv_rec_type IS
    l_vibv_rec                     vibv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status       VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_vibv_rec := get_rec(p_vibv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status:= l_return_status;
    RETURN(l_vibv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vibv_rec                     IN vibv_rec_type
  ) RETURN vibv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vibv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CONTRACT_IB_H
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_vib_rec                      IN vib_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN vib_rec_type IS
    CURSOR okl_contract_ib_h_pk_csr(p_id IN NUMBER) IS
    SELECT  ID,
            MAJOR_VERSION,
            OBJECT_VERSION_NUMBER,
            DNZ_CHR_ID,
            IB_CLE_ID,
            NAME,
            DESCRIPTION,
            INVENTORY_ITEM_ID,
            CURRENT_SERIAL_NUMBER,
            INSTALL_SITE_USE_ID,
            QUANTITY,
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
      FROM Okl_Contract_Ib_H
      WHERE Okl_Contract_Ib_H.ID = p_id;

     l_vib_rec                     vib_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_contract_ib_h_pk_csr (p_vib_rec.id);
    FETCH okl_contract_ib_h_pk_csr INTO
              l_vib_rec.id,
              l_vib_rec.major_version,
              l_vib_rec.object_version_number,
              l_vib_rec.dnz_chr_id,
              l_vib_rec.ib_cle_id,
              l_vib_rec.name,
              l_vib_rec.description,
              l_vib_rec.inventory_item_id,
              l_vib_rec.current_serial_number,
              l_vib_rec.install_site_use_id,
              l_vib_rec.quantity,
              l_vib_rec.attribute_category,
              l_vib_rec.attribute1,
              l_vib_rec.attribute2,
              l_vib_rec.attribute3,
              l_vib_rec.attribute4,
              l_vib_rec.attribute5,
              l_vib_rec.attribute6,
              l_vib_rec.attribute7,
              l_vib_rec.attribute8,
              l_vib_rec.attribute9,
              l_vib_rec.attribute10,
              l_vib_rec.attribute11,
              l_vib_rec.attribute12,
              l_vib_rec.attribute13,
              l_vib_rec.attribute14,
              l_vib_rec.attribute15,
              l_vib_rec.created_by,
              l_vib_rec.creation_date,
              l_vib_rec.last_updated_by,
              l_vib_rec.last_update_date,
              l_vib_rec.last_update_login,
	      --Added by dpsingh for LE uptake
              l_vib_rec.legal_entity_id;
    x_no_data_found := okl_contract_ib_h_pk_csr%NOTFOUND;
    CLOSE okl_contract_ib_h_pk_csr;
    RETURN(l_vib_rec);
  END get_rec;
  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_vib_rec                     IN vib_rec_type,
    x_return_status               OUT NOCOPY VARCHAR2
  ) RETURN vib_rec_type IS
    l_vib_rec                      vib_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status       VARCHAR2(3) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    l_vib_rec := get_rec(p_vib_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status:= l_return_status;
    RETURN(l_vib_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_vib_rec                     IN vib_rec_type
  ) RETURN vib_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_vib_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CONTRACT_IB_HV
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_vibv_rec   IN vibv_rec_type
  ) RETURN vibv_rec_type IS
    l_vibv_rec                     vibv_rec_type := p_vibv_rec;
  BEGIN
    IF (l_vibv_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.id := NULL;
    END IF;
    IF (l_vibv_rec.major_version = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.major_version := NULL;
    END IF;
    IF (l_vibv_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.object_version_number := NULL;
    END IF;
    IF (l_vibv_rec.dnz_chr_id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_vibv_rec.ib_cle_id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.ib_cle_id := NULL;
    END IF;
    IF (l_vibv_rec.name = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.name := NULL;
    END IF;
    IF (l_vibv_rec.description = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.description := NULL;
    END IF;
    IF (l_vibv_rec.inventory_item_id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.inventory_item_id := NULL;
    END IF;
    IF (l_vibv_rec.current_serial_number = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.current_serial_number := NULL;
    END IF;
    IF (l_vibv_rec.install_site_use_id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.install_site_use_id := NULL;
    END IF;
    IF (l_vibv_rec.quantity = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.quantity := NULL;
    END IF;
    IF (l_vibv_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute_category := NULL;
    END IF;
    IF (l_vibv_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute1 := NULL;
    END IF;
    IF (l_vibv_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute2 := NULL;
    END IF;
    IF (l_vibv_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute3 := NULL;
    END IF;
    IF (l_vibv_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute4 := NULL;
    END IF;
    IF (l_vibv_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute5 := NULL;
    END IF;
    IF (l_vibv_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute6 := NULL;
    END IF;
    IF (l_vibv_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute7 := NULL;
    END IF;
    IF (l_vibv_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute8 := NULL;
    END IF;
    IF (l_vibv_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute9 := NULL;
    END IF;
    IF (l_vibv_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute10 := NULL;
    END IF;
    IF (l_vibv_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute11 := NULL;
    END IF;
    IF (l_vibv_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute12 := NULL;
    END IF;
    IF (l_vibv_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute13 := NULL;
    END IF;
    IF (l_vibv_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute14 := NULL;
    END IF;
    IF (l_vibv_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_vibv_rec.attribute15 := NULL;
    END IF;
    IF (l_vibv_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.created_by := NULL;
    END IF;
    IF (l_vibv_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_vibv_rec.creation_date := NULL;
    END IF;
    IF (l_vibv_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.last_updated_by := NULL;
    END IF;
    IF (l_vibv_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_vibv_rec.last_update_date := NULL;
    END IF;
    IF (l_vibv_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.last_update_login := NULL;
    END IF;
     --Added by dpsingh for LE uptake
     IF (l_vibv_rec.legal_entity_id = OKL_API.G_MISS_NUM ) THEN
      l_vibv_rec.legal_entity_id := NULL;
    END IF;
    RETURN(l_vibv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_CONTRACT_IB_HV --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_vibv_rec                     IN vibv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    OKC_UTIL.ADD_VIEW('OKL_CONTRACT_IB_HV', x_return_status);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    IF p_vibv_rec.id = OKL_API.G_MISS_NUM OR
       p_vibv_rec.id IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_vibv_rec.major_version = OKL_API.G_MISS_NUM OR
       p_vibv_rec.major_version IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'major_version');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    ELSIF p_vibv_rec.object_version_number = OKL_API.G_MISS_NUM OR
       p_vibv_rec.object_version_number IS NULL THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKL_API.G_RET_STS_ERROR;
      IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
        l_return_status := x_return_status;
      END IF;
    END IF;
--*******************************Hand Code ***********************************--
    validate_dnz_chr_id(x_return_status, p_vibv_rec.dnz_chr_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;
    validate_ib_cle_id(x_return_status, p_vibv_rec.ib_cle_id);
    IF (x_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
    END IF;

    --Added by dpsingh

-- Validate_LE_Id
     Validate_LE_Id(p_vibv_rec.legal_entity_id,x_return_status);
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
  --------------------------------------------
  -- Validate Record for:OKL_CONTRACT_IB_HV --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_vibv_rec IN vibv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN vibv_rec_type,
    p_to   IN OUT NOCOPY vib_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.major_version := p_from.major_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.ib_cle_id := p_from.ib_cle_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.inventory_item_id := p_from.inventory_item_id;
    p_to.current_serial_number := p_from.current_serial_number;
    p_to.install_site_use_id := p_from.install_site_use_id;
    p_to.quantity := p_from.quantity;
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
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN vib_rec_type,
    p_to   IN OUT NOCOPY vibv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.major_version := p_from.major_version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.ib_cle_id := p_from.ib_cle_id;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.inventory_item_id := p_from.inventory_item_id;
    p_to.current_serial_number := p_from.current_serial_number;
    p_to.install_site_use_id := p_from.install_site_use_id;
    p_to.quantity := p_from.quantity;
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
  -----------------------------------------
  -- validate_row for:OKL_CONTRACT_IB_HV --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vibv_rec                     vibv_rec_type := p_vibv_rec;
    l_vib_rec                      vib_rec_type;
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
    l_return_status := Validate_Attributes(l_vibv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_vibv_rec);
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
  ----------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_CONTRACT_IB_HV --
  ----------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vibv_tbl.COUNT > 0) THEN
      i := p_vibv_tbl.FIRST;
      LOOP
        validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vibv_rec                     => p_vibv_tbl(i));
        EXIT WHEN (i = p_vibv_tbl.LAST);
        i := p_vibv_tbl.NEXT(i);
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
  ---------------------------------------
  -- insert_row for:OKL_CONTRACT_IB_HV --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vib_rec                      IN vib_rec_type,
    x_vib_rec                      OUT NOCOPY vib_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vib_rec                      vib_rec_type := p_vib_rec;
    l_def_vib_rec                  vib_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_IB_HV --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_vib_rec IN vib_rec_type,
      x_vib_rec OUT NOCOPY vib_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vib_rec := p_vib_rec;
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
      p_vib_rec,                        -- IN
      l_vib_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CONTRACT_IB_H(
      id,
      major_version,
      object_version_number,
      dnz_chr_id,
      ib_cle_id,
      name,
      description,
      inventory_item_id,
      current_serial_number,
      install_site_use_id,
      quantity,
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
      l_vib_rec.id,
      l_vib_rec.major_version,
      l_vib_rec.object_version_number,
      l_vib_rec.dnz_chr_id,
      l_vib_rec.ib_cle_id,
      l_vib_rec.name,
      l_vib_rec.description,
      l_vib_rec.inventory_item_id,
      l_vib_rec.current_serial_number,
      l_vib_rec.install_site_use_id,
      l_vib_rec.quantity,
      l_vib_rec.attribute_category,
      l_vib_rec.attribute1,
      l_vib_rec.attribute2,
      l_vib_rec.attribute3,
      l_vib_rec.attribute4,
      l_vib_rec.attribute5,
      l_vib_rec.attribute6,
      l_vib_rec.attribute7,
      l_vib_rec.attribute8,
      l_vib_rec.attribute9,
      l_vib_rec.attribute10,
      l_vib_rec.attribute11,
      l_vib_rec.attribute12,
      l_vib_rec.attribute13,
      l_vib_rec.attribute14,
      l_vib_rec.attribute15,
      l_vib_rec.created_by,
      l_vib_rec.creation_date,
      l_vib_rec.last_updated_by,
      l_vib_rec.last_update_date,
      l_vib_rec.last_update_login,

     --Added by dpsingh for LE uptake
      l_vib_rec.legal_entity_id);
    -- Set OUT values
    x_vib_rec := l_vib_rec;
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
  -- insert_row for :OKL_CONTRACT_IB_HV --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type,
    x_vibv_rec                     OUT NOCOPY vibv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vibv_rec                     vibv_rec_type := p_vibv_rec;
    l_def_vibv_rec                 vibv_rec_type;
    l_vib_rec                      vib_rec_type;
    lx_vib_rec                     vib_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vibv_rec IN vibv_rec_type
    ) RETURN vibv_rec_type IS
      l_vibv_rec vibv_rec_type := p_vibv_rec;
    BEGIN
      l_vibv_rec.CREATION_DATE := SYSDATE;
      l_vibv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_vibv_rec.LAST_UPDATE_DATE := l_vibv_rec.CREATION_DATE;
      l_vibv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vibv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vibv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKL_SUPP_INVOICE_DTLS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_vibv_rec IN vibv_rec_type,
      x_vibv_rec OUT NOCOPY vibv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vibv_rec := p_vibv_rec;
      x_vibv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_vibv_rec := null_out_defaults(p_vibv_rec);
    -- Set primary key value
    l_vibv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_vibv_rec,                        -- IN
      l_def_vibv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vibv_rec := fill_who_columns(l_def_vibv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vibv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vibv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vibv_rec, l_vib_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vib_rec,
      lx_vib_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vib_rec, l_def_vibv_rec);
    -- Set OUT values
    x_vibv_rec := l_def_vibv_rec;
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
  -- PL/SQL TBL insert_row for:vibV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type,
    x_vibv_tbl                     OUT NOCOPY vibv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vibv_tbl.COUNT > 0) THEN
      i := p_vibv_tbl.FIRST;
      LOOP
        insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vibv_rec                     => p_vibv_tbl(i),
            x_vibv_rec                     => x_vibv_tbl(i));
        EXIT WHEN (i = p_vibv_tbl.LAST);
        i := p_vibv_tbl.NEXT(i);
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
  -------------------------------------
  -- lock_row for:OKL_CONTRACT_IB_HV --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vib_rec                      IN vib_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_vib_rec IN vib_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CONTRACT_IB_H
    WHERE OBJECT_VERSION_NUMBER = p_vib_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_vib_rec IN vib_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
    FROM OKL_CONTRACT_IB_H
    WHERE ID = p_vib_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_CONTRACT_IB_H.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_CONTRACT_IB_H.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_vib_rec);
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
      OPEN lchk_csr(p_vib_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_vib_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_vib_rec.object_version_number THEN
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
  --------------------------------------
  -- lock_row for: OKL_CONTRACT_IB_HV --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vibv_rec                     vibv_rec_type;
    l_vib_rec                      vib_rec_type;
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
    migrate(p_vibv_rec, l_vib_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vib_rec);
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
  -- PL/SQL TBL lock_row for:VIBV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_vibv_tbl.COUNT > 0) THEN
      i := p_vibv_tbl.FIRST;
      LOOP
        lock_row(
           p_api_version   => p_api_version,
           p_init_msg_list => p_init_msg_list,
           x_return_status => x_return_status,
           x_msg_count     => x_msg_count,
           x_msg_data      => x_msg_data,
           p_vibv_rec      => p_vibv_tbl(i));
        EXIT WHEN (i = p_vibv_tbl.LAST);
        i := p_vibv_tbl.NEXT(i);
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
  ---------------------------------------
  -- update_row for:OKL_CONTRACT_IB_HV --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vib_rec                      IN vib_rec_type,
    x_vib_rec                      OUT NOCOPY vib_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vib_rec                      vib_rec_type := p_vib_rec;
    l_def_vib_rec                  vib_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vib_rec IN vib_rec_type,
      x_vib_rec OUT NOCOPY vib_rec_type
    ) RETURN VARCHAR2 IS
      l_vib_rec                      vib_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vib_rec := p_vib_rec;
      -- Get current database values
      l_vib_rec := get_rec(p_vib_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_vib_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.id := l_vib_rec.id;
        END IF;
        IF (x_vib_rec.major_version = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.major_version := l_vib_rec.major_version;
        END IF;
        IF (x_vib_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.object_version_number := l_vib_rec.object_version_number;
        END IF;
        IF (x_vib_rec.dnz_chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.dnz_chr_id := l_vib_rec.dnz_chr_id;
        END IF;
        IF (x_vib_rec.ib_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.ib_cle_id := l_vib_rec.ib_cle_id;
        END IF;
        IF (x_vib_rec.name = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.name := l_vib_rec.name;
        END IF;
        IF (x_vib_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.description := l_vib_rec.description;
        END IF;
        IF (x_vib_rec.inventory_item_id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.inventory_item_id := l_vib_rec.inventory_item_id;
        END IF;
        IF (x_vib_rec.current_serial_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.current_serial_number := l_vib_rec.current_serial_number;
        END IF;
        IF (x_vib_rec.install_site_use_id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.install_site_use_id := l_vib_rec.install_site_use_id;
        END IF;
        IF (x_vib_rec.quantity = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.quantity := l_vib_rec.quantity;
        END IF;
        IF (x_vib_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute_category := l_vib_rec.attribute_category;
        END IF;
        IF (x_vib_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute1 := l_vib_rec.attribute1;
        END IF;
        IF (x_vib_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute2 := l_vib_rec.attribute2;
        END IF;
        IF (x_vib_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute3 := l_vib_rec.attribute3;
        END IF;
        IF (x_vib_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute4 := l_vib_rec.attribute4;
        END IF;
        IF (x_vib_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute5 := l_vib_rec.attribute5;
        END IF;
        IF (x_vib_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute6 := l_vib_rec.attribute6;
        END IF;
        IF (x_vib_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute7 := l_vib_rec.attribute7;
        END IF;
        IF (x_vib_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute8 := l_vib_rec.attribute8;
        END IF;
        IF (x_vib_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute9 := l_vib_rec.attribute9;
        END IF;
        IF (x_vib_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute10 := l_vib_rec.attribute10;
        END IF;
        IF (x_vib_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute11 := l_vib_rec.attribute11;
        END IF;
        IF (x_vib_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute12 := l_vib_rec.attribute12;
        END IF;
        IF (x_vib_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute13 := l_vib_rec.attribute13;
        END IF;
        IF (x_vib_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute14 := l_vib_rec.attribute14;
        END IF;
        IF (x_vib_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_vib_rec.attribute15 := l_vib_rec.attribute15;
        END IF;
        IF (x_vib_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.created_by := l_vib_rec.created_by;
        END IF;
        IF (x_vib_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_vib_rec.creation_date := l_vib_rec.creation_date;
        END IF;
        IF (x_vib_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.last_updated_by := l_vib_rec.last_updated_by;
        END IF;
        IF (x_vib_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_vib_rec.last_update_date := l_vib_rec.last_update_date;
        END IF;
        IF (x_vib_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.last_update_login := l_vib_rec.last_update_login;
        END IF;
	--Added by dpsingh for LE uptake
	IF (x_vib_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_vib_rec.legal_entity_id := l_vib_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_IB_H --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_vib_rec IN vib_rec_type,
      x_vib_rec OUT NOCOPY vib_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vib_rec := p_vib_rec;
      x_vib_rec.OBJECT_VERSION_NUMBER := p_vib_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_vib_rec,                        -- IN
      l_vib_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vib_rec, l_def_vib_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_CONTRACT_IB_H
    SET ID = l_def_vib_rec.id,
        MAJOR_VERSION = l_def_vib_rec.major_version,
        OBJECT_VERSION_NUMBER = l_def_vib_rec.object_version_number,
        DNZ_CHR_ID = l_def_vib_rec.dnz_chr_id,
        IB_CLE_ID = l_def_vib_rec.ib_cle_id,
        NAME = l_def_vib_rec.name,
        DESCRIPTION = l_def_vib_rec.description,
        INVENTORY_ITEM_ID = l_def_vib_rec.inventory_item_id,
        CURRENT_SERIAL_NUMBER = l_def_vib_rec.current_serial_number,
        INSTALL_SITE_USE_ID = l_def_vib_rec.install_site_use_id,
        QUANTITY = l_def_vib_rec.quantity,
        ATTRIBUTE_CATEGORY = l_def_vib_rec.attribute_category,
        ATTRIBUTE1 = l_def_vib_rec.attribute1,
        ATTRIBUTE2 = l_def_vib_rec.attribute2,
        ATTRIBUTE3 = l_def_vib_rec.attribute3,
        ATTRIBUTE4 = l_def_vib_rec.attribute4,
        ATTRIBUTE5 = l_def_vib_rec.attribute5,
        ATTRIBUTE6 = l_def_vib_rec.attribute6,
        ATTRIBUTE7 = l_def_vib_rec.attribute7,
        ATTRIBUTE8 = l_def_vib_rec.attribute8,
        ATTRIBUTE9 = l_def_vib_rec.attribute9,
        ATTRIBUTE10 = l_def_vib_rec.attribute10,
        ATTRIBUTE11 = l_def_vib_rec.attribute11,
        ATTRIBUTE12 = l_def_vib_rec.attribute12,
        ATTRIBUTE13 = l_def_vib_rec.attribute13,
        ATTRIBUTE14 = l_def_vib_rec.attribute14,
        ATTRIBUTE15 = l_def_vib_rec.attribute15,
        CREATED_BY = l_def_vib_rec.created_by,
        CREATION_DATE = l_def_vib_rec.creation_date,
        LAST_UPDATED_BY = l_def_vib_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_vib_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_vib_rec.last_update_login,
	--Added by dpsingh for LE uptake
        LEGAL_ENTITY_ID  = l_def_vib_rec.legal_entity_id
    WHERE ID = l_def_vib_rec.id;
    x_vib_rec := l_vib_rec;
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
  ---------------------------------------
  -- update_row for:OKL_CONTRACT_IB_HV --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type,
    x_vibv_rec                     OUT NOCOPY vibv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vibv_rec                     vibv_rec_type := p_vibv_rec;
    l_def_vibv_rec                 vibv_rec_type;
    l_db_vibv_rec                  vibv_rec_type;
    l_vib_rec                      vib_rec_type;
    lx_vib_rec                     vib_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_vibv_rec IN vibv_rec_type
    ) RETURN vibv_rec_type IS
      l_vibv_rec vibv_rec_type := p_vibv_rec;
    BEGIN
      l_vibv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_vibv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_vibv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_vibv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_vibv_rec IN vibv_rec_type,
      x_vibv_rec OUT NOCOPY vibv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vibv_rec := p_vibv_rec;
      l_db_vibv_rec := get_rec(p_vibv_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_vibv_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.id := l_db_vibv_rec.id;
        END IF;
        IF (x_vibv_rec.major_version = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.major_version := l_db_vibv_rec.major_version;
        END IF;
        IF (x_vibv_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.object_version_number := l_db_vibv_rec.object_version_number;
        END IF;
        IF (x_vibv_rec.dnz_chr_id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.dnz_chr_id := l_db_vibv_rec.dnz_chr_id;
        END IF;
        IF (x_vibv_rec.ib_cle_id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.ib_cle_id := l_db_vibv_rec.ib_cle_id;
        END IF;
        IF (x_vibv_rec.name = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.name := l_db_vibv_rec.name;
        END IF;
        IF (x_vibv_rec.description = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.description := l_db_vibv_rec.description;
        END IF;
        IF (x_vibv_rec.inventory_item_id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.inventory_item_id := l_db_vibv_rec.inventory_item_id;
        END IF;
        IF (x_vibv_rec.current_serial_number = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.current_serial_number := l_db_vibv_rec.current_serial_number;
        END IF;
        IF (x_vibv_rec.install_site_use_id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.install_site_use_id := l_db_vibv_rec.install_site_use_id;
        END IF;
        IF (x_vibv_rec.quantity = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.quantity := l_db_vibv_rec.quantity;
        END IF;
        IF (x_vibv_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute_category := l_db_vibv_rec.attribute_category;
        END IF;
        IF (x_vibv_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute1 := l_db_vibv_rec.attribute1;
        END IF;
        IF (x_vibv_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute2 := l_db_vibv_rec.attribute2;
        END IF;
        IF (x_vibv_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute3 := l_db_vibv_rec.attribute3;
        END IF;
        IF (x_vibv_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute4 := l_db_vibv_rec.attribute4;
        END IF;
        IF (x_vibv_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute5 := l_db_vibv_rec.attribute5;
        END IF;
        IF (x_vibv_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute6 := l_db_vibv_rec.attribute6;
        END IF;
        IF (x_vibv_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute7 := l_db_vibv_rec.attribute7;
        END IF;
        IF (x_vibv_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute8 := l_db_vibv_rec.attribute8;
        END IF;
        IF (x_vibv_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute9 := l_db_vibv_rec.attribute9;
        END IF;
        IF (x_vibv_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute10 := l_db_vibv_rec.attribute10;
        END IF;
        IF (x_vibv_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute11 := l_db_vibv_rec.attribute11;
        END IF;
        IF (x_vibv_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute12 := l_db_vibv_rec.attribute12;
        END IF;
        IF (x_vibv_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute13 := l_db_vibv_rec.attribute13;
        END IF;
        IF (x_vibv_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute14 := l_db_vibv_rec.attribute14;
        END IF;
        IF (x_vibv_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_vibv_rec.attribute15 := l_db_vibv_rec.attribute15;
        END IF;
        IF (x_vibv_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.created_by := l_db_vibv_rec.created_by;
        END IF;
        IF (x_vibv_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_vibv_rec.creation_date := l_db_vibv_rec.creation_date;
        END IF;
        IF (x_vibv_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.last_updated_by := l_db_vibv_rec.last_updated_by;
        END IF;
        IF (x_vibv_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_vibv_rec.last_update_date := l_db_vibv_rec.last_update_date;
        END IF;
        IF (x_vibv_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.last_update_login := l_db_vibv_rec.last_update_login;
        END IF;
	--Added by dpsingh for LE uptake
	 IF (x_vibv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
        THEN
          x_vibv_rec.legal_entity_id := l_db_vibv_rec.legal_entity_id;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_CONTRACT_IB_HV --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_vibv_rec IN vibv_rec_type,
      x_vibv_rec OUT NOCOPY vibv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_vibv_rec := p_vibv_rec;
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
      p_vibv_rec,                        -- IN
      x_vibv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_vibv_rec, l_def_vibv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_vibv_rec := fill_who_columns(l_def_vibv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_vibv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_vibv_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_vibv_rec, l_vib_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vib_rec,
      lx_vib_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_vib_rec, l_def_vibv_rec);
    x_vibv_rec := l_def_vibv_rec;
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
  -- PL/SQL TBL update_row for:vibv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type,
    x_vibv_tbl                     OUT NOCOPY vibv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vibv_tbl.COUNT > 0) THEN
      i := p_vibv_tbl.FIRST;
      LOOP
        update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vibv_rec                     => p_vibv_tbl(i),
            x_vibv_rec                     => x_vibv_tbl(i));
        EXIT WHEN (i = p_vibv_tbl.LAST);
        i := p_vibv_tbl.NEXT(i);
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
  ---------------------------------------
  -- delete_row for:OKL_CONTRACT_IB_HV --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vib_rec                      IN vib_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vib_rec                      vib_rec_type := p_vib_rec;
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

    DELETE FROM OKL_CONTRACT_IB_H
    WHERE ID = l_vib_rec.id;
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
  ---------------------------------------
  -- delete_row for:OKL_CONTRACT_IB_HV --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_rec                     IN vibv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_vibv_rec                     vibv_rec_type := p_vibv_rec;
    l_vib_rec                     vib_rec_type;
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
    migrate(l_vibv_rec, l_vib_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_vib_rec
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
  --------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_CONTRACT_IB_HV --
  --------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_vibv_tbl                     IN vibv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_vibv_tbl.COUNT > 0) THEN
      i := p_vibv_tbl.FIRST;
      LOOP
        delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => p_init_msg_list,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_vibv_rec                     => p_vibv_tbl(i));
        EXIT WHEN (i = p_vibv_tbl.LAST);
        i := p_vibv_tbl.NEXT(i);
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
END OKL_VIB_PVT;

/
