--------------------------------------------------------
--  DDL for Package Body OKL_CGM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_CGM_PVT" AS
/* $Header: OKLSCGMB.pls 120.2 2006/12/07 06:16:42 ssdeshpa noship $ */
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
  -- FUNCTION get_rec for: OKL_CNTX_GRP_PRMTRS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cgm_rec                      IN cgm_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cgm_rec_type IS
    CURSOR okl_cntx_grp_prmtrs_b_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CGR_ID,
            PMR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Cntx_Grp_Prmtrs
     WHERE okl_cntx_grp_prmtrs.id = p_id;
    l_okl_cntx_grp_prmtrs_b_pk     okl_cntx_grp_prmtrs_b_pk_csr%ROWTYPE;
    l_cgm_rec                      cgm_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cntx_grp_prmtrs_b_pk_csr (p_cgm_rec.id);
    FETCH okl_cntx_grp_prmtrs_b_pk_csr INTO
              l_cgm_rec.ID,
              l_cgm_rec.CGR_ID,
              l_cgm_rec.PMR_ID,
              l_cgm_rec.OBJECT_VERSION_NUMBER,
              l_cgm_rec.CREATED_BY,
              l_cgm_rec.CREATION_DATE,
              l_cgm_rec.LAST_UPDATED_BY,
              l_cgm_rec.LAST_UPDATE_DATE,
              l_cgm_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cntx_grp_prmtrs_b_pk_csr%NOTFOUND;
    CLOSE okl_cntx_grp_prmtrs_b_pk_csr;
    RETURN(l_cgm_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cgm_rec                      IN cgm_rec_type
  ) RETURN cgm_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cgm_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_CNTX_GRP_PRMTRS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cgmv_rec                     IN cgmv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cgmv_rec_type IS
    CURSOR okl_cgmv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CGR_ID,
            PMR_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Cntx_Grp_Prmtrs_V
     WHERE okl_cntx_grp_prmtrs_v.id = p_id;
    l_okl_cgmv_pk                  okl_cgmv_pk_csr%ROWTYPE;
    l_cgmv_rec                     cgmv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_cgmv_pk_csr (p_cgmv_rec.id);
    FETCH okl_cgmv_pk_csr INTO
              l_cgmv_rec.ID,
              l_cgmv_rec.OBJECT_VERSION_NUMBER,
              l_cgmv_rec.CGR_ID,
              l_cgmv_rec.PMR_ID,
              l_cgmv_rec.CREATED_BY,
              l_cgmv_rec.CREATION_DATE,
              l_cgmv_rec.LAST_UPDATED_BY,
              l_cgmv_rec.LAST_UPDATE_DATE,
              l_cgmv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_cgmv_pk_csr%NOTFOUND;
    CLOSE okl_cgmv_pk_csr;
    RETURN(l_cgmv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cgmv_rec                     IN cgmv_rec_type
  ) RETURN cgmv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cgmv_rec, l_row_notfound));
  END get_rec;

  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_CNTX_GRP_PRMTRS_V --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cgmv_rec	IN cgmv_rec_type
  ) RETURN cgmv_rec_type IS
    l_cgmv_rec	cgmv_rec_type := p_cgmv_rec;
  BEGIN
    IF (l_cgmv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.object_version_number := NULL;
    END IF;
    IF (l_cgmv_rec.cgr_id = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.cgr_id := NULL;
    END IF;
    IF (l_cgmv_rec.pmr_id = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.pmr_id := NULL;
    END IF;
    IF (l_cgmv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.created_by := NULL;
    END IF;
    IF (l_cgmv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cgmv_rec.creation_date := NULL;
    END IF;
    IF (l_cgmv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cgmv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cgmv_rec.last_update_date := NULL;
    END IF;
    IF (l_cgmv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cgmv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cgmv_rec);
  END null_out_defaults;

  /** Commented out nocopy generated code in favor of hand written code *** SBALASHA001 Start ***

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKL_CNTX_GRP_PRMTRS_V --
  ---------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cgmv_rec IN  cgmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_cgmv_rec.id = OKC_API.G_MISS_NUM OR
       p_cgmv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cgmv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cgmv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cgmv_rec.cgr_id = OKC_API.G_MISS_NUM OR
          p_cgmv_rec.cgr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cgr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cgmv_rec.pmr_id = OKC_API.G_MISS_NUM OR
          p_cgmv_rec.pmr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pmr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Record for:OKL_CNTX_GRP_PRMTRS_V --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_cgmv_rec IN cgmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  *** SBALASHA001 End *** **/

 /** SBALASHA001 Start *** -
      INFO: hand coded function related to validate_attribute  **/

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
  PROCEDURE Validate_Object_Version_Number(x_return_status OUT NOCOPY  VARCHAR2
                                          ,p_cgmv_rec      IN   cgmv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- check for data before processing
    IF ( p_cgmv_rec.object_version_number IS NULL ) OR
       ( p_cgmv_rec.object_version_Number = OKC_API.G_MISS_NUM ) THEN
       OKC_API.SET_MESSAGE( p_app_name       => g_app_name,
                            p_msg_name       => g_required_value,
                            p_token1         => g_col_name_token,
                            p_token1_value   => 'object_version_number' );
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
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Object_Version_Number;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Pmr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Pmr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Pmr_Id(
    x_return_status OUT NOCOPY  VARCHAR2,
    p_cgmv_rec      IN   cgmv_rec_type
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             Boolean := False;

  -- Cursor For OKL_CGM_PMR_FK - Foreign Key Constraint
  CURSOR okl_pmrv_pk_csr (p_id IN OKL_CNTX_GRP_PRMTRS_V.pmr_id%TYPE) IS
  SELECT '1'
    FROM OKL_PARAMETERS_V
   WHERE OKL_PARAMETERS_V.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cgmv_rec.cgr_id = OKC_API.G_MISS_NUM OR
       p_cgmv_rec.cgr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pmr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_pmrv_pk_csr(p_cgmv_rec.pmr_id);
    FETCH okl_pmrv_pk_csr INTO l_dummy;
    l_row_not_found := okl_pmrv_pk_csr%NOTFOUND;
    CLOSE okl_pmrv_pk_csr;

    IF l_row_not_found then
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'pmr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_pmrv_pk_csr%ISOPEN THEN
        CLOSE okl_pmrv_pk_csr;
      END IF;
  END Validate_Pmr_Id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Cgr_Id
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Cgr_Id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cgr_Id(
    x_return_status OUT NOCOPY  VARCHAR2,
    p_cgmv_rec      IN   cgmv_rec_type
  ) IS

  l_dummy                 VARCHAR2(1) := '?';
  l_row_not_found             Boolean := False;

  -- Cursor For OKL_CGM_CGR_FK - Foreign Key Constraint
  CURSOR okl_cgrv_pk_csr (p_id IN OKL_CNTX_GRP_PRMTRS_V.cgr_id%TYPE) IS
  SELECT '1'
    FROM OKL_CONTEXT_GROUPS_V
   WHERE OKL_CONTEXT_GROUPS_V.id = p_id;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF p_cgmv_rec.cgr_id = OKC_API.G_MISS_NUM OR
       p_cgmv_rec.cgr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cgr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    OPEN okl_cgrv_pk_csr(p_cgmv_rec.cgr_id);
    FETCH okl_cgrv_pk_csr INTO l_dummy;
    l_row_not_found := okl_cgrv_pk_csr%NOTFOUND;
    CLOSE okl_cgrv_pk_csr;

    IF l_row_not_found then
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'cgr_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => G_APP_NAME
                         ,p_msg_name     => G_UNEXPECTED_ERROR
                         ,p_token1       => G_SQLCODE_TOKEN
                         ,p_token1_value => SQLCODE
                         ,p_token2       => G_SQLERRM_TOKEN
                         ,p_token2_value => SQLERRM);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

      -- verify that the cursor was closed
      IF okl_cgrv_pk_csr%ISOPEN THEN
        CLOSE okl_cgrv_pk_csr;
      END IF;
  END Validate_Cgr_Id;



  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
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
    p_cgmv_rec IN  cgmv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN


  	-- call each column-level validation

	-- Validate ID
    IF p_cgmv_rec.id = OKC_API.G_MISS_NUM OR
       p_cgmv_rec.id IS NULL
    THEN
      OKC_API.set_message( G_APP_NAME,
	  					  G_REQUIRED_VALUE,
						  G_COL_NAME_TOKEN, 'id' );
      l_return_status := OKC_API.G_RET_STS_ERROR;
	END IF;

	-- Valid object_version_number
	IF ( p_cgmv_rec.object_version_number IS NOT NULL ) AND
	( p_cgmv_rec.object_version_number <> OKC_API.G_MISS_NUM ) THEN
		Validate_Object_Version_Number( x_return_status, p_cgmv_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;

	-- Valid Cgr_Id
	IF ( p_cgmv_rec.cgr_id IS NOT NULL ) AND
	( p_cgmv_rec.cgr_id <> OKC_API.G_MISS_NUM ) THEN
		Validate_Cgr_Id( x_return_status, p_cgmv_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
		END IF;
	END IF;

	-- Valid Pmr_Id
	IF ( p_cgmv_rec.pmr_id IS NOT NULL ) AND
	( p_cgmv_rec.pmr_id <> OKC_API.G_MISS_NUM ) THEN
		Validate_Pmr_Id( x_return_status, p_cgmv_rec );
		IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
			IF ( x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
				-- need to leave
				l_return_status := x_return_status;
				RAISE G_EXCEPTION_HALT_VALIDATION;
			ELSE
				-- record that there was an error
				l_return_status := x_return_status;
			END IF;
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
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);
       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       RETURN(l_return_status);

  END Validate_Attributes;



/**  *** SBALASHA001 End ***  **/



/**  *** SBALASHA002 Start *** -
      INFO: hand coded function related to validate_record **/


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Unique_Dsf_Record
  ---------------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure Name  : Validate_Unique_Cgm_Record
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Unique_Cgm_Record(
                                  x_return_status OUT NOCOPY     VARCHAR2,
                                  p_cgmv_rec      IN      cgmv_rec_type)
  IS

  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_unq_tbl               OKC_UTIL.unq_tbl_type;
  l_dummy                 VARCHAR2(1);
  l_row_found             Boolean := False;
  CURSOR c1( p_cgr_id okl_cntx_grp_prmtrs_v.cgr_id%TYPE
  		 	 , p_pmr_id okl_cntx_grp_prmtrs_v.pmr_id%TYPE
  		 	 , p_id okl_cntx_grp_prmtrs_v.id%TYPE ) is
  SELECT 1
  FROM okl_cntx_grp_prmtrs_v
  WHERE  p_cgr_id = cgr_id
  and p_pmr_id = pmr_id
  and id <> nvl( p_cgmv_rec.id, -9999 );

  BEGIN

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    OPEN c1( p_cgmv_rec.cgr_id, p_cgmv_rec.pmr_id, p_cgmv_rec.id );
    FETCH c1 into l_dummy;
    l_row_found := c1%FOUND;
    CLOSE c1;
    IF l_row_found then
		OKC_API.set_message( G_APP_NAME, G_UNQS, G_TABLE_TOKEN, 'Okl_Cntx_Grp_Prmtrs_V' );
		x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Unique_Cgm_Record;


  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Record
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
    p_cgmv_rec IN cgmv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

	-- Validate_Unique_Dsf_Record
	Validate_Unique_Cgm_Record( x_return_status, p_cgmv_rec );
	-- store the highest degree of error
	IF ( x_return_status <> OKC_API.G_RET_STS_SUCCESS ) THEN
	  IF ( x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR ) THEN
	      -- need to leave
	      l_return_status := x_return_status;
	      RAISE G_EXCEPTION_HALT_VALIDATION;
	      ELSE
	      -- record that there was an error
	      l_return_status := x_return_status;
	  END IF;
	END IF;
	RETURN( l_return_status );

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary;  validation can continue
    -- with the next column
    NULL;
    RETURN ( l_return_status );

    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE( p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm );

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END Validate_Record;


/** *** SBALASHA002 End *** **/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cgmv_rec_type,
    p_to	IN OUT NOCOPY cgm_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cgr_id := p_from.cgr_id;
    p_to.pmr_id := p_from.pmr_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cgm_rec_type,
    p_to	OUT NOCOPY cgmv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cgr_id := p_from.cgr_id;
    p_to.pmr_id := p_from.pmr_id;
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
  --------------------------------------------
  -- validate_row for:OKL_CNTX_GRP_PRMTRS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgmv_rec                     cgmv_rec_type := p_cgmv_rec;
    l_cgm_rec                      cgm_rec_type;
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
    l_return_status := Validate_Attributes(l_cgmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cgmv_rec);
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
  -- PL/SQL TBL validate_row for:CGMV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN cgmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
    l_overall_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgmv_rec                     => p_cgmv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  ----------------------------------------
  -- insert_row for:OKL_CNTX_GRP_PRMTRS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgm_rec                      IN cgm_rec_type,
    x_cgm_rec                      OUT NOCOPY cgm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRMTRS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgm_rec                      cgm_rec_type := p_cgm_rec;
    l_def_cgm_rec                  cgm_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNTX_GRP_PRMTRS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cgm_rec IN  cgm_rec_type,
      x_cgm_rec OUT NOCOPY cgm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgm_rec := p_cgm_rec;
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
      p_cgm_rec,                         -- IN
      l_cgm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_CNTX_GRP_PRMTRS(
        id,
        cgr_id,
        pmr_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cgm_rec.id,
        l_cgm_rec.cgr_id,
        l_cgm_rec.pmr_id,
        l_cgm_rec.object_version_number,
        l_cgm_rec.created_by,
        l_cgm_rec.creation_date,
        l_cgm_rec.last_updated_by,
        l_cgm_rec.last_update_date,
        l_cgm_rec.last_update_login);
    -- Set OUT values
    x_cgm_rec := l_cgm_rec;
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
  -- insert_row for:OKL_CNTX_GRP_PRMTRS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgmv_rec                     cgmv_rec_type;
    l_def_cgmv_rec                 cgmv_rec_type;
    l_cgm_rec                      cgm_rec_type;
    lx_cgm_rec                     cgm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cgmv_rec	IN cgmv_rec_type
    ) RETURN cgmv_rec_type IS
      l_cgmv_rec	cgmv_rec_type := p_cgmv_rec;
    BEGIN
      l_cgmv_rec.CREATION_DATE := SYSDATE;
      l_cgmv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cgmv_rec.LAST_UPDATE_DATE := l_cgmv_rec.CREATION_DATE;
      l_cgmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cgmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cgmv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTX_GRP_PRMTRS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cgmv_rec IN  cgmv_rec_type,
      x_cgmv_rec OUT NOCOPY cgmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgmv_rec := p_cgmv_rec;
      x_cgmv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cgmv_rec := null_out_defaults(p_cgmv_rec);
    -- Set primary key value
    l_cgmv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cgmv_rec,                        -- IN
      l_def_cgmv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cgmv_rec := fill_who_columns(l_def_cgmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cgmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cgmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cgmv_rec, l_cgm_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgm_rec,
      lx_cgm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cgm_rec, l_def_cgmv_rec);
    -- Set OUT values
    x_cgmv_rec := l_def_cgmv_rec;
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
  -- PL/SQL TBL insert_row for:CGMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgmv_rec                     => p_cgmv_tbl(i),
          x_cgmv_rec                     => x_cgmv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  --------------------------------------
  -- lock_row for:OKL_CNTX_GRP_PRMTRS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgm_rec                      IN cgm_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cgm_rec IN cgm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTX_GRP_PRMTRS
     WHERE ID = p_cgm_rec.id
       AND OBJECT_VERSION_NUMBER = p_cgm_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cgm_rec IN cgm_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_CNTX_GRP_PRMTRS
    WHERE ID = p_cgm_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRMTRS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_CNTX_GRP_PRMTRS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_CNTX_GRP_PRMTRS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cgm_rec);
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
      OPEN lchk_csr(p_cgm_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cgm_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cgm_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKL_CNTX_GRP_PRMTRS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgm_rec                      cgm_rec_type;
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
    migrate(p_cgmv_rec, l_cgm_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgm_rec
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
  -- PL/SQL TBL lock_row for:CGMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN cgmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgmv_rec                     => p_cgmv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  ----------------------------------------
  -- update_row for:OKL_CNTX_GRP_PRMTRS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgm_rec                      IN cgm_rec_type,
    x_cgm_rec                      OUT NOCOPY cgm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRMTRS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgm_rec                      cgm_rec_type := p_cgm_rec;
    l_def_cgm_rec                  cgm_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cgm_rec	IN cgm_rec_type,
      x_cgm_rec	OUT NOCOPY cgm_rec_type
    ) RETURN VARCHAR2 IS
      l_cgm_rec                      cgm_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgm_rec := p_cgm_rec;
      -- Get current database values
      l_cgm_rec := get_rec(p_cgm_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cgm_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.id := l_cgm_rec.id;
      END IF;
      IF (x_cgm_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.cgr_id := l_cgm_rec.cgr_id;
      END IF;
      IF (x_cgm_rec.pmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.pmr_id := l_cgm_rec.pmr_id;
      END IF;
      IF (x_cgm_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.object_version_number := l_cgm_rec.object_version_number;
      END IF;
      IF (x_cgm_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.created_by := l_cgm_rec.created_by;
      END IF;
      IF (x_cgm_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgm_rec.creation_date := l_cgm_rec.creation_date;
      END IF;
      IF (x_cgm_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.last_updated_by := l_cgm_rec.last_updated_by;
      END IF;
      IF (x_cgm_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgm_rec.last_update_date := l_cgm_rec.last_update_date;
      END IF;
      IF (x_cgm_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cgm_rec.last_update_login := l_cgm_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    --------------------------------------------
    -- Set_Attributes for:OKL_CNTX_GRP_PRMTRS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_cgm_rec IN  cgm_rec_type,
      x_cgm_rec OUT NOCOPY cgm_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgm_rec := p_cgm_rec;
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
      p_cgm_rec,                         -- IN
      l_cgm_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cgm_rec, l_def_cgm_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_CNTX_GRP_PRMTRS
    SET CGR_ID = l_def_cgm_rec.cgr_id,
        PMR_ID = l_def_cgm_rec.pmr_id,
        OBJECT_VERSION_NUMBER = l_def_cgm_rec.object_version_number,
        CREATED_BY = l_def_cgm_rec.created_by,
        CREATION_DATE = l_def_cgm_rec.creation_date,
        LAST_UPDATED_BY = l_def_cgm_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cgm_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cgm_rec.last_update_login
    WHERE ID = l_def_cgm_rec.id;

    x_cgm_rec := l_def_cgm_rec;
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
  -- update_row for:OKL_CNTX_GRP_PRMTRS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type,
    x_cgmv_rec                     OUT NOCOPY cgmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgmv_rec                     cgmv_rec_type := p_cgmv_rec;
    l_def_cgmv_rec                 cgmv_rec_type;
    l_cgm_rec                      cgm_rec_type;
    lx_cgm_rec                     cgm_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cgmv_rec	IN cgmv_rec_type
    ) RETURN cgmv_rec_type IS
      l_cgmv_rec	cgmv_rec_type := p_cgmv_rec;
    BEGIN
      l_cgmv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cgmv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cgmv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cgmv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cgmv_rec	IN cgmv_rec_type,
      x_cgmv_rec	OUT NOCOPY cgmv_rec_type
    ) RETURN VARCHAR2 IS
      l_cgmv_rec                     cgmv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgmv_rec := p_cgmv_rec;
      -- Get current database values
      l_cgmv_rec := get_rec(p_cgmv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cgmv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.id := l_cgmv_rec.id;
      END IF;
      IF (x_cgmv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.object_version_number := l_cgmv_rec.object_version_number;
      END IF;
      IF (x_cgmv_rec.cgr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.cgr_id := l_cgmv_rec.cgr_id;
      END IF;
      IF (x_cgmv_rec.pmr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.pmr_id := l_cgmv_rec.pmr_id;
      END IF;
      IF (x_cgmv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.created_by := l_cgmv_rec.created_by;
      END IF;
      IF (x_cgmv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgmv_rec.creation_date := l_cgmv_rec.creation_date;
      END IF;
      IF (x_cgmv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.last_updated_by := l_cgmv_rec.last_updated_by;
      END IF;
      IF (x_cgmv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgmv_rec.last_update_date := l_cgmv_rec.last_update_date;
      END IF;
      IF (x_cgmv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cgmv_rec.last_update_login := l_cgmv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_CNTX_GRP_PRMTRS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cgmv_rec IN  cgmv_rec_type,
      x_cgmv_rec OUT NOCOPY cgmv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgmv_rec := p_cgmv_rec;
      x_cgmv_rec.OBJECT_VERSION_NUMBER := NVL(x_cgmv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cgmv_rec,                        -- IN
      l_cgmv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cgmv_rec, l_def_cgmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cgmv_rec := fill_who_columns(l_def_cgmv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cgmv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cgmv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cgmv_rec, l_cgm_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgm_rec,
      lx_cgm_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cgm_rec, l_def_cgmv_rec);
    x_cgmv_rec := l_def_cgmv_rec;
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
  -- PL/SQL TBL update_row for:CGMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN cgmv_tbl_type,
    x_cgmv_tbl                     OUT NOCOPY cgmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgmv_rec                     => p_cgmv_tbl(i),
          x_cgmv_rec                     => x_cgmv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
  ----------------------------------------
  -- delete_row for:OKL_CNTX_GRP_PRMTRS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgm_rec                      IN cgm_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PRMTRS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgm_rec                      cgm_rec_type:= p_cgm_rec;
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
    DELETE FROM OKL_CNTX_GRP_PRMTRS
     WHERE ID = l_cgm_rec.id;

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
  -- delete_row for:OKL_CNTX_GRP_PRMTRS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_rec                     IN cgmv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgmv_rec                     cgmv_rec_type := p_cgmv_rec;
    l_cgm_rec                      cgm_rec_type;
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
    migrate(l_cgmv_rec, l_cgm_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgm_rec
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
  -- PL/SQL TBL delete_row for:CGMV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgmv_tbl                     IN cgmv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
	l_overall_status				VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgmv_tbl.COUNT > 0) THEN
      i := p_cgmv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgmv_rec                     => p_cgmv_tbl(i));
		-- store the highest degree of error
		IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
			IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
				l_overall_status := x_return_status;
			END IF;
		END IF;

        EXIT WHEN (i = p_cgmv_tbl.LAST);
        i := p_cgmv_tbl.NEXT(i);
      END LOOP;
	-- return overall status
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
 -- Procedure LOAD_SEED_ROW
 ----------------------------------------

 PROCEDURE LOAD_SEED_ROW(
  	 p_CNTX_GRP_PRMTR_ID      IN  VARCHAR2,
 	 p_CGR_ID                 IN  VARCHAR2,
 	 p_PMR_ID                 IN  VARCHAR2,
 	 p_OBJECT_VERSION_NUMBER  IN  VARCHAR2,
 	 p_OWNER                  IN  VARCHAR2,
 	 p_LAST_UPDATE_DATE       IN  VARCHAR2)IS

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
     from OKL_CNTX_GRP_PRMTRS
     where ID = p_cntx_grp_prmtr_id;

     IF(fnd_load_util.upload_test(f_luby, f_ludate, db_luby,
                                  db_ludate, '')) then
        UPDATE OKL_CNTX_GRP_PRMTRS
        SET
          cgr_id = TO_NUMBER(p_cgr_id),
          pmr_id = TO_NUMBER(p_pmr_id),
          object_version_number = TO_NUMBER(p_object_version_number),
          last_update_date = f_ludate,
          last_updated_by = f_luby,
          last_update_login = 0
        WHERE id = TO_NUMBER(p_cntx_grp_prmtr_id);
      END IF;
     END;
  	EXCEPTION
  	  WHEN NO_DATA_FOUND THEN
  	      INSERT INTO OKL_CNTX_GRP_PRMTRS
          (
            ID,
            CGR_ID,
            PMR_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
		   )
           VALUES
           (TO_NUMBER(p_cntx_grp_prmtr_id),
            TO_NUMBER(p_cgr_id),
            TO_NUMBER(p_pmr_id),
            TO_NUMBER(p_object_version_number),
            f_luby,
            f_ludate,
            f_luby,
            f_ludate,
            0);

 END LOAD_SEED_ROW;

END OKL_CGM_PVT;

/
