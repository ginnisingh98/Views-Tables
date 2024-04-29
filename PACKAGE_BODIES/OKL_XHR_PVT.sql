--------------------------------------------------------
--  DDL for Package Body OKL_XHR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_XHR_PVT" AS
/* $Header: OKLSXHRB.pls 120.3 2007/08/08 12:56:18 arajagop ship $ */
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
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    DELETE FROM OKL_EXT_FUND_RQNS_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKL_EXT_FUND_RQNS_ALL_B B  --fixed bug 3321017 by kmotepal
         WHERE B.ID = T.ID
        );

  /*

     Post-Generation Change
     By RDRAGUIL on 20-Apr-2001

     Since the table does not have any meaningful columns,
       UPDATE statement is not complete.
     Please comment out WHERE condition if
       UPDATE statement is not present
     If new release has some columns in the table,
       this modification is not needed

    WHERE (
            T.ID,
            T.LANGUAGE)
        IN (SELECT
                SUBT.ID,
                SUBT.LANGUAGE
              FROM OKL_EXT_FUND_RQNS_TL SUBB, OKL_EXT_FUND_RQNS_TL SUBT
             WHERE SUBB.ID = SUBT.ID
               AND SUBB.LANGUAGE = SUBT.SOURCE_LANG

  */

  INSERT INTO OKL_EXT_FUND_RQNS_TL (
      ID,
      LANGUAGE,
      SOURCE_LANG,
      SFWT_FLAG,
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
          B.CREATED_BY,
          B.CREATION_DATE,
          B.LAST_UPDATED_BY,
          B.LAST_UPDATE_DATE,
          B.LAST_UPDATE_LOGIN
      FROM OKL_EXT_FUND_RQNS_TL B, FND_LANGUAGES L
     WHERE L.INSTALLED_FLAG IN ('I', 'B')
       AND B.LANGUAGE = USERENV('LANG')
       AND NOT EXISTS(
                  SELECT NULL
                    FROM OKL_EXT_FUND_RQNS_TL T
                   WHERE T.ID = B.ID
                     AND T.LANGUAGE = L.LANGUAGE_CODE
                  );

END add_language;

---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_EXT_FUND_RQNS_B
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_xhr_rec                      IN xhr_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN xhr_rec_type IS
  CURSOR okl_ext_fund_rqns_b_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          IRQ_ID,
          OBJECT_VERSION_NUMBER,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          ORG_ID,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
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
          LAST_UPDATE_LOGIN
    FROM Okl_Ext_Fund_Rqns_B
   WHERE okl_ext_fund_rqns_b.id = p_id;
  l_okl_ext_fund_rqns_b_pk       okl_ext_fund_rqns_b_pk_csr%ROWTYPE;
  l_xhr_rec                      xhr_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_ext_fund_rqns_b_pk_csr (p_xhr_rec.id);
  FETCH okl_ext_fund_rqns_b_pk_csr INTO
            l_xhr_rec.ID,
            l_xhr_rec.IRQ_ID,
            l_xhr_rec.OBJECT_VERSION_NUMBER,
            l_xhr_rec.CREATED_BY,
            l_xhr_rec.CREATION_DATE,
            l_xhr_rec.LAST_UPDATED_BY,
            l_xhr_rec.LAST_UPDATE_DATE,
            l_xhr_rec.ORG_ID,
            l_xhr_rec.REQUEST_ID,
            l_xhr_rec.PROGRAM_APPLICATION_ID,
            l_xhr_rec.PROGRAM_ID,
            l_xhr_rec.PROGRAM_UPDATE_DATE,
            l_xhr_rec.ATTRIBUTE_CATEGORY,
            l_xhr_rec.ATTRIBUTE1,
            l_xhr_rec.ATTRIBUTE2,
            l_xhr_rec.ATTRIBUTE3,
            l_xhr_rec.ATTRIBUTE4,
            l_xhr_rec.ATTRIBUTE5,
            l_xhr_rec.ATTRIBUTE6,
            l_xhr_rec.ATTRIBUTE7,
            l_xhr_rec.ATTRIBUTE8,
            l_xhr_rec.ATTRIBUTE9,
            l_xhr_rec.ATTRIBUTE10,
            l_xhr_rec.ATTRIBUTE11,
            l_xhr_rec.ATTRIBUTE12,
            l_xhr_rec.ATTRIBUTE13,
            l_xhr_rec.ATTRIBUTE14,
            l_xhr_rec.ATTRIBUTE15,
            l_xhr_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_ext_fund_rqns_b_pk_csr%NOTFOUND;
  CLOSE okl_ext_fund_rqns_b_pk_csr;
  RETURN(l_xhr_rec);
END get_rec;

FUNCTION get_rec (
  p_xhr_rec                      IN xhr_rec_type
) RETURN xhr_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_xhr_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_EXT_FUND_RQNS_TL
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN okl_ext_fund_rqns_tl_rec_type IS
  CURSOR okl_ext_fund_rqns_tl_pk_csr (p_id                 IN NUMBER,
                                      p_language           IN VARCHAR2) IS
  SELECT
          ID,
          LANGUAGE,
          SOURCE_LANG,
          SFWT_FLAG,
          CREATED_BY,
          CREATION_DATE,
          LAST_UPDATED_BY,
          LAST_UPDATE_DATE,
          LAST_UPDATE_LOGIN
    FROM Okl_Ext_Fund_Rqns_Tl
   WHERE okl_ext_fund_rqns_tl.id = p_id
     AND okl_ext_fund_rqns_tl.language = p_language;
  l_okl_ext_fund_rqns_tl_pk      okl_ext_fund_rqns_tl_pk_csr%ROWTYPE;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_ext_fund_rqns_tl_pk_csr (p_okl_ext_fund_rqns_tl_rec.id,
                                    p_okl_ext_fund_rqns_tl_rec.language);
  FETCH okl_ext_fund_rqns_tl_pk_csr INTO
            l_okl_ext_fund_rqns_tl_rec.ID,
            l_okl_ext_fund_rqns_tl_rec.LANGUAGE,
            l_okl_ext_fund_rqns_tl_rec.SOURCE_LANG,
            l_okl_ext_fund_rqns_tl_rec.SFWT_FLAG,
            l_okl_ext_fund_rqns_tl_rec.CREATED_BY,
            l_okl_ext_fund_rqns_tl_rec.CREATION_DATE,
            l_okl_ext_fund_rqns_tl_rec.LAST_UPDATED_BY,
            l_okl_ext_fund_rqns_tl_rec.LAST_UPDATE_DATE,
            l_okl_ext_fund_rqns_tl_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_ext_fund_rqns_tl_pk_csr%NOTFOUND;
  CLOSE okl_ext_fund_rqns_tl_pk_csr;
  RETURN(l_okl_ext_fund_rqns_tl_rec);
END get_rec;

FUNCTION get_rec (
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type
) RETURN okl_ext_fund_rqns_tl_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_okl_ext_fund_rqns_tl_rec, l_row_notfound));
END get_rec;
---------------------------------------------------------------------------
-- FUNCTION get_rec for: OKL_EXT_FUND_RQNS_V
---------------------------------------------------------------------------
FUNCTION get_rec (
  p_xhrv_rec                     IN xhrv_rec_type,
  x_no_data_found                OUT NOCOPY BOOLEAN
) RETURN xhrv_rec_type IS
  CURSOR okl_xhrv_pk_csr (p_id                 IN NUMBER) IS
  SELECT
          ID,
          OBJECT_VERSION_NUMBER,
          SFWT_FLAG,
          IRQ_ID,
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
          ORG_ID,
          REQUEST_ID,
          PROGRAM_APPLICATION_ID,
          PROGRAM_ID,
          PROGRAM_UPDATE_DATE,
          LAST_UPDATE_LOGIN
    FROM Okl_Ext_Fund_Rqns_V
   WHERE okl_ext_fund_rqns_v.id = p_id;
  l_okl_xhrv_pk                  okl_xhrv_pk_csr%ROWTYPE;
  l_xhrv_rec                     xhrv_rec_type;
