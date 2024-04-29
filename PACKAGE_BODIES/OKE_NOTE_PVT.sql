--------------------------------------------------------
--  DDL for Package Body OKE_NOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_NOTE_PVT" AS
/* $Header: OKEVNOTB.pls 115.17 2002/11/20 20:42:23 who ship $ */

-- validate record

  FUNCTION validate_record (
    p_note_rec IN note_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate individual attributes

  FUNCTION validate_attributes(
    p_note_rec IN  note_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;



  PROCEDURE validate_k_header_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_note_rec   IN  note_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_HEADERS
	WHERE K_HEADER_ID = p_note_rec.K_HEADER_ID;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_note_rec.k_header_id = OKE_API.G_MISS_NUM
     	OR     p_note_rec.k_header_id IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'K_HEADER_ID');

		x_return_status := OKE_API.G_RET_STS_ERROR;
		raise G_EXCEPTION_HALT_VALIDATION;
	END IF;


    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'K_HEADER_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_K_HEADERS');

      		x_return_status := OKE_API.G_RET_STS_ERROR;
    		END IF;



    EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
	NULL;
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
    x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;

    END validate_k_header_id;


  PROCEDURE validate_k_line_id(x_return_status OUT NOCOPY  VARCHAR2,
			      p_note_rec   IN  note_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_LINES
	WHERE K_LINE_ID = p_note_rec.K_LINE_ID;

   BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;

	IF (   p_note_rec.k_line_id <> OKE_API.G_MISS_NUM
     	AND p_note_rec.k_line_id IS NOT NULL) THEN

    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'K_LINE_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_K_LINES');

      		x_return_status := OKE_API.G_RET_STS_ERROR;
    		END IF;
  	END IF;


    EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
    x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;

    END validate_k_line_id;


  PROCEDURE validate_deliverable_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_note_rec   IN  note_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_DELIVERABLES_B
	WHERE DELIVERABLE_ID = p_note_rec.DELIVERABLE_ID;

    BEGIN
	x_return_status := OKE_API.G_RET_STS_SUCCESS;
	IF (   p_note_rec.deliverable_id <> OKE_API.G_MISS_NUM
     	AND p_note_rec.deliverable_id IS NOT NULL) THEN

    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'DELIVERABLE_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_K_DELIVERABLES_B');

      		x_return_status := OKE_API.G_RET_STS_ERROR;
    		END IF;
  	END IF;


    EXCEPTION
    WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKE_API.SET_MESSAGE(
		p_app_name		=>g_app_name,
		p_msg_name		=>G_UNEXPECTED_ERROR,
		p_token1		=>G_SQLCODE_TOKEN,
		p_token1_value		=>SQLCODE,
		p_token2		=>G_SQLERRM_TOKEN,
		p_token2_value		=>SQLERRM);
    x_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;

    IF l_csr%ISOPEN THEN
      CLOSE l_csr;
    END IF;
    END validate_deliverable_id;


  BEGIN

  validate_k_header_id (x_return_status => l_return_status,
			      p_note_rec	 =>  p_note_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_k_line_id (x_return_status => l_return_status,
			      p_note_rec	 =>  p_note_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_deliverable_id (x_return_status => l_return_status,
			      p_note_rec	 =>  p_note_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


    /* call individual validation procedure */
	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;

  FUNCTION null_out_defaults(
	 p_note_rec	IN note_rec_type ) RETURN note_rec_type IS

  l_note_rec note_rec_type := p_note_rec;

  BEGIN


    IF  l_note_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
	l_note_rec.K_HEADER_ID := NULL;
    END IF;

    IF  l_note_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	l_note_rec.K_LINE_ID := NULL;
    END IF;

    IF  l_note_rec.DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
	l_note_rec.DELIVERABLE_ID := NULL;
    END IF;

    IF  l_note_rec.TYPE_CODE = OKE_API.G_MISS_CHAR THEN
	l_note_rec.TYPE_CODE := NULL;
    END IF;

    IF  l_note_rec.default_flag = OKE_API.G_MISS_CHAR THEN
	l_note_rec.default_flag := NULL;
    END IF;


    IF  l_note_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF  l_note_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_note_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF	l_note_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_note_rec.CREATED_BY := NULL;
    END IF;

    IF	l_note_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_note_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_note_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_note_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_note_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_note_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_note_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_note_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    IF	l_note_rec.SFWT_FLAG = OKE_API.G_MISS_CHAR THEN
	l_note_rec.SFWT_FLAG := NULL;
    END IF;

    IF	l_note_rec.DESCRIPTION = OKE_API.G_MISS_CHAR THEN
	l_note_rec.DESCRIPTION := NULL;
    END IF;

    IF	l_note_rec.NAME = OKE_API.G_MISS_CHAR THEN
	l_note_rec.NAME := NULL;
    END IF;

    IF	l_note_rec.TEXT = OKE_API.G_MISS_CHAR THEN
	l_note_rec.TEXT := NULL;
    END IF;


    RETURN(l_note_rec);

  END null_out_defaults;


  FUNCTION get_rec (
    p_note_rec                      IN note_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN note_rec_type IS

    CURSOR note_pk_csr (p_id                 IN NUMBER) IS
    SELECT
		STANDARD_NOTES_ID		,
		CREATION_DATE			,
		CREATED_BY			,
		LAST_UPDATE_DATE		,
		LAST_UPDATED_BY			,
		LAST_UPDATE_LOGIN		,
		K_HEADER_ID			,
		K_LINE_ID			,
		DELIVERABLE_ID			,
		TYPE_CODE			,
		ATTRIBUTE_CATEGORY		,
		ATTRIBUTE1			,
		ATTRIBUTE2			,
		ATTRIBUTE3			,
		ATTRIBUTE4			,
		ATTRIBUTE5			,
		ATTRIBUTE6			,
		ATTRIBUTE7			,
		ATTRIBUTE8			,
		ATTRIBUTE9			,
		ATTRIBUTE10			,
		ATTRIBUTE11			,
		ATTRIBUTE12			,
		ATTRIBUTE13			,
		ATTRIBUTE14			,
		ATTRIBUTE15			,
		default_flag
    FROM OKE_K_STANDARD_NOTES_B
    WHERE OKE_K_STANDARD_NOTES_B.STANDARD_NOTES_ID = p_id;

    CURSOR note_pk_csr2 (p_id                 IN NUMBER) IS
    SELECT
		SFWT_FLAG	,
		DESCRIPTION	,
		NAME		,
		TEXT
    FROM OKE_K_STANDARD_NOTES_TL
    WHERE OKE_K_STANDARD_NOTES_TL.STANDARD_NOTES_ID = p_id;


    l_note_pk	note_pk_csr%ROWTYPE;
    l_note_rec   note_rec_type;

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value


    OPEN note_pk_csr(p_note_rec.STANDARD_NOTES_ID);
    FETCH note_pk_csr INTO
		l_note_rec.STANDARD_NOTES_ID		,
		l_note_rec.CREATION_DATE		,
		l_note_rec.CREATED_BY			,
		l_note_rec.LAST_UPDATE_DATE		,
		l_note_rec.LAST_UPDATED_BY		,
		l_note_rec.LAST_UPDATE_LOGIN		,
		l_note_rec.K_HEADER_ID			,
		l_note_rec.K_LINE_ID			,
		l_note_rec.DELIVERABLE_ID		,
		l_note_rec.TYPE_CODE			,
		l_note_rec.ATTRIBUTE_CATEGORY		,
		l_note_rec.ATTRIBUTE1			,
		l_note_rec.ATTRIBUTE2			,
		l_note_rec.ATTRIBUTE3			,
		l_note_rec.ATTRIBUTE4			,
		l_note_rec.ATTRIBUTE5			,
		l_note_rec.ATTRIBUTE6			,
		l_note_rec.ATTRIBUTE7			,
		l_note_rec.ATTRIBUTE8			,
		l_note_rec.ATTRIBUTE9			,
		l_note_rec.ATTRIBUTE10			,
		l_note_rec.ATTRIBUTE11			,
		l_note_rec.ATTRIBUTE12			,
		l_note_rec.ATTRIBUTE13			,
		l_note_rec.ATTRIBUTE14			,
		l_note_rec.ATTRIBUTE15			,
		l_note_rec.default_flag			;

    x_no_data_found := note_pk_csr%NOTFOUND;

    CLOSE note_pk_csr;

	IF(x_no_data_found) THEN
	RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    OPEN note_pk_csr2(p_note_rec.STANDARD_NOTES_ID);
    FETCH note_pk_csr2 INTO
		l_note_rec.SFWT_FLAG	,
		l_note_rec.DESCRIPTION	,
		l_note_rec.NAME		,
		l_note_rec.TEXT		;

    x_no_data_found := note_pk_csr2%NOTFOUND;

    CLOSE note_pk_csr2;

	IF(x_no_data_found) THEN
	RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;

    RETURN(l_note_rec);

  END get_rec;



	-- row level insert

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec                      IN note_rec_type,
    x_note_rec                      OUT NOCOPY note_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_note_rec                      note_rec_type;
    l_def_note_rec                  note_rec_type;
    lx_note_rec                     note_rec_type;
    l_seq			   NUMBER;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_note_rec	IN note_rec_type
    ) RETURN note_rec_type IS

      l_note_rec	note_rec_type := p_note_rec;

    BEGIN

      l_note_rec.CREATION_DATE := SYSDATE;
      l_note_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_note_rec.LAST_UPDATE_DATE := SYSDATE;
      l_note_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_note_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_note_rec);

    END fill_who_columns;



    FUNCTION Set_Attributes (
      p_note_rec IN  note_rec_type,
      x_note_rec OUT NOCOPY note_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
	x_note_rec := p_note_rec;
	x_note_rec.SFWT_FLAG := UPPER(x_note_rec.SFWT_FLAG);
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- insert

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_note_rec := null_out_defaults(p_note_rec);



    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_note_rec,                        -- IN
      l_def_note_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_note_rec := fill_who_columns(l_def_note_rec);



    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_note_rec);


    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Validate_Record(l_def_note_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    SELECT OKE_K_STANDARD_NOTES_S.nextval  INTO l_seq FROM dual;

    INSERT INTO OKE_K_STANDARD_NOTES_B(

	STANDARD_NOTES_ID    ,
 	CREATION_DATE        ,
 	CREATED_BY           ,
 	LAST_UPDATE_DATE     ,
 	LAST_UPDATED_BY      ,
 	LAST_UPDATE_LOGIN    ,
 	K_HEADER_ID          ,
 	K_LINE_ID            ,
 	DELIVERABLE_ID       ,
 	TYPE_CODE            ,
 	ATTRIBUTE_CATEGORY   ,
 	ATTRIBUTE1           ,
 	ATTRIBUTE2           ,
 	ATTRIBUTE3           ,
 	ATTRIBUTE4           ,
 	ATTRIBUTE5           ,
 	ATTRIBUTE6           ,
 	ATTRIBUTE7           ,
 	ATTRIBUTE8           ,
 	ATTRIBUTE9           ,
 	ATTRIBUTE10          ,
 	ATTRIBUTE11          ,
 	ATTRIBUTE12          ,
 	ATTRIBUTE13          ,
 	ATTRIBUTE14          ,
 	ATTRIBUTE15	     ,
	default_flag
	)
    VALUES(

	l_seq,
 	l_def_note_rec.CREATION_DATE        ,
 	l_def_note_rec.CREATED_BY           ,
 	l_def_note_rec.LAST_UPDATE_DATE     ,
 	l_def_note_rec.LAST_UPDATED_BY      ,
 	l_def_note_rec.LAST_UPDATE_LOGIN    ,
 	l_def_note_rec.K_HEADER_ID          ,
 	l_def_note_rec.K_LINE_ID            ,
 	l_def_note_rec.DELIVERABLE_ID       ,
 	l_def_note_rec.TYPE_CODE            ,
 	l_def_note_rec.ATTRIBUTE_CATEGORY   ,
 	l_def_note_rec.ATTRIBUTE1           ,
 	l_def_note_rec.ATTRIBUTE2           ,
 	l_def_note_rec.ATTRIBUTE3           ,
 	l_def_note_rec.ATTRIBUTE4           ,
 	l_def_note_rec.ATTRIBUTE5           ,
 	l_def_note_rec.ATTRIBUTE6           ,
 	l_def_note_rec.ATTRIBUTE7           ,
 	l_def_note_rec.ATTRIBUTE8           ,
 	l_def_note_rec.ATTRIBUTE9           ,
 	l_def_note_rec.ATTRIBUTE10          ,
 	l_def_note_rec.ATTRIBUTE11          ,
 	l_def_note_rec.ATTRIBUTE12          ,
 	l_def_note_rec.ATTRIBUTE13          ,
 	l_def_note_rec.ATTRIBUTE14          ,
 	l_def_note_rec.ATTRIBUTE15          ,
	l_def_note_rec.default_flag
	);

     INSERT INTO OKE_K_STANDARD_NOTES_TL(
 	STANDARD_NOTES_ID    ,
	LANGUAGE             ,
 	CREATION_DATE        ,
 	CREATED_BY           ,
 	LAST_UPDATE_DATE     ,
 	LAST_UPDATED_BY      ,
 	LAST_UPDATE_LOGIN    ,
 	SOURCE_LANG          ,
 	SFWT_FLAG            ,
 	DESCRIPTION          ,
 	NAME                 ,
 	TEXT
	)
	SELECT
	l_seq    ,
	L.language_code                     ,
 	l_def_note_rec.CREATION_DATE        ,
 	l_def_note_rec.CREATED_BY           ,
 	l_def_note_rec.LAST_UPDATE_DATE     ,
 	l_def_note_rec.LAST_UPDATED_BY      ,
 	l_def_note_rec.LAST_UPDATE_LOGIN    ,
 	oke_utils.get_userenv_lang          ,
 	l_def_note_rec.SFWT_FLAG            ,
 	l_def_note_rec.DESCRIPTION          ,
 	l_def_note_rec.NAME                 ,
 	l_def_note_rec.TEXT
        FROM fnd_languages L
	WHERE L.INSTALLED_FLAG in ('I', 'B')
	AND NOT EXISTS
	  (select NULL
	   from OKE_K_STANDARD_NOTES_TL T
	   where T.STANDARD_NOTES_ID = l_seq
	   and T.LANGUAGE = L.LANGUAGE_CODE);


    -- Set OUT values
    x_note_rec := l_def_note_rec;
    x_note_rec.STANDARD_NOTES_ID := l_seq;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;   -- row level




	-- table level insert

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                      IN note_tbl_type,
    x_note_tbl                      OUT NOCOPY note_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_note_tbl.COUNT > 0) THEN
      i := p_note_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_note_rec                      => p_note_tbl(i),
          x_note_rec                      => x_note_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_note_tbl.LAST);

        i := p_note_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row; -- table level








  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec                      IN note_rec_type,
    x_note_rec                      OUT NOCOPY note_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_note_rec                      note_rec_type := p_note_rec;
    l_def_note_rec                  note_rec_type;
    lx_note_rec                     note_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_note_rec	IN note_rec_type
    ) RETURN note_rec_type IS

      l_note_rec	note_rec_type := p_note_rec;

    BEGIN
      l_note_rec.LAST_UPDATE_DATE := SYSDATE;
      l_note_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_note_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_note_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_note_rec	IN note_rec_type,
      x_note_rec	OUT NOCOPY note_rec_type
    ) RETURN VARCHAR2 IS

      l_note_rec                     note_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN

      x_note_rec := p_note_rec;


      -- Get current database values
      l_note_rec := get_rec(p_note_rec, l_row_notfound);


      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;


