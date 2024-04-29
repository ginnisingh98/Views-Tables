--------------------------------------------------------
--  DDL for Package Body OKC_CIM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_CIM_PVT" AS
/* $Header: OKCSCIMB.pls 120.1 2005/11/23 01:23:39 jvorugan noship $ */

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
  -- FUNCTION get_rec for: OKC_K_ITEMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cim_rec                      IN cim_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cim_rec_type IS
    CURSOR cim_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            CHR_ID,
            CLE_ID_FOR,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            UOM_CODE,
            EXCEPTION_YN,
            NUMBER_OF_ITEMS,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            PRICED_ITEM_YN,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
      FROM Okc_K_Items
     WHERE okc_k_items.id       = p_id;
    l_cim_pk                       cim_pk_csr%ROWTYPE;
    l_cim_rec                      cim_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN cim_pk_csr (p_cim_rec.id);
    FETCH cim_pk_csr INTO
              l_cim_rec.ID,
              l_cim_rec.CLE_ID,
              l_cim_rec.CHR_ID,
              l_cim_rec.CLE_ID_FOR,
              l_cim_rec.DNZ_CHR_ID,
              l_cim_rec.OBJECT1_ID1,
              l_cim_rec.OBJECT1_ID2,
              l_cim_rec.JTOT_OBJECT1_CODE,
              l_cim_rec.UOM_CODE,
              l_cim_rec.EXCEPTION_YN,
              l_cim_rec.NUMBER_OF_ITEMS,
              l_cim_rec.UPG_ORIG_SYSTEM_REF,
              l_cim_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_cim_rec.PRICED_ITEM_YN,
              l_cim_rec.OBJECT_VERSION_NUMBER,
              l_cim_rec.CREATED_BY,
              l_cim_rec.CREATION_DATE,
              l_cim_rec.LAST_UPDATED_BY,
              l_cim_rec.LAST_UPDATE_DATE,
              l_cim_rec.LAST_UPDATE_LOGIN,
              l_cim_rec.REQUEST_ID,
              l_cim_rec.PROGRAM_APPLICATION_ID,
              l_cim_rec.PROGRAM_ID,
              l_cim_rec.PROGRAM_UPDATE_DATE;
    x_no_data_found := cim_pk_csr%NOTFOUND;
    CLOSE cim_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('550: Leaving Fn Get_Rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_cim_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cim_rec                      IN cim_rec_type
  ) RETURN cim_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cim_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_K_ITEMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_cimv_rec                     IN cimv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN cimv_rec_type IS
    CURSOR okc_cimv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            CLE_ID,
            CHR_ID,
            CLE_ID_FOR,
            DNZ_CHR_ID,
            OBJECT1_ID1,
            OBJECT1_ID2,
            JTOT_OBJECT1_CODE,
            UOM_CODE,
            EXCEPTION_YN,
            NUMBER_OF_ITEMS,
            UPG_ORIG_SYSTEM_REF,
            UPG_ORIG_SYSTEM_REF_ID,
            PRICED_ITEM_YN,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            REQUEST_ID,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE
      FROM Okc_K_Items_V
     WHERE okc_k_items_v.id     = p_id;
    l_okc_cimv_pk                  okc_cimv_pk_csr%ROWTYPE;
    l_cimv_rec                     cimv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_cimv_pk_csr (p_cimv_rec.id);
    FETCH okc_cimv_pk_csr INTO
              l_cimv_rec.ID,
              l_cimv_rec.OBJECT_VERSION_NUMBER,
              l_cimv_rec.CLE_ID,
              l_cimv_rec.CHR_ID,
              l_cimv_rec.CLE_ID_FOR,
              l_cimv_rec.DNZ_CHR_ID,
              l_cimv_rec.OBJECT1_ID1,
              l_cimv_rec.OBJECT1_ID2,
              l_cimv_rec.JTOT_OBJECT1_CODE,
              l_cimv_rec.UOM_CODE,
              l_cimv_rec.EXCEPTION_YN,
              l_cimv_rec.NUMBER_OF_ITEMS,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF,
              l_cimv_rec.UPG_ORIG_SYSTEM_REF_ID,
              l_cimv_rec.PRICED_ITEM_YN,
              l_cimv_rec.CREATED_BY,
              l_cimv_rec.CREATION_DATE,
              l_cimv_rec.LAST_UPDATED_BY,
              l_cimv_rec.LAST_UPDATE_DATE,
              l_cimv_rec.LAST_UPDATE_LOGIN,
              l_cimv_rec.REQUEST_ID,
              l_cimv_rec.PROGRAM_APPLICATION_ID,
              l_cimv_rec.PROGRAM_ID,
              l_cimv_rec.PROGRAM_UPDATE_DATE;

    x_no_data_found := okc_cimv_pk_csr%NOTFOUND;
    CLOSE okc_cimv_pk_csr;

  IF (l_debug = 'Y') THEN
     okc_debug.log('750: Leaving Fn Get_Rec ', 2);
     okc_debug.Reset_Indentation;
  END IF;

    RETURN(l_cimv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_cimv_rec                     IN cimv_rec_type
  ) RETURN cimv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_cimv_rec, l_row_notfound));

  END get_rec;

  ---------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_K_ITEMS_V --
  ---------------------------------------------------
  FUNCTION null_out_defaults (
    p_cimv_rec	IN cimv_rec_type
  ) RETURN cimv_rec_type IS
    l_cimv_rec	cimv_rec_type := p_cimv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('900: Entered null_out_defaults', 2);
    END IF;

    IF (l_cimv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.object_version_number := NULL;
    END IF;
    IF (l_cimv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.cle_id := NULL;
    END IF;
    IF (l_cimv_rec.chr_id = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.chr_id := NULL;
    END IF;
    IF (l_cimv_rec.cle_id_for = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.cle_id_for := NULL;
    END IF;
    IF (l_cimv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_cimv_rec.object1_id1 = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.object1_id1 := NULL;
    END IF;
    IF (l_cimv_rec.object1_id2 = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.object1_id2 := NULL;
    END IF;
    IF (l_cimv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.jtot_object1_code := NULL;
    END IF;
    IF (l_cimv_rec.uom_code = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.uom_code := NULL;
    END IF;
    IF (l_cimv_rec.exception_yn = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.exception_yn := NULL;
    END IF;
    IF (l_cimv_rec.number_of_items = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.number_of_items := NULL;
    END IF;
    IF (l_cimv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.upg_orig_system_ref := NULL;
    END IF;
    IF (l_cimv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.upg_orig_system_ref_id := NULL;
    END IF;
    IF (l_cimv_rec.priced_item_yn = OKC_API.G_MISS_CHAR) THEN
      l_cimv_rec.priced_item_yn := NULL;
    END IF;
    IF (l_cimv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.created_by := NULL;
    END IF;
    IF (l_cimv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_cimv_rec.creation_date := NULL;
    END IF;
    IF (l_cimv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.last_updated_by := NULL;
    END IF;
    IF (l_cimv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_cimv_rec.last_update_date := NULL;
    END IF;
    IF (l_cimv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_cimv_rec.last_update_login := NULL;
    END IF;
    IF (l_cimv_rec.request_id = OKC_API.G_MISS_NUM) THEN
        l_cimv_rec.request_id := NULL;
    END IF;
    IF (l_cimv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
        l_cimv_rec.program_application_id := NULL;
    END IF;
    IF (l_cimv_rec.program_id = OKC_API.G_MISS_NUM) THEN
        l_cimv_rec.program_id := NULL;
    END IF;
    IF (l_cimv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
        l_cimv_rec.program_update_date := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('950: Leaving  Fn  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_cimv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
/*+++++++++++++Start of hand code +++++++++++++++++*/

-- Start of comments
--
-- Procedure Name  : validate_cle_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cle_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cle_csr is
  select 'x'
  from OKC_K_LINES_B
  where id = p_cimv_rec.cle_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('1000: Entered validate_cle_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.cle_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_cimv_rec.cle_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'CLE_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;
  open l_cle_csr;
  fetch l_cle_csr into l_dummy_var;
  close l_cle_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
    raise G_EXCEPTION_HALT_VALIDATION;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving validate_cle_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when G_EXCEPTION_HALT_VALIDATION then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_cle_id:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1300: Exiting validate_cle_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cle_csr%ISOPEN then
      close l_cle_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cle_id;

-- Start of comments
--
-- Procedure Name  : validate_cle_id_for
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_cle_id_for(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_cle_csr is
  select 'x'
  from OKC_K_LINES_B
  where id = p_cimv_rec.cle_id_for;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('1400: Entered validate_cle_id_for', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.cle_id_for = OKC_API.G_MISS_NUM or p_cimv_rec.cle_id_for is NULL) then
    return;
  end if;
  open l_cle_csr;
  fetch l_cle_csr into l_dummy_var;
  close l_cle_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID_FOR');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Leaving validate_cle_id_for', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1600: Exiting validate_cle_id_for:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_cle_csr%ISOPEN then
      close l_cle_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_cle_id_for;

-- Start of comments
--
-- Procedure Name  : validate_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_chr_csr is
  select 'x'
  from  OKC_K_HEADERS_ALL_B   -- Modiifed by jvorugan for Bug: 4645341 OKC_K_HEADERS_B
  where id = p_cimv_rec.chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('1700: Entered validate_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.chr_id = OKC_API.G_MISS_NUM or p_cimv_rec.chr_id is NULL) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
  open l_chr_csr;
  fetch l_chr_csr into l_dummy_var;
  close l_chr_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Leaving validate_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_chr_csr%ISOPEN then
      close l_chr_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_chr_id;

-- Start of comments
--
-- Procedure Name  : validate_exception_yn
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_exception_yn(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('2000: Entered validate_exception_yn', 2);
    END IF;

  if (p_cimv_rec.exception_yn in ('Y','N',OKC_API.G_MISS_CHAR)) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  else
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'EXCEPTION_YN');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2050: Leaving  validate_exception_yn ', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_exception_yn;

-- Start of comments
--
-- Procedure Name  : validate_priced_item_yn
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_priced_item_yn(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
begin

IF (l_debug = 'Y') THEN
   okc_debug.Set_Indentation('OKC_CIM_PVT');
   okc_debug.log('2100: Entered validate_priced_item_yn', 2);
END IF;

  if (p_cimv_rec.priced_item_yn is NULL or p_cimv_rec.priced_item_yn in ('Y','N',OKC_API.G_MISS_CHAR)) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  else
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRICED_ITEM_YN');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

IF (l_debug = 'Y') THEN
   okc_debug.log('2150: Leaving  validate_priced_item_yn ', 2);
   okc_debug.Reset_Indentation;
END IF;

end validate_priced_item_yn;

-- Start of comments
--
-- Procedure Name  : validate_UOM_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_UOM_CODE(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
cursor l_okx_csr is
  select 'x'
  from OKX_UNITS_OF_MEASURE_V
  where UOM_CODE = p_cimv_rec.UOM_CODE;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('2200: Entered validate_UOM_CODE', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.UOM_CODE = OKC_API.G_MISS_CHAR
      or p_cimv_rec.UOM_CODE is NULL) then
    return;
  end if;
  open l_okx_csr;
  fetch l_okx_csr into l_dummy_var;
  close l_okx_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'UOM_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2450: Leaving validate_UOM_CODE', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2400: Exiting validate_UOM_CODE:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_okx_csr%ISOPEN then
      close l_okx_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_UOM_CODE;

-- Start of comments
--
-- Procedure Name  : validate_JTOT_OBJECT1_CODE
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_JTOT_OBJECT1_CODE(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	CIMV_REC_TYPE) is
l_dummy_var                 varchar2(1) := '?';
--
cursor l_object1_csr is
select '!'
from
	okc_k_lines_b LN
	,okc_line_styles_b SL
	,okc_line_style_sources SS
where
	LN.ID = p_cimv_rec.cle_id
	and SL.id = LN.LSE_ID
	and SS.LSE_ID = SL.id
	and SS.jtot_object_code = p_cimv_rec.JTOT_OBJECT1_CODE
	and sysdate>=SS.start_date
	and (SS.end_date is NULL or SS.end_date>=sysdate)
;


begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('2500: Entered validate_JTOT_OBJECT1_CODE', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_cimv_rec.jtot_object1_code is NULL) then
    return;
  end if;
--

  open l_object1_csr;
  fetch l_object1_csr into l_dummy_var;
  close l_object1_csr;
  if (l_dummy_var = '?') then
    OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  end if;
    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Leaving validate_JTOT_OBJECT1_CODE', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('2700: Exiting validate_JTOT_OBJECT1_CODE:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_JTOT_OBJECT1_CODE;

-- Start of comments
--
-- Procedure Name  : validate_object1_id1
-- Description     :  to be called from validate record
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_object1_id1(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	cimv_rec_TYPE) is
l_dummy_var                 varchar2(1) := '?';
L_FROM_TABLE    		VARCHAR2(200);
L_WHERE_CLAUSE            VARCHAR2(2000);
cursor l_object1_csr is
select
	from_table
	,trim(where_clause) where_clause
from
	jtf_objects_vl OB
where
	OB.OBJECT_CODE = p_cimv_rec.jtot_object1_code
;
e_no_data_found EXCEPTION;
PRAGMA EXCEPTION_INIT(e_no_data_found,100);
e_too_many_rows EXCEPTION;
PRAGMA EXCEPTION_INIT(e_too_many_rows,-1422);
e_source_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_source_not_exists,-942);
e_column_not_exists EXCEPTION;
PRAGMA EXCEPTION_INIT(e_column_not_exists,-904);

begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('2800: Entered validate_object1_id1', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR or p_cimv_rec.jtot_object1_code is NULL) then
    return;
  end if;
  if (p_cimv_rec.object1_id1 = OKC_API.G_MISS_CHAR or p_cimv_rec.object1_id1 is NULL) then
	return;
  end if;
  open l_object1_csr;
  fetch l_object1_csr into l_from_table, l_where_clause;
  close l_object1_csr;
  if (l_where_clause is not null) then
	l_where_clause := ' and '||l_where_clause;
  end if;

  EXECUTE IMMEDIATE 'select ''x'' from '||l_from_table||
	' where id1=:object1_id1 and id2=:object1_id2'||l_where_clause
	into l_dummy_var
	USING p_cimv_rec.object1_id1, p_cimv_rec.object1_id2;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2900: Leaving validate_object1_id1', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when e_source_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting validate_object1_id1:e_source_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'JTOT_OBJECT1_CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_column_not_exists then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting validate_object1_id1:e_column_not_exists Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_no_data_found then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Exiting validate_object1_id1:e_no_data_found Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME,'OKC_INVALID_ITEM');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when e_too_many_rows then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting validate_object1_id1:e_too_many_rows Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,l_from_table||'.ID1');
    x_return_status := OKC_API.G_RET_STS_ERROR;
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_object1_id1:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    if l_object1_csr%ISOPEN then
      close l_object1_csr;
    end if;
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_object1_id1;

-- Start of comments
--
-- Procedure Name  : validate_dnz_chr_id
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments

procedure validate_dnz_chr_id(x_return_status OUT NOCOPY VARCHAR2,
                          p_cimv_rec	  IN	cimv_rec_TYPE) is
l_dummy varchar2(1) := '?';
cursor Kt_Hr_Mj_Vr is
    select '!'
    from okc_k_headers_all_b -- Modified by Jvorugan for Bug:4645341 okc_k_headers_b
    where id = p_cimv_rec.dnz_chr_id;
begin

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('3500: Entered validate_dnz_chr_id', 2);
    END IF;

  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_cimv_rec.dnz_chr_id = OKC_API.G_MISS_NUM) then
    return;
  end if;
  if (p_cimv_rec.dnz_chr_id is NULL) then
    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => G_REQUIRED_VALUE,
                        p_token1       => G_COL_NAME_TOKEN,
                        p_token1_value => 'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;
  open Kt_Hr_Mj_Vr;
  fetch Kt_Hr_Mj_Vr into l_dummy;
  close Kt_Hr_Mj_Vr;
  if (l_dummy='?') then
  	OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'DNZ_CHR_ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
	return;
  end if;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3600: Leaving validate_dnz_chr_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

exception
  when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('3700: Exiting validate_dnz_chr_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

    OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

end validate_dnz_chr_id;

/*+++++++++++++End of hand code +++++++++++++++++++*/
  -------------------------------------------
  -- Validate_Attributes for:OKC_K_ITEMS_V --
  -------------------------------------------
  FUNCTION Validate_Attributes (
    p_cimv_rec IN  cimv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*-------------Commented in favor of hand code------
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('3800: Entered Validate_Attributes', 2);
    END IF;

    IF p_cimv_rec.id = OKC_API.G_MISS_NUM OR
       p_cimv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cimv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_cimv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cimv_rec.cle_id = OKC_API.G_MISS_NUM OR
          p_cimv_rec.cle_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'cle_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cimv_rec.dnz_chr_id = OKC_API.G_MISS_NUM OR
          p_cimv_rec.dnz_chr_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'dnz_chr_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_cimv_rec.exception_yn = OKC_API.G_MISS_CHAR OR
          p_cimv_rec.exception_yn IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'exception_yn');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('3850: Leaving Validate_Attributes ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_return_status);

  END Validate_Attributes;
---------------End of the commented code-----------*/
/*+++++++++++++Start of hand code +++++++++++++++++*/
  x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation
--
    validate_cle_id(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_cle_id_for(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_chr_id(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_exception_yn(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_priced_item_yn(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_UOM_CODE(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
    validate_dnz_chr_id(x_return_status => l_return_status,
                    p_cimv_rec      => p_cimv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
--
IF (l_debug = 'Y') THEN
   okc_debug.log('3860: Leaving Validate_Attributes ', 2);
   okc_debug.Reset_Indentation;
END IF;

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
  ---------------------------------------
  -- Validate_Record for:OKC_K_ITEMS_V --
  ---------------------------------------
  FUNCTION Validate_Record (
    p_cimv_rec IN cimv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
/*+++++++++++++Start of hand code +++++++++++++++++*/
  l_dummy_var VARCHAR2(1) := '?';
  x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  -- indirection
  l_access_level        VARCHAR2(1);
  l_lse_id              NUMBER;

  Cursor c_lse_id is
   select lse_id
   from   okc_k_lines_b
   where  id = p_cimv_rec.cle_id;

  Cursor c_access_level(p_id number) is
    select access_level
    from okc_line_styles_b
    where id = p_id;
  --

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('3900: Entered Validate_Record', 2);
    END IF;

      if ((p_cimv_rec.chr_id IS NOT NULL and p_cimv_rec.chr_id <> OKC_API.G_MISS_NUM) and
          (p_cimv_rec.cle_id_for IS NOT NULL and p_cimv_rec.cle_id_for <> OKC_API.G_MISS_NUM)) then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CHR_ID, CLE_ID_FOR');
        l_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    -- indirection
    Open c_lse_id;
    Fetch c_lse_id into l_lse_id;
    Close c_lse_id;

    Open c_access_level(l_lse_id);
    Fetch c_access_level into l_access_level;
    Close c_access_level;
    If l_access_level = 'U' Then -- If user defined line style
    --

      validate_JTOT_OBJECT1_CODE(x_return_status => l_return_status,
                      p_cimv_rec      => p_cimv_rec);
      if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         IF (l_debug = 'Y') THEN
             okc_debug.log('3910: Exiting Validate_jtot_object1_code in validate_record:unexp err', 2);
             okc_debug.Reset_Indentation;
         END IF;
        return OKC_API.G_RET_STS_UNEXP_ERROR;
      end if;
      if (l_return_status = OKC_API.G_RET_STS_ERROR
          and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
          x_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
      validate_object1_id1(x_return_status => l_return_status,
                      p_cimv_rec      => p_cimv_rec);
      if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
         IF (l_debug = 'Y') THEN
             okc_debug.log('3920: Exiting Validate_object1_id1 in validate_record:unexp err', 2);
             okc_debug.Reset_Indentation;
         END IF;
         return OKC_API.G_RET_STS_UNEXP_ERROR;
      end if;
      if (l_return_status = OKC_API.G_RET_STS_ERROR
          and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
          x_return_status := OKC_API.G_RET_STS_ERROR;
      end if;
    End If; -- if user defined

    IF (l_debug = 'Y') THEN
       okc_debug.log('3950: Leaving Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN (x_return_status);

  exception
    when OTHERS then

    IF (l_debug = 'Y') THEN
       okc_debug.log('4100: Exiting Validate_Record:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      RETURN(OKC_API.G_RET_STS_UNEXP_ERROR);

  END Validate_Record;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN cimv_rec_type,
    p_to	IN OUT NOCOPY cim_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id_for := p_from.cle_id_for;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.uom_code := p_from.uom_code;
    p_to.exception_yn := p_from.exception_yn;
    p_to.number_of_items := p_from.number_of_items;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.priced_item_yn := p_from.priced_item_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.request_id   := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;

  END migrate;


  PROCEDURE migrate (
    p_from	IN cim_rec_type,
    p_to	IN OUT NOCOPY cimv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.chr_id := p_from.chr_id;
    p_to.cle_id_for := p_from.cle_id_for;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.object1_id1 := p_from.object1_id1;
    p_to.object1_id2 := p_from.object1_id2;
    p_to.jtot_object1_code := p_from.jtot_object1_code;
    p_to.uom_code := p_from.uom_code;
    p_to.exception_yn := p_from.exception_yn;
    p_to.number_of_items := p_from.number_of_items;
    p_to.upg_orig_system_ref := p_from.upg_orig_system_ref;
    p_to.upg_orig_system_ref_id := p_from.upg_orig_system_ref_id;
    p_to.priced_item_yn := p_from.priced_item_yn;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.request_id   := p_from.request_id;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ------------------------------------
  -- validate_row for:OKC_K_ITEMS_V --
  ------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cimv_rec                     cimv_rec_type := p_cimv_rec;
    l_cim_rec                      cim_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('4400: Entered validate_row', 2);
    END IF;

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
    l_return_status := Validate_Attributes(l_cimv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_cimv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4600: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4700: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('4800: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL validate_row for:CIMV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('4900: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cimv_tbl.COUNT > 0) THEN
      i := p_cimv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cimv_rec                     => p_cimv_tbl(i));
        EXIT WHEN (i = p_cimv_tbl.LAST);
        i := p_cimv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5200: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5300: Exiting validate_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------
  -- insert_row for:OKC_K_ITEMS --
  --------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cim_rec                      IN cim_rec_type,
    x_cim_rec                      OUT NOCOPY cim_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ITEMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cim_rec                      cim_rec_type := p_cim_rec;
    l_def_cim_rec                  cim_rec_type;
    ------------------------------------
    -- Set_Attributes for:OKC_K_ITEMS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_cim_rec IN  cim_rec_type,
      x_cim_rec OUT NOCOPY cim_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cim_rec := p_cim_rec;

      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('5500: Entered insert_row', 2);
    END IF;

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
      p_cim_rec,                         -- IN
      l_cim_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_K_ITEMS(
        id,
        cle_id,
        chr_id,
        cle_id_for,
        dnz_chr_id,
        object1_id1,
        object1_id2,
        jtot_object1_code,
        uom_code,
        exception_yn,
        number_of_items,
        upg_orig_system_ref,
        upg_orig_system_ref_id,
        priced_item_yn,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        request_id,
        program_application_id,
        program_id,
        program_update_date
	   )
      VALUES (
        l_cim_rec.id,
        l_cim_rec.cle_id,
        l_cim_rec.chr_id,
        l_cim_rec.cle_id_for,
        l_cim_rec.dnz_chr_id,
        l_cim_rec.object1_id1,
        l_cim_rec.object1_id2,
        l_cim_rec.jtot_object1_code,
        l_cim_rec.uom_code,
        l_cim_rec.exception_yn,
        l_cim_rec.number_of_items,
        l_cim_rec.upg_orig_system_ref,
        l_cim_rec.upg_orig_system_ref_id,
        l_cim_rec.priced_item_yn,
        l_cim_rec.object_version_number,
        l_cim_rec.created_by,
        l_cim_rec.creation_date,
        l_cim_rec.last_updated_by,
        l_cim_rec.last_update_date,
        l_cim_rec.last_update_login,
decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE) );
    -- Set OUT values
    x_cim_rec := l_cim_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('5600: Leaving insert_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ----------------------------------
  -- insert_row for:OKC_K_ITEMS_V --
  ----------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cimv_rec                     cimv_rec_type;
    l_def_cimv_rec                 cimv_rec_type;
    l_cim_rec                      cim_rec_type;
    lx_cim_rec                     cim_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cimv_rec	IN cimv_rec_type
    ) RETURN cimv_rec_type IS
      l_cimv_rec	cimv_rec_type := p_cimv_rec;
    BEGIN

      l_cimv_rec.CREATION_DATE := SYSDATE;
      l_cimv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_cimv_rec.LAST_UPDATE_DATE := l_cimv_rec.CREATION_DATE;
      l_cimv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cimv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_cimv_rec);

    END fill_who_columns;
    --------------------------------------
    -- Set_Attributes for:OKC_K_ITEMS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cimv_rec IN  cimv_rec_type,
      x_cimv_rec OUT NOCOPY cimv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cimv_rec := p_cimv_rec;
      x_cimv_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('6200: Entered insert_row', 2);
    END IF;

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
    l_cimv_rec := null_out_defaults(p_cimv_rec);
    -- Set primary key value
    l_cimv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_cimv_rec,                        -- IN
      l_def_cimv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cimv_rec := fill_who_columns(l_def_cimv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cimv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cimv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cimv_rec, l_cim_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cim_rec,
      lx_cim_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cim_rec, l_def_cimv_rec);
    -- Set OUT values
    x_cimv_rec := l_def_cimv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('6500: Leaving insert_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6500: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('6600: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL insert_row for:CIMV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('6700: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cimv_tbl.COUNT > 0) THEN
      i := p_cimv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cimv_rec                     => p_cimv_tbl(i),
          x_cimv_rec                     => x_cimv_tbl(i));
        EXIT WHEN (i = p_cimv_tbl.LAST);
        i := p_cimv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000 : Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting insert_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ------------------------------
  -- lock_row for:OKC_K_ITEMS --
  ------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cim_rec                      IN cim_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_cim_rec IN cim_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ITEMS
     WHERE ID = p_cim_rec.id
       AND OBJECT_VERSION_NUMBER = p_cim_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_cim_rec IN cim_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_K_ITEMS
    WHERE ID = p_cim_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ITEMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_K_ITEMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_K_ITEMS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('7200: Entered lock_row', 2);
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('7300: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_cim_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('7400: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7500: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_cim_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_cim_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_cim_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('7900: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------
  -- lock_row for:OKC_K_ITEMS_V --
  --------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cim_rec                      cim_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('8000: Entered lock_row', 2);
    END IF;

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
    migrate(p_cimv_rec, l_cim_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cim_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8200: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL lock_row for:CIMV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('8500: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cimv_tbl.COUNT > 0) THEN
      i := p_cimv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cimv_rec                     => p_cimv_tbl(i));
        EXIT WHEN (i = p_cimv_tbl.LAST);
        i := p_cimv_tbl.NEXT(i);
      END LOOP;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('8600: Leaving lock_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting lock_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------
  -- update_row for:OKC_K_ITEMS --
  --------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cim_rec                      IN cim_rec_type,
    x_cim_rec                      OUT NOCOPY cim_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ITEMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cim_rec                      cim_rec_type := p_cim_rec;
    l_def_cim_rec                  cim_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cim_rec	IN cim_rec_type,
      x_cim_rec	OUT NOCOPY cim_rec_type
    ) RETURN VARCHAR2 IS
      l_cim_rec                      cim_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('9000: Entered populate_new_record', 2);
    END IF;

      x_cim_rec := p_cim_rec;
      -- Get current database values
      l_cim_rec := get_rec(p_cim_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cim_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.id := l_cim_rec.id;
      END IF;
      IF (x_cim_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.cle_id := l_cim_rec.cle_id;
      END IF;
      IF (x_cim_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.chr_id := l_cim_rec.chr_id;
      END IF;
      IF (x_cim_rec.cle_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.cle_id_for := l_cim_rec.cle_id_for;
      END IF;
      IF (x_cim_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.dnz_chr_id := l_cim_rec.dnz_chr_id;
      END IF;
      IF (x_cim_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.object1_id1 := l_cim_rec.object1_id1;
      END IF;
      IF (x_cim_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.object1_id2 := l_cim_rec.object1_id2;
      END IF;
      IF (x_cim_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.jtot_object1_code := l_cim_rec.jtot_object1_code;
      END IF;
      IF (x_cim_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.uom_code := l_cim_rec.uom_code;
      END IF;
      IF (x_cim_rec.exception_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.exception_yn := l_cim_rec.exception_yn;
      END IF;
      IF (x_cim_rec.number_of_items = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.number_of_items := l_cim_rec.number_of_items;
      END IF;
      IF (x_cim_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.upg_orig_system_ref := l_cim_rec.upg_orig_system_ref;
      END IF;
      IF (x_cim_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.upg_orig_system_ref_id := l_cim_rec.upg_orig_system_ref_id;
      END IF;
      IF (x_cim_rec.priced_item_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cim_rec.priced_item_yn := l_cim_rec.priced_item_yn;
      END IF;
      IF (x_cim_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.object_version_number := l_cim_rec.object_version_number;
      END IF;
      IF (x_cim_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.created_by := l_cim_rec.created_by;
      END IF;
      IF (x_cim_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cim_rec.creation_date := l_cim_rec.creation_date;
      END IF;
      IF (x_cim_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.last_updated_by := l_cim_rec.last_updated_by;
      END IF;
      IF (x_cim_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cim_rec.last_update_date := l_cim_rec.last_update_date;
      END IF;
      IF (x_cim_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.last_update_login := l_cim_rec.last_update_login;
      END IF;
      IF (x_cim_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.request_id := l_cim_rec.request_id;
      END IF;
      IF (x_cim_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.program_application_id := l_cim_rec.program_application_id ;
      END IF;
      IF (x_cim_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_cim_rec.program_id := l_cim_rec.program_id ;
      END IF;
      IF (x_cim_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cim_rec.program_update_date := l_cim_rec.program_update_date ;
      END IF;


    IF (l_debug = 'Y') THEN
       okc_debug.log('9100: Leaving populate_new_record', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------
    -- Set_Attributes for:OKC_K_ITEMS --
    ------------------------------------
    FUNCTION Set_Attributes (
      p_cim_rec IN  cim_rec_type,
      x_cim_rec OUT NOCOPY cim_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cim_rec := p_cim_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('9200: Entered update_row', 2);
    END IF;

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
      p_cim_rec,                         -- IN
      l_cim_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cim_rec, l_def_cim_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_K_ITEMS
    SET CLE_ID = l_def_cim_rec.cle_id,
        CHR_ID = l_def_cim_rec.chr_id,
        CLE_ID_FOR = l_def_cim_rec.cle_id_for,
        DNZ_CHR_ID = l_def_cim_rec.dnz_chr_id,
        OBJECT1_ID1 = l_def_cim_rec.object1_id1,
        OBJECT1_ID2 = l_def_cim_rec.object1_id2,
        JTOT_OBJECT1_CODE = l_def_cim_rec.jtot_object1_code,
        UOM_CODE = l_def_cim_rec.uom_code,
        EXCEPTION_YN = l_def_cim_rec.exception_yn,
        NUMBER_OF_ITEMS = l_def_cim_rec.number_of_items,
        UPG_ORIG_SYSTEM_REF = l_def_cim_rec.upg_orig_system_ref,
        UPG_ORIG_SYSTEM_REF_ID = l_def_cim_rec.upg_orig_system_ref_id,
        PRICED_ITEM_YN = l_def_cim_rec.priced_item_yn,
        OBJECT_VERSION_NUMBER = l_def_cim_rec.object_version_number,
        CREATED_BY = l_def_cim_rec.created_by,
        CREATION_DATE = l_def_cim_rec.creation_date,
        LAST_UPDATED_BY = l_def_cim_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_cim_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_cim_rec.last_update_login,
        PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_cim_rec.program_id ),
REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_cim_rec.request_id),
PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_cim_rec.program_update_date,SYSDATE),
PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_cim_rec.program_application_id)
    WHERE ID = l_def_cim_rec.id;

    x_cim_rec := l_def_cim_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9300: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ----------------------------------
  -- update_row for:OKC_K_ITEMS_V --
  ----------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type,
    x_cimv_rec                     OUT NOCOPY cimv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cimv_rec                     cimv_rec_type := p_cimv_rec;
    l_def_cimv_rec                 cimv_rec_type;
    l_cim_rec                      cim_rec_type;
    lx_cim_rec                     cim_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_cimv_rec	IN cimv_rec_type
    ) RETURN cimv_rec_type IS
      l_cimv_rec	cimv_rec_type := p_cimv_rec;
    BEGIN

      l_cimv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_cimv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_cimv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_cimv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_cimv_rec	IN cimv_rec_type,
      x_cimv_rec	OUT NOCOPY cimv_rec_type
    ) RETURN VARCHAR2 IS
      l_cimv_rec                     cimv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('9800: Entered populate_new_record', 2);
    END IF;

      x_cimv_rec := p_cimv_rec;
      -- Get current database values
      l_cimv_rec := get_rec(p_cimv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_cimv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.id := l_cimv_rec.id;
      END IF;
      IF (x_cimv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.object_version_number := l_cimv_rec.object_version_number;
      END IF;
      IF (x_cimv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.cle_id := l_cimv_rec.cle_id;
      END IF;
      IF (x_cimv_rec.chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.chr_id := l_cimv_rec.chr_id;
      END IF;
      IF (x_cimv_rec.cle_id_for = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.cle_id_for := l_cimv_rec.cle_id_for;
      END IF;
      IF (x_cimv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.dnz_chr_id := l_cimv_rec.dnz_chr_id;
      END IF;
      IF (x_cimv_rec.object1_id1 = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.object1_id1 := l_cimv_rec.object1_id1;
      END IF;
      IF (x_cimv_rec.object1_id2 = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.object1_id2 := l_cimv_rec.object1_id2;
      END IF;
      IF (x_cimv_rec.jtot_object1_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.jtot_object1_code := l_cimv_rec.jtot_object1_code;
      END IF;
      IF (x_cimv_rec.uom_code = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.uom_code := l_cimv_rec.uom_code;
      END IF;
      IF (x_cimv_rec.exception_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.exception_yn := l_cimv_rec.exception_yn;
      END IF;
      IF (x_cimv_rec.number_of_items = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.number_of_items := l_cimv_rec.number_of_items;
      END IF;
      IF (x_cimv_rec.upg_orig_system_ref = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.upg_orig_system_ref := l_cimv_rec.upg_orig_system_ref;
      END IF;
      IF (x_cimv_rec.upg_orig_system_ref_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.upg_orig_system_ref_id := l_cimv_rec.upg_orig_system_ref_id;
      END IF;
      IF (x_cimv_rec.priced_item_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_cimv_rec.priced_item_yn := l_cimv_rec.priced_item_yn;
      END IF;
      IF (x_cimv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.created_by := l_cimv_rec.created_by;
      END IF;
      IF (x_cimv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_cimv_rec.creation_date := l_cimv_rec.creation_date;
      END IF;
      IF (x_cimv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.last_updated_by := l_cimv_rec.last_updated_by;
      END IF;
      IF (x_cimv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cimv_rec.last_update_date := l_cimv_rec.last_update_date;
      END IF;
      IF (x_cimv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.last_update_login := l_cimv_rec.last_update_login;
      END IF;
---
      IF (x_cimv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.request_id := l_cimv_rec.request_id;
      END IF;
      IF (x_cimv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.program_application_id := l_cimv_rec.program_application_id;
      END IF;
      IF (x_cimv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_cimv_rec.program_id := l_cimv_rec.program_id;
      END IF;

      IF (x_cimv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_cimv_rec.program_update_date := l_cimv_rec.program_update_date;
      END IF;


    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('9900: Leaving populate_new_record', 2);
    END IF;

      RETURN(l_return_status);

    END populate_new_record;
    --------------------------------------
    -- Set_Attributes for:OKC_K_ITEMS_V --
    --------------------------------------
    FUNCTION Set_Attributes (
      p_cimv_rec IN  cimv_rec_type,
      x_cimv_rec OUT NOCOPY cimv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_cimv_rec := p_cimv_rec;
      x_cimv_rec.OBJECT_VERSION_NUMBER := NVL(x_cimv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('10000: Entered update_row', 2);
    END IF;

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
      p_cimv_rec,                        -- IN
      l_cimv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_cimv_rec, l_def_cimv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_cimv_rec := fill_who_columns(l_def_cimv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_cimv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_cimv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_cimv_rec, l_cim_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cim_rec,
      lx_cim_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_cim_rec, l_def_cimv_rec);
    x_cimv_rec := l_def_cimv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10200: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL update_row for:CIMV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type,
    x_cimv_tbl                     OUT NOCOPY cimv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('10500: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cimv_tbl.COUNT > 0) THEN
      i := p_cimv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cimv_rec                     => p_cimv_tbl(i),
          x_cimv_rec                     => x_cimv_tbl(i));
        EXIT WHEN (i = p_cimv_tbl.LAST);
        i := p_cimv_tbl.NEXT(i);
      END LOOP;
    END IF;

  IF (l_debug = 'Y') THEN
     okc_debug.log('10600: Leaving update_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10700: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10800: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting update_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  --------------------------------
  -- delete_row for:OKC_K_ITEMS --
  --------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cim_rec                      IN cim_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ITEMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cim_rec                      cim_rec_type:= p_cim_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('11000: Entered delete_row', 2);
    END IF;

    l_return_status := OKC_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_K_ITEMS
     WHERE ID = l_cim_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11400: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  ----------------------------------
  -- delete_row for:OKC_K_ITEMS_V --
  ----------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_rec                     IN cimv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_cimv_rec                     cimv_rec_type := p_cimv_rec;
    l_cim_rec                      cim_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('11500: Entered delete_row', 2);
    END IF;

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
    migrate(l_cimv_rec, l_cim_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_cim_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

  IF (l_debug = 'Y') THEN
     okc_debug.log('11600: Leaving delete_row', 2);
     okc_debug.Reset_Indentation;
  END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11700: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11800: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('11900: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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
  -- PL/SQL TBL delete_row for:CIMV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cimv_tbl                     IN cimv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('12000: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_cimv_tbl.COUNT > 0) THEN
      i := p_cimv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_cimv_rec                     => p_cimv_tbl(i));
        EXIT WHEN (i = p_cimv_tbl.LAST);
        i := p_cimv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12200: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12300: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting delete_row:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

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

---------------------------------------------------------------
-- Procedure for mass insert in OKC_K_ITEMS table
---------------------------------------------------------------
PROCEDURE INSERT_ROW_UPG(x_return_status OUT NOCOPY VARCHAR2, p_cimv_tbl cimv_tbl_type) IS
  l_tabsize NUMBER := p_cimv_tbl.COUNT;
  l_source_lang VARCHAR2(12) := okc_util.get_userenv_lang;

  in_id                            OKC_DATATYPES.NumberTabTyp;
  in_object_version_number         OKC_DATATYPES.NumberTabTyp;
  in_cle_id                        OKC_DATATYPES.NumberTabTyp;
  in_chr_id                        OKC_DATATYPES.NumberTabTyp;
  in_cle_id_for                    OKC_DATATYPES.NumberTabTyp;
  in_dnz_chr_id                    OKC_DATATYPES.NumberTabTyp;
  in_object1_id1                   OKC_DATATYPES.Var40TabTyp;
  in_object1_id2                   OKC_DATATYPES.Var200TabTyp;
  in_jtot_object1_code             OKC_DATATYPES.Var30TabTyp;
  in_uom_code                      OKC_DATATYPES.Var3TabTyp;
  in_exception_yn                  OKC_DATATYPES.Var3TabTyp;
  in_number_of_items               OKC_DATATYPES.NumberTabTyp;
  in_upg_orig_system_ref           OKC_DATATYPES.Var75TabTyp;
  in_upg_orig_system_ref_id        OKC_DATATYPES.NumberTabTyp;
  in_priced_item_yn                OKC_DATATYPES.Var3TabTyp;
  in_created_by                    OKC_DATATYPES.NumberTabTyp;
  in_creation_date                 OKC_DATATYPES.DateTabTyp;
  in_last_updated_by               OKC_DATATYPES.NumberTabTyp;
  in_last_update_date              OKC_DATATYPES.DateTabTyp;
  in_last_update_login             OKC_DATATYPES.NumberTabTyp;
  in_request_id                    OKC_DATATYPES.NumberTabTyp;
  in_program_application_id        OKC_DATATYPES.NumberTabTyp;
  in_program_id                    OKC_DATATYPES.NumberTabTyp;
  in_program_update_date           OKC_DATATYPES.DateTabTyp;
  i                                NUMBER := p_cimv_tbl.FIRST;
  j                                NUMBEr := 0;

BEGIN
   -- Initializing return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('12500: Entered INSERT_ROW_UPG', 2);
    END IF;

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
   -- The for loop was erroring for indexes 3,4,5, the while loop
   -- along with the NEXT operator would handle the missing indexes
   -- with out causing the API to fail.
   --

  WHILE i IS NOT NULL
  LOOP

    j                               := j + 1;

    in_id                       (j) := p_cimv_tbl(i).id;
    in_object_version_number    (j) := p_cimv_tbl(i).object_version_number;
    in_cle_id                   (j) := p_cimv_tbl(i).cle_id;
    in_chr_id                   (j) := p_cimv_tbl(i).chr_id;
    in_cle_id_for               (j) := p_cimv_tbl(i).cle_id_for;
    in_dnz_chr_id               (j) := p_cimv_tbl(i).dnz_chr_id;
    in_object1_id1              (j) := p_cimv_tbl(i).object1_id1;
    in_object1_id2              (j) := p_cimv_tbl(i).object1_id2;
    in_jtot_object1_code        (j) := p_cimv_tbl(i).jtot_object1_code;
    in_uom_code                 (j) := p_cimv_tbl(i).uom_code;
    in_exception_yn             (j) := p_cimv_tbl(i).exception_yn;
    in_number_of_items          (j) := p_cimv_tbl(i).number_of_items;
    in_upg_orig_system_ref      (j) := p_cimv_tbl(i).upg_orig_system_ref;
    in_upg_orig_system_ref_id   (j) := p_cimv_tbl(i).upg_orig_system_ref_id;
    in_priced_item_yn           (j) := p_cimv_tbl(i).priced_item_yn;
    in_created_by               (j) := p_cimv_tbl(i).created_by;
    in_creation_date            (j) := p_cimv_tbl(i).creation_date;
    in_last_updated_by          (j) := p_cimv_tbl(i).last_updated_by;
    in_last_update_date         (j) := p_cimv_tbl(i).last_update_date;
    in_last_update_login        (j) := p_cimv_tbl(i).last_update_login;
    in_request_id               (j) := p_cimv_tbl(i).request_id;
    in_program_application_id   (j) := p_cimv_tbl(i).program_application_id;
    in_program_id               (j) := p_cimv_tbl(i).program_id;
    in_program_update_date      (j) := p_cimv_tbl(i).program_update_date;

    i                               := p_cimv_tbl.NEXT(i);

  END LOOP;

  FORALL i in 1..l_tabsize
    INSERT
      INTO OKC_K_ITEMS
      (
        id,
        cle_id,
        chr_id,
        cle_id_for,
        dnz_chr_id,
        object1_id1,
        object1_id2,
        jtot_object1_code,
        uom_code,
        exception_yn,
        number_of_items,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        upg_orig_system_ref,
        upg_orig_system_ref_id,
        priced_item_yn,
        request_id,
        program_application_id,
        program_id,
        program_update_date
     )
     VALUES (
        in_id(i),
        in_cle_id(i),
        in_chr_id(i),
        in_cle_id_for(i),
        in_dnz_chr_id(i),
        in_object1_id1(i),
        in_object1_id2(i),
        in_jtot_object1_code(i),
        in_uom_code(i),
        in_exception_yn(i),
        in_number_of_items(i),
        in_object_version_number(i),
        in_created_by(i),
        in_creation_date(i),
        in_last_updated_by(i),
        in_last_update_date(i),
        in_last_update_login(i),
        in_upg_orig_system_ref(i),
        in_upg_orig_system_ref_id(i),
        in_priced_item_yn(i),
        in_request_id(i),
        in_program_application_id(i),
        in_program_id(i),
        in_program_update_date(i)
     );

    IF (l_debug = 'Y') THEN
       okc_debug.log('12600: Leaving INSERT_ROW_UPG', 2);
       okc_debug.Reset_Indentation;
    END IF;

EXCEPTION
  WHEN OTHERS THEN

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
    IF (l_debug = 'Y') THEN
       okc_debug.log('12700: Exiting INSERT_ROW_UPG:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

  --  RAISE;

END INSERT_ROW_UPG;

--This function is called from versioning API OKC_VERSION_PVT
--Old Location: OKCRVERB.pls
--New Location: Base Table API

FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('12800: Entered create_version', 2);
    END IF;

INSERT INTO okc_k_items_h
  (
      major_version,
      id,
      cle_id,
      chr_id,
      cle_id_for,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      uom_code,
      exception_yn,
      number_of_items,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      priced_item_yn,
      request_id,
      program_id,
      Program_application_id,
      program_update_date
)
  SELECT
      p_major_version,
      id,
      cle_id,
      chr_id,
      cle_id_for,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      uom_code,
      exception_yn,
      number_of_items,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      priced_item_yn,
      request_id,
      program_id,
      Program_application_id,
      program_update_date
  FROM okc_k_items
WHERE dnz_chr_id = p_chr_id;


IF (l_debug = 'Y') THEN
   okc_debug.log('12900: Leaving create_version', 2);
    okc_debug.Reset_Indentation;
END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13000: Exiting create_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END create_version;

--This Function is called from Versioning API OKC_VERSION_PVT
--Old Location:OKCRVERB.pls
--New Location:Base Table API

FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_CIM_PVT');
       okc_debug.log('13100: Entered restore_version', 2);
    END IF;

INSERT INTO okc_k_items
  (
      id,
      cle_id,
      chr_id,
      cle_id_for,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      uom_code,
      exception_yn,
      number_of_items,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      priced_item_yn,
      request_id,
      program_id,
      Program_application_id,
      program_update_date
)
  SELECT
      id,
      cle_id,
      chr_id,
      cle_id_for,
      dnz_chr_id,
      object1_id1,
      object1_id2,
      jtot_object1_code,
      uom_code,
      exception_yn,
      number_of_items,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      priced_item_yn,
      request_id,
      program_id,
      Program_application_id,
      program_update_date
  FROM okc_k_items_h
WHERE dnz_chr_id = p_chr_id
  AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('13200: Leaving restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('13300: Exiting restore_version:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

       -- store SQL error message on message stack
             OKC_API.SET_MESSAGE(p_app_name     => okc_version_pvt.G_APP_NAME,
                                 p_msg_name     => okc_version_pvt.G_UNEXPECTED_ERROR,
                                 p_token1       => okc_version_pvt.G_SQLCODE_TOKEN,
                                 p_token1_value => sqlcode,
                                 p_token2       => okc_version_pvt.G_SQLERRM_TOKEN,
                                 p_token2_value => sqlerrm);

       -- notify  UNEXPECTED error
             l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
             return l_return_status;

END restore_version;

END OKC_CIM_PVT;

/
