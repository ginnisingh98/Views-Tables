--------------------------------------------------------
--  DDL for Package Body OKL_RCS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RCS_PVT" AS
  /* $Header: OKLSRCSB.pls 120.6 2006/07/13 13:02:05 adagur noship $ */

-- The lock_row and the validate_row procedures are not available.

G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200):='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200) :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_VALIDATION exception;
PROCEDURE api_copy IS
BEGIN
  null;
END api_copy;

PROCEDURE change_version IS
BEGIN
  null;
END change_version;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------

  PROCEDURE add_language IS

  BEGIN

    DELETE FROM OKL_FE_RESI_CAT_ALL_TL t
    WHERE       NOT EXISTS(SELECT NULL
                           FROM   OKL_FE_RESI_CAT_ALL_B b
                           WHERE  b.RESI_CATEGORY_SET_ID = t.RESI_CATEGORY_SET_ID);

    UPDATE OKL_FE_RESI_CAT_ALL_TL t
    SET(RESI_CAT_DESC) = (SELECT
                                    -- LANGUAGE,

                                    -- B.LANGUAGE,

                                     b.RESI_CAT_DESC
                              FROM   OKL_FE_RESI_CAT_ALL_TL b
                              WHERE  b.RESI_CATEGORY_SET_ID = t.RESI_CATEGORY_SET_ID
                                 AND b.language = t.source_lang)
    WHERE  (t.RESI_CATEGORY_SET_ID, t.language) IN(SELECT subt.RESI_CATEGORY_SET_ID ,subt.language
           FROM   OKL_FE_RESI_CAT_ALL_TL subb ,OKL_FE_RESI_CAT_ALL_TL subt
           WHERE  subb.RESI_CATEGORY_SET_ID = subt.RESI_CATEGORY_SET_ID AND subb.language = subt.language AND (  -- SUBB.LANGUAGE <> SUBT.LANGUAGE OR
             subb.RESI_CAT_DESC <> subt.RESI_CAT_DESC OR (subb.language IS NOT NULL
       AND subt.language IS NULL)
            OR (subb.RESI_CAT_DESC IS NULL AND subt.RESI_CAT_DESC IS NOT NULL)));

    INSERT INTO OKL_FE_RESI_CAT_ALL_TL
               (RESI_CATEGORY_SET_ID
               ,language
               ,source_lang
               ,sfwt_flag
               ,RESI_CAT_DESC)
                SELECT b.RESI_CATEGORY_SET_ID
                      ,l.language_code
                      ,b.source_lang
                      ,b.sfwt_flag
                      ,b.RESI_CAT_DESC
                FROM   OKL_FE_RESI_CAT_ALL_TL b
                      ,fnd_languages l
                WHERE  l.installed_flag IN('I', 'B')
                   AND b.language = userenv('LANG')
                   AND NOT EXISTS(SELECT NULL
                                      FROM   OKL_FE_RESI_CAT_ALL_TL t
                                      WHERE  t.RESI_CATEGORY_SET_ID = b.RESI_CATEGORY_SET_ID AND t.language = l.language_code);

  END add_language;

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_FE_RESI_CAT_ALL_B
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_rcsb_rec	IN okl_rcsb_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_rcsb_rec IS
   CURSOR rcsb_pk_csr(p_id IN NUMBER) IS
   SELECT
	RESI_CATEGORY_SET_ID,
	RESI_CAT_NAME,
	ORIG_RESI_CAT_SET_ID,
	OBJECT_VERSION_NUMBER,
	ORG_ID,
	SOURCE_CODE,
	STS_CODE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
   FROM OKL_FE_RESI_CAT_ALL_B WHERE OKL_FE_RESI_CAT_ALL_B.resi_category_set_id=p_id;
  l_rcsb_pk	rcsb_pk_csr%ROWTYPE;
  l_rcsb_rec	okl_rcsb_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN rcsb_pk_csr(p_rcsb_rec.resi_category_set_id);
  FETCH rcsb_pk_csr INTO
	l_rcsb_rec.RESI_CATEGORY_SET_ID,
	l_rcsb_rec.RESI_CAT_NAME,
	l_rcsb_rec.ORIG_RESI_CAT_SET_ID,
        l_rcsb_rec.OBJECT_VERSION_NUMBER,
	l_rcsb_rec.ORG_ID,
	l_rcsb_rec.SOURCE_CODE,
	l_rcsb_rec.STS_CODE,
	l_rcsb_rec.CREATED_BY,
	l_rcsb_rec.CREATION_DATE,
	l_rcsb_rec.LAST_UPDATED_BY,
	l_rcsb_rec.LAST_UPDATE_DATE,
	l_rcsb_rec.LAST_UPDATE_LOGIN;
	  x_no_data_found := rcsb_pk_csr%NOTFOUND;
  CLOSE rcsb_pk_csr;
  RETURN (l_rcsb_rec);
 END get_rec;

 FUNCTION get_rec(
  p_rcsb_rec	IN okl_rcsb_rec
 )RETURN okl_rcsb_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_rcsb_rec,l_row_notfound));
 END get_rec;

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_FE_RESI_CAT_ALL_TL
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_rcstl_rec	IN okl_rcstl_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_rcstl_rec IS
   CURSOR rcstl_pk_csr(p_id IN NUMBER,p_language IN VARCHAR2) IS
   SELECT
	RESI_CATEGORY_SET_ID,
	LANGUAGE,
	SOURCE_LANG,
	SFWT_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	RESI_CAT_DESC
   FROM OKL_FE_RESI_CAT_ALL_TL WHERE OKL_FE_RESI_CAT_ALL_TL.resi_category_set_id=p_id AND OKL_FE_RESI_CAT_ALL_TL.language=p_language;
  l_rcstl_pk	rcstl_pk_csr%ROWTYPE;
  l_rcstl_rec	okl_rcstl_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN rcstl_pk_csr(p_rcstl_rec.resi_category_set_id,p_rcstl_rec.language);
  FETCH rcstl_pk_csr INTO
	l_rcstl_rec.RESI_CATEGORY_SET_ID,
	l_rcstl_rec.LANGUAGE,
	l_rcstl_rec.SOURCE_LANG,
	l_rcstl_rec.SFWT_FLAG,
	l_rcstl_rec.CREATED_BY,
	l_rcstl_rec.CREATION_DATE,
	l_rcstl_rec.LAST_UPDATED_BY,
	l_rcstl_rec.LAST_UPDATE_DATE,
	l_rcstl_rec.LAST_UPDATE_LOGIN,
	l_rcstl_rec.RESI_CAT_DESC;
	  x_no_data_found := rcstl_pk_csr%NOTFOUND;
  CLOSE rcstl_pk_csr;
  RETURN (l_rcstl_rec);
 END get_rec;

 FUNCTION get_rec(
  p_rcstl_rec	IN okl_rcstl_rec
 )RETURN okl_rcstl_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_rcstl_rec,l_row_notfound));
 END get_rec;

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_FE_RESI_CAT_V
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_rcsv_rec	IN okl_rcsv_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_rcsv_rec IS
   CURSOR rcsv_pk_csr(p_id IN NUMBER) IS
   SELECT
	RESI_CATEGORY_SET_ID,
	ORIG_RESI_CAT_SET_ID,
        OBJECT_VERSION_NUMBER,
	ORG_ID,
	SOURCE_CODE,
	STS_CODE,
	RESI_CAT_NAME,
	RESI_CAT_DESC,
	SFWT_FLAG,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
   FROM OKL_FE_RESI_CAT_V WHERE OKL_FE_RESI_CAT_V.resi_category_set_id=p_id;
  l_rcsv_pk	rcsv_pk_csr%ROWTYPE;
  l_rcsv_rec	okl_rcsv_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN rcsv_pk_csr(p_rcsv_rec.resi_category_set_id);
  FETCH rcsv_pk_csr INTO
	l_rcsv_rec.RESI_CATEGORY_SET_ID,
	l_rcsv_rec.ORIG_RESI_CAT_SET_ID,
	l_rcsv_rec.OBJECT_VERSION_NUMBER,
	l_rcsv_rec.ORG_ID,
	l_rcsv_rec.SOURCE_CODE,
	l_rcsv_rec.STS_CODE,
	l_rcsv_rec.RESI_CAT_NAME,
	l_rcsv_rec.RESI_CAT_DESC,
	l_rcsv_rec.SFWT_FLAG,
	l_rcsv_rec.CREATED_BY,
	l_rcsv_rec.CREATION_DATE,
	l_rcsv_rec.LAST_UPDATED_BY,
	l_rcsv_rec.LAST_UPDATE_DATE,
	l_rcsv_rec.LAST_UPDATE_LOGIN;
	  x_no_data_found := rcsv_pk_csr%NOTFOUND;
  CLOSE rcsv_pk_csr;

  RETURN (l_rcsv_rec);
 END get_rec;
 FUNCTION get_rec(
  p_rcsv_rec	IN okl_rcsv_rec
 )RETURN okl_rcsv_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_rcsv_rec,l_row_notfound));
 END get_rec;