-- this is key
--????????????????????????????????????????
--	IF x_note_rec.STANDARD_NOTES_ID = OKE_API.G_MISS_NUM THEN
--	  x_note_rec.STANDARD_NOTES_ID := l_note_rec.STANDARD_NOTES_ID;
--    	END IF;

	IF x_note_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	  x_note_rec.CREATION_DATE := l_note_rec.CREATION_DATE;
    	END IF;

	IF x_note_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	  x_note_rec.CREATED_BY := l_note_rec.CREATED_BY;
    	END IF;

	IF x_note_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	  x_note_rec.LAST_UPDATE_DATE := l_note_rec.LAST_UPDATE_DATE;
    	END IF;

	IF x_note_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	  x_note_rec.LAST_UPDATED_BY  := l_note_rec.LAST_UPDATED_BY ;
    	END IF;

	IF x_note_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	  x_note_rec.LAST_UPDATE_LOGIN := l_note_rec.LAST_UPDATE_LOGIN;
    	END IF;

	IF x_note_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
	  x_note_rec.K_HEADER_ID := l_note_rec.K_HEADER_ID;
    	END IF;

	IF x_note_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	  x_note_rec.K_LINE_ID := l_note_rec.K_LINE_ID;
    	END IF;

	IF x_note_rec.DELIVERABLE_ID = OKE_API.G_MISS_NUM THEN
	  x_note_rec.DELIVERABLE_ID := l_note_rec.DELIVERABLE_ID;
    	END IF;

	IF x_note_rec.TYPE_CODE = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.TYPE_CODE := l_note_rec.TYPE_CODE;
    	END IF;

	IF x_note_rec.default_flag = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.default_flag := l_note_rec.default_flag;
    	END IF;

	IF x_note_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE_CATEGORY := l_note_rec.ATTRIBUTE_CATEGORY;
    	END IF;

	IF x_note_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE1 := l_note_rec.ATTRIBUTE1;
    	END IF;

	IF x_note_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE2 := l_note_rec.ATTRIBUTE2;
    	END IF;

	IF x_note_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE3 := l_note_rec.ATTRIBUTE3;
    	END IF;

	IF x_note_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE4 := l_note_rec.ATTRIBUTE4;
    	END IF;

	IF x_note_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE5 := l_note_rec.ATTRIBUTE5;
    	END IF;

	IF x_note_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE6 := l_note_rec.ATTRIBUTE6;
    	END IF;

	IF x_note_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE7 := l_note_rec.ATTRIBUTE7;
    	END IF;

 	IF x_note_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE8 := l_note_rec.ATTRIBUTE8;
    	END IF;

	IF x_note_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE9 := l_note_rec.ATTRIBUTE9;
    	END IF;

	IF x_note_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE10 := l_note_rec.ATTRIBUTE10;
    	END IF;

	IF x_note_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE11 := l_note_rec.ATTRIBUTE11;
    	END IF;

	IF x_note_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE12 := l_note_rec.ATTRIBUTE12;
    	END IF;

	IF x_note_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE13 := l_note_rec.ATTRIBUTE13;
    	END IF;

	IF x_note_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE14 := l_note_rec.ATTRIBUTE14;
    	END IF;

	IF x_note_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	  x_note_rec.ATTRIBUTE15 := l_note_rec.ATTRIBUTE15;
    	END IF;


    RETURN(l_return_status);



  END populate_new_record;




  FUNCTION set_attributes(
	      p_note_rec IN  note_rec_type,
              x_note_rec OUT NOCOPY note_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN

      x_note_rec := p_note_rec;
      x_note_rec.SFWT_FLAG		:= UPPER(x_note_rec.SFWT_FLAG);
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- update row


    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              G_PKG_NAME,
                                              p_init_msg_list,
                                              l_api_version,
                                              p_api_version,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := Set_Attributes(
      p_note_rec,                        -- IN
      l_note_rec);                       -- OUT



    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;



    l_return_status := populate_new_record(l_note_rec, l_def_note_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_def_note_rec := fill_who_columns(l_def_note_rec);


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_note_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_note_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    UPDATE OKE_K_STANDARD_NOTES_B
    SET
	CREATION_DATE	= l_def_note_rec.CREATION_DATE,
	CREATED_BY = l_def_note_rec.CREATED_BY,
	LAST_UPDATE_DATE = l_def_note_rec.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = l_def_note_rec.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = l_def_note_rec.LAST_UPDATE_LOGIN,
	K_HEADER_ID = l_def_note_rec.K_HEADER_ID,
	K_LINE_ID = l_def_note_rec.K_LINE_ID,
	DELIVERABLE_ID = l_def_note_rec.DELIVERABLE_ID,
	TYPE_CODE = l_def_note_rec.TYPE_CODE,
	ATTRIBUTE_CATEGORY = l_def_note_rec.ATTRIBUTE_CATEGORY,
	ATTRIBUTE1 = l_def_note_rec.ATTRIBUTE1,
	ATTRIBUTE2 = l_def_note_rec.ATTRIBUTE2,
	ATTRIBUTE3 = l_def_note_rec.ATTRIBUTE3,
	ATTRIBUTE4 = l_def_note_rec.ATTRIBUTE4,
	ATTRIBUTE5 = l_def_note_rec.ATTRIBUTE5,
	ATTRIBUTE6 = l_def_note_rec.ATTRIBUTE6,
	ATTRIBUTE7 = l_def_note_rec.ATTRIBUTE7,
	ATTRIBUTE8 = l_def_note_rec.ATTRIBUTE8,
	ATTRIBUTE9 = l_def_note_rec.ATTRIBUTE9,
	ATTRIBUTE10 = l_def_note_rec.ATTRIBUTE10,
	ATTRIBUTE11 = l_def_note_rec.ATTRIBUTE11,
	ATTRIBUTE12 = l_def_note_rec.ATTRIBUTE12,
	ATTRIBUTE13 = l_def_note_rec.ATTRIBUTE13,
	ATTRIBUTE14 = l_def_note_rec.ATTRIBUTE14,
	ATTRIBUTE15 = l_def_note_rec.ATTRIBUTE15,
	default_flag= l_def_note_rec.default_flag
    WHERE STANDARD_NOTES_ID = l_def_note_rec.STANDARD_NOTES_ID;





    UPDATE OKE_K_STANDARD_NOTES_TL
    SET
	LAST_UPDATE_DATE = l_def_note_rec.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = l_def_note_rec.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = l_def_note_rec.LAST_UPDATE_LOGIN,
	SOURCE_LANG = oke_utils.get_userenv_lang,
	SFWT_FLAG = l_def_note_rec.SFWT_FLAG,
	DESCRIPTION = l_def_note_rec.DESCRIPTION,
	NAME = l_def_note_rec.NAME,
	TEXT = l_def_note_rec.TEXT
    WHERE STANDARD_NOTES_ID = l_def_note_rec.STANDARD_NOTES_ID
    AND userenv('LANG') in (language , source_lang);

    x_note_rec := l_def_note_rec;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;   -- row level update



  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                     IN note_tbl_type,
    x_note_tbl                     OUT NOCOPY note_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_note_tbl.COUNT > 0) THEN
      i := p_note_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_note_rec                      => p_note_tbl(i),
          x_note_rec                     => x_note_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_note_tbl.LAST);
        i := p_note_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );

    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;  -- table level update


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_del_id                     IN NUMBER) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    DELETE FROM OKE_K_STANDARD_NOTES_TL
    WHERE STANDARD_NOTES_ID IN (
	SELECT STANDARD_NOTES_ID FROM OKE_K_STANDARD_NOTES_B
	WHERE DELIVERABLE_ID = p_del_id);

    DELETE FROM OKE_K_STANDARD_NOTES_B
    WHERE DELIVERABLE_ID = p_del_id;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                     IN NUMBER) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    DELETE FROM OKE_K_STANDARD_NOTES_TL
    WHERE STANDARD_NOTES_ID IN (
	SELECT STANDARD_NOTES_ID FROM OKE_K_STANDARD_NOTES_B
	WHERE K_LINE_ID = p_cle_id);

    DELETE FROM OKE_K_STANDARD_NOTES_B
    WHERE K_LINE_ID = p_cle_id;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_hdr_id                     IN NUMBER) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    DELETE FROM OKE_K_STANDARD_NOTES_TL
    WHERE STANDARD_NOTES_ID IN (
	SELECT STANDARD_NOTES_ID FROM OKE_K_STANDARD_NOTES_B
	WHERE
		(K_HEADER_ID = p_hdr_id) AND
		(K_LINE_ID IS NULL) AND
		(DELIVERABLE_ID IS NULL));

    DELETE FROM OKE_K_STANDARD_NOTES_B
    WHERE (K_HEADER_ID = p_hdr_id) AND
	  (K_LINE_ID IS NULL) AND
	  (DELIVERABLE_ID IS NULL);

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

	-- row level delete
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec                     IN note_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_note_rec                     note_rec_type := p_note_rec;

  BEGIN

    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    DELETE FROM OKE_K_STANDARD_NOTES_B
    WHERE STANDARD_NOTES_ID = l_note_rec.STANDARD_NOTES_ID;

    DELETE FROM OKE_K_STANDARD_NOTES_TL
    WHERE STANDARD_NOTES_ID = l_note_rec.STANDARD_NOTES_ID;

    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;


