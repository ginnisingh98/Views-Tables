--------------------------------------------------------
--  DDL for Package Body OKC_PAA_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PAA_PVT" AS
/* $Header: OKCSPAAB.pls 120.0 2005/05/27 05:17:12 appldev noship $ */

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
  -- FUNCTION get_rec for: OKC_PRICE_ADJ_ATTRIBS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_paa_rec                      IN paa_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN paa_rec_type IS
    CURSOR paa_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            FLEX_TITLE,
            PRICING_CONTEXT,
            PRICING_ATTRIBUTE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PRICING_ATTR_VALUE_FROM,
            PRICING_ATTR_VALUE_TO,
            COMPARISON_OPERATOR,
            LAST_UPDATE_LOGIN,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
           OBJECT_VERSION_NUMBER
       FROM Okc_Price_Adj_Attribs
     WHERE okc_price_adj_attribs.id = p_id;
    l_paa_pk                       paa_pk_csr%ROWTYPE;
    l_paa_rec                      paa_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('500: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN paa_pk_csr (p_paa_rec.id);
    FETCH paa_pk_csr INTO
              l_paa_rec.ID,
              l_paa_rec.PAT_ID,
              l_paa_rec.FLEX_TITLE,
              l_paa_rec.PRICING_CONTEXT,
              l_paa_rec.PRICING_ATTRIBUTE,
              l_paa_rec.CREATED_BY,
              l_paa_rec.CREATION_DATE,
              l_paa_rec.LAST_UPDATED_BY,
              l_paa_rec.LAST_UPDATE_DATE,
              l_paa_rec.PRICING_ATTR_VALUE_FROM,
              l_paa_rec.PRICING_ATTR_VALUE_TO,
              l_paa_rec.COMPARISON_OPERATOR,
              l_paa_rec.LAST_UPDATE_LOGIN,
              l_paa_rec.PROGRAM_APPLICATION_ID,
              l_paa_rec.PROGRAM_ID,
              l_paa_rec.PROGRAM_UPDATE_DATE,
              l_paa_rec.REQUEST_ID,
              l_paa_rec.OBJECT_VERSION_NUMBER;
       x_no_data_found := paa_pk_csr%NOTFOUND;
    CLOSE paa_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Leaving Get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_paa_rec);

  END get_rec;

  FUNCTION get_rec (
    p_paa_rec                      IN paa_rec_type
  ) RETURN paa_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_paa_rec, l_row_notfound));

  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PRICE_ADJ_ATTRIBS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_paav_rec                     IN paav_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN paav_rec_type IS
    CURSOR okc_paav_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            PAT_ID,
            FLEX_TITLE,
            PRICING_CONTEXT,
            PRICING_ATTRIBUTE,
            PRICING_ATTR_VALUE_FROM,
            PRICING_ATTR_VALUE_TO,
            COMPARISON_OPERATOR,
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
        FROM Okc_Price_Adj_Attribs_V
     WHERE okc_price_adj_attribs_v.id = p_id;
    l_okc_paav_pk                  okc_paav_pk_csr%ROWTYPE;
    l_paav_rec                     paav_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('700: Entered get_rec', 2);
    END IF;

    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_paav_pk_csr (p_paav_rec.id);
    FETCH okc_paav_pk_csr INTO
              l_paav_rec.ID,
              l_paav_rec.PAT_ID,
              l_paav_rec.FLEX_TITLE,
              l_paav_rec.PRICING_CONTEXT,
              l_paav_rec.PRICING_ATTRIBUTE,
              l_paav_rec.PRICING_ATTR_VALUE_FROM,
              l_paav_rec.PRICING_ATTR_VALUE_TO,
              l_paav_rec.COMPARISON_OPERATOR,
              l_paav_rec.CREATED_BY,
              l_paav_rec.CREATION_DATE,
              l_paav_rec.LAST_UPDATED_BY,
              l_paav_rec.LAST_UPDATE_DATE,
              l_paav_rec.LAST_UPDATE_LOGIN,
             l_paav_rec.PROGRAM_APPLICATION_ID,
              l_paav_rec.PROGRAM_ID,
              l_paav_rec.PROGRAM_UPDATE_DATE,
              l_paav_rec.REQUEST_ID,
              l_paav_rec.OBJECT_VERSION_NUMBER;
         x_no_data_found := okc_paav_pk_csr%NOTFOUND;
    CLOSE okc_paav_pk_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('800: Leaving Get_rec ', 2);
       okc_debug.Reset_Indentation;
    END IF;

    RETURN(l_paav_rec);

  END get_rec;

  FUNCTION get_rec (
    p_paav_rec                     IN paav_rec_type
  ) RETURN paav_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    RETURN(get_rec(p_paav_rec, l_row_notfound));

  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PRICE_ADJ_ATTRIBS_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_paav_rec	IN paav_rec_type
  ) RETURN paav_rec_type IS
    l_paav_rec	paav_rec_type := p_paav_rec;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('900: Entered null_out_defaults', 2);
    END IF;

    IF (l_paav_rec.pat_id = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.pat_id := NULL;
    END IF;
    IF (l_paav_rec.flex_title = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.flex_title := NULL;
    END IF;
    IF (l_paav_rec.pricing_context = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.pricing_context := NULL;
    END IF;
    IF (l_paav_rec.pricing_attribute = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.pricing_attribute := NULL;
    END IF;
    IF (l_paav_rec.pricing_attr_value_from = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.pricing_attr_value_from := NULL;
    END IF;
    IF (l_paav_rec.pricing_attr_value_to = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.pricing_attr_value_to := NULL;
    END IF;
    IF (l_paav_rec.comparison_operator = OKC_API.G_MISS_CHAR) THEN
      l_paav_rec.comparison_operator := NULL;
    END IF;
    IF (l_paav_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.created_by := NULL;
    END IF;
    IF (l_paav_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_paav_rec.creation_date := NULL;
    END IF;
    IF (l_paav_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.last_updated_by := NULL;
    END IF;
    IF (l_paav_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_paav_rec.last_update_date := NULL;
    END IF;
    IF (l_paav_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.last_update_login := NULL;
    END IF;
        IF (l_paav_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.program_application_id := NULL;
    END IF;
    IF (l_paav_rec.program_id = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.program_id := NULL;
    END IF;
  IF (l_paav_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
      l_paav_rec.program_update_date := NULL;
    END IF;
    IF (l_paav_rec.request_id= OKC_API.G_MISS_NUM) THEN
      l_paav_rec.request_id := NULL;
      END IF;
 IF (l_paav_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_paav_rec.object_version_number := NULL;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('950: Leaving null_out_defaults', 2);
       okc_debug.Reset_Indentation;
    END IF;

      RETURN(l_paav_rec);

  END null_out_defaults;



   ---------------------------------------------------------------------------------------
  --Attribute Level Validattion Procedures Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_id(
    p_paav_rec          IN paav_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('1000: Entered validate_id', 2);
    END IF;

    IF p_paav_rec.id = OKC_API.G_MISS_NUM OR
       p_paav_rec.id IS NULL
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
       okc_debug.log('1200: Leaving validate_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_id;



    PROCEDURE validate_pat_id(
    p_paav_rec          IN paav_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('1300: Entered validate_pat_id', 2);
    END IF;

    IF p_paav_rec.pat_id = OKC_API.G_MISS_NUM OR
       p_paav_rec.pat_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pat_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1400: Exiting validate_pat_id', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1500: Exiting validate_pat_id:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_pat_id;

     ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_flex_title(
    p_paav_rec          IN paav_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('1600: Entered validate_flex_title', 2);
    END IF;

    IF p_paav_rec.flex_title = OKC_API.G_MISS_CHAR OR
       p_paav_rec.flex_title IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'flex_title');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('1700: Exiting validate_flex_title', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1800: Exiting validate_flex_title:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      x_return_status := l_return_status;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('1900: Exiting validate_flex_title:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_flex_title;


   ---------------------------------------------------------------------------
  -- PROCEDURE Validate_pricing_context
  ---------------------------------------------------------------------------
  PROCEDURE validate_pricing_context(
    p_paav_rec          IN paav_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('2000: Entered validate_pricing_context', 2);
    END IF;

    IF p_paav_rec.pricing_context = OKC_API.G_MISS_CHAR OR
       p_paav_rec.pricing_context IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pricing_context');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2100: Exiting validate_pricing_context', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2200: Exiting validate_pricing_context:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      x_return_status := l_return_status;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2300: Exiting validate_pricing_context:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_pricing_context;



    ---------------------------------------------------------------------------
  -- PROCEDURE Validate_pricing_attribute
  ---------------------------------------------------------------------------
  PROCEDURE validate_pricing_attribute(
    p_paav_rec          IN paav_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('2400: Entered validate_pricing_attribute', 2);
    END IF;

    IF p_paav_rec.pricing_attribute = OKC_API.G_MISS_CHAR OR
       p_paav_rec.pricing_attribute IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pricing_attribute');
      l_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    x_return_status := l_return_status;

    IF (l_debug = 'Y') THEN
       okc_debug.log('2500: Exiting validate_pricing_attribute', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2600: Exiting validate_pricing_attribute:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      x_return_status := l_return_status;
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('2700: Exiting validate_pricing_attribute:OTHERS Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      -- store SQL error message on message stack for caller
      OKC_API.set_message(G_APP_NAME, G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

  END validate_pricing_attribute;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------------
  -- Validate_Attributes for:OKC_PRICE_ADJ_ATTRIBS_V --
  -----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_paav_rec IN  paav_rec_type
  ) RETURN VARCHAR2 IS
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('2800: Entered Validate_Attributes', 2);
    END IF;

     ---------------------------------------------------------------------------------------
  --Attribute Level Validation Procedure Calls Starts(Modification on TAPI generated Code.)--
  ---------------------------------------------------------------------------------------

    VALIDATE_id(p_paav_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

  VALIDATE_pat_id(p_paav_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   VALIDATE_flex_title(p_paav_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   VALIDATE_pricing_context(p_paav_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   VALIDATE_pricing_attribute(p_paav_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('2900: Exiting Validate_Attributes', 2);
   okc_debug.Reset_Indentation;
END IF;

  RETURN(x_return_status);

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3000: Exiting Validate_Attributes:G_EXCEPTION_HALT_VALIDATION Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

      return(x_return_status);
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3100: Exiting Validate_Attributes:OTHERS Exception', 2);
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
  -------------------------------------------------
  -- Validate_Record for:OKC_PRICE_ADJ_ATTRIBS_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_paav_rec IN paav_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_paav_rec IN paav_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error          EXCEPTION;
      CURSOR okc_patv_pk_csr (p_id                 IN NUMBER) IS
      SELECT
              'x'
        FROM Okc_Price_Adjustments_V
       WHERE okc_price_adjustments_v.id = p_id;
      l_okc_patv_pk                  okc_patv_pk_csr%ROWTYPE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('3200: Entered validate_foreign_keys', 2);
    END IF;

      IF (p_paav_rec.PAT_ID IS NOT NULL)
      THEN
        OPEN okc_patv_pk_csr(p_paav_rec.PAT_ID);
        FETCH okc_patv_pk_csr INTO l_okc_patv_pk;
        l_row_notfound := okc_patv_pk_csr%NOTFOUND;
        CLOSE okc_patv_pk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PAT_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('3300: Exiting validate_foreign_keys', 2);
   okc_debug.Reset_Indentation;
END IF;

      RETURN (l_return_status);

    EXCEPTION
      WHEN item_not_found_error THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('3400: Exiting validate_foreign_keys:item_not_found_error Exception', 2);
       okc_debug.Reset_Indentation;
    END IF;

        l_return_status := OKC_API.G_RET_STS_ERROR;
        RETURN (l_return_status);

    END validate_foreign_keys;
  BEGIN

    l_return_status := validate_foreign_keys (p_paav_rec);
    RETURN (l_return_status);

  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN paav_rec_type,
    p_to	IN OUT NOCOPY paa_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.flex_title := p_from.flex_title;
    p_to.pricing_context := p_from.pricing_context;
    p_to.pricing_attribute := p_from.pricing_attribute;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.pricing_attr_value_from := p_from.pricing_attr_value_from;
    p_to.pricing_attr_value_to := p_from.pricing_attr_value_to;
    p_to.comparison_operator := p_from.comparison_operator;
    p_to.last_update_login := p_from.last_update_login;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date:= p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.object_version_number := p_from.object_version_number;

 END migrate;

  PROCEDURE migrate (
    p_from	IN paa_rec_type,
    p_to	IN OUT NOCOPY paav_rec_type
  ) IS
  BEGIN

    p_to.id := p_from.id;
    p_to.pat_id := p_from.pat_id;
    p_to.flex_title := p_from.flex_title;
    p_to.pricing_context := p_from.pricing_context;
    p_to.pricing_attribute := p_from.pricing_attribute;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.pricing_attr_value_from := p_from.pricing_attr_value_from;
    p_to.pricing_attr_value_to := p_from.pricing_attr_value_to;
    p_to.comparison_operator := p_from.comparison_operator;
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
  ----------------------------------------------
  -- validate_row for:OKC_PRICE_ADJ_ATTRIBS_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paav_rec                     paav_rec_type := p_paav_rec;
    l_paa_rec                      paa_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('3800: Entered validate_row', 2);
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
    l_return_status := Validate_Attributes(l_paav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_paav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('3900: Exiting validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4000: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4100: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4200: Exiting validate_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL validate_row for:PAAV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('4300: Entered validate_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_paav_tbl.COUNT > 0) THEN
      i := p_paav_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_paav_rec                     => p_paav_tbl(i));
        EXIT WHEN (i = p_paav_tbl.LAST);
        i := p_paav_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('4400: Exiting validate_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('4500: Exiting validate_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('4600: Exiting validate_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('4700: Exiting validate_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- insert_row for:OKC_PRICE_ADJ_ATTRIBS --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paa_rec                      IN paa_rec_type,
    x_paa_rec                      OUT NOCOPY paa_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ATTRIBS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paa_rec                      paa_rec_type := p_paa_rec;
    l_def_paa_rec                  paa_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ATTRIBS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_paa_rec IN  paa_rec_type,
      x_paa_rec OUT NOCOPY paa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_paa_rec := p_paa_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('4900: Entered insert_row', 2);
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
      p_paa_rec,                         -- IN
      l_paa_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PRICE_ADJ_ATTRIBS(
        id,
        pat_id,
        flex_title,
        pricing_context,
        pricing_attribute,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number)
      VALUES (
        l_paa_rec.id,
        l_paa_rec.pat_id,
        l_paa_rec.flex_title,
        l_paa_rec.pricing_context,
        l_paa_rec.pricing_attribute,
        l_paa_rec.created_by,
        l_paa_rec.creation_date,
        l_paa_rec.last_updated_by,
        l_paa_rec.last_update_date,
        l_paa_rec.pricing_attr_value_from,
        l_paa_rec.pricing_attr_value_to,
        l_paa_rec.comparison_operator,
        l_paa_rec.last_update_login,
        decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),
        decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),
        decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),
        l_paa_rec.object_version_number);
 -- Set OUT values
    x_paa_rec := l_paa_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5000: Exiting insert_row', 2);
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
  --------------------------------------------
  -- insert_row for:OKC_PRICE_ADJ_ATTRIBS_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paav_rec                     paav_rec_type;
    l_def_paav_rec                 paav_rec_type;
    l_paa_rec                      paa_rec_type;
    lx_paa_rec                     paa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_paav_rec	IN paav_rec_type
    ) RETURN paav_rec_type IS
      l_paav_rec	paav_rec_type := p_paav_rec;
    BEGIN

      l_paav_rec.CREATION_DATE := SYSDATE;
      l_paav_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_paav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_paav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_paav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;

      RETURN(l_paav_rec);

    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ATTRIBS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_paav_rec IN  paav_rec_type,
      x_paav_rec OUT NOCOPY paav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_paav_rec := p_paav_rec;
      x_paav_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('5600: Entered insert_row', 2);
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
    l_paav_rec := null_out_defaults(p_paav_rec);
    -- Set primary key value
    l_paav_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_paav_rec,                        -- IN
      l_def_paav_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_paav_rec := fill_who_columns(l_def_paav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_paav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_paav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_paav_rec, l_paa_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_paa_rec,
      lx_paa_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_paa_rec, l_def_paav_rec);
    -- Set OUT values
    x_paav_rec := l_def_paav_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('5700: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('5800: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('5900: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6000: Exiting insert_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL insert_row for:PAAV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('6100: Entered insert_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_paav_tbl.COUNT > 0) THEN
      i := p_paav_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_paav_rec                     => p_paav_tbl(i),
          x_paav_rec                     => x_paav_tbl(i));
        EXIT WHEN (i = p_paav_tbl.LAST);
        i := p_paav_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6200: Exiting insert_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6300: Exiting insert_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('6400: Exiting insert_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('6500: Exiting insert_row:OTHERS Exception', 2);
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
  ----------------------------------------
  -- lock_row for:OKC_PRICE_ADJ_ATTRIBS --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paa_rec                      IN paa_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_paa_rec IN paa_rec_type) IS
    SELECT *
      FROM OKC_PRICE_ADJ_ATTRIBS
     WHERE ID = p_paa_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ATTRIBS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('6600: Entered lock_row', 2);
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
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('6700: Entered lock_row', 2);
    END IF;

      OPEN lock_csr(p_paa_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;

    IF (l_debug = 'Y') THEN
       okc_debug.log('6800: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

    EXCEPTION
      WHEN E_Resource_Busy THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('6900: Exiting lock_row:E_Resource_Busy Exception', 2);
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
      IF (l_lock_var.ID <> p_paa_rec.id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PAT_ID <> p_paa_rec.pat_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.FLEX_TITLE <> p_paa_rec.flex_title) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PRICING_CONTEXT <> p_paa_rec.pricing_context) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PRICING_ATTRIBUTE <> p_paa_rec.pricing_attribute) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATED_BY <> p_paa_rec.created_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.CREATION_DATE <> p_paa_rec.creation_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATED_BY <> p_paa_rec.last_updated_by) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_DATE <> p_paa_rec.last_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PRICING_ATTR_VALUE_FROM <> p_paa_rec.pricing_attr_value_from) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.PRICING_ATTR_VALUE_TO <> p_paa_rec.pricing_attr_value_to) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.COMPARISON_OPERATOR <> p_paa_rec.comparison_operator) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
      IF (l_lock_var.LAST_UPDATE_LOGIN <> p_paa_rec.last_update_login) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
     IF (l_lock_var.PROGRAM_APPLICATION_ID <> p_paa_rec.program_application_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.PROGRAM_ID <> p_paa_rec.program_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.PROGRAM_UPDATE_DATE <> p_paa_rec.program_update_date) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
   IF (l_lock_var.REQUEST_ID <> p_paa_rec.request_id) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
    IF (l_lock_var.OBJECT_VERSION_NUMBER <> p_paa_rec.object_version_number) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
     END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7000: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7300: Exiting lock_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- lock_row for:OKC_PRICE_ADJ_ATTRIBS_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paa_rec                      paa_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('7400: Entered lock_row', 2);
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
    migrate(p_paav_rec, l_paa_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_paa_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('7500: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('7600: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('7700: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('7800: Exiting lock_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL lock_row for:PAAV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('7900: Entered lock_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_paav_tbl.COUNT > 0) THEN
      i := p_paav_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_paav_rec                     => p_paav_tbl(i));
        EXIT WHEN (i = p_paav_tbl.LAST);
        i := p_paav_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('8000: Leaving lock_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8100: Exiting lock_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8200: Exiting lock_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('8300: Exiting lock_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- update_row for:OKC_PRICE_ADJ_ATTRIBS --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paa_rec                      IN paa_rec_type,
    x_paa_rec                      OUT NOCOPY paa_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ATTRIBS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paa_rec                      paa_rec_type := p_paa_rec;
    l_def_paa_rec                  paa_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_paa_rec	IN paa_rec_type,
      x_paa_rec	OUT NOCOPY paa_rec_type
    ) RETURN VARCHAR2 IS
      l_paa_rec                      paa_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('8400: Entered populate_new_record', 2);
    END IF;

      x_paa_rec := p_paa_rec;
      -- Get current database values
      l_paa_rec := get_rec(p_paa_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_paa_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.id := l_paa_rec.id;
      END IF;
      IF (x_paa_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.pat_id := l_paa_rec.pat_id;
      END IF;
      IF (x_paa_rec.flex_title = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.flex_title := l_paa_rec.flex_title;
      END IF;
      IF (x_paa_rec.pricing_context = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.pricing_context := l_paa_rec.pricing_context;
      END IF;
      IF (x_paa_rec.pricing_attribute = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.pricing_attribute := l_paa_rec.pricing_attribute;
      END IF;
      IF (x_paa_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.created_by := l_paa_rec.created_by;
      END IF;
      IF (x_paa_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_paa_rec.creation_date := l_paa_rec.creation_date;
      END IF;
      IF (x_paa_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.last_updated_by := l_paa_rec.last_updated_by;
      END IF;
      IF (x_paa_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_paa_rec.last_update_date := l_paa_rec.last_update_date;
      END IF;
      IF (x_paa_rec.pricing_attr_value_from = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.pricing_attr_value_from := l_paa_rec.pricing_attr_value_from;
      END IF;
      IF (x_paa_rec.pricing_attr_value_to = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.pricing_attr_value_to := l_paa_rec.pricing_attr_value_to;
      END IF;
      IF (x_paa_rec.comparison_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_paa_rec.comparison_operator := l_paa_rec.comparison_operator;
      END IF;
      IF (x_paa_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.last_update_login := l_paa_rec.last_update_login;
      END IF;
   IF (x_paa_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.program_application_id := l_paa_rec.program_application_id;
      END IF;
   IF (x_paa_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.program_id := l_paa_rec.program_id;
      END IF;
   IF (x_paa_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_paa_rec.program_update_date := l_paa_rec.program_update_date;
      END IF;
   IF (x_paa_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.request_id := l_paa_rec.request_id;
      END IF;
   IF (x_paa_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_paa_rec.object_version_number := l_paa_rec.object_version_number;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('8500 : Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

     RETURN(l_return_status);

    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ATTRIBS --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_paa_rec IN  paa_rec_type,
      x_paa_rec OUT NOCOPY paa_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_paa_rec := p_paa_rec;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('8600: Entered update_row', 2);
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
      p_paa_rec,                         -- IN
      l_paa_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_paa_rec, l_def_paa_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_PRICE_ADJ_ATTRIBS
    SET PAT_ID = l_def_paa_rec.pat_id,
        FLEX_TITLE = l_def_paa_rec.flex_title,
        PRICING_CONTEXT = l_def_paa_rec.pricing_context,
        PRICING_ATTRIBUTE = l_def_paa_rec.pricing_attribute,
        CREATED_BY = l_def_paa_rec.created_by,
        CREATION_DATE = l_def_paa_rec.creation_date,
        LAST_UPDATED_BY = l_def_paa_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_paa_rec.last_update_date,
        PRICING_ATTR_VALUE_FROM = l_def_paa_rec.pricing_attr_value_from,
        PRICING_ATTR_VALUE_TO = l_def_paa_rec.pricing_attr_value_to,
        COMPARISON_OPERATOR = l_def_paa_rec.comparison_operator,
        LAST_UPDATE_LOGIN = l_def_paa_rec.last_update_login,
 REQUEST_ID = NVL(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,FND_GLOBAL.CONC_REQUEST_ID),l_def_paa_rec.request_id),
 PROGRAM_APPLICATION_ID = NVL(decode(FND_GLOBAL.PROG_APPL_ID,-1,NULL,FND_GLOBAL.PROG_APPL_ID),l_def_paa_rec.program_application_id),
PROGRAM_ID = NVL(decode(FND_GLOBAL.CONC_PROGRAM_ID,-1,NULL,FND_GLOBAL.CONC_PROGRAM_ID),l_def_paa_rec.program_id),
PROGRAM_UPDATE_DATE = decode(decode(FND_GLOBAL.CONC_REQUEST_ID,-1,NULL,SYSDATE),NULL,l_def_paa_rec.program_update_date,SYSDATE),
   OBJECT_VERSION_NUMBER = l_def_paa_rec.object_version_number
       WHERE ID = l_def_paa_rec.id;

    x_paa_rec := l_def_paa_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('8700: Exiting update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('8800: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('8900: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9000: Exiting update_row:OTHERS Exception', 2);
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
  --------------------------------------------
  -- update_row for:OKC_PRICE_ADJ_ATTRIBS_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type,
    x_paav_rec                     OUT NOCOPY paav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paav_rec                     paav_rec_type := p_paav_rec;
    l_def_paav_rec                 paav_rec_type;
    l_paa_rec                      paa_rec_type;
    lx_paa_rec                     paa_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_paav_rec	IN paav_rec_type
    ) RETURN paav_rec_type IS
      l_paav_rec	paav_rec_type := p_paav_rec;
    BEGIN

      l_paav_rec.LAST_UPDATE_DATE := SYSDATE;
      l_paav_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_paav_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_paav_rec);

    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_paav_rec	IN paav_rec_type,
      x_paav_rec	OUT NOCOPY paav_rec_type
    ) RETURN VARCHAR2 IS
      l_paav_rec                     paav_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('9200: Entered populate_new_record', 2);
    END IF;

      x_paav_rec := p_paav_rec;
      -- Get current database values
      l_paav_rec := get_rec(p_paav_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_paav_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.id := l_paav_rec.id;
      END IF;
      IF (x_paav_rec.pat_id = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.pat_id := l_paav_rec.pat_id;
      END IF;
      IF (x_paav_rec.flex_title = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.flex_title := l_paav_rec.flex_title;
      END IF;
      IF (x_paav_rec.pricing_context = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.pricing_context := l_paav_rec.pricing_context;
      END IF;
      IF (x_paav_rec.pricing_attribute = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.pricing_attribute := l_paav_rec.pricing_attribute;
      END IF;
      IF (x_paav_rec.pricing_attr_value_from = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.pricing_attr_value_from := l_paav_rec.pricing_attr_value_from;
      END IF;
      IF (x_paav_rec.pricing_attr_value_to = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.pricing_attr_value_to := l_paav_rec.pricing_attr_value_to;
      END IF;
      IF (x_paav_rec.comparison_operator = OKC_API.G_MISS_CHAR)
      THEN
        x_paav_rec.comparison_operator := l_paav_rec.comparison_operator;
      END IF;
      IF (x_paav_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.created_by := l_paav_rec.created_by;
      END IF;
      IF (x_paav_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_paav_rec.creation_date := l_paav_rec.creation_date;
      END IF;
      IF (x_paav_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.last_updated_by := l_paav_rec.last_updated_by;
      END IF;
      IF (x_paav_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_paav_rec.last_update_date := l_paav_rec.last_update_date;
      END IF;
      IF (x_paav_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.last_update_login := l_paav_rec.last_update_login;
      END IF;
     IF (x_paav_rec.program_application_id = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.program_application_id := l_paav_rec.program_application_id;
      END IF;
     IF (x_paav_rec.program_id = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.program_id := l_paav_rec.program_id;
      END IF;
     IF (x_paav_rec.program_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_paav_rec.program_update_date := l_paav_rec.program_update_date;
      END IF;
    IF (x_paav_rec.request_id = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.request_id := l_paav_rec.request_id;
      END IF;
      IF (x_paav_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_paav_rec.object_version_number := l_paav_rec.object_version_number;
      END IF;

IF (l_debug = 'Y') THEN
   okc_debug.log('9300: Leaving  populate_new_record ', 2);
   okc_debug.Reset_Indentation;
END IF;

  RETURN(l_return_status);

    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_PRICE_ADJ_ATTRIBS_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_paav_rec IN  paav_rec_type,
      x_paav_rec OUT NOCOPY paav_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN

      x_paav_rec := p_paav_rec;
      x_paav_rec.OBJECT_VERSION_NUMBER := NVL(x_paav_rec.OBJECT_VERSION_NUMBER,0) + 1;
      RETURN(l_return_status);

    END Set_Attributes;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('9400: Entered update_row', 2);
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
      p_paav_rec,                        -- IN
      l_paav_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_paav_rec, l_def_paav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_paav_rec := fill_who_columns(l_def_paav_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_paav_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_paav_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_paav_rec, l_paa_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_paa_rec,
      lx_paa_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_paa_rec, l_def_paav_rec);
    x_paav_rec := l_def_paav_rec;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

IF (l_debug = 'Y') THEN
   okc_debug.log('9500: Exiting update_row', 2);
   okc_debug.Reset_Indentation;
END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('9600: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('9700: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('9800: Exiting update_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL update_row for:PAAV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type,
    x_paav_tbl                     OUT NOCOPY paav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('9900: Entered update_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_paav_tbl.COUNT > 0) THEN
      i := p_paav_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_paav_rec                     => p_paav_tbl(i),
          x_paav_rec                     => x_paav_tbl(i));
        EXIT WHEN (i = p_paav_tbl.LAST);
        i := p_paav_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('10000: Exiting update_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10100: Exiting update_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10200: Exiting update_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10300: Exiting update_row:OTHERS Exception', 2);
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
  ------------------------------------------
  -- delete_row for:OKC_PRICE_ADJ_ATTRIBS --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paa_rec                      IN paa_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'ATTRIBS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paa_rec                      paa_rec_type:= p_paa_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('10400: Entered delete_row', 2);
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
    DELETE FROM OKC_PRICE_ADJ_ATTRIBS
     WHERE ID = l_paa_rec.id;

    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('10500: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('10600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('10700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('10800: Exiting delete_row:OTHERS Exception', 2);
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
  --------------------------------------------
  -- delete_row for:OKC_PRICE_ADJ_ATTRIBS_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_rec                     IN paav_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_paav_rec                     paav_rec_type := p_paav_rec;
    l_paa_rec                      paa_rec_type;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('10900: Entered delete_row', 2);
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
    migrate(l_paav_rec, l_paa_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_paa_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

    IF (l_debug = 'Y') THEN
       okc_debug.log('11000: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11100: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11200: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11300: Exiting delete_row:OTHERS Exception', 2);
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
  -- PL/SQL TBL delete_row for:PAAV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_paav_tbl                     IN paav_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('11400: Entered delete_row', 2);
    END IF;

    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_paav_tbl.COUNT > 0) THEN
      i := p_paav_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_paav_rec                     => p_paav_tbl(i));
        EXIT WHEN (i = p_paav_tbl.LAST);
        i := p_paav_tbl.NEXT(i);
      END LOOP;
    END IF;

    IF (l_debug = 'Y') THEN
       okc_debug.log('11500: Exiting delete_row', 2);
       okc_debug.Reset_Indentation;
    END IF;

  EXCEPTION
    WHEN OKC_API.G_EXCEPTION_ERROR THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('11600: Exiting delete_row:OKC_API.G_EXCEPTION_ERROR Exception', 2);
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
       okc_debug.log('11700: Exiting delete_row:OKC_API.G_EXCEPTION_UNEXPECTED_ERROR Exception', 2);
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
       okc_debug.log('11800: Exiting delete_row:OTHERS Exception', 2);
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
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('11900: Entered create_version', 2);
    END IF;

  INSERT INTO okc_price_adj_attribs_h
  (
      id,
      pat_id,
      flex_title,
        pricing_context,
        pricing_attribute,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number,
       major_version )
SELECT
      id,
      pat_id,
      flex_title,
        pricing_context,
        pricing_attribute,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number,
       p_major_version
      FROM okc_price_adj_attribs
WHERE pat_id  IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             );

    IF (l_debug = 'Y') THEN
       okc_debug.log('12000: Exiting create_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

  RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12100: Exiting create_version:OTHERS Exception', 2);
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
       okc_debug.Set_Indentation('OKC_PAA_PVT');
       okc_debug.log('12200: Entered restore_version', 2);
    END IF;

INSERT INTO okc_price_adj_attribs
   (
        id,
        pat_id,
        flex_title,
        pricing_context,
        pricing_attribute,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator,
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
      flex_title,
        pricing_context,
        pricing_attribute,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        pricing_attr_value_from,
        pricing_attr_value_to,
        comparison_operator,
        last_update_login,
        program_application_id,
        program_id,
        program_update_date,
        request_id,
       object_version_number
     FROM okc_price_adj_attribs_h
    WHERE pat_id IN
        ( SELECT pat_id
          FROM OKC_PRICE_ADJUSTMENTS
          WHERE chr_id = p_chr_id
             )
   AND major_version = p_major_version;

    IF (l_debug = 'Y') THEN
       okc_debug.log('12300: Exiting restore_version', 2);
       okc_debug.Reset_Indentation;
    END IF;

RETURN l_return_status;

  EXCEPTION
       -- other appropriate handlers
    WHEN OTHERS THEN

    IF (l_debug = 'Y') THEN
       okc_debug.log('12400: Exiting restore_version:OTHERS Exception', 2);
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

END OKC_PAA_PVT;

/
