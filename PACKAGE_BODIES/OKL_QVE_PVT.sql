--------------------------------------------------------
--  DDL for Package Body OKL_QVE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QVE_PVT" AS
/* $Header: OKLSQVEB.pls 120.7 2007/10/23 05:42:28 dpsingh noship $ */
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

  -- FUNCTION get_rec for: OKL_PQY_VALUES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qve_rec                      IN qve_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qve_rec_type IS
    CURSOR okl_pqy_values_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            VALUE,
            PQY_ID,
            OBJECT_VERSION_NUMBER,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pqy_Values
     WHERE okl_pqy_values.id    = p_id;
    l_okl_pqy_values_pk            okl_pqy_values_pk_csr%ROWTYPE;
    l_qve_rec                      qve_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pqy_values_pk_csr (p_qve_rec.id);
    FETCH okl_pqy_values_pk_csr INTO
              l_qve_rec.ID,
              l_qve_rec.VALUE,
              l_qve_rec.PQY_ID,
              l_qve_rec.OBJECT_VERSION_NUMBER,
              l_qve_rec.DESCRIPTION,
              l_qve_rec.FROM_DATE,
              l_qve_rec.TO_DATE,
              l_qve_rec.CREATED_BY,
              l_qve_rec.CREATION_DATE,
              l_qve_rec.LAST_UPDATED_BY,
              l_qve_rec.LAST_UPDATE_DATE,
              l_qve_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pqy_values_pk_csr%NOTFOUND;
    CLOSE okl_pqy_values_pk_csr;
    RETURN(l_qve_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qve_rec                      IN qve_rec_type
  ) RETURN qve_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qve_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PQY_VALUES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qvev_rec                     IN qvev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qvev_rec_type IS
    CURSOR okl_qvev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            PQY_ID,
            VALUE,
            DESCRIPTION,
            FROM_DATE,
            TO_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pqy_Values_V
     WHERE okl_pqy_values_v.id  = p_id;
    l_okl_qvev_pk                  okl_qvev_pk_csr%ROWTYPE;
    l_qvev_rec                     qvev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qvev_pk_csr (p_qvev_rec.id);
    FETCH okl_qvev_pk_csr INTO
              l_qvev_rec.ID,
              l_qvev_rec.OBJECT_VERSION_NUMBER,
              l_qvev_rec.PQY_ID,
              l_qvev_rec.VALUE,
              l_qvev_rec.DESCRIPTION,
              l_qvev_rec.FROM_DATE,
              l_qvev_rec.TO_DATE,
              l_qvev_rec.CREATED_BY,
              l_qvev_rec.CREATION_DATE,
              l_qvev_rec.LAST_UPDATED_BY,
              l_qvev_rec.LAST_UPDATE_DATE,
              l_qvev_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_qvev_pk_csr%NOTFOUND;
    CLOSE okl_qvev_pk_csr;
    RETURN(l_qvev_rec);
  END get_rec;


  FUNCTION get_rec (
    p_qvev_rec                     IN qvev_rec_type
  ) RETURN qvev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qvev_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PQY_VALUES_V --
  ------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qvev_rec	IN qvev_rec_type
  ) RETURN qvev_rec_type IS
    l_qvev_rec	qvev_rec_type := p_qvev_rec;
  BEGIN
    IF (l_qvev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qvev_rec.object_version_number := NULL;
    END IF;
    IF (l_qvev_rec.pqy_id = OKC_API.G_MISS_NUM) THEN
      l_qvev_rec.pqy_id := NULL;
    END IF;
    IF (l_qvev_rec.value = OKC_API.G_MISS_CHAR) THEN
      l_qvev_rec.value := NULL;
    END IF;
    IF (l_qvev_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_qvev_rec.description := NULL;
    END IF;
    IF (l_qvev_rec.from_date = OKC_API.G_MISS_DATE) THEN
      l_qvev_rec.from_date := NULL;
    END IF;
    IF (l_qvev_rec.TO_DATE = OKC_API.G_MISS_DATE) THEN
      l_qvev_rec.TO_DATE := NULL;
    END IF;
    IF (l_qvev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qvev_rec.created_by := NULL;
    END IF;
    IF (l_qvev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qvev_rec.creation_date := NULL;
    END IF;
    IF (l_qvev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qvev_rec.last_updated_by := NULL;
    END IF;
    IF (l_qvev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qvev_rec.last_update_date := NULL;
    END IF;
    IF (l_qvev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qvev_rec.last_update_login := NULL;
    END IF;
    RETURN(l_qvev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Attributes for:OKL_PQY_VALUES_V --
  ----------------------------------------------
  ----------------TCHGS NEW CHANGS BEGIN --------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

  PROCEDURE Validate_Id (
    p_qvev_rec IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status	 := OKC_API.G_RET_STS_SUCCESS;

    IF p_qvev_rec.id = OKC_API.G_MISS_NUM OR
       p_qvev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>SQLCODE,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Id;
-----end of Validate_Id------------------------


---------------------------------------------------------------------------
  -- PROCEDURE Validate _Object_Version_Number
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Object_Version_Number
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Object_Version_Number (
    p_qvev_rec IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status	 := OKC_API.G_RET_STS_SUCCESS;

    IF p_qvev_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_qvev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;
------end of Validate_Object_Version_Number-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Pqy_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Pqy_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
PROCEDURE Validate_Pqy_Id (
    p_qvev_rec IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR okl_pqy_values_foreign (p_foreign  OKL_PQY_VALUES.PQY_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PDT_QUALITYS_V
      WHERE OKL_PDT_QUALITYS_V.ID =  p_foreign;

    l_foreign_key                   OKL_PQY_VALUES_V.PQY_ID%TYPE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_qvev_rec.pqy_id = OKC_API.G_MISS_NUM OR
       p_qvev_rec.pqy_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pqy_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSE
      OPEN okl_pqy_values_foreign (p_qvev_rec.pqy_id);
      FETCH okl_pqy_values_foreign INTO l_foreign_key;
      IF okl_pqy_values_foreign%NOTFOUND THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_KEY,G_COL_NAME_TOKEN,'pqy_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;

      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
      END IF;
      CLOSE okl_pqy_values_foreign;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Pqy_Id;
------end of Validate_Pqy_Id-----------------------------------


---------------------------------------------------------------------------
  -- PROCEDURE Validate _Value
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Value (
    p_qvev_rec IN OUT NOCOPY qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

       IF (p_qvev_rec.value IS NOT NULL) AND  (p_qvev_rec.value <> OKC_API.G_MISS_CHAR) THEN

	  IF p_qvev_rec.value IN('LEASEDF','LEASEOP','LOAN','LOAN-REVOLVING','LEASEST') THEN
             l_dummy :=  OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_BOOK_CLASS',
                                                                   p_lookup_code => p_qvev_rec.value);
          ELSIF p_qvev_rec.value IN('FIXED','FLOAT','REAMORT','FLOAT_FACTORS','CATCHUP/CLEANUP') THEN
             l_dummy :=  OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_INTEREST_CALCULATION_BASIS',
                                                                   p_lookup_code => p_qvev_rec.value);
          ELSIF p_qvev_rec.value IN('STREAMS','ESTIMATED_AND_BILLED','ACTUAL') THEN
             l_dummy :=  OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_REVENUE_RECOGNITION_METHOD',
                                                                   p_lookup_code => p_qvev_rec.value);
          ELSIF p_qvev_rec.value IN('LESSEE','LESSOR') THEN
             l_dummy :=  OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_TAX_OWNER',
                                                                   p_lookup_code => p_qvev_rec.value);
          ELSIF p_qvev_rec.value IN('SYNDICATION','SECURITIZATION') THEN
             l_dummy :=  OKL_ACCOUNTING_UTIL.validate_lookup_code (p_lookup_type => 'OKL_SECURITIZATION_TYPE',
			 		 	 										   p_lookup_code => p_qvev_rec.value);
          END IF;

        IF (l_dummy = OKC_API.G_FALSE) THEN

           OKC_API.SET_MESSAGE(p_app_name => g_app_name,
                               p_msg_name => g_invalid_value,
                               p_token1   => g_col_name_token,
                               p_token1_value => 'VALUE');

           x_return_status := OKC_API.G_RET_STS_ERROR;
           RAISE G_EXCEPTION_HALT_VALIDATION;

        END IF;

   END IF;

   p_qvev_rec.value := OKL_ACCOUNTING_UTIL.okl_upper(p_qvev_rec.value);

  EXCEPTION
     WHEN G_EXCEPTION_HALT_VALIDATION THEN
         NULL;
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Value;
------end of Validate_Value-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _From_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _From_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_From_Date(
    p_qvev_rec  IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_qvev_rec.from_date IS NULL) OR
       (p_qvev_rec.from_date = OKC_API.G_MISS_DATE) THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,

                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_From_Date;
------end of Validate_From_Date-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _To_Date
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _To_Date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_To_Date(p_qvev_rec  IN  qvev_rec_type,
                           x_return_status OUT  NOCOPY VARCHAR2)IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_qvev_rec.TO_DATE IS NOT NULL) AND
       (p_qvev_rec.TO_DATE < p_qvev_rec.from_date) THEN
       OKC_API.SET_MESSAGE(p_app_name       => g_app_name
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
                          p_token1       => g_sql_sqlcode_token,
                          p_token1_value => SQLCODE,
                          p_token2       => g_sql_sqlerrm_token,
                          p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_To_Date;
------end of Validate_To_Date-----------------------------------

  -- PROCEDURE Validate _Unique_key
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Unique_key
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
 PROCEDURE Validate_Unique_Key(
    p_qvev_rec IN  qvev_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_pqy_values_unique (p_unique1  OKL_PQY_VALUES.VALUE%TYPE, p_unique2  OKL_PQY_VALUES.PQY_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PQY_VALUES_V
      WHERE OKL_PQY_VALUES_V.VALUE =  p_unique1 AND
            OKL_PQY_VALUES_V.PQY_ID =  p_unique2 AND
            OKL_PQY_VALUES_V.ID  <> NVL(p_qvev_rec.id,-9999);

    l_unique_key                   OKL_PQY_VALUES_V.VALUE%TYPE;
    l_unique_key2                   OKL_PQY_VALUES_V.PQY_ID%TYPE;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN okl_pqy_values_unique (p_qvev_rec.value, p_qvev_rec.pqy_id);
    FETCH okl_pqy_values_unique INTO l_unique_key;
    IF okl_pqy_values_unique%FOUND THEN
       OKC_API.set_message('OKL',G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'value');
      -- OKC_API.set_message(G_APP_NAME,G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'pqy_id');

       x_return_status := OKC_API.G_RET_STS_ERROR;
      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pqy_values_unique;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;



  END Validate_Unique_Key;

-----END OF VALIDATE UNIQUE KEY-------------------------


---------------------------------------------------------------------------
  -- FUNCTION Validate _Attribute
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Attribute
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION Validate_Attributes(
    p_qvev_rec IN OUT NOCOPY qvev_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;


  BEGIN
    ---- CHECK FOR ID-------------------------
    Validate_Id (p_qvev_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

   --------CHECK FOR VERSION NUMBER------------------
    Validate_Object_Version_Number (p_qvev_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

    -----CHECK FOR PQY_ID----------------------------
    Validate_Pqy_Id (p_qvev_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
        l_return_status := x_return_status;
     END IF;
    END IF;

    -----CHECK FOR PQY_VALUE----------------------------
    Validate_Value (p_qvev_rec, x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;

    END IF;

   -----CHECK FOR FROM_DATE----------------------------
    Validate_From_Date (p_qvev_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;

          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
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
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);

  END Validate_Attributes;

-----END OF VALIDATE ATTRIBUTES-------------------------

---------------------------------------------------------------------------
  -- FUNCTION Validate _Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

 FUNCTION Validate_Record(
    p_qvev_rec IN  qvev_rec_type
  ) RETURN VARCHAR IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;


  BEGIN

   --------CHECK FOR UNIQUE KEY------------------
    Validate_Unique_Key (p_qvev_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;
-----CHECK FOR TO_DATE----------------------------
    Validate_To_Date (p_qvev_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
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
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>SQLCODE,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>SQLERRM);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

  END Validate_Record;

-----END OF VALIDATE RECORD-------------------------

 ----TCHGS COMMENTED BEGIN --------------------
  --FUNCTION Validate_Attributes (
    --p_qvev_rec IN  qvev_rec_type
  --) RETURN VARCHAR2 IS

    --l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  --BEGIN
  --  IF p_qvev_rec.id = OKC_API.G_MISS_NUM OR
  --     --p_qvev_rec.id IS NULL
  --  THEN
  --    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
  --    l_return_status := OKC_API.G_RET_STS_ERROR;
  --  ELSIF p_qvev_rec.object_version_number = OKC_API.G_MISS_NUM OR
  --        p_qvev_rec.object_version_number IS NULL
  --  THEN
  --    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
  --    l_return_status := OKC_API.G_RET_STS_ERROR;
  --  ELSIF p_qvev_rec.pqy_id = OKC_API.G_MISS_NUM OR
  --        p_qvev_rec.pqy_id IS NULL
  --  THEN
  --    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pqy_id');
  --    l_return_status := OKC_API.G_RET_STS_ERROR;
  --  ELSIF p_qvev_rec.value = OKC_API.G_MISS_CHAR OR
  --        p_qvev_rec.value IS NULL
  --  THEN
  --    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'value');
  --    l_return_status := OKC_API.G_RET_STS_ERROR;
 --   ELSIF p_qvev_rec.description = OKC_API.G_MISS_CHAR
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'description');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   ELSIF p_qvev_rec.from_date = OKC_API.G_MISS_DATE
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'from_date');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   ELSIF p_qvev_rec.to_date = OKC_API.G_MISS_DATE
 --   THEN
 --     OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'to_date');
 --     l_return_status := OKC_API.G_RET_STS_ERROR;
 --   END IF;
 --   RETURN(l_return_status);
 -- END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKL_PQY_VALUES_V --
  ------------------------------------------

  --FUNCTION Validate_Record (
  --  p_qvev_rec IN qvev_rec_type
  --) RETURN VARCHAR2 IS
  --  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  --  RETURN (l_return_status);

  --END Validate_Record;
----------TCHGS COMMENTED END-------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qvev_rec_type,
    p_to	IN OUT NOCOPY qve_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.value := p_from.value;
    p_to.pqy_id := p_from.pqy_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN qve_rec_type,
    p_to	IN OUT NOCOPY qvev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.value := p_from.value;
    p_to.pqy_id := p_from.pqy_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.description := p_from.description;
    p_to.from_date := p_from.from_date;
    p_to.TO_DATE := p_from.TO_DATE;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------

  -- validate_row for:OKL_PQY_VALUES_V --
  ---------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_rec                     IN qvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_rec                     qvev_rec_type := p_qvev_rec;
    l_qve_rec                      qve_rec_type;
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
    l_return_status := Validate_Attributes(l_qvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qvev_rec);
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
  -- PL/SQL TBL validate_row for:QVEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_tbl                     IN qvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,

          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qvev_rec                     => p_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);
        i := p_qvev_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
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
  -----------------------------------
  -- insert_row for:OKL_PQY_VALUES --
  -----------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qve_rec                      IN qve_rec_type,
    x_qve_rec                      OUT NOCOPY qve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qve_rec                      qve_rec_type := p_qve_rec;
    l_def_qve_rec                  qve_rec_type;
    ---------------------------------------
    -- Set_Attributes for:OKL_PQY_VALUES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_qve_rec IN  qve_rec_type,
      x_qve_rec OUT NOCOPY qve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qve_rec := p_qve_rec;
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
      p_qve_rec,                         -- IN
      l_qve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN

      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PQY_VALUES(
        id,
        value,
        pqy_id,
        object_version_number,
        description,
        from_date,
        TO_DATE,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_qve_rec.id,
        l_qve_rec.value,
        l_qve_rec.pqy_id,
        l_qve_rec.object_version_number,
        l_qve_rec.description,
        l_qve_rec.from_date,
        l_qve_rec.TO_DATE,
        l_qve_rec.created_by,
        l_qve_rec.creation_date,
        l_qve_rec.last_updated_by,
        l_qve_rec.last_update_date,
        l_qve_rec.last_update_login);
    -- Set OUT values
    x_qve_rec := l_qve_rec;
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
  -- insert_row for:OKL_PQY_VALUES_V --
  -------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_rec                     IN qvev_rec_type,
    x_qvev_rec                     OUT NOCOPY qvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_rec                     qvev_rec_type;
    l_def_qvev_rec                 qvev_rec_type;
    l_qve_rec                      qve_rec_type;
    lx_qve_rec                     qve_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qvev_rec	IN qvev_rec_type
    ) RETURN qvev_rec_type IS
      l_qvev_rec	qvev_rec_type := p_qvev_rec;
    BEGIN
      l_qvev_rec.CREATION_DATE := SYSDATE;
      l_qvev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qvev_rec.LAST_UPDATE_DATE := l_qvev_rec.CREATION_DATE;
      l_qvev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qvev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qvev_rec);
    END fill_who_columns;
    -----------------------------------------
    -- Set_Attributes for:OKL_PQY_VALUES_V --

    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qvev_rec IN  qvev_rec_type,
      x_qvev_rec OUT NOCOPY qvev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qvev_rec := p_qvev_rec;
      x_qvev_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_qvev_rec := null_out_defaults(p_qvev_rec);
    -- Set primary key value
    l_qvev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qvev_rec,                        -- IN
      l_def_qvev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qvev_rec := fill_who_columns(l_def_qvev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qvev_rec, l_qve_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qve_rec,
      lx_qve_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qve_rec, l_def_qvev_rec);
    -- Set OUT values
    x_qvev_rec := l_def_qvev_rec;
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
  -- PL/SQL TBL insert_row for:QVEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_tbl                     IN qvev_tbl_type,
    x_qvev_tbl                     OUT NOCOPY qvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qvev_rec                     => p_qvev_tbl(i),
          x_qvev_rec                     => x_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);
        i := p_qvev_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
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
  ---------------------------------
  -- lock_row for:OKL_PQY_VALUES --
  ---------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qve_rec                      IN qve_rec_type) IS

    E_Resource_Busy               EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qve_rec IN qve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PQY_VALUES
     WHERE ID = p_qve_rec.id
       AND OBJECT_VERSION_NUMBER = p_qve_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qve_rec IN qve_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PQY_VALUES
    WHERE ID = p_qve_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PQY_VALUES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PQY_VALUES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qve_rec);
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
      OPEN lchk_csr(p_qve_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qve_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qve_rec.object_version_number THEN
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
  -- lock_row for:OKL_PQY_VALUES_V --
  -----------------------------------
  PROCEDURE lock_row(

    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_rec                     IN qvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qve_rec                      qve_rec_type;
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
    migrate(p_qvev_rec, l_qve_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qve_rec
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
  -- PL/SQL TBL lock_row for:QVEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_tbl                     IN qvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        lock_row (

          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qvev_rec                     => p_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);
        i := p_qvev_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
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
  -----------------------------------
  -- update_row for:OKL_PQY_VALUES --
  -----------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qve_rec                      IN qve_rec_type,
    x_qve_rec                      OUT NOCOPY qve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qve_rec                      qve_rec_type := p_qve_rec;
    l_def_qve_rec                  qve_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qve_rec	IN qve_rec_type,
      x_qve_rec	OUT NOCOPY qve_rec_type
    ) RETURN VARCHAR2 IS
      l_qve_rec                      qve_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qve_rec := p_qve_rec;
      -- Get current database values
      l_qve_rec := get_rec(p_qve_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qve_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.id := l_qve_rec.id;
      END IF;
      IF (x_qve_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_qve_rec.value := l_qve_rec.value;
      END IF;
      IF (x_qve_rec.pqy_id = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.pqy_id := l_qve_rec.pqy_id;

      END IF;
      IF (x_qve_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.object_version_number := l_qve_rec.object_version_number;
      END IF;
      IF (x_qve_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_qve_rec.description := l_qve_rec.description;
      END IF;
      IF (x_qve_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_qve_rec.from_date := l_qve_rec.from_date;
      END IF;
      IF (x_qve_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_qve_rec.TO_DATE := l_qve_rec.TO_DATE;
      END IF;
      IF (x_qve_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.created_by := l_qve_rec.created_by;
      END IF;
      IF (x_qve_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qve_rec.creation_date := l_qve_rec.creation_date;
      END IF;
      IF (x_qve_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.last_updated_by := l_qve_rec.last_updated_by;
      END IF;
      IF (x_qve_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qve_rec.last_update_date := l_qve_rec.last_update_date;
      END IF;
      IF (x_qve_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qve_rec.last_update_login := l_qve_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------
    -- Set_Attributes for:OKL_PQY_VALUES --
    ---------------------------------------
    FUNCTION Set_Attributes (
      p_qve_rec IN  qve_rec_type,
      x_qve_rec OUT NOCOPY qve_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qve_rec := p_qve_rec;
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
      p_qve_rec,                         -- IN
      l_qve_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qve_rec, l_def_qve_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PQY_VALUES
    SET VALUE = l_def_qve_rec.value,
        PQY_ID = l_def_qve_rec.pqy_id,
        OBJECT_VERSION_NUMBER = l_def_qve_rec.object_version_number,
        DESCRIPTION = l_def_qve_rec.description,
        FROM_DATE = l_def_qve_rec.from_date,
        TO_DATE = l_def_qve_rec.TO_DATE,
        CREATED_BY = l_def_qve_rec.created_by,
        CREATION_DATE = l_def_qve_rec.creation_date,
        LAST_UPDATED_BY = l_def_qve_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qve_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qve_rec.last_update_login
    WHERE ID = l_def_qve_rec.id;

    x_qve_rec := l_def_qve_rec;
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
  -- update_row for:OKL_PQY_VALUES_V --
  -------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_rec                     IN qvev_rec_type,
    x_qvev_rec                     OUT NOCOPY qvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_rec                     qvev_rec_type := p_qvev_rec;
    l_def_qvev_rec                 qvev_rec_type;
    l_qve_rec                      qve_rec_type;
    lx_qve_rec                     qve_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qvev_rec	IN qvev_rec_type
    ) RETURN qvev_rec_type IS
      l_qvev_rec	qvev_rec_type := p_qvev_rec;
    BEGIN
      l_qvev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qvev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qvev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qvev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qvev_rec	IN qvev_rec_type,
      x_qvev_rec	OUT NOCOPY qvev_rec_type
    ) RETURN VARCHAR2 IS
      l_qvev_rec                     qvev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qvev_rec := p_qvev_rec;
      -- Get current database values
      l_qvev_rec := get_rec(p_qvev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qvev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.id := l_qvev_rec.id;
      END IF;
      IF (x_qvev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.object_version_number := l_qvev_rec.object_version_number;
      END IF;
      IF (x_qvev_rec.pqy_id = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.pqy_id := l_qvev_rec.pqy_id;
      END IF;
      IF (x_qvev_rec.value = OKC_API.G_MISS_CHAR)
      THEN
        x_qvev_rec.value := l_qvev_rec.value;
      END IF;
      IF (x_qvev_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_qvev_rec.description := l_qvev_rec.description;
      END IF;
      IF (x_qvev_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_qvev_rec.from_date := l_qvev_rec.from_date;
      END IF;

      IF (x_qvev_rec.TO_DATE = OKC_API.G_MISS_DATE)
      THEN
        x_qvev_rec.TO_DATE := l_qvev_rec.TO_DATE;
      END IF;
      IF (x_qvev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.created_by := l_qvev_rec.created_by;
      END IF;
      IF (x_qvev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qvev_rec.creation_date := l_qvev_rec.creation_date;
      END IF;
      IF (x_qvev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.last_updated_by := l_qvev_rec.last_updated_by;
      END IF;
      IF (x_qvev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qvev_rec.last_update_date := l_qvev_rec.last_update_date;
      END IF;
      IF (x_qvev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qvev_rec.last_update_login := l_qvev_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_PQY_VALUES_V --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_qvev_rec IN  qvev_rec_type,
      x_qvev_rec OUT NOCOPY qvev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qvev_rec := p_qvev_rec;
      x_qvev_rec.OBJECT_VERSION_NUMBER := NVL(x_qvev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qvev_rec,                        -- IN
      l_qvev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qvev_rec, l_def_qvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qvev_rec := fill_who_columns(l_def_qvev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qvev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qvev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qvev_rec, l_qve_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qve_rec,
      lx_qve_rec
    );

    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qve_rec, l_def_qvev_rec);
    x_qvev_rec := l_def_qvev_rec;
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
  -- PL/SQL TBL update_row for:QVEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_tbl                     IN qvev_tbl_type,
    x_qvev_tbl                     OUT NOCOPY qvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qvev_rec                     => p_qvev_tbl(i),
          x_qvev_rec                     => x_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);
        i := p_qvev_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
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
  -----------------------------------
  -- delete_row for:OKL_PQY_VALUES --
  -----------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qve_rec                      IN qve_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALUES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qve_rec                      qve_rec_type:= p_qve_rec;
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
    DELETE FROM OKL_PQY_VALUES
     WHERE ID = l_qve_rec.id;

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
  -- delete_row for:OKL_PQY_VALUES_V --
  -------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_rec                     IN qvev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qvev_rec                     qvev_rec_type := p_qvev_rec;
    l_qve_rec                      qve_rec_type;
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
    migrate(l_qvev_rec, l_qve_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qve_rec
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
  -- PL/SQL TBL delete_row for:QVEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qvev_tbl                     IN qvev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qvev_tbl.COUNT > 0) THEN
      i := p_qvev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qvev_rec                     => p_qvev_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_qvev_tbl.LAST);

        i := p_qvev_tbl.NEXT(i);
      END LOOP;
	  --TCHGS: return overall status
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

  ----------------------------------------
  -- PROCEDURE  LOAD_SEED_ROW --
  ----------------------------------------
  PROCEDURE LOAD_SEED_ROW(
    p_qve_id                 IN VARCHAR2,
    p_value                  IN VARCHAR2,
    p_pqy_id             	 IN VARCHAR2,
    p_object_version_number  IN VARCHAR2,
    p_from_date              IN VARCHAR2,
    p_to_date                IN VARCHAR2,
    p_description            IN VARCHAR2,
    p_last_update_date       IN VARCHAR2,
    p_owner                  IN VARCHAR2) IS

    id        NUMBER;
    f_luby    NUMBER;  -- entity owner in file
    f_ludate  DATE;    -- entity update date in file
    db_luby   NUMBER;  -- entity owner in db
    db_ludate DATE;    -- entity update date in db
   BEGIN
      -- Translate owner to file_last_updated_by
      f_luby := fnd_load_util.owner_id(p_owner);

      -- Translate char last_update_date to date
      f_ludate := nvl(to_date(p_last_update_date, 'YYYY/MM/DD'), sysdate);

      BEGIN

       SELECT ID , LAST_UPDATED_BY, LAST_UPDATE_DATE
       into id, db_luby, db_ludate
       from OKL_PQY_VALUES
       where ID = p_qve_id;

       IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
          UPDATE OKL_PQY_VALUES
          SET    PQY_ID                = TO_NUMBER(p_pqy_id),
                 OBJECT_VERSION_NUMBER = TO_NUMBER(p_object_version_number),
                 DESCRIPTION        = p_description,
                 VALUE              = p_value,
                 FROM_DATE          = TO_DATE(p_from_date, 'YYYY/MM/DD'),
                 TO_DATE            = TO_DATE(p_to_date, 'YYYY/MM/DD'),
                 LAST_UPDATE_DATE   = f_ludate,
                 LAST_UPDATED_BY    = f_luby,
                 LAST_UPDATE_LOGIN  = 0
          WHERE  ID = to_number(p_qve_id);
       END IF;
     exception
      when no_data_found then
          INSERT INTO OKL_PQY_VALUES
          (
           ID,
           VALUE,
           PQY_ID,
           OBJECT_VERSION_NUMBER,
           DESCRIPTION,
           FROM_DATE,
           TO_DATE,
           CREATED_BY,
           CREATION_DATE,
           LAST_UPDATED_BY,
           LAST_UPDATE_DATE,
           LAST_UPDATE_LOGIN
           )
          VALUES(
           TO_NUMBER(p_qve_id),
           p_value,
           TO_NUMBER(p_pqy_id),
           TO_NUMBER(p_object_version_number),
           p_description,
           TO_DATE(p_from_date, 'YYYY/MM/DD'),
           TO_DATE(p_to_date, 'YYYY/MM/DD'),
           f_luby,
           f_ludate,
           f_luby,
           f_ludate,
           0);
    END;
  END LOAD_SEED_ROW;
END OKL_QVE_PVT;

/