-- table level delete

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                     IN note_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_note_tbl.COUNT > 0) THEN
      i := p_note_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_note_rec                      => p_note_tbl(i));



	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_note_tbl.LAST);
        i := p_note_tbl.NEXT(i);
      END LOOP;

	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row; -- table level delete


-- validate row

  PROCEDURE validate_row(
    p_api_version       IN NUMBER,
    p_init_msg_list     IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2,
    p_note_rec           IN note_rec_type
  ) IS

    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'B_validate_row';
    l_return_status     VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_note_rec           note_rec_type := p_note_rec;

  BEGIN
    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
					      G_PKG_NAME,
					      p_init_msg_list,
					      l_api_version,
					      p_api_version,
					      '_PVT',
					      x_return_status);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN

      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_note_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_note_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);
  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_tbl                      IN note_tbl_type
    ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_note_tbl.COUNT > 0) THEN
      i := p_note_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_note_rec                     => p_note_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_note_tbl.LAST);
        i := p_note_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;

  EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;




  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_note_rec                     IN note_rec_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_row_notfound1                BOOLEAN := FALSE;
    l_row_notfound2                BOOLEAN := FALSE;

    l_row_id                       NUMBER;

	E_Resource_Busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


	CURSOR lock_csr1 (p_note_rec IN note_rec_type) IS
	SELECT standard_notes_id FROM oke_k_standard_notes_b
	WHERE standard_notes_id = p_note_rec.standard_notes_id
	FOR UPDATE NOWAIT;

	CURSOR lock_csr2 (p_note_rec IN note_rec_type) IS
	SELECT standard_notes_id FROM oke_k_standard_notes_tl
	WHERE standard_notes_id = p_note_rec.standard_notes_id
	FOR UPDATE NOWAIT;


