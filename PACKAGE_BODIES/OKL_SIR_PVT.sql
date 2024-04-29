--------------------------------------------------------
--  DDL for Package Body OKL_SIR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_SIR_PVT" AS
/* $Header: OKLSSIRB.pls 115.10 2002/12/18 13:08:18 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_SIF_RETS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sir_rec                      IN sir_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sir_rec_type IS
    CURSOR sir_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TRANSACTION_NUMBER,
            SRT_CODE,
            EFFECTIVE_PRE_TAX_YIELD,
            YIELD_NAME,
            INDEX_NUMBER,
            EFFECTIVE_AFTER_TAX_YIELD,
            NOMINAL_PRE_TAX_YIELD,
            NOMINAL_AFTER_TAX_YIELD,
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
            LAST_UPDATE_LOGIN,
            IMPLICIT_INTEREST_RATE,
            DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
            -- end,mvasudev -- 02/21/2002
      FROM Okl_Sif_Rets
     WHERE okl_sif_rets.id      = p_id;
    l_sir_pk                       sir_pk_csr%ROWTYPE;
    l_sir_rec                      sir_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sir_pk_csr (p_sir_rec.id);
    FETCH sir_pk_csr INTO
              l_sir_rec.ID,
              l_sir_rec.TRANSACTION_NUMBER,
              l_sir_rec.SRT_CODE,
              l_sir_rec.EFFECTIVE_PRE_TAX_YIELD,
              l_sir_rec.YIELD_NAME,
              l_sir_rec.INDEX_NUMBER,
              l_sir_rec.EFFECTIVE_AFTER_TAX_YIELD,
              l_sir_rec.NOMINAL_PRE_TAX_YIELD,
              l_sir_rec.NOMINAL_AFTER_TAX_YIELD,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_sir_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sir_rec.OBJECT_VERSION_NUMBER,
              l_sir_rec.CREATED_BY,
              l_sir_rec.LAST_UPDATED_BY,
              l_sir_rec.CREATION_DATE,
              l_sir_rec.LAST_UPDATE_DATE,
              l_sir_rec.LAST_UPDATE_LOGIN,
              l_sir_rec.IMPLICIT_INTEREST_RATE,
              l_sir_rec.DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sir_rec.REQUEST_ID,
            l_sir_rec.PROGRAM_APPLICATION_ID,
            l_sir_rec.PROGRAM_ID,
            l_sir_rec.PROGRAM_UPDATE_DATE;
            -- end,mvasudev -- 02/21/2002

    x_no_data_found := sir_pk_csr%NOTFOUND;
    CLOSE sir_pk_csr;
    RETURN(l_sir_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sir_rec                      IN sir_rec_type
  ) RETURN sir_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sir_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_SIF_RETS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_sirv_rec                     IN sirv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN sirv_rec_type IS
    CURSOR sirv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            TRANSACTION_NUMBER,
            SRT_CODE,
            EFFECTIVE_PRE_TAX_YIELD,
            YIELD_NAME,
            INDEX_NUMBER,
            EFFECTIVE_AFTER_TAX_YIELD,
            NOMINAL_PRE_TAX_YIELD,
            NOMINAL_AFTER_TAX_YIELD,
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
            LAST_UPDATE_LOGIN,
            IMPLICIT_INTEREST_RATE,
            DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
            -- end,mvasudev -- 02/21/2002
      FROM Okl_Sif_Rets_V
     WHERE okl_sif_rets_v.id    = p_id;
    l_sirv_pk                      sirv_pk_csr%ROWTYPE;
    l_sirv_rec                     sirv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN sirv_pk_csr (p_sirv_rec.id);
    FETCH sirv_pk_csr INTO
              l_sirv_rec.ID,
              l_sirv_rec.TRANSACTION_NUMBER,
              l_sirv_rec.SRT_CODE,
              l_sirv_rec.EFFECTIVE_PRE_TAX_YIELD,
              l_sirv_rec.YIELD_NAME,
              l_sirv_rec.INDEX_NUMBER,
              l_sirv_rec.EFFECTIVE_AFTER_TAX_YIELD,
              l_sirv_rec.NOMINAL_PRE_TAX_YIELD,
              l_sirv_rec.NOMINAL_AFTER_TAX_YIELD,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE01,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE02,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE03,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE04,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE05,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE06,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE07,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE08,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE09,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE10,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE11,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE12,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE13,
			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE14,
   			  l_sirv_rec.STREAM_INTERFACE_ATTRIBUTE15,
              l_sirv_rec.OBJECT_VERSION_NUMBER,
              l_sirv_rec.CREATED_BY,
              l_sirv_rec.LAST_UPDATED_BY,
              l_sirv_rec.CREATION_DATE,
              l_sirv_rec.LAST_UPDATE_DATE,
              l_sirv_rec.LAST_UPDATE_LOGIN,
              l_sirv_rec.IMPLICIT_INTEREST_RATE,
              l_sirv_rec.DATE_PROCESSED,
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
            l_sirv_rec.REQUEST_ID,
            l_sirv_rec.PROGRAM_APPLICATION_ID,
            l_sirv_rec.PROGRAM_ID,
            l_sirv_rec.PROGRAM_UPDATE_DATE;
            -- end,mvasudev -- 02/21/2002

    x_no_data_found := sirv_pk_csr%NOTFOUND;
    CLOSE sirv_pk_csr;
    RETURN(l_sirv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_sirv_rec                     IN sirv_rec_type
  ) RETURN sirv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_sirv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_SIF_RETS_V --
  ----------------------------------------------------
  FUNCTION null_out_defaults (
    p_sirv_rec	IN sirv_rec_type
  ) RETURN sirv_rec_type IS
    l_sirv_rec	sirv_rec_type := p_sirv_rec;
  BEGIN
    IF (l_sirv_rec.transaction_number = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.transaction_number := NULL;
    END IF;
    IF (l_sirv_rec.srt_code = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.srt_code := NULL;
    END IF;
    IF (l_sirv_rec.effective_pre_tax_yield = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.effective_pre_tax_yield := NULL;
    END IF;
    IF (l_sirv_rec.yield_name = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.yield_name := NULL;
    END IF;
    IF (l_sirv_rec.index_number = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.index_number := NULL;
    END IF;
    IF (l_sirv_rec.effective_after_tax_yield = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.effective_after_tax_yield := NULL;
    END IF;
    IF (l_sirv_rec.nominal_pre_tax_yield = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.nominal_pre_tax_yield := NULL;
    END IF;
    IF (l_sirv_rec.nominal_after_tax_yield = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.nominal_after_tax_yield := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute01 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute02 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute03 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute04 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute05 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute06 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute07 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute08 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute09 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute10 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute11 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute12 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute13 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute14 := NULL;
    END IF;
    IF (l_sirv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_sirv_rec.stream_interface_attribute15 := NULL;
    END IF;

    IF (l_sirv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.object_version_number := NULL;
    END IF;
    IF (l_sirv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.created_by := NULL;
    END IF;
    IF (l_sirv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.last_updated_by := NULL;
    END IF;
    IF (l_sirv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_sirv_rec.creation_date := NULL;
    END IF;
    IF (l_sirv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_sirv_rec.last_update_date := NULL;
    END IF;
    IF (l_sirv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.last_update_login := NULL;
    END IF;
    IF (l_sirv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.implicit_interest_rate := NULL;
    END IF;
    IF (l_sirv_rec.date_processed = OKC_API.G_MISS_DATE) THEN
      l_sirv_rec.date_processed := NULL;
    END IF;

    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    IF (l_sirv_rec.REQUEST_ID = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.REQUEST_ID := NULL;
    END IF;
    IF (l_sirv_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.PROGRAM_APPLICATION_ID := NULL;
    END IF;
    IF (l_sirv_rec.PROGRAM_ID = OKC_API.G_MISS_NUM) THEN
      l_sirv_rec.PROGRAM_ID := NULL;
    END IF;
    IF (l_sirv_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE) THEN
      l_sirv_rec.PROGRAM_UPDATE_DATE := NULL;
    END IF;
    -- end,mvasudev -- 02/21/2002
    RETURN(l_sirv_rec);
  END null_out_defaults;


-- START change : akjain , 09/05/2001
      /*
-- TAPI CODE COMMENTED OUT IN FAVOUR OF WRITING SEPARATE PROCEDURES FOR EACH ATTRIBUTE/COLUMN

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Attributes for:OKL_SIF_RETS_V --
  --------------------------------------------
  FUNCTION Validate_Attributes (
    p_sirv_rec IN  sirv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_sirv_rec.id = OKC_API.G_MISS_NUM OR
       p_sirv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sirv_rec.transaction_number = OKC_API.G_MISS_NUM OR
          p_sirv_rec.transaction_number IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'transaction_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sirv_rec.yield_name = OKC_API.G_MISS_CHAR OR
          p_sirv_rec.yield_name IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'yield_name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_sirv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_sirv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

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
    p_sirv_rec      IN   sirv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN
    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sirv_rec.id = Okc_Api.G_MISS_NUM OR
       p_sirv_rec.id IS NULL
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
	p_sirv_rec      IN   sirv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sirv_rec.object_version_number = Okc_Api.G_MISS_NUM OR
       p_sirv_rec.object_version_number IS NULL
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
      -- PROCEDURE Validate_Transaction_Number
      ---------------------------------------------------------------------------
      -- Start of comments
      --
      -- Procedure Name  : Validate_Transaction_Number
      -- Description     :
      -- Business Rules  :
      -- Parameters      :
      -- Version         : 1.0
      -- End of comments
      ---------------------------------------------------------------------------

      PROCEDURE Validate_Transaction_Number(
      p_sirv_rec      IN   sirv_rec_type,
	x_return_status OUT NOCOPY  VARCHAR2
      ) IS

       CURSOR okl_sifv_pk_csr (p_transaction_number IN OKL_SIF_RETS_V.transaction_number%TYPE) IS
       SELECT '1'
       FROM OKL_STREAM_INTERFACES_V
       WHERE OKL_STREAM_INTERFACES_V.transaction_number = p_transaction_number;

      l_dummy                 VARCHAR2(1) := '?';
      l_row_not_found         BOOLEAN := FALSE;


       BEGIN
	-- initialize return status
	x_return_status := Okc_Api.G_RET_STS_SUCCESS;

	IF p_sirv_rec.transaction_number = Okc_Api.G_MISS_NUM OR
	   p_sirv_rec.transaction_number IS NULL
	THEN
	  Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'transaction_number');
	  x_return_status := Okc_Api.G_RET_STS_ERROR;
	  RAISE G_EXCEPTION_HALT_VALIDATION;
	END IF;

       OPEN okl_sifv_pk_csr(p_sirv_rec.transaction_number);
       FETCH okl_sifv_pk_csr INTO l_dummy;
       l_row_not_found := okl_sifv_pk_csr%NOTFOUND;
       CLOSE okl_sifv_pk_csr;

       IF l_row_not_found THEN
        Okc_Api.set_message(G_OKC_APP,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Transaction_Number');
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
      IF okl_sifv_pk_csr%ISOPEN THEN
        CLOSE okl_sifv_pk_csr;
      END IF;
      END Validate_Transaction_Number;




  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Yield_Name
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Yield_Name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Yield_Name(
    p_sirv_rec      IN   sirv_rec_type,
    x_return_status OUT NOCOPY  VARCHAR2
  ) IS

  BEGIN

    -- initialize return status
    x_return_status := Okc_Api.G_RET_STS_SUCCESS;

    IF p_sirv_rec.Yield_Name = Okc_Api.G_MISS_CHAR OR
       p_sirv_rec.Yield_Name IS NULL
    THEN
      Okc_Api.set_message(G_OKC_APP, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'Yield_Name');
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

  END Validate_Yield_Name;


PROCEDURE Validate_Unique_Sir_Record(
          p_sirv_rec      IN   sirv_rec_type,
            x_return_status OUT NOCOPY  VARCHAR2
          ) IS

          l_dummy                 VARCHAR2(1) := '?';
          l_row_found             BOOLEAN := FALSE;

          -- Cursor For OKL_SIF_FEES_V - Unique Key Constraint
          CURSOR okl_sir_unique_csr (p_rec IN sirv_rec_type) IS
          SELECT '1'
            FROM OKL_SIF_RETS_V
           WHERE OKL_SIF_RETS_V.transaction_number = p_rec.transaction_number
           AND
           OKL_SIF_RETS_V.Yield_Name = p_rec.Yield_Name
           AND
           id     <> NVL(p_rec.id,-9999);

          BEGIN
            OPEN okl_sir_unique_csr (p_sirv_rec);
            FETCH okl_sir_unique_csr INTO l_dummy;
            l_row_found := okl_sir_unique_csr%FOUND;
            CLOSE okl_sir_unique_csr;

            IF l_row_found THEN
	          	Okc_Api.set_message(G_APP_NAME,G_OKL_UNQS);
	          	x_return_status := Okc_Api.G_RET_STS_ERROR;
           END IF;
          EXCEPTION
            WHEN G_EXCEPTION_HALT_VALIDATION THEN
            -- no processing necessary; validation can continue
            -- with the next column
            NULL;
            IF okl_sir_unique_csr%ISOPEN THEN
    	            CLOSE okl_sir_unique_csr;
            END IF;

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
              IF okl_sir_unique_csr%ISOPEN THEN
                CLOSE okl_sir_unique_csr;
              END IF;
          END Validate_Unique_Sir_Record;



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
          p_sirv_rec IN  sirv_rec_type
        ) RETURN VARCHAR2 IS

          x_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
          l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
        BEGIN
          -- call each column-level validation

          -- Validate_Id
          Validate_Id(p_sirv_rec, x_return_status);
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



      -- Validate_Yield_Name
                Validate_Yield_Name(p_sirv_rec, x_return_status);
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
          Validate_Object_Version_Number(p_sirv_rec, x_return_status);
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

          -- Validate_Transaction_Number
            Validate_Transaction_Number(p_sirv_rec, x_return_status);
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
            RETURN (l_return_status);
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

  -- END CHANGE akjain

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- Validate_Record for:OKL_SIF_RETS_V --
  ----------------------------------------
  FUNCTION Validate_Record (
    p_sirv_rec IN sirv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
-- Validate_Unique_Sir_Record
      Validate_Unique_Sir_Record(p_sirv_rec, x_return_status);
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
         Okc_Api.SET_MESSAGE(p_app_name         => g_app_name,
                             p_msg_name         => G_OKL_UNEXPECTED_ERROR,
                             p_token1           => G_OKL_SQLCODE_TOKEN,
                             p_token1_value     => SQLCODE,
                             p_token2           => G_OKL_SQLERRM_TOKEN,
                             p_token2_value     => SQLERRM);
         -- notify caller of an UNEXPECTED error
         l_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN sirv_rec_type,
    p_to	IN OUT NOCOPY sir_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.transaction_number := p_from.transaction_number;
    p_to.srt_code := p_from.srt_code;
    p_to.effective_pre_tax_yield := p_from.effective_pre_tax_yield;
    p_to.yield_name := p_from.yield_name;
    p_to.index_number := p_from.index_number;
    p_to.effective_after_tax_yield := p_from.effective_after_tax_yield;
    p_to.nominal_pre_tax_yield := p_from.nominal_pre_tax_yield;
    p_to.nominal_after_tax_yield := p_from.nominal_after_tax_yield;
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
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.date_processed := p_from.date_processed;
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    p_to.REQUEST_ID := p_from.REQUEST_ID;
    p_to.PROGRAM_APPLICATION_ID := p_from.PROGRAM_APPLICATION_ID;
    p_to.PROGRAM_ID := p_from.PROGRAM_ID;
    p_to.PROGRAM_UPDATE_DATE := p_from.PROGRAM_UPDATE_DATE;
    -- end,mvasudev -- 02/21/2002
  END migrate;
  PROCEDURE migrate (
    p_from	IN sir_rec_type,
    p_to	IN OUT NOCOPY sirv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.transaction_number := p_from.transaction_number;
    p_to.srt_code := p_from.srt_code;
    p_to.effective_pre_tax_yield := p_from.effective_pre_tax_yield;
    p_to.yield_name := p_from.yield_name;
    p_to.index_number := p_from.index_number;
    p_to.effective_after_tax_yield := p_from.effective_after_tax_yield;
    p_to.nominal_pre_tax_yield := p_from.nominal_pre_tax_yield;
    p_to.nominal_after_tax_yield := p_from.nominal_after_tax_yield;
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
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.implicit_interest_rate := p_from.implicit_interest_rate;
    p_to.date_processed := p_from.date_processed;
    -- mvasudev -- 02/21/2002
    -- new columns added for concurrent program manager
    p_to.REQUEST_ID := p_from.REQUEST_ID;
    p_to.PROGRAM_APPLICATION_ID := p_from.PROGRAM_APPLICATION_ID;
    p_to.PROGRAM_ID := p_from.PROGRAM_ID;
    p_to.PROGRAM_UPDATE_DATE := p_from.PROGRAM_UPDATE_DATE;
    -- end,mvasudev -- 02/21/2002
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------
  -- validate_row for:OKL_SIF_RETS_V --
  -------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sirv_rec                     sirv_rec_type := p_sirv_rec;
    l_sir_rec                      sir_rec_type;
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
    l_return_status := Validate_Attributes(l_sirv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_sirv_rec);
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
  -- PL/SQL TBL validate_row for:SIRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sirv_tbl.COUNT > 0) THEN
      i := p_sirv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sirv_rec                     => p_sirv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sirv_tbl.LAST);
        i := p_sirv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  -- insert_row for:OKL_SIF_RETS --
  ---------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sir_rec                      IN sir_rec_type,
    x_sir_rec                      OUT NOCOPY sir_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RETS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sir_rec                      sir_rec_type := p_sir_rec;
    l_def_sir_rec                  sir_rec_type;
    -------------------------------------
    -- Set_Attributes for:OKL_SIF_RETS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_sir_rec IN  sir_rec_type,
      x_sir_rec OUT NOCOPY sir_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sir_rec := p_sir_rec;
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
      p_sir_rec,                         -- IN
      l_sir_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_SIF_RETS(
        id,
        transaction_number,
        srt_code,
        effective_pre_tax_yield,
        yield_name,
        index_number,
        effective_after_tax_yield,
        nominal_pre_tax_yield,
        nominal_after_tax_yield,
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
        object_version_number,
        created_by,
        last_updated_by,
        creation_date,
        last_update_date,
        last_update_login,
        implicit_interest_rate,
        date_processed,
        -- mvasudev -- 02/21/2002
        -- new columns added for concurrent program manager
        request_id,
        program_application_id,
        program_id,
        program_update_date
        -- end,mvasudev -- 02/21/2002
        )
      VALUES (
        l_sir_rec.id,
        l_sir_rec.transaction_number,
        l_sir_rec.srt_code,
        l_sir_rec.effective_pre_tax_yield,
        l_sir_rec.yield_name,
        l_sir_rec.index_number,
        l_sir_rec.effective_after_tax_yield,
        l_sir_rec.nominal_pre_tax_yield,
        l_sir_rec.nominal_after_tax_yield,
		l_sir_rec.stream_interface_attribute01,
		l_sir_rec.stream_interface_attribute02,
		l_sir_rec.stream_interface_attribute03,
		l_sir_rec.stream_interface_attribute04,
		l_sir_rec.stream_interface_attribute05,
		l_sir_rec.stream_interface_attribute06,
		l_sir_rec.stream_interface_attribute07,
		l_sir_rec.stream_interface_attribute08,
		l_sir_rec.stream_interface_attribute09,
		l_sir_rec.stream_interface_attribute10,
		l_sir_rec.stream_interface_attribute11,
		l_sir_rec.stream_interface_attribute12,
		l_sir_rec.stream_interface_attribute13,
		l_sir_rec.stream_interface_attribute14,
		l_sir_rec.stream_interface_attribute15,
        l_sir_rec.object_version_number,
        l_sir_rec.created_by,
        l_sir_rec.last_updated_by,
        l_sir_rec.creation_date,
        l_sir_rec.last_update_date,
        l_sir_rec.last_update_login,
        l_sir_rec.implicit_interest_rate,
        l_sir_rec.date_processed,
         -- mvasudev -- 02/21/2002
         -- new columns added for concurrent program manager
        l_sir_rec.request_id,
        l_sir_rec.program_application_id,
        l_sir_rec.program_id,
        l_sir_rec.program_update_date
        -- end,mvasudev -- 02/21/2002
        );
    -- Set OUT values
    x_sir_rec := l_sir_rec;
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
  -- insert_row for:OKL_SIF_RETS_V --
  -----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sirv_rec                     sirv_rec_type;
    l_def_sirv_rec                 sirv_rec_type;
    l_sir_rec                      sir_rec_type;
    lx_sir_rec                     sir_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sirv_rec	IN sirv_rec_type
    ) RETURN sirv_rec_type IS
      l_sirv_rec	sirv_rec_type := p_sirv_rec;
    BEGIN
      l_sirv_rec.CREATION_DATE := SYSDATE;
      l_sirv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_sirv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sirv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sirv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sirv_rec);
    END fill_who_columns;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_RETS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_sirv_rec IN  sirv_rec_type,
      x_sirv_rec OUT NOCOPY sirv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sirv_rec := p_sirv_rec;
      x_sirv_rec.OBJECT_VERSION_NUMBER := 1;

      -- concurrent program columns
      SELECT DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL,Fnd_Global.CONC_REQUEST_ID),
             DECODE(Fnd_Global.PROG_APPL_ID, -1, NULL,Fnd_Global.PROG_APPL_ID),
             DECODE(Fnd_Global.CONC_PROGRAM_ID, -1, NULL,Fnd_Global.CONC_PROGRAM_ID),
             DECODE(Fnd_Global.CONC_REQUEST_ID, -1, NULL, SYSDATE)
      INTO   x_sirv_rec.REQUEST_ID
            ,x_sirv_rec.PROGRAM_APPLICATION_ID
            ,x_sirv_rec.PROGRAM_ID
            ,x_sirv_rec.PROGRAM_UPDATE_DATE
      FROM DUAL;

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
    l_sirv_rec := null_out_defaults(p_sirv_rec);
    -- Set primary key value
    l_sirv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_sirv_rec,                        -- IN
      l_def_sirv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sirv_rec := fill_who_columns(l_def_sirv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sirv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sirv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sirv_rec, l_sir_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sir_rec,
      lx_sir_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sir_rec, l_def_sirv_rec);
    -- Set OUT values
    x_sirv_rec := l_def_sirv_rec;
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
  -- PL/SQL TBL insert_row for:SIRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type,
    x_sirv_tbl                     OUT NOCOPY sirv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sirv_tbl.COUNT > 0) THEN
      i := p_sirv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sirv_rec                     => p_sirv_tbl(i),
          x_sirv_rec                     => x_sirv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sirv_tbl.LAST);
        i := p_sirv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  -- lock_row for:OKL_SIF_RETS --
  -------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sir_rec                      IN sir_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_sir_rec IN sir_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RETS
     WHERE ID = p_sir_rec.id
       AND OBJECT_VERSION_NUMBER = p_sir_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_sir_rec IN sir_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_SIF_RETS
    WHERE ID = p_sir_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RETS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_SIF_RETS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_SIF_RETS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_sir_rec);
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
      OPEN lchk_csr(p_sir_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_sir_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_sir_rec.object_version_number THEN
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
  ---------------------------------
  -- lock_row for:OKL_SIF_RETS_V --
  ---------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sir_rec                      sir_rec_type;
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
    migrate(p_sirv_rec, l_sir_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sir_rec
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
  -- PL/SQL TBL lock_row for:SIRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sirv_tbl.COUNT > 0) THEN
      i := p_sirv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sirv_rec                     => p_sirv_tbl(i));

       -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sirv_tbl.LAST);
        i := p_sirv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  -- update_row for:OKL_SIF_RETS --
  ---------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sir_rec                      IN sir_rec_type,
    x_sir_rec                      OUT NOCOPY sir_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RETS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sir_rec                      sir_rec_type := p_sir_rec;
    l_def_sir_rec                  sir_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sir_rec	IN sir_rec_type,
      x_sir_rec	OUT NOCOPY sir_rec_type
    ) RETURN VARCHAR2 IS
      l_sir_rec                      sir_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sir_rec := p_sir_rec;
      -- Get current database values
      l_sir_rec := get_rec(p_sir_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sir_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.id := l_sir_rec.id;
      END IF;
      IF (x_sir_rec.transaction_number = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.transaction_number := l_sir_rec.transaction_number;
      END IF;
      IF (x_sir_rec.srt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.srt_code := l_sir_rec.srt_code;
      END IF;
      IF (x_sir_rec.effective_pre_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.effective_pre_tax_yield := l_sir_rec.effective_pre_tax_yield;
      END IF;
      IF (x_sir_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.yield_name := l_sir_rec.yield_name;
      END IF;
      IF (x_sir_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.index_number := l_sir_rec.index_number;
      END IF;
      IF (x_sir_rec.effective_after_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.effective_after_tax_yield := l_sir_rec.effective_after_tax_yield;
      END IF;
      IF (x_sir_rec.nominal_pre_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.nominal_pre_tax_yield := l_sir_rec.nominal_pre_tax_yield;
      END IF;
      IF (x_sir_rec.nominal_after_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.nominal_after_tax_yield := l_sir_rec.nominal_after_tax_yield;
      END IF;
      IF (x_sir_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute01 := l_sir_rec.stream_interface_attribute01;
      END IF;
      IF (x_sir_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute02 := l_sir_rec.stream_interface_attribute02;
      END IF;
      IF (x_sir_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute03 := l_sir_rec.stream_interface_attribute03;
      END IF;
      IF (x_sir_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute04 := l_sir_rec.stream_interface_attribute04;
      END IF;
      IF (x_sir_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute05 := l_sir_rec.stream_interface_attribute05;
      END IF;
      IF (x_sir_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute06 := l_sir_rec.stream_interface_attribute06;
      END IF;
      IF (x_sir_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute07 := l_sir_rec.stream_interface_attribute07;
      END IF;
      IF (x_sir_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute08 := l_sir_rec.stream_interface_attribute08;
      END IF;
      IF (x_sir_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute09 := l_sir_rec.stream_interface_attribute09;
      END IF;
      IF (x_sir_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute10 := l_sir_rec.stream_interface_attribute10;
      END IF;
      IF (x_sir_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute11 := l_sir_rec.stream_interface_attribute11;
      END IF;
      IF (x_sir_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute12 := l_sir_rec.stream_interface_attribute12;
      END IF;
      IF (x_sir_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute13 := l_sir_rec.stream_interface_attribute13;
      END IF;
      IF (x_sir_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute14 := l_sir_rec.stream_interface_attribute14;
      END IF;
      IF (x_sir_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sir_rec.stream_interface_attribute15 := l_sir_rec.stream_interface_attribute15;
      END IF;
      IF (x_sir_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.object_version_number := l_sir_rec.object_version_number;
      END IF;
      IF (x_sir_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.created_by := l_sir_rec.created_by;
      END IF;
      IF (x_sir_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.last_updated_by := l_sir_rec.last_updated_by;
      END IF;
      IF (x_sir_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sir_rec.creation_date := l_sir_rec.creation_date;
      END IF;
      IF (x_sir_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sir_rec.last_update_date := l_sir_rec.last_update_date;
      END IF;
      IF (x_sir_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.last_update_login := l_sir_rec.last_update_login;
      END IF;
      IF (x_sir_rec.implicit_interest_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.implicit_interest_rate := l_sir_rec.implicit_interest_rate;
      END IF;
      IF (x_sir_rec.date_processed = OKC_API.G_MISS_DATE)
      THEN
        x_sir_rec.date_processed := l_sir_rec.date_processed;
      END IF;
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
      IF (x_sir_rec.REQUEST_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.REQUEST_ID := l_sir_rec.REQUEST_ID;
      END IF;
      IF (x_sir_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.PROGRAM_APPLICATION_ID := l_sir_rec.PROGRAM_APPLICATION_ID;
      END IF;
      IF (x_sir_rec.PROGRAM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sir_rec.PROGRAM_ID := l_sir_rec.PROGRAM_ID;
      END IF;
      IF (x_sir_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_sir_rec.PROGRAM_UPDATE_DATE := l_sir_rec.PROGRAM_UPDATE_DATE;
      END IF;
            -- end,mvasudev -- 02/21/2002
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------
    -- Set_Attributes for:OKL_SIF_RETS --
    -------------------------------------
    FUNCTION Set_Attributes (
      p_sir_rec IN  sir_rec_type,
      x_sir_rec OUT NOCOPY sir_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sir_rec := p_sir_rec;
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
      p_sir_rec,                         -- IN
      l_sir_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sir_rec, l_def_sir_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_SIF_RETS
    SET TRANSACTION_NUMBER = l_def_sir_rec.transaction_number,
        SRT_CODE = l_def_sir_rec.srt_code,
        EFFECTIVE_PRE_TAX_YIELD = l_def_sir_rec.effective_pre_tax_yield,
        YIELD_NAME = l_def_sir_rec.yield_name,
        INDEX_NUMBER = l_def_sir_rec.index_number,
        EFFECTIVE_AFTER_TAX_YIELD = l_def_sir_rec.effective_after_tax_yield,
        NOMINAL_PRE_TAX_YIELD = l_def_sir_rec.nominal_pre_tax_yield,
        NOMINAL_AFTER_TAX_YIELD = l_def_sir_rec.nominal_after_tax_yield,
		STREAM_INTERFACE_ATTRIBUTE01 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE01,
		STREAM_INTERFACE_ATTRIBUTE02 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE02,
		STREAM_INTERFACE_ATTRIBUTE03 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE03,
		STREAM_INTERFACE_ATTRIBUTE04 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE04,
		STREAM_INTERFACE_ATTRIBUTE05 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE05,
		STREAM_INTERFACE_ATTRIBUTE06 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE06,
		STREAM_INTERFACE_ATTRIBUTE07 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE07,
		STREAM_INTERFACE_ATTRIBUTE08 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE08,
		STREAM_INTERFACE_ATTRIBUTE09 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE09,
		STREAM_INTERFACE_ATTRIBUTE10 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE10,
		STREAM_INTERFACE_ATTRIBUTE11 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE11,
		STREAM_INTERFACE_ATTRIBUTE12 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE12,
		STREAM_INTERFACE_ATTRIBUTE13 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE13,
		STREAM_INTERFACE_ATTRIBUTE14 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE14,
		STREAM_INTERFACE_ATTRIBUTE15 = l_def_sir_rec.STREAM_INTERFACE_ATTRIBUTE15,
        OBJECT_VERSION_NUMBER = l_def_sir_rec.object_version_number,
        CREATED_BY = l_def_sir_rec.created_by,
        LAST_UPDATED_BY = l_def_sir_rec.last_updated_by,
        CREATION_DATE = l_def_sir_rec.creation_date,
        LAST_UPDATE_DATE = l_def_sir_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_sir_rec.last_update_login,
        IMPLICIT_INTEREST_RATE = l_def_sir_rec.implicit_interest_rate,
        DATE_PROCESSED = l_def_sir_rec.date_processed,
        -- mvasudev -- 02/21/2002
        -- new columns added for concurrent program manager
        REQUEST_ID = l_def_sir_rec.REQUEST_ID,
	PROGRAM_APPLICATION_ID = l_def_sir_rec.PROGRAM_APPLICATION_ID,
	PROGRAM_ID = l_def_sir_rec.PROGRAM_ID,
	PROGRAM_UPDATE_DATE = l_def_sir_rec.PROGRAM_UPDATE_DATE
        -- end,mvasudev -- 02/21/2002
    WHERE ID = l_def_sir_rec.id;

    x_sir_rec := l_def_sir_rec;
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
  -- update_row for:OKL_SIF_RETS_V --
  -----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type,
    x_sirv_rec                     OUT NOCOPY sirv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sirv_rec                     sirv_rec_type := p_sirv_rec;
    l_def_sirv_rec                 sirv_rec_type;
    l_sir_rec                      sir_rec_type;
    lx_sir_rec                     sir_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_sirv_rec	IN sirv_rec_type
    ) RETURN sirv_rec_type IS
      l_sirv_rec	sirv_rec_type := p_sirv_rec;
    BEGIN
      l_sirv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_sirv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_sirv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_sirv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_sirv_rec	IN sirv_rec_type,
      x_sirv_rec	OUT NOCOPY sirv_rec_type
    ) RETURN VARCHAR2 IS
      l_sirv_rec                     sirv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sirv_rec := p_sirv_rec;
      -- Get current database values
      l_sirv_rec := get_rec(p_sirv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_sirv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.id := l_sirv_rec.id;
      END IF;
      IF (x_sirv_rec.transaction_number = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.transaction_number := l_sirv_rec.transaction_number;
      END IF;
      IF (x_sirv_rec.srt_code = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.srt_code := l_sirv_rec.srt_code;
      END IF;
      IF (x_sirv_rec.effective_pre_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.effective_pre_tax_yield := l_sirv_rec.effective_pre_tax_yield;
      END IF;
      IF (x_sirv_rec.yield_name = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.yield_name := l_sirv_rec.yield_name;
      END IF;
      IF (x_sirv_rec.index_number = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.index_number := l_sirv_rec.index_number;
      END IF;
      IF (x_sirv_rec.effective_after_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.effective_after_tax_yield := l_sirv_rec.effective_after_tax_yield;
      END IF;
      IF (x_sirv_rec.nominal_pre_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.nominal_pre_tax_yield := l_sirv_rec.nominal_pre_tax_yield;
      END IF;
      IF (x_sirv_rec.nominal_after_tax_yield = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.nominal_after_tax_yield := l_sirv_rec.nominal_after_tax_yield;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute01 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute01 := l_sirv_rec.stream_interface_attribute01;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute02 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute02 := l_sirv_rec.stream_interface_attribute02;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute03 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute03 := l_sirv_rec.stream_interface_attribute03;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute04 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute04 := l_sirv_rec.stream_interface_attribute04;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute05 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute05 := l_sirv_rec.stream_interface_attribute05;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute06 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute06 := l_sirv_rec.stream_interface_attribute06;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute07 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute07 := l_sirv_rec.stream_interface_attribute07;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute08 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute08 := l_sirv_rec.stream_interface_attribute08;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute09 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute09 := l_sirv_rec.stream_interface_attribute09;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute10 := l_sirv_rec.stream_interface_attribute10;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute11 := l_sirv_rec.stream_interface_attribute11;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute12 := l_sirv_rec.stream_interface_attribute12;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute13 := l_sirv_rec.stream_interface_attribute13;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute14 := l_sirv_rec.stream_interface_attribute14;
      END IF;
      IF (x_sirv_rec.stream_interface_attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_sirv_rec.stream_interface_attribute15 := l_sirv_rec.stream_interface_attribute15;
      END IF;
      IF (x_sirv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.object_version_number := l_sirv_rec.object_version_number;
      END IF;
      IF (x_sirv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.created_by := l_sirv_rec.created_by;
      END IF;
      IF (x_sirv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.last_updated_by := l_sirv_rec.last_updated_by;
      END IF;
      IF (x_sirv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_sirv_rec.creation_date := l_sirv_rec.creation_date;
      END IF;
      IF (x_sirv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_sirv_rec.last_update_date := l_sirv_rec.last_update_date;
      END IF;
      IF (x_sirv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.last_update_login := l_sirv_rec.last_update_login;
      END IF;
      IF (x_sirv_rec.implicit_interest_rate = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.implicit_interest_rate := l_sirv_rec.implicit_interest_rate;
      END IF;
      IF (x_sirv_rec.date_processed = OKC_API.G_MISS_DATE)
      THEN
        x_sirv_rec.date_processed := l_sirv_rec.date_processed;
      END IF;
            -- mvasudev -- 02/21/2002
            -- new columns added for concurrent program manager
      IF (x_sirv_rec.REQUEST_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.REQUEST_ID := l_sirv_rec.REQUEST_ID;
      END IF;
      IF (x_sirv_rec.PROGRAM_APPLICATION_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.PROGRAM_APPLICATION_ID := l_sirv_rec.PROGRAM_APPLICATION_ID;
      END IF;
      IF (x_sirv_rec.PROGRAM_ID = OKC_API.G_MISS_NUM)
      THEN
        x_sirv_rec.PROGRAM_ID := l_sirv_rec.PROGRAM_ID;
      END IF;
      IF (x_sirv_rec.PROGRAM_UPDATE_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_sirv_rec.PROGRAM_UPDATE_DATE := l_sirv_rec.PROGRAM_UPDATE_DATE;
      END IF;
            -- END,mvasudev -- 02/21/2002
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_SIF_RETS_V --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_sirv_rec IN  sirv_rec_type,
      x_sirv_rec OUT NOCOPY sirv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_sirv_rec := p_sirv_rec;
      x_sirv_rec.OBJECT_VERSION_NUMBER := NVL(x_sirv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_sirv_rec,                        -- IN
      l_sirv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_sirv_rec, l_def_sirv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_sirv_rec := fill_who_columns(l_def_sirv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_sirv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_sirv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_sirv_rec, l_sir_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sir_rec,
      lx_sir_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_sir_rec, l_def_sirv_rec);
    x_sirv_rec := l_def_sirv_rec;
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
  -- PL/SQL TBL update_row for:SIRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type,
    x_sirv_tbl                     OUT NOCOPY sirv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sirv_tbl.COUNT > 0) THEN
      i := p_sirv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sirv_rec                     => p_sirv_tbl(i),
          x_sirv_rec                     => x_sirv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sirv_tbl.LAST);
        i := p_sirv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
  -- delete_row for:OKL_SIF_RETS --
  ---------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sir_rec                      IN sir_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'RETS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sir_rec                      sir_rec_type:= p_sir_rec;
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
    DELETE FROM OKL_SIF_RETS
     WHERE ID = l_sir_rec.id;

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
  -- delete_row for:OKL_SIF_RETS_V --
  -----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_rec                     IN sirv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_sirv_rec                     sirv_rec_type := p_sirv_rec;
    l_sir_rec                      sir_rec_type;
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
    migrate(l_sirv_rec, l_sir_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_sir_rec
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
  -- PL/SQL TBL delete_row for:SIRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_sirv_tbl                     IN sirv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    -- START change : akjain, 09/05/2001
    -- Adding OverAll Status Flag
    l_overall_status     VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
    -- END change : akjain

  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_sirv_tbl.COUNT > 0) THEN
      i := p_sirv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_sirv_rec                     => p_sirv_tbl(i));
        -- START change : akjain, 09/05/2001
	-- store the highest degree of error
	IF x_return_status <> Okc_Api.G_RET_STS_SUCCESS THEN
	    IF l_overall_status <> Okc_Api.G_RET_STS_UNEXP_ERROR THEN
	             l_overall_status := x_return_status;
	    END IF;
	END IF;
	-- END change : akjain
        EXIT WHEN (i = p_sirv_tbl.LAST);
        i := p_sirv_tbl.NEXT(i);
      END LOOP;
       -- START change : akjain, 09/05/2001
       -- return overall status
       x_return_status := l_overall_status;
       -- END change : akjain

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
END OKL_SIR_PVT;

/
