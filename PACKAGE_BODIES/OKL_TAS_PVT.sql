--------------------------------------------------------
--  DDL for Package Body OKL_TAS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_TAS_PVT" AS
/* $Header: OKLSTASB.pls 120.6 2008/01/17 10:10:26 veramach noship $ */
-- Badrinath Kuchibholta
/************************ HAND-CODED *********************************/
  G_TABLE_TOKEN                CONSTANT VARCHAR2(200) :=  OKC_API.G_CHILD_TABLE_TOKEN;
  G_UNEXPECTED_ERROR           CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN              CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN              CONSTANT VARCHAR2(200) := 'SQLcode';
  G_EXCEPTION_HALT_VALIDATION           EXCEPTION;
  G_EXCEPTION_STOP_VALIDATION           EXCEPTION;
  G_ID2                        CONSTANT VARCHAR2(200) := '#';
  G_TSU_LOOKUP_TYPE            CONSTANT VARCHAR2(200) := 'OKL_TRANSACTION_STATUS';
  G_TAS_LOOKUP_TYPE            CONSTANT VARCHAR2(200) := 'OKL_TRANS_HEADER_TYPE';
  G_REQUIRED_VALUE             CONSTANT VARCHAR2(200) := 'OKL_REQUIRED_VALUE';
  G_INVALID_VALUE              CONSTANT VARCHAR2(200) := 'OKL_INVALID_VALUE';
  G_NO_MATCHING_RECORD         CONSTANT VARCHAR2(200)  := 'OKL_LLA_NO_MATCHING_RECORD';
-------------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_ica_id
-- Description          : FK validation with OKX_CUSTOMER_ACCOUNTS_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_ica_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_tasv_rec IN tasv_rec_type) IS
    ln_dummy            NUMBER := 0;
    CURSOR c_ica_validate(p_id number)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT ID1
                  FROM OKX_CUSTOMER_ACCOUNTS_V
                  WHERE id1  = p_id
                  AND   id2  = G_ID2);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tasv_rec.ica_id = OKC_API.G_MISS_NUM) OR
       (p_tasv_rec.ica_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_ica_validate(p_tasv_rec.ica_id);
    IF c_ica_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_ica_validate into ln_dummy;
    CLOSE c_ica_validate;
    -- Checking if we have record or not
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'ica_id');
    -- notify caller of an error
    IF c_ica_validate%ISOPEN THEN
       CLOSE c_ica_validate;
    END IF;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_ica_validate%ISOPEN THEN
       CLOSE c_ica_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_ica_id;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_tas_type
-- Description          : FK validation with FND COMMON LOOKUPS
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tas_type(x_return_status OUT NOCOPY VARCHAR2,
                              p_tasv_rec IN tasv_rec_type) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tasv_rec.tas_type = OKC_API.G_MISS_CHAR) OR
       (p_tasv_rec.tas_type IS NULL) THEN
       -- halt validation
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    l_return_status := OKC_UTIL.check_lookup_code(G_TAS_LOOKUP_TYPE,
                                                  p_tasv_rec.tas_type);
    IF l_return_status = x_return_status THEN
       x_return_status := l_return_status;
    ELSIF l_return_status <> x_return_status THEN
       -- Notify Error
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_namE     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tas_type');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tas_type');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tas_type;
----------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_tsu_code
-- Description          : FK validation with FND COMMON LOOKUPS
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_tsu_code(x_return_status OUT NOCOPY VARCHAR2,
                              p_tasv_rec IN tasv_rec_type) IS
    l_return_status  VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tasv_rec.tsu_code = OKC_API.G_MISS_CHAR) OR
       (p_tasv_rec.tsu_code IS NULL) THEN
       -- halt validation
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    l_return_status := OKC_UTIL.check_lookup_code(G_TSU_LOOKUP_TYPE,
                                                  p_tasv_rec.tsu_code);
    IF l_return_status = x_return_status THEN
       x_return_status := l_return_status;
    ELSIF l_return_status <> x_return_status THEN
       -- Notify Error
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tsu_code');
    -- Notify Error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'tsu_code');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_tsu_code;
-------------------------------------------------------------------------------
-- Start of Commnets
-- Badrinath Kuchibholta
-- Procedure Name       : Validate_try_id
-- Description          : FK validation with OKL_TRX_TYPES_V
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_try_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_tasv_rec IN tasv_rec_type) IS

    CURSOR c_try_id_validate(p_id number)
    is
    SELECT 1
    FROM DUAl
    WHERE EXISTS (SELECT id
                  FROM OKL_TRX_TYPES_B
                  WHERE id = p_id);

    ln_dummy number := 0;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tasv_rec.try_id = OKC_API.G_MISS_NUM) OR
       (p_tasv_rec.try_id IS NULL) THEN
       -- halt validation
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_try_id_validate(p_tasv_rec.try_id);
    -- If the cursor is open then it has to be closed
    IF c_try_id_validate%NOTFOUND THEN
       close c_try_id_validate;
    END IF;
    FETCH c_try_id_validate into ln_dummy;
    CLOSE c_try_id_validate;
    IF (ln_dummy = 0) then
       -- notify caller of an error
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is required
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'try_id');
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'try_id');
    -- If the cursor is open then it has to be closed
    IF c_try_id_validate%ISOPEN THEN
       close c_try_id_validate;
    END IF;
    -- notify caller of an error
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_try_id_validate%ISOPEN THEN
       close c_try_id_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_try_id;