BEGIN
    l_return_status := OKE_API.START_ACTIVITY(l_api_name,
                                              p_init_msg_list,
                                              '_PVT',
                                              x_return_status);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    BEGIN
      OPEN lock_csr1(p_note_rec);
      FETCH lock_csr1 INTO l_row_id;
      l_row_notfound1 := lock_csr1%NOTFOUND;
      CLOSE lock_csr1;

      OPEN lock_csr2(p_note_rec);
      FETCH lock_csr2 INTO l_row_id;
      l_row_notfound2 := lock_csr2%NOTFOUND;
      CLOSE lock_csr2;

    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr1%ISOPEN) THEN
          CLOSE lock_csr1;
        END IF;
        IF (lock_csr2%ISOPEN) THEN
          CLOSE lock_csr2;
        END IF;
        OKE_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;


    IF (l_row_notfound1)OR(l_row_notfound2) THEN
      OKE_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

	OKE_API.END_ACTIVITY(x_msg_count, x_msg_data);


EXCEPTION
    WHEN OKE_API.G_EXCEPTION_ERROR THEN
      x_return_status := OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OKE_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKE_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status :=OKE_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;

procedure ADD_LANGUAGE
is
begin
  --
  -- Regular table
  --
  delete from OKE_K_STANDARD_NOTES_TL T
  where not exists
    (select NULL
    from OKE_K_STANDARD_NOTES_B B
    where B.STANDARD_NOTES_ID = T.STANDARD_NOTES_ID
    );

  update OKE_K_STANDARD_NOTES_TL T set (
      NAME,
      DESCRIPTION,
      TEXT
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      B.TEXT
    from OKE_K_STANDARD_NOTES_TL B
    where B.STANDARD_NOTES_ID = T.STANDARD_NOTES_ID
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STANDARD_NOTES_ID,
      T.LANGUAGE
  ) in (select
      SUBT.STANDARD_NOTES_ID,
      SUBT.LANGUAGE
    from OKE_K_STANDARD_NOTES_TL SUBB, OKE_K_STANDARD_NOTES_TL SUBT
    where SUBB.STANDARD_NOTES_ID = SUBT.STANDARD_NOTES_ID
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TEXT <> SUBT.TEXT
      or (SUBB.TEXT is null and SUBT.TEXT is not null)
      or (SUBB.TEXT is not null and SUBT.TEXT is null)
  ));

  insert into OKE_K_STANDARD_NOTES_TL (
    STANDARD_NOTES_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SFWT_FLAG,
    DESCRIPTION,
    NAME,
    TEXT,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STANDARD_NOTES_ID,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SFWT_FLAG,
    B.DESCRIPTION,
    B.NAME,
    B.TEXT,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKE_K_STANDARD_NOTES_TL B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKE_K_STANDARD_NOTES_TL T
    where T.STANDARD_NOTES_ID = B.STANDARD_NOTES_ID
    and T.LANGUAGE = L.LANGUAGE_CODE);

  --
  -- History table
  --
  delete from OKE_K_STANDARD_NOTES_TLH T
  where not exists
    (select NULL
    from OKE_K_STANDARD_NOTES_BH B
    where B.STANDARD_NOTES_ID = T.STANDARD_NOTES_ID
    AND B.MAJOR_VERSION = T.MAJOR_VERSION
    );

  update OKE_K_STANDARD_NOTES_TLH T set (
      NAME,
      DESCRIPTION,
      TEXT
    ) = (select
      B.NAME,
      B.DESCRIPTION,
      B.TEXT
    from OKE_K_STANDARD_NOTES_TLH B
    where B.STANDARD_NOTES_ID = T.STANDARD_NOTES_ID
    and B.MAJOR_VERSION = T.MAJOR_VERSION
    and B.LANGUAGE = T.SOURCE_LANG)
  where (
      T.STANDARD_NOTES_ID,
      T.MAJOR_VERSION,
      T.LANGUAGE
  ) in (select
      SUBT.STANDARD_NOTES_ID,
      SUBT.MAJOR_VERSION,
      SUBT.LANGUAGE
    from OKE_K_STANDARD_NOTES_TLH SUBB, OKE_K_STANDARD_NOTES_TLH SUBT
    where SUBB.STANDARD_NOTES_ID = SUBT.STANDARD_NOTES_ID
    and SUBB.MAJOR_VERSION = SUBT.MAJOR_VERSION
    and SUBB.LANGUAGE = SUBT.SOURCE_LANG
    and (SUBB.NAME <> SUBT.NAME
      or (SUBB.NAME is null and SUBT.NAME is not null)
      or (SUBB.NAME is not null and SUBT.NAME is null)
      or SUBB.DESCRIPTION <> SUBT.DESCRIPTION
      or (SUBB.DESCRIPTION is null and SUBT.DESCRIPTION is not null)
      or (SUBB.DESCRIPTION is not null and SUBT.DESCRIPTION is null)
      or SUBB.TEXT <> SUBT.TEXT
      or (SUBB.TEXT is null and SUBT.TEXT is not null)
      or (SUBB.TEXT is not null and SUBT.TEXT is null)
  ));

  insert into OKE_K_STANDARD_NOTES_TLH (
    STANDARD_NOTES_ID,
    MAJOR_VERSION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SFWT_FLAG,
    DESCRIPTION,
    NAME,
    TEXT,
    LANGUAGE,
    SOURCE_LANG
  ) select
    B.STANDARD_NOTES_ID,
    B.MAJOR_VERSION,
    B.CREATION_DATE,
    B.CREATED_BY,
    B.LAST_UPDATE_DATE,
    B.LAST_UPDATED_BY,
    B.LAST_UPDATE_LOGIN,
    B.SFWT_FLAG,
    B.DESCRIPTION,
    B.NAME,
    B.TEXT,
    L.LANGUAGE_CODE,
    B.SOURCE_LANG
  from OKE_K_STANDARD_NOTES_TLH B, FND_LANGUAGES L
  where L.INSTALLED_FLAG in ('I', 'B')
  and B.LANGUAGE = userenv('LANG')
  and not exists
    (select NULL
    from OKE_K_STANDARD_NOTES_TLH T
    where T.STANDARD_NOTES_ID = B.STANDARD_NOTES_ID
    and T.MAJOR_VERSION = B.MAJOR_VERSION
    and T.LANGUAGE = L.LANGUAGE_CODE);
end ADD_LANGUAGE;

END OKE_NOTE_PVT;

/
