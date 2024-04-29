--------------------------------------------------------
--  DDL for Package Body OKC_LSE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_LSE_PVT" AS
/* $Header: OKCSLSEB.pls 120.0 2005/05/25 19:35:34 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');


  G_YES         VARCHAR2(3):='Y';
  G_NO          VARCHAR2(3):='N';



  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
   l_number NUMBER;
  BEGIN
    --RETURN(okc_p_util.raw_to_number(sys_guid()));
    -- Modified to handle it's own sequence
    if fnd_global.user_id = 1 then  -- DATAMERGE user
      select min(LSE1.id + 1)
        into l_number
        from okc_line_styles_b LSE1
       where id < 1000
         and NOT EXISTS (select 'x'
                           from okc_line_styles_b LSE2
                          where LSE2.id = LSE1.id +1);
    else
     select okc_line_styles_s1.nextval
       into l_number
       from dual;
    end if;
   --
    RETURN(l_number);
   --
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
    DELETE FROM OKC_LINE_STYLES_TL T
     WHERE NOT EXISTS (
        SELECT NULL
          FROM OKC_LINE_STYLES_B B
         WHERE B.ID = T.ID
        );

    UPDATE OKC_LINE_STYLES_TL T SET (
        NAME,
        DESCRIPTION) = (SELECT
                                  B.NAME,
                                  B.DESCRIPTION
                                FROM OKC_LINE_STYLES_TL B
                               WHERE B.ID = T.ID
                                 AND B.LANGUAGE = T.SOURCE_LANG)
      WHERE (
              T.ID,
              T.LANGUAGE)
          IN (SELECT
                  SUBT.ID,
                  SUBT.LANGUAGE
                FROM OKC_LINE_STYLES_TL SUBB, OKC_LINE_STYLES_TL SUBT
               WHERE SUBB.ID = SUBT.ID
                 AND SUBB.LANGUAGE = SUBT.SOURCE_LANG
                 AND (SUBB.NAME <> SUBT.NAME
                      OR SUBB.DESCRIPTION <> SUBT.DESCRIPTION
                      OR (SUBB.NAME IS NULL AND SUBT.NAME IS NOT NULL)
                      OR (SUBB.NAME IS NOT NULL AND SUBT.NAME IS NULL)
                      OR (SUBB.DESCRIPTION IS NULL AND SUBT.DESCRIPTION IS NOT NULL)
                      OR (SUBB.DESCRIPTION IS NOT NULL AND SUBT.DESCRIPTION IS NULL)
              ));

    INSERT INTO OKC_LINE_STYLES_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        NAME,
        DESCRIPTION,
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
            B.DESCRIPTION,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_LINE_STYLES_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_LINE_STYLES_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_LINE_STYLES_B
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lse_rec                      IN lse_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lse_rec_type IS
    CURSOR lse_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            LTY_CODE,
            PRICED_YN,
            RECURSIVE_YN,
            PROTECTED_YN,
            LSE_PARENT_ID,
            LSE_TYPE,
            OBJECT_VERSION_NUMBER,
            APPLICATION_ID,
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
            ATTRIBUTE15,
            ITEM_TO_PRICE_YN,
            PRICE_BASIS_YN,
            ACCESS_LEVEL,
            SERVICE_ITEM_YN
     FROM Okc_Line_Styles_B
     WHERE okc_line_styles_b.id = p_id;
    l_lse_pk                       lse_pk_csr%ROWTYPE;
    l_lse_rec                      lse_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN lse_pk_csr (p_lse_rec.id);
    FETCH lse_pk_csr INTO
              l_lse_rec.ID,
              l_lse_rec.LTY_CODE,
              l_lse_rec.priced_yn,
              l_lse_rec.RECURSIVE_YN,
              l_lse_rec.PROTECTED_YN,
              l_lse_rec.LSE_PARENT_ID,
              l_lse_rec.LSE_TYPE,
              l_lse_rec.OBJECT_VERSION_NUMBER,
              l_lse_rec.APPLICATION_ID,
              l_lse_rec.CREATED_BY,
              l_lse_rec.CREATION_DATE,
              l_lse_rec.LAST_UPDATED_BY,
              l_lse_rec.LAST_UPDATE_DATE,
              l_lse_rec.LAST_UPDATE_LOGIN,
              l_lse_rec.ATTRIBUTE_CATEGORY,
              l_lse_rec.ATTRIBUTE1,
              l_lse_rec.ATTRIBUTE2,
              l_lse_rec.ATTRIBUTE3,
              l_lse_rec.ATTRIBUTE4,
              l_lse_rec.ATTRIBUTE5,
              l_lse_rec.ATTRIBUTE6,
              l_lse_rec.ATTRIBUTE7,
              l_lse_rec.ATTRIBUTE8,
              l_lse_rec.ATTRIBUTE9,
              l_lse_rec.ATTRIBUTE10,
              l_lse_rec.ATTRIBUTE11,
              l_lse_rec.ATTRIBUTE12,
              l_lse_rec.ATTRIBUTE13,
              l_lse_rec.ATTRIBUTE14,
              l_lse_rec.ATTRIBUTE15,
              l_lse_rec.ITEM_TO_PRICE_YN,
              l_lse_rec.PRICE_BASIS_YN,
              l_lse_rec.ACCESS_LEVEL,
              l_lse_rec.SERVICE_ITEM_YN;
    x_no_data_found := lse_pk_csr%NOTFOUND;
    CLOSE lse_pk_csr;
    RETURN(l_lse_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lse_rec                      IN lse_rec_type
  ) RETURN lse_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lse_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_LINE_STYLES_TL
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN okc_line_styles_tl_rec_type IS
    CURSOR lse_pktl_csr (p_id                 IN NUMBER,
                         p_language           IN VARCHAR2) IS
    SELECT
            ID,
            LANGUAGE,
            SOURCE_LANG,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN
      FROM Okc_Line_Styles_Tl
     WHERE okc_line_styles_tl.id = p_id
       AND okc_line_styles_tl.language = p_language;
    l_lse_pktl                     lse_pktl_csr%ROWTYPE;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN lse_pktl_csr (p_okc_line_styles_tl_rec.id,
                       p_okc_line_styles_tl_rec.language);
    FETCH lse_pktl_csr INTO
              l_okc_line_styles_tl_rec.ID,
              l_okc_line_styles_tl_rec.LANGUAGE,
              l_okc_line_styles_tl_rec.SOURCE_LANG,
              l_okc_line_styles_tl_rec.SFWT_FLAG,
              l_okc_line_styles_tl_rec.NAME,
              l_okc_line_styles_tl_rec.DESCRIPTION,
              l_okc_line_styles_tl_rec.CREATED_BY,
              l_okc_line_styles_tl_rec.CREATION_DATE,
              l_okc_line_styles_tl_rec.LAST_UPDATED_BY,
              l_okc_line_styles_tl_rec.LAST_UPDATE_DATE,
              l_okc_line_styles_tl_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := lse_pktl_csr%NOTFOUND;
    CLOSE lse_pktl_csr;
    RETURN(l_okc_line_styles_tl_rec);
  END get_rec;

  FUNCTION get_rec (
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type
  ) RETURN okc_line_styles_tl_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_okc_line_styles_tl_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_LINE_STYLES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_lsev_rec                     IN lsev_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN lsev_rec_type IS
    CURSOR okc_lsev_pk_csr (p_id                 IN NUMBER) IS
    SELECT
            ID,
            LTY_CODE,
            priced_yn,
            RECURSIVE_YN,
            PROTECTED_YN,
            LSE_PARENT_ID,
            OBJECT_VERSION_NUMBER,
            APPLICATION_ID,
            SFWT_FLAG,
            NAME,
            DESCRIPTION,
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
            LSE_TYPE,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ITEM_TO_PRICE_YN,
            PRICE_BASIS_YN,
            ACCESS_LEVEL,
            SERVICE_ITEM_YN
      FROM Okc_Line_Styles_v
     WHERE okc_line_styles_v.id = p_id;
    l_okc_lsev_pk                  okc_lsev_pk_csr%ROWTYPE;
    l_lsev_rec                     lsev_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_lsev_pk_csr (p_lsev_rec.id);
    FETCH okc_lsev_pk_csr INTO
              l_lsev_rec.ID,
              l_lsev_rec.LTY_CODE,
              l_lsev_rec.priced_yn,
              l_lsev_rec.RECURSIVE_YN,
              l_lsev_rec.PROTECTED_YN,
              l_lsev_rec.LSE_PARENT_ID,
              l_lsev_rec.OBJECT_VERSION_NUMBER,
              l_lsev_rec.APPLICATION_ID,
              l_lsev_rec.SFWT_FLAG,
              l_lsev_rec.NAME,
              l_lsev_rec.DESCRIPTION,
              l_lsev_rec.ATTRIBUTE_CATEGORY,
              l_lsev_rec.ATTRIBUTE1,
              l_lsev_rec.ATTRIBUTE2,
              l_lsev_rec.ATTRIBUTE3,
              l_lsev_rec.ATTRIBUTE4,
              l_lsev_rec.ATTRIBUTE5,
              l_lsev_rec.ATTRIBUTE6,
              l_lsev_rec.ATTRIBUTE7,
              l_lsev_rec.ATTRIBUTE8,
              l_lsev_rec.ATTRIBUTE9,
              l_lsev_rec.ATTRIBUTE10,
              l_lsev_rec.ATTRIBUTE11,
              l_lsev_rec.ATTRIBUTE12,
              l_lsev_rec.ATTRIBUTE13,
              l_lsev_rec.ATTRIBUTE14,
              l_lsev_rec.ATTRIBUTE15,
              l_lsev_rec.LSE_TYPE,
              l_lsev_rec.CREATED_BY,
              l_lsev_rec.CREATION_DATE,
              l_lsev_rec.LAST_UPDATED_BY,
              l_lsev_rec.LAST_UPDATE_DATE,
              l_lsev_rec.LAST_UPDATE_LOGIN,
              l_lsev_rec.ITEM_TO_PRICE_YN,
              l_lsev_rec.PRICE_BASIS_YN,
              l_lsev_rec.ACCESS_LEVEL,
              l_lsev_rec.SERVICE_ITEM_YN;
    x_no_data_found := okc_lsev_pk_csr%NOTFOUND;
    CLOSE okc_lsev_pk_csr;
    RETURN(l_lsev_rec);
  END get_rec;

  FUNCTION get_rec (
    p_lsev_rec                     IN lsev_rec_type
  ) RETURN lsev_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_lsev_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_LINE_STYLES_V --
  -------------------------------------------------------
  FUNCTION null_out_defaults (
    p_lsev_rec	IN lsev_rec_type
  ) RETURN lsev_rec_type IS
    l_lsev_rec	lsev_rec_type := p_lsev_rec;
  BEGIN
    IF (l_lsev_rec.lty_code = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.lty_code := NULL;
    END IF;
    IF (l_lsev_rec.priced_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.priced_yn := NULL;
    END IF;
    IF (l_lsev_rec.recursive_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.recursive_yn := NULL;
    END IF;
    IF (l_lsev_rec.protected_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.protected_yn := NULL;
    END IF;
    IF (l_lsev_rec.lse_parent_id = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.lse_parent_id := NULL;
    END IF;
    IF (l_lsev_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.object_version_number := NULL;
    END IF;
    IF (l_lsev_rec.APPLICATION_ID = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.APPLICATION_ID := NULL;
    END IF;
    IF (l_lsev_rec.sfwt_flag = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.sfwt_flag := NULL;
    END IF;
    IF (l_lsev_rec.name = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.name := NULL;
    END IF;
    IF (l_lsev_rec.description = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.description := NULL;
    END IF;
    IF (l_lsev_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute_category := NULL;
    END IF;
    IF (l_lsev_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute1 := NULL;
    END IF;
    IF (l_lsev_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute2 := NULL;
    END IF;
    IF (l_lsev_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute3 := NULL;
    END IF;
    IF (l_lsev_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute4 := NULL;
    END IF;
    IF (l_lsev_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute5 := NULL;
    END IF;
    IF (l_lsev_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute6 := NULL;
    END IF;
    IF (l_lsev_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute7 := NULL;
    END IF;
    IF (l_lsev_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute8 := NULL;
    END IF;
    IF (l_lsev_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute9 := NULL;
    END IF;
    IF (l_lsev_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute10 := NULL;
    END IF;
    IF (l_lsev_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute11 := NULL;
    END IF;
    IF (l_lsev_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute12 := NULL;
    END IF;
    IF (l_lsev_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute13 := NULL;
    END IF;
    IF (l_lsev_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute14 := NULL;
    END IF;
    IF (l_lsev_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.attribute15 := NULL;
    END IF;
    IF (l_lsev_rec.lse_type = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.lse_type := NULL;
    END IF;
    IF (l_lsev_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.created_by := NULL;
    END IF;
    IF (l_lsev_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_lsev_rec.creation_date := NULL;
    END IF;
    IF (l_lsev_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.last_updated_by := NULL;
    END IF;
    IF (l_lsev_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_lsev_rec.last_update_date := NULL;
    END IF;
    IF (l_lsev_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_lsev_rec.last_update_login := NULL;
    END IF;
     IF (l_lsev_rec.item_to_price_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.item_to_price_yn := NULL;
    END IF;
     IF (l_lsev_rec.price_basis_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.price_basis_yn := NULL;
    END IF;
     IF (l_lsev_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.access_level := NULL;
    END IF;
     IF (l_lsev_rec.service_item_yn = OKC_API.G_MISS_CHAR) THEN
      l_lsev_rec.service_item_yn := NULL;
    END IF;
   RETURN(l_lsev_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  -----------------------------------------------
  -- Validate_Attributes for:OKC_LINE_STYLES_V --
  -----------------------------------------------
  --**** Change from TAPI Code---follow till end of change---------------

  FUNCTION Check_Unique_Name (
    p_lsev_rec IN lsev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_col_tbl	                    okc_util.unq_tbl_type;
    l_id                           NUMBER:=OKC_API.G_MISS_NUM;
    CURSOR loc_top_csr (p_id IN NUMBER) is
	 select id, lse_type from okc_line_styles_b
	 connect by prior lse_parent_id = id
	 start with id = p_id;

    CURSOR loc_bot_csr (p_id IN NUMBER) is
	 select id, lse_type from okc_line_styles_b
	 connect by prior id = lse_parent_id
	 start with id = p_id;

    CURSOR par_name_csr(p_id IN NUMBER) is
	 select name from okc_line_styles_v
	 where id = p_id;

    CURSOR C1 is select id from okc_line_styles_v
			where lse_type='TLS' and UPPER(name)=UPPER(p_lsev_rec.name);

    loc_top_rec loc_top_csr%rowtype;
    loc_bot_rec loc_bot_csr%rowtype;
    par_name_rec par_name_csr%rowtype;
  BEGIN
	--Check for unique value
    if p_lsev_rec.lse_type = 'TLS' then
	 OPEN C1;
      FETCH C1 into l_id;
	 CLOSE C1;
	 IF (l_id<>OKC_API.G_MISS_NUM and l_id <> nvl(p_lsev_rec.id,-1)) then
          OKC_API.set_message(G_APP_NAME, G_UNQ,G_COL_NAME_TOKEN,'name');
		l_return_status := OKC_API.G_RET_STS_ERROR;

      END IF;
    else
	 open loc_top_csr (p_lsev_rec.lse_parent_id);
	 loop
	   fetch loc_top_csr into loc_top_rec;
	   exit when loc_top_csr%NOTFOUND;
	   open par_name_csr(loc_top_rec.id);
	   fetch par_name_csr into par_name_rec;
	   close par_name_csr;
	   if par_name_rec.name is NULL then
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'id');
		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		exit;
	   end if;
	   if UPPER(par_name_rec.name) = UPPER(p_lsev_rec.name) then
          OKC_API.set_message(G_APP_NAME, G_UNQ,G_COL_NAME_TOKEN,'name');
		l_return_status := OKC_API.G_RET_STS_ERROR;
		exit;
	   end if;
	 end loop;
	 close loc_top_csr;
	 if l_return_status <> OKC_API.G_RET_STS_SUCCESS Then
	   return (l_return_status);
      end if;
	 if loc_top_rec.id is NULL Then
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'id');
	   l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
	   return (l_return_status);
	 end if;
	 open loc_bot_csr (loc_top_rec.id);
	 loop
	   fetch loc_bot_csr into loc_bot_rec;
	   exit when loc_bot_csr%NOTFOUND;
	   open par_name_csr(loc_bot_rec.id);
	   fetch par_name_csr into par_name_rec;
	   close par_name_csr;
	   if par_name_rec.name is NULL then
          OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'id');
		l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
		exit;
	   end if;
	   if UPPER(par_name_rec.name) = UPPER(p_lsev_rec.name)  and
		 loc_bot_rec.id <> p_lsev_rec.id then
          OKC_API.set_message(G_APP_NAME, G_UNQ,G_COL_NAME_TOKEN,'name');
		l_return_status := OKC_API.g_RET_STS_ERROR;
		exit;
	   end if;
	 end loop;
	 close loc_bot_csr;
    end if;
    RETURN (l_return_status);
  END Check_Unique_Name;

  PROCEDURE Validate_Lse_Parent_Id (
      x_return_status                OUT NOCOPY VARCHAR2,
      p_lsev_rec                     IN lsev_rec_type) IS
      item_not_found_error          EXCEPTION;
      l_row_notfound                 BOOLEAN := TRUE;
      CURSOR lse_pk_csr (p_lse_id IN number) IS
      SELECT  '1'
        FROM OKC_LINE_STYLES_B
       WHERE id        = p_lse_id;
      l_lse_pk                  lse_pk_csr%ROWTYPE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
	 IF (p_lsev_rec.lse_type = 'SLS')
	 THEN
        IF (p_lsev_rec.lse_parent_id IS NOT NULL AND
          p_lsev_rec.lse_parent_id <> OKC_API.G_MISS_NUM)
        THEN
          OPEN lse_pk_csr(p_lsev_rec.lse_parent_id);
          FETCH lse_pk_csr INTO l_lse_pk;
          l_row_notfound := lse_pk_csr%NOTFOUND;
          CLOSE lse_pk_csr;
          IF (l_row_notfound) THEN
            OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'lse_parent_id');
            RAISE item_not_found_error;
          END IF;
        ELSE
           OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lse_parent_id');
           x_return_status := OKC_API.G_RET_STS_ERROR;
        END IF;
	 ELSIF (p_lsev_rec.lse_parent_id IS NOT NULL AND
        p_lsev_rec.lse_parent_id <> OKC_API.G_MISS_NUM) THEN
        OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'lse_parent_id');
        x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'lse_parent_id',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Lse_Parent_Id ;

  PROCEDURE Validate_Lse_Type (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.lse_type) = 'SLS' OR
       upper(p_lsev_rec.lse_type) = 'TLS'
    THEN
       IF p_lsev_rec.lse_type = 'SLS' OR
          p_lsev_rec.lse_type = 'TLS'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'LSE_TYPE');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LSE_TYPE');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_Lse_Type;

  PROCEDURE Validate_Lty_Code (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
    item_not_found_error          EXCEPTION;
    l_row_notfound                 BOOLEAN := TRUE;
    BEGIN
      x_return_status                := OKC_API.G_RET_STS_SUCCESS;
      IF (p_lsev_rec.lty_code IS NOT NULL AND
          p_lsev_rec.lty_code <> OKC_API.G_MISS_CHAR)
      THEN
	   x_return_status := OKC_UTIL.CHECK_LOOKUP_CODE('OKC_LINE_TYPE',p_lsev_rec.lty_code);
        if x_return_status = OKC_API.G_RET_STS_ERROR
	   Then
		OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'LTY_CODE');
	   end if;
      ELSE
         OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'lty_code');
         x_return_status := OKC_API.G_RET_STS_ERROR;
      END IF;
    EXCEPTION
      WHEN item_not_found_error THEN
        x_return_status := OKC_API.G_RET_STS_ERROR;
      WHEN OTHERS THEN
        OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                            p_msg_name     => g_unexpected_error,
                            p_token1       => g_sqlcode_token,
                            p_token1_value => sqlcode,
                            p_token2       => g_col_name_token,
                            p_token2_value => 'lty_code',
                            p_token3       => g_sqlerrm_token,
                            p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
        x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Lty_Code ;


  PROCEDURE Validate_PRICED_YN (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.priced_yn) = 'Y' OR
       upper(p_lsev_rec.priced_yn) = 'N'
    THEN
       IF p_lsev_rec.priced_yn = 'Y' OR
          p_lsev_rec.priced_yn = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'PRICED_YN');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRICED_YN');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_PRICED_YN;

  PROCEDURE Validate_ITEM_TO_PRICE_YN (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.item_to_price_yn) = 'Y' OR
       upper(p_lsev_rec.item_to_price_yn) = 'N'
    THEN
       IF p_lsev_rec.item_to_price_yn = 'Y' OR
          p_lsev_rec.item_to_price_yn = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'ITEM_TO_PRICE_YN');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_lsev_rec.item_to_price_yn <> NULL then
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ITEM_TO_PRICE_YN');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_ITEM_TO_PRICE_YN;

--
  PROCEDURE Validate_ACCESS_LEVEL (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.access_level) in ('S', 'E', 'U')
    THEN
       IF p_lsev_rec.access_level in ('S', 'E', 'U')
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'ACCESS_LEVEL');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_lsev_rec.item_to_price_yn <> NULL then
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ACCESS_LEVEL');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_ACCESS_LEVEL;
--


   PROCEDURE Validate_PRICE_BASIS_YN (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN

    IF upper(p_lsev_rec.price_basis_yn) = 'Y' OR
       upper(p_lsev_rec.price_basis_yn) = 'N'
    THEN
       IF p_lsev_rec.price_basis_yn = 'Y' OR
          p_lsev_rec.price_basis_yn = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'PRICE_BASIS_YN');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSIF p_lsev_rec.item_to_price_yn <> NULL then
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'PRICE_BASIS_YN');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_PRICE_BASIS_YN;

  PROCEDURE  Validate_item_or_basis(
   x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
   IF
        p_lsev_rec.item_to_price_yn = 'Y'
  THEN
    IF
      p_lsev_rec.price_basis_yn = 'Y'
   THEN
      x_return_status := OKC_API.G_RET_STS_ERROR;
      OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  =>'OKC_ITEM_OR_BASIS');

   ELSE
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  END IF;

   ELSE
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
  END IF;
END  Validate_item_or_basis;

--
   PROCEDURE validate_application_id(
        x_return_status         OUT NOCOPY VARCHAR2,
        p_lsev_rec               IN lsev_rec_type) IS

        Cursor application_id_cur(p_application_id IN NUMBER) IS
        select '1'
        from fnd_application
        where application_id = p_application_id;

        l_dummy         VARCHAR2(1) := '?';

    BEGIN
        -- initialize return status
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

        IF p_lsev_rec.application_id IS NOT NULL THEN
        --Check if application id exists in the fnd_application or not
        OPEN application_id_cur(p_lsev_rec.application_id);
        FETCH application_id_cur INTO l_dummy;
        CLOSE application_id_cur ;
        IF l_dummy = '?' THEN
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
                -- no processing necessary;  validation can continue
                -- with the next column
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

--

  PROCEDURE Validate_priced_level(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS

    l_return_status               VARCHAR2(1):=OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;
    lx_lsev_rec                    OKC_LINE_STYLES_PUB.lsev_rec_type;

    CURSOR loc_bot_csr (p_id IN NUMBER) is
         select id, priced_yn, item_to_price_yn, price_basis_yn from okc_line_styles_b
         Connect by prior id = lse_parent_id
         start with id = p_id;

    CURSOR loc_top_csr (p_id IN NUMBER) is
         select id, priced_yn,item_to_price_yn, price_basis_yn from okc_line_styles_b
         connect by prior lse_parent_id = id
         start with id = p_id;

    BEGIN
        x_return_status := OKC_API.G_RET_STS_SUCCESS;

     IF p_lsev_rec.priced_yn=G_Yes AND p_lsev_rec.price_basis_yn=G_Yes then
                  x_return_status := OKC_API.G_RET_STS_ERROR;
               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  =>'OKC_PRICED_ABOVE_BASIS' );


      ELSIF p_lsev_rec.priced_yn=G_Yes then
          for l_rec in loc_bot_csr(p_lsev_rec.id) loop
              IF l_rec.item_to_price_yn=G_Yes  and l_rec.id<>p_lsev_rec.id then
                 x_return_status := OKC_API.G_RET_STS_ERROR;

               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  =>'OKC_PRICED_ABOVE_ITEM' );

              END IF;
              IF l_rec.price_basis_yn=G_Yes then
                  x_return_status := OKC_API.G_RET_STS_ERROR;
               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  =>'OKC_PRICED_ABOVE_BASIS' );
               END IF;
            END LOOP;


    ELSIF p_lsev_rec.item_to_price_yn=G_Yes then
          for l_rec in loc_top_csr(p_lsev_rec.id) loop
               IF l_rec.priced_yn=G_Yes and l_rec.id<>p_lsev_rec.id then
                x_return_status := OKC_API.G_RET_STS_ERROR;

               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  =>'OKC_PRICED_ABOVE_ITEM' );

              END IF;
          END LOOP;
       ELSIF p_lsev_rec.price_basis_yn=G_Yes then
          for l_rec in loc_top_csr(p_lsev_rec.id) loop
               IF l_rec.priced_yn=G_Yes  then
                x_return_status := OKC_API.G_RET_STS_ERROR;

               OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  => 'OKC_PRICED_ABOVE_BASIS');

              END IF;
           END LOOP;
        ELSE
             x_return_status := OKC_API.G_RET_STS_SUCCESS;
        END IF;

   EXCEPTION

          WHEN OTHERS THEN
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Validate_priced_level;


   PROCEDURE Validate_item_to_price_source (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS

   l_object_user_code            VARCHAR2(30):=NULL;
   l_object_code                 VARCHAR2(30):=NULL;
   l_mtl_found                   BOOLEAN := FALSE;

  CURSOR loc_source_csr is
   select OBJECT_USER_CODE
    from JTF_OBJECT_USAGES where
       OBJECT_CODE = l_object_code
        AND OBJECT_USER_CODE = 'OKX_MTL_SYSTEM_ITEM';
   BEGIN
   IF (l_debug = 'Y') THEN
      okc_debug.set_indentation('validate_item_to_price_source');
      okc_debug.log('100:enteringvalidate_item_to_price_sourc');
   END IF;
   IF p_lsev_rec.item_to_price_yn = 'Y' THEN

      IF (l_debug = 'Y') THEN
         okc_debug.log('100:here');
      END IF;
        select JTOT_OBJECT_CODE
        into l_object_code
        from OKC_LINE_STYLE_SOURCES
        where lse_id = p_lsev_rec.id
        and sysdate between START_DATE and nvl(END_DATE,sysdate);

         IF (l_debug = 'Y') THEN
            okc_debug.log('300:');
         END IF;
           Open loc_source_csr;
           Fetch loc_source_csr into l_object_user_code;
           l_mtl_found := loc_source_csr%FOUND;
           Close loc_source_csr;

           IF NOT l_mtl_found THEN
             IF (l_debug = 'Y') THEN
                okc_debug.log('400:');
             END IF;
              x_return_status := OKC_API.G_RET_STS_ERROR;
              OKC_API.SET_MESSAGE(p_app_name      => g_app_name,
                                            p_msg_name  => 'OKC_ITEM_TO_PRICE_SOURCE');
            END IF;
          IF l_mtl_found THEN
            IF (l_debug = 'Y') THEN
               okc_debug.log('500:');
            END IF;
             x_return_status := OKC_API.G_RET_STS_SUCCESS;
           END IF;

   ELSE
     IF (l_debug = 'Y') THEN
        okc_debug.log('600:');
     END IF;
     x_return_status := OKC_API.G_RET_STS_SUCCESS;
   END IF;

   EXCEPTION
      WHEN NO_DATA_FOUND THEN
           IF (l_debug = 'Y') THEN
              okc_debug.log('700:');
           END IF;
             x_return_status := OKC_API.G_RET_STS_SUCCESS;
        --changed this to allow the line style to be item to priced when there is no line style source
            /*  x_return_status := OKC_API.G_RET_STS_ERROR;
              OKC_API.SET_MESSAGE(p_app_name  => g_app_name,
                                  p_msg_name  => 'OKC_ITEM_TO_PRICE_SOURCE');
     */
   NULL;
       WHEN OTHERS THEN

                  IF (l_debug = 'Y') THEN
                     okc_debug.log('600:');
                  END IF;
                   OKC_API.set_message(p_app_name      => g_app_name,
                            p_msg_name      => g_unexpected_error,
                      p_token1        => g_sqlcode_token,
                            p_token1_value  => sqlcode,
                            p_token2        => g_sqlerrm_token,
                         p_token2_value  => sqlerrm);
            x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END  Validate_item_to_price_source;


   PROCEDURE Validate_recursive_yn (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.recursive_yn) = 'Y' OR
       upper(p_lsev_rec.recursive_yn) = 'N'
    THEN
       IF p_lsev_rec.recursive_yn = 'Y' OR
          p_lsev_rec.recursive_yn = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'recursive_yn');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'recursive_yn');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_recursive_yn;


  PROCEDURE Validate_protected_yn (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
   IF p_lsev_rec.protected_yn IS NULL THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'protected_yn');
       x_return_status := OKC_API.G_RET_STS_ERROR;
   ELSE
    IF upper(p_lsev_rec.protected_yn) = 'Y' OR
       upper(p_lsev_rec.protected_yn) = 'N'
    THEN
       IF p_lsev_rec.protected_yn = 'Y' OR
          p_lsev_rec.protected_yn = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'protected_yn');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'protected_yn');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
   END IF;
  END Validate_protected_yn;

  PROCEDURE Validate_SFWT_Flag (
    x_return_status                OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS
  BEGIN
    IF upper(p_lsev_rec.sfwt_flag) = 'Y' OR
       upper(p_lsev_rec.sfwt_flag) = 'N'
    THEN
       IF p_lsev_rec.sfwt_flag = 'Y' OR
          p_lsev_rec.sfwt_flag = 'N'
       THEN
         x_return_status := OKC_API.G_RET_STS_SUCCESS;
       ELSE
         OKC_API.set_message(G_APP_NAME, G_UPPERCASE_REQUIRED,G_COL_NAME_TOKEN,'SFWT_FLAG');
         x_return_status := OKC_API.G_RET_STS_ERROR;
       END IF;
    ELSE
       OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'SFWT_FLAG');
       x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END Validate_SFWT_Flag;

  PROCEDURE Validate_Name
    (x_return_status	        OUT NOCOPY VARCHAR2,
     p_lsev_rec	        IN	lsev_rec_type) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_lsev_rec.name is not null) AND
       (p_lsev_rec.name <> OKC_API.G_MISS_CHAR) THEN
	   x_return_status := Check_Unique_Name(p_lsev_rec);
    ELSE
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'NAME');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_col_name_token,
                          p_token2_value => 'Name',
                          p_token3       => g_sqlerrm_token,
                          p_token3_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END Validate_Name;

  FUNCTION Validate_Attributes (
    p_lsev_rec IN  lsev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_lsev_rec.id = OKC_API.G_MISS_NUM OR
       p_lsev_rec.id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_lsev_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_lsev_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    Validate_Lty_Code (l_return_status,
                       p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_priced_yn (l_return_status, p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_application_id (l_return_status, p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;


     Validate_item_to_price_yn (l_return_status, p_lsev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

   Validate_price_basis_yn (l_return_status, p_lsev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_item_or_basis (l_return_status,
                       p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_item_to_price_source (l_return_status, p_lsev_rec);


    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_priced_level (l_return_status, p_lsev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_recursive_yn (l_return_status, p_lsev_rec);


    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;

    Validate_protected_yn (l_return_status, p_lsev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
--
    Validate_access_level (l_return_status, p_lsev_rec);

    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
--
    Validate_Lse_Type (l_return_status,
                       p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Lse_Parent_Id (l_return_status,
                            p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_SFWT_Flag (l_return_status,
                        p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
    Validate_Name(l_return_status, p_lsev_rec);
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN  -- need to leave
        x_return_status := l_return_status;
        RAISE G_EXCEPTION_HALT_VALIDATION;
      ELSE
        x_return_status := l_return_status;   -- record that there was an error
      END IF;
    END IF;
  RETURN(x_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(x_return_status);

    WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
      OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);

    -- notify caller of an UNEXPECTED error
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(x_return_status);
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------
  -- Validate_Record for:OKC_LINE_STYLES_V --
  ------------------------------------------
  FUNCTION Validate_Record (
    p_lsev_rec IN lsev_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
   BEGIN
    RETURN (l_return_status);
  END Validate_Record;

 --**** End of Change -------------------------------------------------------

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN lsev_rec_type,
    p_to	IN OUT NOCOPY lse_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.lty_code := p_from.lty_code;
    p_to.priced_yn := p_from.priced_yn;
    p_to.recursive_yn := p_from.recursive_yn;
    p_to.protected_yn := p_from.protected_yn;
    p_to.lse_parent_id := p_from.lse_parent_id;
    p_to.lse_type := p_from.lse_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.application_id := p_from.application_id;
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
    p_to.item_to_price_yn := p_from.item_to_price_yn;
    p_to.price_basis_yn := p_from.price_basis_yn;
    p_to.access_level := p_from.access_level;
    p_to.service_item_yn := p_from.service_item_yn;
   END migrate;
  PROCEDURE migrate (
    p_from	IN lse_rec_type,
    p_to	IN OUT NOCOPY lsev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.lty_code := p_from.lty_code;
    p_to.priced_yn := p_from.priced_yn;
    p_to.recursive_yn := p_from.recursive_yn;
    p_to.protected_yn := p_from.protected_yn;
    p_to.lse_parent_id := p_from.lse_parent_id;
    p_to.lse_type := p_from.lse_type;
    p_to.object_version_number := p_from.object_version_number;
    p_to.application_id := p_from.application_id;
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
    p_to.item_to_price_yn := p_from.item_to_price_yn;
    p_to.price_basis_yn := p_from.price_basis_yn;
    p_to.access_level := p_from.access_level;
    p_to.service_item_yn := p_from.service_item_yn;
  END migrate;


  PROCEDURE migrate (
    p_from	IN lsev_rec_type,
    p_to	IN OUT NOCOPY okc_line_styles_tl_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;
  PROCEDURE migrate (
    p_from	IN okc_line_styles_tl_rec_type,
    p_to	IN OUT NOCOPY lsev_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.sfwt_flag := p_from.sfwt_flag;
    p_to.name := p_from.name;
    p_to.description := p_from.description;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------
  -- validate_row for:OKC_LINE_STYLES_V --
  ----------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                     lsev_rec_type := p_lsev_rec;
    l_lse_rec                      lse_rec_type;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
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
    l_return_status := Validate_Attributes(l_lsev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_lsev_rec);
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
  -- PL/SQL TBL validate_row for:LSEV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsev_tbl.COUNT > 0) THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsev_rec                     => p_lsev_tbl(i));
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  --------------------------------------
  -- insert_row for:OKC_LINE_STYLES_B --
  --------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lse_rec                      IN lse_rec_type,
    x_lse_rec                      OUT NOCOPY lse_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lse_rec                      lse_rec_type := p_lse_rec;
    l_def_lse_rec                  lse_rec_type;
    ------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_lse_rec IN  lse_rec_type,
      x_lse_rec OUT NOCOPY lse_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lse_rec := p_lse_rec;
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
      p_lse_rec,                         -- IN
      l_lse_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_LINE_STYLES_B(
        id,
        lty_code,
        priced_yn,
        RECURSIVE_YN,
        PROTECTED_YN,
        lse_parent_id,
        lse_type,
        object_version_number,
        application_id,
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
        attribute15,
        item_to_price_yn,
        price_basis_yn,
        access_level,
        service_item_yn)
      VALUES (
        l_lse_rec.id,
        l_lse_rec.lty_code,
        l_lse_rec.priced_yn,
        l_lse_rec.RECURSIVE_YN,
        l_lse_rec.PROTECTED_YN,
        l_lse_rec.lse_parent_id,
        l_lse_rec.lse_type,
        l_lse_rec.object_version_number,
        nvl(l_lse_rec.application_id,fnd_global.resp_appl_id),
        l_lse_rec.created_by,
        l_lse_rec.creation_date,
        l_lse_rec.last_updated_by,
        l_lse_rec.last_update_date,
        l_lse_rec.last_update_login,
        l_lse_rec.attribute_category,
        l_lse_rec.attribute1,
        l_lse_rec.attribute2,
        l_lse_rec.attribute3,
        l_lse_rec.attribute4,
        l_lse_rec.attribute5,
        l_lse_rec.attribute6,
        l_lse_rec.attribute7,
        l_lse_rec.attribute8,
        l_lse_rec.attribute9,
        l_lse_rec.attribute10,
        l_lse_rec.attribute11,
        l_lse_rec.attribute12,
        l_lse_rec.attribute13,
        l_lse_rec.attribute14,
        l_lse_rec.attribute15,
        l_lse_rec.item_to_price_yn,
        l_lse_rec.price_basis_yn,
        l_lse_rec.access_level,
        l_lse_rec.service_item_yn);
    -- Set OUT values
    x_lse_rec := l_lse_rec;
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
  ---------------------------------------
  -- insert_row for:OKC_LINE_STYLES_TL --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type,
    x_okc_line_styles_tl_rec       OUT NOCOPY okc_line_styles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type := p_okc_line_styles_tl_rec;
    l_def_okc_line_styles_tl_rec   okc_line_styles_tl_rec_type;
    CURSOR get_languages IS
      SELECT *
        FROM FND_LANGUAGES
       WHERE INSTALLED_FLAG IN ('I', 'B');
    -------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_line_styles_tl_rec IN  okc_line_styles_tl_rec_type,
      x_okc_line_styles_tl_rec OUT NOCOPY okc_line_styles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_line_styles_tl_rec := p_okc_line_styles_tl_rec;
      x_okc_line_styles_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_line_styles_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_line_styles_tl_rec,          -- IN
      l_okc_line_styles_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    FOR l_lang_rec IN get_languages LOOP
      l_okc_line_styles_tl_rec.language := l_lang_rec.language_code;
      INSERT INTO OKC_LINE_STYLES_TL(
          id,
          language,
          source_lang,
          sfwt_flag,
          name,
          description,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login)
        VALUES (
          l_okc_line_styles_tl_rec.id,
          l_okc_line_styles_tl_rec.language,
          l_okc_line_styles_tl_rec.source_lang,
          l_okc_line_styles_tl_rec.sfwt_flag,
          l_okc_line_styles_tl_rec.name,
          l_okc_line_styles_tl_rec.description,
          l_okc_line_styles_tl_rec.created_by,
          l_okc_line_styles_tl_rec.creation_date,
          l_okc_line_styles_tl_rec.last_updated_by,
          l_okc_line_styles_tl_rec.last_update_date,
          l_okc_line_styles_tl_rec.last_update_login);
    END LOOP;
    -- Set OUT values
    x_okc_line_styles_tl_rec := l_okc_line_styles_tl_rec;
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
  --------------------------------------
  -- insert_row for:OKC_LINE_STYLES_V --
  --------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type,
    x_lsev_rec                     OUT NOCOPY lsev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                     lsev_rec_type;
    l_def_lsev_rec                 lsev_rec_type;
    l_lse_rec                      lse_rec_type;
    lx_lse_rec                     lse_rec_type;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
    lx_okc_line_styles_tl_rec      okc_line_styles_tl_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lsev_rec	IN lsev_rec_type
    ) RETURN lsev_rec_type IS
      l_lsev_rec	lsev_rec_type := p_lsev_rec;
    BEGIN
      l_lsev_rec.CREATION_DATE := SYSDATE;
      l_lsev_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_lsev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lsev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lsev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lsev_rec);
    END fill_who_columns;
    ------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_lsev_rec IN  lsev_rec_type,
      x_lsev_rec OUT NOCOPY lsev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsev_rec := p_lsev_rec;
      x_lsev_rec.OBJECT_VERSION_NUMBER := 1;
      x_lsev_rec.SFWT_FLAG := 'N';
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
    l_lsev_rec := null_out_defaults(p_lsev_rec);
    -- Set primary key value
    l_lsev_rec.ID := get_seq_id;
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_lsev_rec,                        -- IN
      l_def_lsev_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lsev_rec := fill_who_columns(l_def_lsev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lsev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lsev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lsev_rec, l_lse_rec);
    migrate(l_def_lsev_rec, l_okc_line_styles_tl_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lse_rec,
      lx_lse_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lse_rec, l_def_lsev_rec);
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_line_styles_tl_rec,
      lx_okc_line_styles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_line_styles_tl_rec, l_def_lsev_rec);
    -- Set OUT values
    x_lsev_rec := l_def_lsev_rec;
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
  -- PL/SQL TBL insert_row for:LSEV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsev_tbl.COUNT > 0) THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsev_rec                     => p_lsev_tbl(i),
          x_lsev_rec                     => x_lsev_tbl(i));
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  ------------------------------------
  -- lock_row for:OKC_LINE_STYLES_B --
  ------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lse_rec                      IN lse_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_lse_rec IN lse_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_LINE_STYLES_B
     WHERE ID = p_lse_rec.id
       AND OBJECT_VERSION_NUMBER = p_lse_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_lse_rec IN lse_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_LINE_STYLES_B
    WHERE ID = p_lse_rec.id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_LINE_STYLES_B.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_LINE_STYLES_B.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_lse_rec);
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
      OPEN lchk_csr(p_lse_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_lse_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_lse_rec.object_version_number THEN
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
  -------------------------------------
  -- lock_row for:OKC_LINE_STYLES_TL --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_okc_line_styles_tl_rec IN okc_line_styles_tl_rec_type) IS
    SELECT *
      FROM OKC_LINE_STYLES_TL
     WHERE ID = p_okc_line_styles_tl_rec.id
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
      OPEN lock_csr(p_okc_line_styles_tl_rec);
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
  ------------------------------------
  -- lock_row for:OKC_LINE_STYLES_V --
  ------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lse_rec                      lse_rec_type;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
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
    migrate(p_lsev_rec, l_lse_rec);
    migrate(p_lsev_rec, l_okc_line_styles_tl_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lse_rec
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
      l_okc_line_styles_tl_rec
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
  -- PL/SQL TBL lock_row for:LSEV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsev_tbl.COUNT > 0) THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsev_rec                     => p_lsev_tbl(i));
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  --------------------------------------
  -- update_row for:OKC_LINE_STYLES_B --
  --------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lse_rec                      IN lse_rec_type,
    x_lse_rec                      OUT NOCOPY lse_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lse_rec                      lse_rec_type := p_lse_rec;
    l_def_lse_rec                  lse_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lse_rec	IN lse_rec_type,
      x_lse_rec	OUT NOCOPY lse_rec_type
    ) RETURN VARCHAR2 IS
      l_lse_rec                      lse_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lse_rec := p_lse_rec;
      -- Get current database values
      l_lse_rec := get_rec(p_lse_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lse_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.id := l_lse_rec.id;
      END IF;
      IF (x_lse_rec.lty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.lty_code := l_lse_rec.lty_code;
      END IF;
      IF (x_lse_rec.priced_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.priced_yn := l_lse_rec.priced_yn;
      END IF;
      IF (x_lse_rec.recursive_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.recursive_yn := l_lse_rec.recursive_yn;
      END IF;
      IF (x_lse_rec.protected_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.protected_yn := l_lse_rec.protected_yn;
      END IF;
      IF (x_lse_rec.lse_parent_id = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.lse_parent_id := l_lse_rec.lse_parent_id;
      END IF;
      IF (x_lse_rec.lse_type = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.lse_type := l_lse_rec.lse_type;
      END IF;
      IF (x_lse_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.object_version_number := l_lse_rec.object_version_number;
      END IF;
      IF (x_lse_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.application_id := l_lse_rec.application_id;
      END IF;
      IF (x_lse_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.created_by := l_lse_rec.created_by;
      END IF;
      IF (x_lse_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lse_rec.creation_date := l_lse_rec.creation_date;
      END IF;
      IF (x_lse_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.last_updated_by := l_lse_rec.last_updated_by;
      END IF;
      IF (x_lse_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lse_rec.last_update_date := l_lse_rec.last_update_date;
      END IF;
      IF (x_lse_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lse_rec.last_update_login := l_lse_rec.last_update_login;
      END IF;
      IF (x_lse_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute_category := l_lse_rec.attribute_category;
      END IF;
      IF (x_lse_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute1 := l_lse_rec.attribute1;
      END IF;
      IF (x_lse_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute2 := l_lse_rec.attribute2;
      END IF;
      IF (x_lse_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute3 := l_lse_rec.attribute3;
      END IF;
      IF (x_lse_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute4 := l_lse_rec.attribute4;
      END IF;
      IF (x_lse_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute5 := l_lse_rec.attribute5;
      END IF;
      IF (x_lse_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute6 := l_lse_rec.attribute6;
      END IF;
      IF (x_lse_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute7 := l_lse_rec.attribute7;
      END IF;
      IF (x_lse_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute8 := l_lse_rec.attribute8;
      END IF;
      IF (x_lse_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute9 := l_lse_rec.attribute9;
      END IF;
      IF (x_lse_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute10 := l_lse_rec.attribute10;
      END IF;
      IF (x_lse_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute11 := l_lse_rec.attribute11;
      END IF;
      IF (x_lse_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute12 := l_lse_rec.attribute12;
      END IF;
      IF (x_lse_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute13 := l_lse_rec.attribute13;
      END IF;
      IF (x_lse_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute14 := l_lse_rec.attribute14;
      END IF;
      IF (x_lse_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.attribute15 := l_lse_rec.attribute15;
      END IF;
      IF (x_lse_rec.item_to_price_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.item_to_price_yn := l_lse_rec.item_to_price_yn ;
      END IF;
      IF (x_lse_rec.price_basis_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.price_basis_yn := l_lse_rec.price_basis_yn;
      END IF;
      IF (x_lse_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.access_level := l_lse_rec.access_level;
      END IF;
      IF (x_lse_rec.service_item_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lse_rec.service_item_yn := l_lse_rec.service_item_yn;
      END IF;
     RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_B --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_lse_rec IN  lse_rec_type,
      x_lse_rec OUT NOCOPY lse_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lse_rec := p_lse_rec;
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
      p_lse_rec,                         -- IN
      l_lse_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lse_rec, l_def_lse_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_LINE_STYLES_B
    SET LTY_CODE = l_def_lse_rec.lty_code,
        PRICED_YN = l_def_lse_rec.PRICED_YN,
        RECURSIVE_YN = l_def_lse_rec.RECURSIVE_YN,
        LSE_PARENT_ID = l_def_lse_rec.lse_parent_id,
        LSE_TYPE = l_def_lse_rec.lse_type,
        OBJECT_VERSION_NUMBER = l_def_lse_rec.object_version_number,
        APPLICATION_ID = l_def_lse_rec.application_id,
        CREATED_BY = l_def_lse_rec.created_by,
        CREATION_DATE = l_def_lse_rec.creation_date,
        LAST_UPDATED_BY = l_def_lse_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_lse_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_lse_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_lse_rec.attribute_category,
        ATTRIBUTE1 = l_def_lse_rec.attribute1,
        ATTRIBUTE2 = l_def_lse_rec.attribute2,
        ATTRIBUTE3 = l_def_lse_rec.attribute3,
        ATTRIBUTE4 = l_def_lse_rec.attribute4,
        ATTRIBUTE5 = l_def_lse_rec.attribute5,
        ATTRIBUTE6 = l_def_lse_rec.attribute6,
        ATTRIBUTE7 = l_def_lse_rec.attribute7,
        ATTRIBUTE8 = l_def_lse_rec.attribute8,
        ATTRIBUTE9 = l_def_lse_rec.attribute9,
        ATTRIBUTE10 = l_def_lse_rec.attribute10,
        ATTRIBUTE11 = l_def_lse_rec.attribute11,
        ATTRIBUTE12 = l_def_lse_rec.attribute12,
        ATTRIBUTE13 = l_def_lse_rec.attribute13,
        ATTRIBUTE14 = l_def_lse_rec.attribute14,
        ATTRIBUTE15 = l_def_lse_rec.attribute15,
        ITEM_TO_PRICE_YN = l_def_lse_rec.item_to_price_yn,
        PRICE_BASIS_YN = l_def_lse_rec.price_basis_yn,
        ACCESS_LEVEL = l_def_lse_rec.access_level,
        SERVICE_ITEM_YN = l_def_lse_rec.service_item_yn
    WHERE ID = l_def_lse_rec.id;

    x_lse_rec := l_def_lse_rec;
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
  ---------------------------------------
  -- update_row for:OKC_LINE_STYLES_TL --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type,
    x_okc_line_styles_tl_rec       OUT NOCOPY okc_line_styles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type := p_okc_line_styles_tl_rec;
    l_def_okc_line_styles_tl_rec   okc_line_styles_tl_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_okc_line_styles_tl_rec	IN okc_line_styles_tl_rec_type,
      x_okc_line_styles_tl_rec	OUT NOCOPY okc_line_styles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_line_styles_tl_rec := p_okc_line_styles_tl_rec;
      -- Get current database values
      l_okc_line_styles_tl_rec := get_rec(p_okc_line_styles_tl_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_okc_line_styles_tl_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_okc_line_styles_tl_rec.id := l_okc_line_styles_tl_rec.id;
      END IF;
      IF (x_okc_line_styles_tl_rec.language = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_line_styles_tl_rec.language := l_okc_line_styles_tl_rec.language;
      END IF;
      IF (x_okc_line_styles_tl_rec.source_lang = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_line_styles_tl_rec.source_lang := l_okc_line_styles_tl_rec.source_lang;
      END IF;
      IF (x_okc_line_styles_tl_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_line_styles_tl_rec.sfwt_flag := l_okc_line_styles_tl_rec.sfwt_flag;
      END IF;
      IF (x_okc_line_styles_tl_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_line_styles_tl_rec.name := l_okc_line_styles_tl_rec.name;
      END IF;
      IF (x_okc_line_styles_tl_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_okc_line_styles_tl_rec.description := l_okc_line_styles_tl_rec.description;
      END IF;
      IF (x_okc_line_styles_tl_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_line_styles_tl_rec.created_by := l_okc_line_styles_tl_rec.created_by;
      END IF;
      IF (x_okc_line_styles_tl_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_line_styles_tl_rec.creation_date := l_okc_line_styles_tl_rec.creation_date;
      END IF;
      IF (x_okc_line_styles_tl_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_okc_line_styles_tl_rec.last_updated_by := l_okc_line_styles_tl_rec.last_updated_by;
      END IF;
      IF (x_okc_line_styles_tl_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_okc_line_styles_tl_rec.last_update_date := l_okc_line_styles_tl_rec.last_update_date;
      END IF;
      IF (x_okc_line_styles_tl_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_okc_line_styles_tl_rec.last_update_login := l_okc_line_styles_tl_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_line_styles_tl_rec IN  okc_line_styles_tl_rec_type,
      x_okc_line_styles_tl_rec OUT NOCOPY okc_line_styles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_line_styles_tl_rec := p_okc_line_styles_tl_rec;
      x_okc_line_styles_tl_rec.LANGUAGE := USERENV('LANG');
      x_okc_line_styles_tl_rec.SOURCE_LANG := USERENV('LANG');
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
      p_okc_line_styles_tl_rec,          -- IN
      l_okc_line_styles_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_okc_line_styles_tl_rec, l_def_okc_line_styles_tl_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_LINE_STYLES_TL
    SET NAME = l_def_okc_line_styles_tl_rec.name,
        DESCRIPTION = l_def_okc_line_styles_tl_rec.description,
        CREATED_BY = l_def_okc_line_styles_tl_rec.created_by,
        CREATION_DATE = l_def_okc_line_styles_tl_rec.creation_date,
        LAST_UPDATED_BY = l_def_okc_line_styles_tl_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_okc_line_styles_tl_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_okc_line_styles_tl_rec.last_update_login
    WHERE ID = l_def_okc_line_styles_tl_rec.id
      AND SOURCE_LANG = USERENV('LANG');

    UPDATE  OKC_LINE_STYLES_TL
    SET SFWT_FLAG = 'Y'
    WHERE ID = l_def_okc_line_styles_tl_rec.id
      AND SOURCE_LANG <> USERENV('LANG');

    x_okc_line_styles_tl_rec := l_def_okc_line_styles_tl_rec;
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
  --------------------------------------
  -- update_row for:OKC_LINE_STYLES_V --
  --------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type,
    x_lsev_rec                     OUT NOCOPY lsev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                     lsev_rec_type := p_lsev_rec;
    l_def_lsev_rec                 lsev_rec_type;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
    lx_okc_line_styles_tl_rec      okc_line_styles_tl_rec_type;
    l_lse_rec                      lse_rec_type;
    lx_lse_rec                     lse_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_lsev_rec	IN lsev_rec_type
    ) RETURN lsev_rec_type IS
      l_lsev_rec	lsev_rec_type := p_lsev_rec;
    BEGIN
      l_lsev_rec.LAST_UPDATE_DATE := SYSDATE;
      l_lsev_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_lsev_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_lsev_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_lsev_rec	IN lsev_rec_type,
      x_lsev_rec	OUT NOCOPY lsev_rec_type
    ) RETURN VARCHAR2 IS
      l_lsev_rec                     lsev_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsev_rec := p_lsev_rec;
      -- Get current database values
      l_lsev_rec := get_rec(p_lsev_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_lsev_rec.id = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.id := l_lsev_rec.id;
      END IF;
      IF (x_lsev_rec.lty_code = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.lty_code := l_lsev_rec.lty_code;
      END IF;
      IF (x_lsev_rec.priced_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.priced_yn := l_lsev_rec.priced_yn;
      END IF;
      IF (x_lsev_rec.recursive_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.recursive_yn := l_lsev_rec.recursive_yn;
      END IF;
      IF (x_lsev_rec.protected_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.protected_yn := l_lsev_rec.protected_yn;
      END IF;
      IF (x_lsev_rec.lse_parent_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.lse_parent_id := l_lsev_rec.lse_parent_id;
      END IF;
      IF (x_lsev_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.object_version_number := l_lsev_rec.object_version_number;
      END IF;
      IF (x_lsev_rec.application_id = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.application_id := l_lsev_rec.application_id;
      END IF;
      IF (x_lsev_rec.sfwt_flag = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.sfwt_flag := l_lsev_rec.sfwt_flag;
      END IF;
      IF (x_lsev_rec.name = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.name := l_lsev_rec.name;
      END IF;
      IF (x_lsev_rec.description = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.description := l_lsev_rec.description;
      END IF;
      IF (x_lsev_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute_category := l_lsev_rec.attribute_category;
      END IF;
      IF (x_lsev_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute1 := l_lsev_rec.attribute1;
      END IF;
      IF (x_lsev_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute2 := l_lsev_rec.attribute2;
      END IF;
      IF (x_lsev_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute3 := l_lsev_rec.attribute3;
      END IF;
      IF (x_lsev_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute4 := l_lsev_rec.attribute4;
      END IF;
      IF (x_lsev_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute5 := l_lsev_rec.attribute5;
      END IF;
      IF (x_lsev_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute6 := l_lsev_rec.attribute6;
      END IF;
      IF (x_lsev_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute7 := l_lsev_rec.attribute7;
      END IF;
      IF (x_lsev_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute8 := l_lsev_rec.attribute8;
      END IF;
      IF (x_lsev_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute9 := l_lsev_rec.attribute9;
      END IF;
      IF (x_lsev_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute10 := l_lsev_rec.attribute10;
      END IF;
      IF (x_lsev_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute11 := l_lsev_rec.attribute11;
      END IF;
      IF (x_lsev_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute12 := l_lsev_rec.attribute12;
      END IF;
      IF (x_lsev_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute13 := l_lsev_rec.attribute13;
      END IF;
      IF (x_lsev_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute14 := l_lsev_rec.attribute14;
      END IF;
      IF (x_lsev_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.attribute15 := l_lsev_rec.attribute15;
      END IF;
      IF (x_lsev_rec.lse_type = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.lse_type := l_lsev_rec.lse_type;
      END IF;
      IF (x_lsev_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.created_by := l_lsev_rec.created_by;
      END IF;
      IF (x_lsev_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsev_rec.creation_date := l_lsev_rec.creation_date;
      END IF;
      IF (x_lsev_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.last_updated_by := l_lsev_rec.last_updated_by;
      END IF;
      IF (x_lsev_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_lsev_rec.last_update_date := l_lsev_rec.last_update_date;
      END IF;
      IF (x_lsev_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_lsev_rec.last_update_login := l_lsev_rec.last_update_login;
      END IF;
      IF (x_lsev_rec.item_to_price_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.item_to_price_yn := l_lsev_rec.item_to_price_yn;
      END IF;
      IF (x_lsev_rec.price_basis_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_lsev_rec.price_basis_yn := l_lsev_rec.price_basis_yn;
      END IF;
     RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_V --
    ------------------------------------------
    FUNCTION Set_Attributes (
      p_lsev_rec IN  lsev_rec_type,
      x_lsev_rec OUT NOCOPY lsev_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_lsev_rec := p_lsev_rec;
-- **** Added the following two lines for uppercasing *********
      x_lsev_rec.SFWT_FLAG := upper(p_lsev_rec.SFWT_FLAG);
      x_lsev_rec.LSE_TYPE := upper(p_lsev_rec.LSE_TYPE);
      x_lsev_rec.OBJECT_VERSION_NUMBER := NVL(x_lsev_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_lsev_rec,                        -- IN
      l_lsev_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_lsev_rec, l_def_lsev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_lsev_rec := fill_who_columns(l_def_lsev_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_lsev_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_lsev_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_lsev_rec, l_okc_line_styles_tl_rec);
    migrate(l_def_lsev_rec, l_lse_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_line_styles_tl_rec,
      lx_okc_line_styles_tl_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_okc_line_styles_tl_rec, l_def_lsev_rec);
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_lse_rec,
      lx_lse_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_lse_rec, l_def_lsev_rec);
    x_lsev_rec := l_def_lsev_rec;
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
  -- PL/SQL TBL update_row for:LSEV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type,
    x_lsev_tbl                     OUT NOCOPY lsev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsev_tbl.COUNT > 0) THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsev_rec                     => p_lsev_tbl(i),
          x_lsev_rec                     => x_lsev_tbl(i));
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
  --------------------------------------
  -- delete_row for:OKC_LINE_STYLES_B --
  --------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lse_rec                      IN lse_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lse_rec                      lse_rec_type:= p_lse_rec;
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
    DELETE FROM OKC_LINE_STYLES_B
     WHERE ID = l_lse_rec.id;

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
  ---------------------------------------
  -- delete_row for:OKC_LINE_STYLES_TL --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_okc_line_styles_tl_rec       IN okc_line_styles_tl_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TL_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type:= p_okc_line_styles_tl_rec;
    l_row_notfound                 BOOLEAN := TRUE;
    -------------------------------------------
    -- Set_Attributes for:OKC_LINE_STYLES_TL --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_okc_line_styles_tl_rec IN  okc_line_styles_tl_rec_type,
      x_okc_line_styles_tl_rec OUT NOCOPY okc_line_styles_tl_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_okc_line_styles_tl_rec := p_okc_line_styles_tl_rec;
      x_okc_line_styles_tl_rec.LANGUAGE := USERENV('LANG');
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
      p_okc_line_styles_tl_rec,          -- IN
      l_okc_line_styles_tl_rec);         -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    DELETE FROM OKC_LINE_STYLES_TL
     WHERE ID = l_okc_line_styles_tl_rec.id;

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
  --------------------------------------
  -- delete_row for:OKC_LINE_STYLES_V --
  --------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_rec                     IN lsev_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_lsev_rec                     lsev_rec_type := p_lsev_rec;
    l_okc_line_styles_tl_rec       okc_line_styles_tl_rec_type;
    l_lse_rec                      lse_rec_type;
    cursor c1(p_id number) is select created_by from OKC_LINE_STYLES_B
    where ID=p_id;
    l_created_by     number:=OKC_API.G_MISS_NUM;
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
    open c1(l_lse_rec.id);
    Fetch c1 into l_created_by;
    close c1;
    --san created_by=1 means its a seeded value so cannot delete
    IF l_created_by=1 then
          OKC_API.set_message(G_APP_NAME,'OKC_NOT_DELETE_SEEDED');
          RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_lsev_rec, l_okc_line_styles_tl_rec);
    migrate(l_lsev_rec, l_lse_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_okc_line_styles_tl_rec
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
      l_lse_rec
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
  -- PL/SQL TBL delete_row for:LSEV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_lsev_tbl                     IN lsev_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_lsev_tbl.COUNT > 0) THEN
      i := p_lsev_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_lsev_rec                     => p_lsev_tbl(i));
        EXIT WHEN (i = p_lsev_tbl.LAST);
        i := p_lsev_tbl.NEXT(i);
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
END OKC_LSE_PVT;

/
