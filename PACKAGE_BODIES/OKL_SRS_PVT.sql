--------------------------------------------------------
--  DDL for Package Body OKL_SRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SRS_PVT" AS
/* $Header: OKLSSRSB.pls 120.2 2005/10/30 04:44:33 appldev noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_RET_STRMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srs_rec                      IN srs_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srs_rec_type IS
    CURSOR srs_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STREAM_TYPE_NAME,
            INDEX_NUMBER,
            ACTIVITY_TYPE,
            SEQUENCE_NUMBER,
            SRE_DATE,
            AMOUNT,
            SIR_ID,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Ret_Strms
     WHERE okl_sif_ret_strms.id = p_id;
    l_srs_pk                       srs_pk_csr%ROWTYPE;
    l_srs_rec                      srs_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srs_pk_csr (p_srs_rec.id);
    FETCH srs_pk_csr INTO
              l_srs_rec.ID,
              l_srs_rec.STREAM_TYPE_NAME,
              l_srs_rec.INDEX_NUMBER,
              l_srs_rec.ACTIVITY_TYPE,
              l_srs_rec.SEQUENCE_NUMBER,
              l_srs_rec.SRE_DATE,
              l_srs_rec.AMOUNT,
              l_srs_rec.SIR_ID,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_srs_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_srs_rec.OBJECT_VERSION_NUMBER,
              l_srs_rec.CREATED_BY,
              l_srs_rec.LAST_UPDATED_BY,
              l_srs_rec.CREATION_DATE,
              l_srs_rec.LAST_UPDATE_DATE,
              l_srs_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := srs_pk_csr%NOTFOUND;
    CLOSE srs_pk_csr;
    RETURN(l_srs_rec);
  END get_rec;

  FUNCTION get_rec (
    p_srs_rec                      IN srs_rec_type
  ) RETURN srs_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srs_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_RET_STRMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_srsv_rec                     IN srsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN srsv_rec_type IS
    CURSOR srsv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            STREAM_TYPE_NAME,
            INDEX_NUMBER,
            ACTIVITY_TYPE,
            SEQUENCE_NUMBER,
            SRE_DATE,
            AMOUNT,
            SIR_ID,
			STREAM_INTERFACE_ATTRIBUTE01,
			STREAM_INTERFACE_ATTRIBUTE02,
			STREAM_INTERFACE_ATTRIBUTE03,
			STREAM_INTERFACE_ATTRIBUTE04,
			STREAM_INTERFACE_ATTRIBUTE05,
			STREAM_INTERFACE_ATTRIBUTE06,
			STREAM_INTERFACE_ATTRIBUTE07,
			STREAM_INTERFACE_ATTRIBUTE08,
			STREAM_INTERFACE_ATTRIBUTE09,
			STREAM_INTERFACE_ATTRIBUTE10,
			STREAM_INTERFACE_ATTRIBUTE11,
			STREAM_INTERFACE_ATTRIBUTE12,
			STREAM_INTERFACE_ATTRIBUTE13,
			STREAM_INTERFACE_ATTRIBUTE14,
   			STREAM_INTERFACE_ATTRIBUTE15,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Ret_Strms_V
     WHERE okl_sif_ret_strms_v.id = p_id;
    l_srsv_pk                      srsv_pk_csr%ROWTYPE;
    l_srsv_rec                     srsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN srsv_pk_csr (p_srsv_rec.id);
    FETCH srsv_pk_csr INTO
              l_srsv_rec.ID,
              l_srsv_rec.STREAM_TYPE_NAME,
              l_srsv_rec.INDEX_NUMBER,
              l_srsv_rec.ACTIVITY_TYPE,
              l_srsv_rec.SEQUENCE_NUMBER,
              l_srsv_rec.SRE_DATE,
              l_srsv_rec.AMOUNT,
              l_srsv_rec.SIR_ID,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_srsv_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_srsv_rec.OBJECT_VERSION_NUMBER,
              l_srsv_rec.CREATED_BY,
              l_srsv_rec.LAST_UPDATED_BY,
              l_srsv_rec.CREATION_DATE,
              l_srsv_rec.LAST_UPDATE_DATE,
              l_srsv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := srsv_pk_csr%NOTFOUND;
    CLOSE srsv_pk_csr;
    RETURN(l_srsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_srsv_rec                     IN srsv_rec_type
  ) RETURN srsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_srsv_rec, l_row_notfound));
  END get_rec;

  ---------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_RET_STRMS_V --
  ---------------------------------------------------------
  FUNCTION null_out_defaults (
    p_srsv_rec	IN srsv_rec_type
  ) RETURN srsv_rec_type IS
    l_srsv_rec	srsv_rec_type := p_srsv_rec;
  BEGIN
    IF (l_srsv_rec.stream_type_name = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_type_name := NULL;
    END IF;
    IF (l_srsv_rec.index_number = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.index_number := NULL;
    END IF;
    IF (l_srsv_rec.activity_type = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.activity_type := NULL;
    END IF;
    IF (l_srsv_rec.sequence_number = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.sequence_number := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_srsv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_srsv_rec.stream_interface_attribute15 := NULL;
    END IF;

    IF (l_srsv_rec.sre_date = OKC_API.G_MISS_DATE) THEN
      l_srsv_rec.sre_date := NULL;
    END IF;
    IF (l_srsv_rec.amount = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.amount := NULL;
    END IF;
    IF (l_srsv_rec.sir_id = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.sir_id := NULL;
    END IF;
    IF (l_srsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.object_version_number := NULL;
    END IF;
    IF (l_srsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.created_by := NULL;
    END IF;
    IF (l_srsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_srsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_srsv_rec.creation_date := NULL;
    END IF;
    IF (l_srsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_srsv_rec.last_update_date := NULL;
    END IF;
    IF (l_srsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_srsv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_srsv_rec);
  END null_out_defaults;
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Attributes for:OKL_SIF_RET_STRMS_V --
  -------------------------------------------------
  FUNCTION Validate_Attributes (
    p_srsv_rec IN  srsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_srsv_rec.id = OKC_API.G_MISS_NUM OR
       p_srsv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_srsv_rec.stream_type_name = OKC_API.G_MISS_CHAR OR
          p_srsv_rec.stream_type_name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'stream_type_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_srsv_rec.sir_id = OKC_API.G_MISS_NUM OR
          p_srsv_rec.sir_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sir_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_srsv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_srsv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  */

  /**
  * Adding Individual Procedures for each Attribute that
  * needs to be validated
  */
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
  PROCEDURE Validate_Id(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.id = Okc_Api.G_MISS_NUM OR
      p_srsv_rec.id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;

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
  PROCEDURE Validate_Object_Version_Number(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_srsv_rec.object_version_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Index_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Index_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Index_Number(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.index_number = Okc_Api.G_MISS_NUM OR
      p_srsv_rec.index_number IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'index_number');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Index_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sre_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sre_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sre_Date(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.Sre_Date = Okc_Api.G_MISS_DATE OR
      p_srsv_rec.Sre_Date IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Sre_Date');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Sre_Date;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Amount
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Amount
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Amount(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.Amount = Okc_Api.G_MISS_NUM OR
      p_srsv_rec.Amount IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Amount');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Amount;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Stream_Type_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Stream_Type_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Stream_Type_Name(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.Stream_Type_Name = Okc_Api.G_MISS_CHAR OR
       p_srsv_rec.Stream_Type_Name IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Stream_Type_Name');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

  END Validate_Stream_Type_Name;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Sir_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Sir_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Sir_Id(
    p_srsv_rec      IN   srsv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_dummy                 VARCHAR2(1) 	:= '?';
  l_row_not_found         BOOLEAN 	:= FALSE;

  -- Cursor For OKL_SRY_SIR_FK;
  CURSOR okl_sirv_pk_csr (p_id IN OKL_SIF_RETS_V.Id%TYPE) IS
  SELECT '1'
    FROM OKL_SIF_RETS_V
   WHERE OKL_SIF_RETS_V.id = p_id;

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_srsv_rec.sir_id = Okc_Api.G_MISS_NUM OR
       p_srsv_rec.sir_id IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sir_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_sirv_pk_csr(p_srsv_rec.sir_id);
    FETCH okl_sirv_pk_csr INTO l_dummy;
    l_row_not_found := okl_sirv_pk_csr%NOTFOUND;
    CLOSE okl_sirv_pk_csr;

    IF l_row_not_found THEN
      Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'sir_id');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_sirv_pk_csr%ISOPEN THEN
        CLOSE okl_sirv_pk_csr;
      END IF;

  END Validate_Sir_Id;

  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  FUNCTION Validate_Attributes (
    p_srsv_rec IN  srsv_rec_type
  ) RETURN VARCHAR2 IS

    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    -- Validate_Id
    Validate_Id(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Object_Version_Number
    Validate_Object_Version_Number(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Stream_Type_Name
    Validate_Stream_Type_Name(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sre_Date
    Validate_Sre_Date(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Amount
    Validate_Amount(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

    -- Validate_Sir_id
    Validate_Sir_id(p_srsv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
          -- need to exit
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- there was an error
          l_return_status := x_return_status;
       END IF;
    END IF;

  RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
       -- exit with return status
       NULL;
       RETURN (l_return_status);

    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
       Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                           p_token1           => G_OKL_SQLCODE_TOKEN,
                           p_token1_value     => SQLCODE,
                           p_token2           => G_OKL_SQLERRM_TOKEN,
                           p_token2_value     => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN(l_return_status);
  END Validate_Attributes;
  -- END change : mvasudev

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- Validate_Record for:OKL_SIF_RET_STRMS_V --
  ---------------------------------------------
  FUNCTION Validate_Record (
    p_srsv_rec IN srsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN srsv_rec_type,
    -- START change : mvasudev, 09/05/2001
    -- Changing OUT Parameter to IN OUT
    -- p_to	OUT NOCOPY srs_rec_type
    p_to	IN OUT NOCOPY srs_rec_type
    -- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.stream_type_name := p_from.stream_type_name;
    p_to.index_number := p_from.index_number;
    p_to.activity_type := p_from.activity_type;
    p_to.sequence_number := p_from.sequence_number;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.sre_date := p_from.sre_date;
    p_to.amount := p_from.amount;
    p_to.sir_id := p_from.sir_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN srs_rec_type,
    -- START change : mvasudev, 09/05/2001
    -- Changing OUT Parameter to IN OUT
    p_to	IN OUT NOCOPY srsv_rec_type
    -- END change : mvasudev
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.stream_type_name := p_from.stream_type_name;
    p_to.index_number := p_from.index_number;
    p_to.activity_type := p_from.activity_type;
    p_to.sequence_number := p_from.sequence_number;
    p_to.stream_interface_attribute01 := p_from.stream_interface_attribute01;
    p_to.stream_interface_attribute02 := p_from.stream_interface_attribute02;
    p_to.stream_interface_attribute03 := p_from.stream_interface_attribute03;
    p_to.stream_interface_attribute04 := p_from.stream_interface_attribute04;
    p_to.stream_interface_attribute05 := p_from.stream_interface_attribute05;
    p_to.stream_interface_attribute06 := p_from.stream_interface_attribute06;
    p_to.stream_interface_attribute07 := p_from.stream_interface_attribute07;
    p_to.stream_interface_attribute08 := p_from.stream_interface_attribute08;
    p_to.stream_interface_attribute09 := p_from.stream_interface_attribute09;
    p_to.stream_interface_attribute10 := p_from.stream_interface_attribute10;
    p_to.stream_interface_attribute11 := p_from.stream_interface_attribute11;
    p_to.stream_interface_attribute12 := p_from.stream_interface_attribute12;
    p_to.stream_interface_attribute13 := p_from.stream_interface_attribute13;
    p_to.stream_interface_attribute14 := p_from.stream_interface_attribute14;
    p_to.stream_interface_attribute15 := p_from.stream_interface_attribute15;
    p_to.sre_date := p_from.sre_date;
    p_to.amount := p_from.amount;
    p_to.sir_id := p_from.sir_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- validate_row for:OKL_SIF_RET_STRMS_V --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srsv_rec                     srsv_rec_type := p_srsv_rec;
    l_srs_rec                      srs_rec_type;
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
    l_return_status := Validate_Attributes(l_srsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_srsv_rec);
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
  -- PL/SQL TBL validate_row for:SRSV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srsv_tbl.COUNT > 0) THEN
      i := p_srsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srsv_rec                     => p_srsv_tbl(i));
    	-- START change : mvasudev, 09/05/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_srsv_tbl.LAST);
        i := p_srsv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 09/05/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  --------------------------------------
  -- insert_row for:OKL_SIF_RET_STRMS --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srs_rec                      IN srs_rec_type,
    x_srs_rec                      OUT NOCOPY srs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srs_rec                      srs_rec_type := p_srs_rec;
    l_def_srs_rec                  srs_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_STRMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_srs_rec IN  srs_rec_type,
      x_srs_rec OUT NOCOPY srs_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srs_rec := p_srs_rec;
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
      p_srs_rec,                         -- IN
      l_srs_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    INSERT INTO OKL_SIF_RET_STRMS(
        id,
        stream_type_name,
        index_number,
        activity_type,
        sequence_number,
		stream_interface_attribute01,
		stream_interface_attribute02,
		stream_interface_attribute03,
		stream_interface_attribute04,
		stream_interface_attribute05,
		stream_interface_attribute06,
		stream_interface_attribute07,
		stream_interface_attribute08,
		stream_interface_attribute09,
		stream_interface_attribute10,
		stream_interface_attribute11,
		stream_interface_attribute12,
		stream_interface_attribute13,
		stream_interface_attribute14,
     	stream_interface_attribute15,
        sre_date,
        amount,
        sir_id,
        object_version_number,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login)
      VALUES (
        l_srs_rec.id,
        l_srs_rec.stream_type_name,
        l_srs_rec.index_number,
        l_srs_rec.activity_type,
        l_srs_rec.sequence_number,
		l_srs_rec.stream_interface_attribute01,
		l_srs_rec.stream_interface_attribute02,
		l_srs_rec.stream_interface_attribute03,
		l_srs_rec.stream_interface_attribute04,
		l_srs_rec.stream_interface_attribute05,
		l_srs_rec.stream_interface_attribute06,
		l_srs_rec.stream_interface_attribute07,
		l_srs_rec.stream_interface_attribute08,
		l_srs_rec.stream_interface_attribute09,
		l_srs_rec.stream_interface_attribute10,
		l_srs_rec.stream_interface_attribute11,
		l_srs_rec.stream_interface_attribute12,
		l_srs_rec.stream_interface_attribute13,
		l_srs_rec.stream_interface_attribute14,
		l_srs_rec.stream_interface_attribute15,
        l_srs_rec.sre_date,
        l_srs_rec.amount,
        l_srs_rec.sir_id,
        l_srs_rec.object_version_number,
        l_srs_rec.created_by,
        l_srs_rec.last_updated_by,
        l_srs_rec.creation_date,
        l_srs_rec.last_update_date,
        l_srs_rec.last_update_login);
    -- Set OUT values
    x_srs_rec := l_srs_rec;
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
  -- insert_row for:OKL_SIF_RET_STRMS_V --
  ----------------------------------------

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srsv_rec                     srsv_rec_type;
    l_def_srsv_rec                 srsv_rec_type;
    l_srs_rec                      srs_rec_type;
    lx_srs_rec                     srs_rec_type;

    -------------------------------
 -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srsv_rec        IN srsv_rec_type
    ) RETURN srsv_rec_type IS
      l_srsv_rec        srsv_rec_type := p_srsv_rec;
    BEGIN
      l_srsv_rec.CREATION_DATE := SYSDATE;
      l_srsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_srsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srsv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_STRMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_srsv_rec IN  srsv_rec_type,
      x_srsv_rec OUT NOCOPY srsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srsv_rec := p_srsv_rec;
      x_srsv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_srsv_rec := null_out_defaults(p_srsv_rec);
    -- Set primary key value
    l_srsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_srsv_rec,                        -- IN
      l_def_srsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srsv_rec := fill_who_columns(l_def_srsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_srsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srsv_rec, l_srs_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srs_rec,
      lx_srs_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srs_rec, l_def_srsv_rec);
    -- Set OUT values
    x_srsv_rec := l_def_srsv_rec;
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
  -- PL/SQL TBL insert_row for:SRSV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srsv_tbl.COUNT > 0) THEN
      i := p_srsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srsv_rec                     => p_srsv_tbl(i),
          x_srsv_rec                     => x_srsv_tbl(i));
    	-- START change : mvasudev, 09/05/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_srsv_tbl.LAST);
        i := p_srsv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 09/05/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  ------------------------------------
  -- lock_row for:OKL_SIF_RET_STRMS --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srs_rec                      IN srs_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_srs_rec IN srs_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_STRMS
     WHERE ID = p_srs_rec.id
       AND OBJECT_VERSION_NUMBER = p_srs_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_srs_rec IN srs_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RET_STRMS
    WHERE ID = p_srs_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_RET_STRMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_RET_STRMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_srs_rec);
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
      OPEN lchk_csr(p_srs_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_srs_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_srs_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_OKC_APP,G_RECORD_LOGICALLY_DELETED);
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
  -- lock_row for:OKL_SIF_RET_STRMS_V --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srs_rec                      srs_rec_type;
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
    migrate(p_srsv_rec, l_srs_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srs_rec
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
  -- PL/SQL TBL lock_row for:SRSV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srsv_tbl.COUNT > 0) THEN
      i := p_srsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srsv_rec                     => p_srsv_tbl(i));
    	-- START change : mvasudev, 09/05/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_srsv_tbl.LAST);
        i := p_srsv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 09/05/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  --------------------------------------
  -- update_row for:OKL_SIF_RET_STRMS --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srs_rec                      IN srs_rec_type,
    x_srs_rec                      OUT NOCOPY srs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srs_rec                      srs_rec_type := p_srs_rec;
    l_def_srs_rec                  srs_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srs_rec	IN srs_rec_type,
      x_srs_rec	OUT NOCOPY srs_rec_type
    ) RETURN VARCHAR2 IS
      l_srs_rec                      srs_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srs_rec := p_srs_rec;
      -- Get current database values
      l_srs_rec := get_rec(p_srs_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_srs_rec.id IS NULL)
      THEN
        x_srs_rec.id := l_srs_rec.id;
      END IF;
      IF (x_srs_rec.stream_type_name IS NULL)
      THEN
        x_srs_rec.stream_type_name := l_srs_rec.stream_type_name;
      END IF;
      IF (x_srs_rec.index_number IS NULL)
      THEN
        x_srs_rec.index_number := l_srs_rec.index_number;
      END IF;
      IF (x_srs_rec.activity_type IS NULL)
      THEN
        x_srs_rec.activity_type := l_srs_rec.activity_type;
      END IF;
      IF (x_srs_rec.sequence_number IS NULL)
      THEN
        x_srs_rec.sequence_number := l_srs_rec.sequence_number;
      END IF;
      IF (x_srs_rec.stream_interface_attribute01 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute01 := l_srs_rec.stream_interface_attribute01;
      END IF;
      IF (x_srs_rec.stream_interface_attribute02 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute02 := l_srs_rec.stream_interface_attribute02;
      END IF;
      IF (x_srs_rec.stream_interface_attribute03 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute03 := l_srs_rec.stream_interface_attribute03;
      END IF;
      IF (x_srs_rec.stream_interface_attribute04 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute04 := l_srs_rec.stream_interface_attribute04;
      END IF;
      IF (x_srs_rec.stream_interface_attribute05 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute05 := l_srs_rec.stream_interface_attribute05;
      END IF;
      IF (x_srs_rec.stream_interface_attribute06 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute06 := l_srs_rec.stream_interface_attribute06;
      END IF;
      IF (x_srs_rec.stream_interface_attribute07 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute07 := l_srs_rec.stream_interface_attribute07;
      END IF;
      IF (x_srs_rec.stream_interface_attribute08 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute08 := l_srs_rec.stream_interface_attribute08;
      END IF;
      IF (x_srs_rec.stream_interface_attribute09 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute09 := l_srs_rec.stream_interface_attribute09;
      END IF;
      IF (x_srs_rec.stream_interface_attribute10 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute10 := l_srs_rec.stream_interface_attribute10;
      END IF;
      IF (x_srs_rec.stream_interface_attribute11 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute11 := l_srs_rec.stream_interface_attribute11;
      END IF;
      IF (x_srs_rec.stream_interface_attribute12 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute12 := l_srs_rec.stream_interface_attribute12;
      END IF;
      IF (x_srs_rec.stream_interface_attribute13 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute13 := l_srs_rec.stream_interface_attribute13;
      END IF;
      IF (x_srs_rec.stream_interface_attribute14 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute14 := l_srs_rec.stream_interface_attribute14;
      END IF;
      IF (x_srs_rec.stream_interface_attribute15 IS NULL)
      THEN
        x_srs_rec.stream_interface_attribute15 := l_srs_rec.stream_interface_attribute15;
      END IF;
      IF (x_srs_rec.sre_date IS NULL)
      THEN
        x_srs_rec.sre_date := l_srs_rec.sre_date;
      END IF;
      IF (x_srs_rec.amount IS NULL)
      THEN
        x_srs_rec.amount := l_srs_rec.amount;
      END IF;
      IF (x_srs_rec.sir_id IS NULL)
      THEN
        x_srs_rec.sir_id := l_srs_rec.sir_id;
      END IF;
      IF (x_srs_rec.object_version_number IS NULL)
      THEN
        x_srs_rec.object_version_number := l_srs_rec.object_version_number;
      END IF;
      IF (x_srs_rec.created_by IS NULL)
      THEN
        x_srs_rec.created_by := l_srs_rec.created_by;
      END IF;
      IF (x_srs_rec.last_updated_by IS NULL)
      THEN
        x_srs_rec.last_updated_by := l_srs_rec.last_updated_by;
      END IF;
      IF (x_srs_rec.creation_date IS NULL)
      THEN
        x_srs_rec.creation_date := l_srs_rec.creation_date;
      END IF;
      IF (x_srs_rec.last_update_date IS NULL)
      THEN
        x_srs_rec.last_update_date := l_srs_rec.last_update_date;
      END IF;
      IF (x_srs_rec.last_update_login IS NULL)
      THEN
        x_srs_rec.last_update_login := l_srs_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_STRMS --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_srs_rec IN  srs_rec_type,
      x_srs_rec OUT NOCOPY srs_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srs_rec := p_srs_rec;
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
      p_srs_rec,                         -- IN
      l_srs_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_srs_rec, l_def_srs_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_RET_STRMS
    SET STREAM_TYPE_NAME = l_def_srs_rec.stream_type_name,
        INDEX_NUMBER = l_def_srs_rec.index_number,
        ACTIVITY_TYPE = l_def_srs_rec.activity_type,
        SEQUENCE_NUMBER = l_def_srs_rec.sequence_number,
		STREAM_INTERFACE_ATTRIBUTE01 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE01,
		STREAM_INTERFACE_ATTRIBUTE02 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE02,
		STREAM_INTERFACE_ATTRIBUTE03 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE03,
		STREAM_INTERFACE_ATTRIBUTE04 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE04,
		STREAM_INTERFACE_ATTRIBUTE05 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE05,
		STREAM_INTERFACE_ATTRIBUTE06 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE06,
		STREAM_INTERFACE_ATTRIBUTE07 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE07,
		STREAM_INTERFACE_ATTRIBUTE08 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE08,
		STREAM_INTERFACE_ATTRIBUTE09 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE09,
		STREAM_INTERFACE_ATTRIBUTE10 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE10,
		STREAM_INTERFACE_ATTRIBUTE11 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE11,
		STREAM_INTERFACE_ATTRIBUTE12 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE12,
		STREAM_INTERFACE_ATTRIBUTE13 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE13,
		STREAM_INTERFACE_ATTRIBUTE14 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE14,
		STREAM_INTERFACE_ATTRIBUTE15 = l_def_srs_rec.STREAM_INTERFACE_ATTRIBUTE15,
        SRE_DATE = l_def_srs_rec.sre_date,
        AMOUNT = l_def_srs_rec.amount,
        SIR_ID = l_def_srs_rec.sir_id,
        OBJECT_VERSION_NUMBER = l_def_srs_rec.object_version_number,
        CREATED_BY = l_def_srs_rec.created_by,
        LAST_UPDATED_BY = l_def_srs_rec.last_updated_by,
        CREATION_DATE = l_def_srs_rec.creation_date,
        LAST_UPDATE_DATE = l_def_srs_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_srs_rec.last_update_login
    WHERE ID = l_def_srs_rec.id;

    x_srs_rec := l_def_srs_rec;
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
  -- update_row for:OKL_SIF_RET_STRMS_V --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srsv_rec                     srsv_rec_type := p_srsv_rec;
    l_def_srsv_rec                 srsv_rec_type;
    l_srs_rec                      srs_rec_type;
    lx_srs_rec                     srs_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_srsv_rec	IN srsv_rec_type
    ) RETURN srsv_rec_type IS
      l_srsv_rec	srsv_rec_type := p_srsv_rec;
    BEGIN
      l_srsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_srsv_rec	IN srsv_rec_type,
      x_srsv_rec	OUT NOCOPY srsv_rec_type
    ) RETURN VARCHAR2 IS
      l_srsv_rec                     srsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srsv_rec := p_srsv_rec;
      -- Get current database values
      l_srsv_rec := get_rec(p_srsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_srsv_rec.id IS NULL)
      THEN
        x_srsv_rec.id := l_srsv_rec.id;
      END IF;
      IF (x_srsv_rec.stream_type_name IS NULL)
      THEN
        x_srsv_rec.stream_type_name := l_srsv_rec.stream_type_name;
      END IF;
      IF (x_srsv_rec.index_number IS NULL)
      THEN
        x_srsv_rec.index_number := l_srsv_rec.index_number;
      END IF;
      IF (x_srsv_rec.activity_type IS NULL)
      THEN
        x_srsv_rec.activity_type := l_srsv_rec.activity_type;
      END IF;
      IF (x_srsv_rec.sequence_number IS NULL)
      THEN
        x_srsv_rec.sequence_number := l_srsv_rec.sequence_number;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute01 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute01 := l_srsv_rec.stream_interface_attribute01;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute02 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute02 := l_srsv_rec.stream_interface_attribute02;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute03 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute03 := l_srsv_rec.stream_interface_attribute03;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute04 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute04 := l_srsv_rec.stream_interface_attribute04;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute05 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute05 := l_srsv_rec.stream_interface_attribute05;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute06 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute06 := l_srsv_rec.stream_interface_attribute06;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute07 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute07 := l_srsv_rec.stream_interface_attribute07;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute08 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute08 := l_srsv_rec.stream_interface_attribute08;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute09 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute09 := l_srsv_rec.stream_interface_attribute09;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute10 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute10 := l_srsv_rec.stream_interface_attribute10;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute11 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute11 := l_srsv_rec.stream_interface_attribute11;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute12 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute12 := l_srsv_rec.stream_interface_attribute12;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute13 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute13 := l_srsv_rec.stream_interface_attribute13;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute14 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute14 := l_srsv_rec.stream_interface_attribute14;
      END IF;
      IF (x_srsv_rec.stream_interface_attribute15 IS NULL)
      THEN
        x_srsv_rec.stream_interface_attribute15 := l_srsv_rec.stream_interface_attribute15;
      END IF;
      IF (x_srsv_rec.sre_date IS NULL)
      THEN
        x_srsv_rec.sre_date := l_srsv_rec.sre_date;
      END IF;
      IF (x_srsv_rec.amount IS NULL)
      THEN
        x_srsv_rec.amount := l_srsv_rec.amount;
      END IF;
      IF (x_srsv_rec.sir_id IS NULL)
      THEN
        x_srsv_rec.sir_id := l_srsv_rec.sir_id;
      END IF;
      IF (x_srsv_rec.object_version_number IS NULL)
      THEN
        x_srsv_rec.object_version_number := l_srsv_rec.object_version_number;
      END IF;
      IF (x_srsv_rec.created_by IS NULL)
      THEN
        x_srsv_rec.created_by := l_srsv_rec.created_by;
      END IF;
      IF (x_srsv_rec.last_updated_by IS NULL)
      THEN
        x_srsv_rec.last_updated_by := l_srsv_rec.last_updated_by;
      END IF;
      IF (x_srsv_rec.creation_date IS NULL)
      THEN
        x_srsv_rec.creation_date := l_srsv_rec.creation_date;
      END IF;
      IF (x_srsv_rec.last_update_date IS NULL)
      THEN
        x_srsv_rec.last_update_date := l_srsv_rec.last_update_date;
      END IF;
      IF (x_srsv_rec.last_update_login IS NULL)
      THEN
        x_srsv_rec.last_update_login := l_srsv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_STRMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_srsv_rec IN  srsv_rec_type,
      x_srsv_rec OUT NOCOPY srsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srsv_rec := p_srsv_rec;
      x_srsv_rec.OBJECT_VERSION_NUMBER := NVL(x_srsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_srsv_rec,                        -- IN
      l_srsv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*
    l_return_status := populate_new_record(l_srsv_rec, l_def_srsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
*/
    l_def_srsv_rec := fill_who_columns(l_srsv_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    /*
    l_return_status := Validate_Attributes(l_def_srsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_srsv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    */
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_srsv_rec, l_srs_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srs_rec,
      lx_srs_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_srs_rec, l_def_srsv_rec);
    x_srsv_rec := l_def_srsv_rec;
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
  -- PL/SQL TBL update_row for:SRSV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type,
    x_srsv_tbl                     OUT NOCOPY srsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srsv_tbl.COUNT > 0) THEN
      i := p_srsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srsv_rec                     => p_srsv_tbl(i),
          x_srsv_rec                     => x_srsv_tbl(i));
    	-- START change : mvasudev, 09/05/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_srsv_tbl.LAST);
        i := p_srsv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 09/05/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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
  --------------------------------------
  -- delete_row for:OKL_SIF_RET_STRMS --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srs_rec                      IN srs_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'STRMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srs_rec                      srs_rec_type:= p_srs_rec;
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
    DELETE FROM OKL_SIF_RET_STRMS
     WHERE ID = l_srs_rec.id;

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
  -- delete_row for:OKL_SIF_RET_STRMS_V --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srsv_rec                     srsv_rec_type := p_srsv_rec;
    l_srs_rec                      srs_rec_type;
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
    migrate(l_srsv_rec, l_srs_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_srs_rec
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
  -- PL/SQL TBL delete_row for:SRSV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_tbl                     IN srsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_srsv_tbl.COUNT > 0) THEN
      i := p_srsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_srsv_rec                     => p_srsv_tbl(i));
    	-- START change : mvasudev, 09/05/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_srsv_tbl.LAST);
        i := p_srsv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 09/05/2001
      -- return overall status
      x_return_status := l_overall_status;
      -- END change : mvasudev
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

--BAKUCHIB Bug#2807737 start
 ---------------------------------------------
 --- insert_row_per for:OKL_SIF_RET_STRMS_V --
 ---------------------------------------------
 -- Start of comments
 -- Procedure Name  : insert_row_per
 -- Description     : Used extend insert_row without having the actuall insert
 --                   into the table
 -- Business Rules  :
 -- Parameters      : Record structure of OKL_SIF_RET_STRMS table
 -- Version         : 1.0
 -- History         : 09-MAY-20023 BAKUCHIB :Added new procedure
 -- End of comments

  PROCEDURE insert_row_per(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_srsv_rec                     IN srsv_rec_type,
    x_srsv_rec                     OUT NOCOPY srsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_srsv_rec                     srsv_rec_type;
    l_def_srsv_rec                 srsv_rec_type;
    l_srs_rec                      srs_rec_type;
    lx_srs_rec                     srs_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------

    FUNCTION fill_who_columns (
      p_srsv_rec	IN srsv_rec_type
    ) RETURN srsv_rec_type IS
      l_srsv_rec	srsv_rec_type := p_srsv_rec;
    BEGIN
      l_srsv_rec.CREATION_DATE := SYSDATE;
      l_srsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_srsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_srsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_srsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_srsv_rec);
    END fill_who_columns;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_RET_STRMS_V --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_srsv_rec IN  srsv_rec_type,
      x_srsv_rec OUT NOCOPY srsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_srsv_rec := p_srsv_rec;
      x_srsv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_srsv_rec := null_out_defaults(p_srsv_rec);
    -- Set primary key value
    l_srsv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_srsv_rec,                        -- IN
      l_def_srsv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_srsv_rec := fill_who_columns(l_def_srsv_rec);
    x_srsv_rec := l_def_srsv_rec;
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

  END insert_row_per;
 ---------------------------------------------
 --- insert_row_upg for:OKL_SIF_RET_STRMS_V --
 ---------------------------------------------
 -- Start of comments
 -- Procedure Name  : insert_row_upg
 -- Description     : Used for the Bulk insert into the OKL_SIF_RET_STRMS table
 -- Business Rules  :
 -- Parameters      : PL/SQL Table  structure of OKL_SIF_RET_STRMS table
 -- Version         : 1.0
 -- History         : 09-MAY-20023 BAKUCHIB :Added new procedure
  PROCEDURE insert_row_upg(p_srsv_tbl srsv_Tbl_type) IS
    l_tabsize                         NUMBER := p_srsv_tbl.COUNT;
    in_id                             Okl_Streams_Util.NumberTabTyp;
    in_stream_type_name               Okl_Streams_Util.Var150TabTyp;
    in_index_number                   Okl_Streams_Util.NumberTabTyp;
    in_activity_type                  Okl_Streams_Util.Var150TabTyp;
    in_sequence_number                Okl_Streams_Util.NumberTabTyp;
    in_sre_date                       Okl_Streams_Util.DateTabTyp;
    in_amount                         Okl_Streams_Util.NumberTabTyp;
    in_sir_id                         Okl_Streams_Util.NumberTabTyp;
    in_stream_int_attribute01         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute02         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute03         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute04         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute05         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute06         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute07         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute08         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute09         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute10         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute11         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute12         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute13         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute14         Okl_Streams_Util.Var450TabTyp;
    in_stream_int_attribute15         Okl_Streams_Util.Var450TabTyp;
    in_object_version_number          Okl_Streams_Util.NumberTabTyp;
    in_created_by                     Okl_Streams_Util.NumberTabTyp;
    in_last_updated_by                Okl_Streams_Util.NumberTabTyp;
    in_creation_date                  Okl_Streams_Util.DateTabTyp;
    in_last_update_date               Okl_Streams_Util.DateTabTyp;
    in_last_update_login              Okl_Streams_Util.NumberTabTyp;
    i number;
    j number;
    --Declaring the temp variables used for assignment purposes
    --Added by KTHIRUVA
    --Bug 4302322 - Start of Changes
    l_created_by                     NUMBER;
    l_last_updated_by                NUMBER;
    l_creation_date                  DATE;
    l_last_update_date               DATE;
    l_last_update_login              NUMBER;
    --End of Changes

  BEGIN
    i := p_srsv_tbl.FIRST; j:=0;
    --Modified by KTHIRUVA
    --Initialising the params
    --Bug No 4302322 - Start Of Changes
      l_created_by := FND_GLOBAL.USER_ID;
      l_last_updated_by := FND_GLOBAL.USER_ID;
      l_creation_date := SYSDATE;
      l_last_update_date := SYSDATE;
      l_last_update_login := FND_GLOBAL.LOGIN_ID;
    --Bug -End of Changes

    WHILE i is not null LOOP
      j:=j+1;
      --Modified by BKATRAGA on 07-Apr-2005
      --Bug No 4302322 - Start of Changes
      --Obtaining the id from the sequence
      in_id(j) :=  get_seq_id;
      --Bug No - End of Changes
      in_stream_type_name(j) :=      p_srsv_tbl(i).stream_type_name;
      in_index_number(j) := p_srsv_tbl(i).index_number;
      in_activity_type(j) := p_srsv_tbl(i).activity_type;
      in_sequence_number(j) := p_srsv_tbl(i).sequence_number;
      in_sre_date(j) := p_srsv_tbl(i).sre_date;
      in_amount(j) := p_srsv_tbl(i).amount;
      in_sir_id(j) := p_srsv_tbl(i).sir_id;
      in_stream_int_attribute01(j) := p_srsv_tbl(i).stream_interface_attribute01;
      in_stream_int_attribute02(j) := p_srsv_tbl(i).stream_interface_attribute02;
      in_stream_int_attribute03(j) := p_srsv_tbl(i).stream_interface_attribute03;
      in_stream_int_attribute04(j) := p_srsv_tbl(i).stream_interface_attribute04;
      in_stream_int_attribute05(j) := p_srsv_tbl(i).stream_interface_attribute05;
      in_stream_int_attribute06(j) := p_srsv_tbl(i).stream_interface_attribute06;
      in_stream_int_attribute07(j) := p_srsv_tbl(i).stream_interface_attribute07;
      in_stream_int_attribute08(j) := p_srsv_tbl(i).stream_interface_attribute08;
      in_stream_int_attribute09(j) := p_srsv_tbl(i).stream_interface_attribute09;
      in_stream_int_attribute10(j) := p_srsv_tbl(i).stream_interface_attribute10;
      in_stream_int_attribute11(j) := p_srsv_tbl(i).stream_interface_attribute11;
      in_stream_int_attribute12(j) := p_srsv_tbl(i).stream_interface_attribute12;
      in_stream_int_attribute13(j) := p_srsv_tbl(i).stream_interface_attribute13;
      in_stream_int_attribute14(j) := p_srsv_tbl(i).stream_interface_attribute14;
      in_stream_int_attribute15(j) := p_srsv_tbl(i).stream_interface_attribute15;
      --Modified by BKATRAGA on 07-Apr-2005
      --Bug No 4302322- Start of Changes
      in_object_version_number(j) := 1;
      in_created_by(j) := l_created_by;
      in_last_updated_by(j) := l_last_updated_by;
      in_creation_date(j) := l_creation_date;
      in_last_update_date(j) := l_last_update_date;
      in_last_update_login(j) := l_last_update_login;
      --Bug No - End of Changes
      i:= p_srsv_tbl.next(i);
    END LOOP;

    FORALL i in 1..l_tabsize
      INSERT INTO OKL_SIF_RET_STRMS(
                  id,
                  stream_type_name,
                  index_number,
                  activity_type,
                  sequence_number,
                  stream_interface_attribute01,
                  stream_interface_attribute02,
                  stream_interface_attribute03,
                  stream_interface_attribute04,
                  stream_interface_attribute05,
                  stream_interface_attribute06,
                  stream_interface_attribute07,
                  stream_interface_attribute08,
                  stream_interface_attribute09,
                  stream_interface_attribute10,
                  stream_interface_attribute11,
                  stream_interface_attribute12,
                  stream_interface_attribute13,
                  stream_interface_attribute14,
                  stream_interface_attribute15,
                  sre_date,
                  amount,
                  sir_id,
                  object_version_number,
                  created_by,
                  last_updated_by,
                  creation_date,
                  last_update_date,
                  last_update_login)
      VALUES (in_id(i),
              in_stream_type_name(i),
              in_index_number(i),
              in_activity_type(i),
              in_sequence_number(i),
              in_stream_int_attribute01(i),
              in_stream_int_attribute02(i),
              in_stream_int_attribute03(i),
              in_stream_int_attribute04(i),
              in_stream_int_attribute05(i),
              in_stream_int_attribute06(i),
              in_stream_int_attribute07(i),
              in_stream_int_attribute08(i),
              in_stream_int_attribute09(i),
              in_stream_int_attribute10(i),
              in_stream_int_attribute11(i),
              in_stream_int_attribute12(i),
              in_stream_int_attribute13(i),
              in_stream_int_attribute14(i),
              in_stream_int_attribute15(i),
              in_sre_date(i),
              in_amount(i),
              in_sir_id(i),
              in_object_version_number(i),
              in_created_by(i),
              in_last_updated_by(i),
              in_creation_date(i),
              in_last_update_date(i),
              in_last_update_login(i));

  END insert_row_upg;
--BAKUCHIB Bug#2807737 End
END OKL_SRS_PVT ;

/
