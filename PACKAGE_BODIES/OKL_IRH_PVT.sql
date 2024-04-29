--------------------------------------------------------
--  DDL for Package Body OKL_IRH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_IRH_PVT" AS
  /* $Header: OKLSIRHB.pls 120.5 2006/08/09 14:18:45 pagarg noship $ */


G_NO_PARENT_RECORD	CONSTANT VARCHAR2(200)     :='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR	CONSTANT VARCHAR2(200)     :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN	CONSTANT VARCHAR2(200)         := 'SQLerrm';
G_SQLCODE_TOKEN	CONSTANT VARCHAR2(200)         := 'SQLcode';
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
-- Procedure get_rec for OKL_FE_ITEM_RESIDUAL_ALL
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_irh_rec	IN okl_irh_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_irh_rec IS
   CURSOR irh_pk_csr(p_id IN NUMBER) IS
   SELECT
	ITEM_RESIDUAL_ID,
	ORIG_ITEM_RESIDUAL_ID,
	OBJECT_VERSION_NUMBER,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN,
	INVENTORY_ITEM_ID,
	ORGANIZATION_ID,
	CATEGORY_ID,
	CATEGORY_SET_ID,
	RESI_CATEGORY_SET_ID,
	CATEGORY_TYPE_CODE,
	RESIDUAL_TYPE_CODE,
	CURRENCY_CODE,
	STS_CODE,
	EFFECTIVE_FROM_DATE,
	EFFECTIVE_TO_DATE,
	ORG_ID
   FROM OKL_FE_ITEM_RESIDUAL_ALL WHERE OKL_FE_ITEM_RESIDUAL_ALL.item_residual_id=p_id;
  l_irh_pk	irh_pk_csr%ROWTYPE;
  l_irh_rec	okl_irh_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN irh_pk_csr(p_irh_rec.item_residual_id);
  FETCH irh_pk_csr INTO
	l_irh_rec.ITEM_RESIDUAL_ID,
	l_irh_rec.ORIG_ITEM_RESIDUAL_ID,
	l_irh_rec.OBJECT_VERSION_NUMBER,
	l_irh_rec.CREATED_BY,
	l_irh_rec.CREATION_DATE,
	l_irh_rec.LAST_UPDATED_BY,
	l_irh_rec.LAST_UPDATE_DATE,
	l_irh_rec.LAST_UPDATE_LOGIN,
	l_irh_rec.INVENTORY_ITEM_ID,
	l_irh_rec.ORGANIZATION_ID,
	l_irh_rec.CATEGORY_ID,
	l_irh_rec.CATEGORY_SET_ID,
	l_irh_rec.RESI_CATEGORY_SET_ID,
	l_irh_rec.CATEGORY_TYPE_CODE,
	l_irh_rec.RESIDUAL_TYPE_CODE,
	l_irh_rec.CURRENCY_CODE,
	l_irh_rec.STS_CODE,
	l_irh_rec.EFFECTIVE_FROM_DATE,
	l_irh_rec.EFFECTIVE_TO_DATE,
	l_irh_rec.ORG_ID;
	  x_no_data_found := irh_pk_csr%NOTFOUND;
  CLOSE irh_pk_csr;
  RETURN (l_irh_rec);
 END get_rec;

 FUNCTION get_rec(
  p_irh_rec	IN okl_irh_rec
 )RETURN okl_irh_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_irh_rec,l_row_notfound));
 END get_rec;

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_FE_ITEM_RESIDUAL
--------------------------------------------------------------------------------

 FUNCTION get_rec(
  p_irhv_rec	IN okl_irhv_rec,
  x_no_data_found	OUT NOCOPY BOOLEAN
 )RETURN okl_irhv_rec IS
   CURSOR irhv_pk_csr(p_id IN NUMBER) IS
   SELECT
   	  ITEM_RESIDUAL_ID
        , ORIG_ITEM_RESIDUAL_ID
	, OBJECT_VERSION_NUMBER
	, CREATED_BY
	, CREATION_DATE
	, LAST_UPDATED_BY
	, LAST_UPDATE_DATE
	, LAST_UPDATE_LOGIN
	, INVENTORY_ITEM_ID
	, ORGANIZATION_ID
	, CATEGORY_ID
	, CATEGORY_SET_ID
	, RESI_CATEGORY_SET_ID
	, CATEGORY_TYPE_CODE
	, RESIDUAL_TYPE_CODE
	, CURRENCY_CODE
	, STS_CODE
	, EFFECTIVE_FROM_DATE
	, EFFECTIVE_TO_DATE
	, ORG_ID
   FROM
      OKL_FE_ITEM_RESIDUAL_ALL IRH
   WHERE
      IRH.ITEM_RESIDUAL_ID = p_id;
	  l_irhv_pk	    irhv_pk_csr%ROWTYPE;
      l_irhv_rec	okl_irhv_rec;
  BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN irhv_pk_csr(p_irhv_rec.item_residual_id);
  FETCH irhv_pk_csr INTO
   	  l_irhv_rec.item_residual_id
        , l_irhv_rec.orig_item_residual_id
	, l_irhv_rec.object_version_number
	, l_irhv_rec.created_by
	, l_irhv_rec.creation_date
	, l_irhv_rec.last_updated_by
	, l_irhv_rec.last_update_date
	, l_irhv_rec.last_update_login
	, l_irhv_rec.inventory_item_id
	, l_irhv_rec.organization_id
	, l_irhv_rec.category_id
	, l_irhv_rec.category_set_id
	, l_irhv_rec.resi_category_set_id
	, l_irhv_rec.category_type_code
	, l_irhv_rec.residual_type_code
	, l_irhv_rec.currency_code
	, l_irhv_rec.sts_code
	, l_irhv_rec.effective_from_date
	, l_irhv_rec.effective_to_date
	, l_irhv_rec.org_id;
	  x_no_data_found := irhv_pk_csr%NOTFOUND;
  CLOSE irhv_pk_csr;
  RETURN (l_irhv_rec);
 END get_rec;
 FUNCTION get_rec(
  p_irhv_rec	IN okl_irhv_rec
 )RETURN okl_irhv_rec IS
 l_row_notfound	BOOLEAN:=TRUE; BEGIN
  RETURN(get_rec(p_irhv_rec,l_row_notfound));
 END get_rec;

