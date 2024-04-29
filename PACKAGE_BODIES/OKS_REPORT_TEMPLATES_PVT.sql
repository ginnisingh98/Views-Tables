--------------------------------------------------------
--  DDL for Package Body OKS_REPORT_TEMPLATES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_REPORT_TEMPLATES_PVT" AS
/* $Header: OKSRTMPB.pls 120.1.12000000.6 2007/05/10 00:32:14 skekkar ship $ */

 ------------------------------------------------------------------------------
  -- GLOBAL CONSTANTS
  ------------------------------------------------------------------------------
  g_module    CONSTANT VARCHAR2 (250) := 'oks.plsql.' ||g_pkg_name||'.';

  ---------------------------------------------------------------------------
  -- PROCEDURE load_error_tbl
  ---------------------------------------------------------------------------
  PROCEDURE load_error_tbl (
    px_error_rec                   IN OUT NOCOPY OKC_API.ERROR_REC_TYPE,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    j                              INTEGER := NVL(px_error_tbl.LAST, 0) + 1;
    last_msg_idx                   INTEGER := FND_MSG_PUB.COUNT_MSG;
    l_msg_idx                      INTEGER := FND_MSG_PUB.G_NEXT;
  BEGIN
    -- FND_MSG_PUB has a small error in it.  If we call FND_MSG_PUB.COUNT_AND_GET before
    -- we call FND_MSG_PUB.GET, the variable FND_MSG_PUB uses to control the index of the
    -- message stack gets set to 1.  This makes sense until we call FND_MSG_PUB.GET which
    -- automatically increments the index by 1, (making it 2), however, when the GET function
    -- attempts to pull message 2, we get a NO_DATA_FOUND exception because there isn't any
    -- message 2.  To circumvent this problem, check the amount of messages and compensate.
    -- Again, this error only occurs when 1 message is on the stack because COUNT_AND_GET
    -- will only update the index variable when 1 and only 1 message is on the stack.
    IF (last_msg_idx = 1) THEN
      l_msg_idx := FND_MSG_PUB.G_FIRST;
    END IF;
    LOOP
      fnd_msg_pub.get(
            p_msg_index     => l_msg_idx,
            p_encoded       => fnd_api.g_false,
            p_data          => px_error_rec.msg_data,
            p_msg_index_out => px_error_rec.msg_count);
      px_error_tbl(j) := px_error_rec;
      j := j + 1;
    EXIT WHEN (px_error_rec.msg_count = last_msg_idx);
    END LOOP;
  END load_error_tbl;
  ---------------------------------------------------------------------------
  -- FUNCTION find_highest_exception
  ---------------------------------------------------------------------------
  -- Finds the highest exception (G_RET_STS_UNEXP_ERROR)
  -- in a OKC_API.ERROR_TBL_TYPE, and returns it.
  FUNCTION find_highest_exception(
    p_error_tbl                    IN OKC_API.ERROR_TBL_TYPE
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    i                              INTEGER := 1;
  BEGIN
    IF (p_error_tbl.COUNT > 0) THEN
      i := p_error_tbl.FIRST;
      LOOP
        IF (p_error_tbl(i).error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
          IF (l_return_status <> OKC_API.G_RET_STS_UNEXP_ERROR) THEN
            l_return_status := p_error_tbl(i).error_type;
          END IF;
        END IF;
        EXIT WHEN (i = p_error_tbl.LAST);
        i := p_error_tbl.NEXT(i);
      END LOOP;
    END IF;
    RETURN(l_return_status);
  END find_highest_exception;
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
  -- FUNCTION get_rec for: OKS_REPORT_TEMPLATES_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rtmpv_rec_type IS
    CURSOR oks_report_templates_v_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            REPORT_ID,
            TEMPLATE_SET_ID,
            TEMPLATE_SET_TYPE,
            START_DATE,
            END_DATE,
            REPORT_DURATION,
            REPORT_PERIOD,
            STS_CODE,
            PROCESS_CODE,
            APPLIES_TO,
            ATTACHMENT_NAME,
            MESSAGE_TEMPLATE_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER
      FROM Oks_Report_Templates_V
     WHERE oks_report_templates_v.id = p_id;
    l_oks_report_templates_v_pk    oks_report_templates_v_pk_csr%ROWTYPE;
    l_rtmpv_rec                    rtmpv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_report_templates_v_pk_csr (p_rtmpv_rec.id);
    FETCH oks_report_templates_v_pk_csr INTO
              l_rtmpv_rec.id,
              l_rtmpv_rec.report_id,
              l_rtmpv_rec.template_set_id,
              l_rtmpv_rec.template_set_type,
              l_rtmpv_rec.start_date,
              l_rtmpv_rec.end_date,
              l_rtmpv_rec.report_duration,
              l_rtmpv_rec.report_period,
              l_rtmpv_rec.sts_code,
              l_rtmpv_rec.process_code,
              l_rtmpv_rec.applies_to,
              l_rtmpv_rec.attachment_name,
              l_rtmpv_rec.message_template_id,
              l_rtmpv_rec.created_by,
              l_rtmpv_rec.creation_date,
              l_rtmpv_rec.last_updated_by,
              l_rtmpv_rec.last_update_date,
              l_rtmpv_rec.last_update_login,
              l_rtmpv_rec.object_version_number;
    x_no_data_found := oks_report_templates_v_pk_csr%NOTFOUND;
    CLOSE oks_report_templates_v_pk_csr;
    RETURN(l_rtmpv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rtmpv_rec_type IS
    l_rtmpv_rec                    rtmpv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_rtmpv_rec := get_rec(p_rtmpv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rtmpv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rtmpv_rec                    IN rtmpv_rec_type
  ) RETURN rtmpv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rtmpv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_REPORT_TEMPLATES
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_rtmp_rec                     IN rtmp_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN rtmp_rec_type IS
    CURSOR oks_report_temp_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            REPORT_ID,
            TEMPLATE_SET_ID,
            TEMPLATE_SET_TYPE,
            START_DATE,
            END_DATE,
            REPORT_DURATION,
            REPORT_PERIOD,
            STS_CODE,
            PROCESS_CODE,
            APPLIES_TO,
            ATTACHMENT_NAME,
            MESSAGE_TEMPLATE_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            LAST_UPDATE_LOGIN,
            OBJECT_VERSION_NUMBER
      FROM Oks_Report_Templates
     WHERE oks_report_templates.id = p_id;
    l_oks_report_temp_pk           oks_report_temp_pk_csr%ROWTYPE;
    l_rtmp_rec                     rtmp_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_report_temp_pk_csr (p_rtmp_rec.id);
    FETCH oks_report_temp_pk_csr INTO
              l_rtmp_rec.id,
              l_rtmp_rec.report_id,
              l_rtmp_rec.template_set_id,
              l_rtmp_rec.template_set_type,
              l_rtmp_rec.start_date,
              l_rtmp_rec.end_date,
              l_rtmp_rec.report_duration,
              l_rtmp_rec.report_period,
              l_rtmp_rec.sts_code,
              l_rtmp_rec.process_code,
              l_rtmp_rec.applies_to,
              l_rtmp_rec.attachment_name,
              l_rtmp_rec.message_template_id,
              l_rtmp_rec.created_by,
              l_rtmp_rec.creation_date,
              l_rtmp_rec.last_updated_by,
              l_rtmp_rec.last_update_date,
              l_rtmp_rec.last_update_login,
              l_rtmp_rec.object_version_number;
    x_no_data_found := oks_report_temp_pk_csr%NOTFOUND;
    CLOSE oks_report_temp_pk_csr;
    RETURN(l_rtmp_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_rtmp_rec                     IN rtmp_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN rtmp_rec_type IS
    l_rtmp_rec                     rtmp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_rtmp_rec := get_rec(p_rtmp_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_rtmp_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_rtmp_rec                     IN rtmp_rec_type
  ) RETURN rtmp_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_rtmp_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_REPORT_TEMPLATES_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_rtmpv_rec   IN rtmpv_rec_type
  ) RETURN rtmpv_rec_type IS
    l_rtmpv_rec                    rtmpv_rec_type := p_rtmpv_rec;
  BEGIN
    IF (l_rtmpv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.id := NULL;
    END IF;
    IF (l_rtmpv_rec.report_id = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.report_id := NULL;
    END IF;
    IF (l_rtmpv_rec.template_set_id = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.template_set_id := NULL;
    END IF;
    IF (l_rtmpv_rec.template_set_type = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.template_set_type := NULL;
    END IF;
    IF (l_rtmpv_rec.start_date = OKC_API.G_MISS_DATE ) THEN
      l_rtmpv_rec.start_date := NULL;
    END IF;
    IF (l_rtmpv_rec.end_date = OKC_API.G_MISS_DATE ) THEN
      l_rtmpv_rec.end_date := NULL;
    END IF;
    IF (l_rtmpv_rec.report_duration = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.report_duration := NULL;
    END IF;
    IF (l_rtmpv_rec.report_period = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.report_period := NULL;
    END IF;
    IF (l_rtmpv_rec.sts_code = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.sts_code := NULL;
    END IF;
    IF (l_rtmpv_rec.process_code = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.process_code := NULL;
    END IF;
    IF (l_rtmpv_rec.applies_to = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.applies_to := NULL;
    END IF;
    IF (l_rtmpv_rec.attachment_name = OKC_API.G_MISS_CHAR ) THEN
      l_rtmpv_rec.attachment_name := NULL;
    END IF;
    IF (l_rtmpv_rec.message_template_id = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.message_template_id := NULL;
    END IF;
    IF (l_rtmpv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.created_by := NULL;
    END IF;
    IF (l_rtmpv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_rtmpv_rec.creation_date := NULL;
    END IF;
    IF (l_rtmpv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.last_updated_by := NULL;
    END IF;
    IF (l_rtmpv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_rtmpv_rec.last_update_date := NULL;
    END IF;
    IF (l_rtmpv_rec.last_update_login = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.last_update_login := NULL;
    END IF;
    IF (l_rtmpv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_rtmpv_rec.object_version_number := NULL;
    END IF;
    RETURN(l_rtmpv_rec);
  END null_out_defaults;
  ---------------------------------
  -- Validate_Attributes for: ID --
  ---------------------------------
  PROCEDURE validate_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_id                           IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_id = OKC_API.G_MISS_NUM OR
        p_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_id;
  ----------------------------------------------
  -- Validate_Attributes for: TEMPLATE_SET_ID --
  ----------------------------------------------
  PROCEDURE validate_template_set_id(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_template_set_id              IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_template_set_id = OKC_API.G_MISS_NUM OR
        p_template_set_id IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'template_set_id');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_template_set_id;
  ----------------------------------------------------
  -- Validate_Attributes for: OBJECT_VERSION_NUMBER --
  ----------------------------------------------------
  PROCEDURE validate_object_version_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_object_version_number        IN NUMBER) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_object_version_number = OKC_API.G_MISS_NUM OR
        p_object_version_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'object_version_number');
      x_return_status := OKC_API.G_RET_STS_ERROR;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      null;
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      x_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
  END validate_object_version_number;
  ---------------------------------------------------------------------------
  -- FUNCTION Validate_Attributes
  ---------------------------------------------------------------------------
  ----------------------------------------------------
  -- Validate_Attributes for:OKS_REPORT_TEMPLATES_V --
  ----------------------------------------------------
  FUNCTION Validate_Attributes (
    p_rtmpv_rec                    IN rtmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    x_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    -----------------------------
    -- Column Level Validation --
    -----------------------------
    -- ***
    -- id
    -- ***
    validate_id(x_return_status, p_rtmpv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- template_set_id
    -- ***
    validate_template_set_id(x_return_status, p_rtmpv_rec.template_set_id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_rtmpv_rec.object_version_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    RETURN(l_return_status);
  EXCEPTION
    WHEN G_EXCEPTION_HALT_VALIDATION THEN
      RETURN(l_return_status);
    WHEN OTHERS THEN
      OKC_API.SET_MESSAGE( p_app_name     => G_APP_NAME
                          ,p_msg_name     => G_UNEXPECTED_ERROR
                          ,p_token1       => G_SQLCODE_TOKEN
                          ,p_token1_value => SQLCODE
                          ,p_token2       => G_SQLERRM_TOKEN
                          ,p_token2_value => SQLERRM);
      l_return_status := OKC_API.G_RET_STS_UNEXP_ERROR;
      RETURN(l_return_status);
  END Validate_Attributes;
  ---------------------------------------------------------------------------
  -- PROCEDURE Validate_Record
  ---------------------------------------------------------------------------
------------------------------------------------
-- Validate Record for:OKS_REPORT_TEMPLATES_V --
------------------------------------------------
FUNCTION Validate_Record (
    p_rtmpv_rec IN rtmpv_rec_type,
    p_db_rtmpv_rec IN rtmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
-- skekkar
l_start_date          oks_report_templates.start_date%TYPE;
l_end_date            oks_report_templates.end_date%TYPE;
l_report_duration     oks_report_templates.report_duration%TYPE;
l_report_period       oks_report_templates.report_period%TYPE;
l_dummy               VARCHAR2(1);

l_api_name CONSTANT VARCHAR2 (30) := 'Validate_Record';

CURSOR csr_check_record1(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_process_code    IN VARCHAR2,
                         p_applies_to      IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   AND process_code = p_process_code
   AND applies_to = p_applies_to
   AND id  <> p_id;

CURSOR csr_check_record2(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_process_code    IN VARCHAR2,
                         p_applies_to      IN VARCHAR2,
                         p_report_duration IN NUMBER,
                         p_report_period   IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   AND process_code = p_process_code
   AND applies_to = p_applies_to
   AND report_duration = p_report_duration
   AND report_period  = p_report_period
   AND id <> p_id;

CURSOR csr_check_record3(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_applies_to      IN VARCHAR2,
                         p_report_duration IN NUMBER,
                         p_report_period   IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   -- AND process_code = 'O' -- bug 5916645
   AND process_code IN ('O', 'M')
   AND applies_to IN (p_applies_to, DECODE(p_applies_to,'B','N',p_applies_to),DECODE(p_applies_to,'B','R',p_applies_to))
   AND NVL(report_duration,-999) = NVL(p_report_duration,-999)
   AND NVL(report_period,'X') = NVL(p_report_period,'X')
   AND id <> p_id;

CURSOR csr_check_record4(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_applies_to      IN VARCHAR2,
                         p_report_duration IN NUMBER,
                         p_report_period   IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   AND process_code = 'B'
   AND applies_to IN (p_applies_to, DECODE(p_applies_to,'B','N',p_applies_to),DECODE(p_applies_to,'B','R',p_applies_to))
   AND NVL(report_duration,-999) = NVL(p_report_duration,-999)
   AND NVL(report_period,'X') = NVL(p_report_period,'X')
   AND id <> p_id;

CURSOR csr_check_record5(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_process_code    IN VARCHAR2,
                         p_report_duration IN NUMBER,
                         p_report_period   IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   AND applies_to IN ('N', 'R')
   AND process_code IN (p_process_code,'B')
   -- AND process_code <> 'M'
   AND NVL(report_duration,-999) = NVL(p_report_duration,-999)
   AND NVL(report_period,'X') = NVL(p_report_period,'X')
   AND id <> p_id;

CURSOR csr_check_record6(p_template_set_id IN NUMBER,
                         p_document_type   IN VARCHAR2,
                         p_process_code    IN VARCHAR2,
                         p_report_duration IN NUMBER,
                         p_report_period   IN VARCHAR2,
                         p_id              IN NUMBER) IS
SELECT start_date,
       NVL(end_date,sysdate+1)
  FROM oks_report_templates
 WHERE template_set_id = p_template_set_id
   AND template_set_type = p_document_type
   AND applies_to = 'B'
   AND process_code IN(p_process_code,'B')
   AND NVL(report_duration,-999) = NVL(p_report_duration,-999)
   AND NVL(report_period,'X') = NVL(p_report_period,'X')
   AND id <> p_id;


-- skekkar
BEGIN
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: Entered ' || g_pkg_name || '.' || l_api_name
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_template_set_id : '||p_rtmpv_rec.template_set_id
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_document_type : '||p_rtmpv_rec.template_set_type
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_process_code : '||p_rtmpv_rec.process_code
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_applies_to : '||p_rtmpv_rec.applies_to
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_report_duration : '||p_rtmpv_rec.report_duration
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_report_period : '||p_rtmpv_rec.report_period
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_id : '||p_rtmpv_rec.id
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_rtmpv_rec.start_date : '||p_rtmpv_rec.start_date
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '100: p_rtmpv_rec.end_date : '||p_rtmpv_rec.end_date
                     );
   END IF;

-- Bug 5916645
-- If the process_code = 'M' then duplicate record will be allowed
-- No validation needed if process_code = 'M'
--
-- Bug 5916645 , check 1 to check 5 are only needed if process_code is NOT M
--
IF p_rtmpv_rec.process_code <> 'M' -- bug 5916645
    OR (p_rtmpv_rec.process_code = 'M'  AND p_rtmpv_rec.template_set_type  <> 'QUOTE' ) -- bug 6030060
   THEN

   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '110: Check 1: Check if the same combination exists '
                     );
   END IF;


--
-- Check 1: Check if the same combination exists
--
   IF  p_rtmpv_rec.template_set_type IN ('RMN','CCN') THEN

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '120: OPEN csr_check_record2'
                           );
         END IF;

        OPEN csr_check_record2(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_process_code    => p_rtmpv_rec.process_code,
                                p_applies_to      => p_rtmpv_rec.applies_to,
                                p_report_duration => p_rtmpv_rec.report_duration,
                                p_report_period   => p_rtmpv_rec.report_period,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record2 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '120: AFTER OPENING csr_check_record2'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '120: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '120: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record2%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record2;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record2%FOUND
        CLOSE csr_check_record2;

   ELSE
         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '130: OPEN csr_check_record1'
                           );
         END IF;

        OPEN csr_check_record1(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_process_code    => p_rtmpv_rec.process_code,
                                p_applies_to      => p_rtmpv_rec.applies_to,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record1 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '140: AFTER OPENING csr_check_record1'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '140: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '140: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record1%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record1;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record1%FOUND
        CLOSE csr_check_record1;
    END IF; -- p_rtmpv_rec.template_set_type IN ('RMN','CCN')


--
-- Check 2: If current record process_code is 'B' then check no records for the same date range with
--          process_code as 'O' or 'M'
--
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '200: Check 2: If current record process_code is B'
                     );
   END IF;

    IF  p_rtmpv_rec.process_code = 'B' THEN

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '220: OPEN csr_check_record3'
                           );
         END IF;

        OPEN csr_check_record3(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_applies_to      => p_rtmpv_rec.applies_to,
                                p_report_duration => p_rtmpv_rec.report_duration,
                                p_report_period   => p_rtmpv_rec.report_period,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record3 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '240: AFTER OPENING csr_check_record3'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '240: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '240: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record3%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record3;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record3%FOUND
        CLOSE csr_check_record3;

    END IF; -- p_rtmpv_rec.process_code = 'B'


--
-- Check 3: If current record process_code is 'O' or 'M'  then check no records for the same date range with
--          process_code as 'B'
--
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '300: Check 3: If current record process_code is O or M'
                     );
   END IF;

    IF  p_rtmpv_rec.process_code IN ('O','M') THEN
    -- IF  p_rtmpv_rec.process_code = 'O' THEN -- bug 5916645

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '320: OPEN csr_check_record4'
                           );
         END IF;

        OPEN csr_check_record4(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_applies_to      => p_rtmpv_rec.applies_to,
                                p_report_duration => p_rtmpv_rec.report_duration,
                                p_report_period   => p_rtmpv_rec.report_period,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record4 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '340: AFTER OPENING csr_check_record4'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '340: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '340: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record4%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record4;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record4%FOUND
        CLOSE csr_check_record4;

    END IF; -- p_rtmpv_rec.process_code IN ('O','M')


--
-- Check 4: If current record applies_to is 'B' then check no records for the same date range with
--          applies_to as 'N' or 'R'
--
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '400: Check 4: If current record applies_to is B'
                     );
   END IF;

    IF  p_rtmpv_rec.applies_to = 'B' THEN

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '420: OPEN csr_check_record5'
                           );
         END IF;

        OPEN csr_check_record5(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_process_code    => p_rtmpv_rec.process_code,
                                p_report_duration => p_rtmpv_rec.report_duration,
                                p_report_period   => p_rtmpv_rec.report_period,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record5 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '440: AFTER OPENING csr_check_record5'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '440: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '440: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record5%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record5;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record5%FOUND
        CLOSE csr_check_record5;

    END IF; -- p_rtmpv_rec.applies_to = 'B'

--
-- Check 5: If current record applies_to in ('N','R') then check no records for the same date range with
--          applies_to as 'B'
--
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '500: Check 5: If current record applies_to is N or R'
                     );
   END IF;

    IF  p_rtmpv_rec.applies_to IN ('N','R') THEN

         IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
            fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                            '520: OPEN csr_check_record6'
                           );
         END IF;

        OPEN csr_check_record6(p_template_set_id  => p_rtmpv_rec.template_set_id,
                                p_document_type   => p_rtmpv_rec.template_set_type,
                                p_process_code    => p_rtmpv_rec.process_code,
                                p_report_duration => p_rtmpv_rec.report_duration,
                                p_report_period   => p_rtmpv_rec.report_period,
                                p_id              => p_rtmpv_rec.id);
          FETCH csr_check_record6 INTO l_start_date, l_end_date;

             IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '540: AFTER OPENING csr_check_record6'
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '540: l_start_date : '||l_start_date
                               );
                fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                                '540: l_end_date : '||l_end_date
                               );
             END IF;

            IF csr_check_record6%FOUND THEN
              -- check if the dates overlap
              IF (l_start_date BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (l_end_date   BETWEEN p_rtmpv_rec.start_date AND NVL(p_rtmpv_rec.end_date,SYSDATE+1)) OR
                 (p_rtmpv_rec.start_date BETWEEN l_start_date AND l_end_date) OR
                 (NVL(p_rtmpv_rec.end_date,SYSDATE+1) BETWEEN l_start_date AND l_end_date) THEN
                    -- error
                       fnd_message.set_name('OKS','OKS_TS_DUPLICATE_RECORD');
                       fnd_msg_pub.add;
                       CLOSE csr_check_record6;
                       RETURN OKC_API.G_RET_STS_ERROR;
              END IF; -- duplicate record found with dates overlap
            END IF; -- csr_check_record6%FOUND
        CLOSE csr_check_record6;

    END IF; -- p_rtmpv_rec.applies_to IN ('N','R')

END IF; --  p_rtmpv_rec.process_code <> 'M' only then run check 1 to check 5

--
-- Check 6: bug 5873004
--          New Validation: Both Message and Attachment template are optional
--          For each record atleast ONE of the template MUST be specified.
--
   IF (fnd_log.level_procedure >= fnd_log.g_current_runtime_level) THEN
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '600: Check 6: Both Message and Attachment template are optional'
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '600: p_rtmpv_rec.message_template_id : '||p_rtmpv_rec.message_template_id
                     );
      fnd_log.STRING (fnd_log.level_procedure, g_module || l_api_name,
                      '600: p_rtmpv_rec.report_id: '||p_rtmpv_rec.report_id
                     );
   END IF;

     IF ( p_rtmpv_rec.message_template_id IS NULL ) AND
        ( p_rtmpv_rec.report_id IS NULL ) THEN
        -- error
        fnd_message.set_name('OKS','OKS_TS_TMPL_DATA');
        fnd_msg_pub.add;
        RETURN OKC_API.G_RET_STS_ERROR;
     END IF; -- check if atleast Message template or Attachment template is entered

    -- skekkar
    RETURN (l_return_status);
END Validate_Record;

---------------------------------------------------------------------------



  FUNCTION Validate_Record (
    p_rtmpv_rec IN rtmpv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_rtmpv_rec                 rtmpv_rec_type := get_rec(p_rtmpv_rec);
  BEGIN
    l_return_status := Validate_Record(p_rtmpv_rec => p_rtmpv_rec,
                                       p_db_rtmpv_rec => l_db_rtmpv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN rtmpv_rec_type,
    p_to   IN OUT NOCOPY rtmp_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.report_id := p_from.report_id;
    p_to.template_set_id := p_from.template_set_id;
    p_to.template_set_type := p_from.template_set_type;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.report_duration := p_from.report_duration;
    p_to.report_period := p_from.report_period;
    p_to.sts_code := p_from.sts_code;
    p_to.process_code := p_from.process_code;
    p_to.applies_to := p_from.applies_to;
    p_to.attachment_name := p_from.attachment_name;
    p_to.message_template_id := p_from.message_template_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  PROCEDURE migrate (
    p_from IN rtmp_rec_type,
    p_to   IN OUT NOCOPY rtmpv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.report_id := p_from.report_id;
    p_to.template_set_id := p_from.template_set_id;
    p_to.template_set_type := p_from.template_set_type;
    p_to.start_date := p_from.start_date;
    p_to.end_date := p_from.end_date;
    p_to.report_duration := p_from.report_duration;
    p_to.report_period := p_from.report_period;
    p_to.sts_code := p_from.sts_code;
    p_to.process_code := p_from.process_code;
    p_to.applies_to := p_from.applies_to;
    p_to.attachment_name := p_from.attachment_name;
    p_to.message_template_id := p_from.message_template_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
    p_to.last_update_login := p_from.last_update_login;
    p_to.object_version_number := p_from.object_version_number;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  ---------------------------------------------
  -- validate_row for:OKS_REPORT_TEMPLATES_V --
  ---------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmpv_rec                    rtmpv_rec_type := p_rtmpv_rec;
    l_rtmp_rec                     rtmp_rec_type;
    l_rtmp_rec                     rtmp_rec_type;
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
    l_return_status := Validate_Attributes(l_rtmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_rtmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;
  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_REPORT_TEMPLATES_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      i := p_rtmpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          validate_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_rtmpv_rec                    => p_rtmpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_rtmpv_tbl.LAST);
        i := p_rtmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END validate_row;

  --------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_REPORT_TEMPLATES_V --
  --------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rtmpv_tbl                    => p_rtmpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for:OKS_REPORT_TEMPLATES --
  -----------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmp_rec                     IN rtmp_rec_type,
    x_rtmp_rec                     OUT NOCOPY rtmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmp_rec                     rtmp_rec_type := p_rtmp_rec;
    l_def_rtmp_rec                 rtmp_rec_type;
    ---------------------------------------------
    -- Set_Attributes for:OKS_REPORT_TEMPLATES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rtmp_rec IN rtmp_rec_type,
      x_rtmp_rec OUT NOCOPY rtmp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmp_rec := p_rtmp_rec;
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
    --- Setting item atributes
    l_return_status := Set_Attributes(
      p_rtmp_rec,                        -- IN
      l_rtmp_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_REPORT_TEMPLATES(
      id,
      report_id,
      template_set_id,
      template_set_type,
      start_date,
      end_date,
      report_duration,
      report_period,
      sts_code,
      PROCESS_CODE,
      APPLIES_TO,
      ATTACHMENT_NAME,
      MESSAGE_TEMPLATE_ID,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number)
    VALUES (
      l_rtmp_rec.id,
      l_rtmp_rec.report_id,
      l_rtmp_rec.template_set_id,
      l_rtmp_rec.template_set_type,
      l_rtmp_rec.start_date,
      l_rtmp_rec.end_date,
      l_rtmp_rec.report_duration,
      l_rtmp_rec.report_period,
      l_rtmp_rec.sts_code,
      l_rtmp_rec.process_code,
      l_rtmp_rec.applies_to,
      l_rtmp_rec.attachment_name,
      l_rtmp_rec.message_template_id,
      l_rtmp_rec.created_by,
      l_rtmp_rec.creation_date,
      l_rtmp_rec.last_updated_by,
      l_rtmp_rec.last_update_date,
      l_rtmp_rec.last_update_login,
      l_rtmp_rec.object_version_number);
    -- Set OUT values
    x_rtmp_rec := l_rtmp_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- insert_row for :OKS_REPORT_TEMPLATES_V --
  --------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmpv_rec                    rtmpv_rec_type := p_rtmpv_rec;
    l_def_rtmpv_rec                rtmpv_rec_type;
    l_rtmp_rec                     rtmp_rec_type;
    lx_rtmp_rec                    rtmp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rtmpv_rec IN rtmpv_rec_type
    ) RETURN rtmpv_rec_type IS
      l_rtmpv_rec rtmpv_rec_type := p_rtmpv_rec;
    BEGIN
      l_rtmpv_rec.CREATION_DATE := SYSDATE;
      l_rtmpv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_rtmpv_rec.LAST_UPDATE_DATE := l_rtmpv_rec.CREATION_DATE;
      l_rtmpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rtmpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rtmpv_rec);
    END fill_who_columns;
    -----------------------------------------------
    -- Set_Attributes for:OKS_REPORT_TEMPLATES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_rtmpv_rec IN rtmpv_rec_type,
      x_rtmpv_rec OUT NOCOPY rtmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmpv_rec := p_rtmpv_rec;
      x_rtmpv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_rtmpv_rec := null_out_defaults(p_rtmpv_rec);
    -- Set primary key value
    l_rtmpv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_rtmpv_rec,                       -- IN
      l_def_rtmpv_rec);                  -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rtmpv_rec := fill_who_columns(l_def_rtmpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rtmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rtmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_rtmpv_rec, l_rtmp_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rtmp_rec,
      lx_rtmp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rtmp_rec, l_def_rtmpv_rec);
    -- Set OUT values
    x_rtmpv_rec := l_def_rtmpv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;
  -----------------------------------------
  -- PL/SQL TBL insert_row for:RTMPV_TBL --
  -----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      i := p_rtmpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          insert_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_rtmpv_rec                    => p_rtmpv_tbl(i),
            x_rtmpv_rec                    => x_rtmpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_rtmpv_tbl.LAST);
        i := p_rtmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END insert_row;

  -----------------------------------------
  -- PL/SQL TBL insert_row for:RTMPV_TBL --
  -----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rtmpv_tbl                    => p_rtmpv_tbl,
        x_rtmpv_tbl                    => x_rtmpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for:OKS_REPORT_TEMPLATES --
  ---------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmp_rec                     IN rtmp_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_rtmp_rec IN rtmp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_REPORT_TEMPLATES
     WHERE ID = p_rtmp_rec.id
       AND OBJECT_VERSION_NUMBER = p_rtmp_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_rtmp_rec IN rtmp_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_REPORT_TEMPLATES
     WHERE ID = p_rtmp_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_REPORT_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_REPORT_TEMPLATES.OBJECT_VERSION_NUMBER%TYPE;
    l_row_notfound                 BOOLEAN := FALSE;
    lc_row_notfound                BOOLEAN := FALSE;
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
      OPEN lock_csr(p_rtmp_rec);
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
      OPEN lchk_csr(p_rtmp_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_rtmp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_rtmp_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number = -1 THEN
      OKC_API.set_message(G_APP_NAME,G_RECORD_LOGICALLY_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- lock_row for: OKS_REPORT_TEMPLATES_V --
  ------------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmp_rec                     rtmp_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(p_rtmpv_rec, l_rtmp_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rtmp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- PL/SQL TBL lock_row for:RTMPV_TBL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      i := p_rtmpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          lock_row(
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_rtmpv_rec                    => p_rtmpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_rtmpv_tbl.LAST);
        i := p_rtmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END lock_row;
  ---------------------------------------
  -- PL/SQL TBL lock_row for:RTMPV_TBL --
  ---------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rtmpv_tbl                    => p_rtmpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKS_REPORT_TEMPLATES --
  -----------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmp_rec                     IN rtmp_rec_type,
    x_rtmp_rec                     OUT NOCOPY rtmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmp_rec                     rtmp_rec_type := p_rtmp_rec;
    l_def_rtmp_rec                 rtmp_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rtmp_rec IN rtmp_rec_type,
      x_rtmp_rec OUT NOCOPY rtmp_rec_type
    ) RETURN VARCHAR2 IS
      l_rtmp_rec                     rtmp_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmp_rec := p_rtmp_rec;
      -- Get current database values
      l_rtmp_rec := get_rec(p_rtmp_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_rtmp_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.id := l_rtmp_rec.id;
        END IF;
        IF (x_rtmp_rec.report_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.report_id := l_rtmp_rec.report_id;
        END IF;
        IF (x_rtmp_rec.template_set_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.template_set_id := l_rtmp_rec.template_set_id;
        END IF;
        IF (x_rtmp_rec.template_set_type = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.template_set_type := l_rtmp_rec.template_set_type;
        END IF;
        IF (x_rtmp_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmp_rec.start_date := l_rtmp_rec.start_date;
        END IF;
        IF (x_rtmp_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmp_rec.end_date := l_rtmp_rec.end_date;
        END IF;
        IF (x_rtmp_rec.report_duration = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.report_duration := l_rtmp_rec.report_duration;
        END IF;
        IF (x_rtmp_rec.report_period = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.report_period := l_rtmp_rec.report_period;
        END IF;
        IF (x_rtmp_rec.sts_code = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.sts_code := l_rtmp_rec.sts_code;
        END IF;
        IF (x_rtmp_rec.process_code = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.process_code := l_rtmp_rec.process_code;
        END IF;
        IF (x_rtmp_rec.applies_to = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.applies_to := l_rtmp_rec.applies_to;
        END IF;
        IF (x_rtmp_rec.attachment_name = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmp_rec.attachment_name := l_rtmp_rec.attachment_name;
        END IF;
        IF (x_rtmp_rec.message_template_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.message_template_id := l_rtmp_rec.message_template_id;
        END IF;
        IF (x_rtmp_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.created_by := l_rtmp_rec.created_by;
        END IF;
        IF (x_rtmp_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmp_rec.creation_date := l_rtmp_rec.creation_date;
        END IF;
        IF (x_rtmp_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.last_updated_by := l_rtmp_rec.last_updated_by;
        END IF;
        IF (x_rtmp_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmp_rec.last_update_date := l_rtmp_rec.last_update_date;
        END IF;
        IF (x_rtmp_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.last_update_login := l_rtmp_rec.last_update_login;
        END IF;
        IF (x_rtmp_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_rtmp_rec.object_version_number := l_rtmp_rec.object_version_number;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_REPORT_TEMPLATES --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_rtmp_rec IN rtmp_rec_type,
      x_rtmp_rec OUT NOCOPY rtmp_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmp_rec := p_rtmp_rec;
      x_rtmp_rec.OBJECT_VERSION_NUMBER := p_rtmp_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_rtmp_rec,                        -- IN
      l_rtmp_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rtmp_rec, l_def_rtmp_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_REPORT_TEMPLATES
    SET REPORT_ID = l_def_rtmp_rec.report_id,
        TEMPLATE_SET_ID = l_def_rtmp_rec.template_set_id,
        TEMPLATE_SET_TYPE = l_def_rtmp_rec.template_set_type,
        START_DATE = l_def_rtmp_rec.start_date,
        END_DATE = l_def_rtmp_rec.end_date,
        REPORT_DURATION = l_def_rtmp_rec.report_duration,
        REPORT_PERIOD = l_def_rtmp_rec.report_period,
        STS_CODE = l_def_rtmp_rec.sts_code,
        PROCESS_CODE = l_def_rtmp_rec.PROCESS_CODE,
        APPLIES_TO = l_def_rtmp_rec.APPLIES_TO,
        ATTACHMENT_NAME = l_def_rtmp_rec.ATTACHMENT_NAME,
        MESSAGE_TEMPLATE_ID = l_def_rtmp_rec.MESSAGE_TEMPLATE_ID,
        CREATED_BY = l_def_rtmp_rec.created_by,
        CREATION_DATE = l_def_rtmp_rec.creation_date,
        LAST_UPDATED_BY = l_def_rtmp_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_rtmp_rec.last_update_date,
        LAST_UPDATE_LOGIN = l_def_rtmp_rec.last_update_login,
        OBJECT_VERSION_NUMBER = l_def_rtmp_rec.object_version_number
    WHERE ID = l_def_rtmp_rec.id;

    x_rtmp_rec := l_rtmp_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- update_row for:OKS_REPORT_TEMPLATES_V --
  -------------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type,
    x_rtmpv_rec                    OUT NOCOPY rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmpv_rec                    rtmpv_rec_type := p_rtmpv_rec;
    l_def_rtmpv_rec                rtmpv_rec_type;
    l_db_rtmpv_rec                 rtmpv_rec_type;
    l_rtmp_rec                     rtmp_rec_type;
    lx_rtmp_rec                    rtmp_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_rtmpv_rec IN rtmpv_rec_type
    ) RETURN rtmpv_rec_type IS
      l_rtmpv_rec rtmpv_rec_type := p_rtmpv_rec;
    BEGIN
      l_rtmpv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_rtmpv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
      l_rtmpv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_rtmpv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_rtmpv_rec IN rtmpv_rec_type,
      x_rtmpv_rec OUT NOCOPY rtmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmpv_rec := p_rtmpv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_rtmpv_rec := get_rec(p_rtmpv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_rtmpv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.id := l_db_rtmpv_rec.id;
        END IF;
        IF (x_rtmpv_rec.report_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.report_id := l_db_rtmpv_rec.report_id;
        END IF;
        IF (x_rtmpv_rec.template_set_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.template_set_id := l_db_rtmpv_rec.template_set_id;
        END IF;
        IF (x_rtmpv_rec.template_set_type = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.template_set_type := l_db_rtmpv_rec.template_set_type;
        END IF;
        IF (x_rtmpv_rec.start_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmpv_rec.start_date := l_db_rtmpv_rec.start_date;
        END IF;
        IF (x_rtmpv_rec.end_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmpv_rec.end_date := l_db_rtmpv_rec.end_date;
        END IF;
        IF (x_rtmpv_rec.report_duration = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.report_duration := l_db_rtmpv_rec.report_duration;
        END IF;
        IF (x_rtmpv_rec.report_period = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.report_period := l_db_rtmpv_rec.report_period;
        END IF;
        IF (x_rtmpv_rec.sts_code = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.sts_code := l_db_rtmpv_rec.sts_code;
        END IF;
        IF (x_rtmpv_rec.process_code = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.process_code := l_db_rtmpv_rec.process_code;
        END IF;
        IF (x_rtmpv_rec.applies_to = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.applies_to := l_db_rtmpv_rec.applies_to;
        END IF;
        IF (x_rtmpv_rec.attachment_name = OKC_API.G_MISS_CHAR)
        THEN
          x_rtmpv_rec.attachment_name := l_db_rtmpv_rec.attachment_name;
        END IF;
        IF (x_rtmpv_rec.message_template_id = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.message_template_id := l_db_rtmpv_rec.message_template_id;
        END IF;
        IF (x_rtmpv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.created_by := l_db_rtmpv_rec.created_by;
        END IF;
        IF (x_rtmpv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmpv_rec.creation_date := l_db_rtmpv_rec.creation_date;
        END IF;
        IF (x_rtmpv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.last_updated_by := l_db_rtmpv_rec.last_updated_by;
        END IF;
        IF (x_rtmpv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_rtmpv_rec.last_update_date := l_db_rtmpv_rec.last_update_date;
        END IF;
        IF (x_rtmpv_rec.last_update_login = OKC_API.G_MISS_NUM)
        THEN
          x_rtmpv_rec.last_update_login := l_db_rtmpv_rec.last_update_login;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -----------------------------------------------
    -- Set_Attributes for:OKS_REPORT_TEMPLATES_V --
    -----------------------------------------------
    FUNCTION Set_Attributes (
      p_rtmpv_rec IN rtmpv_rec_type,
      x_rtmpv_rec OUT NOCOPY rtmpv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_rtmpv_rec := p_rtmpv_rec;
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
      p_rtmpv_rec,                       -- IN
      x_rtmpv_rec);                      -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_rtmpv_rec, l_def_rtmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_rtmpv_rec := fill_who_columns(l_def_rtmpv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_rtmpv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_rtmpv_rec, l_db_rtmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -- Lock the Record
    lock_row(
      p_api_version                  => p_api_version,
      p_init_msg_list                => p_init_msg_list,
      x_return_status                => l_return_status,
      x_msg_count                    => x_msg_count,
      x_msg_data                     => x_msg_data,
      p_rtmpv_rec                    => p_rtmpv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_rtmpv_rec, l_rtmp_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rtmp_rec,
      lx_rtmp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_rtmp_rec, l_def_rtmpv_rec);
    x_rtmpv_rec := l_def_rtmpv_rec;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;
  -----------------------------------------
  -- PL/SQL TBL update_row for:rtmpv_tbl --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      i := p_rtmpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          update_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_rtmpv_rec                    => p_rtmpv_tbl(i),
            x_rtmpv_rec                    => x_rtmpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_rtmpv_tbl.LAST);
        i := p_rtmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END update_row;

  -----------------------------------------
  -- PL/SQL TBL update_row for:RTMPV_TBL --
  -----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    x_rtmpv_tbl                    OUT NOCOPY rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rtmpv_tbl                    => p_rtmpv_tbl,
        x_rtmpv_tbl                    => x_rtmpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKS_REPORT_TEMPLATES --
  -----------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmp_rec                     IN rtmp_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmp_rec                     rtmp_rec_type := p_rtmp_rec;
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

    DELETE FROM OKS_REPORT_TEMPLATES
     WHERE ID = p_rtmp_rec.id;

    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
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
  -- delete_row for:OKS_REPORT_TEMPLATES_V --
  -------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_rec                    IN rtmpv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_rtmpv_rec                    rtmpv_rec_type := p_rtmpv_rec;
    l_rtmp_rec                     rtmp_rec_type;
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
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_rtmpv_rec, l_rtmp_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_rtmp_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    x_return_status := l_return_status;
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;
  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_REPORT_TEMPLATES_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      i := p_rtmpv_tbl.FIRST;
      LOOP
        DECLARE
          l_error_rec         OKC_API.ERROR_REC_TYPE;
        BEGIN
          l_error_rec.api_name := l_api_name;
          l_error_rec.api_package := G_PKG_NAME;
          l_error_rec.idx := i;
          delete_row (
            p_api_version                  => p_api_version,
            p_init_msg_list                => OKC_API.G_FALSE,
            x_return_status                => l_error_rec.error_type,
            x_msg_count                    => l_error_rec.msg_count,
            x_msg_data                     => l_error_rec.msg_data,
            p_rtmpv_rec                    => p_rtmpv_tbl(i));
          IF (l_error_rec.error_type <> OKC_API.G_RET_STS_SUCCESS) THEN
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          ELSE
            x_msg_count := l_error_rec.msg_count;
            x_msg_data := l_error_rec.msg_data;
          END IF;
        EXCEPTION
          WHEN OKC_API.G_EXCEPTION_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OKC_API.G_EXCEPTION_UNEXPECTED_ERROR THEN
            l_error_rec.error_type := OKC_API.G_RET_STS_UNEXP_ERROR;
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
          WHEN OTHERS THEN
            l_error_rec.error_type := 'OTHERS';
            l_error_rec.sqlcode := SQLCODE;
            load_error_tbl(l_error_rec, px_error_tbl);
        END;
        EXIT WHEN (i = p_rtmpv_tbl.LAST);
        i := p_rtmpv_tbl.NEXT(i);
      END LOOP;
    END IF;
    -- Loop through the error_tbl to find the error with the highest severity
    -- and return it.
    x_return_status := find_highest_exception(px_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

  ------------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_REPORT_TEMPLATES_V --
  ------------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_rtmpv_tbl                    IN rtmpv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_rtmpv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_rtmpv_tbl                    => p_rtmpv_tbl,
        px_error_tbl                   => l_error_tbl);
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
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OKC_API.G_RET_STS_UNEXP_ERROR',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
    WHEN OTHERS THEN
      x_return_status := OKC_API.HANDLE_EXCEPTIONS
      (
        l_api_name,
        G_PKG_NAME,
        'OTHERS',
        x_msg_count,
        x_msg_data,
        '_PVT'
      );
  END delete_row;

END OKS_REPORT_TEMPLATES_PVT;

/
