--------------------------------------------------------
--  DDL for Package Body OKL_BCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKL_BCT_PVT" AS
/* $Header: OKLSBCTB.pls 120.2 2007/05/11 22:47:38 asahoo ship $ */

-- The lock_row and the validate_row procedures are not available.

G_NO_PARENT_RECORD          CONSTANT VARCHAR2(200):='OKC_NO_PARENT_RECORD';
G_UNEXPECTED_ERROR          CONSTANT VARCHAR2(200) :='OKC_CONTRACTS_UNEXPECTED_ERROR';
G_SQLERRM_TOKEN             CONSTANT VARCHAR2(200) := 'SQLerrm';
G_SQLCODE_TOKEN             CONSTANT VARCHAR2(200) := 'SQLcode';
G_EXCEPTION_HALT_VALIDATION EXCEPTION;

PROCEDURE api_copy IS
BEGIN
  null;
END api_copy;

PROCEDURE change_version IS
BEGIN
  null;
END change_version;

--------------------------------------------------------------------------------
-- Procedure get_rec for OKL_BOOK_CONTROLLER_TRX
--------------------------------------------------------------------------------
FUNCTION get_rec(
  p_bct_rec IN okl_bct_rec,
  x_no_data_found   OUT NOCOPY BOOLEAN
 )RETURN okl_bct_rec IS
  CURSOR bct_pk_csr(p_batch_number IN NUMBER,
                    p_srl_number   IN NUMBER) IS
  SELECT
    USER_ID,
    ORG_ID,
    BATCH_NUMBER,
    PROCESSING_SRL_NUMBER,
    KHR_ID,
    PROGRAM_NAME,
    PROG_SHORT_NAME,
    CONC_REQ_ID,
    PROGRESS_STATUS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTIVE_FLAG
  FROM OKL_BOOK_CONTROLLER_TRX
  WHERE OKL_BOOK_CONTROLLER_TRX.BATCH_NUMBER = p_batch_number
  AND OKL_BOOK_CONTROLLER_TRX.PROCESSING_SRL_NUMBER = p_srl_number;
  l_bct_pk  bct_pk_csr%ROWTYPE;
  l_bct_rec okl_bct_rec;
BEGIN
  x_no_data_found:= TRUE;
  --Get current data base values
  OPEN bct_pk_csr(p_bct_rec.batch_number,
                  p_bct_rec.processing_srl_number);
  FETCH bct_pk_csr INTO
    l_bct_rec.USER_ID,
    l_bct_rec.ORG_ID,
    l_bct_rec.BATCH_NUMBER,
    l_bct_rec.PROCESSING_SRL_NUMBER,
    l_bct_rec.KHR_ID,
    l_bct_rec.PROGRAM_NAME,
    l_bct_rec.PROG_SHORT_NAME,
    l_bct_rec.CONC_REQ_ID,
    l_bct_rec.PROGRESS_STATUS,
    l_bct_rec.CREATED_BY,
    l_bct_rec.CREATION_DATE,
    l_bct_rec.LAST_UPDATED_BY,
    l_bct_rec.LAST_UPDATE_DATE,
    l_bct_rec.LAST_UPDATE_LOGIN,
    l_bct_rec.ACTIVE_FLAG;
      x_no_data_found := bct_pk_csr%NOTFOUND;
  CLOSE bct_pk_csr;
  RETURN (l_bct_rec);
END get_rec;

FUNCTION get_rec(
  p_bct_rec IN okl_bct_rec
 )RETURN okl_bct_rec IS
  l_row_notfound BOOLEAN:=TRUE;
BEGIN
  RETURN(get_rec(p_bct_rec,l_row_notfound));
END get_rec;

---------------------------------------------------------------------------
-- FUNCTION null_out_defaults for: OKL_BOOK_CONTROLLER_TRX
---------------------------------------------------------------------------
FUNCTION null_out_defaults(
  p_bct_rec IN okl_bct_rec
 )RETURN okl_bct_rec IS
  l_bct_rec  okl_bct_rec := p_bct_rec;