--------------------------------------------------------------------------------
-- Procedure migrate
--------------------------------------------------------------------------------

 PROCEDURE migrate(
 p_from IN okl_irhv_rec,
 p_to IN OUT NOCOPY okl_irh_rec
 )IS
 BEGIN
	p_to.ITEM_RESIDUAL_ID := p_from.ITEM_RESIDUAL_ID;
	p_to.ORIG_ITEM_RESIDUAL_ID := p_from.ORIG_ITEM_RESIDUAL_ID;
	p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
	p_to.INVENTORY_ITEM_ID := p_from.INVENTORY_ITEM_ID;
	p_to.ORGANIZATION_ID := p_from.ORGANIZATION_ID;
	p_to.CATEGORY_ID := p_from.CATEGORY_ID;
	p_to.CATEGORY_SET_ID := p_from.CATEGORY_SET_ID;
	p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.CATEGORY_TYPE_CODE := p_from.CATEGORY_TYPE_CODE;
	p_to.RESIDUAL_TYPE_CODE := p_from.RESIDUAL_TYPE_CODE;
	p_to.CURRENCY_CODE := p_from.CURRENCY_CODE;
	p_to.STS_CODE := p_from.STS_CODE;
	p_to.EFFECTIVE_FROM_DATE := p_from.EFFECTIVE_FROM_DATE;
	p_to.EFFECTIVE_TO_DATE := p_from.EFFECTIVE_TO_DATE;
	p_to.ORG_ID := p_from.ORG_ID;
  END migrate;

 PROCEDURE migrate(
 p_from IN okl_irh_rec,
 p_to IN OUT NOCOPY okl_irhv_rec
 )IS
 BEGIN
	p_to.ITEM_RESIDUAL_ID := p_from.ITEM_RESIDUAL_ID;
	p_to.ORIG_ITEM_RESIDUAL_ID := p_from.ORIG_ITEM_RESIDUAL_ID;
	p_to.OBJECT_VERSION_NUMBER := p_from.OBJECT_VERSION_NUMBER;
	p_to.CREATED_BY := p_from.CREATED_BY;
	p_to.CREATION_DATE := p_from.CREATION_DATE;
	p_to.LAST_UPDATED_BY := p_from.LAST_UPDATED_BY;
	p_to.LAST_UPDATE_DATE := p_from.LAST_UPDATE_DATE;
	p_to.LAST_UPDATE_LOGIN := p_from.LAST_UPDATE_LOGIN;
	p_to.INVENTORY_ITEM_ID := p_from.INVENTORY_ITEM_ID;
	p_to.ORGANIZATION_ID := p_from.ORGANIZATION_ID;
	p_to.CATEGORY_ID := p_from.CATEGORY_ID;
	p_to.CATEGORY_SET_ID := p_from.CATEGORY_SET_ID;
	p_to.RESI_CATEGORY_SET_ID := p_from.RESI_CATEGORY_SET_ID;
	p_to.CATEGORY_TYPE_CODE := p_from.CATEGORY_TYPE_CODE;
	p_to.RESIDUAL_TYPE_CODE := p_from.RESIDUAL_TYPE_CODE;
	p_to.CURRENCY_CODE := p_from.CURRENCY_CODE;
	p_to.STS_CODE := p_from.STS_CODE;
	p_to.EFFECTIVE_FROM_DATE := p_from.EFFECTIVE_FROM_DATE;
	p_to.EFFECTIVE_TO_DATE := p_from.EFFECTIVE_TO_DATE;
	p_to.ORG_ID := p_from.ORG_ID;
  END migrate;

  ---------------------------------
  -- FUNCTION validate_item_residual_id
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
  -- FUNCTION validate_category_type_code
  ---------------------------------
  FUNCTION validate_category_type_code (p_category_type_code IN VARCHAR2) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_category_type_code';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_category_type_code IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'category_type_code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_SOURCE_TYPES'
						,p_lookup_code 	=>	p_category_type_code);
     IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'category_type_code');
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
  END validate_category_type_code;

  ---------------------------------
  -- FUNCTION validate_residual_type_code
  ---------------------------------
  FUNCTION validate_residual_type_code (p_category_type_code IN VARCHAR2) Return Varchar2 IS
    l_api_name            CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_residual_type_code';
    l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_category_type_code IS NULL THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_REQUIRED_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'residual_type_code');
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := OKL_UTIL.check_lookup_code(
						 p_lookup_type 	=>	'OKL_RESIDUAL_TYPES'
						,p_lookup_code 	=>	p_category_type_code);
     IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.set_message(p_app_name      => G_APP_NAME,
                          p_msg_name      => G_INVALID_VALUE,
                          p_token1        => G_COL_NAME_TOKEN,
                          p_token1_value  => 'residual_type_code');
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
  END validate_residual_type_code;

  ---------------------------------
  -- FUNCTION validate_sts_code
  ---------------------------------
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

PROCEDURE validate_currency_code(   x_return_status OUT NOCOPY VARCHAR2,
                                    p_irhv_rec      IN  okl_irhv_rec) IS
