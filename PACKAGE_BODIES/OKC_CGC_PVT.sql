--------------------------------------------------------
--  DDL for Package Body OKC_CGC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CGC_PVT" AS
/* $Header: OKCSCGCB.pls 120.0 2005/05/26 09:46:16 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

  g_qry_clause Varchar2(2000);

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
  -- FUNCTION get_rec for: OKC_K_GRPINGS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cgc_rec                      IN cgc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cgc_rec_type IS
    CURSOR cgc_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CGP_PARENT_ID,
            INCLUDED_CGP_ID,
            INCLUDED_CHR_ID,
            SCS_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Grpings
     WHERE okc_K_grpings.id = p_id;
    l_cgc_pk                       cgc_pk_csr%ROWTYPE;
    l_cgc_rec                      cgc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cgc_pk_csr (p_cgc_rec.id);
    FETCH cgc_pk_csr INTO
              l_cgc_rec.ID,
              l_cgc_rec.CGP_PARENT_ID,
              l_cgc_rec.INCLUDED_CGP_ID,
              l_cgc_rec.INCLUDED_CHR_ID,
              l_cgc_rec.SCS_CODE,
              l_cgc_rec.OBJECT_VERSION_NUMBER,
              l_cgc_rec.CREATED_BY,
              l_cgc_rec.CREATION_DATE,
              l_cgc_rec.LAST_UPDATED_BY,
              l_cgc_rec.LAST_UPDATE_DATE,
              l_cgc_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cgc_pk_csr%NOTFOUND;
    CLOSE cgc_pk_csr;
    RETURN(l_cgc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cgc_rec                      IN cgc_rec_type
  ) RETURN cgc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cgc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_GRPINGS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cgcv_rec                     IN cgcv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cgcv_rec_type IS
    CURSOR okc_cgcv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CGP_PARENT_ID,
            INCLUDED_CHR_ID,
            INCLUDED_CGP_ID,
            SCS_CODE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_K_Grpings_V
     WHERE okc_K_grpings_v.id = p_id;
    l_okc_cgcv_pk                  okc_cgcv_pk_csr%ROWTYPE;
    l_cgcv_rec                     cgcv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cgcv_pk_csr (p_cgcv_rec.id);
    FETCH okc_cgcv_pk_csr INTO
              l_cgcv_rec.ID,
              l_cgcv_rec.OBJECT_VERSION_NUMBER,
              l_cgcv_rec.CGP_PARENT_ID,
              l_cgcv_rec.INCLUDED_CHR_ID,
              l_cgcv_rec.INCLUDED_CGP_ID,
              l_cgcv_rec.SCS_CODE,
              l_cgcv_rec.CREATED_BY,
              l_cgcv_rec.CREATION_DATE,
              l_cgcv_rec.LAST_UPDATED_BY,
              l_cgcv_rec.LAST_UPDATE_DATE,
              l_cgcv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cgcv_pk_csr%NOTFOUND;
    CLOSE okc_cgcv_pk_csr;
    RETURN(l_cgcv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cgcv_rec                     IN cgcv_rec_type
  ) RETURN cgcv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cgcv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_GRPINGS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cgcv_rec	IN cgcv_rec_type
  ) RETURN cgcv_rec_type IS
    l_cgcv_rec	cgcv_rec_type := p_cgcv_rec;
  BEGIN
    IF (l_cgcv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.object_version_number := NULL;
    END IF;
    IF (l_cgcv_rec.cgp_parent_id = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.cgp_parent_id := NULL;
    END IF;
    IF (l_cgcv_rec.included_chr_id = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.included_chr_id := NULL;
    END IF;
    IF (l_cgcv_rec.included_cgp_id = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.included_cgp_id := NULL;
    END IF;
    IF (l_cgcv_rec.scs_code = OKC_API.G_MISS_CHAR) THEN
      l_cgcv_rec.scs_code := NULL;
    END IF;
    IF (l_cgcv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.created_by := NULL;
    END IF;
    IF (l_cgcv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cgcv_rec.creation_date := NULL;
    END IF;
    IF (l_cgcv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cgcv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cgcv_rec.last_update_date := NULL;
    END IF;
    IF (l_cgcv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cgcv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cgcv_rec);
  END null_out_defaults;
  ---------------------------------------------------
  PROCEDURE Validate_Id(x_return_status OUT NOCOPY VARCHAR2,
                        p_cgcv_rec IN cgcv_rec_type) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_rec.id = OKC_API.G_MISS_NUM OR
       p_cgcv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Id;
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Obj_Version_Num(x_return_status OUT NOCOPY VARCHAR2,
                                     p_cgcv_rec IN cgcv_rec_type) IS
    l_return_status VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_rec.object_version_number = OKC_API.G_MISS_NUM OR
       p_cgcv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Obj_Version_Num;
  ---------------------------------------------------------------------------
  PROCEDURE Validate_Cgp_Parent_Id(x_return_status OUT NOCOPY VARCHAR2,
                                   p_cgcv_rec IN cgcv_rec_type) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF p_cgcv_rec.cgp_parent_id = OKC_API.G_MISS_NUM OR
       p_cgcv_rec.cgp_parent_id IS NULL
    THEN
      ---OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cgp_parent_id');
	 OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_CGP_PARENT_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      NULL;
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Cgp_Parent_Id;
  ---------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_K_GRPINGS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cgcv_rec IN  cgcv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    Validate_Obj_Version_Num(l_return_status, p_cgcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;
    Validate_Cgp_Parent_Id(l_return_status, p_cgcv_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
        raise G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;
      END IF;
    END IF;
    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_K_GRPINGS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_cgcv_rec IN cgcv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_cgcv_rec IN cgcv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_cgpv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_K_Groups_V
       WHERE okc_K_groups_v.id = p_id;
      CURSOR okc_chrv_pk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_K_Headers_V
       WHERE okc_k_headers_v.id = p_id;
      l_okc_cgpv_dummy               VARCHAR2(1);
      l_okc_chrv_dummy               VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_cgcv_rec.CGP_PARENT_ID IS NOT NULL)
      THEN
        OPEN okc_cgpv_pk_csr(p_cgcv_rec.CGP_PARENT_ID);
        FETCH okc_cgpv_pk_csr INTO l_okc_cgpv_dummy;
        l_row_notfound := okc_cgpv_pk_csr%NOTFOUND;
        CLOSE okc_cgpv_pk_csr;
        IF (l_row_notfound) THEN
          ----OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'CGP_PARENT_ID');
		OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_CGP_PARENT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cgcv_rec.INCLUDED_CGP_ID IS NOT NULL)
      THEN
        OPEN okc_cgpv_pk_csr(p_cgcv_rec.INCLUDED_CGP_ID);
        FETCH okc_cgpv_pk_csr INTO l_okc_cgpv_dummy;
        l_row_notfound := okc_cgpv_pk_csr%NOTFOUND;
        CLOSE okc_cgpv_pk_csr;
        IF (l_row_notfound) THEN
		 OKC_API.SET_MESSAGE('OKC', 'OKC_INVALID_CGP_PARENT_ID');--Bug#2836703
          ----OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INCLUDED_CGP_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_cgcv_rec.INCLUDED_CHR_ID IS NOT NULL)
      THEN
        OPEN okc_chrv_pk_csr(p_cgcv_rec.INCLUDED_CHR_ID);
        FETCH okc_chrv_pk_csr INTO l_okc_chrv_dummy;
        l_row_notfound := okc_chrv_pk_csr%NOTFOUND;
        CLOSE okc_chrv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INCLUDED_CHR_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
    ----------------------------------------------------
    FUNCTION validate_unique_keys (
      p_cgcv_rec IN cgcv_rec_type
    ) RETURN VARCHAR2 IS
      unique_key_error          EXCEPTION;
      CURSOR okc_chr_csr (p_id IN okc_k_grpings_v.id%TYPE,
                          p_cgp_parent_id IN okc_k_grpings_v.cgp_parent_id%TYPE,
                          p_included_chr_id IN okc_k_grpings_v.included_chr_id%TYPE) IS
      SELECT 'x'
        FROM Okc_K_Grpings_V
       WHERE okc_K_grpings_v.cgp_parent_id = p_cgp_parent_id
         AND okc_K_grpings_v.included_chr_id = p_included_chr_id
         AND ((p_id IS NULL)
          OR  (p_id IS NOT NULL
         AND   id <> p_id));
      CURSOR okc_cgp_csr (p_id IN okc_k_grpings_v.id%TYPE,
                          p_cgp_parent_id IN okc_k_grpings_v.cgp_parent_id%TYPE,
                          p_included_cgp_id IN okc_k_grpings_v.included_cgp_id%TYPE) IS
      SELECT 'x'
        FROM Okc_K_Grpings_V
       WHERE okc_K_grpings_v.cgp_parent_id = p_cgp_parent_id
         AND okc_K_grpings_v.included_cgp_id = p_included_cgp_id
         AND ((p_id IS NULL)
          OR  (p_id IS NOT NULL
         AND   id <> p_id));
      l_okc_cgp_dummy                VARCHAR2(1);
      l_okc_chr_dummy                VARCHAR2(1);
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_found                    BOOLEAN := FALSE;
    BEGIN
      IF (p_cgcv_rec.INCLUDED_CHR_ID IS NOT NULL) THEN
        OPEN okc_chr_csr(p_cgcv_rec.ID,
                         p_cgcv_rec.CGP_PARENT_ID,
                         p_cgcv_rec.INCLUDED_CHR_ID);
        FETCH okc_chr_csr INTO l_okc_chr_dummy;
        l_row_found := okc_chr_csr%FOUND;
        CLOSE okc_chr_csr;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INCLUDED_CHR_ID');
          RAISE unique_key_error;
        END IF;
      END IF;
      IF (p_cgcv_rec.INCLUDED_CGP_ID IS NOT NULL) THEN
        OPEN okc_cgp_csr(p_cgcv_rec.ID,
                         p_cgcv_rec.CGP_PARENT_ID,
                         p_cgcv_rec.INCLUDED_CGP_ID);
        FETCH okc_cgp_csr INTO l_okc_cgp_dummy;
        l_row_found := okc_cgp_csr%FOUND;
        CLOSE okc_cgp_csr;
        IF (l_row_found) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE, G_COL_NAME_TOKEN, 'INCLUDED_CGP_ID');
          RAISE unique_key_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN unique_key_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_unique_keys;
  BEGIN
    IF (p_cgcv_rec.included_chr_id = OKC_API.G_MISS_NUM OR
        p_cgcv_rec.included_chr_id IS NULL) AND
       (p_cgcv_rec.included_cgp_id = OKC_API.G_MISS_NUM OR
        p_cgcv_rec.included_cgp_id IS NULL) THEN
      OKC_API.set_message(G_APP_NAME, 'OKC_ARC_MANDATORY', 'G_COL_NAME1', 'INCLUDED_CGP_ID',
                                                           'G_COL_NAME2', 'INCLUDED_CHR_ID');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF (p_cgcv_rec.included_chr_id IS NOT NULL) AND
       (p_cgcv_rec.included_cgp_id IS NOT NULL) THEN
      OKC_API.set_message(G_APP_NAME, 'OKC_ARC_VIOLATED', 'G_COL_NAME1', 'INCLUDED_CGP_ID',
                                                          'G_COL_NAME2', 'INCLUDED_CHR_ID');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := validate_foreign_keys (p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    l_return_status := validate_unique_keys (p_cgcv_rec);
    IF l_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    RETURN (l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Populate_Subclass
  ---------------------------------------------------------------------------
  PROCEDURE Populate_Subclass(p_cgcv_rec IN OUT NOCOPY cgcv_rec_type,
                              x_return_status OUT NOCOPY Varchar2) IS
    cursor c1(p_id okc_k_headers_b.id%TYPE) is
    select scs_code
      from okc_k_headers_b
     where id = p_id;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    If p_cgcv_rec.included_chr_id Is Not Null Then
      If p_cgcv_rec.scs_code Is Null Then
        Open c1(p_cgcv_rec.included_chr_id);
        Fetch c1 Into p_cgcv_rec.scs_code;
        Close c1;
      End If;
    End If;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Populate_Subclass;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cgcv_rec_type,
    p_to	OUT NOCOPY cgc_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cgp_parent_id := p_from.cgp_parent_id;
    p_to.included_cgp_id := p_from.included_cgp_id;
    p_to.included_chr_id := p_from.included_chr_id;
    p_to.scs_code := p_from.scs_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cgc_rec_type,
    p_to	IN OUT NOCOPY cgcv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cgp_parent_id := p_from.cgp_parent_id;
    p_to.included_cgp_id := p_from.included_cgp_id;
    p_to.included_chr_id := p_from.included_chr_id;
    p_to.scs_code := p_from.scs_code;
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
  ---------------------------------------------
  -- validate_row for:OKC_K_GRPINGS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
    l_cgc_rec                      cgc_rec_type;
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
    l_return_status := Validate_Attributes(l_cgcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cgcv_rec);
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
  -- PL/SQL TBL validate_row for:CGCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgcv_tbl.COUNT > 0) THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgcv_rec                     => p_cgcv_tbl(i));
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKC_K_GRPINGS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgc_rec                      IN cgc_rec_type,
    x_cgc_rec                      OUT NOCOPY cgc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GRPINGS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgc_rec                      cgc_rec_type := p_cgc_rec;
    l_def_cgc_rec                  cgc_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_GRPINGS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cgc_rec IN  cgc_rec_type,
      x_cgc_rec OUT NOCOPY cgc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgc_rec := p_cgc_rec;
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
      p_cgc_rec,                         -- IN
      l_cgc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_GRPINGS(
        id,
        cgp_parent_id,
        included_cgp_id,
        included_chr_id,
        scs_code,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_cgc_rec.id,
        l_cgc_rec.cgp_parent_id,
        l_cgc_rec.included_cgp_id,
        l_cgc_rec.included_chr_id,
        l_cgc_rec.scs_code,
        l_cgc_rec.object_version_number,
        l_cgc_rec.created_by,
        l_cgc_rec.creation_date,
        l_cgc_rec.last_updated_by,
        l_cgc_rec.last_update_date,
        l_cgc_rec.last_update_login);
    -- Set OUT values
    x_cgc_rec := l_cgc_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_K_GRPINGS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgcv_rec                     cgcv_rec_type;
    l_def_cgcv_rec                 cgcv_rec_type;
    l_cgc_rec                      cgc_rec_type;
    lx_cgc_rec                     cgc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cgcv_rec	IN cgcv_rec_type
    ) RETURN cgcv_rec_type IS
      l_cgcv_rec	cgcv_rec_type := p_cgcv_rec;
    BEGIN
      l_cgcv_rec.CREATION_DATE := SYSDATE;
      l_cgcv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cgcv_rec.LAST_UPDATE_DATE := l_cgcv_rec.CREATION_DATE;
      l_cgcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cgcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cgcv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_K_GRPINGS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_cgcv_rec IN  cgcv_rec_type,
      x_cgcv_rec OUT NOCOPY cgcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgcv_rec := p_cgcv_rec;
      x_cgcv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cgcv_rec := null_out_defaults(p_cgcv_rec);
    -- Set primary key value
    l_cgcv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cgcv_rec,                        -- IN
      l_def_cgcv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cgcv_rec := fill_who_columns(l_def_cgcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cgcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cgcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Populate the denormalized scs_code here
    Populate_Subclass(l_def_cgcv_rec, l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cgcv_rec, l_cgc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgc_rec,
      lx_cgc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cgc_rec, l_def_cgcv_rec);
    -- Set OUT values
    x_cgcv_rec := l_def_cgcv_rec;
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
  -- PL/SQL TBL insert_row for:CGCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgcv_tbl.COUNT > 0) THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgcv_rec                     => p_cgcv_tbl(i),
          x_cgcv_rec                     => x_cgcv_tbl(i));
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKC_K_GRPINGS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgc_rec                      IN cgc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cgc_rec IN cgc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_GRPINGS
     WHERE ID = p_cgc_rec.id
       AND OBJECT_VERSION_NUMBER = p_cgc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cgc_rec IN cgc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_GRPINGS
    WHERE ID = p_cgc_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GRPINGS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_GRPINGS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_GRPINGS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cgc_rec);
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
      OPEN lchk_csr(p_cgc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cgc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cgc_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKC_K_GRPINGS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgc_rec                      cgc_rec_type;
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
    migrate(p_cgcv_rec, l_cgc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgc_rec
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
  -- PL/SQL TBL lock_row for:CGCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgcv_tbl.COUNT > 0) THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgcv_rec                     => p_cgcv_tbl(i));
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKC_K_GRPINGS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgc_rec                      IN cgc_rec_type,
    x_cgc_rec                      OUT NOCOPY cgc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GRPINGS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgc_rec                      cgc_rec_type := p_cgc_rec;
    l_def_cgc_rec                  cgc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cgc_rec	IN cgc_rec_type,
      x_cgc_rec	OUT NOCOPY cgc_rec_type
    ) RETURN VARCHAR2 IS
      l_cgc_rec                      cgc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgc_rec := p_cgc_rec;
      -- Get current database values
      l_cgc_rec := get_rec(p_cgc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cgc_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.id := l_cgc_rec.id;
      END IF;
      IF (x_cgc_rec.cgp_parent_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.cgp_parent_id := l_cgc_rec.cgp_parent_id;
      END IF;
      IF (x_cgc_rec.included_cgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.included_cgp_id := l_cgc_rec.included_cgp_id;
      END IF;
      IF (x_cgc_rec.included_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.included_chr_id := l_cgc_rec.included_chr_id;
      END IF;
      IF (x_cgc_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cgc_rec.scs_code := l_cgc_rec.scs_code;
      END IF;
      IF (x_cgc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.object_version_number := l_cgc_rec.object_version_number;
      END IF;
      IF (x_cgc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.created_by := l_cgc_rec.created_by;
      END IF;
      IF (x_cgc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgc_rec.creation_date := l_cgc_rec.creation_date;
      END IF;
      IF (x_cgc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.last_updated_by := l_cgc_rec.last_updated_by;
      END IF;
      IF (x_cgc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgc_rec.last_update_date := l_cgc_rec.last_update_date;
      END IF;
      IF (x_cgc_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cgc_rec.last_update_login := l_cgc_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_K_GRPINGS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_cgc_rec IN  cgc_rec_type,
      x_cgc_rec OUT NOCOPY cgc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgc_rec := p_cgc_rec;
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
      p_cgc_rec,                         -- IN
      l_cgc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cgc_rec, l_def_cgc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_GRPINGS
    SET CGP_PARENT_ID = l_def_cgc_rec.cgp_parent_id,
        INCLUDED_CGP_ID = l_def_cgc_rec.included_cgp_id,
        INCLUDED_CHR_ID = l_def_cgc_rec.included_chr_id,
        SCS_CODE = l_def_cgc_rec.scs_code,
        OBJECT_VERSION_NUMBER = l_def_cgc_rec.object_version_number,
        CREATED_BY = l_def_cgc_rec.created_by,
        CREATION_DATE = l_def_cgc_rec.creation_date,
        LAST_UPDATED_BY = l_def_cgc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cgc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cgc_rec.last_update_login
    WHERE ID = l_def_cgc_rec.id;

    x_cgc_rec := l_def_cgc_rec;
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
  -------------------------------------------
  -- update_row for:OKC_K_GRPINGS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type,
    x_cgcv_rec                     OUT NOCOPY cgcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
    l_def_cgcv_rec                 cgcv_rec_type;
    l_cgc_rec                      cgc_rec_type;
    lx_cgc_rec                     cgc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cgcv_rec	IN cgcv_rec_type
    ) RETURN cgcv_rec_type IS
      l_cgcv_rec	cgcv_rec_type := p_cgcv_rec;
    BEGIN
      l_cgcv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cgcv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cgcv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cgcv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cgcv_rec	IN cgcv_rec_type,
      x_cgcv_rec	OUT NOCOPY cgcv_rec_type
    ) RETURN VARCHAR2 IS
      l_cgcv_rec                     cgcv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgcv_rec := p_cgcv_rec;
      -- Get current database values
      l_cgcv_rec := get_rec(p_cgcv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cgcv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.id := l_cgcv_rec.id;
      END IF;
      IF (x_cgcv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.object_version_number := l_cgcv_rec.object_version_number;
      END IF;
      IF (x_cgcv_rec.cgp_parent_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.cgp_parent_id := l_cgcv_rec.cgp_parent_id;
      END IF;
      IF (x_cgcv_rec.included_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.included_chr_id := l_cgcv_rec.included_chr_id;
      END IF;
      IF (x_cgcv_rec.included_cgp_id = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.included_cgp_id := l_cgcv_rec.included_cgp_id;
      END IF;
      IF (x_cgcv_rec.scs_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cgcv_rec.scs_code := l_cgcv_rec.scs_code;
      END IF;
      IF (x_cgcv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.created_by := l_cgcv_rec.created_by;
      END IF;
      IF (x_cgcv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgcv_rec.creation_date := l_cgcv_rec.creation_date;
      END IF;
      IF (x_cgcv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.last_updated_by := l_cgcv_rec.last_updated_by;
      END IF;
      IF (x_cgcv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cgcv_rec.last_update_date := l_cgcv_rec.last_update_date;
      END IF;
      IF (x_cgcv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cgcv_rec.last_update_login := l_cgcv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_K_GRPINGS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_cgcv_rec IN  cgcv_rec_type,
      x_cgcv_rec OUT NOCOPY cgcv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cgcv_rec := p_cgcv_rec;
      x_cgcv_rec.OBJECT_VERSION_NUMBER := NVL(x_cgcv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cgcv_rec,                        -- IN
      l_cgcv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cgcv_rec, l_def_cgcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cgcv_rec := fill_who_columns(l_def_cgcv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cgcv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cgcv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -- Populate the denormalized scs_code here
    Populate_Subclass(l_def_cgcv_rec, l_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cgcv_rec, l_cgc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgc_rec,
      lx_cgc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cgc_rec, l_def_cgcv_rec);
    x_cgcv_rec := l_def_cgcv_rec;
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
  -- PL/SQL TBL update_row for:CGCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type,
    x_cgcv_tbl                     OUT NOCOPY cgcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgcv_tbl.COUNT > 0) THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgcv_rec                     => p_cgcv_tbl(i),
          x_cgcv_rec                     => x_cgcv_tbl(i));
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKC_K_GRPINGS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgc_rec                      IN cgc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'GRPINGS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgc_rec                      cgc_rec_type:= p_cgc_rec;
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
    DELETE FROM OKC_K_GRPINGS
     WHERE ID = l_cgc_rec.id;

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
  -------------------------------------------
  -- delete_row for:OKC_K_GRPINGS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_rec                     IN cgcv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cgcv_rec                     cgcv_rec_type := p_cgcv_rec;
    l_cgc_rec                      cgc_rec_type;
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
    migrate(l_cgcv_rec, l_cgc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cgc_rec
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
  -- PL/SQL TBL delete_row for:CGCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cgcv_tbl                     IN cgcv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cgcv_tbl.COUNT > 0) THEN
      i := p_cgcv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => p_init_msg_list,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cgcv_rec                     => p_cgcv_tbl(i));
        EXIT WHEN (i = p_cgcv_tbl.LAST);
        i := p_cgcv_tbl.NEXT(i);
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

  PROCEDURE insert_row_upg(x_return_status OUT NOCOPY VARCHAR2, p_cgcv_tbl IN cgcv_tbl_type) IS
    l_tabsize                  NUMBER := p_cgcv_tbl.COUNT;
    in_id                      OKC_DATATYPES.NumberTabTyp;
    in_object_version_number   OKC_DATATYPES.NumberTabTyp;
    in_cgp_parent_id           OKC_DATATYPES.NumberTabTyp;
    in_included_chr_id         OKC_DATATYPES.NumberTabTyp;
    in_included_cgp_id         OKC_DATATYPES.NumberTabTyp;
    in_scs_code                OKC_DATATYPES.Var30TabTyp;
    in_created_by              OKC_DATATYPES.Number15TabTyp;
    in_creation_date           OKC_DATATYPES.DateTabTyp;
    in_last_updated_by         OKC_DATATYPES.Number15TabTyp;
    in_last_update_date        OKC_DATATYPES.DateTabTyp;
    in_last_update_login       OKC_DATATYPES.Number15TabTyp;
    i                          NUMBER := p_cgcv_tbl.FIRST;
    j                          NUMBER := 0;

  BEGIN
    -- Initializing Return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- pkoganti   08/26/2000
    -- replace for loop with while loop to handle
    -- gaps in pl/sql table indexes.
    -- Example:
    --   consider a pl/sql table(A) with the following elements
    --   A(1) = 10
    --   A(2) = 20
    --   A(6) = 30
    --   A(7) = 40
    --
    --  The for loop was erroring for indexes 3,4,5, the while loop
    -- along with the NEXT operator would handle the missing indexes
    -- with out causing the API to fail.
    --
    WHILE i IS NOT NULL
    LOOP
	 j                           := j + 1;

      in_id(j)                    := p_cgcv_tbl(i).id;
      in_object_version_number(j) := p_cgcv_tbl(i).object_version_number;
      in_cgp_parent_id(j)         := p_cgcv_tbl(i).cgp_parent_id;
      in_included_chr_id(j)       := p_cgcv_tbl(i).included_chr_id;
      in_included_cgp_id(j)       := p_cgcv_tbl(i).included_cgp_id;
      in_scs_code(j)              := p_cgcv_tbl(i).scs_code;
      in_created_by(j)            := p_cgcv_tbl(i).created_by;
      in_creation_date(j)         := p_cgcv_tbl(i).creation_date;
      in_last_updated_by(j)       := p_cgcv_tbl(i).last_updated_by;
      in_last_update_date(j)      := p_cgcv_tbl(i).last_update_date;
      in_last_update_login(j)     := p_cgcv_tbl(i).last_update_login;

	 i                           := p_cgcv_tbl.NEXT(i);
    END LOOP;

    FORALL i in 1..l_tabsize
      INSERT INTO OKC_K_GRPINGS (
             id,
             object_version_number,
             cgp_parent_id,
             included_chr_id,
             included_cgp_id,
             scs_code,
             created_by,
             creation_date,
             last_updated_by,
             last_update_date,
             last_update_login)
      VALUES (
             in_id(i),
             in_object_version_number(i),
             in_cgp_parent_id(i),
             in_included_chr_id(i),
             in_included_cgp_id(i),
             in_scs_code(i),
             in_created_by(i),
             in_creation_date(i),
             in_last_updated_by(i),
             in_last_update_date(i),
             in_last_update_login(i));
  EXCEPTION
    WHEN OTHERS THEN
    --  RAISE;
 -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END;

  PROCEDURE Set_Search_String(p_srch_str      IN         VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    g_qry_clause := p_srch_str;
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
  END;

  PROCEDURE Get_Queried_Contracts(p_cgp_parent_id IN  NUMBER,
                                  x_qry_k_tbl     OUT NOCOPY qry_k_tbl,
                                  x_return_status OUT NOCOPY VARCHAR2) IS
    l_qry Varchar2(2000);
    l_qry_k_tbl qry_k_tbl;
    l_index Number;
    l_id Number;
    l_contract_number Varchar2(255);
    k_csr QueryKCursor;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    -- dbms_output.put_line('g_qry_clause : ' || g_qry_clause);
    IF g_qry_clause IS NOT NULL THEN
      l_qry := 'select chrv.id, chrv.contract_number || ' ||
		     'decode(chrv.contract_number_modifier, null, null,' ||
               ''' ('' || chrv.contract_number_modifier || '')'') contract_number' ||
		     ' from okc_k_headers_v chrv where ' || g_qry_clause ||
			' and chrv.id not in (select included_chr_id from okc_k_grpings' ||
			' where cgp_parent_id = :1' ||
			'   and included_chr_id is not null)' ||
			' order by 2';
    END IF;
    l_index := 1;
    OPEN k_csr FOR l_qry USING p_cgp_parent_id ;
    LOOP
	 FETCH k_csr INTO l_id, l_contract_number;
	 EXIT WHEN k_csr%NOTFOUND;
      l_qry_k_tbl(l_index).id := l_id;
      l_qry_k_tbl(l_index).contract_number := l_contract_number;
	 l_index := l_index + 1;
    END LOOP;
    CLOSE k_csr;
    x_qry_k_tbl := l_qry_k_tbl;
  EXCEPTION
    WHEN OTHERS THEN
      OKC_API.set_message(p_app_name      => g_app_name,
                          p_msg_name      => g_unexpected_error,
                          p_token1        => g_sqlcode_token,
                          p_token1_value  => sqlcode,
                          p_token2        => g_sqlerrm_token,
                          p_token2_value  => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Get_Queried_Contracts;

END OKC_CGC_PVT;

/
