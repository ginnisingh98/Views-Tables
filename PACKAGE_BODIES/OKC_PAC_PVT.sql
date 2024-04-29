--------------------------------------------------------
--  DDL for Package Body OKC_PAC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PAC_PVT" AS
/* $Header: OKCSPACB.pls 120.0 2005/05/26 09:55:44 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
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
  -- FUNCTION get_rec for: OKC_PRICE_ADJ_ASSOCS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pac_rec                      IN pac_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pac_rec_type IS
    CURSOR pac_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            PAT_ID_FROM,
            BSL_ID,
            CLE_ID,
            BCL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
     FROM Okc_Price_Adj_Assocs
     WHERE okc_price_adj_assocs.id = p_id;
    l_pac_pk                       pac_pk_csr%ROWTYPE;
    l_pac_rec                      pac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN pac_pk_csr (p_pac_rec.id);
    FETCH pac_pk_csr INTO
              l_pac_rec.ID,
              l_pac_rec.PAT_ID,
              l_pac_rec.PAT_ID_FROM,
              l_pac_rec.BSL_ID,
              l_pac_rec.CLE_ID,
              l_pac_rec.BCL_ID,
              l_pac_rec.CREATED_BY,
              l_pac_rec.CREATION_DATE,
              l_pac_rec.LAST_UPDATED_BY,
              l_pac_rec.LAST_UPDATE_DATE,
              l_pac_rec.LAST_UPDATE_LOGIN,
              l_pac_rec.PROGRAM_APPLICATION_ID,
              l_pac_rec.PROGRAM_ID,
              l_pac_rec.PROGRAM_UPDATE_DATE,
              l_pac_rec.REQUEST_ID,
              l_pac_rec.OBJECT_VERSION_NUMBER;
    x_no_data_found := pac_pk_csr%NOTFOUND;
    CLOSE pac_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('550: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_pac_rec);

  END get_rec;

  FUNCTION get_rec (
    p_pac_rec                      IN pac_rec_type
  ) RETURN pac_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_pac_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ADJ_ASSOCS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_pacv_rec                     IN pacv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pacv_rec_type IS
    CURSOR okc_pacv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            PAT_ID_FROM,
            BSL_ID,
            CLE_ID,
            BCL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
           PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
      FROM Okc_Price_Adj_Assocs_V
     WHERE okc_price_adj_assocs_v.id = p_id;
    l_okc_pacv_pk                  okc_pacv_pk_csr%ROWTYPE;
    l_pacv_rec                     pacv_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_pacv_pk_csr (p_pacv_rec.id);
    FETCH okc_pacv_pk_csr INTO
              l_pacv_rec.ID,
              l_pacv_rec.PAT_ID,
              l_pacv_rec.PAT_ID_FROM,
              l_pacv_rec.BSL_ID,
              l_pacv_rec.CLE_ID,
              l_pacv_rec.BCL_ID,
              l_pacv_rec.CREATED_BY,
              l_pacv_rec.CREATION_DATE,
              l_pacv_rec.LAST_UPDATED_BY,
              l_pacv_rec.LAST_UPDATE_DATE,
              l_pacv_rec.LAST_UPDATE_LOGIN,
              l_pacv_rec.PROGRAM_APPLICATION_ID,
              l_pacv_rec.PROGRAM_ID,
              l_pacv_rec.PROGRAM_UPDATE_DATE,
              l_pacv_rec.REQUEST_ID,
              l_pacv_rec.OBJECT_VERSION_NUMBER;

   x_no_data_found := okc_pacv_pk_csr%NOTFOUND;
    CLOSE okc_pacv_pk_csr;

IF (l_debug = 'Y') THEN
   okc_debug.log('800: Leaving  Fn  Get_Rec ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_pacv_rec);

  END get_rec;

  FUNCTION get_rec (
    p_pacv_rec                     IN pacv_rec_type
  ) RETURN pacv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_pacv_rec, l_row_notfound));

  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PRICE_ADJ_ASSOCS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_pacv_rec	IN pacv_rec_type
  ) RETURN pacv_rec_type IS
    l_pacv_rec	pacv_rec_type := p_pacv_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('900: Entered null_out_defaults', 2);
    END IF;

    IF (l_pacv_rec.pat_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.pat_id := NULL;
    END IF;
    IF (l_pacv_rec.pat_id_from = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.pat_id_from := NULL;
    END IF;
    IF (l_pacv_rec.bsl_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.bsl_id := NULL;
    END IF;
    IF (l_pacv_rec.cle_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.cle_id := NULL;
    END IF;
    IF (l_pacv_rec.bcl_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.bcl_id := NULL;
    END IF;
    IF (l_pacv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.created_by := NULL;
    END IF;
    IF (l_pacv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_pacv_rec.creation_date := NULL;
    END IF;
    IF (l_pacv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.last_updated_by := NULL;
    END IF;
    IF (l_pacv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_pacv_rec.last_update_date := NULL;
    END IF;
    IF (l_pacv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.last_update_login := NULL;
    END IF;
     IF (l_pacv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.program_application_id := NULL;
    END IF;
    IF (l_pacv_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.program_id := NULL;
    END IF;
  IF (l_pacv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_pacv_rec.program_update_date := NULL;
    END IF;
    IF (l_pacv_rec.request_id= OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.request_id := NULL;
      END IF;
 IF (l_pacv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_pacv_rec.object_version_number := NULL;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('1000: Leaving  null_out_defaults ', 2);
   okc_debug.Reset_Indentation;
END IF;

    RETURN(l_pacv_rec);

  END null_out_defaults;


 ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_pacv_rec          IN pacv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('1000: Entered validate_id', 2);
    END IF;

    IF p_pacv_rec.id = OKC_API.G_MISS_NUM OR
       p_pacv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1100: Leaving validate_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1200: Exiting validate_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;

 ---------------------------------------------------------------------------
  -- PROCEDURE Validate_pat_id_from
  ---------------------------------------------------------------------------

  PROCEDURE validate_pat_id_from(
    p_pacv_rec          IN pacv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('1300: Entered validate_pat_id_from', 2);
    END IF;

    IF p_pacv_rec.pat_id_from = OKC_API.G_MISS_NUM OR
       p_pacv_rec.pat_id_from IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pat_id_from');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

 IF (l_debug = 'Y') THEN
    okc_debug.log('1400: Leaving validate_pat_id_from', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_pat_id_from:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_pat_id_from;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_PRICE_ADJ_ASSOCS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_pacv_rec IN  pacv_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('1600: Entered Validate_Attributes', 2);
    END IF;

 ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
    OKC_UTIL.ADD_VIEW('OKC_PRICE_ADJ_ASSOCS_V', l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

  VALIDATE_id(p_pacv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

  VALIDATE_pat_id_from (p_pacv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Leaving Validate_Attributes', 2);
       okc_debug.Reset_Indentation;
    END IF;

   RETURN(x_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting Validate_Attributes:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      return(x_return_status);
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting Validate_Attributes:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);

   ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Ends(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------


  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_PRICE_ADJ_ASSOCS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_pacv_rec IN pacv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_pacv_rec IN pacv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_patv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_Price_Adjustments_V
       WHERE okc_price_adjustments_v.id = p_id;
      l_okc_patv_pk                  okc_patv_pk_csr%ROWTYPE;
      CURSOR okc_clev_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
       FROM Okc_K_Lines_B
       WHERE okc_k_lines_b.id     = p_id;
      l_okc_clev_pk                  okc_clev_pk_csr%ROWTYPE;
      CURSOR okc_bclv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Oks_Bill_Cont_Lines_V
       WHERE oks_bill_cont_lines_v.id = p_id;
      l_okc_bclv_pk                  okc_bclv_pk_csr%ROWTYPE;
      CURSOR oks_bslv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Oks_Bill_Sub_Lines_V
       WHERE oks_bill_sub_lines_v.id = p_id;
      l_oks_bslv_pk                  oks_bslv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN

      IF (p_pacv_rec.PAT_ID IS NOT NULL)
      THEN
        OPEN okc_patv_pk_csr(p_pacv_rec.PAT_ID);
        FETCH okc_patv_pk_csr INTO l_okc_patv_pk;
        l_row_notfound := okc_patv_pk_csr%NOTFOUND;
        CLOSE okc_patv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PAT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_pacv_rec.CLE_ID IS NOT NULL)
      THEN
        OPEN okc_clev_pk_csr(p_pacv_rec.CLE_ID);
        FETCH okc_clev_pk_csr INTO l_okc_clev_pk;
        l_row_notfound := okc_clev_pk_csr%NOTFOUND;
        CLOSE okc_clev_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_pacv_rec.BCL_ID IS NOT NULL)
      THEN
        OPEN okc_bclv_pk_csr(p_pacv_rec.BCL_ID);
        FETCH okc_bclv_pk_csr INTO l_okc_bclv_pk;
        l_row_notfound := okc_bclv_pk_csr%NOTFOUND;
        CLOSE okc_bclv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BCL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_pacv_rec.PAT_ID_FROM IS NOT NULL)
      THEN
        OPEN okc_patv_pk_csr(p_pacv_rec.PAT_ID_FROM);
        FETCH okc_patv_pk_csr INTO l_okc_patv_pk;
        l_row_notfound := okc_patv_pk_csr%NOTFOUND;
        CLOSE okc_patv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PAT_ID_FROM');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF (p_pacv_rec.BSL_ID IS NOT NULL)
      THEN
        OPEN oks_bslv_pk_csr(p_pacv_rec.BSL_ID);
        FETCH oks_bslv_pk_csr INTO l_oks_bslv_pk;
        l_row_notfound := oks_bslv_pk_csr%NOTFOUND;
        CLOSE oks_bslv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'BSL_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Leaving validate_foreign_keys', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN (l_return_status);

    EXCEPTION
      WHEN item_not_found_error THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_foreign_keys:item_not_found_error Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);

    END validate_foreign_keys;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('2300: Entered Validate_Record', 2);
    END IF;

    l_return_status := validate_foreign_keys (p_pacv_rec);


    IF (l_debug = 'Y') THEN
       okc_debug.log('2350: Leaving Validate_Record', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN pacv_rec_type,
    p_to	IN OUT NOCOPY pac_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.pat_id_from := p_from.pat_id_from;
    p_to.bsl_id := p_from.bsl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date:= p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.object_version_number := p_from.object_version_number;

  END migrate;
  PROCEDURE migrate (
    p_from	IN pac_rec_type,
    p_to	IN OUT NOCOPY pacv_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.pat_id_from := p_from.pat_id_from;
    p_to.bsl_id := p_from.bsl_id;
    p_to.cle_id := p_from.cle_id;
    p_to.bcl_id := p_from.bcl_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date:= p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.object_version_number := p_from.object_version_number;

   END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_PRICE_ADJ_ASSOCS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pacv_rec                     pacv_rec_type := p_pacv_rec;
    l_pac_rec                      pac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('2600: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_pacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_pacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('2700: Leaving validate_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2800: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('2900: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('3000: Exiting validate_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL validate_row for:PACV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('3100: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pacv_tbl.COUNT > 0) THEN
      i := p_pacv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pacv_rec                     => p_pacv_tbl(i));
        EXIT WHEN (i = p_pacv_tbl.LAST);
        i := p_pacv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('3200: Leaving validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3300: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('3400: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('3500: Exiting validate_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- insert_row for:OKC_PRICE_ADJ_ASSOCS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pac_rec                      IN pac_rec_type,
    x_pac_rec                      OUT NOCOPY pac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSOCS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pac_rec                      pac_rec_type := p_pac_rec;
    l_def_pac_rec                  pac_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ASSOCS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pac_rec IN  pac_rec_type,
      x_pac_rec OUT NOCOPY pac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pac_rec := p_pac_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('3700: Entered insert_row', 2);
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
      p_pac_rec,                         -- IN
      l_pac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PRICE_ADJ_ASSOCS(
        id,
        pat_id,
        pat_id_from,
        bsl_id,
        cle_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number)
      VALUES (
        l_pac_rec.id,
        l_pac_rec.pat_id,
        l_pac_rec.pat_id_from,
        l_pac_rec.bsl_id,
        l_pac_rec.cle_id,
        l_pac_rec.bcl_id,
        l_pac_rec.created_by,
        l_pac_rec.creation_date,
        l_pac_rec.last_updated_by,
        l_pac_rec.last_update_date,
        l_pac_rec.last_update_login,
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
       decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        l_pac_rec.object_version_number);
    -- Set OUT values
    x_pac_rec := l_pac_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('3800: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4000: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4100: Exiting insert_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- insert_row for:OKC_PRICE_ADJ_ASSOCS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pacv_rec                     pacv_rec_type;
    l_def_pacv_rec                 pacv_rec_type;
    l_pac_rec                      pac_rec_type;
    lx_pac_rec                     pac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pacv_rec	IN pacv_rec_type
    ) RETURN pacv_rec_type IS
      l_pacv_rec	pacv_rec_type := p_pacv_rec;
    BEGIN

      l_pacv_rec.CREATION_DATE := SYSDATE;
      l_pacv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pacv_rec.LAST_UPDATE_DATE := l_pacv_rec.CREATION_DATE;
      l_pacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pacv_rec);

    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ASSOCS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pacv_rec IN  pacv_rec_type,
      x_pacv_rec OUT NOCOPY pacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pacv_rec := p_pacv_rec;
      x_pacv_rec.OBJECT_VERSION_NUMBER := 1;
     RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('4400: Entered insert_row', 2);
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
    l_pacv_rec := null_out_defaults(p_pacv_rec);
    -- Set primary key value
    l_pacv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pacv_rec,                        -- IN
      l_def_pacv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pacv_rec := fill_who_columns(l_def_pacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pacv_rec, l_pac_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pac_rec,
      lx_pac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pac_rec, l_def_pacv_rec);
    -- Set OUT values
    x_pacv_rec := l_def_pacv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4600: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4700: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4800: Exiting insert_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL insert_row for:PACV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('4900: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pacv_tbl.COUNT > 0) THEN
      i := p_pacv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pacv_rec                     => p_pacv_tbl(i),
          x_pacv_rec                     => x_pacv_tbl(i));
        EXIT WHEN (i = p_pacv_tbl.LAST);
        i := p_pacv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Leaving insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5100: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5200: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('5300: Exiting insert_row:OTHERS Exception', 2);
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
  ---------------------------------------
  -- lock_row for:OKC_PRICE_ADJ_ASSOCS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pac_rec                      IN pac_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_pac_rec IN pac_rec_type) IS
    SELECT *
      FROM OKC_PRICE_ADJ_ASSOCS
     WHERE ID = p_pac_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSOCS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('5400: Entered lock_row', 2);
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

      OPEN lock_csr(p_pac_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Exiting lock_row:E_Resource_Busy Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSE
      IF (l_lock_var.ID <> p_pac_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PAT_ID <> p_pac_rec.pat_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PAT_ID_FROM <> p_pac_rec.pat_id_from) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.BSL_ID <> p_pac_rec.bsl_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CLE_ID <> p_pac_rec.cle_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.BCL_ID <> p_pac_rec.bcl_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATED_BY <> p_pac_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATION_DATE <> p_pac_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATED_BY <> p_pac_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_DATE <> p_pac_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_LOGIN <> p_pac_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
       IF (l_lock_var.PROGRAM_APPLICATION_ID <> p_pac_rec.program_application_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.PROGRAM_ID <> p_pac_rec.program_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.PROGRAM_UPDATE_DATE <> p_pac_rec.program_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.REQUEST_ID <> p_pac_rec.request_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    IF (l_lock_var.OBJECT_VERSION_NUMBER <> p_pac_rec.object_version_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('5800: Leaving lock_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6100: Exiting lock_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- lock_row for:OKC_PRICE_ADJ_ASSOCS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pac_rec                      pac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('6200: Entered lock_row', 2);
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
    migrate(p_pacv_rec, l_pac_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

 IF (l_debug = 'Y') THEN
    okc_debug.log('6300: Leaving lock_row', 2);
    okc_debug.Reset_Indentation;
 END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6400: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6500: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6600: Exiting lock_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL lock_row for:PACV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('6700: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pacv_tbl.COUNT > 0) THEN
      i := p_pacv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pacv_rec                     => p_pacv_tbl(i));
        EXIT WHEN (i = p_pacv_tbl.LAST);
        i := p_pacv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7000: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7100: Exiting lock_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- update_row for:OKC_PRICE_ADJ_ASSOCS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pac_rec                      IN pac_rec_type,
    x_pac_rec                      OUT NOCOPY pac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSOCS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pac_rec                      pac_rec_type := p_pac_rec;
    l_def_pac_rec                  pac_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pac_rec	IN pac_rec_type,
      x_pac_rec	OUT NOCOPY pac_rec_type
    ) RETURN VARCHAR2 IS
      l_pac_rec                      pac_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('7200: Entered populate_new_record', 2);
    END IF;

      x_pac_rec := p_pac_rec;
      -- Get current database values
      l_pac_rec := get_rec(p_pac_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pac_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.id := l_pac_rec.id;
      END IF;
      IF (x_pac_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.pat_id := l_pac_rec.pat_id;
      END IF;
      IF (x_pac_rec.pat_id_from = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.pat_id_from := l_pac_rec.pat_id_from;
      END IF;
      IF (x_pac_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.bsl_id := l_pac_rec.bsl_id;
      END IF;
      IF (x_pac_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.cle_id := l_pac_rec.cle_id;
      END IF;
      IF (x_pac_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.bcl_id := l_pac_rec.bcl_id;
      END IF;
      IF (x_pac_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.created_by := l_pac_rec.created_by;
      END IF;
      IF (x_pac_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pac_rec.creation_date := l_pac_rec.creation_date;
      END IF;
      IF (x_pac_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.last_updated_by := l_pac_rec.last_updated_by;
      END IF;
      IF (x_pac_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pac_rec.last_update_date := l_pac_rec.last_update_date;
      END IF;
      IF (x_pac_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.last_update_login := l_pac_rec.last_update_login;
      END IF;
   IF (x_pac_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.program_application_id := l_pac_rec.program_application_id;
      END IF;
   IF (x_pac_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.program_id := l_pac_rec.program_id;
      END IF;
   IF (x_pac_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pac_rec.program_update_date := l_pac_rec.program_update_date;
      END IF;
   IF (x_pac_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.request_id := l_pac_rec.request_id;
      END IF;
   IF (x_pac_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pac_rec.object_version_number := l_pac_rec.object_version_number;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('7300: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

 RETURN(l_return_status);

    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ASSOCS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_pac_rec IN  pac_rec_type,
      x_pac_rec OUT NOCOPY pac_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pac_rec := p_pac_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('7400: Entered update_row', 2);
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
      p_pac_rec,                         -- IN
      l_pac_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pac_rec, l_def_pac_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PRICE_ADJ_ASSOCS
    SET PAT_ID = l_def_pac_rec.pat_id,
        PAT_ID_FROM = l_def_pac_rec.pat_id_from,
        BSL_ID = l_def_pac_rec.bsl_id,
        CLE_ID = l_def_pac_rec.cle_id,
        BCL_ID = l_def_pac_rec.bcl_id,
        CREATED_BY = l_def_pac_rec.created_by,
        CREATION_DATE = l_def_pac_rec.creation_date,
        LAST_UPDATED_BY = l_def_pac_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_pac_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_pac_rec.last_update_login,
REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_pac_rec.request_id),
PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_pac_rec.program_application_id),
PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_pac_rec.program_id),
PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_pac_rec.program_update_date,SYSDATE),

   OBJECT_VERSION_NUMBER = l_def_pac_rec.object_version_number
 WHERE ID = l_def_pac_rec.id;

    x_pac_rec := l_def_pac_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('7500: Leaving update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7800: Exiting update_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- update_row for:OKC_PRICE_ADJ_ASSOCS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type,
    x_pacv_rec                     OUT NOCOPY pacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pacv_rec                     pacv_rec_type := p_pacv_rec;
    l_def_pacv_rec                 pacv_rec_type;
    l_pac_rec                      pac_rec_type;
    lx_pac_rec                     pac_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pacv_rec	IN pacv_rec_type
    ) RETURN pacv_rec_type IS
      l_pacv_rec	pacv_rec_type := p_pacv_rec;
    BEGIN

      l_pacv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pacv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pacv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_pacv_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pacv_rec	IN pacv_rec_type,
      x_pacv_rec	OUT NOCOPY pacv_rec_type
    ) RETURN VARCHAR2 IS
      l_pacv_rec                     pacv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('8000: Entered populate_new_record', 2);
    END IF;

      x_pacv_rec := p_pacv_rec;
      -- Get current database values
      l_pacv_rec := get_rec(p_pacv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_pacv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.id := l_pacv_rec.id;
      END IF;
      IF (x_pacv_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.pat_id := l_pacv_rec.pat_id;
      END IF;
      IF (x_pacv_rec.pat_id_from = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.pat_id_from := l_pacv_rec.pat_id_from;
      END IF;
      IF (x_pacv_rec.bsl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.bsl_id := l_pacv_rec.bsl_id;
      END IF;
      IF (x_pacv_rec.cle_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.cle_id := l_pacv_rec.cle_id;
      END IF;
      IF (x_pacv_rec.bcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.bcl_id := l_pacv_rec.bcl_id;
      END IF;
      IF (x_pacv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.created_by := l_pacv_rec.created_by;
      END IF;
      IF (x_pacv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_pacv_rec.creation_date := l_pacv_rec.creation_date;
      END IF;
      IF (x_pacv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.last_updated_by := l_pacv_rec.last_updated_by;
      END IF;
      IF (x_pacv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pacv_rec.last_update_date := l_pacv_rec.last_update_date;
      END IF;
      IF (x_pacv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.last_update_login := l_pacv_rec.last_update_login;
      END IF;
    IF (x_pacv_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.program_application_id := l_pacv_rec.program_application_id;
      END IF;
     IF (x_pacv_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.program_id := l_pacv_rec.program_id;
      END IF;
     IF (x_pacv_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_pacv_rec.program_update_date := l_pacv_rec.program_update_date;
      END IF;
    IF (x_pacv_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.request_id := l_pacv_rec.request_id;
      END IF;
      IF (x_pacv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_pacv_rec.object_version_number := l_pacv_rec.object_version_number;
      END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_return_status);

    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ASSOCS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_pacv_rec IN  pacv_rec_type,
      x_pacv_rec OUT NOCOPY pacv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_pacv_rec := p_pacv_rec;
      x_pacv_rec.OBJECT_VERSION_NUMBER := NVL(x_pacv_rec.OBJECT_VERSION_NUMBER,0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('8200: Entered update_row', 2);
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
      p_pacv_rec,                        -- IN
      l_pacv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_pacv_rec, l_def_pacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_pacv_rec := fill_who_columns(l_def_pacv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pacv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_pacv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_pacv_rec, l_pac_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pac_rec,
      lx_pac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_pac_rec, l_def_pacv_rec);
    x_pacv_rec := l_def_pacv_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8300: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8400: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8500: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8600: Exiting update_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL update_row for:PACV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type,
    x_pacv_tbl                     OUT NOCOPY pacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('8700: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pacv_tbl.COUNT > 0) THEN
      i := p_pacv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pacv_rec                     => p_pacv_tbl(i),
          x_pacv_rec                     => x_pacv_tbl(i));
        EXIT WHEN (i = p_pacv_tbl.LAST);
        i := p_pacv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Leaving update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8900: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9000: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9100: Exiting update_row:OTHERS Exception', 2);
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
  -----------------------------------------
  -- delete_row for:OKC_PRICE_ADJ_ASSOCS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pac_rec                      IN pac_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ASSOCS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pac_rec                      pac_rec_type:= p_pac_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('9200: Entered delete_row', 2);
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
    DELETE FROM OKC_PRICE_ADJ_ASSOCS
     WHERE ID = l_pac_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9300: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9600: Exiting delete_row:OTHERS Exception', 2);
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
  -------------------------------------------
  -- delete_row for:OKC_PRICE_ADJ_ASSOCS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_rec                     IN pacv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_pacv_rec                     pacv_rec_type := p_pacv_rec;
    l_pac_rec                      pac_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('9700: Entered delete_row', 2);
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
    migrate(l_pacv_rec, l_pac_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_pac_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('9800: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9900: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10000: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10100: Exiting delete_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL delete_row for:PACV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pacv_tbl                     IN pacv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('10200: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_pacv_tbl.COUNT > 0) THEN
      i := p_pacv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pacv_rec                     => p_pacv_tbl(i));
        EXIT WHEN (i = p_pacv_tbl.LAST);
        i := p_pacv_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10300: Leaving delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10400: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10500: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10600: Exiting delete_row:OTHERS Exception', 2);
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

  FUNCTION create_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('10700: Entered create_version', 2);
    END IF;

  INSERT INTO okc_price_adj_assocs_h
  (
      id,
        pat_id,
        pat_id_from,
        bsl_id,
        cle_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number,
       major_version)
   SELECT
        id,
        pat_id,
        pat_id_from,
        bsl_id,
        cle_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number,
       p_major_version

     FROM okc_price_adj_assocs
WHERE pat_id_from IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             );

IF (l_debug = 'Y') THEN
   okc_debug.log('10800: Leaving create_version', 2);
   okc_debug.Reset_Indentation;
END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10900: Exiting create_version:OTHERS Exception', 2);
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


FUNCTION restore_version(
             p_chr_id         IN NUMBER,
             p_major_version  IN NUMBER
           ) RETURN VARCHAR2 IS

  l_return_status VARCHAR2(1):= OKC_API.G_RET_STS_SUCCESS;

BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAC_PVT');
       okc_debug.log('11000: Entered restore_version', 2);
    END IF;

INSERT INTO okc_price_adj_assocs
   (
    id,
        pat_id,
        pat_id_from,
        bsl_id,
        cle_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number
         )
   SELECT
        id,
        pat_id,
        pat_id_from,
        bsl_id,
        cle_id,
        bcl_id,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
        object_version_number
FROM okc_price_adj_assocs_h
 WHERE pat_id_from IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             )
 AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Leaving restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11200: Exiting restore_version:OTHERS Exception', 2);
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

END OKC_PAC_PVT;

/