-------------------------------------------------------------------------------------
-- Start of Commnets
-- Bug # 2697681 - 11.5.9 schema changes avsingh
-- Procedure Name       : Validate_org_id
-- Description          : FK validation with HR_OPERATING_UNITS
-- Business Rules       :
-- Parameters           : OUT Return Status, IN Rec Info
-- Version              : 1.0
-- End of Commnets

  PROCEDURE validate_org_id(x_return_status OUT NOCOPY VARCHAR2,
                            p_tasv_rec IN tasv_rec_type) IS
    ln_dummy            NUMBER := 0;
    CURSOR c_org_validate(p_id number)
    IS
    SELECT 1
    FROM DUAL
    WHERE EXISTS (SELECT Organization_id
                  FROM  HR_OPERATING_UNITS
                  WHERE Organization_id = p_id);
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- data is required
    IF (p_tasv_rec.org_id = OKC_API.G_MISS_NUM) OR
       (p_tasv_rec.org_id IS NULL) THEN
       -- halt validation as it is a optional field
       RAISE G_EXCEPTION_STOP_VALIDATION;
    END IF;
    -- Enforce Foreign Key
    OPEN  c_org_validate(p_tasv_rec.org_id);
    IF c_org_validate%NOTFOUND THEN
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    FETCH c_org_validate into ln_dummy;
    CLOSE c_org_validate;
    -- Checking if we have record or not
    IF (ln_dummy = 0) then
       -- halt validation as it has no parent record
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_STOP_VALIDATION then
    -- We are here since the field is optional
    null;
    WHEN G_EXCEPTION_HALT_VALIDATION then
    -- We are here b'cause we have no parent record
    -- store SQL error message on message stack
    OKC_API.set_message(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_NO_MATCHING_RECORD,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'org_id');
    -- notify caller of an error
    IF c_org_validate%ISOPEN THEN
       CLOSE c_org_validate;
    END IF;
    x_return_status := OKC_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- If the cursor is open then it has to be closed
    IF c_org_validate%ISOPEN THEN
       CLOSE c_org_validate;
    END IF;
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_org_id;

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
  PROCEDURE Validate_LE_Id(p_tasv_rec IN  tasv_rec_type
                            ,x_return_status OUT NOCOPY VARCHAR2)
  IS
  l_exists                       NUMBER(1);
  item_not_found_error    EXCEPTION;

  BEGIN

    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF (p_tasv_rec.legal_entity_id IS NOT NULL) AND
       (p_tasv_rec.legal_entity_id <> Okl_Api.G_MISS_NUM) THEN
           l_exists  := OKL_LEGAL_ENTITY_UTIL.check_le_id_exists(p_tasv_rec.legal_entity_id) ;
           IF (l_exists<>1) THEN
              Okc_Api.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LEGAL_ENTITY_ID');
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

/************************ HAND-CODED *********************************/
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
  -- FUNCTION get_rec for: OKL_TRX_ASSETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tas_rec                      IN tas_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tas_rec_type IS
    CURSOR okl_trx_assets_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            ICA_ID,
            TAS_TYPE,
            OBJECT_VERSION_NUMBER,
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
            TSU_CODE,
            TRY_ID,
            DATE_TRANS_OCCURRED,
            TRANS_NUMBER,
            COMMENTS,
            REQ_ASSET_ID,
            TOTAL_MATCH_AMOUNT,
--Bug # 2697681 - 11.5.9 schema change
            ORG_ID,
	    --Added by dpsingh for LE uptake
           LEGAL_ENTITY_ID
           ,TRANSACTION_DATE
      FROM Okl_Trx_Assets
     WHERE okl_trx_assets.id    = p_id;
    l_okl_trx_assets_pk            okl_trx_assets_pk_csr%ROWTYPE;
    l_tas_rec                      tas_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_assets_pk_csr (p_tas_rec.id);
    FETCH okl_trx_assets_pk_csr INTO
              l_tas_rec.ID,
              l_tas_rec.ICA_ID,
              l_tas_rec.TAS_TYPE,
              l_tas_rec.OBJECT_VERSION_NUMBER,
              l_tas_rec.ATTRIBUTE_CATEGORY,
              l_tas_rec.ATTRIBUTE1,
              l_tas_rec.ATTRIBUTE2,
              l_tas_rec.ATTRIBUTE3,
              l_tas_rec.ATTRIBUTE4,
              l_tas_rec.ATTRIBUTE5,
              l_tas_rec.ATTRIBUTE6,
              l_tas_rec.ATTRIBUTE7,
              l_tas_rec.ATTRIBUTE8,
              l_tas_rec.ATTRIBUTE9,
              l_tas_rec.ATTRIBUTE10,
              l_tas_rec.ATTRIBUTE11,
              l_tas_rec.ATTRIBUTE12,
              l_tas_rec.ATTRIBUTE13,
              l_tas_rec.ATTRIBUTE14,
              l_tas_rec.ATTRIBUTE15,
              l_tas_rec.CREATED_BY,
              l_tas_rec.CREATION_DATE,
              l_tas_rec.LAST_UPDATED_BY,
              l_tas_rec.LAST_UPDATE_DATE,
              l_tas_rec.LAST_UPDATE_LOGIN,
              l_tas_rec.TSU_CODE,
              l_tas_rec.TRY_ID,
              l_tas_rec.DATE_TRANS_OCCURRED,
              l_tas_rec.TRANS_NUMBER,
              l_tas_rec.COMMENTS,
              l_tas_rec.REQ_ASSET_ID,
              l_tas_rec.TOTAL_MATCH_AMOUNT,
