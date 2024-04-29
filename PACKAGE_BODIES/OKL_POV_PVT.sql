--------------------------------------------------------
--  DDL for Package Body OKL_POV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_POV_PVT" AS
/* $Header: OKLSPOVB.pls 115.7 2002/12/18 13:04:07 kjinger noship $ */
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
  -- FUNCTION get_rec for: OKL_PDT_OPT_VALS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pov_rec                      IN pov_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pov_rec_type IS
    CURSOR okl_pdt_opt_vals_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OVE_ID,
            PON_ID,
            FROM_DATE,
            TO_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opt_Vals
     WHERE okl_pdt_opt_vals.id  = p_id;
    l_okl_pdt_opt_vals_pk          okl_pdt_opt_vals_pk_csr%ROWTYPE;
    l_pov_rec                      pov_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_pdt_opt_vals_pk_csr (p_pov_rec.id);
    FETCH okl_pdt_opt_vals_pk_csr INTO
              l_pov_rec.ID,
              l_pov_rec.OVE_ID,
              l_pov_rec.PON_ID,
              l_pov_rec.FROM_DATE,
              l_pov_rec.TO_DATE,
              l_pov_rec.OBJECT_VERSION_NUMBER,
              l_pov_rec.CREATED_BY,
              l_pov_rec.CREATION_DATE,
              l_pov_rec.LAST_UPDATED_BY,
              l_pov_rec.LAST_UPDATE_DATE,
              l_pov_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_pdt_opt_vals_pk_csr%NOTFOUND;
    CLOSE okl_pdt_opt_vals_pk_csr;
    RETURN(l_pov_rec);
  END get_rec;

  FUNCTION get_rec (
    p_pov_rec                      IN pov_rec_type
  ) RETURN pov_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_pov_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_PDT_OPT_VALS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_povv_rec                     IN povv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN povv_rec_type IS
    CURSOR okl_povv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            OVE_ID,
            PON_ID,
            FROM_DATE,
            CREATED_BY,
            TO_DATE,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Pdt_Opt_Vals_V
     WHERE okl_pdt_opt_vals_v.id = p_id;
    l_okl_povv_pk                  okl_povv_pk_csr%ROWTYPE;
    l_povv_rec                     povv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_povv_pk_csr (p_povv_rec.id);
    FETCH okl_povv_pk_csr INTO
              l_povv_rec.ID,
              l_povv_rec.OBJECT_VERSION_NUMBER,
              l_povv_rec.OVE_ID,
              l_povv_rec.PON_ID,
              l_povv_rec.FROM_DATE,
              l_povv_rec.CREATED_BY,
              l_povv_rec.TO_DATE,
              l_povv_rec.CREATION_DATE,
              l_povv_rec.LAST_UPDATED_BY,
              l_povv_rec.LAST_UPDATE_DATE,
              l_povv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_povv_pk_csr%NOTFOUND;
    CLOSE okl_povv_pk_csr;
    RETURN(l_povv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_povv_rec                     IN povv_rec_type
  ) RETURN povv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_povv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_PDT_OPT_VALS_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_povv_rec	IN povv_rec_type
  ) RETURN povv_rec_type IS
    l_povv_rec	povv_rec_type := p_povv_rec;
  BEGIN
    IF (l_povv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.object_version_number := NULL;
    END IF;
    IF (l_povv_rec.ove_id = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.ove_id := NULL;
    END IF;
    IF (l_povv_rec.pon_id = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.pon_id := NULL;
    END IF;
    IF (l_povv_rec.from_date = OKC_API.G_MISS_DATE) THEN
      l_povv_rec.from_date := NULL;
    END IF;
    IF (l_povv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.created_by := NULL;
    END IF;
    IF (l_povv_rec.to_date = OKC_API.G_MISS_DATE) THEN
      l_povv_rec.to_date := NULL;
    END IF;
    IF (l_povv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_povv_rec.creation_date := NULL;
    END IF;
    IF (l_povv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.last_updated_by := NULL;
    END IF;
    IF (l_povv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_povv_rec.last_update_date := NULL;
    END IF;
    IF (l_povv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_povv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_povv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Attributes for:OKL_PDT_OPT_VALS_V --
  ------------------------------------------------

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
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_povv_rec.id = OKC_API.G_MISS_NUM OR
       p_povv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name       =>G_APP_NAME,
                               p_msg_name       =>G_UNEXPECTED_ERROR,
                               p_token1         =>G_SQL_SQLCODE_TOKEN,
                               p_token1_value   =>sqlcode,
                               p_token2         =>G_SQL_SQLERRM_TOKEN,
                               p_token2_value   =>sqlerrm);
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
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_povv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_povv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;
------end of Validate_Object_Version_Number-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Ove_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Ove_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Ove_Id (
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opt_vals_foreign1 (p_foreign  OKL_PDT_OPT_VALS.OVE_ID%TYPE) IS
    SELECT ID
       FROM OKL_OPT_VALUES_V
      WHERE OKL_OPT_VALUES_V.ID =  p_foreign;

    l_foreign_key                   OKL_PDT_OPT_VALS_V.OVE_ID%TYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_povv_rec.ove_id = OKC_API.G_MISS_NUM OR
       p_povv_rec.ove_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ove_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

	IF p_povv_rec.ove_id IS NOT NULL THEN
    OPEN okl_pdt_opt_vals_foreign1 (p_povv_rec.ove_id);
    FETCH okl_pdt_opt_vals_foreign1 INTO l_foreign_key;
    IF okl_pdt_opt_vals_foreign1%NOTFOUND THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_KEY,G_COL_NAME_TOKEN,'ove_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;

      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opt_vals_foreign1;
	END IF;


  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Ove_Id;
------end of Validate_Ove_Id-----------------------------------

---------------------------------------------------------------------------
  -- PROCEDURE Validate _Pon_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate _Pon_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------

PROCEDURE Validate_Pon_Id (
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR okl_pdt_opt_vals_foreign2 (p_foreign  OKL_PDT_OPT_VALS.PON_ID%TYPE) IS
    SELECT ID
       FROM OKL_PDT_OPTS_V
      WHERE OKL_PDT_OPTS_V.ID =  p_foreign;

    l_foreign_key                   OKL_PDT_OPT_VALS_V.PON_ID%TYPE;


  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_povv_rec.pon_id = OKC_API.G_MISS_NUM OR
       p_povv_rec.pon_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pon_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

	IF p_povv_rec.pon_id IS NOT NULL THEN
    OPEN okl_pdt_opt_vals_foreign2 (p_povv_rec.pon_id);
    FETCH okl_pdt_opt_vals_foreign2 INTO l_foreign_key;
    IF okl_pdt_opt_vals_foreign2%NOTFOUND THEN
         OKC_API.set_message(G_APP_NAME, G_INVALID_KEY,G_COL_NAME_TOKEN,'pon_id');
         x_return_status := OKC_API.G_RET_STS_ERROR;

      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opt_vals_foreign2;
	END IF;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Pon_Id;
------end of Validate_Pon_Id-----------------------------------

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
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_povv_rec.from_date IS NULL OR p_povv_rec.from_date = OKC_API.G_MISS_DATE
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'from_date');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
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

PROCEDURE Validate_To_Date(p_povv_rec IN  povv_rec_type,
                           x_return_status OUT NOCOPY  VARCHAR2)IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF (p_povv_rec.to_date IS NOT NULL) AND
       (p_povv_rec.to_date < p_povv_rec.from_date) THEN
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
                          p_token1       => G_SQL_SQLCODE_TOKEN,
                          p_token1_value => sqlcode,
                          p_token2       => G_SQL_SQLERRM_TOKEN,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_To_Date;------end of Validate_To_Date-----------------------------------


---------------------------------------------------------------------------
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
    p_povv_rec IN  povv_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
  ) IS

    CURSOR okl_pdt_opt_vals_unique (p_unique1  OKL_PDT_OPT_VALS_V.OVE_ID%TYPE, p_unique2  OKL_PDT_OPT_VALS_V.PON_ID%TYPE) IS
    SELECT '1'
       FROM OKL_PDT_OPT_VALS_V
      WHERE OKL_PDT_OPT_VALS_V.OVE_ID =  p_unique1 AND
            OKL_PDT_OPT_VALS_V.PON_ID =  p_unique2 AND
            OKL_PDT_OPT_VALS_V.ID <> nvl(p_povv_rec.id,-9999);

    l_unique_key                   VARCHAR2(1);

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN okl_pdt_opt_vals_unique (p_povv_rec.ove_id, p_povv_rec.pon_id);
    FETCH okl_pdt_opt_vals_unique INTO l_unique_key;
    IF okl_pdt_opt_vals_unique%FOUND THEN
       OKC_API.set_message(G_APP_NAME,G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'ove_id');
       OKC_API.set_message(G_APP_NAME,G_DUPLICATE_RECORD,G_COL_NAME_TOKEN,'pon_id');
       x_return_status := OKC_API.G_RET_STS_ERROR;
      ELSE
          x_return_status := OKC_API.G_RET_STS_SUCCESS;
    END IF;
    CLOSE okl_pdt_opt_vals_unique;

  EXCEPTION
     WHEN OTHERS THEN
           OKC_API.set_message(p_app_name  =>G_APP_NAME,
                          p_msg_name       =>G_UNEXPECTED_ERROR,
                          p_token1         =>G_SQL_SQLCODE_TOKEN,
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Key;

-----END OF VALIDATE UNIQUE KEY----------------------------------------------

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
    p_povv_rec IN  povv_rec_type
  ) RETURN VARCHAR IS
       x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
       l_return_status	VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    ---- CHECK FOR ID-------------------------
    Validate_Id (p_povv_rec, x_return_status);
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
    Validate_Object_Version_Number (p_povv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
    ELSE
       l_return_status := x_return_status;
     END IF;
    END IF;

    -----CHECK FOR OVE_ID----------------------------
    Validate_Ove_Id (p_povv_rec,x_return_status);
    IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
        l_return_status := x_return_status;
     END IF;
    END IF;

-----CHECK FOR PON_ID----------------------------
    Validate_Pon_Id (p_povv_rec,x_return_status);
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
    Validate_From_Date (p_povv_rec,x_return_status);
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
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
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
    p_povv_rec IN  povv_rec_type
  ) RETURN VARCHAR IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN

   --------CHECK FOR UNIQUE KEY------------------
    Validate_Unique_Key (p_povv_rec,x_return_status);
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
    Validate_To_Date (p_povv_rec,x_return_status);
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
                          p_token1_value   =>sqlcode,
                          p_token2         =>G_SQL_SQLERRM_TOKEN,
                          p_token2_value   =>sqlerrm);
           x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
        RETURN(l_return_status);

  END Validate_Record;

-----END OF VALIDATE RECORD-------------------------

----------TCHGS NEW CHANGS END-------------------------------------------------

----TCHGS OLD CODE COMMENTES BEGIN --------------------
--  FUNCTION Validate_Attributes (
--    p_povv_rec IN  povv_rec_type
--  ) RETURN VARCHAR2 IS
--    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--  BEGIN
--    IF p_povv_rec.id = OKC_API.G_MISS_NUM OR
--       p_povv_rec.id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_povv_rec.object_version_number = OKC_API.G_MISS_NUM OR
--          p_povv_rec.object_version_number IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_povv_rec.ove_id = OKC_API.G_MISS_NUM OR
--          p_povv_rec.ove_id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ove_id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    ELSIF p_povv_rec.pon_id = OKC_API.G_MISS_NUM OR
--          p_povv_rec.pon_id IS NULL
--    THEN
--      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pon_id');
--      l_return_status := OKC_API.G_RET_STS_ERROR;
--    END IF;
--    RETURN(l_return_status);
--  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKL_PDT_OPT_VALS_V --
  --------------------------------------------
--  FUNCTION Validate_Record (
--    p_povv_rec IN povv_rec_type
--  ) RETURN VARCHAR2 IS
--    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
--  BEGIN
--    RETURN (l_return_status);
--  END Validate_Record;

  ---------TCHGS OLD CODE COMMENTES END-------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN povv_rec_type,
    p_to	IN OUT NOCOPY pov_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ove_id := p_from.ove_id;
    p_to.pon_id := p_from.pon_id;
    p_to.from_date := p_from.from_date;
    p_to.to_date := p_from.to_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN pov_rec_type,
    p_to	IN OUT NOCOPY povv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.ove_id := p_from.ove_id;
    p_to.pon_id := p_from.pon_id;
    p_to.from_date := p_from.from_date;
    p_to.to_date := p_from.to_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKL_PDT_OPT_VALS_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_rec                     IN povv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_povv_rec                     povv_rec_type := p_povv_rec;
    l_pov_rec                      pov_rec_type;
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
    l_return_status := Validate_Attributes(l_povv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_povv_rec);
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
  -- PL/SQL TBL validate_row for:POVV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_tbl                     IN povv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_povv_rec                     => p_povv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_povv_tbl.LAST);
        i := p_povv_tbl.NEXT(i);
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
  -------------------------------------
  -- insert_row for:OKL_PDT_OPT_VALS --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pov_rec                      IN pov_rec_type,
    x_pov_rec                      OUT NOCOPY pov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pov_rec                      pov_rec_type := p_pov_rec;
    l_def_pov_rec                  pov_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKL_PDT_OPT_VALS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pov_rec IN  pov_rec_type,
      x_pov_rec OUT NOCOPY pov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pov_rec := p_pov_rec;
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
      p_pov_rec,                         -- IN
      l_pov_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_PDT_OPT_VALS(
        id,
        ove_id,
        pon_id,
        from_date,
        to_date,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_pov_rec.id,
        l_pov_rec.ove_id,
        l_pov_rec.pon_id,
        l_pov_rec.from_date,
        l_pov_rec.to_date,
        l_pov_rec.object_version_number,
        l_pov_rec.created_by,
        l_pov_rec.creation_date,
        l_pov_rec.last_updated_by,
        l_pov_rec.last_update_date,
        l_pov_rec.last_update_login);
    -- Set OUT values
    x_pov_rec := l_pov_rec;
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
  ---------------------------------------
  -- insert_row for:OKL_PDT_OPT_VALS_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_rec                     IN povv_rec_type,
    x_povv_rec                     OUT NOCOPY povv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_povv_rec                     povv_rec_type;
    l_def_povv_rec                 povv_rec_type;
    l_pov_rec                      pov_rec_type;
    lx_pov_rec                     pov_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_povv_rec	IN povv_rec_type
    ) RETURN povv_rec_type IS
      l_povv_rec	povv_rec_type := p_povv_rec;
    BEGIN
      l_povv_rec.CREATION_DATE := SYSDATE;
      l_povv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_povv_rec.LAST_UPDATE_DATE := l_povv_rec.CREATION_DATE;
      l_povv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_povv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_povv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKL_PDT_OPT_VALS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_povv_rec IN  povv_rec_type,
      x_povv_rec OUT NOCOPY povv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_povv_rec := p_povv_rec;
      x_povv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_povv_rec := null_out_defaults(p_povv_rec);
    -- Set primary key value
    l_povv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_povv_rec,                        -- IN
      l_def_povv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_povv_rec := fill_who_columns(l_def_povv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_povv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_povv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_povv_rec, l_pov_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pov_rec,
      lx_pov_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pov_rec, l_def_povv_rec);
    -- Set OUT values
    x_povv_rec := l_def_povv_rec;
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
  -- PL/SQL TBL insert_row for:POVV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_tbl                     IN povv_tbl_type,
    x_povv_tbl                     OUT NOCOPY povv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_povv_rec                     => p_povv_tbl(i),
          x_povv_rec                     => x_povv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_povv_tbl.LAST);
        i := p_povv_tbl.NEXT(i);
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
  -----------------------------------
  -- lock_row for:OKL_PDT_OPT_VALS --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pov_rec                      IN pov_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pov_rec IN pov_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PDT_OPT_VALS
     WHERE ID = p_pov_rec.id
       AND OBJECT_VERSION_NUMBER = p_pov_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_pov_rec IN pov_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_PDT_OPT_VALS
    WHERE ID = p_pov_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_PDT_OPT_VALS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_PDT_OPT_VALS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_pov_rec);
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
      OPEN lchk_csr(p_pov_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_pov_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_pov_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKL_PDT_OPT_VALS_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_rec                     IN povv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pov_rec                      pov_rec_type;
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
    migrate(p_povv_rec, l_pov_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pov_rec
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
  -- PL/SQL TBL lock_row for:POVV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_tbl                     IN povv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_povv_rec                     => p_povv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_povv_tbl.LAST);
        i := p_povv_tbl.NEXT(i);
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
  -------------------------------------
  -- update_row for:OKL_PDT_OPT_VALS --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pov_rec                      IN pov_rec_type,
    x_pov_rec                      OUT NOCOPY pov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pov_rec                      pov_rec_type := p_pov_rec;
    l_def_pov_rec                  pov_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pov_rec	IN pov_rec_type,
      x_pov_rec	OUT NOCOPY pov_rec_type
    ) RETURN VARCHAR2 IS
      l_pov_rec                      pov_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pov_rec := p_pov_rec;
      -- Get current database values
      l_pov_rec := get_rec(p_pov_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pov_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.id := l_pov_rec.id;
      END IF;
      IF (x_pov_rec.ove_id = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.ove_id := l_pov_rec.ove_id;
      END IF;
      IF (x_pov_rec.pon_id = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.pon_id := l_pov_rec.pon_id;
      END IF;
      IF (x_pov_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_pov_rec.from_date := l_pov_rec.from_date;
      END IF;
      IF (x_pov_rec.to_date = OKC_API.G_MISS_DATE)
      THEN
        x_pov_rec.to_date := l_pov_rec.to_date;
      END IF;
      IF (x_pov_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.object_version_number := l_pov_rec.object_version_number;
      END IF;
      IF (x_pov_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.created_by := l_pov_rec.created_by;
      END IF;
      IF (x_pov_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pov_rec.creation_date := l_pov_rec.creation_date;
      END IF;
      IF (x_pov_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.last_updated_by := l_pov_rec.last_updated_by;
      END IF;
      IF (x_pov_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pov_rec.last_update_date := l_pov_rec.last_update_date;
      END IF;
      IF (x_pov_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pov_rec.last_update_login := l_pov_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKL_PDT_OPT_VALS --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_pov_rec IN  pov_rec_type,
      x_pov_rec OUT NOCOPY pov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_pov_rec := p_pov_rec;
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
      p_pov_rec,                         -- IN
      l_pov_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pov_rec, l_def_pov_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_PDT_OPT_VALS
    SET OVE_ID = l_def_pov_rec.ove_id,
        PON_ID = l_def_pov_rec.pon_id,
        FROM_DATE = l_def_pov_rec.from_date,
        TO_DATE = l_def_pov_rec.to_date,
        OBJECT_VERSION_NUMBER = l_def_pov_rec.object_version_number,
        CREATED_BY = l_def_pov_rec.created_by,
        CREATION_DATE = l_def_pov_rec.creation_date,
        LAST_UPDATED_BY = l_def_pov_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pov_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pov_rec.last_update_login
    WHERE ID = l_def_pov_rec.id;

    x_pov_rec := l_def_pov_rec;
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
  ---------------------------------------
  -- update_row for:OKL_PDT_OPT_VALS_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_rec                     IN povv_rec_type,
    x_povv_rec                     OUT NOCOPY povv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_povv_rec                     povv_rec_type := p_povv_rec;
    l_def_povv_rec                 povv_rec_type;
    l_pov_rec                      pov_rec_type;
    lx_pov_rec                     pov_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_povv_rec	IN povv_rec_type
    ) RETURN povv_rec_type IS
      l_povv_rec	povv_rec_type := p_povv_rec;
    BEGIN
      l_povv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_povv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_povv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_povv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_povv_rec	IN povv_rec_type,
      x_povv_rec	OUT NOCOPY povv_rec_type
    ) RETURN VARCHAR2 IS
      l_povv_rec                     povv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_povv_rec := p_povv_rec;
      -- Get current database values
      l_povv_rec := get_rec(p_povv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_povv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.id := l_povv_rec.id;
      END IF;
      IF (x_povv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.object_version_number := l_povv_rec.object_version_number;
      END IF;
      IF (x_povv_rec.ove_id = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.ove_id := l_povv_rec.ove_id;
      END IF;
      IF (x_povv_rec.pon_id = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.pon_id := l_povv_rec.pon_id;
      END IF;
      IF (x_povv_rec.from_date = OKC_API.G_MISS_DATE)
      THEN
        x_povv_rec.from_date := l_povv_rec.from_date;
      END IF;
      IF (x_povv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.created_by := l_povv_rec.created_by;
      END IF;
      IF (x_povv_rec.to_date = OKC_API.G_MISS_DATE)
      THEN
        x_povv_rec.to_date := l_povv_rec.to_date;
      END IF;
      IF (x_povv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_povv_rec.creation_date := l_povv_rec.creation_date;
      END IF;
      IF (x_povv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.last_updated_by := l_povv_rec.last_updated_by;
      END IF;
      IF (x_povv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_povv_rec.last_update_date := l_povv_rec.last_update_date;
      END IF;
      IF (x_povv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_povv_rec.last_update_login := l_povv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKL_PDT_OPT_VALS_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_povv_rec IN  povv_rec_type,
      x_povv_rec OUT NOCOPY povv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_povv_rec := p_povv_rec;
      x_povv_rec.OBJECT_VERSION_NUMBER := NVL(x_povv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_povv_rec,                        -- IN
      l_povv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_povv_rec, l_def_povv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_povv_rec := fill_who_columns(l_def_povv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_povv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_povv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_povv_rec, l_pov_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pov_rec,
      lx_pov_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pov_rec, l_def_povv_rec);
    x_povv_rec := l_def_povv_rec;
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
  -- PL/SQL TBL update_row for:POVV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_tbl                     IN povv_tbl_type,
    x_povv_tbl                     OUT NOCOPY povv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_povv_rec                     => p_povv_tbl(i),
          x_povv_rec                     => x_povv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_povv_tbl.LAST);
        i := p_povv_tbl.NEXT(i);
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
  -------------------------------------
  -- delete_row for:OKL_PDT_OPT_VALS --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pov_rec                      IN pov_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'VALS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pov_rec                      pov_rec_type:= p_pov_rec;
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
    DELETE FROM OKL_PDT_OPT_VALS
     WHERE ID = l_pov_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKL_PDT_OPT_VALS_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_rec                     IN povv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_povv_rec                     povv_rec_type := p_povv_rec;
    l_pov_rec                      pov_rec_type;
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
    migrate(l_povv_rec, l_pov_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pov_rec
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
  -- PL/SQL TBL delete_row for:POVV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_povv_tbl                     IN povv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS; --TCHGS
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_povv_tbl.COUNT > 0) THEN
      i := p_povv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_povv_rec                     => p_povv_tbl(i));
		-- TCHGS: Store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
		   IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
		   	  l_overall_status := x_return_status;
		   END IF;
		END IF;
        EXIT WHEN (i = p_povv_tbl.LAST);
        i := p_povv_tbl.NEXT(i);
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
END OKL_POV_PVT;

/
