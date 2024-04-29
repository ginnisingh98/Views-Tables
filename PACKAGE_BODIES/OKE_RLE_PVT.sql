--------------------------------------------------------
--  DDL for Package Body OKE_RLE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_RLE_PVT" AS
/* $Header: OKEVRLEB.pls 115.13 2002/11/20 20:43:07 who ship $ */

-- validate record

  FUNCTION validate_record (
    p_rle_rec IN rle_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
  BEGIN

    RETURN(l_return_status);

  END validate_record;

-- validate individual attributes

  FUNCTION validate_attributes(
    p_rle_rec IN  rle_rec_type
  ) RETURN VARCHAR2 IS

    l_return_status	VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    x_return_status VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;


  PROCEDURE validate_k_header_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_rle_rec   IN  rle_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_HEADERS
	WHERE K_HEADER_ID = p_rle_rec.K_HEADER_ID;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_rle_rec.k_header_id = OKE_API.G_MISS_NUM
     	OR     p_rle_rec.k_header_id IS NULL) THEN
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


  PROCEDURE validate_change_request_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_rle_rec   IN  rle_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_CHG_REQUESTS
	WHERE CHG_REQUEST_ID = p_rle_rec.CHG_REQUEST_ID;

    BEGIN
	x_return_status := OKE_API.G_RET_STS_SUCCESS;
	IF (   p_rle_rec.chg_request_id <> OKE_API.G_MISS_NUM
     	AND p_rle_rec.chg_request_id IS NOT NULL) THEN

    	OPEN l_csr;
    	FETCH l_csr INTO l_dummy_val;
    	CLOSE l_csr;

    		IF (l_dummy_val = '?') THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_no_parent_record,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'CHANGE_REQUEST_ID',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKE_CHG_REQUESTS');

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
    END validate_change_request_id;





  PROCEDURE validate_related_entity_id(x_return_status OUT NOCOPY VARCHAR2,
			      p_rle_rec   IN  rle_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM OKE_K_HEADERS
	WHERE K_HEADER_ID = p_rle_rec.related_entity_id;

    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_rle_rec.related_entity_id = OKE_API.G_MISS_NUM
     	OR     p_rle_rec.related_entity_id IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'RELATED_ENTITY_ID');

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
		p_token1_value		=>'RELATED_ENTITY_ID',
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

    END validate_related_entity_id;


