--------------------------------------------------------
--  DDL for Package Body OKL_QCO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QCO_PVT" AS
/* $Header: OKLSQCOB.pls 120.4 2006/07/11 10:26:25 dkagrawa noship $ */
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
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
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
  -- FUNCTION get_rec for: OKL_TRX_QTE_CF_OBJECTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qcov_rec                     IN qcov_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qcov_rec_type IS
    CURSOR okl_qcov_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            QTE_ID,
            CFO_ID,
            BASE_SOURCE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            attribute_category,
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
            ATTRIBUTE15
      FROM Okl_Trx_Qte_Cf_Objects_V
     WHERE okl_trx_qte_cf_objects_v.id = p_id;
    l_okl_qcov_pk                  okl_qcov_pk_csr%ROWTYPE;
    l_qcov_rec                     qcov_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_qcov_pk_csr (p_qcov_rec.id);
    FETCH okl_qcov_pk_csr INTO
              l_qcov_rec.id,
              l_qcov_rec.qte_id,
              l_qcov_rec.cfo_id,
              l_qcov_rec.base_source_id,
              l_qcov_rec.object_version_number,
              l_qcov_rec.created_by,
              l_qcov_rec.creation_date,
              l_qcov_rec.last_updated_by,
              l_qcov_rec.last_update_date,
              l_qcov_rec.last_update_login,
              l_qcov_rec.attribute_category,
              l_qcov_rec.attribute1,
              l_qcov_rec.attribute2,
              l_qcov_rec.attribute3,
              l_qcov_rec.attribute4,
              l_qcov_rec.attribute5,
              l_qcov_rec.attribute6,
              l_qcov_rec.attribute7,
              l_qcov_rec.attribute8,
              l_qcov_rec.attribute9,
              l_qcov_rec.attribute10,
              l_qcov_rec.attribute11,
              l_qcov_rec.attribute12,
              l_qcov_rec.attribute13,
              l_qcov_rec.attribute14,
              l_qcov_rec.attribute15;
    x_no_data_found := okl_qcov_pk_csr%NOTFOUND;
    CLOSE okl_qcov_pk_csr;
    RETURN(l_qcov_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_qcov_rec                     IN qcov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN qcov_rec_type IS
    l_qcov_rec                     qcov_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_rec := get_rec(p_qcov_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_qcov_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_qcov_rec                     IN qcov_rec_type
  ) RETURN qcov_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qcov_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_TRX_QTE_CF_OBJECTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qco_rec                      IN qco_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qco_rec_type IS
    CURSOR okl_trx_quotes_cf_o1 (p_id IN NUMBER) IS
    SELECT
            ID,
            QTE_ID,
            CFO_ID,
            BASE_SOURCE_ID,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
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
            ATTRIBUTE15
      FROM Okl_Trx_Qte_Cf_Objects
     WHERE okl_trx_qte_cf_objects.id = p_id;
    l_okl_trx_quotes_cf_objects_pk okl_trx_quotes_cf_o1%ROWTYPE;
    l_qco_rec                      qco_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_trx_quotes_cf_o1 (p_qco_rec.id);
    FETCH okl_trx_quotes_cf_o1 INTO
              l_qco_rec.id,
              l_qco_rec.qte_id,
              l_qco_rec.cfo_id,
              l_qco_rec.base_source_id,
              l_qco_rec.object_version_number,
              l_qco_rec.created_by,
              l_qco_rec.creation_date,
              l_qco_rec.last_updated_by,
              l_qco_rec.last_update_date,
              l_qco_rec.last_update_login,
              l_qco_rec.attribute_category,
              l_qco_rec.attribute1,
              l_qco_rec.attribute2,
              l_qco_rec.attribute3,
              l_qco_rec.attribute4,
              l_qco_rec.attribute5,
              l_qco_rec.attribute6,
              l_qco_rec.attribute7,
              l_qco_rec.attribute8,
              l_qco_rec.attribute9,
              l_qco_rec.attribute10,
              l_qco_rec.attribute11,
              l_qco_rec.attribute12,
              l_qco_rec.attribute13,
              l_qco_rec.attribute14,
              l_qco_rec.attribute15;
    x_no_data_found := okl_trx_quotes_cf_o1%NOTFOUND;
    CLOSE okl_trx_quotes_cf_o1;
    RETURN(l_qco_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_qco_rec                      IN qco_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN qco_rec_type IS
    l_qco_rec                      qco_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKL_API.G_RET_STS_SUCCESS;
    l_qco_rec := get_rec(p_qco_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKL_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_qco_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_qco_rec                      IN qco_rec_type
  ) RETURN qco_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qco_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_TRX_QTE_CF_OBJECTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qcov_rec   IN qcov_rec_type
  ) RETURN qcov_rec_type IS
    l_qcov_rec                     qcov_rec_type := p_qcov_rec;
  BEGIN
    IF (l_qcov_rec.id = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.id := NULL;
    END IF;
    IF (l_qcov_rec.qte_id = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.qte_id := NULL;
    END IF;
    IF (l_qcov_rec.cfo_id = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.cfo_id := NULL;
    END IF;
    IF (l_qcov_rec.base_source_id = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.base_source_id := NULL;
    END IF;
    IF (l_qcov_rec.object_version_number = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.object_version_number := NULL;
    END IF;
    IF (l_qcov_rec.created_by = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.created_by := NULL;
    END IF;
    IF (l_qcov_rec.creation_date = OKL_API.G_MISS_DATE ) THEN
      l_qcov_rec.creation_date := NULL;
    END IF;
    IF (l_qcov_rec.last_updated_by = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.last_updated_by := NULL;
    END IF;
    IF (l_qcov_rec.last_update_date = OKL_API.G_MISS_DATE ) THEN
      l_qcov_rec.last_update_date := NULL;
    END IF;
    IF (l_qcov_rec.last_update_login = OKL_API.G_MISS_NUM ) THEN
      l_qcov_rec.last_update_login := NULL;
    END IF;
    IF (l_qcov_rec.attribute_category = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute_category := NULL;
    END IF;
    IF (l_qcov_rec.attribute1 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute1 := NULL;
    END IF;
    IF (l_qcov_rec.attribute2 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute2 := NULL;
    END IF;
    IF (l_qcov_rec.attribute3 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute3 := NULL;
    END IF;
    IF (l_qcov_rec.attribute4 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute4 := NULL;
    END IF;
    IF (l_qcov_rec.attribute5 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute5 := NULL;
    END IF;
    IF (l_qcov_rec.attribute6 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute6 := NULL;
    END IF;
    IF (l_qcov_rec.attribute7 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute7 := NULL;
    END IF;
    IF (l_qcov_rec.attribute8 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute8 := NULL;
    END IF;
    IF (l_qcov_rec.attribute9 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute9 := NULL;
    END IF;
    IF (l_qcov_rec.attribute10 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute10 := NULL;
    END IF;
    IF (l_qcov_rec.attribute11 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute11 := NULL;
    END IF;
    IF (l_qcov_rec.attribute12 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute12 := NULL;
    END IF;
    IF (l_qcov_rec.attribute13 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute13 := NULL;
    END IF;
    IF (l_qcov_rec.attribute14 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute14 := NULL;
    END IF;
    IF (l_qcov_rec.attribute15 = OKL_API.G_MISS_CHAR ) THEN
      l_qcov_rec.attribute15 := NULL;
    END IF;
    RETURN(l_qcov_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    p_qcov_rec                     IN  qcov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_qcov_rec.id = OKL_API.G_MISS_NUM OR p_qcov_rec.id IS NULL) THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  -------------------------------------
  -- Validate_Attributes for: QTE_ID --
  -------------------------------------
  PROCEDURE validate_qte_id(
    p_qcov_rec                     IN qcov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;
    l_dummy_req_var         VARCHAR2(1) := '?' ;
    CURSOR okl_qcov_qtev_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Trx_Quotes_V
       WHERE okl_trx_quotes_v.id  = p_id;

    CURSOR okl_qcov_trxv_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM OKL_TRX_REQUESTS
       WHERE OKL_TRX_REQUESTS.id  = p_id;


  BEGIN
   IF (p_qcov_rec.qte_id = OKL_API.G_MISS_NUM OR p_qcov_rec.qte_id IS NULL)
    THEN

      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'qte_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
   ELSE
      -- enforce foreign key
        OPEN   okl_qcov_qtev_fk_csr(p_qcov_rec.qte_id) ;
        FETCH  okl_qcov_qtev_fk_csr into l_dummy_var ;
        CLOSE  okl_qcov_qtev_fk_csr ;



        -- still set to default means data was not found
        IF ( l_dummy_var = '?' ) THEN
            OPEN   okl_qcov_trxv_fk_csr(p_qcov_rec.qte_id) ;
            FETCH  okl_qcov_trxv_fk_csr into l_dummy_req_var ;
            CLOSE  okl_qcov_trxv_fk_csr ;

            IF ( l_dummy_req_var = '?' ) THEN

               OKC_API.set_message(g_app_name,
                            g_no_parent_record,
                            g_col_name_token,
                            'qte_id',
                            g_child_table_token ,
                            'OKL_TRX_QTE_CF_OBJECTS_V',
                            g_parent_table_token ,
                            'OKL_TRX_QUOTES_V OR OKL_TRX_REQUESTS');
                l_return_status := OKC_API.G_RET_STS_ERROR;
           END IF;

        END IF;

   END IF;
   x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;


  END validate_qte_id;
  -------------------------------------
  -- Validate_Attributes for: CFO_ID --
  -------------------------------------
  PROCEDURE validate_cfo_id(
    p_qcov_rec                     IN  qcov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_dummy_var         VARCHAR2(1) := '?' ;
    CURSOR okl_qcov_cfov_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Cash_Flow_Objects_V
       WHERE okl_cash_flow_objects_v.id = p_id;

  BEGIN

    IF (p_qcov_rec.cfo_id = OKL_API.G_MISS_NUM OR p_qcov_rec.cfo_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'cfo_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    ELSE
      -- enforce foreign key
      OPEN   okl_qcov_cfov_fk_csr(p_qcov_rec.cfo_id) ;
      FETCH  okl_qcov_cfov_fk_csr into l_dummy_var ;
      CLOSE  okl_qcov_cfov_fk_csr ;
      -- still set to default means data was not found
      IF ( l_dummy_var = '?' ) THEN
           OKC_API.set_message(g_app_name,
                        g_no_parent_record,
                        g_col_name_token,
                        'cfo_id',
                        g_child_table_token ,
                        'OKL_TRX_QTE_CF_OBJECTS_V',
                        g_parent_table_token ,
                        'OKL_CASH_FLOW_OBJECTS_V');
           l_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_cfo_id;
  ---------------------------------------------
  -- Validate_Attributes for: BASE_SOURCE_ID --
  ---------------------------------------------
  PROCEDURE validate_base_source_id(
    p_qcov_rec                     IN  qcov_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_qcov_rec.base_source_id = OKL_API.G_MISS_NUM OR p_qcov_rec.base_source_id IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'base_source_id');
      l_return_status := OKL_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_base_source_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
     p_qcov_rec                     IN qcov_rec_type,
     x_return_status                OUT NOCOPY VARCHAR2) IS
     l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    IF (p_qcov_rec.object_version_number = OKL_API.G_MISS_NUM OR p_qcov_rec.object_version_number IS NULL)
    THEN
      OKL_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      l_return_status := OKL_API.G_RET_STS_ERROR;

    END IF;
    x_return_status := l_return_status;
  EXCEPTION

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------------
  -- Validate_Attributes for:OKL_TRX_QTE_CF_OBJECTS_V --
  --------------------------------------------------------
  FUNCTION Validate_Attributes (
    p_qcov_rec                     IN qcov_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(p_qcov_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- qte_id
    -- ***
    validate_qte_id(p_qcov_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- cfo_id
    -- ***
    validate_cfo_id(p_qcov_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- base_source_id
    -- ***
    validate_base_source_id(p_qcov_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(p_qcov_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;

    RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------

  /* SECHAWLA - Not needed, as foreign key validation was moved under individual validate_ procedures
  ----------------------------------------------------
  -- Validate Record for:OKL_TRX_QTE_CF_OBJECTS_V --
  ----------------------------------------------------
  FUNCTION Validate_Record (
    p_qcov_rec IN qcov_rec_type,
    p_db_qcov_rec IN qcov_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    ------------------------------------
    -- FUNCTION validate_foreign_keys --
    ------------------------------------
    FUNCTION validate_foreign_keys (
      p_qcov_rec IN qcov_rec_type,
      p_db_qcov_rec IN qcov_rec_type
    ) RETURN VARCHAR2 IS
      item_not_found_error           EXCEPTION;
      CURSOR okl_qcov_cfov_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Cash_Flow_Objects_V
       WHERE okl_cash_flow_objects_v.id = p_id;
      l_okl_qcov_cfov_fk             okl_qcov_cfov_fk_csr%ROWTYPE;

      CURSOR okl_qcov_qtev_fk_csr (p_id IN NUMBER) IS
      SELECT 'x'
        FROM Okl_Trx_Quotes_V
       WHERE okl_trx_quotes_v.id  = p_id;
      l_okl_qcov_qtev_fk             okl_qcov_qtev_fk_csr%ROWTYPE;

      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
      l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      IF ((p_qcov_rec.CFO_ID IS NOT NULL)
       AND
          (p_qcov_rec.CFO_ID <> p_db_qcov_rec.CFO_ID))
      THEN
        OPEN okl_qcov_cfov_fk_csr (p_qcov_rec.CFO_ID);
        FETCH okl_qcov_cfov_fk_csr INTO l_okl_qcov_cfov_fk;
        l_row_notfound := okl_qcov_cfov_fk_csr%NOTFOUND;
        CLOSE okl_qcov_cfov_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'CFO_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      IF ((p_qcov_rec.QTE_ID IS NOT NULL)
       AND
          (p_qcov_rec.QTE_ID <> p_db_qcov_rec.QTE_ID))
      THEN
        OPEN okl_qcov_qtev_fk_csr (p_qcov_rec.QTE_ID);
        FETCH okl_qcov_qtev_fk_csr INTO l_okl_qcov_qtev_fk;
        l_row_notfound := okl_qcov_qtev_fk_csr%NOTFOUND;
        CLOSE okl_qcov_qtev_fk_csr;
        IF (l_row_notfound) THEN
          OKL_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'QTE_ID');
          RAISE item_not_found_error;
        END IF;
      END IF;
      RETURN (l_return_status);
    EXCEPTION
      WHEN item_not_found_error THEN
        l_return_status := OKL_API.G_RET_STS_ERROR;
        RETURN (l_return_status);
    END validate_foreign_keys;
  BEGIN
    l_return_status := validate_foreign_keys(p_qcov_rec, p_db_qcov_rec);
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_qcov_rec IN qcov_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_db_qcov_rec                  qcov_rec_type := get_rec(p_qcov_rec);
  BEGIN
    l_return_status := Validate_Record(p_qcov_rec => p_qcov_rec,
                                       p_db_qcov_rec => l_db_qcov_rec);
    RETURN (l_return_status);
  END Validate_Record;

  */

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN qcov_rec_type,
    p_to   IN OUT NOCOPY qco_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qte_id := p_from.qte_id;
    p_to.cfo_id := p_from.cfo_id;
    p_to.base_source_id := p_from.base_source_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  PROCEDURE migrate (
    p_from IN qco_rec_type,
    p_to   IN OUT NOCOPY qcov_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.qte_id := p_from.qte_id;
    p_to.cfo_id := p_from.cfo_id;
    p_to.base_source_id := p_from.base_source_id;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
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
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- validate_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  -------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_rec                     IN qcov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_rec                     qcov_rec_type := p_qcov_rec;
    l_qco_rec                      qco_rec_type;
    l_qco_rec                      qco_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_qcov_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
    -- SECHAWLA - Not required, as validate_record has code for foreign key validation only,
    -- which has been moved to individaul valiadte attribute procedures
    l_return_status := Validate_Record(l_qcov_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    x_return_status := l_return_status;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  ------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  ------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      i := p_qcov_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_qcov_rec                     => p_qcov_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_qcov_tbl.LAST);
        i := p_qcov_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  ------------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  ------------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qcov_tbl                     => p_qcov_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------------
  -- insert_row for:OKL_TRX_QTE_CF_OBJECTS --
  ---------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qco_rec                      IN qco_rec_type,
    x_qco_rec                      OUT NOCOPY qco_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qco_rec                      qco_rec_type := p_qco_rec;
    l_def_qco_rec                  qco_rec_type;
    -------------------------------------------------
    -- Set_Attributes for:OKL_TRX_QTE_CF_OBJECTS --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_qco_rec IN qco_rec_type,
      x_qco_rec OUT NOCOPY qco_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qco_rec := p_qco_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_qco_rec,                         -- IN
      l_qco_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_TRX_QTE_CF_OBJECTS(
      id,
      qte_id,
      cfo_id,
      base_source_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
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
      attribute15)
    VALUES (
      l_qco_rec.id,
      l_qco_rec.qte_id,
      l_qco_rec.cfo_id,
      l_qco_rec.base_source_id,
      l_qco_rec.object_version_number,
      l_qco_rec.created_by,
      l_qco_rec.creation_date,
      l_qco_rec.last_updated_by,
      l_qco_rec.last_update_date,
      l_qco_rec.last_update_login,
      l_qco_rec.attribute_category,
      l_qco_rec.attribute1,
      l_qco_rec.attribute2,
      l_qco_rec.attribute3,
      l_qco_rec.attribute4,
      l_qco_rec.attribute5,
      l_qco_rec.attribute6,
      l_qco_rec.attribute7,
      l_qco_rec.attribute8,
      l_qco_rec.attribute9,
      l_qco_rec.attribute10,
      l_qco_rec.attribute11,
      l_qco_rec.attribute12,
      l_qco_rec.attribute13,
      l_qco_rec.attribute14,
      l_qco_rec.attribute15);
    -- Set OUT values
    x_qco_rec := l_qco_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  ------------------------------------------------
  -- insert_row for :OKL_TRX_QTE_CF_OBJECTS_V --
  ------------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_rec                     IN qcov_rec_type,
    x_qcov_rec                     OUT NOCOPY qcov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_rec                     qcov_rec_type := p_qcov_rec;
    l_def_qcov_rec                 qcov_rec_type;
    l_qco_rec                      qco_rec_type;
    lx_qco_rec                     qco_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qcov_rec IN qcov_rec_type
    ) RETURN qcov_rec_type IS
      l_qcov_rec qcov_rec_type := p_qcov_rec;
    BEGIN
      l_qcov_rec.CREATION_DATE := SYSDATE;
      l_qcov_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qcov_rec.LAST_UPDATE_DATE := l_qcov_rec.CREATION_DATE;
      l_qcov_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qcov_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qcov_rec);
    END fill_who_columns;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_TRX_QTE_CF_OBJECTS_V --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_qcov_rec IN qcov_rec_type,
      x_qcov_rec OUT NOCOPY qcov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcov_rec := p_qcov_rec;
      x_qcov_rec.OBJECT_VERSION_NUMBER := 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_qcov_rec := null_out_defaults(p_qcov_rec);
    -- Set primary key value
    l_qcov_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_qcov_rec,                        -- IN
      l_def_qcov_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qcov_rec := fill_who_columns(l_def_qcov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qcov_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
    -- SECHAWLA - Not required, as validate_record has code for foreign key validation only,
    -- which has been moved to individaul valiadte attribute procedures
    l_return_status := Validate_Record(l_def_qcov_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_qcov_rec, l_qco_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qco_rec,
      lx_qco_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qco_rec, l_def_qcov_rec);
    -- Set OUT values
    x_qcov_rec := l_def_qcov_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:QCOV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    x_qcov_tbl                     OUT NOCOPY qcov_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      i := p_qcov_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_qcov_rec                     => p_qcov_tbl(i),
            x_qcov_rec                     => x_qcov_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_qcov_tbl.LAST);
        i := p_qcov_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL insert_row for:QCOV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    x_qcov_tbl                     OUT NOCOPY qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qcov_tbl                     => p_qcov_tbl,
        x_qcov_tbl                     => x_qcov_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

--Bug 4299668 PAGARG new procedure to implement bulk insert
--**START**--
  ----------------------------------------------------------
  -- insert row for bulk insert in OKL_TRX_QTE_CF_OBJECTS --
  ----------------------------------------------------------
  PROCEDURE insert_row_bulk(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    x_qcov_tbl                     OUT NOCOPY qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row_bulk';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_tbl                     qcov_tbl_type;
    l_qcov_rec                     qcov_rec_type;

    -- Arrays to store pl-sql table and pass it to bulk insert
    in_id NumberTabTyp;
    in_object_version_number Number9TabTyp;
    in_attribute_category Var90TabTyp;
    in_attribute1 Var450TabTyp;
    in_attribute2 Var450TabTyp;
    in_attribute3 Var450TabTyp;
    in_attribute4 Var450TabTyp;
    in_attribute5 Var450TabTyp;
    in_attribute6 Var450TabTyp;
    in_attribute7 Var450TabTyp;
    in_attribute8 Var450TabTyp;
    in_attribute9 Var450TabTyp;
    in_attribute10 Var450TabTyp;
    in_attribute11 Var450TabTyp;
    in_attribute12 Var450TabTyp;
    in_attribute13 Var450TabTyp;
    in_attribute14 Var450TabTyp;
    in_attribute15 Var450TabTyp;
    in_created_by Number15TabTyp;
    in_creation_date DateTabTyp;
    in_last_updated_by Number15TabTyp;
    in_last_update_date DateTabTyp;
    in_last_update_login Number15TabTyp;
    in_qte_id NumberTabTyp;
    in_cfo_id NumberTabTyp;
    in_base_source_id NumberTabTyp;

    l_tabsize        NUMBER := p_qcov_tbl.COUNT;
    i                NUMBER := 0;
    j                NUMBER;

    l_user_id        NUMBER(15);
    l_login_id       NUMBER(15);

  BEGIN

    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_qcov_tbl := p_qcov_tbl;
    i := l_qcov_tbl.FIRST;
    j := 0;

    l_user_id := FND_GLOBAL.USER_ID;
    l_login_id := FND_GLOBAL.LOGIN_ID;

    --Loop through the table of records and populate respective arrays.
    WHILE i is not null LOOP
      l_qcov_rec := null_out_defaults(l_qcov_tbl(i));

      -- Set primary key value
      l_qcov_rec.ID := get_seq_id;
      l_qcov_rec.OBJECT_VERSION_NUMBER := 1;
      l_qcov_rec.CREATION_DATE := SYSDATE;
      l_qcov_rec.CREATED_BY := l_user_id;
      l_qcov_rec.LAST_UPDATE_DATE := l_qcov_rec.CREATION_DATE;
      l_qcov_rec.LAST_UPDATED_BY := l_user_id;
      l_qcov_rec.LAST_UPDATE_LOGIN := l_login_id;

      -- Validate all non-missing attributes (Item Level Validation)
      l_return_status := Validate_Attributes(l_qcov_rec);
      -- If any errors happen abort API
      IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      j:=j+1;
      in_id(j) := l_qcov_rec.id;
      in_object_version_number(j) := l_qcov_rec.object_version_number;
      in_created_by(j) := l_qcov_rec.created_by;
      in_creation_date(j) := l_qcov_rec.creation_date;
      in_last_updated_by(j) := l_qcov_rec.last_updated_by;
      in_last_update_date(j) := l_qcov_rec.last_update_date;
      in_last_update_login(j) := l_qcov_rec.last_update_login;
      in_attribute_category(j) := l_qcov_rec.attribute_category;
      in_attribute1(j) := l_qcov_rec.attribute1;
      in_attribute2(j) := l_qcov_rec.attribute2;
      in_attribute3(j) := l_qcov_rec.attribute3;
      in_attribute4(j) := l_qcov_rec.attribute4;
      in_attribute5(j) := l_qcov_rec.attribute5;
      in_attribute6(j) := l_qcov_rec.attribute6;
      in_attribute7(j) := l_qcov_rec.attribute7;
      in_attribute8(j) := l_qcov_rec.attribute8;
      in_attribute9(j) := l_qcov_rec.attribute9;
      in_attribute10(j) := l_qcov_rec.attribute10;
      in_attribute11(j) := l_qcov_rec.attribute11;
      in_attribute12(j) := l_qcov_rec.attribute12;
      in_attribute13(j) := l_qcov_rec.attribute13;
      in_attribute14(j) := l_qcov_rec.attribute14;
      in_attribute15(j) := l_qcov_rec.attribute15;
      in_qte_id(j) := l_qcov_rec.qte_id;
      in_cfo_id(j) := l_qcov_rec.cfo_id;
      in_base_source_id(j) := l_qcov_rec.base_source_id;

      l_qcov_tbl(i) := l_qcov_rec;

      i := l_qcov_tbl.next(i);
    END LOOP;

    -- Bulk insert into table
    FORALL i in 1..l_tabsize
    INSERT INTO OKL_TRX_QTE_CF_OBJECTS(
      id,
      qte_id,
      cfo_id,
      base_source_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
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
      attribute15)
    VALUES (
      in_id(i),
      in_qte_id(i),
      in_cfo_id(i),
      in_base_source_id(i),
      in_object_version_number(i),
      in_created_by(i),
      in_creation_date(i),
      in_last_updated_by(i),
      in_last_update_date(i),
      in_last_update_login(i),
      in_attribute_category(i),
      in_attribute1(i),
      in_attribute2(i),
      in_attribute3(i),
      in_attribute4(i),
      in_attribute5(i),
      in_attribute6(i),
      in_attribute7(i),
      in_attribute8(i),
      in_attribute9(i),
      in_attribute10(i),
      in_attribute11(i),
      in_attribute12(i),
      in_attribute13(i),
      in_attribute14(i),
      in_attribute15(i));

    x_qcov_tbl := l_qcov_tbl;
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row_bulk;
--**END 4299668**--

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- lock_row for:OKL_TRX_QTE_CF_OBJECTS --
  -------------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qco_rec                      IN qco_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qco_rec IN qco_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_QTE_CF_OBJECTS
     WHERE ID = p_qco_rec.id
       AND OBJECT_VERSION_NUMBER = p_qco_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_qco_rec IN qco_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_TRX_QTE_CF_OBJECTS
     WHERE ID = p_qco_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_TRX_QTE_CF_OBJECTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_TRX_QTE_CF_OBJECTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_qco_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_qco_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qco_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qco_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ----------------------------------------------
  -- lock_row for: OKL_TRX_QTE_CF_OBJECTS_V --
  ----------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_rec                     IN qcov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qco_rec                      qco_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_qcov_rec, l_qco_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qco_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:QCOV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      i := p_qcov_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_qcov_rec                     => p_qcov_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_qcov_tbl.LAST);
        i := p_qcov_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row for:QCOV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qcov_tbl                     => p_qcov_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------------
  -- update_row for:OKL_TRX_QTE_CF_OBJECTS --
  ---------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qco_rec                      IN qco_rec_type,
    x_qco_rec                      OUT NOCOPY qco_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qco_rec                      qco_rec_type := p_qco_rec;
    l_def_qco_rec                  qco_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qco_rec IN qco_rec_type,
      x_qco_rec OUT NOCOPY qco_rec_type
    ) RETURN VARCHAR2 IS
      l_qco_rec                      qco_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qco_rec := p_qco_rec;
      -- Get current database values
      l_qco_rec := get_rec(p_qco_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_qco_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.id := l_qco_rec.id;
        END IF;
        IF (x_qco_rec.qte_id = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.qte_id := l_qco_rec.qte_id;
        END IF;
        IF (x_qco_rec.cfo_id = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.cfo_id := l_qco_rec.cfo_id;
        END IF;
        IF (x_qco_rec.base_source_id = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.base_source_id := l_qco_rec.base_source_id;
        END IF;
        IF (x_qco_rec.object_version_number = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.object_version_number := l_qco_rec.object_version_number;
        END IF;
        IF (x_qco_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.created_by := l_qco_rec.created_by;
        END IF;
        IF (x_qco_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_qco_rec.creation_date := l_qco_rec.creation_date;
        END IF;
        IF (x_qco_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.last_updated_by := l_qco_rec.last_updated_by;
        END IF;
        IF (x_qco_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_qco_rec.last_update_date := l_qco_rec.last_update_date;
        END IF;
        IF (x_qco_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_qco_rec.last_update_login := l_qco_rec.last_update_login;
        END IF;
        IF (x_qco_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute_category := l_qco_rec.attribute_category;
        END IF;
        IF (x_qco_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute1 := l_qco_rec.attribute1;
        END IF;
        IF (x_qco_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute2 := l_qco_rec.attribute2;
        END IF;
        IF (x_qco_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute3 := l_qco_rec.attribute3;
        END IF;
        IF (x_qco_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute4 := l_qco_rec.attribute4;
        END IF;
        IF (x_qco_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute5 := l_qco_rec.attribute5;
        END IF;
        IF (x_qco_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute6 := l_qco_rec.attribute6;
        END IF;
        IF (x_qco_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute7 := l_qco_rec.attribute7;
        END IF;
        IF (x_qco_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute8 := l_qco_rec.attribute8;
        END IF;
        IF (x_qco_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute9 := l_qco_rec.attribute9;
        END IF;
        IF (x_qco_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute10 := l_qco_rec.attribute10;
        END IF;
        IF (x_qco_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute11 := l_qco_rec.attribute11;
        END IF;
        IF (x_qco_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute12 := l_qco_rec.attribute12;
        END IF;
        IF (x_qco_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute13 := l_qco_rec.attribute13;
        END IF;
        IF (x_qco_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute14 := l_qco_rec.attribute14;
        END IF;
        IF (x_qco_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_qco_rec.attribute15 := l_qco_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------------
    -- Set_Attributes for:OKL_TRX_QTE_CF_OBJECTS --
    -------------------------------------------------
    FUNCTION Set_Attributes (
      p_qco_rec IN qco_rec_type,
      x_qco_rec OUT NOCOPY qco_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qco_rec := p_qco_rec;
      x_qco_rec.OBJECT_VERSION_NUMBER := p_qco_rec.OBJECT_VERSION_NUMBER + 1;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_qco_rec,                         -- IN
      l_qco_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qco_rec, l_def_qco_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKL_TRX_QTE_CF_OBJECTS
    SET QTE_ID = l_def_qco_rec.qte_id,
        CFO_ID = l_def_qco_rec.cfo_id,
        BASE_SOURCE_ID = l_def_qco_rec.base_source_id,
        OBJECT_VERSION_NUMBER = l_def_qco_rec.object_version_number,
        CREATED_BY = l_def_qco_rec.created_by,
        CREATION_DATE = l_def_qco_rec.creation_date,
        LAST_UPDATED_BY = l_def_qco_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qco_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qco_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_qco_rec.attribute_category,
        ATTRIBUTE1 = l_def_qco_rec.attribute1,
        ATTRIBUTE2 = l_def_qco_rec.attribute2,
        ATTRIBUTE3 = l_def_qco_rec.attribute3,
        ATTRIBUTE4 = l_def_qco_rec.attribute4,
        ATTRIBUTE5 = l_def_qco_rec.attribute5,
        ATTRIBUTE6 = l_def_qco_rec.attribute6,
        ATTRIBUTE7 = l_def_qco_rec.attribute7,
        ATTRIBUTE8 = l_def_qco_rec.attribute8,
        ATTRIBUTE9 = l_def_qco_rec.attribute9,
        ATTRIBUTE10 = l_def_qco_rec.attribute10,
        ATTRIBUTE11 = l_def_qco_rec.attribute11,
        ATTRIBUTE12 = l_def_qco_rec.attribute12,
        ATTRIBUTE13 = l_def_qco_rec.attribute13,
        ATTRIBUTE14 = l_def_qco_rec.attribute14,
        ATTRIBUTE15 = l_def_qco_rec.attribute15
    WHERE ID = l_def_qco_rec.id;

    x_qco_rec := l_qco_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------------
  -- update_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  -----------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_rec                     IN qcov_rec_type,
    x_qcov_rec                     OUT NOCOPY qcov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_rec                     qcov_rec_type := p_qcov_rec;
    l_def_qcov_rec                 qcov_rec_type;
    l_db_qcov_rec                  qcov_rec_type;
    l_qco_rec                      qco_rec_type;
    lx_qco_rec                     qco_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qcov_rec IN qcov_rec_type
    ) RETURN qcov_rec_type IS
      l_qcov_rec qcov_rec_type := p_qcov_rec;
    BEGIN
      l_qcov_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qcov_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qcov_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qcov_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qcov_rec IN qcov_rec_type,
      x_qcov_rec OUT NOCOPY qcov_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcov_rec := p_qcov_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_qcov_rec := get_rec(p_qcov_rec, l_return_status);
      IF (l_return_status = OKL_API.G_RET_STS_SUCCESS) THEN
        IF (x_qcov_rec.id = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.id := l_db_qcov_rec.id;
        END IF;
        IF (x_qcov_rec.qte_id = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.qte_id := l_db_qcov_rec.qte_id;
        END IF;
        IF (x_qcov_rec.cfo_id = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.cfo_id := l_db_qcov_rec.cfo_id;
        END IF;
        IF (x_qcov_rec.base_source_id = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.base_source_id := l_db_qcov_rec.base_source_id;
        END IF;
        IF (x_qcov_rec.created_by = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.created_by := l_db_qcov_rec.created_by;
        END IF;
        IF (x_qcov_rec.creation_date = OKL_API.G_MISS_DATE)
        THEN
          x_qcov_rec.creation_date := l_db_qcov_rec.creation_date;
        END IF;
        IF (x_qcov_rec.last_updated_by = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.last_updated_by := l_db_qcov_rec.last_updated_by;
        END IF;
        IF (x_qcov_rec.last_update_date = OKL_API.G_MISS_DATE)
        THEN
          x_qcov_rec.last_update_date := l_db_qcov_rec.last_update_date;
        END IF;
        IF (x_qcov_rec.last_update_login = OKL_API.G_MISS_NUM)
        THEN
          x_qcov_rec.last_update_login := l_db_qcov_rec.last_update_login;
        END IF;
        IF (x_qcov_rec.attribute_category = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute_category := l_db_qcov_rec.attribute_category;
        END IF;
        IF (x_qcov_rec.attribute1 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute1 := l_db_qcov_rec.attribute1;
        END IF;
        IF (x_qcov_rec.attribute2 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute2 := l_db_qcov_rec.attribute2;
        END IF;
        IF (x_qcov_rec.attribute3 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute3 := l_db_qcov_rec.attribute3;
        END IF;
        IF (x_qcov_rec.attribute4 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute4 := l_db_qcov_rec.attribute4;
        END IF;
        IF (x_qcov_rec.attribute5 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute5 := l_db_qcov_rec.attribute5;
        END IF;
        IF (x_qcov_rec.attribute6 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute6 := l_db_qcov_rec.attribute6;
        END IF;
        IF (x_qcov_rec.attribute7 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute7 := l_db_qcov_rec.attribute7;
        END IF;
        IF (x_qcov_rec.attribute8 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute8 := l_db_qcov_rec.attribute8;
        END IF;
        IF (x_qcov_rec.attribute9 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute9 := l_db_qcov_rec.attribute9;
        END IF;
        IF (x_qcov_rec.attribute10 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute10 := l_db_qcov_rec.attribute10;
        END IF;
        IF (x_qcov_rec.attribute11 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute11 := l_db_qcov_rec.attribute11;
        END IF;
        IF (x_qcov_rec.attribute12 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute12 := l_db_qcov_rec.attribute12;
        END IF;
        IF (x_qcov_rec.attribute13 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute13 := l_db_qcov_rec.attribute13;
        END IF;
        IF (x_qcov_rec.attribute14 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute14 := l_db_qcov_rec.attribute14;
        END IF;
        IF (x_qcov_rec.attribute15 = OKL_API.G_MISS_CHAR)
        THEN
          x_qcov_rec.attribute15 := l_db_qcov_rec.attribute15;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------------
    -- Set_Attributes for:OKL_TRX_QTE_CF_OBJECTS_V --
    ---------------------------------------------------
    FUNCTION Set_Attributes (
      p_qcov_rec IN qcov_rec_type,
      x_qcov_rec OUT NOCOPY qcov_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcov_rec := p_qcov_rec;
      RETURN(l_return_status);
    END Set_Attributes;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      p_qcov_rec,                        -- IN
      x_qcov_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qcov_rec, l_def_qcov_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qcov_rec := fill_who_columns(l_def_qcov_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qcov_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    /*
    -- SECHAWLA - Not required, as validate_record has code for foreign key validation only,
    -- which has been moved to individaul valiadte attribute procedures
    l_return_status := Validate_Record(l_def_qcov_rec, l_db_qcov_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    */

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_qcov_rec                     => p_qcov_rec);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_qcov_rec, l_qco_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qco_rec,
      lx_qco_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qco_rec, l_def_qcov_rec);
    x_qcov_rec := l_def_qcov_rec;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:qcov_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    x_qcov_tbl                     OUT NOCOPY qcov_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      i := p_qcov_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_qcov_rec                     => p_qcov_tbl(i),
            x_qcov_rec                     => x_qcov_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_qcov_tbl.LAST);
        i := p_qcov_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL update_row for:QCOV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    x_qcov_tbl                     OUT NOCOPY qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qcov_tbl                     => p_qcov_tbl,
        x_qcov_tbl                     => x_qcov_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
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
  ---------------------------------------------
  -- delete_row for:OKL_TRX_QTE_CF_OBJECTS --
  ---------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qco_rec                      IN qco_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qco_rec                      qco_rec_type := p_qco_rec;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKL_TRX_QTE_CF_OBJECTS
     WHERE ID = p_qco_rec.id;

    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  -----------------------------------------------
  -- delete_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  -----------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_rec                     IN qcov_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_qcov_rec                     qcov_rec_type := p_qcov_rec;
    l_qco_rec                      qco_rec_type;
  BEGIN
    l_return_status := OKL_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              'PVT',
                                              x_return_status);
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_qcov_rec, l_qco_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_qco_rec
    );
    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  ----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKL_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      i := p_qcov_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKL_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKL_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_qcov_rec                     => p_qcov_tbl(i));
          IF (l_error_rec.error_type <> OKL_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKL_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKL_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_qcov_tbl.LAST);
        i := p_qcov_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ----------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKL_TRX_QTE_CF_OBJECTS_V --
  ----------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcov_tbl                     IN qcov_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKL_API.ERROR_TBL_TYPE;
  BEGIN
    OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qcov_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKL_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_qcov_tbl                     => p_qcov_tbl,
        px_error_tbl                   => l_error_tbl);
    END IF;
    OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKL_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKL_QCO_PVT;

/
