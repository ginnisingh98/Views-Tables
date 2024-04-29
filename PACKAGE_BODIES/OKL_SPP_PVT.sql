--------------------------------------------------------
--  DDL for Package Body OKL_SPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SPP_PVT" AS
/* $Header: OKLSSPPB.pls 115.5 2002/12/18 13:09:12 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_PRICE_PARMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_spp_rec                      IN spp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN spp_rec_type IS
    CURSOR okl_sif_price_param_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
			VERSION,
            DATE_START,
            DATE_END,
            DESCRIPTION,
            SPS_CODE,
            DYP_CODE,
            ARRAY_YN,
			XML_TAG,
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
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Sif_Price_Parms
     WHERE okl_sif_price_parms.id = p_id;
    l_okl_sif_price_param_pk       okl_sif_price_param_pk_csr%ROWTYPE;
    l_spp_rec                      spp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sif_price_param_pk_csr (p_spp_rec.id);
    FETCH okl_sif_price_param_pk_csr INTO
              l_spp_rec.ID,
              l_spp_rec.OBJECT_VERSION_NUMBER,
              l_spp_rec.NAME,
              l_spp_rec.VERSION,
              l_spp_rec.DATE_START,
              l_spp_rec.DATE_END,
              l_spp_rec.DESCRIPTION,
              l_spp_rec.SPS_CODE,
              l_spp_rec.DYP_CODE,
              l_spp_rec.ARRAY_YN,
              l_spp_rec.XML_TAG,
              l_spp_rec.ATTRIBUTE_CATEGORY,
              l_spp_rec.ATTRIBUTE1,
              l_spp_rec.ATTRIBUTE2,
              l_spp_rec.ATTRIBUTE3,
              l_spp_rec.ATTRIBUTE4,
              l_spp_rec.ATTRIBUTE5,
              l_spp_rec.ATTRIBUTE6,
              l_spp_rec.ATTRIBUTE7,
              l_spp_rec.ATTRIBUTE8,
              l_spp_rec.ATTRIBUTE9,
              l_spp_rec.ATTRIBUTE10,
              l_spp_rec.ATTRIBUTE11,
              l_spp_rec.ATTRIBUTE12,
              l_spp_rec.ATTRIBUTE13,
              l_spp_rec.ATTRIBUTE14,
              l_spp_rec.ATTRIBUTE15,
              l_spp_rec.CREATED_BY,
              l_spp_rec.LAST_UPDATED_BY,
              l_spp_rec.CREATION_DATE,
              l_spp_rec.LAST_UPDATE_DATE,
              l_spp_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_sif_price_param_pk_csr%NOTFOUND;
    CLOSE okl_sif_price_param_pk_csr;
    RETURN(l_spp_rec);
  END get_rec;
  FUNCTION get_rec (
    p_spp_rec                      IN spp_rec_type
  ) RETURN spp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_spp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_PRICE_PARMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sppv_rec                     IN sppv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sppv_rec_type IS
    CURSOR okl_sppv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            NAME,
			VERSION,
            DATE_START,
            DATE_END,
            DESCRIPTION,
            SPS_CODE,
            DYP_CODE,
            ARRAY_YN,
            XML_TAG,
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
            LAST_UPDATED_BY,
            CREATION_DATE,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM OKL_SIF_PRICE_PARMS_V
     WHERE OKL_SIF_PRICE_PARMS_V.id = p_id;
    l_okl_sppv_pk       okl_sppv_pk_csr%ROWTYPE;
    l_sppv_rec                     sppv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_sppv_pk_csr (p_sppv_rec.id);
    FETCH okl_sppv_pk_csr INTO
              l_sppv_rec.ID,
              l_sppv_rec.OBJECT_VERSION_NUMBER,
              l_sppv_rec.NAME,
              l_sppv_rec.VERSION,
              l_sppv_rec.DATE_START,
              l_sppv_rec.DATE_END,
              l_sppv_rec.DESCRIPTION,
              l_sppv_rec.SPS_CODE,
              l_sppv_rec.DYP_CODE,
              l_sppv_rec.ARRAY_YN,
              l_sppv_rec.XML_TAG,
              l_sppv_rec.ATTRIBUTE_CATEGORY,
              l_sppv_rec.ATTRIBUTE1,
              l_sppv_rec.ATTRIBUTE2,
              l_sppv_rec.ATTRIBUTE3,
              l_sppv_rec.ATTRIBUTE4,
              l_sppv_rec.ATTRIBUTE5,
              l_sppv_rec.ATTRIBUTE6,
              l_sppv_rec.ATTRIBUTE7,
              l_sppv_rec.ATTRIBUTE8,
              l_sppv_rec.ATTRIBUTE9,
              l_sppv_rec.ATTRIBUTE10,
              l_sppv_rec.ATTRIBUTE11,
              l_sppv_rec.ATTRIBUTE12,
              l_sppv_rec.ATTRIBUTE13,
              l_sppv_rec.ATTRIBUTE14,
              l_sppv_rec.ATTRIBUTE15,
              l_sppv_rec.CREATED_BY,
              l_sppv_rec.LAST_UPDATED_BY,
              l_sppv_rec.CREATION_DATE,
              l_sppv_rec.LAST_UPDATE_DATE,
              l_sppv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_sppv_pk_csr%NOTFOUND;
    CLOSE okl_sppv_pk_csr;
    RETURN(l_sppv_rec);
  END get_rec;
  FUNCTION get_rec (
    p_sppv_rec                     IN sppv_rec_type
  ) RETURN sppv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sppv_rec, l_row_notfound));
  END get_rec;
  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_PRICE_PARMS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_sppv_rec	IN sppv_rec_type
  ) RETURN sppv_rec_type IS
    l_sppv_rec	sppv_rec_type := p_sppv_rec;
  BEGIN
    IF (l_sppv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_sppv_rec.id := NULL;
    END IF;
    IF (l_sppv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sppv_rec.object_version_number := NULL;
    END IF;
    IF (l_sppv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.name := NULL;
    END IF;
    IF (l_sppv_rec.version = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.version := NULL;
    END IF;
    IF (l_sppv_rec.date_start = OKC_API.G_MISS_DATE) THEN
      l_sppv_rec.date_start := NULL;
    END IF;
    IF (l_sppv_rec.date_end = OKC_API.G_MISS_DATE) THEN
      l_sppv_rec.date_end := NULL;
    END IF;
    IF (l_sppv_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.description := NULL;
    END IF;
    IF (l_sppv_rec.sps_code = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.sps_code := NULL;
    END IF;
    IF (l_sppv_rec.dyp_code = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.dyp_code := NULL;
    END IF;
    IF (l_sppv_rec.array_yn = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.array_yn := NULL;
    END IF;
    IF (l_sppv_rec.xml_tag = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.xml_tag := NULL;
    END IF;
    IF (l_sppv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute_category := NULL;
    END IF;
    IF (l_sppv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute1 := NULL;
    END IF;
    IF (l_sppv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute2 := NULL;
    END IF;
    IF (l_sppv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute3 := NULL;
    END IF;
    IF (l_sppv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute4 := NULL;
    END IF;
    IF (l_sppv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute5 := NULL;
    END IF;
    IF (l_sppv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute6 := NULL;
    END IF;
    IF (l_sppv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute7 := NULL;
    END IF;
    IF (l_sppv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute8 := NULL;
    END IF;
    IF (l_sppv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute9 := NULL;
    END IF;
    IF (l_sppv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute10 := NULL;
    END IF;
    IF (l_sppv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute11 := NULL;
    END IF;
    IF (l_sppv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute12 := NULL;
    END IF;
    IF (l_sppv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute13 := NULL;
    END IF;
    IF (l_sppv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute14 := NULL;
    END IF;
    IF (l_sppv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_sppv_rec.attribute15 := NULL;
    END IF;
    IF (l_sppv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sppv_rec.created_by := NULL;
    END IF;
    IF (l_sppv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sppv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sppv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sppv_rec.creation_date := NULL;
    END IF;
    IF (l_sppv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sppv_rec.last_update_date := NULL;
    END IF;
    IF (l_sppv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sppv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_sppv_rec);
  END null_out_defaults;
  -- START change : mvasudev , 08/16/2001
  /*
  -- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_SIF_PRICE_PARMS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_sppv_rec IN  sppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sppv_rec.id = OKC_API.G_MISS_NUM OR
       p_sppv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.date_start = OKC_API.G_MISS_DATE OR
          p_sppv_rec.date_start IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'date_start');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.name = OKC_API.G_MISS_CHAR OR
          p_sppv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.sps_code = OKC_API.G_MISS_CHAR OR
          p_sppv_rec.sps_code IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'sps_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.dyp_code = OKC_API.G_MISS_CHAR OR
          p_sppv_rec.dyp_code IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dyp_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.array_yn = OKC_API.G_MISS_CHAR OR
          p_sppv_rec.array_yn IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'array_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sppv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sppv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_SIF_PRICE_PARMS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_sppv_rec IN sppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
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
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.id = Okc_Api.G_MISS_NUM OR
      p_sppv_rec.id IS NULL
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
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_sppv_rec.object_version_number IS NULL
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
  -- PROCEDURE Validate_Date_Start
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_Start
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Date_Start(
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.Date_Start = Okc_Api.G_MISS_DATE OR
       p_sppv_rec.Date_Start IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Date_Start');
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
  END Validate_Date_Start;
  ------------------------------------------------------------------------------
  -- PROCEDURE Validate_Date_End
  ------------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Date_End
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ------------------------------------------------------------------------------
  PROCEDURE Validate_Date_End(
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2)
  IS
  l_return_status         VARCHAR2(1)  := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    -- check for data before processing
	IF   p_sppv_rec.date_end <> OKC_API.G_MISS_DATE AND p_sppv_rec.date_end IS NOT NULL
	THEN
	    IF 	p_sppv_rec.date_end  < p_sppv_rec.date_start
	    THEN
	      Okc_Api.SET_MESSAGE( p_app_name   => G_OKC_APP,
                           p_msg_name       => g_invalid_value,
                           p_token1         => g_col_name_token,
                           p_token1_value   => 'Date_End' );
       x_return_status    := Okc_Api.G_RET_STS_ERROR;
       RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing required ; validation can continue
    -- with the next column
    NULL;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      Okc_Api.SET_MESSAGE(p_app_name     => G_OKC_APP
                         ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                         ,p_token1       => G_OKL_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_OKL_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Date_End;
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
  PROCEDURE Validate_Name(
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.Name = Okc_Api.G_MISS_CHAR OR
       p_sppv_rec.Name IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Name');
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
  END Validate_Name;
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
  PROCEDURE Validate_Version(
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.Version = Okc_Api.G_MISS_CHAR OR
       p_sppv_rec.Version IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Version');
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
  END Validate_Version;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Sps_Code
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : mvasudev
    -- Procedure Name  : Validate_Sps_Code
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Sps_Code(
      p_sppv_rec IN  sppv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    )  IS

    l_found VARCHAR2(1);

    BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	     -- check for data before processing
	IF (p_sppv_rec.sps_code IS NULL) OR
		(p_sppv_rec .sps_code  = Okc_Api.G_MISS_CHAR) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
			     ,p_msg_name       => g_required_value
			     ,p_token1         => g_col_name_token
			     ,p_token1_value   => 'SPS_CODE');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;
    	ELSE
		--Check if sps_code exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_PRICE_PARAMS_SPS_CODE',
															p_lookup_code => p_sppv_rec.sps_code);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPS_CODE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;
	END IF;
    EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
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
    END Validate_Sps_Code;
    ---------------------------------------------------------------------------
    -- PROCEDURE Validate_Dyp_Code
    --------------------------------------------------------------------------
    -- Start of comments
    -- Author          : mvasudev
    -- Procedure Name  : Validate_Dyp_Code
    -- Description     :
    -- Business Rules  :
    -- Parameters      :
    -- Version         : 1.0
    -- End of comments
    ---------------------------------------------------------------------------
    PROCEDURE Validate_Dyp_Code(
      p_sppv_rec IN  sppv_rec_type,
      x_return_status OUT NOCOPY  VARCHAR2
    )  IS

    l_found  VARCHAR2(1);

    BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;
	     -- check for data before processing
	IF (p_sppv_rec.dyp_code IS NULL) OR
		(p_sppv_rec .dyp_code  = Okc_Api.G_MISS_CHAR) THEN
	  Okc_Api.SET_MESSAGE(p_app_name       => G_OKC_APP
			     ,p_msg_name       => g_required_value
			     ,p_token1         => g_col_name_token
			     ,p_token1_value   => 'DYP_CODE');
	  x_return_status    := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;
    	ELSIF p_sppv_rec.dyp_code IS NOT NULL THEN
		--Check if dyp_code exists in the fnd_common_lookups or not
        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'OKL_PRICE_PARAMS_DYP_CODE',
															p_lookup_code => p_sppv_rec.dyp_code);


		IF (l_found <> OKL_API.G_TRUE ) THEN
             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SPS_CODE');
		     x_return_status := Okc_Api.G_RET_STS_ERROR;
			 -- raise the exception as there's no matching foreign key value
			 RAISE G_EXCEPTION_HALT_VALIDATION;
	 	END IF;
	END IF;
    EXCEPTION
	    	WHEN G_EXCEPTION_HALT_VALIDATION THEN
	    	 -- no processing necessary;  validation can continue
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
    END Validate_Dyp_Code;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Array_Yn
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Array_Yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Array_Yn(
    p_sppv_rec      IN   sppv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  l_found VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    IF p_sppv_rec.Array_Yn = Okc_Api.G_MISS_CHAR OR
       p_sppv_rec.Array_Yn IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Array_Yn');
      x_return_status := Okc_Api.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
	        l_found := okl_accounting_util.validate_lookup_code(p_lookup_type => 'YES_NO',
   															  p_lookup_code => p_sppv_rec.Array_yn,
															  p_app_id 		=> 0,
															  p_view_app_id => 0);


			IF (l_found <> OKL_API.G_TRUE ) THEN
	             OKC_API.set_message(G_OKC_APP, G_INVALID_VALUE,G_COL_NAME_TOKEN,'Array_YN');
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
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END Validate_Array_Yn;
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
    p_sppv_rec IN  sppv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    -- Validate_Id
    Validate_Id(p_sppv_rec, x_return_status);
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
    Validate_Object_Version_Number(p_sppv_rec, x_return_status);
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
    -- Validate_Name
    Validate_Name(p_sppv_rec, x_return_status);
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
    -- Validate_Version
    Validate_Version(p_sppv_rec, x_return_status);
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
    -- Validate_Date_Start
    Validate_Date_Start(p_sppv_rec, x_return_status);
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
    -- Validate_Date_End
    Validate_Date_End(p_sppv_rec, x_return_status);
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
    -- Validate_Sps_Code
    Validate_Sps_Code(p_sppv_rec, x_return_status);
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
    -- Validate_Dyp_Code
    Validate_Dyp_Code(p_sppv_rec, x_return_status);
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
    -- Validate_Array_Yn
    Validate_Array_Yn(p_sppv_rec, x_return_status);
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
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
    RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Spp_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Spp_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Spp_Record(p_sppv_rec      IN      sppv_rec_type
                                       ,x_return_status OUT NOCOPY     VARCHAR2)
  IS
  l_dummy		VARCHAR2(1)	:= '?';
  l_row_found		BOOLEAN 	:= FALSE;
  -- Cursor for spp Unique Key
  CURSOR okl_spp_uk_csr(p_rec sppv_rec_type) IS
  SELECT '1'
  FROM okl_sif_price_parms_v
  WHERE name				= p_rec.name
  AND   version				= p_rec.version
  AND   id     <> NVL(p_rec.id,-9999);
  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;
    OPEN okl_spp_uk_csr(p_sppv_rec);
    FETCH okl_spp_uk_csr INTO l_dummy;
    l_row_found := okl_spp_uk_csr%FOUND;
    CLOSE okl_spp_uk_csr;
    IF l_row_found THEN
	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	x_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
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
  END Validate_Unique_spp_Record;
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
    p_sppv_rec IN sppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
  BEGIN
    -- Validate_Unique_Spp_Record
    Validate_Unique_Spp_Record(p_sppv_rec, x_return_status);
    IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
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
       -- exit with return status
       NULL;
       RETURN (l_return_status);
    WHEN OTHERS THEN
       -- store SQL error message on message stack for caller
    Okc_Api.SET_MESSAGE(p_app_name     => G_APP_NAME
                       ,p_msg_name     => G_OKL_UNEXPECTED_ERROR
                       ,p_token1       => G_OKL_SQLCODE_TOKEN
                       ,p_token1_value => SQLCODE
                       ,p_token2       => G_OKL_SQLERRM_TOKEN
                       ,p_token2_value => SQLERRM);
       -- notify caller of an UNEXPECTED error
       l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);
  END Validate_Record;
  -- END change : mvasudev
  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sppv_rec_type,
    --p_to	OUT NOCOPY spp_rec_type
    p_to	IN OUT NOCOPY spp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.date_start := p_from.date_start;
    p_to.date_end := p_from.date_end;
    p_to.description := p_from.description;
    p_to.sps_code := p_from.sps_code;
    p_to.dyp_code := p_from.dyp_code;
    p_to.array_yn := p_from.array_yn;
    p_to.xml_tag := p_from.xml_tag;
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
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN spp_rec_type,
    --p_to	OUT NOCOPY sppv_rec_type
    p_to	IN OUT NOCOPY sppv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.name := p_from.name;
    p_to.version := p_from.version;
    p_to.date_start := p_from.date_start;
    p_to.date_end := p_from.date_end;
    p_to.description := p_from.description;
    p_to.sps_code := p_from.sps_code;
    p_to.dyp_code := p_from.dyp_code;
    p_to.array_yn := p_from.array_yn;
    p_to.xml_tag := p_from.xml_tag;
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
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKL_SIF_PRICE_PARMS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sppv_rec                     sppv_rec_type := p_sppv_rec;
    l_spp_rec                      spp_rec_type;
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
    l_return_status := Validate_Attributes(l_sppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sppv_rec);
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
  -- PL/SQL TBL validate_row for:SPPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/16/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sppv_tbl.COUNT > 0) THEN
      i := p_sppv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sppv_rec                     => p_sppv_tbl(i));
    	-- START change : mvasudev, 08/16/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sppv_tbl.LAST);
        i := p_sppv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/16/2001
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
  ----------------------------------------
  -- insert_row for:OKL_SIF_PRICE_PARMS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spp_rec                      IN spp_rec_type,
    x_spp_rec                      OUT NOCOPY spp_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spp_rec                      spp_rec_type := p_spp_rec;
    l_def_spp_rec                  spp_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICE_PARMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_spp_rec IN  spp_rec_type,
      x_spp_rec OUT NOCOPY spp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spp_rec := p_spp_rec;
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
      p_spp_rec,                         -- IN
      l_spp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_PRICE_PARMS(
        id,
        object_version_number,
        name,
		version,
        date_start,
        date_end,
        description,
        sps_code,
        dyp_code,
        array_yn,
        xml_tag,
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
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login)
      VALUES (
        l_spp_rec.id,
        l_spp_rec.object_version_number,
        l_spp_rec.name,
        l_spp_rec.version,
        l_spp_rec.date_start,
        l_spp_rec.date_end,
        l_spp_rec.description,
        l_spp_rec.sps_code,
        l_spp_rec.dyp_code,
        l_spp_rec.array_yn,
        l_spp_rec.xml_tag,
        l_spp_rec.attribute_category,
        l_spp_rec.attribute1,
        l_spp_rec.attribute2,
        l_spp_rec.attribute3,
        l_spp_rec.attribute4,
        l_spp_rec.attribute5,
        l_spp_rec.attribute6,
        l_spp_rec.attribute7,
        l_spp_rec.attribute8,
        l_spp_rec.attribute9,
        l_spp_rec.attribute10,
        l_spp_rec.attribute11,
        l_spp_rec.attribute12,
        l_spp_rec.attribute13,
        l_spp_rec.attribute14,
        l_spp_rec.attribute15,
        l_spp_rec.created_by,
        l_spp_rec.last_updated_by,
        l_spp_rec.creation_date,
        l_spp_rec.last_update_date,
        l_spp_rec.last_update_login);
    -- Set OUT values
    x_spp_rec := l_spp_rec;
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
  ------------------------------------------
  -- insert_row for:OKL_SIF_PRICE_PARMS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sppv_rec                     sppv_rec_type;
    l_def_sppv_rec                 sppv_rec_type;
    l_spp_rec                      spp_rec_type;
    lx_spp_rec                     spp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sppv_rec	IN sppv_rec_type
    ) RETURN sppv_rec_type IS
      l_sppv_rec	sppv_rec_type := p_sppv_rec;
    BEGIN
      l_sppv_rec.CREATION_DATE := SYSDATE;
      l_sppv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sppv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sppv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sppv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sppv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICE_PARMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sppv_rec IN  sppv_rec_type,
      x_sppv_rec OUT NOCOPY sppv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sppv_rec := p_sppv_rec;
      x_sppv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_sppv_rec := null_out_defaults(p_sppv_rec);
    -- Set primary key value
    l_sppv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sppv_rec,                        -- IN
      l_def_sppv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sppv_rec := fill_who_columns(l_def_sppv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sppv_rec, l_spp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spp_rec,
      lx_spp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_spp_rec, l_def_sppv_rec);
    -- Set OUT values
    x_sppv_rec := l_def_sppv_rec;
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
  -- PL/SQL TBL insert_row for:SPPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/16/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sppv_tbl.COUNT > 0) THEN
      i := p_sppv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sppv_rec                     => p_sppv_tbl(i),
          x_sppv_rec                     => x_sppv_tbl(i));
    	-- START change : mvasudev, 08/16/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sppv_tbl.LAST);
        i := p_sppv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/16/2001
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
  --------------------------------------
  -- lock_row for:OKL_SIF_PRICE_PARMS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spp_rec                      IN spp_rec_type) IS
    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_spp_rec IN spp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_PRICE_PARMS
     WHERE ID = p_spp_rec.id
       AND OBJECT_VERSION_NUMBER = p_spp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;
    CURSOR  lchk_csr (p_spp_rec IN spp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_PRICE_PARMS
    WHERE ID = p_spp_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_PRICE_PARMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_PRICE_PARMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_spp_rec);
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
      OPEN lchk_csr(p_spp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_spp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_spp_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_SIF_PRICE_PARMS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spp_rec                      spp_rec_type;
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
    migrate(p_sppv_rec, l_spp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spp_rec
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
  -- PL/SQL TBL lock_row for:SPPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/16/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sppv_tbl.COUNT > 0) THEN
      i := p_sppv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sppv_rec                     => p_sppv_tbl(i));
    	-- START change : mvasudev, 08/16/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sppv_tbl.LAST);
        i := p_sppv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/16/2001
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
  ----------------------------------------
  -- update_row for:OKL_SIF_PRICE_PARMS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spp_rec                      IN spp_rec_type,
    x_spp_rec                      OUT NOCOPY spp_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spp_rec                      spp_rec_type := p_spp_rec;
    l_def_spp_rec                  spp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_spp_rec	IN spp_rec_type,
      x_spp_rec	OUT NOCOPY spp_rec_type
    ) RETURN VARCHAR2 IS
      l_spp_rec                      spp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spp_rec := p_spp_rec;
      -- Get current database values
      l_spp_rec := get_rec(p_spp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_spp_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_spp_rec.id := l_spp_rec.id;
      END IF;
      IF (x_spp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_spp_rec.object_version_number := l_spp_rec.object_version_number;
      END IF;
      IF (x_spp_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.name := l_spp_rec.name;
      END IF;
      IF (x_spp_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.version := l_spp_rec.version;
      END IF;
      IF (x_spp_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_spp_rec.date_start := l_spp_rec.date_start;
      END IF;
      IF (x_spp_rec.date_end = OKC_API.G_MISS_DATE)
      THEN
        x_spp_rec.date_end := l_spp_rec.date_end;
      END IF;
      IF (x_spp_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.description := l_spp_rec.description;
      END IF;
      IF (x_spp_rec.sps_code = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.sps_code := l_spp_rec.sps_code;
      END IF;
      IF (x_spp_rec.dyp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.dyp_code := l_spp_rec.dyp_code;
      END IF;
      IF (x_spp_rec.array_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.array_yn := l_spp_rec.array_yn;
      END IF;
      IF (x_spp_rec.xml_tag = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.xml_tag := l_spp_rec.xml_tag;
      END IF;
      IF (x_spp_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute_category := l_spp_rec.attribute_category;
      END IF;
      IF (x_spp_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute1 := l_spp_rec.attribute1;
      END IF;
      IF (x_spp_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute2 := l_spp_rec.attribute2;
      END IF;
      IF (x_spp_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute3 := l_spp_rec.attribute3;
      END IF;
      IF (x_spp_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute4 := l_spp_rec.attribute4;
      END IF;
      IF (x_spp_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute5 := l_spp_rec.attribute5;
      END IF;
      IF (x_spp_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute6 := l_spp_rec.attribute6;
      END IF;
      IF (x_spp_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute7 := l_spp_rec.attribute7;
      END IF;
      IF (x_spp_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute8 := l_spp_rec.attribute8;
      END IF;
      IF (x_spp_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute9 := l_spp_rec.attribute9;
      END IF;
      IF (x_spp_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute10 := l_spp_rec.attribute10;
      END IF;
      IF (x_spp_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute11 := l_spp_rec.attribute11;
      END IF;
      IF (x_spp_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute12 := l_spp_rec.attribute12;
      END IF;
      IF (x_spp_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute13 := l_spp_rec.attribute13;
      END IF;
      IF (x_spp_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute14 := l_spp_rec.attribute14;
      END IF;
      IF (x_spp_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_spp_rec.attribute15 := l_spp_rec.attribute15;
      END IF;
      IF (x_spp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_spp_rec.created_by := l_spp_rec.created_by;
      END IF;
      IF (x_spp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_spp_rec.last_updated_by := l_spp_rec.last_updated_by;
      END IF;
      IF (x_spp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_spp_rec.creation_date := l_spp_rec.creation_date;
      END IF;
      IF (x_spp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_spp_rec.last_update_date := l_spp_rec.last_update_date;
      END IF;
      IF (x_spp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_spp_rec.last_update_login := l_spp_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICE_PARMS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_spp_rec IN  spp_rec_type,
      x_spp_rec OUT NOCOPY spp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_spp_rec := p_spp_rec;
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
      p_spp_rec,                         -- IN
      l_spp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_spp_rec, l_def_spp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_PRICE_PARMS
    SET OBJECT_VERSION_NUMBER = l_def_spp_rec.object_version_number,
        NAME = l_def_spp_rec.name,
        version = l_def_spp_rec.version,
        DATE_START = l_def_spp_rec.date_start,
        DATE_END = l_def_spp_rec.date_end,
        DESCRIPTION = l_def_spp_rec.description,
        SPS_CODE = l_def_spp_rec.sps_code,
        DYP_CODE = l_def_spp_rec.dyp_code,
        ARRAY_YN = l_def_spp_rec.array_yn,
        XML_TAG = l_def_spp_rec.xml_tag,
		ATTRIBUTE_CATEGORY = l_def_spp_rec.attribute_category,
		ATTRIBUTE1 = l_def_spp_rec.attribute1,
		ATTRIBUTE2 = l_def_spp_rec.attribute2,
		ATTRIBUTE3 = l_def_spp_rec.attribute3,
		ATTRIBUTE4 = l_def_spp_rec.attribute4,
		ATTRIBUTE5 = l_def_spp_rec.attribute5,
		ATTRIBUTE6 = l_def_spp_rec.attribute6,
		ATTRIBUTE7 = l_def_spp_rec.attribute7,
		ATTRIBUTE8 = l_def_spp_rec.attribute8,
		ATTRIBUTE9 = l_def_spp_rec.attribute9,
		ATTRIBUTE10 = l_def_spp_rec.attribute10,
		ATTRIBUTE11 = l_def_spp_rec.attribute11,
		ATTRIBUTE12 = l_def_spp_rec.attribute12,
		ATTRIBUTE13 = l_def_spp_rec.attribute13,
		ATTRIBUTE14 = l_def_spp_rec.attribute14,
		ATTRIBUTE15 = l_def_spp_rec.attribute15,
        CREATED_BY = l_def_spp_rec.created_by,
        LAST_UPDATED_BY = l_def_spp_rec.last_updated_by,
        CREATION_DATE = l_def_spp_rec.creation_date,
        LAST_UPDATE_DATE = l_def_spp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_spp_rec.last_update_login
    WHERE ID = l_def_spp_rec.id;
    x_spp_rec := l_def_spp_rec;
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
  ------------------------------------------
  -- update_row for:OKL_SIF_PRICE_PARMS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type,
    x_sppv_rec                     OUT NOCOPY sppv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sppv_rec                     sppv_rec_type := p_sppv_rec;
    l_def_sppv_rec                 sppv_rec_type;
    l_spp_rec                      spp_rec_type;
    lx_spp_rec                     spp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sppv_rec	IN sppv_rec_type
    ) RETURN sppv_rec_type IS
      l_sppv_rec	sppv_rec_type := p_sppv_rec;
    BEGIN
      l_sppv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sppv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sppv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sppv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sppv_rec	IN sppv_rec_type,
      x_sppv_rec	OUT NOCOPY sppv_rec_type
    ) RETURN VARCHAR2 IS
      l_sppv_rec                     sppv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sppv_rec := p_sppv_rec;
      -- Get current database values
      l_sppv_rec := get_rec(p_sppv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sppv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sppv_rec.id := l_sppv_rec.id;
      END IF;
      IF (x_sppv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sppv_rec.object_version_number := l_sppv_rec.object_version_number;
      END IF;
      IF (x_sppv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.name := l_sppv_rec.name;
      END IF;
      IF (x_sppv_rec.version = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.version	 := l_sppv_rec.version;
      END IF;
      IF (x_sppv_rec.date_start = OKC_API.G_MISS_DATE)
      THEN
        x_sppv_rec.date_start := l_sppv_rec.date_start;
      END IF;
      IF (x_sppv_rec.date_end = OKC_API.G_MISS_DATE)
      THEN
        x_sppv_rec.date_end := l_sppv_rec.date_end;
      END IF;
      IF (x_sppv_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.description := l_sppv_rec.description;
      END IF;
      IF (x_sppv_rec.sps_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.sps_code := l_sppv_rec.sps_code;
      END IF;
      IF (x_sppv_rec.dyp_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.dyp_code := l_sppv_rec.dyp_code;
      END IF;
      IF (x_sppv_rec.array_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.array_yn := l_sppv_rec.array_yn;
      END IF;
      IF (x_sppv_rec.xml_tag = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.xml_tag := l_sppv_rec.xml_tag;
      END IF;
      IF (x_sppv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute_category := l_sppv_rec.attribute_category;
      END IF;
      IF (x_sppv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute1 := l_sppv_rec.attribute1;
      END IF;
      IF (x_sppv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute2 := l_sppv_rec.attribute2;
      END IF;
      IF (x_sppv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute3 := l_sppv_rec.attribute3;
      END IF;
      IF (x_sppv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute4 := l_sppv_rec.attribute4;
      END IF;
      IF (x_sppv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute5 := l_sppv_rec.attribute5;
      END IF;
      IF (x_sppv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute6 := l_sppv_rec.attribute6;
      END IF;
      IF (x_sppv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute7 := l_sppv_rec.attribute7;
      END IF;
      IF (x_sppv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute8 := l_sppv_rec.attribute8;
      END IF;
      IF (x_sppv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute9 := l_sppv_rec.attribute9;
      END IF;
      IF (x_sppv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute10 := l_sppv_rec.attribute10;
      END IF;
      IF (x_sppv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute11 := l_sppv_rec.attribute11;
      END IF;
      IF (x_sppv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute12 := l_sppv_rec.attribute12;
      END IF;
      IF (x_sppv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute13 := l_sppv_rec.attribute13;
      END IF;
      IF (x_sppv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute14 := l_sppv_rec.attribute14;
      END IF;
      IF (x_sppv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sppv_rec.attribute15 := l_sppv_rec.attribute15;
      END IF;
      IF (x_sppv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sppv_rec.created_by := l_sppv_rec.created_by;
      END IF;
      IF (x_sppv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sppv_rec.last_updated_by := l_sppv_rec.last_updated_by;
      END IF;
      IF (x_sppv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sppv_rec.creation_date := l_sppv_rec.creation_date;
      END IF;
      IF (x_sppv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sppv_rec.last_update_date := l_sppv_rec.last_update_date;
      END IF;
      IF (x_sppv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sppv_rec.last_update_login := l_sppv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_SIF_PRICE_PARMS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_sppv_rec IN  sppv_rec_type,
      x_sppv_rec OUT NOCOPY sppv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sppv_rec := p_sppv_rec;
      x_sppv_rec.OBJECT_VERSION_NUMBER := NVL(x_sppv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sppv_rec,                        -- IN
      l_sppv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sppv_rec, l_def_sppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sppv_rec := fill_who_columns(l_def_sppv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sppv_rec, l_spp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spp_rec,
      lx_spp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_spp_rec, l_def_sppv_rec);
    x_sppv_rec := l_def_sppv_rec;
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
  -- PL/SQL TBL update_row for:SPPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type,
    x_sppv_tbl                     OUT NOCOPY sppv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/16/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sppv_tbl.COUNT > 0) THEN
      i := p_sppv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sppv_rec                     => p_sppv_tbl(i),
          x_sppv_rec                     => x_sppv_tbl(i));
    	-- START change : mvasudev, 08/16/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sppv_tbl.LAST);
        i := p_sppv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/16/2001
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
  ----------------------------------------
  -- delete_row for:OKL_SIF_PRICE_PARMS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_spp_rec                      IN spp_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_spp_rec                      spp_rec_type:= p_spp_rec;
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
    DELETE FROM OKL_SIF_PRICE_PARMS
     WHERE ID = l_spp_rec.id;
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
  ------------------------------------------
  -- delete_row for:OKL_SIF_PRICE_PARMS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_rec                     IN sppv_rec_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sppv_rec                     sppv_rec_type := p_sppv_rec;
    l_spp_rec                      spp_rec_type;
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
    migrate(l_sppv_rec, l_spp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_spp_rec
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
  -- PL/SQL TBL delete_row for:SPPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sppv_tbl                     IN sppv_tbl_type) IS
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : mvasudev, 08/16/2001
    -- Adding OverAll Status Flag
    l_overall_status 		  VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : mvasudev
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sppv_tbl.COUNT > 0) THEN
      i := p_sppv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sppv_rec                     => p_sppv_tbl(i));
    	-- START change : mvasudev, 08/16/2001
    	-- store the highest degree of error
    	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
    	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
    	    	l_overall_status := x_return_status;
    	    END IF;
    	END IF;
	-- END change : mvasudev
        EXIT WHEN (i = p_sppv_tbl.LAST);
        i := p_sppv_tbl.NEXT(i);
      END LOOP;
      -- START change : mvasudev, 08/16/2001
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
END OKL_SPP_PVT;

/
