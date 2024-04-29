--------------------------------------------------------
--  DDL for Package Body OKC_RSC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_RSC_PVT" AS
/* $Header: OKCSRSCB.pls 120.0 2005/05/26 09:28:15 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_ROLE_SOURCES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rsc_rec                      IN rsc_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rsc_rec_type IS
    CURSOR rsc_pk_csr (p_rle_code           IN VARCHAR2,
                       p_buy_or_sell        IN VARCHAR2,
                       p_start_date         IN DATE) IS
    SELECT
            RLE_CODE,
            BUY_OR_SELL,
            START_DATE,
            END_DATE,
            JTOT_OBJECT_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Role_Sources
     WHERE okc_role_sources.rle_code = p_rle_code
       AND okc_role_sources.buy_or_sell = p_buy_or_sell
       AND okc_role_sources.start_date = p_start_date;
    l_rsc_pk                       rsc_pk_csr%ROWTYPE;
    l_rsc_rec                      rsc_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN rsc_pk_csr (p_rsc_rec.rle_code,
                     p_rsc_rec.buy_or_sell,
                     p_rsc_rec.start_date);
    FETCH rsc_pk_csr INTO
              l_rsc_rec.RLE_CODE,
              l_rsc_rec.BUY_OR_SELL,
              l_rsc_rec.START_DATE,
              l_rsc_rec.END_DATE,
              l_rsc_rec.JTOT_OBJECT_CODE,
              l_rsc_rec.OBJECT_VERSION_NUMBER,
              l_rsc_rec.CREATED_BY,
              l_rsc_rec.CREATION_DATE,
              l_rsc_rec.LAST_UPDATED_BY,
              l_rsc_rec.LAST_UPDATE_DATE,
              l_rsc_rec.LAST_UPDATE_LOGIN,
              l_rsc_rec.ACCESS_LEVEL;
    x_no_data_found := rsc_pk_csr%NOTFOUND;
    CLOSE rsc_pk_csr;
    RETURN(l_rsc_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rsc_rec                      IN rsc_rec_type
  ) RETURN rsc_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rsc_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_ROLE_SOURCES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rscv_rec                     IN rscv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rscv_rec_type IS
    CURSOR okc_rscv_pk_csr (p_rle_code           IN VARCHAR2,
                            p_buy_or_sell        IN VARCHAR2,
                            p_start_date         IN DATE) IS
    SELECT
            RLE_CODE,
            BUY_OR_SELL,
            START_DATE,
            END_DATE,
            JTOT_OBJECT_CODE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Role_Sources
     WHERE okc_role_sources.rle_code = p_rle_code
       AND okc_role_sources.buy_or_sell = p_buy_or_sell
       AND okc_role_sources.start_date = p_start_date;
    l_okc_rscv_pk                  okc_rscv_pk_csr%ROWTYPE;
    l_rscv_rec                     rscv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_rscv_pk_csr (p_rscv_rec.rle_code,
                          p_rscv_rec.buy_or_sell,
                          p_rscv_rec.start_date);
    FETCH okc_rscv_pk_csr INTO
              l_rscv_rec.RLE_CODE,
              l_rscv_rec.BUY_OR_SELL,
              l_rscv_rec.START_DATE,
              l_rscv_rec.END_DATE,
              l_rscv_rec.JTOT_OBJECT_CODE,
              l_rscv_rec.OBJECT_VERSION_NUMBER,
              l_rscv_rec.CREATED_BY,
              l_rscv_rec.CREATION_DATE,
              l_rscv_rec.LAST_UPDATED_BY,
              l_rscv_rec.LAST_UPDATE_DATE,
              l_rscv_rec.LAST_UPDATE_LOGIN,
              l_rscv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_rscv_pk_csr%NOTFOUND;
    CLOSE okc_rscv_pk_csr;
    RETURN(l_rscv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_rscv_rec                     IN rscv_rec_type
  ) RETURN rscv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rscv_rec, l_row_notfound));
  END get_rec;

  --------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_ROLE_SOURCES_V --
  --------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rscv_rec	IN rscv_rec_type
  ) RETURN rscv_rec_type IS
    l_rscv_rec	rscv_rec_type := p_rscv_rec;
  BEGIN
    IF (l_rscv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_rscv_rec.end_date := NULL;
    END IF;
    IF (l_rscv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) THEN
      l_rscv_rec.JTOT_OBJECT_CODE := NULL;
    END IF;
    IF (l_rscv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_rscv_rec.object_version_number := NULL;
    END IF;
    IF (l_rscv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_rscv_rec.created_by := NULL;
    END IF;
    IF (l_rscv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_rscv_rec.creation_date := NULL;
    END IF;
    IF (l_rscv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_rscv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rscv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_rscv_rec.last_update_date := NULL;
    END IF;
    IF (l_rscv_rec.last_update_login= OKC_API.G_MISS_NUM) THEN
      l_rscv_rec.last_update_login := NULL;
    END IF;
    IF (l_rscv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_rscv_rec.access_level := NULL;
    END IF;
    RETURN(l_rscv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/
-- Start of comments
--
-- Procedure Name  : validate_rle_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_rle_code(x_return_status OUT NOCOPY VARCHAR2,
                          p_rscv_rec	  IN	RSCV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
--1
  if (p_rscv_rec.rle_code = OKC_API.G_MISS_CHAR) then
    return;
  end if;
--2
  if (p_rscv_rec.rle_code is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'RLE_CODE');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
--3
  x_return_status := OKC_UTIL.check_lookup_code('OKC_ROLE',p_rscv_rec.rle_code);
  if (x_return_status <> OKC_API.G_RET_STS_SUCCESS) then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
exception
  when G_EXCEPTION_HALT_VALIDATION then
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_rle_code;


-- Start of comments
--
-- Procedure Name  : validate_buy_or_sell
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_buy_or_sell(x_return_status OUT NOCOPY VARCHAR2,
                          p_rscv_rec	  IN	RSCV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
--1
  if (P_RSCV_REC.buy_or_sell in ('B','S',OKC_API.G_MISS_CHAR)) then
    return;
  end if;
--2
  if (P_RSCV_REC.buy_or_sell is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'BUY_OR_SELL');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--3
  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BUY_OR_SELL');
  x_return_status := OKC_API.G_RET_STS_ERROR;
end validate_buy_or_sell;

-- Start of comments
--
-- Procedure Name  : validate_start_date
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_start_date(x_return_status OUT NOCOPY VARCHAR2,
                          p_rscv_rec	  IN	RSCV_REC_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (P_RSCV_REC.start_date is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'START_DATE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
end validate_start_date;

-- Start of comments
--
-- Procedure Name  : validate_JTOT_OBJECT_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_JTOT_OBJECT_CODE(x_return_status OUT NOCOPY VARCHAR2,
                          p_rscv_rec	  IN	rscv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
cursor l_object_csr is
select '!'
from
	jtf_objects_vl J, jtf_object_usages U
where
	J.OBJECT_CODE = p_rscv_rec.JTOT_OBJECT_CODE
	and sysdate between NVL(J.START_DATE_ACTIVE,sysdate)
		and NVL(J.END_DATE_ACTIVE,sysdate)
	and U.OBJECT_code = p_rscv_rec.JTOT_OBJECT_CODE
	and U.object_user_code='OKX_ROLES';
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
--1
  if (p_rscv_rec.jtot_object_code = OKC_API.G_MISS_CHAR) then
    return;
  end if;
--2
  if (P_RSCV_REC.JTOT_OBJECT_CODE is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'JTOT_OBJECT_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--3
  open l_object_csr;
  fetch l_object_csr into l_dummy_var;
  close l_object_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
--
exception
  when OTHERS then
    if l_object_csr%ISOPEN then
      close l_object_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_JTOT_OBJECT_CODE;

-- Start of comments
--
-- Procedure Name  : validate_ACCESS_LEVEL
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments


  PROCEDURE validate_access_level(
    p_rscv_rec     IN rscv_rec_type,
    x_return_status  OUT NOCOPY  VARCHAR2) IS
  BEGIN
    x_return_status :=OKC_API.G_RET_STS_SUCCESS;

    IF (p_rscv_rec.access_level = OKC_API.G_MISS_CHAR OR
        p_rscv_rec.access_level IS NULL)
    THEN
       raise G_EXCEPTION_HALT_VALIDATION;
    END IF;
    IF upper(p_rscv_rec.access_level) not in ('S','E','U') Then
         OKC_API.SET_MESSAGE(p_app_name         => g_app_name,
                                 p_msg_name     => g_invalid_value,
                                 p_token1       => g_col_name_token,
                                 p_token1_value => 'Access Level');
          x_return_status :=OKC_API.G_RET_STS_ERROR;
    End If;
   exception
    when  G_EXCEPTION_HALT_VALIDATION then
         null;
    when OTHERS then
         OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                                 p_msg_name     => g_unexpected_error,
                                 p_token1       => g_sqlcode_token,
                                 p_token1_value => sqlcode,
                                 p_token2       => g_sqlerrm_token,
                                 p_token2_value => sqlerrm );

         x_return_status :=OKC_API.G_RET_STS_UNEXP_ERROR;

 END validate_access_level;

/*+++++++++++++End of hand code +++++++++++++++++++*/

  ------------------------------------------------
  -- Validate_Attributes for:OKC_ROLE_SOURCES_V --
  ------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rscv_rec IN  rscv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    IF p_rscv_rec.rle_code = OKC_API.G_MISS_CHAR OR
       p_rscv_rec.rle_code IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'rle_code');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rscv_rec.buy_or_sell = OKC_API.G_MISS_CHAR OR
          p_rscv_rec.buy_or_sell IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'buy_or_sell');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rscv_rec.start_date = OKC_API.G_MISS_DATE OR
          p_rscv_rec.start_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'start_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rscv_rec.jtot_object_code = OKC_API.G_MISS_CHAR OR
          p_rscv_rec.JTOT_OBJECT_CODE IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT_CODE');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_rscv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_rscv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
    validate_rle_code(x_return_status => l_return_status,
                    p_rscv_rec      => p_rscv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_buy_or_sell(x_return_status => l_return_status,
                    p_rscv_rec      => p_rscv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_start_date(x_return_status => l_return_status,
                    p_rscv_rec      => p_rscv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_JTOT_OBJECT_CODE(x_return_status => l_return_status,
                    p_rscv_rec      => p_rscv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
      validate_ACCESS_LEVEL(x_return_status => l_return_status,
                    p_rscv_rec      => p_rscv_rec);
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

/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  --------------------------------------------
  -- Validate_Record for:OKC_ROLE_SOURCES_V --
  --------------------------------------------
  FUNCTION Validate_Record (
    p_rscv_rec IN rscv_rec_type
--+++++++++++++++Start handcode +++++++++++++++++++++++++++++++++++
    ,p_mode IN varchar2 default 'UPDATE'  -- or 'INSERT'
--+++++++++++++++End   handcode +++++++++++++++++++++++++++++++++++
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  cursor pk_csr is
    select '!' from okc_role_sources
    where rle_code = p_rscv_rec.rle_code
      and buy_or_sell = p_rscv_rec.buy_or_sell
	and start_date = p_rscv_rec.start_date;
  l_dummy varchar2(1) := '?';
  BEGIN
    if (p_mode = 'INSERT') then
--
      if (p_rscv_rec.rle_code = OKC_API.G_MISS_CHAR
		and p_rscv_rec.buy_or_sell = OKC_API.G_MISS_CHAR
		and p_rscv_rec.start_date = OKC_API.G_MISS_DATE )
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
      OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'RLE_CODE, BUY_OR_SELL, START_DATE');
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
    p_from	IN rscv_rec_type,
    p_to	IN OUT NOCOPY rsc_rec_type
  ) IS
  BEGIN
    p_to.rle_code := p_from.rle_code;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.JTOT_OBJECT_CODE := p_from.JTOT_OBJECT_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN rsc_rec_type,
    p_to	IN OUT NOCOPY rscv_rec_type
  ) IS
  BEGIN
    p_to.rle_code := p_from.rle_code;
    p_to.buy_or_sell := p_from.buy_or_sell;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.JTOT_OBJECT_CODE := p_from.JTOT_OBJECT_CODE;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.access_level:= p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -----------------------------------------
  -- validate_row for:OKC_ROLE_SOURCES_V --
  -----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_rec                     IN rscv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rscv_rec                     rscv_rec_type := p_rscv_rec;
    l_rsc_rec                      rsc_rec_type;
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
    l_return_status := Validate_Attributes(l_rscv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rscv_rec);
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
  -- PL/SQL TBL validate_row for:RSCV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_tbl                     IN rscv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rscv_tbl.COUNT > 0) THEN
      i := p_rscv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rscv_rec                     => p_rscv_tbl(i));
        EXIT WHEN (i = p_rscv_tbl.LAST);
        i := p_rscv_tbl.NEXT(i);
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
  -------------------------------------
  -- insert_row for:OKC_ROLE_SOURCES --
  -------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rsc_rec                      IN rsc_rec_type,
    x_rsc_rec                      OUT NOCOPY rsc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rsc_rec                      rsc_rec_type := p_rsc_rec;
    l_def_rsc_rec                  rsc_rec_type;
    -----------------------------------------
    -- Set_Attributes for:OKC_ROLE_SOURCES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rsc_rec IN  rsc_rec_type,
      x_rsc_rec OUT NOCOPY rsc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rsc_rec := p_rsc_rec;
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
      p_rsc_rec,                         -- IN
      l_rsc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_ROLE_SOURCES(
        rle_code,
        buy_or_sell,
        start_date,
        end_date,
        JTOT_OBJECT_CODE,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        access_level)
      VALUES (
        l_rsc_rec.rle_code,
        l_rsc_rec.buy_or_sell,
        l_rsc_rec.start_date,
        l_rsc_rec.end_date,
        l_rsc_rec.JTOT_OBJECT_CODE,
        l_rsc_rec.object_version_number,
        l_rsc_rec.created_by,
        l_rsc_rec.creation_date,
        l_rsc_rec.last_updated_by,
        l_rsc_rec.last_update_date,
        l_rsc_rec.last_update_login,
        l_rsc_rec.access_level);
    -- Set OUT values
    x_rsc_rec := l_rsc_rec;
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
  -- insert_row for:OKC_ROLE_SOURCES_V --
  ---------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_rec                     IN rscv_rec_type,
    x_rscv_rec                     OUT NOCOPY rscv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rscv_rec                     rscv_rec_type;
    l_def_rscv_rec                 rscv_rec_type;
    l_rsc_rec                      rsc_rec_type;
    lx_rsc_rec                     rsc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rscv_rec	IN rscv_rec_type
    ) RETURN rscv_rec_type IS
      l_rscv_rec	rscv_rec_type := p_rscv_rec;
    BEGIN
      l_rscv_rec.CREATION_DATE := SYSDATE;
      l_rscv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rscv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rscv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rscv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rscv_rec);
    END fill_who_columns;
    -------------------------------------------
    -- Set_Attributes for:OKC_ROLE_SOURCES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rscv_rec IN  rscv_rec_type,
      x_rscv_rec OUT NOCOPY rscv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rscv_rec := p_rscv_rec;
      x_rscv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rscv_rec := null_out_defaults(p_rscv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rscv_rec,                        -- IN
      l_def_rscv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rscv_rec := fill_who_columns(l_def_rscv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rscv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
/*------------------------commented in favor of hand code-----------
    l_return_status := Validate_Record(l_def_rscv_rec);
------------------------commented in favor of hand code-----------*/
--++++++++++++++++++++++Hand code start+++++++++++++++++++++++++++++
    l_return_status := Validate_Record(l_def_rscv_rec,'INSERT');
--++++++++++++++++++++++Hand code   end+++++++++++++++++++++++++++++
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rscv_rec, l_rsc_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rsc_rec,
      lx_rsc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rsc_rec, l_def_rscv_rec);
    -- Set OUT values
    x_rscv_rec := l_def_rscv_rec;
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
  -- PL/SQL TBL insert_row for:RSCV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_tbl                     IN rscv_tbl_type,
    x_rscv_tbl                     OUT NOCOPY rscv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rscv_tbl.COUNT > 0) THEN
      i := p_rscv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rscv_rec                     => p_rscv_tbl(i),
          x_rscv_rec                     => x_rscv_tbl(i));
        EXIT WHEN (i = p_rscv_tbl.LAST);
        i := p_rscv_tbl.NEXT(i);
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
  -----------------------------------
  -- lock_row for:OKC_ROLE_SOURCES --
  -----------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rsc_rec                      IN rsc_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rsc_rec IN rsc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ROLE_SOURCES
     WHERE RLE_CODE = p_rsc_rec.rle_code
       AND BUY_OR_SELL = p_rsc_rec.buy_or_sell
       AND START_DATE = p_rsc_rec.start_date
       AND OBJECT_VERSION_NUMBER = p_rsc_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rsc_rec IN rsc_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_ROLE_SOURCES
    WHERE RLE_CODE = p_rsc_rec.rle_code
       AND BUY_OR_SELL = p_rsc_rec.buy_or_sell
       AND START_DATE = p_rsc_rec.start_date;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_ROLE_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_ROLE_SOURCES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_rsc_rec);
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
      OPEN lchk_csr(p_rsc_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rsc_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rsc_rec.object_version_number THEN
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
  -- lock_row for:OKC_ROLE_SOURCES_V --
  -------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_rec                     IN rscv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rsc_rec                      rsc_rec_type;
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
    migrate(p_rscv_rec, l_rsc_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rsc_rec
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
  -- PL/SQL TBL lock_row for:RSCV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_tbl                     IN rscv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rscv_tbl.COUNT > 0) THEN
      i := p_rscv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rscv_rec                     => p_rscv_tbl(i));
        EXIT WHEN (i = p_rscv_tbl.LAST);
        i := p_rscv_tbl.NEXT(i);
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
  -------------------------------------
  -- update_row for:OKC_ROLE_SOURCES --
  -------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rsc_rec                      IN rsc_rec_type,
    x_rsc_rec                      OUT NOCOPY rsc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rsc_rec                      rsc_rec_type := p_rsc_rec;
    l_def_rsc_rec                  rsc_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rsc_rec	IN rsc_rec_type,
      x_rsc_rec	OUT NOCOPY rsc_rec_type
    ) RETURN VARCHAR2 IS
      l_rsc_rec                      rsc_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rsc_rec := p_rsc_rec;
      -- Get current database values
      l_rsc_rec := get_rec(p_rsc_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rsc_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rsc_rec.rle_code := l_rsc_rec.rle_code;
      END IF;
      IF (x_rsc_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
      THEN
        x_rsc_rec.buy_or_sell := l_rsc_rec.buy_or_sell;
      END IF;
      IF (x_rsc_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_rsc_rec.start_date := l_rsc_rec.start_date;
      END IF;
      IF (x_rsc_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_rsc_rec.end_date := l_rsc_rec.end_date;
      END IF;
      IF (x_rsc_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rsc_rec.JTOT_OBJECT_CODE := l_rsc_rec.JTOT_OBJECT_CODE;
      END IF;
      IF (x_rsc_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rsc_rec.object_version_number := l_rsc_rec.object_version_number;
      END IF;
      IF (x_rsc_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rsc_rec.created_by := l_rsc_rec.created_by;
      END IF;
      IF (x_rsc_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rsc_rec.creation_date := l_rsc_rec.creation_date;
      END IF;
      IF (x_rsc_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rsc_rec.last_updated_by := l_rsc_rec.last_updated_by;
      END IF;
      IF (x_rsc_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rsc_rec.last_update_date := l_rsc_rec.last_update_date;
      END IF;
      IF (x_rsc_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rsc_rec.last_update_login := l_rsc_rec.last_update_login;
      END IF;
      IF (x_rsc_rec.access_level= OKC_API.G_MISS_CHAR)
      THEN
        x_rsc_rec.access_level := l_rsc_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------
    -- Set_Attributes for:OKC_ROLE_SOURCES --
    -----------------------------------------
    FUNCTION Set_Attributes (
      p_rsc_rec IN  rsc_rec_type,
      x_rsc_rec OUT NOCOPY rsc_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rsc_rec := p_rsc_rec;
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
      p_rsc_rec,                         -- IN
      l_rsc_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rsc_rec, l_def_rsc_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_ROLE_SOURCES
    SET END_DATE = l_def_rsc_rec.end_date,
        JTOT_OBJECT_CODE = l_def_rsc_rec.JTOT_OBJECT_CODE,
        OBJECT_VERSION_NUMBER = l_def_rsc_rec.object_version_number,
        CREATED_BY = l_def_rsc_rec.created_by,
        CREATION_DATE = l_def_rsc_rec.creation_date,
        LAST_UPDATED_BY = l_def_rsc_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rsc_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rsc_rec.last_update_login,
        ACCESS_LEVEL = l_def_rsc_rec.access_level
    WHERE RLE_CODE = l_def_rsc_rec.rle_code
      AND BUY_OR_SELL = l_def_rsc_rec.buy_or_sell
      AND START_DATE = l_def_rsc_rec.start_date;

    x_rsc_rec := l_def_rsc_rec;
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
  -- update_row for:OKC_ROLE_SOURCES_V --
  ---------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_rec                     IN rscv_rec_type,
    x_rscv_rec                     OUT NOCOPY rscv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rscv_rec                     rscv_rec_type := p_rscv_rec;
    l_def_rscv_rec                 rscv_rec_type;
    l_rsc_rec                      rsc_rec_type;
    lx_rsc_rec                     rsc_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rscv_rec	IN rscv_rec_type
    ) RETURN rscv_rec_type IS
      l_rscv_rec	rscv_rec_type := p_rscv_rec;
    BEGIN
      l_rscv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rscv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rscv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rscv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rscv_rec	IN rscv_rec_type,
      x_rscv_rec	OUT NOCOPY rscv_rec_type
    ) RETURN VARCHAR2 IS
      l_rscv_rec                     rscv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rscv_rec := p_rscv_rec;
      -- Get current database values
      l_rscv_rec := get_rec(p_rscv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_rscv_rec.rle_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rscv_rec.rle_code := l_rscv_rec.rle_code;
      END IF;
      IF (x_rscv_rec.buy_or_sell = OKC_API.G_MISS_CHAR)
      THEN
        x_rscv_rec.buy_or_sell := l_rscv_rec.buy_or_sell;
      END IF;
      IF (x_rscv_rec.start_date = OKC_API.G_MISS_DATE)
      THEN
        x_rscv_rec.start_date := l_rscv_rec.start_date;
      END IF;
      IF (x_rscv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_rscv_rec.end_date := l_rscv_rec.end_date;
      END IF;
      IF (x_rscv_rec.jtot_object_code = OKC_API.G_MISS_CHAR)
      THEN
        x_rscv_rec.JTOT_OBJECT_CODE := l_rscv_rec.JTOT_OBJECT_CODE;
      END IF;
      IF (x_rscv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_rscv_rec.object_version_number := l_rscv_rec.object_version_number;
      END IF;
      IF (x_rscv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_rscv_rec.created_by := l_rscv_rec.created_by;
      END IF;
      IF (x_rscv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_rscv_rec.creation_date := l_rscv_rec.creation_date;
      END IF;
      IF (x_rscv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_rscv_rec.last_updated_by := l_rscv_rec.last_updated_by;
      END IF;
      IF (x_rscv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_rscv_rec.last_update_date := l_rscv_rec.last_update_date;
      END IF;
      IF (x_rscv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_rscv_rec.last_update_login := l_rscv_rec.last_update_login;
      END IF;
      IF (x_rscv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_rscv_rec.access_level := l_rscv_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_ROLE_SOURCES_V --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_rscv_rec IN  rscv_rec_type,
      x_rscv_rec OUT NOCOPY rscv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rscv_rec := p_rscv_rec;
      x_rscv_rec.OBJECT_VERSION_NUMBER := NVL(x_rscv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_rscv_rec,                        -- IN
      l_rscv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rscv_rec, l_def_rscv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rscv_rec := fill_who_columns(l_def_rscv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rscv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rscv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_rscv_rec, l_rsc_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rsc_rec,
      lx_rsc_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rsc_rec, l_def_rscv_rec);
    x_rscv_rec := l_def_rscv_rec;
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
  -- PL/SQL TBL update_row for:RSCV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_tbl                     IN rscv_tbl_type,
    x_rscv_tbl                     OUT NOCOPY rscv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rscv_tbl.COUNT > 0) THEN
      i := p_rscv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rscv_rec                     => p_rscv_tbl(i),
          x_rscv_rec                     => x_rscv_tbl(i));
        EXIT WHEN (i = p_rscv_tbl.LAST);
        i := p_rscv_tbl.NEXT(i);
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
  -------------------------------------
  -- delete_row for:OKC_ROLE_SOURCES --
  -------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rsc_rec                      IN rsc_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'SOURCES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rsc_rec                      rsc_rec_type:= p_rsc_rec;
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
    DELETE FROM OKC_ROLE_SOURCES
     WHERE RLE_CODE = l_rsc_rec.rle_code AND
BUY_OR_SELL = l_rsc_rec.buy_or_sell AND
START_DATE = l_rsc_rec.start_date;

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
  -- delete_row for:OKC_ROLE_SOURCES_V --
  ---------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_rec                     IN rscv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rscv_rec                     rscv_rec_type := p_rscv_rec;
    l_rsc_rec                      rsc_rec_type;
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
    migrate(l_rscv_rec, l_rsc_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rsc_rec
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
  -- PL/SQL TBL delete_row for:RSCV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rscv_tbl                     IN rscv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rscv_tbl.COUNT > 0) THEN
      i := p_rscv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rscv_rec                     => p_rscv_tbl(i));
        EXIT WHEN (i = p_rscv_tbl.LAST);
        i := p_rscv_tbl.NEXT(i);
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
END OKC_RSC_PVT;

/
