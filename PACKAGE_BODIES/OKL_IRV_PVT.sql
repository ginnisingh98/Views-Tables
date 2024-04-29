--------------------------------------------------------
--  DDL for Package Body OKL_IRV_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IRV_PVT" AS
  /* $Header: OKLSIRVB.pls 120.1 2005/07/22 10:02:59 smadhava noship $ */

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
-- Procedure get_rec for OKL_FE_ITEM_RESDL_VALUES
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_irv_rec	IN okl_irv_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_irv_rec IS
   CURSOR irv_pk_csr(p_id IN NUMBER) IS
   SELECT
	ITEM_RESDL_VALUE_ID,
    OBJECT_VERSION_NUMBER,
    ITEM_RESIDUAL_ID,
	ITEM_RESDL_VERSION_ID,
	TERM_IN_MONTHS,
	RESIDUAL_VALUE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
   FROM OKL_FE_ITEM_RESDL_VALUES IRV WHERE IRV.item_resdl_value_id=p_id;
  l_irv_pk	irv_pk_csr%ROWTYPE;
  l_irv_rec	okl_irv_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN irv_pk_csr(p_irv_rec.item_resdl_value_id);
  FETCH irv_pk_csr INTO
	l_irv_rec.ITEM_RESDL_VALUE_ID,
	l_irv_rec.OBJECT_VERSION_NUMBER,
	l_irv_rec.ITEM_RESIDUAL_ID,
	l_irv_rec.ITEM_RESDL_VERSION_ID,
	l_irv_rec.TERM_IN_MONTHS,
	l_irv_rec.RESIDUAL_VALUE,
	l_irv_rec.CREATED_BY,
	l_irv_rec.CREATION_DATE,
	l_irv_rec.LAST_UPDATED_BY,
	l_irv_rec.LAST_UPDATE_DATE,
	l_irv_rec.LAST_UPDATE_LOGIN;
	  x_no_data_found := irv_pk_csr%NOTFOUND;
  CLOSE irv_pk_csr;
  RETURN (l_irv_rec);
 END get_rec;
 FUNCTION get_rec(
  p_irv_rec	IN okl_irv_rec
 )RETURN okl_irv_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_irv_rec,l_row_notfound));
 END get_rec;


 FUNCTION null_out_defaults(
 p_irv_rec IN okl_irv_rec
 ) RETURN okl_irv_rec IS
 l_irv_rec	okl_irv_rec:= p_irv_rec;
 BEGIN
	IF (l_irv_rec.ITEM_RESDL_VALUE_ID=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.ITEM_RESDL_VALUE_ID:=NULL;
	END IF;
	IF (l_irv_rec.OBJECT_VERSION_NUMBER=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.OBJECT_VERSION_NUMBER:=NULL;
	END IF;
	IF (l_irv_rec.ITEM_RESIDUAL_ID=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.ITEM_RESIDUAL_ID:=NULL;
	END IF;
	IF (l_irv_rec.ITEM_RESDL_VERSION_ID=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.ITEM_RESDL_VERSION_ID:=NULL;
	END IF;
	IF (l_irv_rec.TERM_IN_MONTHS=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.TERM_IN_MONTHS:=NULL;
	END IF;
	IF (l_irv_rec.RESIDUAL_VALUE=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.RESIDUAL_VALUE:=NULL;
	END IF;
	IF (l_irv_rec.CREATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.CREATED_BY:=NULL;
	END IF;
	IF (l_irv_rec.CREATION_DATE=OKL_API.G_MISS_DATE) THEN
	 l_irv_rec.CREATION_DATE:=NULL;
	END IF;
	IF (l_irv_rec.LAST_UPDATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.LAST_UPDATED_BY:=NULL;
	END IF;
	IF (l_irv_rec.LAST_UPDATE_DATE=OKL_API.G_MISS_DATE) THEN
	 l_irv_rec.LAST_UPDATE_DATE:=NULL;
	END IF;
	IF (l_irv_rec.LAST_UPDATE_LOGIN=OKL_API.G_MISS_NUM) THEN
	 l_irv_rec.LAST_UPDATE_LOGIN:=NULL;
	END IF;
  RETURN(l_irv_rec);
 END null_out_defaults;

 FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
	RETURN(okc_p_util.raw_to_number(sys_guid()));
	END get_seq_id;

  ---------------------------------
  -- FUNCTION validate_item_resdl_value_id
  ---------------------------------
  FUNCTION validate_item_resdl_value_id (p_item_resdl_value_id IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_item_resdl_value_id';
  BEGIN
    IF p_item_resdl_value_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'item_resdl_value_id');
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
  END validate_item_resdl_value_id;

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
  -- FUNCTION validate_item_resdl_version_id
  ---------------------------------
  FUNCTION validate_item_residual_id (p_item_residual_id IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_item_residual_id';
  BEGIN
    IF p_item_residual_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'item_residual_id');
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
  END validate_item_residual_id;

  ---------------------------------
  -- FUNCTION validate_item_resdl_version_id
  ---------------------------------
  FUNCTION validate_item_resdl_version_id (p_item_resdl_version_id IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_item_resdl_version_id';
  BEGIN
    IF p_item_resdl_version_id IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'item_resdl_version_id');
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
  END validate_item_resdl_version_id;

  ---------------------------------
  -- FUNCTION validate_term
  ---------------------------------
  FUNCTION validate_term (p_term IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_term';
  BEGIN
    IF p_term IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'term');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF p_term <=0 THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_INVALID_TERM');
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
  END validate_term;

  ---------------------------------
  -- FUNCTION validate_value
  ---------------------------------
  FUNCTION validate_value (p_value IN NUMBER, p_term IN NUMBER) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_value';
  BEGIN
    IF p_value IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'value');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF p_value < 0 THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => 'OKL_INVALID_VALUE',
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'Term ' || p_term );
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
  END validate_value;


 FUNCTION Validate_Attributes (
 p_irv_rec IN okl_irv_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_attributes';
    BEGIN

    -- ***
    -- item_resdl_value_id
    -- ***
    l_return_status := validate_item_resdl_value_id(p_irv_rec.item_resdl_value_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    l_return_status := validate_object_version_number(p_irv_rec.object_version_number);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- item_residual_id
    -- ***
    l_return_status := validate_item_residual_id(p_irv_rec.item_residual_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- item_resdl_version_id
    -- ***
    l_return_status := validate_item_resdl_version_id(p_irv_rec.item_resdl_version_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- term
    -- ***
    l_return_status := validate_term(p_irv_rec.term_in_months);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

    -- ***
    -- value
    -- ***
    l_return_status := validate_value(p_irv_rec.residual_value, p_irv_rec.term_in_months);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	RETURN (x_return_status);
   EXCEPTION
    WHEN OKL_API.G_EXCEPTION_ERROR THEN
      RETURN  G_RET_STS_ERROR;
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
 p_irv_rec IN okl_irv_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
    BEGIN
  	  RETURN (x_return_status);
   END Validate_Record;

 FUNCTION check_existence (
 p_irv_rec IN okl_irv_rec
 ) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_temp_item_resdl_version_id     NUMBER := NULL;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_existence';

  CURSOR l_irv_csr IS
        SELECT
            item_resdl_value_id
         FROM
             OKL_FE_ITEM_RESDL_VALUES IRV
         WHERE
              IRV.ITEM_RESDL_VERSION_ID         = p_irv_rec.item_resdl_version_id
          AND IRV.TERM_IN_MONTHS = p_irv_rec.term_in_months;
    BEGIN
      /* Check if a record is present for the same term */
      OPEN l_irv_csr;
       FETCH l_irv_csr INTO l_temp_item_resdl_version_id;
       IF l_irv_csr%FOUND THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_TRM_VAL_EXISTS');
         RAISE OKL_API.G_EXCEPTION_ERROR;
       END IF;
      CLOSE l_irv_csr;

  	  RETURN (x_return_status);
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

--------------------------------------------------------------------------------
-- Procedure insert_row
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec,
	 x_irv_rec			 OUT NOCOPY okl_irv_rec)IS

l_api_version			CONSTANT NUMBER:=1;
l_api_name			CONSTANT VARCHAR2(30):='insert_row';
l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_irv_rec			okl_irv_rec;
l_def_irv_rec			okl_irv_rec;

 FUNCTION fill_who_columns(
 p_irv_rec	IN okl_irv_rec
 )RETURN okl_irv_rec IS
  l_irv_rec okl_irv_rec:=p_irv_rec;
 BEGIN
  l_irv_rec.CREATION_DATE := SYSDATE;
  l_irv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
  l_irv_rec.LAST_UPDATE_DATE := SYSDATE;
  l_irv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_irv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_irv_rec);
 END fill_who_columns;

 FUNCTION Set_Attributes(
	p_irv_rec IN okl_irv_rec,
	x_irv_rec OUT NOCOPY okl_irv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_irv_rec := p_irv_rec;
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
	l_irv_rec:=null_out_defaults(p_irv_rec);
	-- Set Primary key value
	l_irv_rec.item_resdl_value_id := get_seq_id;
	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_irv_rec,l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	l_def_irv_rec := fill_who_columns(l_def_irv_rec);

	l_return_status := Validate_Attributes(l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := check_existence(l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := Validate_Record(l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	INSERT INTO OKL_FE_ITEM_RESDL_VALUES(
	   ITEM_RESDL_VALUE_ID,
	   OBJECT_VERSION_NUMBER,
       ITEM_RESIDUAL_ID,
	   ITEM_RESDL_VERSION_ID,
	   TERM_IN_MONTHS,
	   RESIDUAL_VALUE,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN)
	VALUES (
	   l_def_irv_rec.ITEM_RESDL_VALUE_ID,
	   l_def_irv_rec.OBJECT_VERSION_NUMBER,
	   l_def_irv_rec.ITEM_RESIDUAL_ID,
	   l_def_irv_rec.ITEM_RESDL_VERSION_ID,
	   l_def_irv_rec.TERM_IN_MONTHS,
	   l_def_irv_rec.RESIDUAL_VALUE,
	   l_def_irv_rec.CREATED_BY,
	   l_def_irv_rec.CREATION_DATE,
	   l_def_irv_rec.LAST_UPDATED_BY,
	   l_def_irv_rec.LAST_UPDATE_DATE,
	   l_def_irv_rec.LAST_UPDATE_LOGIN);


	--Set OUT Values
	x_irv_rec:= l_def_irv_rec;
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
-- Procedure insert_row_tbl
--------------------------------------------------------------------------------
PROCEDURE insert_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_tbl			 IN okl_irv_tbl,
	 x_irv_tbl			 OUT NOCOPY okl_irv_tbl)IS

	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='insert_row_tbl';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irv_tbl.COUNT > 0) THEN
	  i := p_irv_tbl.FIRST;
	 LOOP
	   insert_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irv_rec			=> p_irv_tbl(i),
		x_irv_rec			=> x_irv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irv_tbl.LAST);
	i := p_irv_tbl.NEXT(i);
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

-----------------
  -- lock_row (REC)
  -----------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_def_irv_rec                  IN  okl_irv_rec) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (REC)';

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_def_irv_rec IN okl_irv_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_ITEM_RESDL_VALUES
     WHERE ITEM_RESDL_VALUE_ID = p_def_irv_rec.item_resdl_value_id
       AND OBJECT_VERSION_NUMBER = p_def_irv_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_def_irv_rec IN okl_irv_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_ITEM_RESDL_VALUES
     WHERE item_resdl_value_id = p_def_irv_rec.item_resdl_value_id;

    l_return_status                VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_ITM_CAT_RV_PRCS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_ITM_CAT_RV_PRCS.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;

  BEGIN

    BEGIN
      OPEN lock_csr(p_def_irv_rec);
      FETCH lock_csr INTO l_object_version_number;
      l_row_notfound := lock_csr%NOTFOUND;
      CLOSE lock_csr;
    EXCEPTION
      WHEN E_Resource_Busy THEN
        IF (lock_csr%ISOPEN) THEN
          CLOSE lock_csr;
        END IF;
        OKL_API.set_message(G_FND_APP,G_FORM_UNABLE_TO_RESERVE_REC);
        RAISE APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION;
    END;

    IF ( l_row_notfound ) THEN
      OPEN lchk_csr(p_def_irv_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_def_irv_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_def_irv_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKL_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
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
    p_init_msg_list                IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    okl_irv_tbl                     IN okl_irv_tbl) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (okl_irv_tbl.COUNT > 0) THEN

      i := okl_irv_tbl.FIRST;

      LOOP

        IF okl_irv_tbl.EXISTS(i) THEN

          lock_row (p_api_version                  => G_API_VERSION,
                    p_init_msg_list                => G_FALSE,
                    x_return_status                => l_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_def_irv_rec                     => okl_irv_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = okl_irv_tbl.LAST);
          i := okl_irv_tbl.NEXT(i);

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
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec,
	 x_irv_rec			 OUT NOCOPY okl_irv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_irv_rec			okl_irv_rec:=p_irv_rec;
lx_irv_rec 		    okl_irv_rec;
l_def_irv_rec			okl_irv_rec;

 FUNCTION fill_who_columns(
 p_irv_rec	IN okl_irv_rec
 )RETURN okl_irv_rec IS
l_irv_rec 	okl_irv_rec:=p_irv_rec;
 BEGIN
   l_irv_rec .LAST_UPDATE_DATE := SYSDATE;
  l_irv_rec .LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_irv_rec .LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_irv_rec );
 END fill_who_columns;
 FUNCTION populate_new_record(
	p_irv_rec	IN okl_irv_rec,
	x_irv_rec	OUT NOCOPY okl_irv_rec
	)RETURN VARCHAR2 is
	l_irv_rec	okl_irv_rec;
	l_row_notfound	BOOLEAN:=TRUE;
	l_return_status	VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	 BEGIN

	x_irv_rec := p_irv_rec;
	--Get current database values
	l_irv_rec := get_rec(p_irv_rec,l_row_notfound);
	IF(l_row_notfound) THEN
	 l_return_status:= OKL_API.G_RET_STS_UNEXP_ERROR;
  END IF;

	IF (x_irv_rec.ITEM_RESDL_VALUE_ID IS NULL)
	THEN
	 x_irv_rec.ITEM_RESDL_VALUE_ID:=l_irv_rec.ITEM_RESDL_VALUE_ID;
	END IF;
	IF (x_irv_rec.OBJECT_VERSION_NUMBER IS NULL)
	THEN
	 x_irv_rec.OBJECT_VERSION_NUMBER:=l_irv_rec.OBJECT_VERSION_NUMBER;
	END IF;
	IF (x_irv_rec.ITEM_RESIDUAL_ID IS NULL)
	THEN
	 x_irv_rec.ITEM_RESIDUAL_ID:=l_irv_rec.ITEM_RESIDUAL_ID;
	END IF;

	IF (x_irv_rec.ITEM_RESDL_VERSION_ID IS NULL)
	THEN
	 x_irv_rec.ITEM_RESDL_VERSION_ID:=l_irv_rec.ITEM_RESDL_VERSION_ID;
	END IF;
	IF (x_irv_rec.TERM_IN_MONTHS IS NULL)
	THEN
	 x_irv_rec.TERM_IN_MONTHS:=l_irv_rec.TERM_IN_MONTHS;
	END IF;
	IF (x_irv_rec.RESIDUAL_VALUE IS NULL)
	THEN
	 x_irv_rec.RESIDUAL_VALUE:=l_irv_rec.RESIDUAL_VALUE;
	END IF;
	IF (x_irv_rec.CREATED_BY IS NULL)
	THEN
	 x_irv_rec.CREATED_BY:=l_irv_rec.CREATED_BY;
	END IF;
	IF (x_irv_rec.CREATION_DATE IS NULL)
	THEN
	 x_irv_rec.CREATION_DATE:=l_irv_rec.CREATION_DATE;
	END IF;
	IF (x_irv_rec.LAST_UPDATED_BY IS NULL)
	THEN
	 x_irv_rec.LAST_UPDATED_BY:=l_irv_rec.LAST_UPDATED_BY;
	END IF;
	IF (x_irv_rec.LAST_UPDATE_DATE IS NULL)
	THEN
	 x_irv_rec.LAST_UPDATE_DATE:=l_irv_rec.LAST_UPDATE_DATE;
	END IF;
	IF (x_irv_rec.LAST_UPDATE_LOGIN IS NULL)
	THEN
	 x_irv_rec.LAST_UPDATE_LOGIN:=l_irv_rec.LAST_UPDATE_LOGIN;
	END IF;
	RETURN(l_return_status);
   END populate_new_record;

 FUNCTION Set_Attributes(
	p_irv_rec IN okl_irv_rec,
	x_irv_rec OUT NOCOPY okl_irv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_irv_rec := p_irv_rec;
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
	l_return_status:=Set_Attributes(l_irv_rec,lx_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := populate_new_record(lx_irv_rec,l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
  	l_def_irv_rec:=null_out_defaults(l_def_irv_rec);

	l_def_irv_rec := fill_who_columns(l_def_irv_rec);

	l_return_status := Validate_Attributes(l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := Validate_Record(l_def_irv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	-- Lock the row before updating
    lock_row(p_api_version    => G_API_VERSION,
             p_init_msg_list  => G_FALSE,
             x_return_status  => l_return_status,
             x_msg_count      => x_msg_count,
             x_msg_data       => x_msg_data,
             p_def_irv_rec    => l_def_irv_rec);

    IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
UPDATE OKL_FE_ITEM_RESDL_VALUES
 SET
	ITEM_RESDL_VALUE_ID= l_def_irv_rec.ITEM_RESDL_VALUE_ID,
	OBJECT_VERSION_NUMBER=l_def_irv_rec.OBJECT_VERSION_NUMBER+1,
	ITEM_RESIDUAL_ID= l_def_irv_rec.ITEM_RESIDUAL_ID,
	ITEM_RESDL_VERSION_ID= l_def_irv_rec.ITEM_RESDL_VERSION_ID,
	TERM_IN_MONTHS= l_def_irv_rec.TERM_IN_MONTHS,
	RESIDUAL_VALUE= l_def_irv_rec.RESIDUAL_VALUE,
	CREATED_BY= l_def_irv_rec.CREATED_BY,
	CREATION_DATE= l_def_irv_rec.CREATION_DATE,
	LAST_UPDATED_BY= l_def_irv_rec.LAST_UPDATED_BY,
	LAST_UPDATE_DATE= l_def_irv_rec.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN= l_def_irv_rec.LAST_UPDATE_LOGIN
 WHERE ITEM_RESDL_VALUE_ID = l_def_irv_rec.item_resdl_value_id;
	--Set OUT Values
	x_irv_rec:= l_def_irv_rec;
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
-- Procedure insert_row_tbl
--------------------------------------------------------------------------------
PROCEDURE update_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_tbl			 IN okl_irv_tbl,
	 x_irv_tbl			 OUT NOCOPY okl_irv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='update_tbl';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irv_tbl.COUNT > 0) THEN
	  i := p_irv_tbl.FIRST;
	 LOOP
	   update_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irv_rec			=> p_irv_tbl(i),
		x_irv_rec			=> x_irv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irv_tbl.LAST);
	i := p_irv_tbl.NEXT(i);
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
-- Procedure delete_row
--------------------------------------------------------------------------------
PROCEDURE delete_row(
	 p_api_version			 IN NUMBER ,
	 p_init_msg_list		 IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
	 x_return_status		 OUT NOCOPY VARCHAR2,
	 x_msg_count			 OUT NOCOPY NUMBER,
	 x_msg_data			 OUT NOCOPY VARCHAR2,
	 p_irv_rec			 IN okl_irv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
        l_irv_rec			okl_irv_rec:=p_irv_rec;


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

	DELETE FROM OKL_FE_ITEM_RESDL_VALUES
	WHERE ITEM_RESDL_VALUE_ID=l_irv_rec.item_resdl_value_id;


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
	 p_irv_tbl			 IN okl_irv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irv_tbl.COUNT > 0) THEN
	  i := p_irv_tbl.FIRST;
	 LOOP
	   delete_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irv_rec			=> p_irv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irv_tbl.LAST);
	i := p_irv_tbl.NEXT(i);
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
END OKL_IRV_PVT;

/
