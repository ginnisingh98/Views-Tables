--------------------------------------------------------
--  DDL for Package Body OKS_RDS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_RDS_PVT" AS
/* $Header: OKSSRDSB.pls 120.0 2005/05/25 18:21:43 appldev noship $ */

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
  -- FUNCTION get_rec for: OKS_REV_DISTRIBUTIONS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rds_rec                      IN rds_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rds_rec_type IS
    CURSOR oks_rev_distrb_pk_csr (p_id  IN NUMBER) IS
    SELECT
            id,
            chr_id,
            cle_id,
            account_class,
            code_combination_id,
            percent,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            last_update_login
      FROM Oks_rev_distributions
     WHERE Oks_rev_distributions.id = p_id;

    l_oks_rev_distrb_pk_csr  oks_rev_distrb_pk_csr%ROWTYPE;
    l_rds_rec                       rds_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_rev_distrb_pk_csr (p_rds_rec.id);
    FETCH oks_rev_distrb_pk_csr INTO
            l_rds_rec.id,
            l_rds_rec.chr_id,
            l_rds_rec.cle_id,
            l_rds_rec.account_class,
            l_rds_rec.code_combination_id,
            l_rds_rec.percent,
            l_rds_rec.object_version_number,
            l_rds_rec.created_by,
            l_rds_rec.creation_date,
            l_rds_rec.last_updated_by,
            l_rds_rec.last_update_date,
            l_rds_rec.last_update_login;
    x_no_data_found := oks_rev_distrb_pk_csr%NOTFOUND;
    CLOSE oks_rev_distrb_pk_csr;
    RETURN(l_rds_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rds_rec                      IN rds_rec_type
  ) RETURN rds_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rds_rec, l_row_notfound));
  END get_rec;


  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_REV_DISTRIBUTIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rdsv_rec                      IN rdsv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rdsv_rec_type IS
    CURSOR oks_rev_distrbv_pk_csr (p_id IN NUMBER) IS
    SELECT
            id,
            chr_id,
            cle_id,
            account_class,
            code_combination_id,
            percent,
            object_version_number,
            created_by,
            creation_date,
            last_updated_by,
            last_update_date,
            --security_group_id,
            last_update_login
      FROM Oks_rev_distributions

     WHERE Oks_rev_distributions.id = p_id;
    l_oks_rev_distrbv_pk_csr  oks_rev_distrbv_pk_csr%ROWTYPE;
