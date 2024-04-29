--------------------------------------------------------
--  DDL for Package Body OKL_IRK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IRK_PVT" AS
/* $Header: OKLSIRKB.pls 120.2 2005/10/30 03:45:08 appldev noship $ */
   ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKL_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

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
  -- in a OKL_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKL_API.ERROR_TBL_TYPE
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
  -- FUNCTION get_rec for: OKL_INSURER_RANKINGS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_irkv_rec                     IN irkv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN irkv_rec_type IS
    CURSOR okl_irkv_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            RANKING_SEQ,
            OBJECT_VERSION_NUMBER,
            DATE_FROM,
            DATE_TO,
            ISU_ID,
            IC_CODE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Insurer_Rankings_V
     WHERE okl_insurer_rankings_v.id = p_id;
    l_okl_irkv_pk                  okl_irkv_pk_csr%ROWTYPE;
    l_irkv_rec                     irkv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_irkv_pk_csr (p_irkv_rec.id);
    FETCH okl_irkv_pk_csr INTO
              l_irkv_rec.id,
              l_irkv_rec.ranking_seq,
              l_irkv_rec.object_version_number,
              l_irkv_rec.date_from,
              l_irkv_rec.date_to,
              l_irkv_rec.isu_id,
              l_irkv_rec.ic_code,
              l_irkv_rec.attribute_category,
              l_irkv_rec.attribute1,
              l_irkv_rec.attribute2,
              l_irkv_rec.attribute3,
              l_irkv_rec.attribute4,
              l_irkv_rec.attribute5,
              l_irkv_rec.attribute6,
              l_irkv_rec.attribute7,
              l_irkv_rec.attribute8,
              l_irkv_rec.attribute9,
              l_irkv_rec.attribute10,
              l_irkv_rec.attribute11,
              l_irkv_rec.attribute12,
              l_irkv_rec.attribute13,
              l_irkv_rec.attribute14,
              l_irkv_rec.attribute15,
              l_irkv_rec.created_by,
              l_irkv_rec.creation_date,
              l_irkv_rec.last_updated_by,
              l_irkv_rec.last_update_date,
              l_irkv_rec.last_update_login;
    x_no_data_found := okl_irkv_pk_csr%NOTFOUND;
    CLOSE okl_irkv_pk_csr;
    RETURN(l_irkv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_irkv_rec                     IN irkv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN irkv_rec_type IS
    l_irkv_rec                     irkv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_irkv_rec := get_rec(p_irkv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_irkv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_irkv_rec                     IN irkv_rec_type
  ) RETURN irkv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_irkv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INSURER_RANKINGS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_irk_rec                      IN irk_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN irk_rec_type IS
    CURSOR okl_irk_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            RANKING_SEQ,
            DATE_FROM,
            DATE_TO,
            ISU_ID,
            IC_CODE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Insurer_Rankings
     WHERE okl_insurer_rankings.id = p_id;
    l_okl_irk_pk                   okl_irk_pk_csr%ROWTYPE;
    l_irk_rec                      irk_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_irk_pk_csr (p_irk_rec.id);
    FETCH okl_irk_pk_csr INTO
              l_irk_rec.id,
              l_irk_rec.object_version_number,
              l_irk_rec.ranking_seq,
              l_irk_rec.date_from,
              l_irk_rec.date_to,
              l_irk_rec.isu_id,
              l_irk_rec.ic_code,
              l_irk_rec.attribute_category,
              l_irk_rec.attribute1,
              l_irk_rec.attribute2,
              l_irk_rec.attribute3,
              l_irk_rec.attribute4,
              l_irk_rec.attribute5,
              l_irk_rec.attribute6,
              l_irk_rec.attribute7,
              l_irk_rec.attribute8,
              l_irk_rec.attribute9,
              l_irk_rec.attribute10,
              l_irk_rec.attribute11,
              l_irk_rec.attribute12,
              l_irk_rec.attribute13,
              l_irk_rec.attribute14,
              l_irk_rec.attribute15,
              l_irk_rec.created_by,
              l_irk_rec.creation_date,
              l_irk_rec.last_updated_by,
              l_irk_rec.last_update_date,
              l_irk_rec.last_update_login;
    x_no_data_found := okl_irk_pk_csr%NOTFOUND;
    CLOSE okl_irk_pk_csr;
    RETURN(l_irk_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_irk_rec                      IN irk_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN irk_rec_type IS
    l_irk_rec                      irk_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_irk_rec := get_rec(p_irk_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_irk_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_irk_rec                      IN irk_rec_type
  ) RETURN irk_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_irk_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INSURER_RANKINGS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_irkv_rec   IN irkv_rec_type
  ) RETURN irkv_rec_type IS
    l_irkv_rec                     irkv_rec_type := p_irkv_rec;
  BEGIN
    IF (l_irkv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.id := NULL;
    END IF;
    IF (l_irkv_rec.ranking_seq = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.ranking_seq := NULL;
    END IF;
    IF (l_irkv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.object_version_number := NULL;
    END IF;
    IF (l_irkv_rec.date_from = OKC_API.G_MISS_DATE ) THEN
      l_irkv_rec.date_from := NULL;
    END IF;
    IF (l_irkv_rec.date_to = OKC_API.G_MISS_DATE ) THEN
      l_irkv_rec.date_to := NULL;
    END IF;
    IF (l_irkv_rec.isu_id = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.isu_id := NULL;
    END IF;
    IF (l_irkv_rec.ic_code = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.ic_code := NULL;
    END IF;
    IF (l_irkv_rec.attribute_category = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute_category := NULL;
    END IF;
    IF (l_irkv_rec.attribute1 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute1 := NULL;
    END IF;
    IF (l_irkv_rec.attribute2 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute2 := NULL;
    END IF;
    IF (l_irkv_rec.attribute3 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute3 := NULL;
    END IF;
    IF (l_irkv_rec.attribute4 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute4 := NULL;
    END IF;
    IF (l_irkv_rec.attribute5 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute5 := NULL;
    END IF;
    IF (l_irkv_rec.attribute6 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute6 := NULL;
    END IF;
    IF (l_irkv_rec.attribute7 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute7 := NULL;
    END IF;
    IF (l_irkv_rec.attribute8 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute8 := NULL;
    END IF;
    IF (l_irkv_rec.attribute9 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute9 := NULL;
    END IF;
    IF (l_irkv_rec.attribute10 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute10 := NULL;
    END IF;
    IF (l_irkv_rec.attribute11 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute11 := NULL;
    END IF;
    IF (l_irkv_rec.attribute12 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute12 := NULL;
    END IF;
    IF (l_irkv_rec.attribute13 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute13 := NULL;
    END IF;
    IF (l_irkv_rec.attribute14 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute14 := NULL;
    END IF;
    IF (l_irkv_rec.attribute15 = OKC_API.G_MISS_CHAR ) THEN
      l_irkv_rec.attribute15 := NULL;
    END IF;
    IF (l_irkv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.created_by := NULL;
    END IF;
    IF (l_irkv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_irkv_rec.creation_date := NULL;
    END IF;
    IF (l_irkv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.last_updated_by := NULL;
    END IF;
    IF (l_irkv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_irkv_rec.last_update_date := NULL;
    END IF;
    IF (l_irkv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_irkv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_irkv_rec);
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

    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_INSURER_RANKINGS_V'
                          ,p_col_name      => 'id'
                          ,p_col_value     => p_id
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
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
  ------------------------------------------
  -- Validate_Attributes for: RANKING_SEQ --
  ------------------------------------------
  PROCEDURE validate_ranking_seq(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ranking_seq                  IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_ranking_seq = OKC_API.G_MISS_NUM OR
        p_ranking_seq IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'ranking_seq');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_INSURER_RANKINGS_V'
                          ,p_col_name      => 'ranking_seq'
                          ,p_col_value     => p_ranking_seq
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
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
  END validate_ranking_seq;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_INSURER_RANKINGS_V'
                          ,p_col_name      => 'object_version_number'
                          ,p_col_value     => p_object_version_number
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
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
  END validate_object_version_number;
  ----------------------------------------
  -- Validate_Attributes for: DATE_FROM --
  ----------------------------------------
  PROCEDURE validate_date_from(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_date_from                    IN DATE,
    p_object_version_number        IN NUMBER
    ) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_date_from = OKC_API.G_MISS_DATE OR
        p_date_from IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Effective From');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;


    ELSIF(p_object_version_number  < 2 ) THEN

        x_return_status :=  Okl_Util.check_from_to_date_range(trunc(sysdate), p_date_from ); --Fix for bug 3924176
		  	    -- store the highest degree of error
	IF (x_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
		 Okc_Api.set_message(
		  		p_app_name     =>  g_app_name,
		  		p_msg_name     => 'OKL_INVALID_DATE_RANGE',
		  		p_token1       => 'COL_NAME1',
		  		p_token1_value => 'Effective From Date'
		  						);
		IF(x_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN

		  RAISE G_EXCEPTION_HALT_VALIDATION;
		END IF;
	  END IF;


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
  END validate_date_from;
  -------------------------------------
  -- Validate_Attributes for: ISU_ID --
  -------------------------------------
  PROCEDURE validate_isu_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_isu_id                       IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_isu_id = OKC_API.G_MISS_NUM OR
        p_isu_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Provider');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_INSURER_RANKINGS_V'
                          ,p_col_name      => 'isu_id'
                          ,p_col_value     => p_isu_id
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
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
  END validate_isu_id;
  --------------------------------------
  -- Validate_Attributes for: IC_CODE --
  --------------------------------------
  PROCEDURE validate_ic_code(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_ic_code                      IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_ic_code = OKC_API.G_MISS_CHAR OR
        p_ic_code IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'Country');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/*

    -- Verify the value fits the length of the column in the database
    OKC_UTIL.CHECK_LENGTH( p_view_name     => 'OKL_INSURER_RANKINGS_V'
                          ,p_col_name      => 'ic_code'
                          ,p_col_value     => p_ic_code
                          ,x_return_status => x_return_status);
    -- verify that length is within allowed limits
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
*/

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
  END validate_ic_code;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKL_INSURER_RANKINGS_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_irkv_rec                     IN irkv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- Call OKC_UTIL.ADD_VIEW to prepare the PL/SQL table to hold columns of view
    OKC_UTIL.ADD_VIEW('OKL_INSURER_RANKINGS_V', x_return_status);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_irkv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- ranking_seq
    -- ***
    validate_ranking_seq(x_return_status, p_irkv_rec.ranking_seq);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_irkv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- date_from
    -- ***
    validate_date_from(x_return_status, p_irkv_rec.date_from,p_irkv_rec.object_version_number );
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- isu_id
    -- ***
    validate_isu_id(x_return_status, p_irkv_rec.isu_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- ic_code
    -- ***
    validate_ic_code(x_return_status, p_irkv_rec.ic_code);
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
  ------------------------------------------------
  -- Validate Record for:OKL_INSURER_RANKINGS_V --
  ------------------------------------------------

------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_irkv_rec IN irkv_rec_type,
      p_db_irkv_rec IN irkv_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okx_countries_v_pk_csr  IS
            SELECT 'x'
       FROM OKX_COUNTRIES_V
       WHERE id1 = p_irkv_rec.ic_code;
      CURSOR okx_insurer_v_pk_csr (p_isu_id IN NUMBER) IS
      SELECT 'x'
        FROM OKX_INS_PROVIDER_V
       WHERE OKX_INS_PROVIDER_V.PARTY_ID = p_isu_id;

      CURSOR okl_insurer_rankings_v_pk_csr IS
      SELECT 'x'
        FROM okl_insurer_rankings
       WHERE okl_insurer_rankings.id <> p_irkv_rec.id
         and  okl_insurer_rankings.ic_code = p_irkv_rec.ic_code
	  AND	  okl_insurer_rankings.RANKING_SEQ = p_irkv_rec.RANKING_SEQ
    And    okl_insurer_rankings.date_from <= p_irkv_rec.date_from
    AND ( p_irkv_rec.date_from <= nvl(okl_insurer_rankings.date_to,p_irkv_rec.date_from)) ;

 --AND 	 p_irkv_rec.date_from between okl_insurer_rankings.date_from and nvl(okl_insurer_rankings.date_to,SYSDATE)	;

    CURSOR okl_insurer_rank_v_pk_csr IS
    SELECT 'x'
    FROM okl_insurer_rankings
    WHERE okl_insurer_rankings.id <> p_irkv_rec.id
    AND  okl_insurer_rankings.ic_code = p_irkv_rec.ic_code
    AND  okl_insurer_rankings.ISU_ID = p_irkv_rec.ISU_ID
    And    okl_insurer_rankings.date_from <= p_irkv_rec.date_from
    AND ( p_irkv_rec.date_from <= nvl(okl_insurer_rankings.date_to,p_irkv_rec.date_from)) ;

 -- 	AND 	 p_irkv_rec.date_from between okl_insurer_rankings.date_from and nvl(okl_insurer_rankings.date_to,SYSDATE)	;

      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
      l_dummy_var                    VARCHAR2(1) := '?';
    BEGIN
-------------------------------------------------------------------------------------------------------------
         -- Validation for IC_CODE
      IF ((p_irkv_rec.IC_CODE IS NOT NULL) AND (p_irkv_rec.IC_CODE <> p_db_irkv_rec.IC_CODE))  THEN
		-- enforce foreign key
           OPEN okx_countries_v_pk_csr;
	   FETCH okx_countries_v_pk_csr INTO l_dummy_var;
           CLOSE okx_countries_v_pk_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='?') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'Country',
                               p_token2             => g_parent_table_token,
                               p_token2_value       => 'OKX_COUNTRIES_V',
                               p_token3             => g_child_table_token,
                               p_token3_value       => 'OKL_INSURER_RANKINGS');
          -- notify caller of an error
          l_return_status := OKC_API.G_RET_STS_ERROR;
          return (l_return_status);
        END IF;
      END IF;
---------------------------------------------------------------------------------
     -- Validation for ISU_ID
      IF ((p_irkv_rec.ISU_ID IS NOT NULL) AND (p_irkv_rec.ISU_ID <> p_db_irkv_rec.ISU_ID))  THEN
		-- enforce foreign key
           OPEN okx_insurer_v_pk_csr(p_irkv_rec.isu_id);
	   FETCH okx_insurer_v_pk_csr INTO l_dummy_var;
           CLOSE okx_insurer_v_pk_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='?') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => G_NO_PARENT_RECORD,
                               p_token1             => G_COL_NAME_TOKEN,
                               p_token1_value       => 'Provider',
                               p_token2             => g_parent_table_token,
                               p_token2_value       => 'OKX_INS_PROVIDER_V',
                               p_token3             => g_child_table_token,
                               p_token3_value       => 'OKL_INSURER_RANKINGS');
          -- notify caller of an error
          l_return_status := OKC_API.G_RET_STS_ERROR;
          return (l_return_status);
        END IF;
      END IF;
---------------------------------------------------------------------------------
			--
			l_dummy_var := '?' ;
           OPEN okl_insurer_rankings_v_pk_csr;
	   FETCH okl_insurer_rankings_v_pk_csr INTO l_dummy_var;
           CLOSE okl_insurer_rankings_v_pk_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='x') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => 'OKL_INS_RANK_UNIQUE'
					);
          -- notify caller of an error
          l_return_status := OKC_API.G_RET_STS_ERROR;
          return (l_return_status);
        END IF;

        l_dummy_var := '?' ;
         OPEN okl_insurer_rank_v_pk_csr;
	   FETCH okl_insurer_rank_v_pk_csr INTO l_dummy_var;
           CLOSE okl_insurer_rank_v_pk_csr;
         -- if l_dummy_var is still set to default ,data was not found
         IF (l_dummy_var ='x') THEN
           OKC_API.set_message(p_app_name 	    => G_APP_NAME,
                               p_msg_name           => 'OKL_INS_TWO_RANKS'
					);
          -- notify caller of an error
          l_return_status := OKC_API.G_RET_STS_ERROR;
          return (l_return_status);
        END IF;

 return (l_return_status);
 END validate_foreign_keys;


        ------------------------------------------------
  -- Validate Record for:OKL_INSURER_RANKINGS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_irkv_rec IN irkv_rec_type,
    p_db_irkv_rec IN irkv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	BEGIN
        l_return_status := validate_foreign_keys(p_irkv_rec, p_db_irkv_rec);
        RETURN (l_return_status);
	END Validate_Record ;



      FUNCTION Validate_Record (
        p_irkv_rec IN irkv_rec_type
      ) RETURN VARCHAR2 IS
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_db_irkv_rec                  irkv_rec_type := get_rec(p_irkv_rec);
      BEGIN
         --Validate whether start date is less than the end date only if enddate is not null
          IF (p_irkv_rec.date_to IS NOT NULL)THEN
               l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => p_irkv_rec.date_from
                                                                  ,p_to_date => p_irkv_rec.date_to );
          END IF;
           IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                Okc_Api.set_message(
                                    p_app_name     => g_app_name,
			            p_msg_name     => 'OKL_GREATER_THAN',
			            p_token1       => 'COL_NAME1',
			            p_token1_value => 'Effective To',
			            p_token2       => 'COL_NAME2',
			            p_token2_value => 'Effective From'
			           );
                return (l_return_status);
          END IF;
          IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
             return (l_return_status);
          END IF;

          --Validate whether end date is less than the SYSDATE


	   IF (p_irkv_rec.date_to IS NOT NULL OR p_irkv_rec.date_to <> OKC_API.G_MISS_DATE )THEN
	      l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => trunc(SYSDATE) -- Fix for Bug 3924176.
	                                                         ,p_to_date => p_irkv_rec.date_to);

	   END IF;
	   IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
	   Okc_Api.set_message(
	                        p_app_name     => g_app_name,
	  			p_msg_name     => 'OKL_INVALID_DATE_RANGE',
	  			p_token1       => 'COL_NAME1',
	  			p_token1_value => 'Effective To');
	                  return (l_return_status);
	            END IF;
	            IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
	               return (l_return_status);
	            END IF;


        l_return_status := Validate_Record(p_irkv_rec => p_irkv_rec,
                                           p_db_irkv_rec => l_db_irkv_rec);
        RETURN (l_return_status);
      END Validate_Record;





      ---------------------------------------------------------------------------
      -- PROCEDURE Migrate
      ---------------------------------------------------------------------------
      PROCEDURE migrate (
        p_from IN irkv_rec_type,
        p_to   IN OUT NOCOPY irk_rec_type
      ) IS
      BEGIN
        p_to.id := p_from.id;
        p_to.object_version_number := p_from.object_version_number;
        p_to.ranking_seq := p_from.ranking_seq;
        p_to.date_from := p_from.date_from;
        p_to.date_to := p_from.date_to;
        p_to.isu_id := p_from.isu_id;
        p_to.ic_code := p_from.ic_code;
        p_to.attribute_category := p_from.attribute_category;
        p_to.attribute1 := p_from.attribute1;
        p_to.attribute2 := p_from.attribute2;
        p_to.attribute3 := p_from.attribute3;
        p_to.attribute4 := p_from.attribute4;
        p_to.attribute5 := p_from.attribute5;
        p_to.attribute6 := p_from.attribute6;
        p_to.attribute7 := p_from.attribute7;
        p_to.attribute8 := p_from.attribute8;
        p_to.attribute9 := p_from.attribute9;
        p_to.attribute10 := p_from.attribute10;
        p_to.attribute11 := p_from.attribute11;
        p_to.attribute12 := p_from.attribute12;
        p_to.attribute13 := p_from.attribute13;
        p_to.attribute14 := p_from.attribute14;
        p_to.attribute15 := p_from.attribute15;
        p_to.created_by := p_from.created_by;
        p_to.creation_date := p_from.creation_date;
        p_to.last_updated_by := p_from.last_updated_by;
        p_to.last_update_date := p_from.last_update_date;
        p_to.last_update_login := p_from.last_update_login;
      END migrate;
      PROCEDURE migrate (
        p_from IN irk_rec_type,
        p_to   IN OUT NOCOPY irkv_rec_type
      ) IS
      BEGIN
        p_to.id := p_from.id;
        p_to.ranking_seq := p_from.ranking_seq;
        p_to.object_version_number := p_from.object_version_number;
        p_to.date_from := p_from.date_from;
        p_to.date_to := p_from.date_to;
        p_to.isu_id := p_from.isu_id;
        p_to.ic_code := p_from.ic_code;
        p_to.attribute_category := p_from.attribute_category;
        p_to.attribute1 := p_from.attribute1;
        p_to.attribute2 := p_from.attribute2;
        p_to.attribute3 := p_from.attribute3;
        p_to.attribute4 := p_from.attribute4;
        p_to.attribute5 := p_from.attribute5;
        p_to.attribute6 := p_from.attribute6;
        p_to.attribute7 := p_from.attribute7;
        p_to.attribute8 := p_from.attribute8;
        p_to.attribute9 := p_from.attribute9;
        p_to.attribute10 := p_from.attribute10;
        p_to.attribute11 := p_from.attribute11;
        p_to.attribute12 := p_from.attribute12;
        p_to.attribute13 := p_from.attribute13;
        p_to.attribute14 := p_from.attribute14;
        p_to.attribute15 := p_from.attribute15;
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
      -- validate_row for:OKL_INSURER_RANKINGS_V --
      ---------------------------------------------
      PROCEDURE validate_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_rec                     IN irkv_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irkv_rec                     irkv_rec_type := p_irkv_rec;
        l_irk_rec                      irk_rec_type;
        l_irk_rec                      irk_rec_type;
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
        l_return_status := Validate_Attributes(l_irkv_rec);
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_irkv_rec);
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
      --------------------------------------------------------
      -- PL/SQL TBL validate_row for:OKL_INSURER_RANKINGS_V --
      --------------------------------------------------------
      PROCEDURE validate_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
        i                              NUMBER := 0;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          i := p_irkv_tbl.FIRST;
          LOOP
            DECLARE
              l_error_rec         OKL_API.ERROR_REC_TYPE;
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
                p_irkv_rec                     => p_irkv_tbl(i));
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
            EXIT WHEN (i = p_irkv_tbl.LAST);
            i := p_irkv_tbl.NEXT(i);
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

      --------------------------------------------------------
      -- PL/SQL TBL validate_row for:OKL_INSURER_RANKINGS_V --
      --------------------------------------------------------
      PROCEDURE validate_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_irkv_tbl                     => p_irkv_tbl,
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
      -----------------------------------------
      -- insert_row for:OKL_INSURER_RANKINGS --
      -----------------------------------------
      PROCEDURE insert_row(
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irk_rec                      IN irk_rec_type,
        x_irk_rec                      OUT NOCOPY irk_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irk_rec                      irk_rec_type := p_irk_rec;
        l_def_irk_rec                  irk_rec_type;
        ---------------------------------------------
        -- Set_Attributes for:OKL_INSURER_RANKINGS --
        ---------------------------------------------
        FUNCTION Set_Attributes (
          p_irk_rec IN irk_rec_type,
          x_irk_rec OUT NOCOPY irk_rec_type
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irk_rec := p_irk_rec;
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
          p_irk_rec,                         -- IN
          l_irk_rec);                        -- OUT
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        INSERT INTO OKL_INSURER_RANKINGS(
          id,
          object_version_number,
          ranking_seq,
          date_from,
          date_to,
          isu_id,
          ic_code,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_irk_rec.id,
          l_irk_rec.object_version_number,
          l_irk_rec.ranking_seq,
          l_irk_rec.date_from,
          l_irk_rec.date_to,
          l_irk_rec.isu_id,
          l_irk_rec.ic_code,
          l_irk_rec.attribute_category,
          l_irk_rec.attribute1,
          l_irk_rec.attribute2,
          l_irk_rec.attribute3,
          l_irk_rec.attribute4,
          l_irk_rec.attribute5,
          l_irk_rec.attribute6,
          l_irk_rec.attribute7,
          l_irk_rec.attribute8,
          l_irk_rec.attribute9,
          l_irk_rec.attribute10,
          l_irk_rec.attribute11,
          l_irk_rec.attribute12,
          l_irk_rec.attribute13,
          l_irk_rec.attribute14,
          l_irk_rec.attribute15,
          l_irk_rec.created_by,
          l_irk_rec.creation_date,
          l_irk_rec.last_updated_by,
          l_irk_rec.last_update_date,
          l_irk_rec.last_update_login);
        -- Set OUT values
        x_irk_rec := l_irk_rec;
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
      --------------------------------------------
      -- insert_row for :OKL_INSURER_RANKINGS_V --
      --------------------------------------------
      PROCEDURE insert_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_rec                     IN irkv_rec_type,
        x_irkv_rec                     OUT NOCOPY irkv_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irkv_rec                     irkv_rec_type := p_irkv_rec;
        l_def_irkv_rec                 irkv_rec_type;
        l_irk_rec                      irk_rec_type;
        lx_irk_rec                     irk_rec_type;
        -------------------------------
        -- FUNCTION fill_who_columns --
        -------------------------------
        FUNCTION fill_who_columns (
          p_irkv_rec IN irkv_rec_type
        ) RETURN irkv_rec_type IS
          l_irkv_rec irkv_rec_type := p_irkv_rec;
        BEGIN
          l_irkv_rec.CREATION_DATE := SYSDATE;
          l_irkv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
          l_irkv_rec.LAST_UPDATE_DATE := l_irkv_rec.CREATION_DATE;
          l_irkv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
          l_irkv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
          RETURN(l_irkv_rec);
        END fill_who_columns;
        -----------------------------------------------
        -- Set_Attributes for:OKL_INSURER_RANKINGS_V --
        -----------------------------------------------
        FUNCTION Set_Attributes (
          p_irkv_rec IN irkv_rec_type,
          x_irkv_rec OUT NOCOPY irkv_rec_type
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irkv_rec := p_irkv_rec;
          x_irkv_rec.OBJECT_VERSION_NUMBER := 1;
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
        l_irkv_rec := null_out_defaults(p_irkv_rec);
        -- Set primary key value
        l_irkv_rec.ID := get_seq_id;
        -- Setting item attributes
        l_return_Status := Set_Attributes(
          l_irkv_rec,                        -- IN
          l_def_irkv_rec);                   -- OUT
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_irkv_rec := fill_who_columns(l_def_irkv_rec);
        --- Validate all non-missing attributes (Item Level Validation)
        l_return_status := Validate_Attributes(l_def_irkv_rec);
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := Validate_Record(l_def_irkv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        -----------------------------------------
        -- Move VIEW record to "Child" records --
        -----------------------------------------
        migrate(l_def_irkv_rec, l_irk_rec);
        -----------------------------------------------
        -- Call the INSERT_ROW for each child record --
        -----------------------------------------------
        insert_row(
          p_init_msg_list,
          l_return_status,
          x_msg_count,
          x_msg_data,
          l_irk_rec,
          lx_irk_rec
        );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_irk_rec, l_def_irkv_rec);
        -- Set OUT values
        x_irkv_rec := l_def_irkv_rec;
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
      ----------------------------------------
      -- PL/SQL TBL insert_row for:IRKV_TBL --
      ----------------------------------------
      PROCEDURE insert_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        x_irkv_tbl                     OUT NOCOPY irkv_tbl_type,
        px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
        i                              NUMBER := 0;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          i := p_irkv_tbl.FIRST;
          LOOP
            DECLARE
              l_error_rec         OKL_API.ERROR_REC_TYPE;
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
                p_irkv_rec                     => p_irkv_tbl(i),
                x_irkv_rec                     => x_irkv_tbl(i));
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
            EXIT WHEN (i = p_irkv_tbl.LAST);
            i := p_irkv_tbl.NEXT(i);
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

      ----------------------------------------
      -- PL/SQL TBL insert_row for:IRKV_TBL --
      ----------------------------------------
      PROCEDURE insert_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        x_irkv_tbl                     OUT NOCOPY irkv_tbl_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_irkv_tbl                     => p_irkv_tbl,
            x_irkv_tbl                     => x_irkv_tbl,
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
      ---------------------------------------
      -- lock_row for:OKL_INSURER_RANKINGS --
      ---------------------------------------
      PROCEDURE lock_row(
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irk_rec                      IN irk_rec_type) IS

        E_Resource_Busy                EXCEPTION;
        PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
        CURSOR lock_csr (p_irk_rec IN irk_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKL_INSURER_RANKINGS
         WHERE ID = p_irk_rec.id
           AND OBJECT_VERSION_NUMBER = p_irk_rec.object_version_number
        FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

        CURSOR lchk_csr (p_irk_rec IN irk_rec_type) IS
        SELECT OBJECT_VERSION_NUMBER
          FROM OKL_INSURER_RANKINGS
         WHERE ID = p_irk_rec.id;
        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_object_version_number        OKL_INSURER_RANKINGS.OBJECT_VERSION_NUMBER%TYPE;
        lc_object_version_number       OKL_INSURER_RANKINGS.OBJECT_VERSION_NUMBER%TYPE;
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
          OPEN lock_csr(p_irk_rec);
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
          OPEN lchk_csr(p_irk_rec);
          FETCH lchk_csr INTO lc_object_version_number;
          lc_row_notfound := lchk_csr%NOTFOUND;
          CLOSE lchk_csr;
        END IF;
        IF (lc_row_notfound) THEN
          OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
          RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number > p_irk_rec.object_version_number THEN
          OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
          RAISE OKC_API.G_EXCEPTION_ERROR;
        ELSIF lc_object_version_number <> p_irk_rec.object_version_number THEN
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
      ------------------------------------------
      -- lock_row for: OKL_INSURER_RANKINGS_V --
      ------------------------------------------
      PROCEDURE lock_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_rec                     IN irkv_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irk_rec                      irk_rec_type;
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
        migrate(p_irkv_rec, l_irk_rec);
        ---------------------------------------------
        -- Call the LOCK_ROW for each child record --
        ---------------------------------------------
        lock_row(
          p_init_msg_list,
          l_return_status,
          x_msg_count,
          x_msg_data,
          l_irk_rec
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
      --------------------------------------
      -- PL/SQL TBL lock_row for:IRKV_TBL --
      --------------------------------------
      PROCEDURE lock_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
        i                              NUMBER := 0;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has recrods in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          i := p_irkv_tbl.FIRST;
          LOOP
            DECLARE
              l_error_rec         OKL_API.ERROR_REC_TYPE;
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
                p_irkv_rec                     => p_irkv_tbl(i));
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
            EXIT WHEN (i = p_irkv_tbl.LAST);
            i := p_irkv_tbl.NEXT(i);
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
      --------------------------------------
      -- PL/SQL TBL lock_row for:IRKV_TBL --
      --------------------------------------
      PROCEDURE lock_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has recrods in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_irkv_tbl                     => p_irkv_tbl,
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
      -----------------------------------------
      -- update_row for:OKL_INSURER_RANKINGS --
      -----------------------------------------
      PROCEDURE update_row(
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irk_rec                      IN irk_rec_type,
        x_irk_rec                      OUT NOCOPY irk_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irk_rec                      irk_rec_type := p_irk_rec;
        l_def_irk_rec                  irk_rec_type;
        l_row_notfound                 BOOLEAN := TRUE;
        ----------------------------------
        -- FUNCTION populate_new_record --
        ----------------------------------
        FUNCTION populate_new_record (
          p_irk_rec IN irk_rec_type,
          x_irk_rec OUT NOCOPY irk_rec_type
        ) RETURN VARCHAR2 IS
          l_irk_rec                      irk_rec_type;
          l_row_notfound                 BOOLEAN := TRUE;
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irk_rec := p_irk_rec;
          -- Get current database values
          l_irk_rec := get_rec(p_irk_rec, l_return_status);
          IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
            IF (x_irk_rec.id = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.id := l_irk_rec.id;
            END IF;
            IF (x_irk_rec.object_version_number = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.object_version_number := l_irk_rec.object_version_number;
            END IF;
            IF (x_irk_rec.ranking_seq = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.ranking_seq := l_irk_rec.ranking_seq;
            END IF;
            IF (x_irk_rec.date_from = OKC_API.G_MISS_DATE)
            THEN
              x_irk_rec.date_from := l_irk_rec.date_from;
            END IF;
            IF (x_irk_rec.date_to = OKC_API.G_MISS_DATE)
            THEN
              x_irk_rec.date_to := l_irk_rec.date_to;
            END IF;
            IF (x_irk_rec.isu_id = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.isu_id := l_irk_rec.isu_id;
            END IF;
            IF (x_irk_rec.ic_code = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.ic_code := l_irk_rec.ic_code;
            END IF;
            IF (x_irk_rec.attribute_category = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute_category := l_irk_rec.attribute_category;
            END IF;
            IF (x_irk_rec.attribute1 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute1 := l_irk_rec.attribute1;
            END IF;
            IF (x_irk_rec.attribute2 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute2 := l_irk_rec.attribute2;
            END IF;
            IF (x_irk_rec.attribute3 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute3 := l_irk_rec.attribute3;
            END IF;
            IF (x_irk_rec.attribute4 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute4 := l_irk_rec.attribute4;
            END IF;
            IF (x_irk_rec.attribute5 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute5 := l_irk_rec.attribute5;
            END IF;
            IF (x_irk_rec.attribute6 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute6 := l_irk_rec.attribute6;
            END IF;
            IF (x_irk_rec.attribute7 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute7 := l_irk_rec.attribute7;
            END IF;
            IF (x_irk_rec.attribute8 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute8 := l_irk_rec.attribute8;
            END IF;
            IF (x_irk_rec.attribute9 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute9 := l_irk_rec.attribute9;
            END IF;
            IF (x_irk_rec.attribute10 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute10 := l_irk_rec.attribute10;
            END IF;
            IF (x_irk_rec.attribute11 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute11 := l_irk_rec.attribute11;
            END IF;
            IF (x_irk_rec.attribute12 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute12 := l_irk_rec.attribute12;
            END IF;
            IF (x_irk_rec.attribute13 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute13 := l_irk_rec.attribute13;
            END IF;
            IF (x_irk_rec.attribute14 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute14 := l_irk_rec.attribute14;
            END IF;
            IF (x_irk_rec.attribute15 = OKC_API.G_MISS_CHAR)
            THEN
              x_irk_rec.attribute15 := l_irk_rec.attribute15;
            END IF;
            IF (x_irk_rec.created_by = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.created_by := l_irk_rec.created_by;
            END IF;
            IF (x_irk_rec.creation_date = OKC_API.G_MISS_DATE)
            THEN
              x_irk_rec.creation_date := l_irk_rec.creation_date;
            END IF;
            IF (x_irk_rec.last_updated_by = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.last_updated_by := l_irk_rec.last_updated_by;
            END IF;
            IF (x_irk_rec.last_update_date = OKC_API.G_MISS_DATE)
            THEN
              x_irk_rec.last_update_date := l_irk_rec.last_update_date;
            END IF;
            IF (x_irk_rec.last_update_login = OKC_API.G_MISS_NUM)
            THEN
              x_irk_rec.last_update_login := l_irk_rec.last_update_login;
            END IF;
          END IF;
          RETURN(l_return_status);
        END populate_new_record;
        ---------------------------------------------
        -- Set_Attributes for:OKL_INSURER_RANKINGS --
        ---------------------------------------------
        FUNCTION Set_Attributes (
          p_irk_rec IN irk_rec_type,
          x_irk_rec OUT NOCOPY irk_rec_type
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irk_rec := p_irk_rec;
          x_irk_rec.OBJECT_VERSION_NUMBER := p_irk_rec.OBJECT_VERSION_NUMBER + 1;
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
          p_irk_rec,                         -- IN
          l_irk_rec);                        -- OUT
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_irk_rec, l_def_irk_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        UPDATE OKL_INSURER_RANKINGS
        SET OBJECT_VERSION_NUMBER = l_def_irk_rec.object_version_number,
            RANKING_SEQ = l_def_irk_rec.ranking_seq,
            DATE_FROM = l_def_irk_rec.date_from,
            DATE_TO = l_def_irk_rec.date_to,
            ISU_ID = l_def_irk_rec.isu_id,
            IC_CODE = l_def_irk_rec.ic_code,
            ATTRIBUTE_CATEGORY = l_def_irk_rec.attribute_category,
            ATTRIBUTE1 = l_def_irk_rec.attribute1,
            ATTRIBUTE2 = l_def_irk_rec.attribute2,
            ATTRIBUTE3 = l_def_irk_rec.attribute3,
            ATTRIBUTE4 = l_def_irk_rec.attribute4,
            ATTRIBUTE5 = l_def_irk_rec.attribute5,
            ATTRIBUTE6 = l_def_irk_rec.attribute6,
            ATTRIBUTE7 = l_def_irk_rec.attribute7,
            ATTRIBUTE8 = l_def_irk_rec.attribute8,
            ATTRIBUTE9 = l_def_irk_rec.attribute9,
            ATTRIBUTE10 = l_def_irk_rec.attribute10,
            ATTRIBUTE11 = l_def_irk_rec.attribute11,
            ATTRIBUTE12 = l_def_irk_rec.attribute12,
            ATTRIBUTE13 = l_def_irk_rec.attribute13,
            ATTRIBUTE14 = l_def_irk_rec.attribute14,
            ATTRIBUTE15 = l_def_irk_rec.attribute15,
            CREATED_BY = l_def_irk_rec.created_by,
            CREATION_DATE = l_def_irk_rec.creation_date,
            LAST_UPDATED_BY = l_def_irk_rec.last_updated_by,
            LAST_UPDATE_DATE = l_def_irk_rec.last_update_date,
            LAST_UPDATE_LOGIN = l_def_irk_rec.last_update_login
        WHERE ID = l_def_irk_rec.id;

        x_irk_rec := l_irk_rec;
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
      -------------------------------------------
      -- update_row for:OKL_INSURER_RANKINGS_V --
      -------------------------------------------
      PROCEDURE update_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_rec                     IN irkv_rec_type,
        x_irkv_rec                     OUT NOCOPY irkv_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irkv_rec                     irkv_rec_type := p_irkv_rec;
        l_def_irkv_rec                 irkv_rec_type;
        l_def_irkv_rec2                 irkv_rec_type;
        l_db_irkv_rec                  irkv_rec_type;
        l_irk_rec                      irk_rec_type;
        lx_irk_rec                     irk_rec_type;
        -------------------------------
        -- FUNCTION fill_who_columns --
        -------------------------------
        FUNCTION fill_who_columns (
          p_irkv_rec IN irkv_rec_type
        ) RETURN irkv_rec_type IS
          l_irkv_rec irkv_rec_type := p_irkv_rec;
        BEGIN
          l_irkv_rec.LAST_UPDATE_DATE := SYSDATE;
          l_irkv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
          l_irkv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
          RETURN(l_irkv_rec);
        END fill_who_columns;
        ----------------------------------
        -- FUNCTION populate_new_record --
        ----------------------------------
        FUNCTION populate_new_record (
          p_irkv_rec IN irkv_rec_type,
          x_irkv_rec OUT NOCOPY irkv_rec_type
        ) RETURN VARCHAR2 IS
          l_row_notfound                 BOOLEAN := TRUE;
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irkv_rec := p_irkv_rec;
          -- Get current database values
          -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
          --       so it may be verified through LOCK_ROW.
          l_db_irkv_rec := get_rec(p_irkv_rec, l_return_status);
          IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
            IF (x_irkv_rec.id = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.id := l_db_irkv_rec.id;
            END IF;
            IF (x_irkv_rec.ranking_seq = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.ranking_seq := l_db_irkv_rec.ranking_seq;
            END IF;
            IF (x_irkv_rec.date_from = OKC_API.G_MISS_DATE)
            THEN
              x_irkv_rec.date_from := l_db_irkv_rec.date_from;
            END IF;
            IF (x_irkv_rec.date_to = OKC_API.G_MISS_DATE)
            THEN
              x_irkv_rec.date_to := l_db_irkv_rec.date_to;
            END IF;
            IF (x_irkv_rec.isu_id = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.isu_id := l_db_irkv_rec.isu_id;
            END IF;
            IF (x_irkv_rec.ic_code = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.ic_code := l_db_irkv_rec.ic_code;
            END IF;
            IF (x_irkv_rec.attribute_category = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute_category := l_db_irkv_rec.attribute_category;
            END IF;
            IF (x_irkv_rec.attribute1 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute1 := l_db_irkv_rec.attribute1;
            END IF;
            IF (x_irkv_rec.attribute2 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute2 := l_db_irkv_rec.attribute2;
            END IF;
            IF (x_irkv_rec.attribute3 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute3 := l_db_irkv_rec.attribute3;
            END IF;
            IF (x_irkv_rec.attribute4 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute4 := l_db_irkv_rec.attribute4;
            END IF;
            IF (x_irkv_rec.attribute5 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute5 := l_db_irkv_rec.attribute5;
            END IF;
            IF (x_irkv_rec.attribute6 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute6 := l_db_irkv_rec.attribute6;
            END IF;
            IF (x_irkv_rec.attribute7 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute7 := l_db_irkv_rec.attribute7;
            END IF;
            IF (x_irkv_rec.attribute8 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute8 := l_db_irkv_rec.attribute8;
            END IF;
            IF (x_irkv_rec.attribute9 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute9 := l_db_irkv_rec.attribute9;
            END IF;
            IF (x_irkv_rec.attribute10 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute10 := l_db_irkv_rec.attribute10;
            END IF;
            IF (x_irkv_rec.attribute11 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute11 := l_db_irkv_rec.attribute11;
            END IF;
            IF (x_irkv_rec.attribute12 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute12 := l_db_irkv_rec.attribute12;
            END IF;
            IF (x_irkv_rec.attribute13 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute13 := l_db_irkv_rec.attribute13;
            END IF;
            IF (x_irkv_rec.attribute14 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute14 := l_db_irkv_rec.attribute14;
            END IF;
            IF (x_irkv_rec.attribute15 = OKC_API.G_MISS_CHAR)
            THEN
              x_irkv_rec.attribute15 := l_db_irkv_rec.attribute15;
            END IF;
            IF (x_irkv_rec.created_by = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.created_by := l_db_irkv_rec.created_by;
            END IF;
            IF (x_irkv_rec.creation_date = OKC_API.G_MISS_DATE)
            THEN
              x_irkv_rec.creation_date := l_db_irkv_rec.creation_date;
            END IF;
            IF (x_irkv_rec.last_updated_by = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.last_updated_by := l_db_irkv_rec.last_updated_by;
            END IF;
            IF (x_irkv_rec.last_update_date = OKC_API.G_MISS_DATE)
            THEN
              x_irkv_rec.last_update_date := l_db_irkv_rec.last_update_date;
            END IF;
            IF (x_irkv_rec.last_update_login = OKC_API.G_MISS_NUM)
            THEN
              x_irkv_rec.last_update_login := l_db_irkv_rec.last_update_login;
            END IF;
          END IF;
          RETURN(l_return_status);
        END populate_new_record;
        -----------------------------------------------
        -- Set_Attributes for:OKL_INSURER_RANKINGS_V --
        -----------------------------------------------
        FUNCTION Set_Attributes (
          p_irkv_rec IN irkv_rec_type,
          x_irkv_rec OUT NOCOPY irkv_rec_type
        ) RETURN VARCHAR2 IS
          l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        BEGIN
          x_irkv_rec := p_irkv_rec;
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
          p_irkv_rec,                        -- IN
          x_irkv_rec);                       -- OUT
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_return_status := populate_new_record(l_irkv_rec, l_def_irkv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        l_def_irkv_rec := fill_who_columns(l_def_irkv_rec);
        --- Validate all non-missing attributes (Item Level Validation)
        -- To enable object_version_number increment
        l_def_irkv_rec2 := l_def_irkv_rec ;
        l_def_irkv_rec2.object_version_number := l_def_irkv_rec.object_version_number + 1;

        l_return_status := Validate_Attributes(l_def_irkv_rec2);
        --- If any errors happen abort API
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        --l_return_status := Validate_Record(l_def_irkv_rec, l_db_irkv_rec);
        l_return_status := Validate_Record(l_irkv_rec);
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
          p_irkv_rec                     => p_irkv_rec);
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;

        -----------------------------------------
        -- Move VIEW record to "Child" records --
        -----------------------------------------
        migrate(l_def_irkv_rec, l_irk_rec);
        -----------------------------------------------
        -- Call the UPDATE_ROW for each child record --
        -----------------------------------------------
        update_row(
          p_init_msg_list,
          l_return_status,
          x_msg_count,
          x_msg_data,
          l_irk_rec,
          lx_irk_rec
        );
        IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
        ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
          RAISE OKC_API.G_EXCEPTION_ERROR;
        END IF;
        migrate(lx_irk_rec, l_def_irkv_rec);
        x_irkv_rec := l_def_irkv_rec;
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
      ----------------------------------------
      -- PL/SQL TBL update_row for:irkv_tbl --
      ----------------------------------------
      PROCEDURE update_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        x_irkv_tbl                     OUT NOCOPY irkv_tbl_type,
        px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
        i                              NUMBER := 0;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          i := p_irkv_tbl.FIRST;
          LOOP
            DECLARE
              l_error_rec         OKL_API.ERROR_REC_TYPE;
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
                p_irkv_rec                     => p_irkv_tbl(i),
                x_irkv_rec                     => x_irkv_tbl(i));
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
            EXIT WHEN (i = p_irkv_tbl.LAST);
            i := p_irkv_tbl.NEXT(i);
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

      ----------------------------------------
      -- PL/SQL TBL update_row for:IRKV_TBL --
      ----------------------------------------
      PROCEDURE update_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        x_irkv_tbl                     OUT NOCOPY irkv_tbl_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_irkv_tbl                     => p_irkv_tbl,
            x_irkv_tbl                     => x_irkv_tbl,
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
      -----------------------------------------
      -- delete_row for:OKL_INSURER_RANKINGS --
      -----------------------------------------
      PROCEDURE delete_row(
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irk_rec                      IN irk_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irk_rec                      irk_rec_type := p_irk_rec;
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

        DELETE FROM OKL_INSURER_RANKINGS
         WHERE ID = p_irk_rec.id;

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
      -------------------------------------------
      -- delete_row for:OKL_INSURER_RANKINGS_V --
      -------------------------------------------
      PROCEDURE delete_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_rec                     IN irkv_rec_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_irkv_rec                     irkv_rec_type := p_irkv_rec;
        l_irk_rec                      irk_rec_type;
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
        migrate(l_irkv_rec, l_irk_rec);
        -----------------------------------------------
        -- Call the DELETE_ROW for each child record --
        -----------------------------------------------
        delete_row(
          p_init_msg_list,
          l_return_status,
          x_msg_count,
          x_msg_data,
          l_irk_rec
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
      ------------------------------------------------------
      -- PL/SQL TBL delete_row for:OKL_INSURER_RANKINGS_V --
      ------------------------------------------------------
      PROCEDURE delete_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type,
        px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
        i                              NUMBER := 0;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          i := p_irkv_tbl.FIRST;
          LOOP
            DECLARE
              l_error_rec         OKL_API.ERROR_REC_TYPE;
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
                p_irkv_rec                     => p_irkv_tbl(i));
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
            EXIT WHEN (i = p_irkv_tbl.LAST);
            i := p_irkv_tbl.NEXT(i);
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

      ------------------------------------------------------
      -- PL/SQL TBL delete_row for:OKL_INSURER_RANKINGS_V --
      ------------------------------------------------------
      PROCEDURE delete_row(
        p_api_version                  IN NUMBER,
        p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
        x_return_status                OUT NOCOPY VARCHAR2,
        x_msg_count                    OUT NOCOPY NUMBER,
        x_msg_data                     OUT NOCOPY VARCHAR2,
        p_irkv_tbl                     IN irkv_tbl_type) IS

        l_api_version                  CONSTANT NUMBER := 1;
        l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
        l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
        l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
      BEGIN
        OKC_API.init_msg_list(p_init_msg_list);
        -- Make sure PL/SQL table has records in it before passing
        IF (p_irkv_tbl.COUNT > 0) THEN
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => x_return_status,
            x_msg_count                    => x_msg_count,
            x_msg_data                     => x_msg_data,
            p_irkv_tbl                     => p_irkv_tbl,
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

    END OKL_IRK_PVT;

/
