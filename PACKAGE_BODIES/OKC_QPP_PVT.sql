--------------------------------------------------------
--  DDL for Package Body OKC_QPP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKC_QPP_PVT" AS
/* $Header: OKCSQPPB.pls 120.0 2005/05/25 22:33:23 appldev noship $ */

	l_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

/***********************  HAND-CODED  **************************/
  FUNCTION Validate_Attributes
    (p_qppv_rec IN  qppv_rec_type) RETURN VARCHAR2;
  G_NO_PARENT_RECORD CONSTANT	VARCHAR2(200) := 'OKC_NO_PARENT_RECORD';
  G_UNEXPECTED_ERROR CONSTANT	VARCHAR2(200) := 'OKC_CONTRACTS_UNEXPECTED_ERROR';
  G_SQLERRM_TOKEN               CONSTANT VARCHAR2(200) := 'SQLerrm';
  G_SQLCODE_TOKEN	        CONSTANT VARCHAR2(200) := 'SQLcode';
  G_VIEW                        CONSTANT VARCHAR2(200) := 'OKC_QA_PROCESS_PARMS_V';
  G_VALUE_NOT_UNIQUE            CONSTANT VARCHAR2(200) := 'OKC_VALUE_NOT_UNIQUE' ;
  G_EXCEPTION_HALT_VALIDATION	exception;
  g_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  -- Start of comments
  --
  -- Procedure Name  : validate_qlp_qcl_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_qlp_qcl_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qppv_rec      IN    qppv_rec_type
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qppv_rec.qlp_qcl_id = OKC_API.G_MISS_NUM OR
        p_qppv_rec.qlp_qcl_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'qlp_qcl_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
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
  END validate_qlp_qcl_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_qlp_pdf_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_qlp_pdf_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qppv_rec      IN    qppv_rec_type
  ) IS
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qppv_rec.qlp_pdf_id = OKC_API.G_MISS_NUM OR
        p_qppv_rec.qlp_pdf_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'qlp_pdf_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
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
  END validate_qlp_pdf_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_pdp_id
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_pdp_id(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qppv_rec      IN    qppv_rec_type
  ) IS
    l_dummy_var   VARCHAR2(1) := '?';
    CURSOR l_pdpv_csr IS
      SELECT 'x'
        FROM OKC_PROCESS_DEF_PARMS_B pdpv
       WHERE pdpv.ID = p_qppv_rec.PDP_ID;
  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qppv_rec.pdp_id = OKC_API.G_MISS_NUM OR
        p_qppv_rec.pdp_id IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'pdp_id');

      -- notify caller of an error
      x_return_status := OKC_API.G_RET_STS_ERROR;

      -- halt validation
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- enforce foreign key
    OPEN  l_pdpv_csr;
    FETCH l_pdpv_csr INTO l_dummy_var;
    CLOSE l_pdpv_csr;

    -- if l_dummy_var still set to default, data was not found
    IF (l_dummy_var = '?') THEN
      OKC_API.set_message(
        p_app_name      => G_APP_NAME,
        p_msg_name      => G_NO_PARENT_RECORD,
        p_token1        => G_COL_NAME_TOKEN,
        p_token1_value  => 'pdp_id',
        p_token2        => G_CHILD_TABLE_TOKEN,
        p_token2_value  => G_VIEW,
        p_token3        => G_PARENT_TABLE_TOKEN,
        p_token3_value  => 'OKC_PROCESS_DEF_PARAMETERS_V');
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
    IF l_pdpv_csr%ISOPEN THEN
      CLOSE l_pdpv_csr;
    END IF;
  END validate_pdp_id;