--Bug # 2697681 - 11.5.9 Schema change
              l_tas_rec.ORG_ID,
	      --Added by dpsingh for LE uptake
              l_tas_rec.LEGAL_ENTITY_ID
             ,l_tas_rec.TRANSACTION_DATE;
    x_no_data_found := okl_trx_assets_pk_csr%NOTFOUND;
    CLOSE okl_trx_assets_pk_csr;
    RETURN(l_tas_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tas_rec                      IN tas_rec_type
  ) RETURN tas_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tas_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_ASSETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_tasv_rec                     IN tasv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN tasv_rec_type IS
    CURSOR okl_tasv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
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
            TOTAL_MATCH_AMOUNT,
--Bug # 2697681 : 11.5.9 schema change
            ORG_ID ,
	    --Added by dpsingh for LE uptake
            LEGAL_ENTITY_ID
           ,TRANSACTION_DATE
      FROM OKL_TRX_ASSETS
     WHERE OKL_TRX_ASSETS.id  = p_id;
    l_okl_tasv_pk                  okl_tasv_pk_csr%ROWTYPE;
    l_tasv_rec                     tasv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_tasv_pk_csr (p_tasv_rec.id);
    FETCH okl_tasv_pk_csr INTO
              l_tasv_rec.ID,
              l_tasv_rec.OBJECT_VERSION_NUMBER,
              l_tasv_rec.ICA_ID,
              l_tasv_rec.ATTRIBUTE_CATEGORY,
              l_tasv_rec.ATTRIBUTE1,
              l_tasv_rec.ATTRIBUTE2,
              l_tasv_rec.ATTRIBUTE3,
              l_tasv_rec.ATTRIBUTE4,
              l_tasv_rec.ATTRIBUTE5,
              l_tasv_rec.ATTRIBUTE6,
              l_tasv_rec.ATTRIBUTE7,
              l_tasv_rec.ATTRIBUTE8,
              l_tasv_rec.ATTRIBUTE9,
              l_tasv_rec.ATTRIBUTE10,
              l_tasv_rec.ATTRIBUTE11,
              l_tasv_rec.ATTRIBUTE12,
              l_tasv_rec.ATTRIBUTE13,
              l_tasv_rec.ATTRIBUTE14,
              l_tasv_rec.ATTRIBUTE15,
              l_tasv_rec.TAS_TYPE,
              l_tasv_rec.CREATED_BY,
              l_tasv_rec.CREATION_DATE,
              l_tasv_rec.LAST_UPDATED_BY,
              l_tasv_rec.LAST_UPDATE_DATE,
              l_tasv_rec.LAST_UPDATE_LOGIN,
              l_tasv_rec.TSU_CODE,
              l_tasv_rec.TRY_ID,
              l_tasv_rec.DATE_TRANS_OCCURRED,
              l_tasv_rec.TRANS_NUMBER,
              l_tasv_rec.COMMENTS,
              l_tasv_rec.REQ_ASSET_ID,
              l_tasv_rec.TOTAL_MATCH_AMOUNT,