--------------------------------------------------------------------------------
-- Procedure migrate
--------------------------------------------------------------------------------

 PROCEDURE migrate(
 p_from IN okl_rcsv_rec,
 p_to IN OUT NOCOPY okl_rcsb_rec
 )IS
 BEGIN
	p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.RESI_CAT_NAME := p_from.RESI_CAT_NAME;
	p_to.ORIG_RESI_CAT_SET_ID := p_from.ORIG_RESI_CAT_SET_ID;
	p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
	p_to.ORG_ID := p_from.ORG_ID;
	p_to.SOURCE_CODE := p_from.SOURCE_CODE;
	p_to.STS_CODE := p_from.STS_CODE;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
  END migrate;

 PROCEDURE migrate(
 p_from IN okl_rcsb_rec,
 p_to IN OUT NOCOPY okl_rcsv_rec
 )IS
 BEGIN
	p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.RESI_CAT_NAME := p_from.RESI_CAT_NAME;
	p_to.ORIG_RESI_CAT_SET_ID := p_from.ORIG_RESI_CAT_SET_ID;
	p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
	p_to.ORG_ID := p_from.ORG_ID;
	p_to.SOURCE_CODE := p_from.SOURCE_CODE;
	p_to.STS_CODE := p_from.STS_CODE;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
  END migrate;

 PROCEDURE migrate(
 p_from IN okl_rcsv_rec,
 p_to IN OUT NOCOPY okl_rcstl_rec
 )IS
 BEGIN
    p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.SFWT_FLAG := p_from.SFWT_FLAG;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
	p_to.RESI_CAT_DESC := p_from.RESI_CAT_DESC;
  END migrate;

 PROCEDURE migrate(
 p_from IN okl_rcstl_rec,
 p_to IN OUT NOCOPY okl_rcsv_rec
 )IS
 BEGIN
	p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.SFWT_FLAG := p_from.SFWT_FLAG;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
	p_to.RESI_CAT_DESC := p_from.RESI_CAT_DESC;
  END migrate;
 FUNCTION null_out_defaults(
 p_rcsv_rec IN okl_rcsv_rec
 ) RETURN okl_rcsv_rec IS
 l_rcsv_rec	okl_rcsv_rec:= p_rcsv_rec;
 BEGIN
	IF (l_rcsv_rec.RESI_CATEGORY_SET_ID=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.RESI_CATEGORY_SET_ID:=NULL;
	END IF;
	IF (l_rcsv_rec.ORIG_RESI_CAT_SET_ID=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.ORIG_RESI_CAT_SET_ID:=NULL;
	END IF;
	IF (l_rcsv_rec.OBJECT_VERSION_NUMBER=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.OBJECT_VERSION_NUMBER:=NULL;
	END IF;
	IF (l_rcsv_rec.ORG_ID=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.ORG_ID:=NULL;
	END IF;
	IF (l_rcsv_rec.SOURCE_CODE=OKL_API.G_MISS_CHAR) THEN
	 l_rcsv_rec.SOURCE_CODE:=NULL;
	END IF;
	IF (l_rcsv_rec.STS_CODE=OKL_API.G_MISS_CHAR) THEN
	 l_rcsv_rec.STS_CODE:=NULL;
	END IF;
	IF (l_rcsv_rec.RESI_CAT_NAME=OKL_API.G_MISS_CHAR) THEN
	 l_rcsv_rec.RESI_CAT_NAME:=NULL;
	END IF;
	IF (l_rcsv_rec.RESI_CAT_DESC=OKL_API.G_MISS_CHAR) THEN
	 l_rcsv_rec.RESI_CAT_DESC:=NULL;
	END IF;
	IF (l_rcsv_rec.SFWT_FLAG=OKL_API.G_MISS_CHAR) THEN
	 l_rcsv_rec.SFWT_FLAG:=NULL;
	END IF;
	IF (l_rcsv_rec.CREATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.CREATED_BY:=NULL;
	END IF;
	IF (l_rcsv_rec.CREATION_DATE=OKL_API.G_MISS_DATE) THEN
	 l_rcsv_rec.CREATION_DATE:=NULL;
	END IF;
	IF (l_rcsv_rec.LAST_UPDATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.LAST_UPDATED_BY:=NULL;
	END IF;
	IF (l_rcsv_rec.LAST_UPDATE_DATE=OKL_API.G_MISS_DATE) THEN
	 l_rcsv_rec.LAST_UPDATE_DATE:=NULL;
	END IF;
	IF (l_rcsv_rec.LAST_UPDATE_LOGIN=OKL_API.G_MISS_NUM) THEN
	 l_rcsv_rec.LAST_UPDATE_LOGIN:=NULL;
	END IF;
  RETURN(l_rcsv_rec);
 END null_out_defaults;

 FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
	RETURN(okc_p_util.raw_to_number(sys_guid()));
	END get_seq_id;

 -- Function checks if there is any residual category set previously defined under the same name.
 FUNCTION check_existence (
 p_rcsb_rec IN okl_rcsb_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := G_RET_STS_SUCCESS;

  l_temp_resi_category_set_id     NUMBER := NULL;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_existence-Name';

  -- Cursor retrieves the rows for a particular name
  CURSOR l_rcsb_csr IS
        SELECT
            RESI_CATEGORY_SET_ID
         FROM
             -- viselvar Bug 4860445 modified start
             OKL_FE_RESI_CAT_V RCS_B
             -- viselvar Bug 4860445 modifield end
         WHERE
	      RCS_B.RESI_CAT_NAME = p_rcsb_rec.resi_cat_name;


    BEGIN
      /* Check if a record is present for the same name */
      OPEN l_rcsb_csr;
       FETCH l_rcsb_csr INTO l_temp_resi_category_set_id;
       IF l_rcsb_csr%FOUND THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_RES_CAT_NAME_EXISTS');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
      CLOSE l_rcsb_csr;

  	  RETURN (l_return_status);
 EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      RETURN G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);
      RETURN G_RET_STS_UNEXP_ERROR;
   END check_existence;

FUNCTION validate_resi_category_set_id( p_resi_category_set_id   IN  NUMBER) RETURN VARCHAR2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_resi_category_set_id';
BEGIN
   IF p_resi_category_set_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'resi_category_set_id');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;
END validate_resi_category_set_id;

  -------------------------------------------
  -- Function validate_object_version_number
  -------------------------------------------
  FUNCTION validate_object_version_number (p_object_version_number IN NUMBER) Return Varchar2 IS
    l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_object_version_number';
  BEGIN
    IF (p_object_version_number IS NULL) OR (p_object_version_number = OKL_API.G_MISS_NUM) THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'object_version_number');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;
END validate_object_version_number;

  -------------------------------------------
  -- Function validate_org_id
  -------------------------------------------

FUNCTION validate_org_id( p_org_id IN  NUMBER)RETURN VARCHAR2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_org_id';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
    -- check org id validity using the generic function okl_util.check_org_id()
    l_return_status := OKL_UTIL.check_org_id (p_org_id);

     IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'ORG_ID');
       RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;

END validate_org_id;

  -------------------------------------------
  -- Function validate_source_code
  -------------------------------------------

FUNCTION validate_source_code(p_source_code  IN  VARCHAR2)RETURN VARCHAR2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_source_code';
    l_return_status                VARCHAR2(1)  := OKL_API.G_RET_STS_SUCCESS;
BEGIN

    -- Column is mandatory
    IF (p_source_code is null ) THEN
        OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                            p_msg_name      => g_required_value,
                            p_token1        => g_col_name_token,
                            p_token1_value  => 'source_code');
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lookup Code Validation
    l_return_status := OKL_UTIL.check_lookup_code(
                             p_lookup_type  =>  'OKL_SOURCE_TYPES',
                             p_lookup_code  =>  p_source_code);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'source_code');

        -- notify caller of an error
        RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
    Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;

END validate_source_code;

  -------------------------------------------
  -- Function validate_sts_Code
  -------------------------------------------

FUNCTION validate_sts_code(p_sts_code  IN  VARCHAR2) RETURN VARCHAR2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_sts_code';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
    -- Column is mandatory
    IF (p_sts_code is null) THEN
        OKL_API.SET_MESSAGE(p_app_name      => g_app_name,
                            p_msg_name      => g_required_value,
                            p_token1        => g_col_name_token,
                            p_token1_value  => 'sts_code');
       -- notify caller of an error
        RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- Lookup Code Validation
    l_return_status := OKL_UTIL.check_lookup_code(
                             p_lookup_type  =>  'OKL_PRC_STATUS',
                             p_lookup_code  =>  p_sts_code);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
        OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_invalid_value,
                            p_token1       => g_col_name_token,
                            p_token1_value => 'sts_code');
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
        -- notify caller of an error
        raise OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;
   Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;
