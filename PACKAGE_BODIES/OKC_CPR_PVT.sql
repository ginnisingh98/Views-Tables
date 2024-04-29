--------------------------------------------------------
--  DDL for Package Body OKC_CPR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CPR_PVT" AS
/* $Header: OKCSCPRB.pls 120.0 2005/05/25 22:30:24 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
G_EXCEPTION_HALT_VALIDATION  exception;
/*+++++++++++++End of hand code +++++++++++++++++++*/
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
  -- FUNCTION get_rec for: OKC_CHANGE_PARTY_ROLE
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cpr_rec                      IN cpr_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cpr_rec_type IS
    CURSOR cpr_pk_csr (p_crt_id             IN NUMBER,
                       p_cpl_id             IN NUMBER) IS
    SELECT
            CRT_ID,
            CPL_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            ACCEPTANCE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Change_Party_Role
     WHERE okc_change_party_role.crt_id = p_crt_id
       AND okc_change_party_role.cpl_id = p_cpl_id;
    l_cpr_pk                       cpr_pk_csr%ROWTYPE;
    l_cpr_rec                      cpr_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cpr_pk_csr (p_cpr_rec.crt_id,
                     p_cpr_rec.cpl_id);
    FETCH cpr_pk_csr INTO
              l_cpr_rec.CRT_ID,
              l_cpr_rec.CPL_ID,
              l_cpr_rec.OBJECT_VERSION_NUMBER,
              l_cpr_rec.CREATED_BY,
              l_cpr_rec.CREATION_DATE,
              l_cpr_rec.LAST_UPDATED_BY,
              l_cpr_rec.LAST_UPDATE_DATE,
              l_cpr_rec.ACCEPTANCE_DATE,
              l_cpr_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := cpr_pk_csr%NOTFOUND;
    CLOSE cpr_pk_csr;
    RETURN(l_cpr_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cpr_rec                      IN cpr_rec_type
  ) RETURN cpr_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cpr_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_CHANGE_PARTY_ROLE_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cprv_rec                     IN cprv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cprv_rec_type IS
    CURSOR okc_cprv_pk_csr (p_crt_id             IN NUMBER,
                            p_cpl_id             IN NUMBER) IS
    SELECT
            CRT_ID,
            CPL_ID,
            OBJECT_VERSION_NUMBER,
            ACCEPTANCE_DATE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Change_Party_Role_V
     WHERE okc_change_party_role_v.crt_id = p_crt_id
       AND okc_change_party_role_v.cpl_id = p_cpl_id;
    l_okc_cprv_pk                  okc_cprv_pk_csr%ROWTYPE;
    l_cprv_rec                     cprv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cprv_pk_csr (p_cprv_rec.crt_id,
                          p_cprv_rec.cpl_id);
    FETCH okc_cprv_pk_csr INTO
              l_cprv_rec.CRT_ID,
              l_cprv_rec.CPL_ID,
              l_cprv_rec.OBJECT_VERSION_NUMBER,
              l_cprv_rec.ACCEPTANCE_DATE,
              l_cprv_rec.CREATED_BY,
              l_cprv_rec.CREATION_DATE,
              l_cprv_rec.LAST_UPDATED_BY,
              l_cprv_rec.LAST_UPDATE_DATE,
              l_cprv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_cprv_pk_csr%NOTFOUND;
    CLOSE okc_cprv_pk_csr;
    RETURN(l_cprv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_cprv_rec                     IN cprv_rec_type
  ) RETURN cprv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_cprv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_CHANGE_PARTY_ROLE_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_cprv_rec	IN cprv_rec_type
  ) RETURN cprv_rec_type IS
    l_cprv_rec	cprv_rec_type := p_cprv_rec;
  BEGIN
    IF (l_cprv_rec.crt_id = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.crt_id := NULL;
    END IF;
    IF (l_cprv_rec.cpl_id = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.cpl_id := NULL;
    END IF;
    IF (l_cprv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.object_version_number := NULL;
    END IF;
    IF (l_cprv_rec.acceptance_date = OKC_API.G_MISS_DATE) THEN
      l_cprv_rec.acceptance_date := NULL;
    END IF;
    IF (l_cprv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.created_by := NULL;
    END IF;
    IF (l_cprv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cprv_rec.creation_date := NULL;
    END IF;
    IF (l_cprv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cprv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cprv_rec.last_update_date := NULL;
    END IF;
    IF (l_cprv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cprv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_cprv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_cpl_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cpl_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cprv_rec	  IN	cprv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cpl_csr is
  select 'x'
  from OKC_K_PARTY_ROLES_B
  where id = p_cprv_rec.cpl_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cprv_rec.cpl_id = OKC_API.G_MISS_NUM) then
	return;
  end if;
  if (p_cprv_rec.cpl_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CPL_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_cpl_csr;
  fetch l_cpl_csr into l_dummy_var;
  close l_cpl_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPL_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_cpl_csr%ISOPEN then
      close l_cpl_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_cpl_id;

-- Start of comments
--
-- Procedure Name  : validate_crt_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_crt_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cprv_rec	  IN	cprv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_crt_csr is
  select 'x'
  from OKC_CHANGE_REQUESTS_B
  where id = p_cprv_rec.crt_id;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cprv_rec.crt_id = OKC_API.G_MISS_NUM) then
	return;
  end if;
  if (p_cprv_rec.crt_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CRT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_crt_csr;
  fetch l_crt_csr into l_dummy_var;
  close l_crt_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRT_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    if l_crt_csr%ISOPEN then
      close l_crt_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_crt_id;
/*+++++++++++++End of hand code +++++++++++++++++++*/
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_CHANGE_PARTY_ROLE_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_cprv_rec IN  cprv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    IF p_cprv_rec.crt_id = OKC_API.G_MISS_NUM OR
       p_cprv_rec.crt_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'crt_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cprv_rec.cpl_id = OKC_API.G_MISS_NUM OR
          p_cprv_rec.cpl_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cpl_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cprv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cprv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_cpl_id(x_return_status => l_return_status,
                    p_cprv_rec      => p_cprv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_crt_id(x_return_status => l_return_status,
                    p_cprv_rec      => p_cprv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
    return x_return_status;
  exception
    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;
  END Validate_Attributes;
/*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_CHANGE_PARTY_ROLE_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_cprv_rec IN cprv_rec_type
--+++++++++++++++Start handcode +++++++++++++++++++++++++++++++++++
    ,p_mode IN varchar2 DEFAULT 'UPDATE'  -- or 'INSERT'
--+++++++++++++++End   handcode +++++++++++++++++++++++++++++++++++
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  /*-------------Commented in favor of hand code------
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_cprv_rec IN cprv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_crtv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              ID,
              OBJECT_VERSION_NUMBER,
              SFWT_FLAG,
              CHR_ID,
              CRS_CODE,
              USER_ID,
              NAME,
              DATETIME_REQUEST,
              SHORT_DESCRIPTION,
              EXTENDED_YN,
              AUTHORITY,
              SIGNATURE_REQUIRED_YN,
              DATETIME_APPROVED,
              DATETIME_REJECTED,
              DATETIME_EFFECTIVE,
              DATETIME_INEFFECTIVE,
              VERSION_CONTRACT,
              APPLIED_CONTRACT_VERSION,
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
              CRT_TYPE,
              CREATED_BY,
              CREATION_DATE,
              LAST_UPDATED_BY,
              LAST_UPDATE_DATE,
              LAST_UPDATE_LOGIN
        FROM Okc_Change_Requests_V
       WHERE okc_change_requests_v.id = p_id;
      l_okc_crtv_pk                  okc_crtv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF (p_cprv_rec.CRT_ID IS NOT NULL)
      THEN
        OPEN okc_crtv_pk_csr(p_cprv_rec.CRT_ID);
        FETCH okc_crtv_pk_csr INTO l_okc_crtv_pk;
        l_row_notfound := okc_crtv_pk_csr%NOTFOUND;
        CLOSE okc_crtv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CRT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys (p_cprv_rec);
    RETURN (l_return_status);
  END Validate_Record;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  cursor pk_csr is
    select '!' from okc_change_party_role
    where cpl_id = p_cprv_rec.cpl_id
      and crt_id = p_cprv_rec.crt_id;
  l_dummy varchar2(1) := '?';
  BEGIN
    if (p_mode = 'INSERT') then
--
      if (p_cprv_rec.cpl_id = OKC_API.G_MISS_NUM
		and p_cprv_rec.crt_id = OKC_API.G_MISS_NUM )
	then
   		return x_return_status;
	end if;
--
	open pk_csr;
	fetch pk_csr into l_dummy;
      close pk_csr;
--
	if (l_dummy = '?')
	then
        return x_return_status;
	end if;
--
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CPL_ID, CRT_ID');
      return OKC_API.G_RET_STS_ERROR;
    else  -- other mode than INSERT
      return x_return_status;
    end if;
  exception
    when OTHERS then
      -- store SQL error message on message stack for caller
      OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;
  END Validate_Record;
/*+++++++++++++End of hand code +++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cprv_rec_type,
    p_to	IN OUT NOCOPY cpr_rec_type
  ) IS
  BEGIN
    p_to.crt_id := p_from.crt_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.acceptance_date := p_from.acceptance_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN cpr_rec_type,
    p_to	IN OUT NOCOPY cprv_rec_type
  ) IS
  BEGIN
    p_to.crt_id := p_from.crt_id;
    p_to.cpl_id := p_from.cpl_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.acceptance_date := p_from.acceptance_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_CHANGE_PARTY_ROLE_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_rec                     IN cprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cprv_rec                     cprv_rec_type := p_cprv_rec;
    l_cpr_rec                      cpr_rec_type;
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
    l_return_status := Validate_Attributes(l_cprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cprv_rec);
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
  -- PL/SQL TBL validate_row for:CPRV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_tbl                     IN cprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cprv_tbl.COUNT > 0) THEN
      i := p_cprv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cprv_rec                     => p_cprv_tbl(i));
        EXIT WHEN (i = p_cprv_tbl.LAST);
        i := p_cprv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_CHANGE_PARTY_ROLE --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpr_rec                      IN cpr_rec_type,
    x_cpr_rec                      OUT NOCOPY cpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLE_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpr_rec                      cpr_rec_type := p_cpr_rec;
    l_def_cpr_rec                  cpr_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_PARTY_ROLE --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cpr_rec IN  cpr_rec_type,
      x_cpr_rec OUT NOCOPY cpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpr_rec := p_cpr_rec;
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
      p_cpr_rec,                         -- IN
      l_cpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_CHANGE_PARTY_ROLE(
        crt_id,
        cpl_id,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        acceptance_date,
        last_update_login)
      VALUES (
        l_cpr_rec.crt_id,
        l_cpr_rec.cpl_id,
        l_cpr_rec.object_version_number,
        l_cpr_rec.created_by,
        l_cpr_rec.creation_date,
        l_cpr_rec.last_updated_by,
        l_cpr_rec.last_update_date,
        l_cpr_rec.acceptance_date,
        l_cpr_rec.last_update_login);
    -- Set OUT values
    x_cpr_rec := l_cpr_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_CHANGE_PARTY_ROLE_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_rec                     IN cprv_rec_type,
    x_cprv_rec                     OUT NOCOPY cprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cprv_rec                     cprv_rec_type;
    l_def_cprv_rec                 cprv_rec_type;
    l_cpr_rec                      cpr_rec_type;
    lx_cpr_rec                     cpr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cprv_rec	IN cprv_rec_type
    ) RETURN cprv_rec_type IS
      l_cprv_rec	cprv_rec_type := p_cprv_rec;
    BEGIN
      l_cprv_rec.CREATION_DATE := SYSDATE;
      l_cprv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cprv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cprv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cprv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cprv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_PARTY_ROLE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cprv_rec IN  cprv_rec_type,
      x_cprv_rec OUT NOCOPY cprv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cprv_rec := p_cprv_rec;
      x_cprv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_cprv_rec := null_out_defaults(p_cprv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cprv_rec,                        -- IN
      l_def_cprv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cprv_rec := fill_who_columns(l_def_cprv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*------------------------commented in favor of hand code-----------
    l_return_status := Validate_Record(l_def_cprv_rec);
------------------------commented in favor of hand code-----------*/
--++++++++++++++++++++++Hand code start+++++++++++++++++++++++++++++
    l_return_status := Validate_Record(l_def_cprv_rec,'INSERT');
--++++++++++++++++++++++Hand code   end+++++++++++++++++++++++++++++
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cprv_rec, l_cpr_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpr_rec,
      lx_cpr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cpr_rec, l_def_cprv_rec);
    -- Set OUT values
    x_cprv_rec := l_def_cprv_rec;
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
  -- PL/SQL TBL insert_row for:CPRV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_tbl                     IN cprv_tbl_type,
    x_cprv_tbl                     OUT NOCOPY cprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cprv_tbl.COUNT > 0) THEN
      i := p_cprv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cprv_rec                     => p_cprv_tbl(i),
          x_cprv_rec                     => x_cprv_tbl(i));
        EXIT WHEN (i = p_cprv_tbl.LAST);
        i := p_cprv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_CHANGE_PARTY_ROLE --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpr_rec                      IN cpr_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cpr_rec IN cpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGE_PARTY_ROLE
     WHERE CRT_ID = p_cpr_rec.crt_id
       AND CPL_ID = p_cpr_rec.cpl_id
       AND OBJECT_VERSION_NUMBER = p_cpr_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cpr_rec IN cpr_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_CHANGE_PARTY_ROLE
    WHERE CRT_ID = p_cpr_rec.crt_id
       AND CPL_ID = p_cpr_rec.cpl_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLE_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_CHANGE_PARTY_ROLE.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_CHANGE_PARTY_ROLE.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_cpr_rec);
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
      OPEN lchk_csr(p_cpr_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cpr_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cpr_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKC_CHANGE_PARTY_ROLE_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_rec                     IN cprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpr_rec                      cpr_rec_type;
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
    migrate(p_cprv_rec, l_cpr_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpr_rec
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
  -- PL/SQL TBL lock_row for:CPRV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_tbl                     IN cprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cprv_tbl.COUNT > 0) THEN
      i := p_cprv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cprv_rec                     => p_cprv_tbl(i));
        EXIT WHEN (i = p_cprv_tbl.LAST);
        i := p_cprv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_CHANGE_PARTY_ROLE --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpr_rec                      IN cpr_rec_type,
    x_cpr_rec                      OUT NOCOPY cpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLE_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpr_rec                      cpr_rec_type := p_cpr_rec;
    l_def_cpr_rec                  cpr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cpr_rec	IN cpr_rec_type,
      x_cpr_rec	OUT NOCOPY cpr_rec_type
    ) RETURN VARCHAR2 IS
      l_cpr_rec                      cpr_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpr_rec := p_cpr_rec;
      -- Get current database values
      l_cpr_rec := get_rec(p_cpr_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cpr_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.crt_id := l_cpr_rec.crt_id;
      END IF;
      IF (x_cpr_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.cpl_id := l_cpr_rec.cpl_id;
      END IF;
      IF (x_cpr_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.object_version_number := l_cpr_rec.object_version_number;
      END IF;
      IF (x_cpr_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.created_by := l_cpr_rec.created_by;
      END IF;
      IF (x_cpr_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpr_rec.creation_date := l_cpr_rec.creation_date;
      END IF;
      IF (x_cpr_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.last_updated_by := l_cpr_rec.last_updated_by;
      END IF;
      IF (x_cpr_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpr_rec.last_update_date := l_cpr_rec.last_update_date;
      END IF;
      IF (x_cpr_rec.acceptance_date = OKC_API.G_MISS_DATE)
      THEN
        x_cpr_rec.acceptance_date := l_cpr_rec.acceptance_date;
      END IF;
      IF (x_cpr_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cpr_rec.last_update_login := l_cpr_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_PARTY_ROLE --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_cpr_rec IN  cpr_rec_type,
      x_cpr_rec OUT NOCOPY cpr_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cpr_rec := p_cpr_rec;
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
      p_cpr_rec,                         -- IN
      l_cpr_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cpr_rec, l_def_cpr_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_CHANGE_PARTY_ROLE
    SET OBJECT_VERSION_NUMBER = l_def_cpr_rec.object_version_number,
        CREATED_BY = l_def_cpr_rec.created_by,
        CREATION_DATE = l_def_cpr_rec.creation_date,
        LAST_UPDATED_BY = l_def_cpr_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cpr_rec.last_update_date,
        ACCEPTANCE_DATE = l_def_cpr_rec.acceptance_date,
        LAST_UPDATE_LOGIN = l_def_cpr_rec.last_update_login
    WHERE CRT_ID = l_def_cpr_rec.crt_id
      AND CPL_ID = l_def_cpr_rec.cpl_id;

    x_cpr_rec := l_def_cpr_rec;
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
  --------------------------------------------
  -- update_row for:OKC_CHANGE_PARTY_ROLE_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_rec                     IN cprv_rec_type,
    x_cprv_rec                     OUT NOCOPY cprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cprv_rec                     cprv_rec_type := p_cprv_rec;
    l_def_cprv_rec                 cprv_rec_type;
    l_cpr_rec                      cpr_rec_type;
    lx_cpr_rec                     cpr_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cprv_rec	IN cprv_rec_type
    ) RETURN cprv_rec_type IS
      l_cprv_rec	cprv_rec_type := p_cprv_rec;
    BEGIN
      l_cprv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cprv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cprv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_cprv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cprv_rec	IN cprv_rec_type,
      x_cprv_rec	OUT NOCOPY cprv_rec_type
    ) RETURN VARCHAR2 IS
      l_cprv_rec                     cprv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cprv_rec := p_cprv_rec;
      -- Get current database values
      l_cprv_rec := get_rec(p_cprv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cprv_rec.crt_id = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.crt_id := l_cprv_rec.crt_id;
      END IF;
      IF (x_cprv_rec.cpl_id = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.cpl_id := l_cprv_rec.cpl_id;
      END IF;
      IF (x_cprv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.object_version_number := l_cprv_rec.object_version_number;
      END IF;
      IF (x_cprv_rec.acceptance_date = OKC_API.G_MISS_DATE)
      THEN
        x_cprv_rec.acceptance_date := l_cprv_rec.acceptance_date;
      END IF;
      IF (x_cprv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.created_by := l_cprv_rec.created_by;
      END IF;
      IF (x_cprv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cprv_rec.creation_date := l_cprv_rec.creation_date;
      END IF;
      IF (x_cprv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.last_updated_by := l_cprv_rec.last_updated_by;
      END IF;
      IF (x_cprv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cprv_rec.last_update_date := l_cprv_rec.last_update_date;
      END IF;
      IF (x_cprv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cprv_rec.last_update_login := l_cprv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_CHANGE_PARTY_ROLE_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_cprv_rec IN  cprv_rec_type,
      x_cprv_rec OUT NOCOPY cprv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_cprv_rec := p_cprv_rec;
      x_cprv_rec.OBJECT_VERSION_NUMBER := NVL(x_cprv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_cprv_rec,                        -- IN
      l_cprv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cprv_rec, l_def_cprv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cprv_rec := fill_who_columns(l_def_cprv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cprv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cprv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cprv_rec, l_cpr_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpr_rec,
      lx_cpr_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cpr_rec, l_def_cprv_rec);
    x_cprv_rec := l_def_cprv_rec;
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
  -- PL/SQL TBL update_row for:CPRV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_tbl                     IN cprv_tbl_type,
    x_cprv_tbl                     OUT NOCOPY cprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cprv_tbl.COUNT > 0) THEN
      i := p_cprv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cprv_rec                     => p_cprv_tbl(i),
          x_cprv_rec                     => x_cprv_tbl(i));
        EXIT WHEN (i = p_cprv_tbl.LAST);
        i := p_cprv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_CHANGE_PARTY_ROLE --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cpr_rec                      IN cpr_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ROLE_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cpr_rec                      cpr_rec_type:= p_cpr_rec;
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
    DELETE FROM OKC_CHANGE_PARTY_ROLE
     WHERE CRT_ID = l_cpr_rec.crt_id AND
CPL_ID = l_cpr_rec.cpl_id;

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
  --------------------------------------------
  -- delete_row for:OKC_CHANGE_PARTY_ROLE_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_rec                     IN cprv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cprv_rec                     cprv_rec_type := p_cprv_rec;
    l_cpr_rec                      cpr_rec_type;
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
    migrate(l_cprv_rec, l_cpr_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cpr_rec
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
  -- PL/SQL TBL delete_row for:CPRV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cprv_tbl                     IN cprv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cprv_tbl.COUNT > 0) THEN
      i := p_cprv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cprv_rec                     => p_cprv_tbl(i));
        EXIT WHEN (i = p_cprv_tbl.LAST);
        i := p_cprv_tbl.NEXT(i);
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
END OKC_CPR_PVT;

/