--    l_rdsv_rec               oks_rev_distrbv_pk_csr%ROWTYPE;
    l_rdsv_rec                       rdsv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_rev_distrbv_pk_csr (p_rdsv_rec.id);
    FETCH oks_rev_distrbv_pk_csr INTO
            l_rdsv_rec.id,
            l_rdsv_rec.chr_id,
            l_rdsv_rec.cle_id,
            l_rdsv_rec.account_class,
            l_rdsv_rec.code_combination_id,
            l_rdsv_rec.percent,
            l_rdsv_rec.object_version_number,
            l_rdsv_rec.created_by,
            l_rdsv_rec.creation_date,
            l_rdsv_rec.last_updated_by,
            l_rdsv_rec.last_update_date ,
           -- l_rdsv_rec.security_group_id,
            l_rdsv_rec.last_update_login;

    x_no_data_found := oks_rev_distrbv_pk_csr%NOTFOUND;
    CLOSE oks_rev_distrbv_pk_csr;
    RETURN(l_rdsv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rdsv_rec                      IN rdsv_rec_type
  ) RETURN rdsv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rdsv_rec, l_row_notfound));
  END get_rec;


  -----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_REV_DISTRIBUTIONS_v --
  -----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rdsv_rec	IN rdsv_rec_type
  ) RETURN rdsv_rec_type IS
    l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
  BEGIN

    IF (l_rdsv_rec.id = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.id := NULL;
    END IF;

      IF (l_rdsv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.chr_id := NULL;
    END IF;

    IF (l_rdsv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.cle_id := NULL;
    END IF;

     IF (l_rdsv_rec.account_class = OKC_API.G_MISS_CHAR) THEN
      l_rdsv_rec.account_class := NULL;
    END IF;

    IF (l_rdsv_rec.code_combination_id = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.code_combination_id := NULL;
    END IF;

    IF (l_rdsv_rec.percent = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.percent := NULL;
    END IF;

    IF (l_rdsv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.object_version_number := NULL;
    END IF;
    IF (l_rdsv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.created_by := NULL;
    END IF;
    IF (l_rdsv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rdsv_rec.creation_date := NULL;
    END IF;
    IF (l_rdsv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rdsv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rdsv_rec.last_update_date := NULL;
    END IF;
    IF (l_rdsv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.last_update_login := NULL;
    END IF;

/*
    IF (l_rdsv_rec.security_group_id = OKC_API.G_MISS_NUM) THEN
      l_rdsv_rec.security_group_id := NULL;
    END IF;
*/

    RETURN(l_rdsv_rec);
  END null_out_defaults;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ---------------------------------------------------
  -- Validate_Attributes for:OKS_REV_DISTRIBUTIONS_v --
  ---------------------------------------------------
  -----------------------------------------------------
  -- Validate ID--
  -----------------------------------------------------

  PROCEDURE validate_id(x_return_status OUT NOCOPY varchar2,
				P_RDSV_REC   IN  RDSV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_RDSV_REC.id = OKC_API.G_MISS_NUM OR
       P_RDSV_REC.id IS NULL
  Then
      OKC_API.set_message(G_APP_NAME,G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION THEN
            x_return_status := l_return_status;
		NULL;
  When OTHERS THEN
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  End validate_id;


  -----------------------------------------------------
  -- Validate Object Version Number --
  -----------------------------------------------------
  PROCEDURE validate_objvernum(x_return_status OUT NOCOPY varchar2,
				P_RDSV_REC   IN  RDSV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  Begin

  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  If P_RDSV_REC.object_version_number = OKC_API.G_MISS_NUM OR
       P_RDSV_REC.object_version_number IS NULL
  Then
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	RAISE G_EXCEPTION_HALT_VALIDATION;
  End If;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_objvernum;

  -----------------------------------------------------
  -- Validate CHR_ID
  -----------------------------------------------------
  PROCEDURE validate_CHR_ID (x_return_status OUT NOCOPY varchar2,
				P_RDSV_REC   IN  RDSV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR Chr_Cur IS
  SELECT COUNT(1) FROM OKC_K_Headers_v
  WHERE ID=P_RDSV_REC.CHR_ID;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If P_RDSV_REC.CHR_ID = OKC_API.G_MISS_NUM OR
          P_RDSV_REC.CHR_ID IS NULL
  Then
     OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

    OPEN Chr_Cur;
    FETCH Chr_Cur INTO l_Count;
    CLOSE Chr_Cur;
    IF NOT l_Count=1
    THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_CHR_ID;

  -----------------------------------------------------
  -- Validate Cle_Id
  -----------------------------------------------------
  PROCEDURE validate_Cle_Id (x_return_status OUT NOCOPY varchar2,
				P_RDSV_REC   IN  RDSV_REC_TYPE)
  Is
  l_return_status         VARCHAR2(1)  := OKC_API.G_RET_STS_SUCCESS;
  l_Count	INTEGER;
  CURSOR Cle_Cur IS
  SELECT COUNT(1) FROM OKC_K_Lines_V
  WHERE ID=P_RDSV_REC.Cle_Id;
  Begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  If NOT (P_RDSV_REC.cle_Id = OKC_API.G_MISS_NUM OR
          P_RDSV_REC.cle_Id IS NULL)
  Then
    OPEN cle_Cur;
    FETCH cle_Cur INTO l_Count;
    CLOSE cle_Cur;
    IF NOT l_Count=1
    THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'Cle_Id');
	x_return_status := OKC_API.G_RET_STS_ERROR;
	-- halt further validation of this column
	RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
 END IF;
Exception
  When  G_EXCEPTION_HALT_VALIDATION Then
		NULL;
  When OTHERS Then
	-- store SQL error message on message stack for caller
	OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_Cle_Id;


---------------------------------------------------
  -- Validate_Attributes for:OKS_REV_DISTRIBUTIONS_v --
  ---------------------------------------------------
 FUNCTION Validate_Attributes (
    p_rdsv_rec IN  rdsv_rec_type
  )
  Return VARCHAR2 Is
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  Begin
  -- call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view

    OKC_UTIL.ADD_VIEW('OKS_REV_DISTRIBUTIONS_v',x_return_status);

--dbms_output.put_line('After calling okc_util_.add_view ');
--dbms_output.put_line('Value of x_return_status after calling OKC ='||x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
       IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          -- need to leave
          l_return_status := x_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
       ELSE
          -- record that there is a error
          l_return_status := x_return_status;
       END IF;
    END IF;
return(x_return_status);

    --Column Level Validation


-- This has been Commented out as per umesh
-- This has been Commented out as per umesh
-- This has been Commented out as per umesh
     --ID
/*    validate_id(x_return_status, p_rdsv_rec);

    -- store the highest degree of error
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


    --OBJECT_VERSION_NUMBER
    validate_objvernum(x_return_status, p_rdsv_rec);

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



    --CHR_ID
		validate_CHR_ID(x_return_status, p_rdsv_rec);

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



    --Cle_Id
		validate_Cle_Id(x_return_status, p_rdsv_rec);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        -- need to leave
        l_return_status := x_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
        ELSE
        -- record that there was an error
        l_return_status := x_return_status;
        END IF;
    END IF;*/


  Exception

  When G_EXCEPTION_HALT_VALIDATION Then

       Return (l_return_status);

  When OTHERS Then
       -- store SQL error message on message stack for caller
       OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                           p_msg_name         => g_unexpected_error,
                           p_token1           => g_sqlcode_token,
                           p_token1_value     => sqlcode,
                           p_token2           => g_sqlerrm_token,
                           p_token2_value     => sqlerrm);

       -- notify caller of an UNEXPECTED error
       l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
       Return(l_return_status);

  END validate_attributes;



  -----------------------------------------------
  -- Validate_Record for:OKS_REV_DISTRIBUTIONS_v --
  -----------------------------------------------
  FUNCTION Validate_Record (
    p_rdsv_rec IN rdsv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    l_Return_Status:=Validate_Attributes(p_rdsv_Rec);
    RETURN (l_return_status);
  END Validate_Record;


  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN rdsv_rec_type,
    p_to	OUT NOCOPY rds_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.account_class := p_from.account_class;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.percent := p_from.percent;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    --p_to.security_group_id := p_from.security_group_id;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  PROCEDURE migrate (
    p_from	IN rds_rec_type,
    p_to	OUT NOCOPY rdsv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id := p_from.cle_id;
    p_to.account_class := p_from.account_class;
    p_to.code_combination_id := p_from.code_combination_id;
    p_to.percent := p_from.percent;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    --p_to.security_group_id := p_from.security_group_id;
    p_to.last_update_login := p_from.last_update_login;

  END migrate;


   ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- validate_row for:OKS_REV_DISTRIBUTIONS_V --
  --------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec    IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec    rdsv_rec_type := p_rdsv_rec;
    l_rds_rec                      rds_rec_type;
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
    l_return_status := Validate_Attributes(l_rdsv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rdsv_rec);
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


   -----------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_REV_DISTRIBUTIONS_V_TBL --
  -----------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl    IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec    => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  ----------------------------------------
  -- insert_row for:OKS_REV_DISTRIBUTIONS --
  ----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type,
    x_rds_rec                      OUT NOCOPY rds_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'REVENUE_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type := p_rds_rec;
    l_def_rds_rec                  rds_rec_type;
    --------------------------------------------
    -- Set_Attributes for:OKS_REV_DISTRIBUTIONS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_rds_rec IN  rds_rec_type,
      x_rds_rec OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_rds_rec := p_rds_rec;

      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
--dbms_output.put_line('Value of l_return_status AFTER START ACTIVITY='||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_rds_rec,                         -- IN
      l_rds_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_rds_rec.id := get_seq_id;

--dbms_output.put_line('Goinmg to call INSER SQL ');
--dbms_output.put_line('Value of l_rds_rec.id,='||        l_rds_rec.id);
--dbms_output.put_line('Value of l_rds_rec.chr_id='||l_rds_rec.chr_id);
--dbms_output.put_line('Value of l_rds_rec.cle_id='||l_rds_rec.cle_id);
--dbms_output.put_line('Value of l_rds_rec.account_class='||l_rds_rec.account_class);
--dbms_output.put_line('Value of l_rds_rec.code_combination_id='||l_rds_rec.code_combination_id);
--dbms_output.put_line('Value of l_rds_rec.percent='||l_rds_rec.percent);
--dbms_output.put_line('Value of l_rds_rec.object_version_number='||l_rds_rec.object_version_number);
--dbms_output.put_line('Value of l_rds_rec.created_by='||l_rds_rec.created_by);
--dbms_output.put_line('Value of l_rds_rec.creation_date='||l_rds_rec.creation_date);
--dbms_output.put_line('Value of l_rds_rec.last_updated_by='||l_rds_rec.last_updated_by);
--dbms_output.put_line('Value of l_rds_rec.last_update_date='||l_rds_rec.last_update_date);
--dbms_output.put_line('Value of l_rds_rec.security_group_id='||l_rds_rec.security_group_id);
--dbms_output.put_line('Value of l_rds_rec.last_update_login='||l_rds_rec.last_update_login);



    INSERT INTO OKS_REV_DISTRIBUTIONS(
        id,
        chr_id,
        cle_id,
        account_class,
        code_combination_id,
        percent,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        --security_group_id,
        last_update_login
        )
      VALUES (
        l_rds_rec.id,
        l_rds_rec.chr_id,
        l_rds_rec.cle_id,
        l_rds_rec.account_class,
        l_rds_rec.code_combination_id,
        l_rds_rec.percent,
        l_rds_rec.object_version_number,
        l_rds_rec.created_by,
        l_rds_rec.creation_date,
        l_rds_rec.last_updated_by,
        l_rds_rec.last_update_date,
        --l_rds_rec.security_group_id,
        l_rds_rec.last_update_login
        );
    -- Set OUT values
--dbms_output.put_line('sqlcode= ' ||sqlcode);
    x_rds_rec := l_rds_rec;
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
  -- insert_row for:OKS_REV_DISTRIBUTIONS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec    IN rdsv_rec_type,
    x_rdsv_rec    OUT NOCOPY rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec    rdsv_rec_type;
    ldefoksrevdistributionsrec       rdsv_rec_type;
    l_rds_rec                      rds_rec_type;
    lx_rds_rec                     rds_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rdsv_rec	IN rdsv_rec_type
    ) RETURN rdsv_rec_type IS
      l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
    BEGIN
      l_rdsv_rec.CREATION_DATE := SYSDATE;
      l_rdsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rdsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rdsv_rec);
    END fill_who_columns;
    ----------------------------------------------
    -- Set_Attributes for:OKS_REV_DISTRIBUTIONS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rdsv_rec IN  rdsv_rec_type,
      x_rdsv_rec OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      x_rdsv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN

--     dbms_output.put_line('INSIDE INSERT 1 ');
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

    l_rdsv_rec := null_out_defaults(p_rdsv_rec);

--    dbms_output.put_line('RETURN STATUS = ' ||l_return_status );
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rdsv_rec,       -- IN
      ldefoksrevdistributionsrec);         -- OUT
    --- If any errors happen abort API
--dbms_output.put_line('Value of l_return_status AFTER SET ATTRIBUTES ='||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    ldefoksrevdistributionsrec := fill_who_columns(ldefoksrevdistributionsrec);

 --dbms_output.put_line('After fill_who_columns ');
    --- Validate all non-missing attributes (Item Level Validation)
    --dbms_output.put_line('GOING TO CALL VALIDATE ATTRIBUTES ');
     l_return_status := Validate_Attributes(ldefoksrevdistributionsrec);
     --dbms_output.put_line('After Validate attribute ');
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --dbms_output.put_line('Going to call Validate record ');
    l_return_status := Validate_Record(ldefoksrevdistributionsrec);

--dbms_output.put_line('Value of l_return_status after validate record='||l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
--dbms_output.put_line('Going to call migrate ');
    migrate(ldefoksrevdistributionsrec, l_rds_rec);
--dbms_output.put_line('Migrate executed sucess ');
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
--dbms_output.put_line('Going to call Insert row ');
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec,
      lx_rds_rec
    );

--dbms_output.put_line('x_return_status after calling insert row '|| x_return_status);
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rds_rec, ldefoksrevdistributionsrec);
    -- Set OUT values
    x_rdsv_rec := ldefoksrevdistributionsrec;
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


  ---------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKS_REV_DISTRIBUTIONS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl    IN rdsv_tbl_type,
    x_rdsv_tbl    OUT NOCOPY rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec    => p_rdsv_tbl(i),
          x_rdsv_rec    => x_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  --------------------------------------
  -- lock_row for:OKS_REV_DISTRIBUTIONS --
  --------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rds_rec IN rds_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_REV_DISTRIBUTIONS
     WHERE ID = p_rds_rec.id
       AND OBJECT_VERSION_NUMBER = p_rds_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rds_rec IN rds_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_REV_DISTRIBUTIONS
    WHERE ID = p_rds_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'REVENUE_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKS_REV_DISTRIBUTIONS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKS_REV_DISTRIBUTIONS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rds_rec);
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
      OPEN lchk_csr(p_rds_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rds_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rds_rec.object_version_number THEN
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
  -- lock_row for:OKS_REV_DISTRIBUTIONS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec    IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type;
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
    migrate(p_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec
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


  -------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKS_REV_DISTRIBUTIONS_V_TBL --
  -------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl    IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec    => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  ----------------------------------------
  -- update_row for:OKS_REV_DISTRIBUTIONS --
  ----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type,
    x_rds_rec                      OUT NOCOPY rds_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'REVENUE_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type := p_rds_rec;
    l_def_rds_rec                  rds_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rds_rec	IN rds_rec_type,
      x_rds_rec	OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_rds_rec                      rds_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rds_rec := p_rds_rec;
      -- Get current database values
      l_rds_rec := get_rec(p_rds_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rds_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.id := l_rds_rec.id;
      END IF;
      IF (x_rds_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.chr_id := l_rds_rec.chr_id;
      END IF;
      IF (x_rds_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.cle_id := l_rds_rec.cle_id;
      END IF;
      IF (x_rds_rec.account_class = OKC_API.G_MISS_CHAR)
      THEN
        x_rds_rec.account_class := l_rds_rec.account_class;
      END IF;
      IF (x_rds_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.code_combination_id := l_rds_rec.code_combination_id;
      END IF;
      IF (x_rds_rec.percent = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.percent := l_rds_rec.percent;
      END IF;

      IF (x_rds_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.object_version_number := l_rds_rec.object_version_number;
      END IF;
      IF (x_rds_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.created_by := l_rds_rec.created_by;
      END IF;
      IF (x_rds_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.creation_date := l_rds_rec.creation_date;
      END IF;
      IF (x_rds_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.last_updated_by := l_rds_rec.last_updated_by;
      END IF;
      IF (x_rds_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rds_rec.last_update_date := l_rds_rec.last_update_date;
      END IF;
/*
      IF (x_rds_rec.security_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.security_group_id := l_rds_rec.security_group_id;
      END IF;
*/
      IF (x_rds_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rds_rec.last_update_login := l_rds_rec.last_update_login;
      END IF;

      RETURN(l_return_status);
    END populate_new_record;


    --------------------------------------------
    -- Set_Attributes for:OKS_REV_DISTRIBUTIONS --
    --------------------------------------------
    FUNCTION Set_Attributes (
      p_rds_rec IN  rds_rec_type,
      x_rds_rec OUT NOCOPY rds_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rds_rec := p_rds_rec;
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
      p_rds_rec,                         -- IN
      l_rds_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rds_rec, l_def_rds_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKS_REV_DISTRIBUTIONS
    SET chr_id                  = l_def_rds_rec.chr_id,
        cle_id                  = l_def_rds_rec.cle_id,
        account_class           = l_def_rds_rec.account_class,
        code_combination_id     = l_def_rds_rec.code_combination_id,
        percent                 = l_def_rds_rec.percent,
        object_version_number   = l_def_rds_rec.object_version_number,
         last_updated_by         = l_def_rds_rec.last_updated_by,
        last_update_date        = l_def_rds_rec.last_update_date,
--        security_group_id       = l_def_rds_rec.security_group_id
        last_update_login       = l_def_rds_rec.last_update_login

    WHERE ID = l_def_rds_rec.id;

    x_rds_rec := l_def_rds_rec;
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
  -- update_row for:OKS_REV_DISTRIBUTIONS_V --
  ------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec    IN rdsv_rec_type,
    x_rdsv_rec    OUT NOCOPY rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec    rdsv_rec_type := p_rdsv_rec;
    ldefoksrevdistributionsrec       rdsv_rec_type;
    l_rds_rec                      rds_rec_type;
    lx_rds_rec                     rds_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rdsv_rec	IN rdsv_rec_type
    ) RETURN rdsv_rec_type IS
      l_rdsv_rec	rdsv_rec_type := p_rdsv_rec;
    BEGIN
      l_rdsv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rdsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rdsv_rec.last_update_login := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rdsv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rdsv_rec	IN rdsv_rec_type,
      x_rdsv_rec	OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_rdsv_rec    rdsv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      -- Get current database values
      l_rdsv_rec := get_rec(p_rdsv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rdsv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.id := l_rds_rec.id;
      END IF;
      IF (x_rdsv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.chr_id := l_rds_rec.chr_id;
      END IF;
      IF (x_rdsv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.cle_id := l_rds_rec.cle_id;
      END IF;
      IF (x_rdsv_rec.account_class = OKC_API.G_MISS_CHAR)
      THEN
        x_rdsv_rec.account_class := l_rds_rec.account_class;
      END IF;
      IF (x_rdsv_rec.code_combination_id = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.code_combination_id := l_rds_rec.code_combination_id;
      END IF;
      IF (x_rdsv_rec.percent = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.percent := l_rds_rec.percent;
      END IF;

      IF (x_rdsv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.object_version_number := l_rds_rec.object_version_number;
      END IF;
--      IF (x_rdsv_rec.created_by = OKC_API.G_MISS_NUM)
--      THEN
--        x_rdsv_rec.created_by := l_rds_rec.created_by;
--      END IF;
      IF (x_rdsv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.creation_date := l_rds_rec.creation_date;
      END IF;
--      IF (x_rdsv_rec.last_updated_by = OKC_API.G_MISS_NUM)
--      THEN
 --       x_rdsv_rec.last_updated_by := l_rds_rec.last_updated_by;
 --     END IF;
      IF (x_rdsv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rdsv_rec.last_update_date := l_rds_rec.last_update_date;
      END IF;
/*
      IF (x_rdsv_rec.security_group_id = OKC_API.G_MISS_NUM)
      THEN
        x_rdsv_rec.security_group_id := l_rds_rec.security_group_id;
      END IF;
*/


      RETURN(l_return_status);
    END populate_new_record;


    ----------------------------------------------
    -- Set_Attributes for:OKS_REV_DISTRIBUTIONS_V --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_rdsv_rec IN  rdsv_rec_type,
      x_rdsv_rec OUT NOCOPY rdsv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rdsv_rec := p_rdsv_rec;
      x_rdsv_rec.OBJECT_VERSION_NUMBER := NVL(x_rdsv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rdsv_rec,       -- IN
      l_rdsv_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rdsv_rec, ldefoksrevdistributionsrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    ldefoksrevdistributionsrec := fill_who_columns(ldefoksrevdistributionsrec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(ldefoksrevdistributionsrec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(ldefoksrevdistributionsrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;


    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(ldefoksrevdistributionsrec, l_rds_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec,
      lx_rds_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rds_rec, ldefoksrevdistributionsrec);
    x_rdsv_rec := ldefoksrevdistributionsrec;
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



  ---------------------------------------------------------
  -- PL/SQL TBL update_row for:OKS_REV_DISTRIBUTIONS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl    IN rdsv_tbl_type,
    x_rdsv_tbl    OUT NOCOPY rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec    => p_rdsv_tbl(i),
          x_rdsv_rec    => x_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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
  ----------------------------------------
  -- delete_row for:OKS_REV_DISTRIBUTIONS --
  ----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rds_rec                      IN rds_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'REVENUE_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rds_rec                      rds_rec_type:= p_rds_rec;
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
    DELETE FROM OKS_REV_DISTRIBUTIONS
     WHERE ID = l_rds_rec.id;

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
  -- delete_row for:OKS_REV_DISTRIBUTIONS_V --
  ------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_rec    IN rdsv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rdsv_rec    rdsv_rec_type := p_rdsv_rec;
    l_rds_rec                      rds_rec_type;
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
    migrate(l_rdsv_rec, l_rds_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rds_rec
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


  ---------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_REV_DISTRIBUTIONS_V_TBL --
  ---------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rdsv_tbl    IN rdsv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rdsv_tbl.COUNT > 0) THEN
      i := p_rdsv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rdsv_rec    => p_rdsv_tbl(i));
        EXIT WHEN (i = p_rdsv_tbl.LAST);
        i := p_rdsv_tbl.NEXT(i);
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




END OKS_RDS_PVT ;

/
