--------------------------------------------------------
--  DDL for Package Body OKL_PDT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_PDT_PVT" AS
/* $Header: OKLSPDTB.pls 120.2 2005/10/30 04:43:09 appldev noship $ */
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
    NULL;
  END qc;

  ---------------------------------------------------------------------------
  -- PROCEDURE change_version
  ---------------------------------------------------------------------------
  PROCEDURE change_version IS
  BEGIN
    NULL;
  END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE api_copy
  ---------------------------------------------------------------------------
  PROCEDURE api_copy IS
  BEGIN
    NULL;
  END api_copy;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRODUCTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdt_rec                      IN pdt_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdt_rec_type IS
    CURSOR okl_products_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            NAME,
            AES_ID,
            PTL_ID,
            LEGACY_PRODUCT_YN,
            VERSION,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            REPORTING_PDT_ID,
            FROM_DATE,
            TO_DATE,
            product_status_code,
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
      FROM Okl_Products
     WHERE okl_products.id      = p_id;
    l_okl_products_pk              okl_products_pk_csr%ROWTYPE;
    l_pdt_rec                      pdt_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_products_pk_csr (p_pdt_rec.id);
    FETCH okl_products_pk_csr INTO
              l_pdt_rec.ID,
              l_pdt_rec.NAME,
              l_pdt_rec.AES_ID,
              l_pdt_rec.PTL_ID,
              l_pdt_rec.LEGACY_PRODUCT_YN,
              l_pdt_rec.VERSION,
              l_pdt_rec.OBJECT_VERSION_NUMBER,
              l_pdt_rec.DESCRIPTION,
              l_pdt_rec.REPORTING_PDT_ID,
              l_pdt_rec.FROM_DATE,
              l_pdt_rec.TO_DATE,
              l_pdt_rec.product_status_code,
              l_pdt_rec.ATTRIBUTE_CATEGORY,
              l_pdt_rec.ATTRIBUTE1,
              l_pdt_rec.ATTRIBUTE2,
              l_pdt_rec.ATTRIBUTE3,
              l_pdt_rec.ATTRIBUTE4,
              l_pdt_rec.ATTRIBUTE5,
              l_pdt_rec.ATTRIBUTE6,
              l_pdt_rec.ATTRIBUTE7,
              l_pdt_rec.ATTRIBUTE8,
              l_pdt_rec.ATTRIBUTE9,
              l_pdt_rec.ATTRIBUTE10,
              l_pdt_rec.ATTRIBUTE11,
              l_pdt_rec.ATTRIBUTE12,
              l_pdt_rec.ATTRIBUTE13,
              l_pdt_rec.ATTRIBUTE14,
              l_pdt_rec.ATTRIBUTE15,
              l_pdt_rec.CREATED_BY,
              l_pdt_rec.CREATION_DATE,
              l_pdt_rec.LAST_UPDATED_BY,
              l_pdt_rec.LAST_UPDATE_DATE,
              l_pdt_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_products_pk_csr%NOTFOUND;
    CLOSE okl_products_pk_csr;
    RETURN(l_pdt_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdt_rec                      IN pdt_rec_type
  ) RETURN pdt_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdt_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PRODUCTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pdtv_rec                     IN pdtv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pdtv_rec_type IS
    CURSOR okl_pdtv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            AES_ID,
            PTL_ID,
            NAME,
            DESCRIPTION,
            REPORTING_PDT_ID,
            LEGACY_PRODUCT_YN,
            FROM_DATE,
            VERSION,
            TO_DATE,
            ATTRIBUTE_CATEGORY,
            product_status_code,
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
      FROM Okl_Products_V
     WHERE okl_products_v.id    = p_id;
    l_okl_pdtv_pk                  okl_pdtv_pk_csr%ROWTYPE;
    l_pdtv_rec                     pdtv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdtv_pk_csr (p_pdtv_rec.id);
    FETCH okl_pdtv_pk_csr INTO
              l_pdtv_rec.ID,
              l_pdtv_rec.OBJECT_VERSION_NUMBER,
              l_pdtv_rec.AES_ID,
              l_pdtv_rec.PTL_ID,
              l_pdtv_rec.NAME,
              l_pdtv_rec.DESCRIPTION,
              l_pdtv_rec.REPORTING_PDT_ID,
              l_pdtv_rec.LEGACY_PRODUCT_YN,
              l_pdtv_rec.FROM_DATE,
              l_pdtv_rec.VERSION,
              l_pdtv_rec.TO_DATE,
              l_pdtv_rec.ATTRIBUTE_CATEGORY,
              l_pdtv_rec.product_status_code,
              l_pdtv_rec.ATTRIBUTE1,
              l_pdtv_rec.ATTRIBUTE2,
              l_pdtv_rec.ATTRIBUTE3,
              l_pdtv_rec.ATTRIBUTE4,
              l_pdtv_rec.ATTRIBUTE5,
              l_pdtv_rec.ATTRIBUTE6,
              l_pdtv_rec.ATTRIBUTE7,
              l_pdtv_rec.ATTRIBUTE8,
              l_pdtv_rec.ATTRIBUTE9,
              l_pdtv_rec.ATTRIBUTE10,
              l_pdtv_rec.ATTRIBUTE11,
              l_pdtv_rec.ATTRIBUTE12,
              l_pdtv_rec.ATTRIBUTE13,
              l_pdtv_rec.ATTRIBUTE14,
              l_pdtv_rec.ATTRIBUTE15,
              l_pdtv_rec.CREATED_BY,
              l_pdtv_rec.CREATION_DATE,
              l_pdtv_rec.LAST_UPDATED_BY,
              l_pdtv_rec.LAST_UPDATE_DATE,
              l_pdtv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pdtv_pk_csr%NOTFOUND;
    CLOSE okl_pdtv_pk_csr;
    RETURN(l_pdtv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pdtv_rec                     IN pdtv_rec_type
  ) RETURN pdtv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pdtv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PRODUCTS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_pdtv_rec	IN pdtv_rec_type
  ) RETURN pdtv_rec_type IS
    l_pdtv_rec	pdtv_rec_type := p_pdtv_rec;
  BEGIN
    IF (l_pdtv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.object_version_number := NULL;
    END IF;
    IF (l_pdtv_rec.aes_id = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.aes_id := NULL;
    END IF;
    IF (l_pdtv_rec.ptl_id = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.ptl_id := NULL;
    END IF;
    IF (l_pdtv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.name := NULL;
    END IF;
    IF (l_pdtv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.description := NULL;
    END IF;
    IF (l_pdtv_rec.reporting_pdt_id = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.reporting_pdt_id := NULL;
    END IF;
    IF (l_pdtv_rec.legacy_product_yn = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.legacy_product_yn := NULL;
    END IF;

    IF (l_pdtv_rec.product_status_code = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.product_status_code := NULL;
    END IF;

    IF (l_pdtv_rec.from_date = OKC_API.G_MISS_DATE) THEN
      l_pdtv_rec.from_date := NULL;
    END IF;
    IF (l_pdtv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.version := NULL;
    END IF;
    IF (l_pdtv_rec.TO_DATE = OKC_API.G_MISS_DATE) THEN
      l_pdtv_rec.TO_DATE := NULL;
    END IF;
    IF (l_pdtv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute_category := NULL;
    END IF;
    IF (l_pdtv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute1 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute2 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute3 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute4 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute5 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute6 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute7 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute8 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute9 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute10 := NULL;

    END IF;
    IF (l_pdtv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute11 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute12 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute13 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute14 := NULL;
    END IF;
    IF (l_pdtv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_pdtv_rec.attribute15 := NULL;
    END IF;
    IF (l_pdtv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.created_by := NULL;
    END IF;
    IF (l_pdtv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pdtv_rec.creation_date := NULL;
    END IF;
    IF (l_pdtv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pdtv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pdtv_rec.last_update_date := NULL;
    END IF;
    IF (l_pdtv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pdtv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_pdtv_rec);
  END null_out_defaults;
/**********************RPOONUGA001: Commenting Old Code ******************************
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_PRODUCTS_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_pdtv_rec IN  pdtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_pdtv_rec.id = OKC_API.G_MISS_NUM OR
       p_pdtv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_pdtv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.aes_id = OKC_API.G_MISS_NUM OR
          p_pdtv_rec.aes_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'aes_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.name = OKC_API.G_MISS_CHAR OR
          p_pdtv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.legacy_product_yn = OKC_API.G_MISS_CHAR OR
          p_pdtv_rec.legacy_product_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'legacy_product_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.from_date = OKC_API.G_MISS_DATE OR
          p_pdtv_rec.from_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_pdtv_rec.version = OKC_API.G_MISS_CHAR OR
          p_pdtv_rec.version IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'version');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_PRODUCTS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_pdtv_rec IN pdtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
********************************************************************************************/
  /************************** RPOONUGA001: Start New Code *****************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.id IS NULL) OR
       (p_pdtv_rec.id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Aes_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Aes_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Aes_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_aes_status                   VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;
  CURSOR okl_aesv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_ae_tmpt_sets_v
       WHERE okl_ae_tmpt_sets_v.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.aes_id IS NULL) OR
       (p_pdtv_rec.aes_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'aes_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_pdtv_rec.AES_ID IS NOT NULL) THEN
        OPEN okl_aesv_pk_csr(p_pdtv_rec.AES_ID);
        FETCH okl_aesv_pk_csr INTO l_aes_status;
        l_row_notfound := okl_aesv_pk_csr%NOTFOUND;
        CLOSE okl_aesv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'AES_ID');

          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
      END IF;


  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;
    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Aes_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Ptl_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Ptl_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Ptl_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_ptl_status                   VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;
  CURSOR okl_ptlv_pk_csr (p_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_pdt_templates_v
       WHERE okl_pdt_templates_v.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.ptl_id IS NULL) OR
       (p_pdtv_rec.ptl_id = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'ptl_id');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    IF (p_pdtv_rec.PTL_ID IS NOT NULL) THEN
        OPEN okl_ptlv_pk_csr(p_pdtv_rec.PTL_ID);
        FETCH okl_ptlv_pk_csr INTO l_ptl_status;
        l_row_notfound := okl_ptlv_pk_csr%NOTFOUND;
        CLOSE okl_ptlv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PTL_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Ptl_Id;


    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_product_status_code
    --------------------------------------------------------------------------
    -- Start of comments
    --Author           : suresh gorantla
    -- Procedure Name  : Validate_product_status_code
    -- Description     :
    -- Business Rules  :

    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------

    Procedure Validate_product_status_code( p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

    l_found VARCHAR2(1);
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    BEGIN
      x_return_status := OKC_API.G_RET_STS_SUCCESS;

     -- check for data before processing
	   	IF (p_pdtv_rec.product_status_code IS NULL) OR
	    	        (p_pdtv_rec.product_status_code  = Okc_Api.G_MISS_CHAR) THEN
	     OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'product_status_code');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
         ELSE
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_PRODUCT_STATUS',
   								    p_lookup_code => p_pdtv_rec.product_status_code);


			IF (l_found <> OKL_API.G_TRUE ) THEN
                           OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'product_status_code');
			     x_return_status := Okc_Api.G_RET_STS_ERROR;
				 -- raise the exception as there's no matching foreign key value
				 RAISE G_EXCEPTION_HALT_VALIDATION;
			END IF;

	     END IF;


     EXCEPTION
        WHEN G_EXCEPTION_HALT_VALIDATION THEN
	            -- no processing necessary; validation can continue
	            -- with the next column
	            NULL;
        WHEN OTHERS THEN
          -- store SQL error message on message stack for caller
        -- store SQL error message on message stack for caller
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

        -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END Validate_product_status_code;

  --------------------------------------------------------------------------
  -- PROCEDURE Validate_reporting_pdt_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_reporting_pdt_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_reporting_pdt_Id(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_ptl_status                   VARCHAR2(1);
  l_row_notfound                 BOOLEAN := TRUE;
  CURSOR okl_pdtv_pk_csr1 (p_rep_pdt_id                 IN NUMBER) IS
      SELECT  '1'
        FROM okl_products_v pdt
       WHERE pdt.id = p_rep_pdt_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (p_pdtv_rec.reporting_pdt_id IS NOT NULL) THEN
        OPEN okl_pdtv_pk_csr1 (p_pdtv_rec.reporting_pdt_id);
        FETCH okl_pdtv_pk_csr1  INTO l_ptl_status;
        l_row_notfound := okl_pdtv_pk_csr1%NOTFOUND;
        CLOSE okl_pdtv_pk_csr1;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'REPORTING_PDT_ID');
          RAISE G_ITEM_NOT_FOUND_ERROR;
        END IF;
    END IF;

  EXCEPTION

    WHEN G_ITEM_NOT_FOUND_ERROR THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_reporting_pdt_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Object_Version_Number(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.object_version_number IS NULL) OR
       (p_pdtv_rec.object_version_Number = OKC_API.G_MISS_NUM) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'object_version_number');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;


    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Legacy_Product_YN
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Legacy_Product_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Legacy_Product_YN(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    l_return_status :=     OKL_ACCOUNTING_UTIL.validate_lookup_code('YES_NO',p_pdtv_rec.legacy_product_yn,0,0);

 IF l_return_status = OKC_API.G_FALSE THEN
         l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;


    IF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'legacy_product_yn');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing neccessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Legacy_Product_YN;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_From_Date(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.from_date IS NULL) OR
       (p_pdtv_rec.from_date = OKC_API.G_MISS_DATE) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name

                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'from_date');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_To_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_To_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_To_Date(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.TO_DATE IS NOT NULL) AND
       (p_pdtv_rec.TO_DATE < p_pdtv_rec.from_date) THEN
       OKC_API.SET_MESSAGE(p_app_name       => 'OKL'
                          ,p_msg_name       => g_to_date_error
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'to_date');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_To_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Version
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Version
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Version(p_pdtv_rec      IN   pdtv_rec_type
			     ,x_return_status OUT  NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.version IS NULL) OR
       (p_pdtv_rec.version = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'version');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Version;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Name(p_pdtv_rec      IN OUT  NOCOPY pdtv_rec_type
			     ,x_return_status OUT NOCOPY VARCHAR2       )
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_pdtv_rec.name IS NULL) OR
       (p_pdtv_rec.name = OKC_API.G_MISS_CHAR) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
                          ,p_msg_name       => g_required_value
                          ,p_token1         => g_col_name_token
                          ,p_token1_value   => 'name');
       x_return_status    := OKC_API.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    p_pdtv_rec.name := Okl_Accounting_Util.okl_upper(p_pdtv_rec.name);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Name;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Function Name   : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------


  FUNCTION Validate_Attributes (
    p_pdtv_rec IN OUT NOCOPY pdtv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdtv_rec pdtv_rec_type := p_pdtv_rec;
  BEGIN

    -- Validate_Id
    Validate_Id(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Name
    Validate_Name(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- product_status_code
    Validate_product_status_code(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Version
    Validate_Version(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Aes_Id
    Validate_Aes_Id(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Ptl_Id
    Validate_Ptl_Id(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_reporting_pdt_id
    Validate_reporting_pdt_Id(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;


    -- Validate_Legacy_Product_YN
    Validate_Legacy_Product_YN(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_From_Date
    Validate_From_Date(l_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    p_pdtv_rec := l_pdtv_rec;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Pdt_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Pdt_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Pdt_Record(p_pdtv_rec      IN      pdtv_rec_type
					        ,x_return_status OUT NOCOPY VARCHAR2)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_pdt_status            VARCHAR2(1);
  l_row_found             BOOLEAN := FALSE;
  CURSOR c1(p_name okl_products_v.name%TYPE,
		p_version okl_products_v.version%TYPE) IS
  SELECT '1'
  FROM okl_products_v
  WHERE  name = p_name
  AND    version = p_version
  AND    id <> NVL(p_pdtv_rec.id,-9999);
  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    OPEN c1(p_pdtv_rec.name,
	      p_pdtv_rec.version);
    FETCH c1 INTO l_pdt_status;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found THEN
		OKC_API.set_message('OKL',G_UNQS, G_TABLE_TOKEN, 'Okl_Products_V');
		x_return_status := OKC_API.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,

                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Pdt_Record;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Record (
    p_pdtv_rec IN pdtv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_To_Date
    Validate_To_Date(p_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Unique_Pdt_Record
    Validate_Unique_Pdt_Record(p_pdtv_rec, x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- just come out with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => SQLCODE,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;

/************************************** RPOONUGA001: End New Code *************************/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  -- RPOONUGA001: Add IN to p_to parameter of migrate procedure
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pdtv_rec_type,
    p_to	IN OUT NOCOPY pdt_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.aes_id := p_from.aes_id;
    p_to.ptl_id := p_from.ptl_id;
    p_to.legacy_product_yn := p_from.legacy_product_yn;
    p_to.version := p_from.version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.reporting_pdt_id := p_from.reporting_pdt_id;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.attribute_category := p_from.attribute_category;
    p_to.product_status_code := p_from.product_status_code;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN pdt_rec_type,
    p_to	IN OUT NOCOPY pdtv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.name := p_from.name;
    p_to.aes_id := p_from.aes_id;
    p_to.ptl_id := p_from.ptl_id;
    p_to.legacy_product_yn := p_from.legacy_product_yn;
    p_to.version := p_from.version;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.reporting_pdt_id := p_from.reporting_pdt_id;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.attribute_category := p_from.attribute_category;
    p_to.product_status_code := p_from.product_status_code;
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_PRODUCTS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN pdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdtv_rec                     pdtv_rec_type := p_pdtv_rec;
    l_pdt_rec                      pdt_rec_type;
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
    l_return_status := Validate_Attributes(l_pdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_pdtv_rec);
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
  -- PL/SQL TBL validate_row for:PDTV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_tbl                     IN pdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdtv_tbl.COUNT > 0) THEN
      i := p_pdtv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdtv_rec                     => p_pdtv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_pdtv_tbl.LAST);
        i := p_pdtv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
	x_return_status := l_overall_status;
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
  ---------------------------------
  -- insert_row for:OKL_PRODUCTS --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdt_rec                      IN pdt_rec_type,
    x_pdt_rec                      OUT NOCOPY pdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRODUCTS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdt_rec                      pdt_rec_type := p_pdt_rec;
    l_def_pdt_rec                  pdt_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_PRODUCTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_pdt_rec IN  pdt_rec_type,
      x_pdt_rec OUT NOCOPY pdt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdt_rec := p_pdt_rec;
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
      p_pdt_rec,                         -- IN
      l_pdt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PRODUCTS(
        id,
        name,
        aes_id,
        ptl_id,
        legacy_product_yn,
        version,
        object_version_number,
        description,
	reporting_pdt_id,
        from_date,
        TO_DATE,
        attribute_category,
        product_status_code,
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
        last_update_login)

      VALUES (
        l_pdt_rec.id,
        l_pdt_rec.name,
        l_pdt_rec.aes_id,
        l_pdt_rec.ptl_id,
        l_pdt_rec.legacy_product_yn,
        l_pdt_rec.version,
        l_pdt_rec.object_version_number,
        l_pdt_rec.description,
        l_pdt_rec.reporting_pdt_id,
        l_pdt_rec.from_date,
        l_pdt_rec.TO_DATE,
        l_pdt_rec.attribute_category,
        l_pdt_rec.product_status_code,
        l_pdt_rec.attribute1,
        l_pdt_rec.attribute2,
        l_pdt_rec.attribute3,
        l_pdt_rec.attribute4,
        l_pdt_rec.attribute5,
        l_pdt_rec.attribute6,
        l_pdt_rec.attribute7,
        l_pdt_rec.attribute8,
        l_pdt_rec.attribute9,
        l_pdt_rec.attribute10,
        l_pdt_rec.attribute11,
        l_pdt_rec.attribute12,
        l_pdt_rec.attribute13,
        l_pdt_rec.attribute14,
        l_pdt_rec.attribute15,
        l_pdt_rec.created_by,
        l_pdt_rec.creation_date,
        l_pdt_rec.last_updated_by,
        l_pdt_rec.last_update_date,
        l_pdt_rec.last_update_login);
    -- Set OUT values
    x_pdt_rec := l_pdt_rec;
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
  -----------------------------------
  -- insert_row for:OKL_PRODUCTS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdtv_rec                     pdtv_rec_type;
    l_def_pdtv_rec                 pdtv_rec_type;
    l_pdt_rec                      pdt_rec_type;
    lx_pdt_rec                     pdt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdtv_rec	IN pdtv_rec_type
    ) RETURN pdtv_rec_type IS
      l_pdtv_rec	pdtv_rec_type := p_pdtv_rec;
    BEGIN
      l_pdtv_rec.CREATION_DATE := SYSDATE;
      l_pdtv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pdtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pdtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;

      l_pdtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdtv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_PRODUCTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_pdtv_rec IN  pdtv_rec_type,
      x_pdtv_rec OUT NOCOPY pdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdtv_rec := p_pdtv_rec;
      x_pdtv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_pdtv_rec := null_out_defaults(p_pdtv_rec);
    -- Set primary key value
    l_pdtv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pdtv_rec,                        -- IN
      l_def_pdtv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdtv_rec := fill_who_columns(l_def_pdtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdtv_rec, l_pdt_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdt_rec,
      lx_pdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdt_rec, l_def_pdtv_rec);
    -- Set OUT values
    x_pdtv_rec := l_def_pdtv_rec;
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
  -- PL/SQL TBL insert_row for:PDTV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_tbl                     IN pdtv_tbl_type,
    x_pdtv_tbl                     OUT NOCOPY pdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdtv_tbl.COUNT > 0) THEN
      i := p_pdtv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdtv_rec                     => p_pdtv_tbl(i),
          x_pdtv_rec                     => x_pdtv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_pdtv_tbl.LAST);
        i := p_pdtv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
	x_return_status := l_overall_status;
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
  -------------------------------
  -- lock_row for:OKL_PRODUCTS --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,

    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdt_rec                      IN pdt_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pdt_rec IN pdt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRODUCTS
     WHERE ID = p_pdt_rec.id
       AND OBJECT_VERSION_NUMBER = p_pdt_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pdt_rec IN pdt_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PRODUCTS
    WHERE ID = p_pdt_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRODUCTS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PRODUCTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PRODUCTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pdt_rec);
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
      OPEN lchk_csr(p_pdt_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pdt_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pdt_rec.object_version_number THEN
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
  ---------------------------------
  -- lock_row for:OKL_PRODUCTS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN pdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdt_rec                      pdt_rec_type;
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
    migrate(p_pdtv_rec, l_pdt_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdt_rec
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
  -- PL/SQL TBL lock_row for:PDTV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_tbl                     IN pdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdtv_tbl.COUNT > 0) THEN
      i := p_pdtv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdtv_rec                     => p_pdtv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_pdtv_tbl.LAST);
        i := p_pdtv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
	x_return_status := l_overall_status;
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
  ---------------------------------
  -- update_row for:OKL_PRODUCTS --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdt_rec                      IN pdt_rec_type,
    x_pdt_rec                      OUT NOCOPY pdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRODUCTS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdt_rec                      pdt_rec_type := p_pdt_rec;
    l_def_pdt_rec                  pdt_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdt_rec	IN pdt_rec_type,
      x_pdt_rec	OUT NOCOPY pdt_rec_type
    ) RETURN VARCHAR2 IS
      l_pdt_rec                      pdt_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdt_rec := p_pdt_rec;
      -- Get current database values
      l_pdt_rec := get_rec(p_pdt_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdt_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.id := l_pdt_rec.id;
      END IF;

      IF (x_pdt_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.name := l_pdt_rec.name;
      END IF;
      IF (x_pdt_rec.aes_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.aes_id := l_pdt_rec.aes_id;
      END IF;
      IF (x_pdt_rec.reporting_pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.reporting_pdt_id := l_pdt_rec.reporting_pdt_id;
      END IF;
      IF (x_pdt_rec.ptl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.ptl_id := l_pdt_rec.ptl_id;
      END IF;
      IF (x_pdt_rec.legacy_product_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.legacy_product_yn := l_pdt_rec.legacy_product_yn;
      END IF;
      IF (x_pdt_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.version := l_pdt_rec.version;
      END IF;
      IF (x_pdt_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.object_version_number := l_pdt_rec.object_version_number;
      END IF;
      IF (x_pdt_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.description := l_pdt_rec.description;
      END IF;
      IF (x_pdt_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdt_rec.from_date := l_pdt_rec.from_date;
      END IF;
      IF (x_pdt_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_pdt_rec.TO_DATE := l_pdt_rec.TO_DATE;
      END IF;
      IF (x_pdt_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute_category := l_pdt_rec.attribute_category;
      END IF;

      IF (x_pdt_rec.product_status_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.product_status_code := l_pdt_rec.product_status_code;
      END IF;

      IF (x_pdt_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute1 := l_pdt_rec.attribute1;
      END IF;
      IF (x_pdt_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute2 := l_pdt_rec.attribute2;
      END IF;
      IF (x_pdt_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute3 := l_pdt_rec.attribute3;
      END IF;
      IF (x_pdt_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute4 := l_pdt_rec.attribute4;
      END IF;
      IF (x_pdt_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute5 := l_pdt_rec.attribute5;
      END IF;
      IF (x_pdt_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute6 := l_pdt_rec.attribute6;
      END IF;
      IF (x_pdt_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute7 := l_pdt_rec.attribute7;
      END IF;
      IF (x_pdt_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute8 := l_pdt_rec.attribute8;
      END IF;
      IF (x_pdt_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute9 := l_pdt_rec.attribute9;
      END IF;
      IF (x_pdt_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute10 := l_pdt_rec.attribute10;
      END IF;
      IF (x_pdt_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute11 := l_pdt_rec.attribute11;
      END IF;
      IF (x_pdt_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute12 := l_pdt_rec.attribute12;
      END IF;
      IF (x_pdt_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute13 := l_pdt_rec.attribute13;
      END IF;
      IF (x_pdt_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute14 := l_pdt_rec.attribute14;

      END IF;
      IF (x_pdt_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdt_rec.attribute15 := l_pdt_rec.attribute15;
      END IF;
      IF (x_pdt_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.created_by := l_pdt_rec.created_by;
      END IF;
      IF (x_pdt_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdt_rec.creation_date := l_pdt_rec.creation_date;
      END IF;
      IF (x_pdt_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.last_updated_by := l_pdt_rec.last_updated_by;
      END IF;
      IF (x_pdt_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdt_rec.last_update_date := l_pdt_rec.last_update_date;
      END IF;
      IF (x_pdt_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdt_rec.last_update_login := l_pdt_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_PRODUCTS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_pdt_rec IN  pdt_rec_type,
      x_pdt_rec OUT NOCOPY pdt_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdt_rec := p_pdt_rec;
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
      p_pdt_rec,                         -- IN
      l_pdt_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdt_rec, l_def_pdt_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PRODUCTS
    SET NAME = l_def_pdt_rec.name,
        AES_ID = l_def_pdt_rec.aes_id,
        PTL_ID = l_def_pdt_rec.ptl_id,
        LEGACY_PRODUCT_YN = l_def_pdt_rec.legacy_product_yn,
        VERSION = l_def_pdt_rec.version,
        OBJECT_VERSION_NUMBER = l_def_pdt_rec.object_version_number,
        DESCRIPTION = l_def_pdt_rec.description,
   	    REPORTING_PDT_ID = l_def_pdt_rec.reporting_pdt_id,
        product_status_code = l_def_pdt_rec.product_status_code,
        FROM_DATE = l_def_pdt_rec.from_date,
        TO_DATE = l_def_pdt_rec.TO_DATE,
        ATTRIBUTE_CATEGORY = l_def_pdt_rec.attribute_category,
        ATTRIBUTE1 = l_def_pdt_rec.attribute1,
        ATTRIBUTE2 = l_def_pdt_rec.attribute2,
        ATTRIBUTE3 = l_def_pdt_rec.attribute3,
        ATTRIBUTE4 = l_def_pdt_rec.attribute4,
        ATTRIBUTE5 = l_def_pdt_rec.attribute5,
        ATTRIBUTE6 = l_def_pdt_rec.attribute6,
        ATTRIBUTE7 = l_def_pdt_rec.attribute7,
        ATTRIBUTE8 = l_def_pdt_rec.attribute8,
        ATTRIBUTE9 = l_def_pdt_rec.attribute9,
        ATTRIBUTE10 = l_def_pdt_rec.attribute10,
        ATTRIBUTE11 = l_def_pdt_rec.attribute11,
        ATTRIBUTE12 = l_def_pdt_rec.attribute12,
        ATTRIBUTE13 = l_def_pdt_rec.attribute13,
        ATTRIBUTE14 = l_def_pdt_rec.attribute14,
        ATTRIBUTE15 = l_def_pdt_rec.attribute15,
        CREATED_BY = l_def_pdt_rec.created_by,
        CREATION_DATE = l_def_pdt_rec.creation_date,
        LAST_UPDATED_BY = l_def_pdt_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pdt_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pdt_rec.last_update_login
    WHERE ID = l_def_pdt_rec.id;



    x_pdt_rec := l_def_pdt_rec;
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
  -----------------------------------
  -- update_row for:OKL_PRODUCTS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN pdtv_rec_type,
    x_pdtv_rec                     OUT NOCOPY pdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdtv_rec                     pdtv_rec_type := p_pdtv_rec;
    l_def_pdtv_rec                 pdtv_rec_type;
    l_pdt_rec                      pdt_rec_type;
    lx_pdt_rec                     pdt_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pdtv_rec	IN pdtv_rec_type
    ) RETURN pdtv_rec_type IS
      l_pdtv_rec	pdtv_rec_type := p_pdtv_rec;
    BEGIN
      l_pdtv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pdtv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pdtv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pdtv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pdtv_rec	IN pdtv_rec_type,
      x_pdtv_rec	OUT NOCOPY pdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_pdtv_rec                     pdtv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdtv_rec := p_pdtv_rec;
      -- Get current database values
      l_pdtv_rec := get_rec(p_pdtv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pdtv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.id := l_pdtv_rec.id;
      END IF;
      IF (x_pdtv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.object_version_number := l_pdtv_rec.object_version_number;
      END IF;
      IF (x_pdtv_rec.aes_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.aes_id := l_pdtv_rec.aes_id;
      END IF;
      IF (x_pdtv_rec.ptl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.ptl_id := l_pdtv_rec.ptl_id;
      END IF;

      IF (x_pdtv_rec.reporting_pdt_id = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.reporting_pdt_id := l_pdtv_rec.reporting_pdt_id;
      END IF;
      IF (x_pdtv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.name := l_pdtv_rec.name;
      END IF;
      IF (x_pdtv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.description := l_pdtv_rec.description;
      END IF;
      IF (x_pdtv_rec.legacy_product_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.legacy_product_yn := l_pdtv_rec.legacy_product_yn;
      END IF;
      IF (x_pdtv_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdtv_rec.from_date := l_pdtv_rec.from_date;
      END IF;
      IF (x_pdtv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.version := l_pdtv_rec.version;
      END IF;
      IF (x_pdtv_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_pdtv_rec.TO_DATE := l_pdtv_rec.TO_DATE;
      END IF;
      IF (x_pdtv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute_category := l_pdtv_rec.attribute_category;
      END IF;

      IF (x_pdtv_rec.product_status_code = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.product_status_code := l_pdtv_rec.product_status_code;
      END IF;


      IF (x_pdtv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute1 := l_pdtv_rec.attribute1;
      END IF;
      IF (x_pdtv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute2 := l_pdtv_rec.attribute2;
      END IF;
      IF (x_pdtv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute3 := l_pdtv_rec.attribute3;
      END IF;
      IF (x_pdtv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute4 := l_pdtv_rec.attribute4;
      END IF;
      IF (x_pdtv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute5 := l_pdtv_rec.attribute5;
      END IF;
      IF (x_pdtv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute6 := l_pdtv_rec.attribute6;
      END IF;
      IF (x_pdtv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute7 := l_pdtv_rec.attribute7;
      END IF;
      IF (x_pdtv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute8 := l_pdtv_rec.attribute8;
      END IF;
      IF (x_pdtv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute9 := l_pdtv_rec.attribute9;
      END IF;
      IF (x_pdtv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute10 := l_pdtv_rec.attribute10;
      END IF;
      IF (x_pdtv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute11 := l_pdtv_rec.attribute11;
      END IF;
      IF (x_pdtv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute12 := l_pdtv_rec.attribute12;
      END IF;
      IF (x_pdtv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute13 := l_pdtv_rec.attribute13;
      END IF;
      IF (x_pdtv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute14 := l_pdtv_rec.attribute14;
      END IF;
      IF (x_pdtv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_pdtv_rec.attribute15 := l_pdtv_rec.attribute15;
      END IF;
      IF (x_pdtv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.created_by := l_pdtv_rec.created_by;
      END IF;
      IF (x_pdtv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdtv_rec.creation_date := l_pdtv_rec.creation_date;

      END IF;
      IF (x_pdtv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.last_updated_by := l_pdtv_rec.last_updated_by;
      END IF;
      IF (x_pdtv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pdtv_rec.last_update_date := l_pdtv_rec.last_update_date;
      END IF;
      IF (x_pdtv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pdtv_rec.last_update_login := l_pdtv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_PRODUCTS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_pdtv_rec IN  pdtv_rec_type,
      x_pdtv_rec OUT NOCOPY pdtv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pdtv_rec := p_pdtv_rec;
      x_pdtv_rec.OBJECT_VERSION_NUMBER := NVL(x_pdtv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_pdtv_rec,                        -- IN
      l_pdtv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pdtv_rec, l_def_pdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pdtv_rec := fill_who_columns(l_def_pdtv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pdtv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pdtv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pdtv_rec, l_pdt_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdt_rec,
      lx_pdt_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pdt_rec, l_def_pdtv_rec);
    x_pdtv_rec := l_def_pdtv_rec;
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
  -- PL/SQL TBL update_row for:PDTV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_tbl                     IN pdtv_tbl_type,
    x_pdtv_tbl                     OUT NOCOPY pdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdtv_tbl.COUNT > 0) THEN
      i := p_pdtv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdtv_rec                     => p_pdtv_tbl(i),
          x_pdtv_rec                     => x_pdtv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_pdtv_tbl.LAST);
        i := p_pdtv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
	x_return_status := l_overall_status;
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
  ---------------------------------
  -- delete_row for:OKL_PRODUCTS --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdt_rec                      IN pdt_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRODUCTS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdt_rec                      pdt_rec_type:= p_pdt_rec;
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
    DELETE FROM OKL_PRODUCTS
     WHERE ID = l_pdt_rec.id;

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
  -----------------------------------
  -- delete_row for:OKL_PRODUCTS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_rec                     IN pdtv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pdtv_rec                     pdtv_rec_type := p_pdtv_rec;
    l_pdt_rec                      pdt_rec_type;
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
    migrate(l_pdtv_rec, l_pdt_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pdt_rec
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
  -- PL/SQL TBL delete_row for:PDTV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pdtv_tbl                     IN pdtv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- RPOONUGA001: New variable
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pdtv_tbl.COUNT > 0) THEN
      i := p_pdtv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pdtv_rec                     => p_pdtv_tbl(i));
        -- RPOONUGA001: store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;
        EXIT WHEN (i = p_pdtv_tbl.LAST);
        i := p_pdtv_tbl.NEXT(i);
      END LOOP;
	-- RPOONUGA001: return overall status
	x_return_status := l_overall_status;
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
END OKL_PDT_PVT;

/
