--------------------------------------------------------
--  DDL for Package Body OKL_LAT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_LAT_PVT" AS
  /* $Header: OKLSLATB.pls 120.3 2008/02/29 23:56:47 asahoo noship $ */

  -----------------------------
  -- FUNCTION null_out_defaults
  -----------------------------
  FUNCTION null_out_defaults (p_latv_rec IN latv_rec_type) RETURN latv_rec_type IS

    l_latv_rec  latv_rec_type;

  BEGIN

    l_latv_rec := p_latv_rec;

    -- Not applicable to ID and OBJECT_VERSION_NUMBER

    IF l_latv_rec.attribute_category = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute_category := NULL;
    END IF;
    IF l_latv_rec.attribute1 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute1 := NULL;
    END IF;
    IF l_latv_rec.attribute2 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute2 := NULL;
    END IF;
    IF l_latv_rec.attribute3 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute3 := NULL;
    END IF;
    IF l_latv_rec.attribute4 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute4 := NULL;
    END IF;
    IF l_latv_rec.attribute5 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute5 := NULL;
    END IF;
    IF l_latv_rec.attribute6 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute6 := NULL;
    END IF;
    IF l_latv_rec.attribute7 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute7 := NULL;
    END IF;
    IF l_latv_rec.attribute8 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute8 := NULL;
    END IF;
    IF l_latv_rec.attribute9 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute9 := NULL;
    END IF;
    IF l_latv_rec.attribute10 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute10 := NULL;
    END IF;
    IF l_latv_rec.attribute11 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute11 := NULL;
    END IF;
    IF l_latv_rec.attribute12 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute12 := NULL;
    END IF;
    IF l_latv_rec.attribute13 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute13 := NULL;
    END IF;
    IF l_latv_rec.attribute14 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute14 := NULL;
    END IF;
    IF l_latv_rec.attribute15 = FND_API.G_MISS_CHAR THEN
      l_latv_rec.attribute15 := NULL;
    END IF;
    IF l_latv_rec.org_id = FND_API.G_MISS_NUM THEN
      l_latv_rec.org_id := NULL;
    END IF;
    IF l_latv_rec.name = FND_API.G_MISS_CHAR THEN
      l_latv_rec.name := NULL;
    END IF;
    IF l_latv_rec.template_status = FND_API.G_MISS_CHAR THEN
      l_latv_rec.template_status := NULL;
    END IF;
    IF l_latv_rec.credit_review_purpose = FND_API.G_MISS_CHAR THEN
      l_latv_rec.credit_review_purpose := NULL;
    END IF;
    IF l_latv_rec.cust_credit_classification = FND_API.G_MISS_CHAR THEN
      l_latv_rec.cust_credit_classification := NULL;
    END IF;
    IF l_latv_rec.industry_class = FND_API.G_MISS_CHAR THEN
      l_latv_rec.industry_class := NULL;
    END IF;
    IF l_latv_rec.industry_code = FND_API.G_MISS_CHAR THEN
      l_latv_rec.industry_code := NULL;
    END IF;
    IF l_latv_rec.valid_from = FND_API.G_MISS_DATE THEN
      l_latv_rec.valid_from := NULL;
    END IF;
    IF l_latv_rec.valid_to = FND_API.G_MISS_DATE THEN
      l_latv_rec.valid_to := NULL;
    END IF;

    RETURN l_latv_rec;

  END null_out_defaults;

  -------------------
  -- FUNCTION get_rec
  -------------------
  FUNCTION get_rec (p_id             IN         NUMBER
                    ,x_return_status OUT NOCOPY VARCHAR2) RETURN latv_rec_type IS

    l_latv_rec           latv_rec_type;
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
      ,org_id
      ,name
      ,template_status
      ,credit_review_purpose
      ,cust_credit_classification
      ,industry_class
      ,industry_code
      ,valid_from
      ,valid_to
    INTO
      l_latv_rec.id
      ,l_latv_rec.object_version_number
      ,l_latv_rec.attribute_category
      ,l_latv_rec.attribute1
      ,l_latv_rec.attribute2
      ,l_latv_rec.attribute3
      ,l_latv_rec.attribute4
      ,l_latv_rec.attribute5
      ,l_latv_rec.attribute6
      ,l_latv_rec.attribute7
      ,l_latv_rec.attribute8
      ,l_latv_rec.attribute9
      ,l_latv_rec.attribute10
      ,l_latv_rec.attribute11
      ,l_latv_rec.attribute12
      ,l_latv_rec.attribute13
      ,l_latv_rec.attribute14
      ,l_latv_rec.attribute15
      ,l_latv_rec.org_id
      ,l_latv_rec.name
      ,l_latv_rec.template_status
      ,l_latv_rec.credit_review_purpose
      ,l_latv_rec.cust_credit_classification
      ,l_latv_rec.industry_class
      ,l_latv_rec.industry_code
      ,l_latv_rec.valid_from
      ,l_latv_rec.valid_to
    FROM OKL_LEASEAPP_TMPLS
    WHERE id = p_id;

    x_return_status := G_RET_STS_SUCCESS;
    RETURN l_latv_rec;

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
    IF (p_id = OKL_API.G_MISS_NUM OR
	    p_id IS NULL)
	THEN
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
    IF (p_object_version_number = OKL_API.G_MISS_NUM OR
	    p_object_version_number IS NULL)
	THEN
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

  ----------------------------
  -- PROCEDURE validate_org_id
  ----------------------------
  PROCEDURE validate_org_id (x_return_status OUT NOCOPY VARCHAR2, p_org_id IN NUMBER) IS
  BEGIN
    IF (p_org_id = OKL_API.G_MISS_NUM OR
	    p_org_id IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'org_id',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_org_id;

  --------------------------
  -- PROCEDURE validate_name
  --------------------------
  PROCEDURE validate_name (x_return_status OUT NOCOPY VARCHAR2, p_name IN VARCHAR2) IS
  BEGIN
    IF (p_name = OKL_API.G_MISS_CHAR OR
	    p_name IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'name',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_name;

  -------------------------------------
  -- PROCEDURE validate_template_status
  -------------------------------------
  PROCEDURE validate_template_status (x_return_status OUT NOCOPY VARCHAR2, p_template_status IN VARCHAR2) IS
  BEGIN
    IF (p_template_status = OKL_API.G_MISS_CHAR OR
	    p_template_status IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'template_status',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_template_status;

  -----------------------------------
  -- PROCEDURE validate_credit_review
  -----------------------------------
  PROCEDURE validate_credit_review (x_return_status OUT NOCOPY VARCHAR2, p_credit_review IN VARCHAR2) IS
  BEGIN
    IF (p_credit_review = OKL_API.G_MISS_CHAR OR
	    p_credit_review IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'credit_review',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_credit_review;

  ---------------------------------------
  -- PROCEDURE validate_cust_credit_class
  ---------------------------------------
  PROCEDURE validate_cust_credit_class (x_return_status OUT NOCOPY VARCHAR2, p_cust_credit_class IN VARCHAR2) IS
  BEGIN
    IF (p_cust_credit_class = OKL_API.G_MISS_CHAR OR
	    p_cust_credit_class IS NULL)
	THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_COL_ERROR,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'cust_credit_class',
                          p_token2        => G_PKG_NAME_TOKEN,
                          p_token2_value  => G_PKG_NAME);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := G_RET_STS_SUCCESS;
  END validate_cust_credit_class;

  -------------------------------
  -- FUNCTION validate_attributes
  -------------------------------
  FUNCTION validate_attributes (p_latv_rec IN latv_rec_type) RETURN VARCHAR2 IS

    l_return_status                VARCHAR2(1);

  BEGIN

    validate_id (l_return_status, p_latv_rec.id);
    validate_object_version_number (l_return_status, p_latv_rec.object_version_number);
    validate_org_id (l_return_status, p_latv_rec.org_id);
    validate_name (l_return_status, p_latv_rec.name);
    validate_template_status (l_return_status, p_latv_rec.template_status);
    validate_credit_review (l_return_status, p_latv_rec.credit_review_purpose);
    validate_cust_credit_class (l_return_status, p_latv_rec.cust_credit_classification);

    RETURN l_return_status;

  END validate_attributes;

  ----------------------------
  -- PROCEDURE validate_record
  ----------------------------
  FUNCTION validate_record (p_latv_rec IN latv_rec_type) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1);
    l_check_tmplt_number           VARCHAR2(1);
    l_check_tmplt_combination      VARCHAR2(1);
    --Declare Cursor Definations
    CURSOR c_chk_tmlt_number IS
      SELECT 'x'
      FROM Okl_Leaseapp_Templates LATV
      WHERE LATV.name  = p_latv_rec.name
        AND LATV.id <> nvl(p_latv_rec.id,-99999);
  BEGIN
    l_return_status := G_RET_STS_SUCCESS;
    -- check for unique Lease Application Template Number
    OPEN c_chk_tmlt_number;
    FETCH c_chk_tmlt_number INTO l_check_tmplt_number;
    CLOSE c_chk_tmlt_number;
    IF l_check_tmplt_number = 'x' THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => 'OKL_SO_LSEAPP_TMPLT_EXISTS',
                          p_token1       => 'NAME',
                          p_token1_value => p_latv_rec.name);
      -- notify caller of an error
      l_return_status := G_RET_STS_ERROR;
    END IF;
    RETURN l_return_status;
  END validate_record;

  -----------------------------
  -- PROECDURE migrate (V -> B)
  -----------------------------
  PROCEDURE migrate (p_from IN latv_rec_type, p_to IN OUT NOCOPY lat_rec_type) IS

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
    p_to.org_id                         :=  p_from.org_id;
    p_to.name                           :=  p_from.name;
    p_to.template_status                :=  p_from.template_status;
    p_to.credit_review_purpose          :=  p_from.credit_review_purpose;
    p_to.cust_credit_classification     :=  p_from.cust_credit_classification;
    p_to.industry_class                 :=  p_from.industry_class;
    p_to.industry_code                  :=  p_from.industry_code;
    p_to.valid_from                     :=  p_from.valid_from;
    p_to.valid_to                       :=  p_from.valid_to;

  END migrate;

  ---------------------------
  -- PROCEDURE insert_row (B)
  ---------------------------
  PROCEDURE insert_row (x_return_status OUT NOCOPY VARCHAR2, p_lat_rec IN lat_rec_type) IS

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (B)';

    INSERT INTO okl_leaseapp_templates (
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
      ,org_id
      ,name
      ,template_status
      ,credit_review_purpose
      ,cust_credit_classification
      ,industry_class
      ,industry_code
      ,valid_from
      ,valid_to
      )
    VALUES
      (
       p_lat_rec.id
      ,p_lat_rec.object_version_number
      ,p_lat_rec.attribute_category
      ,p_lat_rec.attribute1
      ,p_lat_rec.attribute2
      ,p_lat_rec.attribute3
      ,p_lat_rec.attribute4
      ,p_lat_rec.attribute5
      ,p_lat_rec.attribute6
      ,p_lat_rec.attribute7
      ,p_lat_rec.attribute8
      ,p_lat_rec.attribute9
      ,p_lat_rec.attribute10
      ,p_lat_rec.attribute11
      ,p_lat_rec.attribute12
      ,p_lat_rec.attribute13
      ,p_lat_rec.attribute14
      ,p_lat_rec.attribute15
      ,G_USER_ID
      ,SYSDATE
      ,G_USER_ID
      ,SYSDATE
      ,G_LOGIN_ID
      ,p_lat_rec.org_id
      ,p_lat_rec.name
      ,p_lat_rec.template_status
      ,p_lat_rec.credit_review_purpose
      ,p_lat_rec.cust_credit_classification
      ,p_lat_rec.industry_class
      ,p_lat_rec.industry_code
      ,p_lat_rec.valid_from
      ,p_lat_rec.valid_to
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
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type) IS

    l_return_status                VARCHAR2(1);

    l_latv_rec                     latv_rec_type;
    l_lat_rec                      lat_rec_type;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (V)';

    l_latv_rec  := null_out_defaults (p_latv_rec);

    SELECT okl_lat_seq.nextval INTO l_latv_rec.ID FROM DUAL;

    l_latv_rec.OBJECT_VERSION_NUMBER := 1;

    l_return_status := validate_attributes(l_latv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record(l_latv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_latv_rec, l_lat_rec);

    insert_row (x_return_status => l_return_status, p_lat_rec => l_lat_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_latv_rec      := l_latv_rec;
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
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    insert_row (x_return_status                => l_return_status,
                p_latv_rec                     => p_latv_rec,
                x_latv_rec                     => x_latv_rec);

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
    p_latv_tbl                     IN latv_tbl_type,
    x_latv_tbl                     OUT NOCOPY latv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;

    l_prog_name  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.insert_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_latv_tbl.COUNT > 0) THEN
      i := p_latv_tbl.FIRST;
      LOOP
        IF p_latv_tbl.EXISTS(i) THEN

          insert_row (x_return_status                => l_return_status,
                      p_latv_rec                     => p_latv_tbl(i),
                      x_latv_rec                     => x_latv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_latv_tbl.LAST);
          i := p_latv_tbl.NEXT(i);

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
  PROCEDURE lock_row (x_return_status OUT NOCOPY VARCHAR2, p_lat_rec IN lat_rec_type) IS

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT (E_Resource_Busy, -00054);

    CURSOR lock_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASEAPP_TEMPLATES
     WHERE ID = p_lat_rec.id
       AND OBJECT_VERSION_NUMBER = p_lat_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_LEASEAPP_TEMPLATES
     WHERE ID = p_lat_rec.id;

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

      ELSIF lc_object_version_number <> p_lat_rec.object_version_number THEN

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
  PROCEDURE update_row(x_return_status OUT NOCOPY VARCHAR2, p_lat_rec IN lat_rec_type) IS

    l_return_status           VARCHAR2(1);
    l_prog_name               VARCHAR2(61);
  BEGIN
    l_prog_name := G_PKG_NAME||'.update_row (B)';

    lock_row (x_return_status => l_return_status, p_lat_rec => p_lat_rec);

    IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF l_return_status = G_RET_STS_ERROR THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE okl_leaseapp_templates
    SET
      object_version_number = p_lat_rec.object_version_number+1
      ,attribute_category = p_lat_rec.attribute_category
      ,attribute1 = p_lat_rec.attribute1
      ,attribute2 = p_lat_rec.attribute2
      ,attribute3 = p_lat_rec.attribute3
      ,attribute4 = p_lat_rec.attribute4
      ,attribute5 = p_lat_rec.attribute5
      ,attribute6 = p_lat_rec.attribute6
      ,attribute7 = p_lat_rec.attribute7
      ,attribute8 = p_lat_rec.attribute8
      ,attribute9 = p_lat_rec.attribute9
      ,attribute10 = p_lat_rec.attribute10
      ,attribute11 = p_lat_rec.attribute11
      ,attribute12 = p_lat_rec.attribute12
      ,attribute13 = p_lat_rec.attribute13
      ,attribute14 = p_lat_rec.attribute14
      ,attribute15 = p_lat_rec.attribute15
      ,org_id = p_lat_rec.org_id
      ,name = p_lat_rec.name
      ,template_status = p_lat_rec.template_status
      ,credit_review_purpose = p_lat_rec.credit_review_purpose
      ,cust_credit_classification = p_lat_rec.cust_credit_classification
      ,industry_class = p_lat_rec.industry_class
      ,industry_code = p_lat_rec.industry_code
      ,valid_from = p_lat_rec.valid_from
      ,valid_to = p_lat_rec.valid_to
    WHERE id = p_lat_rec.id;

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
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type) IS

    l_prog_name                    VARCHAR2(61);

    l_return_status                VARCHAR2(1);
    l_latv_rec                     latv_rec_type;
    l_lat_rec                      lat_rec_type;

    ----------------------
    -- populate_new_record
    ----------------------
    FUNCTION populate_new_record (p_latv_rec IN  latv_rec_type,
                                  x_latv_rec OUT NOCOPY latv_rec_type) RETURN VARCHAR2 IS

      l_prog_name          VARCHAR2(61)          := G_PKG_NAME||'.populate_new_record';
      l_return_status      VARCHAR2(1);
      l_db_latv_rec        latv_rec_type;

    BEGIN

      x_latv_rec    := p_latv_rec;
      l_db_latv_rec := get_rec (p_latv_rec.id, l_return_status);

      IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
      ELSIF l_return_status = G_RET_STS_ERROR THEN
        RAISE OKL_API.G_EXCEPTION_ERROR;
      END IF;

      IF x_latv_rec.attribute_category IS NULL THEN
        x_latv_rec.attribute_category := l_db_latv_rec.attribute_category;
      END IF;
      IF x_latv_rec.attribute1 IS NULL THEN
        x_latv_rec.attribute1 := l_db_latv_rec.attribute1;
      END IF;
      IF x_latv_rec.attribute2 IS NULL THEN
        x_latv_rec.attribute2 := l_db_latv_rec.attribute2;
      END IF;
      IF x_latv_rec.attribute3 IS NULL THEN
        x_latv_rec.attribute3 := l_db_latv_rec.attribute3;
      END IF;
      IF x_latv_rec.attribute4 IS NULL THEN
        x_latv_rec.attribute4 := l_db_latv_rec.attribute4;
      END IF;
      IF x_latv_rec.attribute5 IS NULL THEN
        x_latv_rec.attribute5 := l_db_latv_rec.attribute5;
      END IF;
      IF x_latv_rec.attribute6 IS NULL THEN
        x_latv_rec.attribute6 := l_db_latv_rec.attribute6;
      END IF;
      IF x_latv_rec.attribute7 IS NULL THEN
        x_latv_rec.attribute7 := l_db_latv_rec.attribute7;
      END IF;
      IF x_latv_rec.attribute8 IS NULL THEN
        x_latv_rec.attribute8 := l_db_latv_rec.attribute8;
      END IF;
      IF x_latv_rec.attribute9 IS NULL THEN
        x_latv_rec.attribute9 := l_db_latv_rec.attribute9;
      END IF;
      IF x_latv_rec.attribute10 IS NULL THEN
        x_latv_rec.attribute10 := l_db_latv_rec.attribute10;
      END IF;
      IF x_latv_rec.attribute11 IS NULL THEN
        x_latv_rec.attribute11 := l_db_latv_rec.attribute11;
      END IF;
      IF x_latv_rec.attribute12 IS NULL THEN
        x_latv_rec.attribute12 := l_db_latv_rec.attribute12;
      END IF;
      IF x_latv_rec.attribute13 IS NULL THEN
        x_latv_rec.attribute13 := l_db_latv_rec.attribute13;
      END IF;
      IF x_latv_rec.attribute14 IS NULL THEN
        x_latv_rec.attribute14 := l_db_latv_rec.attribute14;
      END IF;
      IF x_latv_rec.attribute15 IS NULL THEN
        x_latv_rec.attribute15 := l_db_latv_rec.attribute15;
      END IF;
      IF x_latv_rec.org_id IS NULL THEN
        x_latv_rec.org_id := l_db_latv_rec.org_id;
      END IF;
      IF x_latv_rec.name IS NULL THEN
        x_latv_rec.name := l_db_latv_rec.name;
      END IF;
      IF x_latv_rec.template_status IS NULL THEN
        x_latv_rec.template_status := l_db_latv_rec.template_status;
      END IF;
      IF x_latv_rec.credit_review_purpose IS NULL THEN
        x_latv_rec.credit_review_purpose := l_db_latv_rec.credit_review_purpose;
      END IF;
      IF x_latv_rec.cust_credit_classification IS NULL THEN
        x_latv_rec.cust_credit_classification := l_db_latv_rec.cust_credit_classification;
      END IF;
      IF x_latv_rec.industry_class IS NULL THEN
        x_latv_rec.industry_class := l_db_latv_rec.industry_class;
      END IF;
      IF x_latv_rec.industry_code IS NULL THEN
        x_latv_rec.industry_code := l_db_latv_rec.industry_code;
      END IF;
      IF x_latv_rec.valid_from IS NULL THEN
        x_latv_rec.valid_from := l_db_latv_rec.valid_from;
      END IF;
      IF x_latv_rec.valid_to IS NULL THEN
        x_latv_rec.valid_to := l_db_latv_rec.valid_to;
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

    l_return_status := populate_new_record (p_latv_rec, l_latv_rec);
    l_latv_rec      := null_out_defaults(l_latv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_attributes (l_latv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := validate_record (l_latv_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    migrate (l_latv_rec, l_lat_rec);

    update_row (x_return_status => l_return_status, p_lat_rec => l_lat_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;
    x_latv_rec      := l_latv_rec;

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
    p_latv_rec                     IN latv_rec_type,
    x_latv_rec                     OUT NOCOPY latv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    update_row (x_return_status                => l_return_status,
                p_latv_rec                     => p_latv_rec,
                x_latv_rec                     => x_latv_rec);

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
    p_latv_tbl                     IN latv_tbl_type,
    x_latv_tbl                     OUT NOCOPY latv_tbl_type) IS

    l_return_status              VARCHAR2(1);
    i                            BINARY_INTEGER;
    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.update_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    x_latv_tbl := p_latv_tbl;

    IF (p_latv_tbl.COUNT > 0) THEN

      i := p_latv_tbl.FIRST;

      LOOP

        IF p_latv_tbl.EXISTS(i) THEN
          update_row (x_return_status                => l_return_status,
                      p_latv_rec                     => p_latv_tbl(i),
                      x_latv_rec                     => x_latv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_latv_tbl.LAST);
          i := p_latv_tbl.NEXT(i);

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
    p_latv_rec                     IN latv_rec_type) IS

    l_return_status              VARCHAR2(1);

    l_prog_name                  VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (REC)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    delete_row (x_return_status                => l_return_status,
                p_id                           => p_latv_rec.id);

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
    p_latv_tbl                     IN latv_tbl_type) IS

    l_return_status                VARCHAR2(1);
    i                              BINARY_INTEGER;

    l_prog_name                    VARCHAR2(61);

  BEGIN

    l_prog_name := G_PKG_NAME||'.delete_row (TBL)';

    IF p_init_msg_list = G_TRUE THEN
      FND_MSG_PUB.initialize;
    END IF;

    IF (p_latv_tbl.COUNT > 0) THEN

      i := p_latv_tbl.FIRST;

      LOOP

        IF p_latv_tbl.EXISTS(i) THEN

          delete_row (x_return_status                => l_return_status,
                      p_id                           => p_latv_tbl(i).id);

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = p_latv_tbl.LAST);
          i := p_latv_tbl.NEXT(i);

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

END OKL_LAT_PVT;

/
