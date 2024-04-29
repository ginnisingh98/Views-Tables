--------------------------------------------------------
--  DDL for Package Body OKC_QCL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QCL_PVT" AS
/* $Header: OKCSQCLB.pls 120.0 2005/05/25 19:10:27 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_qclv_rec IN  qclv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPER_CASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_INVALID_END_DATE    CONSTANT VARCHAR2(200) := 'INVALID_END_DATE';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_QA_CHECK_LISTS_V';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_name
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_name(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qclv_rec      IN    qclv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    CURSOR l_unq_cur(p_name varchar2) is
	  SELECT id from OKC_QA_CHECK_LISTS_V where name=p_name;
    l_id number:=OKC_API.G_MISS_NUM;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qclv_rec.name = OKC_API.G_MISS_CHAR OR
        p_qclv_rec.name IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'name');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

/* bug 3388521 - do not check for upper case for name - translation issues - john
    -- verify that data is uppercase
    IF (p_qclv_rec.name <> upper(p_qclv_rec.name)) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UPPER_CASE_REQUIRED,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'name');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
*/
    -- check for uniqueness
    --smhanda bug 1699203- removed check_unique
    open l_unq_cur(p_qclv_rec.name);
    Fetch l_unq_cur into l_id;
    close l_unq_cur;
    IF (l_id<>OKC_API.G_MISS_NUM AND l_id<>nvl(p_qclv_rec.id,0)) THEN
		x_return_status:=OKC_API.G_RET_STS_ERROR;
		OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
					     p_msg_name      =>  'OKC_DUP_QCL_NAME');
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_name;
--

  -- Start of comments
  --
  -- Procedure Name  : validate_begin_date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_begin_date(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qclv_rec      IN    qclv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qclv_rec.begin_date = OKC_API.G_MISS_DATE OR
        p_qclv_rec.begin_date IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'begin_date');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_begin_date;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_end_date
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_end_date(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qclv_rec      IN    qclv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_end_date;

  PROCEDURE validate_application_id(
     x_return_status     OUT NOCOPY VARCHAR2,
     p_qclv_rec              IN qclv_rec_type) IS
     Cursor application_id_cur(p_application_id IN NUMBER) IS
     select '1'
     from fnd_application
     where application_id = p_application_id;
     l_app_id        VARCHAR2(1) := '?';
    BEGIN
     -- initialize return status
     x_return_status := OKC_API.G_RET_STS_SUCCESS;

     IF ((p_qclv_rec.application_id IS NOT NULL) AND (p_qclv_rec.application_id <> OKC_API.G_MISS_NUM)) THEN
     --Check whether application id exists in the fnd_application or not
     OPEN application_id_cur(p_qclv_rec.application_id);
     FETCH application_id_cur INTO l_app_id;
     CLOSE application_id_cur ;
     IF l_app_id = '?' THEN
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => g_invalid_value,
                             p_token1       => g_col_name_token,
                             p_token1_value => 'application_id');
               x_return_status := OKC_API.G_RET_STS_ERROR;
          raise G_EXCEPTION_HALT_VALIDATION;
     END IF;
     END IF;
    EXCEPTION
          when G_EXCEPTION_HALT_VALIDATION then
          null;

           when OTHERS then
          -- store SQL error message on message stack for caller
          OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                             p_msg_name     => g_unexpected_error,
                             p_token1       => g_sqlcode_token,
                             p_token1_value => sqlcode,
                             p_token2       => g_sqlerrm_token,
                             p_token2_value => sqlerrm);
          -- notify caller of an UNEXPECTED error
          x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_application_id;

 -- Start of comments
  --
  -- Procedure Name  : validate_default_YN
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_default_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qclv_rec      IN    qclv_rec_type
  ) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

   -- check allowed values
    IF (UPPER(p_qclv_rec.default_yn) NOT IN ('Y','N')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'default_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
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
    -- notify caller of an error as UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_default_yn;

--
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_qclv_rec IN  qclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    validate_name(
      x_return_status => l_return_status,
      p_qclv_rec      => p_qclv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--

    validate_begin_date(
      x_return_status => l_return_status,
      p_qclv_rec      => p_qclv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_end_date(
      x_return_status => l_return_status,
      p_qclv_rec      => p_qclv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
  validate_application_id(
       x_return_status => l_return_status,
       p_qclv_rec      => p_qclv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

  validate_default_YN(
       x_return_status => l_return_status,
       p_qclv_rec      => p_qclv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE
      (p_app_name     => G_APP_NAME,
       p_msg_name     => G_UNEXPECTED_ERROR,
       p_token1       => G_SQLCODE_TOKEN,
       p_token1_value => SQLCODE,
       p_token2       => G_SQLERRM_TOKEN,
       p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- return status to caller
    RETURN x_return_status;

  END Validate_Attributes;

/***********************  END HAND-CODED  **************************/

/* $Header: OKCSQCLB.pls 120.0 2005/05/25 19:10:27 appldev noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
    l_id Number;
-- for datamerge's data (for seeded date id should be greater than or equal to 11000 and less than 50000)
    cursor seed_c is
      select
	 nvl(max(id), 11000) + 1
      from
         OKC_QA_CHECK_LISTS_V
      where
         id >= 11000 AND id < 50000;
  BEGIN
   if fnd_global.user_id = 1 then
      open seed_c;
      fetch seed_c into l_id;
      close seed_c;
      return(l_id);
   else
    RETURN(okc_p_util.raw_to_number(sys_guid()));
   end if;
  END get_Seq_id;

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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKC_QA_CHECK_LISTS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_QA_CHECK_LISTS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_QA_CHECK_LISTS_TL T SET (
        NAME,
        SHORT_DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.SHORT_DESCRIPTION
                                FROM OKC_QA_CHECK_LISTS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_QA_CHECK_LISTS_TL SUBB, OKC_QA_CHECK_LISTS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.SHORT_DESCRIPTION <> SUBT.SHORT_DESCRIPTION
                      OR (SUBB.SHORT_DESCRIPTION IS NULL AND SUBT.SHORT_DESCRIPTION IS NOT NULL)
                      OR (SUBB.SHORT_DESCRIPTION IS NOT NULL AND SUBT.SHORT_DESCRIPTION IS NULL)
              ));

    INSERT INTO OKC_QA_CHECK_LISTS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        SHORT_DESCRIPTION,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
            B.ID,
            L.LANGUAGE_CODE,
            B.SOURCE_LANG,
            B.SFWT_FLAG,
            B.NAME,
            B.SHORT_DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_QA_CHECK_LISTS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_QA_CHECK_LISTS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_QA_CHECK_LISTS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qcl_rec                      IN qcl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qcl_rec_type IS
    CURSOR qcl_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            BEGIN_DATE,
            OBJECT_VERSION_NUMBER,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            END_DATE,
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
            ATTRIBUTE15,
            APPLICATION_ID,
            DEFAULT_YN
      FROM Okc_Qa_Check_Lists_B
     WHERE okc_qa_check_lists_b.id = p_id;
    l_qcl_pk                       qcl_pk_csr%ROWTYPE;
    l_qcl_rec                      qcl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qcl_pk_csr (p_qcl_rec.id);
    FETCH qcl_pk_csr INTO
              l_qcl_rec.ID,
              l_qcl_rec.BEGIN_DATE,
              l_qcl_rec.OBJECT_VERSION_NUMBER,
              l_qcl_rec.CREATED_BY,
              l_qcl_rec.CREATION_DATE,
              l_qcl_rec.LAST_UPDATED_BY,
              l_qcl_rec.LAST_UPDATE_DATE,
              l_qcl_rec.END_DATE,
              l_qcl_rec.LAST_UPDATE_LOGIN,
              l_qcl_rec.ATTRIBUTE_CATEGORY,
              l_qcl_rec.ATTRIBUTE1,
              l_qcl_rec.ATTRIBUTE2,
              l_qcl_rec.ATTRIBUTE3,
              l_qcl_rec.ATTRIBUTE4,
              l_qcl_rec.ATTRIBUTE5,
              l_qcl_rec.ATTRIBUTE6,
              l_qcl_rec.ATTRIBUTE7,
              l_qcl_rec.ATTRIBUTE8,
              l_qcl_rec.ATTRIBUTE9,
              l_qcl_rec.ATTRIBUTE10,
              l_qcl_rec.ATTRIBUTE11,
              l_qcl_rec.ATTRIBUTE12,
              l_qcl_rec.ATTRIBUTE13,
              l_qcl_rec.ATTRIBUTE14,
              l_qcl_rec.ATTRIBUTE15,
              l_qcl_rec.APPLICATION_ID,
              l_qcl_rec.DEFAULT_YN;
    x_no_data_found := qcl_pk_csr%NOTFOUND;
    CLOSE qcl_pk_csr;
    RETURN(l_qcl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qcl_rec                      IN qcl_rec_type
  ) RETURN qcl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qcl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_QA_CHECK_LISTS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_qa_check_lists_tl_rec_type IS
    CURSOR qcl_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            SHORT_DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Qa_Check_Lists_Tl
     WHERE okc_qa_check_lists_tl.id = p_id
       AND okc_qa_check_lists_tl.language = p_language;
    l_qcl_pktl                     qcl_pktl_csr%ROWTYPE;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qcl_pktl_csr (p_okc_qa_check_lists_tl_rec.id,
                       p_okc_qa_check_lists_tl_rec.language);
    FETCH qcl_pktl_csr INTO
              l_okc_qa_check_lists_tl_rec.ID,
              l_okc_qa_check_lists_tl_rec.LANGUAGE,
              l_okc_qa_check_lists_tl_rec.SOURCE_LANG,
              l_okc_qa_check_lists_tl_rec.SFWT_FLAG,
              l_okc_qa_check_lists_tl_rec.NAME,
              l_okc_qa_check_lists_tl_rec.SHORT_DESCRIPTION,
              l_okc_qa_check_lists_tl_rec.CREATED_BY,
              l_okc_qa_check_lists_tl_rec.CREATION_DATE,
              l_okc_qa_check_lists_tl_rec.LAST_UPDATED_BY,
              l_okc_qa_check_lists_tl_rec.LAST_UPDATE_DATE,
              l_okc_qa_check_lists_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := qcl_pktl_csr%NOTFOUND;
    CLOSE qcl_pktl_csr;
    RETURN(l_okc_qa_check_lists_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type
  ) RETURN okc_qa_check_lists_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_qa_check_lists_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_QA_CHECK_LISTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qclv_rec                     IN qclv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qclv_rec_type IS
    CURSOR okc_qclv_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            NAME,
            SHORT_DESCRIPTION,
            BEGIN_DATE,
            END_DATE,
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
            LAST_UPDATE_LOGIN,
            APPLICATION_ID,
            DEFAULT_YN
      FROM Okc_Qa_Check_Lists_V
     WHERE okc_qa_check_lists_v.id = p_id;
    l_okc_qclv_pk                  okc_qclv_pk_csr%ROWTYPE;
    l_qclv_rec                     qclv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_qclv_pk_csr (p_qclv_rec.id);
    FETCH okc_qclv_pk_csr INTO
              l_qclv_rec.ID,
              l_qclv_rec.OBJECT_VERSION_NUMBER,
              l_qclv_rec.SFWT_FLAG,
              l_qclv_rec.NAME,
              l_qclv_rec.SHORT_DESCRIPTION,
              l_qclv_rec.BEGIN_DATE,
              l_qclv_rec.END_DATE,
              l_qclv_rec.ATTRIBUTE_CATEGORY,
              l_qclv_rec.ATTRIBUTE1,
              l_qclv_rec.ATTRIBUTE2,
              l_qclv_rec.ATTRIBUTE3,
              l_qclv_rec.ATTRIBUTE4,
              l_qclv_rec.ATTRIBUTE5,
              l_qclv_rec.ATTRIBUTE6,
              l_qclv_rec.ATTRIBUTE7,
              l_qclv_rec.ATTRIBUTE8,
              l_qclv_rec.ATTRIBUTE9,
              l_qclv_rec.ATTRIBUTE10,
              l_qclv_rec.ATTRIBUTE11,
              l_qclv_rec.ATTRIBUTE12,
              l_qclv_rec.ATTRIBUTE13,
              l_qclv_rec.ATTRIBUTE14,
              l_qclv_rec.ATTRIBUTE15,
              l_qclv_rec.CREATED_BY,
              l_qclv_rec.CREATION_DATE,
              l_qclv_rec.LAST_UPDATED_BY,
              l_qclv_rec.LAST_UPDATE_DATE,
              l_qclv_rec.LAST_UPDATE_LOGIN,
              l_qclv_rec.APPLICATION_ID,
              l_qclv_rec.DEFAULT_YN;
    x_no_data_found := okc_qclv_pk_csr%NOTFOUND;
    CLOSE okc_qclv_pk_csr;
    RETURN(l_qclv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qclv_rec                     IN qclv_rec_type
  ) RETURN qclv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qclv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_QA_CHECK_LISTS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qclv_rec	IN qclv_rec_type
  ) RETURN qclv_rec_type IS
    l_qclv_rec	qclv_rec_type := p_qclv_rec;
  BEGIN
    IF (l_qclv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qclv_rec.object_version_number := NULL;
    END IF;
    IF (l_qclv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_qclv_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.name := NULL;
    END IF;
    IF (l_qclv_rec.short_description = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.short_description := NULL;
    END IF;
    IF (l_qclv_rec.begin_date = OKC_API.G_MISS_DATE) THEN
      l_qclv_rec.begin_date := NULL;
    END IF;
    IF (l_qclv_rec.end_date = OKC_API.G_MISS_DATE) THEN
      l_qclv_rec.end_date := NULL;
    END IF;
    IF (l_qclv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute_category := NULL;
    END IF;
    IF (l_qclv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute1 := NULL;
    END IF;
    IF (l_qclv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute2 := NULL;
    END IF;
    IF (l_qclv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute3 := NULL;
    END IF;
    IF (l_qclv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute4 := NULL;
    END IF;
    IF (l_qclv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute5 := NULL;
    END IF;
    IF (l_qclv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute6 := NULL;
    END IF;
    IF (l_qclv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute7 := NULL;
    END IF;
    IF (l_qclv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute8 := NULL;
    END IF;
    IF (l_qclv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute9 := NULL;
    END IF;
    IF (l_qclv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute10 := NULL;
    END IF;
    IF (l_qclv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute11 := NULL;
    END IF;
    IF (l_qclv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute12 := NULL;
    END IF;
    IF (l_qclv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute13 := NULL;
    END IF;
    IF (l_qclv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute14 := NULL;
    END IF;
    IF (l_qclv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.attribute15 := NULL;
    END IF;
    IF (l_qclv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qclv_rec.created_by := NULL;
    END IF;
    IF (l_qclv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qclv_rec.creation_date := NULL;
    END IF;
    IF (l_qclv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qclv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qclv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qclv_rec.last_update_date := NULL;
    END IF;
    IF (l_qclv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qclv_rec.last_update_login := NULL;
    END IF;
    IF (l_qclv_rec.application_id = OKC_API.G_MISS_NUM) THEN
      l_qclv_rec.application_id := NULL;
    END IF;
    IF (l_qclv_rec.default_yn = OKC_API.G_MISS_CHAR) THEN
      l_qclv_rec.default_yn := NULL;
    END IF;
    RETURN(l_qclv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKC_QA_CHECK_LISTS_V --
  --------------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_qclv_rec IN  qclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_qclv_rec.id = OKC_API.G_MISS_NUM OR
       p_qclv_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qclv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_qclv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qclv_rec.name = OKC_API.G_MISS_CHAR OR
          p_qclv_rec.name IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'name');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qclv_rec.begin_date = OKC_API.G_MISS_DATE OR
          p_qclv_rec.begin_date IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'begin_date');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKC_QA_CHECK_LISTS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_qclv_rec IN qclv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    CURSOR cur_qcl IS
      SELECT 'x'
      FROM   okc_qa_check_lists_b
      WHERE  application_id      = p_qclv_rec.application_id
      AND    default_yn  = 'Y'
      AND id <> p_qclv_rec.id;

   CURSOR cur_app_name is
     SELECT application_name
     FROM fnd_application_vl
     WHERE application_id = p_qclv_rec.application_id;

     l_row_found   BOOLEAN := FALSE;
     l_default       VARCHAR2(1);
     app_name        VARCHAR2(100);
  BEGIN
    -- check for data before processing
    IF ((p_qclv_rec.begin_date <> OKC_API.G_MISS_DATE AND
        p_qclv_rec.begin_date IS NOT NULL) AND
        (p_qclv_rec.end_date <> OKC_API.G_MISS_DATE AND
         p_qclv_rec.end_date IS NOT NULL)) THEN
      IF (p_qclv_rec.end_date < p_qclv_rec.begin_date) THEN
        OKC_API.set_message(
          p_app_name     => G_APP_NAME,
          p_msg_name     => G_INVALID_END_DATE);

        -- notify caller of an error
        l_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    END IF;

   IF p_qclv_rec.default_yn = 'Y' then
    IF ((p_qclv_rec.application_id IS NOT NULL)
         AND  (p_qclv_rec.application_id <> OKC_API.G_MISS_NUM))

    THEN
           OPEN  cur_qcl;
           FETCH cur_qcl INTO l_default;
           l_row_found := cur_qcl%FOUND;
           CLOSE cur_qcl;

           IF (l_row_found)
           THEN
                OPEN cur_app_name;
                FETCH cur_app_name into app_name;
                CLOSE cur_app_name;
                     OKC_API.set_message(
                          p_app_name     =>    G_APP_NAME,
                          p_msg_name     =>    'OKC_DUP_DEF_APP',
                          p_token1       =>  'APPLICATION_NAME',
                          p_token1_value  =>    app_name);
                     l_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
   END IF;
END IF;


    RETURN (l_return_status);
  EXCEPTION
    when G_EXCEPTION_HALT_VALIDATION then
      RETURN (l_return_status);

    WHEN OTHERS THEN
      -- store SQL error message on message stack
      OKC_API.SET_MESSAGE(
        p_app_name        => G_APP_NAME,
        p_msg_name        => G_UNEXPECTED_ERROR,
        p_token1	        => G_SQLCODE_TOKEN,
        p_token1_value    => SQLCODE,
        p_token2          => G_SQLERRM_TOKEN,
        p_token2_value    => SQLERRM);
      -- notify caller of an error as UNEXPETED error
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qclv_rec_type,
    p_to	IN OUT NOCOPY qcl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.begin_date := p_from.begin_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.end_date := p_from.end_date;
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
    p_to.application_id := p_from.application_id;
    p_to.default_yn := p_from.default_yn;
  END migrate;
  PROCEDURE migrate (
    p_from	IN qcl_rec_type,
    p_to	IN OUT NOCOPY qclv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.begin_date := p_from.begin_date;
    p_to.object_version_number := p_from.object_version_number;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.end_date := p_from.end_date;
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
    p_to.application_id := p_from.application_id;
    p_to.default_yn := p_from.default_yn;
  END migrate;
  PROCEDURE migrate (
    p_from	IN qclv_rec_type,
    p_to	IN OUT NOCOPY okc_qa_check_lists_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.short_description := p_from.short_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_qa_check_lists_tl_rec_type,
    p_to	IN OUT NOCOPY qclv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.short_description := p_from.short_description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKC_QA_CHECK_LISTS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN qclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
    l_qcl_rec                      qcl_rec_type;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_qclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qclv_rec);
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
  -- PL/SQL TBL validate_row for:QCLV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN qclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qclv_tbl.COUNT > 0) THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qclv_rec                     => p_qclv_tbl(i));
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKC_QA_CHECK_LISTS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_rec                      IN qcl_rec_type,
    x_qcl_rec                      OUT NOCOPY qcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qcl_rec                      qcl_rec_type := p_qcl_rec;
    l_def_qcl_rec                  qcl_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qcl_rec IN  qcl_rec_type,
      x_qcl_rec OUT NOCOPY qcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcl_rec := p_qcl_rec;
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
      p_qcl_rec,                         -- IN
      l_qcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_QA_CHECK_LISTS_B(
        id,
        begin_date,
        object_version_number,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        end_date,
        last_update_login,
	application_id,
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
        default_yn)
      VALUES (
        l_qcl_rec.id,
        l_qcl_rec.begin_date,
        l_qcl_rec.object_version_number,
        l_qcl_rec.created_by,
        l_qcl_rec.creation_date,
        l_qcl_rec.last_updated_by,
        l_qcl_rec.last_update_date,
        l_qcl_rec.end_date,
        l_qcl_rec.last_update_login,
        l_qcl_rec.application_id,
        l_qcl_rec.attribute_category,
        l_qcl_rec.attribute1,
        l_qcl_rec.attribute2,
        l_qcl_rec.attribute3,
        l_qcl_rec.attribute4,
        l_qcl_rec.attribute5,
        l_qcl_rec.attribute6,
        l_qcl_rec.attribute7,
        l_qcl_rec.attribute8,
        l_qcl_rec.attribute9,
        l_qcl_rec.attribute10,
        l_qcl_rec.attribute11,
        l_qcl_rec.attribute12,
        l_qcl_rec.attribute13,
        l_qcl_rec.attribute14,
        l_qcl_rec.attribute15,
        l_qcl_rec.default_yn);
    -- Set OUT values
    x_qcl_rec := l_qcl_rec;
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
  ------------------------------------------
  -- insert_row for:OKC_QA_CHECK_LISTS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type,
    x_okc_qa_check_lists_tl_rec    OUT NOCOPY okc_qa_check_lists_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type := p_okc_qa_check_lists_tl_rec;
    ldefokcqacheckliststlrec       okc_qa_check_lists_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_qa_check_lists_tl_rec IN  okc_qa_check_lists_tl_rec_type,
      x_okc_qa_check_lists_tl_rec OUT NOCOPY okc_qa_check_lists_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_qa_check_lists_tl_rec := p_okc_qa_check_lists_tl_rec;
      x_okc_qa_check_lists_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_qa_check_lists_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_qa_check_lists_tl_rec,       -- IN
      l_okc_qa_check_lists_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_qa_check_lists_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_QA_CHECK_LISTS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          short_description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_qa_check_lists_tl_rec.id,
          l_okc_qa_check_lists_tl_rec.language,
          l_okc_qa_check_lists_tl_rec.source_lang,
          l_okc_qa_check_lists_tl_rec.sfwt_flag,
          l_okc_qa_check_lists_tl_rec.name,
          l_okc_qa_check_lists_tl_rec.short_description,
          l_okc_qa_check_lists_tl_rec.created_by,
          l_okc_qa_check_lists_tl_rec.creation_date,
          l_okc_qa_check_lists_tl_rec.last_updated_by,
          l_okc_qa_check_lists_tl_rec.last_update_date,
          l_okc_qa_check_lists_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_qa_check_lists_tl_rec := l_okc_qa_check_lists_tl_rec;
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
  -----------------------------------------
  -- insert_row for:OKC_QA_CHECK_LISTS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qclv_rec                     qclv_rec_type;
    l_def_qclv_rec                 qclv_rec_type;
    l_qcl_rec                      qcl_rec_type;
    lx_qcl_rec                     qcl_rec_type;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
    lx_okc_qa_check_lists_tl_rec   okc_qa_check_lists_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qclv_rec	IN qclv_rec_type
    ) RETURN qclv_rec_type IS
      l_qclv_rec	qclv_rec_type := p_qclv_rec;
    BEGIN
      l_qclv_rec.CREATION_DATE := SYSDATE;
      l_qclv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_qclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qclv_rec.LAST_UPDATE_DATE := l_qclv_rec.CREATION_DATE;
      l_qclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qclv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qclv_rec IN  qclv_rec_type,
      x_qclv_rec OUT NOCOPY qclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qclv_rec := p_qclv_rec;
      x_qclv_rec.OBJECT_VERSION_NUMBER := 1;
      x_qclv_rec.SFWT_FLAG := 'N';
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
    l_qclv_rec := null_out_defaults(p_qclv_rec);
    -- Set primary key value
    l_qclv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qclv_rec,                        -- IN
      l_def_qclv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qclv_rec := fill_who_columns(l_def_qclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qclv_rec, l_qcl_rec);
    migrate(l_def_qclv_rec, l_okc_qa_check_lists_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcl_rec,
      lx_qcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qcl_rec, l_def_qclv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_qa_check_lists_tl_rec,
      lx_okc_qa_check_lists_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_qa_check_lists_tl_rec, l_def_qclv_rec);
    -- Set OUT values
    x_qclv_rec := l_def_qclv_rec;
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
  -- PL/SQL TBL insert_row for:QCLV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN qclv_tbl_type,
    x_qclv_tbl                     OUT NOCOPY qclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qclv_tbl.COUNT > 0) THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qclv_rec                     => p_qclv_tbl(i),
          x_qclv_rec                     => x_qclv_tbl(i));
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKC_QA_CHECK_LISTS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_rec                      IN qcl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qcl_rec IN qcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_CHECK_LISTS_B
     WHERE ID = p_qcl_rec.id
       AND OBJECT_VERSION_NUMBER = p_qcl_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qcl_rec IN qcl_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_CHECK_LISTS_B
    WHERE ID = p_qcl_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_QA_CHECK_LISTS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_QA_CHECK_LISTS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qcl_rec);
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
      OPEN lchk_csr(p_qcl_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qcl_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qcl_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for:OKC_QA_CHECK_LISTS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_qa_check_lists_tl_rec IN okc_qa_check_lists_tl_rec_type) IS
    SELECT *
      FROM OKC_QA_CHECK_LISTS_TL
     WHERE ID = p_okc_qa_check_lists_tl_rec.id
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
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
      OPEN lock_csr(p_okc_qa_check_lists_tl_rec);
      FETCH lock_csr INTO l_lock_var;
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
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
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
  ---------------------------------------
  -- lock_row for:OKC_QA_CHECK_LISTS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN qclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qcl_rec                      qcl_rec_type;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
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
    migrate(p_qclv_rec, l_qcl_rec);
    migrate(p_qclv_rec, l_okc_qa_check_lists_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_qa_check_lists_tl_rec
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
  -- PL/SQL TBL lock_row for:QCLV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN qclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qclv_tbl.COUNT > 0) THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qclv_rec                     => p_qclv_tbl(i));
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKC_QA_CHECK_LISTS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_rec                      IN qcl_rec_type,
    x_qcl_rec                      OUT NOCOPY qcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qcl_rec                      qcl_rec_type := p_qcl_rec;
    l_def_qcl_rec                  qcl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qcl_rec	IN qcl_rec_type,
      x_qcl_rec	OUT NOCOPY qcl_rec_type
    ) RETURN VARCHAR2 IS
      l_qcl_rec                      qcl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcl_rec := p_qcl_rec;
      -- Get current database values
      l_qcl_rec := get_rec(p_qcl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qcl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.id := l_qcl_rec.id;
      END IF;
      IF (x_qcl_rec.begin_date = OKC_API.G_MISS_DATE)
      THEN
        x_qcl_rec.begin_date := l_qcl_rec.begin_date;
      END IF;
      IF (x_qcl_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.object_version_number := l_qcl_rec.object_version_number;
      END IF;
      IF (x_qcl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.created_by := l_qcl_rec.created_by;
      END IF;
      IF (x_qcl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qcl_rec.creation_date := l_qcl_rec.creation_date;
      END IF;
      IF (x_qcl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.last_updated_by := l_qcl_rec.last_updated_by;
      END IF;
      IF (x_qcl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qcl_rec.last_update_date := l_qcl_rec.last_update_date;
      END IF;
      IF (x_qcl_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_qcl_rec.end_date := l_qcl_rec.end_date;
      END IF;
      IF (x_qcl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.last_update_login := l_qcl_rec.last_update_login;
      END IF;
      IF (x_qcl_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute_category := l_qcl_rec.attribute_category;
      END IF;
      IF (x_qcl_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute1 := l_qcl_rec.attribute1;
      END IF;
      IF (x_qcl_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute2 := l_qcl_rec.attribute2;
      END IF;
      IF (x_qcl_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute3 := l_qcl_rec.attribute3;
      END IF;
      IF (x_qcl_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute4 := l_qcl_rec.attribute4;
      END IF;
      IF (x_qcl_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute5 := l_qcl_rec.attribute5;
      END IF;
      IF (x_qcl_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute6 := l_qcl_rec.attribute6;
      END IF;
      IF (x_qcl_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute7 := l_qcl_rec.attribute7;
      END IF;
      IF (x_qcl_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute8 := l_qcl_rec.attribute8;
      END IF;
      IF (x_qcl_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute9 := l_qcl_rec.attribute9;
      END IF;
      IF (x_qcl_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute10 := l_qcl_rec.attribute10;
      END IF;
      IF (x_qcl_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute11 := l_qcl_rec.attribute11;
      END IF;
      IF (x_qcl_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute12 := l_qcl_rec.attribute12;
      END IF;
      IF (x_qcl_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute13 := l_qcl_rec.attribute13;
      END IF;
      IF (x_qcl_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute14 := l_qcl_rec.attribute14;
      END IF;
      IF (x_qcl_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.attribute15 := l_qcl_rec.attribute15;
      END IF;
      IF (x_qcl_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_qcl_rec.application_id := l_qcl_rec.application_id;
      END IF;
      IF (x_qcl_rec.default_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qcl_rec.default_yn := l_qcl_rec.default_yn;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qcl_rec IN  qcl_rec_type,
      x_qcl_rec OUT NOCOPY qcl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qcl_rec := p_qcl_rec;
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
      p_qcl_rec,                         -- IN
      l_qcl_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qcl_rec, l_def_qcl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_QA_CHECK_LISTS_B
    SET BEGIN_DATE = l_def_qcl_rec.begin_date,
        OBJECT_VERSION_NUMBER = l_def_qcl_rec.object_version_number,
        CREATED_BY = l_def_qcl_rec.created_by,
        CREATION_DATE = l_def_qcl_rec.creation_date,
        LAST_UPDATED_BY = l_def_qcl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qcl_rec.last_update_date,
        END_DATE = l_def_qcl_rec.end_date,
        LAST_UPDATE_LOGIN = l_def_qcl_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_qcl_rec.attribute_category,
        ATTRIBUTE1 = l_def_qcl_rec.attribute1,
        ATTRIBUTE2 = l_def_qcl_rec.attribute2,
        ATTRIBUTE3 = l_def_qcl_rec.attribute3,
        ATTRIBUTE4 = l_def_qcl_rec.attribute4,
        ATTRIBUTE5 = l_def_qcl_rec.attribute5,
        ATTRIBUTE6 = l_def_qcl_rec.attribute6,
        ATTRIBUTE7 = l_def_qcl_rec.attribute7,
        ATTRIBUTE8 = l_def_qcl_rec.attribute8,
        ATTRIBUTE9 = l_def_qcl_rec.attribute9,
        ATTRIBUTE10 = l_def_qcl_rec.attribute10,
        ATTRIBUTE11 = l_def_qcl_rec.attribute11,
        ATTRIBUTE12 = l_def_qcl_rec.attribute12,
        ATTRIBUTE13 = l_def_qcl_rec.attribute13,
        ATTRIBUTE14 = l_def_qcl_rec.attribute14,
        ATTRIBUTE15 = l_def_qcl_rec.attribute15,
        APPLICATION_ID = l_def_qcl_rec.application_id,
        DEFAULT_YN = l_def_qcl_rec.default_yn
    WHERE ID = l_def_qcl_rec.id;

    x_qcl_rec := l_def_qcl_rec;
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
  ------------------------------------------
  -- update_row for:OKC_QA_CHECK_LISTS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type,
    x_okc_qa_check_lists_tl_rec    OUT NOCOPY okc_qa_check_lists_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type := p_okc_qa_check_lists_tl_rec;
    ldefokcqacheckliststlrec       okc_qa_check_lists_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_qa_check_lists_tl_rec	IN okc_qa_check_lists_tl_rec_type,
      x_okc_qa_check_lists_tl_rec	OUT NOCOPY okc_qa_check_lists_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_qa_check_lists_tl_rec := p_okc_qa_check_lists_tl_rec;
      -- Get current database values
      l_okc_qa_check_lists_tl_rec := get_rec(p_okc_qa_check_lists_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_qa_check_lists_tl_rec.id := l_okc_qa_check_lists_tl_rec.id;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_qa_check_lists_tl_rec.language := l_okc_qa_check_lists_tl_rec.language;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_qa_check_lists_tl_rec.source_lang := l_okc_qa_check_lists_tl_rec.source_lang;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_qa_check_lists_tl_rec.sfwt_flag := l_okc_qa_check_lists_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_qa_check_lists_tl_rec.name := l_okc_qa_check_lists_tl_rec.name;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_qa_check_lists_tl_rec.short_description := l_okc_qa_check_lists_tl_rec.short_description;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_qa_check_lists_tl_rec.created_by := l_okc_qa_check_lists_tl_rec.created_by;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_qa_check_lists_tl_rec.creation_date := l_okc_qa_check_lists_tl_rec.creation_date;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_qa_check_lists_tl_rec.last_updated_by := l_okc_qa_check_lists_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_qa_check_lists_tl_rec.last_update_date := l_okc_qa_check_lists_tl_rec.last_update_date;
      END IF;
      IF (x_okc_qa_check_lists_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_qa_check_lists_tl_rec.last_update_login := l_okc_qa_check_lists_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_qa_check_lists_tl_rec IN  okc_qa_check_lists_tl_rec_type,
      x_okc_qa_check_lists_tl_rec OUT NOCOPY okc_qa_check_lists_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_qa_check_lists_tl_rec := p_okc_qa_check_lists_tl_rec;
      x_okc_qa_check_lists_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
      x_okc_qa_check_lists_tl_rec.SOURCE_LANG := okc_util.get_userenv_lang;
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
      p_okc_qa_check_lists_tl_rec,       -- IN
      l_okc_qa_check_lists_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_qa_check_lists_tl_rec, ldefokcqacheckliststlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_QA_CHECK_LISTS_TL
    SET NAME = ldefokcqacheckliststlrec.name,
        SHORT_DESCRIPTION = ldefokcqacheckliststlrec.short_description,
        CREATED_BY = ldefokcqacheckliststlrec.created_by,
        CREATION_DATE = ldefokcqacheckliststlrec.creation_date,
        LAST_UPDATED_BY = ldefokcqacheckliststlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefokcqacheckliststlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefokcqacheckliststlrec.last_update_login
    WHERE ID = ldefokcqacheckliststlrec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_QA_CHECK_LISTS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefokcqacheckliststlrec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_qa_check_lists_tl_rec := ldefokcqacheckliststlrec;
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
  -----------------------------------------
  -- update_row for:OKC_QA_CHECK_LISTS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN qclv_rec_type,
    x_qclv_rec                     OUT NOCOPY qclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
    l_def_qclv_rec                 qclv_rec_type;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
    lx_okc_qa_check_lists_tl_rec   okc_qa_check_lists_tl_rec_type;
    l_qcl_rec                      qcl_rec_type;
    lx_qcl_rec                     qcl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qclv_rec	IN qclv_rec_type
    ) RETURN qclv_rec_type IS
      l_qclv_rec	qclv_rec_type := p_qclv_rec;
    BEGIN
      l_qclv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qclv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qclv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qclv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qclv_rec	IN qclv_rec_type,
      x_qclv_rec	OUT NOCOPY qclv_rec_type
    ) RETURN VARCHAR2 IS
      l_qclv_rec                     qclv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qclv_rec := p_qclv_rec;
      -- Get current database values
      l_qclv_rec := get_rec(p_qclv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qclv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.id := l_qclv_rec.id;
      END IF;
      IF (x_qclv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.object_version_number := l_qclv_rec.object_version_number;
      END IF;
      IF (x_qclv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.sfwt_flag := l_qclv_rec.sfwt_flag;
      END IF;
      IF (x_qclv_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.name := l_qclv_rec.name;
      END IF;
      IF (x_qclv_rec.short_description = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.short_description := l_qclv_rec.short_description;
      END IF;
      IF (x_qclv_rec.begin_date = OKC_API.G_MISS_DATE)
      THEN
        x_qclv_rec.begin_date := l_qclv_rec.begin_date;
      END IF;
      IF (x_qclv_rec.end_date = OKC_API.G_MISS_DATE)
      THEN
        x_qclv_rec.end_date := l_qclv_rec.end_date;
      END IF;
      IF (x_qclv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute_category := l_qclv_rec.attribute_category;
      END IF;
      IF (x_qclv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute1 := l_qclv_rec.attribute1;
      END IF;
      IF (x_qclv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute2 := l_qclv_rec.attribute2;
      END IF;
      IF (x_qclv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute3 := l_qclv_rec.attribute3;
      END IF;
      IF (x_qclv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute4 := l_qclv_rec.attribute4;
      END IF;
      IF (x_qclv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute5 := l_qclv_rec.attribute5;
      END IF;
      IF (x_qclv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute6 := l_qclv_rec.attribute6;
      END IF;
      IF (x_qclv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute7 := l_qclv_rec.attribute7;
      END IF;
      IF (x_qclv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute8 := l_qclv_rec.attribute8;
      END IF;
      IF (x_qclv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute9 := l_qclv_rec.attribute9;
      END IF;
      IF (x_qclv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute10 := l_qclv_rec.attribute10;
      END IF;
      IF (x_qclv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute11 := l_qclv_rec.attribute11;
      END IF;
      IF (x_qclv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute12 := l_qclv_rec.attribute12;
      END IF;
      IF (x_qclv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute13 := l_qclv_rec.attribute13;
      END IF;
      IF (x_qclv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute14 := l_qclv_rec.attribute14;
      END IF;
      IF (x_qclv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qclv_rec.attribute15 := l_qclv_rec.attribute15;
      END IF;
      IF (x_qclv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.created_by := l_qclv_rec.created_by;
      END IF;
      IF (x_qclv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qclv_rec.creation_date := l_qclv_rec.creation_date;
      END IF;
      IF (x_qclv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.last_updated_by := l_qclv_rec.last_updated_by;
      END IF;
      IF (x_qclv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qclv_rec.last_update_date := l_qclv_rec.last_update_date;
      END IF;
      IF (x_qclv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.last_update_login := l_qclv_rec.last_update_login;
      END IF;
      IF (x_qclv_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_qclv_rec.application_id := l_qclv_rec.application_id;
      END IF;
    IF (x_qclv_rec.default_yn = OKC_API.G_MISS_CHAR)
    THEN
      x_qclv_rec.default_yn := l_qclv_rec.default_yn;
    END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qclv_rec IN  qclv_rec_type,
      x_qclv_rec OUT NOCOPY qclv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qclv_rec := p_qclv_rec;
      x_qclv_rec.OBJECT_VERSION_NUMBER := NVL(x_qclv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qclv_rec,                        -- IN
      l_qclv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qclv_rec, l_def_qclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qclv_rec := fill_who_columns(l_def_qclv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qclv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qclv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qclv_rec, l_okc_qa_check_lists_tl_rec);
    migrate(l_def_qclv_rec, l_qcl_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_qa_check_lists_tl_rec,
      lx_okc_qa_check_lists_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_qa_check_lists_tl_rec, l_def_qclv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcl_rec,
      lx_qcl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qcl_rec, l_def_qclv_rec);
    x_qclv_rec := l_def_qclv_rec;
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
  -- PL/SQL TBL update_row for:QCLV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN qclv_tbl_type,
    x_qclv_tbl                     OUT NOCOPY qclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qclv_tbl.COUNT > 0) THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qclv_rec                     => p_qclv_tbl(i),
          x_qclv_rec                     => x_qclv_tbl(i));
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKC_QA_CHECK_LISTS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qcl_rec                      IN qcl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qcl_rec                      qcl_rec_type:= p_qcl_rec;
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
    DELETE FROM OKC_QA_CHECK_LISTS_B
     WHERE ID = l_qcl_rec.id;

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
  ------------------------------------------
  -- delete_row for:OKC_QA_CHECK_LISTS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_qa_check_lists_tl_rec    IN okc_qa_check_lists_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type:= p_okc_qa_check_lists_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKC_QA_CHECK_LISTS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_qa_check_lists_tl_rec IN  okc_qa_check_lists_tl_rec_type,
      x_okc_qa_check_lists_tl_rec OUT NOCOPY okc_qa_check_lists_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_qa_check_lists_tl_rec := p_okc_qa_check_lists_tl_rec;
      x_okc_qa_check_lists_tl_rec.LANGUAGE := okc_util.get_userenv_lang;
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
      p_okc_qa_check_lists_tl_rec,       -- IN
      l_okc_qa_check_lists_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_QA_CHECK_LISTS_TL
     WHERE ID = l_okc_qa_check_lists_tl_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKC_QA_CHECK_LISTS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_rec                     IN qclv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qclv_rec                     qclv_rec_type := p_qclv_rec;
    l_okc_qa_check_lists_tl_rec    okc_qa_check_lists_tl_rec_type;
    l_qcl_rec                      qcl_rec_type;
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
    migrate(l_qclv_rec, l_okc_qa_check_lists_tl_rec);
    migrate(l_qclv_rec, l_qcl_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_qa_check_lists_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qcl_rec
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
  -- PL/SQL TBL delete_row for:QCLV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qclv_tbl                     IN qclv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qclv_tbl.COUNT > 0) THEN
      i := p_qclv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qclv_rec                     => p_qclv_tbl(i));
        EXIT WHEN (i = p_qclv_tbl.LAST);
        i := p_qclv_tbl.NEXT(i);
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

END OKC_QCL_PVT;

/
