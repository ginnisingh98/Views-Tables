--------------------------------------------------------
--  DDL for Package Body OKL_IEN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IEN_PVT" AS
/* $Header: OKLSIENB.pls 120.5 2005/10/30 04:42:40 appldev noship $ */
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
  -- PROCEDURE Validate_ien_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_ienv_id(
    p_ienv_rec           IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ienv_rec.id = OKC_API.G_MISS_NUM OR
       p_ienv_rec.id IS NULL
    THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_ienv_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_object_version_number
  ---------------------------------------------------------------------------
  PROCEDURE validate_object_version_number(
    p_ienv_rec          IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_ienv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_ienv_rec.object_version_number IS NULL    THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;

    PROCEDURE validate_duplicates(
      p_ienv_rec          IN ienv_rec_type,
      x_return_status 	OUT NOCOPY VARCHAR2) IS
      l_return_status	VARCHAR2(1) := Okc_Api.G_RET_STS_SUCCESS;
      l_dummy_var VARCHAR2(1) := '?';
      l_dummy_varCA VARCHAR2(1) := '?';
  CURSOR l_ienv_csr IS
  SELECT 'x' -- Bug:3825159
  FROM OKL_INS_EXCLUSIONS_B IENB
  WHERE IENB.ID 		<> p_ienv_rec.ID
  AND   IENB.country_id 	= p_ienv_rec.country_id
  AND   IENB.coll_code 		= p_ienv_rec.coll_code
  AND   IENB.sic_code		= p_ienv_rec.sic_code
  AND  DECODE(NVL(IENB.DATE_TO,NULL),NULL,'ACTIVE',DECODE(SIGN(MONTHS_BETWEEN(IENB.DATE_TO,SYSDATE)),1,'ACTIVE', 0, 'ACTIVE', 'INACTIVE'))
     = DECODE(NVL(p_ienv_rec.DATE_TO,NULL),NULL,'ACTIVE',DECODE(SIGN(MONTHS_BETWEEN(p_ienv_rec.DATE_TO,SYSDATE)),1,'ACTIVE', 0, 'ACTIVE', 'INACTIVE'));

  CURSOR l_ienvCA_csr IS
  SELECT 'x' -- Bug:3825159
   FROM OKL_INS_EXCLUSIONS_B IENB
  WHERE IENB.ID                 <> p_ienv_rec.ID
  AND   IENB.country_id         = p_ienv_rec.country_id
  AND   IENB.coll_code          = p_ienv_rec.coll_code
  AND  DECODE(NVL(IENB.DATE_TO,NULL),NULL,'ACTIVE',DECODE(SIGN(MONTHS_BETWEEN(IENB.DATE_TO,SYSDATE)),1,'ACTIVE', 0, 'ACTIVE', 'INACTIVE'))
     = DECODE(NVL(p_ienv_rec.DATE_TO,NULL),NULL,'ACTIVE',DECODE(SIGN(MONTHS_BETWEEN(p_ienv_rec.DATE_TO,SYSDATE)),1,'ACTIVE', 0, 'ACTIVE', 'INACTIVE'));

    BEGIN

  	OPEN l_ienv_csr;
  	FETCH l_ienv_csr INTO l_dummy_var;
  	CLOSE l_ienv_csr;

        OPEN l_ienvCA_csr;
  	FETCH l_ienvCA_csr INTO l_dummy_varCA;
  	CLOSE l_ienvCA_csr;
  -- if l_dummy_var is still set to default, data was not found
     IF (l_dummy_var = 'x') THEN
        OKC_API.set_message(p_app_name 	    => 'OKL',
                               p_msg_name           => 'OKL_UNIQUE'
					);
        l_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;
     IF (l_dummy_varCA = 'x') THEN
        OKC_API.set_message(p_app_name 	    => 'OKL',
                            p_msg_name           => 'OKL_UNIQUE'
					);
        l_return_status := Okc_Api.G_RET_STS_ERROR;
     END IF;

      x_return_status := l_return_status;
    EXCEPTION
       WHEN OTHERS THEN
        -- store SQL error message on message stack for caller
        Okc_Api.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
        -- notify caller of an UNEXPECTED error
        x_return_status := Okc_Api.G_RET_STS_UNEXP_ERROR;
  END validate_duplicates;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_INS_EXCLUSIONS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_INS_EXCLUSIONS_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKL_INS_EXCLUSIONS_TL T SET (
        COMMENTS) = (SELECT
                                  B.COMMENTS
                                FROM OKL_INS_EXCLUSIONS_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKL_INS_EXCLUSIONS_TL SUBB, OKL_INS_EXCLUSIONS_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND ( SUBB.COMMENTS <> SUBT.COMMENTS
                      OR (SUBB.COMMENTS IS NULL AND SUBT.COMMENTS IS NOT NULL)
                      OR (SUBB.COMMENTS IS NOT NULL AND SUBT.COMMENTS IS NULL)
              ));

    INSERT INTO OKL_INS_EXCLUSIONS_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        COMMENTS,
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
            B.COMMENTS,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKL_INS_EXCLUSIONS_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKL_INS_EXCLUSIONS_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_EXCLUSIONS_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ien_rec                      IN ien_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ien_rec_type IS
    CURSOR ien_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            COUNTRY_ID,
            DATE_FROM,
            COLL_CODE,
            OBJECT_VERSION_NUMBER,
            SIC_CODE,
            DATE_TO,
            --COMMENTS,
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
      FROM Okl_Ins_Exclusions_B
     WHERE okl_ins_exclusions_b.id = p_id;
    l_ien_pk                       ien_pk_csr%ROWTYPE;
    l_ien_rec                      ien_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ien_pk_csr (p_ien_rec.id);
    FETCH ien_pk_csr INTO
              l_ien_rec.ID,
              l_ien_rec.COUNTRY_ID,
              l_ien_rec.DATE_FROM,
              l_ien_rec.COLL_CODE,
              l_ien_rec.OBJECT_VERSION_NUMBER,
              l_ien_rec.SIC_CODE,
              l_ien_rec.DATE_TO,
              --l_ien_rec.COMMENTS,
              l_ien_rec.ATTRIBUTE_CATEGORY,
              l_ien_rec.ATTRIBUTE1,
              l_ien_rec.ATTRIBUTE2,
              l_ien_rec.ATTRIBUTE3,
              l_ien_rec.ATTRIBUTE4,
              l_ien_rec.ATTRIBUTE5,
              l_ien_rec.ATTRIBUTE6,
              l_ien_rec.ATTRIBUTE7,
              l_ien_rec.ATTRIBUTE8,
              l_ien_rec.ATTRIBUTE9,
              l_ien_rec.ATTRIBUTE10,
              l_ien_rec.ATTRIBUTE11,
              l_ien_rec.ATTRIBUTE12,
              l_ien_rec.ATTRIBUTE13,
              l_ien_rec.ATTRIBUTE14,
              l_ien_rec.ATTRIBUTE15,
              l_ien_rec.CREATED_BY,
              l_ien_rec.CREATION_DATE,
              l_ien_rec.LAST_UPDATED_BY,
              l_ien_rec.LAST_UPDATE_DATE,
              l_ien_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ien_pk_csr%NOTFOUND;
    CLOSE ien_pk_csr;
    RETURN(l_ien_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ien_rec                      IN ien_rec_type
  ) RETURN ien_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ien_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_EXCLUSIONS_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okl_ins_exclusions_tl_rec_type IS
    CURSOR okl_ins_exclusions_tl_pk_csr (p_id                 IN NUMBER,
                                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ins_Exclusions_Tl
     WHERE okl_ins_exclusions_tl.id = p_id
       AND okl_ins_exclusions_tl.language = p_language;
    l_okl_ins_exclusions_tl_pk     okl_ins_exclusions_tl_pk_csr%ROWTYPE;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okl_ins_exclusions_tl_pk_csr (p_okl_ins_exclusions_tl_rec.id,
                                       p_okl_ins_exclusions_tl_rec.language);
    FETCH okl_ins_exclusions_tl_pk_csr INTO
              l_okl_ins_exclusions_tl_rec.ID,
              l_okl_ins_exclusions_tl_rec.LANGUAGE,
              l_okl_ins_exclusions_tl_rec.SOURCE_LANG,
              l_okl_ins_exclusions_tl_rec.SFWT_FLAG,
              l_okl_ins_exclusions_tl_rec.COMMENTS,
              l_okl_ins_exclusions_tl_rec.CREATED_BY,
              l_okl_ins_exclusions_tl_rec.CREATION_DATE,
              l_okl_ins_exclusions_tl_rec.LAST_UPDATED_BY,
              l_okl_ins_exclusions_tl_rec.LAST_UPDATE_DATE,
              l_okl_ins_exclusions_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okl_ins_exclusions_tl_pk_csr%NOTFOUND;
    CLOSE okl_ins_exclusions_tl_pk_csr;
    RETURN(l_okl_ins_exclusions_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type
  ) RETURN okl_ins_exclusions_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okl_ins_exclusions_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKL_INS_EXCLUSIONS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_ienv_rec                     IN ienv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN ienv_rec_type IS
    CURSOR ien_pk1_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            OBJECT_VERSION_NUMBER,
            SFWT_FLAG,
            COUNTRY_ID,
            COLL_CODE,
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
            DATE_FROM,
            SIC_CODE,
            DATE_TO,
            COMMENTS,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okl_Ins_Exclusions_V
     WHERE okl_ins_exclusions_v.id = p_id;
    l_ien_pk1                      ien_pk1_csr%ROWTYPE;
    l_ienv_rec                     ienv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN ien_pk1_csr (p_ienv_rec.id);
    FETCH ien_pk1_csr INTO
              l_ienv_rec.ID,
              l_ienv_rec.OBJECT_VERSION_NUMBER,
              l_ienv_rec.SFWT_FLAG,
              l_ienv_rec.COUNTRY_ID,
              l_ienv_rec.COLL_CODE,
              l_ienv_rec.ATTRIBUTE_CATEGORY,
              l_ienv_rec.ATTRIBUTE1,
              l_ienv_rec.ATTRIBUTE2,
              l_ienv_rec.ATTRIBUTE3,
              l_ienv_rec.ATTRIBUTE4,
              l_ienv_rec.ATTRIBUTE5,
              l_ienv_rec.ATTRIBUTE6,
              l_ienv_rec.ATTRIBUTE7,
              l_ienv_rec.ATTRIBUTE8,
              l_ienv_rec.ATTRIBUTE9,
              l_ienv_rec.ATTRIBUTE10,
              l_ienv_rec.ATTRIBUTE11,
              l_ienv_rec.ATTRIBUTE12,
              l_ienv_rec.ATTRIBUTE13,
              l_ienv_rec.ATTRIBUTE14,
              l_ienv_rec.ATTRIBUTE15,
              l_ienv_rec.DATE_FROM,
              l_ienv_rec.SIC_CODE,
              l_ienv_rec.DATE_TO,
              l_ienv_rec.COMMENTS,
              l_ienv_rec.CREATED_BY,
              l_ienv_rec.CREATION_DATE,
              l_ienv_rec.LAST_UPDATED_BY,
              l_ienv_rec.LAST_UPDATE_DATE,
              l_ienv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := ien_pk1_csr%NOTFOUND;
    CLOSE ien_pk1_csr;
    RETURN(l_ienv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_ienv_rec                     IN ienv_rec_type
  ) RETURN ienv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_ienv_rec, l_row_notfound));
  END get_rec;

  ----------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKL_INS_EXCLUSIONS_V --
  ----------------------------------------------------------
  FUNCTION null_out_defaults (
    p_ienv_rec	IN ienv_rec_type
  ) RETURN ienv_rec_type IS
    l_ienv_rec	ienv_rec_type := p_ienv_rec;
  BEGIN
    IF (l_ienv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_ienv_rec.object_version_number := NULL;
    END IF;
    IF (l_ienv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.sfwt_flag := NULL;
    END IF;
    IF (l_ienv_rec.country_id = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.country_id := NULL;
    END IF;
    IF (l_ienv_rec.coll_code = OKC_API.G_MISS_NUM) THEN
      l_ienv_rec.coll_code := NULL;
    END IF;
    IF (l_ienv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute_category := NULL;
    END IF;
    IF (l_ienv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute1 := NULL;
    END IF;
    IF (l_ienv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute2 := NULL;
    END IF;
    IF (l_ienv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute3 := NULL;
    END IF;
    IF (l_ienv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute4 := NULL;
    END IF;
    IF (l_ienv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute5 := NULL;
    END IF;
    IF (l_ienv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute6 := NULL;
    END IF;
    IF (l_ienv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute7 := NULL;
    END IF;
    IF (l_ienv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute8 := NULL;
    END IF;
    IF (l_ienv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute9 := NULL;
    END IF;
    IF (l_ienv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute10 := NULL;
    END IF;
    IF (l_ienv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute11 := NULL;
    END IF;
    IF (l_ienv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute12 := NULL;
    END IF;
    IF (l_ienv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute13 := NULL;
    END IF;
    IF (l_ienv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute14 := NULL;
    END IF;
    IF (l_ienv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.attribute15 := NULL;
    END IF;
    IF (l_ienv_rec.date_from = OKC_API.G_MISS_DATE) THEN
      l_ienv_rec.date_from := NULL;
    END IF;
    IF (l_ienv_rec.sic_code = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.sic_code := NULL;
    END IF;
    IF (l_ienv_rec.date_to = OKC_API.G_MISS_DATE) THEN
      l_ienv_rec.date_to := NULL;
    END IF;
    IF (l_ienv_rec.comments = OKC_API.G_MISS_CHAR) THEN
      l_ienv_rec.comments := NULL;
    END IF;
    IF (l_ienv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_ienv_rec.created_by := NULL;
    END IF;
    IF (l_ienv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_ienv_rec.creation_date := NULL;
    END IF;
    IF (l_ienv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_ienv_rec.last_updated_by := NULL;
    END IF;
    IF (l_ienv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_ienv_rec.last_update_date := NULL;
    END IF;
    IF (l_ienv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_ienv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_ienv_rec);
  END null_out_defaults;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_sfwt_flag
  ---------------------------------------------------------------------------
  PROCEDURE validate_sfwt_flag(
    p_ienv_rec          IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF UPPER(p_ienv_rec.sfwt_flag) NOT IN ('Y', 'N')  THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'sfwt_flag');
      l_return_status := Okc_Api.G_RET_STS_ERROR;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_sfwt_flag;

  --------------------------------------------------------------------------
  -- PROCEDURE Validate_country_id
  ---------------------------------------------------------------------------
  PROCEDURE validate_country_id(
    p_ienv_rec          IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_dummy_var		VARCHAR2(1) := '0' ;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS ;
   CURSOR l_cpr_csr IS
     SELECT 1
     FROM OKX_COUNTRIES_V
     WHERE ID1 = p_ienv_rec.country_id;

  BEGIN
    x_return_status	 := OKC_API.G_RET_STS_SUCCESS ;
    IF p_ienv_rec.country_id = OKC_API.G_MISS_CHAR OR
          p_ienv_rec.country_id IS NULL    THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Country');
      l_return_status := OKC_API.G_RET_STS_ERROR;
     ELSE
      	-- enforce foreign key
        OPEN   l_cpr_csr ;
        FETCH l_cpr_csr into l_dummy_var ;
        CLOSE l_cpr_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var <> '1' ) THEN
           OKC_API.set_message('OKL',
	        	g_no_parent_record,
			g_col_name_token,
			'country_id',
		 	g_child_table_token ,
			'OKL_INS_EXCLUSIONS_V',
			g_parent_table_token ,
			'OKX_COUNTRIES_V');
			x_return_status := OKC_API.G_RET_STS_ERROR;

	END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_country_id;

   --------------------------------------------------------------------------
  -- PROCEDURE Validate_coll_code
  ---------------------------------------------------------------------------
  PROCEDURE validate_coll_code(
    p_ienv_rec          IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_dummy_var		VARCHAR2(1) := '0' ;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS ;
   CURSOR l_coll_csr IS
     SELECT 1
     FROM OKX_ASST_CATGRS_V
     WHERE ID1 = p_ienv_rec.coll_code;

  BEGIN
    x_return_status	 := OKC_API.G_RET_STS_SUCCESS ;
    IF p_ienv_rec.coll_code = OKC_API.G_MISS_NUM OR
          p_ienv_rec.coll_code IS NULL    THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Asset Category');
      l_return_status := OKC_API.G_RET_STS_ERROR;
     ELSE
      	-- enforce foreign key
        OPEN   l_coll_csr ;
        FETCH l_coll_csr into l_dummy_var ;
        CLOSE l_coll_csr ;
        -- still set to default means data was not found
        IF ( l_dummy_var <> '1' ) THEN
           OKC_API.set_message('OKL',
	        	g_no_parent_record,
			g_col_name_token,
			'coll_code',
		 	g_child_table_token ,
			'OKL_INS_EXCLUSIONS_V',
			g_parent_table_token ,
			'OKX_ASST_CATGRS_V');
			x_return_status := OKC_API.G_RET_STS_ERROR;

	END IF;
    END IF;
    x_return_status := l_return_status;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_coll_code;


  --------------------------------------------------------------------------
  -- PROCEDURE Validate_date_from
  ---------------------------------------------------------------------------
  PROCEDURE validate_date_from(
    p_ienv_rec          IN ienv_rec_type,
    x_return_status 	OUT NOCOPY VARCHAR2) IS
    l_dummy_var		VARCHAR2(1) := '1' ;
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS ;
  BEGIN
     x_return_status	 := OKC_API.G_RET_STS_SUCCESS ;
        IF (p_ienv_rec.date_from = OKC_API.G_MISS_DATE OR p_ienv_rec.date_from IS NULL)THEN
          OKC_API.set_message(g_app_name, 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'Effective From');
          l_return_status := OKC_API.G_RET_STS_ERROR;
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
        END IF;

        x_return_status :=l_return_status;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
        null;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_date_from;


  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  --------------------------------------------------
  -- Validate_Attributes for:OKL_INS_EXCLUSIONS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_ienv_rec IN  ienv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    IF p_ienv_rec.id = OKC_API.G_MISS_NUM OR   p_ienv_rec.id IS NULL  THEN
      OKC_API.set_message('OKL', 'OKL_REQUIRED_VALUE',G_COL_NAME_TOKEN,'id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    validate_object_version_number(p_ienv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    validate_country_id(p_ienv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
   validate_coll_code(p_ienv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    validate_date_from(p_ienv_rec, l_return_status);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
          x_return_status := l_return_status;
          RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
          x_return_status := l_return_status;
      END IF;
    END IF;
    validate_sfwt_flag(p_ienv_rec, l_return_status);
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
      return(x_return_status);
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.set_message('OKL', G_UNEXPECTED_ERROR,G_SQLCODE_TOKEN,SQLCODE,G_SQLERRM_TOKEN,SQLERRM);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- Validate_Record for:OKL_INS_EXCLUSIONS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_ienv_rec IN ienv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
     IF (p_ienv_rec.date_to IS NOT NULL)THEN
            l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date => p_ienv_rec.date_from
                                                               ,p_to_date => p_ienv_rec.date_to );
           END IF;
               IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                     Okc_Api.set_message(
                                         p_app_name     => 'OKL',
     			                        p_msg_name     => 'OKL_GREATER_THAN', -- 3745151 Use of correct message
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

       IF (p_ienv_rec.date_to IS NOT NULL OR p_ienv_rec.date_to <> OKC_API.G_MISS_DATE  )THEN
        l_return_status:= OKL_UTIL.check_from_to_date_range(p_from_date =>trunc(SYSDATE)--Fix for bug 3924176
                                                           ,p_to_date => p_ienv_rec.date_to);
           END IF;
               IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
                     Okc_Api.set_message(
                                         p_app_name     => 'OKL',
     			                        p_msg_name     => 'OKL_INVALID_DATE_RANGE',
     			                        p_token1       => 'COL_NAME1',
     			                        p_token1_value => 'Effective To'
     			                        );
                     return (l_return_status);
               END IF;
               IF(l_return_status = Okc_Api.G_RET_STS_UNEXP_ERROR) THEN
                  return (l_return_status);
               END IF;

      validate_duplicates(p_ienv_rec,l_return_status);
          IF (l_return_status <> Okc_Api.G_RET_STS_SUCCESS) THEN
             l_return_status := Okc_Api.G_RET_STS_ERROR;
          END IF;

    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN ienv_rec_type,
    p_to	OUT NOCOPY ien_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.country_id := p_from.country_id;
    p_to.date_from := p_from.date_from;
    p_to.coll_code := p_from.coll_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sic_code := p_from.sic_code;
    p_to.date_to := p_from.date_to;
    --p_to.comments := p_from.comments;
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
    p_from	IN ien_rec_type,
    p_to	OUT NOCOPY ienv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.country_id := p_from.country_id;
    p_to.date_from := p_from.date_from;
    p_to.coll_code := p_from.coll_code;
    p_to.object_version_number := p_from.object_version_number;
    p_to.sic_code := p_from.sic_code;
    p_to.date_to := p_from.date_to;
    --p_to.comments := p_from.comments;
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
    p_from	IN ienv_rec_type,
    p_to	OUT NOCOPY okl_ins_exclusions_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okl_ins_exclusions_tl_rec_type,
    p_to	OUT NOCOPY ienv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.comments := p_from.comments;
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
  -- validate_row for:OKL_INS_EXCLUSIONS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ienv_rec                     ienv_rec_type := p_ienv_rec;
    l_ien_rec                      ien_rec_type;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_ienv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_ienv_rec);
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
  -- PL/SQL TBL validate_row for:IENV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ienv_tbl.COUNT > 0) THEN
      i := p_ienv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ienv_rec                     => p_ienv_tbl(i));
        EXIT WHEN (i = p_ienv_tbl.LAST);
        i := p_ienv_tbl.NEXT(i);
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
  -- insert_row for:OKL_INS_EXCLUSIONS_B --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ien_rec                      IN ien_rec_type,
    x_ien_rec                      OUT NOCOPY ien_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ien_rec                      ien_rec_type := p_ien_rec;
    l_def_ien_rec                  ien_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ien_rec IN  ien_rec_type,
      x_ien_rec OUT NOCOPY ien_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ien_rec := p_ien_rec;
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
      p_ien_rec,                         -- IN
      l_ien_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKL_INS_EXCLUSIONS_B(
        id,
        country_id,
        date_from,
        coll_code,
        object_version_number,
        sic_code,
        date_to,
        --comments,
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
        l_ien_rec.id,
        l_ien_rec.country_id,
        l_ien_rec.date_from,
        l_ien_rec.coll_code,
        l_ien_rec.object_version_number,
        l_ien_rec.sic_code,
        l_ien_rec.date_to,
        --l_ien_rec.comments,
        l_ien_rec.attribute_category,
        l_ien_rec.attribute1,
        l_ien_rec.attribute2,
        l_ien_rec.attribute3,
        l_ien_rec.attribute4,
        l_ien_rec.attribute5,
        l_ien_rec.attribute6,
        l_ien_rec.attribute7,
        l_ien_rec.attribute8,
        l_ien_rec.attribute9,
        l_ien_rec.attribute10,
        l_ien_rec.attribute11,
        l_ien_rec.attribute12,
        l_ien_rec.attribute13,
        l_ien_rec.attribute14,
        l_ien_rec.attribute15,
        l_ien_rec.created_by,
        l_ien_rec.creation_date,
        l_ien_rec.last_updated_by,
        l_ien_rec.last_update_date,
        l_ien_rec.last_update_login);
    -- Set OUT values
    x_ien_rec := l_ien_rec;
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
  -- insert_row for:OKL_INS_EXCLUSIONS_TL --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type,
    x_okl_ins_exclusions_tl_rec    OUT NOCOPY okl_ins_exclusions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type := p_okl_ins_exclusions_tl_rec;
    ldefoklinsexclusionstlrec      okl_ins_exclusions_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    ----------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ins_exclusions_tl_rec IN  okl_ins_exclusions_tl_rec_type,
      x_okl_ins_exclusions_tl_rec OUT NOCOPY okl_ins_exclusions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ins_exclusions_tl_rec := p_okl_ins_exclusions_tl_rec;
      x_okl_ins_exclusions_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ins_exclusions_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ins_exclusions_tl_rec,       -- IN
      l_okl_ins_exclusions_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okl_ins_exclusions_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKL_INS_EXCLUSIONS_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          comments,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okl_ins_exclusions_tl_rec.id,
          l_okl_ins_exclusions_tl_rec.language,
          l_okl_ins_exclusions_tl_rec.source_lang,
          l_okl_ins_exclusions_tl_rec.sfwt_flag,
          l_okl_ins_exclusions_tl_rec.comments,
          l_okl_ins_exclusions_tl_rec.created_by,
          l_okl_ins_exclusions_tl_rec.creation_date,
          l_okl_ins_exclusions_tl_rec.last_updated_by,
          l_okl_ins_exclusions_tl_rec.last_update_date,
          l_okl_ins_exclusions_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okl_ins_exclusions_tl_rec := l_okl_ins_exclusions_tl_rec;
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
  -- insert_row for:OKL_INS_EXCLUSIONS_V --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type,
    x_ienv_rec                     OUT NOCOPY ienv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ienv_rec                     ienv_rec_type;
    l_def_ienv_rec                 ienv_rec_type;
    l_ien_rec                      ien_rec_type;
    lx_ien_rec                     ien_rec_type;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
    lx_okl_ins_exclusions_tl_rec   okl_ins_exclusions_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ienv_rec	IN ienv_rec_type
    ) RETURN ienv_rec_type IS
      l_ienv_rec	ienv_rec_type := p_ienv_rec;
    BEGIN
      l_ienv_rec.CREATION_DATE := SYSDATE;
      l_ienv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_ienv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ienv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ienv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ienv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ienv_rec IN  ienv_rec_type,
      x_ienv_rec OUT NOCOPY ienv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ienv_rec := p_ienv_rec;
      x_ienv_rec.OBJECT_VERSION_NUMBER := 1;
      x_ienv_rec.SFWT_FLAG := 'N';
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
    l_ienv_rec := null_out_defaults(p_ienv_rec);
    -- Set primary key value
    l_ienv_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_ienv_rec,                        -- IN
      l_def_ienv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_ienv_rec := fill_who_columns(l_def_ienv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_ienv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
   l_return_status := Validate_Record(l_def_ienv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ienv_rec, l_ien_rec);
    migrate(l_def_ienv_rec, l_okl_ins_exclusions_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ien_rec,
      lx_ien_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ien_rec, l_def_ienv_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ins_exclusions_tl_rec,
      lx_okl_ins_exclusions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ins_exclusions_tl_rec, l_def_ienv_rec);
    -- Set OUT values
    x_ienv_rec := l_def_ienv_rec;
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
  -- PL/SQL TBL insert_row for:IENV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type,
    x_ienv_tbl                     OUT NOCOPY ienv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ienv_tbl.COUNT > 0) THEN
      i := p_ienv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ienv_rec                     => p_ienv_tbl(i),
          x_ienv_rec                     => x_ienv_tbl(i));
        EXIT WHEN (i = p_ienv_tbl.LAST);
        i := p_ienv_tbl.NEXT(i);
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
  -- lock_row for:OKL_INS_EXCLUSIONS_B --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ien_rec                      IN ien_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_ien_rec IN ien_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_EXCLUSIONS_B
     WHERE ID = p_ien_rec.id
       AND OBJECT_VERSION_NUMBER = p_ien_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_ien_rec IN ien_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_INS_EXCLUSIONS_B
    WHERE ID = p_ien_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_INS_EXCLUSIONS_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_INS_EXCLUSIONS_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_ien_rec);
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
      OPEN lchk_csr(p_ien_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_ien_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_ien_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message('OKL',G_RECORD_LOGICALLY_DELETED);
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
  -- lock_row for:OKL_INS_EXCLUSIONS_TL --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okl_ins_exclusions_tl_rec IN okl_ins_exclusions_tl_rec_type) IS
    SELECT *
      FROM OKL_INS_EXCLUSIONS_TL
     WHERE ID = p_okl_ins_exclusions_tl_rec.id
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
      OPEN lock_csr(p_okl_ins_exclusions_tl_rec);
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
  -- lock_row for:OKL_INS_EXCLUSIONS_V --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ien_rec                      ien_rec_type;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
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
    migrate(p_ienv_rec, l_ien_rec);
    migrate(p_ienv_rec, l_okl_ins_exclusions_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ien_rec
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
      l_okl_ins_exclusions_tl_rec
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
  -- PL/SQL TBL lock_row for:IENV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ienv_tbl.COUNT > 0) THEN
      i := p_ienv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ienv_rec                     => p_ienv_tbl(i));
        EXIT WHEN (i = p_ienv_tbl.LAST);
        i := p_ienv_tbl.NEXT(i);
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
  -- update_row for:OKL_INS_EXCLUSIONS_B --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ien_rec                      IN ien_rec_type,
    x_ien_rec                      OUT NOCOPY ien_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ien_rec                      ien_rec_type := p_ien_rec;
    l_def_ien_rec                  ien_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ien_rec	IN ien_rec_type,
      x_ien_rec	OUT NOCOPY ien_rec_type
    ) RETURN VARCHAR2 IS
      l_ien_rec                      ien_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ien_rec := p_ien_rec;
      -- Get current database values
      l_ien_rec := get_rec(p_ien_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ien_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.id := l_ien_rec.id;
      END IF;
      IF (x_ien_rec.country_id = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.country_id := l_ien_rec.country_id;
      END IF;
      IF (x_ien_rec.date_from = OKC_API.G_MISS_DATE)
      THEN
        x_ien_rec.date_from := l_ien_rec.date_from;
      END IF;
      IF (x_ien_rec.coll_code = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.coll_code := l_ien_rec.coll_code;
      END IF;
      IF (x_ien_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.object_version_number := l_ien_rec.object_version_number;
      END IF;
      IF (x_ien_rec.sic_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.sic_code := l_ien_rec.sic_code;
      END IF;
      IF (x_ien_rec.date_to = OKC_API.G_MISS_DATE)
      THEN
        x_ien_rec.date_to := l_ien_rec.date_to;
      END IF;
      /*IF (x_ien_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.comments := l_ien_rec.comments;
      END IF;*/
      IF (x_ien_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute_category := l_ien_rec.attribute_category;
      END IF;
      IF (x_ien_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute1 := l_ien_rec.attribute1;
      END IF;
      IF (x_ien_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute2 := l_ien_rec.attribute2;
      END IF;
      IF (x_ien_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute3 := l_ien_rec.attribute3;
      END IF;
      IF (x_ien_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute4 := l_ien_rec.attribute4;
      END IF;
      IF (x_ien_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute5 := l_ien_rec.attribute5;
      END IF;
      IF (x_ien_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute6 := l_ien_rec.attribute6;
      END IF;
      IF (x_ien_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute7 := l_ien_rec.attribute7;
      END IF;
      IF (x_ien_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute8 := l_ien_rec.attribute8;
      END IF;
      IF (x_ien_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute9 := l_ien_rec.attribute9;
      END IF;
      IF (x_ien_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute10 := l_ien_rec.attribute10;
      END IF;
      IF (x_ien_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute11 := l_ien_rec.attribute11;
      END IF;
      IF (x_ien_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute12 := l_ien_rec.attribute12;
      END IF;
      IF (x_ien_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute13 := l_ien_rec.attribute13;
      END IF;
      IF (x_ien_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute14 := l_ien_rec.attribute14;
      END IF;
      IF (x_ien_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ien_rec.attribute15 := l_ien_rec.attribute15;
      END IF;
      IF (x_ien_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.created_by := l_ien_rec.created_by;
      END IF;
      IF (x_ien_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ien_rec.creation_date := l_ien_rec.creation_date;
      END IF;
      IF (x_ien_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.last_updated_by := l_ien_rec.last_updated_by;
      END IF;
      IF (x_ien_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ien_rec.last_update_date := l_ien_rec.last_update_date;
      END IF;
      IF (x_ien_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ien_rec.last_update_login := l_ien_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_B --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ien_rec IN  ien_rec_type,
      x_ien_rec OUT NOCOPY ien_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ien_rec := p_ien_rec;
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
      p_ien_rec,                         -- IN
      l_ien_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ien_rec, l_def_ien_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INS_EXCLUSIONS_B
    SET COUNTRY_ID = l_def_ien_rec.country_id,
        DATE_FROM = l_def_ien_rec.date_from,
        COLL_CODE = l_def_ien_rec.coll_code,
        OBJECT_VERSION_NUMBER = l_def_ien_rec.object_version_number,
        SIC_CODE = l_def_ien_rec.sic_code,
        DATE_TO = l_def_ien_rec.date_to,
        --COMMENTS = l_def_ien_rec.comments,
        ATTRIBUTE_CATEGORY = l_def_ien_rec.attribute_category,
        ATTRIBUTE1 = l_def_ien_rec.attribute1,
        ATTRIBUTE2 = l_def_ien_rec.attribute2,
        ATTRIBUTE3 = l_def_ien_rec.attribute3,
        ATTRIBUTE4 = l_def_ien_rec.attribute4,
        ATTRIBUTE5 = l_def_ien_rec.attribute5,
        ATTRIBUTE6 = l_def_ien_rec.attribute6,
        ATTRIBUTE7 = l_def_ien_rec.attribute7,
        ATTRIBUTE8 = l_def_ien_rec.attribute8,
        ATTRIBUTE9 = l_def_ien_rec.attribute9,
        ATTRIBUTE10 = l_def_ien_rec.attribute10,
        ATTRIBUTE11 = l_def_ien_rec.attribute11,
        ATTRIBUTE12 = l_def_ien_rec.attribute12,
        ATTRIBUTE13 = l_def_ien_rec.attribute13,
        ATTRIBUTE14 = l_def_ien_rec.attribute14,
        ATTRIBUTE15 = l_def_ien_rec.attribute15,
        CREATED_BY = l_def_ien_rec.created_by,
        CREATION_DATE = l_def_ien_rec.creation_date,
        LAST_UPDATED_BY = l_def_ien_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_ien_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_ien_rec.last_update_login
    WHERE ID = l_def_ien_rec.id;
    x_ien_rec := l_def_ien_rec;
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
  -- update_row for:OKL_INS_EXCLUSIONS_TL --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type,
    x_okl_ins_exclusions_tl_rec    OUT NOCOPY okl_ins_exclusions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type := p_okl_ins_exclusions_tl_rec;
    ldefoklinsexclusionstlrec      okl_ins_exclusions_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okl_ins_exclusions_tl_rec	IN okl_ins_exclusions_tl_rec_type,
      x_okl_ins_exclusions_tl_rec	OUT NOCOPY okl_ins_exclusions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ins_exclusions_tl_rec := p_okl_ins_exclusions_tl_rec;
      -- Get current database values
      l_okl_ins_exclusions_tl_rec := get_rec(p_okl_ins_exclusions_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okl_ins_exclusions_tl_rec.id := l_okl_ins_exclusions_tl_rec.id;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_ins_exclusions_tl_rec.language := l_okl_ins_exclusions_tl_rec.language;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_ins_exclusions_tl_rec.source_lang := l_okl_ins_exclusions_tl_rec.source_lang;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_ins_exclusions_tl_rec.sfwt_flag := l_okl_ins_exclusions_tl_rec.sfwt_flag;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_okl_ins_exclusions_tl_rec.comments := l_okl_ins_exclusions_tl_rec.comments;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_ins_exclusions_tl_rec.created_by := l_okl_ins_exclusions_tl_rec.created_by;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_ins_exclusions_tl_rec.creation_date := l_okl_ins_exclusions_tl_rec.creation_date;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okl_ins_exclusions_tl_rec.last_updated_by := l_okl_ins_exclusions_tl_rec.last_updated_by;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okl_ins_exclusions_tl_rec.last_update_date := l_okl_ins_exclusions_tl_rec.last_update_date;
      END IF;
      IF (x_okl_ins_exclusions_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okl_ins_exclusions_tl_rec.last_update_login := l_okl_ins_exclusions_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ins_exclusions_tl_rec IN  okl_ins_exclusions_tl_rec_type,
      x_okl_ins_exclusions_tl_rec OUT NOCOPY okl_ins_exclusions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ins_exclusions_tl_rec := p_okl_ins_exclusions_tl_rec;
      x_okl_ins_exclusions_tl_rec.LANGUAGE := USERENV('LANG');
      x_okl_ins_exclusions_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okl_ins_exclusions_tl_rec,       -- IN
      l_okl_ins_exclusions_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okl_ins_exclusions_tl_rec, ldefoklinsexclusionstlrec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKL_INS_EXCLUSIONS_TL
    SET COMMENTS = ldefoklinsexclusionstlrec.comments,
        SOURCE_LANG = ldefoklinsexclusionstlrec.source_lang,--Added for bug 3637102
        CREATED_BY = ldefoklinsexclusionstlrec.created_by,
        CREATION_DATE = ldefoklinsexclusionstlrec.creation_date,
        LAST_UPDATED_BY = ldefoklinsexclusionstlrec.last_updated_by,
        LAST_UPDATE_DATE = ldefoklinsexclusionstlrec.last_update_date,
        LAST_UPDATE_LOGIN = ldefoklinsexclusionstlrec.last_update_login
    WHERE ID = ldefoklinsexclusionstlrec.id
      AND  USERENV('LANG') in (SOURCE_LANG,LANGUAGE);--Added LANGUAGE as fix for 3637102

    UPDATE  OKL_INS_EXCLUSIONS_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = ldefoklinsexclusionstlrec.id
      AND SOURCE_LANG <> USERENV('LANG');
    x_okl_ins_exclusions_tl_rec := ldefoklinsexclusionstlrec;
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
  -- update_row for:OKL_INS_EXCLUSIONS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type,
    x_ienv_rec                     OUT NOCOPY ienv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ienv_rec                     ienv_rec_type := p_ienv_rec;
    l_def_ienv_rec                 ienv_rec_type;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
    lx_okl_ins_exclusions_tl_rec   okl_ins_exclusions_tl_rec_type;
    l_ien_rec                      ien_rec_type;
    lx_ien_rec                     ien_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_ienv_rec	IN ienv_rec_type
    ) RETURN ienv_rec_type IS
      l_ienv_rec	ienv_rec_type := p_ienv_rec;
    BEGIN
      l_ienv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_ienv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_ienv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_ienv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_ienv_rec	IN ienv_rec_type,
      x_ienv_rec	OUT NOCOPY ienv_rec_type
    ) RETURN VARCHAR2 IS
      l_ienv_rec                     ienv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ienv_rec := p_ienv_rec;
      -- Get current database values
      l_ienv_rec := get_rec(p_ienv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_ienv_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.id := l_ienv_rec.id;
      END IF;
      IF (x_ienv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.object_version_number := l_ienv_rec.object_version_number;
      END IF;
      IF (x_ienv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.sfwt_flag := l_ienv_rec.sfwt_flag;
      END IF;
      IF (x_ienv_rec.country_id = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.country_id := l_ienv_rec.country_id;
      END IF;
      IF (x_ienv_rec.coll_code = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.coll_code := l_ienv_rec.coll_code;
      END IF;
      IF (x_ienv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute_category := l_ienv_rec.attribute_category;
      END IF;
      IF (x_ienv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute1 := l_ienv_rec.attribute1;
      END IF;
      IF (x_ienv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute2 := l_ienv_rec.attribute2;
      END IF;
      IF (x_ienv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute3 := l_ienv_rec.attribute3;
      END IF;
      IF (x_ienv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute4 := l_ienv_rec.attribute4;
      END IF;
      IF (x_ienv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute5 := l_ienv_rec.attribute5;
      END IF;
      IF (x_ienv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute6 := l_ienv_rec.attribute6;
      END IF;
      IF (x_ienv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute7 := l_ienv_rec.attribute7;
      END IF;
      IF (x_ienv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute8 := l_ienv_rec.attribute8;
      END IF;
      IF (x_ienv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute9 := l_ienv_rec.attribute9;
      END IF;
      IF (x_ienv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute10 := l_ienv_rec.attribute10;
      END IF;
      IF (x_ienv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute11 := l_ienv_rec.attribute11;
      END IF;
      IF (x_ienv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute12 := l_ienv_rec.attribute12;
      END IF;
      IF (x_ienv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute13 := l_ienv_rec.attribute13;
      END IF;
      IF (x_ienv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute14 := l_ienv_rec.attribute14;
      END IF;
      IF (x_ienv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.attribute15 := l_ienv_rec.attribute15;
      END IF;
      IF (x_ienv_rec.date_from = OKC_API.G_MISS_DATE)
      THEN
        x_ienv_rec.date_from := l_ienv_rec.date_from;
      END IF;
      IF (x_ienv_rec.sic_code = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.sic_code := l_ienv_rec.sic_code;
      END IF;
      IF (x_ienv_rec.date_to = OKC_API.G_MISS_DATE)
      THEN
        x_ienv_rec.date_to := l_ienv_rec.date_to;
      END IF;
      IF (x_ienv_rec.comments = OKC_API.G_MISS_CHAR)
      THEN
        x_ienv_rec.comments := l_ienv_rec.comments;
      END IF;
      IF (x_ienv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.created_by := l_ienv_rec.created_by;
      END IF;
      IF (x_ienv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_ienv_rec.creation_date := l_ienv_rec.creation_date;
      END IF;
      IF (x_ienv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.last_updated_by := l_ienv_rec.last_updated_by;
      END IF;
      IF (x_ienv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_ienv_rec.last_update_date := l_ienv_rec.last_update_date;
      END IF;
      IF (x_ienv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_ienv_rec.last_update_login := l_ienv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_ienv_rec IN  ienv_rec_type,
      x_ienv_rec OUT NOCOPY ienv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_ienv_rec := p_ienv_rec;
      x_ienv_rec.OBJECT_VERSION_NUMBER := NVL(x_ienv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_ienv_rec,                        -- IN
      l_ienv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_ienv_rec, l_def_ienv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_def_ienv_rec := fill_who_columns(l_def_ienv_rec);
    --- Validate all non-missing attributes (Item Level Validation)

    l_return_status := Validate_Attributes(l_def_ienv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_ienv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_ienv_rec, l_okl_ins_exclusions_tl_rec);
    migrate(l_def_ienv_rec, l_ien_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ins_exclusions_tl_rec,
      lx_okl_ins_exclusions_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okl_ins_exclusions_tl_rec, l_def_ienv_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_ien_rec,
      lx_ien_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_ien_rec, l_def_ienv_rec);
    x_ienv_rec := l_def_ienv_rec;
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
  -- PL/SQL TBL update_row for:IENV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type,
    x_ienv_tbl                     OUT NOCOPY ienv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ienv_tbl.COUNT > 0) THEN
      i := p_ienv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ienv_rec                     => p_ienv_tbl(i),
          x_ienv_rec                     => x_ienv_tbl(i));
        EXIT WHEN (i = p_ienv_tbl.LAST);
        i := p_ienv_tbl.NEXT(i);
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
  -- delete_row for:OKL_INS_EXCLUSIONS_B --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ien_rec                      IN ien_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ien_rec                      ien_rec_type:= p_ien_rec;
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
    DELETE FROM OKL_INS_EXCLUSIONS_B
     WHERE ID = l_ien_rec.id;

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
  -- delete_row for:OKL_INS_EXCLUSIONS_TL --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okl_ins_exclusions_tl_rec    IN okl_ins_exclusions_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type:= p_okl_ins_exclusions_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------------------
    -- Set_Attributes for:OKL_INS_EXCLUSIONS_TL --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_okl_ins_exclusions_tl_rec IN  okl_ins_exclusions_tl_rec_type,
      x_okl_ins_exclusions_tl_rec OUT NOCOPY okl_ins_exclusions_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okl_ins_exclusions_tl_rec := p_okl_ins_exclusions_tl_rec;
      x_okl_ins_exclusions_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okl_ins_exclusions_tl_rec,       -- IN
      l_okl_ins_exclusions_tl_rec);      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKL_INS_EXCLUSIONS_TL
     WHERE ID = l_okl_ins_exclusions_tl_rec.id;

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
  -- delete_row for:OKL_INS_EXCLUSIONS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_rec                     IN ienv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_ienv_rec                     ienv_rec_type := p_ienv_rec;
    l_okl_ins_exclusions_tl_rec    okl_ins_exclusions_tl_rec_type;
    l_ien_rec                      ien_rec_type;
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
    migrate(l_ienv_rec, l_okl_ins_exclusions_tl_rec);
    migrate(l_ienv_rec, l_ien_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okl_ins_exclusions_tl_rec
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
      l_ien_rec
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
  -- PL/SQL TBL delete_row for:IENV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_ienv_tbl                     IN ienv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_ienv_tbl.COUNT > 0) THEN
      i := p_ienv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_ienv_rec                     => p_ienv_tbl(i));
        EXIT WHEN (i = p_ienv_tbl.LAST);
        i := p_ienv_tbl.NEXT(i);
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
END OKL_IEN_PVT;

/
