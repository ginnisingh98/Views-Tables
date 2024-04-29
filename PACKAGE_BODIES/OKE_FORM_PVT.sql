--------------------------------------------------------
--  DDL for Package Body OKE_FORM_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FORM_PVT" AS
/* $Header: OKEVKPFB.pls 120.1 2005/05/27 15:56:40 appldev  $ */

-- validate record
 g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_form_pvt.';
  FUNCTION validate_record (
    p_form_rec IN form_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate individual attributes

  FUNCTION validate_attributes(
    p_form_rec IN  form_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  PROCEDURE validate_k_header_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_form_rec   IN  form_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_HEADERS
	WHERE K_HEADER_ID = p_form_rec.K_HEADER_ID;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_form_rec.k_header_id = OKE_API.G_MISS_NUM
     	OR     p_form_rec.k_header_id IS NULL) THEN
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


  PROCEDURE validate_k_line_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_form_rec   IN  form_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_LINES
	WHERE K_LINE_ID = p_form_rec.K_LINE_ID;

    BEGIN
	x_return_status := OKE_API.G_RET_STS_SUCCESS;
	IF (   p_form_rec.k_line_id <> OKE_API.G_MISS_NUM
     	AND p_form_rec.k_line_id IS NOT NULL) THEN

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
		p_token3_value		=>G_VIEW);

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



  PROCEDURE validate_print_form_code(x_return_status OUT NOCOPY VARCHAR2,
			      p_form_rec   IN  form_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_PRINT_FORMS_B
	WHERE PRINT_FORM_CODE = p_form_rec.PRINT_FORM_CODE;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_form_rec.print_form_code = OKE_API.G_MISS_CHAR
     	OR     p_form_rec.print_form_code IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PRINT_FORM_CODE');

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
		p_token1_value		=>'PRINT_FORM_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_PRINT_FORMS_B');

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

    END validate_print_form_code;


  BEGIN

  validate_k_header_id (x_return_status => l_return_status,
			      p_form_rec	 =>  p_form_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_k_line_id (x_return_status => l_return_status,
			      p_form_rec	 =>  p_form_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;


  validate_print_form_code (x_return_status => l_return_status,
			      p_form_rec	 =>  p_form_rec);
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
	 p_form_rec	IN form_rec_type ) RETURN form_rec_type IS

  l_form_rec form_rec_type := p_form_rec;
  l_api_name                   CONSTANT VARCHAR2(30) := 'null_out_defaults';

  BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'call from  null out defaults');
 END IF;

    IF  l_form_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
	l_form_rec.K_HEADER_ID := NULL;
    END IF;

    IF  l_form_rec.K_LINE_ID = OKE_API.G_MISS_NUM THEN
	l_form_rec.K_LINE_ID := NULL;
    END IF;

    IF  l_form_rec.PRINT_FORM_CODE = OKE_API.G_MISS_CHAR THEN
	l_form_rec.PRINT_FORM_CODE := NULL;
    END IF;

    IF	l_form_rec.REQUIRED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_form_rec.REQUIRED_FLAG := NULL;
    END IF;

    IF	l_form_rec.CUSTOMER_FURNISHED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_form_rec.CUSTOMER_FURNISHED_FLAG := NULL;
    END IF;

    IF	l_form_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	l_form_rec.COMPLETED_FLAG := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF  l_form_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_form_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF	l_form_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_form_rec.CREATED_BY := NULL;
    END IF;

    IF	l_form_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_form_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_form_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_form_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_form_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_form_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_form_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_form_rec.LAST_UPDATE_DATE := NULL;
    END IF;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'all  through null out defaults');
  END IF;

    RETURN(l_form_rec);

  END null_out_defaults;


  FUNCTION get_rec (
    p_form_rec                      IN form_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN form_rec_type IS

    CURSOR form_pk_csr ( chr_id IN NUMBER,cle_id IN NUMBER, pfm_cd IN NUMBER) IS
    SELECT

 	K_HEADER_ID,
 	K_LINE_ID,
 	PRINT_FORM_CODE,
 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_LOGIN,
 	REQUIRED_FLAG,
 	CUSTOMER_FURNISHED_FLAG,
 	COMPLETED_FLAG,
 	ATTRIBUTE_CATEGORY,
 	ATTRIBUTE1   ,
 	ATTRIBUTE2   ,
 	ATTRIBUTE3   ,
 	ATTRIBUTE4   ,
 	ATTRIBUTE5   ,
 	ATTRIBUTE6   ,
 	ATTRIBUTE7              ,
 	ATTRIBUTE8              ,
 	ATTRIBUTE9              ,
 	ATTRIBUTE10             ,
 	ATTRIBUTE11             ,
 	ATTRIBUTE12             ,
 	ATTRIBUTE13             ,
 	ATTRIBUTE14             ,
 	ATTRIBUTE15


    FROM OKE_K_PRINT_FORMS a
    WHERE
	(a.K_HEADER_ID = chr_id)AND(a.PRINT_FORM_CODE=pfm_cd)
	AND(
	     ((a.K_LINE_ID IS NULL)AND(cle_id IS NULL)) OR
             (a.K_LINE_ID = cle_id));

    l_form_pk	form_pk_csr%ROWTYPE;
    l_form_rec   form_rec_type;
    l_api_name                   CONSTANT VARCHAR2(30) := 'get_rec';

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'get rec-pos 1');
END IF;

    OPEN form_pk_csr(p_form_rec.K_HEADER_ID,p_form_rec.K_LINE_ID,p_form_rec.PRINT_FORM_CODE);
    FETCH form_pk_csr INTO
		l_form_rec.K_HEADER_ID			,
		l_form_rec.K_LINE_ID			,
		l_form_rec.PRINT_FORM_CODE		,
		l_form_rec.CREATION_DATE		,
		l_form_rec.CREATED_BY			,
		l_form_rec.LAST_UPDATE_DATE		,
		l_form_rec.LAST_UPDATED_BY		,
		l_form_rec.LAST_UPDATE_LOGIN		,
		l_form_rec.REQUIRED_FLAG		,
		l_form_rec.CUSTOMER_FURNISHED_FLAG	,
		l_form_rec.COMPLETED_FLAG		,
		l_form_rec.ATTRIBUTE_CATEGORY		,
		l_form_rec.ATTRIBUTE1			,
		l_form_rec.ATTRIBUTE2			,
		l_form_rec.ATTRIBUTE3			,
		l_form_rec.ATTRIBUTE4			,
		l_form_rec.ATTRIBUTE5			,
		l_form_rec.ATTRIBUTE6			,
		l_form_rec.ATTRIBUTE7			,
		l_form_rec.ATTRIBUTE8			,
		l_form_rec.ATTRIBUTE9			,
		l_form_rec.ATTRIBUTE10			,
		l_form_rec.ATTRIBUTE11			,
		l_form_rec.ATTRIBUTE12			,
		l_form_rec.ATTRIBUTE13			,
		l_form_rec.ATTRIBUTE14			,
		l_form_rec.ATTRIBUTE15			;

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'get rec-pos 2');
    x_no_data_found := form_pk_csr%NOTFOUND;
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'get rec-pos 3');
    CLOSE form_pk_csr;
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'get rec-pos 4');
END IF;
	IF(x_no_data_found) THEN
	RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'get rec-pos 5');
 END IF;

    RETURN(l_form_rec);

  END get_rec;



	-- row level insert

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_rec                      IN form_rec_type,
    x_form_rec                      OUT NOCOPY form_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_form_rec                      form_rec_type;
    l_def_form_rec                  form_rec_type;
    lx_form_rec                     form_rec_type;
    l_seq			   NUMBER;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_form_rec	IN form_rec_type
    ) RETURN form_rec_type IS

      l_form_rec	form_rec_type := p_form_rec;

    BEGIN

      l_form_rec.CREATION_DATE := SYSDATE;
      l_form_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_form_rec.LAST_UPDATE_DATE := SYSDATE;
      l_form_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_form_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_form_rec);

    END fill_who_columns;



    FUNCTION Set_Attributes (
      p_form_rec IN  form_rec_type,
      x_form_rec OUT NOCOPY form_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
	x_form_rec := p_form_rec;
	x_form_rec.REQUIRED_FLAG := UPPER(x_form_rec.REQUIRED_FLAG);
    	x_form_rec.CUSTOMER_FURNISHED_FLAG :=
			UPPER(x_form_rec.CUSTOMER_FURNISHED_FLAG);
	x_form_rec.COMPLETED_FLAG := UPPER(x_form_rec.COMPLETED_FLAG);

      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- insert

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call insert api');
  END IF;

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

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call null out defaults');
 END IF;
    l_form_rec := null_out_defaults(p_form_rec);

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,' called null out defaults');
  END IF;

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_form_rec,                        -- IN
      l_def_form_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'attributes set for insert');
    END IF;

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_form_rec := fill_who_columns(l_def_form_rec);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'who column filled for insert');
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_form_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'attributes validated for insert');
    END IF;
    l_return_status := Validate_Record(l_def_form_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    INSERT INTO OKE_K_PRINT_FORMS(

 	K_HEADER_ID          ,
 	K_LINE_ID            ,
 	PRINT_FORM_CODE      ,
 	CREATION_DATE        ,
 	CREATED_BY           ,
 	LAST_UPDATE_DATE     ,
 	LAST_UPDATED_BY      ,
 	LAST_UPDATE_LOGIN    ,
 	REQUIRED_FLAG        ,
 	CUSTOMER_FURNISHED_FLAG,
	COMPLETED_FLAG       ,
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
 	ATTRIBUTE15
	)
    VALUES(
	l_def_form_rec.K_HEADER_ID          ,
 	l_def_form_rec.K_LINE_ID            ,
 	l_def_form_rec.PRINT_FORM_CODE      ,
 	l_def_form_rec.CREATION_DATE        ,
 	l_def_form_rec.CREATED_BY           ,
 	l_def_form_rec.LAST_UPDATE_DATE     ,
 	l_def_form_rec.LAST_UPDATED_BY      ,
 	l_def_form_rec.LAST_UPDATE_LOGIN    ,
 	l_def_form_rec.REQUIRED_FLAG        ,
 	l_def_form_rec.CUSTOMER_FURNISHED_FLAG,
	l_def_form_rec.COMPLETED_FLAG       ,
 	l_def_form_rec.ATTRIBUTE_CATEGORY   ,
 	l_def_form_rec.ATTRIBUTE1           ,
 	l_def_form_rec.ATTRIBUTE2           ,
 	l_def_form_rec.ATTRIBUTE3           ,
 	l_def_form_rec.ATTRIBUTE4           ,
 	l_def_form_rec.ATTRIBUTE5           ,
 	l_def_form_rec.ATTRIBUTE6           ,
 	l_def_form_rec.ATTRIBUTE7           ,
 	l_def_form_rec.ATTRIBUTE8           ,
 	l_def_form_rec.ATTRIBUTE9           ,
 	l_def_form_rec.ATTRIBUTE10          ,
 	l_def_form_rec.ATTRIBUTE11          ,
 	l_def_form_rec.ATTRIBUTE12          ,
 	l_def_form_rec.ATTRIBUTE13          ,
 	l_def_form_rec.ATTRIBUTE14          ,
 	l_def_form_rec.ATTRIBUTE15
	);

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'record inserted');
    END IF;
    -- Set OUT values
    x_form_rec := l_def_form_rec;

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
    p_form_tbl                      IN form_tbl_type,
    x_form_tbl                      OUT NOCOPY form_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_form_tbl.COUNT > 0) THEN
      i := p_form_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_form_rec                      => p_form_tbl(i),
          x_form_rec                      => x_form_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_form_tbl.LAST);

        i := p_form_tbl.NEXT(i);
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
    p_form_rec                      IN form_rec_type,
    x_form_rec                      OUT NOCOPY form_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_form_rec                      form_rec_type := p_form_rec;
    l_def_form_rec                  form_rec_type;
    lx_form_rec                     form_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_form_rec	IN form_rec_type
    ) RETURN form_rec_type IS

      l_form_rec	form_rec_type := p_form_rec;

    BEGIN
      l_form_rec.LAST_UPDATE_DATE := SYSDATE;
      l_form_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_form_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_form_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_form_rec	IN form_rec_type,
      x_form_rec	OUT NOCOPY form_rec_type
    ) RETURN VARCHAR2 IS

      l_form_rec                     form_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call populate new record');
    END IF;

      x_form_rec := p_form_rec;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call get rec');
    END IF;
      -- Get current database values

      l_form_rec := get_rec(p_form_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'record got');
    END IF;

	IF x_form_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	  x_form_rec.CREATION_DATE := l_form_rec.CREATION_DATE;
    	END IF;

	IF x_form_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	  x_form_rec.CREATED_BY := l_form_rec.CREATED_BY;
    	END IF;

	IF x_form_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	  x_form_rec.LAST_UPDATE_DATE := l_form_rec.LAST_UPDATE_DATE;
    	END IF;

	IF x_form_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	  x_form_rec.LAST_UPDATED_BY  := l_form_rec.LAST_UPDATED_BY ;
    	END IF;

	IF x_form_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	  x_form_rec.LAST_UPDATE_LOGIN := l_form_rec.LAST_UPDATE_LOGIN;
    	END IF;

	IF x_form_rec.REQUIRED_FLAG = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.REQUIRED_FLAG := l_form_rec.REQUIRED_FLAG;
    	END IF;

	IF x_form_rec.CUSTOMER_FURNISHED_FLAG = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.CUSTOMER_FURNISHED_FLAG := l_form_rec.CUSTOMER_FURNISHED_FLAG;
    	END IF;

	IF x_form_rec.COMPLETED_FLAG = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.COMPLETED_FLAG := l_form_rec.COMPLETED_FLAG;
    	END IF;

	IF x_form_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE_CATEGORY := l_form_rec.ATTRIBUTE_CATEGORY;
    	END IF;

	IF x_form_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE1 := l_form_rec.ATTRIBUTE1;
    	END IF;

	IF x_form_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE2 := l_form_rec.ATTRIBUTE2;
    	END IF;

	IF x_form_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE3 := l_form_rec.ATTRIBUTE3;
    	END IF;

	IF x_form_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE4 := l_form_rec.ATTRIBUTE4;
    	END IF;

	IF x_form_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE5 := l_form_rec.ATTRIBUTE5;
    	END IF;

	IF x_form_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE6 := l_form_rec.ATTRIBUTE6;
    	END IF;

	IF x_form_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE7 := l_form_rec.ATTRIBUTE7;
    	END IF;

 	IF x_form_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE8 := l_form_rec.ATTRIBUTE8;
    	END IF;

	IF x_form_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE9 := l_form_rec.ATTRIBUTE9;
    	END IF;

	IF x_form_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE10 := l_form_rec.ATTRIBUTE10;
    	END IF;

	IF x_form_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE11 := l_form_rec.ATTRIBUTE11;
    	END IF;

	IF x_form_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE12 := l_form_rec.ATTRIBUTE12;
    	END IF;

	IF x_form_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE13 := l_form_rec.ATTRIBUTE13;
    	END IF;

	IF x_form_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE14 := l_form_rec.ATTRIBUTE14;
    	END IF;

	IF x_form_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	  x_form_rec.ATTRIBUTE15 := l_form_rec.ATTRIBUTE15;
    	END IF;

    RETURN(l_return_status);
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'all the way through populate new record');
END IF;

  END populate_new_record;



  FUNCTION set_attributes(
	      p_form_rec IN  form_rec_type,
              x_form_rec OUT NOCOPY form_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
      	x_form_rec := p_form_rec;
 	x_form_rec.REQUIRED_FLAG := UPPER(x_form_rec.REQUIRED_FLAG);
    	x_form_rec.CUSTOMER_FURNISHED_FLAG :=
			UPPER(x_form_rec.CUSTOMER_FURNISHED_FLAG);
	x_form_rec.COMPLETED_FLAG := UPPER(x_form_rec.COMPLETED_FLAG);
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- update row
   IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call api initialization');
   END IF;

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

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'start call not pvt');
   END IF;

    l_return_status := Set_Attributes(
      p_form_rec,                        -- IN
      l_form_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'attributes set');
   END IF;

    l_return_status := populate_new_record(l_form_rec, l_def_form_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'record populated');
    END IF;

    l_def_form_rec := fill_who_columns(l_def_form_rec);
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'who column filled');
    END IF;

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_form_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'attributes validated');
    END IF;
    l_return_status := Validate_Record(l_def_form_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
       FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'update base table');
    END IF;

    UPDATE OKE_K_PRINT_FORMS
    SET
	CREATION_DATE	= l_def_form_rec.CREATION_DATE,
	CREATED_BY = l_def_form_rec.CREATED_BY,
	LAST_UPDATE_DATE = l_def_form_rec.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = l_def_form_rec.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = l_def_form_rec.LAST_UPDATE_LOGIN,
	REQUIRED_FLAG = l_def_form_rec.REQUIRED_FLAG,
	CUSTOMER_FURNISHED_FLAG = l_def_form_rec.CUSTOMER_FURNISHED_FLAG,
	COMPLETED_FLAG = l_def_form_rec.COMPLETED_FLAG,

	ATTRIBUTE_CATEGORY = l_def_form_rec.ATTRIBUTE_CATEGORY,
	ATTRIBUTE1 = l_def_form_rec.ATTRIBUTE1,
	ATTRIBUTE2 = l_def_form_rec.ATTRIBUTE2,
	ATTRIBUTE3 = l_def_form_rec.ATTRIBUTE3,
	ATTRIBUTE4 = l_def_form_rec.ATTRIBUTE4,
	ATTRIBUTE5 = l_def_form_rec.ATTRIBUTE5,
	ATTRIBUTE6 = l_def_form_rec.ATTRIBUTE6,
	ATTRIBUTE7 = l_def_form_rec.ATTRIBUTE7,
	ATTRIBUTE8 = l_def_form_rec.ATTRIBUTE8,
	ATTRIBUTE9 = l_def_form_rec.ATTRIBUTE9,
	ATTRIBUTE10 = l_def_form_rec.ATTRIBUTE10,
	ATTRIBUTE11 = l_def_form_rec.ATTRIBUTE11,
	ATTRIBUTE12 = l_def_form_rec.ATTRIBUTE12,
	ATTRIBUTE13 = l_def_form_rec.ATTRIBUTE13,
	ATTRIBUTE14 = l_def_form_rec.ATTRIBUTE14,
	ATTRIBUTE15 = l_def_form_rec.ATTRIBUTE15
    WHERE
	(K_HEADER_ID = l_def_form_rec.K_HEADER_ID)AND
	(PRINT_FORM_CODE = l_def_form_rec.PRINT_FORM_CODE) AND
	((K_LINE_ID = l_def_form_rec.K_LINE_ID)OR
	 (K_LINE_ID IS NULL)AND(l_def_form_rec.K_LINE_ID IS NULL));

    x_form_rec := l_def_form_rec;

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
    p_form_tbl                     IN form_tbl_type,
    x_form_tbl                     OUT NOCOPY form_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'begin table type of update in pvt');
  END IF;

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_form_tbl.COUNT > 0) THEN
      i := p_form_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_form_rec                      => p_form_tbl(i),
          x_form_rec                     => x_form_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_form_tbl.LAST);
        i := p_form_tbl.NEXT(i);
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


   -- by line id and pf code
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_cle_id                       IN NUMBER,
    p_pfm_cd			   OKE_K_PRINT_FORMS.PRINT_FORM_CODE%TYPE
) IS

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

    DELETE FROM OKE_K_PRINT_FORMS
    WHERE K_LINE_ID = p_cle_id AND PRINT_FORM_CODE = p_pfm_cd;

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
    p_chr_id                       IN NUMBER,
    p_pfm_cd			   OKE_K_PRINT_FORMS.PRINT_FORM_CODE%TYPE
) IS

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

    DELETE FROM OKE_K_PRINT_FORMS
    WHERE (K_HEADER_ID=p_chr_id) AND (PRINT_FORM_CODE=p_pfm_cd) AND (K_LINE_ID IS NULL);

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
    p_form_rec                     IN form_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_form_rec                     form_rec_type := p_form_rec;

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

	IF(p_form_rec.K_LINE_ID IS NULL) THEN
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
	  p_chr_id			 => p_form_rec.K_HEADER_ID,
	  p_pfm_cd			 => p_form_rec.PRINT_FORM_CODE);
	ELSE
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
	  p_cle_id			 => p_form_rec.K_LINE_ID,
	  p_pfm_cd			 => p_form_rec.PRINT_FORM_CODE);
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
  END delete_row;