/*  PROCEDURE validate_version(x_return_status OUT NOCOPY VARCHAR2,
			      p_rle_rec   IN  rle_rec_type)IS

	l_dummy_val VARCHAR2(1):='?';
	CURSOR l_csr IS
	SELECT 'x'
	FROM
	((Select major_version
	 From OKE_K_VERS_NUMBERS_V
	 Where chr_id = p_rle_rec.related_entity_id)
	 UNION
	 (Select major_version
	  From OKE_K_HEADERS_H
	  Where k_header_id = p_rle_rec.related_entity_id)
	)
	WHERE  major_version  = p_rle_rec.related_entity_version;



    BEGIN

	x_return_status := OKE_API.G_RET_STS_SUCCESS;


	-- check required value - not null

	IF (   p_rle_rec.related_entity_version = OKE_API.G_MISS_NUM
     	OR     p_rle_rec.related_entity_version IS NULL) THEN
      		OKE_API.SET_MESSAGE(
        	p_app_name		=>g_app_name,
 		p_msg_name		=>g_required_value,
		p_token1		=>g_col_name_token,
		p_token1_value		=>'RELATED_ENTITY_VERSION');

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
		p_token1_value		=>'VERSION',
		p_token2		=>g_child_table_token,
		p_token2_value		=>G_VIEW,
		p_token3		=>g_parent_table_token,
		p_token3_value		=>'OKC_K_VERS_NUMBERS');

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

    END validate_version; */


  BEGIN

 validate_k_header_id (x_return_status => l_return_status,
                              p_rle_rec         =>  p_rle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

 validate_change_request_id (x_return_status => l_return_status,
                              p_rle_rec         =>  p_rle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

 validate_related_entity_id (x_return_status => l_return_status,
                              p_rle_rec         =>  p_rle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

/*  validate_version (x_return_status => l_return_status,
                              p_rle_rec         =>  p_rle_rec);
  IF l_return_status <> OKE_API.G_RET_STS_SUCCESS THEN
    IF x_return_status <> OKE_API.G_RET_STS_UNEXP_ERROR THEN
      x_return_status := l_return_status;
    END IF;
  END IF;   */

   /* call individual validation procedure */
	   -- return status to caller
        RETURN(x_return_status);

  END Validate_Attributes;

  FUNCTION null_out_defaults(
	 p_rle_rec	IN rle_rec_type ) RETURN rle_rec_type IS

  l_rle_rec rle_rec_type := p_rle_rec;

  BEGIN


    IF  l_rle_rec.K_HEADER_ID = OKE_API.G_MISS_NUM THEN
	l_rle_rec.K_HEADER_ID := NULL;
    END IF;

    IF  l_rle_rec.CHG_REQUEST_ID = OKE_API.G_MISS_NUM THEN
	l_rle_rec.CHG_REQUEST_ID := NULL;
    END IF;

    IF  l_rle_rec.RELATED_ENTITY_ID = OKE_API.G_MISS_NUM THEN
	l_rle_rec.RELATED_ENTITY_ID := NULL;
    END IF;

    IF  l_rle_rec.RELATED_ENTITY_VERSION = OKE_API.G_MISS_NUM THEN
    	l_rle_rec.RELATED_ENTITY_VERSION := NULL;
    END IF;

    IF	l_rle_rec.CREATED_BY = OKE_API.G_MISS_NUM THEN
	l_rle_rec.CREATED_BY := NULL;
    END IF;

    IF	l_rle_rec.CREATION_DATE = OKE_API.G_MISS_DATE THEN
	l_rle_rec.CREATION_DATE := NULL;
    END IF;

    IF	l_rle_rec.LAST_UPDATED_BY = OKE_API.G_MISS_NUM THEN
	l_rle_rec.LAST_UPDATED_BY := NULL;
    END IF;

    IF	l_rle_rec.LAST_UPDATE_LOGIN = OKE_API.G_MISS_NUM THEN
	l_rle_rec.LAST_UPDATE_LOGIN := NULL;
    END IF;

    IF	l_rle_rec.LAST_UPDATE_DATE = OKE_API.G_MISS_DATE THEN
	l_rle_rec.LAST_UPDATE_DATE := NULL;
    END IF;


    RETURN(l_rle_rec);

  END null_out_defaults;


	-- row level insert

  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKE_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rle_rec                      IN rle_rec_type,
    x_rle_rec                      OUT NOCOPY rle_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_rle_rec                      rle_rec_type;
    l_def_rle_rec                  rle_rec_type;
    lx_rle_rec                     rle_rec_type;



    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rle_rec	IN rle_rec_type
    ) RETURN rle_rec_type IS

      l_rle_rec	rle_rec_type := p_rle_rec;

    BEGIN

      l_rle_rec.CREATION_DATE := SYSDATE;
      l_rle_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rle_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rle_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rle_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rle_rec);

    END fill_who_columns;



    FUNCTION Set_Attributes (
      p_rle_rec IN  rle_rec_type,
      x_rle_rec OUT NOCOPY rle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
	x_rle_rec := p_rle_rec;

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


    l_rle_rec := null_out_defaults(p_rle_rec);



    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_rle_rec,                        -- IN
      l_def_rle_rec);                   -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    END IF;

    l_def_rle_rec := fill_who_columns(l_def_rle_rec);


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rle_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;

    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_return_status := Validate_Record(l_def_rle_rec);

    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    INSERT INTO OKE_K_RELATED_ENTITIES(

 	K_HEADER_ID          ,
 	CHG_REQUEST_ID ,
 	RELATED_ENTITY_ID ,
	RELATED_ENTITY_VERSION,
 	CREATION_DATE        ,
 	CREATED_BY           ,
 	LAST_UPDATE_DATE     ,
 	LAST_UPDATED_BY      ,
 	LAST_UPDATE_LOGIN
	)
    VALUES(
	l_def_rle_rec.K_HEADER_ID          ,
 	l_def_rle_rec.CHG_REQUEST_ID ,
 	l_def_rle_rec.RELATED_ENTITY_ID ,
 	l_def_rle_rec.RELATED_ENTITY_VERSION,
 	l_def_rle_rec.CREATION_DATE        ,
 	l_def_rle_rec.CREATED_BY           ,
 	l_def_rle_rec.LAST_UPDATE_DATE     ,
 	l_def_rle_rec.LAST_UPDATED_BY      ,
 	l_def_rle_rec.LAST_UPDATE_LOGIN
	);




    -- Set OUT values
    x_rle_rec := l_def_rle_rec;

    	SELECT rowid INTO x_rle_rec.ROW_ID
     	FROM OKE_K_RELATED_ENTITIES
	WHERE K_HEADER_ID=x_rle_rec.K_HEADER_ID
	AND
	(CHG_REQUEST_ID = x_rle_rec.CHG_REQUEST_ID
	 OR
	(CHG_REQUEST_ID IS NULL
		AND x_rle_rec.CHG_REQUEST_ID IS NULL))
	AND RELATED_ENTITY_ID = x_rle_rec.RELATED_ENTITY_ID
	AND
	(RELATED_ENTITY_VERSION = x_rle_rec.RELATED_ENTITY_VERSION
	 OR
	(RELATED_ENTITY_VERSION IS NULL
		AND x_rle_rec.RELATED_ENTITY_VERSION IS NULL));


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
    p_rle_tbl                      IN rle_tbl_type,
    x_rle_tbl                      OUT NOCOPY rle_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_insert_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rle_tbl.COUNT > 0) THEN
      i := p_rle_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,

          p_rle_rec                      => p_rle_tbl(i),
          x_rle_rec                      => x_rle_tbl(i));

		-- store the highest degree of error
	 If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	   If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	   End If;
	 End If;

        EXIT WHEN (i = p_rle_tbl.LAST);

        i := p_rle_tbl.NEXT(i);
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
    p_rle_rec                      IN rle_rec_type,
    x_rle_rec                      OUT NOCOPY rle_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_rle_rec                      rle_rec_type := p_rle_rec;
    l_def_rle_rec                  rle_rec_type;
    lx_rle_rec                     rle_rec_type;

    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rle_rec	IN rle_rec_type
    ) RETURN rle_rec_type IS

      l_rle_rec	rle_rec_type := p_rle_rec;

    BEGIN
      l_rle_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rle_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rle_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rle_rec);
    END fill_who_columns;



  FUNCTION set_attributes(
	      p_rle_rec IN  rle_rec_type,
              x_rle_rec OUT NOCOPY rle_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    BEGIN
      	x_rle_rec := p_rle_rec;
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
      p_rle_rec,                        -- IN
      l_rle_rec);                       -- OUT

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    l_def_rle_rec:=l_rle_rec;

    l_def_rle_rec := fill_who_columns(l_def_rle_rec);


    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rle_rec);

    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;

    l_return_status := Validate_Record(l_def_rle_rec);
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;


    UPDATE OKE_K_RELATED_ENTITIES
    SET
	K_HEADER_ID = l_def_rle_rec.K_HEADER_ID,
	CHG_REQUEST_ID = l_def_rle_rec.CHG_REQUEST_ID,
	RELATED_ENTITY_ID = l_def_rle_rec.RELATED_ENTITY_ID,
        RELATED_ENTITY_VERSION = l_def_rle_rec.RELATED_ENTITY_VERSION,
	CREATION_DATE	= l_def_rle_rec.CREATION_DATE,
	CREATED_BY = l_def_rle_rec.CREATED_BY,
	LAST_UPDATE_DATE = l_def_rle_rec.LAST_UPDATE_DATE,
	LAST_UPDATED_BY = l_def_rle_rec.LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = l_def_rle_rec.LAST_UPDATE_LOGIN
    WHERE
	rowid = l_def_rle_rec.ROW_ID;

    x_rle_rec := l_def_rle_rec;

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
    p_rle_tbl                     IN rle_tbl_type,
    x_rle_tbl                     OUT NOCOPY rle_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1.0;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_update_row';


    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN

    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rle_tbl.COUNT > 0) THEN
      i := p_rle_tbl.FIRST;
      LOOP

        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rle_rec                      => p_rle_tbl(i),
          x_rle_rec                     => x_rle_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_rle_tbl.LAST);
        i := p_rle_tbl.NEXT(i);
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
    p_rle_rec                     IN rle_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_rle_rec                     rle_rec_type := p_rle_rec;

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


    DELETE FROM OKE_K_RELATED_ENTITIES
    WHERE rowid = p_rle_rec.ROW_ID;

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
    p_rle_tbl                     IN rle_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_delete_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);

    -- Make sure PL/SQL table has records in it before passing
    IF (p_rle_tbl.COUNT > 0) THEN
      i := p_rle_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rle_rec                      => p_rle_tbl(i));



	-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	    l_overall_status := x_return_status;
          End If;
	End If;

        EXIT WHEN (i = p_rle_tbl.LAST);
        i := p_rle_tbl.NEXT(i);
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
    p_rle_rec           IN rle_rec_type
  ) IS

    l_api_version       CONSTANT NUMBER := 1;
    l_api_name          CONSTANT VARCHAR2(30) := 'B_validate_row';
    l_return_status     VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_rle_rec           rle_rec_type := p_rle_rec;

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
    l_return_status := Validate_Attributes(l_rle_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKE_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKE_API.G_RET_STS_ERROR) THEN
      RAISE OKE_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rle_rec);

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
    p_rle_tbl                      IN rle_tbl_type
    ) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'TBL_validate_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_overall_status               VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKE_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rle_tbl.COUNT > 0) THEN
      i := p_rle_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKE_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_rle_rec                     => p_rle_tbl(i));

		-- store the highest degree of error
	If x_return_status <> OKE_API.G_RET_STS_SUCCESS Then
	  If l_overall_status <> OKE_API.G_RET_STS_UNEXP_ERROR Then
	     l_overall_status := x_return_status;
	  End If;
	End If;

        EXIT WHEN (i = p_rle_tbl.LAST);
        i := p_rle_tbl.NEXT(i);
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
    p_rle_rec                     IN rle_rec_type) IS


    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'lock_row';
    l_return_status                VARCHAR2(1) := OKE_API.G_RET_STS_SUCCESS;
    l_row_notfound                BOOLEAN := FALSE;

    l_chr_id                       NUMBER;
    l_rle_id                       NUMBER;
    l_ver_id			   NUMBER;

	E_Resource_Busy		EXCEPTION;
	PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);


	CURSOR lock_csr (p IN rle_rec_type) IS
	SELECT k_header_id,related_entity_id,related_entity_version FROM oke_k_related_entities a
	WHERE  a.rowid = p.ROW_ID

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
      OPEN lock_csr(p_rle_rec);
      FETCH lock_csr INTO l_chr_id,l_rle_id,l_ver_id;
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


END OKE_RLE_PVT;


/
