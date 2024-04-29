--------------------------------------------------------
--  DDL for Package Body OKC_QLP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QLP_PVT" AS
/* $Header: OKCSQLPB.pls 120.0 2005/05/25 19:43:55 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_qlpv_rec IN  qlpv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD    CONSTANT VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR    CONSTANT VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_UPPER_CASE_REQUIRED CONSTANT VARCHAR2(200) := 'OKC_UPPER_CASE_REQUIRED';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_QA_LIST_PROCESSES_V';
  G_VALUE_NOT_UNIQUE		CONSTANT VARCHAR2(200) := 'OKC_VALUE_NOT_UNIQUE';
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_qcl_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_qcl_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_qclv_csr IS
      SELECT 'x'
        FROM OKC_QA_CHECK_LISTS_B qclv
       WHERE qclv.ID = p_qlpv_rec.QCL_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qlpv_rec.qcl_id = OKC_API.G_MISS_NUM OR
        p_qlpv_rec.qcl_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'qcl_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_qclv_csr;
    FETCH l_qclv_csr INTO l_dummy_var;
    CLOSE l_qclv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'qcl_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_QA_CHECK_LISTS_B');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_qclv_csr%ISOPEN THEN
      CLOSE l_qclv_csr;
    END IF;
  END validate_qcl_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_pdf_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_pdf_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_pdfv_csr IS
      SELECT 'x'
        FROM OKC_PROCESS_DEFS_B pdfv
       WHERE pdfv.ID = p_qlpv_rec.PDF_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qlpv_rec.pdf_id = OKC_API.G_MISS_NUM OR
        p_qlpv_rec.pdf_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'pdf_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_pdfv_csr;
    FETCH l_pdfv_csr INTO l_dummy_var;
    CLOSE l_pdfv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'pdf_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_PROCESS_DEFS_B');
      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  EXCEPTION
  WHEN G_EXCEPTION_HALT_VALIDATION THEN
    -- no processing necessary; validation can continue with next column
    NULL;
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    -- verify that cursor was closed
    IF l_pdfv_csr%ISOPEN THEN
      CLOSE l_pdfv_csr;
    END IF;
  END validate_pdf_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_severity
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_severity(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qlpv_rec.severity = OKC_API.G_MISS_CHAR OR
        p_qlpv_rec.severity IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'severity');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is uppercase
    IF (p_qlpv_rec.severity <> upper(p_qlpv_rec.severity)) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UPPER_CASE_REQUIRED,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'severity');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    -- check allowed values
    IF (UPPER(p_qlpv_rec.severity) NOT IN ('W', 'S')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'severity');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_severity;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_active_yn
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_active_yn(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qlpv_rec.active_yn = OKC_API.G_MISS_CHAR OR
        p_qlpv_rec.active_yn IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'active_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- verify that data is uppercase
    IF (p_qlpv_rec.active_yn <> upper(p_qlpv_rec.active_yn)) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UPPER_CASE_REQUIRED,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'active_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;

    -- check allowed values
    IF (UPPER(p_qlpv_rec.active_yn) NOT IN ('Y','N')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'active_yn');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_active_yn;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_run_sequence
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_run_sequence(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qlpv_rec.run_sequence = OKC_API.G_MISS_NUM OR
        p_qlpv_rec.run_sequence IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'run_sequence');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_run_sequence;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_uniqueness
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_uniqueness(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_count NUMBER;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    SELECT COUNT(1)
      INTO l_count
      FROM OKC_QA_LIST_PROCESSES_V qlp
     WHERE PDF_ID = p_qlpv_rec.pdf_id
       AND QCL_ID = p_qlpv_rec.qcl_id;
    /*   AND RUN_SEQUENCE = p_qlpv_rec.run_sequence
       AND ((p_qlpv_rec.row_id IS NULL) OR (ROWID <> p_qlpv_rec.row_id)); */

    IF (l_count >= 1) then
       --set error message in message stack
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_VALUE_NOT_UNIQUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'Process');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1	        => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPETED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_uniqueness;
 -- Start of comments
  --
  -- Procedure Name  : validate_access_level
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_access_level(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qlpv_rec      IN    qlpv_rec_type
  ) IS
    l_return_status     VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- verify that data is uppercase
    IF (p_qlpv_rec.access_level <> upper(p_qlpv_rec.access_level)) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_UPPER_CASE_REQUIRED,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'access_level');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    end if;
   -- check allowed values
   IF p_qlpv_rec.access_level is not null then
    IF (UPPER(p_qlpv_rec.access_level) NOT IN ('S','U','E')) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_INVALID_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'access_level');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack
    OKC_API.SET_MESSAGE(
      p_app_name        => G_APP_NAME,
      p_msg_name        => G_UNEXPECTED_ERROR,
      p_token1          => G_SQLCODE_TOKEN,
      p_token1_value    => SQLCODE,
      p_token2          => G_SQLERRM_TOKEN,
      p_token2_value    => SQLERRM);
    -- notify caller of an error as UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_access_level;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_attributes
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  FUNCTION Validate_Attributes (
    p_qlpv_rec IN  qlpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    validate_qcl_id(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_pdf_id(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_severity(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_active_yn(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_run_sequence(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
  validate_access_level(
      x_return_status => l_return_status,
      p_qlpv_rec      => p_qlpv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;

--
    -- return status to caller
    RETURN(x_return_status);

  EXCEPTION
  WHEN OTHERS THEN
    -- store SQL error message on message stack for caller
    OKC_API.SET_MESSAGE
      (p_app_name     => G_APP_NAME,
       p_msg_name     => G_UNEXPECTED_ERROR,
       p_token1       => G_SQLCODE_TOKEN,
       p_token1_value => SQLCODE,
       p_token2       => G_SQLERRM_TOKEN,
       p_token2_value => SQLERRM);

    -- notify caller of an UNEXPECTED error
    x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    -- return status to caller
    RETURN x_return_status;

  END Validate_Attributes;

/***********************  END HAND-CODED  **************************/

/* $Header: OKCSQLPB.pls 120.0 2005/05/25 19:43:55 appldev noship $ */
  ---------------------------------------------------------------------------
  -- FUNCTION get_seq_id
  ---------------------------------------------------------------------------
  FUNCTION get_seq_id RETURN NUMBER IS
  BEGIN
    RETURN(okc_p_util.raw_to_number(sys_guid()));
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
  -- FUNCTION get_rec for: OKC_QA_LIST_PROCESSES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qlp_rec                      IN qlp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qlp_rec_type IS
    CURSOR qlp_pk_csr (p_qcl_id             IN NUMBER,
                       p_pdf_id             IN NUMBER) IS
    SELECT
            PDF_ID,
            QCL_ID,
            SEVERITY,
            ACTIVE_YN,
            RUN_SEQUENCE,
            OBJECT_VERSION_NUMBER,
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
            ACCESS_LEVEL
      FROM Okc_Qa_List_Processes
     WHERE okc_qa_list_processes.qcl_id = p_qcl_id
       AND okc_qa_list_processes.pdf_id = p_pdf_id;
    l_qlp_pk                       qlp_pk_csr%ROWTYPE;
    l_qlp_rec                      qlp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qlp_pk_csr (p_qlp_rec.qcl_id,
                     p_qlp_rec.pdf_id);
    FETCH qlp_pk_csr INTO
              l_qlp_rec.PDF_ID,
              l_qlp_rec.QCL_ID,
              l_qlp_rec.SEVERITY,
              l_qlp_rec.ACTIVE_YN,
              l_qlp_rec.RUN_SEQUENCE,
              l_qlp_rec.OBJECT_VERSION_NUMBER,
              l_qlp_rec.CREATED_BY,
              l_qlp_rec.CREATION_DATE,
              l_qlp_rec.LAST_UPDATED_BY,
              l_qlp_rec.LAST_UPDATE_DATE,
              l_qlp_rec.LAST_UPDATE_LOGIN,
              l_qlp_rec.ATTRIBUTE_CATEGORY,
              l_qlp_rec.ATTRIBUTE1,
              l_qlp_rec.ATTRIBUTE2,
              l_qlp_rec.ATTRIBUTE3,
              l_qlp_rec.ATTRIBUTE4,
              l_qlp_rec.ATTRIBUTE5,
              l_qlp_rec.ATTRIBUTE6,
              l_qlp_rec.ATTRIBUTE7,
              l_qlp_rec.ATTRIBUTE8,
              l_qlp_rec.ATTRIBUTE9,
              l_qlp_rec.ATTRIBUTE10,
              l_qlp_rec.ATTRIBUTE11,
              l_qlp_rec.ATTRIBUTE12,
              l_qlp_rec.ATTRIBUTE13,
              l_qlp_rec.ATTRIBUTE14,
              l_qlp_rec.ATTRIBUTE15,
              l_qlp_rec.ACCESS_LEVEL;
    x_no_data_found := qlp_pk_csr%NOTFOUND;
    CLOSE qlp_pk_csr;
    RETURN(l_qlp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qlp_rec                      IN qlp_rec_type
  ) RETURN qlp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qlp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_QA_LIST_PROCESSES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qlpv_rec                     IN qlpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qlpv_rec_type IS
    CURSOR okc_qlpv_pk_csr (p_qcl_id             IN NUMBER,
                            p_pdf_id             IN NUMBER) IS
    SELECT
            QCL_ID,
            PDF_ID,
            OBJECT_VERSION_NUMBER,
            SEVERITY,
            ACTIVE_YN,
            RUN_SEQUENCE,
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
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            ACCESS_LEVEL
      FROM Okc_Qa_List_Processes_V
     WHERE okc_qa_list_processes_v.qcl_id = p_qcl_id
       AND okc_qa_list_processes_v.pdf_id = p_pdf_id;
    l_okc_qlpv_pk                  okc_qlpv_pk_csr%ROWTYPE;
    l_qlpv_rec                     qlpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_qlpv_pk_csr (p_qlpv_rec.qcl_id,
                          p_qlpv_rec.pdf_id);
    FETCH okc_qlpv_pk_csr INTO
              l_qlpv_rec.QCL_ID,
              l_qlpv_rec.PDF_ID,
              l_qlpv_rec.OBJECT_VERSION_NUMBER,
              l_qlpv_rec.SEVERITY,
              l_qlpv_rec.ACTIVE_YN,
              l_qlpv_rec.RUN_SEQUENCE,
              l_qlpv_rec.ATTRIBUTE_CATEGORY,
              l_qlpv_rec.ATTRIBUTE1,
              l_qlpv_rec.ATTRIBUTE2,
              l_qlpv_rec.ATTRIBUTE3,
              l_qlpv_rec.ATTRIBUTE4,
              l_qlpv_rec.ATTRIBUTE5,
              l_qlpv_rec.ATTRIBUTE6,
              l_qlpv_rec.ATTRIBUTE7,
              l_qlpv_rec.ATTRIBUTE8,
              l_qlpv_rec.ATTRIBUTE9,
              l_qlpv_rec.ATTRIBUTE10,
              l_qlpv_rec.ATTRIBUTE11,
              l_qlpv_rec.ATTRIBUTE12,
              l_qlpv_rec.ATTRIBUTE13,
              l_qlpv_rec.ATTRIBUTE14,
              l_qlpv_rec.ATTRIBUTE15,
              l_qlpv_rec.CREATED_BY,
              l_qlpv_rec.CREATION_DATE,
              l_qlpv_rec.LAST_UPDATED_BY,
              l_qlpv_rec.LAST_UPDATE_DATE,
              l_qlpv_rec.LAST_UPDATE_LOGIN,
              l_qlpv_rec.ACCESS_LEVEL;
    x_no_data_found := okc_qlpv_pk_csr%NOTFOUND;
    CLOSE okc_qlpv_pk_csr;
    RETURN(l_qlpv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qlpv_rec                     IN qlpv_rec_type
  ) RETURN qlpv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qlpv_rec, l_row_notfound));
  END get_rec;

  -------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_QA_LIST_PROCESSES_V --
  -------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qlpv_rec	IN qlpv_rec_type
  ) RETURN qlpv_rec_type IS
    l_qlpv_rec	qlpv_rec_type := p_qlpv_rec;
  BEGIN
    IF (l_qlpv_rec.qcl_id = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.qcl_id := NULL;
    END IF;
    IF (l_qlpv_rec.pdf_id = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.pdf_id := NULL;
    END IF;
    IF (l_qlpv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.object_version_number := NULL;
    END IF;
    IF (l_qlpv_rec.severity = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.severity := NULL;
    END IF;
    IF (l_qlpv_rec.active_yn = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.active_yn := NULL;
    END IF;
    IF (l_qlpv_rec.run_sequence = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.run_sequence := NULL;
    END IF;
    IF (l_qlpv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute_category := NULL;
    END IF;
    IF (l_qlpv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute1 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute2 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute3 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute4 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute5 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute6 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute7 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute8 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute9 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute10 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute11 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute12 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute13 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute14 := NULL;
    END IF;
    IF (l_qlpv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.attribute15 := NULL;
    END IF;
    IF (l_qlpv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.created_by := NULL;
    END IF;
    IF (l_qlpv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qlpv_rec.creation_date := NULL;
    END IF;
    IF (l_qlpv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qlpv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qlpv_rec.last_update_date := NULL;
    END IF;
    IF (l_qlpv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qlpv_rec.last_update_login := NULL;
    END IF;
    IF (l_qlpv_rec.access_level = OKC_API.G_MISS_CHAR) THEN
      l_qlpv_rec.access_level := NULL;
    END IF;
    RETURN(l_qlpv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  -------------------------------------------------
  -- Validate_Record for:OKC_QA_LIST_PROCESSES_V --
  -------------------------------------------------
  FUNCTION Validate_Record (
    p_qlpv_rec IN qlpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qlpv_rec_type,
    p_to	IN OUT NOCOPY qlp_rec_type
  ) IS
  BEGIN
    p_to.pdf_id := p_from.pdf_id;
    p_to.qcl_id := p_from.qcl_id;
    p_to.severity := p_from.severity;
    p_to.active_yn := p_from.active_yn;
    p_to.run_sequence := p_from.run_sequence;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.access_level := p_from.access_level;
  END migrate;
  PROCEDURE migrate (
    p_from	IN qlp_rec_type,
    p_to	IN OUT NOCOPY qlpv_rec_type
  ) IS
  BEGIN
    p_to.pdf_id := p_from.pdf_id;
    p_to.qcl_id := p_from.qcl_id;
    p_to.severity := p_from.severity;
    p_to.active_yn := p_from.active_yn;
    p_to.run_sequence := p_from.run_sequence;
    p_to.object_version_number := p_from.object_version_number;
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
    p_to.access_level := p_from.access_level;
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ----------------------------------------------
  -- validate_row for:OKC_QA_LIST_PROCESSES_V --
  ----------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN qlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
    l_qlp_rec                      qlp_rec_type;
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
    l_return_status := Validate_Attributes(l_qlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qlpv_rec);
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
  -- PL/SQL TBL validate_row for:QLPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN qlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qlpv_tbl.COUNT > 0) THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qlpv_rec                     => p_qlpv_tbl(i));
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
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
  ------------------------------------------
  -- insert_row for:OKC_QA_LIST_PROCESSES --
  ------------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlp_rec                      IN qlp_rec_type,
    x_qlp_rec                      OUT NOCOPY qlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlp_rec                      qlp_rec_type := p_qlp_rec;
    l_def_qlp_rec                  qlp_rec_type;
    ----------------------------------------------
    -- Set_Attributes for:OKC_QA_LIST_PROCESSES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_qlp_rec IN  qlp_rec_type,
      x_qlp_rec OUT NOCOPY qlp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlp_rec := p_qlp_rec;
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
      p_qlp_rec,                         -- IN
      l_qlp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_QA_LIST_PROCESSES(
        pdf_id,
        qcl_id,
        severity,
        active_yn,
        run_sequence,
        object_version_number,
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
        access_level)
      VALUES (
        l_qlp_rec.pdf_id,
        l_qlp_rec.qcl_id,
        l_qlp_rec.severity,
        l_qlp_rec.active_yn,
        l_qlp_rec.run_sequence,
        l_qlp_rec.object_version_number,
        l_qlp_rec.created_by,
        l_qlp_rec.creation_date,
        l_qlp_rec.last_updated_by,
        l_qlp_rec.last_update_date,
        l_qlp_rec.last_update_login,
        l_qlp_rec.attribute_category,
        l_qlp_rec.attribute1,
        l_qlp_rec.attribute2,
        l_qlp_rec.attribute3,
        l_qlp_rec.attribute4,
        l_qlp_rec.attribute5,
        l_qlp_rec.attribute6,
        l_qlp_rec.attribute7,
        l_qlp_rec.attribute8,
        l_qlp_rec.attribute9,
        l_qlp_rec.attribute10,
        l_qlp_rec.attribute11,
        l_qlp_rec.attribute12,
        l_qlp_rec.attribute13,
        l_qlp_rec.attribute14,
        l_qlp_rec.attribute15,
        l_qlp_rec.access_level);
    -- Set OUT values
    x_qlp_rec := l_qlp_rec;
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
  --------------------------------------------
  -- insert_row for:OKC_QA_LIST_PROCESSES_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlpv_rec                     qlpv_rec_type;
    l_def_qlpv_rec                 qlpv_rec_type;
    l_qlp_rec                      qlp_rec_type;
    lx_qlp_rec                     qlp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qlpv_rec	IN qlpv_rec_type
    ) RETURN qlpv_rec_type IS
      l_qlpv_rec	qlpv_rec_type := p_qlpv_rec;
    BEGIN
      l_qlpv_rec.CREATION_DATE := SYSDATE;
      l_qlpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_qlpv_rec.LAST_UPDATE_DATE := l_qlpv_rec.CREATION_DATE;
      l_qlpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qlpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qlpv_rec);
    END fill_who_columns;
    ------------------------------------------------
    -- Set_Attributes for:OKC_QA_LIST_PROCESSES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_qlpv_rec IN  qlpv_rec_type,
      x_qlpv_rec OUT NOCOPY qlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlpv_rec := p_qlpv_rec;
      x_qlpv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_qlpv_rec := null_out_defaults(p_qlpv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qlpv_rec,                        -- IN
      l_def_qlpv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qlpv_rec := fill_who_columns(l_def_qlpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qlpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    validate_uniqueness(x_return_status => l_return_status,
                        p_qlpv_rec      => l_def_qlpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qlpv_rec, l_qlp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qlp_rec,
      lx_qlp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qlp_rec, l_def_qlpv_rec);
    -- Set OUT values
    x_qlpv_rec := l_def_qlpv_rec;
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
  -- PL/SQL TBL insert_row for:QLPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN qlpv_tbl_type,
    x_qlpv_tbl                     OUT NOCOPY qlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qlpv_tbl.COUNT > 0) THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qlpv_rec                     => p_qlpv_tbl(i),
          x_qlpv_rec                     => x_qlpv_tbl(i));
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
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
  ----------------------------------------
  -- lock_row for:OKC_QA_LIST_PROCESSES --
  ----------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlp_rec                      IN qlp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qlp_rec IN qlp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_LIST_PROCESSES
     WHERE QCL_ID = p_qlp_rec.qcl_id
       AND PDF_ID = p_qlp_rec.pdf_id
       AND OBJECT_VERSION_NUMBER = p_qlp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qlp_rec IN qlp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_LIST_PROCESSES
    WHERE QCL_ID = p_qlp_rec.qcl_id
       AND PDF_ID = p_qlp_rec.pdf_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_QA_LIST_PROCESSES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_QA_LIST_PROCESSES.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qlp_rec);
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
      OPEN lchk_csr(p_qlp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qlp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qlp_rec.object_version_number THEN
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
  ------------------------------------------
  -- lock_row for:OKC_QA_LIST_PROCESSES_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN qlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlp_rec                      qlp_rec_type;
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
    migrate(p_qlpv_rec, l_qlp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qlp_rec
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
  -- PL/SQL TBL lock_row for:QLPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN qlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qlpv_tbl.COUNT > 0) THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qlpv_rec                     => p_qlpv_tbl(i));
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
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
  ------------------------------------------
  -- update_row for:OKC_QA_LIST_PROCESSES --
  ------------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlp_rec                      IN qlp_rec_type,
    x_qlp_rec                      OUT NOCOPY qlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlp_rec                      qlp_rec_type := p_qlp_rec;
    l_def_qlp_rec                  qlp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qlp_rec	IN qlp_rec_type,
      x_qlp_rec	OUT NOCOPY qlp_rec_type
    ) RETURN VARCHAR2 IS
      l_qlp_rec                      qlp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlp_rec := p_qlp_rec;
      -- Get current database values
      l_qlp_rec := get_rec(p_qlp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qlp_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.pdf_id := l_qlp_rec.pdf_id;
      END IF;
      IF (x_qlp_rec.qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.qcl_id := l_qlp_rec.qcl_id;
      END IF;
      IF (x_qlp_rec.severity = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.severity := l_qlp_rec.severity;
      END IF;
      IF (x_qlp_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.active_yn := l_qlp_rec.active_yn;
      END IF;
      IF (x_qlp_rec.run_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.run_sequence := l_qlp_rec.run_sequence;
      END IF;
      IF (x_qlp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.object_version_number := l_qlp_rec.object_version_number;
      END IF;
      IF (x_qlp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.created_by := l_qlp_rec.created_by;
      END IF;
      IF (x_qlp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qlp_rec.creation_date := l_qlp_rec.creation_date;
      END IF;
      IF (x_qlp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.last_updated_by := l_qlp_rec.last_updated_by;
      END IF;
      IF (x_qlp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qlp_rec.last_update_date := l_qlp_rec.last_update_date;
      END IF;
      IF (x_qlp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qlp_rec.last_update_login := l_qlp_rec.last_update_login;
      END IF;
      IF (x_qlp_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute_category := l_qlp_rec.attribute_category;
      END IF;
      IF (x_qlp_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute1 := l_qlp_rec.attribute1;
      END IF;
      IF (x_qlp_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute2 := l_qlp_rec.attribute2;
      END IF;
      IF (x_qlp_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute3 := l_qlp_rec.attribute3;
      END IF;
      IF (x_qlp_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute4 := l_qlp_rec.attribute4;
      END IF;
      IF (x_qlp_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute5 := l_qlp_rec.attribute5;
      END IF;
      IF (x_qlp_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute6 := l_qlp_rec.attribute6;
      END IF;
      IF (x_qlp_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute7 := l_qlp_rec.attribute7;
      END IF;
      IF (x_qlp_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute8 := l_qlp_rec.attribute8;
      END IF;
      IF (x_qlp_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute9 := l_qlp_rec.attribute9;
      END IF;
      IF (x_qlp_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute10 := l_qlp_rec.attribute10;
      END IF;
      IF (x_qlp_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute11 := l_qlp_rec.attribute11;
      END IF;
      IF (x_qlp_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute12 := l_qlp_rec.attribute12;
      END IF;
      IF (x_qlp_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute13 := l_qlp_rec.attribute13;
      END IF;
      IF (x_qlp_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute14 := l_qlp_rec.attribute14;
      END IF;
      IF (x_qlp_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.attribute15 := l_qlp_rec.attribute15;
      IF (x_qlp_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_qlp_rec.access_level := l_qlp_rec.access_level;
      END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ----------------------------------------------
    -- Set_Attributes for:OKC_QA_LIST_PROCESSES --
    ----------------------------------------------
    FUNCTION Set_Attributes (
      p_qlp_rec IN  qlp_rec_type,
      x_qlp_rec OUT NOCOPY qlp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlp_rec := p_qlp_rec;
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
      p_qlp_rec,                         -- IN
      l_qlp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qlp_rec, l_def_qlp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_QA_LIST_PROCESSES
    SET SEVERITY = l_def_qlp_rec.severity,
        ACTIVE_YN = l_def_qlp_rec.active_yn,
        RUN_SEQUENCE = l_def_qlp_rec.run_sequence,
        OBJECT_VERSION_NUMBER = l_def_qlp_rec.object_version_number,
        CREATED_BY = l_def_qlp_rec.created_by,
        CREATION_DATE = l_def_qlp_rec.creation_date,
        LAST_UPDATED_BY = l_def_qlp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qlp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qlp_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_qlp_rec.attribute_category,
        ATTRIBUTE1 = l_def_qlp_rec.attribute1,
        ATTRIBUTE2 = l_def_qlp_rec.attribute2,
        ATTRIBUTE3 = l_def_qlp_rec.attribute3,
        ATTRIBUTE4 = l_def_qlp_rec.attribute4,
        ATTRIBUTE5 = l_def_qlp_rec.attribute5,
        ATTRIBUTE6 = l_def_qlp_rec.attribute6,
        ATTRIBUTE7 = l_def_qlp_rec.attribute7,
        ATTRIBUTE8 = l_def_qlp_rec.attribute8,
        ATTRIBUTE9 = l_def_qlp_rec.attribute9,
        ATTRIBUTE10 = l_def_qlp_rec.attribute10,
        ATTRIBUTE11 = l_def_qlp_rec.attribute11,
        ATTRIBUTE12 = l_def_qlp_rec.attribute12,
        ATTRIBUTE13 = l_def_qlp_rec.attribute13,
        ATTRIBUTE14 = l_def_qlp_rec.attribute14,
        ATTRIBUTE15 = l_def_qlp_rec.attribute15,
        ACCESS_LEVEL = l_def_qlp_rec.access_level
    WHERE QCL_ID = l_def_qlp_rec.qcl_id
      AND PDF_ID = l_def_qlp_rec.pdf_id;

    x_qlp_rec := l_def_qlp_rec;
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
  --------------------------------------------
  -- update_row for:OKC_QA_LIST_PROCESSES_V --
  --------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN qlpv_rec_type,
    x_qlpv_rec                     OUT NOCOPY qlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
    l_def_qlpv_rec                 qlpv_rec_type;
    l_qlp_rec                      qlp_rec_type;
    lx_qlp_rec                     qlp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qlpv_rec	IN qlpv_rec_type
    ) RETURN qlpv_rec_type IS
      l_qlpv_rec	qlpv_rec_type := p_qlpv_rec;
    BEGIN
      l_qlpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qlpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qlpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qlpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qlpv_rec	IN qlpv_rec_type,
      x_qlpv_rec	OUT NOCOPY qlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_qlpv_rec                     qlpv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlpv_rec := p_qlpv_rec;
      -- Get current database values
      l_qlpv_rec := get_rec(p_qlpv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qlpv_rec.qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.qcl_id := l_qlpv_rec.qcl_id;
      END IF;
      IF (x_qlpv_rec.pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.pdf_id := l_qlpv_rec.pdf_id;
      END IF;
      IF (x_qlpv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.object_version_number := l_qlpv_rec.object_version_number;
      END IF;
      IF (x_qlpv_rec.severity = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.severity := l_qlpv_rec.severity;
      END IF;
      IF (x_qlpv_rec.active_yn = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.active_yn := l_qlpv_rec.active_yn;
      END IF;
      IF (x_qlpv_rec.run_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.run_sequence := l_qlpv_rec.run_sequence;
      END IF;
      IF (x_qlpv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute_category := l_qlpv_rec.attribute_category;
      END IF;
      IF (x_qlpv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute1 := l_qlpv_rec.attribute1;
      END IF;
      IF (x_qlpv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute2 := l_qlpv_rec.attribute2;
      END IF;
      IF (x_qlpv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute3 := l_qlpv_rec.attribute3;
      END IF;
      IF (x_qlpv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute4 := l_qlpv_rec.attribute4;
      END IF;
      IF (x_qlpv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute5 := l_qlpv_rec.attribute5;
      END IF;
      IF (x_qlpv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute6 := l_qlpv_rec.attribute6;
      END IF;
      IF (x_qlpv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute7 := l_qlpv_rec.attribute7;
      END IF;
      IF (x_qlpv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute8 := l_qlpv_rec.attribute8;
      END IF;
      IF (x_qlpv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute9 := l_qlpv_rec.attribute9;
      END IF;
      IF (x_qlpv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute10 := l_qlpv_rec.attribute10;
      END IF;
      IF (x_qlpv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute11 := l_qlpv_rec.attribute11;
      END IF;
      IF (x_qlpv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute12 := l_qlpv_rec.attribute12;
      END IF;
      IF (x_qlpv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute13 := l_qlpv_rec.attribute13;
      END IF;
      IF (x_qlpv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute14 := l_qlpv_rec.attribute14;
      END IF;
      IF (x_qlpv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.attribute15 := l_qlpv_rec.attribute15;
      END IF;
      IF (x_qlpv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.created_by := l_qlpv_rec.created_by;
      END IF;
      IF (x_qlpv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qlpv_rec.creation_date := l_qlpv_rec.creation_date;
      END IF;
      IF (x_qlpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.last_updated_by := l_qlpv_rec.last_updated_by;
      END IF;
      IF (x_qlpv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qlpv_rec.last_update_date := l_qlpv_rec.last_update_date;
      END IF;
      IF (x_qlpv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qlpv_rec.last_update_login := l_qlpv_rec.last_update_login;
      END IF;
      IF (x_qlpv_rec.access_level = OKC_API.G_MISS_CHAR)
      THEN
        x_qlpv_rec.access_level := l_qlpv_rec.access_level;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ------------------------------------------------
    -- Set_Attributes for:OKC_QA_LIST_PROCESSES_V --
    ------------------------------------------------
    FUNCTION Set_Attributes (
      p_qlpv_rec IN  qlpv_rec_type,
      x_qlpv_rec OUT NOCOPY qlpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qlpv_rec := p_qlpv_rec;
      x_qlpv_rec.OBJECT_VERSION_NUMBER := NVL(x_qlpv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qlpv_rec,                        -- IN
      l_qlpv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qlpv_rec, l_def_qlpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qlpv_rec := fill_who_columns(l_def_qlpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qlpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qlpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qlpv_rec, l_qlp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qlp_rec,
      lx_qlp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qlp_rec, l_def_qlpv_rec);
    x_qlpv_rec := l_def_qlpv_rec;
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
  -- PL/SQL TBL update_row for:QLPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN qlpv_tbl_type,
    x_qlpv_tbl                     OUT NOCOPY qlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qlpv_tbl.COUNT > 0) THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qlpv_rec                     => p_qlpv_tbl(i),
          x_qlpv_rec                     => x_qlpv_tbl(i));
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
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
  ------------------------------------------
  -- delete_row for:OKC_QA_LIST_PROCESSES --
  ------------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlp_rec                      IN qlp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PROCESSES_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlp_rec                      qlp_rec_type:= p_qlp_rec;
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
    DELETE FROM OKC_QA_LIST_PROCESSES
     WHERE QCL_ID = l_qlp_rec.qcl_id AND
PDF_ID = l_qlp_rec.pdf_id;

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
  --------------------------------------------
  -- delete_row for:OKC_QA_LIST_PROCESSES_V --
  --------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_rec                     IN qlpv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qlpv_rec                     qlpv_rec_type := p_qlpv_rec;
    l_qlp_rec                      qlp_rec_type;
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
    migrate(l_qlpv_rec, l_qlp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qlp_rec
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
  -- PL/SQL TBL delete_row for:QLPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qlpv_tbl                     IN qlpv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qlpv_tbl.COUNT > 0) THEN
      i := p_qlpv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qlpv_rec                     => p_qlpv_tbl(i));
        EXIT WHEN (i = p_qlpv_tbl.LAST);
        i := p_qlpv_tbl.NEXT(i);
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

END OKC_QLP_PVT;

/
