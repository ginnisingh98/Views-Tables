--------------------------------------------------------
--  DDL for Package Body OKC_TAG_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_TAG_PVT" AS
/* $Header: OKCSTAGB.pls 120.0 2005/05/25 19:22:13 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/*+++++++++++++Start of hand code +++++++++++++++++*/
G_UNEXPECTED_ERROR           CONSTANT   varchar2(200) := 'OKC_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN              CONSTANT   varchar2(200) := 'ERROR_MESSAGE';
G_SQLCODE_TOKEN              CONSTANT   varchar2(200) := 'ERROR_CODE';
g_return_status                         varchar2(1)   :=  OKC_API.G_RET_STS_SUCCESS;
/*+++++++++++++End of hand code +++++++++++++++++++*/

  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

  ---------------------------------------------------------------------------
  -- PROCEDURE add_language
  ---------------------------------------------------------------------------
  PROCEDURE add_language IS
  BEGIN
    INSERT INTO OKC_REPORT_TAG_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        MEANING,
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
            B.MEANING,
            B.CREATED_BY,
            B.CREATION_DATE,
            B.LAST_UPDATED_BY,
            B.LAST_UPDATE_DATE,
            B.LAST_UPDATE_LOGIN
        FROM OKC_REPORT_TAG_TL B, FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
         AND B.LANGUAGE = USERENV('LANG')
         AND NOT EXISTS(
                    SELECT NULL
                      FROM OKC_REPORT_TAG_TL T
                     WHERE T.ID = B.ID
                       AND T.LANGUAGE = L.LANGUAGE_CODE
                    );

  END add_language;

-- Start of comments
--
-- Procedure Name  : validate_enabled_flag
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_enabled_flag(p_oper IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
                        p_tagv_rec	  IN	tagv_rec_TYPE) is
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_tagv_rec.enabled_flag in ('Y','N')) then
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    return;
  end if;
  if (p_tagv_rec.enabled_flag is NULL or
	(p_tagv_rec.enabled_flag = OKC_API.G_MISS_CHAR and p_oper = 'I')) then
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'ENABLED_FLAG');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  OKC_API.set_message(G_APP_NAME, G_INVALID_VALUE,G_COL_NAME_TOKEN,'ENABLED_FLAG');
  x_return_status := OKC_API.G_RET_STS_ERROR;
  return;
exception
  when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_enabled_flag;

-- Start of comments
--
-- Procedure Name  : validate_code
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_code(p_oper IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
                        p_tagv_rec	  IN	tagv_rec_TYPE) is
l_dummy varchar2(1) := '?';
cursor c1(n1 number, c2 varchar2, n3 number) is
    select '!'
    from OKC_REPORT_TAG_V
    where xsl_id = n1 and code = c2
    and id <> n3;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;
  if (p_tagv_rec.XSL_ID is NULL or
	(p_tagv_rec.XSL_ID = OKC_API.G_MISS_NUM and p_oper = 'I')) then
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'XSL_ID');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  if (p_tagv_rec.code is NULL or
	(p_tagv_rec.code = OKC_API.G_MISS_CHAR and p_oper = 'I')) then
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'CODE');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
    open c1(p_tagv_rec.XSL_ID,p_tagv_rec.CODE,p_tagv_rec.id);
    fetch c1 into l_dummy;
    close c1;
    if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			  p_msg_name      =>  OKC_UTIL.G_UNQ,
                          p_token1        =>  OKC_API.G_COL_NAME_TOKEN,
			  p_token1_value  =>  'CODE');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
exception
  when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_code;

-- Start of comments
--
-- Procedure Name  : validate_meaning
-- Description     :
-- Business Rules  :
-- Parameters      :
-- Version         : 1.0
-- End of comments
procedure validate_meaning(p_oper IN VARCHAR2,
			x_return_status OUT NOCOPY VARCHAR2,
                        p_tagv_rec	  IN	tagv_rec_TYPE) is
l_dummy varchar2(1) := '?';
cursor c1(n1 number, c2 varchar2, n3 number) is
    select '!'
    from OKC_REPORT_TAG_V
    where xsl_id = n1 and meaning = c2
    and id <> n3;