BEGIN
  IF (l_bct_rec.USER_ID=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.USER_ID:=NULL;
  END IF;
  IF (l_bct_rec.ORG_ID=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.ORG_ID:=NULL;
  END IF;
  IF (l_bct_rec.BATCH_NUMBER=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.BATCH_NUMBER:=NULL;
  END IF;
  IF (l_bct_rec.PROCESSING_SRL_NUMBER=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.PROCESSING_SRL_NUMBER:=NULL;
  END IF;
  IF (l_bct_rec.KHR_ID=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.KHR_ID:=NULL;
  END IF;
  IF (l_bct_rec.PROGRAM_NAME=OKL_API.G_MISS_CHAR) THEN
    l_bct_rec.PROGRAM_NAME:=NULL;
  END IF;
  IF (l_bct_rec.PROG_SHORT_NAME=OKL_API.G_MISS_CHAR) THEN
    l_bct_rec.PROG_SHORT_NAME:=NULL;
  END IF;
  IF (l_bct_rec.CONC_REQ_ID=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.CONC_REQ_ID:=NULL;
  END IF;
  IF (l_bct_rec.PROGRESS_STATUS=OKL_API.G_MISS_CHAR) THEN
    l_bct_rec.PROGRESS_STATUS:=NULL;
  END IF;
  IF (l_bct_rec.CREATED_BY=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.CREATED_BY:=NULL;
  END IF;
  IF (l_bct_rec.CREATION_DATE=OKL_API.G_MISS_DATE) THEN
    l_bct_rec.CREATION_DATE:=NULL;
  END IF;
  IF (l_bct_rec.LAST_UPDATED_BY=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.LAST_UPDATED_BY:=NULL;
  END IF;
  IF (l_bct_rec.LAST_UPDATE_DATE=OKL_API.G_MISS_DATE) THEN
    l_bct_rec.LAST_UPDATE_DATE:=NULL;
  END IF;
  IF (l_bct_rec.LAST_UPDATE_LOGIN=OKL_API.G_MISS_NUM) THEN
    l_bct_rec.LAST_UPDATE_LOGIN:=NULL;
  END IF;
  IF (l_bct_rec.ACTIVE_FLAG=OKL_API.G_MISS_CHAR) THEN
    l_bct_rec.ACTIVE_FLAG:=NULL;
  END IF;
  RETURN(l_bct_rec);
END null_out_defaults;

-----------------------------------------------------------------------------
-- PROCEDURE validate_user_id
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_user_id
-- Description     : Procedure to validate user id
-- Business Rules  :
-- Parameters      : p_user_id,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_user_id(
  p_user_id       IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_user_id IS NULL) OR (p_user_id = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'user_id');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_user_id;

-----------------------------------------------------------------------------
-- PROCEDURE validate_org_id
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_org_id
-- Description     : Procedure to validate org id
-- Business Rules  :
-- Parameters      : p_org_id,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_org_id(
  p_org_id        IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

  l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- check org id validity using the generic function in okl_util
  l_return_status := okl_util.check_org_id (p_org_id,'N');

  IF ( l_return_status = OKL_API.G_RET_STS_ERROR) THEN
     OKL_API.SET_MESSAGE(p_app_name    => g_app_name,
                        p_msg_name     => g_invalid_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'org_id');

     -- notify caller of an error
     x_return_status := OKL_API.G_RET_STS_ERROR;
     RAISE G_EXCEPTION_HALT_VALIDATION;

   ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      -- notify caller of an error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary.
    --Validation can continue to next attribute/column
    NULL;

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

END validate_org_id;

-----------------------------------------------------------------------------
-- PROCEDURE validate_batch_number
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_batch_number
-- Description     : Procedure to validate batch number
-- Business Rules  :
-- Parameters      : p_batch_number,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_batch_number(
  p_batch_number  IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_batch_number IS NULL) OR (p_batch_number = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'batch_number');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_batch_number;

-----------------------------------------------------------------------------
-- PROCEDURE validate_processing_srl_number
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_processing_srl_number
-- Description     : Procedure to validate processing serial number
-- Business Rules  :
-- Parameters      : p_srl_number,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_processing_srl_number(
  p_srl_number    IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_srl_number IS NULL) OR (p_srl_number = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'processing_srl_number');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_processing_srl_number;

-----------------------------------------------------------------------------
-- PROCEDURE validate_khr_id
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_khr_id
-- Description     : Procedure to validate contract id
-- Business Rules  :
-- Parameters      : p_khr_id,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_khr_id(
  p_khr_id        IN  NUMBER,
  x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_khr_id IS NULL) OR (p_khr_id = OKL_API.G_MISS_NUM) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'khr_id');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_khr_id;

-----------------------------------------------------------------------------
-- PROCEDURE validate_program_name
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_program_name
-- Description     : Procedure to validate program name
-- Business Rules  :
-- Parameters      : p_program_name,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_program_name(
  p_program_name  IN  VARCHAR2,
  x_return_status OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_program_name IS NULL) OR (p_program_name = OKL_API.G_MISS_CHAR) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'program_name');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_program_name;

-----------------------------------------------------------------------------
-- PROCEDURE validate_prog_short_name
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_prog_short_name
-- Description     : Procedure to validate program short name
-- Business Rules  :
-- Parameters      : p_prog_short_name,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_prog_short_name(
  p_prog_short_name  IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2) IS

BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- data is required
  IF (p_prog_short_name IS NULL) OR (p_prog_short_name = OKL_API.G_MISS_CHAR) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'prog_short_name');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- notify caller of an error
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

END validate_prog_short_name;

-----------------------------------------------------------------------------
-- PROCEDURE validate_progress_status
-----------------------------------------------------------------------------
-- Start of comments
--
-- procedure Name  : validate_progress_status
-- Description     : Procedure to validate progress status
-- Business Rules  :
-- Parameters      : p_progress_status,x_return_status
-- Version         : 1.0
-- History         : XX-XXX-XXXX vthiruva Created
-- End of comments

PROCEDURE validate_progress_status(
  p_progress_status  IN  VARCHAR2,
  x_return_status    OUT NOCOPY VARCHAR2) IS

l_return_status VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  -- initialize return status
  x_return_status := OKL_API.G_RET_STS_SUCCESS;

  -- If value passed
  IF (p_progress_status IS NULL) OR
     (p_progress_status = OKL_API.G_MISS_CHAR) THEN
    OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                        p_msg_name     => g_required_value,
                        p_token1       => g_col_name_token,
                        p_token1_value => 'progress_status');

    -- halt further validation of this column
    RAISE G_EXCEPTION_HALT_VALIDATION;

  ELSE
    -- check the status code is a valid value
    l_return_status := okl_util.check_lookup_code(
                        p_lookup_type  =>  'OKL_BKG_CONTL_STATUS',
                        p_lookup_code  =>  p_progress_status);

    IF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
      OKL_API.SET_MESSAGE(p_app_name     => g_app_name,
                          p_msg_name     => g_invalid_value,
                          p_token1       => g_col_name_token,
                          p_token1_value => 'progress_status');

      -- notify caller of an error
      x_return_status := OKL_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;

    ELSIF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      -- notify caller of an error
      x_return_status := OKL_API.G_RET_STS_UNEXP_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  END IF;

  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION then
      -- No action necessary.
      -- Validation can continue to next attribute/column
      NULL;

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
END validate_progress_status;

-----------------------------------------------------------------
-- Validate_Attributes for:OKL_BOOK_CONTROLLER_TRX  --
-----------------------------------------------------------------
FUNCTION Validate_Attributes (
  p_bct_rec IN okl_bct_rec
 )RETURN VARCHAR2 IS
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  -- call each column-level validation
  validate_user_id(p_user_id       => p_bct_rec.user_id,
                   x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_org_id(p_org_id        => p_bct_rec.org_id,
                  x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_batch_number(p_batch_number  => p_bct_rec.batch_number,
                        x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_processing_srl_number(
                  p_srl_number    => p_bct_rec.processing_srl_number,
                  x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_khr_id(p_khr_id        => p_bct_rec.khr_id,
                  x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_program_name(p_program_name  => p_bct_rec.program_name,
                        x_return_status => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_prog_short_name(p_prog_short_name => p_bct_rec.prog_short_name,
                           x_return_status   => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  validate_progress_status(p_progress_status => p_bct_rec.progress_status,
                           x_return_status   => l_return_status);

  -- store the highest degree of error
  IF (l_return_status <> OKL_API.G_RET_STS_SUCCESS) THEN
    IF (x_return_status <> OKL_API.G_RET_STS_UNEXP_ERROR) THEN
      x_return_status := l_return_status;
    END IF;
  END IF;

  RETURN (x_return_status);
END Validate_Attributes;
------------------------------------------------------
-- Validate Record for:OKL_BOOK_CONTROLLER_TRX --
------------------------------------------------------
FUNCTION Validate_Record (
  p_bct_rec IN okl_bct_rec
 )RETURN VARCHAR2 IS
  l_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  x_return_status   VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
BEGIN
  RETURN (x_return_status);
END Validate_Record;
--------------------------------------------------------------------------------
-- Procedure insert_row for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE insert_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec,
     x_bct_rec         OUT NOCOPY okl_bct_rec)IS

  l_api_version     CONSTANT NUMBER:=1;
  l_api_name        CONSTANT VARCHAR2(30):='insert_row';
  l_return_status   VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  l_bct_rec         okl_bct_rec;
  l_def_bct_rec     okl_bct_rec;

  FUNCTION fill_who_columns(
    p_bct_rec  IN okl_bct_rec
   )RETURN okl_bct_rec IS
    l_bct_rec okl_bct_rec:=p_bct_rec;
  BEGIN
    l_bct_rec.CREATION_DATE := SYSDATE;
    l_bct_rec.CREATED_BY := FND_GLOBAL.USER_ID;
    l_bct_rec.LAST_UPDATE_DATE := SYSDATE;
    l_bct_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_bct_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
    RETURN (l_bct_rec);
  END fill_who_columns;

  FUNCTION Set_Attributes(
    p_bct_rec IN okl_bct_rec,
    x_bct_rec OUT NOCOPY okl_bct_rec
   )RETURN VARCHAR2 IS
    l_return_status            VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_bct_rec := p_bct_rec;
    RETURN (l_return_status);
  END Set_Attributes;
  --procedure begins here
BEGIN
  l_return_status := OKL_API.START_ACTIVITY(
                          l_api_name,
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

  l_bct_rec:=null_out_defaults(p_bct_rec);

  --Setting Item Attributes
  l_return_status:=Set_Attributes(l_bct_rec,l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_def_bct_rec := fill_who_columns(l_def_bct_rec);

  l_return_status := Validate_Attributes(l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_return_status := Validate_Record(l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  INSERT INTO OKL_BOOK_CONTROLLER_TRX(
    USER_ID,
    ORG_ID,
    BATCH_NUMBER,
    PROCESSING_SRL_NUMBER,
    KHR_ID,
    PROGRAM_NAME,
    PROG_SHORT_NAME,
    CONC_REQ_ID,
    PROGRESS_STATUS,
    CREATED_BY,
    CREATION_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN,
    ACTIVE_FLAG)
  VALUES(
    l_def_bct_rec.USER_ID,
    l_def_bct_rec.ORG_ID,
    l_def_bct_rec.BATCH_NUMBER,
    l_def_bct_rec.PROCESSING_SRL_NUMBER,
    l_def_bct_rec.KHR_ID,
    l_def_bct_rec.PROGRAM_NAME,
    l_def_bct_rec.PROG_SHORT_NAME,
    l_def_bct_rec.CONC_REQ_ID,
    l_def_bct_rec.PROGRESS_STATUS,
    l_def_bct_rec.CREATED_BY,
    l_def_bct_rec.CREATION_DATE,
    l_def_bct_rec.LAST_UPDATED_BY,
    l_def_bct_rec.LAST_UPDATE_DATE,
    l_def_bct_rec.LAST_UPDATE_LOGIN,
    l_def_bct_rec.ACTIVE_FLAG);

  --Set OUT Values
  x_bct_rec:= l_def_bct_rec;
  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
  -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END insert_row;
--------------------------------------------------------------------------------
-- Procedure insert_row with PL/SQL table for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE insert_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl,
     x_bct_tbl         OUT NOCOPY okl_bct_tbl)IS

  l_api_version     CONSTANT NUMBER:=1;
  l_api_name        CONSTANT VARCHAR2(30):='insert_row_tbl';
  l_return_status   VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  i                 NUMBER:=0;
  l_overall_status  VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
BEGIN
  OKL_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
  IF (p_bct_tbl.COUNT > 0) THEN
    i := p_bct_tbl.FIRST;
    LOOP
      insert_row(p_api_version   => p_api_version,
                 p_init_msg_list => OKL_API.G_FALSE,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_bct_rec       => p_bct_tbl(i),
                 x_bct_rec       => x_bct_tbl(i));

      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
        END IF;
      END IF;

      EXIT WHEN (i = p_bct_tbl.LAST);
      i := p_bct_tbl.NEXT(i);
    END LOOP;
    x_return_status := l_overall_status;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END insert_row;
--------------------------------------------------------------------------------
-- Procedure update_row for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE update_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec,
     x_bct_rec         OUT NOCOPY okl_bct_rec)IS

  l_api_version     CONSTANT NUMBER:=1;
  l_api_name        CONSTANT VARCHAR2(30):='update_row';
  l_return_status   VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  l_bct_rec         okl_bct_rec:=p_bct_rec;
  l_def_bct_rec     okl_bct_rec;

  FUNCTION fill_who_columns(
    p_bct_rec  IN okl_bct_rec
   )RETURN okl_bct_rec IS
    l_bct_rec   okl_bct_rec:=p_bct_rec;
  BEGIN
    l_bct_rec.LAST_UPDATE_DATE := SYSDATE;
    l_bct_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    l_bct_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
    RETURN (l_bct_rec );
  END fill_who_columns;

  FUNCTION populate_new_record(
    p_bct_rec   IN okl_bct_rec,
    x_bct_rec   OUT NOCOPY okl_bct_rec
   )RETURN VARCHAR2 is
    l_bct_rec       okl_bct_rec;
    l_row_notfound  BOOLEAN:=TRUE;
    l_return_status VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  BEGIN

    x_bct_rec := p_bct_rec;
    --Get current database values
    l_bct_rec := get_rec(p_bct_rec,l_row_notfound);
    IF(l_row_notfound) THEN
      l_return_status:= OKL_API.G_RET_STS_UNEXP_ERROR;
    END IF;

    IF (x_bct_rec.USER_ID = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.USER_ID:=l_bct_rec.USER_ID;
    END IF;
    IF (x_bct_rec.ORG_ID = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.ORG_ID:=l_bct_rec.ORG_ID;
    END IF;
    IF (x_bct_rec.BATCH_NUMBER = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.BATCH_NUMBER:=l_bct_rec.BATCH_NUMBER;
    END IF;
    IF (x_bct_rec.PROCESSING_SRL_NUMBER = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.PROCESSING_SRL_NUMBER:=l_bct_rec.PROCESSING_SRL_NUMBER;
    END IF;
    IF (x_bct_rec.KHR_ID = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.KHR_ID:=l_bct_rec.KHR_ID;
    END IF;
    IF (x_bct_rec.PROGRAM_NAME = OKL_API.G_MISS_CHAR) THEN
      x_bct_rec.PROGRAM_NAME:=l_bct_rec.PROGRAM_NAME;
    END IF;
    IF (x_bct_rec.PROG_SHORT_NAME = OKL_API.G_MISS_CHAR) THEN
      x_bct_rec.PROG_SHORT_NAME:=l_bct_rec.PROG_SHORT_NAME;
    END IF;
    IF (x_bct_rec.CONC_REQ_ID = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.CONC_REQ_ID:=l_bct_rec.CONC_REQ_ID;
    END IF;
    IF (x_bct_rec.PROGRESS_STATUS = OKL_API.G_MISS_CHAR) THEN
      x_bct_rec.PROGRESS_STATUS:=l_bct_rec.PROGRESS_STATUS;
    END IF;
    IF (x_bct_rec.CREATED_BY = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.CREATED_BY:=l_bct_rec.CREATED_BY;
    END IF;
    IF (x_bct_rec.CREATION_DATE = OKL_API.G_MISS_DATE) THEN
      x_bct_rec.CREATION_DATE:=l_bct_rec.CREATION_DATE;
    END IF;
    IF (x_bct_rec.LAST_UPDATED_BY = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.LAST_UPDATED_BY:=l_bct_rec.LAST_UPDATED_BY;
    END IF;
    IF (x_bct_rec.LAST_UPDATE_DATE = OKL_API.G_MISS_DATE) THEN
      x_bct_rec.LAST_UPDATE_DATE:=l_bct_rec.LAST_UPDATE_DATE;
    END IF;
    IF (x_bct_rec.LAST_UPDATE_LOGIN = OKL_API.G_MISS_NUM) THEN
      x_bct_rec.LAST_UPDATE_LOGIN:=l_bct_rec.LAST_UPDATE_LOGIN;
    END IF;
    IF (x_bct_rec.ACTIVE_FLAG = OKL_API.G_MISS_CHAR) THEN
      x_bct_rec.ACTIVE_FLAG:=l_bct_rec.ACTIVE_FLAG;
    END IF;
    RETURN(l_return_status);
  END populate_new_record;

  FUNCTION Set_Attributes(
    p_bct_rec IN okl_bct_rec,
    x_bct_rec OUT NOCOPY okl_bct_rec
   )RETURN VARCHAR2 IS
    l_return_status  VARCHAR2(1) := OKL_API.G_RET_STS_SUCCESS;
  BEGIN
    x_bct_rec := p_bct_rec;
    RETURN (l_return_status);
  END Set_Attributes;
--procedure begins here
BEGIN
  l_return_status := OKL_API.START_ACTIVITY(
                          l_api_name,
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
  l_return_status:=Set_Attributes(p_bct_rec,l_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_return_status := populate_new_record(l_bct_rec,l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_def_bct_rec := fill_who_columns(l_def_bct_rec);

  l_return_status := Validate_Attributes(l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;

  l_return_status := Validate_Record(l_def_bct_rec);
  IF (l_return_status = OKL_API.G_RET_STS_UNEXP_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_UNEXPECTED_ERROR;
  ELSIF (l_return_status = OKL_API.G_RET_STS_ERROR) THEN
    RAISE OKL_API.G_EXCEPTION_ERROR;
  END IF;


  UPDATE OKL_BOOK_CONTROLLER_TRX
  SET
    USER_ID= l_def_bct_rec.USER_ID,
    ORG_ID= l_def_bct_rec.ORG_ID,
    BATCH_NUMBER= l_def_bct_rec.BATCH_NUMBER,
    PROCESSING_SRL_NUMBER= l_def_bct_rec.PROCESSING_SRL_NUMBER,
    KHR_ID= l_def_bct_rec.KHR_ID,
    PROGRAM_NAME= l_def_bct_rec.PROGRAM_NAME,
    PROG_SHORT_NAME= l_def_bct_rec.PROG_SHORT_NAME,
    CONC_REQ_ID= l_def_bct_rec.CONC_REQ_ID,
    PROGRESS_STATUS= l_def_bct_rec.PROGRESS_STATUS,
    CREATED_BY= l_def_bct_rec.CREATED_BY,
    CREATION_DATE= l_def_bct_rec.CREATION_DATE,
    LAST_UPDATED_BY= l_def_bct_rec.LAST_UPDATED_BY,
    LAST_UPDATE_DATE= l_def_bct_rec.LAST_UPDATE_DATE,
    LAST_UPDATE_LOGIN= l_def_bct_rec.LAST_UPDATE_LOGIN,
    ACTIVE_FLAG= l_def_bct_rec.ACTIVE_FLAG
  WHERE BATCH_NUMBER = l_def_bct_rec.BATCH_NUMBER
  AND PROCESSING_SRL_NUMBER = l_def_bct_rec.PROCESSING_SRL_NUMBER;

  --Set OUT Values
  x_bct_rec:= l_def_bct_rec;
  OKL_API.END_ACTIVITY(x_msg_count, x_msg_data);

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END update_row;
--------------------------------------------------------------------------------
-- Procedure update_row with PL/SQL table for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE update_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl,
     x_bct_tbl         OUT NOCOPY okl_bct_tbl)IS

  l_api_version     CONSTANT NUMBER:=1;
  l_api_name        CONSTANT VARCHAR2(30):='update_row_tbl';
  l_return_status   VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  i                 NUMBER:=0;
  l_overall_status  VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
BEGIN
  OKL_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_bct_tbl.COUNT > 0) THEN
    i := p_bct_tbl.FIRST;
    LOOP
      update_row (p_api_version   => p_api_version,
                  p_init_msg_list => OKL_API.G_FALSE,
                  x_return_status => x_return_status,
                  x_msg_count     => x_msg_count,
                  x_msg_data      => x_msg_data,
                  p_bct_rec       => p_bct_tbl(i),
                  x_bct_rec       => x_bct_tbl(i));
      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
        END IF;
      END IF;

      EXIT WHEN (i = p_bct_tbl.LAST);
      i := p_bct_tbl.NEXT(i);
    END LOOP;
    x_return_status := l_overall_status;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END update_row;
--------------------------------------------------------------------------------
-- Procedure delete_row for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE delete_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_rec         IN okl_bct_rec)IS

  l_api_version    CONSTANT NUMBER:=1;
  l_api_name       CONSTANT VARCHAR2(30):='delete_row';
  l_return_status  VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  l_bct_rec        okl_bct_rec := p_bct_rec;
  l_row_notfound   BOOLEAN:=TRUE;

BEGIN
  l_return_status := OKL_API.START_ACTIVITY(
                          l_api_name,
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

  DELETE FROM OKL_BOOK_CONTROLLER_TRX
  WHERE BATCH_NUMBER=l_bct_rec.batch_number
  AND PROCESSING_SRL_NUMBER = l_bct_rec.processing_srl_number;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END delete_row;
--------------------------------------------------------------------------------
-- Procedure delete_row with PL/SQL table for:OKL_BOOK_CONTROLLER_TRX --
--------------------------------------------------------------------------------
PROCEDURE delete_row(
     p_api_version     IN NUMBER ,
     p_init_msg_list   IN VARCHAR2 DEFAULT OKL_API.G_FALSE,
     x_return_status   OUT NOCOPY VARCHAR2,
     x_msg_count       OUT NOCOPY NUMBER,
     x_msg_data        OUT NOCOPY VARCHAR2,
     p_bct_tbl         IN okl_bct_tbl)IS

  l_api_version     CONSTANT NUMBER:=1;
  l_api_name        CONSTANT VARCHAR2(30):='delete_row_tbl';
  l_return_status   VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
  i                 NUMBER:=0;
  l_overall_status  VARCHAR2(1):=OKL_API.G_RET_STS_SUCCESS;
BEGIN
  OKL_API.init_msg_list(p_init_msg_list);
  -- Make sure PL/SQL table has records in it before passing
  IF (p_bct_tbl.COUNT > 0) THEN
    i := p_bct_tbl.FIRST;
    LOOP
      delete_row(p_api_version   => p_api_version,
                 p_init_msg_list => OKL_API.G_FALSE,
                 x_return_status => x_return_status,
                 x_msg_count     => x_msg_count,
                 x_msg_data      => x_msg_data,
                 p_bct_rec       => p_bct_tbl(i));
      IF x_return_status <> OKL_API.G_RET_STS_SUCCESS THEN
        IF l_overall_status <> OKL_API.G_RET_STS_UNEXP_ERROR THEN
          l_overall_status := x_return_status;
        END IF;
      END IF;

      EXIT WHEN (i = p_bct_tbl.LAST);
      i := p_bct_tbl.NEXT(i);
    END LOOP;
    x_return_status := l_overall_status;
  END IF;

EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION then
    -- No action necessary. Validation can continue to next attribute/column
    null;

  WHEN OKL_API.G_EXCEPTION_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OKL_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OKL_API.G_RET_STS_UNEXP_ERROR',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');

  WHEN OTHERS THEN
    x_return_status := OKL_API.HANDLE_EXCEPTIONS(
                            l_api_name,
                            G_PKG_NAME,
                            'OTHERS',
                            x_msg_count,
                            x_msg_data,
                            '_PVT');
END delete_row;

END OKL_BCT_PVT;

/