-- table level delete

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_form_tbl                     IN form_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_form_tbl.COUNT > 0) THEN
      i := p_form_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_form_rec                      => p_form_tbl(i));



	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_form_tbl.LAST);
        i := p_form_tbl.NEXT(i);
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
    p_form_rec           IN form_rec_type
  ) IS

    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'B_validate_row';
    l_return_status     VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_form_rec           form_rec_type := p_form_rec;

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
    l_return_status := Validate_Attributes(l_form_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_form_rec);

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
    p_form_tbl                      IN form_tbl_type
    ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_form_tbl.COUNT > 0) THEN
      i := p_form_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_form_rec                     => p_form_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_form_tbl.LAST);
        i := p_form_tbl.NEXT(i);
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
    p_form_rec                     IN form_rec_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_row_notfound                BOOLEAN := FALSE;

    l_chr_id                       NUMBER;
    l_cle_id                       NUMBER;
    l_pfm_cd			   OKE_K_PRINT_FORMS.PRINT_FORM_CODE%TYPE;

	E_Resource_Busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


	CURSOR lock_csr (p IN form_rec_type) IS
	SELECT k_header_id,k_line_id,print_form_code FROM oke_k_print_forms a
	WHERE
	(a.K_HEADER_ID = p.K_HEADER_ID)AND(a.PRINT_FORM_CODE=p.PRINT_FORM_CODE)
	AND(
	     ((a.K_LINE_ID IS NULL)AND(p.K_LINE_ID IS NULL)) OR
             (a.K_LINE_ID = p.K_LINE_ID))
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
      OPEN lock_csr(p_form_rec);
      FETCH lock_csr INTO l_chr_id,l_cle_id,l_pfm_cd;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;


    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKE_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;


    IF (l_row_notfound) THEN
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


END OKE_FORM_PVT;


/