--Bug#  2697681 : 11.5.9 Schema changes
              l_tasv_rec.ORG_ID,
	      --Added by dpsingh for LE uptake
              l_tasv_rec.LEGAL_ENTITY_ID
             ,l_tasv_rec.TRANSACTION_DATE;
    x_no_data_found := okl_tasv_pk_csr%NOTFOUND;
    CLOSE okl_tasv_pk_csr;
    RETURN(l_tasv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_tasv_rec                     IN tasv_rec_type
  ) RETURN tasv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_tasv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_ASSETS_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_tasv_rec  IN tasv_rec_type
  ) RETURN tasv_rec_type IS
    l_tasv_rec  tasv_rec_type := p_tasv_rec;
  BEGIN
    IF (l_tasv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.object_version_number := NULL;
    END IF;
    IF (l_tasv_rec.ica_id = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.ica_id := NULL;
    END IF;
    IF (l_tasv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute_category := NULL;
    END IF;
    IF (l_tasv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute1 := NULL;
    END IF;
    IF (l_tasv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute2 := NULL;
    END IF;
    IF (l_tasv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute3 := NULL;
    END IF;
    IF (l_tasv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute4 := NULL;
    END IF;
    IF (l_tasv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute5 := NULL;
    END IF;
    IF (l_tasv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute6 := NULL;
    END IF;
    IF (l_tasv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute7 := NULL;
    END IF;
    IF (l_tasv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute8 := NULL;
    END IF;
    IF (l_tasv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute9 := NULL;
    END IF;
    IF (l_tasv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute10 := NULL;
    END IF;
    IF (l_tasv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute11 := NULL;
    END IF;
    IF (l_tasv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute12 := NULL;
    END IF;
    IF (l_tasv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute13 := NULL;
    END IF;
    IF (l_tasv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute14 := NULL;
    END IF;
    IF (l_tasv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.attribute15 := NULL;
    END IF;
    IF (l_tasv_rec.tas_type = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.tas_type := NULL;
    END IF;
    IF (l_tasv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.created_by := NULL;
    END IF;
    IF (l_tasv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_tasv_rec.creation_date := NULL;
    END IF;
    IF (l_tasv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.last_updated_by := NULL;
    END IF;
    IF (l_tasv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_tasv_rec.last_update_date := NULL;
    END IF;
    IF (l_tasv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.last_update_login := NULL;
    END IF;
    IF (l_tasv_rec.tsu_code = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.tsu_code := NULL;
    END IF;
    IF (l_tasv_rec.try_id = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.try_id := NULL;
    END IF;
    IF (l_tasv_rec.date_trans_occurred = OKC_API.G_MISS_DATE) THEN
      l_tasv_rec.date_trans_occurred := NULL;
    END IF;
    IF (l_tasv_rec.trans_number = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.trans_number := NULL;
    END IF;
    IF (l_tasv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_tasv_rec.comments := NULL;
    END IF;
    IF (l_tasv_rec.req_asset_id = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.req_asset_id := NULL;
    END IF;
    IF (l_tasv_rec.total_match_amount = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.total_match_amount := NULL;
    END IF;
--Bug#  2697681 : 11.5.9 Schema changes
   IF (l_tasv_rec.org_id = OKC_API.G_MISS_NUM) THEN
      l_tasv_rec.org_id := NULL;
    END IF;
 --Added by dpsingh for LE uptake
  IF (l_tasv_rec.LEGAL_ENTITY_ID = OKL_API.G_MISS_NUM) THEN
      l_tasv_rec.LEGAL_ENTITY_ID := NULL;
  END IF;
  IF (l_tasv_rec.TRANSACTION_DATE = OKL_API.G_MISS_DATE) THEN
      l_tasv_rec.TRANSACTION_DATE := NULL;
  END IF;
    RETURN(l_tasv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_TRX_ASSETS_V --
  ----------------------------------------------
  FUNCTION Validate_Attributes (
    p_tasv_rec IN  tasv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_tasv_rec.id = OKC_API.G_MISS_NUM OR
       p_tasv_rec.id IS NULL THEN
       -- store SQL error message on message stack
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'id');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tasv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_tasv_rec.object_version_number IS NULL THEN
       -- store SQL error message on message stack
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'object_version_number');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_tasv_rec.date_trans_occurred = OKC_API.G_MISS_DATE OR
          p_tasv_rec.date_trans_occurred IS NULL THEN
       -- store SQL error message on message stack
       OKC_API.set_message(p_app_name     => G_APP_NAME,
                           p_msg_name     => G_REQUIRED_VALUE,
                           p_token1       => G_COL_NAME_TOKEN,
                           p_token1_value => 'date_trans_occurred');
       -- notify caller of an error
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
/************************ HAND-CODED *********************************/
    -- Calling the Validate Procedure  to validate Individual Attributes
    validate_ica_id(x_return_status => l_return_status,
                    p_tasv_rec      => p_tasv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_tas_type(x_return_status => l_return_status,
                      p_tasv_rec      => p_tasv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_tsu_code(x_return_status => l_return_status,
                      p_tasv_rec      => p_tasv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    validate_try_id(x_return_status => l_return_status,
                    p_tasv_rec      => p_tasv_rec);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
  --Added by dpsingh for LE uptake
 Validate_LE_Id(p_tasv_rec      => p_tasv_rec,
                       x_return_status => l_return_status);
    -- Store the Highest Degree of Error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
           x_return_status := l_return_status;
       END IF;
    END IF;
    l_return_status := x_return_status;
    RETURN(l_return_status);
  EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                        p_msg_name     => G_UNEXPECTED_ERROR,
                        p_token1       => G_SQLCODE_TOKEN,
                        p_token1_value => SQLCODE,
                        p_token2       => G_SQLERRM_TOKEN,
                        p_token2_value => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- Return status to caller
    RETURN(x_return_status);
  END Validate_Attributes;
/************************ HAND-CODED *********************************/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_TRX_ASSETS_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_tasv_rec IN tasv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from  IN tasv_rec_type,
    p_to  OUT NOCOPY tas_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ica_id := p_from.ica_id;
    p_to.tas_type := p_from.tas_type;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.tsu_code := p_from.tsu_code;
    p_to.try_id := p_from.try_id;
    p_to.date_trans_occurred := p_from.date_trans_occurred;
    p_to.trans_number := p_from.trans_number;
    p_to.comments := p_from.comments;
    p_to.req_asset_id := p_from.req_asset_id;
    p_to.total_match_amount := p_from.total_match_amount;
--Bug#  2697681 : 11.5.9 Schema changes
    p_to.org_id := p_from.org_id;
--Added by dpsingh for LE uptake
    p_to.LEGAL_ENTITY_ID := p_from.LEGAL_ENTITY_ID;
    p_to.TRANSACTION_DATE := p_from.TRANSACTION_DATE;
  END migrate;
  PROCEDURE migrate (
    p_from  IN tas_rec_type,
    p_to  OUT NOCOPY tasv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ica_id := p_from.ica_id;
    p_to.tas_type := p_from.tas_type;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.tsu_code := p_from.tsu_code;
    p_to.try_id := p_from.try_id;
    p_to.date_trans_occurred := p_from.date_trans_occurred;
    p_to.trans_number := p_from.trans_number;
    p_to.comments := p_from.comments;
    p_to.req_asset_id := p_from.req_asset_id;
    p_to.total_match_amount := p_from.total_match_amount;
--Bug#  2697681 : 11.5.9 Schema changes
    p_to.org_id := p_from.org_id;
    --Added by dpsingh for LE uptake
    p_to.LEGAL_ENTITY_ID := p_from.LEGAL_ENTITY_ID;
    p_to.TRANSACTION_DATE := p_from.TRANSACTION_DATE;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- validate_row for:OKL_TRX_ASSETS_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tasv_rec                     tasv_rec_type := p_tasv_rec;
    l_tas_rec                      tas_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_tasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_tasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------
  -- PL/SQL TBL validate_row for:TASV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tasv_tbl.COUNT > 0) THEN
      i := p_tasv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tasv_rec                     => p_tasv_tbl(i));
        EXIT WHEN (i = p_tasv_tbl.LAST);
        i := p_tasv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- insert_row for:OKL_TRX_ASSETS --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tas_rec                      IN tas_rec_type,
    x_tas_rec                      OUT NOCOPY tas_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tas_rec                      tas_rec_type := p_tas_rec;
    l_def_tas_rec                  tas_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_TRX_ASSETS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_tas_rec IN  tas_rec_type,
      x_tas_rec OUT NOCOPY tas_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tas_rec := p_tas_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tas_rec,                         -- IN
      l_tas_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_ASSETS(
        id,
        ica_id,
        tas_type,
        object_version_number,
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
        tsu_code,
        try_id,
        date_trans_occurred,
        trans_number,
        comments,
        req_asset_id,
        total_match_amount,
--Bug#  2697681 : 11.5.9 Schema changes
        org_id,
	--Added by dpsingh for LE uptake
        legal_entity_id
        ,transaction_date)
      VALUES (
        l_tas_rec.id,
        l_tas_rec.ica_id,
        l_tas_rec.tas_type,
        l_tas_rec.object_version_number,
        l_tas_rec.attribute_category,
        l_tas_rec.attribute1,
        l_tas_rec.attribute2,
        l_tas_rec.attribute3,
        l_tas_rec.attribute4,
        l_tas_rec.attribute5,
        l_tas_rec.attribute6,
        l_tas_rec.attribute7,
        l_tas_rec.attribute8,
        l_tas_rec.attribute9,
        l_tas_rec.attribute10,
        l_tas_rec.attribute11,
        l_tas_rec.attribute12,
        l_tas_rec.attribute13,
        l_tas_rec.attribute14,
        l_tas_rec.attribute15,
        l_tas_rec.created_by,
        l_tas_rec.creation_date,
        l_tas_rec.last_updated_by,
        l_tas_rec.last_update_date,
        l_tas_rec.last_update_login,
        l_tas_rec.tsu_code,
        l_tas_rec.try_id,
        l_tas_rec.date_trans_occurred,
        l_tas_rec.trans_number,
        l_tas_rec.comments,
        l_tas_rec.req_asset_id,
        l_tas_rec.total_match_amount,
--Bug#  2697681 : 11.5.9 Schema changes
        l_tas_rec.org_id,
	--Added by dpsingh for LE uptake
        l_tas_rec.legal_entity_id
        ,NVL(l_tas_rec.transaction_date,SYSDATE));
    -- Set OUT values
    x_tas_rec := l_tas_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -------------------------------------
  -- insert_row for:OKL_TRX_ASSETS_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type,
    x_tasv_rec                     OUT NOCOPY tasv_rec_type) IS


    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tasv_rec                     tasv_rec_type;
    l_def_tasv_rec                 tasv_rec_type;
    l_tas_rec                      tas_rec_type;
    lx_tas_rec                     tas_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tasv_rec  IN tasv_rec_type
    ) RETURN tasv_rec_type IS
      l_tasv_rec  tasv_rec_type := p_tasv_rec;
    BEGIN
      l_tasv_rec.CREATION_DATE := SYSDATE;
      l_tasv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_tasv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tasv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tasv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tasv_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tasv_rec IN  tasv_rec_type,
      x_tasv_rec OUT NOCOPY tasv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      CURSOR c_get_trans_number
      IS
      SELECT OKL_TRN_SEQ.NEXTVAL
      FROM dual;
    BEGIN
      x_tasv_rec := p_tasv_rec;
      x_tasv_rec.OBJECT_VERSION_NUMBER := 1;
      -- Bug no 2627151 change start
      IF (p_tasv_rec.trans_number IS NULL OR
         p_tasv_rec.trans_number = OKL_API.G_MISS_NUM) THEN
         OPEN  c_get_trans_number;
         FETCH c_get_trans_number INTO x_tasv_rec.trans_number;
         CLOSE c_get_trans_number;
      END IF;
      -- Bug no 2627151 change end
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_tasv_rec := null_out_defaults(p_tasv_rec);
    -- Set primary key value
    l_tasv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_tasv_rec,                        -- IN
      l_def_tasv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tasv_rec := fill_who_columns(l_def_tasv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tasv_rec, l_tas_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tas_rec,
      lx_tas_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tas_rec, l_def_tasv_rec);
    -- Set OUT values
    x_tasv_rec := l_def_tasv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:TASV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tasv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tasv_tbl.COUNT > 0) THEN
      i := p_tasv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tasv_rec                     => p_tasv_tbl(i),
          x_tasv_rec                     => x_tasv_tbl(i));
        EXIT WHEN (i = p_tasv_tbl.LAST);
        i := p_tasv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------
  -- lock_row for:OKL_TRX_ASSETS --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tas_rec                      IN tas_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_tas_rec IN tas_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_ASSETS
     WHERE ID = p_tas_rec.id
       AND OBJECT_VERSION_NUMBER = p_tas_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tas_rec IN tas_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_ASSETS
    WHERE ID = p_tas_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_TRX_ASSETS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_TRX_ASSETS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_tas_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_tas_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_tas_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_tas_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  -----------------------------------
  -- lock_row for:OKL_TRX_ASSETS_V --
  -----------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tas_rec                      tas_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_tasv_rec, l_tas_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tas_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:TASV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tasv_tbl.COUNT > 0) THEN
      i := p_tasv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tasv_rec                     => p_tasv_tbl(i));
        EXIT WHEN (i = p_tasv_tbl.LAST);
        i := p_tasv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- update_row for:OKL_TRX_ASSETS --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tas_rec                      IN tas_rec_type,
    x_tas_rec                      OUT NOCOPY tas_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tas_rec                      tas_rec_type := p_tas_rec;
    l_def_tas_rec                  tas_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tas_rec IN tas_rec_type,
      x_tas_rec OUT NOCOPY tas_rec_type
    ) RETURN VARCHAR2 IS
      l_tas_rec                      tas_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tas_rec := p_tas_rec;
      -- Get current database values
      l_tas_rec := get_rec(p_tas_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tas_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.id := l_tas_rec.id;
      END IF;
      IF (x_tas_rec.ica_id = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.ica_id := l_tas_rec.ica_id;
      END IF;
      IF (x_tas_rec.tas_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.tas_type := l_tas_rec.tas_type;
      END IF;
      IF (x_tas_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.object_version_number := l_tas_rec.object_version_number;
      END IF;
      IF (x_tas_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute_category := l_tas_rec.attribute_category;
      END IF;
      IF (x_tas_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute1 := l_tas_rec.attribute1;
      END IF;
      IF (x_tas_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute2 := l_tas_rec.attribute2;
      END IF;
      IF (x_tas_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute3 := l_tas_rec.attribute3;
      END IF;
      IF (x_tas_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute4 := l_tas_rec.attribute4;
      END IF;
      IF (x_tas_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute5 := l_tas_rec.attribute5;
      END IF;
      IF (x_tas_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute6 := l_tas_rec.attribute6;
      END IF;
      IF (x_tas_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute7 := l_tas_rec.attribute7;
      END IF;
      IF (x_tas_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute8 := l_tas_rec.attribute8;
      END IF;
      IF (x_tas_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute9 := l_tas_rec.attribute9;
      END IF;
      IF (x_tas_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute10 := l_tas_rec.attribute10;
      END IF;
      IF (x_tas_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute11 := l_tas_rec.attribute11;
      END IF;
      IF (x_tas_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute12 := l_tas_rec.attribute12;
      END IF;
      IF (x_tas_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute13 := l_tas_rec.attribute13;
      END IF;
      IF (x_tas_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute14 := l_tas_rec.attribute14;
      END IF;
      IF (x_tas_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.attribute15 := l_tas_rec.attribute15;
      END IF;
      IF (x_tas_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.created_by := l_tas_rec.created_by;
      END IF;
      IF (x_tas_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tas_rec.creation_date := l_tas_rec.creation_date;
      END IF;
      IF (x_tas_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.last_updated_by := l_tas_rec.last_updated_by;
      END IF;
      IF (x_tas_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tas_rec.last_update_date := l_tas_rec.last_update_date;
      END IF;
      IF (x_tas_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.last_update_login := l_tas_rec.last_update_login;
      END IF;
      IF (x_tas_rec.tsu_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.tsu_code := l_tas_rec.tsu_code;
      END IF;
      IF (x_tas_rec.try_id = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.try_id := l_tas_rec.try_id;
      END IF;
      IF (x_tas_rec.date_trans_occurred = OKC_API.G_MISS_DATE)
      THEN
        x_tas_rec.date_trans_occurred := l_tas_rec.date_trans_occurred;
      END IF;
      IF (x_tas_rec.trans_number = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.trans_number := l_tas_rec.trans_number;
      END IF;
      IF (x_tas_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tas_rec.comments := l_tas_rec.comments;
      END IF;
      IF (x_tas_rec.req_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.req_asset_id := l_tas_rec.req_asset_id;
      END IF;
      IF (x_tas_rec.total_match_amount = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.total_match_amount := l_tas_rec.total_match_amount;
      END IF;
--Bug#  2697681 : 11.5.9 Schema changes
      IF (x_tas_rec.org_id = OKC_API.G_MISS_NUM)
      THEN
        x_tas_rec.org_id := l_tas_rec.org_id;
      END IF;
      -- Added by dpsingh for LE uptake
       IF (x_tas_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_tas_rec.legal_entity_id := l_tas_rec.legal_entity_id;
      END IF;
       IF (x_tas_rec.transaction_date = OKL_API.G_MISS_DATE)
      THEN
        x_tas_rec.transaction_date := SYSDATE;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_TRX_ASSETS --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_tas_rec IN  tas_rec_type,
      x_tas_rec OUT NOCOPY tas_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tas_rec := p_tas_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tas_rec,                         -- IN
      l_tas_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tas_rec, l_def_tas_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_TRX_ASSETS
    SET ICA_ID = l_def_tas_rec.ica_id,
        TAS_TYPE = l_def_tas_rec.tas_type,
        OBJECT_VERSION_NUMBER = l_def_tas_rec.object_version_number,
        ATTRIBUTE_CATEGORY = l_def_tas_rec.attribute_category,
        ATTRIBUTE1 = l_def_tas_rec.attribute1,
        ATTRIBUTE2 = l_def_tas_rec.attribute2,
        ATTRIBUTE3 = l_def_tas_rec.attribute3,
        ATTRIBUTE4 = l_def_tas_rec.attribute4,
        ATTRIBUTE5 = l_def_tas_rec.attribute5,
        ATTRIBUTE6 = l_def_tas_rec.attribute6,
        ATTRIBUTE7 = l_def_tas_rec.attribute7,
        ATTRIBUTE8 = l_def_tas_rec.attribute8,
        ATTRIBUTE9 = l_def_tas_rec.attribute9,
        ATTRIBUTE10 = l_def_tas_rec.attribute10,
        ATTRIBUTE11 = l_def_tas_rec.attribute11,
        ATTRIBUTE12 = l_def_tas_rec.attribute12,
        ATTRIBUTE13 = l_def_tas_rec.attribute13,
        ATTRIBUTE14 = l_def_tas_rec.attribute14,
        ATTRIBUTE15 = l_def_tas_rec.attribute15,
        CREATED_BY = l_def_tas_rec.created_by,
        CREATION_DATE = l_def_tas_rec.creation_date,
        LAST_UPDATED_BY = l_def_tas_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_tas_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_tas_rec.last_update_login,
        TSU_CODE = l_def_tas_rec.tsu_code,
        TRY_ID = l_def_tas_rec.try_id,
        DATE_TRANS_OCCURRED = l_def_tas_rec.date_trans_occurred,
        TRANS_NUMBER = l_def_tas_rec.trans_number,
        COMMENTS = l_def_tas_rec.comments,
        REQ_ASSET_ID = l_def_tas_rec.req_asset_id,
        TOTAL_MATCH_AMOUNT = l_def_tas_rec.total_match_amount,
--Bug#  2697681 : 11.5.9 Schema changes
        ORG_ID = l_def_tas_rec.org_id ,
	--Added by dpsingh for LE uptake
        LEGAL_ENTITY_ID = l_def_tas_rec.legal_entity_id
        ,TRANSACTION_DATE = l_def_tas_rec.transaction_date
     WHERE ID = l_def_tas_rec.id;

    x_tas_rec := l_def_tas_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -------------------------------------
  -- update_row for:OKL_TRX_ASSETS_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type,
    x_tasv_rec                     OUT NOCOPY tasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tasv_rec                     tasv_rec_type := p_tasv_rec;
    l_def_tasv_rec                 tasv_rec_type;
    l_tas_rec                      tas_rec_type;
    lx_tas_rec                     tas_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_tasv_rec  IN tasv_rec_type
    ) RETURN tasv_rec_type IS
      l_tasv_rec  tasv_rec_type := p_tasv_rec;
    BEGIN
      l_tasv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_tasv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_tasv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_tasv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_tasv_rec  IN tasv_rec_type,
      x_tasv_rec  OUT NOCOPY tasv_rec_type
    ) RETURN VARCHAR2 IS
      l_tasv_rec                     tasv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tasv_rec := p_tasv_rec;
      -- Get current database values
      l_tasv_rec := get_rec(p_tasv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_tasv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.id := l_tasv_rec.id;
      END IF;
      IF (x_tasv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.object_version_number := l_tasv_rec.object_version_number;
      END IF;
      IF (x_tasv_rec.ica_id = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.ica_id := l_tasv_rec.ica_id;
      END IF;
      IF (x_tasv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute_category := l_tasv_rec.attribute_category;
      END IF;
      IF (x_tasv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute1 := l_tasv_rec.attribute1;
      END IF;
      IF (x_tasv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute2 := l_tasv_rec.attribute2;
      END IF;
      IF (x_tasv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute3 := l_tasv_rec.attribute3;
      END IF;
      IF (x_tasv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute4 := l_tasv_rec.attribute4;
      END IF;
      IF (x_tasv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute5 := l_tasv_rec.attribute5;
      END IF;
      IF (x_tasv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute6 := l_tasv_rec.attribute6;
      END IF;
      IF (x_tasv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute7 := l_tasv_rec.attribute7;
      END IF;
      IF (x_tasv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute8 := l_tasv_rec.attribute8;
      END IF;
      IF (x_tasv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute9 := l_tasv_rec.attribute9;
      END IF;
      IF (x_tasv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute10 := l_tasv_rec.attribute10;
      END IF;
      IF (x_tasv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute11 := l_tasv_rec.attribute11;
      END IF;
      IF (x_tasv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute12 := l_tasv_rec.attribute12;
      END IF;
      IF (x_tasv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute13 := l_tasv_rec.attribute13;
      END IF;
      IF (x_tasv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute14 := l_tasv_rec.attribute14;
      END IF;
      IF (x_tasv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.attribute15 := l_tasv_rec.attribute15;
      END IF;
      IF (x_tasv_rec.tas_type = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.tas_type := l_tasv_rec.tas_type;
      END IF;
      IF (x_tasv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.created_by := l_tasv_rec.created_by;
      END IF;
      IF (x_tasv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_tasv_rec.creation_date := l_tasv_rec.creation_date;
      END IF;
      IF (x_tasv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.last_updated_by := l_tasv_rec.last_updated_by;
      END IF;
      IF (x_tasv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_tasv_rec.last_update_date := l_tasv_rec.last_update_date;
      END IF;
      IF (x_tasv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.last_update_login := l_tasv_rec.last_update_login;
      END IF;
      IF (x_tasv_rec.tsu_code = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.tsu_code := l_tasv_rec.tsu_code;
      END IF;
      IF (x_tasv_rec.try_id = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.try_id := l_tasv_rec.try_id;
      END IF;
      IF (x_tasv_rec.date_trans_occurred = OKC_API.G_MISS_DATE)
      THEN
        x_tasv_rec.date_trans_occurred := l_tasv_rec.date_trans_occurred;
      END IF;
      IF (x_tasv_rec.trans_number = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.trans_number := l_tasv_rec.trans_number;
      END IF;
      IF (x_tasv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_tasv_rec.comments := l_tasv_rec.comments;
      END IF;
      IF (x_tasv_rec.req_asset_id = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.req_asset_id := l_tasv_rec.req_asset_id;
      END IF;
      IF (x_tasv_rec.total_match_amount = OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.total_match_amount := l_tasv_rec.total_match_amount;
      END IF;
--Bug#  2697681 : 11.5.9 Schema changes
      IF (x_tasv_rec.org_id= OKC_API.G_MISS_NUM)
      THEN
        x_tasv_rec.org_id := l_tasv_rec.org_id;
      END IF;
     --Added by dpsingh for LE uptake
      IF (x_tasv_rec.legal_entity_id = OKL_API.G_MISS_NUM)
      THEN
        x_tasv_rec.legal_entity_id := l_tasv_rec.legal_entity_id;
      END IF;
      IF (x_tasv_rec.transaction_date = OKL_API.G_MISS_DATE)
      THEN
        x_tasv_rec.transaction_date := l_tasv_rec.transaction_date;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_TRX_ASSETS_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_tasv_rec IN  tasv_rec_type,
      x_tasv_rec OUT NOCOPY tasv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_tasv_rec := p_tasv_rec;
      x_tasv_rec.OBJECT_VERSION_NUMBER := NVL(x_tasv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_tasv_rec,                        -- IN
      l_tasv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_tasv_rec, l_def_tasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_tasv_rec := fill_who_columns(l_def_tasv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_tasv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_tasv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_tasv_rec, l_tas_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tas_rec,
      lx_tas_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_tas_rec, l_def_tasv_rec);
    x_tasv_rec := l_def_tasv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:TASV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type,
    x_tasv_tbl                     OUT NOCOPY tasv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tasv_tbl.COUNT > 0) THEN
      i := p_tasv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tasv_rec                     => p_tasv_tbl(i),
          x_tasv_rec                     => x_tasv_tbl(i));
        EXIT WHEN (i = p_tasv_tbl.LAST);
        i := p_tasv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
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
  -----------------------------------
  -- delete_row for:OKL_TRX_ASSETS --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tas_rec                      IN tas_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSETS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tas_rec                      tas_rec_type:= p_tas_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_TRX_ASSETS
     WHERE ID = l_tas_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -------------------------------------
  -- delete_row for:OKL_TRX_ASSETS_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_rec                     IN tasv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tasv_rec                     tasv_rec_type := p_tasv_rec;
    l_tas_rec                      tas_rec_type;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_tasv_rec, l_tas_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_tas_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------
  -- PL/SQL TBL delete_row for:TASV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tasv_tbl                     IN tasv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_tasv_tbl.COUNT > 0) THEN
      i := p_tasv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_tasv_rec                     => p_tasv_tbl(i));
        EXIT WHEN (i = p_tasv_tbl.LAST);
        i := p_tasv_tbl.NEXT(i);
      END LOOP;
    END IF;
  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
END OKL_TAS_PVT;

/
