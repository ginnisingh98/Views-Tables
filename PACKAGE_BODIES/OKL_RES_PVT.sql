--------------------------------------------------------
--  DDL for Package Body OKL_RES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_RES_PVT" AS
  /* $Header: OKLSRESB.pls 120.0 2005/07/08 14:26:06 smadhava noship $ */

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

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_FE_RESI_CAT_OBJECTS
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_res_rec	IN okl_res_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_res_rec IS
   CURSOR rcv_pk_csr(p_id IN NUMBER) IS
   SELECT
	RESI_CAT_OBJECT_ID,
        OBJECT_VERSION_NUMBER,
	RESI_CATEGORY_SET_ID,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	CATEGORY_ID,
	CATEGORY_SET_ID
   FROM OKL_FE_RESI_CAT_OBJECTS WHERE OKL_FE_RESI_CAT_OBJECTS.RESI_CAT_OBJECT_ID=p_id;
  l_res_pk	rcv_pk_csr%ROWTYPE;
  l_res_rec	okl_res_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN rcv_pk_csr(p_res_rec.resi_cat_object_id);
  FETCH rcv_pk_csr INTO
	l_res_rec.RESI_CAT_OBJECT_ID,
	l_res_rec.OBJECT_VERSION_NUMBER,
	l_res_rec.RESI_CATEGORY_SET_ID,
	l_res_rec.CREATED_BY,
	l_res_rec.CREATION_DATE,
	l_res_rec.LAST_UPDATED_BY,
	l_res_rec.LAST_UPDATE_DATE,
	l_res_rec.LAST_UPDATE_LOGIN,
	l_res_rec.INVENTORY_ITEM_ID,
	l_res_rec.ORGANIZATION_ID,
	l_res_rec.CATEGORY_ID,
	l_res_rec.CATEGORY_SET_ID;
	  x_no_data_found := rcv_pk_csr%NOTFOUND;
  CLOSE rcv_pk_csr;
  RETURN (l_res_rec);
 END get_rec;
 FUNCTION get_rec(
  p_res_rec	IN okl_res_rec
 )RETURN okl_res_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_res_rec,l_row_notfound));
 END get_rec;

 FUNCTION null_out_defaults(
 p_res_rec IN okl_res_rec
 ) RETURN okl_res_rec IS
 l_res_rec	okl_res_rec:= p_res_rec;
 BEGIN
	IF (l_res_rec.RESI_CAT_OBJECT_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.RESI_CAT_OBJECT_ID:=NULL;
	END IF;
	IF (l_res_rec.OBJECT_VERSION_NUMBER=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.OBJECT_VERSION_NUMBER:=NULL;
	END IF;
	IF (l_res_rec.INVENTORY_ITEM_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.INVENTORY_ITEM_ID:=NULL;
	END IF;
	IF (l_res_rec.ORGANIZATION_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.ORGANIZATION_ID:=NULL;
	END IF;
	IF (l_res_rec.CATEGORY_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.CATEGORY_ID:=NULL;
	END IF;
	IF (l_res_rec.CATEGORY_SET_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.CATEGORY_SET_ID:=NULL;
	END IF;
	IF (l_res_rec.RESI_CATEGORY_SET_ID=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.RESI_CATEGORY_SET_ID:=NULL;
	END IF;
	IF (l_res_rec.CREATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.CREATED_BY:=NULL;
	END IF;
	IF (l_res_rec.CREATION_DATE=OKL_API.G_MISS_DATE) THEN
	 l_res_rec.CREATION_DATE:=NULL;
	END IF;
	IF (l_res_rec.LAST_UPDATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.LAST_UPDATED_BY:=NULL;
	END IF;
	IF (l_res_rec.LAST_UPDATE_DATE=OKL_API.G_MISS_DATE) THEN
	 l_res_rec.LAST_UPDATE_DATE:=NULL;
	END IF;
	IF (l_res_rec.LAST_UPDATE_LOGIN=OKL_API.G_MISS_NUM) THEN
	 l_res_rec.LAST_UPDATE_LOGIN:=NULL;
	END IF;
  RETURN(l_res_rec);
 END null_out_defaults;

 FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
	RETURN(okc_p_util.raw_to_number(sys_guid()));
	END get_seq_id;

  ---------------------------------
  -- FUNCTION validate_resi_cat_object_id
  ---------------------------------
  FUNCTION validate_resi_cat_object_id (p_resi_cat_object_id IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_resi_cat_object_id';
  BEGIN
    IF p_resi_cat_object_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'resi_cat_object_id');
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
  END validate_resi_cat_object_id;


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

  ---------------------------------
  -- FUNCTION validate_resi_category_set_id
  ---------------------------------
  FUNCTION validate_resi_category_set_id (p_resi_category_set_id IN NUMBER) Return Varchar2 IS
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


 FUNCTION Validate_Attributes (
 p_res_rec IN okl_res_rec
 ) RETURN VARCHAR2 IS
   l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_attributes';
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
    -- ***
    -- resi_cat_object_id
    -- ***
    l_return_status := validate_resi_cat_object_id(p_res_rec.resi_cat_object_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- ***
    -- object_version_number
    -- ***
    l_return_status := validate_object_version_number(p_res_rec.object_version_number);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    -- ***
    -- resi_category_set_id
    -- ***
    l_return_status := validate_resi_category_set_id(p_res_rec.resi_category_set_id);

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
 p_res_rec IN okl_res_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
	RETURN (x_return_status);
   END Validate_Record;

--------------------------------------------------------------------------------
-- Procedure insert_row_v
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec,
	 x_res_rec			 OUT NOCOPY okl_res_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_res_rec			okl_res_rec;
l_def_res_rec			okl_res_rec;
l_rcvrec			okl_res_rec;
lx_res_rec			okl_res_rec;

 FUNCTION fill_who_columns(
 p_res_rec	IN okl_res_rec
 )RETURN okl_res_rec IS
l_res_rec okl_res_rec:=p_res_rec;
 BEGIN
   l_res_rec.CREATION_DATE := SYSDATE;
  l_res_rec.CREATED_BY := FND_GLOBAL.USER_ID;
  l_res_rec.LAST_UPDATE_DATE := SYSDATE;
  l_res_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_res_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_res_rec);
 END fill_who_columns;

 FUNCTION Set_Attributes(
	p_res_rec IN okl_res_rec,
	x_res_rec OUT NOCOPY okl_res_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_res_rec := p_res_rec;
 RETURN (l_return_status);
 END Set_Attributes;
   BEGIN
	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
							G_PKG_NAME,
							p_init_msg_list,
							l_api_version,
							p_api_version,
							'_PVT',
							x_return_status);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_res_rec:=null_out_defaults(p_res_rec);
	-- Set Primary key value
	l_res_rec.RESI_CAT_OBJECT_ID := get_seq_id;
	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_res_rec,l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
	l_def_res_rec := fill_who_columns(l_def_res_rec);

	l_return_status := Validate_Attributes(l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := Validate_Record(l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;
	INSERT INTO OKL_FE_RESI_CAT_OBJECTS(
	   RESI_CAT_OBJECT_ID,
	   OBJECT_VERSION_NUMBER,
	   RESI_CATEGORY_SET_ID,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN,
	   INVENTORY_ITEM_ID,
	   ORGANIZATION_ID,
	   CATEGORY_ID,
	   CATEGORY_SET_ID)
	VALUES (
	   l_def_res_rec.RESI_CAT_OBJECT_ID,
	   l_def_res_rec.OBJECT_VERSION_NUMBER,
	   l_def_res_rec.RESI_CATEGORY_SET_ID,
	   l_def_res_rec.CREATED_BY,
	   l_def_res_rec.CREATION_DATE,
	   l_def_res_rec.LAST_UPDATED_BY,
	   l_def_res_rec.LAST_UPDATE_DATE,
	   l_def_res_rec.LAST_UPDATE_LOGIN,
	   l_def_res_rec.INVENTORY_ITEM_ID,
	   l_def_res_rec.ORGANIZATION_ID,
	   l_def_res_rec.CATEGORY_ID,
	   l_def_res_rec.CATEGORY_SET_ID);
	--Set OUT Values
	x_res_rec:= l_def_res_rec;
	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl,
	 x_res_tbl			 OUT NOCOPY okl_res_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKC_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_res_tbl.COUNT > 0) THEN
	  i := p_res_tbl.FIRST;
	 LOOP
	   insert_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKC_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_res_rec			=> p_res_tbl(i),
		x_res_rec			=> x_res_tbl(i));
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_res_tbl.LAST);
	i := p_res_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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


 -----------------
  -- lock_row (REC)
  -----------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_def_res_rec                  IN  okl_res_rec) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (REC)';

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_def_res_rec IN okl_res_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_RESI_CAT_OBJECTS
     WHERE RESI_CAT_OBJECT_ID = p_def_res_rec.resi_cat_object_id
       AND OBJECT_VERSION_NUMBER = p_def_res_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_def_res_rec IN okl_res_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_RESI_CAT_OBJECTS
     WHERE RESI_CAT_OBJECT_ID = p_def_res_rec.resi_cat_object_id;

    l_return_status                VARCHAR2(1);
    l_object_version_number        OKL_FE_RESI_CAT_OBJECTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_FE_RESI_CAT_OBJECTS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;

  BEGIN

    BEGIN
      OPEN lock_csr(p_def_res_rec);
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
      OPEN lchk_csr(p_def_res_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_def_res_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_def_res_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;


  -----------------
  -- lock_row (TBL)
  -----------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    okl_res_tbl                     IN okl_res_tbl) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (okl_res_tbl.COUNT > 0) THEN

      i := okl_res_tbl.FIRST;

      LOOP

        IF okl_res_tbl.EXISTS(i) THEN

          lock_row (p_api_version                  => G_API_VERSION,
                    p_init_msg_list                => G_FALSE,
                    x_return_status                => l_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_def_res_rec                     => okl_res_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = okl_res_tbl.LAST);
          i := okl_res_tbl.NEXT(i);

        END IF;

      END LOOP;

    END IF;

    x_return_status := l_return_status;

  EXCEPTION

    WHEN OKL_API.G_EXCEPTION_ERROR THEN

      x_return_status := G_RET_STS_ERROR;

    WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN

      x_return_status := G_RET_STS_UNEXP_ERROR;

    WHEN OTHERS THEN

      OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                           p_msg_name     => G_DB_ERROR,
                           p_token1       => G_PROG_NAME_TOKEN,
                           p_token1_value => l_api_name,
                           p_token2       => G_SQLCODE_TOKEN,
                           p_token2_value => sqlcode,
                           p_token3       => G_SQLERRM_TOKEN,
                           p_token3_value => sqlerrm);

      x_return_status := G_RET_STS_UNEXP_ERROR;

  END lock_row;

--------------------------------------------------------------------------------
-- Procedure update_row
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec,
	 x_res_rec			 OUT NOCOPY okl_res_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_res_rec			okl_res_rec:=p_res_rec;
l_def_res_rec			okl_res_rec;
l_rcvrec			okl_res_rec;
lx_res_rec			okl_res_rec;

 FUNCTION fill_who_columns(
 p_res_rec	IN okl_res_rec
 )RETURN okl_res_rec IS
l_res_rec 	okl_res_rec:=p_res_rec;
 BEGIN
   l_res_rec .LAST_UPDATE_DATE := SYSDATE;
  l_res_rec .LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_res_rec .LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_res_rec );
 END fill_who_columns;
 FUNCTION populate_new_record(
	p_res_rec	IN okl_res_rec,
	x_res_rec	OUT NOCOPY okl_res_rec
	)RETURN VARCHAR2 is
	l_res_rec	okl_res_rec;
	l_row_notfound	BOOLEAN:=TRUE;
	l_return_status	VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	 BEGIN

	x_res_rec := p_res_rec;
	--Get current database values
	l_res_rec := get_rec(p_res_rec,l_row_notfound);
	IF(l_row_notfound) THEN
	 l_return_status:= OKL_API.G_RET_STS_UNEXP_ERROR;
  END IF;

	IF (x_res_rec.RESI_CAT_OBJECT_ID IS NULL)
	THEN
	 x_res_rec.RESI_CAT_OBJECT_ID:=l_res_rec.RESI_CAT_OBJECT_ID;
	END IF;
	IF (x_res_rec.OBJECT_VERSION_NUMBER IS NULL)
	THEN
	 x_res_rec.OBJECT_VERSION_NUMBER:=l_res_rec.OBJECT_VERSION_NUMBER;
	END IF;
	IF (x_res_rec.INVENTORY_ITEM_ID IS NULL)
	THEN
	 x_res_rec.INVENTORY_ITEM_ID:=l_res_rec.INVENTORY_ITEM_ID;
	END IF;
	IF (x_res_rec.ORGANIZATION_ID IS NULL)
	THEN
	 x_res_rec.ORGANIZATION_ID:=l_res_rec.ORGANIZATION_ID;
	END IF;
	IF (x_res_rec.CATEGORY_ID IS NULL)
	THEN
	 x_res_rec.CATEGORY_ID:=l_res_rec.CATEGORY_ID;
	END IF;
	IF (x_res_rec.CATEGORY_SET_ID IS NULL)
	THEN
	 x_res_rec.CATEGORY_SET_ID:=l_res_rec.CATEGORY_SET_ID;
	END IF;
	IF (x_res_rec.RESI_CATEGORY_SET_ID IS NULL)
	THEN
	 x_res_rec.RESI_CATEGORY_SET_ID:=l_res_rec.RESI_CATEGORY_SET_ID;
	END IF;
	IF (x_res_rec.CREATED_BY IS NULL)
	THEN
	 x_res_rec.CREATED_BY:=l_res_rec.CREATED_BY;
	END IF;
	IF (x_res_rec.CREATION_DATE IS NULL)
	THEN
	 x_res_rec.CREATION_DATE:=l_res_rec.CREATION_DATE;
	END IF;
	IF (x_res_rec.LAST_UPDATED_BY IS NULL)
	THEN
	 x_res_rec.LAST_UPDATED_BY:=l_res_rec.LAST_UPDATED_BY;
	END IF;
	IF (x_res_rec.LAST_UPDATE_DATE IS NULL)
	THEN
	 x_res_rec.LAST_UPDATE_DATE:=l_res_rec.LAST_UPDATE_DATE;
	END IF;
	IF (x_res_rec.LAST_UPDATE_LOGIN IS NULL)
	THEN
	 x_res_rec.LAST_UPDATE_LOGIN:=l_res_rec.LAST_UPDATE_LOGIN;
	END IF;
	RETURN(l_return_status);
   END populate_new_record;

 FUNCTION Set_Attributes(
	p_res_rec IN okl_res_rec,
	x_res_rec OUT NOCOPY okl_res_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
	BEGIN
		x_res_rec := p_res_rec;
 RETURN (l_return_status);
 END Set_Attributes;
   BEGIN
	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
							G_PKG_NAME,
							p_init_msg_list,
							l_api_version,
							p_api_version,
							'_PVT',
							x_return_status);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_res_rec,l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_return_status := populate_new_record(l_res_rec,l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;


	l_def_res_rec := fill_who_columns(l_def_res_rec);

	l_return_status := Validate_Attributes(l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	l_return_status := Validate_Record(l_def_res_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	-- Lock the row before updating
    lock_row(p_api_version    => G_API_VERSION,
             p_init_msg_list  => G_FALSE,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_def_res_rec    => l_def_res_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

UPDATE OKL_FE_RESI_CAT_OBJECTS
 SET
	RESI_CAT_OBJECT_ID= l_def_res_rec.RESI_CAT_OBJECT_ID,
	OBJECT_VERSION_NUMBER=l_def_res_rec.OBJECT_VERSION_NUMBER+1,
	RESI_CATEGORY_SET_ID= l_def_res_rec.RESI_CATEGORY_SET_ID,
	CREATED_BY= l_def_res_rec.CREATED_BY,
	CREATION_DATE= l_def_res_rec.CREATION_DATE,
	LAST_UPDATED_BY= l_def_res_rec.LAST_UPDATED_BY,
	LAST_UPDATE_DATE= l_def_res_rec.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN= l_def_res_rec.LAST_UPDATE_LOGIN,
	INVENTORY_ITEM_ID= l_def_res_rec.INVENTORY_ITEM_ID,
	ORGANIZATION_ID= l_def_res_rec.ORGANIZATION_ID,
	CATEGORY_ID= l_def_res_rec.CATEGORY_ID,
	CATEGORY_SET_ID= l_def_res_rec.CATEGORY_SET_ID
 WHERE RESI_CAT_OBJECT_ID = l_def_res_rec.RESI_CAT_OBJECT_ID;

	--Set OUT Values
	x_res_rec:= l_def_res_rec;
	OKC_API.END_ACTIVITY(x_msg_count, x_msg_data);

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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
-- Procedure insert_row_tbl
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl,
	 x_res_tbl			 OUT NOCOPY okl_res_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKC_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_res_tbl.COUNT > 0) THEN
	  i := p_res_tbl.FIRST;
	 LOOP
	   update_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKC_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_res_rec			=> p_res_tbl(i),
		x_res_rec			=> x_res_tbl(i));
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_res_tbl.LAST);
	i := p_res_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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
-- Procedure delete_row
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_rec			 IN okl_res_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_res_rec			okl_res_rec := p_res_rec;
	l_row_notfound			BOOLEAN:=TRUE;

   BEGIN
	l_return_status := OKC_API.START_ACTIVITY(l_api_name,
							G_PKG_NAME,
							p_init_msg_list,
							l_api_version,
							p_api_version,
							'_PVT',
							x_return_status);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKC_API.G_EXCEPTION_ERROR;
	END IF;

	DELETE FROM OKL_FE_RESI_CAT_OBJECTS
	WHERE RESI_CAT_OBJECT_ID=l_res_rec.RESI_CAT_OBJECT_ID;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKC_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_res_tbl			 IN okl_res_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKC_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_res_tbl.COUNT > 0) THEN
	  i := p_res_tbl.FIRST;
	 LOOP
	   delete_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKC_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_res_rec			=> p_res_tbl(i));
	IF x_return_status <> OKC_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKC_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_res_tbl.LAST);
	i := p_res_tbl.NEXT(i);
	END LOOP;
	x_return_status := l_overall_status;
	END IF;

	EXCEPTION
	  WHEN G_EXCEPTION_HALT_VALIDATION then
	-- No action necessary. Validation can continue to next attribute/column
		 null;

	  WHEN OKC_API.G_EXCEPTION_ERROR THEN
		x_return_status := OKL_API.HANDLE_EXCEPTIONS
		(
			l_api_name,
			G_PKG_NAME,
			'OKL_API.G_RET_STS_ERROR',
			x_msg_count,
			x_msg_data,
			'_PVT'
		);

	  WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
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
END OKL_RES_PVT;

/