END validate_sts_code;

  -------------------------------------------
  -- Function validate_resi_cat_name
  -------------------------------------------

Function validate_resi_cat_name( p_resi_cat_name IN  VARCHAR2)RETURN VARCHAR2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_resi_cat_name';
BEGIN
    -- RESI_CAT_NAME is a required field
    IF (p_resi_cat_name is null ) THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'resi_cat_name');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    Return G_RET_STS_SUCCESS;
  EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      Return G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      Return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);
      Return G_RET_STS_UNEXP_ERROR;
END validate_resi_cat_name;

  -------------------------------------------
  -- Function validate_Attributes
  -------------------------------------------
 FUNCTION Validate_Attributes (
 p_rcsv_rec IN okl_rcsv_rec
 ) RETURN VARCHAR2 IS
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_attributes';
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN

    -- ***
    -- resi_category_set_id
    -- ***
    l_return_status := validate_resi_category_set_id(p_rcsv_rec.resi_category_set_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;


    -- ***
    -- object_version_number
    -- ***
    l_return_status := validate_object_version_number(p_rcsv_rec.object_version_number);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- org_id
    -- ***
    l_return_status := validate_org_id(p_rcsv_rec.org_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- source_code
    -- ***
    l_return_status := validate_source_code(p_rcsv_rec.source_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- sts_code
    -- ***
    l_return_status := validate_sts_code(p_rcsv_rec.sts_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- resi_cat_name
    -- ***
    l_return_status := validate_resi_cat_name(p_rcsv_rec.resi_cat_name);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    RETURN (x_return_status);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      return  G_RET_STS_ERROR;
    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      return G_RET_STS_UNEXP_ERROR;
    WHEN OTHERS THEN
      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => 'SQLCODE',
                           p_token2_value => sqlcode,
                           p_token3       => 'SQLERRM',
                           p_token3_value => sqlerrm);

      return G_RET_STS_UNEXP_ERROR;

   END Validate_Attributes;


 FUNCTION Validate_Record (
 p_rcsv_rec IN okl_rcsv_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
	RETURN (x_return_status);
   END Validate_Record;

--------------------------------------------------------------------------------
-- Procedure insert_row_b
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsb_rec			 IN okl_rcsb_rec,
	 x_rcsb_rec			 OUT NOCOPY okl_rcsb_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcsb_rec			okl_rcsb_rec := p_rcsb_rec;

 FUNCTION Set_Attributes(
	p_rcsb_rec IN okl_rcsb_rec,
	x_rcsb_rec OUT NOCOPY okl_rcsb_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcsb_rec := p_rcsb_rec;
 RETURN (l_return_status);
 END Set_Attributes;
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

	--Setting Item Attributes
	l_return_status:=Set_Attributes(p_rcsb_rec,
		l_rcsb_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	--Checking the existence of the residual category set under the same name
	l_return_status:= check_existence(p_rcsb_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;


	INSERT INTO OKL_FE_RESI_CAT_ALL_B(
	   RESI_CATEGORY_SET_ID,
	   RESI_CAT_NAME,
	   ORIG_RESI_CAT_SET_ID,
	   OBJECT_VERSION_NUMBER,
	   ORG_ID,
	   SOURCE_CODE,
	   STS_CODE,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN)
	VALUES (
	   l_rcsb_rec.RESI_CATEGORY_SET_ID,
	   l_rcsb_rec.RESI_CAT_NAME,
	   l_rcsb_rec.ORIG_RESI_CAT_SET_ID,
	   l_rcsb_rec.OBJECT_VERSION_NUMBER,
	   l_rcsb_rec.ORG_ID,
	   l_rcsb_rec.SOURCE_CODE,
	   l_rcsb_rec.STS_CODE,
	   l_rcsb_rec.CREATED_BY,
	   l_rcsb_rec.CREATION_DATE,
	   l_rcsb_rec.LAST_UPDATED_BY,
	   l_rcsb_rec.LAST_UPDATE_DATE,
	   l_rcsb_rec.LAST_UPDATE_LOGIN);

	--Set OUT Values
	x_rcsb_rec:=l_rcsb_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure insert_row_tl
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcstl_rec			 IN okl_rcstl_rec,
	 x_rcstl_rec			 OUT NOCOPY okl_rcstl_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcstl_rec			okl_rcstl_rec := p_rcstl_rec;
   CURSOR get_languages IS
     SELECT * from fnd_languages
      where INSTALLED_FLAG IN ('I','B');

 FUNCTION Set_Attributes(
	p_rcstl_rec IN okl_rcstl_rec,
	x_rcstl_rec OUT NOCOPY okl_rcstl_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcstl_rec := p_rcstl_rec;
		x_rcstl_rec.LANGUAGE := USERENV('LANG');
		x_rcstl_rec.SOURCE_LANG := USERENV('LANG');
 RETURN (l_return_status);
 END Set_Attributes;
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

	--Setting Item Attributes
	l_return_status:=Set_Attributes(p_rcstl_rec,
		l_rcstl_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;


	FOR l_lang_rec IN get_languages LOOP
	  l_rcstl_rec.language := l_lang_rec.language_code;


	INSERT INTO OKL_FE_RESI_CAT_ALL_TL(
	   RESI_CATEGORY_SET_ID,
	   LANGUAGE,
	   SOURCE_LANG,
	   SFWT_FLAG,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN,
	   RESI_CAT_DESC)
	VALUES (
	   l_rcstl_rec.RESI_CATEGORY_SET_ID,
	   l_rcstl_rec.LANGUAGE,
	   l_rcstl_rec.SOURCE_LANG,
	   l_rcstl_rec.SFWT_FLAG,
	   l_rcstl_rec.CREATED_BY,
	   l_rcstl_rec.CREATION_DATE,
	   l_rcstl_rec.LAST_UPDATED_BY,
	   l_rcstl_rec.LAST_UPDATE_DATE,
	   l_rcstl_rec.LAST_UPDATE_LOGIN,
	   l_rcstl_rec.RESI_CAT_DESC);

	END LOOP;
	--Set OUT Values
	x_rcstl_rec:=l_rcstl_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure insert_row_v
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec,
	 x_rcsv_rec			 OUT NOCOPY okl_rcsv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_rcsv_rec			okl_rcsv_rec;
l_def_rcsv_rec			okl_rcsv_rec;
l_rcsb_rec			okl_rcsb_rec;
lx_rcsb_rec			okl_rcsb_rec;
l_rcstl_rec			okl_rcstl_rec;
lx_rcstl_rec			okl_rcstl_rec;

 FUNCTION fill_who_columns(
 p_rcsv_rec	IN okl_rcsv_rec
 )RETURN okl_rcsv_rec IS
l_rcsv_rec okl_rcsv_rec:=p_rcsv_rec;
 BEGIN
   l_rcsv_rec.CREATION_DATE := SYSDATE;
  l_rcsv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
  l_rcsv_rec.LAST_UPDATE_DATE := SYSDATE;
  l_rcsv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_rcsv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_rcsv_rec);
 END fill_who_columns;

 FUNCTION Set_Attributes(
	p_rcsv_rec IN okl_rcsv_rec,
	x_rcsv_rec OUT NOCOPY okl_rcsv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
	x_rcsv_rec := p_rcsv_rec;
        x_rcsv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
 RETURN (l_return_status);
 END Set_Attributes;
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

	l_rcsv_rec:=null_out_defaults(p_rcsv_rec);
	-- Set Primary key value
	l_rcsv_rec.resi_category_set_id := get_seq_id;
	-- Set the original id incase of duplication
    l_rcsv_rec.orig_resi_cat_set_id := p_rcsv_rec.resi_category_set_id;

	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_rcsv_rec,l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	l_def_rcsv_rec := fill_who_columns(l_def_rcsv_rec);

	l_return_status := Validate_Attributes(l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	l_return_status := Validate_Record(l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	migrate(l_def_rcsv_rec,l_rcsb_rec);
	migrate(l_def_rcsv_rec,l_rcstl_rec);
	insert_row(
	 p_api_version,
	 p_init_msg_list,
	 x_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcsb_rec,
	 lx_rcsb_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	migrate(lx_rcsb_rec,l_def_rcsv_rec);
	insert_row(
	 p_api_version,
	 p_init_msg_list,
	 x_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcstl_rec,
	 lx_rcstl_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	migrate(lx_rcstl_rec,l_def_rcsv_rec);

	--Set OUT Values
	x_rcsv_rec:= l_def_rcsv_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);
	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION THEN
	-- No action necessary. Validation can continue to next attribute/column
       NULL;
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
--------------------------------------------------------------------------------
-- Procedure insert_row_tbl
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl,
	 x_rcsv_tbl			 OUT NOCOPY okl_rcsv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_rcsv_tbl.COUNT > 0) THEN
	  i := p_rcsv_tbl.FIRST;
	 LOOP
	   insert_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_rcsv_rec			=> p_rcsv_tbl(i),
		x_rcsv_rec			=> x_rcsv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_rcsv_tbl.LAST);
	i := p_rcsv_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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


 ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------
  ---------------------------------------
  -- lock_row_b --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcsb_rec                      IN okl_rcsb_rec) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rcsb_rec IN okl_rcsb_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_RESI_CAT_ALL_B
     WHERE RESI_CATEGORY_SET_ID = p_rcsb_rec.RESI_CATEGORY_SET_ID
       AND OBJECT_VERSION_NUMBER = p_rcsb_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_rcsb_rec IN okl_rcsb_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_RESI_CAT_ALL_B
    WHERE RESI_CATEGORY_SET_ID = p_rcsb_rec.RESI_CATEGORY_SET_ID;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_object_version_number       OKL_FE_RESI_CAT_ALL_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKL_FE_RESI_CAT_ALL_B.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_rcsb_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_rcsb_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rcsb_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rcsb_rec.object_version_number THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      Okl_Api.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
      WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row_tl --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcstl_rec    IN okl_rcstl_rec) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rcstl_rec IN okl_rcstl_rec) IS
    SELECT *
      FROM OKL_FE_RESI_CAT_ALL_TL
     WHERE RESI_CATEGORY_SET_ID = p_rcstl_rec.RESI_CATEGORY_SET_ID
    FOR UPDATE NOWAIT;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_lock_var                    lock_csr%ROWTYPE;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    BEGIN
      OPEN lock_csr(p_rcstl_rec);
      FETCH lock_csr INTO l_lock_var;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        Okl_Api.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE App_Exceptions.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      Okl_Api.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- lock_row_v --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcsv_rec                     IN okl_rcsv_rec) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    l_rcsb_rec                      okl_rcsb_rec;
    l_rcstl_rec    okl_rcstl_rec;
  BEGIN
    l_return_status := Okl_Api.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(p_rcsv_rec, l_rcsb_rec);
    migrate(p_rcsv_rec, l_rcstl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rcsb_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_rcstl_rec
    );
    IF (x_return_status = Okl_Api.G_RET_STS_UNEXP_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = Okl_Api.G_RET_STS_ERROR) THEN
      RAISE Okl_Api.G_EXCEPTION_ERROR;
    END IF;
    Okl_Api.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
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
  -- PL/SQL TBL lock_row_tbl --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rcsv_tbl                     IN okl_rcsv_tbl) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
	-- Begin Post-Generation Change
    -- overall error status
    l_overall_status               VARCHAR2(1) := Okl_Api.G_RET_STS_SUCCESS;
    -- End Post-Generation Change
    i                              NUMBER := 0;
  BEGIN
    Okl_Api.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rcsv_tbl.COUNT > 0) THEN
      i := p_rcsv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => Okl_Api.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rcsv_rec                     => p_rcsv_tbl(i));
		-- Begin Post-Generation Change
        -- store the highest degree of error
        IF x_return_status <> Okl_Api.G_RET_STS_SUCCESS THEN
           IF l_overall_status <> Okl_Api.G_RET_STS_UNEXP_ERROR THEN
              l_overall_status := x_return_status;
           END IF;
        END IF;
        -- End Post-Generation Change
        EXIT WHEN (i = p_rcsv_tbl.LAST);
        i := p_rcsv_tbl.NEXT(i);
      END LOOP;
      -- Begin Post-Generation Change
      -- return overall status
      x_return_status := l_overall_status;
      -- End Post-Generation Change
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_ERROR THEN
      x_return_status := Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN Okl_Api.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKL_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=Okl_Api.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

--------------------------------------------------------------------------------
-- Procedure update_row_b
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsb_rec			 IN okl_rcsb_rec,
	 x_rcsb_rec			 OUT NOCOPY okl_rcsb_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcsb_rec			okl_rcsb_rec := p_rcsb_rec;
	l_def_rcsb_rec			okl_rcsb_rec;
	l_row_notfound			BOOLEAN:=TRUE;

 FUNCTION Set_Attributes(
	p_rcsb_rec IN okl_rcsb_rec,
	x_rcsb_rec OUT NOCOPY okl_rcsb_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcsb_rec := p_rcsb_rec;
 RETURN (l_return_status);
 END Set_Attributes;
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

	--Setting Item Attributes
	l_return_status:=Set_Attributes(p_rcsb_rec,
		l_def_rcsb_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

UPDATE OKL_FE_RESI_CAT_ALL_B
 SET
	RESI_CATEGORY_SET_ID= l_def_rcsb_rec.RESI_CATEGORY_SET_ID,
	RESI_CAT_NAME       =l_def_rcsb_rec.RESI_CAT_NAME,
	ORIG_RESI_CAT_SET_ID=l_def_rcsb_rec.ORIG_RESI_CAT_SET_ID,
	OBJECT_VERSION_NUMBER=l_def_rcsb_rec.OBJECT_VERSION_NUMBER+1,
	ORG_ID= l_def_rcsb_rec.ORG_ID,
	SOURCE_CODE= l_def_rcsb_rec.SOURCE_CODE,
	STS_CODE= l_def_rcsb_rec.STS_CODE,
	CREATED_BY= l_def_rcsb_rec.CREATED_BY,
	CREATION_DATE= l_def_rcsb_rec.CREATION_DATE,
	LAST_UPDATED_BY= l_def_rcsb_rec.LAST_UPDATED_BY,
	LAST_UPDATE_DATE= l_def_rcsb_rec.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN= l_def_rcsb_rec.LAST_UPDATE_LOGIN
 WHERE RESI_CATEGORY_SET_ID = l_def_rcsb_rec.resi_category_set_id;
	--Set OUT Values
	x_rcsb_rec:=l_rcsb_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure update_row_tl
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcstl_rec			 IN okl_rcstl_rec,
	 x_rcstl_rec			 OUT NOCOPY okl_rcstl_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcstl_rec			okl_rcstl_rec := p_rcstl_rec;
	l_def_rcstl_rec			okl_rcstl_rec;
	l_row_notfound			BOOLEAN:=TRUE;

 FUNCTION Set_Attributes(
	p_rcstl_rec IN okl_rcstl_rec,
	x_rcstl_rec OUT NOCOPY okl_rcstl_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcstl_rec := p_rcstl_rec;
		x_rcstl_rec.LANGUAGE := USERENV('LANG');
		x_rcstl_rec.SOURCE_LANG := USERENV('LANG');
 RETURN (l_return_status);
 END Set_Attributes;
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
	--Setting Item Attributes
	l_return_status:=Set_Attributes(p_rcstl_rec,
		l_def_rcstl_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
UPDATE OKL_FE_RESI_CAT_ALL_TL
 SET
	RESI_CATEGORY_SET_ID= l_def_rcstl_rec.RESI_CATEGORY_SET_ID,
	SOURCE_LANG= l_def_rcstl_rec.SOURCE_LANG,
	SFWT_FLAG= l_def_rcstl_rec.SFWT_FLAG,
	CREATED_BY= l_def_rcstl_rec.CREATED_BY,
	CREATION_DATE= l_def_rcstl_rec.CREATION_DATE,
	LAST_UPDATED_BY= l_def_rcstl_rec.LAST_UPDATED_BY,
	LAST_UPDATE_DATE= l_def_rcstl_rec.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN= l_def_rcstl_rec.LAST_UPDATE_LOGIN,
	RESI_CAT_DESC= l_def_rcstl_rec.RESI_CAT_DESC
 WHERE
       RESI_CATEGORY_SET_ID   = l_def_rcstl_rec.resi_category_set_id;

UPDATE OKL_FE_RESI_CAT_ALL_TL
	SET SFWT_FLAG='Y' WHERE RESI_CATEGORY_SET_ID =l_def_rcstl_rec.resi_category_set_id
	AND SOURCE_LANG<>USERENV('LANG');
	--Set OUT Values
	x_rcstl_rec:=l_rcstl_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure update_row_v
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec,
	 x_rcsv_rec			 OUT NOCOPY okl_rcsv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_rcsv_rec			okl_rcsv_rec:=p_rcsv_rec;
l_def_rcsv_rec			okl_rcsv_rec;
l_rcsb_rec			okl_rcsb_rec;
lx_rcsb_rec			okl_rcsb_rec;
l_rcstl_rec			okl_rcstl_rec;
lx_rcstl_rec			okl_rcstl_rec;

 FUNCTION fill_who_columns(
 p_rcsv_rec	IN okl_rcsv_rec
 )RETURN okl_rcsv_rec IS
l_rcsv_rec 	okl_rcsv_rec:=p_rcsv_rec;
 BEGIN
   l_rcsv_rec .LAST_UPDATE_DATE := SYSDATE;
  l_rcsv_rec .LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_rcsv_rec .LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_rcsv_rec );
 END fill_who_columns;
 FUNCTION populate_new_record(
	p_rcsv_rec	IN okl_rcsv_rec,
	x_rcsv_rec	OUT NOCOPY okl_rcsv_rec
	)RETURN VARCHAR2 is
	l_rcsv_rec	okl_rcsv_rec;
	l_row_notfound	BOOLEAN:=TRUE;
	l_return_status	VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	 BEGIN
	x_rcsv_rec := p_rcsv_rec;
	--Get current database values
	l_rcsv_rec := get_rec(p_rcsv_rec,l_row_notfound);
	IF(l_row_notfound) THEN
	 l_return_status:= OKL_API.G_RET_STS_UNEXP_ERROR;
  END IF;


	IF (x_rcsv_rec.RESI_CATEGORY_SET_ID IS NULL)
	THEN
	 x_rcsv_rec.RESI_CATEGORY_SET_ID:=l_rcsv_rec.RESI_CATEGORY_SET_ID;
	END IF;
	IF (x_rcsv_rec.ORIG_RESI_CAT_SET_ID IS NULL)
	THEN
	 x_rcsv_rec.ORIG_RESI_CAT_SET_ID:=l_rcsv_rec.ORIG_RESI_CAT_SET_ID;
	END IF;
	IF (x_rcsv_rec.OBJECT_VERSION_NUMBER IS NULL)
	THEN
	 x_rcsv_rec.OBJECT_VERSION_NUMBER:=l_rcsv_rec.RESI_CATEGORY_SET_ID;
	END IF;
	IF (x_rcsv_rec.ORG_ID IS NULL)
	THEN
	 x_rcsv_rec.ORG_ID:=l_rcsv_rec.ORG_ID;
	END IF;
	IF (x_rcsv_rec.SOURCE_CODE IS NULL )
	THEN
	 x_rcsv_rec.SOURCE_CODE:=l_rcsv_rec.SOURCE_CODE;
	END IF;
	IF (x_rcsv_rec.STS_CODE IS NULL)
	THEN
	 x_rcsv_rec.STS_CODE:=l_rcsv_rec.STS_CODE;
	END IF;
	IF (x_rcsv_rec.RESI_CAT_NAME IS NULL)
	THEN
	 x_rcsv_rec.RESI_CAT_NAME:=l_rcsv_rec.RESI_CAT_NAME;
	END IF;
	IF (x_rcsv_rec.RESI_CAT_DESC IS NULL)
	THEN
	 x_rcsv_rec.RESI_CAT_DESC:=l_rcsv_rec.RESI_CAT_DESC;
	END IF;
	IF (x_rcsv_rec.SFWT_FLAG IS NULL)
	THEN
	 x_rcsv_rec.SFWT_FLAG:=l_rcsv_rec.SFWT_FLAG;
	END IF;
	IF (x_rcsv_rec.CREATED_BY IS NULL)
	THEN
	 x_rcsv_rec.CREATED_BY:=l_rcsv_rec.CREATED_BY;
	END IF;
	IF (x_rcsv_rec.CREATION_DATE IS NULL)
	THEN
	 x_rcsv_rec.CREATION_DATE:=l_rcsv_rec.CREATION_DATE;
	END IF;
	IF (x_rcsv_rec.LAST_UPDATED_BY IS NULL)
	THEN
	 x_rcsv_rec.LAST_UPDATED_BY:=l_rcsv_rec.LAST_UPDATED_BY;
	END IF;
	IF (x_rcsv_rec.LAST_UPDATE_DATE IS NULL)
	THEN
	 x_rcsv_rec.LAST_UPDATE_DATE:=l_rcsv_rec.LAST_UPDATE_DATE;
	END IF;
	IF (x_rcsv_rec.LAST_UPDATE_LOGIN IS NULL)
	THEN
	 x_rcsv_rec.LAST_UPDATE_LOGIN:=l_rcsv_rec.LAST_UPDATE_LOGIN;
	END IF;
	RETURN(l_return_status);
   END populate_new_record;

 FUNCTION Set_Attributes(
	p_rcsv_rec IN okl_rcsv_rec,
	x_rcsv_rec OUT NOCOPY okl_rcsv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcsv_rec := p_rcsv_rec;
 RETURN (l_return_status);
 END Set_Attributes;
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
	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_rcsv_rec,l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := populate_new_record(l_rcsv_rec,l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    l_def_rcsv_rec := null_out_defaults(l_def_rcsv_rec);
	l_def_rcsv_rec := fill_who_columns(l_def_rcsv_rec);

	l_return_status := Validate_Attributes(l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := Validate_Record(l_def_rcsv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
    --lock the row
    lock_row(p_api_version    => l_api_version,
             p_init_msg_list  => OKL_API.G_FALSE,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_rcsv_rec       => l_def_rcsv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	migrate(l_def_rcsv_rec,l_rcsb_rec);
	migrate(l_def_rcsv_rec,l_rcstl_rec);
	update_row(
	 p_api_version,
	 p_init_msg_list,
	 l_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcsb_rec,
	 lx_rcsb_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	migrate(lx_rcsb_rec,l_def_rcsv_rec);
	update_row(
	 p_api_version,
	 p_init_msg_list,
	 l_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcstl_rec,
	 lx_rcstl_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	migrate(lx_rcstl_rec,l_def_rcsv_rec);

	--Set OUT Values
	x_rcsv_rec:= l_def_rcsv_rec;
    x_return_status := l_return_status;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure update_row_tbl
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl,
	 x_rcsv_tbl			 OUT NOCOPY okl_rcsv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_rcsv_tbl.COUNT > 0) THEN
	  i := p_rcsv_tbl.FIRST;
	 LOOP
	   update_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_rcsv_rec			=> p_rcsv_tbl(i),
		x_rcsv_rec			=> x_rcsv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_rcsv_tbl.LAST);
	i := p_rcsv_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure delete_row_b
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsb_rec			 IN okl_rcsb_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcsb_rec			okl_rcsb_rec := p_rcsb_rec;
	l_row_notfound			BOOLEAN:=TRUE;

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

	DELETE FROM OKL_FE_RESI_CAT_ALL_B
	WHERE RESI_CATEGORY_SET_ID=l_rcsb_rec.resi_category_set_id;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure delete_row_tl
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcstl_rec			 IN okl_rcstl_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_rcstl_rec			okl_rcstl_rec := p_rcstl_rec;
	l_row_notfound			BOOLEAN:=TRUE;

 FUNCTION Set_Attributes(
	p_rcstl_rec IN okl_rcstl_rec,
	x_rcstl_rec OUT NOCOPY okl_rcstl_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_rcstl_rec := p_rcstl_rec;
		x_rcstl_rec.LANGUAGE := USERENV('LANG');
		x_rcstl_rec.SOURCE_LANG := USERENV('LANG');
 RETURN (l_return_status);
 END Set_Attributes;
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

	--Setting Item Attributes
	l_return_status:=Set_Attributes(p_rcstl_rec,
		l_rcstl_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	DELETE FROM OKL_FE_RESI_CAT_ALL_TL
	WHERE RESI_CATEGORY_SET_ID=l_rcstl_rec.resi_category_set_id;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure delete_row_v
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_rec			 IN okl_rcsv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_rcsv_rec			okl_rcsv_rec:=p_rcsv_rec;
l_rcsb_rec			okl_rcsb_rec;
l_rcstl_rec			okl_rcstl_rec;

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

	migrate(l_rcsv_rec,l_rcsb_rec);
	migrate(l_rcsv_rec,l_rcstl_rec);
	delete_row(
	 p_api_version,
	 p_init_msg_list,
	 x_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcsb_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	delete_row(
	 p_api_version,
	 p_init_msg_list,
	 x_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_rcstl_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
--------------------------------------------------------------------------------
-- Procedure delete_row_tbl
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_rcsv_tbl			 IN okl_rcsv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_rcsv_tbl.COUNT > 0) THEN
	  i := p_rcsv_tbl.FIRST;
	 LOOP
	   delete_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_rcsv_rec			=> p_rcsv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_rcsv_tbl.LAST);
	i := p_rcsv_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

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
END OKL_RCS_PVT;

/
