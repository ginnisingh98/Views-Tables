--------------------------------------------------------
--  DDL for Package Body OKE_POOL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_POOL_PVT" AS
/* $Header: OKEVFPLB.pls 120.0 2005/05/25 17:46:47 appldev noship $ */

-- validate record

  FUNCTION validate_record (
    p_pool_rec IN pool_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate individual attributes

  FUNCTION validate_attributes(
    p_pool_rec IN  pool_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  PROCEDURE validate_name (x_return_status OUT NOCOPY VARCHAR2,
			      p_pool_rec   IN  pool_rec_type)IS

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_pool_rec.name = OKE_API.G_MISS_CHAR
     	OR     p_pool_rec.name IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'NAME');

		x_return_status := OKE_API.G_RET_STS_ERROR;
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

    END validate_name;


  PROCEDURE validate_currency_code(x_return_status OUT NOCOPY VARCHAR2,
			      p_pool_rec   IN  pool_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM FND_CURRENCIES
	WHERE CURRENCY_CODE = p_pool_rec.CURRENCY_CODE;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_pool_rec.currency_code = OKE_API.G_MISS_CHAR
     	OR     p_pool_rec.currency_code IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'CURRENCY_CODE');

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
		p_token1_value		=>'CURRENCY_CODE',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'FND_CURRENCIES');

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

    END validate_currency_code;


  PROCEDURE validate_contact_person_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_pool_rec   IN  pool_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM PER_EMPLOYEES_CURRENT_X
	WHERE EMPLOYEE_ID= p_pool_rec.CONTACT_PERSON_ID;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;

	IF(p_pool_rec.contact_person_id <> OKE_API.G_MISS_NUM
	AND p_pool_rec.contact_person_id IS NOT NULL) THEN

    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'CONTACT_PERSON_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'PER_EMPLOYEES_CURRENT_X');

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

    END validate_contact_person_id;



  PROCEDURE validate_program_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_pool_rec   IN  pool_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_PROGRAMS
	WHERE PROGRAM_ID= p_pool_rec.PROGRAM_ID
          AND SYSDATE BETWEEN START_DATE
          AND NVL(END_DATE+1 , SYSDATE )
        ;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;

	IF(p_pool_rec.program_id <> OKE_API.G_MISS_NUM
	AND p_pool_rec.program_id IS NOT NULL) THEN

    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'PROGRAM_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_PROGRAMS');

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

    END validate_program_id;



  BEGIN

  validate_name (x_return_status => l_return_status,
			      p_pool_rec	 =>  p_pool_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_currency_code (x_return_status => l_return_status,
			      p_pool_rec	 =>  p_pool_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_contact_person_id (x_return_status => l_return_status,
			      p_pool_rec	 =>  p_pool_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

 validate_program_id (x_return_status => l_return_status,
			      p_pool_rec	 =>  p_pool_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;
    /* call individual validation procedure */
	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;


-- called by insert_row to make unfilled attributes NULL

  FUNCTION null_out_defaults(
	 p_pool_rec	IN pool_rec_type ) RETURN pool_rec_type IS

  l_pool_rec pool_rec_type := p_pool_rec;

  BEGIN

    IF  l_pool_rec.FUNDING_POOL_ID = OKE_API.G_MISS_NUM THEN
	l_pool_rec.FUNDING_POOL_ID := NULL;
    END IF;

    IF  l_pool_rec.NAME = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.NAME := NULL;
    END IF;

    IF  l_pool_rec.DESCRIPTION = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.DESCRIPTION := NULL;
    END IF;

    IF	l_pool_rec.CURRENCY_CODE = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.CURRENCY_CODE := NULL;
    END IF;

    IF	l_pool_rec.CONTACT_PERSON_ID = OKE_API.G_MISS_NUM THEN
	l_pool_rec.CONTACT_PERSON_ID := NULL;
    END IF;

    IF	l_pool_rec.PROGRAM_ID = OKE_API.G_MISS_NUM THEN
	l_pool_rec.PROGRAM_ID := NULL;
    END IF;


    IF  l_pool_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE_CATEGORY := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE1 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE2 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE3 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE4 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE5 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE6 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE7 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE8 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE9 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE10 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE11 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE12 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE13 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE14 := NULL;
    END IF;

    IF  l_pool_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	l_pool_rec.ATTRIBUTE15 := NULL;
    END IF;

    IF	l_pool_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_pool_rec.CREATED_BY := NULL;
    END IF;

    IF	l_pool_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_pool_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_pool_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_pool_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_pool_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_pool_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_pool_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_pool_rec.LAST_UPDATE_DATE := NULL;
    END IF;

    RETURN(l_pool_rec);

  END null_out_defaults;


-- gets the record based on a key attribute

  FUNCTION get_rec (
    p_pool_rec                      IN pool_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN pool_rec_type IS

    CURSOR pool_pk_csr ( p_funding_pool_id NUMBER) IS
    SELECT

	FUNDING_POOL_ID,
	NAME,
	DESCRIPTION,
	CURRENCY_CODE,
	CONTACT_PERSON_ID,
	PROGRAM_ID,

 	CREATION_DATE,
 	CREATED_BY,
 	LAST_UPDATE_DATE,
 	LAST_UPDATED_BY,
 	LAST_UPDATE_LOGIN,
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


    FROM OKE_FUNDING_POOLS a
    WHERE (a.funding_pool_id = p_funding_pool_id);

    l_pool_pk	pool_pk_csr%ROWTYPE;
    l_pool_rec   pool_rec_type;

  BEGIN
    x_no_data_found := TRUE;

    -- get current database value

    OPEN pool_pk_csr(p_pool_rec.FUNDING_POOL_ID);
    FETCH pool_pk_csr INTO
		l_pool_rec.FUNDING_POOL_ID		,
		l_pool_rec.NAME				,
		l_pool_rec.DESCRIPTION			,
		l_pool_rec.CURRENCY_CODE		,
		l_pool_rec.CONTACT_PERSON_ID		,
		l_pool_rec.PROGRAM_ID			,
		l_pool_rec.CREATION_DATE		,
		l_pool_rec.CREATED_BY			,
		l_pool_rec.LAST_UPDATE_DATE		,
		l_pool_rec.LAST_UPDATED_BY		,
		l_pool_rec.LAST_UPDATE_LOGIN		,
		l_pool_rec.ATTRIBUTE_CATEGORY		,
		l_pool_rec.ATTRIBUTE1			,
		l_pool_rec.ATTRIBUTE2			,
		l_pool_rec.ATTRIBUTE3			,
		l_pool_rec.ATTRIBUTE4			,
		l_pool_rec.ATTRIBUTE5			,
		l_pool_rec.ATTRIBUTE6			,
		l_pool_rec.ATTRIBUTE7			,
		l_pool_rec.ATTRIBUTE8			,
		l_pool_rec.ATTRIBUTE9			,
		l_pool_rec.ATTRIBUTE10			,
		l_pool_rec.ATTRIBUTE11			,
		l_pool_rec.ATTRIBUTE12			,
		l_pool_rec.ATTRIBUTE13			,
		l_pool_rec.ATTRIBUTE14			,
		l_pool_rec.ATTRIBUTE15			;

    x_no_data_found := pool_pk_csr%NOTFOUND;
    CLOSE pool_pk_csr;
	IF(x_no_data_found) THEN
      	OKE_API.set_message(G_APP_NAME,G_FORM_RECORD_DELETED);
	RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
	END IF;
    RETURN(l_pool_rec);

  END get_rec;



	-- row level insert
	-- will create using nextVal from sequence oke_funding_pools_s

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                      IN pool_rec_type,
    x_pool_rec                      OUT NOCOPY pool_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_pool_rec                      pool_rec_type;
    l_def_pool_rec                  pool_rec_type;
    lx_pool_rec                     pool_rec_type;
    l_seq			   NUMBER;
    l_row_id			   RowID;

    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pool_rec	IN pool_rec_type
    ) RETURN pool_rec_type IS

      l_pool_rec	pool_rec_type := p_pool_rec;

    BEGIN

      l_pool_rec.CREATION_DATE := SYSDATE;
      l_pool_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_pool_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pool_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pool_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pool_rec);

    END fill_who_columns;


	-- nothing much here. flags to UPPERCASE

    FUNCTION Set_Attributes (
      p_pool_rec IN  pool_rec_type,
      x_pool_rec OUT NOCOPY pool_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
	x_pool_rec := p_pool_rec;
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- insert
    --oke_debug.debug('start call oke_pool_pvt.insert_row');

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


   IF p_pool_rec.funding_pool_id <> OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --dbms_output.put_line('must not provide funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

    l_pool_rec := null_out_defaults(p_pool_rec);

    --oke_debug.debug(' called null out defaults');

    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_pool_rec,                        -- IN
      l_def_pool_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('attributes set for insert');

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_pool_rec := fill_who_columns(l_def_pool_rec);

    --oke_debug.debug('who column filled for insert');

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pool_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('attributes validated for insert');

    l_return_status := Validate_Record(l_def_pool_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('record validated for insert');

    SELECT OKE_FUNDING_POOLS_S.nextval  INTO l_seq FROM dual;

    OKE_FUNDING_POOLS_PKG.Insert_Row
	(l_row_id,
	l_seq,
	l_def_pool_rec.NAME,
	l_def_pool_rec.DESCRIPTION,
	l_def_pool_rec.CURRENCY_CODE,
	l_def_pool_rec.CONTACT_PERSON_ID,
	l_def_pool_rec.PROGRAM_ID,
 	l_def_pool_rec.LAST_UPDATE_DATE     ,
 	l_def_pool_rec.LAST_UPDATED_BY      ,
 	l_def_pool_rec.CREATION_DATE        ,
 	l_def_pool_rec.CREATED_BY           ,
 	l_def_pool_rec.LAST_UPDATE_LOGIN    ,
 	l_def_pool_rec.ATTRIBUTE_CATEGORY   ,
 	l_def_pool_rec.ATTRIBUTE1           ,
 	l_def_pool_rec.ATTRIBUTE2           ,
 	l_def_pool_rec.ATTRIBUTE3           ,
 	l_def_pool_rec.ATTRIBUTE4           ,
 	l_def_pool_rec.ATTRIBUTE5           ,
 	l_def_pool_rec.ATTRIBUTE6           ,
 	l_def_pool_rec.ATTRIBUTE7           ,
 	l_def_pool_rec.ATTRIBUTE8           ,
 	l_def_pool_rec.ATTRIBUTE9           ,
 	l_def_pool_rec.ATTRIBUTE10          ,
 	l_def_pool_rec.ATTRIBUTE11          ,
 	l_def_pool_rec.ATTRIBUTE12          ,
 	l_def_pool_rec.ATTRIBUTE13          ,
 	l_def_pool_rec.ATTRIBUTE14          ,
 	l_def_pool_rec.ATTRIBUTE15
	);

    --oke_debug.debug('record inserted');
    -- Set OUT values
    x_pool_rec := l_def_pool_rec;
    x_pool_rec.FUNDING_POOL_ID:=l_seq;

    --oke_debug.debug('end call oke_pool_pvt.insert_row');
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
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                      IN pool_tbl_type,
    x_pool_tbl                      OUT NOCOPY pool_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    --oke_debug.debug('start call oke_pool_pvt.insert_row');

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


    -- Make sure PL/SQL table has records in it before passing
    IF (p_pool_tbl.COUNT > 0) THEN
      i := p_pool_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_pool_rec                      => p_pool_tbl(i),
          x_pool_rec                      => x_pool_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_pool_tbl.LAST);

        i := p_pool_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
   --oke_debug.debug('end call oke_pool_pvt.insert_row');
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
  END insert_row; -- table level








  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                      IN pool_rec_type,
    x_pool_rec                      OUT NOCOPY pool_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_pool_rec                      pool_rec_type := p_pool_rec;
    l_def_pool_rec                  pool_rec_type;
    lx_pool_rec                     pool_rec_type;
    l_temp			NUMBER;

Cursor l_csr_id IS
	select funding_pool_id
	from oke_funding_pools
	where funding_pool_id=p_pool_rec.funding_pool_id;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_pool_rec	IN pool_rec_type
    ) RETURN pool_rec_type IS

      l_pool_rec	pool_rec_type := p_pool_rec;

    BEGIN
      l_pool_rec.LAST_UPDATE_DATE := SYSDATE;
      l_pool_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_pool_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_pool_rec);
    END fill_who_columns;

    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_pool_rec	IN pool_rec_type,
      x_pool_rec	OUT NOCOPY pool_rec_type
    ) RETURN VARCHAR2 IS

      l_pool_rec                     pool_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;

    BEGIN

      x_pool_rec := p_pool_rec;

      l_pool_rec := get_rec(p_pool_rec, l_row_notfound);

      IF (l_row_notfound) THEN
        l_return_status := OKE_API.G_RET_STS_UNEXP_ERROR;
      END IF;

	IF x_pool_rec.NAME = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.NAME := l_pool_rec.NAME;
    	END IF;

	IF x_pool_rec.DESCRIPTION = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.DESCRIPTION := l_pool_rec.DESCRIPTION;
    	END IF;

	IF x_pool_rec.CURRENCY_CODE = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.CURRENCY_CODE := l_pool_rec.CURRENCY_CODE;
    	END IF;

	IF x_pool_rec.CONTACT_PERSON_ID = OKE_API.G_MISS_NUM THEN
	  x_pool_rec.CONTACT_PERSON_ID := l_pool_rec.CONTACT_PERSON_ID;
    	END IF;

	IF x_pool_rec.PROGRAM_ID = OKE_API.G_MISS_NUM THEN
	  x_pool_rec.PROGRAM_ID := l_pool_rec.PROGRAM_ID;
    	END IF;


	IF x_pool_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	  x_pool_rec.CREATION_DATE := l_pool_rec.CREATION_DATE;
    	END IF;

	IF x_pool_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	  x_pool_rec.CREATED_BY := l_pool_rec.CREATED_BY;
    	END IF;

	IF x_pool_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	  x_pool_rec.LAST_UPDATE_DATE := l_pool_rec.LAST_UPDATE_DATE;
    	END IF;

	IF x_pool_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	  x_pool_rec.LAST_UPDATED_BY  := l_pool_rec.LAST_UPDATED_BY ;
    	END IF;

	IF x_pool_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	  x_pool_rec.LAST_UPDATE_LOGIN := l_pool_rec.LAST_UPDATE_LOGIN;
    	END IF;

	IF x_pool_rec.ATTRIBUTE_CATEGORY = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE_CATEGORY := l_pool_rec.ATTRIBUTE_CATEGORY;
    	END IF;

	IF x_pool_rec.ATTRIBUTE1 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE1 := l_pool_rec.ATTRIBUTE1;
    	END IF;

	IF x_pool_rec.ATTRIBUTE2 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE2 := l_pool_rec.ATTRIBUTE2;
    	END IF;

	IF x_pool_rec.ATTRIBUTE3 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE3 := l_pool_rec.ATTRIBUTE3;
    	END IF;

	IF x_pool_rec.ATTRIBUTE4 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE4 := l_pool_rec.ATTRIBUTE4;
    	END IF;

	IF x_pool_rec.ATTRIBUTE5 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE5 := l_pool_rec.ATTRIBUTE5;
    	END IF;

	IF x_pool_rec.ATTRIBUTE6 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE6 := l_pool_rec.ATTRIBUTE6;
    	END IF;

	IF x_pool_rec.ATTRIBUTE7 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE7 := l_pool_rec.ATTRIBUTE7;
    	END IF;

 	IF x_pool_rec.ATTRIBUTE8 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE8 := l_pool_rec.ATTRIBUTE8;
    	END IF;

	IF x_pool_rec.ATTRIBUTE9 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE9 := l_pool_rec.ATTRIBUTE9;
    	END IF;

	IF x_pool_rec.ATTRIBUTE10 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE10 := l_pool_rec.ATTRIBUTE10;
    	END IF;

	IF x_pool_rec.ATTRIBUTE11 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE11 := l_pool_rec.ATTRIBUTE11;
    	END IF;

	IF x_pool_rec.ATTRIBUTE12 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE12 := l_pool_rec.ATTRIBUTE12;
    	END IF;

	IF x_pool_rec.ATTRIBUTE13 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE13 := l_pool_rec.ATTRIBUTE13;
    	END IF;

	IF x_pool_rec.ATTRIBUTE14 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE14 := l_pool_rec.ATTRIBUTE14;
    	END IF;

	IF x_pool_rec.ATTRIBUTE15 = OKE_API.G_MISS_CHAR THEN
	  x_pool_rec.ATTRIBUTE15 := l_pool_rec.ATTRIBUTE15;
    	END IF;

    RETURN(l_return_status);

  END populate_new_record;



  FUNCTION set_attributes(
	      p_pool_rec IN  pool_rec_type,
              x_pool_rec OUT NOCOPY pool_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
      	x_pool_rec := p_pool_rec;
      RETURN(l_return_status);

    END Set_Attributes;


  BEGIN  -- update row

    --oke_debug.debug('start call oke_pool_pvt.update_row');

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


   IF p_pool_rec.funding_pool_id = OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --dbms_output.put_line('must provide funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --dbms_output.put_line('must provide valid funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;

    l_return_status := Set_Attributes(
      p_pool_rec,                        -- IN
      l_pool_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('attributes set');


    -- check if user is trying to update attributes
    -- that should not be updated

	If( l_pool_rec.CURRENCY_CODE <> OKE_API.G_MISS_CHAR) Then
	  OKE_API.SET_MESSAGE(
	   p_app_name =>g_app_name,
	   p_msg_name =>G_INVALID_VALUE,
	   p_token1 => g_col_name_token,
	   p_token1_value=>'CURRENCY_CODE');
	   raise OKE_API.G_EXCEPTION_ERROR;
	End If;



    l_return_status := populate_new_record(l_pool_rec, l_def_pool_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('record populated');

    l_def_pool_rec := fill_who_columns(l_def_pool_rec);

--oke_debug.debug('who column filled');

    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_pool_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

--oke_debug.debug('attributes validated');

    l_return_status := Validate_Record(l_def_pool_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

     --oke_debug.debug('update base table');


    OKE_FUNDING_POOLS_PKG.update_row(
	l_def_pool_rec.FUNDING_POOL_ID,
	l_def_pool_rec.NAME,
	l_def_pool_rec.DESCRIPTION,
	l_def_pool_rec.CONTACT_PERSON_ID,
	l_def_pool_rec.PROGRAM_ID,

	l_def_pool_rec.LAST_UPDATE_DATE,
	l_def_pool_rec.LAST_UPDATED_BY,
	l_def_pool_rec.LAST_UPDATE_LOGIN,

	l_def_pool_rec.ATTRIBUTE_CATEGORY,
	l_def_pool_rec.ATTRIBUTE1,
	l_def_pool_rec.ATTRIBUTE2,
	l_def_pool_rec.ATTRIBUTE3,
	 l_def_pool_rec.ATTRIBUTE4,
	l_def_pool_rec.ATTRIBUTE5,
	l_def_pool_rec.ATTRIBUTE6,
	l_def_pool_rec.ATTRIBUTE7,
	l_def_pool_rec.ATTRIBUTE8,
	l_def_pool_rec.ATTRIBUTE9,
	l_def_pool_rec.ATTRIBUTE10,
	l_def_pool_rec.ATTRIBUTE11,
	l_def_pool_rec.ATTRIBUTE12,
	l_def_pool_rec.ATTRIBUTE13,
	l_def_pool_rec.ATTRIBUTE14,
	l_def_pool_rec.ATTRIBUTE15 );

    x_pool_rec := l_def_pool_rec;
    --oke_debug.debug('end call oke_pool_pvt.update_row');
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
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN pool_tbl_type,
    x_pool_tbl                     OUT NOCOPY pool_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN


    --oke_debug.debug('start call oke_pool_pvt.update_row');

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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_pool_tbl.COUNT > 0) THEN
      i := p_pool_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pool_rec                      => p_pool_tbl(i),
          x_pool_rec                     => x_pool_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_pool_tbl.LAST);
        i := p_pool_tbl.NEXT(i);
      END LOOP;
	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
    --oke_debug.debug('end call oke_pool_pvt.update_row');
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
  END update_row;  -- table level update


	-- deletes by the funding_pool_id

  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                     IN pool_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_pool_rec                     pool_rec_type := p_pool_rec;
    l_temp			NUMBER;

Cursor l_csr_id IS
	select funding_pool_id
	from oke_funding_pools
	where funding_pool_id=p_pool_rec.funding_pool_id;

  BEGIN
  --oke_debug.debug('start call oke_pool_pvt.delete_row');

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

   IF p_pool_rec.funding_pool_id = OKE_API.G_MISS_NUM THEN
     		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --dbms_output.put_line('must provide funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;

    OPEN l_csr_id;
    FETCH l_csr_id INTO l_temp;
    IF l_csr_id%NOTFOUND THEN
		OKE_API.SET_MESSAGE(
       		p_app_name		=>g_app_name,
 		p_msg_name		=>g_invalid_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'funding_pool_id');
        --dbms_output.put_line('must provide valid funding_pool_id');
	RAISE OKE_API.G_EXCEPTION_ERROR;
   END IF;
   CLOSE l_csr_id;


	DELETE FROM OKE_FUNDING_POOLS
	WHERE FUNDING_POOL_ID = p_pool_rec.FUNDING_POOL_ID;

    --oke_debug.debug('end call oke_pool_pvt.delete_row');
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
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_tbl                     IN pool_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
  --oke_debug.debug('start call oke_pool_pvt.delete_row');

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

    -- Make sure PL/SQL table has records in it before passing
    IF (p_pool_tbl.COUNT > 0) THEN
      i := p_pool_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_pool_rec                      => p_pool_tbl(i));



	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_pool_tbl.LAST);
        i := p_pool_tbl.NEXT(i);
      END LOOP;

	 -- return overall status
	 x_return_status := l_overall_status;
    END IF;
    --oke_debug.debug('end call oke_pool_pvt.delete_row');
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
  END delete_row; -- table level delete


  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_pool_rec                     IN pool_rec_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_row_notfound                BOOLEAN := FALSE;

    l_funding_pool_id		NUMBER;

	E_Resource_Busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


	CURSOR lock_csr (p IN pool_rec_type) IS
	SELECT funding_pool_id FROM oke_funding_pools a
	WHERE
	  a.funding_pool_id = p.funding_pool_id
	FOR UPDATE NOWAIT;


BEGIN
  --oke_debug.debug('start call oke_pool_pvt.lock_row');

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


    BEGIN
      OPEN lock_csr(p_pool_rec);
      FETCH lock_csr INTO l_funding_pool_id;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;


    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKE_API.set_message(G_APP_NAME,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;


    IF (l_row_notfound) THEN
      OKE_API.set_message(G_APP_NAME,G_FORM_RECORD_DELETED);
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    --oke_debug.debug('end call oke_pool_pvt.lock_row');
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


END OKE_POOL_PVT;


/