BEGIN
  x_no_data_found := TRUE;
  -- Get current database values
  OPEN okl_xhrv_pk_csr (p_xhrv_rec.id);
  FETCH okl_xhrv_pk_csr INTO
            l_xhrv_rec.ID,
            l_xhrv_rec.OBJECT_VERSION_NUMBER,
            l_xhrv_rec.SFWT_FLAG,
            l_xhrv_rec.IRQ_ID,
            l_xhrv_rec.ATTRIBUTE_CATEGORY,
            l_xhrv_rec.ATTRIBUTE1,
            l_xhrv_rec.ATTRIBUTE2,
            l_xhrv_rec.ATTRIBUTE3,
            l_xhrv_rec.ATTRIBUTE4,
            l_xhrv_rec.ATTRIBUTE5,
            l_xhrv_rec.ATTRIBUTE6,
            l_xhrv_rec.ATTRIBUTE7,
            l_xhrv_rec.ATTRIBUTE8,
            l_xhrv_rec.ATTRIBUTE9,
            l_xhrv_rec.ATTRIBUTE10,
            l_xhrv_rec.ATTRIBUTE11,
            l_xhrv_rec.ATTRIBUTE12,
            l_xhrv_rec.ATTRIBUTE13,
            l_xhrv_rec.ATTRIBUTE14,
            l_xhrv_rec.ATTRIBUTE15,
            l_xhrv_rec.CREATED_BY,
            l_xhrv_rec.CREATION_DATE,
            l_xhrv_rec.LAST_UPDATED_BY,
            l_xhrv_rec.LAST_UPDATE_DATE,
            l_xhrv_rec.ORG_ID,
            l_xhrv_rec.REQUEST_ID,
            l_xhrv_rec.PROGRAM_APPLICATION_ID,
            l_xhrv_rec.PROGRAM_ID,
            l_xhrv_rec.PROGRAM_UPDATE_DATE,
            l_xhrv_rec.LAST_UPDATE_LOGIN;
  x_no_data_found := okl_xhrv_pk_csr%NOTFOUND;
  CLOSE okl_xhrv_pk_csr;
  RETURN(l_xhrv_rec);
END get_rec;

FUNCTION get_rec (
  p_xhrv_rec                     IN xhrv_rec_type
) RETURN xhrv_rec_type IS
  l_row_notfound                 BOOLEAN := TRUE;
BEGIN
  RETURN(get_rec(p_xhrv_rec, l_row_notfound));
END get_rec;

---------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_EXT_FUND_RQNS_V --
---------------------------------------------------------
FUNCTION null_out_defaults (
  p_xhrv_rec	IN xhrv_rec_type
) RETURN xhrv_rec_type IS
  l_xhrv_rec	xhrv_rec_type := p_xhrv_rec;