begin
  x_return_status := OKC_API.G_RET_STS_SUCCESS;

  if (p_tagv_rec.XSL_ID is NULL or
	(p_tagv_rec.XSL_ID = OKC_API.G_MISS_NUM and p_oper = 'I')) then
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
  if (p_tagv_rec.meaning is NULL or
	(p_tagv_rec.meaning = OKC_API.G_MISS_CHAR and p_oper = 'I')) then
    OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'MEANING');
    x_return_status := OKC_API.G_RET_STS_ERROR;
    return;
  end if;
    open c1(p_tagv_rec.XSL_ID,p_tagv_rec.MEANING,p_tagv_rec.id);
    fetch c1 into l_dummy;
    close c1;
    if (l_dummy = '!') then
      OKC_API.SET_MESSAGE(p_app_name      =>  G_APP_NAME,
			  p_msg_name      =>  OKC_UTIL.G_UNQ,
                          p_token1        =>  OKC_API.G_COL_NAME_TOKEN,
			  p_token1_value  =>  'MEANING');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
exception
  when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
end validate_meaning;

FUNCTION Validate_Attributes (p_oper IN varchar2,
    p_tagv_rec IN  tagv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status  varchar2(1) := OKC_API.G_RET_STS_SUCCESS;
BEGIN

    validate_enabled_flag(p_oper => p_oper, x_return_status => l_return_status, p_tagv_rec => p_tagv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    validate_code(p_oper => p_oper, x_return_status => l_return_status, p_tagv_rec => p_tagv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    validate_meaning(p_oper => p_oper, x_return_status => l_return_status, p_tagv_rec => p_tagv_rec);
    if (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) then
      return OKC_API.G_RET_STS_UNEXP_ERROR;
    end if;
    if (l_return_status = OKC_API.G_RET_STS_ERROR
        and x_return_status = OKC_API.G_RET_STS_SUCCESS) then
        x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    return x_return_status;
  exception
    when OTHERS then
    OKC_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_unexpected_error,
                        p_token1       => g_sqlcode_token,
                        p_token1_value => sqlcode,
                        p_token2       => g_sqlerrm_token,
                        p_token2_value => sqlerrm);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      return x_return_status;
  END Validate_Attributes;

  ---------------------------------------------------------------------------
  -- PROCEDURE insert_row
  ---------------------------------------------------------------------------

  PROCEDURE date_xsl(p_xsl_id IN NUMBER) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR  xsl_csr (p IN NUMBER) IS
    SELECT '!' FROM OKC_REPORT_XSL_B
    WHERE ID = p FOR UPDATE OF LAST_UPDATE_DATE;
    l_dummy varchar2(1) := '?';

  begin
    open xsl_csr(p_xsl_id);
    fetch xsl_csr into l_dummy;
    close xsl_csr;
    update okc_report_xsl_b set LAST_UPDATE_DATE = sysdate
    where id = p_xsl_id;
  EXCEPTION
    WHEN E_Resource_Busy THEN
      IF (xsl_csr%ISOPEN) THEN
         CLOSE xsl_csr;
      END IF;
      OKC_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
      RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
  end;

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tagv_rec                     IN tagv_rec_type,
    x_tagv_rec                     OUT NOCOPY tagv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tagv_rec                     tagv_rec_type;

  begin

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

    l_tagv_rec.ID 			:= get_seq_id;
    l_tagv_rec.XSL_ID 			:= p_tagv_rec.XSL_ID;
    l_tagv_rec.CODE 			:= p_tagv_rec.CODE;
    l_tagv_rec.MEANING 			:= p_tagv_rec.MEANING;
    l_tagv_rec.ENABLED_FLAG 		:= p_tagv_rec.ENABLED_FLAG;
    l_tagv_rec.OBJECT_VERSION_NUMBER 	:= 1;
    l_tagv_rec.CREATED_BY 		:= FND_GLOBAL.USER_ID;
    l_tagv_rec.CREATION_DATE 		:= SYSDATE;
    l_tagv_rec.LAST_UPDATED_BY 		:= FND_GLOBAL.USER_ID;
    l_tagv_rec.LAST_UPDATE_DATE 	:= SYSDATE;
    l_tagv_rec.LAST_UPDATE_LOGIN 	:= FND_GLOBAL.LOGIN_ID;

    l_return_status := Validate_Attributes('I',l_tagv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    insert into OKC_REPORT_TAG_B
    (
	 ID
	 ,XSL_ID
	 ,CODE
	 ,ENABLED_FLAG
	 ,OBJECT_VERSION_NUMBER
	 ,CREATED_BY
	 ,CREATION_DATE
	 ,LAST_UPDATED_BY
	 ,LAST_UPDATE_DATE
	 ,LAST_UPDATE_LOGIN
    ) values
    (
	 l_tagv_rec.ID
	 ,l_tagv_rec.XSL_ID
	 ,l_tagv_rec.CODE
	 ,l_tagv_rec.ENABLED_FLAG
	 ,l_tagv_rec.OBJECT_VERSION_NUMBER
	 ,l_tagv_rec.CREATED_BY
	 ,l_tagv_rec.CREATION_DATE
	 ,l_tagv_rec.LAST_UPDATED_BY
	 ,l_tagv_rec.LAST_UPDATE_DATE
	 ,l_tagv_rec.LAST_UPDATE_LOGIN
    );

    INSERT INTO OKC_REPORT_TAG_TL (
        ID,
        LANGUAGE,
        SOURCE_LANG,
        SFWT_FLAG,
        MEANING,
        CREATED_BY,
        CREATION_DATE,
        LAST_UPDATED_BY,
        LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN)
      SELECT
  	    l_tagv_rec.ID,
            L.LANGUAGE_CODE,
            USERENV('LANG'),
            decode(L.LANGUAGE_CODE,USERENV('LANG'),'N','Y'),
  	    l_tagv_rec.MEANING,
 	    l_tagv_rec.CREATED_BY,
	    l_tagv_rec.CREATION_DATE,
	    l_tagv_rec.LAST_UPDATED_BY,
	    l_tagv_rec.LAST_UPDATE_DATE,
	    l_tagv_rec.LAST_UPDATE_LOGIN
        FROM FND_LANGUAGES L
       WHERE L.INSTALLED_FLAG IN ('I', 'B')
     ;
    date_xsl(l_tagv_rec.XSL_ID);
    x_tagv_rec := l_tagv_rec;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE lock_row
  ---------------------------------------------------------------------------

  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tagv_rec                     IN tagv_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_tagv_rec IN tagv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_REPORT_TAG_V
     WHERE ID = p_tagv_rec.id
       AND OBJECT_VERSION_NUMBER =
         decode(p_tagv_rec.object_version_number,NULL,OBJECT_VERSION_NUMBER,
			OKC_API.G_MISS_NUM,OBJECT_VERSION_NUMBER,p_tagv_rec.object_version_number)
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_tagv_rec IN tagv_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_REPORT_TAG_B
    WHERE ID = p_tagv_rec.id;

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    l_object_version_number       NUMBER;
    lc_object_version_number      NUMBER;
    l_row_notfound                BOOLEAN := FALSE;
    lc_row_notfound               BOOLEAN := FALSE;

  BEGIN
    x_return_status := 'S';
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
      OPEN lock_csr(p_tagv_rec);
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
      OPEN lchk_csr(p_tagv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
      IF (lc_row_notfound) THEN
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      ELSE
        OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
        RAISE OKC_API.G_EXCEPTION_ERROR;
      END IF;
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

  ---------------------------------------------------------------------------
  -- PROCEDURE update_row
  ---------------------------------------------------------------------------

  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tagv_rec                     IN tagv_rec_type,
    x_tagv_rec                     OUT NOCOPY tagv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_tagv_rec                     tagv_rec_type := p_tagv_rec;

  begin

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

    lock_row(p_init_msg_list => 'F',
	    x_return_status => l_return_status,
	    x_msg_count     => x_msg_count,
	    x_msg_data      => x_msg_data,
	    p_tagv_rec      => p_tagv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    l_tagv_rec.ID 			:= p_tagv_rec.ID;
    select
	 XSL_ID
	,CODE
	,MEANING
	,ENABLED_FLAG
	,OBJECT_VERSION_NUMBER+1
        ,created_by
        ,creation_date
    into
	 l_tagv_rec.XSL_ID
	,l_tagv_rec.CODE
	,l_tagv_rec.MEANING
	,l_tagv_rec.ENABLED_FLAG
	,l_tagv_rec.OBJECT_VERSION_NUMBER
        ,l_tagv_rec.created_by
        ,l_tagv_rec.creation_date
    from OKC_REPORT_TAG_V
    where ID = l_tagv_rec.ID;

    l_tagv_rec.LAST_UPDATED_BY 		:= FND_GLOBAL.USER_ID;
    l_tagv_rec.LAST_UPDATE_DATE 	:= SYSDATE;
    l_tagv_rec.LAST_UPDATE_LOGIN 	:= FND_GLOBAL.LOGIN_ID;


    if (p_tagv_rec.XSL_ID is NULL or p_tagv_rec.XSL_ID <> OKC_API.G_MISS_NUM) then
	l_tagv_rec.XSL_ID 			:= p_tagv_rec.XSL_ID;
    end if;
    if (p_tagv_rec.CODE is NULL or p_tagv_rec.CODE <> OKC_API.G_MISS_CHAR) then
	l_tagv_rec.CODE 			:= p_tagv_rec.CODE;
    end if;
    if (p_tagv_rec.MEANING is NULL or p_tagv_rec.MEANING <> OKC_API.G_MISS_CHAR) then
	l_tagv_rec.MEANING 			:= p_tagv_rec.MEANING;
    end if;
    if (p_tagv_rec.ENABLED_FLAG is NULL or p_tagv_rec.ENABLED_FLAG <> OKC_API.G_MISS_CHAR) then
	l_tagv_rec.ENABLED_FLAG 			:= p_tagv_rec.ENABLED_FLAG;
    end if;

    l_return_status := Validate_Attributes('U',l_tagv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    UPDATE OKC_REPORT_TAG_B set
	 XSL_ID = l_tagv_rec.XSL_ID
	 ,CODE = l_tagv_rec.CODE
	 ,ENABLED_FLAG = l_tagv_rec.ENABLED_FLAG
	 ,OBJECT_VERSION_NUMBER = l_tagv_rec.OBJECT_VERSION_NUMBER
	 ,LAST_UPDATED_BY = l_tagv_rec.LAST_UPDATED_BY
	 ,LAST_UPDATE_DATE = l_tagv_rec.LAST_UPDATE_DATE
	 ,LAST_UPDATE_LOGIN = l_tagv_rec.LAST_UPDATE_LOGIN
    where ID = l_tagv_rec.ID;

    UPDATE OKC_REPORT_TAG_TL set
	 SOURCE_LANG = USERENV('LANG')
         ,SFWT_FLAG = decode(LANGUAGE,USERENV('LANG'),'N','Y')
         ,MEANING = l_tagv_rec.MEANING
	 ,LAST_UPDATED_BY = l_tagv_rec.LAST_UPDATED_BY
	 ,LAST_UPDATE_DATE = l_tagv_rec.LAST_UPDATE_DATE
	 ,LAST_UPDATE_LOGIN = l_tagv_rec.LAST_UPDATE_LOGIN
    where ID = l_tagv_rec.ID
      and USERENV('LANG') in (LANGUAGE, SOURCE_LANG);

    date_xsl(l_tagv_rec.XSL_ID);
    x_tagv_rec := l_tagv_rec;
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


  ---------------------------------------------------------------------------
  -- PROCEDURE delete_row
  ---------------------------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_tagv_rec                     IN tagv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

    cursor xsl_csr(p NUMBER) is
    select S.id
    from okc_report_tag_v TAG, okc_report_xsl_v S
    where TAG.id = p and S.id = TAG.xsl_id;

    l_xsl_id NUMBER;

  begin

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

    lock_row(p_init_msg_list => 'F',
	    x_return_status => l_return_status,
	    x_msg_count     => x_msg_count,
	    x_msg_data      => x_msg_data,
	    p_tagv_rec      => p_tagv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    delete
    from OKC_REPORT_TAG_B
    where ID = p_tagv_rec.ID;

    delete
    from OKC_REPORT_TAG_TL
    where ID = p_tagv_rec.ID;

    open xsl_csr(p_tagv_rec.ID);
    fetch xsl_csr into l_xsl_id;
    close xsl_csr;
    if (l_xsl_id is not null) then
      date_xsl(l_xsl_id);
    end if;

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

END OKC_TAG_PVT;

/