--
  -- Start of comments
  --
  -- Procedure Name  : validate_parm_value
  -- Description     :
  -- Business Rules  :
  -- Parameters      :
  -- Version         : 1.0
  -- End of comments

  PROCEDURE validate_parm_value(
    x_return_status OUT NOCOPY   VARCHAR2,
    p_qppv_rec      IN    qppv_rec_type
  ) IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;

  BEGIN
    -- initialize return status
    x_return_status := OKC_API.G_RET_STS_SUCCESS;

    -- data is required
    IF (p_qppv_rec.parm_value = OKC_API.G_MISS_CHAR OR
        p_qppv_rec.parm_value IS NULL) THEN
      OKC_API.set_message(
        p_app_name     => G_APP_NAME,
        p_msg_name     => G_REQUIRED_VALUE,
        p_token1       => G_COL_NAME_TOKEN,
        p_token1_value => 'parm_value');

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
  END validate_parm_value;
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
    p_qppv_rec IN  qppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -- call each column-level validation

    validate_qlp_qcl_id(
      x_return_status => l_return_status,
      p_qppv_rec      => p_qppv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_qlp_pdf_id(
      x_return_status => l_return_status,
      p_qppv_rec      => p_qppv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_pdp_id(
      x_return_status => l_return_status,
      p_qppv_rec      => p_qppv_rec);

    -- store the highest degree of error
    IF (l_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      IF (x_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
        x_return_status := l_return_status;
      END IF;
    END IF;
--
    validate_parm_value(
      x_return_status => l_return_status,
      p_qppv_rec      => p_qppv_rec);

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
  -- FUNCTION get_rec for: OKC_QA_PROCESS_PARMS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qpp_rec                      IN qpp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qpp_rec_type IS
    CURSOR qpp_pk_csr (p_qlp_qcl_id         IN NUMBER,
                       p_qlp_pdf_id         IN NUMBER,
                       p_pdp_id             IN NUMBER) IS
    SELECT
            PDP_ID,
            QLP_PDF_ID,
            QLP_QCL_ID,
            QLP_RUN_SEQUENCE,
            PARM_VALUE,
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
            ATTRIBUTE15
      FROM Okc_Qa_Process_Parms
     WHERE okc_qa_process_parms.qlp_qcl_id = p_qlp_qcl_id
       AND okc_qa_process_parms.qlp_pdf_id = p_qlp_pdf_id
       AND okc_qa_process_parms.pdp_id = p_pdp_id;
    l_qpp_pk                       qpp_pk_csr%ROWTYPE;
    l_qpp_rec                      qpp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN qpp_pk_csr (p_qpp_rec.qlp_qcl_id,
                     p_qpp_rec.qlp_pdf_id,
                     p_qpp_rec.pdp_id);
    FETCH qpp_pk_csr INTO
              l_qpp_rec.PDP_ID,
              l_qpp_rec.QLP_PDF_ID,
              l_qpp_rec.QLP_QCL_ID,
              l_qpp_rec.QLP_RUN_SEQUENCE,
              l_qpp_rec.PARM_VALUE,
              l_qpp_rec.OBJECT_VERSION_NUMBER,
              l_qpp_rec.CREATED_BY,
              l_qpp_rec.CREATION_DATE,
              l_qpp_rec.LAST_UPDATED_BY,
              l_qpp_rec.LAST_UPDATE_DATE,
              l_qpp_rec.LAST_UPDATE_LOGIN,
              l_qpp_rec.ATTRIBUTE_CATEGORY,
              l_qpp_rec.ATTRIBUTE1,
              l_qpp_rec.ATTRIBUTE2,
              l_qpp_rec.ATTRIBUTE3,
              l_qpp_rec.ATTRIBUTE4,
              l_qpp_rec.ATTRIBUTE5,
              l_qpp_rec.ATTRIBUTE6,
              l_qpp_rec.ATTRIBUTE7,
              l_qpp_rec.ATTRIBUTE8,
              l_qpp_rec.ATTRIBUTE9,
              l_qpp_rec.ATTRIBUTE10,
              l_qpp_rec.ATTRIBUTE11,
              l_qpp_rec.ATTRIBUTE12,
              l_qpp_rec.ATTRIBUTE13,
              l_qpp_rec.ATTRIBUTE14,
              l_qpp_rec.ATTRIBUTE15;
    x_no_data_found := qpp_pk_csr%NOTFOUND;
    CLOSE qpp_pk_csr;
    RETURN(l_qpp_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qpp_rec                      IN qpp_rec_type
  ) RETURN qpp_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qpp_rec, l_row_notfound));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKC_QA_PROCESS_PARMS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_qppv_rec                     IN qppv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN qppv_rec_type IS
    CURSOR okc_qppv_pk_csr (p_qlp_qcl_id         IN NUMBER,
                            p_qlp_pdf_id         IN NUMBER,
                            p_qlp_run_sequence   IN NUMBER,
                            p_pdp_id             IN NUMBER) IS
    SELECT
            QLP_QCL_ID,
            QLP_PDF_ID,
            QLP_RUN_SEQUENCE,
            PDP_ID,
            OBJECT_VERSION_NUMBER,
            PARM_VALUE,
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
            LAST_UPDATE_LOGIN
      FROM Okc_Qa_Process_Parms_V
     WHERE okc_qa_process_parms_v.qlp_qcl_id = p_qlp_qcl_id
       AND okc_qa_process_parms_v.qlp_pdf_id = p_qlp_pdf_id
       AND okc_qa_process_parms_v.qlp_run_sequence = p_qlp_run_sequence
       AND okc_qa_process_parms_v.pdp_id = p_pdp_id;
    l_okc_qppv_pk                  okc_qppv_pk_csr%ROWTYPE;
    l_qppv_rec                     qppv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN okc_qppv_pk_csr (p_qppv_rec.qlp_qcl_id,
                          p_qppv_rec.qlp_pdf_id,
                          p_qppv_rec.qlp_run_sequence,
                          p_qppv_rec.pdp_id);
    FETCH okc_qppv_pk_csr INTO
              l_qppv_rec.QLP_QCL_ID,
              l_qppv_rec.QLP_PDF_ID,
              l_qppv_rec.QLP_RUN_SEQUENCE,
              l_qppv_rec.PDP_ID,
              l_qppv_rec.OBJECT_VERSION_NUMBER,
              l_qppv_rec.PARM_VALUE,
              l_qppv_rec.ATTRIBUTE_CATEGORY,
              l_qppv_rec.ATTRIBUTE1,
              l_qppv_rec.ATTRIBUTE2,
              l_qppv_rec.ATTRIBUTE3,
              l_qppv_rec.ATTRIBUTE4,
              l_qppv_rec.ATTRIBUTE5,
              l_qppv_rec.ATTRIBUTE6,
              l_qppv_rec.ATTRIBUTE7,
              l_qppv_rec.ATTRIBUTE8,
              l_qppv_rec.ATTRIBUTE9,
              l_qppv_rec.ATTRIBUTE10,
              l_qppv_rec.ATTRIBUTE11,
              l_qppv_rec.ATTRIBUTE12,
              l_qppv_rec.ATTRIBUTE13,
              l_qppv_rec.ATTRIBUTE14,
              l_qppv_rec.ATTRIBUTE15,
              l_qppv_rec.CREATED_BY,
              l_qppv_rec.CREATION_DATE,
              l_qppv_rec.LAST_UPDATED_BY,
              l_qppv_rec.LAST_UPDATE_DATE,
              l_qppv_rec.LAST_UPDATE_LOGIN;
    x_no_data_found := okc_qppv_pk_csr%NOTFOUND;
    CLOSE okc_qppv_pk_csr;
    RETURN(l_qppv_rec);
  END get_rec;

  FUNCTION get_rec (
    p_qppv_rec                     IN qppv_rec_type
  ) RETURN qppv_rec_type IS
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_qppv_rec, l_row_notfound));
  END get_rec;

  ------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKC_QA_PROCESS_PARMS_V --
  ------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_qppv_rec	IN qppv_rec_type
  ) RETURN qppv_rec_type IS
    l_qppv_rec	qppv_rec_type := p_qppv_rec;
  BEGIN
    IF (l_qppv_rec.qlp_qcl_id = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.qlp_qcl_id := NULL;
    END IF;
    IF (l_qppv_rec.qlp_pdf_id = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.qlp_pdf_id := NULL;
    END IF;
    IF (l_qppv_rec.qlp_run_sequence = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.qlp_run_sequence := NULL;
    END IF;
    IF (l_qppv_rec.pdp_id = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.pdp_id := NULL;
    END IF;
    IF (l_qppv_rec.object_version_number = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.object_version_number := NULL;
    END IF;
    IF (l_qppv_rec.parm_value = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.parm_value := NULL;
    END IF;
    IF (l_qppv_rec.attribute_category = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute_category := NULL;
    END IF;
    IF (l_qppv_rec.attribute1 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute1 := NULL;
    END IF;
    IF (l_qppv_rec.attribute2 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute2 := NULL;
    END IF;
    IF (l_qppv_rec.attribute3 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute3 := NULL;
    END IF;
    IF (l_qppv_rec.attribute4 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute4 := NULL;
    END IF;
    IF (l_qppv_rec.attribute5 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute5 := NULL;
    END IF;
    IF (l_qppv_rec.attribute6 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute6 := NULL;
    END IF;
    IF (l_qppv_rec.attribute7 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute7 := NULL;
    END IF;
    IF (l_qppv_rec.attribute8 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute8 := NULL;
    END IF;
    IF (l_qppv_rec.attribute9 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute9 := NULL;
    END IF;
    IF (l_qppv_rec.attribute10 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute10 := NULL;
    END IF;
    IF (l_qppv_rec.attribute11 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute11 := NULL;
    END IF;
    IF (l_qppv_rec.attribute12 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute12 := NULL;
    END IF;
    IF (l_qppv_rec.attribute13 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute13 := NULL;
    END IF;
    IF (l_qppv_rec.attribute14 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute14 := NULL;
    END IF;
    IF (l_qppv_rec.attribute15 = OKC_API.G_MISS_CHAR) THEN
      l_qppv_rec.attribute15 := NULL;
    END IF;
    IF (l_qppv_rec.created_by = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.created_by := NULL;
    END IF;
    IF (l_qppv_rec.creation_date = OKC_API.G_MISS_DATE) THEN
      l_qppv_rec.creation_date := NULL;
    END IF;
    IF (l_qppv_rec.last_updated_by = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.last_updated_by := NULL;
    END IF;
    IF (l_qppv_rec.last_update_date = OKC_API.G_MISS_DATE) THEN
      l_qppv_rec.last_update_date := NULL;
    END IF;
    IF (l_qppv_rec.last_update_login = OKC_API.G_MISS_NUM) THEN
      l_qppv_rec.last_update_login := NULL;
    END IF;
    RETURN(l_qppv_rec);
  END null_out_defaults;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKC_QA_PROCESS_PARMS_V --
  ----------------------------------------------------
/* commenting out nocopy generated code in favor of hand-coded procedure
  FUNCTION Validate_Attributes (
    p_qppv_rec IN  qppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status	VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    IF p_qppv_rec.qlp_qcl_id = OKC_API.G_MISS_NUM OR
       p_qppv_rec.qlp_qcl_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qlp_qcl_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qppv_rec.qlp_pdf_id = OKC_API.G_MISS_NUM OR
          p_qppv_rec.qlp_pdf_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'qlp_pdf_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qppv_rec.pdp_id = OKC_API.G_MISS_NUM OR
          p_qppv_rec.pdp_id IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'pdp_id');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qppv_rec.object_version_number = OKC_API.G_MISS_NUM OR
          p_qppv_rec.object_version_number IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'object_version_number');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    ELSIF p_qppv_rec.parm_value = OKC_API.G_MISS_CHAR OR
          p_qppv_rec.parm_value IS NULL
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE,G_COL_NAME_TOKEN,'parm_value');
      l_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_return_status);
  END Validate_Attributes;
*/
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
  ------------------------------------------------
  -- Validate_Record for:OKC_QA_PROCESS_PARMS_V --
  ------------------------------------------------
  FUNCTION Validate_Record (
    p_qppv_rec IN qppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_count NUMBER;
  BEGIN
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
    SELECT COUNT(1)
    INTO l_count
    FROM OKC_QA_PROCESS_PARMS_V qpp
    WHERE QLP_QCL_ID = p_qppv_rec.qlp_qcl_id
    AND QLP_PDF_ID = p_qppv_rec.qlp_pdf_id
    AND PDP_ID = p_qppv_rec.pdp_id
    AND QLP_RUN_SEQUENCE = p_qppv_rec.qlp_run_sequence;

   IF (l_count > 1) then
    OKC_API.set_Message(
      p_app_name  => G_APP_NAME,
      p_msg_name  => G_INVALID_VALUE,
      p_token1    => G_COL_NAME_TOKEN,
      p_token1_value => 'Parameter Name');
  l_return_status := OKC_API.G_RET_STS_ERROR;
   -- RETURN (l_return_status);
  END IF;
    return(l_return_status);
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
  l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
    return(l_return_status);
  END Validate_Record;

-- Called from insert_row
  FUNCTION Validate_ins_Record (
    p_qppv_rec IN qppv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_count    NUMBER;
  BEGIN
    l_return_status := OKC_API.G_RET_STS_SUCCESS;
        SELECT COUNT(1)
       INTO l_count
      FROM OKC_QA_PROCESS_PARMS_V qpp
     WHERE QLP_QCL_ID = p_qppv_rec.qlp_qcl_id
    AND QLP_PDF_ID = p_qppv_rec.qlp_pdf_id
   AND PDP_ID = p_qppv_rec.pdp_id
 AND QLP_RUN_SEQUENCE = p_qppv_rec.qlp_run_sequence;

     IF (l_count = 1) then
    OKC_API.set_Message(
     p_app_name  => G_APP_NAME,
     p_msg_name  => G_INVALID_VALUE,
     p_token1    => G_COL_NAME_TOKEN,
     p_token1_value => 'Parameter Name');
          l_return_status := OKC_API.G_RET_STS_ERROR;
     end if;
     return(l_return_status);

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

    l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;

    RETURN (l_return_status);
  END Validate_ins_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from	IN qppv_rec_type,
    p_to	IN OUT NOCOPY qpp_rec_type
  ) IS
  BEGIN
    p_to.pdp_id := p_from.pdp_id;
    p_to.qlp_pdf_id := p_from.qlp_pdf_id;
    p_to.qlp_qcl_id := p_from.qlp_qcl_id;
    p_to.qlp_run_sequence := p_from.qlp_run_sequence;
    p_to.parm_value := p_from.parm_value;
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
  END migrate;
  PROCEDURE migrate (
    p_from	IN qpp_rec_type,
    p_to	IN OUT NOCOPY qppv_rec_type
  ) IS
  BEGIN
    p_to.pdp_id := p_from.pdp_id;
    p_to.qlp_pdf_id := p_from.qlp_pdf_id;
    p_to.qlp_qcl_id := p_from.qlp_qcl_id;
    p_to.qlp_run_sequence := p_from.qlp_run_sequence;
    p_to.parm_value := p_from.parm_value;
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
  END migrate;

  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKC_QA_PROCESS_PARMS_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN qppv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
    l_qpp_rec                      qpp_rec_type;
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
    l_return_status := Validate_Attributes(l_qppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_qppv_rec);
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
  -- PL/SQL TBL validate_row for:QPPV_TBL --
  ------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN qppv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qppv_tbl.COUNT > 0) THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        validate_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qppv_rec                     => p_qppv_tbl(i));
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
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
  -----------------------------------------
  -- insert_row for:OKC_QA_PROCESS_PARMS --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpp_rec                      IN qpp_rec_type,
    x_qpp_rec                      OUT NOCOPY qpp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpp_rec                      qpp_rec_type := p_qpp_rec;
    l_def_qpp_rec                  qpp_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_PROCESS_PARMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qpp_rec IN  qpp_rec_type,
      x_qpp_rec OUT NOCOPY qpp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpp_rec := p_qpp_rec;
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
      p_qpp_rec,                         -- IN
      l_qpp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKC_QA_PROCESS_PARMS(
        pdp_id,
        qlp_pdf_id,
        qlp_qcl_id,
        qlp_run_sequence,
        parm_value,
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
        attribute15)
      VALUES (
        l_qpp_rec.pdp_id,
        l_qpp_rec.qlp_pdf_id,
        l_qpp_rec.qlp_qcl_id,
        l_qpp_rec.qlp_run_sequence,
        l_qpp_rec.parm_value,
        l_qpp_rec.object_version_number,
        l_qpp_rec.created_by,
        l_qpp_rec.creation_date,
        l_qpp_rec.last_updated_by,
        l_qpp_rec.last_update_date,
        l_qpp_rec.last_update_login,
        l_qpp_rec.attribute_category,
        l_qpp_rec.attribute1,
        l_qpp_rec.attribute2,
        l_qpp_rec.attribute3,
        l_qpp_rec.attribute4,
        l_qpp_rec.attribute5,
        l_qpp_rec.attribute6,
        l_qpp_rec.attribute7,
        l_qpp_rec.attribute8,
        l_qpp_rec.attribute9,
        l_qpp_rec.attribute10,
        l_qpp_rec.attribute11,
        l_qpp_rec.attribute12,
        l_qpp_rec.attribute13,
        l_qpp_rec.attribute14,
        l_qpp_rec.attribute15);
    -- Set OUT values
    x_qpp_rec := l_qpp_rec;
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
  -------------------------------------------
  -- insert_row for:OKC_QA_PROCESS_PARMS_V --
  -------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qppv_rec                     qppv_rec_type;
    l_def_qppv_rec                 qppv_rec_type;
    l_qpp_rec                      qpp_rec_type;
    lx_qpp_rec                     qpp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qppv_rec	IN qppv_rec_type
    ) RETURN qppv_rec_type IS
      l_qppv_rec	qppv_rec_type := p_qppv_rec;
    BEGIN
      l_qppv_rec.CREATION_DATE := SYSDATE;
      l_qppv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      --l_qppv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qppv_rec.LAST_UPDATE_DATE := l_qppv_rec.CREATION_DATE ;
      l_qppv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qppv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qppv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKC_QA_PROCESS_PARMS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_qppv_rec IN  qppv_rec_type,
      x_qppv_rec OUT NOCOPY qppv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qppv_rec := p_qppv_rec;
      x_qppv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_qppv_rec := null_out_defaults(p_qppv_rec);
    --- Setting item attributes
    l_return_status := Set_Attributes(
      l_qppv_rec,                        -- IN
      l_def_qppv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qppv_rec := fill_who_columns(l_def_qppv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_ins_Record(l_def_qppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qppv_rec, l_qpp_rec);
    --------------------------------------------
    -- Call the INSERT_ROW for each child record
    --------------------------------------------
    insert_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpp_rec,
      lx_qpp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qpp_rec, l_def_qppv_rec);
    -- Set OUT values
    x_qppv_rec := l_def_qppv_rec;
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
  -- PL/SQL TBL insert_row for:QPPV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN qppv_tbl_type,
    x_qppv_tbl                     OUT NOCOPY qppv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qppv_tbl.COUNT > 0) THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        insert_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qppv_rec                     => p_qppv_tbl(i),
          x_qppv_rec                     => x_qppv_tbl(i));
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
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
  ---------------------------------------
  -- lock_row for:OKC_QA_PROCESS_PARMS --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpp_rec                      IN qpp_rec_type) IS

    E_Resource_Busy               EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_qpp_rec IN qpp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_PROCESS_PARMS
     WHERE QLP_QCL_ID = p_qpp_rec.qlp_qcl_id
       AND QLP_PDF_ID = p_qpp_rec.qlp_pdf_id
       AND QLP_RUN_SEQUENCE = p_qpp_rec.qlp_run_sequence
       AND PDP_ID = p_qpp_rec.pdp_id
       AND OBJECT_VERSION_NUMBER = p_qpp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR  lchk_csr (p_qpp_rec IN qpp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKC_QA_PROCESS_PARMS
    WHERE QLP_QCL_ID = p_qpp_rec.qlp_qcl_id
       AND QLP_PDF_ID = p_qpp_rec.qlp_pdf_id
       AND PDP_ID = p_qpp_rec.pdp_id;
    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number       OKC_QA_PROCESS_PARMS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number      OKC_QA_PROCESS_PARMS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_qpp_rec);
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
      OPEN lchk_csr(p_qpp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_qpp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_qpp_rec.object_version_number THEN
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
  -----------------------------------------
  -- lock_row for:OKC_QA_PROCESS_PARMS_V --
  -----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN qppv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpp_rec                      qpp_rec_type;
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
    migrate(p_qppv_rec, l_qpp_rec);
    --------------------------------------------
    -- Call the LOCK_ROW for each child record
    --------------------------------------------
    lock_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpp_rec
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
  -- PL/SQL TBL lock_row for:QPPV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN qppv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qppv_tbl.COUNT > 0) THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        lock_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qppv_rec                     => p_qppv_tbl(i));
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
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
  -----------------------------------------
  -- update_row for:OKC_QA_PROCESS_PARMS --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpp_rec                      IN qpp_rec_type,
    x_qpp_rec                      OUT NOCOPY qpp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpp_rec                      qpp_rec_type := p_qpp_rec;
    l_def_qpp_rec                  qpp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qpp_rec	IN qpp_rec_type,
      x_qpp_rec	OUT NOCOPY qpp_rec_type
    ) RETURN VARCHAR2 IS
      l_qpp_rec                      qpp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpp_rec := p_qpp_rec;
      -- Get current database values
      l_qpp_rec := get_rec(p_qpp_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qpp_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.pdp_id := l_qpp_rec.pdp_id;
      END IF;
      IF (x_qpp_rec.qlp_pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.qlp_pdf_id := l_qpp_rec.qlp_pdf_id;
      END IF;
      IF (x_qpp_rec.qlp_qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.qlp_qcl_id := l_qpp_rec.qlp_qcl_id;
      END IF;
      IF (x_qpp_rec.qlp_run_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.qlp_run_sequence := l_qpp_rec.qlp_run_sequence;
      END IF;
      IF (x_qpp_rec.parm_value = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.parm_value := l_qpp_rec.parm_value;
      END IF;
      IF (x_qpp_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.object_version_number := l_qpp_rec.object_version_number;
      END IF;
      IF (x_qpp_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.created_by := l_qpp_rec.created_by;
      END IF;
      IF (x_qpp_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpp_rec.creation_date := l_qpp_rec.creation_date;
      END IF;
      IF (x_qpp_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.last_updated_by := l_qpp_rec.last_updated_by;
      END IF;
      IF (x_qpp_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qpp_rec.last_update_date := l_qpp_rec.last_update_date;
      END IF;
      IF (x_qpp_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qpp_rec.last_update_login := l_qpp_rec.last_update_login;
      END IF;
      IF (x_qpp_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute_category := l_qpp_rec.attribute_category;
      END IF;
      IF (x_qpp_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute1 := l_qpp_rec.attribute1;
      END IF;
      IF (x_qpp_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute2 := l_qpp_rec.attribute2;
      END IF;
      IF (x_qpp_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute3 := l_qpp_rec.attribute3;
      END IF;
      IF (x_qpp_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute4 := l_qpp_rec.attribute4;
      END IF;
      IF (x_qpp_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute5 := l_qpp_rec.attribute5;
      END IF;
      IF (x_qpp_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute6 := l_qpp_rec.attribute6;
      END IF;
      IF (x_qpp_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute7 := l_qpp_rec.attribute7;
      END IF;
      IF (x_qpp_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute8 := l_qpp_rec.attribute8;
      END IF;
      IF (x_qpp_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute9 := l_qpp_rec.attribute9;
      END IF;
      IF (x_qpp_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute10 := l_qpp_rec.attribute10;
      END IF;
      IF (x_qpp_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute11 := l_qpp_rec.attribute11;
      END IF;
      IF (x_qpp_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute12 := l_qpp_rec.attribute12;
      END IF;
      IF (x_qpp_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute13 := l_qpp_rec.attribute13;
      END IF;
      IF (x_qpp_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute14 := l_qpp_rec.attribute14;
      END IF;
      IF (x_qpp_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qpp_rec.attribute15 := l_qpp_rec.attribute15;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKC_QA_PROCESS_PARMS --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_qpp_rec IN  qpp_rec_type,
      x_qpp_rec OUT NOCOPY qpp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qpp_rec := p_qpp_rec;
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
      p_qpp_rec,                         -- IN
      l_qpp_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qpp_rec, l_def_qpp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE  OKC_QA_PROCESS_PARMS
    SET PARM_VALUE = l_def_qpp_rec.parm_value,
        OBJECT_VERSION_NUMBER = l_def_qpp_rec.object_version_number,
        CREATED_BY = l_def_qpp_rec.created_by,
        CREATION_DATE = l_def_qpp_rec.creation_date,
        LAST_UPDATED_BY = l_def_qpp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_qpp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_qpp_rec.last_update_login,
        ATTRIBUTE_CATEGORY = l_def_qpp_rec.attribute_category,
        ATTRIBUTE1 = l_def_qpp_rec.attribute1,
        ATTRIBUTE2 = l_def_qpp_rec.attribute2,
        ATTRIBUTE3 = l_def_qpp_rec.attribute3,
        ATTRIBUTE4 = l_def_qpp_rec.attribute4,
        ATTRIBUTE5 = l_def_qpp_rec.attribute5,
        ATTRIBUTE6 = l_def_qpp_rec.attribute6,
        ATTRIBUTE7 = l_def_qpp_rec.attribute7,
        ATTRIBUTE8 = l_def_qpp_rec.attribute8,
        ATTRIBUTE9 = l_def_qpp_rec.attribute9,
        ATTRIBUTE10 = l_def_qpp_rec.attribute10,
        ATTRIBUTE11 = l_def_qpp_rec.attribute11,
        ATTRIBUTE12 = l_def_qpp_rec.attribute12,
        ATTRIBUTE13 = l_def_qpp_rec.attribute13,
        ATTRIBUTE14 = l_def_qpp_rec.attribute14,
        ATTRIBUTE15 = l_def_qpp_rec.attribute15
    WHERE QLP_QCL_ID = l_def_qpp_rec.qlp_qcl_id
      AND QLP_PDF_ID = l_def_qpp_rec.qlp_pdf_id
      AND QLP_RUN_SEQUENCE = l_def_qpp_rec.qlp_run_sequence
      AND PDP_ID = l_def_qpp_rec.pdp_id;

    x_qpp_rec := l_def_qpp_rec;
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
  -------------------------------------------
  -- update_row for:OKC_QA_PROCESS_PARMS_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN qppv_rec_type,
    x_qppv_rec                     OUT NOCOPY qppv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
    l_def_qppv_rec                 qppv_rec_type;
    l_qpp_rec                      qpp_rec_type;
    lx_qpp_rec                     qpp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_qppv_rec	IN qppv_rec_type
    ) RETURN qppv_rec_type IS
      l_qppv_rec	qppv_rec_type := p_qppv_rec;
    BEGIN
      l_qppv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_qppv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_qppv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_qppv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_qppv_rec	IN qppv_rec_type,
      x_qppv_rec	OUT NOCOPY qppv_rec_type
    ) RETURN VARCHAR2 IS
      l_qppv_rec                     qppv_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qppv_rec := p_qppv_rec;
      -- Get current database values
      l_qppv_rec := get_rec(p_qppv_rec, l_row_notfound);
      IF (l_row_notfound) THEN
        l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      END IF;
      IF (x_qppv_rec.qlp_qcl_id = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.qlp_qcl_id := l_qppv_rec.qlp_qcl_id;
      END IF;
      IF (x_qppv_rec.qlp_pdf_id = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.qlp_pdf_id := l_qppv_rec.qlp_pdf_id;
      END IF;
      IF (x_qppv_rec.qlp_run_sequence = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.qlp_run_sequence := l_qppv_rec.qlp_run_sequence;
      END IF;
      IF (x_qppv_rec.pdp_id = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.pdp_id := l_qppv_rec.pdp_id;
      END IF;
      IF (x_qppv_rec.object_version_number = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.object_version_number := l_qppv_rec.object_version_number;
      END IF;
      IF (x_qppv_rec.parm_value = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.parm_value := l_qppv_rec.parm_value;
      END IF;
      IF (x_qppv_rec.attribute_category = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute_category := l_qppv_rec.attribute_category;
      END IF;
      IF (x_qppv_rec.attribute1 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute1 := l_qppv_rec.attribute1;
      END IF;
      IF (x_qppv_rec.attribute2 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute2 := l_qppv_rec.attribute2;
      END IF;
      IF (x_qppv_rec.attribute3 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute3 := l_qppv_rec.attribute3;
      END IF;
      IF (x_qppv_rec.attribute4 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute4 := l_qppv_rec.attribute4;
      END IF;
      IF (x_qppv_rec.attribute5 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute5 := l_qppv_rec.attribute5;
      END IF;
      IF (x_qppv_rec.attribute6 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute6 := l_qppv_rec.attribute6;
      END IF;
      IF (x_qppv_rec.attribute7 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute7 := l_qppv_rec.attribute7;
      END IF;
      IF (x_qppv_rec.attribute8 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute8 := l_qppv_rec.attribute8;
      END IF;
      IF (x_qppv_rec.attribute9 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute9 := l_qppv_rec.attribute9;
      END IF;
      IF (x_qppv_rec.attribute10 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute10 := l_qppv_rec.attribute10;
      END IF;
      IF (x_qppv_rec.attribute11 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute11 := l_qppv_rec.attribute11;
      END IF;
      IF (x_qppv_rec.attribute12 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute12 := l_qppv_rec.attribute12;
      END IF;
      IF (x_qppv_rec.attribute13 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute13 := l_qppv_rec.attribute13;
      END IF;
      IF (x_qppv_rec.attribute14 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute14 := l_qppv_rec.attribute14;
      END IF;
      IF (x_qppv_rec.attribute15 = OKC_API.G_MISS_CHAR)
      THEN
        x_qppv_rec.attribute15 := l_qppv_rec.attribute15;
      END IF;
      IF (x_qppv_rec.created_by = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.created_by := l_qppv_rec.created_by;
      END IF;
      IF (x_qppv_rec.creation_date = OKC_API.G_MISS_DATE)
      THEN
        x_qppv_rec.creation_date := l_qppv_rec.creation_date;
      END IF;
      IF (x_qppv_rec.last_updated_by = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.last_updated_by := l_qppv_rec.last_updated_by;
      END IF;
      IF (x_qppv_rec.last_update_date = OKC_API.G_MISS_DATE)
      THEN
        x_qppv_rec.last_update_date := l_qppv_rec.last_update_date;
      END IF;
      IF (x_qppv_rec.last_update_login = OKC_API.G_MISS_NUM)
      THEN
        x_qppv_rec.last_update_login := l_qppv_rec.last_update_login;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKC_QA_PROCESS_PARMS_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_qppv_rec IN  qppv_rec_type,
      x_qppv_rec OUT NOCOPY qppv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_qppv_rec := p_qppv_rec;
      x_qppv_rec.OBJECT_VERSION_NUMBER := NVL(x_qppv_rec.OBJECT_VERSION_NUMBER, 0) + 1;
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
      p_qppv_rec,                        -- IN
      l_qppv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_qppv_rec, l_def_qppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_qppv_rec := fill_who_columns(l_def_qppv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_qppv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_qppv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    --------------------------------------
    -- Move VIEW record to "Child" records
    --------------------------------------
    migrate(l_def_qppv_rec, l_qpp_rec);
    --------------------------------------------
    -- Call the UPDATE_ROW for each child record
    --------------------------------------------
    update_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpp_rec,
      lx_qpp_rec
    );
    IF (x_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (x_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_qpp_rec, l_def_qppv_rec);
    x_qppv_rec := l_def_qppv_rec;
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
  -- PL/SQL TBL update_row for:QPPV_TBL --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN qppv_tbl_type,
    x_qppv_tbl                     OUT NOCOPY qppv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qppv_tbl.COUNT > 0) THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        update_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qppv_rec                     => p_qppv_tbl(i),
          x_qppv_rec                     => x_qppv_tbl(i));
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
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
  -----------------------------------------
  -- delete_row for:OKC_QA_PROCESS_PARMS --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qpp_rec                      IN qpp_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'PARMS_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qpp_rec                      qpp_rec_type:= p_qpp_rec;
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
    DELETE FROM OKC_QA_PROCESS_PARMS
     WHERE QLP_QCL_ID = l_qpp_rec.qlp_qcl_id AND
QLP_PDF_ID = l_qpp_rec.qlp_pdf_id AND
QLP_RUN_SEQUENCE = l_qpp_rec.qlp_run_sequence AND
PDP_ID = l_qpp_rec.pdp_id;

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
  -------------------------------------------
  -- delete_row for:OKC_QA_PROCESS_PARMS_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_rec                     IN qppv_rec_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_qppv_rec                     qppv_rec_type := p_qppv_rec;
    l_qpp_rec                      qpp_rec_type;
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
    migrate(l_qppv_rec, l_qpp_rec);
    --------------------------------------------
    -- Call the DELETE_ROW for each child record
    --------------------------------------------
    delete_row(
      p_init_msg_list,
      x_return_status,
      x_msg_count,
      x_msg_data,
      l_qpp_rec
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
  -- PL/SQL TBL delete_row for:QPPV_TBL --
  ----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2 ,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_qppv_tbl                     IN qppv_tbl_type) IS

    l_api_version                 CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_qppv_tbl.COUNT > 0) THEN
      i := p_qppv_tbl.FIRST;
      LOOP
        delete_row (
          p_api_version                  => p_api_version,
          p_init_msg_list                => OKC_API.G_FALSE,
          x_return_status                => x_return_status,
          x_msg_count                    => x_msg_count,
          x_msg_data                     => x_msg_data,
          p_qppv_rec                     => p_qppv_tbl(i));
        EXIT WHEN (i = p_qppv_tbl.LAST);
        i := p_qppv_tbl.NEXT(i);
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

END OKC_QPP_PVT;

/