BEGIN
    -- initialize return status
    x_return_status := OKL_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_irhv_rec.currency_code IS NOT NULL)  THEN
      -- check from currency values using the generic okl_util.validate_currency_code
      x_return_status := OKL_ACCOUNTING_UTIL.validate_currency_code(p_irhv_rec.currency_code);
      IF (x_return_status <>  OKL_API.G_TRUE) THEN
              OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                                  p_msg_name     => G_INVALID_VALUE,
                                  p_token1       => G_COL_NAME_TOKEN,
                                  p_token1_value => 'currency_code');

         -- halt further validation of this column
         RAISE G_EXCEPTION_HALT_VALIDATION;
       END IF;
     END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
          x_return_status := OKL_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      -- store SQL error message on message stack for caller
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_unexpected_error,
                          p_token1       => g_sqlcode_token,
                          p_token1_value => sqlcode,
                          p_token2       => g_sqlerrm_token,
                          p_token2_value => sqlerrm);
      -- notify caller of an UNEXPECTED error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;

END validate_currency_code;

 FUNCTION null_out_defaults(p_irhv_rec IN okl_irhv_rec) RETURN okl_irhv_rec IS
    l_irhv_rec	okl_irhv_rec:= p_irhv_rec;
 BEGIN
	IF (l_irhv_rec.ITEM_RESIDUAL_ID=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.ITEM_RESIDUAL_ID:=NULL;
	END IF;
	IF (l_irhv_rec.ORIG_ITEM_RESIDUAL_ID=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.ORIG_ITEM_RESIDUAL_ID:=NULL;
	END IF;
	IF (l_irhv_rec.ORG_ID=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.ORG_ID:=NULL;
	END IF;
	IF (l_irhv_rec.CREATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.CREATED_BY:=NULL;
	END IF;
	IF (l_irhv_rec.CREATION_DATE=OKL_API.G_MISS_DATE) THEN
	 l_irhv_rec.CREATION_DATE:=NULL;
	END IF;
	IF (l_irhv_rec.LAST_UPDATED_BY=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.LAST_UPDATED_BY:=NULL;
	END IF;
	IF (l_irhv_rec.LAST_UPDATE_DATE=OKL_API.G_MISS_DATE) THEN
	 l_irhv_rec.LAST_UPDATE_DATE:=NULL;
	END IF;
	IF (l_irhv_rec.LAST_UPDATE_LOGIN=OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.LAST_UPDATE_LOGIN:=NULL;
	END IF;
	IF (l_irhv_rec.INVENTORY_ITEM_ID = OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.INVENTORY_ITEM_ID:=NULL;
	END IF;
	IF (l_irhv_rec.ORGANIZATION_ID = OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.ORGANIZATION_ID:=NULL;
	END IF;
	IF (l_irhv_rec.CATEGORY_ID = OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.CATEGORY_ID:=NULL;
	END IF;
	IF (l_irhv_rec.CATEGORY_SET_ID = OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.CATEGORY_SET_ID:=NULL;
	END IF;
	IF (l_irhv_rec.RESI_CATEGORY_SET_ID = OKL_API.G_MISS_NUM) THEN
	 l_irhv_rec.RESI_CATEGORY_SET_ID:=NULL;
	END IF;
	IF (l_irhv_rec.CATEGORY_TYPE_CODE = OKL_API.G_MISS_CHAR) THEN
	 l_irhv_rec.CATEGORY_TYPE_CODE:=NULL;
	END IF;
	IF (l_irhv_rec.RESIDUAL_TYPE_CODE = OKL_API.G_MISS_CHAR) THEN
	 l_irhv_rec.RESIDUAL_TYPE_CODE:=NULL;
	END IF;
	IF (l_irhv_rec.CURRENCY_CODE = OKL_API.G_MISS_CHAR) THEN
	 l_irhv_rec.CURRENCY_CODE:=NULL;
	END IF;
	IF (l_irhv_rec.STS_CODE = OKL_API.G_MISS_CHAR) THEN
	 l_irhv_rec.STS_CODE:=NULL;
	END IF;
	IF (l_irhv_rec.EFFECTIVE_FROM_DATE = OKL_API.G_MISS_DATE) THEN
	 l_irhv_rec.EFFECTIVE_FROM_DATE:=NULL;
	END IF;
	IF (l_irhv_rec.EFFECTIVE_TO_DATE = OKL_API.G_MISS_DATE) THEN
	 l_irhv_rec.EFFECTIVE_TO_DATE:=NULL;
	END IF;

	RETURN(l_irhv_rec);
 END null_out_defaults;

 FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
	RETURN(okc_p_util.raw_to_number(sys_guid()));
  END get_seq_id;

 FUNCTION Validate_Attributes (p_irhv_rec IN okl_irhv_rec) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_attributes';
  BEGIN
	-- ***
    -- item_residual_id
    -- ***
    l_return_status := validate_item_residual_id(p_irhv_rec.item_residual_id);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	-- ***
    -- validate_category_type_code
    -- ***
    l_return_status := validate_category_type_code(p_irhv_rec.category_type_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	-- ***
    -- validate_residual_type_code
    -- ***
    l_return_status := validate_residual_type_code(p_irhv_rec.residual_type_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
	-- ***
    -- validate_sts_code
    -- ***
    l_return_status := validate_sts_code(p_irhv_rec.sts_code);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

	-- ***
    -- validate_currency_code
    -- ***
    validate_currency_code(l_return_status,p_irhv_rec);

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

FUNCTION validate_record(p_irhv_rec IN okl_irhv_rec) RETURN VARCHAR2 IS
  l_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status	VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'validate_record';
 BEGIN
   /* Check if the Effective From is null */
   IF p_irhv_rec.effective_from_date IS NULL THEN
      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_REQUIRED_EFFECTIVE_FROM');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;
   /* Check if the Effective to date is prior to effective From */
   IF p_irhv_rec.effective_to_date < p_irhv_rec.effective_from_date THEN

      OKL_API.SET_MESSAGE(p_app_name     => G_APP_NAME,
                          p_msg_name     => 'OKL_INVALID_EFFECTIVE_TO');

      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;
   /* Check for currency code when the residual type is Amount */
   IF p_irhv_rec.residual_type_code = G_RESD_AMOUNT AND p_irhv_rec.currency_code IS NULL THEN
      OKL_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_REQUIRED_VALUE
                          ,p_token1       => G_COL_NAME_TOKEN
                          ,p_token1_value => 'currency_code');
       RAISE OKL_API.G_EXCEPTION_ERROR;
   END IF;

   RETURN x_return_status;

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

 END validate_record;

 -- Returns G_RET_STS_SUCCESS if the residual is not existing.
 FUNCTION check_existence (p_irhv_rec IN okl_irhv_rec) RETURN VARCHAR2 IS
  l_api_name  CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'check_existence';
  l_residual_id NUMBER;
  l_residual_exists BOOLEAN := false;
  l_residual_type FND_LOOKUPS.MEANING%TYPE;
  l_category_type FND_LOOKUPS.MEANING%TYPE;
  l_source_type VARCHAR2(30);

  -- Cursor to get look_up meaning
  CURSOR get_lookup_meaning(p_lookup_type VARCHAR2, p_lookup_code VARCHAR2) IS
    SELECT
          FND.MEANING
      FROM
          FND_LOOKUPS FND
      WHERE
            FND.LOOKUP_TYPE = p_lookup_type
        AND FND.LOOKUP_CODE = p_lookup_code;

  -- Retrieves the Residual ID of the item passed.
  -- Item is identified by the INVENTORY_ITEM_ID, ORAGANIZATION_ID and the CATEGORY_SET_ID
  CURSOR get_residual_items (p_inventory_item_id NUMBER, p_organization_id NUMBER, p_category_set_id NUMBER, p_residual_type_code VARCHAR2, p_currency_code VARCHAR2) IS
    SELECT
           IRHV.ITEM_RESIDUAL_ID
      FROM
           OKL_FE_ITEM_RESIDUAL IRHV
  --       , OKL_SYSTEM_PARAMS_ALL_V SYSOP
     WHERE
           IRHV.INVENTORY_ITEM_ID  = p_inventory_item_id
       AND IRHV.ORGANIZATION_ID    = p_organization_id
       AND IRHV.CATEGORY_SET_ID    = p_category_set_id
       AND IRHV.RESIDUAL_TYPE_CODE = p_residual_type_code
       AND NVL(IRHV.CURRENCY_CODE,'NONE')      = NVL(p_currency_code,'NONE')
  --     AND SYSOP.CATEGORY_SET_ID  = IRHV.CATEGORY_SET_ID
        ;   -- end of cursor get_residual_items


  -- Retrieves the Residual ID of the item category passed.
  -- Item category is identified by the CATEGORY_ID and the CATEGORY_SET_ID
  CURSOR get_residual_categories (p_category_id NUMBER, p_category_set_id NUMBER, p_residual_type_code VARCHAR2, p_currency_code VARCHAR2) IS
    SELECT
           IRHV.ITEM_RESIDUAL_ID
      FROM
           OKL_FE_ITEM_RESIDUAL IRHV
  --       , OKL_SYSTEM_PARAMS_ALL_V SYSOP
     WHERE
           IRHV.CATEGORY_ID       = p_category_id
       AND IRHV.CATEGORY_SET_ID   = p_category_set_id
       AND IRHV.RESIDUAL_TYPE_CODE = p_residual_type_code
       AND NVL(IRHV.CURRENCY_CODE,'NONE')      = NVL(p_currency_code,'NONE')
  --   AND SYSOP.CATEGORY_SET_ID  = IRHV.CATEGORY_SET_ID
        ;   -- end of cursor get_residual_categories


  -- Retrieves the Residual ID of the residual category set passed.
  -- Residual category set is identified by the RESI_CATEGORY_SET_ID.
  CURSOR get_residual_rcs ( p_resi_category_set_id NUMBER, p_residual_type_code VARCHAR2, p_currency_code VARCHAR2) IS
    SELECT
           IRHV.ITEM_RESIDUAL_ID
      FROM
           OKL_FE_ITEM_RESIDUAL IRHV
  --       , OKL_SYSTEM_PARAMS_ALL_V SYSOP
     WHERE
           IRHV.RESI_CATEGORY_SET_ID   = p_resi_category_set_id
       AND IRHV.RESIDUAL_TYPE_CODE = p_residual_type_code
       AND NVL(IRHV.CURRENCY_CODE,'NONE')      = NVL(p_currency_code,'NONE')
  --   AND SYSOP.CATEGORY_SET_ID  = IRHV.CATEGORY_SET_ID
        ;   -- end of cursor get_residual_rcs

 BEGIN

     IF p_irhv_rec.category_type_code = G_CAT_ITEM THEN
        OPEN get_residual_items(p_irhv_rec.inventory_item_id, p_irhv_rec.organization_id, p_irhv_rec.category_set_id, p_irhv_rec.residual_type_code, p_irhv_rec.currency_code);
          FETCH get_residual_items INTO l_residual_id;
          IF get_residual_items%FOUND THEN
            l_residual_exists := TRUE;
          END IF; -- end of check for residuals for item
        CLOSE get_residual_items;
     ELSIF p_irhv_rec.category_type_code = G_CAT_ITEM_CAT THEN
      OPEN get_residual_categories(p_irhv_rec.category_id, p_irhv_rec.category_set_id, p_irhv_rec.residual_type_code, p_irhv_rec.currency_code);
        FETCH get_residual_categories INTO l_residual_id;
        IF get_residual_categories%FOUND THEN
          l_residual_exists := TRUE;
        END IF; -- end of check for residuals for categories
      CLOSE get_residual_categories;

      ELSIF p_irhv_rec.category_type_code = G_CAT_RES_CAT THEN
       OPEN get_residual_rcs(p_irhv_rec.resi_category_set_id, p_irhv_rec.residual_type_code, p_irhv_rec.currency_code);
         FETCH get_residual_rcs INTO l_residual_id;
         IF get_residual_rcs%FOUND THEN
           l_residual_exists := TRUE;
         END IF; -- end of check for residuals for Residual Category set
       CLOSE get_residual_rcs;
     END IF; -- end of check for source type = Item or Item Category or Residual Category Set

     IF ( l_residual_exists ) THEN
       OPEN get_lookup_meaning('OKL_SOURCE_TYPES',p_irhv_rec.category_type_code);
         FETCH get_lookup_meaning INTO l_category_type;
       CLOSE get_lookup_meaning;

       OPEN get_lookup_meaning('OKL_RESIDUAL_TYPES',p_irhv_rec.residual_type_code);
         FETCH get_lookup_meaning INTO l_residual_type;
       CLOSE get_lookup_meaning;


       IF p_irhv_rec.residual_type_code = G_RESD_AMOUNT THEN
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_ITMRES_EXISTS_FOR_AMOUNT',
                              p_token1       => 'CATEGORY_TYPE',
                              p_token1_value => l_category_type);
       ELSE
         OKL_API.SET_MESSAGE (p_app_name     => G_APP_NAME,
                              p_msg_name     => 'OKL_ITMRES_EXISTS_FOR_PERCENT',
                              p_token1       => 'CATEGORY_TYPE',
                              p_token1_value => l_category_type);
       END IF;
       RAISE OKL_API.G_EXCEPTION_ERROR;
     ELSE
       RETURN G_RET_STS_SUCCESS;
     END IF;

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
	 p_irh_rec			 IN okl_irh_rec,
	 x_irh_rec			 OUT NOCOPY okl_irh_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_irh_rec			okl_irh_rec := p_irh_rec;

 FUNCTION Set_Attributes(
	p_irh_rec IN okl_irh_rec,
	x_irh_rec OUT NOCOPY okl_irh_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_irh_rec := p_irh_rec;
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
	l_return_status:=Set_Attributes(p_irh_rec,
		l_irh_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	INSERT INTO OKL_FE_ITEM_RESIDUAL_ALL(
	   ITEM_RESIDUAL_ID,
	   ORIG_ITEM_RESIDUAL_ID,
	   OBJECT_VERSION_NUMBER,
	   CREATED_BY,
	   CREATION_DATE,
	   LAST_UPDATED_BY,
	   LAST_UPDATE_DATE,
	   LAST_UPDATE_LOGIN,
	   INVENTORY_ITEM_ID,
	   ORGANIZATION_ID,
	   CATEGORY_ID,
	   CATEGORY_SET_ID,
	   RESI_CATEGORY_SET_ID,
	   CATEGORY_TYPE_CODE,
	   RESIDUAL_TYPE_CODE,
	   CURRENCY_CODE,
	   STS_CODE,
	   EFFECTIVE_FROM_DATE,
	   EFFECTIVE_TO_DATE,
	   ORG_ID)
	VALUES (
	   l_irh_rec.ITEM_RESIDUAL_ID,
	   l_irh_rec.ORIG_ITEM_RESIDUAL_ID,
	   l_irh_rec.OBJECT_VERSION_NUMBER,
	   l_irh_rec.CREATED_BY,
	   l_irh_rec.CREATION_DATE,
	   l_irh_rec.LAST_UPDATED_BY,
	   l_irh_rec.LAST_UPDATE_DATE,
	   l_irh_rec.LAST_UPDATE_LOGIN,
	   l_irh_rec.INVENTORY_ITEM_ID,
	   l_irh_rec.ORGANIZATION_ID,
	   l_irh_rec.CATEGORY_ID,
	   l_irh_rec.CATEGORY_SET_ID,
	   l_irh_rec.RESI_CATEGORY_SET_ID,
	   l_irh_rec.CATEGORY_TYPE_CODE,
	   l_irh_rec.RESIDUAL_TYPE_CODE,
	   l_irh_rec.CURRENCY_CODE,
	   l_irh_rec.STS_CODE,
	   l_irh_rec.EFFECTIVE_FROM_DATE,
	   l_irh_rec.EFFECTIVE_TO_DATE,
	   l_irh_rec.ORG_ID);

	--Set OUT Values
	x_irh_rec:=l_irh_rec;
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
	 p_irhv_rec			 IN okl_irhv_rec,
	 x_irhv_rec			 OUT NOCOPY okl_irhv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_irhv_rec			okl_irhv_rec;
l_def_irhv_rec			okl_irhv_rec;
l_irhrec			okl_irh_rec;
lx_irh_rec			okl_irh_rec;

 FUNCTION fill_who_columns(
 p_irhv_rec	IN okl_irhv_rec
 )RETURN okl_irhv_rec IS
l_irhv_rec okl_irhv_rec:=p_irhv_rec;
 BEGIN
   l_irhv_rec.CREATION_DATE := SYSDATE;
  l_irhv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
  l_irhv_rec.LAST_UPDATE_DATE := SYSDATE;
  l_irhv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_irhv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_irhv_rec);
 END fill_who_columns;

 FUNCTION Set_Attributes(
	p_irhv_rec IN okl_irhv_rec,
	x_irhv_rec OUT NOCOPY okl_irhv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
	  x_irhv_rec := p_irhv_rec;
          x_irhv_rec.ORG_ID := MO_GLOBAL.GET_CURRENT_ORG_ID();
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
	l_irhv_rec:=null_out_defaults(p_irhv_rec);
	-- Set Primary key value
	l_irhv_rec.ITEM_RESIDUAL_ID := get_seq_id;
	-- Set the ORIG_ITEM_RESIDUAL_ID of the record for duplication
	l_irhv_rec.orig_item_residual_id := p_irhv_rec.item_residual_id;
	--Setting Item Attributes
	l_return_status:=Set_Attributes(l_irhv_rec,l_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_def_irhv_rec := fill_who_columns(l_def_irhv_rec);
	l_return_status := Validate_Attributes(l_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

    l_return_status := check_existence(l_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	l_return_status := Validate_Record(l_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	migrate(l_def_irhv_rec,l_irhrec);
insert_row(
	 p_api_version,
	 p_init_msg_list,
	 l_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_irhrec,
	 lx_irh_rec);
	IF (x_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (x_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	migrate(lx_irh_rec,l_def_irhv_rec);

	--Set OUT Values
	x_irhv_rec:= l_def_irhv_rec;
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
	 p_irhv_tbl			 IN okl_irhv_tbl,
	 x_irhv_tbl			 OUT NOCOPY okl_irhv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irhv_tbl.COUNT > 0) THEN
	  i := p_irhv_tbl.FIRST;
	 LOOP
	   insert_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irhv_rec			=> p_irhv_tbl(i),
		x_irhv_rec			=> x_irhv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irhv_tbl.LAST);
	i := p_irhv_tbl.NEXT(i);
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
    p_def_irh_rec                  IN  okl_irh_rec) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (REC)';

    E_Resource_Busy                EXCEPTION;

    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);

    CURSOR lock_csr (p_def_irh_rec IN okl_irh_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_ITEM_RESIDUAL_ALL
     WHERE ITEM_RESIDUAL_ID = p_def_irh_rec.item_residual_id
       AND OBJECT_VERSION_NUMBER = p_def_irh_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_def_irh_rec IN okl_irh_rec) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKL_FE_ITEM_RESIDUAL_ALL
     WHERE item_residual_id = p_def_irh_rec.item_residual_id;

    l_return_status                VARCHAR2(1):= OKL_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKL_FE_ITEM_RESIDUAL_ALL.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKL_FE_ITEM_RESIDUAL_ALL.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;

  BEGIN

    BEGIN
      OPEN lock_csr(p_def_irh_rec);
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
      OPEN lchk_csr(p_def_irh_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_def_irh_rec.object_version_number THEN
      OKL_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKL_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_def_irh_rec.object_version_number THEN
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
    okl_irh_tbl                     IN okl_irh_tbl) IS

    l_api_name                     CONSTANT VARCHAR2(61) := G_PKG_NAME||'.'||'lock_row (TBL)';
    l_return_status                VARCHAR2(1)           := G_RET_STS_SUCCESS;
    i                              BINARY_INTEGER;

  BEGIN

    IF (okl_irh_tbl.COUNT > 0) THEN

      i := okl_irh_tbl.FIRST;

      LOOP

        IF okl_irh_tbl.EXISTS(i) THEN

          lock_row (p_api_version                  => G_API_VERSION,
                    p_init_msg_list                => G_FALSE,
                    x_return_status                => l_return_status,
                    x_msg_count                    => x_msg_count,
                    x_msg_data                     => x_msg_data,
                    p_def_irh_rec                     => okl_irh_tbl(i));

          IF l_return_status = G_RET_STS_UNEXP_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
          ELSIF l_return_status = G_RET_STS_ERROR THEN
            RAISE OKL_API.G_EXCEPTION_ERROR;
          END IF;

          EXIT WHEN (i = okl_irh_tbl.LAST);
          i := okl_irh_tbl.NEXT(i);

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
	 p_irh_rec			 IN okl_irh_rec,
	 x_irh_rec			 OUT NOCOPY okl_irh_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_def_irh_rec			okl_irh_rec := p_irh_rec;

	l_row_notfound			BOOLEAN:=TRUE;

 FUNCTION Set_Attributes(
	p_irh_rec IN okl_irh_rec,
	x_irh_rec OUT NOCOPY okl_irh_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_irh_rec := p_irh_rec;
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
	l_return_status:=Set_Attributes(p_irh_rec,
		l_def_irh_rec);
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
             p_def_irh_rec    => l_def_irh_rec);

    IF (l_return_status = G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = G_RET_STS_ERROR) THEN
      RAISE OKL_API.G_EXCEPTION_ERROR;
    END IF;

UPDATE OKL_FE_ITEM_RESIDUAL_ALL
 SET
	ITEM_RESIDUAL_ID= l_def_irh_rec.ITEM_RESIDUAL_ID,
	ORIG_ITEM_RESIDUAL_ID = l_def_irh_rec.ORIG_ITEM_RESIDUAL_ID,
	OBJECT_VERSION_NUMBER= l_def_irh_rec.OBJECT_VERSION_NUMBER+1,
	CREATED_BY= l_def_irh_rec.CREATED_BY,
	CREATION_DATE= l_def_irh_rec.CREATION_DATE,
	LAST_UPDATED_BY= l_def_irh_rec.LAST_UPDATED_BY,
	LAST_UPDATE_DATE= l_def_irh_rec.LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN= l_def_irh_rec.LAST_UPDATE_LOGIN,
	INVENTORY_ITEM_ID= l_def_irh_rec.INVENTORY_ITEM_ID,
	ORGANIZATION_ID= l_def_irh_rec.ORGANIZATION_ID,
	CATEGORY_ID= l_def_irh_rec.CATEGORY_ID,
	CATEGORY_SET_ID= l_def_irh_rec.CATEGORY_SET_ID,
	RESI_CATEGORY_SET_ID= l_def_irh_rec.RESI_CATEGORY_SET_ID,
	CATEGORY_TYPE_CODE= l_def_irh_rec.CATEGORY_TYPE_CODE,
	RESIDUAL_TYPE_CODE= l_def_irh_rec.RESIDUAL_TYPE_CODE,
	CURRENCY_CODE= l_def_irh_rec.CURRENCY_CODE,
	STS_CODE= l_def_irh_rec.STS_CODE,
	EFFECTIVE_FROM_DATE= l_def_irh_rec.EFFECTIVE_FROM_DATE,
	EFFECTIVE_TO_DATE= l_def_irh_rec.EFFECTIVE_TO_DATE,
	ORG_ID= l_def_irh_rec.ORG_ID
 WHERE ITEM_RESIDUAL_ID = l_def_irh_rec.ITEM_RESIDUAL_ID;
	--Set OUT Values
	x_irh_rec:=l_def_irh_rec;
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
	 p_irhv_rec			 IN okl_irhv_rec,
	 x_irhv_rec			 OUT NOCOPY okl_irhv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_insert_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_irhv_rec			okl_irhv_rec:=p_irhv_rec;
l_def_irhv_rec			okl_irhv_rec;
lx_def_irhv_rec			okl_irhv_rec;
l_irhrec			okl_irh_rec;
lx_irh_rec			okl_irh_rec;

 FUNCTION fill_who_columns(
 p_irhv_rec	IN okl_irhv_rec
 )RETURN okl_irhv_rec IS
l_irhv_rec 	okl_irhv_rec:=p_irhv_rec;
 BEGIN
   l_irhv_rec .LAST_UPDATE_DATE := SYSDATE;
  l_irhv_rec .LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
  l_irhv_rec .LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
  RETURN (l_irhv_rec );
 END fill_who_columns;
 FUNCTION populate_new_record(
	p_irhv_rec	IN okl_irhv_rec,
	x_irhv_rec	OUT NOCOPY okl_irhv_rec
	)RETURN VARCHAR2 is
	l_irhv_rec	okl_irhv_rec;
	l_row_notfound	BOOLEAN:=TRUE;
	l_return_status	VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	 BEGIN

	x_irhv_rec := p_irhv_rec;
	--Get current database values
	l_irhv_rec := get_rec(p_irhv_rec,l_row_notfound);
	IF(l_row_notfound) THEN
	 l_return_status:= OKL_API.G_RET_STS_UNEXP_ERROR;
     END IF;
	IF (x_irhv_rec.ITEM_RESIDUAL_ID IS NULL)
	THEN
	 x_irhv_rec.ITEM_RESIDUAL_ID:=l_irhv_rec.ITEM_RESIDUAL_ID;
	END IF;

	IF (x_irhv_rec.ORIG_ITEM_RESIDUAL_ID IS NULL)
	THEN
	 x_irhv_rec.ORIG_ITEM_RESIDUAL_ID :=l_irhv_rec.ORIG_ITEM_RESIDUAL_ID;
	END IF;

	IF (x_irhv_rec.OBJECT_VERSION_NUMBER IS NULL)
	THEN
	 x_irhv_rec.OBJECT_VERSION_NUMBER:=l_irhv_rec.OBJECT_VERSION_NUMBER;
	END IF;

	IF (x_irhv_rec.CREATED_BY IS NULL)
	THEN
	 x_irhv_rec.CREATED_BY:=l_irhv_rec.CREATED_BY;
	END IF;
	IF (x_irhv_rec.CREATION_DATE IS NULL)
	THEN
	 x_irhv_rec.CREATION_DATE:=l_irhv_rec.CREATION_DATE;
	END IF;
	IF (x_irhv_rec.LAST_UPDATED_BY IS NULL)
	THEN
	 x_irhv_rec.LAST_UPDATED_BY:=l_irhv_rec.LAST_UPDATED_BY;
	END IF;
	IF (x_irhv_rec.LAST_UPDATE_DATE IS NULL)
	THEN
	 x_irhv_rec.LAST_UPDATE_DATE:=l_irhv_rec.LAST_UPDATE_DATE;
	END IF;
	IF (x_irhv_rec.LAST_UPDATE_LOGIN IS NULL)
	THEN
	 x_irhv_rec.LAST_UPDATE_LOGIN:=l_irhv_rec.LAST_UPDATE_LOGIN;
	END IF;
	IF (x_irhv_rec.INVENTORY_ITEM_ID IS NULL)
	THEN
	 x_irhv_rec.INVENTORY_ITEM_ID:=l_irhv_rec.INVENTORY_ITEM_ID;
	END IF;
	IF (x_irhv_rec.ORGANIZATION_ID IS NULL)
	THEN
	 x_irhv_rec.ORGANIZATION_ID:=l_irhv_rec.ORGANIZATION_ID;
	END IF;
	IF (x_irhv_rec.CATEGORY_ID IS NULL)
	THEN
	 x_irhv_rec.CATEGORY_ID:=l_irhv_rec.CATEGORY_ID;
	END IF;
	IF (x_irhv_rec.CATEGORY_SET_ID IS NULL)
	THEN
	 x_irhv_rec.CATEGORY_SET_ID:=l_irhv_rec.CATEGORY_SET_ID;
	END IF;
	IF (x_irhv_rec.RESI_CATEGORY_SET_ID IS NULL)
	THEN
	 x_irhv_rec.RESI_CATEGORY_SET_ID:=l_irhv_rec.RESI_CATEGORY_SET_ID;
	END IF;
	IF (x_irhv_rec.CATEGORY_TYPE_CODE IS NULL)
	THEN
	 x_irhv_rec.CATEGORY_TYPE_CODE:=l_irhv_rec.CATEGORY_TYPE_CODE;
	END IF;
	IF (x_irhv_rec.RESIDUAL_TYPE_CODE IS NULL)
	THEN
	 x_irhv_rec.RESIDUAL_TYPE_CODE:=l_irhv_rec.RESIDUAL_TYPE_CODE;
	END IF;
	IF (x_irhv_rec.CURRENCY_CODE IS NULL)
	THEN
	 x_irhv_rec.CURRENCY_CODE:=l_irhv_rec.CURRENCY_CODE;
	END IF;
	IF (x_irhv_rec.STS_CODE IS NULL)
	THEN
	 x_irhv_rec.STS_CODE:=l_irhv_rec.STS_CODE;
	END IF;
	IF (x_irhv_rec.EFFECTIVE_FROM_DATE IS NULL)
	THEN
	 x_irhv_rec.EFFECTIVE_FROM_DATE:=l_irhv_rec.EFFECTIVE_FROM_DATE;
	END IF;
	IF (x_irhv_rec.EFFECTIVE_TO_DATE IS NULL)
	THEN
	 x_irhv_rec.EFFECTIVE_TO_DATE:=l_irhv_rec.EFFECTIVE_TO_DATE;
	END IF;
	IF (x_irhv_rec.ORG_ID IS NULL)
	THEN
	 x_irhv_rec.ORG_ID:=l_irhv_rec.ORG_ID;
	END IF;
	RETURN(l_return_status);
   END populate_new_record;

 FUNCTION Set_Attributes(
	p_irhv_rec IN okl_irhv_rec,
	x_irhv_rec OUT NOCOPY okl_irhv_rec
 ) RETURN VARCHAR2 IS
 l_return_status			VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
	BEGIN
		x_irhv_rec := p_irhv_rec;
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
	l_return_status:=Set_Attributes(l_irhv_rec,l_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	l_return_status := populate_new_record(l_def_irhv_rec,lx_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	lx_def_irhv_rec := null_out_defaults(lx_def_irhv_rec);

	lx_def_irhv_rec := fill_who_columns(lx_def_irhv_rec);

	l_return_status := Validate_Attributes(lx_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	l_return_status := Validate_Record(lx_def_irhv_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;
	migrate(lx_def_irhv_rec,l_irhrec);
update_row(
	 p_api_version,
	 p_init_msg_list,
	 l_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_irhrec,
	 lx_irh_rec);
	IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
	ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
	 RAISE OKL_API.G_EXCEPTION_ERROR;
	END IF;

	migrate(lx_irh_rec,lx_def_irhv_rec);
	--Set OUT Values
	x_irhv_rec:= lx_def_irhv_rec;
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
	 p_irhv_tbl			 IN okl_irhv_tbl,
	 x_irhv_tbl			 OUT NOCOPY okl_irhv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_update_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irhv_tbl.COUNT > 0) THEN
	  i := p_irhv_tbl.FIRST;
	 LOOP
	   update_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irhv_rec			=> p_irhv_tbl(i),
		x_irhv_rec			=> x_irhv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irhv_tbl.LAST);
	i := p_irhv_tbl.NEXT(i);
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
	 p_irh_rec			 IN okl_irh_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	l_irh_rec			okl_irh_rec := p_irh_rec;
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

	DELETE FROM OKL_FE_ITEM_RESIDUAL_ALL
	WHERE ITEM_RESIDUAL_ID=l_irh_rec.item_residual_id;

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
	 p_irhv_rec			 IN okl_irhv_rec)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
l_irhv_rec			okl_irhv_rec:=p_irhv_rec;
l_irhrec			okl_irh_rec;

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

	migrate(l_irhv_rec,l_irhrec);
delete_row(
	 p_api_version,
	 p_init_msg_list,
	 x_return_status,
	 x_msg_count,
	 x_msg_data,
	 l_irhrec);
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
	 p_irhv_tbl			 IN okl_irhv_tbl)IS
	l_api_version			CONSTANT NUMBER:=1;
	l_api_name			CONSTANT VARCHAR2(30):='v_delete_row';
	l_return_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
	i			NUMBER:=0;
	l_overall_status			VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
   BEGIN
	OKL_API.init_msg_list(p_init_msg_list);
	-- Make sure PL/SQL table has records in it before passing
	IF (p_irhv_tbl.COUNT > 0) THEN
	  i := p_irhv_tbl.FIRST;
	 LOOP
	   delete_row (p_api_version			=> p_api_version,
		p_init_msg_list			=> OKL_API.G_FALSE,
		x_return_status			=> x_return_status,
		x_msg_count			=> x_msg_count,
		x_msg_data			=> x_msg_data,
		p_irhv_rec			=> p_irhv_tbl(i));
	IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
	 IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
	   l_overall_status := x_return_status;
	 END IF;
	END IF;

	EXIT WHEN (i = p_irhv_tbl.LAST);
	i := p_irhv_tbl.NEXT(i);
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
END OKL_IRH_PVT;

/
