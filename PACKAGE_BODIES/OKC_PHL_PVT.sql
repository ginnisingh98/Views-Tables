--------------------------------------------------------
--  DDL for Package Body OKC_PHL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_PHL_PVT" AS
/* $Header: OKCSPHLB.pls 120.0 2005/05/25 23:12:56 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
  -- FUNCTION get_rec for: OKC_PH_LINE_BREAKS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_ph_line_breaks_v_rec_type IS
    CURSOR okc_phlbv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            VALUE_FROM,
            VALUE_TO,
            PRICING_TYPE,
            VALUE,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            INTEGRATED_WITH_QP,
            QP_REFERENCE_ID,
            SHIP_TO_ORGANIZATION_ID,
            SHIP_TO_LOCATION_ID,
            LAST_UPDATE_LOGIN
      FROM Okc_Ph_Line_Breaks_V
     WHERE okc_ph_line_breaks_v.id = p_id;
    l_okc_phlbv_pk                 okc_phlbv_pk_csr%ROWTYPE;
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_phlbv_pk_csr (p_okc_ph_line_breaks_v_rec.id);
    FETCH okc_phlbv_pk_csr INTO
              l_okc_ph_line_breaks_v_rec.id,
              l_okc_ph_line_breaks_v_rec.cle_id,
              l_okc_ph_line_breaks_v_rec.value_from,
              l_okc_ph_line_breaks_v_rec.value_to,
              l_okc_ph_line_breaks_v_rec.pricing_type,
              l_okc_ph_line_breaks_v_rec.value,
              l_okc_ph_line_breaks_v_rec.start_date,
              l_okc_ph_line_breaks_v_rec.end_date,
              l_okc_ph_line_breaks_v_rec.object_version_number,
              l_okc_ph_line_breaks_v_rec.created_by,
              l_okc_ph_line_breaks_v_rec.creation_date,
              l_okc_ph_line_breaks_v_rec.last_updated_by,
              l_okc_ph_line_breaks_v_rec.last_update_date,
              l_okc_ph_line_breaks_v_rec.program_application_id,
              l_okc_ph_line_breaks_v_rec.program_id,
              l_okc_ph_line_breaks_v_rec.program_update_date,
              l_okc_ph_line_breaks_v_rec.request_id,
              l_okc_ph_line_breaks_v_rec.integrated_with_qp,
              l_okc_ph_line_breaks_v_rec.qp_reference_id,
              l_okc_ph_line_breaks_v_rec.ship_to_organization_id,
              l_okc_ph_line_breaks_v_rec.ship_to_location_id,
              l_okc_ph_line_breaks_v_rec.last_update_login;
    x_no_data_found := okc_phlbv_pk_csr%NOTFOUND;
    CLOSE okc_phlbv_pk_csr;
    RETURN(l_okc_ph_line_breaks_v_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_ph_line_breaks_v_rec_type IS
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_v_rec := get_rec(p_okc_ph_line_breaks_v_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_ph_line_breaks_v_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type
  ) RETURN okc_ph_line_breaks_v_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_ph_line_breaks_v_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_PH_LINE_BREAKS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_ph_line_breaks_rec_type IS
    CURSOR okc_ph_line_breaks_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            VALUE_FROM,
            VALUE_TO,
            PRICING_TYPE,
            VALUE,
            START_DATE,
            END_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            PROGRAM_APPLICATION_ID,
            PROGRAM_ID,
            PROGRAM_UPDATE_DATE,
            REQUEST_ID,
            INTEGRATED_WITH_QP,
            QP_REFERENCE_ID,
            SHIP_TO_ORGANIZATION_ID,
            SHIP_TO_LOCATION_ID,
            LAST_UPDATE_LOGIN
      FROM Okc_Ph_Line_Breaks
     WHERE okc_ph_line_breaks.id = p_id;
    l_okc_ph_line_breaks_pk        okc_ph_line_breaks_pk_csr%ROWTYPE;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_ph_line_breaks_pk_csr (p_okc_ph_line_breaks_rec.id);
    FETCH okc_ph_line_breaks_pk_csr INTO
              l_okc_ph_line_breaks_rec.id,
              l_okc_ph_line_breaks_rec.cle_id,
              l_okc_ph_line_breaks_rec.value_from,
              l_okc_ph_line_breaks_rec.value_to,
              l_okc_ph_line_breaks_rec.pricing_type,
              l_okc_ph_line_breaks_rec.value,
              l_okc_ph_line_breaks_rec.start_date,
              l_okc_ph_line_breaks_rec.end_date,
              l_okc_ph_line_breaks_rec.object_version_number,
              l_okc_ph_line_breaks_rec.created_by,
              l_okc_ph_line_breaks_rec.creation_date,
              l_okc_ph_line_breaks_rec.last_updated_by,
              l_okc_ph_line_breaks_rec.last_update_date,
              l_okc_ph_line_breaks_rec.program_application_id,
              l_okc_ph_line_breaks_rec.program_id,
              l_okc_ph_line_breaks_rec.program_update_date,
              l_okc_ph_line_breaks_rec.request_id,
              l_okc_ph_line_breaks_rec.integrated_with_qp,
              l_okc_ph_line_breaks_rec.qp_reference_id,
              l_okc_ph_line_breaks_rec.ship_to_organization_id,
              l_okc_ph_line_breaks_rec.ship_to_location_id,
              l_okc_ph_line_breaks_rec.last_update_login;
    x_no_data_found := okc_ph_line_breaks_pk_csr%NOTFOUND;
    CLOSE okc_ph_line_breaks_pk_csr;
    RETURN(l_okc_ph_line_breaks_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN okc_ph_line_breaks_rec_type IS
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_rec := get_rec(p_okc_ph_line_breaks_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_okc_ph_line_breaks_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type
  ) RETURN okc_ph_line_breaks_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_ph_line_breaks_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_PH_LINE_BREAKS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_okc_ph_line_breaks_v_rec   IN okc_ph_line_breaks_v_rec_type
  ) RETURN okc_ph_line_breaks_v_rec_type IS
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
  BEGIN
    IF (l_okc_ph_line_breaks_v_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.cle_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.value_from = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.value_from := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.value_to = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.value_to := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.pricing_type = OKC_API.G_MISS_CHAR ) THEN
      l_okc_ph_line_breaks_v_rec.pricing_type := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.value = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.value := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.start_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_ph_line_breaks_v_rec.start_date := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.end_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_ph_line_breaks_v_rec.end_date := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.object_version_number := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.created_by := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_ph_line_breaks_v_rec.creation_date := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.last_updated_by := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_ph_line_breaks_v_rec.last_update_date := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.program_application_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.program_application_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.program_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.program_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.program_update_date = OKC_API.G_MISS_DATE ) THEN
      l_okc_ph_line_breaks_v_rec.program_update_date := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.request_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.request_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.integrated_with_qp = OKC_API.G_MISS_CHAR ) THEN
      l_okc_ph_line_breaks_v_rec.integrated_with_qp := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.qp_reference_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.qp_reference_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.ship_to_organization_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.ship_to_organization_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.ship_to_location_id = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.ship_to_location_id := NULL;
    END IF;
    IF (l_okc_ph_line_breaks_v_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_okc_ph_line_breaks_v_rec.last_update_login := NULL;
    END IF;
    RETURN(l_okc_ph_line_breaks_v_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------
  -- Validate_Attributes for: CLE_ID --
  -------------------------------------
  PROCEDURE validate_cle_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_cle_id = OKC_API.G_MISS_NUM OR
        p_cle_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cle_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_cle_id;
  -------------------------------------------
  -- Validate_Attributes for: PRICING_TYPE --
  -------------------------------------------
  PROCEDURE validate_pricing_type(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_pricing_type                 IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_pricing_type = OKC_API.G_MISS_CHAR OR
        p_pricing_type IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'pricing_type');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_pricing_type;
  --------------------------------------------------
  -- Validate_Attributes for: VALUE_FROM and VALUE_TO --
  --------------------------------------------------
  PROCEDURE validate_values_from_to(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_phlv_rec     IN okc_ph_line_breaks_v_rec_type) IS
    l_dummy_var   VARCHAR2(1) := '?';
    l_MAX_NUM NUMBER := 9999999999999999999999999999999999999999;
    CURSOR c_overlaping( p_from NUMBER, p_to NUMBER, p_cle_id NUMBER, p_id NUMBER) IS
      SELECT 'x'
       FROM OKC_PH_LINE_BREAKS
       WHERE CLE_ID=p_cle_id AND ID<>p_id
         AND Greatest( p_from, Nvl(value_from,0)) <= Least( p_to, Nvl(value_to,l_MAX_NUM) );
  BEGIN
    IF (l_debug = 'Y') THEN
       okc_debug.Set_Indentation('OKC_PHL_PVT');
       okc_debug.log('500: Entered validate_values_from_to', 2);
    END IF;

    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- enforce foreign key, if data exists
    If ( Nvl(p_phlv_rec.value_from,0) <= Nvl(p_phlv_rec.value_to, l_MAX_NUM) )  Then
      Open c_overlaping(
                Nvl(p_phlv_rec.value_from,0),
                Nvl(p_phlv_rec.value_to,l_MAX_NUM),
                p_phlv_rec.cle_id,
                Nvl(p_phlv_rec.id,-1) );
      Fetch c_overlaping Into l_dummy_var;
      Close c_overlaping;

      -- if l_dummy_var still set to default, data was not found
      If (l_dummy_var = 'x') Then
  	    OKC_API.SET_MESSAGE(p_app_name	=> 'QP',
					    p_msg_name	=> 'QP_OVERLAP_PRICE_BREAK_RANGE');
	    -- notify caller of an error
        x_return_status := OKC_API.G_RET_STS_ERROR;
      End If;
     ELSE
  	    OKC_API.SET_MESSAGE(p_app_name	=> 'OKC',
					    p_msg_name	=> 'OKC_INVALID_RANGE');
        x_return_status := OKC_API.G_RET_STS_ERROR;
    End If;

    IF (l_debug = 'Y') THEN
       okc_debug.log('600: Leaving validate_values_from_to', 2);
       okc_debug.Reset_Indentation;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_values_from_to;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKC_PH_LINE_BREAKS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_okc_ph_line_breaks_v_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- cle_id
    -- ***
    validate_cle_id(x_return_status, p_okc_ph_line_breaks_v_rec.cle_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- pricing_type
    -- ***
    validate_pricing_type(x_return_status, p_okc_ph_line_breaks_v_rec.pricing_type);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- value_from and value_to
    -- ***
    validate_values_from_to(x_return_status, p_okc_ph_line_breaks_v_rec);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;


    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate Record for:OKC_PH_LINE_BREAKS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type,
    p_db_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type,
      p_db_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okc_phlbv_hraouv_fk_csr (p_organization_id IN NUMBER) IS
      SELECT 'x'
        FROM Hr_All_Organization_Units
       WHERE hr_all_organization_units.organization_id = p_organization_id;
      l_okc_phlbv_hraouv_fk          okc_phlbv_hraouv_fk_csr%ROWTYPE;

      CURSOR okc_phlbv_flkup_fk_csr (p_lookup_code IN VARCHAR2) IS
      SELECT 'x'
        FROM Fnd_Lookups
       WHERE fnd_lookups.lookup_code = p_lookup_code;
      l_okc_phlbv_flkup_fk           okc_phlbv_flkup_fk_csr%ROWTYPE;

      CURSOR okc_phlbv_okcklv_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okc_K_Lines_V
       WHERE okc_k_lines_v.id     = p_id;
      l_okc_phlbv_okcklv_fk          okc_phlbv_okcklv_fk_csr%ROWTYPE;

      CURSOR okc_phlbv_hrlav_fk_csr (p_ship_to_location_id IN NUMBER) IS
      SELECT 'x'
        FROM Hr_Locations_All_V
       WHERE hr_locations_all_v.ship_to_location_id = p_ship_to_location_id;
      l_okc_phlbv_hrlav_fk           okc_phlbv_hrlav_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_okc_ph_line_breaks_v_rec.PRICING_TYPE IS NOT NULL)
       AND
          (p_okc_ph_line_breaks_v_rec.PRICING_TYPE <> p_db_okc_ph_line_breaks_v_rec.PRICING_TYPE))
      THEN
        OPEN okc_phlbv_flkup_fk_csr (p_okc_ph_line_breaks_v_rec.PRICING_TYPE);
        FETCH okc_phlbv_flkup_fk_csr INTO l_okc_phlbv_flkup_fk;
        l_row_notfound := okc_phlbv_flkup_fk_csr%NOTFOUND;
        CLOSE okc_phlbv_flkup_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRICING_TYPE');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_okc_ph_line_breaks_v_rec.CLE_ID IS NOT NULL)
       AND
          (p_okc_ph_line_breaks_v_rec.CLE_ID <> p_db_okc_ph_line_breaks_v_rec.CLE_ID))
      THEN
        OPEN okc_phlbv_okcklv_fk_csr (p_okc_ph_line_breaks_v_rec.CLE_ID);
        FETCH okc_phlbv_okcklv_fk_csr INTO l_okc_phlbv_okcklv_fk;
        l_row_notfound := okc_phlbv_okcklv_fk_csr%NOTFOUND;
        CLOSE okc_phlbv_okcklv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CLE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_okc_ph_line_breaks_v_rec.SHIP_TO_LOCATION_ID IS NOT NULL)
       AND
          (p_okc_ph_line_breaks_v_rec.SHIP_TO_LOCATION_ID <> p_db_okc_ph_line_breaks_v_rec.SHIP_TO_LOCATION_ID))
      THEN
        OPEN okc_phlbv_hrlav_fk_csr (p_okc_ph_line_breaks_v_rec.SHIP_TO_LOCATION_ID);
        FETCH okc_phlbv_hrlav_fk_csr INTO l_okc_phlbv_hrlav_fk;
        l_row_notfound := okc_phlbv_hrlav_fk_csr%NOTFOUND;
        CLOSE okc_phlbv_hrlav_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SHIP_TO_LOCATION_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_okc_ph_line_breaks_v_rec.SHIP_TO_ORGANIZATION_ID IS NOT NULL)
       AND
          (p_okc_ph_line_breaks_v_rec.SHIP_TO_ORGANIZATION_ID <> p_db_okc_ph_line_breaks_v_rec.SHIP_TO_ORGANIZATION_ID))
      THEN
        OPEN okc_phlbv_hraouv_fk_csr (p_okc_ph_line_breaks_v_rec.SHIP_TO_ORGANIZATION_ID);
        FETCH okc_phlbv_hraouv_fk_csr INTO l_okc_phlbv_hraouv_fk;
        l_row_notfound := okc_phlbv_hraouv_fk_csr%NOTFOUND;
        CLOSE okc_phlbv_hraouv_fk_csr;
        IF (l_row_notfound) THEN
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SHIP_TO_ORGANIZATION_ID');
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
    l_return_status := validate_foreign_keys(p_okc_ph_line_breaks_v_rec, p_db_okc_ph_line_breaks_v_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_okc_ph_line_breaks_v_rec  okc_ph_line_breaks_v_rec_type := get_rec(p_okc_ph_line_breaks_v_rec);
  BEGIN
    l_return_status := Validate_Record(p_okc_ph_line_breaks_v_rec => p_okc_ph_line_breaks_v_rec,
                                       p_db_okc_ph_line_breaks_v_rec => l_db_okc_ph_line_breaks_v_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN okc_ph_line_breaks_v_rec_type,
    p_to   IN OUT NOCOPY okc_ph_line_breaks_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.value_from := p_from.value_from;
    p_to.value_to := p_from.value_to;
    p_to.pricing_type := p_from.pricing_type;
    p_to.value := p_from.value;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.integrated_with_qp := p_from.integrated_with_qp;
    p_to.qp_reference_id := p_from.qp_reference_id;
    p_to.ship_to_organization_id := p_from.ship_to_organization_id;
    p_to.ship_to_location_id := p_from.ship_to_location_id;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from IN okc_ph_line_breaks_rec_type,
    p_to   IN OUT NOCOPY okc_ph_line_breaks_v_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.value_from := p_from.value_from;
    p_to.value_to := p_from.value_to;
    p_to.pricing_type := p_from.pricing_type;
    p_to.value := p_from.value;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.program_application_id := p_from.program_application_id;
    p_to.program_id := p_from.program_id;
    p_to.program_update_date := p_from.program_update_date;
    p_to.request_id := p_from.request_id;
    p_to.integrated_with_qp := p_from.integrated_with_qp;
    p_to.qp_reference_id := p_from.qp_reference_id;
    p_to.ship_to_organization_id := p_from.ship_to_organization_id;
    p_to.ship_to_location_id := p_from.ship_to_location_id;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKC_PH_LINE_BREAKS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
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
    l_return_status := Validate_Attributes(l_okc_ph_line_breaks_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_okc_ph_line_breaks_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKC_PH_LINE_BREAKS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      i := p_okc_ph_line_breaks_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
        i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKC_PH_LINE_BREAKS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_ph_line_breaks_v_tbl     => p_okc_ph_line_breaks_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- insert_row for:OKC_PH_LINE_BREAKS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type,
    x_okc_ph_line_breaks_rec       OUT NOCOPY okc_ph_line_breaks_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type := p_okc_ph_line_breaks_rec;
    l_def_okc_ph_line_breaks_rec   okc_ph_line_breaks_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKC_PH_LINE_BREAKS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_ph_line_breaks_rec IN okc_ph_line_breaks_rec_type,
      x_okc_ph_line_breaks_rec OUT NOCOPY okc_ph_line_breaks_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_rec := p_okc_ph_line_breaks_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_okc_ph_line_breaks_rec,          -- IN
      l_okc_ph_line_breaks_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_PH_LINE_BREAKS(
      id,
      cle_id,
      value_from,
      value_to,
      pricing_type,
      value,
      start_date,
      end_date,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      program_application_id,
      program_id,
      program_update_date,
      request_id,
      integrated_with_qp,
      qp_reference_id,
      ship_to_organization_id,
      ship_to_location_id,
      last_update_login)
    VALUES (
      l_okc_ph_line_breaks_rec.id,
      l_okc_ph_line_breaks_rec.cle_id,
      l_okc_ph_line_breaks_rec.value_from,
      l_okc_ph_line_breaks_rec.value_to,
      l_okc_ph_line_breaks_rec.pricing_type,
      l_okc_ph_line_breaks_rec.value,
      l_okc_ph_line_breaks_rec.start_date,
      l_okc_ph_line_breaks_rec.end_date,
      l_okc_ph_line_breaks_rec.object_version_number,
      l_okc_ph_line_breaks_rec.created_by,
      l_okc_ph_line_breaks_rec.creation_date,
      l_okc_ph_line_breaks_rec.last_updated_by,
      l_okc_ph_line_breaks_rec.last_update_date,
      l_okc_ph_line_breaks_rec.program_application_id,
      l_okc_ph_line_breaks_rec.program_id,
      l_okc_ph_line_breaks_rec.program_update_date,
      l_okc_ph_line_breaks_rec.request_id,
      l_okc_ph_line_breaks_rec.integrated_with_qp,
      l_okc_ph_line_breaks_rec.qp_reference_id,
      l_okc_ph_line_breaks_rec.ship_to_organization_id,
      l_okc_ph_line_breaks_rec.ship_to_location_id,
      l_okc_ph_line_breaks_rec.last_update_login);
    -- Set OUT values
    x_okc_ph_line_breaks_rec := l_okc_ph_line_breaks_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKC_PH_LINE_BREAKS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_okc_ph_line_breaks_v_rec     OUT NOCOPY okc_ph_line_breaks_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    l_def_okc_ph_line_breaks_v_rec okc_ph_line_breaks_v_rec_type;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
    lx_okc_ph_line_breaks_rec      okc_ph_line_breaks_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type
    ) RETURN okc_ph_line_breaks_v_rec_type IS
      l_okc_ph_line_breaks_v_rec okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    BEGIN
      l_okc_ph_line_breaks_v_rec.CREATION_DATE := SYSDATE;
      l_okc_ph_line_breaks_v_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_okc_ph_line_breaks_v_rec.LAST_UPDATE_DATE := l_okc_ph_line_breaks_v_rec.CREATION_DATE;
      l_okc_ph_line_breaks_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okc_ph_line_breaks_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okc_ph_line_breaks_v_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PH_LINE_BREAKS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type,
      x_okc_ph_line_breaks_v_rec OUT NOCOPY okc_ph_line_breaks_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_v_rec := p_okc_ph_line_breaks_v_rec;
      x_okc_ph_line_breaks_v_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_okc_ph_line_breaks_v_rec := null_out_defaults(p_okc_ph_line_breaks_v_rec);
    -- Set primary key value
    l_okc_ph_line_breaks_v_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_okc_ph_line_breaks_v_rec,        -- IN
      l_def_okc_ph_line_breaks_v_rec);   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okc_ph_line_breaks_v_rec := fill_who_columns(l_def_okc_ph_line_breaks_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okc_ph_line_breaks_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okc_ph_line_breaks_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okc_ph_line_breaks_v_rec, l_okc_ph_line_breaks_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_ph_line_breaks_rec,
      lx_okc_ph_line_breaks_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_ph_line_breaks_rec, l_def_okc_ph_line_breaks_v_rec);
    -- Set OUT values
    x_okc_ph_line_breaks_v_rec := l_def_okc_ph_line_breaks_v_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  --------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKC_PH_LINE_BREAKS_V_TBL --
  --------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      i := p_okc_ph_line_breaks_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_tbl(i),
            x_okc_ph_line_breaks_v_rec     => x_okc_ph_line_breaks_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
        i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  --------------------------------------------------------
  -- PL/SQL TBL insert_row for:OKC_PH_LINE_BREAKS_V_TBL --
  --------------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_ph_line_breaks_v_tbl     => p_okc_ph_line_breaks_v_tbl,
        x_okc_ph_line_breaks_v_tbl     => x_okc_ph_line_breaks_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -------------------------------------
  -- lock_row for:OKC_PH_LINE_BREAKS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_ph_line_breaks_rec IN okc_ph_line_breaks_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PH_LINE_BREAKS
     WHERE ID = p_okc_ph_line_breaks_rec.id
       AND OBJECT_VERSION_NUMBER = p_okc_ph_line_breaks_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_okc_ph_line_breaks_rec IN okc_ph_line_breaks_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_PH_LINE_BREAKS
     WHERE ID = p_okc_ph_line_breaks_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKC_PH_LINE_BREAKS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKC_PH_LINE_BREAKS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_okc_ph_line_breaks_rec);
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
      OPEN lchk_csr(p_okc_ph_line_breaks_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_okc_ph_line_breaks_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_okc_ph_line_breaks_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKC_PH_LINE_BREAKS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_okc_ph_line_breaks_v_rec, l_okc_ph_line_breaks_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_ph_line_breaks_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKC_PH_LINE_BREAKS_V_TBL --
  ------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      i := p_okc_ph_line_breaks_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
        i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ------------------------------------------------------
  -- PL/SQL TBL lock_row for:OKC_PH_LINE_BREAKS_V_TBL --
  ------------------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_ph_line_breaks_v_tbl     => p_okc_ph_line_breaks_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- update_row for:OKC_PH_LINE_BREAKS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type,
    x_okc_ph_line_breaks_rec       OUT NOCOPY okc_ph_line_breaks_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type := p_okc_ph_line_breaks_rec;
    l_def_okc_ph_line_breaks_rec   okc_ph_line_breaks_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_ph_line_breaks_rec IN okc_ph_line_breaks_rec_type,
      x_okc_ph_line_breaks_rec OUT NOCOPY okc_ph_line_breaks_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_rec := p_okc_ph_line_breaks_rec;
      -- Get current database values
      l_okc_ph_line_breaks_rec := get_rec(p_okc_ph_line_breaks_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_ph_line_breaks_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.id := l_okc_ph_line_breaks_rec.id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.cle_id := l_okc_ph_line_breaks_rec.cle_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.value_from = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.value_from := l_okc_ph_line_breaks_rec.value_from;
        END IF;
        IF (x_okc_ph_line_breaks_rec.value_to = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.value_to := l_okc_ph_line_breaks_rec.value_to;
        END IF;
        IF (x_okc_ph_line_breaks_rec.pricing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_ph_line_breaks_rec.pricing_type := l_okc_ph_line_breaks_rec.pricing_type;
        END IF;
        IF (x_okc_ph_line_breaks_rec.value = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.value := l_okc_ph_line_breaks_rec.value;
        END IF;
        IF (x_okc_ph_line_breaks_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_rec.start_date := l_okc_ph_line_breaks_rec.start_date;
        END IF;
        IF (x_okc_ph_line_breaks_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_rec.end_date := l_okc_ph_line_breaks_rec.end_date;
        END IF;
        IF (x_okc_ph_line_breaks_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.object_version_number := l_okc_ph_line_breaks_rec.object_version_number;
        END IF;
        IF (x_okc_ph_line_breaks_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.created_by := l_okc_ph_line_breaks_rec.created_by;
        END IF;
        IF (x_okc_ph_line_breaks_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_rec.creation_date := l_okc_ph_line_breaks_rec.creation_date;
        END IF;
        IF (x_okc_ph_line_breaks_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.last_updated_by := l_okc_ph_line_breaks_rec.last_updated_by;
        END IF;
        IF (x_okc_ph_line_breaks_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_rec.last_update_date := l_okc_ph_line_breaks_rec.last_update_date;
        END IF;
        IF (x_okc_ph_line_breaks_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.program_application_id := l_okc_ph_line_breaks_rec.program_application_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.program_id := l_okc_ph_line_breaks_rec.program_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_rec.program_update_date := l_okc_ph_line_breaks_rec.program_update_date;
        END IF;
        IF (x_okc_ph_line_breaks_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.request_id := l_okc_ph_line_breaks_rec.request_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.integrated_with_qp = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_ph_line_breaks_rec.integrated_with_qp := l_okc_ph_line_breaks_rec.integrated_with_qp;
        END IF;
        IF (x_okc_ph_line_breaks_rec.qp_reference_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.qp_reference_id := l_okc_ph_line_breaks_rec.qp_reference_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.ship_to_organization_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.ship_to_organization_id := l_okc_ph_line_breaks_rec.ship_to_organization_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.ship_to_location_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.ship_to_location_id := l_okc_ph_line_breaks_rec.ship_to_location_id;
        END IF;
        IF (x_okc_ph_line_breaks_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_rec.last_update_login := l_okc_ph_line_breaks_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_PH_LINE_BREAKS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_ph_line_breaks_rec IN okc_ph_line_breaks_rec_type,
      x_okc_ph_line_breaks_rec OUT NOCOPY okc_ph_line_breaks_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_rec := p_okc_ph_line_breaks_rec;
      x_okc_ph_line_breaks_rec.OBJECT_VERSION_NUMBER := p_okc_ph_line_breaks_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_okc_ph_line_breaks_rec,          -- IN
      l_okc_ph_line_breaks_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_ph_line_breaks_rec, l_def_okc_ph_line_breaks_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKC_PH_LINE_BREAKS
    SET CLE_ID = l_def_okc_ph_line_breaks_rec.cle_id,
        VALUE_FROM = l_def_okc_ph_line_breaks_rec.value_from,
        VALUE_TO = l_def_okc_ph_line_breaks_rec.value_to,
        PRICING_TYPE = l_def_okc_ph_line_breaks_rec.pricing_type,
        VALUE = l_def_okc_ph_line_breaks_rec.value,
        START_DATE = l_def_okc_ph_line_breaks_rec.start_date,
        END_DATE = l_def_okc_ph_line_breaks_rec.end_date,
        OBJECT_VERSION_NUMBER = l_def_okc_ph_line_breaks_rec.object_version_number,
        CREATED_BY = l_def_okc_ph_line_breaks_rec.created_by,
        CREATION_DATE = l_def_okc_ph_line_breaks_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_ph_line_breaks_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_ph_line_breaks_rec.last_update_date,
        PROGRAM_APPLICATION_ID = l_def_okc_ph_line_breaks_rec.program_application_id,
        PROGRAM_ID = l_def_okc_ph_line_breaks_rec.program_id,
        PROGRAM_UPDATE_DATE = l_def_okc_ph_line_breaks_rec.program_update_date,
        REQUEST_ID = l_def_okc_ph_line_breaks_rec.request_id,
        INTEGRATED_WITH_QP = l_def_okc_ph_line_breaks_rec.integrated_with_qp,
        QP_REFERENCE_ID = l_def_okc_ph_line_breaks_rec.qp_reference_id,
        SHIP_TO_ORGANIZATION_ID = l_def_okc_ph_line_breaks_rec.ship_to_organization_id,
        SHIP_TO_LOCATION_ID = l_def_okc_ph_line_breaks_rec.ship_to_location_id,
        LAST_UPDATE_LOGIN = l_def_okc_ph_line_breaks_rec.last_update_login
    WHERE ID = l_def_okc_ph_line_breaks_rec.id;

    x_okc_ph_line_breaks_rec := l_okc_ph_line_breaks_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------
  -- update_row for:OKC_PH_LINE_BREAKS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type,
    x_okc_ph_line_breaks_v_rec     OUT NOCOPY okc_ph_line_breaks_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    l_def_okc_ph_line_breaks_v_rec okc_ph_line_breaks_v_rec_type;
    l_db_okc_ph_line_breaks_v_rec  okc_ph_line_breaks_v_rec_type;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
    lx_okc_ph_line_breaks_rec      okc_ph_line_breaks_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type
    ) RETURN okc_ph_line_breaks_v_rec_type IS
      l_okc_ph_line_breaks_v_rec okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    BEGIN
      l_okc_ph_line_breaks_v_rec.LAST_UPDATE_DATE := SYSDATE;
      l_okc_ph_line_breaks_v_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_okc_ph_line_breaks_v_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_okc_ph_line_breaks_v_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type,
      x_okc_ph_line_breaks_v_rec OUT NOCOPY okc_ph_line_breaks_v_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_v_rec := p_okc_ph_line_breaks_v_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_okc_ph_line_breaks_v_rec := get_rec(p_okc_ph_line_breaks_v_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_okc_ph_line_breaks_v_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.id := l_db_okc_ph_line_breaks_v_rec.id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.cle_id := l_db_okc_ph_line_breaks_v_rec.cle_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.value_from = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.value_from := l_db_okc_ph_line_breaks_v_rec.value_from;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.value_to = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.value_to := l_db_okc_ph_line_breaks_v_rec.value_to;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.pricing_type = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_ph_line_breaks_v_rec.pricing_type := l_db_okc_ph_line_breaks_v_rec.pricing_type;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.value = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.value := l_db_okc_ph_line_breaks_v_rec.value;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_v_rec.start_date := l_db_okc_ph_line_breaks_v_rec.start_date;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_v_rec.end_date := l_db_okc_ph_line_breaks_v_rec.end_date;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.created_by := l_db_okc_ph_line_breaks_v_rec.created_by;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_v_rec.creation_date := l_db_okc_ph_line_breaks_v_rec.creation_date;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.last_updated_by := l_db_okc_ph_line_breaks_v_rec.last_updated_by;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_v_rec.last_update_date := l_db_okc_ph_line_breaks_v_rec.last_update_date;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.program_application_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.program_application_id := l_db_okc_ph_line_breaks_v_rec.program_application_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.program_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.program_id := l_db_okc_ph_line_breaks_v_rec.program_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.program_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_okc_ph_line_breaks_v_rec.program_update_date := l_db_okc_ph_line_breaks_v_rec.program_update_date;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.request_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.request_id := l_db_okc_ph_line_breaks_v_rec.request_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.integrated_with_qp = OKC_API.G_MISS_CHAR)
        THEN
          x_okc_ph_line_breaks_v_rec.integrated_with_qp := l_db_okc_ph_line_breaks_v_rec.integrated_with_qp;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.qp_reference_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.qp_reference_id := l_db_okc_ph_line_breaks_v_rec.qp_reference_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.ship_to_organization_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.ship_to_organization_id := l_db_okc_ph_line_breaks_v_rec.ship_to_organization_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.ship_to_location_id = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.ship_to_location_id := l_db_okc_ph_line_breaks_v_rec.ship_to_location_id;
        END IF;
        IF (x_okc_ph_line_breaks_v_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_okc_ph_line_breaks_v_rec.last_update_login := l_db_okc_ph_line_breaks_v_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_PH_LINE_BREAKS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_ph_line_breaks_v_rec IN okc_ph_line_breaks_v_rec_type,
      x_okc_ph_line_breaks_v_rec OUT NOCOPY okc_ph_line_breaks_v_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_ph_line_breaks_v_rec := p_okc_ph_line_breaks_v_rec;
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
      p_okc_ph_line_breaks_v_rec,        -- IN
      x_okc_ph_line_breaks_v_rec);       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_ph_line_breaks_v_rec, l_def_okc_ph_line_breaks_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_okc_ph_line_breaks_v_rec := fill_who_columns(l_def_okc_ph_line_breaks_v_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_okc_ph_line_breaks_v_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_okc_ph_line_breaks_v_rec, l_db_okc_ph_line_breaks_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_okc_ph_line_breaks_v_rec, l_okc_ph_line_breaks_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_ph_line_breaks_rec,
      lx_okc_ph_line_breaks_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_ph_line_breaks_rec, l_def_okc_ph_line_breaks_v_rec);
    x_okc_ph_line_breaks_v_rec := l_def_okc_ph_line_breaks_v_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  --------------------------------------------------------
  -- PL/SQL TBL update_row for:okc_ph_line_breaks_v_tbl --
  --------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      i := p_okc_ph_line_breaks_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_tbl(i),
            x_okc_ph_line_breaks_v_rec     => x_okc_ph_line_breaks_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
        i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  --------------------------------------------------------
  -- PL/SQL TBL update_row for:OKC_PH_LINE_BREAKS_V_TBL --
  --------------------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    x_okc_ph_line_breaks_v_tbl     OUT NOCOPY okc_ph_line_breaks_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_ph_line_breaks_v_tbl     => p_okc_ph_line_breaks_v_tbl,
        x_okc_ph_line_breaks_v_tbl     => x_okc_ph_line_breaks_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------
  -- delete_row for:OKC_PH_LINE_BREAKS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_rec       IN okc_ph_line_breaks_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type := p_okc_ph_line_breaks_rec;
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

    DELETE FROM OKC_PH_LINE_BREAKS
     WHERE ID = p_okc_ph_line_breaks_rec.id;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------
  -- delete_row for:OKC_PH_LINE_BREAKS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_rec     IN okc_ph_line_breaks_v_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_ph_line_breaks_v_rec     okc_ph_line_breaks_v_rec_type := p_okc_ph_line_breaks_v_rec;
    l_okc_ph_line_breaks_rec       okc_ph_line_breaks_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_okc_ph_line_breaks_v_rec, l_okc_ph_line_breaks_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_ph_line_breaks_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKC_PH_LINE_BREAKS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      i := p_okc_ph_line_breaks_v_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_okc_ph_line_breaks_v_rec     => p_okc_ph_line_breaks_v_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_okc_ph_line_breaks_v_tbl.LAST);
        i := p_okc_ph_line_breaks_v_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKC_PH_LINE_BREAKS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_ph_line_breaks_v_tbl     IN okc_ph_line_breaks_v_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_okc_ph_line_breaks_v_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_okc_ph_line_breaks_v_tbl     => p_okc_ph_line_breaks_v_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
       okc_debug.Set_Indentation('OKC_PHL_PVT');
       okc_debug.log('10700: Entered create_version', 2);
    END IF;

  INSERT INTO okc_ph_line_breaks_h
  (
       id,
       major_version,
       cle_id,
       value_from,
       value_to,
       pricing_type,
       value,
       start_date,
       end_date,
       object_version_number,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       security_group_id,
       integrated_with_qp,
       qp_reference_id,
       ship_to_organization_id,
       ship_to_location_id,
       last_update_login)
   SELECT
       id,
       p_major_version,
       cle_id,
       value_from,
       value_to,
       pricing_type,
       value,
       start_date,
       end_date,
       object_version_number,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       security_group_id,
       integrated_with_qp,
       qp_reference_id,
       ship_to_organization_id,
       ship_to_location_id,
       last_update_login

     FROM okc_ph_line_breaks
WHERE cle_id IN
     (SELECT id
      FROM okc_k_lines_b
      WHERE dnz_chr_id = p_chr_id    --price hold sub-line
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
       okc_debug.Set_Indentation('OKC_PHL_PVT');
       okc_debug.log('11000: Entered restore_version', 2);
    END IF;

INSERT INTO okc_ph_line_breaks
   (
       id,
       cle_id,
       value_from,
       value_to,
       pricing_type,
       value,
       start_date,
       end_date,
       object_version_number,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       security_group_id,
       integrated_with_qp,
       qp_reference_id,
       ship_to_organization_id,
       ship_to_location_id,
       last_update_login
         )
   SELECT

       id,
       cle_id,
       value_from,
       value_to,
       pricing_type,
       value,
       start_date,
       end_date,
       object_version_number,
       created_by,
       creation_date,
       last_updated_by,
       last_update_date,
       program_application_id,
       program_id,
       program_update_date,
       request_id,
       security_group_id,
       integrated_with_qp,
       qp_reference_id,
       ship_to_organization_id,
       ship_to_location_id,
       last_update_login

FROM okc_ph_line_breaks_h
 WHERE cle_id IN
     (SELECT id
      FROM okc_k_lines_b
      WHERE dnz_chr_id = p_chr_id    --price hold sub-line
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






END OKC_PHL_PVT;

/