BEGIN
  IF (l_xhrv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.object_version_number := NULL;
  END IF;
  IF (l_xhrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.sfwt_flag := NULL;
  END IF;
  IF (l_xhrv_rec.irq_id = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.irq_id := NULL;
  END IF;
  IF (l_xhrv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute_category := NULL;
  END IF;
  IF (l_xhrv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute1 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute2 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute3 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute4 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute5 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute6 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute7 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute8 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute9 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute10 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute11 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute12 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute13 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute14 := NULL;
  END IF;
  IF (l_xhrv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
    l_xhrv_rec.attribute15 := NULL;
  END IF;
  IF (l_xhrv_rec.created_by = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.created_by := NULL;
  END IF;
  IF (l_xhrv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
    l_xhrv_rec.creation_date := NULL;
  END IF;
  IF (l_xhrv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.last_updated_by := NULL;
  END IF;
  IF (l_xhrv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
    l_xhrv_rec.last_update_date := NULL;
  END IF;
  IF (l_xhrv_rec.org_id = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.org_id := NULL;
  END IF;
  IF (l_xhrv_rec.request_id = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.request_id := NULL;
  END IF;
  IF (l_xhrv_rec.program_application_id = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.program_application_id := NULL;
  END IF;
  IF (l_xhrv_rec.program_id = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.program_id := NULL;
  END IF;
  IF (l_xhrv_rec.program_update_date = OKC_API.G_MISS_DATE) THEN
    l_xhrv_rec.program_update_date := NULL;
  END IF;
  IF (l_xhrv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
    l_xhrv_rec.last_update_login := NULL;
  END IF;
  RETURN(l_xhrv_rec);
END null_out_defaults;
---------------------------------------------------------------------------
-- PROCEDURE Validate_Attributes
---------------------------------------------------------------------------
-------------------------------------------------
-- Validate_Attributes for:OKL_EXT_FUND_RQNS_V --
-------------------------------------------------
FUNCTION Validate_Attributes (
  p_xhrv_rec IN  xhrv_rec_type
) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  IF p_xhrv_rec.id = OKC_API.G_MISS_NUM OR
     p_xhrv_rec.id IS NULL
  THEN
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
    l_return_status := OKC_API.G_RET_STS_ERROR;
  ELSIF p_xhrv_rec.object_version_number = OKC_API.G_MISS_NUM OR
        p_xhrv_rec.object_version_number IS NULL
  THEN
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
    l_return_status := OKC_API.G_RET_STS_ERROR;
  END IF;
  RETURN(l_return_status);
END Validate_Attributes;

---------------------------------------------------------------------------
-- PROCEDURE Validate_Record
---------------------------------------------------------------------------
---------------------------------------------
-- Validate_Record for:OKL_EXT_FUND_RQNS_V --
---------------------------------------------
FUNCTION Validate_Record (
  p_xhrv_rec IN xhrv_rec_type
) RETURN VARCHAR2 IS
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN
  RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------
-- PROCEDURE Migrate
---------------------------------------------------------------------------
PROCEDURE migrate (
  p_from	IN xhrv_rec_type,
  p_to	OUT NOCOPY xhr_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.irq_id := p_from.irq_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.created_by := p_from.created_by;
  p_to.creation_date := p_from.creation_date;
  p_to.last_updated_by := p_from.last_updated_by;
  p_to.last_update_date := p_from.last_update_date;
  p_to.org_id := p_from.org_id;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
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
  p_to.last_update_login := p_from.last_update_login;
END migrate;
PROCEDURE migrate (
  p_from	IN xhr_rec_type,
  p_to	OUT NOCOPY xhrv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.irq_id := p_from.irq_id;
  p_to.object_version_number := p_from.object_version_number;
  p_to.created_by := p_from.created_by;
  p_to.creation_date := p_from.creation_date;
  p_to.last_updated_by := p_from.last_updated_by;
  p_to.last_update_date := p_from.last_update_date;
  p_to.org_id := p_from.org_id;
  p_to.request_id := p_from.request_id;
  p_to.program_application_id := p_from.program_application_id;
  p_to.program_id := p_from.program_id;
  p_to.program_update_date := p_from.program_update_date;
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
  p_to.last_update_login := p_from.last_update_login;
END migrate;
PROCEDURE migrate (
  p_from	IN xhrv_rec_type,
  p_to	OUT NOCOPY okl_ext_fund_rqns_tl_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sfwt_flag := p_from.sfwt_flag;
  p_to.created_by := p_from.created_by;
  p_to.creation_date := p_from.creation_date;
  p_to.last_updated_by := p_from.last_updated_by;
  p_to.last_update_date := p_from.last_update_date;
  p_to.last_update_login := p_from.last_update_login;
END migrate;
PROCEDURE migrate (
  p_from	IN okl_ext_fund_rqns_tl_rec_type,
  p_to	OUT NOCOPY xhrv_rec_type
) IS
BEGIN
  p_to.id := p_from.id;
  p_to.sfwt_flag := p_from.sfwt_flag;
  p_to.created_by := p_from.created_by;
  p_to.creation_date := p_from.creation_date;
  p_to.last_updated_by := p_from.last_updated_by;
  p_to.last_update_date := p_from.last_update_date;
  p_to.last_update_login := p_from.last_update_login;
END migrate;

---------------------------------------------------------------------------
-- PROCEDURE validate_row
---------------------------------------------------------------------------
------------------------------------------
-- validate_row for:OKL_EXT_FUND_RQNS_V --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_rec                     IN xhrv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhrv_rec                     xhrv_rec_type := p_xhrv_rec;
  l_xhr_rec                      xhr_rec_type;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
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
  l_return_status := Validate_Attributes(l_xhrv_rec);
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_xhrv_rec);
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
-- PL/SQL TBL validate_row for:XHRV_TBL --
------------------------------------------
PROCEDURE validate_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_tbl                     IN xhrv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_xhrv_tbl.COUNT > 0) THEN
    i := p_xhrv_tbl.FIRST;
    LOOP
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xhrv_rec                     => p_xhrv_tbl(i));
      EXIT WHEN (i = p_xhrv_tbl.LAST);
      i := p_xhrv_tbl.NEXT(i);
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
----------------------------------------
-- insert_row for:OKL_EXT_FUND_RQNS_B --
----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhr_rec                      IN xhr_rec_type,
  x_xhr_rec                      OUT NOCOPY xhr_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhr_rec                      xhr_rec_type := p_xhr_rec;
  l_def_xhr_rec                  xhr_rec_type;
  --------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_B --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_xhr_rec IN  xhr_rec_type,
    x_xhr_rec OUT NOCOPY xhr_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhr_rec := p_xhr_rec;
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
    p_xhr_rec,                         -- IN
    l_xhr_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  INSERT INTO OKL_EXT_FUND_RQNS_B(
      id,
      irq_id,
      object_version_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      org_id,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
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
      last_update_login)
    VALUES (
      l_xhr_rec.id,
      l_xhr_rec.irq_id,
      l_xhr_rec.object_version_number,
      l_xhr_rec.created_by,
      l_xhr_rec.creation_date,
      l_xhr_rec.last_updated_by,
      l_xhr_rec.last_update_date,
      l_xhr_rec.org_id,
      l_xhr_rec.request_id,
      l_xhr_rec.program_application_id,
      l_xhr_rec.program_id,
      l_xhr_rec.program_update_date,
      l_xhr_rec.attribute_category,
      l_xhr_rec.attribute1,
      l_xhr_rec.attribute2,
      l_xhr_rec.attribute3,
      l_xhr_rec.attribute4,
      l_xhr_rec.attribute5,
      l_xhr_rec.attribute6,
      l_xhr_rec.attribute7,
      l_xhr_rec.attribute8,
      l_xhr_rec.attribute9,
      l_xhr_rec.attribute10,
      l_xhr_rec.attribute11,
      l_xhr_rec.attribute12,
      l_xhr_rec.attribute13,
      l_xhr_rec.attribute14,
      l_xhr_rec.attribute15,
      l_xhr_rec.last_update_login);
  -- Set OUT values
  x_xhr_rec := l_xhr_rec;
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
-- insert_row for:OKL_EXT_FUND_RQNS_TL --
-----------------------------------------
PROCEDURE insert_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type,
  x_okl_ext_fund_rqns_tl_rec     OUT NOCOPY okl_ext_fund_rqns_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type := p_okl_ext_fund_rqns_tl_rec;
  ldefoklextfundrqnstlrec        okl_ext_fund_rqns_tl_rec_type;
  CURSOR get_languages IS
    SELECT *
      FROM FND_LANGUAGES
     WHERE INSTALLED_FLAG IN ('I', 'B');
  ---------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_ext_fund_rqns_tl_rec IN  okl_ext_fund_rqns_tl_rec_type,
    x_okl_ext_fund_rqns_tl_rec OUT NOCOPY okl_ext_fund_rqns_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_ext_fund_rqns_tl_rec := p_okl_ext_fund_rqns_tl_rec;
    x_okl_ext_fund_rqns_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_ext_fund_rqns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_ext_fund_rqns_tl_rec,        -- IN
    l_okl_ext_fund_rqns_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  FOR l_lang_rec IN get_languages LOOP
    l_okl_ext_fund_rqns_tl_rec.language := l_lang_rec.language_code;
    INSERT INTO OKL_EXT_FUND_RQNS_TL(
        id,
        language,
        source_lang,
        sfwt_flag,
        created_by,
        creation_date,
        last_updated_by,
        last_update_date,
        last_update_login)
      VALUES (
        l_okl_ext_fund_rqns_tl_rec.id,
        l_okl_ext_fund_rqns_tl_rec.language,
        l_okl_ext_fund_rqns_tl_rec.source_lang,
        l_okl_ext_fund_rqns_tl_rec.sfwt_flag,
        l_okl_ext_fund_rqns_tl_rec.created_by,
        l_okl_ext_fund_rqns_tl_rec.creation_date,
        l_okl_ext_fund_rqns_tl_rec.last_updated_by,
        l_okl_ext_fund_rqns_tl_rec.last_update_date,
        l_okl_ext_fund_rqns_tl_rec.last_update_login);
  END LOOP;
  -- Set OUT values
  x_okl_ext_fund_rqns_tl_rec := l_okl_ext_fund_rqns_tl_rec;
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
-- insert_row for:OKL_EXT_FUND_RQNS_V --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_rec                     IN xhrv_rec_type,
  x_xhrv_rec                     OUT NOCOPY xhrv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhrv_rec                     xhrv_rec_type;
  l_def_xhrv_rec                 xhrv_rec_type;
  l_xhr_rec                      xhr_rec_type;
  lx_xhr_rec                     xhr_rec_type;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
  lx_okl_ext_fund_rqns_tl_rec    okl_ext_fund_rqns_tl_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_xhrv_rec	IN xhrv_rec_type
  ) RETURN xhrv_rec_type IS
    l_xhrv_rec	xhrv_rec_type := p_xhrv_rec;
  BEGIN
    l_xhrv_rec.CREATION_DATE := SYSDATE;
    l_xhrv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
    l_xhrv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_xhrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_xhrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
    RETURN(l_xhrv_rec);
  END fill_who_columns;
  --------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_V --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_xhrv_rec IN  xhrv_rec_type,
    x_xhrv_rec OUT NOCOPY xhrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhrv_rec := p_xhrv_rec;
    x_xhrv_rec.OBJECT_VERSION_NUMBER := 1;
    x_xhrv_rec.SFWT_FLAG := 'N';
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
  l_xhrv_rec := null_out_defaults(p_xhrv_rec);
  -- Set primary key value
  l_xhrv_rec.ID := get_seq_id;
  --- Setting item attributes
  l_return_status := Set_Attributes(
    l_xhrv_rec,                        -- IN
    l_def_xhrv_rec);                   -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_def_xhrv_rec := fill_who_columns(l_def_xhrv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_xhrv_rec);
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_xhrv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_xhrv_rec, l_xhr_rec);
  migrate(l_def_xhrv_rec, l_okl_ext_fund_rqns_tl_rec);
  --------------------------------------------
  -- Call the INSERT_ROW for each child record
  --------------------------------------------
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xhr_rec,
    lx_xhr_rec
  );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_xhr_rec, l_def_xhrv_rec);
  insert_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_ext_fund_rqns_tl_rec,
    lx_okl_ext_fund_rqns_tl_rec
  );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_ext_fund_rqns_tl_rec, l_def_xhrv_rec);
  -- Set OUT values
  x_xhrv_rec := l_def_xhrv_rec;
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
-- PL/SQL TBL insert_row for:XHRV_TBL --
----------------------------------------
PROCEDURE insert_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_tbl                     IN xhrv_tbl_type,
  x_xhrv_tbl                     OUT NOCOPY xhrv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_xhrv_tbl.COUNT > 0) THEN
    i := p_xhrv_tbl.FIRST;
    LOOP
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xhrv_rec                     => p_xhrv_tbl(i),
        x_xhrv_rec                     => x_xhrv_tbl(i));
      EXIT WHEN (i = p_xhrv_tbl.LAST);
      i := p_xhrv_tbl.NEXT(i);
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
--------------------------------------
-- lock_row for:OKL_EXT_FUND_RQNS_B --
--------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhr_rec                      IN xhr_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_xhr_rec IN xhr_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_EXT_FUND_RQNS_B
   WHERE ID = p_xhr_rec.id
     AND OBJECT_VERSION_NUMBER = p_xhr_rec.object_version_number
  FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

  CURSOR  lchk_csr (p_xhr_rec IN xhr_rec_type) IS
  SELECT OBJECT_VERSION_NUMBER
    FROM OKL_EXT_FUND_RQNS_B
  WHERE ID = p_xhr_rec.id;
  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_object_version_number       OKL_EXT_FUND_RQNS_B.OBJECT_VERSION_NUMBER%TYPE;
  lc_object_version_number      OKL_EXT_FUND_RQNS_B.OBJECT_VERSION_NUMBER%TYPE;
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
    OPEN lock_csr(p_xhr_rec);
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
    OPEN lchk_csr(p_xhr_rec);
    FETCH lchk_csr INTO lc_object_version_number;
    lc_row_notfound := lchk_csr%NOTFOUND;
    CLOSE lchk_csr;
  END IF;
  IF (lc_row_notfound) THEN
    OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
    RAISE OKC_API.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number > p_xhr_rec.object_version_number THEN
    OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
    RAISE OKC_API.G_EXCEPTION_ERROR;
  ELSIF lc_object_version_number <> p_xhr_rec.object_version_number THEN
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
---------------------------------------
-- lock_row for:OKL_EXT_FUND_RQNS_TL --
---------------------------------------
PROCEDURE lock_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type) IS

  E_Resource_Busy               EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
  CURSOR lock_csr (p_okl_ext_fund_rqns_tl_rec IN okl_ext_fund_rqns_tl_rec_type) IS
  SELECT *
    FROM OKL_EXT_FUND_RQNS_TL
   WHERE ID = p_okl_ext_fund_rqns_tl_rec.id
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
    OPEN lock_csr(p_okl_ext_fund_rqns_tl_rec);
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
--------------------------------------
-- lock_row for:OKL_EXT_FUND_RQNS_V --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_rec                     IN xhrv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhr_rec                      xhr_rec_type;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
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
  migrate(p_xhrv_rec, l_xhr_rec);
  migrate(p_xhrv_rec, l_okl_ext_fund_rqns_tl_rec);
  --------------------------------------------
  -- Call the LOCK_ROW for each child record
  --------------------------------------------
  lock_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xhr_rec
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
    l_okl_ext_fund_rqns_tl_rec
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
-- PL/SQL TBL lock_row for:XHRV_TBL --
--------------------------------------
PROCEDURE lock_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_tbl                     IN xhrv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_xhrv_tbl.COUNT > 0) THEN
    i := p_xhrv_tbl.FIRST;
    LOOP
      lock_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xhrv_rec                     => p_xhrv_tbl(i));
      EXIT WHEN (i = p_xhrv_tbl.LAST);
      i := p_xhrv_tbl.NEXT(i);
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
----------------------------------------
-- update_row for:OKL_EXT_FUND_RQNS_B --
----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhr_rec                      IN xhr_rec_type,
  x_xhr_rec                      OUT NOCOPY xhr_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhr_rec                      xhr_rec_type := p_xhr_rec;
  l_def_xhr_rec                  xhr_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_xhr_rec	IN xhr_rec_type,
    x_xhr_rec	OUT NOCOPY xhr_rec_type
  ) RETURN VARCHAR2 IS
    l_xhr_rec                      xhr_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhr_rec := p_xhr_rec;
    -- Get current database values
    l_xhr_rec := get_rec(p_xhr_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_xhr_rec.id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.id := l_xhr_rec.id;
    END IF;
    IF (x_xhr_rec.irq_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.irq_id := l_xhr_rec.irq_id;
    END IF;
    IF (x_xhr_rec.object_version_number = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.object_version_number := l_xhr_rec.object_version_number;
    END IF;
    IF (x_xhr_rec.created_by = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.created_by := l_xhr_rec.created_by;
    END IF;
    IF (x_xhr_rec.creation_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhr_rec.creation_date := l_xhr_rec.creation_date;
    END IF;
    IF (x_xhr_rec.last_updated_by = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.last_updated_by := l_xhr_rec.last_updated_by;
    END IF;
    IF (x_xhr_rec.last_update_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhr_rec.last_update_date := l_xhr_rec.last_update_date;
    END IF;
    IF (x_xhr_rec.org_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.org_id := l_xhr_rec.org_id;
    END IF;
    IF (x_xhr_rec.request_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.request_id := l_xhr_rec.request_id;
    END IF;
    IF (x_xhr_rec.program_application_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.program_application_id := l_xhr_rec.program_application_id;
    END IF;
    IF (x_xhr_rec.program_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.program_id := l_xhr_rec.program_id;
    END IF;
    IF (x_xhr_rec.program_update_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhr_rec.program_update_date := l_xhr_rec.program_update_date;
    END IF;
    IF (x_xhr_rec.attribute_category = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute_category := l_xhr_rec.attribute_category;
    END IF;
    IF (x_xhr_rec.attribute1 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute1 := l_xhr_rec.attribute1;
    END IF;
    IF (x_xhr_rec.attribute2 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute2 := l_xhr_rec.attribute2;
    END IF;
    IF (x_xhr_rec.attribute3 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute3 := l_xhr_rec.attribute3;
    END IF;
    IF (x_xhr_rec.attribute4 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute4 := l_xhr_rec.attribute4;
    END IF;
    IF (x_xhr_rec.attribute5 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute5 := l_xhr_rec.attribute5;
    END IF;
    IF (x_xhr_rec.attribute6 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute6 := l_xhr_rec.attribute6;
    END IF;
    IF (x_xhr_rec.attribute7 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute7 := l_xhr_rec.attribute7;
    END IF;
    IF (x_xhr_rec.attribute8 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute8 := l_xhr_rec.attribute8;
    END IF;
    IF (x_xhr_rec.attribute9 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute9 := l_xhr_rec.attribute9;
    END IF;
    IF (x_xhr_rec.attribute10 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute10 := l_xhr_rec.attribute10;
    END IF;
    IF (x_xhr_rec.attribute11 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute11 := l_xhr_rec.attribute11;
    END IF;
    IF (x_xhr_rec.attribute12 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute12 := l_xhr_rec.attribute12;
    END IF;
    IF (x_xhr_rec.attribute13 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute13 := l_xhr_rec.attribute13;
    END IF;
    IF (x_xhr_rec.attribute14 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute14 := l_xhr_rec.attribute14;
    END IF;
    IF (x_xhr_rec.attribute15 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhr_rec.attribute15 := l_xhr_rec.attribute15;
    END IF;
    IF (x_xhr_rec.last_update_login = OKC_API.G_MISS_NUM)
    THEN
      x_xhr_rec.last_update_login := l_xhr_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  --------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_B --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_xhr_rec IN  xhr_rec_type,
    x_xhr_rec OUT NOCOPY xhr_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhr_rec := p_xhr_rec;
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
    p_xhr_rec,                         -- IN
    l_xhr_rec);                        -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_xhr_rec, l_def_xhr_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_EXT_FUND_RQNS_B
  SET IRQ_ID = l_def_xhr_rec.irq_id,
      OBJECT_VERSION_NUMBER = l_def_xhr_rec.object_version_number,
      CREATED_BY = l_def_xhr_rec.created_by,
      CREATION_DATE = l_def_xhr_rec.creation_date,
      LAST_UPDATED_BY = l_def_xhr_rec.last_updated_by,
      LAST_UPDATE_DATE = l_def_xhr_rec.last_update_date,
      ORG_ID = l_def_xhr_rec.org_id,
      REQUEST_ID = l_def_xhr_rec.request_id,
      PROGRAM_APPLICATION_ID = l_def_xhr_rec.program_application_id,
      PROGRAM_ID = l_def_xhr_rec.program_id,
      PROGRAM_UPDATE_DATE = l_def_xhr_rec.program_update_date,
      ATTRIBUTE_CATEGORY = l_def_xhr_rec.attribute_category,
      ATTRIBUTE1 = l_def_xhr_rec.attribute1,
      ATTRIBUTE2 = l_def_xhr_rec.attribute2,
      ATTRIBUTE3 = l_def_xhr_rec.attribute3,
      ATTRIBUTE4 = l_def_xhr_rec.attribute4,
      ATTRIBUTE5 = l_def_xhr_rec.attribute5,
      ATTRIBUTE6 = l_def_xhr_rec.attribute6,
      ATTRIBUTE7 = l_def_xhr_rec.attribute7,
      ATTRIBUTE8 = l_def_xhr_rec.attribute8,
      ATTRIBUTE9 = l_def_xhr_rec.attribute9,
      ATTRIBUTE10 = l_def_xhr_rec.attribute10,
      ATTRIBUTE11 = l_def_xhr_rec.attribute11,
      ATTRIBUTE12 = l_def_xhr_rec.attribute12,
      ATTRIBUTE13 = l_def_xhr_rec.attribute13,
      ATTRIBUTE14 = l_def_xhr_rec.attribute14,
      ATTRIBUTE15 = l_def_xhr_rec.attribute15,
      LAST_UPDATE_LOGIN = l_def_xhr_rec.last_update_login
  WHERE ID = l_def_xhr_rec.id;

  x_xhr_rec := l_def_xhr_rec;
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
-- update_row for:OKL_EXT_FUND_RQNS_TL --
-----------------------------------------
PROCEDURE update_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type,
  x_okl_ext_fund_rqns_tl_rec     OUT NOCOPY okl_ext_fund_rqns_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type := p_okl_ext_fund_rqns_tl_rec;
  ldefoklextfundrqnstlrec        okl_ext_fund_rqns_tl_rec_type;
  l_row_notfound                 BOOLEAN := TRUE;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_okl_ext_fund_rqns_tl_rec	IN okl_ext_fund_rqns_tl_rec_type,
    x_okl_ext_fund_rqns_tl_rec	OUT NOCOPY okl_ext_fund_rqns_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_ext_fund_rqns_tl_rec := p_okl_ext_fund_rqns_tl_rec;
    -- Get current database values
    l_okl_ext_fund_rqns_tl_rec := get_rec(p_okl_ext_fund_rqns_tl_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.id = OKC_API.G_MISS_NUM)
    THEN
      x_okl_ext_fund_rqns_tl_rec.id := l_okl_ext_fund_rqns_tl_rec.id;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.language = OKC_API.G_MISS_CHAR)
    THEN
      x_okl_ext_fund_rqns_tl_rec.language := l_okl_ext_fund_rqns_tl_rec.language;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
    THEN
      x_okl_ext_fund_rqns_tl_rec.source_lang := l_okl_ext_fund_rqns_tl_rec.source_lang;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
    THEN
      x_okl_ext_fund_rqns_tl_rec.sfwt_flag := l_okl_ext_fund_rqns_tl_rec.sfwt_flag;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.created_by = OKC_API.G_MISS_NUM)
    THEN
      x_okl_ext_fund_rqns_tl_rec.created_by := l_okl_ext_fund_rqns_tl_rec.created_by;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.creation_date = OKC_API.G_MISS_DATE)
    THEN
      x_okl_ext_fund_rqns_tl_rec.creation_date := l_okl_ext_fund_rqns_tl_rec.creation_date;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
    THEN
      x_okl_ext_fund_rqns_tl_rec.last_updated_by := l_okl_ext_fund_rqns_tl_rec.last_updated_by;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
    THEN
      x_okl_ext_fund_rqns_tl_rec.last_update_date := l_okl_ext_fund_rqns_tl_rec.last_update_date;
    END IF;
    IF (x_okl_ext_fund_rqns_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
    THEN
      x_okl_ext_fund_rqns_tl_rec.last_update_login := l_okl_ext_fund_rqns_tl_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  ---------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_ext_fund_rqns_tl_rec IN  okl_ext_fund_rqns_tl_rec_type,
    x_okl_ext_fund_rqns_tl_rec OUT NOCOPY okl_ext_fund_rqns_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_ext_fund_rqns_tl_rec := p_okl_ext_fund_rqns_tl_rec;
    x_okl_ext_fund_rqns_tl_rec.LANGUAGE := USERENV('LANG');
    x_okl_ext_fund_rqns_tl_rec.SOURCE_LANG := USERENV('LANG');
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
    p_okl_ext_fund_rqns_tl_rec,        -- IN
    l_okl_ext_fund_rqns_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_okl_ext_fund_rqns_tl_rec, ldefoklextfundrqnstlrec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  UPDATE  OKL_EXT_FUND_RQNS_TL
  SET SOURCE_LANG = ldefoklextfundrqnstlrec.source_lang,
      CREATED_BY = ldefoklextfundrqnstlrec.created_by,
      CREATION_DATE = ldefoklextfundrqnstlrec.creation_date,
      LAST_UPDATED_BY = ldefoklextfundrqnstlrec.last_updated_by,
      LAST_UPDATE_DATE = ldefoklextfundrqnstlrec.last_update_date,
      LAST_UPDATE_LOGIN = ldefoklextfundrqnstlrec.last_update_login
  WHERE ID = ldefoklextfundrqnstlrec.id
  AND USERENV('LANG') in (SOURCE_LANG, LANGUAGE);

  UPDATE  OKL_EXT_FUND_RQNS_TL
  SET SFWT_FLAG = 'Y'
  WHERE ID = ldefoklextfundrqnstlrec.id
    AND SOURCE_LANG <> USERENV('LANG');

  x_okl_ext_fund_rqns_tl_rec := ldefoklextfundrqnstlrec;
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
-- update_row for:OKL_EXT_FUND_RQNS_V --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_rec                     IN xhrv_rec_type,
  x_xhrv_rec                     OUT NOCOPY xhrv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhrv_rec                     xhrv_rec_type := p_xhrv_rec;
  l_def_xhrv_rec                 xhrv_rec_type;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
  lx_okl_ext_fund_rqns_tl_rec    okl_ext_fund_rqns_tl_rec_type;
  l_xhr_rec                      xhr_rec_type;
  lx_xhr_rec                     xhr_rec_type;
  -------------------------------
  -- FUNCTION fill_who_columns --
  -------------------------------
  FUNCTION fill_who_columns (
    p_xhrv_rec	IN xhrv_rec_type
  ) RETURN xhrv_rec_type IS
    l_xhrv_rec	xhrv_rec_type := p_xhrv_rec;
  BEGIN
    l_xhrv_rec.LAST_UPDATE_DATE := SYSDATE;
    l_xhrv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_xhrv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
    RETURN(l_xhrv_rec);
  END fill_who_columns;
  ----------------------------------
  -- FUNCTION populate_new_record --
  ----------------------------------
  FUNCTION populate_new_record (
    p_xhrv_rec	IN xhrv_rec_type,
    x_xhrv_rec	OUT NOCOPY xhrv_rec_type
  ) RETURN VARCHAR2 IS
    l_xhrv_rec                     xhrv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhrv_rec := p_xhrv_rec;
    -- Get current database values
    l_xhrv_rec := get_rec(p_xhrv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    END IF;
    IF (x_xhrv_rec.id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.id := l_xhrv_rec.id;
    END IF;
    IF (x_xhrv_rec.object_version_number = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.object_version_number := l_xhrv_rec.object_version_number;
    END IF;
    IF (x_xhrv_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.sfwt_flag := l_xhrv_rec.sfwt_flag;
    END IF;
    IF (x_xhrv_rec.irq_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.irq_id := l_xhrv_rec.irq_id;
    END IF;
    IF (x_xhrv_rec.attribute_category = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute_category := l_xhrv_rec.attribute_category;
    END IF;
    IF (x_xhrv_rec.attribute1 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute1 := l_xhrv_rec.attribute1;
    END IF;
    IF (x_xhrv_rec.attribute2 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute2 := l_xhrv_rec.attribute2;
    END IF;
    IF (x_xhrv_rec.attribute3 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute3 := l_xhrv_rec.attribute3;
    END IF;
    IF (x_xhrv_rec.attribute4 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute4 := l_xhrv_rec.attribute4;
    END IF;
    IF (x_xhrv_rec.attribute5 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute5 := l_xhrv_rec.attribute5;
    END IF;
    IF (x_xhrv_rec.attribute6 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute6 := l_xhrv_rec.attribute6;
    END IF;
    IF (x_xhrv_rec.attribute7 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute7 := l_xhrv_rec.attribute7;
    END IF;
    IF (x_xhrv_rec.attribute8 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute8 := l_xhrv_rec.attribute8;
    END IF;
    IF (x_xhrv_rec.attribute9 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute9 := l_xhrv_rec.attribute9;
    END IF;
    IF (x_xhrv_rec.attribute10 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute10 := l_xhrv_rec.attribute10;
    END IF;
    IF (x_xhrv_rec.attribute11 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute11 := l_xhrv_rec.attribute11;
    END IF;
    IF (x_xhrv_rec.attribute12 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute12 := l_xhrv_rec.attribute12;
    END IF;
    IF (x_xhrv_rec.attribute13 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute13 := l_xhrv_rec.attribute13;
    END IF;
    IF (x_xhrv_rec.attribute14 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute14 := l_xhrv_rec.attribute14;
    END IF;
    IF (x_xhrv_rec.attribute15 = OKC_API.G_MISS_CHAR)
    THEN
      x_xhrv_rec.attribute15 := l_xhrv_rec.attribute15;
    END IF;
    IF (x_xhrv_rec.created_by = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.created_by := l_xhrv_rec.created_by;
    END IF;
    IF (x_xhrv_rec.creation_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhrv_rec.creation_date := l_xhrv_rec.creation_date;
    END IF;
    IF (x_xhrv_rec.last_updated_by = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.last_updated_by := l_xhrv_rec.last_updated_by;
    END IF;
    IF (x_xhrv_rec.last_update_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhrv_rec.last_update_date := l_xhrv_rec.last_update_date;
    END IF;
    IF (x_xhrv_rec.org_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.org_id := l_xhrv_rec.org_id;
    END IF;
    IF (x_xhrv_rec.request_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.request_id := l_xhrv_rec.request_id;
    END IF;
    IF (x_xhrv_rec.program_application_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.program_application_id := l_xhrv_rec.program_application_id;
    END IF;
    IF (x_xhrv_rec.program_id = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.program_id := l_xhrv_rec.program_id;
    END IF;
    IF (x_xhrv_rec.program_update_date = OKC_API.G_MISS_DATE)
    THEN
      x_xhrv_rec.program_update_date := l_xhrv_rec.program_update_date;
    END IF;
    IF (x_xhrv_rec.last_update_login = OKC_API.G_MISS_NUM)
    THEN
      x_xhrv_rec.last_update_login := l_xhrv_rec.last_update_login;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;
  --------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_V --
  --------------------------------------------
  FUNCTION Set_Attributes (
    p_xhrv_rec IN  xhrv_rec_type,
    x_xhrv_rec OUT NOCOPY xhrv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_xhrv_rec := p_xhrv_rec;
    x_xhrv_rec.OBJECT_VERSION_NUMBER := NVL(x_xhrv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
    p_xhrv_rec,                        -- IN
    l_xhrv_rec);                       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := populate_new_record(l_xhrv_rec, l_def_xhrv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_def_xhrv_rec := fill_who_columns(l_def_xhrv_rec);
  --- Validate all non-missing attributes (Item Level Validation)
  l_return_status := Validate_Attributes(l_def_xhrv_rec);
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  l_return_status := Validate_Record(l_def_xhrv_rec);
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;

  --------------------------------------
  -- Move VIEW record to "Child" records
  --------------------------------------
  migrate(l_def_xhrv_rec, l_okl_ext_fund_rqns_tl_rec);
  migrate(l_def_xhrv_rec, l_xhr_rec);
  --------------------------------------------
  -- Call the UPDATE_ROW for each child record
  --------------------------------------------
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_ext_fund_rqns_tl_rec,
    lx_okl_ext_fund_rqns_tl_rec
  );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_okl_ext_fund_rqns_tl_rec, l_def_xhrv_rec);
  update_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_xhr_rec,
    lx_xhr_rec
  );
  IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  migrate(lx_xhr_rec, l_def_xhrv_rec);
  x_xhrv_rec := l_def_xhrv_rec;
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
-- PL/SQL TBL update_row for:XHRV_TBL --
----------------------------------------
PROCEDURE update_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_tbl                     IN xhrv_tbl_type,
  x_xhrv_tbl                     OUT NOCOPY xhrv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_xhrv_tbl.COUNT > 0) THEN
    i := p_xhrv_tbl.FIRST;
    LOOP
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xhrv_rec                     => p_xhrv_tbl(i),
        x_xhrv_rec                     => x_xhrv_tbl(i));
      EXIT WHEN (i = p_xhrv_tbl.LAST);
      i := p_xhrv_tbl.NEXT(i);
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
----------------------------------------
-- delete_row for:OKL_EXT_FUND_RQNS_B --
----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhr_rec                      IN xhr_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhr_rec                      xhr_rec_type:= p_xhr_rec;
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
  DELETE FROM OKL_EXT_FUND_RQNS_B
   WHERE ID = l_xhr_rec.id;

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
-- delete_row for:OKL_EXT_FUND_RQNS_TL --
-----------------------------------------
PROCEDURE delete_row(
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_okl_ext_fund_rqns_tl_rec     IN okl_ext_fund_rqns_tl_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type:= p_okl_ext_fund_rqns_tl_rec;
  l_row_notfound                 BOOLEAN := TRUE;
  ---------------------------------------------
  -- Set_Attributes for:OKL_EXT_FUND_RQNS_TL --
  ---------------------------------------------
  FUNCTION Set_Attributes (
    p_okl_ext_fund_rqns_tl_rec IN  okl_ext_fund_rqns_tl_rec_type,
    x_okl_ext_fund_rqns_tl_rec OUT NOCOPY okl_ext_fund_rqns_tl_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    x_okl_ext_fund_rqns_tl_rec := p_okl_ext_fund_rqns_tl_rec;
    x_okl_ext_fund_rqns_tl_rec.LANGUAGE := USERENV('LANG');
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
    p_okl_ext_fund_rqns_tl_rec,        -- IN
    l_okl_ext_fund_rqns_tl_rec);       -- OUT
  --- If any errors happen abort API
  IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
    RAISE OKC_API.G_EXCEPTION_ERROR;
  END IF;
  DELETE FROM OKL_EXT_FUND_RQNS_TL
   WHERE ID = l_okl_ext_fund_rqns_tl_rec.id;

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
-- delete_row for:OKL_EXT_FUND_RQNS_V --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_rec                     IN xhrv_rec_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  l_xhrv_rec                     xhrv_rec_type := p_xhrv_rec;
  l_okl_ext_fund_rqns_tl_rec     okl_ext_fund_rqns_tl_rec_type;
  l_xhr_rec                      xhr_rec_type;
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
  migrate(l_xhrv_rec, l_okl_ext_fund_rqns_tl_rec);
  migrate(l_xhrv_rec, l_xhr_rec);
  --------------------------------------------
  -- Call the DELETE_ROW for each child record
  --------------------------------------------
  delete_row(
    p_init_msg_list,
    x_return_status,
    x_msg_count,
    x_msg_data,
    l_okl_ext_fund_rqns_tl_rec
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
    l_xhr_rec
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
-- PL/SQL TBL delete_row for:XHRV_TBL --
----------------------------------------
PROCEDURE delete_row(
  p_api_version                  IN NUMBER,
  p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
  x_return_status                OUT NOCOPY VARCHAR2,
  x_msg_count                    OUT NOCOPY NUMBER,
  x_msg_data                     OUT NOCOPY VARCHAR2,
  p_xhrv_tbl                     IN xhrv_tbl_type) IS

  l_api_version                 CONSTANT NUMBER := 1;
  l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
  l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  i                              NUMBER := 0;
BEGIN
  OKC_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_xhrv_tbl.COUNT > 0) THEN
    i := p_xhrv_tbl.FIRST;
    LOOP
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_xhrv_rec                     => p_xhrv_tbl(i));
      EXIT WHEN (i = p_xhrv_tbl.LAST);
      i := p_xhrv_tbl.NEXT(i);
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
END OKL_XHR_PVT;

/
