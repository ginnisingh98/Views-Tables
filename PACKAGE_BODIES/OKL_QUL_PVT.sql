--------------------------------------------------------
--  DDL for Package Body OKL_QUL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_QUL_PVT" AS
/* $Header: OKLSQULB.pls 120.1 2005/08/31 23:33:14 rravikir noship $ */

  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_qulv_rec IN qulv_rec_type) RETURN qulv_rec_type IS

    l_qulv_rec  qulv_rec_type;

  BEGIN

    l_qulv_rec := p_qulv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_qulv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute_category := NULL;
    END IF;
    IF l_qulv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute1 := NULL;
    END IF;
    IF l_qulv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute2 := NULL;
    END IF;
    IF l_qulv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute3 := NULL;
    END IF;
    IF l_qulv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute4 := NULL;
    END IF;
    IF l_qulv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute5 := NULL;
    END IF;
    IF l_qulv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute6 := NULL;
    END IF;
    IF l_qulv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute7 := NULL;
    END IF;
    IF l_qulv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute8 := NULL;
    END IF;
    IF l_qulv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute9 := NULL;
    END IF;
    IF l_qulv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute10 := NULL;
    END IF;
    IF l_qulv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute11 := NULL;
    END IF;
    IF l_qulv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute12 := NULL;
    END IF;
    IF l_qulv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute13 := NULL;
    END IF;
    IF l_qulv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute14 := NULL;
    END IF;
    IF l_qulv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.attribute15 := NULL;
    END IF;
    IF l_qulv_rec.subpool_trx_id = FND_API.G_MISS_NUM THEN
      l_qulv_rec.subpool_trx_id := NULL;
    END IF;
    IF l_qulv_rec.source_type_code = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.source_type_code := NULL;
    END IF;
    IF l_qulv_rec.source_object_id = FND_API.G_MISS_NUM THEN
      l_qulv_rec.source_object_id := NULL;
    END IF;
    IF l_qulv_rec.asset_number = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.asset_number := NULL;
    END IF;
    IF l_qulv_rec.asset_start_date = FND_API.G_MISS_DATE THEN
      l_qulv_rec.asset_start_date := NULL;
    END IF;
    IF l_qulv_rec.subsidy_pool_id = FND_API.G_MISS_NUM THEN
      l_qulv_rec.subsidy_pool_id := NULL;
    END IF;
    IF l_qulv_rec.subsidy_pool_amount = FND_API.G_MISS_NUM THEN
      l_qulv_rec.subsidy_pool_amount := NULL;
    END IF;
    IF l_qulv_rec.subsidy_pool_currency_code = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.subsidy_pool_currency_code := NULL;
    END IF;
    IF l_qulv_rec.subsidy_id = FND_API.G_MISS_NUM THEN
      l_qulv_rec.subsidy_id := NULL;
    END IF;
    IF l_qulv_rec.subsidy_amount = FND_API.G_MISS_NUM THEN
      l_qulv_rec.subsidy_amount := NULL;
    END IF;
    IF l_qulv_rec.subsidy_currency_code = FND_API.G_MISS_CHAR THEN
      l_qulv_rec.subsidy_currency_code := NULL;
    END IF;
    IF l_qulv_rec.vendor_id = FND_API.G_MISS_NUM THEN
      l_qulv_rec.vendor_id := NULL;
    END IF;
    IF l_qulv_rec.conversion_rate = FND_API.G_MISS_NUM THEN
      l_qulv_rec.conversion_rate := NULL;
    END IF;

    RETURN l_qulv_rec;

  END null_out_defaults;


  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN qulv_rec_type IS

    l_qulv_rec           qulv_rec_type;
    l_prog_name          VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.get_rec';

    SELECT
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,subpool_trx_id
      ,source_type_code
      ,source_object_id
      ,asset_number
      ,asset_start_date
      ,subsidy_pool_id
      ,subsidy_pool_amount
      ,subsidy_pool_currency_code
      ,subsidy_id
      ,subsidy_amount
      ,subsidy_currency_code
      ,vendor_id
      ,conversion_rate
    INTO
      l_qulv_rec.id
      ,l_qulv_rec.object_version_number
      ,l_qulv_rec.attribute_category
      ,l_qulv_rec.attribute1
      ,l_qulv_rec.attribute2
      ,l_qulv_rec.attribute3
      ,l_qulv_rec.attribute4
      ,l_qulv_rec.attribute5
      ,l_qulv_rec.attribute6
      ,l_qulv_rec.attribute7
      ,l_qulv_rec.attribute8
      ,l_qulv_rec.attribute9
      ,l_qulv_rec.attribute10
      ,l_qulv_rec.attribute11
      ,l_qulv_rec.attribute12
      ,l_qulv_rec.attribute13
      ,l_qulv_rec.attribute14
      ,l_qulv_rec.attribute15
      ,l_qulv_rec.subpool_trx_id
      ,l_qulv_rec.source_type_code
      ,l_qulv_rec.source_object_id
      ,l_qulv_rec.asset_number
      ,l_qulv_rec.asset_start_date
      ,l_qulv_rec.subsidy_pool_id
      ,l_qulv_rec.subsidy_pool_amount
      ,l_qulv_rec.subsidy_pool_currency_code
      ,l_qulv_rec.subsidy_id
      ,l_qulv_rec.subsidy_amount
      ,l_qulv_rec.subsidy_currency_code
      ,l_qulv_rec.vendor_id
      ,l_qulv_rec.conversion_rate
    FROM okl_quote_subpool_usage_v
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_qulv_rec;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END get_rec;


  ------------------------
  -- PROCEDURE validate_id
  ------------------------
  PROCEDURE validate_id (x_return_status OUT NOCOPY VARCHAR2, p_id IN NUMBER) IS
  BEGIN
    IF p_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_id;


  -------------------------------------------
  -- PROCEDURE validate_object_version_number
  -------------------------------------------
  PROCEDURE validate_object_version_number (x_return_status OUT NOCOPY VARCHAR2, p_object_version_number IN NUMBER) IS
  BEGIN
    IF p_object_version_number IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'object_version_number',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_object_version_number;


  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_qulv_rec IN qulv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_qulv_rec.id);
    validate_object_version_number (l_return_status, p_qulv_rec.object_version_number);

    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_qulv_rec IN qulv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
  BEGIN
    RETURN G_RET_STS_SUCCESS;
  END validate_record;


  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN qulv_rec_type, p_to IN OUT NOCOPY qul_rec_type) IS

  BEGIN

    p_to.id                             :=  p_from.id;
    p_to.object_version_number          :=  p_from.object_version_number;
    p_to.attribute_category             :=  p_from.attribute_category;
    p_to.attribute1                     :=  p_from.attribute1;
    p_to.attribute2                     :=  p_from.attribute2;
    p_to.attribute3                     :=  p_from.attribute3;
    p_to.attribute4                     :=  p_from.attribute4;
    p_to.attribute5                     :=  p_from.attribute5;
    p_to.attribute6                     :=  p_from.attribute6;
    p_to.attribute7                     :=  p_from.attribute7;
    p_to.attribute8                     :=  p_from.attribute8;
    p_to.attribute9                     :=  p_from.attribute9;
    p_to.attribute10                    :=  p_from.attribute10;
    p_to.attribute11                    :=  p_from.attribute11;
    p_to.attribute12                    :=  p_from.attribute12;
    p_to.attribute13                    :=  p_from.attribute13;
    p_to.attribute14                    :=  p_from.attribute14;
    p_to.attribute15                    :=  p_from.attribute15;
    p_to.subpool_trx_id                 :=  p_from.subpool_trx_id;
    p_to.source_type_code               :=  p_from.source_type_code;
    p_to.source_object_id               :=  p_from.source_object_id;
    p_to.asset_number                   :=  p_from.asset_number;
    p_to.asset_start_date               :=  p_from.asset_start_date;
    p_to.subsidy_pool_id                :=  p_from.subsidy_pool_id;
    p_to.subsidy_pool_amount            :=  p_from.subsidy_pool_amount;
    p_to.subsidy_pool_currency_code     :=  p_from.subsidy_pool_currency_code;
    p_to.subsidy_id                     :=  p_from.subsidy_id;
    p_to.subsidy_amount                 :=  p_from.subsidy_amount;
    p_to.subsidy_currency_code          :=  p_from.subsidy_currency_code;
    p_to.vendor_id                      :=  p_from.vendor_id;
    p_to.conversion_rate                :=  p_from.conversion_rate;

  END migrate;


  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_qul_rec IN qul_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_quote_subpool_usage (
      id
      ,object_version_number
      ,attribute_category
      ,attribute1
      ,attribute2
      ,attribute3
      ,attribute4
      ,attribute5
      ,attribute6
      ,attribute7
      ,attribute8
      ,attribute9
      ,attribute10
      ,attribute11
      ,attribute12
      ,attribute13
      ,attribute14
      ,attribute15
      ,created_by
      ,creation_date
      ,last_updated_by
      ,last_update_date
      ,last_update_login
      ,subpool_trx_id
      ,source_type_code
      ,source_object_id
      ,asset_number
      ,asset_start_date
      ,subsidy_pool_id
      ,subsidy_pool_amount
      ,subsidy_pool_currency_code
      ,subsidy_id
      ,subsidy_amount
      ,subsidy_currency_code
      ,vendor_id
      ,conversion_rate
      )
    VALUES
      (
       p_qul_rec.id
      ,p_qul_rec.object_version_number
      ,p_qul_rec.attribute_category
      ,p_qul_rec.attribute1
      ,p_qul_rec.attribute2
      ,p_qul_rec.attribute3
      ,p_qul_rec.attribute4
      ,p_qul_rec.attribute5
      ,p_qul_rec.attribute6
      ,p_qul_rec.attribute7
      ,p_qul_rec.attribute8
      ,p_qul_rec.attribute9
      ,p_qul_rec.attribute10
      ,p_qul_rec.attribute11
      ,p_qul_rec.attribute12
      ,p_qul_rec.attribute13
      ,p_qul_rec.attribute14
      ,p_qul_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_qul_rec.subpool_trx_id
      ,p_qul_rec.source_type_code
      ,p_qul_rec.source_object_id
      ,p_qul_rec.asset_number
      ,p_qul_rec.asset_start_date
      ,p_qul_rec.subsidy_pool_id
      ,p_qul_rec.subsidy_pool_amount
      ,p_qul_rec.subsidy_pool_currency_code
      ,p_qul_rec.subsidy_id
      ,p_qul_rec.subsidy_amount
      ,p_qul_rec.subsidy_currency_code
      ,p_qul_rec.vendor_id
      ,p_qul_rec.conversion_rate
    );

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------------
  -- PROCEDURE insert_row (V)
  ---------------------------
  PROCEDURE insert_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_qulv_rec                     qulv_rec_type;
    l_qul_rec                      qul_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_qulv_rec                       := null_out_defaults (p_qulv_rec);

    SELECT okl_qul_seq.nextval INTO l_qulv_rec.ID FROM DUAL;

    l_qulv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_qulv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_qulv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_qulv_rec, l_qul_rec);

    insert_row (x_return_status => l_return_status, p_qul_rec => l_qul_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_qulv_rec      := l_qulv_rec;
    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (REC)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_qulv_rec                     => p_qulv_rec,
                x_qulv_rec                     => x_qulv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  -----------------------------
  -- PROCEDURE insert_row (TBL)
  -----------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type,
    x_qulv_tbl                     OUT NOCOPY qulv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qulv_tbl.COUNT > 0) THEN
      i := p_qulv_tbl.FIRST;
      LOOP
        IF p_qulv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_qulv_rec                     => p_qulv_tbl(i),
                      x_qulv_rec                     => x_qulv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qulv_tbl.LAST);
          i := p_qulv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END insert_row;


  ---------------------
  -- PROCEDURE lock_row
  ---------------------
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_qul_rec IN qul_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUOTE_SUBPOOL_USAGE
     WHERE ID = p_qul_rec.id
       AND OBJECT_VERSION_NUMBER = p_qul_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_QUOTE_SUBPOOL_USAGE
     WHERE ID = p_qul_rec.id;

    l_object_version_number        NUMBER;
    lc_object_version_number       NUMBER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.lock_row';

    BEGIN
      OPEN lock_csr;
      FETCH lock_csr INTO l_object_version_number;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN

        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR2,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END;

    IF l_object_version_number IS NULL THEN

      OPEN lchk_csr;
      FETCH lchk_csr INTO lc_object_version_number;
      CLOSE lchk_csr;

      IF lc_object_version_number IS NULL THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR3,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      ELSIF lc_object_version_number <> p_qul_rec.object_version_number THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_OVN_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name);

      END IF;

      RAISE OKL_API.G_EXCEPTION_ERROR;

    END IF;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  ---------------------------
  -- PROCEDURE update_row (B)
  ---------------------------
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_qul_rec IN qul_rec_type) IS

    l_return_status           VARCHAR2(1);

    l_prog_name               VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_qul_rec => p_qul_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_quote_subpool_usage
    SET
      object_version_number = p_qul_rec.object_version_number+1
      ,attribute_category = p_qul_rec.attribute_category
      ,attribute1 = p_qul_rec.attribute1
      ,attribute2 = p_qul_rec.attribute2
      ,attribute3 = p_qul_rec.attribute3
      ,attribute4 = p_qul_rec.attribute4
      ,attribute5 = p_qul_rec.attribute5
      ,attribute6 = p_qul_rec.attribute6
      ,attribute7 = p_qul_rec.attribute7
      ,attribute8 = p_qul_rec.attribute8
      ,attribute9 = p_qul_rec.attribute9
      ,attribute10 = p_qul_rec.attribute10
      ,attribute11 = p_qul_rec.attribute11
      ,attribute12 = p_qul_rec.attribute12
      ,attribute13 = p_qul_rec.attribute13
      ,attribute14 = p_qul_rec.attribute14
      ,attribute15 = p_qul_rec.attribute15
      ,subpool_trx_id = p_qul_rec.subpool_trx_id
      ,source_type_code = p_qul_rec.source_type_code
      ,source_object_id = p_qul_rec.source_object_id
      ,asset_number = p_qul_rec.asset_number
      ,asset_start_date = p_qul_rec.asset_start_date
      ,subsidy_pool_id = p_qul_rec.subsidy_pool_id
      ,subsidy_pool_amount = p_qul_rec.subsidy_pool_amount
      ,subsidy_pool_currency_code = p_qul_rec.subsidy_pool_currency_code
      ,subsidy_id = p_qul_rec.subsidy_id
      ,subsidy_amount = p_qul_rec.subsidy_amount
      ,subsidy_currency_code = p_qul_rec.subsidy_currency_code
      ,vendor_id = p_qul_rec.vendor_id
      ,conversion_rate = p_qul_rec.conversion_rate
    WHERE id = p_qul_rec.id;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  ---------------------------
  -- PROCEDURE update_row (V)
  ---------------------------
  PROCEDURE update_row (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_qulv_rec                     qulv_rec_type;
    l_qul_rec                      qul_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_qulv_rec IN  qulv_rec_type,
                                  x_qulv_rec OUT NOCOPY qulv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61);
      l_return_status      VARCHAR2(1);
      l_db_qulv_rec        qulv_rec_type;

    BEGIN

      l_prog_name := G_PKG_NAME||'.populate_new_record';

      x_qulv_rec    := p_qulv_rec;
      l_db_qulv_rec := get_rec (p_qulv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_qulv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute_category := l_db_qulv_rec.attribute_category;
      END IF;
      IF x_qulv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute1 := l_db_qulv_rec.attribute1;
      END IF;
      IF x_qulv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute2 := l_db_qulv_rec.attribute2;
      END IF;
      IF x_qulv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute3 := l_db_qulv_rec.attribute3;
      END IF;
      IF x_qulv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute4 := l_db_qulv_rec.attribute4;
      END IF;
      IF x_qulv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute5 := l_db_qulv_rec.attribute5;
      END IF;
      IF x_qulv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute6 := l_db_qulv_rec.attribute6;
      END IF;
      IF x_qulv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute7 := l_db_qulv_rec.attribute7;
      END IF;
      IF x_qulv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute8 := l_db_qulv_rec.attribute8;
      END IF;
      IF x_qulv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute9 := l_db_qulv_rec.attribute9;
      END IF;
      IF x_qulv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute10 := l_db_qulv_rec.attribute10;
      END IF;
      IF x_qulv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute11 := l_db_qulv_rec.attribute11;
      END IF;
      IF x_qulv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute12 := l_db_qulv_rec.attribute12;
      END IF;
      IF x_qulv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute13 := l_db_qulv_rec.attribute13;
      END IF;
      IF x_qulv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute14 := l_db_qulv_rec.attribute14;
      END IF;
      IF x_qulv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.attribute15 := l_db_qulv_rec.attribute15;
      END IF;
      IF x_qulv_rec.subpool_trx_id = FND_API.G_MISS_NUM THEN
        x_qulv_rec.subpool_trx_id := l_db_qulv_rec.subpool_trx_id;
      END IF;
      IF x_qulv_rec.source_type_code = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.source_type_code := l_db_qulv_rec.source_type_code;
      END IF;
      IF x_qulv_rec.source_object_id = FND_API.G_MISS_NUM THEN
        x_qulv_rec.source_object_id := l_db_qulv_rec.source_object_id;
      END IF;
      IF x_qulv_rec.asset_number = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.asset_number := l_db_qulv_rec.asset_number;
      END IF;
      IF x_qulv_rec.asset_start_date = FND_API.G_MISS_DATE THEN
        x_qulv_rec.asset_start_date := l_db_qulv_rec.asset_start_date;
      END IF;
      IF x_qulv_rec.subsidy_pool_id = FND_API.G_MISS_NUM THEN
        x_qulv_rec.subsidy_pool_id := l_db_qulv_rec.subsidy_pool_id;
      END IF;
      IF x_qulv_rec.subsidy_pool_amount = FND_API.G_MISS_NUM THEN
        x_qulv_rec.subsidy_pool_amount := l_db_qulv_rec.subsidy_pool_amount;
      END IF;
      IF x_qulv_rec.subsidy_pool_currency_code = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.subsidy_pool_currency_code := l_db_qulv_rec.subsidy_pool_currency_code;
      END IF;
      IF x_qulv_rec.subsidy_id = FND_API.G_MISS_NUM THEN
        x_qulv_rec.subsidy_id := l_db_qulv_rec.subsidy_id;
      END IF;
      IF x_qulv_rec.subsidy_amount = FND_API.G_MISS_NUM THEN
        x_qulv_rec.subsidy_amount := l_db_qulv_rec.subsidy_amount;
      END IF;
      IF x_qulv_rec.subsidy_currency_code = FND_API.G_MISS_CHAR THEN
        x_qulv_rec.subsidy_currency_code := l_db_qulv_rec.subsidy_currency_code;
      END IF;
      IF x_qulv_rec.vendor_id = FND_API.G_MISS_NUM THEN
        x_qulv_rec.vendor_id := l_db_qulv_rec.vendor_id;
      END IF;
      IF x_qulv_rec.conversion_rate = FND_API.G_MISS_NUM THEN
        x_qulv_rec.conversion_rate := l_db_qulv_rec.conversion_rate;
      END IF;

      RETURN l_return_status;

    EXCEPTION

      WHEN OKL_API.G_EXCEPTION_ERROR THEN

        x_return_status := G_RET_STS_ERROR;

      WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

        x_return_status := G_RET_STS_UNEXP_ERROR;

      WHEN OTHERS THEN

        OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                             p_msg_name     => G_DB_ERROR,
                             p_token1       => G_PROG_NAME_TOKEN,
                             p_token1_value => l_prog_name,
                             p_token2       => G_SQLCODE_TOKEN,
                             p_token2_value => sqlcode,
                             p_token3       => G_SQLERRM_TOKEN,
                             p_token3_value => sqlerrm);

        x_return_status := G_RET_STS_UNEXP_ERROR;

    END populate_new_record;

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (V)';

    l_return_status := populate_new_record (p_qulv_rec, l_qulv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_qulv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_qulv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_qulv_rec, l_qul_rec);

    update_row (x_return_status => l_return_status, p_qul_rec => l_qul_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_qulv_rec      := l_qulv_rec;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (REC)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type,
    x_qulv_rec                     OUT NOCOPY qulv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_qulv_rec                     => p_qulv_rec,
                x_qulv_rec                     => x_qulv_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------------------
  -- PROCEDURE update_row (TBL)
  -----------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type,
    x_qulv_tbl                     OUT NOCOPY qulv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_qulv_tbl := p_qulv_tbl;

    IF (p_qulv_tbl.COUNT > 0) THEN

      i := p_qulv_tbl.FIRST;

      LOOP

        IF p_qulv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_qulv_rec                     => p_qulv_tbl(i),
                      x_qulv_rec                     => x_qulv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qulv_tbl.LAST);
          i := p_qulv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END update_row;


  -----------------
  -- delete_row (V)
  -----------------
  PROCEDURE delete_row(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (V)';

    DELETE FROM OKL_QUOTE_SUBPOOL_USAGE WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -----------------------------
  -- PROCEDURE delete_row (REC)
  -----------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_rec                     IN qulv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_qulv_rec.id);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


  -------------------
  -- delete_row (TBL)
  -------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qulv_tbl                     IN qulv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_qulv_tbl.COUNT > 0) THEN

      i := p_qulv_tbl.FIRST;

      LOOP

        IF p_qulv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_qulv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_qulv_tbl.LAST);
          i := p_qulv_tbl.NEXT(i);

        END IF;

      END LOOP;

    ELSE

      l_return_status := G_RET_STS_SUCCESS;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_prog_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END delete_row;


END OKL_QUL_PVT;

/
