--------------------------------------------------------
--  DDL for Package Body OKS_BILL_LEVEL_ELEMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKS_BILL_LEVEL_ELEMENTS_PVT" AS
/* $Header: OKSSBLEB.pls 120.0 2005/05/27 15:27:08 appldev noship $ */

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
  -- FUNCTION get_rec for: OKS_LEVEL_ELEMENTS_V
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_letv_rec                     IN letv_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN letv_rec_type IS
    CURSOR oks_let_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            PARENT_CLE_ID,
            SEQUENCE_NUMBER,
            DATE_START,
            DATE_END,
            AMOUNT,
            DATE_REVENUE_RULE_START,
            DATE_RECEIVABLE_GL,
            DATE_TRANSACTION,
            DATE_DUE,
            OBJECT_VERSION_NUMBER,
            DATE_PRINT,
            DATE_TO_INTERFACE,
            DATE_COMPLETED,
            RUL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Oks_Level_Elements_V
     WHERE oks_level_elements_v.id = p_id;
    l_oks_let_pk                   oks_let_pk_csr%ROWTYPE;
    l_letv_rec                     letv_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_let_pk_csr (p_letv_rec.id);
    FETCH oks_let_pk_csr INTO
              l_letv_rec.id,
              l_letv_rec.cle_id,
              l_letv_rec.dnz_chr_id,
              l_letv_rec.parent_cle_id,
              l_letv_rec.sequence_number,
              l_letv_rec.date_start,
              l_letv_rec.date_end,
              l_letv_rec.amount,
              l_letv_rec.date_revenue_rule_start,
              l_letv_rec.date_receivable_gl,
              l_letv_rec.date_transaction,
              l_letv_rec.date_due,
              l_letv_rec.object_version_number,
              l_letv_rec.date_print,
              l_letv_rec.date_to_interface,
              l_letv_rec.date_completed,
              l_letv_rec.rul_id,
              l_letv_rec.created_by,
              l_letv_rec.creation_date,
              l_letv_rec.last_updated_by,
              l_letv_rec.last_update_date;
    x_no_data_found := oks_let_pk_csr%NOTFOUND;
    CLOSE oks_let_pk_csr;
    RETURN(l_letv_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_letv_rec                     IN letv_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN letv_rec_type IS
    l_letv_rec                     letv_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_letv_rec := get_rec(p_letv_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_letv_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_letv_rec                     IN letv_rec_type
  ) RETURN letv_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_letv_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION get_rec for: OKS_LEVEL_ELEMENTS
  ---------------------------------------------------------------------------
  FUNCTION get_rec (
    p_let_rec                      IN let_rec_type,
    x_no_data_found                OUT NOCOPY BOOLEAN
  ) RETURN let_rec_type IS
    CURSOR oks_level_elements_pk_csr (p_id IN NUMBER) IS
    SELECT
            ID,
            CLE_ID,
            DNZ_CHR_ID,
            PARENT_CLE_ID,
            SEQUENCE_NUMBER,
            DATE_START,
            DATE_END,
            AMOUNT,
            DATE_RECEIVABLE_GL,
            DATE_REVENUE_RULE_START,
            DATE_TRANSACTION,
            DATE_DUE,
            DATE_PRINT,
            DATE_TO_INTERFACE,
            DATE_COMPLETED,
            OBJECT_VERSION_NUMBER,
            RUL_ID,
            CREATED_BY,
            CREATION_DATE,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE
      FROM Oks_Level_Elements
     WHERE oks_level_elements.id = p_id;
    l_oks_level_elements_pk        oks_level_elements_pk_csr%ROWTYPE;
    l_let_rec                      let_rec_type;
  BEGIN
    x_no_data_found := TRUE;
    -- Get current database values
    OPEN oks_level_elements_pk_csr (p_let_rec.id);
    FETCH oks_level_elements_pk_csr INTO
              l_let_rec.id,
              l_let_rec.cle_id,
              l_let_rec.dnz_chr_id,
              l_let_rec.parent_cle_id,
              l_let_rec.sequence_number,
              l_let_rec.date_start,
              l_let_rec.date_end,
              l_let_rec.amount,
              l_let_rec.date_receivable_gl,
              l_let_rec.date_revenue_rule_start,
              l_let_rec.date_transaction,
              l_let_rec.date_due,
              l_let_rec.date_print,
              l_let_rec.date_to_interface,
              l_let_rec.date_completed,
              l_let_rec.object_version_number,
              l_let_rec.rul_id,
              l_let_rec.created_by,
              l_let_rec.creation_date,
              l_let_rec.last_updated_by,
              l_let_rec.last_update_date;
    x_no_data_found := oks_level_elements_pk_csr%NOTFOUND;
    CLOSE oks_level_elements_pk_csr;
    RETURN(l_let_rec);
  END get_rec;

  ------------------------------------------------------------------
  -- This version of get_rec sets error messages if no data found --
  ------------------------------------------------------------------
  FUNCTION get_rec (
    p_let_rec                      IN let_rec_type,
    x_return_status                OUT NOCOPY VARCHAR2
  ) RETURN let_rec_type IS
    l_let_rec                      let_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    l_let_rec := get_rec(p_let_rec, l_row_notfound);
    IF (l_row_notfound) THEN
      OKC_API.set_message(G_APP_NAME,G_INVALID_VALUE,G_COL_NAME_TOKEN,'ID');
      x_return_status := OKC_API.G_RET_STS_ERROR;
    END IF;
    RETURN(l_let_rec);
  END get_rec;
  -----------------------------------------------------------
  -- So we don't have to pass an "l_row_notfound" variable --
  -----------------------------------------------------------
  FUNCTION get_rec (
    p_let_rec                      IN let_rec_type
  ) RETURN let_rec_type IS
    l_row_not_found                BOOLEAN := TRUE;
  BEGIN
    RETURN(get_rec(p_let_rec, l_row_not_found));
  END get_rec;
  ---------------------------------------------------------------------------
  -- FUNCTION null_out_defaults for: OKS_LEVEL_ELEMENTS_V
  ---------------------------------------------------------------------------
  FUNCTION null_out_defaults (
    p_letv_rec   IN letv_rec_type
  ) RETURN letv_rec_type IS
    l_letv_rec                     letv_rec_type := p_letv_rec;
  BEGIN
    IF (l_letv_rec.id = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.id := NULL;
    END IF;
    IF (l_letv_rec.cle_id = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.cle_id := NULL;
    END IF;
    IF (l_letv_rec.dnz_chr_id = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.dnz_chr_id := NULL;
    END IF;
    IF (l_letv_rec.parent_cle_id = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.parent_cle_id := NULL;
    END IF;
    IF (l_letv_rec.sequence_number = OKC_API.G_MISS_CHAR ) THEN
      l_letv_rec.sequence_number := NULL;
    END IF;
    IF (l_letv_rec.date_start = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_start := NULL;
    END IF;
    IF (l_letv_rec.date_end = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_end := NULL;
    END IF;
    IF (l_letv_rec.amount = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.amount := NULL;
    END IF;
    IF (l_letv_rec.date_revenue_rule_start = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_revenue_rule_start := NULL;
    END IF;
    IF (l_letv_rec.date_receivable_gl = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_receivable_gl := NULL;
    END IF;
    IF (l_letv_rec.date_transaction = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_transaction := NULL;
    END IF;
    IF (l_letv_rec.date_due = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_due := NULL;
    END IF;
    IF (l_letv_rec.object_version_number = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.object_version_number := NULL;
    END IF;
    IF (l_letv_rec.date_print = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_print := NULL;
    END IF;
    IF (l_letv_rec.date_to_interface = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_to_interface := NULL;
    END IF;
    IF (l_letv_rec.date_completed = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.date_completed := NULL;
    END IF;
    IF (l_letv_rec.rul_id = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.rul_id := NULL;
    END IF;
    IF (l_letv_rec.created_by = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.created_by := NULL;
    END IF;
    IF (l_letv_rec.creation_date = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.creation_date := NULL;
    END IF;
    IF (l_letv_rec.last_updated_by = OKC_API.G_MISS_NUM ) THEN
      l_letv_rec.last_updated_by := NULL;
    END IF;
    IF (l_letv_rec.last_update_date = OKC_API.G_MISS_DATE ) THEN
      l_letv_rec.last_update_date := NULL;
    END IF;
    RETURN(l_letv_rec);
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
  -- Validate_Attributes for: SEQUENCE_NUMBER --
  ----------------------------------------------
  PROCEDURE validate_sequence_number(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_sequence_number              IN VARCHAR2) IS
  BEGIN
    x_return_status := OKC_API.G_RET_STS_SUCCESS;
    IF (p_sequence_number = OKC_API.G_MISS_CHAR OR
        p_sequence_number IS NULL)
    THEN
      OKC_API.set_message(G_APP_NAME, G_REQUIRED_VALUE, G_COL_NAME_TOKEN, 'sequence_number');
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
  END validate_sequence_number;
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
  --------------------------------------------------
  -- Validate_Attributes for:OKS_LEVEL_ELEMENTS_V --
  --------------------------------------------------
  FUNCTION Validate_Attributes (
    p_letv_rec                     IN letv_rec_type
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
    validate_id(x_return_status, p_letv_rec.id);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- sequence_number
    -- ***
    validate_sequence_number(x_return_status, p_letv_rec.sequence_number);
    IF (x_return_status <> OKC_API.G_RET_STS_SUCCESS) THEN
      l_return_status := x_return_status;
      RAISE G_EXCEPTION_HALT_VALIDATION;
    END IF;

    -- ***
    -- object_version_number
    -- ***
    validate_object_version_number(x_return_status, p_letv_rec.object_version_number);
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
  ----------------------------------------------
  -- Validate Record for:OKS_LEVEL_ELEMENTS_V --
  ----------------------------------------------
  FUNCTION Validate_Record (
    p_letv_rec IN letv_rec_type,
    p_db_letv_rec IN letv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
  BEGIN
    RETURN (l_return_status);
  END Validate_Record;
  FUNCTION Validate_Record (
    p_letv_rec IN letv_rec_type
  ) RETURN VARCHAR2 IS
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_db_letv_rec                  letv_rec_type := get_rec(p_letv_rec);
  BEGIN
    l_return_status := Validate_Record(p_letv_rec => p_letv_rec,
                                       p_db_letv_rec => l_db_letv_rec);
    RETURN (l_return_status);
  END Validate_Record;

  ---------------------------------------------------------------------------
  -- PROCEDURE Migrate
  ---------------------------------------------------------------------------
  PROCEDURE migrate (
    p_from IN letv_rec_type,
    p_to   IN OUT NOCOPY let_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_cle_id := p_from.parent_cle_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.date_start := p_from.date_start;
    p_to.date_end := p_from.date_end;
    p_to.amount := p_from.amount;
    p_to.date_receivable_gl := p_from.date_receivable_gl;
    p_to.date_revenue_rule_start := p_from.date_revenue_rule_start;
    p_to.date_transaction := p_from.date_transaction;
    p_to.date_due := p_from.date_due;
    p_to.date_print := p_from.date_print;
    p_to.date_to_interface := p_from.date_to_interface;
    p_to.date_completed := p_from.date_completed;
    p_to.object_version_number := p_from.object_version_number;
    p_to.rul_id := p_from.rul_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  PROCEDURE migrate (
    p_from IN let_rec_type,
    p_to   IN OUT NOCOPY letv_rec_type
  ) IS
  BEGIN
    p_to.id := p_from.id;
    p_to.cle_id := p_from.cle_id;
    p_to.dnz_chr_id := p_from.dnz_chr_id;
    p_to.parent_cle_id := p_from.parent_cle_id;
    p_to.sequence_number := p_from.sequence_number;
    p_to.date_start := p_from.date_start;
    p_to.date_end := p_from.date_end;
    p_to.amount := p_from.amount;
    p_to.date_revenue_rule_start := p_from.date_revenue_rule_start;
    p_to.date_receivable_gl := p_from.date_receivable_gl;
    p_to.date_transaction := p_from.date_transaction;
    p_to.date_due := p_from.date_due;
    p_to.object_version_number := p_from.object_version_number;
    p_to.date_print := p_from.date_print;
    p_to.date_to_interface := p_from.date_to_interface;
    p_to.date_completed := p_from.date_completed;
    p_to.rul_id := p_from.rul_id;
    p_to.created_by := p_from.created_by;
    p_to.creation_date := p_from.creation_date;
    p_to.last_updated_by := p_from.last_updated_by;
    p_to.last_update_date := p_from.last_update_date;
  END migrate;
  ---------------------------------------------------------------------------
  -- PROCEDURE validate_row
  ---------------------------------------------------------------------------
  -------------------------------------------
  -- validate_row for:OKS_LEVEL_ELEMENTS_V --
  -------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_letv_rec                     letv_rec_type := p_letv_rec;
    l_let_rec                      let_rec_type;
    l_let_rec                      let_rec_type;
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
    l_return_status := Validate_Attributes(l_letv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_letv_rec);
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
  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_LEVEL_ELEMENTS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_validate_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      i := p_letv_tbl.FIRST;
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
            p_letv_rec                     => p_letv_tbl(i));
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
        EXIT WHEN (i = p_letv_tbl.LAST);
        i := p_letv_tbl.NEXT(i);
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

  ------------------------------------------------------
  -- PL/SQL TBL validate_row for:OKS_LEVEL_ELEMENTS_V --
  ------------------------------------------------------
  PROCEDURE validate_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_validate_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      validate_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_letv_tbl                     => p_letv_tbl,
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
  ---------------------------------------
  -- insert_row for:OKS_LEVEL_ELEMENTS --
  ---------------------------------------
  PROCEDURE insert_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_let_rec                      IN let_rec_type,
    x_let_rec                      OUT NOCOPY let_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_let_rec                      let_rec_type := p_let_rec;
    l_def_let_rec                  let_rec_type;
    -------------------------------------------
    -- Set_Attributes for:OKS_LEVEL_ELEMENTS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_let_rec IN let_rec_type,
      x_let_rec OUT NOCOPY let_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_let_rec := p_let_rec;
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
      p_let_rec,                         -- IN
      l_let_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    INSERT INTO OKS_LEVEL_ELEMENTS(
      id,
      cle_id,
      dnz_chr_id,
      parent_cle_id,
      sequence_number,
      date_start,
      date_end,
      amount,
      date_receivable_gl,
      date_revenue_rule_start,
      date_transaction,
      date_due,
      date_print,
      date_to_interface,
      date_completed,
      object_version_number,
      rul_id,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date)
    VALUES (
      l_let_rec.id,
      l_let_rec.cle_id,
      l_let_rec.dnz_chr_id,
      l_let_rec.parent_cle_id,
      l_let_rec.sequence_number,
      l_let_rec.date_start,
      l_let_rec.date_end,
      l_let_rec.amount,
      l_let_rec.date_receivable_gl,
      l_let_rec.date_revenue_rule_start,
      l_let_rec.date_transaction,
      l_let_rec.date_due,
      l_let_rec.date_print,
      l_let_rec.date_to_interface,
      l_let_rec.date_completed,
      l_let_rec.object_version_number,
      l_let_rec.rul_id,
      l_let_rec.created_by,
      l_let_rec.creation_date,
      l_let_rec.last_updated_by,
      l_let_rec.last_update_date);
    -- Set OUT values
    x_let_rec := l_let_rec;
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
  ------------------------------------------
  -- insert_row for :OKS_LEVEL_ELEMENTS_V --
  ------------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type,
    x_letv_rec                     OUT NOCOPY letv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_letv_rec                     letv_rec_type := p_letv_rec;
    l_def_letv_rec                 letv_rec_type;
    l_let_rec                      let_rec_type;
    lx_let_rec                     let_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_letv_rec IN letv_rec_type
    ) RETURN letv_rec_type IS
      l_letv_rec letv_rec_type := p_letv_rec;
    BEGIN
      l_letv_rec.CREATION_DATE := SYSDATE;
      l_letv_rec.CREATED_BY := FND_GLOBAL.USER_ID;
      l_letv_rec.LAST_UPDATE_DATE := l_letv_rec.CREATION_DATE;
      l_letv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
--      l_letv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_letv_rec);
    END fill_who_columns;
    ---------------------------------------------
    -- Set_Attributes for:OKS_LEVEL_ELEMENTS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_letv_rec IN letv_rec_type,
      x_letv_rec OUT NOCOPY letv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_letv_rec := p_letv_rec;
      x_letv_rec.OBJECT_VERSION_NUMBER := 1;
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
    l_letv_rec := null_out_defaults(p_letv_rec);
    -- Set primary key value
    l_letv_rec.ID := get_seq_id;
    -- Setting item attributes
    l_return_Status := Set_Attributes(
      l_letv_rec,                        -- IN
      l_def_letv_rec);                   -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_letv_rec := fill_who_columns(l_def_letv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_letv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_letv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_letv_rec, l_let_rec);
    -----------------------------------------------
    -- Call the INSERT_ROW for each child record --
    -----------------------------------------------
    insert_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_let_rec,
      lx_let_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_let_rec, l_def_letv_rec);
    -- Set OUT values
    x_letv_rec := l_def_letv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL insert_row for:LETV_TBL --
  ----------------------------------------
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_insert_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      i := p_letv_tbl.FIRST;
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
            p_letv_rec                     => p_letv_tbl(i),
            x_letv_rec                     => x_letv_tbl(i));
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
        EXIT WHEN (i = p_letv_tbl.LAST);
        i := p_letv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL insert_row for:LETV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE insert_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_insert_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      insert_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_letv_tbl                     => p_letv_tbl,
        x_letv_tbl                     => x_letv_tbl,
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
  -------------------------------------
  -- lock_row for:OKS_LEVEL_ELEMENTS --
  -------------------------------------
  PROCEDURE lock_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_let_rec                      IN let_rec_type) IS

    E_Resource_Busy                EXCEPTION;
    PRAGMA EXCEPTION_INIT(E_Resource_Busy, -00054);
    CURSOR lock_csr (p_let_rec IN let_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_LEVEL_ELEMENTS
     WHERE ID = p_let_rec.id
       AND OBJECT_VERSION_NUMBER = p_let_rec.object_version_number
    FOR UPDATE OF OBJECT_VERSION_NUMBER NOWAIT;

    CURSOR lchk_csr (p_let_rec IN let_rec_type) IS
    SELECT OBJECT_VERSION_NUMBER
      FROM OKS_LEVEL_ELEMENTS
     WHERE ID = p_let_rec.id;
    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_object_version_number        OKS_LEVEL_ELEMENTS.OBJECT_VERSION_NUMBER%TYPE;
    lc_object_version_number       OKS_LEVEL_ELEMENTS.OBJECT_VERSION_NUMBER%TYPE;
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
      OPEN lock_csr(p_let_rec);
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
      OPEN lchk_csr(p_let_rec);
      FETCH lchk_csr INTO lc_object_version_number;
      lc_row_notfound := lchk_csr%NOTFOUND;
      CLOSE lchk_csr;
    END IF;
    IF (lc_row_notfound) THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_DELETED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number > p_let_rec.object_version_number THEN
      OKC_API.set_message(G_FND_APP,G_FORM_RECORD_CHANGED);
      RAISE OKC_API.G_EXCEPTION_ERROR;
    ELSIF lc_object_version_number <> p_let_rec.object_version_number THEN
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
  ----------------------------------------
  -- lock_row for: OKS_LEVEL_ELEMENTS_V --
  ----------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_let_rec                      let_rec_type;
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
    migrate(p_letv_rec, l_let_rec);
    ---------------------------------------------
    -- Call the LOCK_ROW for each child record --
    ---------------------------------------------
    lock_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_let_rec
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:LETV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_lock_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      i := p_letv_tbl.FIRST;
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
            p_letv_rec                     => p_letv_tbl(i));
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
        EXIT WHEN (i = p_letv_tbl.LAST);
        i := p_letv_tbl.NEXT(i);
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
  --------------------------------------
  -- PL/SQL TBL lock_row for:LETV_TBL --
  --------------------------------------
  PROCEDURE lock_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_lock_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has recrods in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      lock_row(
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_letv_tbl                     => p_letv_tbl,
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
  ---------------------------------------
  -- update_row for:OKS_LEVEL_ELEMENTS --
  ---------------------------------------
  PROCEDURE update_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_let_rec                      IN let_rec_type,
    x_let_rec                      OUT NOCOPY let_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_let_rec                      let_rec_type := p_let_rec;
    l_def_let_rec                  let_rec_type;
    l_row_notfound                 BOOLEAN := TRUE;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_let_rec IN let_rec_type,
      x_let_rec OUT NOCOPY let_rec_type
    ) RETURN VARCHAR2 IS
      l_let_rec                      let_rec_type;
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_let_rec := p_let_rec;
      -- Get current database values
      l_let_rec := get_rec(p_let_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_let_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.id := l_let_rec.id;
        END IF;
        IF (x_let_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.cle_id := l_let_rec.cle_id;
        END IF;
        IF (x_let_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.dnz_chr_id := l_let_rec.dnz_chr_id;
        END IF;
        IF (x_let_rec.parent_cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.parent_cle_id := l_let_rec.parent_cle_id;
        END IF;
        IF (x_let_rec.sequence_number = OKC_API.G_MISS_CHAR)
        THEN
          x_let_rec.sequence_number := l_let_rec.sequence_number;
        END IF;
        IF (x_let_rec.date_start = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_start := l_let_rec.date_start;
        END IF;
        IF (x_let_rec.date_end = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_end := l_let_rec.date_end;
        END IF;
        IF (x_let_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.amount := l_let_rec.amount;
        END IF;
        IF (x_let_rec.date_receivable_gl = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_receivable_gl := l_let_rec.date_receivable_gl;
        END IF;
        IF (x_let_rec.date_revenue_rule_start = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_revenue_rule_start := l_let_rec.date_revenue_rule_start;
        END IF;
        IF (x_let_rec.date_transaction = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_transaction := l_let_rec.date_transaction;
        END IF;
        IF (x_let_rec.date_due = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_due := l_let_rec.date_due;
        END IF;
        IF (x_let_rec.date_print = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_print := l_let_rec.date_print;
        END IF;
        IF (x_let_rec.date_to_interface = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_to_interface := l_let_rec.date_to_interface;
        END IF;
        IF (x_let_rec.date_completed = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.date_completed := l_let_rec.date_completed;
        END IF;
        IF (x_let_rec.object_version_number = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.object_version_number := l_let_rec.object_version_number;
        END IF;
        IF (x_let_rec.rul_id = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.rul_id := l_let_rec.rul_id;
        END IF;
        IF (x_let_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.created_by := l_let_rec.created_by;
        END IF;
        IF (x_let_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.creation_date := l_let_rec.creation_date;
        END IF;
        IF (x_let_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_let_rec.last_updated_by := l_let_rec.last_updated_by;
        END IF;
        IF (x_let_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_let_rec.last_update_date := l_let_rec.last_update_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    -------------------------------------------
    -- Set_Attributes for:OKS_LEVEL_ELEMENTS --
    -------------------------------------------
    FUNCTION Set_Attributes (
      p_let_rec IN let_rec_type,
      x_let_rec OUT NOCOPY let_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_let_rec := p_let_rec;
      x_let_rec.OBJECT_VERSION_NUMBER := p_let_rec.OBJECT_VERSION_NUMBER + 1;
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
      p_let_rec,                         -- IN
      l_let_rec);                        -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_let_rec, l_def_let_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    UPDATE OKS_LEVEL_ELEMENTS
    SET CLE_ID = l_def_let_rec.cle_id,
        DNZ_CHR_ID = l_def_let_rec.dnz_chr_id,
        PARENT_CLE_ID = l_def_let_rec.parent_cle_id,
        SEQUENCE_NUMBER = l_def_let_rec.sequence_number,
        DATE_START = l_def_let_rec.date_start,
        DATE_END = l_def_let_rec.date_end,
        AMOUNT = l_def_let_rec.amount,
        DATE_RECEIVABLE_GL = l_def_let_rec.date_receivable_gl,
        DATE_REVENUE_RULE_START = l_def_let_rec.date_revenue_rule_start,
        DATE_TRANSACTION = l_def_let_rec.date_transaction,
        DATE_DUE = l_def_let_rec.date_due,
        DATE_PRINT = l_def_let_rec.date_print,
        DATE_TO_INTERFACE = l_def_let_rec.date_to_interface,
        DATE_COMPLETED = l_def_let_rec.date_completed,
        OBJECT_VERSION_NUMBER = l_def_let_rec.object_version_number,
        RUL_ID = l_def_let_rec.rul_id,
        CREATED_BY = l_def_let_rec.created_by,
        CREATION_DATE = l_def_let_rec.creation_date,
        LAST_UPDATED_BY = l_def_let_rec.last_updated_by,
        LAST_UPDATE_DATE = l_def_let_rec.last_update_date
    WHERE ID = l_def_let_rec.id;

    x_let_rec := l_let_rec;
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
  -- update_row for:OKS_LEVEL_ELEMENTS_V --
  -----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type,
    x_letv_rec                     OUT NOCOPY letv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_letv_rec                     letv_rec_type := p_letv_rec;
    l_def_letv_rec                 letv_rec_type;
    l_db_letv_rec                  letv_rec_type;
    l_let_rec                      let_rec_type;
    lx_let_rec                     let_rec_type;
    -------------------------------
    -- FUNCTION fill_who_columns --
    -------------------------------
    FUNCTION fill_who_columns (
      p_letv_rec IN letv_rec_type
    ) RETURN letv_rec_type IS
      l_letv_rec letv_rec_type := p_letv_rec;
    BEGIN
      l_letv_rec.LAST_UPDATE_DATE := SYSDATE;
      l_letv_rec.LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
--      l_letv_rec.LAST_UPDATE_LOGIN := FND_GLOBAL.LOGIN_ID;
      RETURN(l_letv_rec);
    END fill_who_columns;
    ----------------------------------
    -- FUNCTION populate_new_record --
    ----------------------------------
    FUNCTION populate_new_record (
      p_letv_rec IN letv_rec_type,
      x_letv_rec OUT NOCOPY letv_rec_type
    ) RETURN VARCHAR2 IS
      l_row_notfound                 BOOLEAN := TRUE;
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_letv_rec := p_letv_rec;
      -- Get current database values
      -- NOTE: Never assign the OBJECT_VERSION_NUMBER.  Force the user to pass it
      --       so it may be verified through LOCK_ROW.
      l_db_letv_rec := get_rec(p_letv_rec, l_return_status);
      IF (l_return_status = OKC_API.G_RET_STS_SUCCESS) THEN
        IF (x_letv_rec.id = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.id := l_db_letv_rec.id;
        END IF;
        IF (x_letv_rec.cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.cle_id := l_db_letv_rec.cle_id;
        END IF;
        IF (x_letv_rec.dnz_chr_id = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.dnz_chr_id := l_db_letv_rec.dnz_chr_id;
        END IF;
        IF (x_letv_rec.parent_cle_id = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.parent_cle_id := l_db_letv_rec.parent_cle_id;
        END IF;
        IF (x_letv_rec.sequence_number = OKC_API.G_MISS_CHAR)
        THEN
          x_letv_rec.sequence_number := l_db_letv_rec.sequence_number;
        END IF;
        IF (x_letv_rec.date_start = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_start := l_db_letv_rec.date_start;
        END IF;
        IF (x_letv_rec.date_end = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_end := l_db_letv_rec.date_end;
        END IF;
        IF (x_letv_rec.amount = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.amount := l_db_letv_rec.amount;
        END IF;
        IF (x_letv_rec.date_revenue_rule_start = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_revenue_rule_start := l_db_letv_rec.date_revenue_rule_start;
        END IF;
        IF (x_letv_rec.date_receivable_gl = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_receivable_gl := l_db_letv_rec.date_receivable_gl;
        END IF;
        IF (x_letv_rec.date_transaction = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_transaction := l_db_letv_rec.date_transaction;
        END IF;
        IF (x_letv_rec.date_due = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_due := l_db_letv_rec.date_due;
        END IF;
        IF (x_letv_rec.date_print = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_print := l_db_letv_rec.date_print;
        END IF;
        IF (x_letv_rec.date_to_interface = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_to_interface := l_db_letv_rec.date_to_interface;
        END IF;
        IF (x_letv_rec.date_completed = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.date_completed := l_db_letv_rec.date_completed;
        END IF;
        IF (x_letv_rec.rul_id = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.rul_id := l_db_letv_rec.rul_id;
        END IF;
        IF (x_letv_rec.created_by = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.created_by := l_db_letv_rec.created_by;
        END IF;
        IF (x_letv_rec.creation_date = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.creation_date := l_db_letv_rec.creation_date;
        END IF;
        IF (x_letv_rec.last_updated_by = OKC_API.G_MISS_NUM)
        THEN
          x_letv_rec.last_updated_by := l_db_letv_rec.last_updated_by;
        END IF;
        IF (x_letv_rec.last_update_date = OKC_API.G_MISS_DATE)
        THEN
          x_letv_rec.last_update_date := l_db_letv_rec.last_update_date;
        END IF;
      END IF;
      RETURN(l_return_status);
    END populate_new_record;
    ---------------------------------------------
    -- Set_Attributes for:OKS_LEVEL_ELEMENTS_V --
    ---------------------------------------------
    FUNCTION Set_Attributes (
      p_letv_rec IN letv_rec_type,
      x_letv_rec OUT NOCOPY letv_rec_type
    ) RETURN VARCHAR2 IS
      l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    BEGIN
      x_letv_rec := p_letv_rec;
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
      p_letv_rec,                        -- IN
      x_letv_rec);                       -- OUT
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := populate_new_record(l_letv_rec, l_def_letv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_def_letv_rec := fill_who_columns(l_def_letv_rec);
    --- Validate all non-missing attributes (Item Level Validation)
    l_return_status := Validate_Attributes(l_def_letv_rec);
    --- If any errors happen abort API
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    l_return_status := Validate_Record(l_def_letv_rec, l_db_letv_rec);
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
      p_letv_rec                     => p_letv_rec);
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;

    -----------------------------------------
    -- Move VIEW record to "Child" records --
    -----------------------------------------
    migrate(l_def_letv_rec, l_let_rec);
    -----------------------------------------------
    -- Call the UPDATE_ROW for each child record --
    -----------------------------------------------
    update_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_let_rec,
      lx_let_rec
    );
    IF (l_return_status = OKC_API.G_RET_STS_UNEXP_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_UNEXPECTED_ERROR;
    ELSIF (l_return_status = OKC_API.G_RET_STS_ERROR) THEN
      RAISE OKC_API.G_EXCEPTION_ERROR;
    END IF;
    migrate(lx_let_rec, l_def_letv_rec);
    x_letv_rec := l_def_letv_rec;
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
  ----------------------------------------
  -- PL/SQL TBL update_row for:letv_tbl --
  ----------------------------------------
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_update_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      i := p_letv_tbl.FIRST;
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
            p_letv_rec                     => p_letv_tbl(i),
            x_letv_rec                     => x_letv_tbl(i));
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
        EXIT WHEN (i = p_letv_tbl.LAST);
        i := p_letv_tbl.NEXT(i);
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

  ----------------------------------------
  -- PL/SQL TBL update_row for:LETV_TBL --
  ----------------------------------------
  -- This procedure is the same as the one above except it does not have a "px_error_tbl" argument.
  -- This procedure was create for backward compatibility and simply is a wrapper for the one above.
  PROCEDURE update_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    x_letv_tbl                     OUT NOCOPY letv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_update_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      update_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_letv_tbl                     => p_letv_tbl,
        x_letv_tbl                     => x_letv_tbl,
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
  ---------------------------------------
  -- delete_row for:OKS_LEVEL_ELEMENTS --
  ---------------------------------------
  PROCEDURE delete_row(
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_let_rec                      IN let_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'B_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_let_rec                      let_rec_type := p_let_rec;
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

    DELETE FROM OKS_LEVEL_ELEMENTS
     WHERE ID = p_let_rec.id;

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
  -----------------------------------------
  -- delete_row for:OKS_LEVEL_ELEMENTS_V --
  -----------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_rec                     IN letv_rec_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_letv_rec                     letv_rec_type := p_letv_rec;
    l_let_rec                      let_rec_type;
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
    migrate(l_letv_rec, l_let_rec);
    -----------------------------------------------
    -- Call the DELETE_ROW for each child record --
    -----------------------------------------------
    delete_row(
      p_init_msg_list,
      l_return_status,
      x_msg_count,
      x_msg_data,
      l_let_rec
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
  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_LEVEL_ELEMENTS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type,
    px_error_tbl                   IN OUT NOCOPY OKC_API.ERROR_TBL_TYPE) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_error_tbl_delete_row';
    i                              NUMBER := 0;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      i := p_letv_tbl.FIRST;
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
            p_letv_rec                     => p_letv_tbl(i));
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
        EXIT WHEN (i = p_letv_tbl.LAST);
        i := p_letv_tbl.NEXT(i);
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

  ----------------------------------------------------
  -- PL/SQL TBL delete_row for:OKS_LEVEL_ELEMENTS_V --
  ----------------------------------------------------
  PROCEDURE delete_row(
    p_api_version                  IN NUMBER,
    p_init_msg_list                IN VARCHAR2,
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,
    p_letv_tbl                     IN letv_tbl_type) IS

    l_api_version                  CONSTANT NUMBER := 1;
    l_api_name                     CONSTANT VARCHAR2(30) := 'V_tbl_delete_row';
    l_return_status                VARCHAR2(1) := OKC_API.G_RET_STS_SUCCESS;
    l_error_tbl                    OKC_API.ERROR_TBL_TYPE;
  BEGIN
    OKC_API.init_msg_list(p_init_msg_list);
    -- Make sure PL/SQL table has records in it before passing
    IF (p_letv_tbl.COUNT > 0) THEN
      delete_row (
        p_api_version                  => p_api_version,
        p_init_msg_list                => OKC_API.G_FALSE,
        x_return_status                => x_return_status,
        x_msg_count                    => x_msg_count,
        x_msg_data                     => x_msg_data,
        p_letv_tbl                     => p_letv_tbl,
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

END OKS_BILL_LEVEL_ELEMENTS_PVT ;

/
